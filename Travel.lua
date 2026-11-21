local _, ns = ...

-- Travel.lua: pick the best next hop for guide steps using walk cost,
-- unlocked flight paths (NavFlightConnections), boats/zeppelins
-- (NavTransportDocks / NavTransportLegs), and hearthstone location.
-- Applies to travel wording and general steps with a resolvable destination.

local RUN_YARDS_PER_SEC = 10
local FLY_BOARD_SECONDS = 12
local TRANSPORT_BOARD_SECONDS = 8
local HEARTH_SECONDS = 15
local MIN_IMPROVE_SECONDS = 25
local NEAR_YARDS = 80
local TRAVEL_ARRIVE_YARDS = 10
-- Bind must be closer than this before we even consider a soft hearth tip.
-- Cast time alone is ~HEARTH_SECONDS * RUN_YARDS_PER_SEC yards of walking.
local HEARTH_CLOSER_YARDS = (HEARTH_SECONDS * RUN_YARDS_PER_SEC) + 50
local HEARTHSTONE_ITEM = 6948
local hearthButton

local nodesById
local edgesByFrom
local docksById
local transportLegsByFrom
local placeIndex
local aliasIndex
local graphBuilt = false
local innsNeedCoords = false
local ensureGraph
-- Poll-scoped caches: GuideObjectives calls TravelApplyToItem once per shown
-- step, and without these each sticky re-ran full flight/boat routing.
local unlockedCache
local unlockedCacheGen = 0
local flightUnlockGen = 0
local routeCache = {}
local routeCacheGen = 0
local nearbyHintCache
local nearbyHintChecked = false
-- Coarse grid so walking does not invalidate BestPath every few seconds.
local ROUTE_GRID_YARDS = 200

local function isNumber(value)
    return type(value) == "number"
end

local function charDB()
    if type(WaynotesCharDB) ~= "table" then
        if type(RestedXPBetterCharDB) == "table" then
            WaynotesCharDB = RestedXPBetterCharDB
        else
            WaynotesCharDB = {}
        end
    end
    if type(WaynotesCharDB.flightPaths) ~= "table" then
        WaynotesCharDB.flightPaths = {}
    end
    return WaynotesCharDB
end

local function playerFaction()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    if faction == "Horde" or faction == "Alliance" then
        return faction
    end
end

local function factionUsable(entryFaction, playerFac)
    if not playerFac or not entryFaction or entryFaction == "Both" then
        return true
    end
    return entryFaction == playerFac
end

local function normalizeName(name)
    if type(name) ~= "string" then
        return nil
    end
    name = name:lower()
    name = name:gsub("^the%s+", "")
    name = name:gsub("[%'%`]", "")
    name = name:gsub("%s+", " ")
    name = strtrim(name)
    if name == "" then
        return nil
    end
    return name
end

local function addAlias(index, name, place)
    local key = normalizeName(name)
    if not key or type(place) ~= "table" then
        return
    end
    if not index[key] then
        index[key] = place
    end
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
end

local function euclidean(ax, ay, bx, by)
    if not isNumber(ax) or not isNumber(ay) or not isNumber(bx) or not isNumber(by) then
        return nil
    end
    local dx, dy = ax - bx, ay - by
    return math.sqrt(dx * dx + dy * dy)
end

-- Forever flight JSON is map-world. UnitPosition is often axis-swapped against
-- that space. Discover the orientation once, then reuse it — scanning every
-- pad on each travel/fly-rec pulse hitchs the client.
local flightAxisSwapped -- nil unknown, true/false once confident (HBD path)
local unitPosUseAB -- nil unknown; true → UnitPosition (a,b), false → (b,a)
local playerPointCache = { at = -1 }

-- Single pass: pick (wx,wy) vs (wy,wx) by nearest flight pad.
-- Returns alignedX, alignedY, swapped, bestDirect, bestSwap.
local function scoreFlightAxis(wx, wy)
    if ensureGraph then
        ensureGraph()
    end
    if not isNumber(wx) or not isNumber(wy) or not nodesById then
        return wx, wy, false, nil, nil
    end
    local faction = playerFaction()
    local bestDirect, bestSwap
    for _, node in pairs(nodesById) do
        if factionUsable(node.faction, faction) and isNumber(node.wx) then
            local direct = euclidean(wx, wy, node.wx, node.wy)
            local swapped = euclidean(wy, wx, node.wx, node.wy)
            if direct and (not bestDirect or direct < bestDirect) then
                bestDirect = direct
            end
            if swapped and (not bestSwap or swapped < bestSwap) then
                bestSwap = swapped
            end
        end
    end
    local swap = false
    if bestSwap and bestDirect and bestSwap + 5 < bestDirect then
        swap = true
    elseif bestSwap and (not bestDirect or bestDirect > 500) and bestSwap < 200 then
        swap = true
    end
    if swap then
        return wy, wx, true, bestDirect, bestSwap
    end
    return wx, wy, false, bestDirect, bestSwap
end

local function lockFlightAxis(swapped, fitDirect, fitSwap)
    if flightAxisSwapped ~= nil then
        return
    end
    if isNumber(fitDirect) and isNumber(fitSwap) then
        if fitSwap + 5 < fitDirect then
            flightAxisSwapped = true
        elseif fitDirect + 5 < fitSwap then
            flightAxisSwapped = false
        else
            flightAxisSwapped = swapped and true or false
        end
        return
    end
    if isNumber(fitDirect) then
        flightAxisSwapped = false
    elseif isNumber(fitSwap) then
        flightAxisSwapped = true
    end
end

local function alignToFlightWorld(wx, wy)
    if flightAxisSwapped == true then
        return wy, wx, true
    end
    if flightAxisSwapped == false then
        return wx, wy, false
    end
    local ax, ay, swapped, fitDirect, fitSwap = scoreFlightAxis(wx, wy)
    lockFlightAxis(swapped, fitDirect, fitSwap)
    return ax, ay, swapped
end

-- Debug helper: nearest pad distance for a raw world point (no axis rewrite).
local function nearestPadFit(wx, wy)
    if ensureGraph then
        ensureGraph()
    end
    if not isNumber(wx) or not isNumber(wy) or not nodesById then
        return nil
    end
    local faction = playerFaction()
    local best
    for _, node in pairs(nodesById) do
        if factionUsable(node.faction, faction) and isNumber(node.wx) then
            local dist = euclidean(wx, wy, node.wx, node.wy)
            if dist and (not best or dist < best) then
                best = dist
            end
        end
    end
    return best
end

local function playerPoint()
    local now = (GetTime and GetTime()) or 0
    -- Fly-rec / travel pulse every 0.25–0.5s; reuse a fresh sample briefly so
    -- one recommendation does not rescan pads / UnitPosition repeatedly.
    if playerPointCache.wx and (now - playerPointCache.at) < 0.2 then
        return playerPointCache.wx, playerPointCache.wy, playerPointCache.instance
    end

    local function remember(wx, wy, instance)
        playerPointCache.wx, playerPointCache.wy, playerPointCache.instance = wx, wy, instance
        playerPointCache.at = now
        return wx, wy, instance
    end

    local hbd = getHBD()
    if hbd and type(hbd.GetPlayerWorldPosition) == "function" then
        local ok, wx, wy, instance = pcall(hbd.GetPlayerWorldPosition, hbd)
        if ok and isNumber(wx) and isNumber(wy) then
            wx, wy = alignToFlightWorld(wx, wy)
            -- Forever flight JSON uses UnitPosition continent ids (0/1). HBD's
            -- instance often disagrees; prefer UnitPosition so same-continent
            -- FP filters do not skip every Kalimdor pad (or tip EK ones).
            if type(UnitPosition) == "function" then
                local uok, _, _, _, unitInstance = pcall(UnitPosition, "player")
                if uok and isNumber(unitInstance) then
                    instance = unitInstance
                end
            end
            return remember(wx, wy, instance)
        end
    end
    -- Forever often leaves HBD player world unset. UnitPosition returns
    -- (y, x) on retail-style clients; try that first, then (a, b).
    if type(UnitPosition) == "function" then
        local ok, a, b, _, instance = pcall(UnitPosition, "player")
        if ok and isNumber(a) and isNumber(b) then
            if unitPosUseAB ~= nil then
                if unitPosUseAB then
                    return remember(a, b, instance)
                end
                return remember(b, a, instance)
            end
            -- Discovery: at most two pad scans once per session, then lock
            -- which UnitPosition ordering matches flight JSON.
            local x1, y1, swap1, d1, s1 = scoreFlightAxis(b, a)
            local fit1 = (swap1 and s1) or d1
            local x2, y2, swap2, d2, s2 = scoreFlightAxis(a, b)
            local fit2 = (swap2 and s2) or d2
            local wx, wy, swap, d, s
            if fit1 and (not fit2 or fit1 <= fit2) then
                wx, wy, swap, d, s = x1, y1, swap1, d1, s1
            else
                wx, wy, swap, d, s = x2, y2, swap2, d2, s2
            end
            lockFlightAxis(swap, d, s)
            -- Final aligned point is always either (a,b) or (b,a).
            unitPosUseAB = (isNumber(wx) and isNumber(a) and math.abs(wx - a) < 1e-3
                and isNumber(wy) and isNumber(b) and math.abs(wy - b) < 1e-3)
            return remember(wx, wy, instance)
        end
    end
    return nil
end

local function worldDistanceOn(instance, ax, ay, bx, by)
    if not isNumber(ax) or not isNumber(ay) or not isNumber(bx) or not isNumber(by) then
        return nil
    end
    local hbd = getHBD()
    if not isNumber(instance) then
        instance = 0
    end
    if hbd and type(hbd.GetWorldDistance) == "function" then
        local ok, yards = pcall(hbd.GetWorldDistance, hbd, instance, ax, ay, bx, by)
        if ok and isNumber(yards) and yards == yards then
            return yards
        end
    end
    if hbd and type(hbd.GetWorldVector) == "function" then
        local ok, _, yards = pcall(hbd.GetWorldVector, hbd, instance, ax, ay, bx, by)
        if ok and isNumber(yards) and yards == yards then
            return yards
        end
    end
    return euclidean(ax, ay, bx, by)
end

local function worldDistance(instance, ax, ay, bx, by)
    local yards = worldDistanceOn(instance, ax, ay, bx, by)
    if yards then
        return yards
    end
    -- Forever HBD continent ids often disagree with flight JSON 0/1.
    if instance ~= 0 then
        yards = worldDistanceOn(0, ax, ay, bx, by)
        if yards then
            return yards
        end
    end
    if instance ~= 1 then
        yards = worldDistanceOn(1, ax, ay, bx, by)
        if yards then
            return yards
        end
    end
    return euclidean(ax, ay, bx, by)
end

-- Pad ranking only. HBD GetWorldDistance across every flight node was the
-- TravelBestPath spike (~100ms+). Euclidean matches Forever JSON space after
-- playerPoint alignment and is good enough to pick the nearest pad.
local function nodeDistance(wx, wy, instance, node)
    if not node or not isNumber(wx) or not isNumber(wy) or not isNumber(node.wx) or not isNumber(node.wy) then
        return nil
    end
    return euclidean(wx, wy, node.wx, node.wy)
end

-- Precise yards when we already know the two points that matter.
local function nodeDistancePrecise(wx, wy, instance, node)
    if not node or not isNumber(wx) or not isNumber(wy) or not isNumber(node.wx) or not isNumber(node.wy) then
        return nil
    end
    local yards = worldDistance(instance or node.instance, wx, wy, node.wx, node.wy)
    if yards then
        return yards
    end
    if isNumber(node.instance) and node.instance ~= instance then
        yards = worldDistance(node.instance, wx, wy, node.wx, node.wy)
        if yards then
            return yards
        end
    end
    return euclidean(wx, wy, node.wx, node.wy)
end

