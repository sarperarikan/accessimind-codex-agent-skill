param(
  [Parameter(Mandatory = $true)]
  [string[]]$Urls,
  [string]$ProjectName = "",
  [string]$OutputDir = "",
  [int]$MotorTabSteps = 350,
  [string]$RepoRoot = "",
  [string]$StorageStatePath = "",
  [string]$CdpUrl = ""
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  if ($RepoRoot -and (Test-Path $RepoRoot)) { return (Resolve-Path $RepoRoot).Path }
  return (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
}

function Get-NpxPath {
  $default = "C:\Program Files\nodejs\npx.cmd"
  if (Test-Path $default) { return $default }
  $cmd = Get-Command npx.cmd -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  throw "npx.cmd not found."
}

function Safe-Name([string]$text) {
  $name = $text -replace "^https?://", ""
  $name = $name -replace "[^a-zA-Z0-9\-]+", "-"
  return $name.Trim("-").ToLower()
}

function Write-Utf8Bom([string]$path, [string]$content) {
  if ($null -eq $content) { $content = "" }
  $content = $content.Normalize([Text.NormalizationForm]::FormC)
  $content = $content.Replace([string][char]0x200B, "")
  $content = $content.Replace([string][char]0xFEFF, "")
  if ($content.Contains([char]0xFFFD)) {
    throw "Encoding integrity check failed for $path. Possible mojibake detected."
  }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $enc)
}

function Assert-Utf8RoundTrip([string]$path, [string[]]$expectedTokens) {
  $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  if ($content.Contains([char]0xFFFD)) {
    throw "Encoding verification failed for $path. Replacement character detected after write."
  }
  foreach ($token in @($expectedTokens | Where-Object { $_ })) {
    if (-not $content.Contains($token)) {
      throw "Encoding verification failed for $path. Expected token not found: $token"
    }
  }
}

function Repair-Utf8Artifact([string]$RepairScript, [string]$Path) {
  if (-not (Test-Path $Path)) { return }
  & py -3 $RepairScript $Path | Out-Null
}

function Invoke-WithRetry([scriptblock]$Action, [int]$Attempts = 3, [int]$DelayMs = 1200) {
  $lastError = $null
  for ($try = 1; $try -le $Attempts; $try++) {
    try {
      return & $Action
    } catch {
      $lastError = $_
      if ($try -lt $Attempts) {
        Start-Sleep -Milliseconds $DelayMs
      }
    }
  }
  if ($lastError) { throw $lastError }
}

function Invoke-CdpProbe([string]$NpxPath, [string]$ProbeScript, [string]$Url, [string]$ScreenshotPath, [int]$TabSteps, [string]$CdpUrl) {
  if (-not $CdpUrl) { throw "CDP URL is mandatory for the CDP-native collector." }
  $args = @("--yes", "--package", "chrome-remote-interface", "--package", "axe-core", "node", $ProbeScript, "--url", $Url, "--screenshot", $ScreenshotPath, "--tab-steps", $TabSteps, "--cdp-url", $CdpUrl)
  $raw = & $NpxPath @args
  return ($raw -join "`n" | ConvertFrom-Json)
}

function Invoke-AccessSurfaceAnalyzer([string]$AnalyzerScript, [string]$InputPath, [string]$OutputPath) {
  & py -3 $AnalyzerScript --input $InputPath --output $OutputPath | Out-Null
  return (Get-Content -Path $OutputPath -Raw | ConvertFrom-Json)
}

function New-CookieInspectionState {
  return [pscustomobject]@{
    inspected = $false
    dialogCount = $null
    accepted = $false
    acceptedActions = @()
  }
}

function Get-WcagTagString($tags) {
  $wcagTags = @($tags | Where-Object { $_ -match '^wcag' })
  if (@($wcagTags).Count -gt 0) {
    return ($wcagTags -join ', ')
  }
  return 'axe-rule'
}

function Get-AxeSeverity([string]$impact) {
  $normalizedImpact = if ($null -eq $impact) { '' } else { $impact.ToLower() }
  switch ($normalizedImpact) {
    'critical' { return 'high' }
    'serious' { return 'high' }
    'moderate' { return 'medium' }
    'minor' { return 'low' }
    default { return 'medium' }
  }
}

function Resolve-ElementIndexFromTarget([string]$target, $elements) {
  if (-not $target -or -not $elements) { return -1 }
  $exact = @($elements | Where-Object { $_.cssPath -eq $target } | Select-Object -First 1)[0]
  if ($exact) { return [int]$exact.idx }
  if ($target -match '#([A-Za-z0-9\-_]+)') {
    $id = $Matches[1]
    $byId = @($elements | Where-Object { $_.id -eq $id } | Select-Object -First 1)[0]
    if ($byId) { return [int]$byId.idx }
  }
  $contains = @($elements | Where-Object { $_.cssPath -and $_.cssPath.EndsWith($target) } | Select-Object -First 1)[0]
  if ($contains) { return [int]$contains.idx }
  return -1
}

function Add-FindingUnique([ref]$Findings, $Finding) {
  $current = @($Findings.Value)
  $exists = @($current | Where-Object {
      $_.title -eq $Finding.title -and
      $_.selectorHint -eq $Finding.selectorHint -and
      $_.elementIndex -eq $Finding.elementIndex
    } | Select-Object -First 1)[0]
  if (-not $exists) {
    $Findings.Value += $Finding
  }
}

