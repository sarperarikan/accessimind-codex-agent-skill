import argparse
from pathlib import Path

from ftfy import fix_text


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("path")
    args = parser.parse_args()

    path = Path(args.path)
    text = path.read_text(encoding="utf-8")
    path.write_text(fix_text(text), encoding="utf-8", newline="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
