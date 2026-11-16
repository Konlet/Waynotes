local _, ns = ...

-- Nav.lua: quick navigation to the nearest inn, bank, repair NPC, auction house,
-- mailbox, flight master or class trainer.
--
-- All destination lists come from Data/*.lua (generated from Forever JSON).
-- Nearest search scores every candidate in player-space HereBeDragons yards.

local PRESETS = {}

-- Merge Forever nav tables loaded from Data/*.lua.
do
    local function pushZone(kind, entry, extra)
        if type(entry) ~= "table" or type(entry.x) ~= "number" or type(entry.y) ~= "number" then
            return
        end
        local row = {
            kind = kind,
            faction = entry.faction,
            map = entry.map,
            x = entry.x,
            y = entry.y,
            name = entry.name,
            zone = entry.zone,
            forever = true,
            npc = entry.npc,
        }
        if type(extra) == "table" then
            for key, value in pairs(extra) do
                row[key] = value
            end
        end
        PRESETS[#PRESETS + 1] = row
    end

    local function mergeZoneTable(kind, list, extraKey)
        if type(list) ~= "table" then
            return
        end
        for index = 1, #list do
            local entry = list[index]
            local extra
            if extraKey and type(entry) == "table" then
                extra = { [extraKey] = entry[extraKey] }
            end
            pushZone(kind, entry, extra)
        end
    end

    mergeZoneTable("inn", ns.NavInnkeepers)
    mergeZoneTable("bank", ns.NavBanks)
    mergeZoneTable("repair", ns.NavRepairs)
    mergeZoneTable("auction", ns.NavAuctionHouses)
    mergeZoneTable("mail", ns.NavMailboxes)
    mergeZoneTable("trainer", ns.NavClassTrainers, "class")

    local flights = ns.NavFlightMasters
    if type(flights) == "table" then
        for index = 1, #flights do
            local entry = flights[index]
            if type(entry) == "table" and type(entry.wx) == "number" and type(entry.wy) == "number" and type(entry.instance) == "number" then
                PRESETS[#PRESETS + 1] = {
                    kind = "flight",
                    faction = entry.faction,
                    name = entry.name,
                    zone = entry.hub or entry.zone,
                    forever = true,
                    npc = entry.npc,
                    nodeId = entry.nodeId,
                    map = entry.map,
                    x = entry.x,
                    y = entry.y,
                    wx = entry.wx,
                    wy = entry.wy,
                    wz = entry.wz,
                    instance = entry.instance,
                }
            end
        end
    end

    local docks = ns.NavTransportDocks
    if type(docks) == "table" then
        for index = 1, #docks do
            local entry = docks[index]
            if type(entry) == "table" and type(entry.wx) == "number" and type(entry.wy) == "number" and type(entry.instance) == "number" then
                local kind = entry.type
                if kind ~= "boat" and kind ~= "zeppelin" and kind ~= "skycutter" then
                    kind = "transport"
                end
                PRESETS[#PRESETS + 1] = {
                    kind = kind,
                    faction = entry.faction,
                    name = entry.name,
                    zone = entry.zone,
                    forever = true,
                    dockId = entry.dockId,
                    routeId = entry.routeId,
                    routeName = entry.routeName,
                    wx = entry.wx,
                    wy = entry.wy,
                    wz = entry.wz,
                    instance = entry.instance,
                    map = entry.map,
                }
            end
        end
    end
end

local KIND_LABEL = {
    inn = "Inn",
    bank = "Bank",
    repair = "Repair",
    auction = "Auction House",
    mail = "Mailbox",
    flight = "Flight Master",
    trainer = "Class Trainer",
    boat = "Boat",
    zeppelin = "Zeppelin",
    skycutter = "Skycutter",
    transport = "Transport",
}

local TRAINER_CLASSES = {
    "Warrior",
    "Paladin",
    "Hunter",
    "Rogue",
    "Priest",
    "Shaman",
    "Mage",
    "Warlock",
    "Druid",
}

-- Scoring tiers (lower wins). Same-zone / same-continent finite yards must
-- always beat other-continent results. Unresolved pins are worst.
-- IMPORTANT: OTHER_CONTINENT must be >> any real same-continent distance, and
-- UNRESOLVED must be >> OTHER_CONTINENT so a failed Barrens convert never loses
-- to "Arathi is 1580 yd away" measured in the wrong continent space.
local FAR_AWAY = 1e15
local UNRESOLVED = 1e14
local OTHER_CONTINENT = 1e12

local target

ns.NavPresets = PRESETS
ns.NavKindLabel = KIND_LABEL
ns.NavTrainerClasses = TRAINER_CLASSES

-- Helpers

local function isNumber(value)
    return type(value) == "number"
end

local function playerFaction()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    if faction == "Horde" or faction == "Alliance" then
        return faction
    end
    return nil
end

local function playerClassName()
    if ns.PlayerClass then
        return ns.PlayerClass()
    end
    local _, token = UnitClass("player")
    if type(token) ~= "string" or token == "" then
        return nil
    end
    return token:sub(1, 1):upper() .. token:sub(2):lower()
end

local hbdCache

local function getHBD()
    if hbdCache then
        return hbdCache
    end
    if type(LibStub) ~= "function" then
        return nil
    end
    local ok, lib = pcall(LibStub, "HereBeDragons-2.0")
    if ok and type(lib) == "table" then
        hbdCache = lib
        return lib
    end
    return nil
end

local function worldPoint(map, x, y)
    if not isNumber(map) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local zx, zy = x, y
    -- Accept either percent (0-100) or fraction (0-1) zone coordinates.
    if zx > 1 or zy > 1 then
        zx, zy = zx / 100, zy / 100
    end

    local hbd = getHBD()
    if hbd and type(hbd.GetWorldCoordinatesFromZone) == "function" then
        local ok, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, zx, zy, map)
        if ok and isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end

    -- Fallback when HereBeDragons has no map data for this UiMap.
    if C_Map and C_Map.GetWorldPosFromMapPos then
        local vector
        if CreateVector2D then
            vector = CreateVector2D(zx, zy)
        else
            vector = { x = zx, y = zy }
        end
        local ok, continent, worldPos = pcall(C_Map.GetWorldPosFromMapPos, map, vector)
        if ok and type(worldPos) == "table" and isNumber(worldPos.x) and isNumber(worldPos.y) then
            return worldPos.x, worldPos.y, continent
        end
    end
    return nil
end

function ns.ZoneToWorld(map, x, y)
    return worldPoint(map, x, y)
end

local function zoneFromWorld(wx, wy, instance)
    local hbd = getHBD()
    if not hbd or not isNumber(wx) or not isNumber(wy) or not isNumber(instance) then
        return nil
    end
    if type(hbd.GetZoneCoordinatesFromWorld) ~= "function" then
        return nil
    end
    local ok, x, y, map = pcall(hbd.GetZoneCoordinatesFromWorld, hbd, wx, wy, instance, true)
    if not ok or not isNumber(x) or not isNumber(y) or not isNumber(map) then
        return nil
    end
    return map, x * 100, y * 100
end

-- Forever HBD continent ids may not match flight JSON mapId 0/1. Try a few.
local function zoneFromWorldAny(wx, wy, preferred)
    if not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    local tried = {}
    local function try(instance)
        if not isNumber(instance) or tried[instance] then
            return nil
        end
        tried[instance] = true
        return zoneFromWorld(wx, wy, instance)
    end
    local map, x, y = try(preferred)
    if map then
        return map, x, y
    end
    map, x, y = try(0)
    if map then
        return map, x, y
    end
    map, x, y = try(1)
    if map then
        return map, x, y
    end
    return nil
end

local function playerPoint()
    local hbd = getHBD()
    if hbd and type(hbd.GetPlayerWorldPosition) == "function" then
        local ok, wx, wy, instance = pcall(hbd.GetPlayerWorldPosition, hbd)
        if ok and isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end
    -- Forever: HBD player world is often nil outdoors. UnitPosition matches
    -- Forever flight / dock JSON coordinates.
    if type(UnitPosition) == "function" then
        local ok, posY, posX, _, instance = pcall(UnitPosition, "player")
        if ok and isNumber(posX) and isNumber(posY) then
            return posX, posY, instance
        end
    end
    return nil
end

local function playerZonePos()
    local hbd = getHBD()
    if hbd and type(hbd.GetPlayerZonePosition) == "function" then
        local ok, x, y, map = pcall(hbd.GetPlayerZonePosition, hbd, true)
        if ok and isNumber(x) and isNumber(y) and isNumber(map) then
            return x, y, map
        end
    end
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition then
        local map = C_Map.GetBestMapForUnit("player")
        if isNumber(map) then
            local ok, pos = pcall(C_Map.GetPlayerMapPosition, map, "player")
            if ok and type(pos) == "table" then
                local x = pos.GetXY and pos:GetXY() or pos.x
                local y = pos.GetXY and select(2, pos:GetXY()) or pos.y
                if isNumber(x) and isNumber(y) then
                    return x, y, map
                end
            end
        end
    end
    return nil
end

local function playerZoneName()
    if GetRealZoneText then
        local name = GetRealZoneText()
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    if GetZoneText then
        local name = GetZoneText()
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    return nil
end

local function toFraction(value)
    if not isNumber(value) then
        return nil
    end
    if value > 1 then
        return value / 100
    end
    return value
end

local function normalizeZoneName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    return name:lower():gsub("^the%s+", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function zonesMatch(a, b)
    local na = normalizeZoneName(a)
    local nb = normalizeZoneName(b)
    if not na or not nb then
        return false
    end
    if na == nb then
        return true
    end
    -- Forever sometimes reports a sub-area while presets keep the parent zone.
    if #na >= 4 and #nb >= 4 and (na:find(nb, 1, true) or nb:find(na, 1, true)) then
        return true
    end
    return false
end

-- Convert a zone pin into player-space world coords via HBD/C_Map.
local function pinWorld(map, x, y)
    return worldPoint(map, x, y)
end

-- Same-zone ranking when classic UiMap conversion fails on Forever. Absolute
-- yards are approximate; ranking only needs nearby pins to beat far ones.
-- scale defaults to outdoor (~4000); capitals should pass ~1200 via mapPercentScale.
local function zonePercentYards(pzx, pzy, dx, dy, scale)
    local SCALE = (isNumber(scale) and scale > 0) and scale or 4000
    local ex = (pzx - dx) * SCALE
    local ey = (pzy - dy) * SCALE
    return (ex * ex + ey * ey) ^ 0.5
end

-- Same convention as tracker step arrows: use the player's instance id.
local function worldDistance(hbd, instance, px, py, wx, wy)
    if not hbd or not isNumber(px) or not isNumber(wx) then
        return nil
    end
    if not isNumber(instance) then
        instance = 0
    end
    if type(hbd.GetWorldDistance) == "function" then
        local ok, yards = pcall(hbd.GetWorldDistance, hbd, instance, px, py, wx, wy)
        if ok and isNumber(yards) then
            return yards
        end
    end
    if type(hbd.GetWorldVector) == "function" then
        local ok, _, yards = pcall(hbd.GetWorldVector, hbd, instance, px, py, wx, wy)
        if ok and isNumber(yards) then
            return yards
        end
    end
    return nil
end

-- Classic Era UiMap labels. Forever's C_Map.GetMapInfo often returns nil for
-- these ids even while the player is standing in that zone under a new map id.
local CLASSIC_MAP_ZONE = {
    [1411] = "Durotar",
    [1412] = "Mulgore",
    [1413] = "The Barrens",
    [1417] = "Arathi Highlands",
    [1418] = "Badlands",
    [1419] = "Blasted Lands",
    [1420] = "Tirisfal Glades",
    [1421] = "Silverpine Forest",
    [1422] = "Western Plaguelands",
    [1423] = "Eastern Plaguelands",
    [1424] = "Hillsbrad Foothills",
    [1425] = "The Hinterlands",
    [1426] = "Dun Morogh",
    [1427] = "Searing Gorge",
    [1428] = "Burning Steppes",
    [1429] = "Elwynn Forest",
    [1430] = "Deadwind Pass",
    [1431] = "Duskwood",
    [1432] = "Loch Modan",
    [1433] = "Redridge Mountains",
    [1434] = "Stranglethorn Vale",
    [1435] = "Swamp of Sorrows",
    [1436] = "Westfall",
    [1437] = "Wetlands",
    [1438] = "Teldrassil",
    [1439] = "Darkshore",
    [1440] = "Ashenvale",
    [1441] = "Thousand Needles",
    [1442] = "Stonetalon Mountains",
    [1443] = "Desolace",
    [1444] = "Feralas",
    [1445] = "Dustwallow Marsh",
    [1446] = "Tanaris",
    [1447] = "Azshara",
    [1448] = "Felwood",
    [1449] = "Un'Goro Crater",
    [1450] = "Moonglade",
    [1451] = "Silithus",
    [1452] = "Winterspring",
    [1453] = "Stormwind City",
    [1454] = "Orgrimmar",
    [1455] = "Ironforge",
    [1456] = "Thunder Bluff",
    [1457] = "Darnassus",
    [1458] = "Undercity",
    [1416] = "Alterac Mountains",
}

-- Capitals are ~0.8-1.5k yd across. Outdoor zones use ~4000 as a last-resort
-- percent→yard guess; cities must not inherit that or Undercity reads 3-4x high.
local OUTDOOR_MAP_SCALE = 4000
local CITY_MAP_SCALE = 1200
local CITY_CLASSIC_MAPS = {
    [1453] = true,
    [1454] = true,
    [1455] = true,
    [1456] = true,
    [1457] = true,
    [1458] = true,
}

local function mapName(map)
    if not isNumber(map) then
        return nil
    end
    if C_Map and C_Map.GetMapInfo then
        local ok, info = pcall(C_Map.GetMapInfo, map)
        if ok and type(info) == "table" and type(info.name) == "string" and info.name ~= "" then
            return info.name
        end
    end
    return CLASSIC_MAP_ZONE[map]
end

function ns.MapZoneName(map)
    return mapName(map)
end

-- Guide pins use Classic UiMap ids, which Forever renumbers. Prefer the
-- Classic name table so the id is not looked up as a different Forever map.
function ns.ClassicZoneName(map)
    return CLASSIC_MAP_ZONE[map] or mapName(map)
end

function ns.ZoneNamesMatch(a, b)
    local na = normalizeZoneName(a)
    return na ~= nil and na == normalizeZoneName(b)
end

-- Forever remaps classic UiMap ids. Remember the live map while the player is
-- standing in a zone so other-zone pins can reuse that id later.
local liveMapByClassic = {}
local liveMapByZone = {}

local function rememberLiveMap(pmap, pzone)
    if not isNumber(pmap) then
        return
    end
    local zoneKey = normalizeZoneName(pzone)
    if zoneKey then
        liveMapByZone[zoneKey] = pmap
    end
    for classicId, name in pairs(CLASSIC_MAP_ZONE) do
        if zonesMatch(pzone, name) then
            liveMapByClassic[classicId] = pmap
        end
    end
end

-- Continent yards from C_Map.GetWorldPosFromMapPos .x/.y.
-- HereBeDragons reads GetXY() as (top, left) and returns (left, top). That pair
-- does not match UnitPosition, so cross-zone arrows and yards were wrong until
-- the pin shared the player's zone. .x/.y are one continent space for both.
local function cmapXY(worldPos)
    if type(worldPos) ~= "table" then
        return nil
    end
    if isNumber(worldPos.x) and isNumber(worldPos.y) then
        return worldPos.x, worldPos.y
    end
    if type(worldPos.GetXY) == "function" then
        local a, b = worldPos:GetXY()
        if isNumber(a) and isNumber(b) then
            return a, b
        end
    end
end

local function mapWorld(map, x, y)
    if not C_Map or not C_Map.GetWorldPosFromMapPos or not isNumber(map) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local zx, zy = toFraction(x), toFraction(y)
    if not isNumber(zx) or not isNumber(zy) then
        return nil
    end
    local vector
    if CreateVector2D then
        vector = CreateVector2D(zx, zy)
    else
        vector = { x = zx, y = zy }
    end
    local ok, continent, worldPos = pcall(C_Map.GetWorldPosFromMapPos, map, vector)
    if not ok then
        return nil
    end
    local wx, wy = cmapXY(worldPos)
    if not wx then
        return nil
    end
    return wx, wy, continent
end

local function pinMapsForWorld(map, zone)
    local list = {}
    local seen = {}
    local function add(id)
        if isNumber(id) and not seen[id] then
            seen[id] = true
            list[#list + 1] = id
        end
    end
    add(map)
    if isNumber(map) then
        add(liveMapByClassic[map])
    end
    local zoneKey = normalizeZoneName(zone or mapName(map))
    if zoneKey then
        add(liveMapByZone[zoneKey])
    end
    return list
end

local function mapPercentScale(map)
    if isNumber(map) then
        if CITY_CLASSIC_MAPS[map] then
            return CITY_MAP_SCALE
        end
        for classicId, liveId in pairs(liveMapByClassic) do
            if liveId == map and CITY_CLASSIC_MAPS[classicId] then
                return CITY_MAP_SCALE
            end
        end
        local key = normalizeZoneName(mapName(map))
        if key == "stormwind city" or key == "orgrimmar" or key == "ironforge"
            or key == "thunder bluff" or key == "darnassus" or key == "undercity" then
            return CITY_MAP_SCALE
        end
    end
    return OUTDOOR_MAP_SCALE
end

-- Same-zone yards from C_Map.GetWorldPosFromMapPos .x/.y (trusted continent space).
-- Prefer this over HBD / outdoor percent*4000 inside capitals.
local function sameZoneCMapDistance(map, x, y, zone)
    local pzx, pzy, pmap = playerZonePos()
    if not isNumber(pzx) or not isNumber(pmap) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local pzone = playerZoneName()
    local pinZone = zone or mapName(map)
    local sameZone = (isNumber(map) and map == pmap) or zonesMatch(pzone, pinZone)
    if not sameZone then
        return nil
    end
    rememberLiveMap(pmap, pzone)
    local pwx, pwy, pcont = mapWorld(pmap, pzx, pzy)
    if not pwx then
        return nil
    end
    local function distFrom(twx, twy, tcont)
        if not twx then
            return nil
        end
        if pcont and tcont and pcont ~= tcont then
            return nil
        end
        local dx = twx - pwx
        local dy = twy - pwy
        return (dx * dx + dy * dy) ^ 0.5
    end
    for _, pinMap in ipairs(pinMapsForWorld(map, pinZone)) do
        local dist = distFrom(mapWorld(pinMap, x, y))
        if dist then
            return dist
        end
    end
    -- Classic pin map may not convert on Forever; measure pin % on the live map.
    return distFrom(mapWorld(pmap, x, y))
end

-- Cross-zone vector in C_Map world space. Nil when the pin is already same-zone
-- (callers keep the zone-percent arrow) or when either map will not convert.
function ns.CrossZoneVector(map, x, y, zone)
    local pzx, pzy, pmap = playerZonePos()
    if not isNumber(pzx) or not isNumber(pmap) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local pzone = playerZoneName()
    local pinZone = zone or mapName(map)
    if (isNumber(map) and map == pmap) or zonesMatch(pzone, pinZone) then
        return nil
    end
    local pwx, pwy, pcont = mapWorld(pmap, pzx, pzy)
    if not pwx then
        return nil
    end
    local twx, twy, tcont
    for _, pinMap in ipairs(pinMapsForWorld(map, pinZone)) do
        twx, twy, tcont = mapWorld(pinMap, x, y)
        if twx then
            break
        end
    end
    if not twx then
        return nil
    end
    if isNumber(pcont) and isNumber(tcont) and pcont ~= tcont then
        return nil
    end
    local dx, dy = twx - pwx, twy - pwy
    local dist = (dx * dx + dy * dy) ^ 0.5

    local function axis(which)
        local amount = 0.02
        local sx, sy = pzx, pzy
        if which == "x" then
            if sx > 0.9 then
                amount = -0.02
            end
            sx = sx + amount
        else
            if sy > 0.9 then
                amount = -0.02
            end
            sy = sy + amount
        end
        local wx, wy = mapWorld(pmap, sx, sy)
        if not wx then
            return nil
        end
        return (wx - pwx) / amount, (wy - pwy) / amount
    end

    local east, south
    local ex, ey = axis("x")
    local sx, sy = axis("y")
    if ex and sx then
        local elen = ex * ex + ey * ey
        local slen = sx * sx + sy * sy
        if elen > 1 and slen > 1 then
            east = (dx * ex + dy * ey) / elen
            south = (dx * sx + dy * sy) / slen
        end
    end
    return {
        dist = dist,
        east = east,
        south = south,
    }
end

local mapConvertsCache = {}

local function mapConverts(map)
    if not isNumber(map) then
        return false
    end
    local cached = mapConvertsCache[map]
    if cached ~= nil then
        return cached
    end
    local wx = worldPoint(map, 0.5, 0.5)
    cached = wx ~= nil
    mapConvertsCache[map] = cached
    return cached
end

-- Prefer a map id that actually converts on this client (live Forever id over
-- classic Era id when the latter is inert).
local function resolvePinMap(map, zone)
    if isNumber(map) and mapConverts(map) then
        return map
    end
    if isNumber(map) and liveMapByClassic[map] then
        return liveMapByClassic[map]
    end
    local zoneKey = normalizeZoneName(zone or mapName(map))
    if zoneKey and liveMapByZone[zoneKey] then
        return liveMapByZone[zoneKey]
    end
    return map
end

-- Classic HereBeDragons builds map axes from GetWorldPosFromMapPos():GetXY()
-- assigned as (top, left). Zone→world X/Y then come out swapped against
-- UnitPosition. Standing on Kaltunk (Durotar 43.3, 68.5) that swap is ~5150 yd:
-- map world (-4252, -606) versus unit position (-607, -4251).
local AXIS_MATCH_YARDS = 1500

local function axesAreCrossed(map, zx, zy, px, py)
    if not isNumber(map) or not isNumber(zx) or not isNumber(zy) or not isNumber(px) or not isNumber(py) then
        return false
    end
    local mx, my = pinWorld(map, zx, zy)
    if not mx or not my then
        return false
    end
    local direct = (mx - px) * (mx - px) + (my - py) * (my - py)
    local crossed = (my - px) * (my - px) + (mx - py) * (mx - py)
    return crossed < direct and crossed < (AXIS_MATCH_YARDS * AXIS_MATCH_YARDS)
end

-- Forever outdoor maps: measure the UnitPosition ↔ map-world axis swap on the
-- player's LIVE map only. Cross-zone checks against the destination map fail
-- (projected player is thousands of yards from UnitPosition), so arrows and
-- distances stayed wrong until the player entered the pin's zone.
local function playerAxesCrossed(pmap, pzx, pzy, px, py)
    if not isNumber(pmap) or not isNumber(pzx) or not isNumber(pzy) or not isNumber(px) or not isNumber(py) then
        return false
    end
    return axesAreCrossed(pmap, pzx, pzy, px, py)
end

local function mapWorldToUnit(mx, my, crossed)
    if crossed then
        return my, mx
    end
    return mx, my
end

local function unitToMapWorld(ux, uy, crossed)
    if crossed then
        return uy, ux
    end
    return ux, uy
end

local function alignMapWorld(mx, my, map, zx, zy, px, py)
    if axesAreCrossed(map, zx, zy, px, py) then
        return my, mx
    end
    return mx, my
end

-- Forever: UnitPosition (player world) and UiMap zone→world can disagree by
-- an axis swap or a few hundred yards of origin. Build the waypoint in
-- UnitPosition space by applying the zone-space delta between the player and the pin.
local function pinWorldFromZoneDelta(map, pinX, pinY, pzx, pzy, px, py, pinstance, crossed)
    if not isNumber(map) or not isNumber(pinX) or not isNumber(pzx) or not isNumber(px) or not isNumber(py) then
        return nil
    end
    -- worldPoint accepts 0-1 or 0-100. Do not pre-multiply: a percent value
    -- times 100 is converted as thousands of percent and the delta explodes.
    local playerMx, playerMy = pinWorld(map, pzx, pzy)
    local pinMx, pinMy, pinInstance = pinWorld(map, pinX, pinY)
    if not playerMx or not pinMx then
        return nil
    end
    if crossed == nil then
        playerMx, playerMy = alignMapWorld(playerMx, playerMy, map, pzx, pzy, px, py)
        pinMx, pinMy = alignMapWorld(pinMx, pinMy, map, pzx, pzy, px, py)
        return px + (pinMx - playerMx), py + (pinMy - playerMy), pinstance or pinInstance
    end
    -- Explicit crossed flag: convert map-space delta into UnitPosition space.
    local dUx, dUy = mapWorldToUnit(pinMx - playerMx, pinMy - playerMy, crossed)
    return px + dUx, py + dUy, pinstance or pinInstance
end

-- When HBD cannot convert a map at all, approximate the pin in UnitPosition
-- space from zone-percent delta. Outdoor classic zones are ~3-6k yd across;
-- capitals use CITY_MAP_SCALE so Undercity does not inherit the outdoor guess.
local function pinWorldFromPercent(pzx, pzy, pinX, pinY, px, py, pinstance, map)
    local dx = toFraction(pinX)
    local dy = toFraction(pinY)
    pzx, pzy = toFraction(pzx), toFraction(pzy)
    if not isNumber(pzx) or not isNumber(pzy) or not isNumber(dx) or not isNumber(dy) or not isNumber(px) or not isNumber(py) then
        return nil
    end
    local SCALE = mapPercentScale(map)
    return px + (dx - pzx) * SCALE, py + (dy - pzy) * SCALE, pinstance
end

-- Convert a zone pin into UnitPosition-space world coords for arrow aiming.
-- Forever's UiMap zone→world origin often disagrees with UnitPosition; applying
-- the zone-space delta to the live player position keeps step/Go arrows honest.
function ns.PinToPlayerWorld(map, x, y, zone)
    if not isNumber(x) or not isNumber(y) then
        return nil
    end
    local px, py, pinstance = playerPoint()
    local pzx, pzy, pmap = playerZonePos()
    local pzone = playerZoneName()
    local hbd = getHBD()
    local pinZone = zone or mapName(map)
    rememberLiveMap(pmap, pzone)
    map = resolvePinMap(map, pinZone)

    local crossed = playerAxesCrossed(pmap, pzx, pzy, px, py)

    local function deltaOn(useMap, useX, useY)
        return pinWorldFromZoneDelta(useMap, x, y, useX, useY, px, py, pinstance, crossed)
    end

    local sameZone = (isNumber(map) and isNumber(pmap) and map == pmap)
        or zonesMatch(pzone, pinZone)

    if isNumber(px) and isNumber(pzx) then
        -- Live player map first. Classic pin.map often fails to convert on Forever
        -- even when the player is standing in that zone under a remapped UiMap.
        if sameZone and isNumber(pmap) then
            local wx, wy, instance = deltaOn(pmap, pzx, pzy)
            if wx then
                return wx, wy, instance
            end
            wx, wy, instance = pinWorldFromPercent(pzx, pzy, x, y, px, py, pinstance, pmap)
            if wx then
                return wx, wy, instance
            end
        end

        -- Other-zone: project the player onto the destination map in map-world
        -- space, then apply the pin delta back in UnitPosition space. Never reuse
        -- the player's zone percents on a different map.
        if not sameZone and isNumber(map) and hbd and type(hbd.GetZoneCoordinatesFromWorld) == "function" then
            local worldX, worldY = unitToMapWorld(px, py, crossed)
            local ok, zx, zy = pcall(hbd.GetZoneCoordinatesFromWorld, hbd, worldX, worldY, map, true)
            if ok and isNumber(zx) and isNumber(zy) then
                local wx, wy, instance = deltaOn(map, zx, zy)
                if wx then
                    return wx, wy, instance
                end
            end
        end

        if sameZone and isNumber(map) and map ~= pmap then
            local wx, wy, instance = deltaOn(map, pzx, pzy)
            if wx then
                return wx, wy, instance
            end
        end

        -- Classic map id will not convert on Forever: if zone names match (or the
        -- classic id is known for this zone), keep Forever percents on the live map.
        if sameZone and isNumber(pmap) then
            local abs = worldPoint(map, x, y)
            if not abs then
                local wx, wy, instance = deltaOn(pmap, pzx, pzy)
                if wx then
                    return wx, wy, instance
                end
                return pinWorldFromPercent(pzx, pzy, x, y, px, py, pinstance, pmap)
            end
        end
    end

    local mx, my, instance = worldPoint(map, x, y)
    if not mx then
        return nil
    end
    -- Always align absolute converts into UnitPosition space when we know the
    -- live-map axis relationship. Leaving raw map-world coords here was the
    -- cross-zone arrow/distance failure mode.
    local wx, wy = mapWorldToUnit(mx, my, crossed)
    return wx, wy, pinstance or instance
end

-- Zone yards for UI when a world waypoint cannot be built yet.
function ns.PinZoneDistance(map, x, y, zone)
    if not isNumber(x) or not isNumber(y) then
        return nil
    end
    local pzx, pzy, pmap = playerZonePos()
    local pzone = playerZoneName()
    local hbd = getHBD()
    local dx, dy = toFraction(x), toFraction(y)
    pzx, pzy = toFraction(pzx), toFraction(pzy)
    if not isNumber(pzx) or not isNumber(dx) then
        return nil
    end
    local pinZone = zone or mapName(map)
    local sameZone = (isNumber(map) and isNumber(pmap) and map == pmap) or zonesMatch(pzone, pinZone)
    if not sameZone then
        return nil
    end
    -- C_Map continent yards first. HBD city scales (and outdoor 4000) are wrong
    -- in capitals like Undercity.
    local cmapDist = sameZoneCMapDistance(map, x, y, pinZone)
    if isNumber(cmapDist) then
        return cmapDist
    end
    if hbd and isNumber(pmap) and type(hbd.GetZoneDistance) == "function" then
        local ok, dist = pcall(hbd.GetZoneDistance, hbd, pmap, pzx, pzy, pmap, dx, dy)
        if ok and isNumber(dist) then
            return dist
        end
    end
    -- Prefer live-map size over a flat outdoor guess when HBD can convert corners.
    if hbd and isNumber(pmap) and type(hbd.GetWorldCoordinatesFromZone) == "function" then
        local ok0, wx0, wy0, inst0 = pcall(hbd.GetWorldCoordinatesFromZone, hbd, 0, 0, pmap)
        local ok1, wx1, wy1, inst1 = pcall(hbd.GetWorldCoordinatesFromZone, hbd, 1, 1, pmap)
        if ok0 and ok1 and isNumber(wx0) and isNumber(wx1) and inst0 == inst1 then
            local scaleX = math.abs(wx1 - wx0)
            local scaleY = math.abs(wy1 - wy0)
            if scaleX > 1 and scaleY > 1 then
                local ex = (dx - pzx) * scaleX
                local ey = (dy - pzy) * scaleY
                return (ex * ex + ey * ey) ^ 0.5
            end
        end
    end
    return zonePercentYards(pzx, pzy, dx, dy, mapPercentScale(pmap or map))
end

-- Prefer a UnitPosition-relative waypoint when possible; otherwise the closest
-- axis-aligned zone→world conversion.
local function closestPinWorld(pin, pmap, pzx, pzy, px, py, pinstance)
    if type(pin) ~= "table" or not isNumber(pin.x) or not isNumber(pin.y) then
        return nil
    end

    local crossed = playerAxesCrossed(pmap, pzx, pzy, px, py)

    if isNumber(pmap) and isNumber(pzx) and isNumber(px) then
        local wx, wy, instance = pinWorldFromZoneDelta(pmap, pin.x, pin.y, pzx, pzy, px, py, pinstance, crossed)
        if wx then
            local dist = worldDistance(getHBD(), pinstance, px, py, wx, wy)
            return wx, wy, instance or pinstance, dist
        end
    end

    local bestWx, bestWy, bestInstance, bestDist
    local function consider(map)
        if not isNumber(map) then
            return
        end
        local mx, my, instance = pinWorld(map, pin.x, pin.y)
        if not mx then
            return
        end
        local wx, wy = mapWorldToUnit(mx, my, crossed)
        local dist = isNumber(px) and worldDistance(getHBD(), pinstance, px, py, wx, wy) or nil
        if not bestWx or (isNumber(dist) and (not isNumber(bestDist) or dist < bestDist)) then
            bestWx, bestWy, bestInstance, bestDist = wx, wy, instance or pinstance, dist
        end
    end
    consider(pmap)
    if isNumber(pin.map) and pin.map ~= pmap then
        consider(pin.map)
    end
    return bestWx, bestWy, bestInstance, bestDist
end

-- Prefer same-zone scoring first. Forever often fails classic Barrens UiMap
-- 1413 conversion for ranking, and classic world converts can be 500+ yd off.
local function pinDistance(hbd, pzx, pzy, pmap, pzone, pin, px, py, pinstance)
    if type(pin) ~= "table" then
        return nil, nil, nil, nil
    end

    local dx = toFraction(pin.x)
    local dy = toFraction(pin.y)
    local wx, wy, instance

    local sameZone = (isNumber(pin.map) and isNumber(pmap) and pin.map == pmap)
        or zonesMatch(pzone, pin.zone)

    -- Same zone: measure on the player's live map with Forever percents.
    if sameZone and isNumber(dx) and isNumber(dy) and isNumber(pzx) and isNumber(pmap) then
        local zoneDist = sameZoneCMapDistance(pin.map, pin.x, pin.y, pin.zone)
        if not zoneDist and hbd and type(hbd.GetZoneDistance) == "function" then
            local ok, yards = pcall(hbd.GetZoneDistance, hbd, pmap, pzx, pzy, pmap, dx, dy)
            if ok and isNumber(yards) then
                zoneDist = yards
            end
        end
        if not zoneDist then
            zoneDist = zonePercentYards(pzx, pzy, dx, dy, mapPercentScale(pmap or pin.map))
        end

        local worldDist
        wx, wy, instance, worldDist = closestPinWorld(pin, pmap, pzx, pzy, px, py, pinstance)
        -- Prefer C_Map / zone yards in cities; UnitPosition-relative HBD deltas
        -- can still inherit a bad map scale there.
        local dist = zoneDist or worldDist
        if dist then
            return dist, wx, wy, instance or pinstance
        end
    end

    -- Cross-map zone distance only when HBD can convert both ends (same continent).
    if hbd and isNumber(pmap) and isNumber(pzx) and isNumber(dx) and isNumber(pin.map) and type(hbd.GetZoneDistance) == "function" then
        local ok, dist = pcall(hbd.GetZoneDistance, hbd, pmap, pzx, pzy, pin.map, dx, dy)
        if ok and isNumber(dist) then
            wx, wy, instance = closestPinWorld(pin, pmap, pzx, pzy, px, py, pinstance)
            if not wx then
                wx, wy, instance = pinWorld(pin.map, pin.x, pin.y)
            end
            return dist, wx, wy, instance
        end
    end

    -- World-space fallback only when conversion works.
    if isNumber(pin.map) and isNumber(pin.x) then
        wx, wy, instance = closestPinWorld(pin, pmap, pzx, pzy, px, py, pinstance)
        if not wx then
            wx, wy, instance = pinWorld(pin.map, pin.x, pin.y)
        end
    elseif isNumber(pin.wx) then
        wx, wy, instance = pin.wx, pin.wy, pin.instance
    end
    if wx and px and hbd then
        local dist = worldDistance(hbd, pinstance, px, py, wx, wy)
        if dist then
            -- Missing instance metadata: treat as other-continent so it cannot
            -- beat a same-zone neighbor that only has percent scoring.
            if not isNumber(instance) or not isNumber(pinstance) or instance ~= pinstance then
                return OTHER_CONTINENT + dist, wx, wy, instance
            end
            return dist, wx, wy, instance
        end
    end

    return nil, wx, wy, instance
end

-- Build comparable candidate pins for an entry (Questie spawns, zone percents,
-- or flight world coords converted into a zone pin).
local function candidatePins(entry, pinstance)
    local pins = {}

    -- Forever inn/flight presets already store Forever zone percents. Questie
    -- classic spawns disagree with that layout and produce huge yard errors.
    local allowQuestie = not entry.forever

    if allowQuestie and entry.npc and ns.NpcSpawns then
        local ok, spawns = pcall(ns.NpcSpawns, entry.npc)
        if ok and type(spawns) == "table" then
            for index = 1, #spawns do
                local pin = spawns[index]
                if type(pin) == "table" and isNumber(pin.map) and isNumber(pin.x) and isNumber(pin.y) then
                    pins[#pins + 1] = {
                        map = pin.map,
                        x = pin.x,
                        y = pin.y,
                        zone = pin.zone or entry.zone,
                        source = "questie",
                    }
                end
            end
        end
    end

    if allowQuestie and #pins == 0 and entry.npc and ns.NpcPin then
        local ok, pin = pcall(ns.NpcPin, entry.npc)
        if ok and type(pin) == "table" and isNumber(pin.map) and isNumber(pin.x) and isNumber(pin.y) then
            pins[#pins + 1] = {
                map = pin.map,
                x = pin.x,
                y = pin.y,
                zone = pin.zone or entry.zone,
                source = "questie",
            }
        end
    end

    if isNumber(entry.map) and isNumber(entry.x) and isNumber(entry.y) then
        local x, y = entry.x, entry.y
        if not entry.forever and ns.IsForever and ns.IsForever() and LibQuestieDB and type(LibQuestieDB.EraToForeverByUiMapId) == "function" then
            local ok, nx, ny = pcall(LibQuestieDB.EraToForeverByUiMapId, entry.map, x, y)
            if ok and isNumber(nx) and isNumber(ny) then
                x, y = nx, ny
            end
        end
        pins[#pins + 1] = {
            map = entry.map,
            x = x,
            y = y,
            zone = entry.zone,
            source = "preset",
        }
    end

    if isNumber(entry.wx) and isNumber(entry.wy) then
        local map, x, y = zoneFromWorldAny(entry.wx, entry.wy, pinstance or entry.instance)
        if map then
            pins[#pins + 1] = {
                map = map,
                x = x,
                y = y,
                zone = entry.zone,
                source = "flight-world",
                wx = entry.wx,
                wy = entry.wy,
                instance = entry.instance,
            }
        else
            -- Last resort: keep raw world coords tagged so scoring can still
            -- compare flight masters against each other on the same continent.
            pins[#pins + 1] = {
                zone = entry.zone,
                source = "flight-raw",
                wx = entry.wx,
                wy = entry.wy,
                instance = entry.instance,
            }
        end
    end

    return pins
end

-- Resolve a candidate pin into player-space world coords for distance/aiming.
local function candidateWorld(pin, pinstance)
    if type(pin) ~= "table" then
        return nil
    end
    if isNumber(pin.map) and isNumber(pin.x) and isNumber(pin.y) then
        local wx, wy, instance = pinWorld(pin.map, pin.x, pin.y)
        if wx then
            return wx, wy, instance or pinstance, pin
        end
    end
    if isNumber(pin.wx) and isNumber(pin.wy) then
        return pin.wx, pin.wy, pin.instance or pinstance, pin
    end
    return nil
end

local function resolveFlightZonePin(dest)
    if type(dest) ~= "table" then
        return dest
    end
    if isNumber(dest.map) and isNumber(dest.x) and isNumber(dest.y) then
        dest._pinResolved = true
        return dest
    end
    -- Avoid repeating Questie / HBD world→zone work every strip pulse.
    if dest._pinResolved then
        return dest
    end
    dest._pinResolved = true
    -- NPC spawn pins (Questie / Forever) beat world→zone conversion for aiming.
    if dest.npc and ns.NpcPin then
        local ok, pin = pcall(ns.NpcPin, dest.npc)
        if ok and type(pin) == "table" and isNumber(pin.map) and isNumber(pin.x) and isNumber(pin.y) then
            dest.map, dest.x, dest.y = pin.map, pin.x, pin.y
            if type(pin.zone) == "string" and pin.zone ~= "" then
                dest.zone = pin.zone
            end
            return dest
        end
    end
    if isNumber(dest.wx) and isNumber(dest.wy) then
        local map, x, y = zoneFromWorldAny(dest.wx, dest.wy, dest.instance)
        if map then
            dest.map, dest.x, dest.y = map, x, y
        end
    end
    return dest
end

-- Fill map/x/y on flight/dock targets so tracker arrows aim in UnitPosition space.
function ns.NavResolveTargetPin(dest)
    return resolveFlightZonePin(dest)
end

local function destWorld(dest)
    if type(dest) ~= "table" then
        return nil
    end
    -- Flight / dock JSON wx/wy are Forever map-world. Convert to a zone pin and
    -- aim through PinToPlayerWorld so the arrow matches UnitPosition space.
    resolveFlightZonePin(dest)
    -- Prefer UnitPosition-aligned coords so NavDistance / NavFacing match tracker arrows.
    if isNumber(dest.map) and isNumber(dest.x) and isNumber(dest.y) then
        local wx, wy, instance = ns.PinToPlayerWorld(dest.map, dest.x, dest.y, dest.zone)
        if wx then
            dest.waypoint = { wx = wx, wy = wy, instance = instance }
            return wx, wy, instance
        end
    end
    if type(dest.waypoint) == "table" and isNumber(dest.waypoint.wx) and isNumber(dest.waypoint.wy) then
        return dest.waypoint.wx, dest.waypoint.wy, dest.waypoint.instance
    end
    if isNumber(dest.wx) and isNumber(dest.wy) then
        -- Last resort: axis-align map-world JSON into UnitPosition space.
        local px, py = playerPoint()
        local wx, wy = dest.wx, dest.wy
        if isNumber(px) and isNumber(py) then
            local direct = (px - wx) * (px - wx) + (py - wy) * (py - wy)
            local swapped = (px - wy) * (px - wy) + (py - wx) * (py - wx)
            if swapped + 100 < direct then
                wx, wy = dest.wy, dest.wx
            end
        end
        dest.waypoint = { wx = wx, wy = wy, instance = dest.instance }
        return wx, wy, dest.instance
    end
    return nil
end

local function copyResolved(entry, pin, wx, wy, instance)
    local dest = {}
    for key, value in pairs(entry) do
        dest[key] = value
    end
    if type(pin) == "table" then
        dest.map = pin.map
        dest.x = pin.x
        dest.y = pin.y
        if pin.zone then
            dest.zone = pin.zone
        end
    end
    if wx then
        dest.waypoint = { wx = wx, wy = wy, instance = instance }
    else
        dest.waypoint = nil
    end
    return dest
end

-- Public API: target state

local function notifyChanged()
    if ns.NavOnTargetChanged then
        ns.NavOnTargetChanged(target)
    end
end

function ns.NavTarget()
    return target
end

function ns.NavSetTarget(dest)
    if type(dest) ~= "table" then
        return ns.NavClearTarget()
    end
    target = dest
    notifyChanged()
end

function ns.NavClearTarget()
    target = nil
    notifyChanged()
end

-- Public API: search

function ns.NavFindNearest(kind, className)
    local faction = playerFaction()
    if kind == "trainer" and (type(className) ~= "string" or className == "") then
        className = playerClassName()
    end

    local px, py, pinstance = playerPoint()
    local pzx, pzy, pmap = playerZonePos()
    local pzone = playerZoneName()
    local hbd = getHBD()

    local best, bestScore
    for index, entry in ipairs(PRESETS) do
        local matches = entry.kind == kind
        -- nil faction means usable by both (neutral inns / flight hubs).
        -- nil / "Both" means usable by either faction.
        if matches and faction and entry.faction and entry.faction ~= "Both" and entry.faction ~= faction then
            matches = false
        end
        if matches and kind == "trainer" and entry.class ~= className then
            matches = false
        end
        if matches then
            local pins = candidatePins(entry, pinstance)
            if #pins == 0 then
                local score = FAR_AWAY + index
                if not bestScore or score < bestScore then
                    bestScore = score
                    best = copyResolved(entry, nil, nil, nil, nil)
                end
            else
                for pinIndex = 1, #pins do
                    local pin = pins[pinIndex]
                    local score = UNRESOLVED + index + pinIndex * 0.001
                    local dist, wx, wy, instance = pinDistance(hbd, pzx, pzy, pmap, pzone, pin, px, py, pinstance)
                    if isNumber(dist) then
                        score = dist
                    elseif not px and not pzx then
                        score = index + pinIndex * 0.001
                    end
                    if not bestScore or score < bestScore then
                        bestScore = score
                        best = copyResolved(entry, pin, wx, wy, instance or pinstance)
                    end
                end
            end
        end
    end
    return best
end

function ns.NavChoose(kind, className)
    local dest = ns.NavFindNearest(kind, className)
    if not dest then
        local label = KIND_LABEL[kind] or "destination"
        if kind == "trainer" and className and className ~= "" then
            label = className .. " Trainer"
        end
        if UIErrorsFrame and UIErrorsFrame.AddMessage then
            UIErrorsFrame:AddMessage("No " .. label .. " found for your faction.", 1, 0.1, 0.1, 1)
        end
        return nil
    end
    ns.NavSetTarget(dest)
    return dest
end

-- Public API: formatting and measurement

function ns.NavFormatCoords(dest)
    if type(dest) ~= "table" or not isNumber(dest.x) or not isNumber(dest.y) then
        return ""
    end
    return string.format("%.1f, %.1f", dest.x, dest.y)
end

function ns.NavFormatYards(dist)
    if not isNumber(dist) then
        return ""
    end
    if dist >= 1000 then
        return string.format("%.1fk yd", dist / 1000)
    end
    return string.format("%d yd", math.floor(dist + 0.5))
end

-- Returns distance in yards, or nil when the player / destination world point
-- cannot be resolved. Continent ids on the destination are ignored; measurement
-- always uses the player's HereBeDragons instance like tracker step arrows.
function ns.NavDistance(dest)
    if type(dest) ~= "table" then
        return nil
    end
    if isNumber(dest.x) and isNumber(dest.y) then
        local cross = ns.CrossZoneVector(dest.map, dest.x, dest.y, dest.zone)
        if cross and isNumber(cross.dist) then
            return cross.dist
        end
        -- Same-zone (CrossZoneVector is nil): use C_Map / PinZoneDistance so
        -- city yards match the tracker instead of HBD outdoor scales.
        local zoneDist = ns.PinZoneDistance(dest.map, dest.x, dest.y, dest.zone)
        if isNumber(zoneDist) then
            return zoneDist
        end
    end
    local hbd = getHBD()
    local px, py, pinstance = playerPoint()
    if not hbd or not px then
        return nil
    end
    local wx, wy = destWorld(dest)
    if not wx then
        return nil
    end
    return worldDistance(hbd, pinstance, px, py, wx, wy)
end

-- Returns relative facing angle (tracker step-arrow convention) and distance.
-- Distance is still returned when GetPlayerFacing is unavailable so the strip
-- can show yards even if the arrow cannot rotate yet.
function ns.NavFacing(dest)
    if type(dest) ~= "table" then
        return nil
    end
    local hbd = getHBD()
    local px, py, pinstance = playerPoint()
    if not hbd or not px or type(hbd.GetWorldVector) ~= "function" then
        return nil
    end
    local wx, wy = destWorld(dest)
    if not wx then
        return nil
    end
    local ok, angle, dist = pcall(hbd.GetWorldVector, hbd, pinstance or 0, px, py, wx, wy)
    if not ok or not isNumber(angle) then
        return nil
    end
    -- Prefer same-zone C_Map yards for the label; keep HBD angle for aiming.
    if isNumber(dest.x) and isNumber(dest.y) then
        local zoneDist = ns.PinZoneDistance(dest.map, dest.x, dest.y, dest.zone)
        if isNumber(zoneDist) then
            dist = zoneDist
        else
            local cross = ns.CrossZoneVector(dest.map, dest.x, dest.y, dest.zone)
            if cross and isNumber(cross.dist) then
                dist = cross.dist
            end
        end
    end
    local facing = GetPlayerFacing and GetPlayerFacing() or nil
    if not isNumber(facing) then
        return nil, dist
    end
    return angle - facing, dist
end

-- Dropdown menu

local MENU_WIDTH = 168
local SUB_WIDTH = 150
local ROW_HEIGHT = 20
local PAD = 4

local catcher
local menu
local subMenu
local menuRows = {}
local subRows = {}
local trainerRow

local function styleNavFrame(frame)
    if ns.StylePopupFrame then
        ns.StylePopupFrame(frame)
        return
    end
    frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    local panelR, panelG, panelB = 0.04, 0.04, 0.04
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    local background = 0.94
    if ns.Color then
        panelR, panelG, panelB = ns.Color("background")
        edgeR, edgeG, edgeB = ns.Color("accent")
    end
    if ns.db and type(ns.db.trackerBackground) == "number" and ns.db.trackerBackground > background then
        background = ns.db.trackerBackground
    end
    frame:SetBackdropColor(panelR, panelG, panelB, background)
    frame:SetBackdropBorderColor(edgeR, edgeG, edgeB, 0.9)
end

local function hideMenus()
    if subMenu then
        subMenu:Hide()
    end
    if menu then
        menu:Hide()
    end
end

local function acquireRow(parent, rows, index)
    local row = rows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.label:SetPoint("LEFT", 8, 0)
    row.label:SetPoint("RIGHT", -8, 0)
    row.label:SetJustifyH("LEFT")
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    rows[index] = row
    return row
end

local function placeRow(row, parent, offset)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -(PAD + offset))
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -(PAD + offset))
    row:Show()
end

local function chooseAndClose(kind, className)
    hideMenus()
    ns.NavChoose(kind, className)
end

local function presentSubMenu()
    local entries = {}
    local mine = playerClassName()
    if mine then
        entries[#entries + 1] = { text = "My class (" .. mine .. ")", class = mine, mine = true }
    end
    for _, className in ipairs(TRAINER_CLASSES) do
        entries[#entries + 1] = { text = className, class = className }
    end

    for index, entry in ipairs(entries) do
        local row = acquireRow(subMenu, subRows, index)
        row.label:SetText(entry.text)
        if entry.mine and ns.Color then
            local r, g, b = ns.Color("accent")
            row.label:SetTextColor(r, g, b)
        else
            row.label:SetTextColor(1, 1, 1)
        end
        row.className = entry.class
        row:SetScript("OnClick", function(self)
            chooseAndClose("trainer", self.className)
        end)
        placeRow(row, subMenu, (index - 1) * ROW_HEIGHT)
    end
    for extra = #entries + 1, #subRows do
        subRows[extra]:Hide()
        subRows[extra].className = nil
    end
    subMenu:SetHeight(#entries * ROW_HEIGHT + PAD * 2)
    styleNavFrame(subMenu)
end

local function openSubMenu()
    if not trainerRow then
        return
    end
    presentSubMenu()
    subMenu:ClearAllPoints()
    subMenu:SetPoint("TOPLEFT", trainerRow, "TOPRIGHT", PAD + 2, PAD)
    subMenu:Show()
end

local function presentMenu()
    local items = {
        { text = KIND_LABEL.inn, kind = "inn" },
        { text = KIND_LABEL.bank, kind = "bank" },
        { text = KIND_LABEL.repair, kind = "repair" },
        { text = KIND_LABEL.auction, kind = "auction" },
        { text = KIND_LABEL.mail, kind = "mail" },
        { text = KIND_LABEL.flight, kind = "flight" },
        { text = KIND_LABEL.boat, kind = "boat" },
        { text = KIND_LABEL.zeppelin, kind = "zeppelin" },
        { text = "Class Trainers  >", submenu = true },
    }
    if target then
        items[#items + 1] = { text = "Clear destination", clear = true }
    end

    trainerRow = nil
    for index, item in ipairs(items) do
        local row = acquireRow(menu, menuRows, index)
        row.label:SetText(item.text)
        if item.clear then
            row.label:SetTextColor(1, 0.5, 0.5)
        else
            row.label:SetTextColor(1, 1, 1)
        end
        if item.submenu then
            trainerRow = row
            row:SetScript("OnEnter", openSubMenu)
            row:SetScript("OnClick", openSubMenu)
        else
            row:SetScript("OnEnter", function()
                if subMenu then
                    subMenu:Hide()
                end
            end)
            row:SetScript("OnClick", function()
                hideMenus()
                if item.clear then
                    ns.NavClearTarget()
                else
                    ns.NavChoose(item.kind)
                end
            end)
        end
        placeRow(row, menu, (index - 1) * ROW_HEIGHT)
    end
    for extra = #items + 1, #menuRows do
        menuRows[extra]:Hide()
        menuRows[extra]:SetScript("OnEnter", nil)
        menuRows[extra]:SetScript("OnClick", nil)
    end
    menu:SetSize(MENU_WIDTH, #items * ROW_HEIGHT + PAD * 2)
    styleNavFrame(menu)
end

local function buildMenu()
    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints()
    catcher:SetFrameStrata("DIALOG")
    catcher:SetFrameLevel(1)
    catcher:Hide()
    catcher:RegisterForClicks("AnyUp")
    catcher:SetScript("OnClick", hideMenus)

    menu = CreateFrame("Frame", "WaynotesNavMenu", UIParent, "BackdropTemplate")
    menu:SetSize(MENU_WIDTH, 80)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(20)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:Hide()
    menu:SetScript("OnShow", function(self)
        catcher:Show()
        styleNavFrame(self)
    end)
    menu:SetScript("OnHide", function()
        catcher:Hide()
        if subMenu then
            subMenu:Hide()
        end
    end)

    subMenu = CreateFrame("Frame", "WaynotesNavSubMenu", UIParent, "BackdropTemplate")
    subMenu:SetSize(SUB_WIDTH, 80)
    subMenu:SetFrameStrata("DIALOG")
    subMenu:SetFrameLevel(30)
    subMenu:SetClampedToScreen(true)
    subMenu:EnableMouse(true)
    subMenu:Hide()
    subMenu:SetScript("OnShow", function(self)
        styleNavFrame(self)
    end)
end

buildMenu()

function ns.HideNavMenu()
    hideMenus()
end

function ns.ToggleNavMenu(anchor)
    if menu:IsShown() then
        hideMenus()
        return
    end
    if ns.HideGuideMenu then
        ns.HideGuideMenu()
    end
    anchor = anchor or UIParent
    presentMenu()
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -2)
    menu:Show()
end

-- Clear the nav strip when the player opens a dialogue with its target NPC.
local function unitNpcId(unit)
    if not UnitGUID then
        return nil
    end
    local guid = UnitGUID(unit)
    if type(guid) ~= "string" or guid == "" then
        return nil
    end
    local id = select(6, strsplit("-", guid))
    return tonumber(id)
end

local function unitMatchesDest(unit, dest)
    if type(dest) ~= "table" or not UnitExists or not UnitExists(unit) then
        return false
    end
    local npcId = tonumber(dest.npc)
    if npcId then
        local id = unitNpcId(unit)
        if id and id == npcId then
            return true
        end
    end
    if type(dest.name) == "string" and dest.name ~= "" and UnitName then
        local name = UnitName(unit)
        if name and name == dest.name then
            return true
        end
    end
    return false
end

function ns.NavClearIfSpeakingToTarget()
    local dest = target
    if type(dest) ~= "table" then
        return false
    end
    if unitMatchesDest("npc", dest) or unitMatchesDest("target", dest) then
        ns.NavClearTarget()
        return true
    end
    return false
end

do
    local watcher = CreateFrame("Frame")
    local events = {
        "GOSSIP_SHOW",
        "MERCHANT_SHOW",
        "TRAINER_SHOW",
        "BANKFRAME_OPENED",
        "MAIL_SHOW",
        "AUCTION_HOUSE_SHOW",
        "TAXIMAP_OPENED",
        "QUEST_DETAIL",
        "QUEST_GREETING",
        "QUEST_PROGRESS",
        "QUEST_COMPLETE",
    }
    for index = 1, #events do
        pcall(watcher.RegisterEvent, watcher, events[index])
    end
    watcher:SetScript("OnEvent", function(_, event)
        if event == "TRAINER_SHOW" and IsTradeskillTrainer and IsTradeskillTrainer() then
            return
        end
        ns.NavClearIfSpeakingToTarget()
    end)
end