function Add-AxeFindings($axeResult, $elements, [ref]$Findings) {
  if (-not $axeResult -or -not $axeResult.violations) { return }
  foreach ($violation in @($axeResult.violations)) {
    foreach ($node in @($violation.nodes)) {
      $target = @($node.target | Select-Object -First 1)[0]
      $elementIndex = Resolve-ElementIndexFromTarget -target $target -elements $elements
      $summary = if ($node.failureSummary) { $node.failureSummary } else { $violation.description }
      $selectorHint = if ($target) { [string]$target } else { [string]$violation.id }
      $fix = if ($violation.helpUrl) {
        "Axe kural yonu: $($violation.help). Ayrintili teknik rehber: $($violation.helpUrl)"
      } else {
        "Axe kural yonu: $($violation.help)"
      }
      $finding = New-Finding -severity (Get-AxeSeverity -impact $violation.impact) -wcag (Get-WcagTagString -tags $violation.tags) -title ("axe: " + $violation.help) -selectorHint $selectorHint -issue $summary -fix $fix -elementIndex $elementIndex
      Add-FindingUnique -Findings $Findings -Finding $finding
    }
  }
}

function Get-ElementByFinding($finding, $elements) {
  if (($finding.elementIndex -gt 0) -and $elements) {
    return @($elements | Where-Object { $_.idx -eq $finding.elementIndex } | Select-Object -First 1)[0]
  }
  return $null
}

function Get-FocusEvidence($element, $focusTrail) {
  if (-not $element) { return $null }
  return @($focusTrail | Where-Object {
      ($_.tag -eq $element.tag) -and (
        ($element.id -and $_.id -eq $element.id) -or
        ($element.name -and $_.name -and $_.name -like "*$($element.name.Substring(0, [Math]::Min($element.name.Length, 20)))*")
      )
    } | Select-Object -First 1)[0]
}

function Get-SpokenEvidence($element, $blindSpeechTrace) {
  if (-not $element -or -not $blindSpeechTrace) { return $null }
  $needle = if ($element.name) { $element.name.Substring(0, [Math]::Min($element.name.Length, 20)) } else { $element.tag }
  return @($blindSpeechTrace.events | Where-Object { $_.spokenPhrase -and $_.spokenPhrase -like "*$needle*" } | Select-Object -First 1)[0]
}

function Get-FindingNarrative($finding, [string]$url, $elements, $focusTrail, $blindSpeechTrace) {
  $element = Get-ElementByFinding -finding $finding -elements $elements
  $focusEvidence = Get-FocusEvidence -element $element -focusTrail $focusTrail
  $spokenEvidence = Get-SpokenEvidence -element $element -blindSpeechTrace $blindSpeechTrace

  $elementLabel = if ($element) {
    $namePart = if ($element.name) { "'$($element.name)'" } else { 'adsız öğe' }
    "$($element.tag) $namePart"
  } elseif ($finding.selectorHint) {
    $finding.selectorHint
  } else {
    'ilgili öğe'
  }

  switch ($finding.title) {
    'Broken link semantics' {
      $behavior = "Klavye ile ilerlerken $elementLabel link gibi sunuluyor, ancak hedefi gerçek bir sayfaya gitmiyor."
      $wcagReason = 'Bu durum WCAG 2.4.4 ve 4.1.2 açısından sorun yaratır; kullanıcı linkin ne yapacağını ve nereye gideceğini anlayamaz.'
      $toBe = 'Aynı kontrol bir sayfaya götürüyorsa gerçek URL ile link olmalı; panel açıyor ya da işlem yapıyorsa button olarak yeniden kurgulanmalı.'
    }
    'Unnamed interactive element' {
      $behavior = "Tab ile ulaşılan $elementLabel odağa geliyor ama erişilebilir adı net olmadığı için kullanıcı neye geldiğini güvenilir biçimde anlayamıyor."
      $wcagReason = 'Bu durum WCAG 4.1.2 kapsamında isim, rol ve değer bilgisini zayıflatır; ekran okuyucu ve sesli komut kullanımı zorlaşır.'
      $toBe = 'Öğe görünür etiketiyle uyumlu, ayırt edici bir erişilebilir ada sahip olmalı.'
    }
    'Missing alt text' {
      $behavior = "$elementLabel görseli içerikte mevcut, ancak ekran okuyucu tarafında anlamlı alternatif metin taşımıyor."
      $wcagReason = 'Bu durum WCAG 1.1.1 kapsamında görsel bilginin kör kullanıcıya taşınmasını engeller.'
      $toBe = 'Görsel bilgi taşıyorsa anlamlı bir alt metni olmalı; dekoratifse boş alt değeri kullanılmalı.'
    }
    'Small target size' {
      $size = if ($element) { "$($element.width)x$($element.height) px" } else { '44x44 px altı' }
      $behavior = "$elementLabel kontrolü etkileşimli, ancak tıklanabilir alanı yaklaşık $size olduğu için rahat hedeflenemiyor."
      $wcagReason = 'Bu durum WCAG 2.5.8 kapsamında özellikle motor kısıtlı kullanıcılar ve mobil kullanım için hata riskini artırır.'
      $toBe = 'Kontrolün aktif alanı en az 44x44 CSS piksel olacak şekilde büyütülmeli.'
    }
    'Document language missing' {
      $behavior = 'Sayfa yükleniyor ancak kök dokümanda dil bilgisi tanımlı olmadığı için yardımcı teknolojiler doğru telaffuz ve dil kurallarını seçemiyor.'
      $wcagReason = 'Bu durum WCAG 3.1.1 kapsamında sayfanın varsayılan dilinin programatik olarak belirlenmesini engeller.'
      $toBe = 'Kök html elemanında doğru lang değeri tanımlanmalı.'
    }
    default {
      $behavior = $finding.issue
      $wcagReason = 'Bu bulgu ilgili WCAG kriterine karşı davranışsal uyumsuzluk gösteriyor.'
      $toBe = $finding.fix
    }
  }

  $evidenceParts = @()
  if ($focusEvidence) {
    $evidenceParts += "Tab adımı $($focusEvidence.step) sırasında odak doğrulandı."
  }
  if ($spokenEvidence) {
    $evidenceParts += "NVDA çıktısı: '$($spokenEvidence.spokenPhrase)'."
  }
  if ($element -and $element.href) {
    $evidenceParts += "Hedef: $($element.href)."
  }
  if ($element -and $element.width -and $element.height) {
    $evidenceParts += "Ölçü: $($element.width)x$($element.height) px."
  }
  if (-not $evidenceParts) {
    $evidenceParts += $finding.issue
  }

  return [pscustomobject]@{
    elementLabel = $elementLabel
    behavior = $behavior
    wcagReason = $wcagReason
    toBe = $toBe
    evidenceNarrative = ($evidenceParts -join ' ')
  }
}

