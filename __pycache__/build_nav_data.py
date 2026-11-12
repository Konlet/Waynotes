import json
from pathlib import Path

root = Path(r"d:/!Mods/RestedXP-Better")
inn = json.loads((root / "Data/wow-forever-innkeepers.json").read_text(encoding="utf-8"))
flt = json.loads((root / "Data/wow-forever-flight-connections.json").read_text(encoding="utf-8"))

# Classic Era / Forever continent zone UiMap IDs (percent coords in Data are Forever).
ZONE_MAP = {
    "Alterac Mountains": 1416,
    "Arathi Highlands": 1417,
    "Ashenvale": 1440,
    "Azshara": 1447,
    "Badlands": 1418,
    "Blasted Lands": 1419,
    "Burning Steppes": 1428,
    "Darkshore": 1439,
    "Darnassus": 1457,
    "Desolace": 1443,
    "Dun Morogh": 1426,
    "Durotar": 1411,
    "Duskwood": 1431,
    "Dustwallow Marsh": 1445,
    "Eastern Plaguelands": 1423,
    "Elwynn Forest": 1429,
    "Felwood": 1448,
    "Feralas": 1444,
    "Hillsbrad Foothills": 1424,
    "Ironforge": 1455,
    "Loch Modan": 1432,
    "Moonglade": 1450,
    "Mulgore": 1412,
    "Orgrimmar": 1454,
    "Redridge Mountains": 1433,
    "Searing Gorge": 1427,
    "Silithus": 1451,
    "Silverpine Forest": 1421,
    "Stonetalon Mountains": 1442,
    "Stormwind City": 1453,
    "Stranglethorn Vale": 1434,
    "Swamp of Sorrows": 1435,
    "Tanaris": 1446,
    "Teldrassil": 1438,
    "The Barrens": 1413,
    "The Hinterlands": 1425,
    "Thousand Needles": 1441,
    "Thunder Bluff": 1456,
    "Tirisfal Glades": 1420,
    "Undercity": 1458,
    "Un'Goro Crater": 1449,
    "Western Plaguelands": 1422,
    "Westfall": 1436,
    "Wetlands": 1437,
    "Winterspring": 1452,
    # Forever custom / renamed zones: leave nil until known.
    "Mount Hyjal": None,
    "Riverglades": None,
    "Shen'dralas": None,
    "Zephras Isle": None,
}


def lua_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def faction_lua(f):
    if f in ("Horde", "Alliance"):
        return lua_str(f)
    return "nil"


# Classic NPC ids so Questie can supply live Forever spawn pins for the arrow.
INN_NPC = {
    "Calandrath": 15174,
    "Innkeeper Abeqwa": 11116,
    "Innkeeper Adegwa": 9501,
    "Innkeeper Allison": 6740,
    "Innkeeper Anderson": 2352,
    "Innkeeper Bates": 6739,
    "Innkeeper Belm": 1247,
    "Innkeeper Boorand Plainswind": 3934,
    "Innkeeper Brianna": 6727,
    "Innkeeper Byula": 7714,
    "Innkeeper Faralia": 16458,
    "Innkeeper Farley": 295,
    "Innkeeper Firebrew": 5111,
    "Innkeeper Fizzgrimble": 7733,
    "Innkeeper Greul": 7737,
    "Innkeeper Grosk": 6928,
    "Innkeeper Gryshka": 6929,
    "Innkeeper Hearthstove": 6734,
    "Innkeeper Heather": 8931,
    "Innkeeper Helbrek": 1464,
    "Innkeeper Janene": 6272,
    "Innkeeper Jayka": 7731,
    "Innkeeper Karakul": 6930,
    "Innkeeper Kauth": 6747,
    "Innkeeper Kaylisk": 12196,
    "Innkeeper Keldamyr": 6736,
    "Innkeeper Kimlya": 6738,
    "Innkeeper Lyshaerya": 11103,
    "Innkeeper Norman": 6741,
    "Innkeeper Pala": 6746,
    "Innkeeper Renee": 5688,
    "Innkeeper Saelienne": 6735,
    "Innkeeper Shaussiy": 6737,
    "Innkeeper Shay": 2388,
    "Innkeeper Shul'kar": 9356,
    "Innkeeper Shyria": 7736,
    "Innkeeper Sikewa": 11106,
    "Innkeeper Skindle": 6807,
    "Innkeeper Thulbek": 5814,
    "Innkeeper Thulfram": 7744,
    "Innkeeper Trelayne": 6790,
    "Innkeeper Vizzie": 11118,
    "Innkeeper Wiley": 6791,
    "Jessica Chambers": 16256,
    "Lard": 14731,
}


