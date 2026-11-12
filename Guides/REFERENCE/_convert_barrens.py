#!/usr/bin/env python3
"""Convert the RXP Barrens guide into ns.RegisterGuide steps."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

SRC = Path(__file__).with_name("Horde-12-22_Barrens.lua")
DST = Path(__file__).resolve().parents[1] / "Forever" / "Horde_12-22_Barrens.lua"

CLASSES = {
    "warrior": "Warrior",
    "paladin": "Paladin",
    "hunter": "Hunter",
    "rogue": "Rogue",
    "priest": "Priest",
    "shaman": "Shaman",
    "mage": "Mage",
    "warlock": "Warlock",
    "druid": "Druid",
}
RACES = {
    "orc": "Orc",
    "troll": "Troll",
    "tauren": "Tauren",
    "undead": "Undead",
    "scourge": "Undead",
    "skyborne": "Skyborne",
    "bloodelf": "Blood Elf",
    "goblin": "Goblin",
}
CLASS_ORDER = list(dict.fromkeys(CLASSES.values()))
RACE_ORDER = ["Orc", "Undead", "Tauren", "Troll", "Blood Elf", "Goblin", "Skyborne"]

RXP_NAME = re.compile(r"\|cRXP_(FRIENDLY|ENEMY|LOOT|PICK|QUEST)_([^|]+)\|r")
RXP_WRAP = re.compile(r"\|cRXP_(WARN|BUY|BAD)_(.+?)\|r")
TEXTURE = re.compile(r"\|T[^|]+\|t")
COLOR = re.compile(r"\|c[0-9A-Fa-f]{8}")
COUNT_COMMENT = re.compile(r"\(\d+\)\s*$")


@dataclass(frozen=True)
class Group:
    classes: frozenset[str] = frozenset()
    races: frozenset[str] = frozenset()
    exclude_classes: frozenset[str] = frozenset()
    exclude_races: frozenset[str] = frozenset()

    def key(self) -> tuple:
        return (
            tuple(sorted(self.classes)),
            tuple(sorted(self.races)),
            tuple(sorted(self.exclude_classes)),
            tuple(sorted(self.exclude_races)),
        )


def clean_markup(text: str) -> str:
    for _ in range(8):
        nxt = RXP_NAME.sub(lambda m: m.group(2), text)
        nxt = RXP_WRAP.sub(lambda m: m.group(2), nxt)
        if nxt == text:
            break
        text = nxt
    text = TEXTURE.sub(" ", text)
    text = COLOR.sub("", text)
    text = text.replace("|r", "").replace("|n", " ")
    text = re.sub(r"\|H[^|]*\|h", "", text)
    text = text.replace("|h", "")
    text = re.sub(r"\|cRXP_[A-Z]+_", "", text)
    text = text.replace("|", "")
    text = re.sub(r"(\w)\[", r"\1 [", text)
    text = re.sub(r"\b([Tt]he)\s+[Tt]he\b", r"\1", text)
    text = re.sub(r"[ \t]+", " ", text).strip()
    text = text.strip(" .")
    return text


def lua_str(text: str) -> str:
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def strip_comment(line: str) -> tuple[str, str | None]:
    if " --" in line:
        left, right = line.split(" --", 1)
        return left.rstrip(), right.strip() or None
    if line.strip().startswith("--"):
        return "", line.strip()[2:].strip() or None
    return line, None


def split_inline(line: str) -> tuple[str, str | None]:
    """Split a trailing << filter. Filters do not contain '<<'."""
    if "<<" not in line:
        return line, None
    left, right = line.split("<<", 1)
    return left.rstrip(), right.strip() or None


def parse_filter(expr: str | None) -> list[Group] | None | str:
    """None = everyone. 'skip' = drop. A list is OR of AND-groups."""
    if not expr:
        return None
    expr = expr.strip()
    if not expr:
        return None
    low = expr.lower()
    if low == "skip" or low.startswith("skip ") or low.startswith("skip-"):
        return "skip"
    pieces = expr.split("/")
    if len(pieces) > 1 and "!" in pieces[-1] and all("!" not in piece for piece in pieces[:-1]):
        bits = pieces[-1].split(None, 1)
        if len(bits) == 2 and bits[1].strip().startswith("!"):
            pieces = [f"{piece.strip()} {bits[1].strip()}" for piece in pieces[:-1]] + [pieces[-1]]
    groups: list[Group] = []
    for part in pieces:
        classes: set[str] = set()
        races: set[str] = set()
        exclude_classes: set[str] = set()
        exclude_races: set[str] = set()
        unknown = False
        for token in part.split():
            neg = token.startswith("!")
            name = token[1:] if neg else token
            key = name.lower().replace(" ", "")
            if key in {"horde", "alliance"}:
                if (not neg and key == "alliance") or (neg and key == "horde"):
                    return "skip"
                continue
            if key in CLASSES:
                (exclude_classes if neg else classes).add(CLASSES[key])
            elif key in RACES:
                (exclude_races if neg else races).add(RACES[key])
            else:
                unknown = True
                break
        if unknown:
            continue
        if classes & exclude_classes or races & exclude_races:
            continue
        if not classes and not races and not exclude_classes and not exclude_races:
            continue
        groups.append(Group(frozenset(classes), frozenset(races), frozenset(exclude_classes), frozenset(exclude_races)))
    if not groups:
        return None
    return groups


def and_groups(a: Group, b: Group) -> Group | None:
    if a.classes and b.classes:
        classes = a.classes & b.classes
        if not classes:
            return None
    else:
        classes = a.classes or b.classes
    if a.races and b.races:
        races = a.races & b.races
        if not races:
            return None
    else:
        races = a.races or b.races
    exclude_classes = a.exclude_classes | b.exclude_classes
    exclude_races = a.exclude_races | b.exclude_races
    if classes & exclude_classes or races & exclude_races:
        return None
    return Group(frozenset(classes), frozenset(races), frozenset(exclude_classes), frozenset(exclude_races))


def combine(step_filter: list[Group] | None, line_filter: list[Group] | None | str) -> list[Group] | None | str:
    if line_filter == "skip" or step_filter == "skip":
        return "skip"
    if step_filter is None:
        return line_filter  # type: ignore[return-value]
    if line_filter is None:
        return step_filter
    out: list[Group] = []
    for left in step_filter:
        for right in line_filter:  # type: ignore[union-attr]
            merged = and_groups(left, right)
            if merged:
                out.append(merged)
    return out or "skip"


def collapse(groups: list[Group]) -> list[Group]:
    buckets: list[list[Group]] = []
    for group in groups:
        placed = False
        for bucket in buckets:
            if collapse_one(bucket + [group]) is not None:
                bucket.append(group)
                placed = True
                break
        if not placed:
            buckets.append([group])
    collapsed = []
    for bucket in buckets:
        one = collapse_one(bucket)
        collapsed.append(one if one is not None else bucket[0])
    return collapsed


def collapse_one(groups: list[Group]) -> Group | None:
    exclude_classes = groups[0].exclude_classes
    exclude_races = groups[0].exclude_races
    if any(g.exclude_classes != exclude_classes or g.exclude_races != exclude_races for g in groups):
        return None
    if all(not g.classes and not g.races for g in groups):
        return groups[0] if len(groups) == 1 else None
    if all(len(g.classes) == 1 and not g.races for g in groups):
        classes: set[str] = set()
        for group in groups:
            classes |= set(group.classes)
        return Group(frozenset(classes), frozenset(), exclude_classes, exclude_races)
    if all(len(g.races) == 1 and not g.classes for g in groups):
        races: set[str] = set()
        for group in groups:
            races |= set(group.races)
        return Group(frozenset(), frozenset(races), exclude_classes, exclude_races)
    if all(len(g.classes) == 1 and len(g.races) == 1 for g in groups):
        classes = set()
        races = set()
        pairs = set()
        for group in groups:
            cls = next(iter(group.classes))
            race = next(iter(group.races))
            classes.add(cls)
            races.add(race)
            pairs.add((cls, race))
        if len(classes) == 1 or len(races) == 1 or pairs == {(c, r) for c in classes for r in races}:
            return Group(frozenset(classes), frozenset(races), exclude_classes, exclude_races)
        return None
    return None


def filter_key(groups: list[Group] | None) -> tuple:
    if not groups:
        return ()
    return tuple(sorted(group.key() for group in collapse(groups)))


def ordered(names: frozenset[str], order: list[str]) -> list[str]:
    rank = {name: index for index, name in enumerate(order)}
    return sorted(names, key=lambda name: (rank.get(name, 99), name))


def parse_guides(text: str) -> list[tuple[str, str]]:
    parts = re.split(r"RXPGuides\.RegisterGuide\(\[\[", text)[1:]
    guides = []
    for part in parts:
        body = part.split("]])", 1)[0]
        name_m = re.search(r"^#name\s+(.+)$", body, re.M)
        name = name_m.group(1).strip() if name_m else "Unknown"
        guides.append((name, body))
    return guides


def split_steps(body: str) -> list[str]:
    idx = re.search(r"^step(?:\s|<<|$)", body, re.M)
    if not idx:
        return []
    body = body[idx.start():]
    return [chunk for chunk in re.split(r"(?m)^(?=step(?:\s|<<|$))", body) if chunk.strip()]


def arrow_text(line: str) -> str | None:
    if ">>" not in line:
        return None
    right = line.split(">>", 1)[1]
    right, _ = strip_comment(right)
    text = clean_markup(right)
    return text or None


def finish_sentence(text: str) -> str:
    text = text.strip()
    if text and text[-1] not in ".!?":
        text += "."
    return text


def join_parts(parts: list[str]) -> str:
    joined = ""
    for part in parts:
        part = part.strip()
        if not part:
            continue
        if not joined:
            joined = part
            continue
        if joined[-1] in ".!?":
            joined += " " + part
        else:
            joined += ". " + part
    return finish_sentence(joined)


def build_step(lines: list[str], group: Group | None, tags: set[str], inherited: list[str]) -> dict | None:
    accepts: list[tuple[int, str | None]] = []
    turnins: list[tuple[int, str | None]] = []
    completes: list[int] = []
    texts: list[str] = []
    notes: list[str] = []
    targets: list[str] = []
    details: list[str] = []

    usable = list(inherited) + lines
    for raw in usable:
        code, comment = strip_comment(raw)
        code, _inline = split_inline(code)
        code = code.strip()
        comment_text = clean_markup(comment) if comment else None
        if comment_text and COUNT_COMMENT.search(comment_text):
            details.append(comment_text)
        if not code:
            continue
        if code.startswith(".accept "):
            match = re.match(r"\.accept\s+(\d+)\s*(?:>>\s*(.*))?$", code)
            if match:
                quest_id = int(match.group(1))
                label = clean_markup(match.group(2)) if match.group(2) else None
                accepts.append((quest_id, label))
                if label:
                    texts.append(label if label.lower().startswith("accept") else f"Accept {label}")
            continue
        if code.startswith(".turnin "):
            match = re.match(r"\.turnin\s+(\d+)\s*(?:>>\s*(.*))?$", code)
            if match:
                quest_id = int(match.group(1))
                label = clean_markup(match.group(2)) if match.group(2) else None
                turnins.append((quest_id, label))
                if label:
                    texts.append(label if label.lower().startswith("turn") else f"Turn in {label}")
            continue
        if code.startswith(".complete "):
            match = re.match(r"\.complete\s+(\d+)", code)
            if match:
                completes.append(int(match.group(1)))
                if comment_text and comment_text not in details:
                    details.append(comment_text)
            continue
        if code.startswith(".target"):
            name = code.split(None, 1)[1].lstrip("+").strip() if " " in code else ""
            name = clean_markup(name)
            if name:
                targets.append(name)
            continue
        if code.startswith(".mob "):
            name = clean_markup(code[5:].lstrip("+").strip())
            if name:
                details.append(f"Kill {name}")
            continue
        if code.startswith(".unitscan "):
            name = clean_markup(code.split(None, 1)[1]) if " " in code else ""
            if name:
                texts.append(f"Look for {name}")
            continue
        if code.startswith("+"):
            tip = clean_markup(code[1:])
            if tip:
                notes.append(tip)
            continue
        if code.startswith(">>"):
            tip = clean_markup(strip_comment(code[2:])[0])
            if tip:
                texts.append(tip)
            continue
        if code.startswith("."):
            tip = arrow_text(code)
            if tip:
                texts.append(tip)
            elif code.startswith(".train"):
                texts.append("Train a new skill")
            continue
        tip = clean_markup(code)
        if tip:
            notes.append(tip)

    text_parts: list[str] = []
    for part in texts:
        part = clean_markup(part)
        if part and part not in text_parts:
            text_parts.append(part)
    if targets:
        who = targets[0]
        talk = f"Talk to {who}"
        text_parts = [part for part in text_parts if part != talk]
        joined = " ".join(text_parts)
        short = who.split(None, 1)[0]
        named = who in joined or short in joined
        already = any(part.lower().startswith("talk to ") for part in text_parts)
        if text_parts and not already and not named:
            text_parts[0] = f"Talk to {who}. {text_parts[0]}"
        elif not text_parts:
            text_parts.append(talk)
    if not text_parts and completes and details:
        text_parts.append(details[0])
    if not text_parts and notes:
        text_parts.append(notes.pop(0))
    if not text_parts and details:
        text_parts.append(details[0])

    text = join_parts(text_parts)
    if "optional" in tags and text and not text.lower().startswith("optional"):
        text = "Optional: " + text

    quest_ids: list[int] = []
    when: str | None = None
    if turnins and not accepts and not completes:
        when = "complete"
        quest_ids = [quest_id for quest_id, _label in turnins]
    elif accepts and not turnins and not completes:
        when = "accepted"
        quest_ids = [quest_id for quest_id, _label in accepts]
    elif turnins and accepts and not completes:
        when = "accepted"
        quest_ids = [quest_id for quest_id, _label in accepts]
        for _quest_id, label in turnins:
            if label:
                details.insert(0, label if label.lower().startswith("turn") else f"Turn in {label}")
    elif completes and not accepts and not turnins:
        when = "objectives"
        quest_ids = completes
    elif completes and accepts:
        when = "accepted"
        quest_ids = [quest_id for quest_id, _label in accepts]
    elif completes and turnins:
        when = "complete"
        quest_ids = [quest_id for quest_id, _label in turnins]
    else:
        when = None

    seen: set[int] = set()
    unique: list[int] = []
    for quest_id in quest_ids:
        if quest_id not in seen:
            seen.add(quest_id)
            unique.append(quest_id)
    quest_ids = unique

    note = None
    for entry in notes:
        if not entry or entry == text.rstrip("."):
            continue
        if note is None:
            note = entry
        elif entry not in details:
            details.append(entry)
    if targets and not any(target in text for target in targets):
        details.append("NPC: " + ", ".join(dict.fromkeys(targets)))

    detail_list: list[str] = []
    for entry in details:
        if entry and entry not in detail_list and entry != text.rstrip(".") and entry != note:
            detail_list.append(entry)
    detail_list = detail_list[:8]

    if not text and not quest_ids and not note and not detail_list:
        return None
    if not text:
        text = note or detail_list[0]
        if note == text:
            note = None
        elif detail_list and detail_list[0] == text:
            detail_list = detail_list[1:]
        text = finish_sentence(text)

    step: dict = {
        "text": text,
        "completes": set(completes),
        "has_accept": bool(accepts),
        "has_turnin": bool(turnins),
        "reminder": "completewith" in tags or "sticky" in tags,
    }
    if note:
        step["note"] = note
    if "softcore" in tags:
        step["mode"] = "softcore"
    elif "hardcore" in tags:
        step["mode"] = "hardcore"
    if when:
        step["when"] = when
    if len(quest_ids) == 1:
        step["quest"] = quest_ids[0]
    elif len(quest_ids) > 1:
        step["quests"] = quest_ids
    if detail_list:
        step["details"] = detail_list
    if group:
        if group.classes:
            step["classes"] = ordered(group.classes, CLASS_ORDER)
        if group.exclude_classes and not group.classes:
            step["excludeClasses"] = ordered(group.exclude_classes, CLASS_ORDER)
        if group.races:
            step["races"] = ordered(group.races, RACE_ORDER)
        if group.exclude_races and not group.races:
            step["excludeRaces"] = ordered(group.exclude_races, RACE_ORDER)
    return step


def convert_step(raw: str) -> list[dict]:
    lines = [ln.strip() for ln in raw.splitlines() if ln.strip() and not ln.strip().startswith("--")]
    if not lines:
        return []
    header, header_filter = split_inline(lines[0].strip())
    if not header.startswith("step"):
        return []
    parsed = parse_filter(header_filter)
    if parsed == "skip":
        return []
    step_filter = None if parsed is None else parsed

    tags: set[str] = set()
    content: list[tuple[str, list[Group] | None]] = []
    for line in lines[1:]:
        if line.startswith("#"):
            tag = line[1:].split()[0].lower() if line[1:].strip() else ""
            if tag in {"softcore", "hardcore", "optional", "sticky", "completewith"}:
                tags.add("completewith" if tag == "completewith" else tag)
            continue
        code, _comment = strip_comment(line)
        code, inline = split_inline(code)
        code = code.strip()
        if not code:
            continue
        command = code.split()[0]
        if command in {
            ".isOnQuest", ".isQuestComplete", ".isQuestTurnedIn", ".isQuestAvailable",
            ".isNotOnQuest", ".xp", ".money", ".itemcount", ".itemStat", ".skill",
            ".cooldown", ".zoneskip", ".subzoneskip", ".maxlevel", ".group",
            ".disablecheckbox", ".bindlocation", ".aura", ".line",
        }:
            continue
        line_filter = parse_filter(inline)
        if line_filter == "skip":
            continue
        combined = combine(step_filter, line_filter if isinstance(line_filter, list) else None)
        if combined == "skip":
            continue
        content.append((code if not _comment else f"{code} --{_comment}", combined if isinstance(combined, list) else None))

    if not content:
        return []

    def preamble(segment_lines: list[str]) -> bool:
        if not segment_lines:
            return False
        for code in segment_lines:
            plain, _comment = strip_comment(code)
            plain, _inline = split_inline(plain)
            plain = plain.strip()
            if plain.startswith(".target"):
                continue
            if plain.startswith((".goto", ".subzone", ".zone")) and ">>" not in plain:
                continue
            if plain.startswith(">>") and "talk to" in clean_markup(plain).lower():
                continue
            return False
        return True

    segments: list[dict] = []
    for code, filt in content:
        key = filter_key(filt)
        if segments and segments[-1]["key"] == key:
            segments[-1]["lines"].append(code)
        else:
            segments.append({"key": key, "filter": filt, "lines": [code]})

    merged: list[dict] = []
    waiting: list[dict] = []
    for segment in segments:
        if preamble(segment["lines"]):
            waiting.append(segment)
            continue
        if waiting:
            for earlier in waiting:
                for line in earlier["lines"]:
                    if line not in segment["lines"]:
                        segment["lines"].insert(0, line)
            waiting = []
        merged.append(segment)
    if not merged and waiting:
        merged = waiting
    segments = merged

    shared_talk: list[str] = []
    shared_targets: list[str] = []
    step_key = filter_key(step_filter if isinstance(step_filter, list) else None)
    for segment in segments:
        if segment["key"] != step_key:
            continue
        for code in segment["lines"]:
            plain, _comment = strip_comment(code)
            plain, _inline = split_inline(plain)
            plain = plain.strip()
            if plain.startswith(".target"):
                shared_targets.append(plain)
            elif plain.startswith(">>") and "talk to" in clean_markup(plain).lower():
                shared_talk.append(plain)

    built: list[dict] = []
    for segment in segments:
        inherited: list[str] = []
        if segment["key"] != step_key:
            blob = " ".join(segment["lines"]).lower()
            if ".accept" in blob or ".turnin" in blob or ".fp" in blob or ".vendor" in blob or ".home" in blob:
                inherited.extend(shared_talk)
                inherited.extend(shared_targets)
        groups = collapse(segment["filter"]) if segment["filter"] else [None]
        for group in groups:
            step = build_step(segment["lines"], group, tags, inherited)
            if step:
                built.append(step)
    return built


def fold_reminders(steps: list[dict]) -> list[dict]:
    primary: set[int] = set()
    for step in steps:
        if not step["reminder"] and step["completes"]:
            primary |= step["completes"]
    kept: list[dict] = []
    pending: list[tuple[set[int], list[str]]] = []
    for step in steps:
        completes = step["completes"]
        if step["reminder"] and completes and completes <= primary and not step["has_accept"] and not step["has_turnin"]:
            extra = []
            if step.get("text"):
                extra.append(step["text"].rstrip("."))
            extra.extend(step.get("details") or [])
            pending.append((completes, extra))
            continue
        if pending and step["completes"]:
            details = list(step.get("details") or [])
            for quests, extra in pending:
                if quests & step["completes"]:
                    for line in extra:
                        if line and line not in details and line != step["text"].rstrip("."):
                            details.append(line)
            if details:
                step["details"] = details[:8]
            pending = [(quests, extra) for quests, extra in pending if not (quests & step["completes"])]
        kept.append(step)
    for step in kept:
        step.pop("completes", None)
        step.pop("has_accept", None)
        step.pop("has_turnin", None)
        step.pop("reminder", None)
    return kept


def emit_step(step: dict) -> str:
    indent = "        "
    inner = indent + "    "
    lines = [indent + "{"]
    for key in ("classes", "excludeClasses", "races", "excludeRaces"):
        if key in step:
            names = ", ".join(lua_str(name) for name in step[key])
            lines.append(f"{inner}{key} = {{ {names} }},")
    lines.append(f"{inner}text = {lua_str(step['text'])},")
    if "note" in step:
        lines.append(f"{inner}note = {lua_str(step['note'])},")
    if "quest" in step:
        lines.append(f"{inner}quest = {step['quest']},")
    if "quests" in step:
        lines.append(f"{inner}quests = {{ {', '.join(str(quest_id) for quest_id in step['quests'])} }},")
    if "when" in step:
        lines.append(f"{inner}when = {lua_str(step['when'])},")
    if "mode" in step:
        lines.append(f"{inner}mode = {lua_str(step['mode'])},")
    if "details" in step:
        lines.append(f"{inner}details = {{")
        for detail in step["details"]:
            lines.append(f"{inner}    {lua_str(detail)},")
        lines.append(f"{inner}}},")
    lines.append(indent + "},")
    return "\n".join(lines)


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def main() -> None:
    guides = parse_guides(SRC.read_text(encoding="utf-8", errors="replace"))
    out = [
        "local _, ns = ...",
        "",
        "-- The Barrens leveling for WoW Forever.",
        "-- classes and excludeClasses choose who sees a step. races and excludeRaces do the same for race.",
        '-- when = "accepted" moves on once the quest is in your log.',
        '-- when = "complete" moves on once the quest is turned in.',
        '-- when = "objectives" moves on once its objectives are finished.',
        '-- mode = "softcore" or "hardcore" is that branch. Hardcore steps in options follows the other one.',
        "-- Pins omitted: QuestieDB supplies NPC coordinates for accept and turn-in steps.",
        "",
    ]
    total = 0
    for name, body in guides:
        steps: list[dict] = []
        for chunk in split_steps(body):
            steps.extend(convert_step(chunk))
        steps = fold_reminders(steps)
        total += len(steps)
        out.append("ns.RegisterGuide({")
        out.append(f"    id = {lua_str('horde-' + slug(name))},")
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
    print(f"steps {total}")


if __name__ == "__main__":
    main()
