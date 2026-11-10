local _, ns = ...

local factsCache = {}
local areaMap
local areaMapTried = false

function ns.IsForever()
    local version = select(4, GetBuildInfo())
    return type(version) == "number" and version > 16000 and version < 20000
end

function ns.QuestieReady()
    return type(QuestDB) == "table" and type(QuestDB.name) == "function"
end

local function call(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, a, b, c = pcall(fn, ...)
    if not ok then
        return nil
    end
    return a, b, c
end

local function textOrNil(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end
    return value
end

local function numberOrNil(value)
    if type(value) ~= "number" or value == 0 then
        return nil
    end
    return value
end

local function firstId(list)
    if type(list) ~= "table" then
        return nil
    end
    for _, id in ipairs(list) do
        if type(id) == "number" and id > 0 then
            return id
        end
    end
end

local function entityName(db, id)
    if type(db) ~= "table" or type(id) ~= "number" then
        return nil
    end
    return textOrNil(call(db.name, id))
end

local function readAreaMap()
    local map = {}
    local support = LibQuestieDB and LibQuestieDB.Support
    if type(support) ~= "table" or type(support.Get) ~= "function" then
        return map
    end
    local ok, zoneDb = pcall(support.Get, "ZoneDB")
    local raw = ok and type(zoneDb) == "table" and zoneDb.private and zoneDb.private.areaIdToUiMapId
    local parsed
    if type(raw) == "table" then
        parsed = raw
    elseif type(raw) == "string" then
        local loader = loadstring or load
        if type(loader) == "function" then
            local loaded, fn = pcall(loader, raw)
            if loaded and type(fn) == "function" then
                local ran, result = pcall(fn)
                if ran and type(result) == "table" then
                    parsed = result
                end
            end
        end
    end
    if type(parsed) ~= "table" then
        return map
    end
    return parsed
end

local function areaUiMap(areaId)
    if not areaMapTried then
        areaMapTried = true
        areaMap = readAreaMap()
    end
    local uiMap = areaMap and areaMap[areaId]
    if type(uiMap) == "number" and uiMap > 0 then
        return uiMap
    end
end

local function areaName(areaId)
    if C_Map and C_Map.GetAreaInfo then
        local ok, name = pcall(C_Map.GetAreaInfo, areaId)
        if ok then
            return textOrNil(name)
        end
    end
end

local function mapName(uiMap)
    if type(uiMap) ~= "number" or not C_Map or not C_Map.GetMapInfo then
        return nil
    end
    local ok, info = pcall(C_Map.GetMapInfo, uiMap)
    if ok and type(info) == "table" then
        return textOrNil(info.name)
    end
end

local function firstSpawn(db, id)
    if type(db) ~= "table" or type(db.spawns) ~= "function" or type(id) ~= "number" then
        return nil
    end
    local spawns = call(db.spawns, id)
    if type(spawns) ~= "table" then
        return nil
    end
    local bestArea
    local bestPoint
    for areaId, points in pairs(spawns) do
        if type(areaId) == "number" and type(points) == "table" then
            local point
            for _, entry in ipairs(points) do
                if type(entry) == "table" and type(entry[1]) == "number" and type(entry[2]) == "number" and entry[1] > 0 and entry[2] > 0 then
                    point = entry
                    break
                end
            end
            if point and (not bestArea or areaId < bestArea) then
                bestArea = areaId
                bestPoint = point
            end
        end
    end
    if not bestArea or not bestPoint then
        return nil
    end
    return bestArea, bestPoint[1], bestPoint[2]
end

local function pinFor(kind, id)
    local db
    if kind == "npc" then
        db = NpcDB
    elseif kind == "object" then
        db = ObjectDB
    end
    local area, x, y = firstSpawn(db, id)
    if not area then
        return nil
    end
    local uiMap = areaUiMap(area)
    return {
        area = area,
        map = uiMap,
        x = x,
        y = y,
        zone = areaName(area) or mapName(uiMap),
    }
end

local function party(list, db, kind)
    local id = firstId(list)
    if not id then
        return nil
    end
    return {
        id = id,
        kind = kind,
        name = entityName(db, id),
    }
end

local function pickWho(startedBy)
    if type(startedBy) ~= "table" then
        return nil
    end
    return party(startedBy[1], NpcDB, "npc")
        or party(startedBy[2], ObjectDB, "object")
        or party(startedBy[3], ItemDB, "item")
end

local function pushLine(lines, text)
    text = textOrNil(text)
    if not text or #lines >= 4 then
        return
    end
    lines[#lines + 1] = text
end

local function objectiveId(entry)
    if type(entry) ~= "table" then
        return nil
    end
    if type(entry[1]) == "number" and entry[1] > 0 then
        return entry[1], entry[2]
    end
    if type(entry[1]) == "table" then
        return firstId(entry[1]), entry[3] or entry[2]
    end
end

local function addObjectives(lines, list, db, verb)
    if type(list) ~= "table" then
        return
    end
    for _, entry in ipairs(list) do
        local id, text = objectiveId(entry)
        if type(text) == "string" and text ~= "" then
            pushLine(lines, text)
        elseif id then
            local name = entityName(db, id)
            if name then
                pushLine(lines, verb .. " " .. name)
            end
        end
    end
end

local function objectiveLines(id)
    local lines = {}
    local objectives = call(QuestDB.objectives, id)
    if type(objectives) == "table" then
        addObjectives(lines, objectives[1], NpcDB, "Kill")
        addObjectives(lines, objectives[2], ObjectDB, "Use")
        addObjectives(lines, objectives[3], ItemDB, "Collect")
    end
    if #lines > 0 then
        return lines
    end
    local texts = call(QuestDB.objectivesText, id)
    local text = type(texts) == "table" and texts[1]
    if type(text) == "string" and text ~= "" then
        if #text > 160 then
            text = text:sub(1, 157) .. "..."
        end
        pushLine(lines, text)
    end
    return lines
end

local function firstObjectiveNpc(id)
    local objectives = call(QuestDB.objectives, id)
    local list = type(objectives) == "table" and objectives[1]
    if type(list) ~= "table" then
        return nil
    end
    for _, entry in ipairs(list) do
        local npcId = objectiveId(entry)
        if npcId then
            return npcId
        end
    end
end

local function readFacts(id)
    if not ns.QuestieReady() then
        return nil
    end
    local name = textOrNil(call(QuestDB.name, id))
    if not name then
        return nil
    end
    local giver = pickWho(call(QuestDB.startedBy, id))
    local turnIn = pickWho(call(QuestDB.finishedBy, id))
    local pin
    if giver then
        pin = pinFor(giver.kind, giver.id)
    end
    if not pin then
        local npcId = firstObjectiveNpc(id)
        if npcId then
            pin = pinFor("npc", npcId)
        end
    end
    local turnInPin
    if turnIn then
        turnInPin = pinFor(turnIn.kind, turnIn.id)
    end
    return {
        id = id,
        name = name,
        level = numberOrNil(call(QuestDB.questLevel, id)),
        requiredLevel = numberOrNil(call(QuestDB.requiredLevel, id)),
        giver = giver,
        turnIn = turnIn,
        pin = pin,
        turnInPin = turnInPin,
        lines = objectiveLines(id),
    }
end

function ns.QuestFacts(id)
    id = tonumber(id)
    if not id or id <= 0 or not ns.QuestieReady() then
        return nil
    end
    local cached = factsCache[id]
    if cached == nil then
        cached = readFacts(id) or false
        factsCache[id] = cached
    end
    if cached then
        return cached
    end
end

function ns.MapName(uiMap)
    return mapName(uiMap)
end
