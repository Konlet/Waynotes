"""
Audit curated guide map/x/y pins against QuestieDB Forever data.

Compares each quest step pin to:
  accepted  -> quest starter NPC/object
  complete  -> quest finisher NPC/object
  objectives -> creature objectives, object objectives, or item drop NPCs/objects
"""
from __future__ import annotations

import argparse
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QDB = ROOT / "_questiedb" / "data" / "Forever"
CURATED = ROOT / "Guides" / "Forever" / "Curated"

WARN_DIST = 8.0
BAD_DIST = 20.0


@dataclass
class Pin:
    map_id: int
    x: float
    y: float


@dataclass
class StepHit:
    file: str
    line: int
    quest: int | None
    when: str
    text: str
    pin: Pin
    expected: Pin | None
    dist: float | None
    reason: str
    note: str


def load_area_to_uimap() -> dict[int, int]:
    data = json.loads((QDB / "conversion.json").read_text(encoding="utf-8"))
    out: dict[int, int] = {}
    for t in data["geometry"]["transforms"]:
        out[int(t["area_id"])] = int(t["ui_map_id"])
    extras = {
        1637: 1454,
        1638: 1456,
        1497: 1458,
        1657: 1457,
        1519: 1453,
        1537: 1455,
        14: 1411,
        215: 1412,
        17: 1413,
        406: 1442,
        331: 1440,
        400: 1441,
        267: 1424,
        85: 1420,
        141: 1438,
        148: 1439,
        44: 1433,
        12: 1429,
        40: 1436,
        38: 1432,
        11: 1437,
        10: 1431,
        33: 1434,
        130: 1421,
        15: 1445,
        405: 1443,
        357: 1444,
        440: 1446,
        490: 1449,
        361: 1448,
        618: 1452,
        1377: 1451,
        16: 1447,
        3: 1418,
        4: 1419,
        8: 1435,
        28: 1422,
        139: 1423,
        47: 1425,
        45: 1417,
        51: 1427,
        46: 1428,
        36: 1416,
        1: 1426,
        41: 1430,
        493: 1450,
    }
    for k, v in extras.items():
        out.setdefault(k, v)
    return out


def _decode(s: str) -> str:
    return (
        s.replace("\\'", "'")
        .replace('\\"', '"')
        .replace("\\n", "\n")
        .replace("\\\\", "\\")
    )


def _extract_entries(blob: str) -> list[tuple[int, str]]:
    """Return (id, body) for each [id] = {body} top-level entry."""
    out: list[tuple[int, str]] = []
    for em in re.finditer(r"\[(\d+)\]\s*=\s*\{", blob):
        eid = int(em.group(1))
        start = em.end() - 1
        i = start
        depth = 0
        in_str = False
        str_ch = ""
        esc = False
        while i < len(blob):
            ch = blob[i]
            if in_str:
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == str_ch:
                    in_str = False
            else:
                if ch in ("'", '"'):
                    in_str = True
                    str_ch = ch
                elif ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
                    if depth == 0:
                        out.append((eid, blob[start + 1 : i]))
                        break
            i += 1
    return out


def _split_fields(body: str) -> list[str]:
    fields: list[str] = []
    pos = 0
    depth = 0
    in_str = False
    str_ch = ""
    esc = False
    field_start = 0
    while pos < len(body):
        ch = body[pos]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == str_ch:
                in_str = False
        else:
            if ch in ("'", '"'):
                in_str = True
                str_ch = ch
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
            elif ch == "," and depth == 0:
                fields.append(body[field_start:pos].strip())
                field_start = pos + 1
        pos += 1
    fields.append(body[field_start:].strip())
    return fields


def _parse_id_list(field: str | None) -> list[int]:
    if not field or field == "nil":
        return []
    return [int(x) for x in re.findall(r"\d+", field)]