local function zoneWorld(map, x, y, zone)
    if ns.PinToPlayerWorld then
        local wx, wy, instance = ns.PinToPlayerWorld(map, x, y, zone)
        if isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end
    if ns.ZoneToWorld then
        local wx, wy, instance = ns.ZoneToWorld(map, x, y)
        if isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end
    if not isNumber(map) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local zx, zy = x, y
    if zx > 1 or zy > 1 then
        zx, zy = zx / 100, zy / 100
    end
    local hbd = getHBD()
    if not hbd or type(hbd.GetWorldCoordinatesFromZone) ~= "function" then
        return nil
    end
    local ok, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, zx, zy, map)
    if not ok or not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    return wx, wy, instance
end

local function walkSeconds(yards)
    if not isNumber(yards) then
        return nil
    end
    return yards / RUN_YARDS_PER_SEC
end

local function fillMissingInnCoords()
    local missing = false
    for _, place in pairs(placeIndex) do
        if type(place) == "table" and place.kind == "inn" and not isNumber(place.wx) then
            local wx, wy, instance = zoneWorld(place.map, place.x, place.y, place.zone)
            if wx then
                place.wx, place.wy, place.instance = wx, wy, instance
            else
                missing = true
            end
        end
    end
    innsNeedCoords = missing
end

ensureGraph = function()
    if graphBuilt then
        if innsNeedCoords then
            fillMissingInnCoords()
        end
        return
    end
    graphBuilt = true
    nodesById = {}
    edgesByFrom = {}
    docksById = {}
    transportLegsByFrom = {}
    placeIndex = {}
    aliasIndex = {}

    local flights = ns.NavFlightMasters
    if type(flights) == "table" then
        for index = 1, #flights do
            local entry = flights[index]
            if type(entry) == "table" and isNumber(entry.nodeId) and isNumber(entry.wx) and isNumber(entry.wy) then
                local node = {
                    nodeId = entry.nodeId,
                    name = entry.name,
                    hub = entry.hub or entry.zone,
                    zone = entry.zone,
                    faction = entry.faction,
                    map = entry.map,
                    x = entry.x,
                    y = entry.y,
                    wx = entry.wx,
                    wy = entry.wy,
                    wz = entry.wz,
                    instance = entry.instance,
                    npc = entry.npc,
                    kind = "flight",
                }
                nodesById[entry.nodeId] = node
                local place = {
                    kind = "flight",
                    nodeId = entry.nodeId,
                    name = node.hub,
                    zone = node.zone,
                    map = node.map,
                    x = node.x,
                    y = node.y,
                    wx = node.wx,
                    wy = node.wy,
                    instance = node.instance,
                    npc = node.npc,
                }
                addAlias(placeIndex, node.hub, place)
                addAlias(placeIndex, node.zone, place)
                addAlias(placeIndex, node.name, place)
            end
        end
    end

    local connections = ns.NavFlightConnections
    if type(connections) == "table" then
        for index = 1, #connections do
            local edge = connections[index]
            if type(edge) == "table" and isNumber(edge.from) and isNumber(edge.to) and isNumber(edge.seconds) then
                local list = edgesByFrom[edge.from]
                if not list then
                    list = {}
                    edgesByFrom[edge.from] = list
                end
                list[#list + 1] = {
                    to = edge.to,
                    seconds = edge.seconds,
                    faction = edge.faction,
                }
            end
        end
    end

    local inns = ns.NavInnkeepers
    if type(inns) == "table" then
        for index = 1, #inns do
            local entry = inns[index]
            if type(entry) == "table" and type(entry.name) == "string" then
                local wx, wy, instance = zoneWorld(entry.map, entry.x, entry.y, entry.zone)
                local place = {
                    kind = "inn",
                    name = entry.zone or entry.name,
                    zone = entry.zone,
                    map = entry.map,
                    x = entry.x,
                    y = entry.y,
                    wx = wx,
                    wy = wy,
                    instance = instance,
                    faction = entry.faction,
                    npc = entry.npc,
                }
                addAlias(placeIndex, entry.zone, place)
                addAlias(placeIndex, entry.name, place)
            end
        end
    end

    local docks = ns.NavTransportDocks
    if type(docks) == "table" then
        for index = 1, #docks do
            local entry = docks[index]
            if type(entry) == "table" and isNumber(entry.dockId) and isNumber(entry.wx) and isNumber(entry.wy) then
                local dock = {
                    dockId = entry.dockId,
                    routeId = entry.routeId,
                    name = entry.name,
                    zone = entry.zone,
                    map = entry.map,
                    faction = entry.faction,
                    type = entry.type or "boat",
                    routeName = entry.routeName,
                    wx = entry.wx,
                    wy = entry.wy,
                    wz = entry.wz,
                    instance = entry.instance,
                    dwellSeconds = entry.dwellSeconds or 60,
                    cycleSeconds = entry.cycleSeconds or 300,
                    kind = "transport",
                }
                docksById[entry.dockId] = dock
                local place = {
                    kind = "transport",
                    dockId = entry.dockId,
                    name = dock.name,
                    zone = dock.zone,
                    map = dock.map,
                    wx = dock.wx,
                    wy = dock.wy,
                    instance = dock.instance,
                    type = dock.type,
                }
                addAlias(placeIndex, dock.name, place)
                -- Prefer flight hubs for city names; dock-only labels still resolve.
                addAlias(placeIndex, dock.zone, place)
            end
        end
    end

    local transportLegs = ns.NavTransportLegs
    if type(transportLegs) == "table" then
        for index = 1, #transportLegs do
            local edge = transportLegs[index]
            if type(edge) == "table" and isNumber(edge.from) and isNumber(edge.to) and isNumber(edge.seconds) then
                local list = transportLegsByFrom[edge.from]
                if not list then
                    list = {}
                    transportLegsByFrom[edge.from] = list
                end
                list[#list + 1] = {
                    to = edge.to,
                    seconds = edge.seconds,
                    faction = edge.faction,
                    type = edge.type or "boat",
                    routeId = edge.routeId,
                    routeName = edge.routeName,
                }
            end
        end
    end

    -- Common spoken aliases that do not match hub names exactly.
    local aliases = {
        ["the crossroads"] = "Crossroads",
        ["crossroads"] = "Crossroads",
        ["the sepulcher"] = "The Sepulcher",
        ["sepulcher"] = "The Sepulcher",
        ["senjin village"] = "Sen'jin Village",
        ["sen'jin village"] = "Sen'jin Village",
        ["thunderbluff"] = "Thunder Bluff",
        ["undercity"] = "Undercity",
        ["org"] = "Orgrimmar",
        ["tb"] = "Thunder Bluff",
        ["uc"] = "Undercity",
        ["sw"] = "Stormwind",
        ["if"] = "Ironforge",
    }
    for alias, hub in pairs(aliases) do
        local place = placeIndex[normalizeName(hub)]
        if place then
            aliasIndex[alias] = place
            addAlias(placeIndex, alias, place)
        end
    end
    fillMissingInnCoords()
end

local function bumpFlightUnlockGen()
    flightUnlockGen = flightUnlockGen + 1
    unlockedCache = nil
    unlockedCacheGen = 0
    routeCache = {}
    routeCacheGen = 0
    nearbyHintCache = nil
    nearbyHintChecked = false
end

function ns.TravelInvalidateRoutes()
    routeCache = {}
    routeCacheGen = 0
end

local function unlockedFlightPaths()
    if unlockedCache and unlockedCacheGen == flightUnlockGen then
        return unlockedCache
    end
    local db = charDB().flightPaths
    local unlocked = {}
    for key, value in pairs(db) do
        local id = tonumber(key)
        if id and value then
            unlocked[id] = true
        end
    end
    -- Prefer RXP discovery when present so routes stay useful without a fresh taxi open.
    local rxp = _G.RXPCData and _G.RXPCData.flightPaths
    if type(rxp) == "table" then
        for key, value in pairs(rxp) do
            local id = tonumber(key)
            if id and value then
                unlocked[id] = true
                if not db[id] then
                    db[id] = type(value) == "string" and value or true
                end
            end
        end
    end
    unlockedCache = unlocked
    unlockedCacheGen = flightUnlockGen
    return unlocked
end

local function markFlightUnlocked(nodeId, name)
    nodeId = tonumber(nodeId)
    if not nodeId then
        return
    end
    local db = charDB().flightPaths
    local changed = false
    if type(name) == "string" and name ~= "" then
        changed = db[nodeId] ~= name
        db[nodeId] = name
    elseif not db[nodeId] then
        db[nodeId] = true
        changed = true
    end
    if changed then
        bumpFlightUnlockGen()
    end
end

local function routeCacheKey(dest, opts, px, py, pinstance)
    local prefer = (opts and opts.prefer) or dest.prefer or "-"
    local gx = math.floor((px or 0) / ROUTE_GRID_YARDS + 0.5)
    local gy = math.floor((py or 0) / ROUTE_GRID_YARDS + 0.5)
    return table.concat({
        tostring(dest.wx or "-"),
        tostring(dest.wy or "-"),
        tostring(dest.instance or "-"),
        tostring(dest.nodeId or "-"),
        tostring(prefer),
        tostring(gx),
        tostring(gy),
        tostring(pinstance or "-"),
        tostring(flightUnlockGen),
    }, ":")
end

local function matchNodeIdByTaxiName(taxiName)
    ensureGraph()
    local key = normalizeName(taxiName)
    if not key then
        return nil
    end
    local faction = playerFaction()
    local bestId
    local bestScore = 0
    for nodeId, node in pairs(nodesById) do
        if factionUsable(node.faction, faction) then
            local hub = normalizeName(node.hub)
            local zone = normalizeName(node.zone)
            local name = normalizeName(node.name)
            local score = 0
            if hub and key == hub then
                score = 100
            elseif zone and key == zone then
                score = 90
            elseif name and key == name then
                score = 80
            elseif hub and key:find(hub, 1, true) then
                score = 70
            elseif name and key:find(name, 1, true) then
                score = 60
            elseif zone and key:find(zone, 1, true) then
                score = 40
            end
            if score > bestScore then
                bestScore = score
                bestId = nodeId
            end
        end
    end
    return bestId
end

function ns.MatchFlightNodeId(taxiName)
    return matchNodeIdByTaxiName(taxiName)
end

local flightSecondsByPair

local function ensureFlightSecondsIndex()
    if flightSecondsByPair then
        return flightSecondsByPair
    end
    flightSecondsByPair = {}
    local connections = ns.NavFlightConnections
    if type(connections) == "table" then
        for index = 1, #connections do
            local edge = connections[index]
            if type(edge) == "table" and isNumber(edge.from) and isNumber(edge.to) and isNumber(edge.seconds) then
                local bucket = flightSecondsByPair[edge.from]
                if not bucket then
                    bucket = {}
                    flightSecondsByPair[edge.from] = bucket
                end
                bucket[edge.to] = edge.seconds
            end
        end
    end
    return flightSecondsByPair
end

-- Sum forever flight-time defaults along a nodeId path (from wow-forever-flight-times.json).
function ns.DefaultFlightSeconds(nodeIds)
    if type(nodeIds) ~= "table" or #nodeIds < 2 then
        return nil
    end
    local index = ensureFlightSecondsIndex()
    local total = 0
    for hop = 1, #nodeIds - 1 do
        local fromId = nodeIds[hop]
        local toId = nodeIds[hop + 1]
        local bucket = index[fromId]
        local seconds = bucket and bucket[toId]
        if type(seconds) ~= "number" or seconds <= 0 then
            return nil
        end
        total = total + seconds
    end
    return total
end

function ns.TravelRememberOpenTaxiNodes()
    ensureGraph()
    if C_TaxiMap and type(C_TaxiMap.GetAllTaxiNodes) == "function" then
        local ok, nodes = pcall(C_TaxiMap.GetAllTaxiNodes)
        if ok and type(nodes) == "table" then
            local current = Enum and Enum.FlightPathState and Enum.FlightPathState.Current
            local reachable = Enum and Enum.FlightPathState and Enum.FlightPathState.Reachable
            for index = 1, #nodes do
                local info = nodes[index]
                if type(info) == "table" then
                    local state = info.state
                    if state == current or state == reachable or state == 0 or state == 1 then
                        markFlightUnlocked(info.nodeID or info.nodeId, info.name)
                    end
                end
            end
        end
    end
    if type(NumTaxiNodes) ~= "function" or type(TaxiNodeGetType) ~= "function" then
        return
    end
    local count = NumTaxiNodes() or 0
    for index = 1, count do
        local nodeType = TaxiNodeGetType(index)
        if nodeType == "CURRENT" or nodeType == "REACHABLE" then
            local taxiName = TaxiNodeName and TaxiNodeName(index)
            local nodeId = matchNodeIdByTaxiName(taxiName)
            if nodeId then
                markFlightUnlocked(nodeId, taxiName)
            end
        end
    end
