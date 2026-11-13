local _, ns = ...

-- Travel.lua: pick the best next hop for travel steps using walk cost,
-- unlocked flight paths (NavFlightConnections), and hearthstone location.

local RUN_YARDS_PER_SEC = 10
local FLY_BOARD_SECONDS = 12
local HEARTH_SECONDS = 15
local MIN_IMPROVE_SECONDS = 25
local NEAR_YARDS = 80
local HEARTHSTONE_ITEM = 6948

local nodesById
local edgesByFrom
local placeIndex
local aliasIndex
local graphBuilt = false

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

local function playerPoint()
    local hbd = getHBD()
    if not hbd or type(hbd.GetPlayerWorldPosition) ~= "function" then
        return nil
    end
    local ok, wx, wy, instance = pcall(hbd.GetPlayerWorldPosition, hbd)
    if not ok or not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    return wx, wy, instance
end

local function worldDistance(instance, ax, ay, bx, by)
    local hbd = getHBD()
    if not hbd or not isNumber(ax) or not isNumber(bx) then
        return nil
    end
    if not isNumber(instance) then
        instance = 0
    end
    if type(hbd.GetWorldDistance) == "function" then
        local ok, yards = pcall(hbd.GetWorldDistance, hbd, instance, ax, ay, bx, by)
        if ok and isNumber(yards) then
            return yards
        end
    end
    if type(hbd.GetWorldVector) == "function" then
        local ok, _, yards = pcall(hbd.GetWorldVector, hbd, instance, ax, ay, bx, by)
        if ok and isNumber(yards) then
            return yards
        end
    end
    local dx, dy = ax - bx, ay - by
    return math.sqrt(dx * dx + dy * dy)
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
    for _, place in pairs(placeIndex) do
        if type(place) == "table" and place.kind == "inn" and not isNumber(place.wx) then
            local wx, wy, instance = zoneWorld(place.map, place.x, place.y, place.zone)
            if wx then
                place.wx, place.wy, place.instance = wx, wy, instance
            end
        end
    end
end

local function ensureGraph()
    if graphBuilt then
        fillMissingInnCoords()
        return
    end
    graphBuilt = true
    nodesById = {}
    edgesByFrom = {}
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
end

local function unlockedFlightPaths()
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
    return unlocked
end

local function markFlightUnlocked(nodeId, name)
    nodeId = tonumber(nodeId)
    if not nodeId then
        return
    end
    local db = charDB().flightPaths
    if type(name) == "string" and name ~= "" then
        db[nodeId] = name
    elseif not db[nodeId] then
        db[nodeId] = true
    end
end

local function matchNodeIdByTaxiName(taxiName)
    ensureGraph()
    local key = normalizeName(taxiName)
    if not key then
        return nil
    end
    for nodeId, node in pairs(nodesById) do
        local hub = normalizeName(node.hub)
        local zone = normalizeName(node.zone)
        local name = normalizeName(node.name)
        if key == hub or key == zone or key == name then
            return nodeId
        end
        if hub and key:find(hub, 1, true) then
            return nodeId
        end
        if name and key:find(name, 1, true) then
            return nodeId
        end
    end
end

function ns.TravelRememberOpenTaxiNodes()
    ensureGraph()
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
    local faction = playerFaction()
    local bestId, bestDist
    for nodeId, node in pairs(nodesById) do
        if factionUsable(node.faction, faction) and (not isNumber(node.instance) or node.instance == instance) then
            local dist = worldDistance(instance, px, py, node.wx, node.wy)
            if dist and (not bestDist or dist < bestDist) then
                bestDist = dist
                bestId = nodeId
            end
        end
    end
    if bestId and bestDist and bestDist <= 200 then
        markFlightUnlocked(bestId, nodesById[bestId].hub)
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

local function extractDestinationName(text)
    if type(text) ~= "string" then
        return nil, nil
    end
    text = strtrim(text)
    text = text:gsub("^%[[^%]]+%]%s*", "")
    local patterns = {
        { "^Hearth%s+to%s+(.-)%.?$", "hearth" },
        { "^Fly%s+to%s+(.-)%.?$", "fly" },
        { "^Travel%s+back%s+to%s+(.-)%.?$", "travel" },
        { "^Travel%s+toward%s+(.-)%.?$", "travel" },
        { "^Travel%s+to%s+(.-)%.?$", "travel" },
        { "^Run%s+to%s+(.-)%.?$", "travel" },
        { "^Run%s+back%s+to%s+(.-)%.?$", "travel" },
    }
    for index = 1, #patterns do
        local dest = text:match(patterns[index][1])
        if dest then
            dest = dest:gsub("%s+and%s+enter.*$", "")
            dest = dest:gsub("%s+through%s+the%s+sewers.*$", "")
            dest = strtrim(dest)
            if dest ~= "" then
                return dest, patterns[index][2]
            end
        end
    end
