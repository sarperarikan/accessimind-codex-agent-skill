param(
  [Parameter(Mandatory = $true)]
  [string[]]$Urls,
  [string]$OutputDir = "",
  [string]$RepoRoot = "",
  [string]$PlaywrightWrapper = "",
  [string]$StorageStatePath = "",
  [string]$CdpUrl = "",
  [switch]$ManualSessionCapture,
  [int]$ManualSessionSeconds = 90
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  if ($RepoRoot -and (Test-Path $RepoRoot)) { return (Resolve-Path $RepoRoot).Path }
  return (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\..")).Path
}

function Get-NpxPath {
  $default = "C:\Program Files\nodejs\npx.cmd"
  if (Test-Path $default) { return $default }
  $cmd = Get-Command npx.cmd -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  throw "npx.cmd not found."
}

function Get-BrowserPath {
  $candidates = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  )
  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) { return $candidate }
  }
  throw "Google Chrome executable not found. Chrome is mandatory for this audit flow."
}

function Write-Utf8Bom([string]$path, [string]$content) {
  if ($null -eq $content) { $content = "" }
  $content = $content.Normalize([Text.NormalizationForm]::FormC)
  $content = $content.Replace([string][char]0x200B, "")
  $content = $content.Replace([string][char]0xFEFF, "")
  $badReplacement = [char]0xFFFD
  if ($content.Contains($badReplacement)) {
    throw "Encoding integrity check failed for $path. Possible mojibake detected."
  }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $enc)
}

function Repair-Utf8Artifact([string]$RepairScript, [string]$Path) {
  if (-not (Test-Path $Path)) { return }
  & py -3 $RepairScript $Path | Out-Null
}

function Safe-Name([string]$url) {
  $name = $url -replace "^https?://", ""
  $name = $name -replace "[^a-zA-Z0-9\\-]+", "-"
  return $name.Trim("-").ToLower()
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
  $args = @("--yes", "--package", "chrome-remote-interface", "--package", "axe-core", "node", $ProbeScript, "--url", $Url, "--screenshot", $ScreenshotPath, "--tab-steps", $TabSteps, "--cdp-url", $CdpUrl, "--keep-page-open", "true")
  $raw = & $NpxPath @args
  return ($raw -join "`n" | ConvertFrom-Json)
}