end

function ns.TravelRememberNearestFlight()
    ensureGraph()
    local px, py, instance = playerPoint()
    if not px then
        return
    end
    -- Strict same-continent: Sen'jin (Kalimdor) is euclidean-near Revantusk (EK).
    local node, dist = nearestFlightNode(px, py, instance, false, false, true)
    if node and dist and dist <= 200 then
        markFlightUnlocked(node.nodeId, node.hub)
    end
end

local function hearthReady()
    if type(GetItemCount) == "function" then
        local count = GetItemCount(HEARTHSTONE_ITEM)
        if type(count) == "number" and count <= 0 then
            return false
        end
    end
    local start, duration
    if C_Container and C_Container.GetItemCooldown then
        local ok, a, b = pcall(C_Container.GetItemCooldown, HEARTHSTONE_ITEM)
        if ok then
            start, duration = a, b
        end
    end
    if not start and type(GetItemCooldown) == "function" then
        start, duration = GetItemCooldown(HEARTHSTONE_ITEM)
    end
    if type(start) == "number" and type(duration) == "number" and start > 0 and duration > 0 then
        local remains = start + duration - GetTime()
        if remains > 1 then
            return false, remains
        end
    end
    return true, 0
end

local function bindPlace()
    ensureGraph()
    if type(GetBindLocation) ~= "function" then
        return nil
    end
    local bind = GetBindLocation()
    if type(bind) ~= "string" or bind == "" then
        return nil
    end
    local place = placeIndex[normalizeName(bind)]
    if place then
        return place, bind
    end
    return {
        kind = "bind",
        name = bind,
        zone = bind,
    }, bind
end

local function hearthItemIcon()
    if C_Item and C_Item.GetItemIconByID then
        local ok, tex = pcall(C_Item.GetItemIconByID, HEARTHSTONE_ITEM)
        if ok and tex then
            return tex
        end
    end
    if type(GetItemIcon) == "function" then
        local ok, tex = pcall(GetItemIcon, HEARTHSTONE_ITEM)
        if ok and tex then
            return tex
        end
    end
    return "Interface\\Icons\\INV_Misc_Rune_01"
end

local function updateHearthCooldown(button)
    if not button or not button.cooldown then
        return
    end
    local start, duration
    if C_Container and C_Container.GetItemCooldown then
        local ok, a, b = pcall(C_Container.GetItemCooldown, HEARTHSTONE_ITEM)
        if ok then
            start, duration = a, b
        end
    end
    if not start and type(GetItemCooldown) == "function" then
        start, duration = GetItemCooldown(HEARTHSTONE_ITEM)
    end
    if type(start) == "number" and type(duration) == "number" and start > 0 and duration > 0 then
        button.cooldown:SetCooldown(start, duration)
    elseif button.cooldown.Clear then
        button.cooldown:Clear()
    else
        button.cooldown:SetCooldown(0, 0)
    end
end

function ns.TravelHearthButton()
    if hearthButton then
        updateHearthCooldown(hearthButton)
        return hearthButton
    end
    if InCombatLockdown and InCombatLockdown() then
        return nil
    end
    hearthButton = CreateFrame("Button", "WaynotesHearthButton", UIParent, "SecureActionButtonTemplate")
    hearthButton:SetSize(22, 22)
    if hearthButton.RegisterForClicks then
        pcall(hearthButton.RegisterForClicks, hearthButton, "AnyUp", "AnyDown")
    end
    hearthButton:SetAttribute("type", "item")
    hearthButton:SetAttribute("item", "item:" .. HEARTHSTONE_ITEM)
    hearthButton.itemId = HEARTHSTONE_ITEM
    hearthButton.name = "Hearthstone"
    local icon = hearthButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(hearthItemIcon())
    hearthButton.icon = icon
    local cooldown = CreateFrame("Cooldown", nil, hearthButton, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    hearthButton.cooldown = cooldown
    hearthButton:SetScript("OnEnter", function(self)
        local r, g, b = 0.9, 0.82, 0.45
        if ns.Color then
            r, g, b = ns.Color("accent")
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if GameTooltip.SetItemByID then
            GameTooltip:SetItemByID(HEARTHSTONE_ITEM)
        else
            GameTooltip:SetHyperlink("item:" .. HEARTHSTONE_ITEM)
        end
        local bind = self.bindName
        if type(bind) == "string" and bind ~= "" then
            GameTooltip:AddLine("Bound to " .. bind, r, g, b, true)
        end
        GameTooltip:AddLine("Click to use your Hearthstone.", 1, 1, 1, true)
        if ns.FinishTooltip then
            ns.FinishTooltip()
        else
            GameTooltip:Show()
        end
    end)
    hearthButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    hearthButton:SetScript("OnShow", function(self)
        updateHearthCooldown(self)
    end)
    hearthButton:Hide()
    updateHearthCooldown(hearthButton)
    return hearthButton
end

local activeFlightRec
local activeHearthRec

local function flightRecMinYards()
    local minYards = (ns.db and ns.db.flightRecommendMinYards) or 500
    if type(minYards) ~= "number" then
        return 500
    end
    return minYards
end

function ns.TravelBeginHints()
    -- Nearby FP tip is rebuilt per GuideObjectives pass. Fly/hearth strip state
    -- is owned by TravelPulsePrimaryRoute (step/zone only). Clearing it here
    -- made every tracker refresh wipe the strip until the next route pulse.
    nearbyHintCache = nil
    nearbyHintChecked = false
end

function ns.TravelActiveFlightRecommendation()
    return activeFlightRec
end

function ns.TravelActiveHearthRecommendation()
    return activeHearthRec
end

local function rememberFlightRec(route)
    if type(route) ~= "table" or route.mode ~= "fly" then
        return
    end
    if not route.departId or not route.arriveId or route.departId == route.arriveId then
        return
    end
    if not isNumber(route.savingsYards) or route.savingsYards < flightRecMinYards() then
        return
    end
    if not activeFlightRec or route.savingsYards > (activeFlightRec.savingsYards or 0) then
        activeFlightRec = route
    end
end

local NEARBY_FP_YARDS = 150

local function plainGuideText(text)
    if type(text) ~= "string" then
        return nil
    end
    text = text:gsub("|cRB_[%w_]+_", "")
    text = text:gsub("|cRXP_[%w_]+_", "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|T.-|t", "")
    -- Keep the body of curated [FRIENDLY]Name[/] / [FRIENDLY]Name[/FRIENDLY] tags.
    text = text:gsub("%[([%a]+)%](.-)%[/%1%]", "%2")
    text = text:gsub("%[%a+%](.-)%[/%]", "%1")
    text = strtrim(text)
    text = text:gsub("^%[[^%]]+%]%s*", "")
    if text == "" then
        return nil
    end
    return text
end

-- Absolute pin→world for flight-master matching. PinToPlayerWorld is player-relative
-- and aims arrows; using it here while the player is elsewhere picks the wrong node.
local function absoluteZoneWorld(map, x, y)
    if ns.ZoneToWorld then
        local wx, wy, instance = ns.ZoneToWorld(map, x, y)
        if isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end
    if not isNumber(map) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local zx, zy = x, y
    if zx > 1 or zy > 1 then
        zx, zy = zx / 100, zy / 100
    end
    local hbd = getHBD()
    if not hbd or type(hbd.GetWorldCoordinatesFromZone) ~= "function" then
        return nil
    end
    local ok, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, zx, zy, map)
    if not ok or not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    return wx, wy, instance
end

local function cleanDestinationPhrase(dest)
    if type(dest) ~= "string" then
        return nil
    end
    dest = dest:gsub("%s*%b()", "")
    dest = dest:gsub("%s+and%s+enter.*$", "")
    dest = dest:gsub("%s+through%s+the%s+sewers.*$", "")
    dest = dest:gsub("%s+from%s+.*$", "")
    dest = dest:gsub("%s+and%s+.*$", "")
    dest = dest:gsub("%s+or%s+.*$", "")
    dest = dest:gsub("%s+then%s+.*$", "")
    dest = dest:gsub("[%.%,%;:!].*$", "")
    dest = strtrim(dest)
    if dest == "" then
        return nil
    end
    return dest
end

local function extractDestinationName(text)
    text = plainGuideText(text)
    if not text then
        return nil, nil
    end
    local patterns = {
        { "^Hearth%s+or%s+return%s+to%s+(.+)$", "hearth" },
        { "^Hearth%s+to%s+(.+)$", "hearth" },
        { "^Fly%s+or%s+hearth%s+to%s+(.+)$", "hearth" },
        { "^Fly%s+or%s+run%s+back%s+to%s+(.+)$", "fly" },
        { "^Fly%s+or%s+run%s+to%s+(.+)$", "fly" },
        { "^Fly%s+or%s+ride%s+to%s+(.+)$", "fly" },
        { "^Fly%s+to%s+(.+)$", "fly" },
        { "^Take the flight path.-toward%s+(.+)$", "fly" },
        { "^Take the%s+zeppelin%s+to%s+(.+)$", "travel" },
        { "^Take the%s+boat%s+to%s+(.+)$", "travel" },
        { "^Take the%s+skycutter%s+to%s+(.+)$", "travel" },
        { "^Take the%s+ferry%s+to%s+(.+)$", "travel" },
        -- "Return to Hub" usually means fly back; prefer=fly also soft-trusts a
        -- named pad that is missing from the character flight DB.
        { "^Return%s+back%s+to%s+(.+)$", "fly" },
        { "^Return%s+to%s+(.+)$", "fly" },
        { "^Head%s+back%s+to%s+(.+)$", "travel" },
        { "^Head%s+to%s+(.+)$", "travel" },
        { "^Go%s+back%s+to%s+(.+)$", "fly" },
        { "^Travel%s+back%s+to%s+(.+)$", "fly" },
        { "^Travel%s+toward%s+(.+)$", "travel" },
        { "^Travel%s+to%s+(.+)$", "travel" },
        { "^Run%s+back%s+to%s+(.+)$", "travel" },
        { "^Run%s+to%s+(.+)$", "travel" },
        -- Curated wording: "Travel south to X" / mid-sentence "and travel to X".
        { "[Tt]ravel%s+.-to%s+(.+)$", "travel" },
        { "[Rr]eturn%s+to%s+(.+)$", "fly" },
        { "[Ff]ly%s+to%s+(.+)$", "fly" },
        { "[Hh]earth%s+to%s+(.+)$", "hearth" },
        { "[Tt]ake the%s+zeppelin%s+to%s+(.+)$", "travel" },
        { "[Tt]ake the%s+boat%s+to%s+(.+)$", "travel" },
    }
    for index = 1, #patterns do
        local dest = text:match(patterns[index][1])
        dest = cleanDestinationPhrase(dest)
        if dest then
            return dest, patterns[index][2]
        end
    end
end

local function resolveNamedPlace(name)
    ensureGraph()
    local key = normalizeName(name)
    if not key then
        return nil
    end
    if placeIndex[key] then
        return placeIndex[key]
    end
    if aliasIndex[key] then
        return aliasIndex[key]
    end
    -- Partial match against known hubs/zones.
    local best, bestLen
    for placeKey, place in pairs(placeIndex) do
        if placeKey:find(key, 1, true) or key:find(placeKey, 1, true) then
            local len = #placeKey
            if not bestLen or len < bestLen then
                bestLen = len
                best = place
            end
        end
    end
    return best
end

local function resolveBindPlace()
    local place, bindName = bindPlace()
    if place and isNumber(place.wx) and isNumber(place.wy) then
        return place, bindName
    end
    if type(bindName) == "string" then
        local resolved = resolveNamedPlace(bindName)
        if resolved and isNumber(resolved.wx) and isNumber(resolved.wy) then
            return resolved, bindName
        end
    end
    return place, bindName