end

function ns.TravelIsTravelStep(step)
    if type(step) ~= "table" then
        return false
    end
    if step.travel then
        return true
    end
    local text = step.text
    if type(text) ~= "string" then
        return false
    end
    text = text:gsub("^%[[^%]]+%]%s*", "")
    if text:match("^Travel")
        or text:match("^Fly%s+to")
        or text:match("^Hearth%s+to")
        or text:match("^Run%s+to")
        or text:match("^Run%s+back%s+to")
    then
        return true
    end
    return false
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

    local prefer
    local named
    named, prefer = extractDestinationName(step.text)
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

    if isNumber(step.map) and isNumber(step.x) and isNumber(step.y) then
        local zone = ns.MapName and ns.MapName(step.map) or nil
        local wx, wy, instance = zoneWorld(step.map, step.x, step.y, zone)
        return {
            name = zone or "destination",
            map = step.map,
            x = step.x,
            y = step.y,
            zone = zone,
            wx = wx,
            wy = wy,
            instance = instance,
        }
    end
end

local function flightPathSeconds(fromId, toId, unlocked, faction)
    if fromId == toId then
        return 0, { fromId }
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
                if unlocked[edge.to] and factionUsable(edge.faction, faction) then
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
    local bestId, bestDist
    for nodeId, node in pairs(nodesById) do
        if unlocked[nodeId] and factionUsable(node.faction, faction) then
            if not sameContinentOnly or not isNumber(node.instance) or not isNumber(instance) or node.instance == instance then
                local dist = worldDistance(instance or node.instance, wx, wy, node.wx, node.wy)
                if dist and (not bestDist or dist < bestDist) then
                    bestDist = dist
                    bestId = nodeId
                end
            end
        end
    end
    return bestId, bestDist
end

local function copyWaypoint(wx, wy, instance)
    if not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    return { wx = wx, wy = wy, instance = instance }
end

local function routeWalk(dest, fromWx, fromWy, fromInstance, label)
    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end
    local yards = worldDistance(fromInstance or dest.instance, fromWx, fromWy, dest.wx, dest.wy)
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
        waypoint = copyWaypoint(dest.wx, dest.wy, dest.instance or fromInstance),
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
    if not isNumber(dest.wx) or not isNumber(dest.wy) then
        return nil
    end
    local departId, departDist = nearestUnlockedFlight(fromWx, fromWy, fromInstance, unlocked, faction, true)
    local arriveId, arriveDist = nearestUnlockedFlight(dest.wx, dest.wy, dest.instance or fromInstance, unlocked, faction, true)
    if not departId or not arriveId then
        return nil
    end
    -- Flying only helps when both ends are unlocked and destination is not already at the departure pad.
    if departDist and departDist <= NEAR_YARDS and arriveId == departId then
        return nil
    end
    local flightSeconds, path = flightPathSeconds(departId, arriveId, unlocked, faction)
    if not flightSeconds then
        return nil
    end
    local depart = nodesById[departId]
    local arrive = nodesById[arriveId]
    local toPad = walkSeconds(departDist or 0) or 0
    local fromPad = walkSeconds(arriveDist or 0) or 0
    local total = toPad + FLY_BOARD_SECONDS + flightSeconds + fromPad
    local summary
    if departId == arriveId then
        summary = "Run via " .. (depart.hub or "flight master")
    else
        summary = "Fly " .. (depart.hub or "?") .. " → " .. (arrive.hub or "?")
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
        path = path,
        dest = dest,
    }
end

local function namesCompatible(a, b)
    local na, nb = normalizeName(a), normalizeName(b)
    if not na or not nb then
        return false
    end
    return na == nb or na:find(nb, 1, true) or nb:find(na, 1, true)
end