function New-BusinessAnalystNote($finding, [string]$url, $elements, $focusTrail, $blindSpeechTrace) {
  $narrative = Get-FindingNarrative -finding $finding -url $url -elements $elements -focusTrail $focusTrail -blindSpeechTrace $blindSpeechTrace
  return [pscustomobject]@{
    asIs = "Bu sayfada $($narrative.behavior) $($narrative.evidenceNarrative)"
    toBe = "Beklenen durumda $($narrative.toBe) Böylece kullanıcı kontrolün ne yaptığını anlayıp akışı kesintisiz tamamlayabilmeli."
    userImpact = $narrative.wcagReason
    devAction = $finding.fix
    baAction = "Acceptance criteria'yı davranış üzerinden yaz: kullanıcı $($narrative.elementLabel) üzerinde beklenen işlemi klavye ve ekran okuyucu ile tamamlayabilsin."
    poAction = "Bu bulguyu $($finding.wcag) ve kullanıcı akış kesintisi riskine göre önceliklendir."
    acceptanceCriteria = 'Klavye odağı, ekran okuyucu anonsu ve beklenen işlev aynı öğe üzerinde tutarlı çalışmalı.'
    owner = 'TBD'
    eta = 'TBD'
  }
}

function Assert-FileHasContent([string]$path, [string]$label) {
  if (-not (Test-Path $path)) {
    throw "$label file was not created: $path"
  }
  $item = Get-Item $path
  if ($item.Length -le 0) {
    throw "$label file is empty: $path"
  }
}

function Assert-ScrollCoverage($coverage, [string]$url) {
  $expected = @(0, 20, 40, 60, 80, 100)
  $actual = @($coverage | Where-Object { $_ -and ($expected -contains $_.checkpoint) } | ForEach-Object { [int]$_.checkpoint } | Select-Object -Unique | Sort-Object)
  if ($actual.Count -ne $expected.Count) {
    throw "Deterministic scroll coverage failed for $url. Expected checkpoints: $($expected -join ', '); actual: $($actual -join ', ')."
  }
  foreach ($point in $coverage) {
    if (($null -eq $point.scrollHeight) -or ($point.scrollHeight -le 0) -or ($null -eq $point.viewportHeight) -or ($point.viewportHeight -le 0)) {
      throw "Invalid scroll coverage metrics captured for $url at checkpoint $($point.checkpoint)."
    }
  }
  return @($coverage)
}

function Assert-FullPersonaEvidence($dom, $focusTrail, $scrollCoverage, $vision, [string]$screenshotPath, [string]$url) {
  if (-not $dom) {
    throw "DOM evidence was not captured for $url."
  }
  if (($null -eq $dom.count) -or ($dom.count -le 0)) {
    throw "DOM element count is invalid for $url."
  }
  if (($null -eq $dom.elements) -or (@($dom.elements).Count -le 0)) {
    throw "DOM element inventory is empty for $url."
  }
  if (@($focusTrail).Count -le 0) {
    throw "Keyboard focus trail was not captured for $url."
  }
  $meaningfulFocus = @($focusTrail | Where-Object { $_.tag -or $_.id -or $_.name }).Count
  if ($meaningfulFocus -le 0) {
    throw "Keyboard traversal did not capture any meaningful focus targets for $url."
  }
  Assert-ScrollCoverage -coverage $scrollCoverage -url $url | Out-Null
  if (-not $vision) {
    throw "Vision evidence was not captured for $url."
  }
  if (-not $vision.screenshotRequired) {
    throw "Vision evidence contract is invalid for $url."
  }
  Assert-FileHasContent -path $screenshotPath -label 'Screenshot'
  return 'verified'
}