end

local function hearthCloserSuggestion(dest)
    if type(dest) ~= "table" or not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end
    local ready = hearthReady()
    if not ready then
        return nil
    end
    local place, bindName = resolveBindPlace()
    if not place or not isNumber(place.wx) or not isNumber(place.wy) then
        return nil
    end
    local px, py, pinstance = playerPoint()
    if not px then
        return nil
    end
    local destInstance = dest.instance
    local bindInstance = place.instance
    if isNumber(destInstance) and isNumber(bindInstance) and destInstance ~= bindInstance then
        return nil
    end
    if isNumber(destInstance) and isNumber(pinstance) and destInstance ~= pinstance then
        -- Player is off-continent; hearth helps only when the bind is on the
        -- destination continent.
        if not (isNumber(bindInstance) and bindInstance == destInstance) then
            return nil
        end
        return {
            bindName = bindName or place.name or place.zone,
            place = place,
            playerDist = math.huge,
            bindDist = 0,
            savingsYards = math.huge,
        }
    end
    local compareInstance = destInstance or bindInstance or pinstance
    local playerDist = worldDistance(compareInstance, px, py, dest.wx, dest.wy)
    local bindDist = worldDistance(compareInstance, place.wx, place.wy, dest.wx, dest.wy)
    if not playerDist or not bindDist then
        return nil
    end
    if playerDist <= NEAR_YARDS * 2 then
        return nil
    end
    local fromBind = worldDistance(pinstance or compareInstance, px, py, place.wx, place.wy)
    if fromBind and fromBind <= NEAR_YARDS then
        return nil
    end
    local savings = playerDist - bindDist
    if savings < HEARTH_CLOSER_YARDS then
        return nil
    end
    return {
        bindName = bindName or place.name or place.zone,
        place = place,
        playerDist = playerDist,
        bindDist = bindDist,
        savingsYards = savings,
    }
end

-- Bottom-chrome hearth tip: only when hearth beats walking on time, and
-- (for soft tips alongside fly) the bind is meaningfully closer on foot.
local function hearthRecommendation(dest, route)
    if type(dest) ~= "table" or not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end
    if route and route.mode == "hearth" then
        local suggestion = hearthCloserSuggestion(dest)
        local savings = suggestion and suggestion.savingsYards or nil
        if savings == math.huge then
            savings = nil
        end
        return {
            bindName = route.bindName or (suggestion and suggestion.bindName),
            summary = route.summary or ("Hearth to " .. (route.bindName or "bind")),
            savingsYards = savings,
            useHearth = true,
        }
    end
    -- BestPath already rejected hearth vs walk; no tip.
    if not route or route.mode == "walk" then
        return nil
    end
    -- Soft tip when BestPath preferred fly/boat: hearth still beats walk
    -- and the bind is far enough closer to cover cast time.
    local suggestion = hearthCloserSuggestion(dest)
    if not suggestion then
        return nil
    end
    local px, py, pinstance = playerPoint()
    if not px then
        return nil
    end
    if suggestion.savingsYards == math.huge then
        return {
            bindName = suggestion.bindName,
            summary = "Hearth to " .. (suggestion.bindName or "bind"),
            useHearth = true,
        }
    end
    local walk = routeWalk(dest, px, py, pinstance)
    local hearth = routeHearth(dest, px, py, pinstance, unlockedFlightPaths(), playerFaction(), false)
    if not hearth then
        return nil
    end
    if walk and (walk.seconds - hearth.seconds) < MIN_IMPROVE_SECONDS then
        return nil
    end
    return {
        bindName = suggestion.bindName or hearth.bindName,
        summary = hearth.summary or ("Hearth to " .. (suggestion.bindName or "bind")),
        savingsYards = suggestion.savingsYards,
        useHearth = true,
    }
end

local function namesCompatible(a, b)
    local na, nb = normalizeName(a), normalizeName(b)
    if not na or not nb then
        return false
    end
    return na == nb or na:find(nb, 1, true) or nb:find(na, 1, true)
end

local function flightNodeByName(name)
    ensureGraph()
    if type(name) ~= "string" or name == "" then
        return nil
    end
    local faction = playerFaction()
    local best, bestScore
    for _, node in pairs(nodesById) do
        if factionUsable(node.faction, faction) then
            local score = 0
            if namesCompatible(node.name, name) then
                score = 100
            elseif namesCompatible(node.hub, name) then
                score = 80
            elseif namesCompatible(node.zone, name) then
                score = 40
            end
            if score > 0 and (not bestScore or score > bestScore) then
                bestScore = score
                best = node
            end
        end
    end
    return best
end

