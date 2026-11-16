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
        requiredClasses = call(QuestDB.requiredClasses, id) or 0,
        requiredRaces = call(QuestDB.requiredRaces, id) or 0,
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

function ns.NpcName(id)
    id = tonumber(id)
    if not id or id <= 0 then
        return nil
    end
    return entityName(NpcDB, id)
end

function ns.NpcPin(id)
    id = tonumber(id)
    if not id or id <= 0 then
        return nil
    end
    return pinFor("npc", id)
end

-- All known spawn pins for an NPC (each with map/x/y when UiMap is known).
-- Used by nav nearest-search so multi-zone NPCs pick the closest spawn.
function ns.NpcSpawns(id)
    id = tonumber(id)
    if not id or id <= 0 then
        return nil
    end
    local spawns = call(NpcDB.spawns, id)
    if type(spawns) ~= "table" then
        return nil
    end
    local list = {}
    for areaId, points in pairs(spawns) do
        if type(areaId) == "number" and type(points) == "table" then
            local uiMap = areaUiMap(areaId)
            local zone = areaName(areaId) or mapName(uiMap)
            for _, entry in ipairs(points) do
                if type(entry) == "table" and type(entry[1]) == "number" and type(entry[2]) == "number" and entry[1] > 0 and entry[2] > 0 then
                    list[#list + 1] = {
                        area = areaId,
                        map = uiMap,
                        x = entry[1],
                        y = entry[2],
                        zone = zone,
                    }
                end
            end
        end
    end
    if #list == 0 then
        return nil
    end
    return list
end

local entityDb = {
    npc = function()
        return NpcDB
    end,
    item = function()
        return ItemDB
    end,
    object = function()
        return ObjectDB
    end,
    quest = function()
        return QuestDB
    end,
}

local entityIdCache = {
    npc = {},
    item = {},
    object = {},
    quest = {},
}

local nameIndexWarm