function New-Finding([string]$severity, [string]$wcag, [string]$title, [string]$selectorHint, [string]$issue, [string]$fix, [int]$elementIndex) {
  return [pscustomobject]@{
    severity = $severity
    wcag = $wcag
    title = $title
    selectorHint = $selectorHint
    issue = $issue
    fix = $fix
    elementIndex = $elementIndex
  }
}

$root = Get-RepoRoot
$probeScript = Join-Path $root 'scripts\deterministic_cdp_probe.cjs'
if (-not (Test-Path $probeScript)) { throw "Deterministic CDP probe not found: $probeScript" }
$accessAnalyzerScript = Join-Path $root 'scripts\langchain_access_surface_analyzer.py'
if (-not (Test-Path $accessAnalyzerScript)) { throw "LangChain access surface analyzer not found: $accessAnalyzerScript" }
$llmCommentaryScript = Join-Path $root 'scripts\langchain_a11y_commentary.py'
if (-not (Test-Path $llmCommentaryScript)) { throw "LangChain accessibility commentary generator not found: $llmCommentaryScript" }
$repairScript = Join-Path $root 'scripts\repair_utf8_artifact.py'
if (-not (Test-Path $repairScript)) { throw "UTF-8 repair helper not found: $repairScript" }
$npxPath = Get-NpxPath

$nvdaRunner = Join-Path $root 'skills\nvda-portable-a11y-audit\scripts\invoke-nvda-playwright-audit.ps1'
if (-not (Test-Path $nvdaRunner)) { throw "NVDA runner not found: $nvdaRunner" }

if (-not $ProjectName) {
  $hostFirstLabel = (([uri]$Urls[0]).Host -split '\.')[0]
  $ProjectName = if ($hostFirstLabel) { Safe-Name $hostFirstLabel } else { 'audit' }
}

$datePart = Get-Date -Format 'yyyy-MM-dd'
if (-not $OutputDir) {
  $OutputDir = Join-Path $root ("reports\{0}-{1}" -f (Safe-Name $ProjectName), $datePart)
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $OutputDir 'pages') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $OutputDir 'blind') -Force | Out-Null

$blindOutputDir = Join-Path $OutputDir 'blind'
$nvdaRunnerParams = @{
  Urls = @($Urls)
  OutputDir = $blindOutputDir
  RepoRoot = $root
  StorageStatePath = $StorageStatePath
  CdpUrl = $CdpUrl
}
& $nvdaRunner @nvdaRunnerParams | Out-Null
$blindSummaryPath = Join-Path $blindOutputDir 'summary.json'
if (-not (Test-Path $blindSummaryPath)) { throw "Blind-side summary not found: $blindSummaryPath" }
$blindSummary = Get-Content -Path $blindSummaryPath -Raw | ConvertFrom-Json
$blindPagesByUrl = @{}
foreach ($blindPage in @($blindSummary.pages)) {
  if ($blindPage.url) {
    $blindPagesByUrl[$blindPage.url] = $blindPage
  }
}

$pages = @()
$allFindings = @()