local function flightMasterNodeFromText(text)
    text = plainGuideText(text)
    if not text then
        return nil
    end
    local phrases = {}
    local fromNpc = text:match("[Ff]light path from%s+([^%.]+)")
    if fromNpc then
        phrases[#phrases + 1] = cleanDestinationPhrase(fromNpc)
    end
    local talk = text:match("[Tt]alk to%s+([^%.]+)")
    if talk then
        talk = cleanDestinationPhrase(talk)
        if talk then
            talk = talk:gsub("%s+in%s+.*$", "")
            talk = strtrim(talk)
            if talk ~= "" then
                phrases[#phrases + 1] = talk
            end
        end
    end
    for index = 1, #phrases do
        local node = flightNodeByName(phrases[index])
        if node then
            return node
        end
    end
end

local function flightNodePlace(node)
    if type(node) ~= "table" or not isNumber(node.nodeId) then
        return nil
    end
    return {
        kind = "flight",
        nodeId = node.nodeId,
        name = node.hub or node.zone or node.name or "flight master",
        zone = node.zone,
        wx = node.wx,
        wy = node.wy,
        instance = node.instance,
        npc = node.npc,
        pickup = true,
    }
end

-- EK/Kalimdor share overlapping numeric UnitPosition ranges (e.g. Sen'jin
-- Village sits ~40 yd from Revantusk Village's XY). Always prefer same
-- instance; when sameContinentOnly, never fall back across continents.
local function nearestFlightNode(wx, wy, instance, unlockedOnly, unlearnedOnly, sameContinentOnly)
    ensureGraph()
    if not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    local unlocked = unlockedFlightPaths()
    local faction = playerFaction()
    local bestId, bestDist
    local bestSameId, bestSameDist
    for nodeId, node in pairs(nodesById) do
        if factionUsable(node.faction, faction) then
            local known = unlocked[nodeId] and true or false
            if (not unlockedOnly or known) and (not unlearnedOnly or not known) then
                local dist = nodeDistance(wx, wy, instance, node)
                if dist then
                    if not bestDist or dist < bestDist then
                        bestDist = dist
                        bestId = nodeId
                    end
                    if isNumber(instance)
                        and isNumber(node.instance)
                        and node.instance == instance
                        and (not bestSameDist or dist < bestSameDist)
                    then
                        bestSameDist = dist
                        bestSameId = nodeId
                    end
                end
            end
        end
    end
    if bestSameId then
        return nodesById[bestSameId], bestSameDist
    end
    if sameContinentOnly then
        return nil
    end
    if bestId then
        return nodesById[bestId], bestDist
    end
end

local function flightPathNameFromText(text)
    text = plainGuideText(text)
    if not text then
        return nil
    end
    local hub = text:match("[Ff]path%s+([^%.]+)")
    if not hub then
        hub = text:match("[Gg]et the%s+(.-)%s+flight path")
    end
    hub = cleanDestinationPhrase(hub)
    if hub and hub ~= "" and hub:lower() ~= "the" then
        return hub
    end
    if text:match("[Gg]et the flight path")
        or text:match("flight path from")
        or text:match("[Ff]path%s")
        or (text:match("flight path") and text:lower():find("get the", 1, true))
    then
        return true
    end
end

local function flightPathTargetFromStep(step)
    ensureGraph()
    if type(step) ~= "table" then
        return nil
    end

    local function placeFromHub(hub)
        if type(hub) ~= "string" or hub == "" then
            return nil
        end
        local place = resolveNamedPlace(hub)
        if place and (place.kind == "flight" or isNumber(place.nodeId)) then
            local copy = {}
            for key, value in pairs(place) do
                copy[key] = value
            end
            copy.pickup = true
            return copy
        end
        local node = flightNodeByName(hub)
        if node then
            return flightNodePlace(node)
        end
    end

    if type(step.fpath) == "string" and step.fpath ~= "" then
        local place = placeFromHub(step.fpath)
        if place then
            return place
        end
    end

    local hub = flightPathNameFromText(step.text)
    if not hub then
        return nil
    end
    if type(hub) == "string" then
        local place = placeFromHub(hub)
        if place then
            return place
        end
    end

    -- Unnamed "Get the flight path": prefer the flight master named in the step,
    -- then the Travel-to hub, then the nearest master to the authored pin.
    local npcNode = flightMasterNodeFromText(step.text)
    if npcNode then
        return flightNodePlace(npcNode)
    end
    local named = extractDestinationName(step.text)
    if named then
        local place = placeFromHub(named)
        if place then
            return place
        end
    end
    if isNumber(step.map) and isNumber(step.x) and isNumber(step.y) then
        local wx, wy, instance = absoluteZoneWorld(step.map, step.x, step.y)
        local node = nearestFlightNode(wx, wy, instance, false, false, true)
        if node then
            return flightNodePlace(node)
        end
    end
end

function ns.TravelIsFlightPathStep(step)
    return flightPathTargetFromStep(step) ~= nil
end

function ns.TravelFlightPathStepDone(step)
    local target = flightPathTargetFromStep(step)
    if not target or not isNumber(target.nodeId) then
        return false
    end
    local unlocked = unlockedFlightPaths()
    return unlocked[target.nodeId] and true or false
end

local function hearthBindNameFromText(text)
    text = plainGuideText(text)
    if not text then
        return nil
    end
    local hub = text:match("[Ss]et your [Hh]earthstone%s+to%s+([^%.]+)")
        or text:match("[Ss]et your [Hh]earth%s+to%s+([^%.]+)")
        or text:match("[Ss]et%s+hearthstone%s+to%s+([^%.]+)")
        or text:match("[Ss]et%s+hearth%s+to%s+([^%.]+)")
        or text:match("[Bb]ind%s+your%s+[Hh]earthstone%s+to%s+([^%.]+)")
    return cleanDestinationPhrase(hub)
end

local function hearthBindTargetFromStep(step)
    if type(step) ~= "table" then
        return nil
    end
    if type(step.hearth) == "string" and step.hearth ~= "" then
        return strtrim(step.hearth)
    end
    if type(step.bind) == "string" and step.bind ~= "" then
        return strtrim(step.bind)
    end
    return hearthBindNameFromText(step.text)
end

function ns.TravelIsHearthBindStep(step)
    return hearthBindTargetFromStep(step) ~= nil
end

-- True once GetBindLocation matches the hub named in "Set your Hearthstone to X".
function ns.TravelHearthBindStepDone(step)
    local target = hearthBindTargetFromStep(step)
    if not target then
        return false
    end
    if type(GetBindLocation) ~= "function" then
        return false
    end
    local bind = GetBindLocation()
    if type(bind) ~= "string" or bind == "" then
        return false
    end
    if namesCompatible(bind, target) then
        return true
    end
    local bindResolved = resolveNamedPlace(bind)
    local targetResolved = resolveNamedPlace(target)
    if bindResolved and targetResolved and bindResolved == targetResolved then
        return true
    end
    if bindResolved then
        if namesCompatible(bindResolved.name, target) or namesCompatible(bindResolved.zone, target) then
            return true
        end
    end
    if targetResolved then
        if namesCompatible(bind, targetResolved.name) or namesCompatible(bind, targetResolved.zone) then
            return true
        end
    end
    return false
end

function ns.TravelNearbyUnlearnedFlight(maxYards)
    maxYards = maxYards or NEARBY_FP_YARDS
    if nearbyHintChecked and nearbyHintCache and nearbyHintCache.maxYards == maxYards then
        return nearbyHintCache.place
    end
    ensureGraph()
    local px, py, instance = playerPoint()
    if not px then
        nearbyHintChecked = true
        nearbyHintCache = { maxYards = maxYards, place = nil }
        return nil
    end
    -- Strict same-continent so Durotar never tips Revantusk Village (EK).
    local node, dist = nearestFlightNode(px, py, instance, false, true, true)
    local place
    if node and dist and dist <= maxYards then
        place = flightNodePlace(node)
        place.yards = dist
    end
    nearbyHintChecked = true
    nearbyHintCache = { maxYards = maxYards, place = place }
    return place
end

function ns.TravelIsTravelStep(step)
    if type(step) ~= "table" then
        return false
    end
    if step.when == "travel" or step.travel or step.fpath then
        return true
    end
    if flightPathTargetFromStep(step) then
        return true
    end
    local text = plainGuideText(step.text)
    if not text then
        return false
    end
    if text:match("^Travel")
        or text:match("^Fly%s")
        or text:match("^Hearth%s")
        or text:match("^Run%s+to")
        or text:match("^Run%s+back%s+to")
        or text:match("^Take the flight path")
        or text:match("[Tt]ravel%s+.-to%s+")
        or text:match("[Ff]ly%s+to%s+")
        or text:match("[Hh]earth%s+to%s+")
    then
        return true
    end
    return false
end

local function destinationFromStep(step)
    ensureGraph()
    if type(step) ~= "table" then
        return nil
    end

    if type(step.travel) == "table" then
        if isNumber(step.travel.wx) and isNumber(step.travel.wy) then
            return {
                name = step.travel.name or step.travel.zone or "destination",
                zone = step.travel.zone,
                wx = step.travel.wx,
                wy = step.travel.wy,
                instance = step.travel.instance,
                map = step.travel.map,
                x = step.travel.x,
                y = step.travel.y,
                prefer = step.travel.prefer,
            }
        end
        if isNumber(step.travel.map) and isNumber(step.travel.x) and isNumber(step.travel.y) then
            local wx, wy, instance = zoneWorld(step.travel.map, step.travel.x, step.travel.y, step.travel.zone)
            return {
                name = step.travel.name or step.travel.zone or "destination",
                zone = step.travel.zone,
                map = step.travel.map,
                x = step.travel.x,
                y = step.travel.y,
                wx = wx,
                wy = wy,
                instance = instance,
                prefer = step.travel.prefer,
            }
        end
        if type(step.travel.name) == "string" then
            local place = resolveNamedPlace(step.travel.name)
            if place then
                local copy = {}
                for key, value in pairs(place) do
                    copy[key] = value
                end
                copy.prefer = step.travel.prefer
                return copy
            end
        end
    elseif type(step.travel) == "string" then
        local place = resolveNamedPlace(step.travel)
        if place then
            return place
        end
    end

    local fpDest = flightPathTargetFromStep(step)
    if fpDest then
        return fpDest
    end

    local named, prefer = extractDestinationName(step.text)
    -- An authored pin is the destination. "Travel to the Undercity Courtyard"
    -- must not collapse to the Undercity flight master (zone Tirisfal, no x/y).
    if isNumber(step.map) and isNumber(step.x) and isNumber(step.y) then
        local zone = ns.MapName and ns.MapName(step.map) or nil
        local wx, wy, instance = zoneWorld(step.map, step.x, step.y, zone)
        if not isNumber(wx) and named then
            local hub = resolveNamedPlace(named)
            if hub and isNumber(hub.wx) and isNumber(hub.wy) then
                wx, wy, instance = hub.wx, hub.wy, hub.instance
            end
        end
        return {
            name = named or zone or "destination",
            map = step.map,
            x = step.x,
            y = step.y,
            zone = zone,
            wx = wx,
            wy = wy,
            instance = instance,
            prefer = prefer,
            rawName = named,
        }
    end

    if named then
        local place = resolveNamedPlace(named)
        if place then
            local copy = {}
            for key, value in pairs(place) do
                copy[key] = value
            end
            copy.prefer = prefer
            copy.rawName = named
            return copy
        end
        return {
            name = named,
            zone = named,
            prefer = prefer,
            rawName = named,
        }
    end
end

-- Classic taxi pathfinding uses the full faction network. Discovery only gates
-- which endpoints you can pick; intermediate hubs along the route do not need
-- to be unlocked. Callers must pass an unlocked (or soft-trusted) toId.
local function flightPathSeconds(fromId, toId, unlocked, faction)
    if fromId == toId then
        return 0, { fromId }
    end
    -- Endpoints must be known (or soft-trusted by the caller). Reject early so a
    -- missing DB entry cannot invent flights to pads the player has never learned.
    if type(unlocked) == "table" and not unlocked[toId] then
        return nil
    end
    local best = {}
    local prev = {}
    local queue = {}
    best[fromId] = 0
    queue[1] = fromId
    local head = 1
    while head <= #queue do
        local current = queue[head]
        head = head + 1
        local currentCost = best[current]
        local edges = edgesByFrom[current]
        if edges then
            for index = 1, #edges do
                local edge = edges[index]
                if factionUsable(edge.faction, faction) then
                    local nextCost = currentCost + edge.seconds
                    if not best[edge.to] or nextCost < best[edge.to] then
                        best[edge.to] = nextCost
                        prev[edge.to] = current
                        queue[#queue + 1] = edge.to
                    end
                end
            end
        end
    end
    if not best[toId] then
        return nil
    end
    local path = { toId }
    local cursor = toId
    while cursor ~= fromId do
        cursor = prev[cursor]
        if not cursor then
            return nil
        end
        path[#path + 1] = cursor
    end
    local ordered = {}
    for index = #path, 1, -1 do
        ordered[#ordered + 1] = path[index]
    end
    return best[toId], ordered
end

local function nearestUnlockedFlight(wx, wy, instance, unlocked, faction, sameContinentOnly)
    -- Forever HBD continent ids rarely equal flight JSON 0/1, so never hard-filter
    -- on instance equality. Score every unlocked pad and keep the closest.
    local bestId, bestDist
    local bestSameId, bestSameDist
    for nodeId, node in pairs(nodesById) do
        if unlocked[nodeId] and factionUsable(node.faction, faction) then
            local dist = nodeDistance(wx, wy, instance, node)
            if dist and (not bestDist or dist < bestDist) then
                bestDist = dist
                bestId = nodeId
            end
            if sameContinentOnly
                and isNumber(node.instance)
                and isNumber(instance)
                and node.instance == instance
                and dist
                and (not bestSameDist or dist < bestSameDist)
            then
                bestSameDist = dist
                bestSameId = nodeId
            end
        end
    end
    if bestSameId then
        return bestSameId, bestSameDist
    end
    return bestId, bestDist
end

local function copyWaypoint(wx, wy, instance)
    if not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    return { wx = wx, wy = wy, instance = instance }
end

-- Flight-master matching must use Forever absolute hub/pin coords. Arrow
-- waypoints from PinToPlayerWorld are player-relative and pick the wrong pad
-- when the player is far from the destination (e.g. Camp Taurajo → Crossroads).
local function flightArrivePoint(dest)
    ensureGraph()
    if type(dest) ~= "table" then
        return nil
    end
    if isNumber(dest.nodeId) and nodesById[dest.nodeId] then
        local node = nodesById[dest.nodeId]
        return node.wx, node.wy, node.instance, node.nodeId
    end
    local names = { dest.rawName, dest.name, dest.hub, dest.zone }
    for index = 1, #names do
        local name = names[index]
        if type(name) == "string" and name ~= "" then
            local place = resolveNamedPlace(name)
            if place and isNumber(place.wx) and (place.kind == "flight" or isNumber(place.nodeId)) then
                return place.wx, place.wy, place.instance, place.nodeId
            end
            local node = flightNodeByName(name)
            if node and isNumber(node.wx) then
                return node.wx, node.wy, node.instance, node.nodeId
            end
        end
    end
    if isNumber(dest.map) and isNumber(dest.x) and isNumber(dest.y) then
        local wx, wy, instance = absoluteZoneWorld(dest.map, dest.x, dest.y)
        if isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end
    if isNumber(dest.wx) and isNumber(dest.wy) then
        return dest.wx, dest.wy, dest.instance
    end
end

local function routeWalk(dest, fromWx, fromWy, fromInstance, label)
    local walkWx, walkWy, walkInstance = dest.wx, dest.wy, dest.instance
    if not isNumber(walkWx) or not isNumber(walkWy) then
        walkWx, walkWy, walkInstance = flightArrivePoint(dest)
    end
    if not isNumber(walkWx) or not isNumber(walkWy) then
        return nil
    end
    -- Walking cannot cross continents / transport instances.
    if isNumber(fromInstance) and isNumber(walkInstance) and fromInstance ~= walkInstance then
        return nil
    end
    local yards = worldDistance(fromInstance or walkInstance, fromWx, fromWy, walkWx, walkWy)
    if not yards then
        return nil
    end
    local seconds = walkSeconds(yards)
    return {
        mode = "walk",
        seconds = seconds,
        yards = yards,
        summary = label or ("Run to " .. (dest.name or "destination")),
        details = {},
        waypoint = copyWaypoint(walkWx, walkWy, walkInstance or fromInstance),
        place = {
            map = dest.map,
            x = dest.x,
            y = dest.y,
            zone = dest.zone or dest.name,
        },
        dest = dest,
    }
end

local function routeFly(dest, fromWx, fromWy, fromInstance, unlocked, faction)
    local arriveWx, arriveWy, arriveInstance, knownArriveId = flightArrivePoint(dest)
    local walkWx, walkWy = dest.wx, dest.wy
    if not isNumber(walkWx) or not isNumber(walkWy) then
        walkWx, walkWy = arriveWx, arriveWy
    end
    if not isNumber(arriveWx) or not isNumber(arriveWy) then
        return nil
    end

    -- Nearby flight master: record it even if the taxi UI never wrote it to
    -- WaynotesCharDB (common when catch-up skipped the "get FP" step).
    -- Same-continent only: Sen'jin XY overlaps Revantusk across continents.
    local nearNode, nearDist = nearestFlightNode(fromWx, fromWy, fromInstance, false, false, true)
    local localPadYards = 300
    if nearNode and nearDist and nearDist <= localPadYards then
        markFlightUnlocked(nearNode.nodeId, nearNode.hub)
        unlocked = unlockedFlightPaths()
    end

    -- Soft-trust a named arrive pad only when the guide implies the player
    -- should already know it (Fly/Return). Plain "Travel to Zoram'gar" on a
    -- first visit must fall back to the nearest actually unlocked pad (Sun Rock).
    local trustNamedArrive = knownArriveId
        and nodesById[knownArriveId]
        and (unlocked[knownArriveId] or dest.prefer == "fly")

    local unlockedForPath = unlocked
    if trustNamedArrive and knownArriveId and not unlocked[knownArriveId] then
        unlockedForPath = {}
        for id, value in pairs(unlocked) do
            unlockedForPath[id] = value
        end
        unlockedForPath[knownArriveId] = true
    end

    local departId, departDist = nearestUnlockedFlight(fromWx, fromWy, fromInstance, unlockedForPath, faction, true)
    -- Prefer the local pad when the nearest "unlocked" pad is actually far away
    -- (addon DB missing Camp Taurajo while Crossroads is known).
    if nearNode and nearDist and nearDist <= localPadYards then
        if not departId or not departDist or nearDist + 80 < departDist then
            departId, departDist = nearNode.nodeId, nearDist
            unlockedForPath[departId] = true
            markFlightUnlocked(departId, nearNode.hub)
        end
    end

    local arriveId, arriveDist
    if trustNamedArrive then
        arriveId = knownArriveId
        arriveDist = nodeDistance(arriveWx, arriveWy, arriveInstance or fromInstance, nodesById[arriveId]) or 0
    else
        -- Nearest learned pad to the destination (Sun Rock for west Ashenvale).
        arriveId, arriveDist = nearestUnlockedFlight(arriveWx, arriveWy, arriveInstance or fromInstance, unlocked, faction, true)
    end
    if not departId or not arriveId then
        return nil
    end
    -- Flying only helps when both ends are unlocked and destination is not already at the departure pad.
    if departDist and departDist <= NEAR_YARDS and arriveId == departId then
        return nil
    end
    local flightSeconds, path = flightPathSeconds(departId, arriveId, unlockedForPath, faction)
    if not flightSeconds then
        return nil
    end
    local depart = nodesById[departId]
    local arrive = nodesById[arriveId]
    -- Refine the two winners with HBD; ranking above stayed euclidean.
    departDist = nodeDistancePrecise(fromWx, fromWy, fromInstance, depart) or departDist
    arriveDist = nodeDistancePrecise(arriveWx, arriveWy, arriveInstance or fromInstance, arrive) or arriveDist
    local toPad = walkSeconds(departDist or 0) or 0
    local fromPad = walkSeconds(arriveDist or 0) or 0
    local total = toPad + FLY_BOARD_SECONDS + flightSeconds + fromPad
    local walkYards = worldDistance(fromInstance or arriveInstance or dest.instance, fromWx, fromWy, walkWx, walkWy)
    if not isNumber(walkYards) and isNumber(dest.map) and isNumber(dest.x) and isNumber(dest.y) and ns.PinZoneDistance then
        walkYards = ns.PinZoneDistance(dest.map, dest.x, dest.y, dest.zone)
    end
    if not isNumber(walkYards) and departId ~= arriveId then
        -- Pads differ but world measure failed (Forever instance mismatch). Use
        -- pad separation as a lower bound on the ground route.
        walkYards = nodeDistance(fromWx, fromWy, fromInstance, arrive) or ((departDist or 0) + (arriveDist or 0) + flightRecMinYards())
    end
    local groundYards = (departDist or 0) + (arriveDist or 0)
    local savingsYards
    if isNumber(walkYards) then
        savingsYards = walkYards - groundYards
    end
    local summary
    if departId == arriveId then
        summary = "Run via " .. (depart.hub or "flight master")
    else
        summary = "Fly " .. (depart.hub or "?") .. " -> " .. (arrive.hub or "?")
    end
    local details = {}
    if departDist and departDist > NEAR_YARDS then
        details[#details + 1] = "Go to the " .. (depart.hub or "") .. " flight master"
    end
    if departId ~= arriveId then
        details[#details + 1] = "Fly to " .. (arrive.hub or "destination")
    end
    if arriveDist and arriveDist > NEAR_YARDS then
        details[#details + 1] = "Run to " .. (dest.name or "destination")
    end
    -- Aim at the departure flight master until the player is close enough to board.
    local aim = depart
    if departDist and departDist <= NEAR_YARDS and departId ~= arriveId then
        aim = arrive
    elseif arriveDist and arriveDist <= NEAR_YARDS then
        aim = dest
    end
    return {
        mode = "fly",
        seconds = total,
        yards = walkYards,
        groundYards = groundYards,
        savingsYards = savingsYards,
        departDist = departDist,
        arriveDist = arriveDist,
        summary = summary,
        details = details,
        waypoint = copyWaypoint(aim.wx or dest.wx, aim.wy or dest.wy, aim.instance or dest.instance or fromInstance),
        place = {
            map = aim.map,
            x = aim.x,
            y = aim.y,
            zone = aim.hub or aim.zone or dest.zone,
        },
        departId = departId,
        arriveId = arriveId,
        depart = depart,
        arrive = arrive,
        path = path,
        dest = dest,
    }
end

local function transportVerb(kind)
    if kind == "zeppelin" then
        return "zeppelin"
    end
    if kind == "skycutter" then
        return "skycutter"
    end
    if kind == "ferry" then
        return "ferry"
    end
    return "boat"
end

local function dockAsDest(dock)
    return {
        name = dock.name,
        zone = dock.zone or dock.name,
        map = dock.map,
        wx = dock.wx,
        wy = dock.wy,
        instance = dock.instance,
        dockId = dock.dockId,
        kind = "transport",
    }
end

local function transportPathSeconds(fromId, toId, faction)
    if fromId == toId then
        return 0, { fromId }, nil
    end
    local best = {}
    local prev = {}
    local edgeVia = {}
    local queue = {}
    best[fromId] = 0
    queue[1] = fromId
    local head = 1
    while head <= #queue do
        local current = queue[head]
        head = head + 1
        local currentCost = best[current]
        local edges = transportLegsByFrom[current]
        if edges then
            for index = 1, #edges do
                local edge = edges[index]
                if factionUsable(edge.faction, faction) then
                    local nextCost = currentCost + edge.seconds
                    if not best[edge.to] or nextCost < best[edge.to] then
                        best[edge.to] = nextCost
                        prev[edge.to] = current
                        edgeVia[edge.to] = edge
                        queue[#queue + 1] = edge.to
                    end
                end
            end
        end
    end
    if not best[toId] then
        return nil
    end
    local path = { toId }
    local cursor = toId
    local sampleEdge = edgeVia[toId]
    while cursor ~= fromId do
        cursor = prev[cursor]
        if not cursor then
            return nil
        end
        path[#path + 1] = cursor
        if not sampleEdge and edgeVia[cursor] then
            sampleEdge = edgeVia[cursor]
        end
    end
    local ordered = {}
    for index = #path, 1, -1 do
        ordered[#ordered + 1] = path[index]
    end
    return best[toId], ordered, sampleEdge
end

local function expectedTransportWait(dock)
    local cycle = dock.cycleSeconds or 300
    local dwell = dock.dwellSeconds or 60
    local wait = (cycle - dwell) * 0.5
    if wait < 20 then
        wait = 20
    end
    return wait
end

-- Walk-only approach for boat/zeppelin routing. Calling routeFly per dock was
-- the ~70ms TravelBestPath spike (20+ pads × full flight search).
local function approachDockWalk(dest, fromWx, fromWy, fromInstance)
    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end
    if isNumber(fromInstance) and isNumber(dest.instance) and fromInstance ~= dest.instance then
        return nil
    end
    return routeWalk(dest, fromWx, fromWy, fromInstance)
end

local function routeTransport(dest, fromWx, fromWy, fromInstance, unlocked, faction)
    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end
    if type(docksById) ~= "table" then
        return nil
    end

    local best
    local departures = {}
    for departId, depart in pairs(docksById) do
        if factionUsable(depart.faction, faction)
            and (not isNumber(fromInstance) or not isNumber(depart.instance) or fromInstance == depart.instance)
        then
            local approach = approachDockWalk(dockAsDest(depart), fromWx, fromWy, fromInstance)
            if approach then
                departures[#departures + 1] = { id = departId, dock = depart, approach = approach }
            end
        end
    end
    if #departures == 0 then
        return nil
    end

    local arrivals = {}
    for arriveId, arrive in pairs(docksById) do
        if factionUsable(arrive.faction, faction)
            and (not isNumber(dest.instance) or not isNumber(arrive.instance) or dest.instance == arrive.instance)
        then
            local egress = approachDockWalk(dest, arrive.wx, arrive.wy, arrive.instance)
            if egress then
                arrivals[#arrivals + 1] = { id = arriveId, dock = arrive, egress = egress }
            end
        end
    end
    if #arrivals == 0 then
        return nil
    end

    for d = 1, #departures do
        local dep = departures[d]
        for a = 1, #arrivals do
            local arr = arrivals[a]
            if arr.id ~= dep.id then
                local rideSeconds, path, sampleEdge = transportPathSeconds(dep.id, arr.id, faction)
                if rideSeconds and path and #path >= 2 then
                    local depart = dep.dock
                    local arrive = arr.dock
                    local approach = dep.approach
                    local egress = arr.egress
                    local wait = expectedTransportWait(depart)
                    local total = (approach.seconds or 0) + wait + TRANSPORT_BOARD_SECONDS + rideSeconds + (egress.seconds or 0)
                    local kind = (sampleEdge and sampleEdge.type) or depart.type or "boat"
                    local verb = transportVerb(kind)
                    local fromLabel = depart.name or "dock"
                    local toLabel = arrive.name or "dock"
                    local details = {}
                    if approach.yards and approach.yards > NEAR_YARDS then
                        details[#details + 1] = "Go to the " .. fromLabel .. " " .. verb .. " dock"
                    end
                    details[#details + 1] = "Take the " .. verb .. " to " .. toLabel
                    if egress.yards and egress.yards > NEAR_YARDS then
                        details[#details + 1] = "Run to " .. (dest.name or "destination")
                    end
                    local route = {
                        mode = "transport",
                        seconds = total,
                        summary = "Take the " .. verb .. " " .. fromLabel .. " -> " .. toLabel,
                        details = details,
                        -- Keep the arrow on this continent at the boarding dock.
                        waypoint = copyWaypoint(depart.wx, depart.wy, depart.instance or fromInstance),
                        place = {
                            map = depart.map,
                            zone = depart.zone or fromLabel,
                        },
                        departId = dep.id,
                        arriveId = arr.id,
                        path = path,
                        transportType = kind,
                        routeName = (sampleEdge and sampleEdge.routeName) or depart.routeName,
                        dest = dest,
                    }
                    if not best or total + 0.01 < best.seconds then
                        best = route
                    end
                end
            end
        end
    end
    return best
end

local function routeHearth(dest, fromWx, fromWy, fromInstance, unlocked, faction, requireMatch)
    local ready = hearthReady()
    if not ready then
        return nil
    end
    local place, bindName = resolveBindPlace()
    if not place or not isNumber(place.wx) or not isNumber(place.wy) then
        return nil
    end
    if requireMatch then
        local destName = dest.rawName or dest.name or dest.zone
        if not namesCompatible(bindName, destName)
            and not namesCompatible(place.name, destName)
            and not namesCompatible(place.zone, destName)
        then
            return nil
        end
    end
    -- Walk-only after hearth. Nested routeFly/routeTransport here used to
    -- triple TravelBestPath cost (~100ms spikes). Fly-after-hearth is covered
    -- by the bottom fly-rec chrome once you land.
    local after = routeWalk(dest, place.wx, place.wy, place.instance or fromInstance)
    if not after then
        return nil
    end
    local total = HEARTH_SECONDS + (after.seconds or 0)
    local details = {
        "Use your Hearthstone (" .. (bindName or place.name or "bind") .. ")",
    }
    if (after.yards or 0) > NEAR_YARDS then
        details[#details + 1] = after.summary
    end
    return {
        mode = "hearth",
        seconds = total,
        summary = "Hearth to " .. (bindName or place.name or "bind"),
        details = details,
        waypoint = after.waypoint,
        place = after.place,
        useHearth = true,
        bindName = bindName,
        dest = dest,
    }
end

local function travelBestPathInner(dest, opts)
    ensureGraph()
    if type(dest) ~= "table" then
        return nil
    end
    opts = opts or {}
    local px, py, pinstance = playerPoint()
    if not px then
        -- Without a player position, fall back to a destination pin when known.
        if isNumber(dest.wx) and isNumber(dest.wy) then
            return {
                mode = "walk",
                seconds = 0,
                summary = "Travel to " .. (dest.name or "destination"),
                details = {},
                waypoint = copyWaypoint(dest.wx, dest.wy, dest.instance),
                place = {
                    map = dest.map,
                    x = dest.x,
                    y = dest.y,
                    zone = dest.zone or dest.name,
                },
                dest = dest,
            }
        end
        return nil
    end

    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end

    local cacheKey = routeCacheKey(dest, opts, px, py, pinstance)
    local cached = routeCache[cacheKey]
    if cached ~= nil then
        return cached or nil
    end

    local unlocked = unlockedFlightPaths()
    local faction = playerFaction()
    local candidates = {}
    local flyCandidate

    local walk = routeWalk(dest, px, py, pinstance)
    if walk then
        candidates[#candidates + 1] = walk
    end

    local prefer = opts.prefer or dest.prefer
    local best
    if prefer == "hearth" then
        local hearth = routeHearth(dest, px, py, pinstance, unlocked, faction, true)
        if hearth then
            routeCache[cacheKey] = hearth
            return hearth
        end
    elseif prefer == "fly" then
        local fly = routeFly(dest, px, py, pinstance, unlocked, faction)
        if fly then
            routeCache[cacheKey] = fly
            return fly
        end
    end

    if prefer ~= "hearth" then
        local fly = routeFly(dest, px, py, pinstance, unlocked, faction)
        if fly then
            flyCandidate = fly
            candidates[#candidates + 1] = fly
        end
        -- Boat/zeppelin only when continents disagree or walking is impossible.
        local needBoat = not walk
            or (isNumber(dest.instance) and isNumber(pinstance) and dest.instance ~= pinstance)
        if needBoat then
            local boat = routeTransport(dest, px, py, pinstance, unlocked, faction)
            if boat then
                candidates[#candidates + 1] = boat
            end
        end
    end
    if prefer ~= "fly" then
        local hearth = routeHearth(dest, px, py, pinstance, unlocked, faction, prefer == "hearth")
        if hearth then
            candidates[#candidates + 1] = hearth
        end
    end

    local recommendFly = not ns.db or ns.db.showFlightRecommend ~= false
    local minFlyYards = flightRecMinYards()
    local function flySavesYards(route)
        return recommendFly
            and route
            and route.mode == "fly"
            and route.departId
            and route.arriveId
            and route.departId ~= route.arriveId
            and isNumber(route.savingsYards)
            and route.savingsYards >= minFlyYards
    end

    best = candidates[1]
    for index = 2, #candidates do
        local route = candidates[index]
        if route.seconds + 0.01 < (best.seconds or math.huge) then
            -- Prefer alternate modes only when they beat walking by a useful margin.
            if best.mode == "walk" and route.mode ~= "walk" then
                local timeOk = (best.seconds - route.seconds) >= MIN_IMPROVE_SECONDS
                if timeOk or flySavesYards(route) then
                    best = route
                end
            else
                best = route
            end
        elseif best.mode == "walk" and flySavesYards(route) then
            -- Even when flying is not faster by the time margin, recommend it when
            -- ground travel savings clear the configured yard threshold.
            best = route
        end
    end
    -- Stash fly candidate for the bottom chrome so pulse does not re-run routeFly.
    if best then
        best._flyCandidate = flyCandidate
    end
    -- Cache nil misses as false so repeated sticky polls skip the full search.
    routeCache[cacheKey] = best or false
    if routeCacheGen < 64 then
        routeCacheGen = routeCacheGen + 1
    else
        routeCache = { [cacheKey] = routeCache[cacheKey] }
        routeCacheGen = 1
    end
    return best
end

function ns.TravelBestPath(dest, opts)
    if ns.PerfProbe then
        return ns.PerfProbe("TravelBestPath", travelBestPathInner, dest, opts)
    end
    return travelBestPathInner(dest, opts)
end

function ns.TravelResolveStep(step)
    return destinationFromStep(step)
end

-- Returns a fly route when an unlocked flight path cuts ground travel by at
-- least minYards (default: ns.db.flightRecommendMinYards or 500).
local function travelFlightRecommendationInner(dest, minYards)
    ensureGraph()
    if type(dest) ~= "table" then
        return nil
    end
    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        local arriveWx, arriveWy, arriveInstance = flightArrivePoint(dest)
        if not isNumber(arriveWx) then
            return nil
        end
        dest = {
            name = dest.name,
            zone = dest.zone,
            hub = dest.hub,
            rawName = dest.rawName,
            map = dest.map,
            x = dest.x,
            y = dest.y,
            nodeId = dest.nodeId,
            wx = dest.wx or arriveWx,
            wy = dest.wy or arriveWy,
            instance = dest.instance or arriveInstance,
        }
    end
    if type(minYards) ~= "number" then
        minYards = flightRecMinYards()
    end
    local px, py, pinstance = playerPoint()
    if not px then
        return nil
    end
    local unlocked = unlockedFlightPaths()
    local faction = playerFaction()
    local fly = routeFly(dest, px, py, pinstance, unlocked, faction)
    if not fly
        or not fly.departId
        or not fly.arriveId
        or fly.departId == fly.arriveId
        or not isNumber(fly.savingsYards)
        or fly.savingsYards < minYards
    then
        return nil
    end
    return fly
end

function ns.TravelFlightRecommendation(dest, minYards)
    if ns.PerfProbe then
        return ns.PerfProbe("TravelFlightRecommendation", travelFlightRecommendationInner, dest, minYards)
    end
    return travelFlightRecommendationInner(dest, minYards)
end

function ns.TravelFillDestinationCoords(dest, step)
    if type(dest) ~= "table" then
        return dest
    end
    if isNumber(dest.wx) and isNumber(dest.wy) then
        return dest
    end
    if type(step) == "table" and isNumber(step.map) and isNumber(step.x) and isNumber(step.y) then
        local zone = ns.MapName and ns.MapName(step.map) or dest.zone
        local wx, wy, instance = zoneWorld(step.map, step.x, step.y, zone)
        dest.map, dest.x, dest.y = step.map, step.x, step.y
        dest.zone = zone or dest.zone
        dest.wx, dest.wy, dest.instance = wx, wy, instance
    end
    return dest
end

-- /waynotes fly — dump why a flight recommendation is or is not showing.
function ns.TravelDebugFlight()
    ensureGraph()
    local function say(line)
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes fly|r " .. tostring(line))
        end
    end
    local function fmt(value)
        if value == nil then
            return "nil"
        end
        if type(value) == "number" then
            return string.format("%.1f", value)
        end
        return tostring(value)
    end

    say("--- flight recommend debug ---")
    local db = ns.db or {}
    say(string.format(
        "settings show=%s minYards=%s forever=%s",
        tostring(db.showFlightRecommend),
        tostring(db.flightRecommendMinYards or flightRecMinYards()),
        tostring(ns.IsForever and ns.IsForever() or false)
    ))

    local rawA, rawB
    if type(UnitPosition) == "function" then
        local ok, a, b = pcall(UnitPosition, "player")
        if ok then
            rawA, rawB = a, b
        end
    end
    local px, py, pinstance = playerPoint()
    local playerSource = "none"
    do
        local hbd = getHBD()
        if hbd and hbd.GetPlayerWorldPosition then
            local ok, wx, wy = pcall(hbd.GetPlayerWorldPosition, hbd)
            if ok and isNumber(wx) and isNumber(wy) then
                playerSource = "hbd"
            end
        end
        if playerSource == "none" and px then
            playerSource = "UnitPosition"
        end
    end
    say(string.format(
        "player wx=%s wy=%s instance=%s source=%s zone=%s",
        fmt(px),
        fmt(py),
        fmt(pinstance),
        playerSource,
        tostring(GetRealZoneText and GetRealZoneText() or "?")
    ))
    say(string.format(
        "UnitPosition raw a=%s b=%s fitAB=%s fitBA=%s",
        fmt(rawA),
        fmt(rawB),
        fmt(nearestPadFit(rawA, rawB)),
        fmt(nearestPadFit(rawB, rawA))
    ))
    if px then
        say(string.format(
            "dist to Taurajo(77)=%s Crossroads(25)=%s Revantusk(76)=%s",
            fmt(nodesById[77] and nodeDistance(px, py, pinstance, nodesById[77])),
            fmt(nodesById[25] and nodeDistance(px, py, pinstance, nodesById[25])),
            fmt(nodesById[76] and nodeDistance(px, py, pinstance, nodesById[76]))
        ))
    end

    local step, stepIndex
    if ns.GuidePrimaryStep then
        step, stepIndex = ns.GuidePrimaryStep()
    end
    if step then
        local text = plainGuideText(step.text) or "?"
        if #text > 70 then
            text = text:sub(1, 70) .. "..."
        end
        say(string.format(
            "step #%s when=%s travel=%s map=%s x=%s y=%s",
            tostring(stepIndex or step.index),
            tostring(step.when),
            tostring(ns.TravelIsTravelStep and ns.TravelIsTravelStep(step)),
            tostring(step.map),
            fmt(step.x),
            fmt(step.y)
        ))
        say("text: " .. text)
        local named, prefer = extractDestinationName(step.text)
        say(string.format("extract named=%s prefer=%s", tostring(named), tostring(prefer)))
    else
        say("step: none (GuidePrimaryStep returned nil)")
    end

    local dest = ns.GuideTravelDestination and select(1, ns.GuideTravelDestination()) or nil
    if not dest and step then
        dest = destinationFromStep(step)
        if ns.TravelFillDestinationCoords then
            dest = ns.TravelFillDestinationCoords(dest, step) or dest
        end
    end
    if dest then
        say(string.format(
            "dest name=%s raw=%s zone=%s nodeId=%s prefer=%s",
            tostring(dest.name),
            tostring(dest.rawName),
            tostring(dest.zone),
            tostring(dest.nodeId),
            tostring(dest.prefer)
        ))
        say(string.format(
            "dest wx=%s wy=%s instance=%s map=%s x=%s y=%s",
            fmt(dest.wx),
            fmt(dest.wy),
            fmt(dest.instance),
            tostring(dest.map),
            fmt(dest.x),
            fmt(dest.y)
        ))
        local ax, ay, ainst, aid = flightArrivePoint(dest)
        local namedKnown = aid and unlockedFlightPaths()[aid] and true or false
        local trustNamed = aid and nodesById[aid] and (namedKnown or dest.prefer == "fly")
        say(string.format(
            "arrivePoint wx=%s wy=%s instance=%s nodeId=%s hub=%s known=%s trust=%s",
            fmt(ax),
            fmt(ay),
            fmt(ainst),
            tostring(aid),
            tostring(aid and nodesById[aid] and nodesById[aid].hub),
            tostring(namedKnown),
            tostring(trustNamed and true or false)
        ))
    else
        say("dest: nil")
    end

    local unlocked = unlockedFlightPaths()
    local unlockedList = {}
    for id in pairs(unlocked) do
        unlockedList[#unlockedList + 1] = id
    end
    table.sort(unlockedList)
    local unlockedText = {}
    for index = 1, math.min(#unlockedList, 12) do
        local id = unlockedList[index]
        local node = nodesById[id]
        unlockedText[#unlockedText + 1] = id .. "=" .. (node and (node.hub or "?") or "?")
    end
    say(string.format(
        "unlocked count=%d %s%s",
        #unlockedList,
        table.concat(unlockedText, ", "),
        #unlockedList > 12 and ", ..." or ""
    ))
    for _, id in ipairs({ 25, 77 }) do
        local node = nodesById[id]
        say(string.format(
            "node %d %s unlocked=%s wx=%s wy=%s instance=%s",
            id,
            node and (node.hub or "?") or "missing",
            tostring(unlocked[id] and true or false),
            fmt(node and node.wx),
            fmt(node and node.wy),
            fmt(node and node.instance)
        ))
    end

    if px then
        local faction = playerFaction()
        local nearAny, nearAnyDist = nearestFlightNode(px, py, pinstance, false, false, false)
        local nearSame, nearSameDist = nearestFlightNode(px, py, pinstance, false, false, true)
        local nearUnlearned, nearUnlearnedDist = nearestFlightNode(px, py, pinstance, false, true, true)
        local nearUn, nearUnDist = nearestUnlockedFlight(px, py, pinstance, unlocked, faction, true)
        say(string.format(
            "nearestAny id=%s hub=%s dist=%s",
            tostring(nearAny and nearAny.nodeId),
            tostring(nearAny and nearAny.hub),
            fmt(nearAnyDist)
        ))
        say(string.format(
            "nearestSameContinent id=%s hub=%s dist=%s",
            tostring(nearSame and nearSame.nodeId),
            tostring(nearSame and nearSame.hub),
            fmt(nearSameDist)
        ))
        say(string.format(
            "nearestUnlearnedSame id=%s hub=%s dist=%s",
            tostring(nearUnlearned and nearUnlearned.nodeId),
            tostring(nearUnlearned and nearUnlearned.hub),
            fmt(nearUnlearnedDist)
        ))
        say(string.format(
            "nearestUnlocked id=%s hub=%s dist=%s",
            tostring(nearUn),
            tostring(nearUn and nodesById[nearUn] and nodesById[nearUn].hub),
            fmt(nearUnDist)
        ))
    end

    local fly
    local reject
    if not dest then
        reject = "no dest"
    elseif not px then
        reject = "no player point"
    else
        fly = routeFly(dest, px, py, pinstance, unlocked, playerFaction())
        if not fly then
            reject = "routeFly nil"
        elseif fly.departId == fly.arriveId then
            reject = "same pad " .. tostring(fly.departId)
        elseif not isNumber(fly.savingsYards) then
            reject = "no savingsYards"
        elseif fly.savingsYards < flightRecMinYards() then
            reject = string.format("savings %.1f < min %d", fly.savingsYards, flightRecMinYards())
        end
    end

    if fly then
        say(string.format(
            "routeFly mode=%s %s -> %s seconds=%.1f walk=%s ground=%s savings=%s",
            tostring(fly.mode),
            tostring(fly.depart and fly.depart.hub or fly.departId),
            tostring(fly.arrive and fly.arrive.hub or fly.arriveId),
            fly.seconds or 0,
            fmt(fly.yards),
            fmt(fly.groundYards),
            fmt(fly.savingsYards)
        ))
        say("summary: " .. tostring(fly.summary))
    else
        say("routeFly: nil (" .. (reject or "?") .. ")")
    end

    local rec = dest and ns.TravelFlightRecommendation(dest) or nil
    say("TravelFlightRecommendation: " .. (rec and (rec.summary .. " savings=" .. fmt(rec.savingsYards)) or "nil"))

    local best = dest and ns.TravelBestPath(dest) or nil
    say("TravelBestPath: " .. (best and (tostring(best.mode) .. " " .. tostring(best.summary)) or "nil"))

    local active = ns.TravelActiveFlightRecommendation and ns.TravelActiveFlightRecommendation()
    say("activeFlightRec: " .. (active and (active.summary .. " savings=" .. fmt(active.savingsYards)) or "nil"))

    local state = ns.ReplaceState and ns.ReplaceState.flyRec
    if state then
        say(string.format(
            "strip chrome=%s shown=%s dismissed=%s route=%s",
            tostring(state.chrome),
            tostring(state.strip and state.strip:IsShown()),
            tostring(state.dismissed),
            tostring(state.route and state.route.summary)
        ))
    else
        say("strip state: missing")
    end
    say("--- end ---")
end

local function travelDestinationName(step)
    if type(step.travel) == "string" then
        return step.travel
    end
    if type(step.travel) == "table" then
        return step.travel.name
    end
    return (extractDestinationName(step.text))
end

-- "Travel to Stonetalon Mountains" names a whole zone, so crossing into it
-- counts as arrival even when the pin sits at a border camp in the last zone.
local function playerInDestinationZone(step)
    local key = normalizeName(travelDestinationName(step))
    if not key or not GetRealZoneText then
        return false
    end
    return normalizeName(GetRealZoneText()) == key
end

-- when = "travel" advances once the player is near the step destination,
-- or inside the zone the step names. Multi-pin travel paths complete at the
-- last pin (intermediate pins are waypoints along the route) and never by
-- zone-name match alone.
function ns.TravelStepDone(step)
    if type(step) ~= "table" then
        return false
    end
    local multiPin = type(step.pins) == "table" and #step.pins > 1
    if not multiPin and playerInDestinationZone(step) then
        return true
    end
    local dest = destinationFromStep(step)
    if multiPin then
        local last = step.pins[#step.pins]
        if type(last) == "table" and isNumber(last.x) and isNumber(last.y) then
            local map = tonumber(last.map) or step.map or (dest and dest.map)
            local zone = last.zone or (dest and dest.zone)
            dest = {
                map = map,
                x = last.x,
                y = last.y,
                zone = zone,
            }
            if isNumber(map) and ns.PinToPlayerWorld then
                local wx, wy, instance = ns.PinToPlayerWorld(map, last.x, last.y, zone)
                if isNumber(wx) then
                    dest.wx, dest.wy, dest.instance = wx, wy, instance
                end
            end
        end
    end
    if not dest then
        return false
    end
    local radius = TRAVEL_ARRIVE_YARDS
    if isNumber(step.arriveYards) and step.arriveYards > 0 then
        radius = step.arriveYards
    elseif type(step.travel) == "table" and isNumber(step.travel.arriveYards) and step.travel.arriveYards > 0 then
        radius = step.travel.arriveYards
    end
    -- Same-zone pins measure in zone percents. The world point from
    -- PinToPlayerWorld is player-relative and does not line up with HBD's
    -- player world position on Forever, so it can never read as arrived.
    if isNumber(dest.map) and isNumber(dest.x) and isNumber(dest.y) and ns.PinZoneDistance then
        local yards = ns.PinZoneDistance(dest.map, dest.x, dest.y, dest.zone)
        if isNumber(yards) then
            return yards <= radius
        end
    end
    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        return false
    end
    local px, py, pinstance = playerPoint()
    if not px then
        return false
    end
    if isNumber(dest.instance) and isNumber(pinstance) and dest.instance ~= pinstance then
        return false
    end
    local dist = worldDistance(pinstance or dest.instance, px, py, dest.wx, dest.wy)
    if not dist then
        return false
    end
    return dist <= radius
end

local function pushDetail(item, line)
    if type(item) ~= "table" or type(line) ~= "string" or line == "" then
        return
    end
    local details = item.details
    if type(details) ~= "table" then
        details = {}
        item.details = details
    end
    local key = line:lower()
    for index = 1, #details do
        if details[index]:lower() == key then
            return
        end
        -- Avoid duplicating authored "Get the X flight path" lines.
        if key:find("flight path", 1, true) and details[index]:lower():find("flight path", 1, true) then
            return
        end
    end
    if #details >= 6 then
        return
    end
    details[#details + 1] = line
end

local function applyNearbyFlightTip(item, step)
    local nearby = ns.TravelNearbyUnlearnedFlight(NEARBY_FP_YARDS)
    if not nearby then
        return item
    end
    local target = flightPathTargetFromStep(step)
    if target and isNumber(target.nodeId) and target.nodeId == nearby.nodeId then
        pushDetail(item, "Get the " .. (nearby.name or "local") .. " flight path")
        return item
    end
    local named, prefer = extractDestinationName(step and step.text)
    if named and namesCompatible(named, nearby.name) then
        pushDetail(item, "Get the " .. (nearby.name or "local") .. " flight path while you are here")
        return item
    end
    if prefer then
        -- Travel/fly/hearth steps already have a destination; keep the tip short.
    end
    pushDetail(item, "Nearby: get the " .. (nearby.name or "local") .. " flight path")
    return item
end

function ns.TravelApplyToItem(item, step)
    if type(item) ~= "table" or type(step) ~= "table" then
        return item
    end

    -- Route any step with a resolvable destination (travel wording, authored
    -- pins on general steps, named hubs, flight-path pickups). Walk stays
    -- silent; fly/boat/hearth only surface when they beat walking by enough.
    local dest = destinationFromStep(step)
    if dest then
        -- Authored pins fill missing world coords; named hubs keep their pads.
        if isNumber(step.map) and isNumber(step.x) and isNumber(step.y) and not isNumber(dest.wx) then
            local zone = ns.MapName and ns.MapName(step.map) or dest.zone
            local wx, wy, instance = zoneWorld(step.map, step.x, step.y, zone)
            dest.map, dest.x, dest.y = step.map, step.x, step.y
            dest.zone = zone or dest.zone
            dest.wx, dest.wy, dest.instance = wx, wy, instance
        end

        -- Never run TravelBestPath during tracker rebuilds (was ~126ms spikes).
        -- Primary routing + fly-rec are computed on TravelPulsePrimaryRoute.
        if isNumber(dest.wx) and isNumber(dest.wy) and not item.waypoint then
            item.waypoint = copyWaypoint(dest.wx, dest.wy, dest.instance)
        end
        if isNumber(dest.x) and isNumber(dest.y) then
            item.place = {
                map = dest.map,
                x = dest.x,
                y = dest.y,
                zone = dest.zone or dest.name,
            }
        elseif not item.place and (dest.zone or dest.name) then
            item.place = {
                map = dest.map,
                zone = dest.zone or dest.name,
            }
        end

        if dest.pickup and isNumber(dest.nodeId) then
            local unlocked = unlockedFlightPaths()
            if unlocked[dest.nodeId] then
                pushDetail(item, "Flight path already learned")
            else
                pushDetail(item, "Get the " .. (dest.name or "local") .. " flight path")
            end
        end
    end

    applyNearbyFlightTip(item, step)
    return item
end

-- Compute primary BestPath + fly-rec off the rebuild path. Call from OnUpdate.
function ns.TravelPulsePrimaryRoute()
    local dest, step, stepIndex
    if ns.GuideTravelDestination then
        dest, step, stepIndex = ns.GuideTravelDestination()
    end
    if type(dest) ~= "table" then
        activeFlightRec = nil
        activeHearthRec = nil
        if ns.OnTravelRouteReady then
            ns.OnTravelRouteReady(nil, nil, nil, nil)
        end
        return nil
    end
    if step and isNumber(step.map) and isNumber(step.x) and isNumber(step.y) and not isNumber(dest.wx) then
        dest = ns.TravelFillDestinationCoords(dest, step) or dest
    end
    local route = ns.TravelBestPath(dest)
    activeFlightRec = nil
    activeHearthRec = nil
    if route and route.mode == "fly" then
        rememberFlightRec(route)
    elseif route and route._flyCandidate then
        rememberFlightRec(route._flyCandidate)
    elseif not dest.pickup then
        -- Fallback only when BestPath had no fly candidate (rare).
        local travelStep = not step
            or not ns.TravelIsTravelStep
            or ns.TravelIsTravelStep(step)
        if travelStep then
            rememberFlightRec(ns.TravelFlightRecommendation(dest))
        end
    end
    -- Hearth tip for bottom chrome only when it saves over walking.
    if not dest.pickup then
        activeHearthRec = hearthRecommendation(dest, route)
    end
    if ns.OnTravelRouteReady then
        ns.OnTravelRouteReady(route, dest, step, stepIndex)
    end
    return route
end

-- Events: learn unlocked flight paths whenever the taxi map is available;
-- advance hearth-bind steps when the bind location changes.
do
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("TAXIMAP_OPENED")
    frame:RegisterEvent("UI_INFO_MESSAGE")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("GOSSIP_CLOSED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    pcall(frame.RegisterEvent, frame, "BAG_UPDATE_COOLDOWN")
    pcall(frame.RegisterEvent, frame, "HEARTHSTONE_BOUND")
    local function refresh()
        if hearthButton then
            updateHearthCooldown(hearthButton)
        end
        if ns.GuideCatchUp then
            pcall(ns.GuideCatchUp)
        end
        -- Coalesce; never RefreshTracker(true) inline (that was a 45ms cast hitch).
        if ns.MarkTrackerDirty then
            ns.MarkTrackerDirty(true)
        elseif ns.RefreshTracker then
            pcall(ns.RefreshTracker, true)
        end
    end

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "ZONE_CHANGED_NEW_AREA" then
            -- Recompute BestPath once on real zone changes, not subzone chatter.
            ns.TravelInvalidateRoutes()
            if ns.RequestPrimaryRoute then
                ns.RequestPrimaryRoute()
            end
            return
        end
        if event == "TAXIMAP_OPENED" then
            ns.TravelRememberOpenTaxiNodes()
            refresh()
            return
        end
        if event == "HEARTHSTONE_BOUND" or event == "GOSSIP_CLOSED" then
            refresh()
            return
        end
        if event == "BAG_UPDATE_COOLDOWN" or event == "PLAYER_REGEN_ENABLED" then
            -- BAG_UPDATE_COOLDOWN fires on cast GCD / item CD updates. Only the
            -- hearth button needs that; a full forced tracker rebuild was the
            -- every-cast ~45ms spike.
            if hearthButton then
                updateHearthCooldown(hearthButton)
            end
            return
        end
        if event == "UI_INFO_MESSAGE" then
            local arg1, arg2 = ...
            local message = arg2 or arg1
            if message == _G.ERR_NEWTAXIPATH or message == _G.ERR_TAXINOPATHS then
                ns.TravelRememberNearestFlight()
                refresh()
            end
        end
    end)
end
