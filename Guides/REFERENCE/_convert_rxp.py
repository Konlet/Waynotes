#!/usr/bin/env python3
"""Convert RXP Forever REFERENCE guides into ns.RegisterGuide format."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

REF = Path(__file__).resolve().parent
FOREVER = REF.parent / "Forever"

# Classic Era UiMap IDs used by authored pins.
ZONE_UI_MAP = {
    "mulgore": 1412,
    "durotar": 1411,
    "the barrens": 1413,
    "barrens": 1413,
    "thunder bluff": 1456,
    "orgrimmar": 1454,
    "tirisfal glades": 1420,
    "tirisfal": 1420,
    "silverpine forest": 1421,
    "stonetalon mountains": 1442,
    "ashenvale": 1440,
    "elwynn forest": 1429,
    "westfall": 1436,
    "redridge mountains": 1433,
    "loch modan": 1432,
    "dun morogh": 1426,
    "teldrassil": 1438,
    "darkshore": 1439,
    "darnassus": 1457,
    "ironforge": 1455,
    "stormwind city": 1453,
    "undercity": 1458,
}

RXP_NAME = re.compile(
    r"\|cRXP_(FRIENDLY|ENEMY|LOOT|PICK|QUEST)_([^|]+)\|r"
)
RXP_WRAP = re.compile(
    r"\|cRXP_(WARN|BUY|BAD)_(.+?)\|r"
)
TEXTURE = re.compile(r"\|T[^|]+\|t")
COLOR = re.compile(r"\|c[0-9A-Fa-f]{8}")
PIPE_R = re.compile(r"\|r")
PIPE_H = re.compile(r"\|H[^|]*\|h")
PIPE_END_H = re.compile(r"\|h")
WHITESPACE = re.compile(r"[ \t]+")
INLINE_CLASS = re.compile(r"\s*<<\s*[^<].*$")
PIN_COMMENT = re.compile(
    r"^c:([^,]+),([0-9]+(?:\.[0-9]+)?),([0-9]+(?:\.[0-9]+)?)\s*$",
    re.I,
)


def clean_markup(s: str) -> str:
    s = INLINE_CLASS.sub("", s)
    for _ in range(8):
        nxt = RXP_NAME.sub(lambda m: m.group(2), s)
        nxt = RXP_WRAP.sub(lambda m: m.group(2), nxt)
        if nxt == s:
            break
        s = nxt
    s = TEXTURE.sub("", s)
    s = COLOR.sub("", s)
    s = PIPE_R.sub("", s)
    s = PIPE_H.sub("", s)
    s = PIPE_END_H.sub("", s)
    s = s.replace("|n", " ")
    s = re.sub(r"\|cRXP_[A-Z]+_", "", s)
    s = s.replace("|", "")
    s = WHITESPACE.sub(" ", s).strip()
    s = s.strip(" .")
    return s


def lua_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def parse_guides(text: str) -> list[tuple[str, str]]:
    parts = re.split(r"RXPGuides\.RegisterGuide\(\[\[", text)[1:]
    out: list[tuple[str, str]] = []
    for part in parts:
        body = part.split("]])", 1)[0]
        name_m = re.search(r"^#name\s+(.+)$", body, re.M)
        name = name_m.group(1).strip() if name_m else "Unknown"
        out.append((name, body))
    return out


def split_steps(body: str) -> list[str]:
    idx = re.search(r"^step(?:\s|<<|$)", body, re.M)
    if not idx:
        return []
    body = body[idx.start() :]
    chunks = re.split(r"(?m)^(?=step(?:\s|<<|$))", body)
    return [c for c in chunks if c.strip()]


def step_class_filter(header_line: str) -> str | None:
    m = re.match(r"^step\s*(<<\s*.+)?\s*$", header_line.strip())
    if not m or not m.group(1):
        return None
    filt = m.group(1).strip()
    if filt.startswith("<<"):
        filt = filt[2:].strip()
    low = filt.lower()
    if low == "skip" or low.startswith("skip ") or low.startswith("skip-"):
        return "skip"
    return filt


def parse_pin(comment: str | None) -> dict | None:
    if not comment:
        return None
    m = PIN_COMMENT.match(comment.strip())
    if not m:
        return None
    zone = m.group(1).strip().lower()
    ui_map = ZONE_UI_MAP.get(zone)
    if not ui_map:
        return None
    return {
        "map": ui_map,
        "x": float(m.group(2)),
        "y": float(m.group(3)),
    }


def strip_lua_comment(line: str) -> tuple[str, str | None]:
    # Glued Era pin comments: .goto ...--c:Mulgore,44.92,77.12
    glued = re.search(r"--c:", line)
    if glued:
        return line[: glued.start()].rstrip(), line[glued.start() + 2 :].strip() or None
    if " --" in line:
        left, right = line.split(" --", 1)
        return left.rstrip(), right.strip() or None
    if line.strip().startswith("--"):
        return "", line.strip()[2:].strip() or None
    return line, None


def extract_arrow_text(line: str) -> str | None:
    if ">>" not in line:
        return None
    right = line.split(">>", 1)[1]
    right, _ = strip_lua_comment(right)
    return clean_markup(right)


def convert_step(raw: str) -> dict | None:
    lines = [ln.rstrip() for ln in raw.splitlines() if ln.strip() and not ln.strip().startswith("--")]
    if not lines:
        return None

    header = lines[0].strip()
    class_filt = step_class_filter(header)
    if class_filt == "skip":
        return None

    body_lines = lines[1:]
    tags = []
    content = []
    for ln in body_lines:
        s = ln.strip()
        if s.startswith("#"):
            tag = s[1:].strip().lower()
            if tag in {"softcore", "hardcore"}:
                tags.append(tag)
            continue
        if s.startswith(".isOnQuest") or s.startswith(".isQuestComplete") or s.startswith(".isQuestTurnedIn"):
            continue
        if s.startswith(".zoneskip") or s.startswith(".xp ") or s.startswith(".hs ") or s.startswith(".cooldown"):
            continue
        if s.startswith(".money") or s.startswith(".itemcount") or s.startswith(".skill") or s.startswith(".itemStat"):
            continue
        content.append(s)

    accepts: list[tuple[int, str | None]] = []
    turnins: list[tuple[int, str | None]] = []
    completes: list[tuple[int, str | None]] = []
    texts: list[str] = []
    notes: list[str] = []
    targets: list[str] = []
    details: list[str] = []
    pin: dict | None = None

    for raw_line in content:
        s, comment = strip_lua_comment(raw_line)
        s = s.strip()
        maybe_pin = parse_pin(comment)
        if maybe_pin:
            pin = maybe_pin
            comment = None
        if comment:
            c = clean_markup(comment)
            if c and re.match(r"^[A-Za-z].*\(\d+\)\s*$", c):
                details.append(c)
        if not s:
            continue
        if s.startswith(".accept "):
            m = re.match(r"\.accept\s+(\d+)\s*(?:>>\s*(.*))?$", s)
            if m:
                qid = int(m.group(1))
                label = clean_markup(m.group(2)) if m.group(2) else None
                accepts.append((qid, label))
                if label:
                    texts.append(label if label.lower().startswith("accept") else f"Accept {label}")
            continue
        if s.startswith(".turnin "):
            m = re.match(r"\.turnin\s+(\d+)\s*(?:>>\s*(.*))?$", s)
            if m:
                qid = int(m.group(1))
                label = clean_markup(m.group(2)) if m.group(2) else None
                turnins.append((qid, label))
                if label:
                    texts.append(label if label.lower().startswith("turn") else f"Turn in {label}")
            continue
        if s.startswith(".complete "):
            m = re.match(r"\.complete\s+(\d+)(?:,(\d+))?$", s)
            if m:
                qid = int(m.group(1))
                obj = clean_markup(comment) if comment else None
                completes.append((qid, obj))
                if obj:
                    details.append(obj)
            continue
        if s.startswith(".target"):
            name = s.split(None, 1)[1].lstrip("+").strip() if " " in s else ""
            name = clean_markup(name)
            if name:
                targets.append(name)
            continue
        if s.startswith(".mob "):
            name = clean_markup(s[5:].strip())
            if name:
                details.append(f"Kill {name}")
            continue
        if s.startswith(".goto ") or s.startswith(".subzone ") or s.startswith(".zone "):
            arrow = extract_arrow_text(s)
            if arrow:
                texts.append(arrow)
            continue
        if s.startswith(".vendor"):
            arrow = extract_arrow_text(s) or "Vendor trash"
            texts.append(arrow)
            continue
        if s.startswith(".train "):
            arrow = extract_arrow_text(s) or "Train your class spells"
            texts.append(arrow)
            continue
        if s.startswith(".collect "):
            arrow = extract_arrow_text(s)
            if arrow:
                texts.append(arrow)
            continue
        if s.startswith(".cast ") or s.startswith(".use ") or s.startswith(".destroy "):
            arrow = extract_arrow_text(s)
            if arrow:
                texts.append(arrow)
            continue
        if s.startswith(".abandon "):
            arrow = extract_arrow_text(s) or clean_markup(s)
            texts.append(arrow)
            continue
        if s.startswith(".home ") or s.startswith(".fly ") or s.startswith(".bind "):
            arrow = extract_arrow_text(s) or clean_markup(s)
            texts.append(arrow)
            continue
        if s.startswith("+"):
            tip = clean_markup(s[1:])
            if tip:
                notes.append(tip)
            continue
        if s.startswith(">>"):
            tip = clean_markup(strip_lua_comment(s[2:])[0])
            if tip:
                texts.append(tip)
            continue
        if s.startswith("."):
            arrow = extract_arrow_text(s)
            if arrow:
                texts.append(arrow)
            continue
        tip = clean_markup(s)
        if tip:
            notes.append(tip)

    text_parts = []
    for t in texts:
        t = clean_markup(t)
        if t and t not in text_parts:
            text_parts.append(t)

    if targets:
        who = targets[0]
        talk = f"Talk to {who}"
        text_parts = [p for p in text_parts if p != talk]

    if not text_parts and completes:
        if details:
            text_parts.append(details[0])
        else:
            text_parts.append("Complete quest objectives")
    if not text_parts and notes:
        text_parts.append(notes[0])
        notes = notes[1:]
    if not text_parts and targets and (accepts or turnins):
        who = targets[0]
        if accepts and not turnins:
            text_parts.append(f"Accept from {who}")
        elif turnins and not accepts:
            text_parts.append(f"Turn in to {who}")
        else:
            text_parts.append(f"Talk to {who}")
    elif targets and text_parts:
        who = targets[0]
        joined = " ".join(text_parts)
        already_talk = any(p.lower().startswith("talk to ") for p in text_parts)
        short = who.split(None, 1)[0]
        named = who in joined or short in joined
        if not already_talk and not named and (
            accepts
            or turnins
            or any(p.lower().startswith(("accept", "turn", "vendor", "train", "buy")) for p in text_parts)
        ):
            text_parts[0] = f"Talk to {who}. {text_parts[0]}"

    if tags:
        notes.insert(0, "/".join(tags))

    text = ". ".join(text_parts).strip()
    if class_filt and text:
        text = f"[{class_filt}] {text}"
    elif class_filt and not text:
        text = f"[{class_filt}]"
    if text and not text.endswith((".", "!", "?")):
        text = text + "."

    quest_ids: list[int] = []
    when: str | None = None

    if turnins and not accepts and not completes:
        when = "complete"
        quest_ids = [q for q, _ in turnins]
    elif accepts and not turnins and not completes:
        when = "accepted"
        quest_ids = [q for q, _ in accepts]
    elif turnins and accepts and not completes:
        when = "accepted"
        quest_ids = [q for q, _ in accepts]
        for q, label in turnins:
            details.insert(0, label or f"Turn in quest {q}")
    elif completes and not accepts and not turnins:
        when = None
        quest_ids = [q for q, _ in completes]
    elif completes and (accepts or turnins):
        if accepts:
            when = "accepted"
            quest_ids = [q for q, _ in accepts]
        elif turnins:
            when = "complete"
            quest_ids = [q for q, _ in turnins]
        for q, obj in completes:
            if obj:
                details.append(obj)
    else:
        when = None
        quest_ids = []

    seen: set[int] = set()
    uniq: list[int] = []
    for q in quest_ids:
        if q not in seen:
            seen.add(q)
            uniq.append(q)
    quest_ids = uniq

    note = None
    extra_notes: list[str] = []
    for n in notes:
        if not n or n == text.rstrip("."):
            continue
        if note is None and n not in {"softcore", "hardcore"}:
            note = n
        elif n in {"softcore", "hardcore"}:
            if note:
                note = f"({n}) {note}"
            else:
                note = n
        else:
            extra_notes.append(n)
    if targets and not any(t in (text or "") for t in targets):
        extra_notes.append("NPC: " + ", ".join(dict.fromkeys(targets)))

    detail_list = []
    for d in details + extra_notes:
        if d and d not in detail_list and d != text.rstrip(".") and d != note:
            detail_list.append(d)

    if not text and not quest_ids and not note and not detail_list:
        return None

    if not text:
        if quest_ids and when == "accepted":
            text = "Accept the quest."
        elif quest_ids and when == "complete":
            text = "Turn in the quest."
        elif quest_ids:
            text = "Do the quest objectives."
        elif note:
            text = note
            note = None
        else:
            text = detail_list[0]
            detail_list = detail_list[1:]

    step: dict = {"text": text}
    if note:
        step["note"] = note
    if when:
        step["when"] = when
    if len(quest_ids) == 1:
        step["quest"] = quest_ids[0]
    elif len(quest_ids) > 1:
        step["quests"] = quest_ids
    if pin:
        step["map"] = pin["map"]
        step["x"] = pin["x"]
        step["y"] = pin["y"]
    if detail_list:
        step["details"] = detail_list[:6]
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


def slug(name: str) -> str:
    s = name.lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s


def convert_file(src: Path, dst: Path, keep: set[str] | None) -> tuple[int, int]:
    raw = src.read_text(encoding="utf-8", errors="replace")
    guides = parse_guides(raw)

    out: list[str] = []
    out.append("local _, ns = ...")
    out.append("")
    out.append(f"-- Converted from Guides/REFERENCE/{src.name}")
    out.append("-- Class tags from the RXP source are kept in [brackets] on the step text.")
    out.append("-- Era pins come from --c:Zone,x,y comments when present; otherwise QuestieDB supplies NPC coords.")
    out.append("")

    total_steps = 0
    kept = 0
    for name, body in guides:
        if keep is not None and name not in keep:
            continue
        kept += 1
        steps_raw = split_steps(body)
        steps: list[dict] = []
        for chunk in steps_raw:
            step = convert_step(chunk)
            if step:
                steps.append(step)
        total_steps += len(steps)
        guide_id = "horde-" + slug(name)
        out.append("ns.RegisterGuide({")
        out.append(f"    id = {lua_str(guide_id)},")
        out.append(f"    name = {lua_str(name)},")
        out.append('    group = "Forever Horde",')
        out.append('    faction = "Horde",')
        out.append("    steps = {")
        for step in steps:
            out.append(emit_step(step))
        out.append("    },")
        out.append("})")
        out.append("")

    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {dst}")
    print(f"Guides: {kept}, steps: {total_steps}")
    return kept, total_steps


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("src", type=Path, help="REFERENCE .lua path (or filename under REFERENCE/)")
    ap.add_argument(
        "-o",
        "--out",
        type=Path,
        help="Output Forever .lua path (default: Guides/Forever/<src stem normalized>)",
    )
    ap.add_argument(
        "--keep",
        action="append",
        default=[],
        help="Only convert guides with this #name (repeatable). Default: all.",
    )
    args = ap.parse_args()

    src = args.src
    if not src.is_file():
        candidate = REF / src.name
        if candidate.is_file():
            src = candidate
        else:
            raise SystemExit(f"Source not found: {args.src}")

    if args.out:
        dst = args.out
    else:
        stem = src.stem.replace("-", "_")
        # Normalize Horde-1-12_Mulgore -> Horde_01-12_Mulgore style when needed
        dst = FOREVER / f"{stem}.lua"

    keep = set(args.keep) if args.keep else None
    convert_file(src, dst, keep)


if __name__ == "__main__":
    main()
