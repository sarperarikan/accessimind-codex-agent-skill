import argparse
import json
import os
import re
import subprocess
import sys
import time

from pywinauto import Desktop
from pywinauto.mouse import click
from pywinauto.keyboard import send_keys


SPEECH_VIEWER_RE = re.compile(r".*Speech Viewer.*", re.IGNORECASE)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--browser-path", required=True)
    parser.add_argument("--expected-title", default="")
    parser.add_argument("--expected-host", default="")
    parser.add_argument("--mode", choices=["auto", "session"], default="auto")
    parser.add_argument("--session-name", default="")
    parser.add_argument("--session-seconds", type=int, default=90)
    parser.add_argument("--poll-interval-ms", type=int, default=700)
    parser.add_argument("--steps", type=int, default=6)
    parser.add_argument("--step-delay-ms", type=int, default=900)
    parser.add_argument("--load-delay-ms", type=int, default=4000)
    parser.add_argument("--reuse-existing-browser", action="store_true")
    parser.add_argument("--output")
    return parser.parse_args()


def find_window(patterns, timeout_seconds=15):
    deadline = time.time() + timeout_seconds
    desktop = Desktop(backend="uia")
    lowered = [pattern.lower() for pattern in patterns]
    while time.time() < deadline:
        for window in desktop.windows():
            title = (window.window_text() or "").strip()
            if any(pattern in title.lower() for pattern in lowered):
                return desktop.window(handle=window.handle)
        time.sleep(0.4)
    return None


def get_speech_viewer_window(timeout_seconds=15):
    viewer = find_window(["NVDA Speech Viewer", "Speech Viewer"], timeout_seconds=timeout_seconds)
    if viewer:
        return viewer
    raise RuntimeError("Speech Viewer window was not found.")


def get_speech_text(viewer_window):
    descendants = viewer_window.descendants()
    text_candidates = []
    for item in descendants:
        try:
            value = item.window_text()
        except Exception:
            continue
        if value and value.strip():
            text_candidates.append(value.strip())
    if not text_candidates:
        return ""
    return max(text_candidates, key=len)


def diff_phrase(previous_text, current_text):
    if not current_text:
        return ""
    if not previous_text:
        lines = [line.strip() for line in current_text.splitlines() if line.strip()]
        return lines[-1] if lines else current_text.strip()
    if current_text.startswith(previous_text):
        delta = current_text[len(previous_text):].strip()
        if delta:
            lines = [line.strip() for line in delta.splitlines() if line.strip()]
            return lines[-1] if lines else delta
    prev_lines = [line.strip() for line in previous_text.splitlines() if line.strip()]
    curr_lines = [line.strip() for line in current_text.splitlines() if line.strip()]
    for line in reversed(curr_lines):
        if line and line not in prev_lines:
            return line
    return curr_lines[-1] if curr_lines else ""


def launch_browser(browser_path, url):
    private_flag = "--incognito" if "chrome" in os.path.basename(browser_path).lower() else "--inprivate"
    return subprocess.Popen([browser_path, "--new-window", private_flag, url])


def _normalize_title(text: str) -> str:
    return re.sub(r"[\W_]+", " ", (text or "").lower()).strip()


def focus_browser(browser_path, expected_title="", expected_host="", timeout_seconds=20):
    browser_name = os.path.basename(browser_path).lower()
    title_hints = []
    if "msedge" in browser_name:
        title_hints = ["edge", "microsoft edge"]
    elif "chrome" in browser_name:
        title_hints = ["chrome", "google chrome"]
    else:
        title_hints = [os.path.splitext(browser_name)[0]]
    expected_fragments = []
    if expected_title:
        expected_fragments.append(_normalize_title(expected_title))
    if expected_host:
        expected_fragments.append(_normalize_title(expected_host))

    deadline = time.time() + timeout_seconds
    desktop = Desktop(backend="uia")
    while time.time() < deadline:
        fallback_candidate = None
        for window in desktop.windows():
            title = (window.window_text() or "").strip()
            class_name = (window.element_info.class_name or "").strip()
            if not title:
                continue
            normalized_title = _normalize_title(title)
            if not any(hint in normalized_title for hint in title_hints):
                continue
            if class_name not in ("Chrome_WidgetWin_1", "ApplicationFrameWindow", "MozillaWindowClass"):
                continue
            candidate = desktop.window(handle=window.handle)
            if expected_fragments and any(fragment and fragment in normalized_title for fragment in expected_fragments):
                try:
                    candidate.set_focus()
                    return candidate
                except Exception:
                    continue
            if fallback_candidate is None:
                fallback_candidate = candidate
        if fallback_candidate is not None:
            try:
                fallback_candidate.set_focus()
                return fallback_candidate
            except Exception:
                pass
        time.sleep(0.5)
    raise RuntimeError(f"Browser window for {browser_name} was not found.")


def activate_browser_document(browser_window, attempts=4):
    last_error = None
    for _ in range(attempts):
        try:
            browser_window.set_focus()
            browser_window.restore()
        except Exception as exc:
            last_error = exc
        try:
            rect = browser_window.rectangle()
            target = (rect.left + max(300, int(rect.width() * 0.35)), rect.top + max(220, int(rect.height() * 0.35)))
            click(coords=target)
            time.sleep(0.6)
            send_keys("^{HOME}")
            time.sleep(0.4)
            send_keys("{VK_INSERT down}{SPACE}{VK_INSERT up}")
            time.sleep(0.4)
            return
        except Exception as exc:
            last_error = exc
            time.sleep(0.7)
    if last_error:
        raise RuntimeError(f"Browser document could not be activated: {last_error}") from last_error
    raise RuntimeError("Browser document could not be activated.")


