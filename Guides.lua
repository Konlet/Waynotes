local addonName, ns = ...

local order = {}
local byId = {}

local menu
local catcher
local scroll
local content
local rows = {}

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

local function cleanStep(step)
    if type(step) ~= "table" then
        return nil
    end
    local copy = {}
    if type(step.text) == "string" and step.text ~= "" then
        copy.text = step.text
    end
    if type(step.note) == "string" and step.note ~= "" then
        copy.note = step.note
    end
    if step.when == "accepted" or step.when == "complete" then
        copy.when = step.when
    end
    copy.map = tonumber(step.map)
    copy.x = tonumber(step.x)
    copy.y = tonumber(step.y)
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
    if not byId[id] then
        order[#order + 1] = id
    end
    byId[id] = {
        id = id,
        name = name,
        group = group,
        faction = faction,
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
    local total = #guide.steps
    if current > total then
        current = total
    end
    return string.format("%d%%", math.floor(current / total * 100 + 0.5))
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

local function stepDone(step)
    if not step or (step.when ~= "accepted" and step.when ~= "complete") or #step.quests == 0 then
        return false
    end
    for _, id in ipairs(step.quests) do
        if step.when == "accepted" then
            if not questOn(id) and not questCompleted(id) then
                return false
            end
        elseif not questCompleted(id) then
            return false
        end
    end
    return true
end

function ns.GuideCatchUp()
    local guide = activeGuide()
    if not guide then
        return false
    end
    local entry = progress(guide.id)
    local moved = false
    local guard = 0
    while entry.step < #guide.steps and guard < 40 do
        if not stepDone(guide.steps[entry.step]) then
            break
        end
        entry.step = entry.step + 1
        moved = true
        guard = guard + 1
    end
    return moved
end

function ns.GuideEnsure()
    if activeGuide() then
        return false
    end
    local list = ns.GuideList()
    local guide = list[1]
    if not guide then
        return false
    end
    charDB().guide = guide.id
    local entry = progress(guide.id)
    if entry.step > #guide.steps then
        entry.step = #guide.steps
    end
    return true
end

function ns.GuideSelect(id)
    local guide = findGuide(id)
    if not guide then
        say("No guide with id \"" .. tostring(id) .. "\". /rxpb guides lists them.")
        return
    end
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
    local step = progress(guide.id).step
    if direction < 0 then
        return step > 1
    end
    return step < #guide.steps
end

function ns.GuideStep(direction)
    local guide = activeGuide()
    if not guide then
        return
    end
    local entry = progress(guide.id)
    local count = #guide.steps
    local nextStep = entry.step + (direction < 0 and -1 or 1)
    if nextStep < 1 then
        nextStep = 1
    elseif nextStep > count then
        nextStep = count
    end
    if nextStep == entry.step then
        return
    end
    entry.step = nextStep
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
    progress(guide.id).step = index
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
    end
    local ahead = 0
    if not (ns.db and ns.db.simpleMode) then
        ahead = 3
    end
    local items = {}
    local last = math.min(count, entry.step + ahead)
    for index = entry.step, last do
        items[#items + 1] = buildItem(guide.steps[index], index == entry.step)
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
        local suffix = guide.faction and (" (" .. guide.faction .. ")") or ""
        row.label:SetText(guide.name .. suffix)
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
    local guide = activeGuide()
    local before = guide and progress(guide.id).step
    if ns.GuideCatchUp() and guide and progress(guide.id).step ~= before and ns.RefreshTracker then
        ns.RefreshTracker(true)
    end
end)
