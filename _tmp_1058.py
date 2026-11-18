import sys
from pathlib import Path
sys.path.insert(0, str(Path(r"D:/!Mods/Waynotes/Data")))
from audit_curated_coords import *

area = load_area_to_uimap()
npcs = parse_npc_db(QDB / "foreverNpcDB.lua")
objs = parse_object_db(QDB / "foreverObjectDB.lua")
items = parse_item_db(QDB / "foreverItemDB.lua")
quests = parse_quest_db(QDB / "foreverQuestDB.lua")

for qid in (1057, 1058, 1060):
    q = quests[qid]
    print("===", qid, q["name"])
    print(" start", q["started_npcs"], "finish", q["finished_npcs"])
    print(" obj_npcs", q["obj_npcs"], "obj_objs", q["obj_objs"], "obj_items", q["obj_items"])
    for iid in q["obj_items"]:
        it = items[iid]
        print("  item", iid, it["name"], "npcDrops", it["npcDrops"][:8], "objDrops", it["objectDrops"][:8])
        pins = []
        for nid in it["npcDrops"]:
            pins.extend(entity_pins(npcs.get(nid), area, 1442))
        for oid in it["objectDrops"]:
            pins.extend(entity_pins(objs.get(oid), area, 1442))
        if pins:
            xs = sum(p.x for p in pins) / len(pins)
            ys = sum(p.y for p in pins) / len(pins)
            print(f"   centroid 1442 {xs:.2f},{ys:.2f} n={len(pins)}")
            # nearest few
            pins.sort(key=lambda p: (p.x - xs) ** 2 + (p.y - ys) ** 2)
            for p in pins[:3]:
                print(f"   pin {p.x:.2f},{p.y:.2f}")