foreach ($url in $Urls) {
  $slug = Safe-Name $url
  $pageDir = Join-Path (Join-Path $OutputDir 'pages') $slug
  New-Item -ItemType Directory -Path $pageDir -Force | Out-Null

  $shot = Join-Path $pageDir 'base.png'
  $probeJson = Join-Path $pageDir 'probe.json'
  $barrierJson = Join-Path $pageDir 'barrier-analysis.json'

  $probe = Invoke-WithRetry -Action {
    Invoke-CdpProbe -NpxPath $npxPath -ProbeScript $probeScript -Url $url -ScreenshotPath $shot -TabSteps $MotorTabSteps -CdpUrl $CdpUrl
  }
  Write-Utf8Bom -path $probeJson -content ($probe | ConvertTo-Json -Depth 15)
  $barrierAnalysis = Invoke-AccessSurfaceAnalyzer -AnalyzerScript $accessAnalyzerScript -InputPath $probeJson -OutputPath $barrierJson

  $cookie = if ($probe.cookieDialog) { $probe.cookieDialog } else { New-CookieInspectionState }
  if ($probe.cookieDialog -and -not ($cookie.PSObject.Properties.Name -contains 'inspected')) {
    $cookie | Add-Member -NotePropertyName inspected -NotePropertyValue $true -Force
  }

  $dom = $probe.dom
  $axe = $probe.axe
  $cdpAccessibility = $probe.cdpAccessibility
  $vision = $probe.vision
  $scrollCoverage = Assert-ScrollCoverage -coverage $probe.scrollCoverage -url $url
  $statefulCoverage = @($probe.statefulCoverage)
  $localization = $probe.localization
  if (-not $localization) { throw "Localization evidence was not captured for $url." }
  $focusTrail = @($probe.focusTrail)
  $uniqueFocusTargets = $probe.uniqueFocusTargets
  $coverageStatus = Assert-FullPersonaEvidence -dom $dom -focusTrail $focusTrail -scrollCoverage $scrollCoverage -vision $vision -screenshotPath $shot -url $url

  $blindPage = $null
  if ($blindPagesByUrl.ContainsKey($probe.meta.url)) {
    $blindPage = $blindPagesByUrl[$probe.meta.url]
  } elseif ($blindPagesByUrl.ContainsKey($url)) {
    $blindPage = $blindPagesByUrl[$url]
  }
  if (-not $blindPage) {
    throw "Blind-side evidence was not found for $url."
  }
  if ($barrierAnalysis.blocked) {
    throw "Rendered surface for $url is blocked: $($barrierAnalysis.summary). Recommended path: $($barrierAnalysis.nextStep)"
  }

  $findings = @()
  if ($cookie.inspected -and $cookie.dialogCount -gt 0 -and -not $cookie.accepted) {
    $findings += New-Finding -severity 'high' -wcag '2.1.1' -title 'Cookie dialog blocks flow' -selectorHint 'cookie-dialog' -issue 'Cookie dialog detected but accept action was not confirmed.' -fix 'Make cookie dialog keyboard-operable and provide a clear accept control.' -elementIndex -1
  }
  if ($cookie.inspected -and $cookie.dialogCount -gt 0 -and $cookie.accepted) {
    $findings += New-Finding -severity 'info' -wcag 'Process' -title 'Cookie dialog handled' -selectorHint 'cookie-dialog' -issue 'Cookie dialog evaluated and accepted before scan.' -fix 'Keep this sequence stable on all pages.' -elementIndex -1
  }
  if (-not $localization.lang) {
    $findings += New-Finding -severity 'medium' -wcag '3.1.1' -title 'Document language missing' -selectorHint 'html' -issue 'Document root does not expose a lang attribute.' -fix 'Set a valid document language on the html element.' -elementIndex -1
  }

  foreach ($el in @($dom.elements)) {
    if ($el.focusable -and -not $el.name) {
      $findings += New-Finding -severity 'high' -wcag '4.1.2' -title 'Unnamed interactive element' -selectorHint "$($el.tag)#$($el.id)" -issue 'Focusable element has no accessible name.' -fix 'Add visible label or aria-label.' -elementIndex $el.idx
    }
    if ($el.tag -eq 'A' -and (($el.href -eq '#') -or (($el.href + '').ToLower().StartsWith('javascript:')))) {
      $findings += New-Finding -severity 'high' -wcag '4.1.2' -title 'Broken link semantics' -selectorHint "$($el.tag)#$($el.id)" -issue 'Anchor uses placeholder href.' -fix 'Use a real URL or native button semantics.' -elementIndex $el.idx
    }
    if ($el.tag -eq 'IMG' -and -not $el.alt) {
      $findings += New-Finding -severity 'medium' -wcag '1.1.1' -title 'Missing alt text' -selectorHint "$($el.tag)#$($el.id)" -issue 'Image has no alternative text.' -fix 'Add meaningful alt text or empty alt for decorative image.' -elementIndex $el.idx
    }
    if ($el.focusable -and (($el.width -gt 0 -and $el.width -lt 44) -or ($el.height -gt 0 -and $el.height -lt 44))) {
      $findings += New-Finding -severity 'medium' -wcag '2.5.8' -title 'Small target size' -selectorHint "$($el.tag)#$($el.id)" -issue 'Interactive target below 44x44.' -fix 'Increase hit area to at least 44x44 CSS px.' -elementIndex $el.idx
    }
  }
  Add-AxeFindings -axeResult $axe -elements $dom.elements -Findings ([ref]$findings)

  $baFindings = @()
  foreach ($f in $findings) {
    $baFindings += [pscustomobject]@{
      finding = $f
      narrative = Get-FindingNarrative -finding $f -url $url -elements $dom.elements -focusTrail $focusTrail -blindSpeechTrace $blindPage.speechTrace
      businessAnalysis = New-BusinessAnalystNote -finding $f -url $url -elements $dom.elements -focusTrail $focusTrail -blindSpeechTrace $blindPage.speechTrace
    }
  }

  $page = [pscustomobject]@{
    url = $probe.meta.url
    title = $probe.meta.title
    elementCount = $dom.count
    interactiveCount = $dom.interactiveCount
    coverageStatus = $coverageStatus
    cookieDialog = $cookie
    screenshot = $shot
    scrollCoverage = $scrollCoverage
    statefulCoverage = $statefulCoverage
    localization = $localization
    focusTrail = $focusTrail
    uniqueFocusTargets = $uniqueFocusTargets
    barrierAnalysis = $barrierAnalysis
    blindSpeechTrace = $blindPage.speechTrace
    blindCoverageStatus = $blindPage.coverageStatus
    axe = $axe
    cdpAccessibility = $cdpAccessibility
    vision = $vision
    elements = $dom.elements
    findings = $findings
    baFindings = $baFindings
  }
  Write-Utf8Bom -path (Join-Path $pageDir 'page.json') -content ($page | ConvertTo-Json -Depth 15)
  Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $pageDir 'page.json')
  $pages += $page
  $allFindings += $findings
}

$summary = [pscustomobject]@{
  createdAt = (Get-Date).ToString('o')
  projectName = $ProjectName
  outputDir = $OutputDir
  coverageSummary = [pscustomobject]@{
    verified = @($pages | Where-Object { $_.coverageStatus -eq 'verified' }).Count
  }
  pages = $pages
  findingCount = $allFindings.Count
}
Write-Utf8Bom -path (Join-Path $OutputDir 'summary.json') -content ($summary | ConvertTo-Json -Depth 15)
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'summary.json')
& py -3 $llmCommentaryScript --summary (Join-Path $OutputDir 'summary.json') --output (Join-Path $OutputDir 'llm-commentary.json') | Out-Null
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'llm-commentary.json')