function Invoke-NvdaSpeechProbe([string]$SpeechProbeScript, [string]$BrowserPath, [string]$Url, [string]$OutputPath, [int]$Steps, [bool]$ReuseExistingBrowser, [string]$ExpectedTitle, [string]$ExpectedHost, [string]$Mode = "auto", [int]$SessionSeconds = 90, [string]$SessionName = "") {
  $args = @($SpeechProbeScript, "--url", $Url, "--browser-path", $BrowserPath, "--steps", $Steps, "--output", $OutputPath, "--mode", $Mode)
  if ($ExpectedTitle) {
    $args += @("--expected-title", $ExpectedTitle)
  }
  if ($ExpectedHost) {
    $args += @("--expected-host", $ExpectedHost)
  }
  if ($Mode -eq "session") {
    $args += @("--session-seconds", $SessionSeconds)
    if ($SessionName) {
      $args += @("--session-name", $SessionName)
    }
  }
  if ($ReuseExistingBrowser) {
    $args += "--reuse-existing-browser"
  }
  & py -3 @args | Out-Null
  return (Get-Content -Path $OutputPath -Raw | ConvertFrom-Json)
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

function Assert-NvdaEvidence($meta, $inventory, $scrollCoverage, $speechTrace, $barrierAnalysis, $vision, [string]$screenshotPath, [string]$url) {
  if (-not $meta) {
    throw "Page metadata was not captured for $url."
  }
  if (-not $meta.url) {
    throw "Resolved URL metadata is empty for $url."
  }
  if (@($inventory).Count -le 0) {
    throw "NVDA DOM inventory is empty for $url."
  }
  if (-not $speechTrace) {
    throw "NVDA spoken trace was not captured for $url."
  }
  if (-not $speechTrace.speechViewerDetected) {
    throw "NVDA Speech Viewer was not confirmed for $url."
  }
  if (@($speechTrace.events).Count -le 0) {
    throw "NVDA spoken events are empty for $url."
  }
  if (@($speechTrace.spokenPhraseLog).Count -le 0) {
    throw "NVDA spoken phrase log is empty for $url."
  }
  if ($barrierAnalysis -and $barrierAnalysis.blocked) {
    throw "Rendered surface for $url is blocked: $($barrierAnalysis.summary). Recommended path: $($barrierAnalysis.nextStep)"
  }
  Assert-ScrollCoverage -coverage $scrollCoverage -url $url | Out-Null
  if (-not $vision) {
    throw "Vision evidence was not captured for $url."
  }
  Assert-FileHasContent -path $screenshotPath -label "Blind screenshot"
  return "verified"
}

function New-NvdaSessionOverview($sessionTrace, [string]$jsonPath) {
  if (-not $sessionTrace) { return $null }
  $sessionMeta = if ($sessionTrace.session) { $sessionTrace.session } else { $null }
  $events = @($sessionTrace.events)
  $phrases = @($sessionTrace.uniqueSpokenPhraseLog)
  return [pscustomobject]@{
    jsonPath = $jsonPath
    enabled = $true
    name = if ($sessionMeta -and $sessionMeta.name) { $sessionMeta.name } else { "manual-navigation-session" }
    durationSeconds = if ($sessionMeta) { $sessionMeta.durationSeconds } else { $null }
    eventCount = @($events).Count
    uniquePhraseCount = @($phrases).Count
    lastSpokenPhrase = if ($sessionTrace.lastSpokenPhrase) { $sessionTrace.lastSpokenPhrase } else { "" }
    startedAt = if ($sessionMeta) { $sessionMeta.startedAt } else { $null }
    endedAt = if ($sessionMeta) { $sessionMeta.endedAt } else { $null }
    keyMoments = @($events | Select-Object -First 12 | ForEach-Object {
        [pscustomobject]@{
          step = $_.step
          action = $_.action
          spokenPhrase = $_.spokenPhrase
          elapsedMs = $_.elapsedMs
        }
      })
  }
}

$root = Get-RepoRoot
$nvdaExe = Join-Path $root "NVDA\\nvda_noUIAccess.exe"
if (-not (Test-Path $nvdaExe)) { $nvdaExe = Join-Path $root "NVDA\\nvda.exe" }
if (-not (Test-Path $nvdaExe)) { throw "NVDA executable not found under $root\\NVDA" }

$probeScript = Join-Path $root "scripts\deterministic_cdp_probe.cjs"
if (-not (Test-Path $probeScript)) { throw "Deterministic CDP probe not found: $probeScript" }
$speechProbeScript = Join-Path $root "scripts\nvda_speech_probe.py"
if (-not (Test-Path $speechProbeScript)) { throw "NVDA speech probe not found: $speechProbeScript" }
$accessAnalyzerScript = Join-Path $root "scripts\langchain_access_surface_analyzer.py"
if (-not (Test-Path $accessAnalyzerScript)) { throw "LangChain access surface analyzer not found: $accessAnalyzerScript" }
$repairScript = Join-Path $root "scripts\repair_utf8_artifact.py"
if (-not (Test-Path $repairScript)) { throw "UTF-8 repair helper not found: $repairScript" }
$npxPath = Get-NpxPath
$browserPath = Get-BrowserPath

if (-not $OutputDir) {
  $OutputDir = Join-Path $root ("reports\\nvda-audit-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
}
New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

$startedAt = (Get-Date).ToString("o")
$nvdaProc = $null
$pages = @()

try {
  $nvdaProc = Start-Process -FilePath $nvdaExe -PassThru
  Start-Sleep -Seconds 6

  foreach ($url in $Urls) {
    $slug = Safe-Name $url
    $pageDir = Join-Path $OutputDir $slug
    New-Item -Path $pageDir -ItemType Directory -Force | Out-Null

    $shot = Join-Path $pageDir "blind-base.png"
    $speechJson = Join-Path $pageDir "speech-trace.json"
    $sessionSpeechJson = Join-Path $pageDir "speech-session.json"
    $probeJson = Join-Path $pageDir "probe.json"
    $barrierJson = Join-Path $pageDir "barrier-analysis.json"
    $probe = Invoke-WithRetry -Action { Invoke-CdpProbe -NpxPath $npxPath -ProbeScript $probeScript -Url $url -ScreenshotPath $shot -TabSteps 40 -CdpUrl $CdpUrl }
    Write-Utf8Bom -path $probeJson -content ($probe | ConvertTo-Json -Depth 15)
    $barrierAnalysis = Invoke-AccessSurfaceAnalyzer -AnalyzerScript $accessAnalyzerScript -InputPath $probeJson -OutputPath $barrierJson
    $reuseExistingBrowser = [bool]$CdpUrl
    $expectedHost = ([uri]$url).Host
    $expectedTitle = if ($probe.meta -and $probe.meta.title) { [string]$probe.meta.title } else { "" }
    $speechTrace = Invoke-WithRetry -Action { Invoke-NvdaSpeechProbe -SpeechProbeScript $speechProbeScript -BrowserPath $browserPath -Url $url -OutputPath $speechJson -Steps 12 -ReuseExistingBrowser $reuseExistingBrowser -ExpectedTitle $expectedTitle -ExpectedHost $expectedHost -Mode "auto" }
    $sessionTrace = $null
    $sessionOverview = $null
    if ($ManualSessionCapture) {
      Write-Host "Manual NVDA session capture started for $url. Navigate the page for $ManualSessionSeconds seconds."
      $sessionTrace = Invoke-WithRetry -Action {
        Invoke-NvdaSpeechProbe `
          -SpeechProbeScript $speechProbeScript `
          -BrowserPath $browserPath `
          -Url $url `
          -OutputPath $sessionSpeechJson `
          -Steps 0 `
          -ReuseExistingBrowser $reuseExistingBrowser `
          -ExpectedTitle $expectedTitle `
          -ExpectedHost $expectedHost `
          -Mode "session" `
          -SessionSeconds $ManualSessionSeconds `
          -SessionName ("manual-navigation-" + $slug)
      } -Attempts 1
      $sessionOverview = New-NvdaSessionOverview -sessionTrace $sessionTrace -jsonPath $sessionSpeechJson
    }

    $cookie = if ($probe.cookieDialog) { $probe.cookieDialog } else { New-CookieInspectionState }
    if ($probe.cookieDialog -and -not ($cookie.PSObject.Properties.Name -contains 'inspected')) {
      $cookie | Add-Member -NotePropertyName inspected -NotePropertyValue $true -Force
    }
    $scrollCoverage = Assert-ScrollCoverage -coverage $probe.scrollCoverage -url $url
    $meta = $probe.meta
    $headings = @($probe.headings)
    $landmarks = @($probe.landmarks)
    $links = @($probe.links)
    $forms = @($probe.formFields)
    $buttons = @($probe.buttons)
    $graphics = @($probe.graphics)
    $inventory = @($probe.dom.elements)
    $vision = $probe.vision
    $localization = $probe.localization
    if (-not $localization) { throw "Localization evidence was not captured for $url." }

    $findings = @()
    if ($cookie.inspected -and $cookie.dialogCount -gt 0 -and -not $cookie.accepted) {
      $findings += [pscustomobject]@{
        severity = "high"
        wcag = "2.1.1"
        title = "Cookie dialog blocks flow"
        issue = "Cookie dialog was detected but acceptance action could not be confirmed."
        fix = "Make cookie dialog keyboard-operable and expose a clear accept control."
        evidence = "dialogs=$($cookie.dialogCount)"
      }
    }
    if ($cookie.inspected -and $cookie.dialogCount -gt 0 -and $cookie.accepted) {
      $findings += [pscustomobject]@{
        severity = "info"
        wcag = "Process"
        title = "Cookie dialog handled"
        issue = "Cookie dialog was evaluated and accepted before blind scan started."
        fix = "Keep this pre-scan sequence stable across all pages."
        evidence = ($cookie.acceptedActions -join "; ")
      }
    }

    foreach ($l in @($links)) {
      if ($l.badHref) {
        $findings += [pscustomobject]@{
          severity = "high"
          wcag = "4.1.2"
          title = "Link semantics risk"
          issue = "Placeholder href appears in NVDA link model."
          fix = "Use a real URL or native button semantics."
          evidence = "href=$($l.href);name=$($l.name)"
        }
      }
      if (-not $l.name) {
        $findings += [pscustomobject]@{
          severity = "high"
          wcag = "2.4.4"
          title = "Ambiguous link name"
          issue = "Link name is empty or not meaningful."
          fix = "Provide clear link text or aria-label."
          evidence = "href=$($l.href)"
        }
      }
    }

    foreach ($b in @($buttons)) {
      if (-not $b.name) {
        $findings += [pscustomobject]@{
          severity = "high"
          wcag = "4.1.2"
          title = "Button name missing"
          issue = "Button has no accessible name in NVDA quick navigation."
          fix = "Add visible label and expose name in accessibility tree."
          evidence = "id=$($b.id)"
        }
      }
    }

    foreach ($g in @($graphics)) {
      if ($g.missingAlt) {
        $findings += [pscustomobject]@{
          severity = "medium"
          wcag = "1.1.1"
          title = "Missing image alt text"
          issue = "Image has no alternative text in NVDA graphics navigation."
          fix = "Add meaningful alt text or empty alt for decorative images."
          evidence = "index=$($g.index)"
        }
      }
    }
    if (-not $localization.lang) {
      $findings += [pscustomobject]@{
        severity = "medium"
        wcag = "3.1.1"
        title = "Document language missing"
        issue = "Document root does not expose a lang attribute."
        fix = "Set a valid document language on the html element."
        evidence = "html[lang] missing"
      }
    }

    $coverageStatus = Assert-NvdaEvidence -meta $meta -inventory $inventory -scrollCoverage $scrollCoverage -speechTrace $speechTrace -barrierAnalysis $barrierAnalysis -vision $vision -screenshotPath $shot -url $url

    $page = [pscustomobject]@{
      url = $meta.url
      title = $meta.title
      screenshot = $shot
      speechTrace = $speechTrace
      manualSession = $sessionOverview
      barrierAnalysis = $barrierAnalysis
      coverageStatus = $coverageStatus
      cookieDialog = $cookie
      localization = $localization
      vision = $vision
      domScan = [pscustomobject]@{
        elementCount = @($inventory).Count
        interactiveCount = @($inventory | Where-Object { $_.focusable }).Count
        elements = $inventory
      }
      scrollCoverage = $scrollCoverage
      elementsListModel = [pscustomobject]@{
        headingsCount = @($headings).Count
        linksCount = @($links).Count
        formFieldsCount = @($forms).Count
        buttonsCount = @($buttons).Count
        landmarksCount = @($landmarks).Count
        graphicsCount = @($graphics).Count
      }
      headings = $headings
      links = $links
      formFields = $forms
      buttons = $buttons
      landmarks = $landmarks
      graphics = $graphics
      findings = $findings
    }

    Write-Utf8Bom -path (Join-Path $pageDir "blind-page.json") -content ($page | ConvertTo-Json -Depth 15)
    Repair-Utf8Artifact -RepairScript $repairScript -Path (Join-Path $pageDir "blind-page.json")
    $pages += $page
  }
}
finally {
  if ($nvdaProc -and -not $nvdaProc.HasExited) {
    Stop-Process -Id $nvdaProc.Id -Force
  }
}

$summary = [pscustomobject]@{
  startedAt = $startedAt
  endedAt = (Get-Date).ToString("o")
  nvdaExecutable = $nvdaExe
  nvdaStarted = [bool]$nvdaProc
  outputDir = $OutputDir
  pages = $pages
}

$jsonPath = Join-Path $OutputDir "summary.json"
Write-Utf8Bom -path $jsonPath -content ($summary | ConvertTo-Json -Depth 15)
Repair-Utf8Artifact -RepairScript $repairScript -Path $jsonPath

$md = @()
$md += "# NVDA Portable Blind-Side Audit"
$md += ""
$md += "## Model"
$md += "- Source: NVDA User Guide Browse Mode + Single Letter Navigation + Elements List"
$md += "- Keys: h/1-9, k, f/e, b, d, g, NVDA+F7"
$md += "- Cookie workflow: detect -> evaluate -> accept -> restart from top"

foreach ($p in $pages) {
  $md += ""
  $md += "## $($p.url)"
  $md += "- title: $($p.title)"
  $md += "- screenshot: $($p.screenshot)"
  $md += "- verification status: $($p.coverageStatus)"
  $md += "- cookie dialogs detected: $($p.cookieDialog.dialogCount)"
  $md += "- cookie accepted: $($p.cookieDialog.accepted)"
  $md += "- cookie accepted actions: $($p.cookieDialog.acceptedActions -join '; ')"
  $md += "- full DOM elements scanned: $($p.domScan.elementCount)"
  $md += "- interactive elements scanned: $($p.domScan.interactiveCount)"
  $md += "- headings: $($p.elementsListModel.headingsCount)"
  $md += "- links: $($p.elementsListModel.linksCount)"
  $md += "- form fields: $($p.elementsListModel.formFieldsCount)"
  $md += "- buttons: $($p.elementsListModel.buttonsCount)"
  $md += "- landmarks: $($p.elementsListModel.landmarksCount)"
  $md += "- graphics: $($p.elementsListModel.graphicsCount)"
  $md += "- html lang: $($p.localization.lang)"
  $md += "- html dir: $($p.localization.dir)"
  $md += "- findings: $(@($p.findings).Count)"
  $md += "- scroll checkpoints covered: $(@($p.scrollCoverage | ForEach-Object { $_.checkpoint }) -join ', ')"
  $md += "- access barrier blocked: $($p.barrierAnalysis.blocked)"
  $md += "- access barrier type: $($p.barrierAnalysis.barrierType)"
  $md += "- recommended acquisition: $($p.barrierAnalysis.recommendedAcquisition)"
  $md += "- spoken phrases captured: $(@($p.speechTrace.spokenPhraseLog).Count)"
  $md += "- last spoken phrase: $($p.speechTrace.lastSpokenPhrase)"
  if ($p.manualSession -and $p.manualSession.enabled) {
    $md += "- manual NVDA session log: $($p.manualSession.jsonPath)"
    $md += "- manual session duration seconds: $($p.manualSession.durationSeconds)"
    $md += "- manual session events: $($p.manualSession.eventCount)"
    $md += "- manual session unique phrases: $($p.manualSession.uniquePhraseCount)"
    $md += "- manual session last spoken phrase: $($p.manualSession.lastSpokenPhrase)"
  }
  if (@($p.speechTrace.events).Count -gt 0) {
    $md += "### Spoken interaction trace"
    foreach ($evt in $p.speechTrace.events) {
      $md += "- step $($evt.step) | action: $($evt.action) | speech: $($evt.spokenPhrase)"
    }
  }
  if ($p.manualSession -and @($p.manualSession.keyMoments).Count -gt 0) {
    $md += "### Manual navigation session trace"
    foreach ($evt in $p.manualSession.keyMoments) {
      $md += "- step $($evt.step) | action: $($evt.action) | elapsedMs: $($evt.elapsedMs) | speech: $($evt.spokenPhrase)"
    }
  }
  if (@($p.findings).Count -gt 0) {
    $md += "### Findings detail"
    $n = 0
    foreach ($f in $p.findings) {
      $n++
      $md += "$n. [$($f.severity)] $($f.title) ($($f.wcag))"
      $md += "   - issue: $($f.issue)"
      $md += "   - fix: $($f.fix)"
      $md += "   - evidence: $($f.evidence)"
    }
  }
}

$mdPath = Join-Path $OutputDir "summary.md"
Write-Utf8Bom -path $mdPath -content ($md -join "`r`n")
Repair-Utf8Artifact -RepairScript $repairScript -Path $mdPath

Write-Host "Audit completed."
Write-Host "JSON: $jsonPath"
Write-Host "Markdown: $mdPath"
