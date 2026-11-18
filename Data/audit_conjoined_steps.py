"""
Find curated steps that pack geographically separate work into one step.

Flags:
  1. Multi-quest accept/complete steps whose NPCs are far apart
  2. Objectives steps with multiple quest objectives whose spawn centroids
     are far apart (and no objective=N split)
  3. Steps that name multiple FRIENDLY NPCs (likely hub mashups)
"""
from __future__ import annotations

import math
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from audit_curated_coords import (  # noqa: E402
    CURATED,
    QDB,
    entity_pins,
    load_area_to_uimap,
    parse_item_db,
    parse_npc_db,
    parse_object_db,
    parse_quest_db,
)

SEP = 12.0  # map percent; ~same as sticky/camp separation judgment


def centroid(pins: list) -> tuple[int, float, float] | None:
    if not pins:
        return None
    # Prefer densest map
    by_map: dict[int, list[tuple[float, float]]] = {}
    for p in pins:
        by_map.setdefault(p.map_id, []).append((p.x, p.y))
    map_id, pts = max(by_map.items(), key=lambda kv: len(kv[1]))
    return map_id, sum(p[0] for p in pts) / len(pts), sum(p[1] for p in pts) / len(pts)


def dist(a: tuple[float, float], b: tuple[float, float]) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def npc_centroid(npc_id: int, npcs: dict, area: dict) -> tuple[int, float, float] | None:
    pins = entity_pins(npcs.get(npc_id), area)
    return centroid(pins)


def objective_centroids(quest: dict, npcs, objs, items, area) -> list[tuple[str, tuple[int, float, float]]]:
    out = []
    for kind, ids, db in (
        ("creature", quest.get("obj_npcs") or [], npcs),
        ("object", quest.get("obj_objs") or [], objs),
    ):
        for eid in ids:
            c = centroid(entity_pins(db.get(eid), area))
            if c:
                name = (db.get(eid) or {}).get("name") or str(eid)
                out.append((f"{kind}:{name}", c))
    for iid in quest.get("obj_items") or []:
        item = items.get(iid) or {}
        pins = []
        for nid in item.get("npcDrops") or []:
            pins.extend(entity_pins(npcs.get(nid), area))
        for oid in item.get("objectDrops") or []:
            pins.extend(entity_pins(objs.get(oid), area))
        c = centroid(pins)
        if c:
            out.append((f"item:{item.get('name') or iid}", c))
    return out


def friendlies(text: str) -> list[str]:
    return re.findall(r"\[FRIENDLY\]([^\[\]]+)\[/\]", text or "")


def parse_steps_rich(path: Path) -> list[dict]:
    """Richer step parse: quests list, objective index, pins, full body."""
    from audit_curated_coords import _decode

    text = path.read_text(encoding="utf-8", errors="replace")
    steps = []
    for m in re.finditer(r"\{\s*\n((?:[^\n]*\n)*?)\s*\},?", text):
        body = m.group(1)
        if "text" not in body:
            continue
        text_m = re.search(r'\btext\s*=\s*"((?:\\.|[^"\\])*)"', body)
        if not text_m:
            continue
        when_m = re.search(r'\bwhen\s*=\s*"([^"]+)"', body)
        qm = re.search(r"\bquest\s*=\s*(\d+)", body)
        qsm = re.search(r"\bquests\s*=\s*\{([^}]+)\}", body)
        qids = []
        if qsm:
            qids = [int(x) for x in re.findall(r"\d+", qsm.group(1))]
        elif qm:
            qids = [int(qm.group(1))]
        obj_m = re.search(r"\bobjective\s*=\s*(\d+)", body)
        mm = re.search(r"\bmap\s*=\s*(\d+)", body)
        pins = []
        pins_m = re.search(r"\bpins\s*=\s*\{([\s\S]*?)\n\s*\},?", body)
        if pins_m:
            for pm in re.finditer(
                r"\{\s*(?:map\s*=\s*(\d+)\s*,\s*)?x\s*=\s*([0-9.]+)\s*,\s*y\s*=\s*([0-9.]+)",
                pins_m.group(1),
            ):
                pins.append(
                    {
                        "map": int(pm.group(1)) if pm.group(1) else (int(mm.group(1)) if mm else None),
                        "x": float(pm.group(2)),
                        "y": float(pm.group(3)),
                    }
                )
        xm = re.search(r"\bx\s*=\s*(-?[0-9.]+)", body)
        ym = re.search(r"\by\s*=\s*(-?[0-9.]+)", body)
        line = text[: m.start()].count("\n") + 1
        when = when_m.group(1) if when_m else ("objectives" if qids else "")
        steps.append(
            {
                "line": line,
                "text": _decode(text_m.group(1)),
                "when": when,
                "quests": qids,
                "objective": int(obj_m.group(1)) if obj_m else None,
                "map": int(mm.group(1)) if mm else None,
                "x": float(xm.group(1)) if xm else None,
                "y": float(ym.group(1)) if ym else None,
                "pins": pins,
            }
        )
    return steps


