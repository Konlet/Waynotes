"""Generate Data/*.lua nav tables from Forever JSON dumps."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "Data"

# Classic Era / Forever continent zone UiMap IDs (inn JSON has no mapId).
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

# Classic NPC ids so Questie can supply live Forever spawn pins when useful.
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


def load_json(name: str):
    return json.loads((DATA / name).read_text(encoding="utf-8"))


def lua_str(s: str) -> str:
    return '"' + str(s).replace("\\", "\\\\").replace('"', '\\"') + '"'


def faction_lua(faction) -> str:
    if faction in ("Horde", "Alliance", "Both"):
        return lua_str(faction)
    return "nil"


def map_from_position(pos: dict):
    if isinstance(pos.get("mapId"), int):
        return pos["mapId"]
    zone = pos.get("zone")
    return ZONE_MAP.get(zone) if isinstance(zone, str) else None


def write_lines(path: Path, lines: list[str]) -> None:
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def emit_zone_entry(e: dict, *, extra: list[str] | None = None) -> str:
    pos = e["position"]
    zone = pos["zone"]
    parts = [
        f"name = {lua_str(e['name'])}",
        f"zone = {lua_str(zone)}",
        f"x = {pos['x']}",
        f"y = {pos['y']}",
        f"faction = {faction_lua(e.get('faction'))}",
        "forever = true",
    ]
    ui = map_from_position(pos)
    if isinstance(ui, int):
        parts.insert(2, f"map = {ui}")
    if extra:
        parts.extend(extra)
    return "    { " + ", ".join(parts) + " },"


def build_innkeepers() -> int:
    inns = load_json("wow-forever-innkeepers.json")
    lines = [
        "local _, ns = ...",
        "",
        "-- Generated from Data/wow-forever-innkeepers.json",
        "-- Coordinates are Forever zone percents. map is Classic Era UiMap ID when known.",
        "-- npc ids are classic references; Forever presets are authoritative for aiming.",
        "",
        "ns.NavInnkeepers = {",
    ]
    for e in sorted(inns, key=lambda x: (x["position"]["zone"], x["name"])):
        extra = []
        npc = INN_NPC.get(e["name"])
        if isinstance(npc, int):
            extra.append(f"npc = {npc}")
        lines.append(emit_zone_entry(e, extra=extra))
    lines.append("}")
    lines.append("")
    write_lines(DATA / "Innkeepers.lua", lines)
    return len(inns)


def build_flight_masters() -> tuple[int, int]:
    edges = load_json("wow-forever-flight-connections.json")
    nodes = {}
    for edge in edges:
        for side in ("from", "to"):
            n = edge[side]
            nodes[n["nodeId"]] = n

    lines = [
        "local _, ns = ...",
        "",
        "-- Generated from Data/wow-forever-flight-connections.json",
        "-- World coordinates use continent mapId 0 (EK) / 1 (Kalimdor).",
        "",
        "ns.NavFlightMasters = {",
    ]
    for node_id in sorted(nodes):
        n = nodes[node_id]
        fm = n.get("flightmaster") or {}
        pos = n["position"]
        parts = [
            f"nodeId = {node_id}",
            f"name = {lua_str(fm.get('name') or n['name'])}",
            f"zone = {lua_str(n.get('zone') or '')}",
            f"hub = {lua_str(n['name'])}",
            f"faction = {faction_lua(n.get('faction'))}",
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
    lines.append("ns.NavFlightConnections = {")
    for edge in edges:
        a = edge["from"]["nodeId"]
        b = edge["to"]["nodeId"]
        sec = edge.get("estimatedSeconds")
        fac = edge.get("faction")
        parts = [f"from = {a}", f"to = {b}", f"seconds = {sec}", f"faction = {faction_lua(fac)}"]
        lines.append("    { " + ", ".join(parts) + " },")
    lines.append("}")
    lines.append("")
    write_lines(DATA / "FlightMasters.lua", lines)
    return len(nodes), len(edges)


def build_simple_zone_table(json_name: str, lua_name: str, ns_name: str, *, npc_field: str | None = "npcId") -> int:
    rows = load_json(json_name)
    lines = [
        "local _, ns = ...",
        "",
        f"-- Generated from Data/{json_name}",
        "-- Coordinates are Forever zone percents.",
        "",
        f"ns.{ns_name} = {{",
    ]
    for e in sorted(rows, key=lambda x: (x["position"]["zone"], x["name"], x["position"]["x"], x["position"]["y"])):
        extra = []
        if npc_field and isinstance(e.get(npc_field), int):
            extra.append(f"npc = {e[npc_field]}")
        if isinstance(e.get("objectId"), int):
            extra.append(f"object = {e['objectId']}")
        lines.append(emit_zone_entry(e, extra=extra))
    lines.append("}")
    lines.append("")
    write_lines(DATA / lua_name, lines)
    return len(rows)


def build_class_trainers() -> int:
    rows = load_json("wow-forever-class-trainers.json")
    # Go -> Trainer is class trainers only (not pet / portal / demon).
    rows = [e for e in rows if e.get("trainerType") == "class"]
    lines = [
        "local _, ns = ...",
        "",
        "-- Generated from Data/wow-forever-class-trainers.json",
        "-- Class trainers only (trainerType == class). Forever zone percents.",
        "",
        "ns.NavClassTrainers = {",
    ]
    for e in sorted(rows, key=lambda x: (x.get("className") or "", x["position"]["zone"], x["name"])):
        extra = [
            f"class = {lua_str(e.get('className') or '')}",
        ]
        if isinstance(e.get("npcId"), int):
            extra.append(f"npc = {e['npcId']}")
        lines.append(emit_zone_entry(e, extra=extra))
    lines.append("}")
    lines.append("")
    write_lines(DATA / "ClassTrainers.lua", lines)
    return len(rows)


def _dock_world(stop: dict) -> tuple[float, float, float, int] | None:
    """Prefer boardingPosition for aiming; fall back to dock position."""
    for key in ("boardingPosition", "position"):
        pos = stop.get(key)
        if not isinstance(pos, dict):
            continue
        if not isinstance(pos.get("mapId"), int):
            continue
        if not isinstance(pos.get("x"), (int, float)) or not isinstance(pos.get("y"), (int, float)):
            continue
        z = pos.get("z", 0)
        if not isinstance(z, (int, float)):
            z = 0
        return float(pos["x"]), float(pos["y"]), float(z), int(pos["mapId"])
    return None


def build_boats_zeppelins() -> tuple[int, int, int]:
    routes = load_json("wow-forever-boats-zeppelins.json")
    lines = [
        "local _, ns = ...",
        "",
        "-- Generated from Data/wow-forever-boats-zeppelins.json",
        "-- World coordinates use continent mapId 0 (EK) / 1 (Kalimdor) / Forever instances.",
        "-- Dock wx/wy prefer boardingPosition when present.",
        "",
        "ns.NavTransports = {",
    ]
    docks: list[dict] = []
    legs: list[dict] = []
    for route in sorted(routes, key=lambda r: r.get("routeId") or 0):
        route_id = route.get("routeId")
        if not isinstance(route_id, int):
            continue
        parts = [
            f"routeId = {route_id}",
            f"name = {lua_str(route.get('name') or '')}",
            f"type = {lua_str(route.get('type') or 'boat')}",
            f"faction = {faction_lua(route.get('faction'))}",
            f"cycleSeconds = {float(route.get('estimatedCycleSeconds') or 0)}",
        ]
        lines.append("    { " + ", ".join(parts) + " },")
        for stop in route.get("stops") or []:
            dock_id = stop.get("dockId")
            world = _dock_world(stop)
            if not isinstance(dock_id, int) or world is None:
                continue
            wx, wy, wz, instance = world
            docks.append(
                {
                    "dockId": dock_id,
                    "routeId": route_id,
                    "name": stop.get("name") or "",
                    "zone": stop.get("zone") or "",
                    "uiMapId": stop.get("uiMapId"),
                    "wx": wx,
                    "wy": wy,
                    "wz": wz,
                    "instance": instance,
                    "dwellSeconds": float(stop.get("dwellSeconds") or 60),
                    "faction": route.get("faction"),
                    "type": route.get("type") or "boat",
                    "routeName": route.get("name") or "",
                    "cycleSeconds": float(route.get("estimatedCycleSeconds") or 0),
                }
            )
        for leg in route.get("legs") or []:
            a, b = leg.get("fromDockId"), leg.get("toDockId")
            sec = leg.get("estimatedSeconds")
            if isinstance(a, int) and isinstance(b, int) and isinstance(sec, (int, float)):
                legs.append(
                    {
                        "from": a,
                        "to": b,
                        "seconds": float(sec),
                        "routeId": route_id,
                        "faction": route.get("faction"),
                        "type": route.get("type") or "boat",
                        "routeName": route.get("name") or "",
                    }
                )
    lines.append("}")
    lines.append("")
    lines.append("ns.NavTransportDocks = {")
    for d in sorted(docks, key=lambda x: x["dockId"]):
        parts = [
            f"dockId = {d['dockId']}",
            f"routeId = {d['routeId']}",
            f"name = {lua_str(d['name'])}",
            f"zone = {lua_str(d['zone'])}",
            f"faction = {faction_lua(d.get('faction'))}",
            f"type = {lua_str(d.get('type') or 'boat')}",
            f"routeName = {lua_str(d.get('routeName') or '')}",
            f"wx = {d['wx']}",
            f"wy = {d['wy']}",
            f"wz = {d['wz']}",
            f"instance = {d['instance']}",
            f"dwellSeconds = {d['dwellSeconds']}",
            f"cycleSeconds = {d['cycleSeconds']}",
            "forever = true",
        ]
        if isinstance(d.get("uiMapId"), int):
            parts.insert(4, f"map = {d['uiMapId']}")
        lines.append("    { " + ", ".join(parts) + " },")
    lines.append("}")
    lines.append("")
    lines.append("ns.NavTransportLegs = {")
    for leg in sorted(legs, key=lambda x: (x["routeId"], x["from"], x["to"])):
        parts = [
            f"from = {leg['from']}",
            f"to = {leg['to']}",
            f"seconds = {leg['seconds']}",
            f"routeId = {leg['routeId']}",
            f"faction = {faction_lua(leg.get('faction'))}",
            f"type = {lua_str(leg.get('type') or 'boat')}",
            f"routeName = {lua_str(leg.get('routeName') or '')}",
        ]
        lines.append("    { " + ", ".join(parts) + " },")
    lines.append("}")
    lines.append("")
    write_lines(DATA / "BoatsZeppelins.lua", lines)
    return len(routes), len(docks), len(legs)


def main() -> None:
    inns = build_innkeepers()
    flights, connections = build_flight_masters()
    banks = build_simple_zone_table("wow-forever-banks.json", "Banks.lua", "NavBanks")
    auctions = build_simple_zone_table("wow-forever-auction-houses.json", "AuctionHouses.lua", "NavAuctionHouses")
    mail = build_simple_zone_table("wow-forever-mailboxes.json", "Mailboxes.lua", "NavMailboxes", npc_field=None)
    trainers = build_class_trainers()
    routes, docks, transport_legs = build_boats_zeppelins()
    print(
        f"Wrote {inns} inns, {flights} flight masters, {connections} connections, "
        f"{banks} banks, {auctions} auctioneers, {mail} mailboxes, {trainers} class trainers, "
        f"{routes} boat/zeppelin routes ({docks} docks, {transport_legs} legs)"
    )
    missing = sorted(
        {
            e["position"]["zone"]
            for e in load_json("wow-forever-innkeepers.json")
            if map_from_position(e["position"]) is None
        }
    )
    if missing:
        print("Inns without UiMap:", ", ".join(missing))


if __name__ == "__main__":
    main()
