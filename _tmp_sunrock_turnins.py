import sys
from pathlib import Path
sys.path.insert(0, str(Path(r"D:/!Mods/Waynotes/Data")))
from audit_curated_coords import *

area = load_area_to_uimap()
npcs = parse_npc_db(QDB / "foreverNpcDB.lua")
quests = parse_quest_db(QDB / "foreverQuestDB.lua")

for qid in (6393, 6282, 1087, 6301, 6381):
    q = quests[qid]
    print("===", qid, q["name"])
    print(" finish", q["finished_npcs"], "start", q["started_npcs"])
    for nid in q["finished_npcs"] or q["started_npcs"]:
        n = npcs.get(nid, {})
        pins = entity_pins(n, area, 1442)
        if pins:
            xs = sum(p.x for p in pins)/len(pins)
            ys = sum(p.y for p in pins)/len(pins)
            print(f"  {nid} {n.get('name')} {xs:.2f},{ys:.2f}")
