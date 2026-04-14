import argparse
import html
import json
from collections import defaultdict
from pathlib import Path

from ftfy import fix_text
from PIL import Image


BAD_TOKENS = ("Ã", "\ufffd")
MOJIBAKE_MAP = {
    "Ã§": "ç",
    "Ã‡": "Ç",
    "Ã¶": "ö",
    "Ã–": "Ö",
    "Ã¼": "ü",
    "Ãœ": "Ü",
    "Ä±": "ı",
    "Ä°": "İ",
    "ÄŸ": "ğ",
    "Äž": "Ğ",
    "ÅŸ": "ş",
    "Åž": "Ş",
    "â€¦": "…",
    "â€“": "–",
    "â€”": "—",
    "â€˜": "‘",
    "â€™": "’",
    "â€œ": "“",
    "â€�": "”",
    "â€¢": "•",
    "â„¢": "™",
    "âŒ˜": "⌘",
}


def normalize_text(value):
    if isinstance(value, str):
        fixed = value
        for wrong, right in MOJIBAKE_MAP.items():
            fixed = fixed.replace(wrong, right)
        fixed = fix_text(fixed)
        for wrong, right in MOJIBAKE_MAP.items():
            fixed = fixed.replace(wrong, right)
        return fixed.replace("\ufeff", "").replace("\u200b", "").strip()
    if isinstance(value, list):
        return [normalize_text(item) for item in value]
    if isinstance(value, dict):
        return {key: normalize_text(item) for key, item in value.items()}
    return value


def assert_clean_utf8(text: str) -> None:
    found = [token for token in BAD_TOKENS if token in text]
    if found:
        raise ValueError(
            "UTF-8 doğrulaması başarısız. Bozuk karakter dizileri bulundu: "
            + ", ".join(found)
        )


def esc(value) -> str:
    return html.escape(str(value or ""))


def infer_area(page_url: str, finding: dict, narrative: dict, element: dict | None) -> str:
    haystack = " ".join(
        str(x or "")
        for x in [
            page_url,
            finding.get("selectorHint"),
            finding.get("title"),
            finding.get("issue"),
            narrative.get("elementLabel"),
            element.get("id") if element else "",
            element.get("name") if element else "",
            element.get("href") if element else "",
            element.get("role") if element else "",
            element.get("cssPath") if element else "",
        ]
    ).lower()

    rules = [
        ("Hızlı menü / yardımcı aksiyonlar", ["quick", "hızlı", "yardım", "chat", "görüş", "quick-link"]),
        ("Üst gezinme / header", ["menu", "logo", "search", "arama", "giriş", "üye", "ürünler", "teknolojiler", "blog"]),
        ("İçeriğe atla bağlantıları", ["içeriğe atla", "alt içeriğe atla", "skip"]),
        ("Destek akışı", ["destek", "servis", "bağlan", "yardım", "chat"]),
        ("Kampanya alanı", ["kampanya", "kampanyalar"]),
        ("Kurumsal alan", ["kurumsal"]),
        ("Hero / medya", ["slider", "slayt", "hero", "banner"]),
        ("Footer", ["footer", "site-footer"]),
        ("Hesap / sepet", ["favori", "sepet", "hesab", "bilgilerim"]),
    ]
    for label, needles in rules:
        if any(needle in haystack for needle in needles):
            return label
    if element and element.get("tag") == "IMG":
        return "Görsel / medya"
    return "Genel sayfa içeriği"


def build_exact_locator(element: dict | None, finding: dict) -> str:
    if not element:
        return finding.get("selectorHint", "")
    parts = []
    if element.get("cssPath"):
        parts.append(element["cssPath"])
    tag = element.get("tag", "")
    if tag:
        detail_parts = [tag]
        if element.get("id"):
            detail_parts.append(f"id={element['id']}")
        if element.get("role"):
            detail_parts.append(f"role={element['role']}")
        if element.get("name"):
            detail_parts.append(f"ad={element['name']}")
        parts.append(" | ".join(detail_parts))
    if not parts:
        parts.append(finding.get("selectorHint", ""))
    return " || ".join(part for part in parts if part)