def close_dialog_if_present(title_patterns, button_title, timeout_seconds=5):
    window = find_window(title_patterns, timeout_seconds=timeout_seconds)
    if not window:
        return False
    window.set_focus()
    button = window.child_window(title=button_title, control_type="Button")
    button.click_input()
    time.sleep(1.0)
    return True


def normalize_nvda_session():
    close_dialog_if_present(["Welcome to NVDA"], "OK", timeout_seconds=8)
    close_dialog_if_present(["Usage Data Collection"], "No", timeout_seconds=4)


def ensure_speech_viewer():
    existing = find_window(["NVDA Speech Viewer", "Speech Viewer"], timeout_seconds=2)
    if existing:
        return existing
    for _ in range(3):
        send_keys("{VK_INSERT down}n{VK_INSERT up}")
        time.sleep(1.0)
        send_keys("tv")
        try:
            return get_speech_viewer_window(timeout_seconds=6)
        except RuntimeError:
            time.sleep(1.2)
    return get_speech_viewer_window(timeout_seconds=18)


def make_event(step, action, previous_text, current_text, started_at):
    return {
        "step": step,
        "action": action,
        "spokenPhrase": diff_phrase(previous_text, current_text),
        "speechViewerText": current_text,
        "timestamp": time.time(),
        "elapsedMs": int((time.time() - started_at) * 1000),
    }


def collect_auto_events(args, viewer_window, browser_window):
    started_at = time.time()
    initial_text = get_speech_text(viewer_window)
    events = [make_event(0, "page-load-and-document-activate", "", initial_text, started_at)]

    previous_text = initial_text
    for step in range(1, args.steps + 1):
        browser_window.set_focus()
        send_keys("{TAB}")
        time.sleep(args.step_delay_ms / 1000.0)
        current_text = get_speech_text(viewer_window)
        events.append(make_event(step, "TAB", previous_text, current_text, started_at))
        previous_text = current_text
    return events


def collect_session_events(args, viewer_window, browser_window):
    started_at = time.time()
    initial_text = get_speech_text(viewer_window)
    session_name = args.session_name or "manual-navigation-session"
    events = [make_event(0, "session-start", "", initial_text, started_at)]
    previous_text = initial_text
    deadline = time.time() + max(1, args.session_seconds)
    step = 1

    while time.time() < deadline:
        browser_window.set_focus()
        time.sleep(args.poll_interval_ms / 1000.0)
        current_text = get_speech_text(viewer_window)
        if current_text == previous_text:
            continue
        events.append(make_event(step, "speech-update", previous_text, current_text, started_at))
        previous_text = current_text
        step += 1

    final_text = get_speech_text(viewer_window)
    if final_text != previous_text:
        events.append(make_event(step, "session-end", previous_text, final_text, started_at))
        previous_text = final_text

    return events, {
        "name": session_name,
        "startedAt": started_at,
        "endedAt": time.time(),
        "durationSeconds": max(1, args.session_seconds),
        "pollIntervalMs": args.poll_interval_ms,
    }


def main():
    args = parse_args()
    browser_proc = None
    try:
        normalize_nvda_session()
        viewer_window = ensure_speech_viewer()
        if not args.reuse_existing_browser:
            browser_proc = launch_browser(args.browser_path, args.url)
        browser_window = focus_browser(
            args.browser_path,
            expected_title=args.expected_title,
            expected_host=args.expected_host,
        )
        time.sleep(args.load_delay_ms / 1000.0)
        activate_browser_document(browser_window)
        time.sleep(1.2)

        session_info = None
        if args.mode == "session":
            events, session_info = collect_session_events(args, viewer_window, browser_window)
        else:
            events = collect_auto_events(args, viewer_window, browser_window)

        spoken_phrases = [event["spokenPhrase"] for event in events if event["spokenPhrase"]]
        result = {
            "url": args.url,
            "mode": args.mode,
            "events": events,
            "spokenPhraseLog": spoken_phrases,
            "uniqueSpokenPhraseLog": list(dict.fromkeys(spoken_phrases)),
            "lastSpokenPhrase": spoken_phrases[-1] if spoken_phrases else "",
            "speechViewerDetected": True,
            "browserAcquisition": "reused-existing-window" if args.reuse_existing_browser else "launched-new-window",
        }
        if session_info is not None:
            result["session"] = {
                "name": session_info["name"],
                "startedAt": time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(session_info["startedAt"])),
                "endedAt": time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(session_info["endedAt"])),
                "durationSeconds": session_info["durationSeconds"],
                "pollIntervalMs": session_info["pollIntervalMs"],
                "eventCount": len(events),
                "uniquePhraseCount": len(result["uniqueSpokenPhraseLog"]),
            }

        payload = json.dumps(result, ensure_ascii=False)
        if args.output:
            with open(args.output, "w", encoding="utf-8") as handle:
                handle.write(payload)
        sys.stdout.buffer.write(payload.encode("utf-8"))
        sys.stdout.buffer.write(b"\n")
    finally:
        if browser_proc and browser_proc.poll() is None:
            browser_proc.terminate()
            try:
                browser_proc.wait(timeout=5)
            except Exception:
                browser_proc.kill()


if __name__ == "__main__":
    main()
