local addonName, ns = ...

local order = {}
local byId = {}

local menu
local catcher
local scroll
local content
local rows = {}

local stepApplies
local progressCounts
local neighbor
local inferLevels
local inferRaces

local function say(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffRestedXP Better|r " .. text)
    end
end

local function charDB()
    if type(RestedXPBetterCharDB) ~= "table" then
        RestedXPBetterCharDB = {}
    end
    if type(RestedXPBetterCharDB.progress) ~= "table" then
        RestedXPBetterCharDB.progress = {}
    end
    return RestedXPBetterCharDB
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
    end
    if ns.RefreshOptions then
        ns.RefreshOptions()
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

local function copyNames(value)
    if type(value) ~= "table" then
        return nil
    end
    local list = {}
    local seen = {}
    for _, name in ipairs(value) do
        if type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            list[#list + 1] = name
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
            copy.classes = copyNames(step.classes) or classes
            copy.excludeClasses = copyNames(step.excludeClasses) or excludeClasses
            copy.races = copyNames(step.races) or races
            copy.excludeRaces = copyNames(step.excludeRaces) or excludeRaces
        end
    end
    if not copy.classes then
        copy.classes = copyNames(step.classes)
        copy.excludeClasses = copyNames(step.excludeClasses)
        copy.races = copyNames(step.races)
        copy.excludeRaces = copyNames(step.excludeRaces)
    end
    if step.mode == "softcore" or step.mode == "hardcore" then
        copy.mode = step.mode
    elseif step.note == "softcore" or step.note == "hardcore" then
        copy.mode = step.note
    end
    if type(step.note) == "string" and step.note ~= "" and step.note ~= "softcore" and step.note ~= "hardcore" then
        copy.note = step.note
    end
    copy.map = tonumber(step.map)
    copy.x = tonumber(step.x)
    copy.y = tonumber(step.y)
    if type(step.travel) == "table" or type(step.travel) == "string" or step.travel == true then
        copy.travel = step.travel
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
    if step.when == "accepted" or step.when == "complete" or step.when == "objectives" then
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
    local races = copyNames(guide.races) or inferRaces(name, id)
    local classes = copyNames(guide.classes)
    local excludeRaces = copyNames(guide.excludeRaces)
    local excludeClasses = copyNames(guide.excludeClasses)
    if not byId[id] then
        order[#order + 1] = id
    end
    byId[id] = {
        id = id,
        name = name,
        group = group,
        faction = faction,
        minLevel = minLevel,
        maxLevel = maxLevel,
        races = races,
        classes = classes,
        excludeRaces = excludeRaces,
        excludeClasses = excludeClasses,
        steps = steps,
    }
end

function ns.GuideList()
    local list = {}
    for _, id in ipairs(order) do
        if byId[id] then
            list[#list + 1] = byId[id]
        end
    end
    table.sort(list, function(a, b)
        if a.group ~= b.group then
            return a.group < b.group
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

local function questOn(id)
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
    return false
end

local function questCompleted(id)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, done = pcall(C_QuestLog.IsQuestFlaggedCompleted, id)
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

local function logObjectives(id)
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, list = pcall(C_QuestLog.GetQuestObjectives, id)
        if ok and type(list) == "table" then
            local lines = {}
            for _, info in ipairs(list) do
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
                if #lines >= 4 then
                    break
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
                local text = GetQuestLogLeaderBoard(board, index)
                if type(text) == "string" and text ~= "" then
                    lines[#lines + 1] = text
                end
                if #lines >= 4 then
                    break
                end
            end
            if #lines > 0 then
                return lines
            end
            return nil
        end
    end
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

local function questObjectivesDone(id)
    if questCompleted(id) then
        return true
    end
    if not questOn(id) then
        return false
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

local function questSatisfied(id, when)
    if when == "complete" then
        return questCompleted(id)
    end
    if when == "accepted" then
        return questOn(id) or questCompleted(id)
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

local function stepDone(step)
    if not step or not stepApplies(step) then
        return true
    end
    local when = step.when
    if when ~= "accepted" and when ~= "complete" and when ~= "objectives" then
        return false
    end
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
            if questSatisfied(id, when) then
                return true
            end
        end
        return false
    end
    for _, id in ipairs(ids) do
        if not questSatisfied(id, when) then
            return false
        end
    end
    return true
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

function ns.GuideCatchUp()
    local guide = activeGuide()
    if not guide then
        return false
    end
    local entry = progress(guide.id)
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
        elseif not stepDone(step) then
            break
        else
            local hopped = neighbor(guide, entry.step, 1)
            if not hopped then
                break
            end
            entry.step = hopped
            guard = guard + 1
        end
    end
    return entry.step ~= before
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
        local score = ns.GuideScore(guide)
        if score > -500 then
            ranked[#ranked + 1] = { guide = guide, score = score }
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

function ns.GuideEnsure()
    if activeGuide() then
        return false
    end
    local guide = ns.RecommendedGuide()
    if not guide then
        local list = ns.GuideList()
        guide = list[1]
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
    return true
end

function ns.GuideSelect(id)
    local guide = findGuide(id)
    if not guide then
        say("No guide with id \"" .. tostring(id) .. "\". /rxpb guides lists them.")
        return
    end
    reviewKey = nil
    local db = charDB()
    db.guide = guide.id
    local entry = progress(guide.id)
    if entry.step > #guide.steps then
        entry.step = #guide.steps
    end
    ns.GuideCatchUp()
    refresh()
    if not ns.db or not ns.db.standaloneGuide then
        say("Selected " .. guide.name .. ". Turn on Use our guide to show it.")
        return
    end
    say(guide.name .. ", step " .. progress(guide.id).step .. ".")
end

function ns.GuideCanStep(direction)
    local guide = activeGuide()
    if not guide then
        return false
    end
    return neighbor(guide, progress(guide.id).step, direction < 0 and -1 or 1) ~= nil
end

function ns.GuideStep(direction)
    local guide = activeGuide()
    if not guide then
        return
    end
    local entry = progress(guide.id)
    local nextStep = neighbor(guide, entry.step, direction < 0 and -1 or 1)
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
end

function ns.GuideJump(index)
    index = tonumber(index)
    if not index then
        return
    end
    index = math.floor(index)
    local guide = activeGuide()
    if not guide then
        say("Choose a guide first. Right-click the tracker, or use /rxpb guides.")
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
end

function ns.GuideSkip(index)
    ns.GuideJump((tonumber(index) or 0) + 1)
end

local function addDetail(details, seen, text)
    if type(text) ~= "string" then
        return
    end
    text = strtrim(text)
    if text == "" or #details >= 6 then
        return
    end
    local key = text:lower()
    if seen[key] then
        return
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
            return "Turn in at " .. who.name
        end
        return "Accept at " .. who.name
    end
    if turnIn then
        return "Turn in to " .. who.name
    end
    return "Accept from " .. who.name
end

local function authorPin(step)
    if type(step.map) ~= "number" or type(step.x) ~= "number" or type(step.y) ~= "number" then
        return nil
    end
    local x, y = step.x, step.y
    if ns.IsForever and ns.IsForever() and LibQuestieDB and type(LibQuestieDB.EraToForeverByUiMapId) == "function" then
        local ok, nx, ny = pcall(LibQuestieDB.EraToForeverByUiMapId, step.map, x, y)
        if ok and type(nx) == "number" and type(ny) == "number" then
            x, y = nx, ny
        end
    end
    return {
        map = step.map,
        x = x,
        y = y,
        zone = ns.MapName and ns.MapName(step.map) or nil,
    }
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
    if not pin or type(pin.map) ~= "number" or type(pin.x) ~= "number" or type(pin.y) ~= "number" then
        return nil
    end
    if type(LibStub) ~= "function" then
        return nil
    end
    local ok, hbd = pcall(LibStub, "HereBeDragons-2.0")
    if not ok or type(hbd) ~= "table" or type(hbd.GetWorldCoordinatesFromZone) ~= "function" then
        return nil
    end
    local fine, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, pin.x / 100, pin.y / 100, pin.map)
    if not fine or type(wx) ~= "number" or type(wy) ~= "number" then
        return nil
    end
    return { wx = wx, wy = wy, instance = instance }
end

local function headlineFor(step)
    if step.text then
        return step.text
    end
    local id = step.quests[1]
    if id then
        return questName(id)
    end
    return "Step"
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

    local details = {}
    local seen = {}
    if type(step.details) == "table" then
        for _, line in ipairs(step.details) do
            addDetail(details, seen, line)
        end
    end
    addDetail(details, seen, step.note)

    if full then
        local facts = step.quests[1] and ns.QuestFacts and ns.QuestFacts(step.quests[1])
        addDetail(details, seen, whoLine(facts and (step.when == "complete" and facts.turnIn or facts.giver), step.when == "complete"))
        local allDone = #step.quests > 0
        local unresolved = false
        for _, id in ipairs(step.quests) do
            if questCompleted(id) then
                -- This quest is already turned in.
            elseif questOn(id) then
                allDone = false
                local lines = logObjectives(id)
                if lines then
                    for _, line in ipairs(lines) do
                        addDetail(details, seen, line)
                    end
                end
            else
                allDone = false
                local questFacts = ns.QuestFacts and ns.QuestFacts(id)
                if questFacts and questFacts.lines then
                    for _, line in ipairs(questFacts.lines) do
                        addDetail(details, seen, line)
                    end
                else
                    unresolved = true
                end
            end
        end
        if allDone then
            addDetail(details, seen, "Completed.")
        elseif unresolved and not (ns.QuestieReady and ns.QuestieReady()) then
            addDetail(details, seen, "QuestieDB is not installed.")
        end
    end

    local item = {
        number = step.index,
        headline = headlineFor(step),
        details = details,
        actions = {},
        names = {},
        quests = {},
        stepIndex = step.index,
        sticky = false,
        stepQuests = entries,
        questId = primary and primary.id,
        questName = primary and primary.name,
    }
    if full then
        local pin = pinForStep(step)
        if pin then
            item.place = {
                x = pin.x,
                y = pin.y,
                zone = pin.zone,
            }
            item.waypoint = worldPoint(pin)
        end
        if ns.TravelApplyToItem then
            item = ns.TravelApplyToItem(item, step) or item
        end
    end
    return item
end

function ns.GuideObjectives()
    local guide = activeGuide()
    if not guide then
        return {
            {
                number = 0,
                headline = "No guide selected",
                details = {
                    "Right-click the tracker to choose a guide.",
                    "Add guides as Lua files in the Guides folder. /rxpb guides lists them.",
                },
                actions = {},
                names = {},
                quests = {},
                stepQuests = {},
            },
        }
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
    local ahead = 0
    if not (ns.db and ns.db.simpleMode) then
        ahead = 3
    end
    local items = {}
    local index = entry.step
    local guard = 0
    while index <= count and guard < count do
        local step = guide.steps[index]
        if stepApplies(step) then
            items[#items + 1] = buildItem(step, #items == 0)
            if #items > ahead then
                break
            end
        end
        index = index + 1
        guard = guard + 1
    end
    if #items == 0 then
        return {
            {
                number = entry.step,
                headline = "End of this guide",
                details = { "Right-click the tracker to choose another guide." },
                actions = {},
                names = {},
                quests = {},
                stepQuests = {},
            },
        }
    end
    return items
end

local function acquireRow(index)
    local row = rows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, content)
    row:SetHeight(20)
    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.label:SetPoint("LEFT", 8, 0)
    row.label:SetPoint("RIGHT", -8, 0)
    row.label:SetJustifyH("LEFT")
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    row:SetScript("OnClick", function(self)
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

local function presentMenu()
    local y = 4
    local index = 0
    local lastGroup
    local list = ns.GuideList()
    local function place(row, height)
        row:Show()
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
        row:SetHeight(height)
        y = y + height
    end
    if #list == 0 then
        index = 1
        local row = acquireRow(index)
        row.guideId = nil
        row:EnableMouse(false)
        row.label:SetText("No guides yet. Add a Lua file in the Guides folder.")
        row.label:SetTextColor(0.8, 0.8, 0.8)
        place(row, 32)
    end
    local recommended = ns.RecommendedGuide and ns.RecommendedGuide() or nil
    if recommended then
        index = index + 1
        local row = acquireRow(index)
        row.guideId = nil
        row:EnableMouse(false)
        row.label:SetText("Recommended")
        row.label:SetTextColor(0.45, 0.9, 0.45)
        place(row, 18)
        index = index + 1
        row = acquireRow(index)
        row.guideId = recommended.id
        row:EnableMouse(true)
        local band = ""
        if recommended.minLevel and recommended.maxLevel then
            band = string.format("  %d-%d", recommended.minLevel, recommended.maxLevel)
        end
        row.label:SetText(recommended.name .. band)
        if ns.GuideId() == recommended.id and ns.Color then
            local r, g, b = ns.Color("accent")
            row.label:SetTextColor(r, g, b)
        else
            row.label:SetTextColor(0.7, 1, 0.7)
        end
        place(row, 20)
    end
    for _, guide in ipairs(list) do
        if guide.group ~= lastGroup then
            lastGroup = guide.group
            index = index + 1
            local row = acquireRow(index)
            row.guideId = nil
            row:EnableMouse(false)
            row.label:SetText(guide.group)
            row.label:SetTextColor(1, 0.82, 0.35)
            place(row, 18)
        end
        index = index + 1
        local row = acquireRow(index)
        row.guideId = guide.id
        row:EnableMouse(true)
        local mark = (recommended and recommended.id == guide.id) and "* " or ""
        local suffix = guide.faction and (" (" .. guide.faction .. ")") or ""
        row.label:SetText(mark .. guide.name .. suffix)
        if ns.GuideId() == guide.id and ns.Color then
            local r, g, b = ns.Color("accent")
            row.label:SetTextColor(r, g, b)
        else
            row.label:SetTextColor(1, 1, 1)
        end
        place(row, 20)
    end
    for extra = index + 1, #rows do
        rows[extra]:Hide()
        rows[extra].guideId = nil
    end
    local height = math.max(36, y + 8)
    content:SetHeight(height)
    local shown = height + 12
    if shown > 360 then
        shown = 360
    end
    menu:SetHeight(shown)
    scroll:SetVerticalScroll(0)
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

    menu = CreateFrame("Frame", "RestedXPBetterGuideMenu", UIParent, "BackdropTemplate")
    menu:SetSize(280, 80)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(20)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:EnableMouseWheel(true)
    menu:Hide()
    menu:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    menu:SetBackdropColor(0.04, 0.04, 0.04, 0.96)
    menu:SetBackdropBorderColor(1, 0.82, 0, 0.85)

    scroll = CreateFrame("ScrollFrame", nil, menu)
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -4, 4)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(268, 40)
    scroll:SetScrollChild(content)

    menu:SetScript("OnMouseWheel", function(_, delta)
        local current = scroll:GetVerticalScroll() or 0
        local maxScroll = scroll:GetVerticalScrollRange() or 0
        local nextScroll = current - delta * 24
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        scroll:SetVerticalScroll(nextScroll)
    end)
    menu:SetScript("OnShow", function(self)
        catcher:Show()
        local r, g, b = 1, 0.82, 0
        if ns.Color then
            r, g, b = ns.Color("accent")
        end
        self:SetBackdropBorderColor(r, g, b, 0.9)
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
    local x, y = GetCursorPosition()
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    menu:Show()
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("ADDON_LOADED")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:RegisterEvent("QUEST_ACCEPTED")
watcher:RegisterEvent("QUEST_TURNED_IN")
watcher:RegisterEvent("QUEST_REMOVED")
watcher:RegisterEvent("QUEST_LOG_UPDATE")
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
        if ns.UsingStandalone and ns.UsingStandalone() then
            local moved = ns.GuideCatchUp()
            if moved then
                refresh()
            end
        end
        return
    end
    if not ns.UsingStandalone or not ns.UsingStandalone() then
        return
    end
    -- Quest progress always wins over a manual review pause.
    reviewKey = nil
    local guide = activeGuide()
    local before = guide and progress(guide.id).step
    if ns.GuideCatchUp() and guide and progress(guide.id).step ~= before and ns.RefreshTracker then
        ns.RefreshTracker(true)
    end
end)
