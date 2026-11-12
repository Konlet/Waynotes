#!/usr/bin/env python3
"""Convert RXP Forever Durotar guide into ns.RegisterGuide format."""

from __future__ import annotations

import re
from pathlib import Path

SRC = Path(__file__).with_name("Horde-01-12_Durotar.lua")
DST = Path(__file__).resolve().parents[1] / "Forever" / "Horde_01-12_Durotar.lua"

# Keep Durotar sections only; Tirisfal is a different zone route.
KEEP_NAMES = {
    "1-6 Durotar",
    "6-10 Durotar",
    "10-12 Durotar",
}

# Innermost name tags first (FRIENDLY/ENEMY/...), then wrappers (WARN/BUY/...).
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


def clean_markup(s: str) -> str:
    # Strip trailing inline class filters on tip lines: "<< Warlock"
    s = INLINE_CLASS.sub("", s)
    # Repeat until nested RXP tags are gone.
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
    # Leftover broken tag crumbs
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
    # Drop metadata header before first step
    idx = re.search(r"^step(?:\s|<<|$)", body, re.M)
    if not idx:
        return []
    body = body[idx.start() :]
    chunks = re.split(r"(?m)^(?=step(?:\s|<<|$))", body)
    return [c for c in chunks if c.strip()]


def step_class_filter(header_line: str) -> str | None:
    # step << Warrior/Shaman
    m = re.match(r"^step\s*(<<\s*.+)?\s*$", header_line.strip())
    if not m or not m.group(1):
        return None
    filt = m.group(1).strip()
    if filt.startswith("<<"):
        filt = filt[2:].strip()
    # "skip", "skip --Shaman", etc.
    if filt.lower() == "skip" or filt.lower().startswith("skip ") or filt.lower().startswith("skip-"):
        return "skip"
    return filt


def strip_lua_comment(line: str) -> tuple[str, str | None]:
    """Split trailing -- comment; ignore -- inside strings roughly by first ' --'."""
    # Prefer ' --' so item links like [x--y] are untouched; RXP uses ' --Name'
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
    # Softcore/hardcore tags: keep both; annotate
    tags = []
    content = []
    for ln in body_lines:
        s = ln.strip()
        if s.startswith("#"):
            tag = s[1:].strip().lower()
            if tag in {"softcore", "hardcore", "optional", "sticky", "label", "completewith", "loop", "hidewindow", "requires", "maxlevel", "era", "som", "season", "phase"}:
                # keep a short note for soft/hard
                if tag in {"softcore", "hardcore"}:
                    tags.append(tag)
            # labels and completewith names ignored for structure
            continue
        if s.startswith(".isOnQuest") or s.startswith(".isQuestComplete") or s.startswith(".isQuestTurnedIn"):
            continue
        if s.startswith(".zoneskip") or s.startswith(".xp ") or s.startswith(".hs ") or s.startswith(".cooldown"):
            continue
        if s.startswith(".money") or s.startswith(".itemcount") or s.startswith(".skill"):
            continue
        content.append(s)

    accepts: list[tuple[int, str | None]] = []
    turnins: list[tuple[int, str | None]] = []
    completes: list[tuple[int, str | None]] = []
    texts: list[str] = []
    notes: list[str] = []
    targets: list[str] = []
    details: list[str] = []

    for raw in content:
        s, comment = strip_lua_comment(raw)
        s = s.strip()
        if comment:
            c = clean_markup(comment)
            # Named collect/complete comments are useful detail lines
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
            # .target Name or .target +Name
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
            # travel goto with >> text
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
            # Named amounts come from -- comments via details above
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
            # warning / tip lines like +|cRXP_WARN_...
            tip = clean_markup(s[1:])
            if tip:
                # Multiple class-specific + tips become details, first is text/note
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
        # plain prose
        tip = clean_markup(s)
        if tip:
            notes.append(tip)

    # Build primary text
    text_parts = []
    for t in texts:
        t = clean_markup(t)
        if t and t not in text_parts:
            text_parts.append(t)

    # Prefer a single "Talk to X" when >> already said it and we also have accept/turnin labels
    if targets:
        who = targets[0]
        talk = f"Talk to {who}"
        # Drop redundant bare talk lines; keep accept/turnin wording
        text_parts = [p for p in text_parts if p != talk]

    # If only completes, synthesize text from details/targets
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
            accepts or turnins or any(p.lower().startswith(("accept", "turn", "vendor", "train", "buy")) for p in text_parts)
        ):
            text_parts[0] = f"Talk to {who}. {text_parts[0]}"

    if tags:
        tag_note = "/".join(tags)
        notes.insert(0, tag_note)

    text = ". ".join(text_parts).strip()
    if class_filt and text:
        text = f"[{class_filt}] {text}"
    elif class_filt and not text:
        text = f"[{class_filt}]"
    if text and not text.endswith((".", "!", "?")):
        text = text + "."

    # Decide when / quests
    quest_ids: list[int] = []
    when: str | None = None

    if turnins and not accepts and not completes:
        when = "complete"
        quest_ids = [q for q, _ in turnins]
    elif accepts and not turnins and not completes:
        when = "accepted"
        quest_ids = [q for q, _ in accepts]
    elif turnins and accepts and not completes:
        # Turn in then accept: advance when the new quest is accepted
        when = "accepted"
        quest_ids = [q for q, _ in accepts]
        # Keep turnin ids visible via details
        for q, label in turnins:
            details.insert(0, label or f"Turn in quest {q}")
    elif completes and not accepts and not turnins:
        # Objective step: show quest, manual advance (objectives visible via Questie/log)
        when = None
        quest_ids = [q for q, _ in completes]
    elif completes and (accepts or turnins):
        # Mixed sticky-style: prefer accept/turnin automation
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
        # travel / vendor / train / tip
        when = None
        quest_ids = []

    # Deduplicate quest ids preserving order
    seen: set[int] = set()
    uniq: list[int] = []
    for q in quest_ids:
        if q not in seen:
            seen.add(q)
            uniq.append(q)
    quest_ids = uniq

    # First tip stays as note; extra class-specific tips become details.
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


def main() -> None:
    raw = SRC.read_text(encoding="utf-8", errors="replace")
    guides = parse_guides(raw)

    out: list[str] = []
    out.append("local _, ns = ...")
    out.append("")
    out.append("-- Converted from Guides/REFERENCE/Horde-01-12_Durotar.lua")
    out.append("-- Class tags from the RXP source are kept in [brackets] on the step text.")
    out.append("-- Pins omitted: QuestieDB supplies NPC coordinates for accept/turn-in steps.")
    out.append("")

    total_steps = 0
    for name, body in guides:
        if name not in KEEP_NAMES:
            continue
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

    DST.write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {DST}")
    print(f"Guides: {sum(1 for n,_ in guides if n in KEEP_NAMES)}, steps: {total_steps}")


if __name__ == "__main__":
    main()