lines = []
lines.append("local _, ns = ...")
lines.append("")
lines.append("-- Generated from Data/wow-forever-innkeepers.json")
lines.append("-- Coordinates are Forever zone percents. map is Classic Era UiMap ID when known.")
lines.append("-- npc ids let Questie override the pin for accurate Go-button arrow aiming.")
lines.append("")
lines.append("ns.NavInnkeepers = {")
for e in sorted(inn, key=lambda x: (x["position"]["zone"], x["name"])):
    zone = e["position"]["zone"]
    ui = ZONE_MAP.get(zone)
    fac = e.get("faction")
    parts = [
        f"name = {lua_str(e['name'])}",
        f"zone = {lua_str(zone)}",
        f"x = {e['position']['x']}",
        f"y = {e['position']['y']}",
        f"faction = {faction_lua(fac)}",
        "forever = true",
    ]
    if isinstance(ui, int):
        parts.insert(2, f"map = {ui}")
    npc = INN_NPC.get(e["name"])
    if isinstance(npc, int):
        parts.append(f"npc = {npc}")
    lines.append("    { " + ", ".join(parts) + " },")
lines.append("}")
lines.append("")
(root / "Data/Innkeepers.lua").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")

nodes = {}
for edge in flt:
    for side in ("from", "to"):
        n = edge[side]
        nodes[n["nodeId"]] = n

lines = []
lines.append("local _, ns = ...")
lines.append("")
lines.append("-- Generated from Data/wow-forever-flight-connections.json")
lines.append("-- World coordinates use continent mapId 0 (EK) / 1 (Kalimdor).")
lines.append("")
lines.append("ns.NavFlightMasters = {")
for node_id in sorted(nodes):
    n = nodes[node_id]
    fm = n.get("flightmaster") or {}
    pos = n["position"]
    fac = n.get("faction")
    parts = [
        f"nodeId = {node_id}",
        f"name = {lua_str(fm.get('name') or n['name'])}",
        f"zone = {lua_str(n.get('zone') or '')}",
        f"hub = {lua_str(n['name'])}",
        f"faction = {faction_lua(fac)}",
        f"wx = {pos['x']}",
        f"wy = {pos['y']}",
        f"wz = {pos.get('z', 0)}",
        f"instance = {pos['mapId']}",
        "forever = true",
    ]
    npc = fm.get("id")
    if isinstance(npc, int):
        parts.append(f"npc = {npc}")
    lines.append("    { " + ", ".join(parts) + " },")
lines.append("}")
lines.append("")

# Compact connection index for later flight routing / timers.
lines.append("ns.NavFlightConnections = {")
for edge in flt:
    a = edge["from"]["nodeId"]
    b = edge["to"]["nodeId"]
    sec = edge.get("estimatedSeconds")
    fac = edge.get("faction")
    parts = [f"from = {a}", f"to = {b}", f"seconds = {sec}", f"faction = {faction_lua(fac)}"]
    lines.append("    { " + ", ".join(parts) + " },")
lines.append("}")
lines.append("")
(root / "Data/FlightMasters.lua").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")

print(f"Wrote {len(inn)} innkeepers, {len(nodes)} flight masters, {len(flt)} connections")
missing = sorted({e['position']['zone'] for e in inn if ZONE_MAP.get(e['position']['zone']) is None})
print("Inns without UiMap:", missing)