def _parse_spawn_field(field: str | None) -> dict[int, list[tuple[float, float]]]:
    spawns: dict[int, list[tuple[float, float]]] = {}
    if not field or field == "nil":
        return spawns
    for area_m in re.finditer(
        r"\[(\d+)\]=\{\{([0-9.]+),([0-9.]+)\}((?:,\{[0-9.]+,[0-9.]+\})*)\}",
        field,
    ):
        area = int(area_m.group(1))
        pts = [(float(area_m.group(2)), float(area_m.group(3)))]
        for pm in re.finditer(r"\{([0-9.]+),([0-9.]+)\}", area_m.group(4)):
            pts.append((float(pm.group(1)), float(pm.group(2))))
        spawns[area] = pts
    return spawns


def _load_data_blob(path: Path, key: str) -> str:
    text = path.read_text(encoding="utf-8", errors="replace")
    m = re.search(rf"QuestieDB\.{key}\s*=\s*\[\[return\s*\{{", text)
    if not m:
        raise RuntimeError(f"{key} not found in {path}")
    blob = text[m.end() :]
    end = blob.rfind("}]]")
    return blob[:end]


def parse_npc_db(path: Path) -> dict[int, dict]:
    blob = _load_data_blob(path, "npcData")
    npcs: dict[int, dict] = {}
    for nid, body in _extract_entries(blob):
        fields = _split_fields(body)
        name = ""
        if fields and fields[0].startswith("'"):
            name = _decode(fields[0].strip("'"))
        # spawns = field 7 (index 6)
        spawns = _parse_spawn_field(fields[6] if len(fields) > 6 else None)
        npcs[nid] = {"name": name, "spawns": spawns}
    return npcs


def parse_object_db(path: Path) -> dict[int, dict]:
    blob = _load_data_blob(path, "objectData")
    objs: dict[int, dict] = {}
    for oid, body in _extract_entries(blob):
        fields = _split_fields(body)
        name = ""
        if fields and (fields[0].startswith('"') or fields[0].startswith("'")):
            name = _decode(fields[0].strip("\"'"))
        # spawns = field 4 (index 3)
        spawns = _parse_spawn_field(fields[3] if len(fields) > 3 else None)
        objs[oid] = {"name": name, "spawns": spawns}
    return objs


def parse_item_db(path: Path) -> dict[int, dict]:
    blob = _load_data_blob(path, "itemData")
    items: dict[int, dict] = {}
    for iid, body in _extract_entries(blob):
        fields = _split_fields(body)
        name = ""
        if fields and fields[0].startswith("'"):
            name = _decode(fields[0].strip("'"))
        items[iid] = {
            "name": name,
            "npcDrops": _parse_id_list(fields[1] if len(fields) > 1 else None),
            "objectDrops": _parse_id_list(fields[2] if len(fields) > 2 else None),
        }
    return items


def _unwrap_table(field: str | None) -> str | None:
    """Remove one outer {...} layer. Do not use str.strip('{}/')."""
    if not field or field == "nil":
        return None
    field = field.strip()
    if field.startswith("{") and field.endswith("}"):
        return field[1:-1]
    return field


def _first_creature_ids(table_field: str | None) -> list[int]:
    """From startedBy/finishedBy {{creatures},{objects},{items}} take creatures."""
    inner = _unwrap_table(table_field)
    if inner is None:
        return []
    fields = _split_fields(inner)
    if not fields:
        return []
    return _parse_id_list(fields[0])


def _first_object_ids(table_field: str | None) -> list[int]:
    inner = _unwrap_table(table_field)
    if inner is None:
        return []
    fields = _split_fields(inner)
    if len(fields) < 2:
        return []
    return _parse_id_list(fields[1])


def _objective_ids(obj_field: str | None) -> tuple[list[int], list[int], list[int]]:
    """Return (creature_ids, object_ids, item_ids) from objectives field."""
    inner = _unwrap_table(obj_field)
    if inner is None:
        return [], [], []
    top = _split_fields(inner)
    creatures: list[int] = []
    objects: list[int] = []
    items: list[int] = []
    def ids_in(sub: str) -> list[int]:
        # Entries look like {id}, {{id}}, or {id,"text"} inside the subtable.
        return [int(x) for x in re.findall(r"\{(\d+)", sub)]

    if len(top) >= 1 and top[0] != "nil":
        creatures = ids_in(top[0])
    if len(top) >= 2 and top[1] != "nil":
        objects = ids_in(top[1])
    if len(top) >= 3 and top[2] != "nil":
        items = ids_in(top[2])
    return creatures, objects, items