local function routeHearth(dest, fromWx, fromWy, fromInstance, unlocked, faction, requireMatch)
    local ready = hearthReady()
    if not ready then
        return nil
    end
    local place, bindName = bindPlace()
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
    local afterWalk = routeWalk(dest, place.wx, place.wy, place.instance or fromInstance)
    if not afterWalk then
        return nil
    end
    local flyAfter = routeFly(dest, place.wx, place.wy, place.instance or fromInstance, unlocked, faction)
    local after = afterWalk
    if flyAfter and flyAfter.seconds + 1 < afterWalk.seconds then
        after = flyAfter
    end
    local total = HEARTH_SECONDS + (after.seconds or 0)
    local details = {
        "Use your Hearthstone (" .. (bindName or place.name or "bind") .. ")",
    }
    for index = 1, #(after.details or {}) do
        details[#details + 1] = after.details[index]
    end
    if after.mode == "walk" and (after.yards or 0) > NEAR_YARDS then
        details[#details + 1] = after.summary
    end
    return {
        mode = after.mode == "fly" and "hearth+fly" or "hearth",
        seconds = total,
        summary = "Hearth to " .. (bindName or place.name or "bind") .. (after.mode == "fly" and (", then " .. after.summary) or ""),
        details = details,
        waypoint = after.waypoint,
        place = after.place,
        useHearth = true,
        bindName = bindName,
        dest = dest,
    }
end

function ns.TravelBestPath(dest, opts)
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

    local unlocked = unlockedFlightPaths()
    local faction = playerFaction()
    local candidates = {}

    local walk = routeWalk(dest, px, py, pinstance)
    if walk then
        candidates[#candidates + 1] = walk
    end

    local prefer = opts.prefer or dest.prefer
    if prefer == "hearth" then
        local hearth = routeHearth(dest, px, py, pinstance, unlocked, faction, true)
        if hearth then
            return hearth
        end
    elseif prefer == "fly" then
        local fly = routeFly(dest, px, py, pinstance, unlocked, faction)
        if fly then
            return fly
        end
    end

    if prefer ~= "hearth" then
        local fly = routeFly(dest, px, py, pinstance, unlocked, faction)
        if fly then
            candidates[#candidates + 1] = fly
        end
    end
    if prefer ~= "fly" then
        local hearth = routeHearth(dest, px, py, pinstance, unlocked, faction, prefer == "hearth")
        if hearth then
            candidates[#candidates + 1] = hearth
        end
    end

    local best = candidates[1]
    for index = 2, #candidates do
        local route = candidates[index]
        if route.seconds + 0.01 < (best.seconds or math.huge) then
            -- Prefer alternate modes only when they beat walking by a useful margin.
            if best.mode == "walk" and route.mode ~= "walk" then
                if (best.seconds - route.seconds) >= MIN_IMPROVE_SECONDS then
                    best = route
                end
            else
                best = route
            end
        end
    end
    return best
end

function ns.TravelResolveStep(step)
    return destinationFromStep(step)
end

function ns.TravelApplyToItem(item, step)
    if type(item) ~= "table" or type(step) ~= "table" then
        return item
    end
    if not ns.TravelIsTravelStep(step) then
        return item
    end

    local dest = destinationFromStep(step)
    if not dest then
        return item
    end

    -- Authored pins win for destination coordinates when present.
    if isNumber(step.map) and isNumber(step.x) and isNumber(step.y) and not isNumber(dest.wx) then
        local zone = ns.MapName and ns.MapName(step.map) or dest.zone
        local wx, wy, instance = zoneWorld(step.map, step.x, step.y, zone)
        dest.map, dest.x, dest.y = step.map, step.x, step.y
        dest.zone = zone or dest.zone
        dest.wx, dest.wy, dest.instance = wx, wy, instance
    end

    local route = ns.TravelBestPath(dest)
    if not route then
        if isNumber(dest.wx) and isNumber(dest.wy) and not item.waypoint then
            item.waypoint = copyWaypoint(dest.wx, dest.wy, dest.instance)
            item.place = {
                map = dest.map,
                x = dest.x,
                y = dest.y,
                zone = dest.zone or dest.name,
            }
        end
        return item
    end

    item.travel = route
    if route.waypoint then
        item.waypoint = route.waypoint
    end
    if route.place and (route.place.x or route.place.zone) then
        item.place = route.place
    elseif dest.map and dest.x and dest.y then
        item.place = {
            map = dest.map,
            x = dest.x,
            y = dest.y,
            zone = dest.zone or dest.name,
        }
    end

    if route.mode ~= "walk" and type(route.summary) == "string" and route.summary ~= "" then
        local details = item.details
        if type(details) ~= "table" then
            details = {}
            item.details = details
        end
        local seen = {}
        for index = 1, #details do
            seen[details[index]:lower()] = true
        end
        local function push(line)
            if type(line) ~= "string" or line == "" then
                return
            end
            local key = line:lower()
            if seen[key] or #details >= 6 then
                return
            end
            seen[key] = true
            details[#details + 1] = line
        end
        push(route.summary)
        for index = 1, #(route.details or {}) do
            push(route.details[index])
        end
    end

    return item
end

-- Events: learn unlocked flight paths whenever the taxi map is available.
do
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("TAXIMAP_OPENED")
    frame:RegisterEvent("UI_INFO_MESSAGE")
    local function refresh()
        if ns.RefreshTracker then
            pcall(ns.RefreshTracker, true)
        end
    end

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "TAXIMAP_OPENED" then
            ns.TravelRememberOpenTaxiNodes()
            refresh()
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