def main() -> int:
    area = load_area_to_uimap()
    npcs = parse_npc_db(QDB / "foreverNpcDB.lua")
    objs = parse_object_db(QDB / "foreverObjectDB.lua")
    items = parse_item_db(QDB / "foreverItemDB.lua")
    quests = parse_quest_db(QDB / "foreverQuestDB.lua")

    files = sorted(
        p
        for p in CURATED.glob("*_Curated.lua")
        if "Profession" not in p.name
    )
    findings = []
    for path in files:
        steps = parse_steps_rich(path)
        for step in steps:
            text = step.get("text") or ""
            when = step.get("when") or ""
            qids = list(step.get("quests") or [])

            # Multiple FRIENDLY names in one step
            fr = friendlies(text)
            if len(set(fr)) >= 2:
                findings.append(
                    {
                        "file": path.name,
                        "line": step.get("line"),
                        "kind": "multi-npc-text",
                        "text": text[:110],
                        "detail": " / ".join(fr),
                        "quests": qids,
                    }
                )

            # Multi-quest: compare NPC centroids (starters for accepted, finishers for complete)
            if len(qids) >= 2 and when in ("accepted", "complete"):
                cents = []
                for qid in qids:
                    q = quests.get(qid)
                    if not q:
                        continue
                    ids = q.get("finished_npcs") if when == "complete" else q.get("started_npcs")
                    for nid in ids or []:
                        c = npc_centroid(nid, npcs, area)
                        if c:
                            cents.append((qid, nid, c))
                for i in range(len(cents)):
                    for j in range(i + 1, len(cents)):
                        a, b = cents[i], cents[j]
                        if a[0] == b[0]:
                            continue
                        if a[2][0] != b[2][0]:
                            findings.append(
                                {
                                    "file": path.name,
                                    "line": step.get("line"),
                                    "kind": "multi-quest-diff-map",
                                    "text": text[:110],
                                    "detail": f"q{a[0]} map{a[2][0]} vs q{b[0]} map{b[2][0]}",
                                    "quests": qids,
                                }
                            )
                        else:
                            d = dist((a[2][1], a[2][2]), (b[2][1], b[2][2]))
                            if d >= SEP:
                                findings.append(
                                    {
                                        "file": path.name,
                                        "line": step.get("line"),
                                        "kind": "multi-quest-far-npc",
                                        "text": text[:110],
                                        "detail": f"q{a[0]} npc{a[1]} vs q{b[0]} npc{b[1]} dist={d:.1f}%",
                                        "quests": qids,
                                    }
                                )

            # Objectives without objective index: multiple far objective centroids
            if when == "objectives" and qids and not step.get("objective"):
                for qid in qids:
                    q = quests.get(qid)
                    if not q:
                        continue
                    cents = objective_centroids(q, npcs, objs, items, area)
                    if len(cents) < 2:
                        continue
                    far_pairs = []
                    for i in range(len(cents)):
                        for j in range(i + 1, len(cents)):
                            na, ca = cents[i]
                            nb, cb = cents[j]
                            if ca[0] != cb[0]:
                                far_pairs.append(f"{na} map{ca[0]} vs {nb} map{cb[0]}")
                            else:
                                d = dist((ca[1], ca[2]), (cb[1], cb[2]))
                                if d >= SEP:
                                    far_pairs.append(
                                        f"{na} ({ca[1]:.1f},{ca[2]:.1f}) vs "
                                        f"{nb} ({cb[1]:.1f},{cb[2]:.1f}) dist={d:.1f}%"
                                    )
                    if far_pairs:
                        findings.append(
                            {
                                "file": path.name,
                                "line": step.get("line"),
                                "kind": "multi-obj-far",
                                "text": text[:110],
                                "detail": f"q{qid}: " + "; ".join(far_pairs[:3]),
                                "quests": [qid],
                            }
                        )

            # Authored pins span on objectives
            pins = step.get("pins") or []
            if when == "objectives" and len(pins) >= 2:
                xs = [(p.get("x"), p.get("y")) for p in pins if p.get("x") is not None]
                if len(xs) >= 2:
                    maxd = 0.0
                    for i in range(len(xs)):
                        for j in range(i + 1, len(xs)):
                            maxd = max(maxd, dist(xs[i], xs[j]))
                    if maxd >= 15.0:
                        findings.append(
                            {
                                "file": path.name,
                                "line": step.get("line"),
                                "kind": "wide-pins",
                                "text": text[:110],
                                "detail": f"{len(pins)} pins span {maxd:.1f}%",
                                "quests": qids,
                            }
                        )

    # Dedupe identical findings
    seen = set()
    uniq = []
    for f in findings:
        key = (f["file"], f["line"], f["kind"], f["detail"])
        if key in seen:
            continue
        seen.add(key)
        uniq.append(f)

    by_file: dict[str, list] = {}
    for f in uniq:
        by_file.setdefault(f["file"], []).append(f)

    total = 0
    for file, rows in sorted(by_file.items()):
        print(f"\n=== {file} ({len(rows)}) ===")
        for f in sorted(rows, key=lambda r: r["line"] or 0):
            total += 1
            print(f"L{f['line']}: [{f['kind']}] q={f['quests']}")
            print(f"  {f['text']}")
            print(f"  -> {f['detail']}")
    print(f"\nTOTAL {total} findings across {len(by_file)} files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