def parse_quest_db(path: Path) -> dict[int, dict]:
    blob = _load_data_blob(path, "questData")
    quests: dict[int, dict] = {}
    for qid, body in _extract_entries(blob):
        fields = _split_fields(body)
        name = ""
        if fields and fields[0].startswith('"'):
            name = _decode(fields[0].strip('"'))
        started_npcs = _first_creature_ids(fields[1] if len(fields) > 1 else None)
        started_objs = _first_object_ids(fields[1] if len(fields) > 1 else None)
        finished_npcs = _first_creature_ids(fields[2] if len(fields) > 2 else None)
        finished_objs = _first_object_ids(fields[2] if len(fields) > 2 else None)
        cre, obj, items = _objective_ids(fields[9] if len(fields) > 9 else None)
        quests[qid] = {
            "name": name,
            "started_npcs": started_npcs,
            "started_objs": started_objs,
            "finished_npcs": finished_npcs,
            "finished_objs": finished_objs,
            "obj_npcs": cre,
            "obj_objs": obj,
            "obj_items": items,
        }
    return quests


def entity_pins(
    entity: dict | None,
    area_to_map: dict[int, int],
    prefer_map: int | None = None,
) -> list[Pin]:
    if not entity:
        return []
    pins: list[Pin] = []
    for area, pts in entity.get("spawns", {}).items():
        ui = area_to_map.get(area)
        if ui is None:
            continue
        if prefer_map is not None and ui != prefer_map:
            continue
        for x, y in pts:
            pins.append(Pin(ui, x, y))
    if prefer_map is not None and not pins:
        return entity_pins(entity, area_to_map, prefer_map=None)
    return pins


def nearest_pin(target: Pin, candidates: list[Pin]) -> tuple[Pin | None, float | None]:
    best = None
    best_d = None
    for c in candidates:
        if c.map_id != target.map_id:
            continue
        d = math.hypot(c.x - target.x, c.y - target.y)
        if best_d is None or d < best_d:
            best_d = d
            best = c
    if best is not None:
        return best, best_d
    if candidates:
        return candidates[0], 999.0
    return None, None


def parse_guide_steps(path: Path) -> list[dict]:
    text = path.read_text(encoding="utf-8", errors="replace")
    steps = []
    for m in re.finditer(r"\{\s*\n((?:[^\n]*\n)*?)\s*\},?", text):
        body = m.group(1)
        if "map" not in body or re.search(r"\bx\s*=", body) is None:
            continue
        mm = re.search(r"\bmap\s*=\s*(\d+)", body)
        xm = re.search(r"\bx\s*=\s*(-?[0-9.]+)", body)
        ym = re.search(r"\by\s*=\s*(-?[0-9.]+)", body)
        if not (mm and xm and ym):
            continue
        qm = re.search(r"\bquest\s*=\s*(\d+)", body)
        # Also support quests = { a, b } — use first id for lookup.
        qsm = re.search(r"\bquests\s*=\s*\{([^}]+)\}", body)
        quest = None
        if qm:
            quest = int(qm.group(1))
        elif qsm:
            nums = re.findall(r"\d+", qsm.group(1))
            if nums:
                quest = int(nums[0])
        when_m = re.search(r'\bwhen\s*=\s*"([^"]+)"', body)
        text_m = re.search(r'\btext\s*=\s*"((?:\\.|[^"\\])*)"', body)
        line = text[: m.start()].count("\n") + 1
        steps.append(
            {
                "line": line,
                "quest": quest,
                "when": when_m.group(1)
                if when_m
                else ("objectives" if quest else "travel"),
                "text": _decode(text_m.group(1)) if text_m else "",
                "pin": Pin(int(mm.group(1)), float(xm.group(1)), float(ym.group(1))),
            }
        )
    return steps


