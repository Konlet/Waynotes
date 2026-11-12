#!/usr/bin/env python3
"""Convert Zygor Classic dungeon REFERENCE guides into ns.RegisterGuide files."""

from __future__ import annotations

import importlib.util
import re
from pathlib import Path

REF = Path(__file__).resolve().parent
SRC_DIR = REF / "Dungeons"
OUT_DIR = REF.parent / "Forever" / "Zygor" / "Dungeons"

SOURCES = [
    ("ZygorDungeonHordeCLASSIC.lua", "Horde", "Zygor Dungeons Horde"),
    ("ZygorDungeonAllianceCLASSIC.lua", "Alliance", "Zygor Dungeons Alliance"),
]


def load_zygor():
    path = REF / "_convert_zygor.py"
    spec = importlib.util.spec_from_file_location("convert_zygor", path)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def band_for(name: str) -> str:
    low = name.lower()
    if "attunement" in low or " raid" in low or low.endswith(" raid") or "raid (" in low:
        return "Raids.lua"
    if low.endswith(" quests") or " quests" in low or low.endswith(" side quests"):
        return "Quests.lua"
    m = re.search(r"\((\d+)\s*-\s*(\d+)\)", name)
    if m:
        start = int(m.group(1))
        if start < 30:
            return "01-30.lua"
        if start < 45:
            return "30-45.lua"
        return "45-60.lua"
    m = re.search(r"\((\d+)\)", name)
    if m:
        level = int(m.group(1))
        if level < 30:
            return "01-30.lua"
        if level < 45:
            return "30-45.lua"
        return "45-60.lua"
    return "Other.lua"


def main() -> None:
    z = load_zygor()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for old in OUT_DIR.glob("*.lua"):
        old.unlink()

    grand_guides = 0
    grand_steps = 0
    toc_files: list[str] = []

    for src_name, faction, group in SOURCES:
        src = SRC_DIR / src_name
        if not src.is_file():
            print(f"Missing {src}")
            continue
        text = src.read_text(encoding="utf-8", errors="replace")
        parsed = z.split_guides(text)
        print(f"\n{src_name}: {len(parsed)} guides")

        buckets: dict[str, list[tuple[str, list[dict]]]] = {}
        for title, body in parsed:
            display = z.guide_display_name(title)
            _, steps = z.convert_guide(title, body)
            fname = f"{faction}_{band_for(display)}"
            buckets.setdefault(fname, []).append((title, steps))
            print(f"  {display} -> {fname} ({len(steps)} steps)")

        for fname, guides in buckets.items():
            path = OUT_DIR / fname
            out: list[str] = []
            out.append("local _, ns = ...")
            out.append("")
            out.append(f"-- Converted from Guides/REFERENCE/Dungeons/{src_name}")
            out.append("-- Zygor Classic dungeon guides. Confirm/click-here gates removed.")
            out.append("")
            file_steps = 0
            kept = 0
            for title, steps in guides:
                if not steps:
                    print(f"  SKIP empty: {title}")
                    continue
                kept += 1
                file_steps += len(steps)
                name = z.guide_display_name(title)
                min_level, max_level = z.guide_levels(name)
                guide_id = "zygor-" + faction.lower() + "-dungeon-" + z.slug(name)
                out.append("ns.RegisterGuide({")
                out.append(f"    id = {z.lua_str(guide_id)},")
                out.append(f"    name = {z.lua_str(name)},")
                out.append(f"    group = {z.lua_str(group)},")
                out.append(f"    faction = {z.lua_str(faction)},")
                if min_level is not None and max_level is not None:
                    out.append(f"    minLevel = {min_level},")
                    out.append(f"    maxLevel = {max_level},")
                out.append("    steps = {")
                for step in steps:
                    out.append(z.emit_step(step))
                out.append("    },")
                out.append("})")
                out.append("")
            path.write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
            toc_files.append(f"Guides/Forever/Zygor/Dungeons/{fname}")
            grand_guides += kept
            grand_steps += file_steps
            print(f"Wrote {path.name} ({kept} guides, {file_steps} steps)")

    print(f"\nDone: {grand_guides} guides, {grand_steps} steps, {len(toc_files)} files")
    for line in toc_files:
        print("TOC", line)


if __name__ == "__main__":
    main()
