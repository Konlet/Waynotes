#!/usr/bin/env python3
"""Convert Zygor Classic Horde leveling REFERENCE into ns.RegisterGuide files."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

REF = Path(__file__).resolve().parent
FOREVER = REF.parent / "Forever" / "Zygor"

# Classic Era / Forever-authored UiMap IDs.
ZONE_UI_MAP = {
    "durotar": 1411,
    "mulgore": 1412,
    "the barrens": 1413,
    "barrens": 1413,
    "tirisfal glades": 1420,
    "tirisfal": 1420,
    "silverpine forest": 1421,
    "undercity": 1458,
    "orgrimmar": 1454,
    "thunder bluff": 1456,
    "stonetalon mountains": 1442,
    "ashenvale": 1440,
    "hillsbrad foothills": 1424,
    "alterac mountains": 1416,
    "arathi highlands": 1417,
    "thousand needles": 1441,
    "desolace": 1443,
    "dustwallow marsh": 1445,
    "feralas": 1444,
    "tanaris": 1446,
    "un'goro crater": 1449,
    "ungoro crater": 1449,
    "silithus": 1451,
    "felwood": 1448,
    "winterspring": 1452,
    "moonglade": 1450,
    "azshara": 1447,
    "stranglethorn vale": 1434,
    "swamp of sorrows": 1435,
    "badlands": 1418,
    "searing gorge": 1427,
    "burning steppes": 1428,
    "blasted lands": 1419,
    "the hinterlands": 1425,
    "hinterlands": 1425,
    "western plaguelands": 1422,
    "eastern plaguelands": 1423,
    "wetlands": 1437,
    "redridge mountains": 1433,
    "elwynn forest": 1429,
    "westfall": 1436,
    "duskwood": 1431,
    "deadwind pass": 1430,
    "loch modan": 1432,
    "dun morogh": 1426,
    "wetlands": 1437,
    "darkshore": 1439,
    "teldrassil": 1438,
    "darnassus": 1457,
    "ironforge": 1455,
    "stormwind city": 1453,
    "stormwind": 1453,
}

SKIP_TITLES = {
    "Leveling Guides\\Startup Guide Wizard",
}

# Output bands: (filename, group label, title substring predicates / exact titles)
# Guides not listed go into Optional.
LEVELING_BANDS: list[tuple[str, list[str]]] = [
    (
        "Horde_01-13_Starters.lua",
        [
            "Leveling Guides\\Undead Starter (1-13)",
            "Leveling Guides\\Tauren Starter (1-13)",
            "Leveling Guides\\Orc & Troll Starter (1-13)",
        ],
    ),
    (
        "Horde_13-30.lua",
        [
            "Leveling Guides\\Silverpine Forest (13-15)",
            "Leveling Guides\\The Barrens & Stonetalon Mountain (15-21)",
            "Leveling Guides\\Ashenvale (21-22)",
            "Leveling Guides\\Hillsbrad Foothills (22-24)",
            "Leveling Guides\\The Barrens (24-25)",
            "Leveling Guides\\Stonetalon Mountains (25-26)",
            "Leveling Guides\\Ashenvale (26-28)",
            "Leveling Guides\\Thousand Needles (28-30)",
        ],
    ),
    (
        "Horde_30-40.lua",
        [
            "Leveling Guides\\Hillsbrad Foothills (30-32)",
            "Leveling Guides\\Arathi Highlands (32-33)",
            "Leveling Guides\\Thousand Needles (33-34)",
            "Leveling Guides\\Desolace (34-36)",
            "Leveling Guides\\Stranglethorn Vale (36-37)",
            "Leveling Guides\\Dustwallow Marsh (37-38)",
            "Leveling Guides\\Alterac Mountains & Arathi Highlands (38-39)",
            "Leveling Guides\\Badlands (39-40)",
        ],
    ),
    (
        "Horde_40-50.lua",
        [
            "Leveling Guides\\Stranglethorn Vale & Swamp of Sorrows (40-41)",
            "Leveling Guides\\Desolace (41-41)",
            "Leveling Guides\\Tanaris (41-42)",
            "Leveling Guides\\Dustwallow Marsh (42-42)",
            "Leveling Guides\\Tanaris (42-43)",
            "Leveling Guides\\Feralas (43-44)",
            "Leveling Guides\\Stranglethorn Vale (44-45)",
            "Leveling Guides\\Swamp of Sorrows (45-46)",
            "Leveling Guides\\Tanaris & Dustwallow Marsh (46-48)",
            "Leveling Guides\\The Hinterlands (48-49)",
            "Leveling Guides\\Feralas & Un'Goro Crater (49-50)",
        ],
    ),
    (
        "Horde_50-60.lua",
        [
            "Leveling Guides\\Stranglethorn Vale & Swamp of Sorrows (50-50)",
            "Leveling Guides\\Blasted Lands (50-51)",
            "Leveling Guides\\Searing Gorge (51-51)",
            "Leveling Guides\\Burning Steppes & Azshara (51-52)",
            "Leveling Guides\\Felwood & Winterspring (52-53)",
            "Leveling Guides\\Un'Goro Crater (53-54)",
            "Leveling Guides\\Azshara (54-54)",
            "Leveling Guides\\Felwood & Winterspring (54-56)",
            "Leveling Guides\\Western & Eastern Plaguelands (56-58)",
            "Leveling Guides\\Winterspring (58-59)",
            "Leveling Guides\\Silithus (59-60)",
        ],
    ),
]

OPTIONAL_PREFIXES = (
    "Leveling Guides\\Ahn'Qiraj Gear\\",
    "Leveling Guides\\Scepter of the Shifting Sands",
    "Leveling Guides\\Cenarion Field Duty",
    "Leveling Guides\\Druid Class Quests",
    "Leveling Guides\\Priest Class Quests",
    "Leveling Guides\\Warrior Class Quests",
    "Leveling Guides\\Hunter Class Quests",
    "Leveling Guides\\Mage Class Quests",
    "Leveling Guides\\Rogue Class Quests",
    "Leveling Guides\\Shaman Class Quests",
    "Leveling Guides\\Warlock Class Quests",
    "Leveling Guides\\Cozy Sleeping Bag",
    "Leveling Guides\\City of Dalaran Key",
)

ONLY_IF = re.compile(r"\|only if\s+(.+?)(?=\||$)", re.I)
GOTO = re.compile(
    r"\|goto\s+([^|]+?)\s+(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)(?=\s*\||\s*$)",
    re.I,
)
ACCEPT = re.compile(r"\baccept\s+(.+?)##(\d+)", re.I)
TURNIN = re.compile(r"\bturnin\s+(.+?)##(\d+)", re.I)
QUEST_OBJ = re.compile(r"\|q\s+(\d+)(?:/(\d+))?", re.I)
TIP = re.compile(r"\|tip\s+(.+?)(?=\||$)", re.I)
ZYGOR_COLOR = re.compile(r"\{[oyrgbwp]\}|\{/[oyrgbwp]\}", re.I)
HASH_ID = re.compile(r"##\d+")
UNDERSCORE_TITLE = re.compile(r"^_(.+)_$")
WHITESPACE = re.compile(r"[ \t]+")


def lua_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def slug(s: str) -> str:
    s = s.lower().replace("&", " and ")
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s


def clean_text(s: str) -> str:
    s = s.replace("''", "'")
    s = ZYGOR_COLOR.sub("", s)
    s = re.sub(r"\{\}", "", s)
    s = HASH_ID.sub("", s)
    s = re.sub(r"\+(?=\s|$)", "", s)  # Zygor plural markers after ##id
    s = re.sub(r"\|[a-zA-Z]+(?:\s+[^|]*)?", " ", s)  # leftover pipes on same fragment
    s = s.replace("|", " ")
    s = WHITESPACE.sub(" ", s).strip(" .-\t")
    # Zygor section headers like _NOTE:_ or _Destroy This Item:_
    s = re.sub(r"_([^_]+)_:?", r"\1", s)
    s = WHITESPACE.sub(" ", s).strip(" .-\t")
    m = UNDERSCORE_TITLE.match(s)
    if m:
        s = m.group(1)
    # Drop trailing orphan colons from headers
    s = re.sub(r"\s*:\s*$", "", s)
    s = re.sub(r"\s*:\s*\.", ".", s)
    return s.strip()


def sentence_case_action(s: str) -> str:
    for verb in ("kill", "collect", "use", "cast", "click", "enter", "leave", "follow", "talk"):
        if s.lower().startswith(verb + " "):
            return verb.capitalize() + s[len(verb) :]
    return s


def zone_map(zone: str) -> int | None:
    z = zone.strip()
    # Tirisfal Glades/0 -> Tirisfal Glades
    z = re.sub(r"/\d+$", "", z).strip()
    return ZONE_UI_MAP.get(z.lower())


def parse_only_if(blob: str) -> str | None:
    m = ONLY_IF.search(blob)
    if not m:
        return None
    cond = m.group(1).strip()
    # Simplify common race/class checks
    cond = re.sub(r"\s+", " ", cond)
    if cond.lower().startswith("not "):
        return "!" + cond[4:].strip()
    return cond


def parse_goto(blob: str) -> tuple[int, float, float] | None:
    m = GOTO.search(blob)
    if not m:
        return None
    ui = zone_map(m.group(1))
    if not ui:
        return None
    return ui, float(m.group(2)), float(m.group(3))


def split_guides(text: str) -> list[tuple[str, str]]:
    """Return (title, body) for each RegisterGuide."""
    out: list[tuple[str, str]] = []
    header = re.compile(r'ZygorGuidesViewer:RegisterGuide\("([^"]+)"')
    pos = 0
    while True:
        m = header.search(text, pos)
        if not m:
            break
        # Raw Lua source keeps \\\\ as two chars; normalize to one path separator.
        title = m.group(1).replace("\\\\", "\\")
        body_open = text.find("},[[", m.end())
        if body_open < 0:
            pos = m.end()
            continue
        start = body_open + 4
        body_close = text.find("]])", start)
        if body_close < 0:
            break
        out.append((title, text[start:body_close]))
        pos = body_close + 3
    return out


def split_steps(body: str) -> list[str]:
    # Drop defaultfor / header lines before first step
    idx = re.search(r"(?m)^step\b", body)
    if not idx:
        return []
    body = body[idx.start() :]
    chunks = re.split(r"(?m)^(?=step\b|stickystart\b|stickystop\b)", body)
    return [c for c in chunks if c.strip()]


def convert_step(raw: str) -> dict | None:
    # Flatten to single blob but keep line tips
    lines = [ln.rstrip() for ln in raw.splitlines()]
    if not lines:
        return None
    kind = lines[0].strip().split(None, 1)[0].lower() if lines[0].strip() else ""
    if kind in {"stickystart", "stickystop"}:
        return None

    # Join remaining content; Zygor tags often share lines with actions
    content_lines = []
    for ln in lines[1:]:
        s = ln.strip()
        if not s:
            continue
        if s.startswith("label "):
            continue
        content_lines.append(s)
    if not content_lines:
        return None

    blob = "\n".join(content_lines)
    only = parse_only_if(blob)
    pin = parse_goto(blob)

    def useful_tip(t: str) -> bool:
        low = t.lower()
        if not t:
            return False
        if "click here" in low:
            return False
        if low in {"confirm", "confirm begin"}:
            return False
        return True

    tips = [clean_text(m.group(1)) for m in TIP.finditer(blob)]
    tips = [t for t in tips if useful_tip(t)]

    # Pure Zygor confirm / "click here" gates are not used in our format.
    has_confirm = any(
        re.split(r"\|", ln, maxsplit=1)[0].strip().lower().startswith("confirm")
        for ln in content_lines
        if not ln.startswith("|")
    )
    has_quest_action = bool(ACCEPT.search(blob) or TURNIN.search(blob) or QUEST_OBJ.search(blob))
    has_real_action = any(
        re.split(r"\|", ln, maxsplit=1)[0].strip().lower().startswith(
            ("talk ", "kill ", "collect ", "use ", "cast ", "click ", "train ", "sell ", "ding ", "trash ", "home ", "fpath ", "fly ", "hearth ")
        )
        for ln in content_lines
        if not ln.startswith("|")
    )
    if has_confirm and not has_quest_action and not has_real_action:
        return None

    # Per-line accept/turnin so |only if stays attached to the right quest.
    accepts: list[tuple[str, int, str | None]] = []
    turnins: list[tuple[str, int, str | None]] = []
    for ln in content_lines:
        line_only = parse_only_if(ln)
        for name, qid in TURNIN.findall(ln):
            turnins.append((clean_text(name), int(qid), line_only))
        for name, qid in ACCEPT.findall(ln):
            accepts.append((clean_text(name), int(qid), line_only))

    # Step-level only if every gated line shares one class, else leave unset.
    gated = [o for o in [only] + [a[2] for a in accepts] + [t[2] for t in turnins] if o]
    if gated and len(set(gated)) == 1:
        only = gated[0]
    elif any(a[2] for a in accepts) or any(t[2] for t in turnins):
        only = None

    # Strip tagged lines for prose extraction
    prose_lines = []
    for ln in content_lines:
        if ln.startswith("|"):
            continue
        # Remove inline tags from action lines
        base = re.split(r"\|", ln, maxsplit=1)[0].strip()
        if not base:
            continue
        # Skip pure meta commands without readable value
        low = base.lower()
        if low.startswith(("confirm", "ding ", "trash ", "findcity", "openskill", "talknpcs")):
            # confirm / "click here" steps are dropped; keep ding/trash text
            if low.startswith("ding "):
                prose_lines.append("Grind to " + base.split(None, 1)[1])
            elif low.startswith("trash "):
                prose_lines.append("Destroy " + clean_text(base[6:]))
            continue
        # talk / kill / collect / use / cast lines
        if low.startswith("talk "):
            name = clean_text(re.sub(r"^talk\s+", "", base, flags=re.I))
            prose_lines.append(f"Talk to {name}")
            continue
        if low.startswith("kill "):
            prose_lines.append(sentence_case_action(clean_text(base)))
            continue
        if low.startswith("collect "):
            prose_lines.append(sentence_case_action(clean_text(base)))
            continue
        if low.startswith(("use ", "cast ", "click ", "clicknpc ", "clickobject ", "enter ", "leave ", "follow ")):
            prose_lines.append(sentence_case_action(clean_text(base)))
            continue
        if "|trainer" in ln.lower() or low.startswith("train "):
            prose_lines.append(clean_text(base) if base.lower() != "train abilities" else "Train your class abilities")
            continue
        if "|vendor" in ln.lower() or low.startswith("sell "):
            prose_lines.append(clean_text(base) if not base.lower().startswith("sell") else "Vendor trash")
            continue
        if low.startswith(("accept ", "turnin ")):
            # Names already captured; still useful if clean_text of accept line
            continue
        if low.startswith(("home ", "fpath ", "fly ", "hearth ", "bind ")):
            prose_lines.append(clean_text(base))
            continue
        # Generic prose / NOTE headers
        cleaned = clean_text(base)
        if cleaned:
            prose_lines.append(cleaned)

    # Deduplicate prose while preserving order
    text_parts: list[str] = []
    for p in prose_lines:
        p = sentence_case_action(p) if p[:1].islower() else p
        if not useful_tip(p):
            continue
        # Strip leftover click-here phrases glued onto real text.
        p = re.sub(r"(?i)\s*click here(?: to continue| to change paths)?\.?", "", p).strip(" .")
        if p and p not in text_parts:
            text_parts.append(p)

    # Drop header-only leftovers when a stronger action follows
    if len(text_parts) > 1:
        headers = {"note", "destroy this item", "wrong character race"}
        text_parts = [p for p in text_parts if p.lower().rstrip(".") not in headers] or text_parts

    for name, _qid, line_only in turnins:
        label = f"Turn in {name}" if name else "Turn in the quest"
        if line_only and line_only != only:
            label = f"[{line_only}] {label}"
        if label not in text_parts:
            text_parts.append(label)
    for name, _qid, line_only in accepts:
        label = f"Accept {name}" if name else "Accept the quest"
        if line_only and line_only != only:
            label = f"[{line_only}] {label}"
        if label not in text_parts:
            text_parts.append(label)

    if not text_parts and tips:
        text_parts.append(tips[0])
        tips = tips[1:]

    text = ". ".join(text_parts).strip()
    if only and text:
        text = f"[{only}] {text}"
    elif only and not text:
        text = f"[{only}]"
    if text and not text.endswith((".", "!", "?")):
        text += "."

    # Quest automation
    when: str | None = None
    quest_ids: list[int] = []
    details: list[str] = []

    # Prefer ungated quests for auto-advance; gated ones stay in text only if mixed.
    ungated_accepts = [qid for _, qid, o in accepts if not o]
    ungated_turnins = [qid for _, qid, o in turnins if not o]
    all_accepts = [qid for _, qid, _ in accepts]
    all_turnins = [qid for _, qid, _ in turnins]

    if all_turnins and not all_accepts:
        when = "complete"
        quest_ids = ungated_turnins or all_turnins
    elif all_accepts and not all_turnins:
        when = "accepted"
        quest_ids = ungated_accepts or all_accepts
    elif all_accepts and all_turnins:
        when = "accepted"
        quest_ids = ungated_accepts or all_accepts
        for name, qid, _o in turnins:
            details.append(f"Turn in {name}" if name else f"Turn in quest {qid}")
    else:
        # Objective / travel / train
        objs = QUEST_OBJ.findall(blob)
        if objs:
            for qid, _obj in objs:
                q = int(qid)
                if q not in quest_ids:
                    quest_ids.append(q)

    note = None
    if tips:
        note = tips[0]
        for t in tips[1:]:
            if t not in details and t != text.rstrip("."):
                details.append(t)

    if not text and not quest_ids and not note and not details:
        return None
    if not text:
        if when == "accepted":
            text = "Accept the quest."
        elif when == "complete":
            text = "Turn in the quest."
        elif quest_ids:
            text = "Do the quest objectives."
        elif note:
            text = note
            note = None
        else:
            text = details[0]
            details = details[1:]

    step: dict = {"text": text}
    if note and note != text.rstrip("."):
        step["note"] = note
    if when:
        step["when"] = when
    if len(quest_ids) == 1:
        step["quest"] = quest_ids[0]
    elif len(quest_ids) > 1:
        step["quests"] = quest_ids
    if pin:
        step["map"], step["x"], step["y"] = pin
    if details:
        step["details"] = details[:6]
    return step


def emit_step(step: dict, indent: str = "        ") -> str:
    lines = [indent + "{"]
    inner = indent + "    "
    lines.append(f"{inner}text = {lua_str(step['text'])},")
    if "note" in step:
        lines.append(f"{inner}note = {lua_str(step['note'])},")
    if "quest" in step:
        lines.append(f"{inner}quest = {step['quest']},")
    if "quests" in step:
        ids = ", ".join(str(q) for q in step["quests"])
        lines.append(f"{inner}quests = {{ {ids} }},")
    if "when" in step:
        lines.append(f"{inner}when = {lua_str(step['when'])},")
    if "map" in step:
        lines.append(f"{inner}map = {step['map']},")
        lines.append(f"{inner}x = {step['x']},")
        lines.append(f"{inner}y = {step['y']},")
    if "details" in step:
        lines.append(f"{inner}details = {{")
        for d in step["details"]:
            lines.append(f"{inner}    {lua_str(d)},")
        lines.append(f"{inner}}},")
    lines.append(indent + "},")
    return "\n".join(lines)


def guide_display_name(title: str) -> str:
    # Leveling Guides\\Undead Starter (1-13) -> Undead Starter (1-13)
    return title.split("\\")[-1].strip()


def guide_id(title: str) -> str:
    name = guide_display_name(title)
    return "zygor-horde-" + slug(name)


def guide_levels(name: str) -> tuple[int | None, int | None]:
    m = re.search(r"\((\d+)\s*-\s*(\d+)\)", name)
    if m:
        return int(m.group(1)), int(m.group(2))
    m = re.search(r"\((\d+)\)", name)
    if m:
        level = int(m.group(1))
        return level, level
    m = re.search(r"(\d+)\s*-\s*(\d+)", name)
    if m:
        return int(m.group(1)), int(m.group(2))
    return None, None


def guide_races(name: str) -> list[str] | None:
    low = name.lower()
    if "undead" in low or "scourge" in low:
        return ["Undead"]
    if "tauren" in low:
        return ["Tauren"]
    if "orc" in low or "troll" in low:
        races = []
        if "orc" in low:
            races.append("Orc")
        if "troll" in low:
            races.append("Troll")
        return races or ["Orc", "Troll"]
    return None


def convert_guide(title: str, body: str) -> tuple[str, list[dict]]:
    steps_raw = split_steps(body)
    steps: list[dict] = []
    for chunk in steps_raw:
        step = convert_step(chunk)
        if step:
            steps.append(step)
    return title, steps


def emit_file(path: Path, source_name: str, guides: list[tuple[str, list[dict]]]) -> int:
    out: list[str] = []
    out.append("local _, ns = ...")
    out.append("")
    out.append(f"-- Converted from Guides/REFERENCE/{source_name}")
    out.append("-- Zygor Classic Horde leveling. Class/race gates kept in [brackets].")
    out.append("")
    total = 0
    for title, steps in guides:
        if not steps:
            print(f"  SKIP empty: {title}")
            continue
        total += len(steps)
        name = guide_display_name(title)
        min_level, max_level = guide_levels(name)
        races = guide_races(name)
        out.append("ns.RegisterGuide({")
        out.append(f"    id = {lua_str(guide_id(title))},")
        out.append(f"    name = {lua_str(name)},")
        out.append('    group = "Zygor Horde",')
        out.append('    faction = "Horde",')
        if min_level is not None and max_level is not None:
            out.append(f"    minLevel = {min_level},")
            out.append(f"    maxLevel = {max_level},")
        if races:
            out.append("    races = { " + ", ".join(lua_str(r) for r in races) + " },")
        out.append("    steps = {")
        for step in steps:
            out.append(emit_step(step))
        out.append("    },")
        out.append("})")
        out.append("")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
    return total


def band_for(title: str) -> str:
    for filename, titles in LEVELING_BANDS:
        if title in titles:
            return filename
    for prefix in OPTIONAL_PREFIXES:
        if title.startswith(prefix) or title == prefix:
            return "Horde_Optional.lua"
    return "Horde_Optional.lua"


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "src",
        nargs="?",
        default=REF / "ZygorLevelingHordeCLASSIC.lua",
        type=Path,
    )
    args = ap.parse_args()
    src = args.src if args.src.is_file() else REF / args.src.name
    text = src.read_text(encoding="utf-8", errors="replace")
    parsed = split_guides(text)
    print(f"Parsed {len(parsed)} Zygor guides from {src.name}")

    buckets: dict[str, list[tuple[str, list[dict]]]] = {}
    for title, body in parsed:
        if title in SKIP_TITLES:
            print(f"  skip wizard: {title}")
            continue
        _title, steps = convert_guide(title, body)
        fname = band_for(title)
        buckets.setdefault(fname, []).append((title, steps))
        print(f"  {guide_display_name(title)} -> {fname} ({len(steps)} steps)")

    FOREVER.mkdir(parents=True, exist_ok=True)
    # Remove previous generated zygor files in this folder
    for old in FOREVER.glob("Horde_*.lua"):
        old.unlink()

    grand = 0
    files = 0
    for fname, guides in buckets.items():
        path = FOREVER / fname
        n = emit_file(path, src.name, guides)
        files += 1
        grand += n
        print(f"Wrote {path} ({len(guides)} guides, {n} steps)")

    print(f"Done: {files} files, {grand} total steps")


if __name__ == "__main__":
    main()