def expected_for_step(
    step: dict,
    quests: dict[int, dict],
    npcs: dict[int, dict],
    objs: dict[int, dict],
    items: dict[int, dict],
    area_to_map: dict[int, int],
) -> tuple[list[Pin], str]:
    qid = step["quest"]
    when = step["when"]
    if not qid or qid not in quests:
        return [], "no-quest-db"
    q = quests[qid]
    prefer = step["pin"].map_id
    pins: list[Pin] = []

    def add_npcs(ids: list[int]) -> None:
        for nid in ids:
            pins.extend(entity_pins(npcs.get(nid), area_to_map, prefer))

    def add_objs(ids: list[int]) -> None:
        for oid in ids:
            pins.extend(entity_pins(objs.get(oid), area_to_map, prefer))

    if when == "accepted":
        add_npcs(q["started_npcs"])
        add_objs(q["started_objs"])
        return pins, "giver"
    if when in ("complete", "turnin"):
        add_npcs(q["finished_npcs"])
        add_objs(q["finished_objs"])
        return pins, "turnin"

    # objectives
    add_npcs(q["obj_npcs"])
    add_objs(q["obj_objs"])
    for iid in q["obj_items"]:
        item = items.get(iid)
        if not item:
            continue
        add_npcs(item["npcDrops"])
        add_objs(item["objectDrops"])
    if pins:
        return pins, "objective"
    return [], "no-objective-spawns"


def audit_file(
    path: Path,
    quests: dict[int, dict],
    npcs: dict[int, dict],
    objs: dict[int, dict],
    items: dict[int, dict],
    area_to_map: dict[int, int],
) -> list[StepHit]:
    hits: list[StepHit] = []
    for step in parse_guide_steps(path):
        if not step["quest"]:
            continue
        candidates, reason = expected_for_step(
            step, quests, npcs, objs, items, area_to_map
        )
        if not candidates:
            if reason != "no-objective-spawns":
                hits.append(
                    StepHit(
                        file=path.name,
                        line=step["line"],
                        quest=step["quest"],
                        when=step["when"],
                        text=step["text"][:90],
                        pin=step["pin"],
                        expected=None,
                        dist=None,
                        reason=reason,
                        note=reason,
                    )
                )
            continue
        exp, dist = nearest_pin(step["pin"], candidates)
        if exp is None or dist is None or dist < WARN_DIST:
            continue
        qname = quests.get(step["quest"], {}).get("name", "")
        same = exp.map_id == step["pin"].map_id
        note = (
            f"Questie {reason} @ {exp.map_id} {exp.x:.2f},{exp.y:.2f}"
            + ("" if same else " (MAP MISMATCH)")
            + (f" [{qname}]" if qname else "")
        )
        hits.append(
            StepHit(
                file=path.name,
                line=step["line"],
                quest=step["quest"],
                when=step["when"],
                text=step["text"][:90],
                pin=step["pin"],
                expected=exp,
                dist=dist,
                reason=reason,
                note=note,
            )
        )
    return hits


def fmt_coord(v: float) -> str:
    s = f"{v:.2f}".rstrip("0").rstrip(".")
    return s


