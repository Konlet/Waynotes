"""
Convert Era percent pins to Forever in curated guides that set forever = true.

Uses QuestieDB data/Forever/conversion.json coefficients for changed UiMaps.
Only rewrites x/y on steps whose map id has a Forever transform with changed=true.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QDB = ROOT / "_questiedb" / "data" / "Forever"
CURATED = ROOT / "Guides" / "Forever" / "Curated"


def load_changed_coeffs() -> dict[int, dict[str, float]]:
    data = json.loads((QDB / "conversion.json").read_text(encoding="utf-8"))
    out: dict[int, dict[str, float]] = {}
    for t in data["geometry"]["transforms"]:
        if t.get("changed"):
            out[int(t["ui_map_id"])] = t["coefficients"]
    return out


def fmt(v: float) -> str:
    s = f"{v:.2f}".rstrip("0").rstrip(".")
    return s


def convert_file(path: Path, coeffs: dict[int, dict[str, float]], dry_run: bool) -> int:
    text = path.read_text(encoding="utf-8")
    if "forever = true" not in text and "forever=true" not in text:
        return 0

    lines = text.splitlines(keepends=True)
    i = 0
    changes = 0
    current_map: int | None = None
    while i < len(lines):
        line = lines[i]
        mm = re.match(r"^(\s*)map\s*=\s*(\d+)(\s*,?\s*)$", line)
        if mm:
            current_map = int(mm.group(2))
            i += 1
            continue
        if current_map is None or current_map not in coeffs:
            # Reset map when a step ends.
            if re.match(r"^\s*\},?\s*$", line):
                current_map = None
            i += 1
            continue

        xm = re.match(r"^(\s*)x\s*=\s*(-?[0-9.]+)(\s*,?\s*)$", line)
        if xm and i + 1 < len(lines):
            ym = re.match(r"^(\s*)y\s*=\s*(-?[0-9.]+)(\s*,?\s*)$", lines[i + 1])
            if ym:
                c = coeffs[current_map]
                old_x = float(xm.group(2))
                old_y = float(ym.group(2))
                new_x = c["scale_x"] * old_x + c["offset_x"]
                new_y = c["scale_y"] * old_y + c["offset_y"]
                # Skip no-ops.
                if abs(new_x - old_x) >= 0.05 or abs(new_y - old_y) >= 0.05:
                    nx, ny = fmt(new_x), fmt(new_y)
                    x_comma = "," if "," in line else ""
                    y_comma = "," if "," in lines[i + 1] else ""
                    x_nl = "\n" if line.endswith("\n") else ""
                    y_nl = "\n" if lines[i + 1].endswith("\n") else ""
                    lines[i] = f"{xm.group(1)}x = {nx}{x_comma}{x_nl}"
                    lines[i + 1] = f"{ym.group(1)}y = {ny}{y_comma}{y_nl}"
                    changes += 1
                    print(
                        f"{path.name}:{i+1} map {current_map} "
                        f"{fmt(old_x)},{fmt(old_y)} -> {nx},{ny}"
                    )
                i += 2
                continue
        if re.match(r"^\s*\},?\s*$", line):
            current_map = None
        i += 1

    if changes and not dry_run:
        path.write_text("".join(lines), encoding="utf-8")
    return changes


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument(
        "--maps",
        type=int,
        nargs="*",
        help="Only convert these UiMap ids (default: all changed maps)",
    )
    ap.add_argument("files", nargs="*", help="Optional curated filenames")
    args = ap.parse_args()

    coeffs = load_changed_coeffs()
    if args.maps:
        coeffs = {m: coeffs[m] for m in args.maps if m in coeffs}

    print("Changed Forever maps:", sorted(coeffs))
    if args.files:
        files = [CURATED / f for f in args.files]
    else:
        files = sorted(
            f
            for f in CURATED.glob("*_Curated.lua")
            if not f.name.startswith("Professions_")
        )

    total = 0
    for f in files:
        n = convert_file(f, coeffs, dry_run=args.dry_run)
        if n:
            print(f"  -> {n} pins in {f.name}")
            total += n
    print(f"Total pin conversions: {total}" + (" (dry-run)" if args.dry_run else ""))


if __name__ == "__main__":
    main()