$reportLang = @($pages | ForEach-Object { $_.localization.lang } | Where-Object { $_ } | Select-Object -First 1)[0]
if (-not $reportLang) { $reportLang = 'tr' }
$severityBuckets = @{
  high = @($allFindings | Where-Object { $_.severity -eq 'high' }).Count
  medium = @($allFindings | Where-Object { $_.severity -eq 'medium' }).Count
  info = @($allFindings | Where-Object { $_.severity -eq 'info' }).Count
}
$topPatterns = @($allFindings | Group-Object title | Sort-Object Count -Descending | Select-Object -First 8)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<!doctype html>')
[void]$sb.AppendLine(("<html lang=""{0}"">" -f [System.Web.HttpUtility]::HtmlEncode($reportLang)))
[void]$sb.AppendLine('<head>')
[void]$sb.AppendLine('<meta charset="UTF-8">')
[void]$sb.AppendLine('<meta name="viewport" content="width=device-width, initial-scale=1">')
[void]$sb.AppendLine(("<title>{0} Erisilebilirlik Denetim Raporu</title>" -f [System.Web.HttpUtility]::HtmlEncode($ProjectName)))
[void]$sb.AppendLine('<style>body{font-family:Segoe UI,Arial,sans-serif;line-height:1.6;margin:1rem;color:#17202a}table{border-collapse:collapse;width:100%;margin-bottom:1rem}th,td{border:1px solid #666;padding:.55rem;vertical-align:top;text-align:left}th{background:#efefef}.skip-link{position:absolute;left:-9999px}.skip-link:focus{left:1rem;top:1rem;background:#fff;border:2px solid #000;padding:.5rem;z-index:1000}a:focus,button:focus{outline:3px solid #005fcc;outline-offset:2px}.meta{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:.75rem;margin:1rem 0}.meta-card{border:1px solid #c9d3dd;padding:.85rem;background:#f8fafc}.pattern-card{border:1px solid #d7dde5;padding:.75rem;margin-bottom:.75rem;background:#fff}.sev-high{color:#8a1c1c;font-weight:700}.sev-medium{color:#8a5a00;font-weight:700}.sev-info{color:#0b5cab;font-weight:700}code{white-space:nowrap}.narrative{background:#f8fafc;border-left:4px solid #005fcc;padding:.75rem;margin:.75rem 0}</style>')
[void]$sb.AppendLine('</head>')
[void]$sb.AppendLine('<body>')
[void]$sb.AppendLine('<a class="skip-link" href="#content">Icerige atla</a>')
[void]$sb.AppendLine(("<h1>{0} Erisilebilirlik Denetim Raporu</h1>" -f [System.Web.HttpUtility]::HtmlEncode($ProjectName)))
[void]$sb.AppendLine('<p>Bu rapor Chrome uzerinden canli render alinarak, klavye yolu, NVDA konusma izi ve davranissal etkilesim kaniti ile hazirlanmistir.</p>')
[void]$sb.AppendLine('<section aria-labelledby="summary-title">')
[void]$sb.AppendLine('<h2 id="summary-title">Yonetici Ozeti</h2>')
[void]$sb.AppendLine('<div class="meta">')
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Tarih</strong><br>{0}</div>" -f $datePart))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Incelenen sayfa</strong><br>{0}</div>" -f $pages.Count))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Toplam bulgu</strong><br>{0}</div>" -f $allFindings.Count))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Dogrulanan kapsam</strong><br>verified={0}</div>" -f $summary.coverageSummary.verified))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>High</strong><br><span class=""sev-high"">{0}</span></div>" -f $severityBuckets.high))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Medium</strong><br><span class=""sev-medium"">{0}</span></div>" -f $severityBuckets.medium))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Info</strong><br><span class=""sev-info"">{0}</span></div>" -f $severityBuckets.info))
[void]$sb.AppendLine(("<div class=""meta-card""><strong>Gezinme derinligi</strong><br>Sayfa basina {0} Tab adimi ve coklu scroll checkpoint</div>" -f $MotorTabSteps))
[void]$sb.AppendLine('</div>')
[void]$sb.AppendLine('</section>')
[void]$sb.AppendLine('<section aria-labelledby="pattern-title">')
[void]$sb.AppendLine('<h2 id="pattern-title">Tekrarlayan Ana Problem Desenleri</h2>')
foreach ($pattern in $topPatterns) {
  [void]$sb.AppendLine(("<div class=""pattern-card""><strong>{0}</strong><br>Bu desen toplam <strong>{1}</strong> kez dogrulandi.</div>" -f [System.Web.HttpUtility]::HtmlEncode($pattern.Name), $pattern.Count))
}
[void]$sb.AppendLine('</section>')
[void]$sb.AppendLine('<nav aria-label="Icindekiler"><h2>Icindekiler</h2><ol>')

$idx = 0
foreach ($p in $pages) {
  $idx++
  [void]$sb.AppendLine(("<li><a href=""#page-{0}"">{1}</a></li>" -f $idx, [System.Web.HttpUtility]::HtmlEncode($p.url)))
}