def crop_issue(base_dir: Path, page_slug: str, element: dict | None, crop_name: str) -> str | None:
    if not element:
        return None
    x = int(element.get("x") or 0)
    y = int(element.get("y") or 0)
    width = int(element.get("width") or 0)
    height = int(element.get("height") or 0)
    if width <= 0 or height <= 0:
        return None

    source = base_dir / "pages" / page_slug / "base.png"
    if not source.exists():
        return None

    output_dir = base_dir / "issue-crops" / page_slug
    output_dir.mkdir(parents=True, exist_ok=True)
    output = output_dir / f"{crop_name}.png"

    with Image.open(source) as img:
        margin = 24
        left = max(0, x - margin)
        top = max(0, y - margin)
        right = min(img.width, x + width + margin)
        bottom = min(img.height, y + height + margin)
        if right <= left or bottom <= top:
            return None
        img.crop((left, top, right, bottom)).save(output)

    return output.relative_to(base_dir).as_posix()


def build_instance(base_dir: Path, page: dict, item: dict) -> dict:
    finding = item["finding"]
    narrative = item["narrative"]
    element = None
    idx = finding.get("elementIndex")
    if idx and idx > 0:
        for candidate in page.get("elements", []):
            if candidate.get("idx") == idx:
                element = candidate
                break

    page_slug = page["screenshot"].replace("\\", "/").split("/pages/")[-1].split("/")[0]
    safe_title = finding["title"].lower().replace(" ", "-")[:40]
    crop_rel = crop_issue(base_dir, page_slug, element, f"finding-{finding.get('elementIndex', 'na')}-{safe_title}")
    area = infer_area(page["url"], finding, narrative, element)
    href = element.get("href") if element else None
    size = None
    if element and element.get("width") and element.get("height"):
        size = f"{element['width']}x{element['height']} px"

    return {
        "page_url": page["url"],
        "page_title": page["title"],
        "page_slug": page_slug,
        "area": area,
        "severity": finding["severity"],
        "wcag": finding["wcag"],
        "title": finding["title"],
        "selector": finding.get("selectorHint", ""),
        "exact_locator": build_exact_locator(element, finding),
        "element_label": narrative.get("elementLabel", ""),
        "impact": item["businessAnalysis"].get("userImpact", ""),
        "expected": item["businessAnalysis"].get("toBe", ""),
        "dev_action": item["businessAnalysis"].get("devAction", ""),
        "acceptance": item["businessAnalysis"].get("acceptanceCriteria", ""),
        "as_is": item["businessAnalysis"].get("asIs", ""),
        "evidence": narrative.get("evidenceNarrative", ""),
        "href": href,
        "size": size,
        "crop_rel": crop_rel,
    }


def cluster_key(instance: dict) -> tuple:
    return (
        instance["severity"],
        instance["title"],
        instance["area"],
        instance["wcag"],
        instance["dev_action"],
    )


def severity_rank(value: str) -> int:
    return {"high": 0, "medium": 1, "low": 2, "info": 3}.get(value, 4)