local function nameLookupForms(name)
    local forms = { name }
    if type(name) ~= "string" or name == "" then
        return forms
    end
    if name:match("[^aeiouAEIOU]y$") then
        forms[#forms + 1] = name:sub(1, -2) .. "ies"
    elseif name:match("[^aeiouAEIOU]ies$") then
        forms[#forms + 1] = name:sub(1, -4) .. "y"
    elseif name:match("s$") and not name:match("ss$") then
        forms[#forms + 1] = name:sub(1, -2)
    else
        forms[#forms + 1] = name .. "s"
    end
    return forms
end

local function firstNameId(db, name)
    if type(db) ~= "table" or type(db.IdsByName) ~= "function" or type(name) ~= "string" or name == "" then
        return nil
    end
    local ids = call(db.IdsByName, name)
    if type(ids) == "table" then
        for _, id in ipairs(ids) do
            if type(id) == "number" and id > 0 then
                return id
            end
        end
    end
end

-- Resolve a guide-tag name to a QuestieDB id. Exact match first, then
-- singular/plural variants. Misses cache as false.
function ns.EntityIdByName(kind, name)
    kind = kind and tostring(kind):lower() or ""
    name = textOrNil(name)
    local cache = entityIdCache[kind]
    local getDb = entityDb[kind]
    if not cache or not getDb or not name then
        return nil
    end
    local cached = cache[name]
    if cached ~= nil then
        if cached then
            return cached
        end
        return nil
    end
    if not ns.QuestieReady() then
        return nil
    end
    local db = getDb()
    local id = firstNameId(db, name)
    if not id then
        for _, form in ipairs(nameLookupForms(name)) do
            if form ~= name then
                id = firstNameId(db, form)
                if id then
                    break
                end
            end
        end
    end
    cache[name] = id or false
    if id then
        return id
    end
end

local function npcRankLabel(rank)
    if rank == 1 then
        return "Elite"
    end
    if rank == 2 then
        return "Rare Elite"
    end
    if rank == 3 then
        return "Boss"
    end
    if rank == 4 then
        return "Rare"
    end
end

local function showItemTooltip(owner, id)
    GameTooltip:SetOwner(owner, "ANCHOR_NONE")
    local ok = false
    if GameTooltip.SetItemByID then
        ok = pcall(GameTooltip.SetItemByID, GameTooltip, id)
    end
    if not ok then
        ok = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. id)
    end
    local lines = (GameTooltip.NumLines and GameTooltip:NumLines()) or 0
    if not ok or lines == 0 then
        local name = entityName(ItemDB, id) or ("Item " .. id)
        GameTooltip:ClearLines()
        GameTooltip:SetText(name, 1, 1, 1)
        local level = numberOrNil(call(ItemDB.itemLevel, id))
        local required = numberOrNil(call(ItemDB.requiredLevel, id))
        if level then
            GameTooltip:AddLine("Item Level " .. level, 0.8, 0.8, 0.8)
        end
        if required then
            GameTooltip:AddLine("Requires Level " .. required, 0.8, 0.8, 0.8)
        end
    end
    if ns.FinishTooltip then
        ns.FinishTooltip()
    else
        GameTooltip:Show()
    end
    return true
end

local function showNpcTooltip(owner, id)
    local name = entityName(NpcDB, id)
    if not name then
        return false
    end
    local sub = textOrNil(call(NpcDB.subName, id))
    local minLevel = numberOrNil(call(NpcDB.minLevel, id))
    local maxLevel = numberOrNil(call(NpcDB.maxLevel, id))
    local rank = numberOrNil(call(NpcDB.rank, id))
    local pin = pinFor("npc", id)
    local friendly = textOrNil(call(NpcDB.friendlyToFaction, id))
    local r, g, b = 1, 0.82, 0
    if ns.Color then
        r, g, b = ns.Color("accent")
    end
    if friendly == "A" or friendly == "H" or friendly == "AH" then
        r, g, b = 0.15, 1, 0.15
    else
        r, g, b = 1, 0.34, 0.13
    end
    GameTooltip:SetOwner(owner, "ANCHOR_NONE")
    GameTooltip:ClearLines()
    GameTooltip:SetText(name, r, g, b, 1, true)
    if sub then
        GameTooltip:AddLine(sub, 0.85, 0.85, 0.85, true)
    end
    local levelLine
    if minLevel and maxLevel and minLevel ~= maxLevel then
        levelLine = "Level " .. minLevel .. "-" .. maxLevel
    elseif minLevel or maxLevel then
        levelLine = "Level " .. (minLevel or maxLevel)
    end
    local rankLabel = npcRankLabel(rank)
    if levelLine and rankLabel then
        levelLine = levelLine .. " " .. rankLabel
    elseif rankLabel then
        levelLine = rankLabel
    end
    if levelLine then
        GameTooltip:AddLine(levelLine, 1, 1, 1)
    end
    if pin and pin.zone then
        local where = pin.zone
        if type(pin.x) == "number" and type(pin.y) == "number" then
            where = string.format("%s (%.1f, %.1f)", where, pin.x, pin.y)
        end
        GameTooltip:AddLine(where, 0.8, 0.8, 0.8, true)
    end
    if ns.FinishTooltip then
        ns.FinishTooltip()
    else
        GameTooltip:Show()
    end
    return true
end

local function showObjectTooltip(owner, id)
    local name = entityName(ObjectDB, id)
    if not name then
        return false
    end
    local pin = pinFor("object", id)
    local r, g, b = 0.86, 0.18, 0.94
    if ns.Color then
        r, g, b = ns.Color("accent")
    end
    GameTooltip:SetOwner(owner, "ANCHOR_NONE")
    GameTooltip:ClearLines()
    GameTooltip:SetText(name, r, g, b, 1, true)
    GameTooltip:AddLine("Object", 0.85, 0.85, 0.85)
    if pin and pin.zone then
        local where = pin.zone
        if type(pin.x) == "number" and type(pin.y) == "number" then
            where = string.format("%s (%.1f, %.1f)", where, pin.x, pin.y)
        end
        GameTooltip:AddLine(where, 0.8, 0.8, 0.8, true)
    end
    if ns.FinishTooltip then
        ns.FinishTooltip()
    else
        GameTooltip:Show()
    end
    return true
end

-- Hover tip for a guide-tag entity (npc / item / object) resolved via QuestieDB.
function ns.ShowGuideEntityTooltip(owner, kind, name)
    if not owner then
        return false
    end
    kind = kind and tostring(kind):lower() or ""
    local id = ns.EntityIdByName(kind, name)
    if not id then
        return false
    end
    if kind == "item" then
        return showItemTooltip(owner, id)
    end
    if kind == "npc" then
        return showNpcTooltip(owner, id)
    end
    if kind == "object" then
        return showObjectTooltip(owner, id)
    end
    return false
end

-- Pay for IdsByName indexes off the hover path. BuildNameIndexAsync yields
-- inside the caller's coroutine; we resume it a little each frame.
function ns.WarmQuestieNameIndexes()
    if nameIndexWarm or not ns.QuestieReady() then
        return
    end
    nameIndexWarm = true
    local queue = {}
    for _, kind in ipairs({ "npc", "item", "object", "quest" }) do
        local getDb = entityDb[kind]
        local db = getDb and getDb()
        if type(db) == "table" then
            queue[#queue + 1] = db
        end
    end
    if #queue == 0 then
        return
    end
    local frame = CreateFrame("Frame")
    local index = 1
    local co
    local function startNext()
        while index <= #queue do
            local db = queue[index]
            index = index + 1
            if type(db.BuildNameIndexAsync) == "function" then
                co = coroutine.create(function()
                    call(db.BuildNameIndexAsync, 200)
                end)
                return true
            end
            if type(db.BuildNameIndex) == "function" then
                call(db.BuildNameIndex)
            end
        end
        co = nil
        return false
    end
    startNext()
    frame:SetScript("OnUpdate", function(self)
        if not co then
            if not startNext() then
                self:SetScript("OnUpdate", nil)
            end
            return
        end
        if coroutine.status(co) == "dead" then
            co = nil
            if not startNext() then
                self:SetScript("OnUpdate", nil)
            end
            return
        end
        local ok = coroutine.resume(co)
        if not ok then
            co = nil
            if not startNext() then
                self:SetScript("OnUpdate", nil)
            end
        end
    end)
end