[void]$sb.AppendLine('</ol></nav><main id="content">')
$idx = 0
foreach ($p in $pages) {
  $idx++
  $cookieText = if ($p.cookieDialog.inspected) {
    [System.Web.HttpUtility]::HtmlEncode(("Algilanan diyalog: {0}, kabul edildi: {1}, aksiyonlar: {2}" -f $p.cookieDialog.dialogCount, $p.cookieDialog.accepted, ($p.cookieDialog.acceptedActions -join '; ')))
  } else {
    'Cerez denetimi bu calistirmada kararli sinyal uretmedi.'
  }

  [void]$sb.AppendLine(("<section id=""page-{0}"" aria-labelledby=""page-{0}-title"">" -f $idx))
  [void]$sb.AppendLine(("<h2 id=""page-{0}-title"">{1}</h2>" -f $idx, [System.Web.HttpUtility]::HtmlEncode($p.url)))
  [void]$sb.AppendLine(("<p><strong>Sayfa basligi:</strong> {0}</p>" -f [System.Web.HttpUtility]::HtmlEncode($p.title)))
  [void]$sb.AppendLine(("<p><strong>Tarama ozeti:</strong> {0} element, {1} etkilesimli oge, {2} benzersiz odak hedefi dogrulandi.</p>" -f $p.elementCount, $p.interactiveCount, $p.uniqueFocusTargets))
  [void]$sb.AppendLine(("<p><strong>Dogrulama durumu:</strong> gorsel={0}, NVDA={1}</p>" -f $p.coverageStatus, $p.blindCoverageStatus))
  [void]$sb.AppendLine(("<p><strong>Bariyer siniflandirmasi:</strong> {0}</p>" -f [System.Web.HttpUtility]::HtmlEncode($p.barrierAnalysis.barrierType)))
  [void]$sb.AppendLine(("<p><strong>Cerez akisi:</strong> {0}</p>" -f $cookieText))
  [void]$sb.AppendLine(("<p><strong>Ekran goruntusu:</strong> {0}</p>" -f [System.IO.Path]::GetFileName($p.screenshot)))

  [void]$sb.AppendLine('<h3>Yerellestirme Ozeti</h3><table><thead><tr><th>Lang</th><th>Dir</th><th>Yerel ornek sayisi</th><th>Yerel karakter gozlemi</th><th>ASCII-only ornek</th></tr></thead><tbody>')
  [void]$sb.AppendLine(("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>" -f [System.Web.HttpUtility]::HtmlEncode($p.localization.lang), [System.Web.HttpUtility]::HtmlEncode($p.localization.dir), $p.localization.localizedSampleCount, $p.localization.containsLocaleSpecificText, $p.localization.asciiOnlyCount))
  [void]$sb.AppendLine('</tbody></table>')

  [void]$sb.AppendLine('<h3>Kapsam Ozeti</h3><table><thead><tr><th>Checkpoint</th><th>Scroll Y</th><th>Dokuman yuksekligi</th><th>Viewport yuksekligi</th></tr></thead><tbody>')
  foreach ($c in $p.scrollCoverage) {
    [void]$sb.AppendLine(("<tr><td>{0}%</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>" -f $c.checkpoint, $c.scrollY, $c.scrollHeight, $c.viewportHeight))
  }
  [void]$sb.AppendLine('</tbody></table>')

  [void]$sb.AppendLine('<h3>Bulgular</h3>')
  if (@($p.baFindings).Count -eq 0) {
    [void]$sb.AppendLine('<p>Bu sayfa icin bulgu tespit edilmedi.</p>')
  } else {
    foreach ($bf in $p.baFindings) {
      $sevClass = "sev-$($bf.finding.severity)"
      [void]$sb.AppendLine('<article class="pattern-card">')
      [void]$sb.AppendLine(("<p><strong class=""{0}"">{1}</strong> | WCAG {2} | <code>{3}</code></p>" -f $sevClass, [System.Web.HttpUtility]::HtmlEncode($bf.finding.title), [System.Web.HttpUtility]::HtmlEncode($bf.finding.wcag), [System.Web.HttpUtility]::HtmlEncode($bf.finding.selectorHint)))
      [void]$sb.AppendLine(("<div class=""narrative""><strong>Ne denendi:</strong> {0}<br><strong>Ne oldu:</strong> {1}<br><strong>Neden uygun degil:</strong> {2}<br><strong>Olmasi gereken:</strong> {3}<br><strong>Gelistirici aksiyonu:</strong> {4}<br><strong>BA acceptance criteria:</strong> {5}</div>" -f [System.Web.HttpUtility]::HtmlEncode($bf.narrative.elementLabel), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.asIs), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.userImpact), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.toBe), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.devAction), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.acceptanceCriteria)))
      [void]$sb.AppendLine('</article>')
    }
  }

  [void]$sb.AppendLine('<h3>Head-to-Tail Element Envanteri</h3><table><thead><tr><th>#</th><th>Tag</th><th>Id</th><th>Role</th><th>Name</th><th>Link/Alt</th><th>Blind perception</th><th>Low-vision perception</th><th>Motor perception</th></tr></thead><tbody>')
  foreach ($el in $p.elements) {
    $linkOrAlt = if ($el.href) { "href=$($el.href)" } elseif ($el.alt) { "alt=$($el.alt)" } else { "" }
    [void]$sb.AppendLine(("<tr><td>{0}</td><td>{1}</td><td><code>{2}</code></td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td></tr>" -f $el.idx, $el.tag, [System.Web.HttpUtility]::HtmlEncode($el.id), [System.Web.HttpUtility]::HtmlEncode($el.role), [System.Web.HttpUtility]::HtmlEncode($el.name), [System.Web.HttpUtility]::HtmlEncode($linkOrAlt), [System.Web.HttpUtility]::HtmlEncode("tag=$($el.tag),name=$($el.name)"), [System.Web.HttpUtility]::HtmlEncode("size=$($el.width)x$($el.height)"), [System.Web.HttpUtility]::HtmlEncode("focusable=$($el.focusable)")))
  }
  [void]$sb.AppendLine('</tbody></table>')

  [void]$sb.AppendLine('<h3>NVDA Konusma Izi</h3><table><thead><tr><th>Adim</th><th>Aksiyon</th><th>Konusulan ifade</th></tr></thead><tbody>')
  if (($null -eq $p.blindSpeechTrace) -or (@($p.blindSpeechTrace.events).Count -eq 0)) {
    [void]$sb.AppendLine('<tr><td colspan="3">Konusma izi yakalanmadi.</td></tr>')
  } else {
    foreach ($evt in $p.blindSpeechTrace.events) {
      [void]$sb.AppendLine(("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>" -f $evt.step, [System.Web.HttpUtility]::HtmlEncode($evt.action), [System.Web.HttpUtility]::HtmlEncode($evt.spokenPhrase)))
    }
  }
  [void]$sb.AppendLine('</tbody></table>')

  [void]$sb.AppendLine('<h3>Stateful Bilesen Kapsami</h3><table><thead><tr><th>Tur</th><th>Tag</th><th>Role</th><th>Ad</th><th>Expanded</th></tr></thead><tbody>')
  if (@($p.statefulCoverage).Count -eq 0) {
    [void]$sb.AppendLine('<tr><td colspan="5">Deterministik tur sirasinda acilan yaygin stateful bilesen bulunmadi.</td></tr>')
  } else {
    foreach ($s in $p.statefulCoverage) {
      [void]$sb.AppendLine(("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>" -f [System.Web.HttpUtility]::HtmlEncode($s.kind), [System.Web.HttpUtility]::HtmlEncode($s.tag), [System.Web.HttpUtility]::HtmlEncode($s.role), [System.Web.HttpUtility]::HtmlEncode($s.name), [System.Web.HttpUtility]::HtmlEncode($s.expanded)))
    }
  }
  [void]$sb.AppendLine('</tbody></table>')

  [void]$sb.AppendLine('<h3>Business Analyst Ozeti</h3><table><thead><tr><th>Bulgu</th><th>As-Is</th><th>To-Be</th><th>Developer action</th><th>BA action</th><th>PO action</th></tr></thead><tbody>')
  if (@($p.baFindings).Count -eq 0) {
    [void]$sb.AppendLine('<tr><td colspan="6">BA notu uretilmedi.</td></tr>')
  } else {
    foreach ($bf in $p.baFindings) {
      [void]$sb.AppendLine(("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td></tr>" -f [System.Web.HttpUtility]::HtmlEncode($bf.finding.title), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.asIs), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.toBe), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.devAction), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.baAction), [System.Web.HttpUtility]::HtmlEncode($bf.businessAnalysis.poAction)))
    }
  }
  [void]$sb.AppendLine('</tbody></table></section>')
}