def apply_fixes(hits: list[StepHit], threshold: float) -> None:
    by_file: dict[str, list[StepHit]] = {}
    for h in hits:
        if h.expected is None or h.dist is None:
            continue
        if h.dist < threshold or h.dist >= 900:
            continue
        if h.expected.map_id != h.pin.map_id:
            continue
        by_file.setdefault(h.file, []).append(h)

    for fname, rows in by_file.items():
        path = CURATED / fname
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines(keepends=True)
        # Process descending by line so earlier indices stay valid.
        for h in sorted(rows, key=lambda r: r.line, reverse=True):
            start = max(0, h.line - 1)
            end = min(len(lines), h.line + 50)
            old_x, old_y = h.pin.x, h.pin.y
            new_x, new_y = fmt_coord(h.expected.x), fmt_coord(h.expected.y)
            replaced = False
            for i in range(start, end):
                xm = re.match(rf"^(\s*x\s*=\s*){re.escape(str(old_x))}(\s*,?\s*)$", lines[i])
                if not xm:
                    xm = re.match(rf"^(\s*x\s*=\s*){old_x}(\s*,?\s*)$", lines[i])
                if not xm:
                    continue
                for j in range(i, min(i + 3, end)):
                    ym = re.match(
                        rf"^(\s*y\s*=\s*){re.escape(str(old_y))}(\s*,?\s*)$", lines[j]
                    )
                    if not ym:
                        ym = re.match(rf"^(\s*y\s*=\s*){old_y}(\s*,?\s*)$", lines[j])
                    if not ym:
                        continue
                    # Prefer keeping a trailing comma if present.
                    x_suffix = xm.group(2)
                    y_suffix = ym.group(2)
                    if "," not in x_suffix:
                        x_suffix = "," + ("\n" if x_suffix.endswith("\n") else "")
                        if not x_suffix.endswith("\n") and lines[i].endswith("\n"):
                            x_suffix = ",\n"
                    lines[i] = xm.group(1) + new_x + (
                        ",\n" if lines[i].endswith("\n") else ","
                    )
                    # Preserve original y line ending/comma style more carefully.
                    y_comma = "," if "," in lines[j] else ""
                    y_nl = "\n" if lines[j].endswith("\n") else ""
                    lines[j] = ym.group(1) + new_y + y_comma + y_nl
                    replaced = True
                    break
                break
            if replaced:
                print(
                    f"FIX {fname}:{h.line} q{h.quest} "
                    f"{old_x},{old_y} -> {new_x},{new_y} ({h.reason})"
                )
            else:
                print(f"SKIP {fname}:{h.line} q{h.quest} (could not rewrite)")
        path.write_text("".join(lines), encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--fix", action="store_true")
    ap.add_argument("--threshold", type=float, default=BAD_DIST)
    ap.add_argument("--warn", type=float, default=WARN_DIST)
    ap.add_argument("files", nargs="*")
    args = ap.parse_args()

    print("Loading QuestieDB Forever...")
    area_to_map = load_area_to_uimap()
    npcs = parse_npc_db(QDB / "foreverNpcDB.lua")
    objs = parse_object_db(QDB / "foreverObjectDB.lua")
    items = parse_item_db(QDB / "foreverItemDB.lua")
    quests = parse_quest_db(QDB / "foreverQuestDB.lua")
    print(f"  NPCs={len(npcs)} Objs={len(objs)} Items={len(items)} Quests={len(quests)}")

    if args.files:
        files = [CURATED / f for f in args.files]
    else:
        files = sorted(
            f
            for f in CURATED.glob("*_Curated.lua")
            if not f.name.startswith("Professions_")
        )

    all_hits: list[StepHit] = []
    for f in files:
        all_hits.extend(audit_file(f, quests, npcs, objs, items, area_to_map))

    bad = [h for h in all_hits if h.dist is not None and h.dist >= args.threshold]
    warn = [
        h
        for h in all_hits
        if h.dist is not None and args.warn <= h.dist < args.threshold
    ]
    missing = [h for h in all_hits if h.dist is None]

    def show(title: str, rows: list[StepHit]) -> None:
        print(f"\n=== {title} ({len(rows)}) ===")
        for h in sorted(rows, key=lambda r: (-(r.dist or 0), r.file, r.line)):
            pin = f"{h.pin.map_id} {h.pin.x:.2f},{h.pin.y:.2f}"
            dist = f"{h.dist:.1f}" if h.dist is not None else "?"
            print(
                f"{h.file}:{h.line} q{h.quest} [{h.when}] dist={dist} pin={pin} | {h.note}"
            )
            print(f"  {h.text}")

    show(f"BAD (>= {args.threshold})", bad)
    show(f"WARN ({args.warn}-{args.threshold})", warn)
    if missing:
        print(f"\n=== NO SPAWN DATA ({len(missing)}) ===")
        for h in missing[:50]:
            print(f"{h.file}:{h.line} q{h.quest} [{h.when}] {h.note} | {h.text[:70]}")

    if args.fix:
        print("\nApplying same-map BAD fixes...")
        apply_fixes(bad, args.threshold)

    print(
        f"\nSummary: {len(bad)} bad, {len(warn)} warn, {len(missing)} unresolved "
        f"across {len(files)} guides"
    )


if __name__ == "__main__":
    main()
