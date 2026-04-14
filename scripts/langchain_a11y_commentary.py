import argparse
import json
import os
from collections import Counter, defaultdict
from pathlib import Path

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableLambda


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--summary", required=True)
    parser.add_argument("--output", required=True)
    return parser.parse_args()


def load_summary(path_str: str) -> dict:
    return json.loads(Path(path_str).read_text(encoding="utf-8"))


def compact_summary(data: dict) -> dict:
    pattern_counter = Counter()
    page_comments = []
    wcag_counter = Counter()
    area_counter = Counter()

    for page in data.get("pages", []):
        title_counter = Counter()
        for item in page.get("baFindings", []):
            finding = item.get("finding", {})
            narrative = item.get("narrative", {})
            title = finding.get("title", "")
            if title:
                pattern_counter[title] += 1
                title_counter[title] += 1
            wcag = finding.get("wcag", "")
            if wcag:
                wcag_counter[wcag] += 1
            area = (narrative.get("elementLabel") or finding.get("selectorHint") or "").strip()
            if area:
                area_counter[area] += 1
        top_titles = [name for name, _ in title_counter.most_common(3)]
        page_comments.append(
            {
                "url": page.get("url", ""),
                "title": page.get("title", ""),
                "findingCount": len(page.get("baFindings", [])),
                "topFindingTitles": top_titles,
                "axeViolationCount": ((page.get("axe") or {}).get("violationCount") or 0),
                "cdpNodeCount": ((page.get("cdpAccessibility") or {}).get("nodeCount") or 0),
            }
        )

    return {
        "projectName": data.get("projectName", ""),
        "pageCount": len(data.get("pages", [])),
        "findingCount": data.get("findingCount", 0),
        "verifiedCount": ((data.get("coverageSummary") or {}).get("verified") or 0),
        "topPatterns": [{"title": title, "count": count} for title, count in pattern_counter.most_common(8)],
        "topWcag": [{"wcag": wcag, "count": count} for wcag, count in wcag_counter.most_common(8)],
        "representativeAreas": [{"label": label, "count": count} for label, count in area_counter.most_common(8)],
        "pages": page_comments,
    }


def fallback_commentary(compact: dict) -> dict:
    top_patterns = compact.get("topPatterns", [])
    top_pages = sorted(compact.get("pages", []), key=lambda item: item.get("findingCount", 0), reverse=True)
    pattern_text = ", ".join(f"{item['title']} ({item['count']})" for item in top_patterns[:4]) or "belirgin bir tekrar eden desen yok"
    overall = (
        f"{compact['pageCount']} sayfa üzerinde {compact['findingCount']} bulgu doğrulandı. "
        f"En baskın problem kümeleri: {pattern_text}. "
        "CDP erişilebilirlik ağacı, axe-core kural sonuçları ve NVDA konuşma izi birlikte okunarak önceliklendirme yapıldı."
    )
    priorities = []
    for item in top_patterns[:3]:
        priorities.append(f"{item['title']} desenini ortak bileşen seviyesinde düzeltin; tekrar sayısı {item['count']}.")
    page_comments = []
    for page in top_pages[:4]:
        top_titles = ", ".join(page.get("topFindingTitles") or []) or "belirgin tekrar eden başlık yok"
        page_comments.append(
            {
                "url": page.get("url", ""),
                "comment": (
                    f"Bu sayfada {page.get('findingCount', 0)} bulgu var. "
                    f"En görünür problem başlıkları: {top_titles}. "
                    f"Axe ihlal sayısı {page.get('axeViolationCount', 0)}, CDP ağaç düğümü {page.get('cdpNodeCount', 0)}."
                ),
            }
        )
    return {
        "generationMode": "heuristic-langchain",
        "overallSummary": overall,
        "priorityActions": priorities,
        "pageComments": page_comments,
    }


def llm_commentary(compact: dict) -> dict:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        return fallback_commentary(compact)

    try:
        from langchain_openai import ChatOpenAI
    except Exception:
        return fallback_commentary(compact)

    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "Sen bir erişilebilirlik denetim uzmanısın. Sana verilen denetim özetinden Türkçe, aksiyon alınabilir ve yalın bir JSON yorum üret. "
                "Sadece JSON dön. Şema: {\"overallSummary\": string, \"priorityActions\": [string,string,string], \"pageComments\": [{\"url\": string, \"comment\": string}]}. "
                "Genel ifadeler kullanma; mümkün olduğunca özetten gelen tekrar eden bulgu başlıklarını ve yoğun sayfaları an.",
            ),
            ("human", "{payload}"),
        ]
    )
    model = ChatOpenAI(model=os.getenv("OPENAI_MODEL", "gpt-5-mini"), temperature=0.1, api_key=api_key)
    chain = prompt | model | StrOutputParser()
    raw = chain.invoke({"payload": json.dumps(compact, ensure_ascii=False)})
    try:
        parsed = json.loads(raw)
    except Exception:
        return fallback_commentary(compact)
    parsed["generationMode"] = "openai-langchain"
    return parsed


def main() -> int:
    args = parse_args()
    data = load_summary(args.summary)
    compact = compact_summary(data)
    chain = RunnableLambda(lambda payload: llm_commentary(payload))
    result = chain.invoke(compact)
    Path(args.output).write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