[void]$sb.AppendLine('</main></body></html>')
$indexHtml = $sb.ToString()

Write-Utf8Bom -path (Join-Path $OutputDir 'index.html') -content $indexHtml
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'index.html')
Assert-Utf8RoundTrip -path (Join-Path $OutputDir 'index.html') -expectedTokens @('Erisilebilirlik Denetim Raporu', 'Yonetici Ozeti', 'Ne oldu')
Write-Utf8Bom -path (Join-Path $OutputDir 'blind.md') -content ('# Blind track' + "`r`n`r`n" + '- Folder: ' + (Join-Path $OutputDir 'blind'))
Write-Utf8Bom -path (Join-Path $OutputDir 'low-vision.md') -content ('# Low-vision track' + "`r`n`r`n" + '- Included in index.html and page.json files.' + "`r`n" + '- Multi-checkpoint scroll coverage enabled.')
Write-Utf8Bom -path (Join-Path $OutputDir 'motor.md') -content ('# Motor track' + "`r`n`r`n" + '- Tab steps configured: ' + $MotorTabSteps + "`r`n" + '- Unique focus targets are summarized per page in index.html.')
Write-Utf8Bom -path (Join-Path $OutputDir 'summary.md') -content ('# Summary' + "`r`n`r`n" + '- Output folder: ' + $OutputDir + "`r`n" + '- Main report: ' + (Join-Path $OutputDir 'index.html') + "`r`n" + '- Coverage style: deeper scroll traversal + extended keyboard path' + "`r`n" + '- Includes stateful component coverage, localization summary, verified runtime evidence gate, and blind spoken trace')
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'blind.md')
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'low-vision.md')
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'motor.md')
Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $OutputDir 'summary.md')

Write-Host 'Full persona audit script configuration completed.'
Write-Host "Output folder template: $OutputDir"