def load_commentary(base_dir: Path) -> dict:
    commentary_path = base_dir / "llm-commentary.json"
    if not commentary_path.exists():
        return {}
    return normalize_text(json.loads(commentary_path.read_text(encoding="utf-8")))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--summary", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--title", default="Erişilebilirlik Bulguları Raporu")
    args = parser.parse_args()

    summary_path = Path(args.summary)
    output_path = Path(args.output)
    base_dir = output_path.parent

    data = normalize_text(json.loads(summary_path.read_text(encoding="utf-8")))
    llm_commentary = load_commentary(base_dir)

    instances = []
    for page in data["pages"]:
        for item in page.get("baFindings", []):
            instances.append(build_instance(base_dir, page, item))

    grouped: dict[tuple, list[dict]] = defaultdict(list)
    for instance in instances:
        grouped[cluster_key(instance)].append(instance)

    clusters = []
    for rows in grouped.values():
        sample = rows[0]
        clusters.append(
            {
                "severity": sample["severity"],
                "title": sample["title"],
                "area": sample["area"],
                "wcag": sample["wcag"],
                "dev_action": sample["dev_action"],
                "impact": sample["impact"],
                "expected": sample["expected"],
                "acceptance": sample["acceptance"],
                "count": len(rows),
                "pages": sorted({row["page_url"] for row in rows}),
                "samples": rows[:5],
            }
        )

    clusters.sort(key=lambda item: (severity_rank(item["severity"]), -item["count"], item["title"], item["area"]))

    page_cards = []
    for page in data["pages"]:
        page_clusters = [cluster for cluster in clusters if page["url"] in cluster["pages"]]
        page_cards.append(
            {
                "url": page["url"],
                "title": page["title"],
                "element_count": page["elementCount"],
                "interactive_count": page["interactiveCount"],
                "focus_targets": page["uniqueFocusTargets"],
                "axe_violation_count": ((page.get("axe") or {}).get("violationCount") or 0),
                "cdp_node_count": ((page.get("cdpAccessibility") or {}).get("nodeCount") or 0),
                "vision_small_targets": ((page.get("vision") or {}).get("smallTargetCandidates") or 0),
                "cluster_count": len(page_clusters),
            }
        )

    top_clusters = clusters[:20]
    html_parts = [
        "<!doctype html>",
        "<html lang=\"tr\">",
        "<head>",
        "<meta charset=\"UTF-8\">",
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
        f"<title>{esc(args.title)}</title>",
        "<style>"
        "body{font-family:'Segoe UI',Arial,sans-serif;line-height:1.6;margin:24px;color:#17202a;background:#fff}"
        "h1,h2,h3,h4{line-height:1.25}"
        ".grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;margin:16px 0 24px}"
        ".card,.cluster{border:1px solid #d6dce3;background:#f8fafc;padding:14px;border-radius:10px}"
        ".cluster{background:#fff;margin:0 0 18px}"
        ".sev-high{border-left:6px solid #b42318}.sev-medium{border-left:6px solid #b54708}.sev-info{border-left:6px solid #175cd3}"
        ".pill{display:inline-block;padding:2px 8px;border-radius:999px;background:#eef2f6;margin-right:6px}"
        "table{width:100%;border-collapse:collapse;margin:10px 0 14px}"
        "th,td{border:1px solid #d0d7de;padding:8px;vertical-align:top;text-align:left}"
        "th{background:#f2f4f7} code{white-space:normal;word-break:break-word}"
        ".crop{max-width:260px;border:1px solid #d0d7de;border-radius:8px}"
        "</style>",
        "</head>",
        "<body>",
        f"<h1>{esc(args.title)}</h1>",
        "<p>Bu rapor, tekrar eden bulguları bileşen veya bölge bazında birleştirir. Yalnızca erişilebilirlik ihlalleri, kullanıcı etkisi ve geliştiriciye dönük çözüm yönü gösterilir. Her örnek kanıtta daha keskin locator, axe-core kural izi ve bulguya özel kırpılmış görsel bulunur.</p>",
        "<section>",
        "<h2>Yönetici Özeti</h2>",
        "<div class=\"grid\">",
        f"<div class=\"card\"><strong>İncelenen sayfa</strong><br>{len(data['pages'])}</div>",
        f"<div class=\"card\"><strong>Toplam bulgu</strong><br>{len(instances)}</div>",
        f"<div class=\"card\"><strong>Aksiyon kümesi</strong><br>{len(clusters)}</div>",
        f"<div class=\"card\"><strong>Doğrulanan kapsam</strong><br>{data['coverageSummary']['verified']}</div>",
        f"<div class=\"card\"><strong>Yüksek öncelik kümesi</strong><br>{sum(1 for item in clusters if item['severity'] == 'high')}</div>",
        f"<div class=\"card\"><strong>Orta öncelik kümesi</strong><br>{sum(1 for item in clusters if item['severity'] == 'medium')}</div>",
        "</div>",
        "</section>",
    ]

    if llm_commentary:
        html_parts.extend(["<section>", "<h2>LLM Yorum Katmanı</h2>"])
        if llm_commentary.get("overallSummary"):
            html_parts.append(f"<p>{esc(llm_commentary['overallSummary'])}</p>")
        if llm_commentary.get("priorityActions"):
            html_parts.append("<h3>Öncelikli yorumlanan aksiyonlar</h3><ul>")
            for action in llm_commentary["priorityActions"]:
                html_parts.append(f"<li>{esc(action)}</li>")
            html_parts.append("</ul>")
        if llm_commentary.get("pageComments"):
            html_parts.append("<h3>Sayfa bazlı yorumlar</h3><table><thead><tr><th>Sayfa</th><th>Yorum</th></tr></thead><tbody>")
            for item in llm_commentary["pageComments"]:
                html_parts.append(f"<tr><td>{esc(item.get('url', ''))}</td><td>{esc(item.get('comment', ''))}</td></tr>")
            html_parts.append("</tbody></table>")
        html_parts.append("</section>")

    html_parts.extend([
        "<section>",
        "<h2>Sayfa Bazlı Görünüm</h2>",
        "<table><thead><tr><th>Sayfa</th><th>Başlık</th><th>Element</th><th>Etkileşimli öğe</th><th>Odak hedefi</th><th>axe ihlali</th><th>CDP AX düğümü</th><th>Vision adayları</th><th>Aksiyon kümesi</th></tr></thead><tbody>",
    ])

    for page in page_cards:
        html_parts.append(
            "<tr>"
            f"<td>{esc(page['url'])}</td>"
            f"<td>{esc(page['title'])}</td>"
            f"<td>{page['element_count']}</td>"
            f"<td>{page['interactive_count']}</td>"
            f"<td>{page['focus_targets']}</td>"
            f"<td>{page['axe_violation_count']}</td>"
            f"<td>{page['cdp_node_count']}</td>"
            f"<td>{page['vision_small_targets']}</td>"
            f"<td>{page['cluster_count']}</td>"
            "</tr>"
        )

    html_parts.extend(["</tbody></table>", "</section>", "<section>", "<h2>Öncelikli Aksiyon Alanları</h2>"])

    for cluster in top_clusters:
        sev_class = f"sev-{cluster['severity']}"
        pages_text = ", ".join(cluster["pages"])
        html_parts.extend(
            [
                f"<article class=\"cluster {sev_class}\">",
                f"<h3>{esc(cluster['title'])}</h3>",
                f"<p><span class=\"pill\">{esc(cluster['severity']).upper()}</span><span class=\"pill\">WCAG {esc(cluster['wcag'])}</span><span class=\"pill\">Bölge: {esc(cluster['area'])}</span><span class=\"pill\">Tekrar: {cluster['count']}</span></p>",
                f"<p><strong>Nerede var:</strong> {esc(pages_text)}</p>",
                f"<p><strong>Neden aksiyon alınmalı:</strong> {esc(cluster['impact'])}</p>",
                f"<p><strong>Beklenen durum:</strong> {esc(cluster['expected'])}</p>",
                f"<p><strong>Geliştirici aksiyonu:</strong> {esc(cluster['dev_action'])}</p>",
                f"<p><strong>Tamamlanma kriteri:</strong> {esc(cluster['acceptance'])}</p>",
                "<h4>Örnek kanıtlar</h4>",
                "<table><thead><tr><th>Sayfa</th><th>Öğe</th><th>Kesin locator</th><th>Ne oldu</th><th>Ek kanıt</th><th>Kırpılmış görsel</th></tr></thead><tbody>",
            ]
        )

        for sample in cluster["samples"]:
            evidence_bits = [sample["evidence"]]
            if sample["href"]:
                evidence_bits.append(f"Hedef: {sample['href']}")
            if sample["size"]:
                evidence_bits.append(f"Ölçü: {sample['size']}")
            crop_html = ""
            if sample["crop_rel"]:
                crop_html = f"<img class=\"crop\" src=\"{esc(sample['crop_rel'])}\" alt=\"Bulguya ait kırpılmış görsel\">"
            html_parts.append(
                "<tr>"
                f"<td>{esc(sample['page_url'])}</td>"
                f"<td>{esc(sample['element_label'])}</td>"
                f"<td><code>{esc(sample['exact_locator'])}</code></td>"
                f"<td>{esc(sample['as_is'])}</td>"
                f"<td>{esc(' | '.join(bit for bit in evidence_bits if bit))}</td>"
                f"<td>{crop_html}</td>"
                "</tr>"
            )

        html_parts.extend(["</tbody></table>", "</article>"])

    html_parts.extend(["</section>", "</body>", "</html>"])
    final_html = "\n".join(html_parts)
    assert_clean_utf8(final_html)
    output_path.write_text(final_html, encoding="utf-8", newline="\n")
    assert_clean_utf8(output_path.read_text(encoding="utf-8"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
