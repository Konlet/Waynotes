local addonName, ns = ...

local order = {}
local byId = {}

local menu
local catcher
local scroll
local content
local rows = {}
local declinedOffStep = {}
local declinedDungeon = {}
local lastDungeonPromptKey
local lastSyncStickies = {}
local lastSyncProgress = {}
local lastSyncNeedsBag = false

local stepApplies
local progressCounts
local neighbor
local inferLevels
local inferRaces
local inferDungeon

local function say(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r " .. text)
    end
end

local function charDB()
    if type(WaynotesCharDB) ~= "table" then
        if type(RestedXPBetterCharDB) == "table" then
            WaynotesCharDB = RestedXPBetterCharDB
        else
            WaynotesCharDB = {}
        end
    end
    if type(WaynotesCharDB.progress) ~= "table" then
        WaynotesCharDB.progress = {}
    end
    return WaynotesCharDB
end

local function findGuide(id)
    if type(id) ~= "string" or id == "" then
        return nil
    end
    if byId[id] then
        return byId[id]
    end
    local want = id:lower()
    for _, guide in pairs(byId) do
        if guide.id:lower() == want then
            return guide
        end
    end
end

local function activeGuide()
    local id = charDB().guide
    if type(id) ~= "string" then
        return nil
    end
    return byId[id]
end

local function progress(id)
    local db = charDB()
    local entry = db.progress[id]
    if type(entry) ~= "table" then
        entry = { step = 1 }
        db.progress[id] = entry
    end
    if type(entry.step) ~= "number" or entry.step < 1 then
        entry.step = 1
    else
        entry.step = math.floor(entry.step)
    end
    return entry
end

local function refresh()
    if ns.RefreshTracker then
        ns.RefreshTracker(true)
    elseif ns.MarkTrackerDirty then
        ns.MarkTrackerDirty(true)
    end
    if ns.RefreshOptions then
        ns.RefreshOptions()
    end
end

local function markStepsDirty(force)
    if ns.MarkTrackerDirty then
        ns.MarkTrackerDirty(force)
    elseif ns.RefreshTracker then
        ns.RefreshTracker(force and true or false)
    end
end

local CLASS_CANON = {
    warrior = "Warrior",
    paladin = "Paladin",
    hunter = "Hunter",
    rogue = "Rogue",
    priest = "Priest",
    shaman = "Shaman",
    mage = "Mage",
    warlock = "Warlock",
    druid = "Druid",
    monk = "Monk",
    deathknight = "Death Knight",
    demonhunter = "Demon Hunter",
}

local RACE_CANON = {
    orc = "Orc",
    troll = "Troll",
    tauren = "Tauren",
    undead = "Undead",
    scourge = "Undead",
    bloodelf = "Blood Elf",
    goblin = "Goblin",
    human = "Human",
    dwarf = "Dwarf",
    nightelf = "Night Elf",
    gnome = "Gnome",
    draenei = "Draenei",
    skyborne = "Skyborne",
    aeolid = "Skyborne",
    highborne = "Skyborne",
    windborne = "Skyborne",
}

local CLASS_MASK = {
    Warrior = 1,
    Paladin = 2,
    Hunter = 4,
    Rogue = 8,
    Priest = 16,
    ["Death Knight"] = 32,
    Shaman = 64,
    Mage = 128,
    Warlock = 256,
    Monk = 512,
    Druid = 1024,
    ["Demon Hunter"] = 2048,
}

local RACE_MASK = {
    Human = 1,
    Orc = 2,
    Dwarf = 4,
    ["Night Elf"] = 8,
    Undead = 16,
    Tauren = 32,
    Gnome = 64,
    Troll = 128,
    Goblin = 256,
    ["Blood Elf"] = 512,
    Draenei = 1024,
    -- Forever race ids 95 and 96. Both are "Skyborne" in these guides.
    Skyborne = 4294967296,
}

local function canonName(name, canon)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    if not canon then
        return name
    end
    -- Accept "NightElf", "Night Elf", or "nightelf" as the same race.
    local key = name:lower():gsub("%s+", "")
    return canon[key] or name
end

local function copyNames(value, canon)
    if type(value) ~= "table" then
        return nil
    end
    local list = {}
    local seen = {}
    for _, name in ipairs(value) do
        local resolved = canonName(name, canon)
        if resolved and not seen[resolved] then
            seen[resolved] = true
            list[#list + 1] = resolved
        end
    end
    if #list > 0 then
        return list
    end
end

local FILTER_SKIP = {
    ["or"] = true,
    ["and"] = true,
    ["/"] = true,
    [","] = true,
    ["&"] = true,
}

local function parseLeadingFilter(text)
    local inside, rest = text:match("^%[([^%]]+)%]%s*(.*)$")
    if not inside then
        return nil
    end
    local classes, excludeClasses, races, excludeRaces = {}, {}, {}, {}
    for token in inside:gmatch("[%w'!]+") do
        local key = token:lower():gsub("%s+", "")
        if not FILTER_SKIP[key] then
            local neg = token:sub(1, 1) == "!"
            local name = neg and token:sub(2) or token
            key = name:lower():gsub("%s+", "")
            local className = CLASS_CANON[key]
            local raceName = RACE_CANON[key]
            if className then
                local dest = neg and excludeClasses or classes
                dest[#dest + 1] = className
            elseif raceName then
                local dest = neg and excludeRaces or races
                dest[#dest + 1] = raceName
            else
                return nil
            end
        end
    end
    if #classes + #excludeClasses + #races + #excludeRaces == 0 then
        return nil
    end
    rest = strtrim(rest or "")
    if rest == "" or rest == "." then
        rest = nil
    end
    return rest, classes, excludeClasses, races, excludeRaces
end

local function cleanStep(step)
    if type(step) ~= "table" then
        return nil
    end
    local copy = {}
    if type(step.text) == "string" and step.text ~= "" then
        copy.text = step.text
    end
    if copy.text then
        local rest, classes, excludeClasses, races, excludeRaces = parseLeadingFilter(copy.text)
        if classes then
            copy.text = rest
            copy.classes = copyNames(step.classes, CLASS_CANON) or classes
            copy.excludeClasses = copyNames(step.excludeClasses, CLASS_CANON) or excludeClasses
            copy.races = copyNames(step.races, RACE_CANON) or races
            copy.excludeRaces = copyNames(step.excludeRaces, RACE_CANON) or excludeRaces
        end
    end
    if not copy.classes then
        copy.classes = copyNames(step.classes, CLASS_CANON)
        copy.excludeClasses = copyNames(step.excludeClasses, CLASS_CANON)
        copy.races = copyNames(step.races, RACE_CANON)
        copy.excludeRaces = copyNames(step.excludeRaces, RACE_CANON)
    end
    if step.mode == "softcore" or step.mode == "hardcore" then
        copy.mode = step.mode
    elseif step.note == "softcore" or step.note == "hardcore" then
        copy.mode = step.note
    end
    if type(step.note) == "string" and step.note ~= "" and step.note ~= "softcore" and step.note ~= "hardcore" then
        copy.note = step.note
    end
    if step.faction == "Alliance" or step.faction == "Horde" then
        copy.faction = step.faction
    end
    copy.map = tonumber(step.map)
    copy.x = tonumber(step.x)
    copy.y = tonumber(step.y)
    if type(step.pins) == "table" then
        local pins = {}
        -- Pins without a map share the step's map, else the first pin that names one.
        local sharedMap = copy.map
        if not sharedMap then
            for _, pin in ipairs(step.pins) do
                if type(pin) == "table" and tonumber(pin.map) then
                    sharedMap = tonumber(pin.map)
                    break
                end
            end
        end
        for _, pin in ipairs(step.pins) do
            if type(pin) == "table" then
                local map = tonumber(pin.map) or sharedMap
                local x = tonumber(pin.x)
                local y = tonumber(pin.y)
                if map and x and y then
                    local entry = { map = map, x = x, y = y }
                    if type(pin.note) == "string" and pin.note ~= "" then
                        entry.note = pin.note
                    elseif type(pin.label) == "string" and pin.label ~= "" then
                        entry.note = pin.label
                    end
                    pins[#pins + 1] = entry
                end
            end
        end
        if #pins > 0 then
            copy.pins = pins
            if not copy.map then
                copy.map = pins[1].map
            end
            if not copy.x then
                copy.x = pins[1].x
                copy.y = pins[1].y
            end
        end
    end
    if step.forever then
        copy.forever = true
    end
    if step.sticky then
        copy.sticky = true
    end
    local objective = tonumber(step.objective)
    if objective and objective >= 1 then
        copy.objective = math.floor(objective)
    end
    if type(step.travel) == "table" or type(step.travel) == "string" or step.travel == true then
        copy.travel = step.travel
    end
    local arriveYards = tonumber(step.arriveYards)
    if arriveYards and arriveYards > 0 then
        copy.arriveYards = arriveYards
    end
    local nearYards = tonumber(step.nearYards)
    if nearYards and nearYards > 0 then
        copy.nearYards = nearYards
    end
    if type(step.fpath) == "string" and strtrim(step.fpath) ~= "" then
        copy.fpath = strtrim(step.fpath)
    end
    if type(step.hearth) == "string" and strtrim(step.hearth) ~= "" then
        copy.hearth = strtrim(step.hearth)
    elseif type(step.bind) == "string" and strtrim(step.bind) ~= "" then
        copy.hearth = strtrim(step.bind)
    end
    if type(step.guide) == "string" and strtrim(step.guide) ~= "" then
        copy.guide = strtrim(step.guide)
    end
    local quests = {}
    local seen = {}
    local function add(id)
        id = tonumber(id)
        if not id or id <= 0 or seen[id] then
            return
        end
        seen[id] = true
        quests[#quests + 1] = id
    end
    add(step.quest)
    if type(step.quests) == "table" then
        for _, id in ipairs(step.quests) do
            add(id)
        end
    end
    copy.quests = quests
    if step.when == "accepted" or step.when == "complete" or step.when == "objectives" or step.when == "travel" then
        copy.when = step.when
    elseif #quests > 0 then
        copy.when = "objectives"
    end
    if type(step.details) == "table" then
        local details = {}
        for _, line in ipairs(step.details) do
            if type(line) == "string" and line ~= "" then
                details[#details + 1] = line
            end
        end
        if #details > 0 then
            copy.details = details
        end
    end
    if not copy.text and copy.details and copy.details[1] then
        copy.text = copy.details[1]
        table.remove(copy.details, 1)
        if #copy.details == 0 then
            copy.details = nil
        end
    end
    if not copy.text and #copy.quests == 0 and not copy.note and not copy.details then
        return nil
    end
    return copy
end

function ns.RegisterGuide(guide)
    if type(guide) ~= "table" or type(guide.id) ~= "string" or strtrim(guide.id) == "" then
        say("A guide is missing an id.")
        return
    end
    local id = strtrim(guide.id)
    local name = type(guide.name) == "string" and strtrim(guide.name) or ""
    if name == "" then
        name = id
    end
    local steps = {}
    if type(guide.steps) == "table" then
        for _, step in ipairs(guide.steps) do
            local clean = cleanStep(step)
            if clean then
                clean.index = #steps + 1
                if guide.forever then
                    clean.forever = true
                end
                steps[#steps + 1] = clean
            end
        end
    end
    if #steps == 0 then
        say("Guide " .. id .. " has no steps.")
        return
    end
    local group = type(guide.group) == "string" and strtrim(guide.group) or ""
    if group == "" then
        group = "Guides"
    end
    local faction
    if guide.faction == "Alliance" or guide.faction == "Horde" then
        faction = guide.faction
    end
    local minLevel = tonumber(guide.minLevel)
    local maxLevel = tonumber(guide.maxLevel)
    if not minLevel or not maxLevel then
        local inferredMin, inferredMax = inferLevels(name, id)
        minLevel = minLevel or inferredMin
        maxLevel = maxLevel or inferredMax
    end
    local races = copyNames(guide.races, RACE_CANON) or inferRaces(name, id)
    local classes = copyNames(guide.classes, CLASS_CANON)
    local excludeRaces = copyNames(guide.excludeRaces, RACE_CANON)
    local excludeClasses = copyNames(guide.excludeClasses, CLASS_CANON)
    local subgroup = type(guide.subgroup) == "string" and strtrim(guide.subgroup) or ""
    if subgroup == "" then
        subgroup = nil
    end
    -- Class side quests nest under Class Guides > ClassName in the menu.
    if classes and #classes == 1 then
        group = "Class Guides"
        subgroup = classes[1]
    end
    if not byId[id] then
        order[#order + 1] = id
    end
    local nextId = type(guide.next) == "string" and strtrim(guide.next) or nil
    if nextId == "" then
        nextId = nil
    end
    local dungeon = type(guide.dungeon) == "string" and strtrim(guide.dungeon) or nil
    if dungeon == "" then
        dungeon = nil
    end
    if not dungeon then
        dungeon = inferDungeon(name, id, group)
    end
    -- Only explicitly curated/listed guides appear in the menu. Dungeon packs
    -- can still load for in-instance prompts without cluttering the picker.
    local listed
    if guide.listed ~= nil then
        listed = guide.listed and true or false
    else
        listed = false
    end
    byId[id] = {
        id = id,
        name = name,
        group = group,
        subgroup = subgroup,
        faction = faction,
        minLevel = minLevel,
        maxLevel = maxLevel,
        races = races,
        classes = classes,
        excludeRaces = excludeRaces,
        excludeClasses = excludeClasses,
        listed = listed,
        dungeon = dungeon,
        starter = guide.starter and true or false,
        next = nextId,
        steps = steps,
    }
end

function ns.GuideRelevant(guide)
    if type(guide) ~= "table" then
        return false
    end
    local active = activeGuide()
    if active and guide.id == active.id then
        return true
    end
    return ns.GuideScore(guide) > -500
end

local function groupSortKey(group)
    if group == "Alliance" or group == "Horde" then
        return "0:" .. group
    end
    if group == "Class Guides" then
        return "2:" .. group
    end
    return "1:" .. (group or "")
end

function ns.GuideList()
    local list = {}
    for _, id in ipairs(order) do
        local guide = byId[id]
        if guide and guide.listed then
            list[#list + 1] = guide
        end
    end
    table.sort(list, function(a, b)
        local aGroup = groupSortKey(a.group)
        local bGroup = groupSortKey(b.group)
        if aGroup ~= bGroup then
            return aGroup < bGroup
        end
        local aSub = a.subgroup or ""
        local bSub = b.subgroup or ""
        if aSub ~= bSub then
            return aSub < bSub
        end
        local aMin = a.minLevel or 0
        local bMin = b.minLevel or 0
        if aMin ~= bMin then
            return aMin < bMin
        end
        local aMax = a.maxLevel or 0
        local bMax = b.maxLevel or 0
        if aMax ~= bMax then
            return aMax < bMax
        end
        if a.name ~= b.name then
            return a.name < b.name
        end
        return a.id < b.id
    end)
    return list
end

function ns.GuideId()
    local guide = activeGuide()
    return guide and guide.id
end

function ns.GuideExists(id)
    return findGuide(id) ~= nil
end

function ns.GuideTitle()
    local guide = activeGuide()
    if guide then
        return guide.name
    end
    return "Guide"
end

function ns.GuidePercentLabel()
    if not ns.db or not ns.db.showGuidePercent then
        return nil
    end
    local guide = activeGuide()
    if not guide or #guide.steps < 1 then
        return nil
    end
    local current = progress(guide.id).step
    local pos, total = progressCounts(guide, current)
    if not total or total < 1 then
        return nil
    end
    return string.format("%d%%", math.floor(pos / total * 100 + 0.5))
end

function ns.PrintGuides()
    local list = ns.GuideList()
    if #list == 0 then
        say("No guides yet. Add a Lua file in the Guides folder.")
        return
    end
    say("Guides:")
    for _, guide in ipairs(list) do
        DEFAULT_CHAT_FRAME:AddMessage("  " .. guide.group .. " / " .. guide.name .. "  |cffffffff" .. guide.id .. "|r")
    end
end

-- While party-sync following, prefer the leader's quest snapshot over the local log.
local function syncQuest(id)
    if type(id) ~= "number" or id <= 0 then
        return nil
    end
    if not (ns.PartySyncFollowing and ns.PartySyncFollowing()) then
        return nil
    end
    if not ns.PartySyncRemoteQuest then
        return nil
    end
    return ns.PartySyncRemoteQuest(id)
end

local function syncObjectiveText(id, index, filled, need, finished)
    local facts = ns.QuestFacts and ns.QuestFacts(id)
    local label
    if facts and type(facts.lines) == "table" and type(facts.lines[index]) == "string" then
        label = facts.lines[index]
        label = label:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
        label = label:gsub("|cRB_[A-Z]+_", ""):gsub("|cRXP_[A-Z]+_", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        label = label:gsub("%d+%s*/%s*%d+", " ")
        label = label:gsub("%(%d+%)", " ")
        label = strtrim(label:gsub("%s+", " "))
    end
    if type(need) == "number" and need > 0 then
        if label and label ~= "" then
            return string.format("%s: %d/%d", label, filled or 0, need)
        end
        return string.format("%d/%d", filled or 0, need)
    end
    if label and label ~= "" then
        return finished and (label .. " (done)") or label
    end
    if finished then
        return "1/1"
    end
    return "0/1"
end

local function questOn(id)
    if type(id) ~= "number" or id <= 0 then
        return false
    end
    local remote = syncQuest(id)
    if remote then
        return remote.on and true or false
    end
    -- Trust a successful modern API result. Falling through to a full quest-log
    -- scan on "not on quest" made every sticky poll O(steps * log size).
    if C_QuestLog and C_QuestLog.IsOnQuest then
        local ok, on = pcall(C_QuestLog.IsOnQuest, id)
        if ok then
            return on and true or false
        end
    end
    if IsOnQuest then
        local ok, on = pcall(IsOnQuest, id)
        if ok then
            return on and true or false
        end
    end
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local ok, index = pcall(C_QuestLog.GetLogIndexForQuestID, id)
        if ok then
            return type(index) == "number" and index > 0
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle then
        return false
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and qid == id then
            return true
        end
    end
    return false
end

local function questCompleted(id)
    if type(id) ~= "number" or id <= 0 then
        return false
    end
    local remote = syncQuest(id)
    if remote then
        return remote.completed and true or false
    end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, done = pcall(C_QuestLog.IsQuestFlaggedCompleted, id)
        if ok then
            return done and true or false
        end
    end
    if IsQuestFlaggedCompleted then
        local ok, done = pcall(IsQuestFlaggedCompleted, id)
        if ok then
            return done and true or false
        end
    end
    if GetQuestsCompleted then
        local bucket = {}
        local ok, result = pcall(GetQuestsCompleted, bucket)
        local done = ok and type(result) == "table" and result or bucket
        if type(done) == "table" then
            return done[id] and true or false
        end
    end
    return false
end

local function logObjectives(id, objectiveIndex)
    objectiveIndex = tonumber(objectiveIndex)
    if objectiveIndex and objectiveIndex < 1 then
        objectiveIndex = nil
    end
    local remote = syncQuest(id)
    if remote then
        local lines = {}
        local list = remote.objectives
        if type(list) == "table" then
            for index, info in ipairs(list) do
                if not objectiveIndex or index == objectiveIndex then
                    local text = type(info) == "table" and info.text or nil
                    if type(text) ~= "string" or text == "" then
                        text = syncObjectiveText(
                            id,
                            index,
                            info and info.filled,
                            info and info.need,
                            info and info.finished
                        )
                    end
                    if type(text) == "string" and text ~= "" then
                        lines[#lines + 1] = text
                    end
                end
            end
        end
        if #lines > 0 then
            return lines
        end
        return nil
    end
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, list = pcall(C_QuestLog.GetQuestObjectives, id)
        if ok and type(list) == "table" then
            local lines = {}
            for index, info in ipairs(list) do
                if not objectiveIndex or index == objectiveIndex then
                    if type(info) == "table" then
                        local text = info.text
                        if type(text) ~= "string" or text == "" then
                            if type(info.numRequired) == "number" and info.numRequired > 0 then
                                text = string.format("%d/%d", info.numFulfilled or 0, info.numRequired)
                            end
                        end
                        if type(text) == "string" and text ~= "" then
                            lines[#lines + 1] = text
                        end
                    end
                end
            end
            if #lines > 0 then
                return lines
            end
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle or not GetQuestLogLeaderBoard then
        return nil
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and qid == id then
            local lines = {}
            local boards = GetNumQuestLeaderBoards and GetNumQuestLeaderBoards(index) or 0
            for board = 1, boards do
                if not objectiveIndex or board == objectiveIndex then
                    local text = GetQuestLogLeaderBoard(board, index)
                    if type(text) == "string" and text ~= "" then
                        lines[#lines + 1] = text
                    end
                end
            end
            if #lines > 0 then
                return lines
            end
            return nil
        end
    end
end

local function logObjectiveStates(id)
    local remote = syncQuest(id)
    if remote then
        local states = {}
        local list = remote.objectives
        if type(list) == "table" then
            for index, info in ipairs(list) do
                if type(info) == "table" then
                    local text = info.text
                    if type(text) ~= "string" or text == "" then
                        text = syncObjectiveText(id, index, info.filled, info.need, info.finished)
                    end
                    local finished = info.finished and true or false
                    if not finished and type(info.need) == "number" and info.need > 0 then
                        finished = (info.filled or 0) >= info.need
                    end
                    states[#states + 1] = {
                        index = index,
                        text = text,
                        finished = finished,
                    }
                end
            end
        end
        if #states > 0 then
            return states
        end
        return nil
    end
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, list = pcall(C_QuestLog.GetQuestObjectives, id)
        if ok and type(list) == "table" and #list > 0 then
            local states = {}
            for index, info in ipairs(list) do
                if type(info) == "table" then
                    local text = info.text
                    if type(text) ~= "string" or text == "" then
                        if type(info.numRequired) == "number" and info.numRequired > 0 then
                            text = string.format("%d/%d", info.numFulfilled or 0, info.numRequired)
                        else
                            text = ""
                        end
                    end
                    local finished = info.finished and true or false
                    if not finished and type(info.numRequired) == "number" and info.numRequired > 0 then
                        finished = (info.numFulfilled or 0) >= info.numRequired
                    end
                    states[#states + 1] = {
                        index = index,
                        text = text,
                        finished = finished,
                    }
                end
            end
            if #states > 0 then
                return states
            end
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle or not GetQuestLogLeaderBoard then
        return nil
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and qid == id then
            local complete = isComplete == 1 or isComplete == -1 or isComplete == true
            local states = {}
            local boards = GetNumQuestLeaderBoards and GetNumQuestLeaderBoards(index) or 0
            for board = 1, boards do
                local text, _, finished = GetQuestLogLeaderBoard(board, index)
                states[#states + 1] = {
                    index = board,
                    text = type(text) == "string" and text or "",
                    finished = complete or (finished and true) or false,
                }
            end
            if #states > 0 then
                return states
            end
            return nil
        end
    end
end

-- Detail lines like "[LOOT]Hyacinth Mushroom[/] (7)" name the requirements
-- this step owns. Other objectives on the same quest stay on their own steps.
local OBJECTIVE_SKIP = {
    the = true,
    ["and"] = true,
    ["for"] = true,
    from = true,
    with = true,
    ["then"] = true,
    kill = true,
    collect = true,
    slain = true,
    loot = true,
}

local function objectivePlain(text)
    if type(text) ~= "string" then
        return ""
    end
    local plain = text:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
    plain = plain:gsub("|cRB_[A-Z]+_", ""):gsub("|cRXP_[A-Z]+_", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    return strtrim(plain)
end

local function objectiveToken(word)
    word = word:lower()
    if #word > 4 and word:sub(-3) == "ies" then
        return word:sub(1, -4) .. "y"
    end
    if #word > 4 and word:sub(-1) == "s" and word:sub(-2) ~= "ss" then
        return word:sub(1, -2)
    end
    return word
end

local function objectiveTokens(text)
    local plain = objectivePlain(text)
    plain = plain:gsub("%d+%s*/%s*%d+", " ")
    plain = plain:gsub("%(%d+%)", " ")
    local tokens = {}
    local seen = {}
    -- Keep coded names like XT:4 / XT-9 as one token. Plain %a+ would drop
    -- the short "xt" (# < 3) and stripping digits would erase the rest.
    plain = plain:gsub("(%a+)[%:%-](%d+)", function(letters, digits)
        local token = (letters .. ":" .. digits):lower()
        if not seen[token] then
            seen[token] = true
            tokens[#tokens + 1] = token
        end
        return " "
    end)
    plain = plain:gsub("(%a+)(%d+)", function(letters, digits)
        local token = (letters .. digits):lower()
        if #letters >= 2 and not seen[token] then
            seen[token] = true
            tokens[#tokens + 1] = token
        end
        return " "
    end)
    plain = plain:gsub("%d+", " ")
    for word in plain:gmatch("%a+") do
        if #word >= 3 then
            local token = objectiveToken(word)
            if not OBJECTIVE_SKIP[token] and not seen[token] then
                seen[token] = true
                tokens[#tokens + 1] = token
            end
        end
    end
    return tokens
end

local function tokensCover(have, need)
    if #need == 0 then
        return false
    end
    local set = {}
    for _, token in ipairs(have) do
        set[token] = true
    end
    for _, token in ipairs(need) do
        if not set[token] then
            return false
        end
    end
    return true
end

local function authoredObjectiveNames(step)
    local names = {}
    if type(step.details) ~= "table" then
        return names
    end
    for _, line in ipairs(step.details) do
        local name = objectivePlain(line):match("^(.-)%s*%(%d+%)%s*$")
        if name then
            name = strtrim(name)
            if name ~= "" then
                names[#names + 1] = name
            end
        end
    end
    return names
end

-- Bag count for authored collect lines that are not quest-log objectives
-- (e.g. Sunscale Feather for The Angry Scytheclaws while farming Raptor Horns).
local function itemCountByName(name)
    if type(name) ~= "string" or name == "" then
        return 0
    end
    if C_Item and C_Item.GetItemCount then
        local ok, count = pcall(C_Item.GetItemCount, name, false, false)
        if ok and type(count) == "number" then
            return count
        end
    end
    if type(GetItemCount) == "function" then
        local ok, count = pcall(GetItemCount, name, false)
        if ok and type(count) == "number" then
            return count
        end
    end
    return 0
end

-- "[LOOT]Sunscale Feather[/] (3)" -> "2/3 Sunscale Feather" when the quest
-- log never supplies live n/m (bag-only collects). Match quest-log order
-- ("x/y Name"). Never rewrite kill counts like "[ENEMY]Water Seeker[/] (6)".
local function bagProgressLine(line)
    if type(line) ~= "string" then
        return nil
    end
    if not line:find("[LOOT]", 1, true) and not line:find("RB_LOOT_", 1, true) then
        return nil
    end
    local plain = objectivePlain(line)
    if plain:match("%d+%s*/%s*%d+") then
        return nil
    end
    local name, need = plain:match("^(.-)%s*%((%d+)%)%s*$")
    if not name then
        return nil
    end
    name = strtrim(name)
    need = tonumber(need)
    if name == "" or not need or need < 1 then
        return nil
    end
    local have = itemCountByName(name)
    if have < 0 then
        have = 0
    elseif have > need then
        have = need
    end
    return have .. "/" .. need .. " " .. name
end

local function rewriteProgressDetail(line, filled, need)
    filled = tonumber(filled) or 0
    need = tonumber(need) or 0
    if need < 1 then
        return line
    end
    if filled < 0 then
        filled = 0
    elseif filled > need then
        filled = need
    end
    local plain = objectivePlain(line)
    local name = plain:match("^(.-)%s*%(%d+%)%s*$")
    if not name then
        name = plain:gsub("%d+%s*/%s*%d+", " ")
        name = name:gsub("^:%s*", ""):gsub("%s+", " ")
        name = strtrim(name)
    else
        name = strtrim(name)
    end
    if name ~= "" then
        return filled .. "/" .. need .. " " .. name
    end
    return filled .. "/" .. need
end

local function applyRemoteStepProgress(step, details)
    if type(details) ~= "table" or not step or type(step.index) ~= "number" then
        return details
    end
    if not (ns.PartySyncFollowing and ns.PartySyncFollowing()) then
        return details
    end
    if not ns.PartySyncRemoteStepProgress then
        return details
    end
    local remote = ns.PartySyncRemoteStepProgress(step.index)
    if type(remote) ~= "table" or #remote == 0 then
        return details
    end
    local slot = 1
    -- Prefer live n/m lines first (same order the host encodes).
    for index, line in ipairs(details) do
        if slot > #remote then
            break
        end
        local plain = objectivePlain(line)
        if plain:match("%d+%s*/%s*%d+") then
            details[index] = rewriteProgressDetail(line, remote[slot].filled, remote[slot].need)
            slot = slot + 1
        end
    end
    -- Then upgrade authored kill/loot "(N)" placeholders still on the step.
    for index, line in ipairs(details) do
        if slot > #remote then
            break
        end
        local plain = objectivePlain(line)
        if plain:match("%(%d+%)") and not plain:match("%d+%s*/%s*%d+") then
            details[index] = rewriteProgressDetail(line, remote[slot].filled, remote[slot].need)
            slot = slot + 1
        end
    end
    while slot <= #remote do
        local entry = remote[slot]
        details[#details + 1] = string.format("%d/%d", entry.filled or 0, entry.need or 0)
        slot = slot + 1
    end
    return details
end

local function objectiveListed(step, line)
    if not step or step.objective then
        return true
    end
    local names = authoredObjectiveNames(step)
    if #names == 0 then
        return true
    end
    local live = objectiveTokens(line)
    for _, name in ipairs(names) do
        if tokensCover(live, objectiveTokens(name)) then
            return true
        end
    end
    return false
end

-- nil: this step does not name a subset, so the whole quest still decides.
local function authoredObjectivesDone(step, questId)
    if not step or step.objective then
        return nil
    end
    local names = authoredObjectiveNames(step)
    if #names == 0 then
        return nil
    end
    if questCompleted(questId) then
        return true
    end
    if not questOn(questId) then
        return nil
    end
    local states = logObjectiveStates(questId)
    if not states then
        return nil
    end
    local matched = 0
    for _, name in ipairs(names) do
        local need = objectiveTokens(name)
        local hit = false
        local finished = true
        for _, info in ipairs(states) do
            if tokensCover(objectiveTokens(info.text), need) then
                hit = true
                if not info.finished then
                    finished = false
                end
            end
        end
        if hit then
            matched = matched + 1
            if not finished then
                return false
            end
        end
    end
    if matched == 0 then
        return nil
    end
    if #(step.quests or {}) <= 1 and matched < #names then
        return nil
    end
    return true
end

local function questName(id)
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local ok, name = pcall(C_QuestLog.GetTitleForQuestID, id)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    local facts = ns.QuestFacts and ns.QuestFacts(id)
    if facts and facts.name then
        return facts.name
    end
    return "Quest " .. id
end

local function listed(list, name)
    if type(list) ~= "table" or not name then
        return false
    end
    for _, entry in ipairs(list) do
        if entry == name then
            return true
        end
    end
    return false
end

local function hasBit(mask, flag)
    if type(mask) ~= "number" or type(flag) ~= "number" or flag == 0 or flag < 0 then
        return false
    end
    -- Arithmetic, so Forever's Skyborne bits past 2^31 still match.
    return math.floor(mask / flag) % 2 == 1
end

local function raceMatches(required, race)
    if race == "Skyborne" then
        return hasBit(required, 4294967296) or hasBit(required, 8589934592)
    end
    local flag = RACE_MASK[race or ""]
    if not flag then
        return true
    end
    return hasBit(required, flag)
end

function ns.PlayerClass()
    if not UnitClass then
        return nil
    end
    local _, token = UnitClass("player")
    if type(token) ~= "string" then
        return nil
    end
    return CLASS_CANON[token:lower()] or token
end

function ns.PlayerRace()
    if not UnitRace then
        return nil
    end
    local _, token = UnitRace("player")
    if type(token) ~= "string" then
        return nil
    end
    return RACE_CANON[token:lower()] or token
end

local function guideMode()
    if ns.db and ns.db.hardcoreGuide then
        return "hardcore"
    end
    return "softcore"
end

stepApplies = function(step)
    if not step then
        return false
    end
    if step.faction == "Alliance" or step.faction == "Horde" then
        local faction = UnitFactionGroup and UnitFactionGroup("player")
        if (faction == "Alliance" or faction == "Horde") and step.faction ~= faction then
            return false
        end
    end
    local class = ns.PlayerClass()
    if class then
        if step.classes and #step.classes > 0 and not listed(step.classes, class) then
            return false
        end
        if listed(step.excludeClasses, class) then
            return false
        end
    end
    local race = ns.PlayerRace()
    if race then
        if step.races and #step.races > 0 and not listed(step.races, race) then
            return false
        end
        if listed(step.excludeRaces, race) then
            return false
        end
    end
    if step.mode == "softcore" or step.mode == "hardcore" then
        if step.mode ~= guideMode() then
            return false
        end
    end
    return true
end

-- Next ". " sentence break. Periods inside [TAG]…[/] or |c…|r do not count
-- (e.g. [ENEMY]Venture Co. Loggers[/], [ENEMY]Mr. Smite[/]).
local function findSentenceBreak(text)
    local i = 1
    local n = #text
    while i <= n do
        local ch = text:sub(i, i)
        if ch == "[" then
            local closeBracket = text:find("]", i + 1, true)
            if not closeBracket then
                return nil
            end
            local tag = text:sub(i + 1, closeBracket - 1)
            if tag:match("^%u+$") then
                local bodyStart = closeBracket + 1
                local closeNamed = text:find("[/" .. tag .. "]", bodyStart, true)
                local closeShort = text:find("[/]", bodyStart, true)
                local closeEnd
                if closeNamed and (not closeShort or closeNamed <= closeShort) then
                    closeEnd = closeNamed + #tag + 2
                elseif closeShort then
                    closeEnd = closeShort + 2
                end
                if closeEnd then
                    i = closeEnd + 1
                else
                    i = closeBracket + 1
                end
            else
                i = closeBracket + 1
            end
        elseif ch == "|" and text:sub(i + 1, i + 1) == "c" then
            local close = text:find("|r", i + 2, true)
            if close then
                i = close + 2
            else
                i = i + 1
            end
        elseif ch == "." then
            local after = text:sub(i + 1, i + 1)
            if after ~= "" and after:match("%s") then
                local endAt = i + 1
                local j = i + 2
                while j <= n and text:sub(j, j):match("%s") do
                    endAt = j
                    j = j + 1
                end
                return i, endAt
            end
            i = i + 1
        else
            i = i + 1
        end
    end
    return nil
end

-- Keep shared note text; drop "Horde:" / "Alliance:" sentences for the other faction.
local function filterFactionLabeledText(text, faction)
    if type(text) ~= "string" or text == "" then
        return nil
    end
    if faction ~= "Alliance" and faction ~= "Horde" then
        return text
    end
    local parts = {}
    local i = 1
    local n = #text
    while i <= n do
        local allianceAt = text:find("Alliance:", i, true)
        local hordeAt = text:find("Horde:", i, true)
        local labelAt
        local labelLen
        local label
        if allianceAt and (not hordeAt or allianceAt < hordeAt) then
            labelAt = allianceAt
            labelLen = 9
            label = "Alliance"
        elseif hordeAt then
            labelAt = hordeAt
            labelLen = 6
            label = "Horde"
        else
            local rest = strtrim(text:sub(i))
            if rest ~= "" then
                parts[#parts + 1] = rest
            end
            break
        end
        local before = strtrim(text:sub(i, labelAt - 1))
        if before ~= "" then
            parts[#parts + 1] = before
        end
        local bodyStart = labelAt + labelLen
        while bodyStart <= n and text:sub(bodyStart, bodyStart):match("%s") do
            bodyStart = bodyStart + 1
        end
        local nextAlliance = text:find("Alliance:", bodyStart, true)
        local nextHorde = text:find("Horde:", bodyStart, true)
        local nextLabel
        if nextAlliance and (not nextHorde or nextAlliance < nextHorde) then
            nextLabel = nextAlliance
        elseif nextHorde then
            nextLabel = nextHorde
        end
        local bodyEnd
        local searchFrom = bodyStart
        local limit = nextLabel and (nextLabel - 1) or n
        local region = text:sub(searchFrom, limit)
        -- Reuse sentence-break rules so "Venture Co." inside tags does not
        -- truncate a faction-labeled note body.
        local relDot = select(1, findSentenceBreak(region))
        if relDot then
            bodyEnd = searchFrom + relDot - 1
        else
            -- Trailing period with no following whitespace still ends the body.
            local trailing = region:match("()%.%s*$")
            if trailing then
                bodyEnd = searchFrom + trailing - 1
            end
        end
        if not bodyEnd then
            if nextLabel then
                bodyEnd = nextLabel - 1
            else
                bodyEnd = n
            end
        end
        if label == faction then
            local body = strtrim(text:sub(bodyStart, bodyEnd))
            if body ~= "" then
                parts[#parts + 1] = body
            end
        end
        i = bodyEnd + 1
        while i <= n and text:sub(i, i):match("%s") do
            i = i + 1
        end
    end
    if #parts == 0 then
        return nil
    end
    local out = strtrim(table.concat(parts, " "):gsub("%s+", " "))
    if out == "" then
        return nil
    end
    return out
end

local function playerFactionForNotes()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    if faction == "Alliance" or faction == "Horde" then
        return faction
    end
end

local function questApplies(id)
    if not ns.QuestieReady or not ns.QuestieReady() then
        return true
    end
    local facts = ns.QuestFacts and ns.QuestFacts(id)
    if not facts then
        return true
    end
    local classMask = CLASS_MASK[ns.PlayerClass() or ""]
    local race = ns.PlayerRace()
    if type(facts.requiredClasses) == "number" and facts.requiredClasses ~= 0 and classMask then
        if not hasBit(facts.requiredClasses, classMask) then
            return false
        end
    end
    if type(facts.requiredRaces) == "number" and facts.requiredRaces ~= 0 and race then
        if not raceMatches(facts.requiredRaces, race) then
            return false
        end
    end
    return true
end

local function questObjectiveFinished(id, objectiveIndex)
    if questCompleted(id) then
        return true
    end
    if not questOn(id) then
        return false
    end
    objectiveIndex = tonumber(objectiveIndex)
    if not objectiveIndex or objectiveIndex < 1 then
        return false
    end
    local remote = syncQuest(id)
    if remote then
        if remote.objDone or remote.completed then
            return true
        end
        local info = remote.objectives and remote.objectives[objectiveIndex]
        if type(info) ~= "table" then
            return false
        end
        if info.finished then
            return true
        end
        if type(info.need) == "number" and info.need > 0 then
            return (info.filled or 0) >= info.need
        end
        return false
    end
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, list = pcall(C_QuestLog.GetQuestObjectives, id)
        if ok and type(list) == "table" and #list > 0 then
            local info = list[objectiveIndex]
            return type(info) == "table" and info.finished and true or false
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle or not GetNumQuestLeaderBoards or not GetQuestLogLeaderBoard then
        return false
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and qid == id then
            if isComplete == 1 or isComplete == -1 or isComplete == true then
                return true
            end
            local boards = GetNumQuestLeaderBoards(index) or 0
            if objectiveIndex > boards then
                return false
            end
            local _, _, finished = GetQuestLogLeaderBoard(objectiveIndex, index)
            return finished and true or false
        end
    end
    return false
end

local function questObjectivesDone(id)
    if questCompleted(id) then
        return true
    end
    if not questOn(id) then
        return false
    end
    local remote = syncQuest(id)
    if remote then
        if remote.objDone or remote.completed then
            return true
        end
        local list = remote.objectives
        if type(list) ~= "table" or #list == 0 then
            return false
        end
        for _, info in ipairs(list) do
            if type(info) ~= "table" then
                return false
            end
            local finished = info.finished and true or false
            if not finished and type(info.need) == "number" and info.need > 0 then
                finished = (info.filled or 0) >= info.need
            end
            if not finished then
                return false
            end
        end
        return true
    end
    if C_QuestLog and C_QuestLog.IsComplete then
        local ok, done = pcall(C_QuestLog.IsComplete, id)
        if ok and done then
            return true
        end
    end
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, list = pcall(C_QuestLog.GetQuestObjectives, id)
        if ok and type(list) == "table" and #list > 0 then
            for _, info in ipairs(list) do
                if type(info) ~= "table" or not info.finished then
                    return false
                end
            end
            return true
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle or not GetNumQuestLeaderBoards or not GetQuestLogLeaderBoard then
        return false
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and qid == id then
            if isComplete == 1 or isComplete == -1 or isComplete == true then
                return true
            end
            local boards = GetNumQuestLeaderBoards(index) or 0
            if boards < 1 then
                return false
            end
            for board = 1, boards do
                local _, _, finished = GetQuestLogLeaderBoard(board, index)
                if not finished then
                    return false
                end
            end
            return true
        end
    end
    return false
end

local function questSatisfied(id, when, objectiveIndex, step)
    if when == "complete" then
        return questCompleted(id)
    end
    if when == "accepted" then
        return questOn(id) or questCompleted(id)
    end
    if objectiveIndex then
        return questObjectiveFinished(id, objectiveIndex)
    end
    if step and (when == "objectives" or when == nil) then
        local partial = authoredObjectivesDone(step, id)
        if partial ~= nil then
            return partial
        end
    end
    return questObjectivesDone(id)
end

local function relevantQuests(step)
    local ids = {}
    for _, id in ipairs(step.quests or {}) do
        if questApplies(id) then
            ids[#ids + 1] = id
        end
    end
    return ids
end

-- Quest-gated steps that advance from log / turn-in state.
local function isQuestAutoStep(step)
    if not step then
        return false
    end
    local when = step.when
    return when == "accepted" or when == "complete" or when == "objectives"
end

-- Quest autos plus travel (arrive near the pin). Used to park the guide.
local function isAutoStep(step)
    if not step then
        return false
    end
    if isQuestAutoStep(step) then
        return true
    end
    return step.when == "travel"
end

-- True when every applicable quest-gated step in a linked guide is finished.
-- Manual handoff steps (including return / load-guide pointers) do not block.
local function linkedGuideFinished(id)
    local guide = findGuide(id)
    if not guide then
        return false
    end
    local sawAuto = false
    for _, step in ipairs(guide.steps) do
        if stepApplies(step) and isQuestAutoStep(step) then
            sawAuto = true
            local when = step.when
            local listedQuests = step.quests or {}
            local ids = relevantQuests(step)
            if #ids == 0 then
                if #listedQuests == 0 then
                    return false
                end
            else
                local useAny = not (ns.QuestieReady and ns.QuestieReady()) and #listedQuests > 1
                if useAny then
                    local any = false
                    for _, questId in ipairs(ids) do
                        if questSatisfied(questId, when, step.objective, step) then
                            any = true
                            break
                        end
                    end
                    if not any then
                        return false
                    end
                else
                    for _, questId in ipairs(ids) do
                        if not questSatisfied(questId, when, step.objective, step) then
                            return false
                        end
                    end
                end
            end
        end
    end
    return sawAuto
end

local function stepManuallySkipped(step)
    if not step or type(step.index) ~= "number" then
        return false
    end
    local guide = activeGuide()
    if not guide then
        return false
    end
    local skips = progress(guide.id).skip
    return type(skips) == "table" and skips[step.index] and true or false
end

local function markStepSkipped(guide, index)
    if not guide or type(index) ~= "number" then
        return
    end
    local entry = progress(guide.id)
    if type(entry.skip) ~= "table" then
        entry.skip = {}
    end
    entry.skip[index] = true
end

local function stepDone(step)
    if not step or not stepApplies(step) then
        return true
    end
    if stepManuallySkipped(step) then
        return true
    end
    if step.when == "travel" then
        return ns.TravelStepDone and ns.TravelStepDone(step) and true or false
    end
    if not isAutoStep(step) then
        -- Side-guide / next-guide pointer: skip once that guide's content is done.
        if type(step.guide) == "string" and step.guide ~= "" and linkedGuideFinished(step.guide) then
            return true
        end
        -- Flight-path pickup steps ("Get the Crossroads flight path" / fpath) advance
        -- once that node is unlocked, including when you already had it.
        if ns.TravelFlightPathStepDone and ns.TravelFlightPathStepDone(step) then
            return true
        end
        -- "Set your Hearthstone to X" advances once the bind location matches.
        if ns.TravelHearthBindStepDone and ns.TravelHearthBindStepDone(step) then
            return true
        end
        return false
    end
    local when = step.when
    local objectiveIndex = step.objective
    local listedQuests = step.quests or {}
    local ids = relevantQuests(step)
    if #ids == 0 then
        -- Manual step with no quests waits for Next.
        -- Quests listed but none apply to this character: skip.
        return #listedQuests > 0
    end
    local useAny = not (ns.QuestieReady and ns.QuestieReady()) and #listedQuests > 1
    if useAny then
        for _, id in ipairs(ids) do
            if questSatisfied(id, when, objectiveIndex, step) then
                return true
            end
        end
        return false
    end
    for _, id in ipairs(ids) do
        if not questSatisfied(id, when, objectiveIndex, step) then
            return false
        end
    end
    return true
end

-- Manual vendor/train steps (and ungated "Travel to X" text) have no quest gate.
-- During catch-up, skip them once a later quest step is already satisfied.
-- when = "travel" and hearth-led steps are isAutoStep, but catch-up also skips
-- them once the next quest auto step is done (player already finished the reason
-- to go / hearth).
local function laterAutoStepDone(guide, fromIndex)
    if not guide then
        return false
    end
    for index = fromIndex + 1, #guide.steps do
        local step = guide.steps[index]
        if stepApplies(step) and isQuestAutoStep(step) then
            local listedQuests = step.quests or {}
            local ids = relevantQuests(step)
            if #ids == 0 then
                if #listedQuests > 0 then
                    -- Filtered out for this character; keep looking ahead.
                else
                    -- Auto step with no quests should not happen; stop looking.
                    return false
                end
            elseif stepDone(step) then
                return true
            else
                return false
            end
        end
    end
    return false
end

-- "Hearth to X" / "Set your Hearthstone" / "Hearth or return" wording.
local function isHearthStep(step)
    if not step or type(step.text) ~= "string" then
        return false
    end
    local text = step.text
    text = text:gsub("%[[%w_]+%]", ""):gsub("%[/%w*%]", "")
    text = strtrim(text)
    if text == "" then
        return false
    end
    if text:match("^[Hh]earth") then
        return true
    end
    local lower = text:lower()
    return lower:find("set your hearth", 1, true) ~= nil
        or lower:find("set your hearthstone", 1, true) ~= nil
end

-- Manuals always; travel and hearth steps also, so an already-finished accept
-- or turn-in does not park the guide on "Travel to X" / "Hearth to X".
local function catchUpSkipsViaLaterAuto(step)
    if not step then
        return false
    end
    if not isAutoStep(step) then
        return true
    end
    if step.when == "travel" then
        return true
    end
    return isHearthStep(step)
end

-- A later step stays off the tracker while an earlier step is still the work
-- it depends on. Same quest: accept before objectives before turn-in, and a
-- single objective before the turn-in of that quest. Different objectives of
-- one quest do not block each other. Different quest: Questie's preQuestGroup
-- (all) and preQuestSingle (any) must be turned in first. An objectives step
-- only counts once that quest is in the log, so an unoffered optional sticky
-- does not freeze the guide.
local WHEN_RANK = {
    accepted = 1,
    objectives = 2,
    complete = 3,
}
local prereqCache = {}
local nextCache = {}

local function questIdList(value)
    if type(value) == "number" and value > 0 then
        return { value }
    end
    if type(value) ~= "table" then
        return nil
    end
    local list = {}
    for _, id in ipairs(value) do
        id = tonumber(id)
        if id and id > 0 then
            list[#list + 1] = id
        end
    end
    if #list == 0 then
        return nil
    end
    return list
end

local function questField(id, name)
    if type(QuestDB) ~= "table" then
        return nil
    end
    local getter = QuestDB[name]
    if type(getter) == "function" then
        local ok, value = pcall(getter, id)
        if ok then
            return value
        end
    end
    if type(QuestDB.Get) == "function" then
        local ok, value = pcall(QuestDB.Get, id, name)
        if ok then
            return value
        end
    end
end

local function questPrereqs(id)
    local cached = prereqCache[id]
    if cached ~= nil then
        return cached or nil
    end
    if not ns.QuestieReady or not ns.QuestieReady() then
        return nil
    end
    local group = questIdList(questField(id, "preQuestGroup"))
    local single = questIdList(questField(id, "preQuestSingle"))
    if not group and not single then
        prereqCache[id] = false
        return nil
    end
    local info = {
        group = group,
        single = single,
    }
    prereqCache[id] = info
    return info
end

local function nextQuest(id)
    local cached = nextCache[id]
    if cached ~= nil then
        return cached or nil
    end
    if not ns.QuestieReady or not ns.QuestieReady() then
        return nil
    end
    local value = tonumber(questField(id, "nextQuestInChain"))
    if not value or value <= 0 then
        nextCache[id] = false
        return nil
    end
    nextCache[id] = value
    return value
end

local function laterNeedsEarlierQuest(laterId, earlierId)
    if laterId == earlierId or questCompleted(earlierId) then
        return false
    end
    local info = questPrereqs(laterId)
    if not info then
        return nextQuest(earlierId) == laterId
    end
    if info.group then
        for _, pre in ipairs(info.group) do
            if pre == earlierId then
                return true
            end
        end
    end
    if info.single then
        for _, pre in ipairs(info.single) do
            if questCompleted(pre) then
                return false
            end
        end
        for _, pre in ipairs(info.single) do
            if pre == earlierId then
                return true
            end
        end
    end
    return false
end

local function questListed(step, questId)
    for _, id in ipairs(step.quests or {}) do
        if id == questId then
            return true
        end
    end
    return false
end

-- Accept steps are pending until the quest is taken. Objective and turn-in
-- steps are pending only while that quest is in the log.
local function questLive(step, questId)
    if questCompleted(questId) then
        return false
    end
    if step.when == "accepted" then
        return true
    end
    return questOn(questId)
end

local function stepQuestInLog(step)
    for _, id in ipairs(step.quests or {}) do
        if questOn(id) then
            return true
        end
    end
    return false
end

local function sameQuestBlocks(earlier, later)
    local earlierRank = WHEN_RANK[earlier.when]
    local laterRank = WHEN_RANK[later.when]
    if not earlierRank or not laterRank or earlierRank > laterRank then
        return false
    end
    for _, id in ipairs(earlier.quests or {}) do
        if questListed(later, id) and questLive(earlier, id) then
            if earlierRank < laterRank then
                return true
            end
            if earlierRank == 2 and laterRank == 2 then
                local earlierObjective = earlier.objective
                local laterObjective = later.objective
                if earlierObjective and (not laterObjective or earlierObjective == laterObjective) then
                    return true
                end
            end
        end
    end
    return false
end

local function chainBlocks(earlier, later)
    for _, earlierId in ipairs(earlier.quests or {}) do
        if questLive(earlier, earlierId) then
            for _, laterId in ipairs(later.quests or {}) do
                if laterNeedsEarlierQuest(laterId, earlierId) then
                    return true
                end
            end
        end
    end
    return false
end

local function questStepBlocks(earlier, later)
    if not earlier or not later then
        return false
    end
    return sameQuestBlocks(earlier, later) or chainBlocks(earlier, later)
end

progressCounts = function(guide, current)
    local total, pos = 0, 0
    for index, step in ipairs(guide.steps) do
        if stepApplies(step) then
            total = total + 1
            if index <= current then
                pos = total
            end
        end
    end
    if total > 0 and pos < 1 then
        pos = 1
    end
    return pos, total
end

neighbor = function(guide, index, direction)
    local count = #guide.steps
    local step = index
    local guard = 0
    while guard < count do
        step = step + direction
        if step < 1 or step > count then
            return nil
        end
        if stepApplies(guide.steps[step]) then
            return step
        end
        guard = guard + 1
    end
end

local reviewKey

local function rememberReview(guide, step)
    local entry = guide.steps[step]
    if entry and stepApplies(entry) and stepDone(entry) then
        reviewKey = guide.id .. ":" .. step
    else
        reviewKey = nil
    end
end

local function partySyncBroadcast()
    if ns.PartySyncBroadcast and not (ns.PartySyncApplying and ns.PartySyncApplying()) then
        ns.PartySyncBroadcast()
    end
end

local function partySyncBlocksAuto()
    return ns.PartySyncFollowing and ns.PartySyncFollowing()
end

-- Quiet guide+step apply for party sync followers (no chat, no catch-up).
function ns.GuideApplySync(guideId, stepIndex)
    local guide = findGuide(guideId)
    if not guide then
        return false
    end
    stepIndex = tonumber(stepIndex)
    if not stepIndex then
        return false
    end
    stepIndex = math.floor(stepIndex)
    local count = #guide.steps
    if count < 1 then
        return false
    end
    if stepIndex < 1 then
        stepIndex = 1
    elseif stepIndex > count then
        stepIndex = count
    end
    reviewKey = nil
    declinedOffStep = {}
    charDB().guide = guide.id
    progress(guide.id).step = stepIndex
    -- Coalesced dirty instead of a synchronous RefreshTracker(true) hitch.
    markStepsDirty(true)
    return true
end

local function advanceToNextGuide(fromGuide)
    if not fromGuide or type(fromGuide.next) ~= "string" or fromGuide.next == "" then
        return false
    end
    local nxt = findGuide(fromGuide.next)
    if not nxt or nxt.id == fromGuide.id then
        return false
    end
    reviewKey = nil
    charDB().guide = nxt.id
    local entry = progress(nxt.id)
    if entry.step < 1 then
        entry.step = 1
    end
    say("Continuing with " .. nxt.name .. ".")
    ns.GuideCatchUp()
    return true
end

local function atGuideEnd(guide, stepIndex)
    if not guide then
        return false
    end
    if neighbor(guide, stepIndex, 1) then
        return false
    end
    local step = guide.steps[stepIndex]
    if not step or not stepApplies(step) then
        return true
    end
    if stepDone(step) then
        return true
    end
    -- Last applicable step with no quest gate (including travel): Next continues the chain.
    return not isQuestAutoStep(step)
end

function ns.GuideCatchUp()
    local guide = activeGuide()
    if not guide then
        return false
    end
    -- Followers only move when the synced player broadcasts a new step.
    if partySyncBlocksAuto() then
        return false
    end
    local auto = not ns.db or ns.db.autoProgress ~= false
    local entry = progress(guide.id)
    local beforeGuide = guide.id
    local before = entry.step
    local count = #guide.steps
    local guard = 0
    while entry.step <= count and guard < count do
        local step = guide.steps[entry.step]
        if not stepApplies(step) then
            local hopped = neighbor(guide, entry.step, 1)
            if not hopped then
                break
            end
            entry.step = hopped
            guard = guard + 1
        elseif reviewKey == guide.id .. ":" .. entry.step then
            break
        elseif auto and (stepDone(step) or (catchUpSkipsViaLaterAuto(step) and laterAutoStepDone(guide, entry.step))) then
            local hopped = neighbor(guide, entry.step, 1)
            if not hopped then
                break
            end
            entry.step = hopped
            guard = guard + 1
        elseif step.sticky then
            -- Incomplete sticky steps stay listed; do not park the guide on them.
            local hopped = neighbor(guide, entry.step, 1)
            if not hopped then
                break
            end
            entry.step = hopped
            guard = guard + 1
        else
            break
        end
    end
    local moved = entry.step ~= before
    if auto and atGuideEnd(guide, entry.step) and advanceToNextGuide(guide) then
        partySyncBroadcast()
        return true
    end
    if activeGuide() and activeGuide().id ~= beforeGuide then
        partySyncBroadcast()
        return true
    end
    if moved then
        partySyncBroadcast()
    end
    return moved
end

-- Light pulse: only arrival-check travel steps. Quest progress is event-driven.
function ns.GuidePulseTravel()
    local guide = activeGuide()
    if not guide then
        return false
    end
    local entry = progress(guide.id)
    local step = guide.steps[entry.step]
    if not step or not stepApplies(step) then
        return false
    end
    local travel = step.when == "travel"
        or (ns.TravelIsTravelStep and ns.TravelIsTravelStep(step))
        or (ns.TravelIsFlightPathStep and ns.TravelIsFlightPathStep(step))
        or (ns.TravelIsHearthBindStep and ns.TravelIsHearthBindStep(step))
    if not travel then
        return false
    end
    return ns.GuideCatchUp()
end

inferLevels = function(name, id)
    local text = (name or "") .. " " .. (id or "")
    local a, b = text:match("(%d+)%s*%-%s*(%d+)")
    if a and b then
        return tonumber(a), tonumber(b)
    end
    local one = text:match("%((%d+)%)")
    if one then
        local level = tonumber(one)
        return level, level
    end
end

inferRaces = function(name, id)
    local text = ((name or "") .. " " .. (id or "")):lower()
    if text:find("undead", 1, true) or text:find("scourge", 1, true) or text:find("tirisfal", 1, true) then
        return { "Undead" }
    end
    if text:find("tauren", 1, true) or text:find("mulgore", 1, true) then
        return { "Tauren" }
    end
    if text:find("orc", 1, true) or text:find("troll", 1, true) or text:find("durotar", 1, true) then
        return { "Orc", "Troll" }
    end
end

inferDungeon = function(name, id, group)
    local haystack = ((group or "") .. " " .. (id or "") .. " " .. (name or "")):lower()
    if not haystack:find("dungeon", 1, true) then
        return nil
    end
    local label = name or ""
    label = label:gsub("%s*%(%d+%s*%-%s*%d+%)%s*$", "")
    label = label:gsub("%s*%(%d+%)%s*$", "")
    label = label:gsub("%s+Raid%s+Quests%s*$", "")
    label = label:gsub("%s+Quests%s*$", "")
    label = label:gsub("%s+Attunement%s*$", "")
    label = label:gsub("%s+Raid%s*$", "")
    label = label:gsub("%s+Tribute%s*$", "")
    label = strtrim(label)
    if label == "" then
        return nil
    end
    return label
end

local function normalizeDungeonKey(text)
    if type(text) ~= "string" then
        return ""
    end
    local key = text:lower()
    key = key:gsub("^the%s+", "")
    key = key:gsub("[^%a%d]+", "")
    return key
end

local function dungeonMatchScore(instanceName, guide)
    if type(guide) ~= "table" or type(guide.dungeon) ~= "string" then
        return 0
    end
    local inst = normalizeDungeonKey(instanceName)
    local key = normalizeDungeonKey(guide.dungeon)
    if inst == "" or key == "" then
        return 0
    end
    if key == inst then
        return 100
    end
    if key:find(inst, 1, true) then
        return 70 + math.min(20, #inst)
    end
    if inst:find(key, 1, true) then
        return 50 + math.min(20, #key)
    end
    return 0
end

local function dungeonGuideBonus(guide)
    local score = 0
    local id = (guide.id or ""):lower()
    local name = (guide.name or ""):lower()
    if id:find("attunement", 1, true) or name:find("attunement", 1, true) then
        score = score - 120
    end
    if id:find("raid", 1, true) or name:find("raid", 1, true) then
        score = score - 50
    end
    if id:find("quests", 1, true) or name:find("quests", 1, true) then
        score = score - 25
    end
    if type(guide.minLevel) == "number" and type(guide.maxLevel) == "number" then
        score = score + 25
    end
    return score
end

function ns.RecommendedDungeonGuide(instanceName)
    if type(instanceName) ~= "string" or instanceName == "" then
        return nil
    end
    local best
    local bestScore
    for _, id in ipairs(order) do
        local guide = byId[id]
        if guide and guide.dungeon then
            local match = dungeonMatchScore(instanceName, guide)
            if match > 0 then
                local relevance = ns.GuideScore(guide)
                if relevance > -500 then
                    local score = match * 10 + relevance + dungeonGuideBonus(guide)
                    if not best or score > bestScore or (score == bestScore and guide.name < best.name) then
                        best = guide
                        bestScore = score
                    end
                end
            end
        end
    end
    return best, bestScore
end

local function playerFaction()
    if not UnitFactionGroup then
        return nil
    end
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" or faction == "Horde" then
        return faction
    end
end

local function playerLevel()
    if UnitLevel then
        local level = UnitLevel("player")
        if type(level) == "number" and level > 0 then
            return level
        end
    end
    return 1
end

function ns.GuideScore(guide)
    if type(guide) ~= "table" then
        return -1000
    end
    local score = 0
    local faction = playerFaction()
    if guide.faction and faction then
        if guide.faction ~= faction then
            return -1000
        end
        score = score + 40
    end
    local race = ns.PlayerRace()
    if guide.races and #guide.races > 0 then
        if race and listed(guide.races, race) then
            score = score + 50
        else
            return -1000
        end
    end
    if guide.excludeRaces and race and listed(guide.excludeRaces, race) then
        return -1000
    end
    local class = ns.PlayerClass()
    if guide.classes and #guide.classes > 0 then
        if class and listed(guide.classes, class) then
            score = score + 35
        else
            return -1000
        end
    end
    if guide.excludeClasses and class and listed(guide.excludeClasses, class) then
        return -1000
    end
    local level = playerLevel()
    local minLevel = guide.minLevel
    local maxLevel = guide.maxLevel
    if type(minLevel) == "number" or type(maxLevel) == "number" then
        minLevel = type(minLevel) == "number" and minLevel or 1
        maxLevel = type(maxLevel) == "number" and maxLevel or 60
        if level < minLevel then
            score = score - (minLevel - level) * 8
        elseif level > maxLevel then
            score = score - (level - maxLevel) * 12
        else
            score = score + 60
            -- Prefer the tightest band that still fits.
            local span = math.max(1, maxLevel - minLevel)
            score = score + math.max(0, 20 - span)
            score = score + math.max(0, 10 - math.abs(level - minLevel))
        end
    else
        score = score + 5
    end
    return score
end

function ns.RecommendGuides()
    local list = ns.GuideList()
    local ranked = {}
    for _, guide in ipairs(list) do
        -- Class side guides stay selectable, but never auto-recommend over the route.
        if not guide.classes or #guide.classes == 0 then
            local score = ns.GuideScore(guide)
            if guide.starter then
                score = score + 80
            end
            if score > -500 then
                ranked[#ranked + 1] = { guide = guide, score = score }
            end
        end
    end
    table.sort(ranked, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.guide.name < b.guide.name
    end)
    return ranked
end

function ns.RecommendedGuide()
    local ranked = ns.RecommendGuides()
    local best = ranked[1]
    if not best or best.score < 20 then
        return nil
    end
    return best.guide, best.score
end

function ns.StarterGuide()
    local best
    local bestScore
    for _, id in ipairs(order) do
        local guide = byId[id]
        if guide and guide.starter and guide.listed ~= false then
            local score = ns.GuideScore(guide)
            if score > -500 then
                score = score + 80
                if not best or score > bestScore or (score == bestScore and guide.name < best.name) then
                    best = guide
                    bestScore = score
                end
            end
        end
    end
    return best, bestScore
end

function ns.GuideEnsure()
    if activeGuide() then
        return false
    end
    local guide
    local level = playerLevel()
    local usedStarter = false
    -- New characters: lock onto the curated starting-zone guide for their race.
    if level <= 1 then
        local starter, starterScore = ns.StarterGuide()
        if starter and starterScore and starterScore >= 20 then
            guide = starter
            usedStarter = true
        end
    end
    if not guide then
        guide = ns.RecommendedGuide()
    end
    if not guide then
        for _, candidate in ipairs(ns.GuideList()) do
            if ns.GuideRelevant(candidate) then
                guide = candidate
                break
            end
        end
    end
    if not guide then
        return false
    end
    reviewKey = nil
    charDB().guide = guide.id
    local entry = progress(guide.id)
    if entry.step > #guide.steps then
        entry.step = #guide.steps
    end
    ns.GuideCatchUp()
    if usedStarter then
        say("Loaded " .. guide.name .. " for your starting zone.")
    end
    return true
end

function ns.GuideSelect(id)
    local guide = findGuide(id)
    if not guide then
        say("No guide with id \"" .. tostring(id) .. "\". /waynotes guides lists them.")
        return
    end
    reviewKey = nil
    declinedOffStep = {}
    local db = charDB()
    db.guide = guide.id
    local entry = progress(guide.id)
    if entry.step > #guide.steps then
        entry.step = #guide.steps
    end
    ns.GuideCatchUp()
    refresh()
    partySyncBroadcast()
    if not ns.db or not ns.db.standaloneGuide then
        say("Selected " .. guide.name .. ". Turn on Replace RestedXP to show it.")
        return
    end
    say(guide.name .. ", step " .. progress(guide.id).step .. ".")
end

function ns.GuideCanStep(direction)
    local guide = activeGuide()
    if not guide then
        return false
    end
    local entry = progress(guide.id)
    if neighbor(guide, entry.step, direction < 0 and -1 or 1) then
        return true
    end
    if direction > 0 and atGuideEnd(guide, entry.step) and guide.next and findGuide(guide.next) then
        return true
    end
    return false
end

-- Primary non-sticky step the tracker is guiding toward right now.
function ns.GuidePrimaryStep()
    local guide = activeGuide()
    if not guide then
        return nil
    end
    local entry = progress(guide.id)
    local count = #guide.steps
    local primaryIndex = entry.step
    if primaryIndex < 1 then
        primaryIndex = 1
    elseif primaryIndex > count then
        primaryIndex = count
    end
    local primary = guide.steps[primaryIndex]
    if primary and primary.sticky then
        for index = primaryIndex + 1, count do
            local step = guide.steps[index]
            if stepApplies(step) and not step.sticky then
                return step, index
            end
        end
    elseif primary and not stepApplies(primary) then
        for index = primaryIndex, count do
            local step = guide.steps[index]
            if stepApplies(step) and not step.sticky then
                return step, index
            end
        end
        return nil
    end
    if primary and stepApplies(primary) then
        return primary, primaryIndex
    end
    return nil
end

function ns.GuideTravelDestination()
    local step, stepIndex = ns.GuidePrimaryStep()
    if not step or not ns.TravelResolveStep then
        return nil, nil, nil
    end
    local dest = ns.TravelResolveStep(step)
    if not dest then
        return nil, step, stepIndex
    end
    if ns.TravelFillDestinationCoords then
        dest = ns.TravelFillDestinationCoords(dest, step) or dest
    end
    return dest, step, stepIndex
end

function ns.GuideStep(direction)
    local guide = activeGuide()
    if not guide then
        return
    end
    local entry = progress(guide.id)
    local nextStep = neighbor(guide, entry.step, direction < 0 and -1 or 1)
    if (not nextStep or nextStep == entry.step) and direction > 0 then
        if atGuideEnd(guide, entry.step) and advanceToNextGuide(guide) then
            refresh()
        end
        return
    end
    if not nextStep or nextStep == entry.step then
        return
    end
    entry.step = nextStep
    if direction < 0 then
        rememberReview(guide, entry.step)
    else
        reviewKey = nil
        ns.GuideCatchUp()
    end
    refresh()
    partySyncBroadcast()
end

function ns.GuideJump(index)
    index = tonumber(index)
    if not index then
        return
    end
    index = math.floor(index)
    local guide = activeGuide()
    if not guide then
        say("Choose a guide first. Right-click the tracker, or use /waynotes guides.")
        return
    end
    local count = #guide.steps
    if count < 1 then
        return
    end
    if index < 1 then
        index = 1
    elseif index > count then
        index = count
    end
    if guide.steps[index] and not stepApplies(guide.steps[index]) then
        local hopped = neighbor(guide, index, 1) or neighbor(guide, index, -1)
        if hopped then
            index = hopped
        end
    end
    progress(guide.id).step = index
    rememberReview(guide, index)
    refresh()
    partySyncBroadcast()
end

function ns.GuideSkip(index)
    index = tonumber(index)
    if not index then
        return
    end
    index = math.floor(index)
    local guide = activeGuide()
    if not guide then
        return
    end
    local count = #guide.steps
    if index < 1 or index > count then
        return
    end
    local step = guide.steps[index]
    if not step then
        return
    end
    markStepSkipped(guide, index)
    local entry = progress(guide.id)
    -- Do not use GuideJump: that sets a review lock on already-complete steps
    -- and never CatchUps, so skip could park on a finished neighbor.
    reviewKey = nil
    if step.sticky then
        -- Stickies ride along behind the primary. Keep the current cursor unless
        -- progress was somehow parked on the skipped sticky itself.
        if entry.step == index then
            local hopped = neighbor(guide, index, 1)
            if hopped then
                entry.step = hopped
            end
        end
    else
        local hopped = neighbor(guide, index, 1)
        if hopped then
            entry.step = hopped
        end
    end
    ns.GuideCatchUp()
    refresh()
    partySyncBroadcast()
end

local function detailKey(text)
    if type(text) ~= "string" then
        return nil
    end
    local plain = text:lower()
    plain = plain:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
    plain = plain:gsub("|cRB_[A-Z]+_", "")
    plain = plain:gsub("|cRXP_[A-Z]+_", "")
    plain = plain:gsub("|c%x%x%x%x%x%x%x%x", "")
    plain = plain:gsub("|r", "")
    -- Keep ":" so coded names like XT:4 stay intact. Strip other punctuation.
    plain = plain:gsub("[%[%]%.,;!%?\"']", " ")
    plain = plain:gsub("%s+", " ")
    plain = strtrim(plain)
    if plain == "" then
        return nil
    end
    return plain
end

local function detailCovers(longKey, shortKey)
    if not longKey or not shortKey or shortKey == "" then
        return false
    end
    if longKey == shortKey then
        return true
    end
    if #shortKey < 6 then
        return false
    end
    if longKey:find(shortKey, 1, true) then
        return true
    end
    -- Token overlap: "Escort Kaya Flathoof" vs "Escort Kaya Flathoof to Camp Aparaje".
    local skip = {
        the = true,
        ["and"] = true,
        ["for"] = true,
        from = true,
        with = true,
        ["then"] = true,
        her = true,
        him = true,
        them = true,
        to = true,
        of = true,
        a = true,
        an = true,
        your = true,
        this = true,
    }
    local function words(key)
        local list = {}
        local seen = {}
        -- Drop live "3/8" and authored "(8)" counts so sibling lines like
        -- "Empty Vial Labeled #1 (1)" vs "#2 (1)" compare on the name only.
        local rest = key:gsub("%d+%s*/%s*%d+", " ")
        rest = rest:gsub("%(%s*%d+%s*%)", " ")
        -- Treat #1 / #2 labels as digit tokens ("Empty Vial Labeled #1").
        rest = rest:gsub("#", " ")
        -- Coded names like XT:4. Skip "Name: 3/8" live-progress colons.
        rest = rest:gsub("(%a+)[%:%-]%s*(%d+)(/?)", function(letters, digits, slash)
            if slash == "/" then
                return letters .. " " .. digits .. slash
            end
            local token = letters .. ":" .. digits
            if not seen[token] then
                seen[token] = true
                list[#list + 1] = token
            end
            return " "
        end)
        for word in rest:gmatch("%w+") do
            -- Keep digits so "Vial #1" and "Vial #2" stay distinct.
            local keep = (not skip[word]) and (#word >= 3 or word:match("^%d+$"))
            if keep and not seen[word] then
                seen[word] = true
                list[#list + 1] = word
            end
        end
        return list
    end
    -- "Incendrite (10)" must cover live "1/10 Incendrites".
    local function wordStem(word)
        if type(word) ~= "string" or #word < 4 then
            return word
        end
        if word:sub(-3) == "ies" and #word >= 5 then
            return word:sub(1, -4) .. "y"
        end
        if word:sub(-1) == "s" and word:sub(-2, -2) ~= "s" then
            return word:sub(1, -2)
        end
        return word
    end
    local shortWords = words(shortKey)
    local longWords = words(longKey)
    if #shortWords == 0 or #longWords == 0 then
        return false
    end
    local have = {}
    for _, word in ipairs(longWords) do
        have[word] = true
        have[wordStem(word)] = true
    end
    local shared = 0
    for _, word in ipairs(shortWords) do
        if have[word] or have[wordStem(word)] then
            shared = shared + 1
        end
    end
    -- Short is covered only when every short token appears in long.
    -- A 75% overlap was collapsing sibling objectives that share boilerplate
    -- ("Attack Plan … destroyed", "Shut off … Valve", "Visit … Raptor Nest").
    if shared ~= #shortWords then
        return false
    end
    -- One coded id (xt:4) or one long item name (incendrites) is enough when
    -- that single token matched. Two or more matched tokens always cover.
    if shared == 1 then
        local only = shortWords[1]
        return only:find("%d") ~= nil or #only >= 5
    end
    return true
end

-- Strip author-only quest numbers, guide ids, and UI prompts from player-facing text.
local function scrubPlayerText(text)
    if type(text) ~= "string" then
        return nil
    end
    local cleaned = text
    cleaned = cleaned:gsub("[Gg]uide%s+[Ii][Dd]%s*:%s*[%w_%-]+%.?", "")
    cleaned = cleaned:gsub("[Ee]scort%s+[Qq]uest%s+%d+%.?", "")
    cleaned = cleaned:gsub("[Qq]uests?%s+%d[%d%s,]*and%s+%d+%.?", "")
    cleaned = cleaned:gsub("[Qq]uests?%s+%d[%d%s,]*%d*%.?", "")
    cleaned = cleaned:gsub("and%s+optional%s+%d+", "")
    cleaned = cleaned:gsub("optional%s+%d+", "optional")
    cleaned = cleaned:gsub("[Pp]ress%s+[Nn]ext%s+when%s+done%s+or%s+if%s+skipping%.?", "")
    cleaned = cleaned:gsub(",%s*then%s+[Pp]ress%s+[Nn]ext%.?", "")
    cleaned = cleaned:gsub("%.?%s*[Pp]ress%s+[Nn]ext%.?", "")
    cleaned = cleaned:gsub("|c%x%x%x%x%x%x%x%x%s*|r", "")
    cleaned = cleaned:gsub("|cRB_[%w_]+_%s*|r", "")
    cleaned = cleaned:gsub("|cRB_WARN_%s+", "|cRB_WARN_")
    cleaned = cleaned:gsub("%[%a+%]%s*%[%/%a*%]", "")
    cleaned = cleaned:gsub("%s+", " ")
    cleaned = strtrim(cleaned)
    cleaned = cleaned:gsub("^[%.,;:%-%s]+", "")
    -- Keep a trailing period: curated notes (and authored sentences) end with one.
    cleaned = cleaned:gsub("[,;:%-%s]+$", "")
    cleaned = strtrim(cleaned)
    if cleaned == "" or cleaned == "|cRB_WARN_|r" or cleaned:match("^|cRB_WARN_%.?|r$") or cleaned:match("^%[%a+%]%[%/%a*%]$") then
        return nil
    end
    return cleaned
end

local function isTalkDetail(text)
    if type(text) ~= "string" then
        return false
    end
    local plain = text:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
    plain = plain:gsub("|cRB_[A-Z]+_", ""):gsub("|cRXP_[A-Z]+_", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    plain = strtrim(plain)
    return plain:match("^[Tt]alk to%s+") ~= nil or plain:match("^[Ss]peak with%s+") ~= nil
end

local function addDetail(details, seen, text, headlineKey)
    text = scrubPlayerText(text)
    if type(text) ~= "string" then
        return
    end
    text = strtrim(text)
    if text == "" or #details >= 6 then
        return
    end
    -- Talk/speak lines belong in the headline only.
    if isTalkDetail(text) then
        return
    end
    local key = detailKey(text)
    if not key or seen[key] then
        return
    end
    local function progressPlain(line)
        local plain = line:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
        plain = plain:gsub("|cRB_[A-Z]+_", ""):gsub("|cRXP_[A-Z]+_", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        return strtrim(plain)
    end
    -- Live quest log: "Fel Moss: 3/8". Authored gather counts: "Fel Moss (8)".
    local function looksLiveProgress(line)
        return progressPlain(line):match("%d+%s*/%s*%d+") ~= nil
    end
    local function looksCount(line)
        local plain = progressPlain(line)
        return plain:match("%d+%s*/%s*%d+") ~= nil or plain:match("%S.+%(%d+%)%s*$") ~= nil
    end
    -- Headlines often name the same item ("Kill grellkin for Fel Moss"), but the
    -- count line still carries the amount. Never drop progress/count details as
    -- redundant with the headline.
    if headlineKey and detailCovers(headlineKey, key) and not looksCount(text) then
        return
    end
    for index, existing in ipairs(details) do
        local existingKey = detailKey(existing)
        if existingKey then
            if detailCovers(existingKey, key) then
                -- Prefer live n/m objective text over authored "Item (N)" counts.
                if looksLiveProgress(text) and not looksLiveProgress(existing) then
                    details[index] = text
                    seen[existingKey] = nil
                    seen[key] = true
                end
                return
            end
            if detailCovers(key, existingKey) then
                details[index] = text
                seen[existingKey] = nil
                seen[key] = true
                return
            end
        end
    end
    seen[key] = true
    details[#details + 1] = text
end

local function whoLine(who, turnIn)
    if not who or type(who.name) ~= "string" or who.name == "" then
        return nil
    end
    if who.kind == "object" then
        if turnIn then
            return "Turn in at [PICK]" .. who.name .. "[/]"
        end
        return "Accept at [PICK]" .. who.name .. "[/]"
    end
    if turnIn then
        return "Turn in to [FRIENDLY]" .. who.name .. "[/]"
    end
    return "Accept from [FRIENDLY]" .. who.name .. "[/]"
end

-- Split "Talk to X. Turn in Y. Accept Z." into a short headline plus detail lines.
-- Talk/speak sentences always stay in the headline, never in details.
local function authoredPresentation(step)
    local details = {}
    local seen = {}
    local text = scrubPlayerText(type(step.text) == "string" and step.text or "") or ""
    local headline = text
    local sentences = {}
    if text ~= "" then
        local rest = text
        while rest ~= "" do
            local startAt, endAt = findSentenceBreak(rest)
            if not startAt then
                local last = strtrim(rest)
                if last ~= "" then
                    sentences[#sentences + 1] = last:gsub("%.$", "")
                end
                break
            end
            local piece = strtrim(rest:sub(1, startAt - 1))
            if piece ~= "" then
                sentences[#sentences + 1] = piece
            end
            rest = strtrim(rest:sub(endAt + 1))
        end
        if #sentences > 0 then
            headline = sentences[1]
        end
    end
    -- Fold later Talk/Speak sentences into the title so they are not details.
    local keep = {}
    for index = 2, #sentences do
        local sentence = sentences[index]
        if isTalkDetail(sentence) then
            if isTalkDetail(headline) then
                headline = headline .. ". " .. sentence
            else
                local lead = headline
                local talk = sentence
                if talk:match("^[Tt]alk to%s+") then
                    talk = talk:gsub("^[Tt]alk", "talk")
                elseif talk:match("^[Ss]peak with%s+") then
                    talk = talk:gsub("^[Ss]peak", "speak")
                end
                headline = lead .. " and " .. talk
            end
        else
            keep[#keep + 1] = sentence
        end
    end
    local headlineKey = detailKey(headline)
    local noteFaction = playerFactionForNotes()
    -- Authored notes before extra sentences / detail lists so they cannot be
    -- dropped by the detail cap or buried under "+ more notes".
    local guideNote = scrubPlayerText(filterFactionLabeledText(step.note, noteFaction))
    if guideNote then
        addDetail(details, seen, guideNote, headlineKey)
    end
    for _, sentence in ipairs(keep) do
        addDetail(details, seen, sentence, headlineKey)
    end
    if type(step.details) == "table" then
        for _, line in ipairs(step.details) do
            addDetail(details, seen, filterFactionLabeledText(line, noteFaction), headlineKey)
        end
    end
    if headline == "" then
        local id = step.quests and step.quests[1]
        if id then
            headline = questName(id)
        else
            headline = "Step"
        end
        headlineKey = detailKey(headline)
    end
    return headline, details, seen, headlineKey, guideNote
end

local function plainStepListText(text)
    if type(text) ~= "string" then
        return nil
    end
    text = text:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
    text = text:gsub("|cRB_[A-Z]+_", "")
    text = text:gsub("|cRXP_[A-Z]+_", "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|n", " ")
    text = text:gsub("\n", " ")
    text = strtrim(text)
    if text == "" then
        return nil
    end
    return text
end

-- Active step index for the slim step list (no presentation work).
function ns.GuideStepListCurrent()
    local guide = activeGuide()
    if not guide or type(guide.steps) ~= "table" or #guide.steps < 1 then
        return nil
    end
    local current = 1
    local entry = progress(guide.id)
    if entry and type(entry.step) == "number" and entry.step >= 1 then
        current = entry.step
    end
    local _, primaryIndex = ns.GuidePrimaryStep()
    if type(primaryIndex) == "number" and primaryIndex >= 1 then
        current = primaryIndex
    end
    if current > #guide.steps then
        current = #guide.steps
    end
    return current
end

-- Slim step-list rows: number, one-line header, and tooltip details.
function ns.GuideStepListData()
    local guide = activeGuide()
    if not guide or type(guide.steps) ~= "table" or #guide.steps < 1 then
        return nil, nil, nil
    end
    local current = ns.GuideStepListCurrent() or 1

    local entries = {}
    for index, step in ipairs(guide.steps) do
        local headline, details = authoredPresentation(step)
        local header = plainStepListText(headline) or ("Step " .. index)
        local tips = {}
        if type(details) == "table" then
            for _, line in ipairs(details) do
                local plain = plainStepListText(line)
                if plain and plain ~= header then
                    tips[#tips + 1] = plain
                end
            end
        end
        entries[index] = {
            index = index,
            header = header,
            details = tips,
        }
    end
    return entries, current, guide.id
end

local function rememberGuideName(into, seen, name)
    if type(name) ~= "string" then
        return
    end
    name = strtrim(name:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1"))
    name = strtrim(name:gsub("|cRB_[A-Z]+_", ""):gsub("|cRXP_[A-Z]+_", ""):gsub("|r", ""):gsub("|c%x%x%x%x%x%x%x%x", ""))
    if name == "" or #name < 3 then
        return
    end
    local key = name:lower()
    if seen[key] then
        return
    end
    seen[key] = true
    into[#into + 1] = name
end

local function collectTaggedGuideNames(raw, into, seen)
    if type(raw) ~= "string" then
        return
    end
    for _, tag in ipairs({ "ENEMY", "FRIENDLY", "LOOT", "PICK", "BUY", "QUEST", "SKILL" }) do
        local startAt = 1
        local open = "[" .. tag .. "]"
        while true do
            local found, finish = raw:find(open, startAt, true)
            if not found then
                break
            end
            local closeNamed = raw:find("[/" .. tag .. "]", finish + 1, true)
            local closeShort = raw:find("[/]", finish + 1, true)
            local close, closeEnd
            if closeNamed and (not closeShort or closeNamed <= closeShort) then
                close, closeEnd = closeNamed, closeNamed + #tag + 2
            elseif closeShort then
                close, closeEnd = closeShort, closeShort + 2
            else
                break
            end
            rememberGuideName(into, seen, raw:sub(finish + 1, close - 1))
            startAt = closeEnd + 1
        end
    end
    for _, tag in ipairs({ "RB_ENEMY_", "RB_FRIENDLY_", "RB_LOOT_", "RB_PICK_", "RB_BUY_", "RB_QUEST_", "RB_SKILL_" }) do
        local startAt = 1
        local marker = "|c" .. tag
        while true do
            local found, finish = raw:find(marker, startAt, true)
            if not found then
                break
            end
            local close = raw:find("|r", finish + 1, true)
            if not close then
                break
            end
            rememberGuideName(into, seen, raw:sub(finish + 1, close - 1))
            startAt = close + 2
        end
    end
end

local function remapPinXY(step, map, x, y)
    -- Curated Forever guides already store Forever percents. Classic-authored
    -- guides (Zygor, etc.) still need Era→Forever remapping when available.
    if not step.forever and ns.IsForever and ns.IsForever() and LibQuestieDB and type(LibQuestieDB.EraToForeverByUiMapId) == "function" then
        local ok, nx, ny = pcall(LibQuestieDB.EraToForeverByUiMapId, map, x, y)
        if ok and type(nx) == "number" and type(ny) == "number" then
            return nx, ny
        end
    end
    return x, y
end

local function makeAuthorPin(step, map, x, y, note)
    if type(map) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end
    x, y = remapPinXY(step, map, x, y)
    local zone = (ns.MapName and ns.MapName(map)) or (ns.MapZoneName and ns.MapZoneName(map)) or nil
    local pin = {
        map = map,
        x = x,
        y = y,
        zone = zone,
        forever = step.forever and true or nil,
    }
    if type(note) == "string" and note ~= "" then
        pin.note = note
    end
    return pin
end

local function authorPins(step)
    local pins = {}
    if type(step.pins) == "table" then
        for _, entry in ipairs(step.pins) do
            if type(entry) == "table" then
                local pin = makeAuthorPin(step, entry.map or step.map, entry.x, entry.y, entry.note or entry.label)
                if pin then
                    pins[#pins + 1] = pin
                end
            end
        end
    end
    if #pins == 0 then
        local pin = makeAuthorPin(step, step.map, step.x, step.y)
        if pin then
            pins[1] = pin
        end
    end
    return pins
end

local function authorPin(step)
    return authorPins(step)[1]
end

-- Kill and collect objectives share an area pin: show NEAR within nearYards
-- (options: nearYardsEnemy / Loot / Pick, or nearYardsSingle for a count of 1).

local function scanAreaTags(text, flags)
    if type(text) ~= "string" then
        return
    end
    if text:find("[ENEMY]", 1, true)
        or text:find("RB_ENEMY_", 1, true)
        or text:find("|cffff5722", 1, true)
    then
        flags.enemy = true
    end
    if text:find("[LOOT]", 1, true)
        or text:find("RB_LOOT_", 1, true)
        or text:find("|cff00bcd4", 1, true)
    then
        flags.loot = true
    end
    if text:find("[PICK]", 1, true)
        or text:find("RB_PICK_", 1, true)
        or text:find("|cffdb2eef", 1, true)
    then
        flags.pick = true
    end
end

local function hasAreaTag(text)
    local flags = {}
    scanAreaTags(text, flags)
    return flags.enemy or flags.loot or flags.pick
end

local function stepAreaFlags(step)
    local flags = {}
    scanAreaTags(step.text, flags)
    if type(step.details) == "table" then
        for _, line in ipairs(step.details) do
            scanAreaTags(line, flags)
        end
    end
    return flags
end

local function stepIsAreaObjective(step)
    if step.when ~= "objectives" then
        return false
    end
    local flags = stepAreaFlags(step)
    return flags.enemy or flags.loot or flags.pick
end

-- Enemy beats loot beats pick when a step mixes tags (kill-and-loot grinds).
local function stepAreaKind(step)
    local flags = stepAreaFlags(step)
    if flags.enemy then
        return "enemy"
    end
    if flags.loot then
        return "loot"
    end
    if flags.pick then
        return "pick"
    end
    return "enemy"
end

local function defaultNear(kind)
    if ns.DefaultNearYards then
        return ns.DefaultNearYards(kind)
    end
    if kind == "single" then
        return 5
    end
    if kind == "travel" then
        return 10
    end
    return 100
end

-- One named kill or one (1) loot/pick uses the single radius. Grind counts use
-- the matching enemy / loot / pick option.
local function stepNearYards(step)
    local authored = tonumber(step.nearYards)
    if authored and authored > 0 then
        return authored
    end
    if not stepIsAreaObjective(step) then
        return nil
    end
    local maxCount = 0
    local function consider(text)
        if not hasAreaTag(text) then
            return
        end
        local count = tonumber(text:match("%((%d+)%)"))
        if count and count > 0 then
            if count > maxCount then
                maxCount = count
            end
        else
            maxCount = math.max(maxCount, 1)
        end
    end
    consider(step.text)
    if type(step.details) == "table" then
        for _, line in ipairs(step.details) do
            consider(line)
        end
    end
    if maxCount == 1 then
        return defaultNear("single")
    end
    return defaultNear(stepAreaKind(step))
end

local function pinForStep(step)
    local authored = authorPin(step)
    if authored then
        return authored
    end
    local id = step.quests[1]
    if not id or not ns.QuestFacts then
        return nil
    end
    local facts = ns.QuestFacts(id)
    if not facts then
        return nil
    end
    if step.when == "complete" then
        return facts.turnInPin or facts.pin
    end
    return facts.pin
end

local function worldPoint(pin)
    if not pin or type(pin.x) ~= "number" or type(pin.y) ~= "number" then
        return nil
    end
    local wx, wy, instance
    if ns.PinToPlayerWorld then
        wx, wy, instance = ns.PinToPlayerWorld(pin.map, pin.x, pin.y, pin.zone)
    elseif ns.ZoneToWorld and type(pin.map) == "number" then
        wx, wy, instance = ns.ZoneToWorld(pin.map, pin.x, pin.y)
    end
    if type(wx) ~= "number" or type(wy) ~= "number" then
        return nil
    end
    return { wx = wx, wy = wy, instance = instance }
end

local function buildItem(step, full)
    local entries = {}
    local primary
    for _, id in ipairs(step.quests) do
        local on = questOn(id)
        local entry = {
            id = id,
            name = questName(id),
            on = on,
        }
        entries[#entries + 1] = entry
        if on and not primary then
            primary = entry
        end
    end
    if not primary then
        primary = entries[1]
    end

    local headline, details, seen, headlineKey, guideNote = authoredPresentation(step)
    local hasAuthoredText = type(step.text) == "string" and strtrim(step.text) ~= ""

    if full then
        -- Authored talk/turn-in/accept text already covers the NPC action.
        if not hasAuthoredText then
            local facts = step.quests[1] and ns.QuestFacts and ns.QuestFacts(step.quests[1])
            addDetail(details, seen, whoLine(facts and (step.when == "complete" and facts.turnIn or facts.giver), step.when == "complete"), headlineKey)
        end
        local allDone = #step.quests > 0
        local unresolved = false
        for _, id in ipairs(step.quests) do
            if questCompleted(id) then
                -- This quest is already turned in.
            elseif questOn(id) then
                allDone = false
                -- Live log objectives only while the quest is in the log.
                if step.when == "objectives" or step.when == nil then
                    local lines = logObjectives(id, step.objective)
                    if lines then
                        for _, line in ipairs(lines) do
                            if objectiveListed(step, line) then
                                addDetail(details, seen, line, headlineKey)
                            end
                        end
                    end
                end
            else
                allDone = false
                -- Do not preview kill/collect objectives on accept/turn-in steps.
                if step.when == "objectives" then
                    local questFacts = ns.QuestFacts and ns.QuestFacts(id)
                    if questFacts and questFacts.lines then
                        for index, line in ipairs(questFacts.lines) do
                            if (not step.objective or index == step.objective) and objectiveListed(step, line) then
                                addDetail(details, seen, line, headlineKey)
                            end
                        end
                    else
                        unresolved = true
                    end
                end
            end
        end
        if allDone and step.when == "complete" then
            addDetail(details, seen, "Completed.", headlineKey)
        elseif unresolved and not (ns.QuestieReady and ns.QuestieReady()) then
            addDetail(details, seen, "QuestieDB is not installed.", headlineKey)
        end
        -- Authored "Item (N)" lines that the quest log never upgrades (bag-only
        -- collects for another quest) still need live n/m so they show as
        -- numbered objectives instead of static placeholders.
        -- Skip while party-sync following so local bags cannot override the leader.
        if not (ns.PartySyncFollowing and ns.PartySyncFollowing()) then
            local function looksLiveProgress(line)
                return objectivePlain(line):match("%d+%s*/%s*%d+") ~= nil
            end
            local kept = {}
            for _, line in ipairs(details) do
                local upgraded = bagProgressLine(line)
                if upgraded then
                    local upgradeKey = detailKey(upgraded)
                    local covered = false
                    for _, other in ipairs(details) do
                        if other ~= line and looksLiveProgress(other) then
                            local otherKey = detailKey(other)
                            if otherKey and upgradeKey and (
                                detailCovers(otherKey, upgradeKey) or detailCovers(upgradeKey, otherKey)
                            ) then
                                covered = true
                                break
                            end
                        end
                    end
                    -- Quest log already tracks this loot: drop the authored duplicate.
                    if not covered then
                        kept[#kept + 1] = upgraded
                        lastSyncNeedsBag = true
                    end
                else
                    kept[#kept + 1] = line
                end
            end
            details = kept
        else
            applyRemoteStepProgress(step, details)
        end
    end

    local names = {}
    local nameSeen = {}
    local quests = {}
    local questSeen = {}
    collectTaggedGuideNames(headline, names, nameSeen)
    for _, line in ipairs(details) do
        collectTaggedGuideNames(line, names, nameSeen)
    end
    for _, entry in ipairs(entries) do
        if entry.name then
            rememberGuideName(quests, questSeen, entry.name)
        end
    end
    for _, id in ipairs(step.quests) do
        local facts = ns.QuestFacts and ns.QuestFacts(id)
        if facts then
            rememberGuideName(quests, questSeen, facts.name)
            if facts.giver and facts.giver.name then
                rememberGuideName(names, nameSeen, facts.giver.name)
            end
            if facts.turnIn and facts.turnIn.name then
                rememberGuideName(names, nameSeen, facts.turnIn.name)
            end
        else
            rememberGuideName(quests, questSeen, questName(id))
        end
    end

    local item = {
        number = step.index,
        headline = headline,
        details = details,
        note = guideNote,
        actions = {},
        names = names,
        quests = quests,
        stepIndex = step.index,
        sticky = step.sticky and true or false,
        kill = stepIsAreaObjective(step) or nil,
        nearYards = stepNearYards(step),
        stepQuests = entries,
        questId = primary and primary.id,
        questName = primary and primary.name,
    }
    if type(step.guide) == "string" and step.guide ~= "" then
        local linked = findGuide(step.guide)
        if linked then
            item.loadGuide = {
                id = linked.id,
                name = linked.name,
            }
        end
    end
    if full then
        local pins = authorPins(step)
        if #pins == 0 then
            local fallback = pinForStep(step)
            if fallback then
                pins[1] = fallback
            end
        end
        if #pins > 0 then
            local places = {}
            for index, pin in ipairs(pins) do
                places[index] = {
                    map = pin.map,
                    x = pin.x,
                    y = pin.y,
                    zone = pin.zone,
                    note = pin.note,
                }
            end
            item.places = places
            item.place = places[1]
            item.waypoint = worldPoint(pins[1])
            -- Travel multi-pins are a path: follow in order, no cycle button.
            if step.when == "travel" and #places > 1 then
                item.pinOrder = true
                item.arriveYards = step.arriveYards
            end
        end
        if ns.TravelApplyToItem then
            item = ns.TravelApplyToItem(item, step) or item
        end
    end
    return item
end

function ns.GuideObjectives()
    if ns.TravelBeginHints then
        ns.TravelBeginHints()
    end
    lastSyncNeedsBag = false
    local guide = activeGuide()
    if not guide then
        return {
            {
                number = 0,
                headline = "No guide selected",
                details = {
                    "Right-click the tracker to choose a guide.",
                    "Add guides as Lua files in the Guides folder. /waynotes guides lists them.",
                },
                actions = {},
                names = {},
                quests = {},
                stepQuests = {},
            },
        }
    end
    -- Advance past finished accepts/objectives and incomplete stickies before
    -- choosing what to show. Otherwise a done accept stays primary and the
    -- sticky kill right after it is treated as "upcoming" and hidden.
    if not partySyncBlocksAuto() then
        ns.GuideCatchUp()
        guide = activeGuide() or guide
    end
    local entry = progress(guide.id)
    local count = #guide.steps
    if entry.step > count then
        entry.step = count
    elseif entry.step < 1 then
        entry.step = 1
    end
    if guide.steps[entry.step] and not stepApplies(guide.steps[entry.step]) then
        local hopped = neighbor(guide, entry.step, 1)
        if hopped then
            entry.step = hopped
        end
    end
    -- Primary step plus incomplete stickies already passed.
    -- A step is left off while an earlier step it depends on is still open,
    -- so a turn-in is not listed beside the objectives that have to finish first.
    -- Parallel stickies that do not gate the step stay on screen.
    local items = {}
    local primaryIndex = entry.step
    local primary = guide.steps[primaryIndex]
    if primary and primary.sticky then
        for index = primaryIndex + 1, count do
            local step = guide.steps[index]
            if stepApplies(step) and not step.sticky then
                primaryIndex = index
                primary = step
                break
            end
        end
    elseif primary and not stepApplies(primary) then
        primary = nil
        for index = primaryIndex, count do
            local step = guide.steps[index]
            if stepApplies(step) and not step.sticky then
                primaryIndex = index
                primary = step
                break
            end
        end
    end
    local doneCache = {}
    local function isDone(index)
        local known = doneCache[index]
        if known ~= nil then
            return known
        end
        local result = stepDone(guide.steps[index])
        doneCache[index] = result
        return result
    end
    local waitingCache = {}
    local function waiting(index)
        local known = waitingCache[index]
        if known ~= nil then
            return known
        end
        local step = guide.steps[index]
        if not step or not stepApplies(step) or not isAutoStep(step) or isDone(index) then
            waitingCache[index] = false
            return false
        end
        for earlierIndex = 1, index - 1 do
            local earlier = guide.steps[earlierIndex]
            if earlier and stepApplies(earlier) and isAutoStep(earlier) and not isDone(earlierIndex) and questStepBlocks(earlier, step) then
                waitingCache[index] = true
                return true
            end
        end
        waitingCache[index] = false
        return false
    end
    -- Stickies after the primary still show when their quest is already in the
    -- log (picked up earlier), or when the primary is gated by earlier work.
    -- Stop before the next non-sticky step that can be done now.
    local function stickyHorizon(blockedPrimary)
        local last = primaryIndex
        for index = primaryIndex + 1, count do
            local step = guide.steps[index]
            if stepApplies(step) and not isDone(index) then
                if step.sticky then
                    if blockedPrimary or stepQuestInLog(step) then
                        last = index
                    else
                        break
                    end
                elseif waiting(index) then
                    last = index
                else
                    break
                end
            end
        end
        return last
    end
    -- Incomplete stickies stay listed only while they are near the current work
    -- (or the player). Otherwise a south-oasis sticky rides along to a north
    -- harpy step a thousand yards away.
    local STICKY_NEAR_YARDS = 750
    local function pinPairYards(a, b)
        if not a or not b then
            return nil
        end
        if ns.ZoneToWorld then
            local ax, ay, ai = ns.ZoneToWorld(a.map, a.x, a.y)
            local bx, by, bi = ns.ZoneToWorld(b.map, b.x, b.y)
            if type(ax) == "number" and type(bx) == "number" and type(ay) == "number" and type(by) == "number" then
                if type(ai) == "number" and type(bi) == "number" and ai ~= bi then
                    return nil
                end
                local dx, dy = ax - bx, ay - by
                return math.sqrt(dx * dx + dy * dy)
            end
        end
        if a.map and b.map and a.map == b.map and type(a.x) == "number" and type(b.x) == "number" then
            -- Rough same-map fallback when HBD world coords are missing (~40 yd/%).
            local dx = (a.x - b.x) * 40
            local dy = (a.y - b.y) * 40
            return math.sqrt(dx * dx + dy * dy)
        end
        return nil
    end
    -- Multi-pin stickies count as nearby when any of their pins is close.
    local function stickyIsNearby(step)
        local stickyPins = authorPins(step)
        if #stickyPins == 0 then
            return true
        end
        if ns.PinZoneDistance then
            for _, stickyPin in ipairs(stickyPins) do
                local toPlayer = ns.PinZoneDistance(stickyPin.map, stickyPin.x, stickyPin.y, stickyPin.zone)
                if type(toPlayer) == "number" and toPlayer <= STICKY_NEAR_YARDS then
                    return true
                end
            end
        end
        local primaryPins = authorPins(primary)
        if #primaryPins == 0 then
            return true
        end
        local measured = false
        for _, stickyPin in ipairs(stickyPins) do
            for _, primaryPin in ipairs(primaryPins) do
                local yards = pinPairYards(stickyPin, primaryPin)
                if yards ~= nil then
                    measured = true
                    if yards <= STICKY_NEAR_YARDS then
                        return true
                    end
                end
            end
        end
        return not measured
    end
    local remoteStickies = ns.PartySyncRemoteStickies and ns.PartySyncRemoteStickies()
    local function showSticky(index, step, blockedPrimary)
        if not step or not step.sticky or not stepApplies(step) then
            return false
        end
        if index == primaryIndex then
            return false
        end
        -- Followers mirror the host's sticky set instead of local nearby/done filters.
        if type(remoteStickies) == "table" then
            return remoteStickies[index] and true or false
        end
        if isDone(index) or waiting(index) then
            return false
        end
        -- Upcoming stickies need their quest already in the log. Past stickies
        -- (before the primary) stay eligible regardless.
        if index > primaryIndex and not stepQuestInLog(step) then
            return false
        end
        if not stickyIsNearby(step) then
            -- Far stickies that gate the current step still show so the block
            -- reason is visible.
            if not (blockedPrimary and questStepBlocks(step, primary)) then
                return false
            end
        end
        return true
    end
    local simple = ns.db and ns.db.simpleMode
    if primary and stepApplies(primary) then
        local primaryWaiting = waiting(primaryIndex)
        local horizon = stickyHorizon(primaryWaiting)
        if type(remoteStickies) == "table" then
            for index in pairs(remoteStickies) do
                if type(index) == "number" and index > horizon then
                    horizon = index
                end
            end
        end
        local function addStep(step, asSticky)
            items[#items + 1] = buildItem(step, true)
            items[#items].sticky = asSticky and true or false
        end
        if simple then
            -- Simple mode shows only the earliest incomplete active step,
            -- including stickies that would otherwise stay concurrent.
            -- A gated turn-in yields to the earliest sticky that is blocking it.
            local showStep = nil
            if primaryWaiting then
                for index = 1, horizon do
                    local step = guide.steps[index]
                    if showSticky(index, step, true) and questStepBlocks(step, primary) then
                        showStep = step
                        break
                    end
                end
            end
            if not showStep then
                for index = 1, primaryIndex - 1 do
                    local step = guide.steps[index]
                    if showSticky(index, step, primaryWaiting) then
                        showStep = step
                        break
                    end
                end
            end
            if not showStep and not primaryWaiting then
                showStep = primary
            end
            if not showStep and primaryWaiting then
                for index = primaryIndex + 1, horizon do
                    local step = guide.steps[index]
                    if showSticky(index, step, true) then
                        showStep = step
                        break
                    end
                end
            end
            if showStep then
                addStep(showStep, showStep ~= primary)
            end
        else
            if not primaryWaiting then
                addStep(primary, false)
            end
            local gates = {}
            local others = {}
            for index = 1, horizon do
                local step = guide.steps[index]
                if showSticky(index, step, primaryWaiting) then
                    if primaryWaiting and questStepBlocks(step, primary) then
                        gates[#gates + 1] = step
                    else
                        others[#others + 1] = step
                    end
                end
            end
            for _, step in ipairs(gates) do
                addStep(step, true)
            end
            for _, step in ipairs(others) do
                addStep(step, true)
            end
            if #items == 0 then
                addStep(primary, false)
            end
        end
    end
    -- Host caches visible sticky indexes and kill/loot progress for followers.
    if type(remoteStickies) ~= "table" then
        local listed = {}
        local progress = {}
        for _, item in ipairs(items) do
            if item.sticky and type(item.stepIndex) == "number" then
                listed[#listed + 1] = item.stepIndex
            end
            if type(item.stepIndex) == "number" and type(item.details) == "table" then
                local counts = {}
                for _, line in ipairs(item.details) do
                    local plain = objectivePlain(line)
                    local filled, need = plain:match("(%d+)%s*/%s*(%d+)")
                    filled = tonumber(filled)
                    need = tonumber(need)
                    -- Only live n/m (quest log or bag upgrades), not bare "(N)" placeholders.
                    if filled and need and need > 0 then
                        counts[#counts + 1] = { filled = filled, need = need }
                    end
                end
                if #counts > 0 then
                    progress[item.stepIndex] = counts
                end
            end
        end
        table.sort(listed)
        lastSyncStickies = listed
        lastSyncProgress = progress
    end
    if #items == 0 then
        local auto = (not ns.db or ns.db.autoProgress ~= false) and not partySyncBlocksAuto()
        if auto and advanceToNextGuide(guide) then
            return ns.GuideObjectives()
        end
        local details = { "Right-click the tracker to choose another guide." }
        local loadGuide
        if guide.next then
            local nxt = findGuide(guide.next)
            if nxt then
                details = { "Continue with " .. nxt.name .. "." }
                loadGuide = {
                    id = nxt.id,
                    name = nxt.name,
                }
            end
        end
        return {
            {
                number = entry.step,
                headline = "End of this guide",
                details = details,
                actions = {},
                names = {},
                quests = {},
                stepQuests = {},
                loadGuide = loadGuide,
            },
        }
    end
    return items
end

local MENU_WIDTH = 320
local MENU_MAX_HEIGHT = 420
local MENU_SCROLL_STEP = 28
local MENU_ROW = {
    action = 26,
    section = 18,
    group = 24,
    subgroup = 22,
    guide = 22,
    tip = 28,
    separator = 8,
}

local menuScrollBar
local menuScrollThumb
local menuColors = {
    text = { 1, 1, 1 },
    detail = { 0.82, 0.82, 0.82 },
    accent = { 1, 0.82, 0 },
    secondary = { 0.9, 0.9, 0.86 },
}

local function refreshMenuColors()
    if not ns.Color then
        return
    end
    menuColors.text[1], menuColors.text[2], menuColors.text[3] = ns.Color("text")
    menuColors.detail[1], menuColors.detail[2], menuColors.detail[3] = ns.Color("detail")
    menuColors.accent[1], menuColors.accent[2], menuColors.accent[3] = ns.Color("accent")
    menuColors.secondary[1], menuColors.secondary[2], menuColors.secondary[3] = ns.Color("secondary")
end

local function paintMenuLabel(label, r, g, b)
    if not label then
        return
    end
    local outline = ns.db and ns.db.textOutline
    local font, size = label:GetFont()
    if font and size then
        label:SetFont(font, size, outline and "OUTLINE" or "")
    end
    label:SetTextColor(r or 1, g or 1, b or 1)
end

local function guideLevelBand(guide)
    if type(guide) ~= "table" then
        return ""
    end
    local minLevel = tonumber(guide.minLevel)
    local maxLevel = tonumber(guide.maxLevel)
    if minLevel and maxLevel then
        return string.format("%d-%d", minLevel, maxLevel)
    end
    if minLevel then
        return tostring(minLevel)
    end
    if maxLevel then
        return tostring(maxLevel)
    end
    return ""
end

-- Quest-log style colours for guide level fit vs the player.
local GUIDE_DIFFICULTY = {
    impossible = { r = 1.00, g = 0.10, b = 0.10, label = "Too hard" },
    verydifficult = { r = 1.00, g = 0.50, b = 0.25, label = "Hard" },
    difficult = { r = 1.00, g = 1.00, b = 0.00, label = "On level" },
    standard = { r = 0.25, g = 0.75, b = 0.25, label = "Easy" },
    trivial = { r = 0.50, g = 0.50, b = 0.50, label = "Trivial" },
}

local function guideCompareLevel(guide)
    if type(guide) ~= "table" then
        return nil
    end
    local minLevel = tonumber(guide.minLevel)
    local maxLevel = tonumber(guide.maxLevel)
    if not minLevel and not maxLevel then
        return nil
    end
    minLevel = minLevel or maxLevel
    maxLevel = maxLevel or minLevel
    local level = playerLevel()
    if level < minLevel then
        return minLevel
    end
    if level > maxLevel then
        return maxLevel
    end
    return level
end

local function questGreenRange(level)
    if GetQuestGreenRange then
        local range = GetQuestGreenRange()
        if type(range) == "number" and range > 0 then
            return range
        end
    end
    if level < 10 then
        return 4
    elseif level < 20 then
        return 5
    elseif level < 30 then
        return 6
    elseif level < 40 then
        return 7
    end
    return 8
end

local function guideDifficultyKey(compareLevel)
    local level = playerLevel()
    local levelDiff = compareLevel - level
    if levelDiff >= 5 then
        return "impossible"
    elseif levelDiff >= 3 then
        return "verydifficult"
    elseif levelDiff >= -2 then
        return "difficult"
    elseif -levelDiff <= questGreenRange(level) then
        return "standard"
    end
    return "trivial"
end

-- Returns label, r, g, b for the guide's estimated difficulty at the player's level.
local function guideDifficultyInfo(guide)
    local compare = guideCompareLevel(guide)
    if not compare then
        return nil
    end
    if GetQuestDifficultyColor then
        local color = GetQuestDifficultyColor(compare)
        local key = guideDifficultyKey(compare)
        local info = GUIDE_DIFFICULTY[key]
        if type(color) == "table" and info then
            return info.label, color.r or info.r, color.g or info.g, color.b or info.b
        end
    end
    local info = GUIDE_DIFFICULTY[guideDifficultyKey(compare)]
    if not info then
        return nil
    end
    return info.label, info.r, info.g, info.b
end

local function updateMenuScrollThumb()
    if not menuScrollBar or not menuScrollThumb or not scroll then
        return
    end
    local height = menuScrollBar:GetHeight() or 0
    local contentHeight = content and content:GetHeight() or 0
    local viewHeight = scroll:GetHeight() or 0
    if height < 8 or contentHeight <= viewHeight + 1 then
        menuScrollBar:Hide()
        return
    end
    menuScrollBar:Show()
    local range = scroll:GetVerticalScrollRange() or 0
    local current = scroll:GetVerticalScroll() or 0
    local thumbHeight = math.floor(height * (viewHeight / contentHeight))
    if thumbHeight < 18 then
        thumbHeight = 18
    elseif thumbHeight > height then
        thumbHeight = height
    end
    local travel = height - thumbHeight
    local top = 0
    if range > 0 and travel > 0 then
        top = (current / range) * travel
    end
    local ar, ag, ab = menuColors.accent[1], menuColors.accent[2], menuColors.accent[3]
    menuScrollThumb:SetVertexColor(ar, ag, ab, 0.7)
    menuScrollThumb:ClearAllPoints()
    menuScrollThumb:SetPoint("TOP", menuScrollBar, "TOP", 0, -top)
    menuScrollThumb:SetHeight(thumbHeight)
end

local function styleGuideMenu()
    if not menu then
        return 4
    end
    refreshMenuColors()
    local radius = 0
    if ns.StylePopupFrame then
        radius = ns.StylePopupFrame(menu) or 0
    end
    local pad = 6
    if type(radius) == "number" and radius > 0 then
        pad = math.max(8, math.floor(radius * 0.5) + 2)
    end
    local gutter = 10
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", pad, -pad)
    scroll:SetPoint("BOTTOMRIGHT", -(pad + gutter), pad)
    if menuScrollBar then
        menuScrollBar:ClearAllPoints()
        menuScrollBar:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -(pad + 1), -pad)
        menuScrollBar:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", -(pad + 1), pad)
        menuScrollBar:SetWidth(3)
    end
    local width = (menu:GetWidth() or MENU_WIDTH) - pad * 2 - gutter
    if width < 40 then
        width = 40
    end
    content:SetWidth(width)
    updateMenuScrollThumb()
    return pad
end

local function groupCollapsedDefaults()
    return {
        Dungeons = true,
        Professions = true,
    }
end

local function groupCollapsedByDefault(group)
    if type(group) ~= "string" or group == "" then
        return false
    end
    local defaults = groupCollapsedDefaults()
    if defaults[group] then
        return true
    end
    -- Keep the player's faction leveling guides open; collapse the other side.
    if group == "Alliance" or group == "Horde" then
        local faction = playerFaction()
        if faction and group ~= faction then
            return true
        end
        return false
    end
    -- Class Guides > ClassName: keep the player's class open, collapse the rest.
    local className = group:match("^Class Guides||(.+)$")
    if className then
        local mine = ns.PlayerClass and ns.PlayerClass()
        if mine and className == mine then
            return false
        end
        return true
    end
    return false
end

local function guideMenuCollapsedStore()
    local db = charDB()
    if type(db.guideMenuCollapsed) ~= "table" then
        db.guideMenuCollapsed = {}
    end
    return db.guideMenuCollapsed
end

local function isGuideMenuGroupCollapsed(group)
    if type(group) ~= "string" or group == "" then
        return false
    end
    local store = guideMenuCollapsedStore()
    local saved = store[group]
    if saved ~= nil then
        return saved and true or false
    end
    return groupCollapsedByDefault(group)
end

local function toggleGuideMenuGroup(group)
    if type(group) ~= "string" or group == "" then
        return
    end
    local store = guideMenuCollapsedStore()
    store[group] = not isGuideMenuGroupCollapsed(group)
end

local presentMenu

local function setRowHover(row, on)
    if not row or not row.hover then
        return
    end
    if not on or not row:IsEnabled() or not row:IsMouseEnabled() then
        row.hover:Hide()
        return
    end
    local ar, ag, ab = menuColors.accent[1], menuColors.accent[2], menuColors.accent[3]
    local light = ns.IsLightBackground and ns.IsLightBackground()
    row.hover:SetVertexColor(ar, ag, ab, light and 0.12 or 0.18)
    row.hover:Show()
end

local function setRowMark(row, kind)
    if not row or not row.mark then
        return
    end
    local ar, ag, ab = menuColors.accent[1], menuColors.accent[2], menuColors.accent[3]
    if kind == "current" then
        row.mark:SetVertexColor(ar, ag, ab, 0.95)
        row.mark:Show()
    elseif kind == "recommended" then
        row.mark:SetVertexColor(0.45, 0.9, 0.45, 0.9)
        row.mark:Show()
    elseif kind == "action" then
        row.mark:SetVertexColor(ar, ag, ab, 0.55)
        row.mark:Show()
    else
        row.mark:Hide()
    end
end

local function setRowWash(row, kind)
    if not row or not row.wash then
        return
    end
    local light = ns.IsLightBackground and ns.IsLightBackground()
    if kind == "group" then
        local ar, ag, ab = menuColors.accent[1], menuColors.accent[2], menuColors.accent[3]
        row.wash:SetVertexColor(ar, ag, ab, light and 0.1 or 0.14)
        row.wash:Show()
    elseif kind == "current" then
        local ar, ag, ab = menuColors.accent[1], menuColors.accent[2], menuColors.accent[3]
        row.wash:SetVertexColor(ar, ag, ab, light and 0.08 or 0.12)
        row.wash:Show()
    elseif kind == "recommended" then
        row.wash:SetVertexColor(0.35, 0.75, 0.4, light and 0.1 or 0.12)
        row.wash:Show()
    else
        row.wash:Hide()
    end
end

local function acquireRow(index)
    local row = rows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, content)
    row:SetHeight(MENU_ROW.guide)
    row.wash = row:CreateTexture(nil, "BACKGROUND")
    row.wash:SetAllPoints()
    row.wash:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    row.wash:Hide()
    row.hover = row:CreateTexture(nil, "BORDER")
    row.hover:SetAllPoints()
    row.hover:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    row.hover:Hide()
    row.mark = row:CreateTexture(nil, "ARTWORK")
    row.mark:SetWidth(2)
    row.mark:SetPoint("TOPLEFT", 0, 0)
    row.mark:SetPoint("BOTTOMLEFT", 0, 0)
    row.mark:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    row.mark:Hide()
    row.chevron = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.chevron:SetPoint("LEFT", 8, 0)
    row.chevron:SetWidth(12)
    row.chevron:SetJustifyH("CENTER")
    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.label:SetPoint("LEFT", 24, 0)
    row.label:SetPoint("RIGHT", -52, 0)
    row.label:SetJustifyH("LEFT")
    row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.meta:SetPoint("RIGHT", -10, 0)
    row.meta:SetWidth(44)
    row.meta:SetJustifyH("RIGHT")
    row.rule = row:CreateTexture(nil, "ARTWORK")
    row.rule:SetHeight(1)
    row.rule:SetPoint("LEFT", 10, 0)
    row.rule:SetPoint("RIGHT", -10, 0)
    row.rule:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    row.rule:Hide()
    row:SetScript("OnEnter", function(self)
        if self:IsMouseEnabled() then
            setRowHover(self, true)
        end
        if self.tipTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tipTitle, 1, 1, 1)
            if self.tipDetail then
                GameTooltip:AddLine(self.tipDetail, 0.9, 0.9, 0.9, true)
            end
            if self.guideId then
                local guide = findGuide(self.guideId)
                local band = guideLevelBand(guide)
                local label, r, g, b = guideDifficultyInfo(guide)
                if band ~= "" and label then
                    GameTooltip:AddLine(string.format("Levels %s · %s", band, label), r, g, b, true)
                elseif label then
                    GameTooltip:AddLine("Difficulty: " .. label, r, g, b, true)
                elseif band ~= "" then
                    GameTooltip:AddLine("Levels " .. band, 0.9, 0.9, 0.9, true)
                end
            end
            if ns.FinishTooltip then
                ns.FinishTooltip()
            else
                GameTooltip:Show()
            end
        end
    end)
    row:SetScript("OnLeave", function(self)
        setRowHover(self, false)
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if self.action == "options" then
            if menu then
                menu:Hide()
            end
            if ns.OpenOptions then
                ns.OpenOptions()
            end
            return
        end
        if self.action == "sync" then
            if menu then
                menu:Hide()
            end
            if ns.PartySyncOpenPicker then
                ns.PartySyncOpenPicker(menu)
            end
            return
        end
        if self.action == "toggleGroup" and self.groupName then
            toggleGuideMenuGroup(self.groupName)
            if presentMenu then
                presentMenu(true)
            end
            return
        end
        if self.action == "rxp" and self.rxpGroup and self.rxpName and ns.LoadRestedXPGuide then
            ns.LoadRestedXPGuide(self.rxpGroup, self.rxpName)
            if menu then
                menu:Hide()
            end
            return
        end
        if self.guideId then
            ns.GuideSelect(self.guideId)
            if menu then
                menu:Hide()
            end
        end
    end)
    rows[index] = row
    return row
end

local function rxpPlain(text)
    if type(text) ~= "string" then
        return ""
    end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("\\n", " ")
    text = text:gsub("|n", " ")
    return strtrim(text)
end

local function rxpGuideLabel(rxp, guide)
    local name
    if type(rxp.GetGuideName) == "function" then
        local ok, value = pcall(rxp.GetGuideName, guide)
        if ok and type(value) == "string" then
            name = value
        end
    end
    name = rxpPlain(name)
    if name == "" then
        name = rxpPlain(guide.displayname)
    end
    if name == "" then
        name = rxpPlain(guide.name)
    end
    return name
end

function ns.LoadRestedXPGuide(group, name)
    local rxp = ns.RestedXP and ns.RestedXP()
    if not rxp or type(group) ~= "string" or type(name) ~= "string" or type(rxp.GetGuideTable) ~= "function" then
        return
    end
    local ok, guide = pcall(rxp.GetGuideTable, group, name)
    if not ok or type(guide) ~= "table" then
        return
    end
    local clicked = false
    local funcName = guide.OnClick
    if type(funcName) == "string" and type(rxp.functions) == "table" and type(rxp.functions[funcName]) == "function" then
        clicked = pcall(rxp.functions[funcName], guide)
    end
    if not clicked then
        pcall(rxp.LoadGuide, rxp, guide)
    end
    if ns.RefreshTracker then
        ns.RefreshTracker(true)
    end
end

function ns.RestedXPGuideRows()
    local rxp = ns.RestedXP and ns.RestedXP()
    if not rxp or type(rxp.guideList) ~= "table" then
        return nil
    end
    local profile = rxp.settings and rxp.settings.profile
    local showUnused = profile and profile.showUnusedGuides and true or false
    local ga = _G.RXPCData and _G.RXPCData.GA and true or false
    local current = rxp.currentGuide
    local currentGroup = type(current) == "table" and current.group
    local currentName = type(current) == "table" and current.name

    local groups = {}
    for group, info in pairs(rxp.guideList) do
        if type(group) == "string" and type(info) == "table" and group ~= "RXPGuides" then
            local first = group:sub(1, 1)
            local farm = first == "+"
            local unused = first == "*"
            local include
            if ga then
                include = farm
            elseif unused then
                include = showUnused
            else
                include = not farm
            end
            if include then
                groups[#groups + 1] = group
            end
        end
    end
    table.sort(groups, function(a, b)
        local wa = tonumber(rxp.guideList[a] and rxp.guideList[a].weight_) or 0
        local wb = tonumber(rxp.guideList[b] and rxp.guideList[b].weight_) or 0
        if wa ~= wb then
            return wa > wb
        end
        return a < b
    end)

    local rows = {}
    local function add(kind, text, group, name, currentRow)
        rows[#rows + 1] = {
            kind = kind,
            text = text,
            group = group,
            name = name,
            current = currentRow and true or false,
        }
    end

    local function guideActive(guide, includeInternal)
        if type(rxp.IsGuideActive) ~= "function" then
            return true
        end
        local ok, value = pcall(rxp.IsGuideActive, guide, includeInternal)
        return ok and value and true or false
    end

    local function selectable(guide)
        if type(guide) ~= "table" or guide.disabled then
            return false
        end
        if type(rxp.IsGuideSelectable) == "function" then
            local ok, value = pcall(rxp.IsGuideSelectable, guide, nil, showUnused)
            if ok then
                return value and true or false
            end
        end
        return true
    end

    local function chaptersOf(guide)
        local list = {}
        if type(guide.chapters) ~= "string" then
            return list
        end
        for chapterName in guide.chapters:gmatch("%s*([^;]+)%s*") do
            if chapterName ~= "" then
                list[#list + 1] = chapterName
            end
        end
        return list
    end

    local function appendGuide(guide, indent, seen)
        if type(guide) ~= "table" or type(guide.name) ~= "string" or type(guide.group) ~= "string" then
            return
        end
        local key = guide.group .. "||" .. guide.name
        if seen[key] then
            return
        end
        seen[key] = true
        local label = indent .. rxpGuideLabel(rxp, guide)
        local chapterGuides = {}
        for _, chapterName in ipairs(chaptersOf(guide)) do
            local chapter
            if type(rxp.GetGuideTable) == "function" then
                local ok, value = pcall(rxp.GetGuideTable, guide.group, chapterName)
                if ok then
                    chapter = value
                end
            end
            if selectable(chapter) and guideActive(chapter, true) then
                chapterGuides[#chapterGuides + 1] = chapter
            end
        end
        if #chapterGuides > 0 then
            add("label", label)
            for _, chapter in ipairs(chapterGuides) do
                appendGuide(chapter, indent .. "    ", seen)
            end
            return
        end
        local isCurrent = guide.group == currentGroup and guide.name == currentName
        add("guide", label, guide.group, guide.name, isCurrent)
    end

    local function byLabel(a, b)
        return rxpGuideLabel(rxp, a) < rxpGuideLabel(rxp, b)
    end

    for _, group in ipairs(groups) do
        local guides = {}
        if type(rxp.GetActiveGuidesInGroup) == "function" then
            local ok, value = pcall(rxp.GetActiveGuidesInGroup, group)
            if ok and type(value) == "table" then
                guides = value
            end
        end
        local buckets = {}
        local bucketOrder = {}
        local loose = {}
        for _, guide in ipairs(guides) do
            if selectable(guide) then
                local subgroup = type(guide.subgroup) == "string" and guide.subgroup or ""
                if subgroup == "" then
                    loose[#loose + 1] = guide
                else
                    local bucket = buckets[subgroup]
                    if not bucket then
                        bucket = {}
                        buckets[subgroup] = bucket
                        bucketOrder[#bucketOrder + 1] = subgroup
                    end
                    bucket[#bucket + 1] = guide
                end
            end
        end
        if type(rxp.GetGuideSubgroups) == "function" then
            local ok, categories = pcall(rxp.GetGuideSubgroups, guides)
            if ok and type(categories) == "table" and #categories > 0 then
                local ordered = {}
                local seenSub = {}
                for _, category in ipairs(categories) do
                    local subgroup = type(category) == "table" and category.subgroup
                    if type(subgroup) == "string" and buckets[subgroup] and not seenSub[subgroup] then
                        seenSub[subgroup] = true
                        ordered[#ordered + 1] = subgroup
                    end
                end
                for _, subgroup in ipairs(bucketOrder) do
                    if not seenSub[subgroup] then
                        ordered[#ordered + 1] = subgroup
                    end
                end
                bucketOrder = ordered
            end
        end
        table.sort(loose, byLabel)
        local emitted = false
        local function ensureHeader()
            if emitted then
                return
            end
            emitted = true
            add("group", group:gsub("^%*", ""):gsub("^%+", ""))
        end
        local seen = {}
        if #loose > 0 then
            ensureHeader()
            for _, guide in ipairs(loose) do
                appendGuide(guide, "", seen)
            end
        end
        for _, subgroup in ipairs(bucketOrder) do
            local list = buckets[subgroup]
            if list and #list > 0 then
                table.sort(list, byLabel)
                ensureHeader()
                add("subgroup", "  " .. rxpPlain(subgroup))
                for _, guide in ipairs(list) do
                    appendGuide(guide, "    ", seen)
                end
            end
        end
    end
    return rows
end

presentMenu = function(keepScroll)
    local pad = styleGuideMenu()
    local y = 2
    local index = 0
    local lastGroup
    local list = ns.GuideList()
    refreshMenuColors()
    local textR, textG, textB = menuColors.text[1], menuColors.text[2], menuColors.text[3]
    local detailR, detailG, detailB = menuColors.detail[1], menuColors.detail[2], menuColors.detail[3]
    local accentR, accentG, accentB = menuColors.accent[1], menuColors.accent[2], menuColors.accent[3]
    local secondaryR, secondaryG, secondaryB = menuColors.secondary[1], menuColors.secondary[2], menuColors.secondary[3]
    local priorScroll = keepScroll and scroll and (scroll:GetVerticalScroll() or 0) or 0
    local currentId = ns.GuideId and ns.GuideId() or nil

    local function place(row, height)
        row:Show()
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
        row:SetHeight(height)
        y = y + height
    end

    local function resetRow(row)
        row.guideId = nil
        row.action = nil
        row.groupName = nil
        row.rxpGroup = nil
        row.rxpName = nil
        row.tipTitle = nil
        row.tipDetail = nil
        row:Enable()
        row:EnableMouse(false)
        row.chevron:SetText("")
        row.chevron:ClearAllPoints()
        row.chevron:SetPoint("LEFT", 8, 0)
        row.chevron:SetWidth(12)
        row.chevron:Show()
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", 24, 0)
        row.label:SetPoint("RIGHT", -52, 0)
        row.label:SetJustifyH("LEFT")
        row.meta:SetText("")
        row.meta:Show()
        row.rule:Hide()
        setRowMark(row, nil)
        setRowWash(row, nil)
        setRowHover(row, false)
    end

    local function layoutLabel(row, left, showChevron)
        left = left or 10
        row.chevron:ClearAllPoints()
        if showChevron then
            row.chevron:SetPoint("LEFT", left, 0)
            row.chevron:SetWidth(12)
            row.chevron:Show()
            row.label:ClearAllPoints()
            row.label:SetPoint("LEFT", row.chevron, "RIGHT", 4, 0)
            row.label:SetPoint("RIGHT", -52, 0)
        else
            row.chevron:SetText("")
            row.chevron:Hide()
            row.label:ClearAllPoints()
            row.label:SetPoint("LEFT", left, 0)
            row.label:SetPoint("RIGHT", -52, 0)
        end
    end

    local function finishMenu()
        for extra = index + 1, #rows do
            rows[extra]:Hide()
            resetRow(rows[extra])
        end
        local height = math.max(40, y + 6)
        content:SetHeight(height)
        local shown = height + pad * 2
        if shown > MENU_MAX_HEIGHT then
            shown = MENU_MAX_HEIGHT
        end
        menu:SetWidth(MENU_WIDTH)
        menu:SetHeight(shown)
        styleGuideMenu()
        if keepScroll then
            local maxScroll = scroll:GetVerticalScrollRange() or 0
            if priorScroll > maxScroll then
                priorScroll = maxScroll
            end
            scroll:SetVerticalScroll(priorScroll)
        else
            scroll:SetVerticalScroll(0)
        end
        updateMenuScrollThumb()
    end

    local function addSeparator()
        index = index + 1
        local row = acquireRow(index)
        resetRow(row)
        row.meta:Hide()
        row.rule:SetVertexColor(accentR, accentG, accentB, 0.28)
        row.rule:Show()
        place(row, MENU_ROW.separator)
    end

    local function addSection(text, r, g, b)
        index = index + 1
        local row = acquireRow(index)
        resetRow(row)
        row.meta:Hide()
        layoutLabel(row, 12, false)
        row.label:SetText(text)
        paintMenuLabel(row.label, r or detailR, g or detailG, b or detailB)
        place(row, MENU_ROW.section)
    end

    local function addAction(action, text, enabled, tipTitle, tipDetail, active)
        index = index + 1
        local row = acquireRow(index)
        resetRow(row)
        row.action = action
        row.tipTitle = tipTitle
        row.tipDetail = tipDetail
        row.meta:Hide()
        layoutLabel(row, 12, false)
        row.label:SetText(text)
        if enabled then
            row:EnableMouse(true)
            paintMenuLabel(row.label, accentR, accentG, accentB)
            setRowMark(row, "action")
        else
            paintMenuLabel(row.label, detailR, detailG, detailB)
        end
        if active then
            setRowWash(row, "current")
        end
        place(row, MENU_ROW.action)
    end

    local function addGuideRow(guide, indent, recommended)
        index = index + 1
        local row = acquireRow(index)
        resetRow(row)
        row.guideId = guide.id
        row:EnableMouse(true)
        local band = guideLevelBand(guide)
        local isCurrent = currentId == guide.id
        local isRecommended = recommended and recommended.id == guide.id
        layoutLabel(row, indent or 18, false)
        row.label:SetText(guide.name or guide.id)
        row.meta:SetText(band)
        local _, diffR, diffG, diffB = guideDifficultyInfo(guide)
        if diffR then
            paintMenuLabel(row.meta, diffR, diffG, diffB)
        else
            paintMenuLabel(row.meta, detailR, detailG, detailB)
        end
        row.tipTitle = guide.name or guide.id
        local tipBits = {}
        if guide.group then
            tipBits[#tipBits + 1] = guide.group
        end
        if guide.subgroup then
            tipBits[#tipBits + 1] = guide.subgroup
        end
        if isCurrent then
            tipBits[#tipBits + 1] = "Currently active"
        elseif isRecommended then
            tipBits[#tipBits + 1] = "Recommended for your level"
        end
        if #tipBits > 0 then
            row.tipDetail = table.concat(tipBits, "  ·  ")
        end
        if isCurrent then
            paintMenuLabel(row.label, accentR, accentG, accentB)
            setRowMark(row, "current")
            setRowWash(row, "current")
        elseif isRecommended then
            paintMenuLabel(row.label, 0.72, 1, 0.72)
            setRowMark(row, "recommended")
            setRowWash(row, "recommended")
        else
            paintMenuLabel(row.label, textR, textG, textB)
        end
        place(row, MENU_ROW.guide)
    end

    addAction("options", "Options", true, "Options", "Open Waynotes settings.")
    local syncTarget = ns.PartySyncFollowTarget and ns.PartySyncFollowTarget()
    local hasPeers = ns.PartySyncHasPeers and ns.PartySyncHasPeers()
    local standalone = ns.UsingStandalone and ns.UsingStandalone()
    if syncTarget then
        addAction("sync", "Synced with " .. syncTarget, true, "Party sync", "Click to change or clear party sync.", true)
    elseif standalone and hasPeers then
        addAction("sync", "Sync with party", true, "Party sync", "Follow a party member's guide progress.")
    elseif standalone then
        addAction("sync", "Sync with party", true, "Party sync", "No party members available right now.")
    else
        addAction("sync", "Sync with party", false, "Party sync", "Turn on Replace RestedXP to sync guides with your party.")
    end
    addSeparator()

    if ns.db and ns.db.restedXPGuides then
        addSection("RestedXP guides", accentR, accentG, accentB)
        local rxpRows = ns.RestedXPGuideRows and ns.RestedXPGuideRows()
        if not rxpRows or #rxpRows == 0 then
            index = index + 1
            local row = acquireRow(index)
            resetRow(row)
            row.meta:Hide()
            layoutLabel(row, 12, false)
            if rxpRows then
                row.label:SetText("No RestedXP guides for this character.")
            else
                row.label:SetText("RestedXP is still loading its guides.")
            end
            paintMenuLabel(row.label, detailR, detailG, detailB)
            place(row, MENU_ROW.tip)
        else
            for _, entry in ipairs(rxpRows) do
                index = index + 1
                local row = acquireRow(index)
                resetRow(row)
                if entry.kind == "guide" then
                    row.action = "rxp"
                    row.rxpGroup = entry.group
                    row.rxpName = entry.name
                    row:EnableMouse(true)
                    row.meta:Hide()
                    layoutLabel(row, 18, false)
                    row.label:SetText(strtrim(entry.text or ""))
                    row.tipTitle = strtrim(entry.text or "")
                    if entry.current then
                        paintMenuLabel(row.label, accentR, accentG, accentB)
                        setRowMark(row, "current")
                        setRowWash(row, "current")
                    else
                        paintMenuLabel(row.label, textR, textG, textB)
                    end
                    place(row, MENU_ROW.guide)
                elseif entry.kind == "group" then
                    row.meta:Hide()
                    layoutLabel(row, 12, false)
                    row.label:SetText(strtrim(entry.text or ""))
                    paintMenuLabel(row.label, accentR, accentG, accentB)
                    setRowWash(row, "group")
                    place(row, MENU_ROW.group)
                else
                    row.meta:Hide()
                    layoutLabel(row, 18, false)
                    row.label:SetText(strtrim(entry.text or ""))
                    paintMenuLabel(row.label, secondaryR, secondaryG, secondaryB)
                    place(row, MENU_ROW.subgroup)
                end
            end
        end
        finishMenu()
        return
    end

    if #list == 0 then
        index = index + 1
        local row = acquireRow(index)
        resetRow(row)
        row.meta:Hide()
        layoutLabel(row, 12, false)
        row.label:SetText("No guides yet. Add a Lua file in the Guides folder.")
        paintMenuLabel(row.label, detailR, detailG, detailB)
        place(row, MENU_ROW.tip)
    end

    local recommended = ns.RecommendedGuide and ns.RecommendedGuide() or nil
    if recommended then
        addSection("Recommended", 0.45, 0.9, 0.45)
        addGuideRow(recommended, 14, recommended)
        addSeparator()
        addSection("All guides", detailR, detailG, detailB)
    end

    local groupCollapsed = false
    local subgroupCollapsed = false
    local lastSubgroup
    for _, guide in ipairs(list) do
        if guide.group ~= lastGroup then
            lastGroup = guide.group
            lastSubgroup = nil
            subgroupCollapsed = false
            groupCollapsed = isGuideMenuGroupCollapsed(guide.group)
            index = index + 1
            local row = acquireRow(index)
            resetRow(row)
            row.action = "toggleGroup"
            row.groupName = guide.group
            row:EnableMouse(true)
            row.meta:Hide()
            layoutLabel(row, 10, true)
            row.chevron:SetText(groupCollapsed and ">" or "v")
            paintMenuLabel(row.chevron, accentR, accentG, accentB)
            row.label:SetText(guide.group)
            paintMenuLabel(row.label, accentR, accentG, accentB)
            setRowWash(row, "group")
            row.tipTitle = guide.group
            row.tipDetail = groupCollapsed and "Click to expand." or "Click to collapse."
            place(row, MENU_ROW.group)
        end
        if not groupCollapsed then
            local subgroup = guide.subgroup
            if type(subgroup) == "string" and subgroup ~= "" then
                if subgroup ~= lastSubgroup then
                    lastSubgroup = subgroup
                    local subKey = guide.group .. "||" .. subgroup
                    subgroupCollapsed = isGuideMenuGroupCollapsed(subKey)
                    index = index + 1
                    local row = acquireRow(index)
                    resetRow(row)
                    row.action = "toggleGroup"
                    row.groupName = subKey
                    row:EnableMouse(true)
                    row.meta:Hide()
                    layoutLabel(row, 22, true)
                    row.chevron:SetText(subgroupCollapsed and ">" or "v")
                    paintMenuLabel(row.chevron, secondaryR, secondaryG, secondaryB)
                    row.label:SetText(subgroup)
                    paintMenuLabel(row.label, secondaryR, secondaryG, secondaryB)
                    row.tipTitle = subgroup
                    row.tipDetail = subgroupCollapsed and "Click to expand." or "Click to collapse."
                    place(row, MENU_ROW.subgroup)
                end
                if not subgroupCollapsed then
                    addGuideRow(guide, 36, recommended)
                end
            else
                lastSubgroup = nil
                subgroupCollapsed = false
                addGuideRow(guide, 18, recommended)
            end
        end
    end
    finishMenu()
end

local function buildMenu()
    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints()
    catcher:SetFrameStrata("DIALOG")
    catcher:SetFrameLevel(1)
    catcher:Hide()
    catcher:RegisterForClicks("AnyUp")
    catcher:SetScript("OnClick", function()
        menu:Hide()
    end)

    menu = CreateFrame("Frame", "WaynotesGuideMenu", UIParent, "BackdropTemplate")
    menu:SetSize(MENU_WIDTH, 80)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(20)
    menu:SetClampedToScreen(true)
    -- Expand the clamp rect so the frame stays 8px inside the screen edges.
    menu:SetClampRectInsets(-8, 8, 8, -8)
    menu:EnableMouse(true)
    menu:EnableMouseWheel(true)
    menu:Hide()

    scroll = CreateFrame("ScrollFrame", nil, menu)
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -18, 8)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(MENU_WIDTH - 26, 40)
    scroll:SetScrollChild(content)

    menuScrollBar = CreateFrame("Frame", nil, menu)
    menuScrollBar:SetWidth(3)
    menuScrollBar:Hide()
    menuScrollThumb = menuScrollBar:CreateTexture(nil, "OVERLAY")
    menuScrollThumb:SetWidth(3)
    menuScrollThumb:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    menuScrollThumb:SetVertexColor(1, 0.82, 0, 0.7)

    local function scrollBy(delta)
        local current = scroll:GetVerticalScroll() or 0
        local maxScroll = scroll:GetVerticalScrollRange() or 0
        local nextScroll = current - delta * MENU_SCROLL_STEP
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        scroll:SetVerticalScroll(nextScroll)
        updateMenuScrollThumb()
    end

    menu:SetScript("OnMouseWheel", function(_, delta)
        scrollBy(delta)
    end)
    scroll:SetScript("OnVerticalScroll", function()
        updateMenuScrollThumb()
    end)
    menu:SetScript("OnShow", function()
        catcher:Show()
        styleGuideMenu()
    end)
    menu:SetScript("OnHide", function()
        catcher:Hide()
    end)
end

buildMenu()

function ns.HideGuideMenu()
    if menu and menu:IsShown() then
        menu:Hide()
    end
end

function ns.ToggleGuideMenu()
    if menu:IsShown() then
        menu:Hide()
        return
    end
    if ns.HideNavMenu then
        ns.HideNavMenu()
    end
    presentMenu()
    local scale = UIParent:GetEffectiveScale()
    if not scale or scale == 0 then
        scale = 1
    end
    local pad = 8
    local x, y = GetCursorPosition()
    x, y = x / scale, y / scale
    local width = menu:GetWidth() or MENU_WIDTH
    local height = menu:GetHeight() or 80
    local screenW = UIParent:GetWidth() or 0
    local screenH = UIParent:GetHeight() or 0
    if x < pad then
        x = pad
    elseif screenW > 0 and x + width > screenW - pad then
        x = math.max(pad, screenW - pad - width)
    end
    if screenH > 0 and y > screenH - pad then
        y = screenH - pad
    end
    if y - height < pad then
        y = pad + height
    end
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    menu:Show()
end

local watcher = CreateFrame("Frame")
local catchUpAt = 0
local catchUpFirstAt = 0
local objectiveSnap
local objectiveSnapReady = false
local pendingOffStepCheck = false
local pendingBagDirty = false
local pendingCatchUpForce = false
local promptedOffStepAt = 0
local promptedDungeonAt = 0
local dungeonCheckAt = 0
-- Coalesce QUEST_LOG spam without sliding forever past a turn-in/accept.
local CATCH_UP_DELAY = 0.15
local CATCH_UP_MAX_WAIT = 0.35

watcher:RegisterEvent("ADDON_LOADED")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:RegisterEvent("ZONE_CHANGED")
watcher:RegisterEvent("ZONE_CHANGED_INDOORS")
watcher:RegisterEvent("QUEST_ACCEPTED")
watcher:RegisterEvent("QUEST_TURNED_IN")
watcher:RegisterEvent("QUEST_REMOVED")
watcher:RegisterEvent("QUEST_LOG_UPDATE")
watcher:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
watcher:RegisterEvent("BAG_UPDATE_DELAYED")
watcher:RegisterEvent("PLAYER_LEVEL_UP")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")

local function objectiveParts(id)
    local parts = {}
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, list = pcall(C_QuestLog.GetQuestObjectives, id)
        if ok and type(list) == "table" then
            for index, info in ipairs(list) do
                if type(info) == "table" then
                    parts[#parts + 1] = string.format(
                        "%d:%d:%d:%s",
                        index,
                        tonumber(info.numFulfilled) or 0,
                        tonumber(info.numRequired) or 0,
                        info.finished and "1" or "0"
                    )
                end
            end
            if #parts > 0 then
                return parts
            end
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle or not GetNumQuestLeaderBoards or not GetQuestLogLeaderBoard then
        return parts
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and qid == id then
            local boards = GetNumQuestLeaderBoards(index) or 0
            for board = 1, boards do
                local text, _, finished = GetQuestLogLeaderBoard(board, index)
                local filled, need = 0, 0
                if type(text) == "string" then
                    local a, b = text:match("(%d+)%s*/%s*(%d+)")
                    filled = tonumber(a) or 0
                    need = tonumber(b) or 0
                end
                parts[#parts + 1] = string.format("%d:%d:%d:%s", board, filled, need, finished and "1" or "0")
            end
            break
        end
    end
    return parts
end

local function objectiveSignature(id)
    local parts = objectiveParts(id)
    if #parts == 0 then
        return ""
    end
    return table.concat(parts, "|")
end

local function logQuestIds()
    local ids = {}
    if not GetNumQuestLogEntries or not GetQuestLogTitle then
        return ids
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
        local qid = questID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, value = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(value) == "number" then
                qid = value
            end
        end
        if not isHeader and type(qid) == "number" and qid > 0 then
            ids[#ids + 1] = qid
        end
    end
    return ids
end

function ns.GuideEncodeSyncStickies()
    if type(lastSyncStickies) ~= "table" or #lastSyncStickies == 0 then
        return ""
    end
    return table.concat(lastSyncStickies, ",")
end

-- Compact per-step kill/loot progress: step:filled/need,filled/need;...
function ns.GuideEncodeSyncProgress(maxLen)
    maxLen = tonumber(maxLen) or 120
    if type(lastSyncProgress) ~= "table" then
        return ""
    end
    local order = {}
    for stepIndex in pairs(lastSyncProgress) do
        order[#order + 1] = stepIndex
    end
    table.sort(order)
    local chunks = {}
    local used = 0
    for _, stepIndex in ipairs(order) do
        local counts = lastSyncProgress[stepIndex]
        if type(counts) == "table" and #counts > 0 then
            local parts = {}
            for _, entry in ipairs(counts) do
                parts[#parts + 1] = string.format("%d/%d", entry.filled or 0, entry.need or 0)
            end
            local body = tostring(stepIndex) .. ":" .. table.concat(parts, ",")
            local extra = (#chunks > 0 and 1 or 0) + #body
            if used + extra > maxLen then
                break
            end
            chunks[#chunks + 1] = body
            used = used + extra
        end
    end
    return table.concat(chunks, ";")
end

-- Compact quest snapshot for party sync. Uses the local log only (never remote).
-- Format: id:flags:filled/need,filled/need;...  flags: 1=on 2=turnedIn 4=objDone
function ns.GuideEncodeSyncQuests(maxLen)
    maxLen = tonumber(maxLen) or 180
    local wanted = {}
    local order = {}
    local function want(id)
        id = tonumber(id)
        if not id or id <= 0 or wanted[id] then
            return
        end
        wanted[id] = true
        order[#order + 1] = id
    end
    for _, id in ipairs(logQuestIds()) do
        want(id)
    end
    local guide = activeGuide()
    if guide then
        local current = progress(guide.id).step
        local from = math.max(1, current - 8)
        local to = math.min(#guide.steps, current + 2)
        for index = from, to do
            local step = guide.steps[index]
            if step then
                for _, id in ipairs(step.quests or {}) do
                    want(id)
                end
            end
        end
        -- Always include quests from stickies currently shown on the host tracker.
        for _, index in ipairs(lastSyncStickies) do
            local step = guide.steps[index]
            if step then
                for _, id in ipairs(step.quests or {}) do
                    want(id)
                end
            end
        end
    end

    local chunks = {}
    local used = 0
    local followingFn = ns.PartySyncFollowing
    ns.PartySyncFollowing = function()
        return false
    end
    local ok, err = pcall(function()
        for _, id in ipairs(order) do
            local on = questOn(id) and true or false
            local completed = questCompleted(id) and true or false
            local objDone = false
            local objs = {}
            if on then
                objDone = questObjectivesDone(id) and true or false
                local states = logObjectiveStates(id)
                if type(states) == "table" then
                    for _, info in ipairs(states) do
                        local filled, need = 0, 0
                        if type(info.text) == "string" then
                            local a, b = info.text:match("(%d+)%s*/%s*(%d+)")
                            filled = tonumber(a) or 0
                            need = tonumber(b) or 0
                        end
                        if need < 1 and info.finished then
                            filled, need = 1, 1
                        end
                        objs[#objs + 1] = string.format("%d/%d", filled, need)
                    end
                end
            end
            local flags = 0
            if on then
                flags = flags + 1
            end
            if completed then
                flags = flags + 2
            end
            if objDone then
                flags = flags + 4
            end
            local body = tostring(id) .. ":" .. tostring(flags)
            if #objs > 0 then
                body = body .. ":" .. table.concat(objs, ",")
            end
            local extra = (#chunks > 0 and 1 or 0) + #body
            if used + extra > maxLen then
                break
            end
            chunks[#chunks + 1] = body
            used = used + extra
        end
    end)
    ns.PartySyncFollowing = followingFn
    if not ok then
        return ""
    end
    return table.concat(chunks, ";")
end

local function takeObjectiveSnap()
    local snap = {}
    for _, id in ipairs(logQuestIds()) do
        snap[id] = objectiveSignature(id)
    end
    return snap
end

local function snapsEqual(a, b)
    if a == b then
        return true
    end
    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end
    local count = 0
    for id, signature in pairs(a) do
        if b[id] ~= signature then
            return false
        end
        count = count + 1
    end
    local other = 0
    for _ in pairs(b) do
        other = other + 1
    end
    return count == other
end

local function progressedQuestIds(before, after)
    local list = {}
    if type(before) ~= "table" or type(after) ~= "table" then
        return list
    end
    for id, signature in pairs(after) do
        local previous = before[id]
        if type(previous) == "string" and previous ~= "" and signature ~= previous then
            local gained = false
            local beforeByBoard = {}
            for part in previous:gmatch("[^|]+") do
                local board, filled = part:match("^(%d+):(%d+):")
                board = tonumber(board)
                filled = tonumber(filled)
                if board and filled then
                    beforeByBoard[board] = filled
                end
            end
            for part in signature:gmatch("[^|]+") do
                local board, filled = part:match("^(%d+):(%d+):")
                board = tonumber(board)
                filled = tonumber(filled)
                if board and filled and filled > (beforeByBoard[board] or 0) then
                    gained = true
                    break
                end
            end
            if gained then
                list[#list + 1] = id
            end
        end
    end
    return list
end

local function stepHasQuest(step, questId)
    if not step or not questId then
        return false
    end
    for _, id in ipairs(step.quests or {}) do
        if id == questId then
            return true
        end
    end
    return false
end

local function currentStepHasQuest(guide, stepIndex, questId)
    local step = guide and guide.steps and guide.steps[stepIndex]
    return stepHasQuest(step, questId)
end

local function findOffStepForQuest(guide, currentIndex, questId)
    if not guide or type(questId) ~= "number" then
        return nil
    end
    local bestIndex
    local bestDistance
    for index, step in ipairs(guide.steps) do
        if index ~= currentIndex and stepApplies(step) and stepHasQuest(step, questId) then
            local when = step.when
            if when == nil or when == "objectives" then
                if not stepDone(step) and questApplies(questId) then
                    local distance = math.abs(index - currentIndex)
                    if not bestIndex or distance < bestDistance or (distance == bestDistance and index > bestIndex) then
                        bestIndex = index
                        bestDistance = distance
                    end
                end
            end
        end
    end
    return bestIndex
end

if not StaticPopupDialogs["WaynotesOffStepJump"] then
    StaticPopupDialogs["WaynotesOffStepJump"] = {
        text = "It seems like you're on another section, jump to step %s?",
        button1 = "Yes",
        button2 = "No",
        button3 = "Don't Ask Again",
        OnAccept = function(self, data)
            local index = data or (self and self.data)
            if type(index) == "number" then
                ns.GuideJump(index)
            end
        end,
        OnCancel = function(self, data)
            local guide = activeGuide()
            local index = data or (self and self.data)
            if guide and type(index) == "number" then
                declinedOffStep[guide.id .. ":" .. index] = true
            end
        end,
        OnAlt = function(self)
            if ns.db then
                ns.db.promptOffStepJump = false
            end
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
            say("Jump suggestions off. Re-enable them in options.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        exclusive = true,
    }
end

if not StaticPopupDialogs["WaynotesDungeonGuide"] then
    StaticPopupDialogs["WaynotesDungeonGuide"] = {
        text = "Load the dungeon guide|n|cffffffff%s|r?",
        button1 = "Yes",
        button2 = "No",
        button3 = "Don't Ask Again",
        OnAccept = function(self, data)
            local guideId = type(data) == "table" and data.guideId or (self and type(self.data) == "table" and self.data.guideId)
            if type(guideId) == "string" then
                ns.GuideSelect(guideId)
            end
        end,
        OnCancel = function(self, data)
            local info = data or (self and self.data)
            local key = type(info) == "table" and info.instance
            if type(key) == "string" and key ~= "" then
                declinedDungeon[key] = true
            end
        end,
        OnAlt = function(self)
            if ns.db then
                ns.db.promptDungeonGuide = false
            end
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
            say("Dungeon guide suggestions off. Re-enable them in options.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        exclusive = true,
    }
end

local function promptDungeonGuide(guide, instanceName)
    if type(guide) ~= "table" or type(guide.id) ~= "string" or not StaticPopup_Show then
        return
    end
    if StaticPopup_Visible and StaticPopup_Visible("WaynotesDungeonGuide") then
        return
    end
    local now = GetTime()
    if now - promptedDungeonAt < 2 then
        return
    end
    promptedDungeonAt = now
    lastDungeonPromptKey = instanceName
    StaticPopup_Show("WaynotesDungeonGuide", guide.name, nil, {
        guideId = guide.id,
        instance = instanceName,
    })
end

local function considerDungeonGuide()
    if not ns.db or not ns.db.promptDungeonGuide then
        return
    end
    if not ns.UsingStandalone or not ns.UsingStandalone() then
        return
    end
    if not IsInInstance or not GetInstanceInfo then
        return
    end
    local inInstance, instanceType = IsInInstance()
    if not inInstance or instanceType ~= "party" then
        lastDungeonPromptKey = nil
        return
    end
    local name = GetInstanceInfo()
    if type(name) ~= "string" or name == "" then
        return
    end
    if declinedDungeon[name] or lastDungeonPromptKey == name then
        return
    end
    local guide = ns.RecommendedDungeonGuide(name)
    if not guide then
        return
    end
    local active = activeGuide()
    if active then
        if active.id == guide.id then
            lastDungeonPromptKey = name
            return
        end
        if dungeonMatchScore(name, active) > 0 then
            lastDungeonPromptKey = name
            return
        end
    end
    promptDungeonGuide(guide, name)
end

local function promptOffStepJump(index)
    if type(index) ~= "number" or not StaticPopup_Show then
        return
    end
    if StaticPopup_Visible and StaticPopup_Visible("WaynotesOffStepJump") then
        return
    end
    local now = GetTime()
    if now - promptedOffStepAt < 2 then
        return
    end
    promptedOffStepAt = now
    StaticPopup_Show("WaynotesOffStepJump", tostring(index), nil, index)
end

local function considerOffStepJump(questIds)
    if not ns.db or not ns.db.promptOffStepJump then
        return
    end
    if not ns.UsingStandalone or not ns.UsingStandalone() then
        return
    end
    local guide = activeGuide()
    if not guide or type(questIds) ~= "table" or #questIds == 0 then
        return
    end
    local current = progress(guide.id).step
    local bestIndex
    local bestDistance
    for _, questId in ipairs(questIds) do
        if not currentStepHasQuest(guide, current, questId) then
            local index = findOffStepForQuest(guide, current, questId)
            if index and not declinedOffStep[guide.id .. ":" .. index] then
                local distance = math.abs(index - current)
                if distance > 3 then
                    if not bestIndex or distance < bestDistance or (distance == bestDistance and index > bestIndex) then
                        bestIndex = index
                        bestDistance = distance
                    end
                end
            end
        end
    end
    if bestIndex then
        promptOffStepJump(bestIndex)
    end
end

local function runCatchUp()
    if not ns.UsingStandalone or not ns.UsingStandalone() then
        pendingOffStepCheck = false
        pendingCatchUpForce = false
        return false
    end
    local beforeSnap = objectiveSnap
    local checkOffStep = pendingOffStepCheck and objectiveSnapReady
    local force = pendingCatchUpForce
    pendingOffStepCheck = false
    pendingCatchUpForce = false
    local afterSnap = takeObjectiveSnap()
    local changed = not objectiveSnapReady or not snapsEqual(beforeSnap, afterSnap)
    local progressed
    if checkOffStep and changed then
        progressed = progressedQuestIds(beforeSnap, afterSnap)
    end
    objectiveSnap = afterSnap
    objectiveSnapReady = true
    -- Always advance steps. QUEST_LOG can fire before the log API reflects a
    -- turn-in; skipping CatchUp on "unchanged" snap left the guide stuck.
    -- Quest progress always wins over a manual review pause.
    reviewKey = nil
    local moved = ns.GuideCatchUp()
    -- Rebuild only when something real happened. Loot/cast QUEST_LOG noise
    -- with no snap change and no step move stays quiet (cast lag fix).
    if moved then
        markStepsDirty(true)
    elseif changed or force then
        markStepsDirty(false)
    end
    if checkOffStep and progressed and #progressed > 0 then
        considerOffStepJump(progressed)
    end
    return moved
end

local function pumpWatcher()
    watcher:SetScript("OnUpdate", function(self)
        local now = GetTime()
        local dueCatchUp = catchUpAt > 0 and now >= catchUpAt
        local dueDungeon = dungeonCheckAt > 0 and now >= dungeonCheckAt
        if not dueCatchUp and not dueDungeon then
            return
        end
        if dueCatchUp then
            catchUpAt = 0
            catchUpFirstAt = 0
        end
        if dueDungeon then
            dungeonCheckAt = 0
        end
        if catchUpAt <= 0 and dungeonCheckAt <= 0 then
            self:SetScript("OnUpdate", nil)
        end
        if dueCatchUp then
            runCatchUp()
        end
        if dueDungeon then
            considerDungeonGuide()
        end
    end)
end

local function queueCatchUp(delay, checkOffStep, force)
    if checkOffStep then
        pendingOffStepCheck = true
    end
    if force then
        pendingCatchUpForce = true
    end
    delay = tonumber(delay) or CATCH_UP_DELAY
    local now = GetTime()
    if catchUpAt <= 0 then
        catchUpFirstAt = now
        catchUpAt = now + delay
    else
        -- Trailing coalesce, but never slide past first-event + max wait.
        -- The old "always extend" timer never fired during loot QUEST_LOG spam.
        local trailing = now + delay
        local capped = (catchUpFirstAt > 0 and catchUpFirstAt or now) + CATCH_UP_MAX_WAIT
        local when = trailing
        if when > capped then
            when = capped
        end
        if when < catchUpAt then
            catchUpAt = when
        end
    end
    pumpWatcher()
end

local function queueDungeonCheck(delay)
    local when = GetTime() + (delay or 0.5)
    if when > dungeonCheckAt then
        dungeonCheckAt = when
    end
    pumpWatcher()
end

watcher:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addonName then
            return
        end
        charDB()
        return
    end
    if event == "PLAYER_LOGIN" then
        charDB()
        if ns.InitDB then
            ns.InitDB()
        end
        objectiveSnapReady = false
        declinedOffStep = {}
        declinedDungeon = {}
        lastDungeonPromptKey = nil
        if ns.UsingStandalone and ns.UsingStandalone() then
            ns.GuideEnsure()
        end
        queueCatchUp(0.5, false)
        queueDungeonCheck(0.75)
        return
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        charDB()
        if event == "PLAYER_ENTERING_WORLD" then
            objectiveSnapReady = false
            declinedOffStep = {}
            if ns.InitDB then
                ns.InitDB()
            end
            if ns.UsingStandalone and ns.UsingStandalone() then
                ns.GuideEnsure()
            end
        end
        queueCatchUp(0.5, false)
        queueDungeonCheck(0.75)
        markStepsDirty(true)
        return
    end
    if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        markStepsDirty(false)
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        if pendingBagDirty then
            pendingBagDirty = false
            if lastSyncNeedsBag then
                markStepsDirty(false)
            end
        end
        -- Combat may have deferred quest catch-up under loot spam; flush now.
        if ns.UsingStandalone and ns.UsingStandalone() then
            queueCatchUp(0.05, true, true)
        end
        return
    end
    if event == "PLAYER_LEVEL_UP" then
        markStepsDirty(false)
        return
    end
    if event == "BAG_UPDATE_DELAYED" then
        -- Loot and reagent spends fire this constantly. Only rebuild when the
        -- tracker is showing bag-fed collect lines (not every grey/green loot).
        if not lastSyncNeedsBag then
            return
        end
        if InCombatLockdown and InCombatLockdown() then
            pendingBagDirty = true
            return
        end
        markStepsDirty(false)
        return
    end
    if event == "UNIT_QUEST_LOG_CHANGED" and name ~= "player" then
        return
    end
    if not ns.UsingStandalone or not ns.UsingStandalone() then
        return
    end
    -- Accept / turn-in / remove must always refresh, even if the objective snap
    -- looks unchanged for a frame (Forever can fire before the log API settles).
    if event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" or event == "QUEST_REMOVED" then
        queueCatchUp(0.05, false, true)
        return
    end
    local checkOffStep = event == "QUEST_LOG_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED"
    queueCatchUp(CATCH_UP_DELAY, checkOffStep)
end)
