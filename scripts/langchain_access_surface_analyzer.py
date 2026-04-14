import argparse
import json
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", message="Core Pydantic V1 functionality")

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableLambda


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output")
    return parser.parse_args()


def load_probe(path_str):
    path = Path(path_str)
    return json.loads(path.read_text(encoding="utf-8-sig"))


def classify_surface(payload):
    barrier = payload.get("accessBarrier") or {}
    meta = payload.get("meta") or {}
    detected = bool(barrier.get("detected"))
    acquisition_mode = meta.get("acquisitionMode") or "fresh-context"
    barrier_type = barrier.get("type") or "none"

    if not detected:
      return {
          "blocked": False,
          "barrierType": "none",
          "severity": "info",
          "summary": "No access barrier signature was detected in the rendered surface.",
          "recommendedAcquisition": "continue-current-flow",
          "nextStep": "Proceed with the deterministic audit path.",
      }

    recommendations = {
        "access_denied": (
            "attach-existing-session",
            "Open the target site in your own browser session, confirm the real page renders, enable remote debugging, and rerun the audit with a CDP attach.",
        ),
        "captcha_challenge": (
            "manual-user-session",
            "Complete the human verification in a user-controlled browser session and rerun the audit against that authenticated session.",
        ),
        "login_wall": (
            "authenticated-session",
            "Sign in with an authorized account, export storage state or attach to the live browser session, and rerun the audit.",
        ),
        "bot_mitigation": (
            "authorized-browser-session",
            "Use an approved user session or a site-owner-provided test allowlist; do not attempt to bypass the mitigation automatically.",
        ),
    }
    rec_key, rec_text = recommendations.get(
        barrier_type,
        (
            "authorized-session-required",
            "Use a user-authorized browser session or site-owner-provided access path before rerunning the audit.",
        ),
    )

    severity = "high" if acquisition_mode == "fresh-context" else "medium"
    return {
        "blocked": True,
        "barrierType": barrier_type,
        "severity": severity,
        "summary": barrier.get("label") or "Rendered surface indicates an access barrier.",
        "recommendedAcquisition": rec_key,
        "nextStep": rec_text,
        "signals": barrier.get("signals") or [],
        "excerpt": barrier.get("excerpt") or "",
    }


def main():
    args = parse_args()
    payload = load_probe(args.input)

    chain = (
        RunnableLambda(lambda raw: {
            "meta": raw.get("meta") or {},
            "accessBarrier": raw.get("accessBarrier") or {},
        })
        | RunnableLambda(lambda compact: {
            **compact,
            "renderedPrompt": ChatPromptTemplate.from_messages([
                ("system", "You classify rendered accessibility audit surfaces into safe acquisition paths."),
                ("human", "Title: {title}\nBarrier: {barrier_type}\nSignals: {signals}\nMode: {mode}"),
            ]).format_messages(
                title=(compact["meta"].get("title") or ""),
                barrier_type=(compact["accessBarrier"].get("type") or "none"),
                signals=", ".join(compact["accessBarrier"].get("signals") or []),
                mode=(compact["meta"].get("acquisitionMode") or "fresh-context"),
            )[1].content,
        })
        | RunnableLambda(lambda enriched: {
            **classify_surface(payload),
            "langchainPrompt": enriched["renderedPrompt"],
        })
    )

    result = chain.invoke(payload)
    serialized = json.dumps(result, ensure_ascii=False)
    if args.output:
        Path(args.output).write_text(serialized, encoding="utf-8")
    print(serialized)


if __name__ == "__main__":
    main()
