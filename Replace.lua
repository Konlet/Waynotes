local addonName, ns = ...

local lastSignature

local applyFont, paint, plainText, primaryStep, currentGuide
local maintainReview, earlierStep, goToStep, goBackward, skipListedStep
local guideTitle, isProgress, progressItemName, itemWindow, hereBeDragons
local playerOnQuest, collectObjectives

-- Guide helpers stay in this block so the tracker below can keep its own locals.
-- One chunk can hold 200 locals, and this file is past that on its own.
do
local function uiFont()
    if GameFontHighlight then
        local font = GameFontHighlight:GetFont()
        if font then
            return font
        end
    end
    return "Fonts\\FRIZQT__.TTF"
end

function applyFont(fs, size, flags)
    local font = uiFont()
    if not fs:SetFont(font, size, flags) then
        fs:SetFont(font, size)
    end
end

function paint(fs, size, r, g, b)
    applyFont(fs, size, "")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 1)
    fs:SetTextColor(r, g, b)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
end

local function objectiveText(text)
    if type(text) ~= "string" then
        return nil
    end
    text = text:gsub("|T.-|t", "")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|cRXP_[A-Z]+_(.-)|r", "%1")
    text = text:gsub("RXP_[A-Z]+_", "")
    text = text:gsub("|n", "\n")
    text = strtrim(text)
    if text == "" or text == " " then
        return nil
    end
    return text
end

function plainText(text)
    text = objectiveText(text)
    if not text then
        return nil
    end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|c", "")
    text = strtrim(text)
    if text == "" then
        return nil
    end
    return text
end

local function niceTitle(step)
    local title = plainText(step and step.title)
    if not title or title:match("^Step %d+$") then
        return nil
    end
    return title
end

function primaryStep()
    local steps = _G.RXPFrame and _G.RXPFrame.activeSteps
    if type(steps) ~= "table" then
        return nil
    end
    for _, step in ipairs(steps) do
        if step and not step.tip and not step.sticky and not step.hidewindow and type(step.index) == "number" then
            return step
        end
    end
end

local function stepSetter()
    local menu = _G.RXPFrame and _G.RXPFrame.bottomMenu
    local setStep = menu and menu[1] and menu[1].func
    if type(setStep) == "function" then
        return setStep
    end
end

function currentGuide()
    local pool = _G.RXPFrame and _G.RXPFrame.ScrollChild and _G.RXPFrame.ScrollChild.framePool
    if type(pool) ~= "table" then
        return nil
    end
    for _, frame in ipairs(pool) do
        if frame and frame.guide and type(frame.guide.steps) == "table" then
            return frame.guide
        end
    end
end

local reviewStep

local function restorePinnedText(step)
    if not step or type(step.elements) ~= "table" then
        return
    end
    for _, element in ipairs(step.elements) do
        if element.__rxpbWasTextOnly ~= nil then
            element.textOnly = element.__rxpbWasTextOnly == 1
            element.__rxpbWasTextOnly = nil
        end
    end
end

local function releaseReview()
    local step = reviewStep
    reviewStep = nil
    restorePinnedText(step)
end

local function pinStep(step)
    if not step then
        return
    end
    step.completed = false
    if step.tipWindow then
        step.tipWindow.completed = false
    end
    if _G.RXPCData and _G.RXPCData.stepSkip and step.index then
        _G.RXPCData.stepSkip[step.index] = nil
    end
    local elements = step.elements
    if type(elements) ~= "table" then
        return
    end
    local pinned = false
    for _, element in ipairs(elements) do
        if not element.textOnly then
            local button = element.frame and element.frame.button
            if button and button.SetChecked and button:GetChecked() then
                button:SetChecked(false)
            end
            element.completed = nil
            element.skip = nil
            pinned = true
        end
    end
    if not pinned then
        local element = elements[1]
        if element then
            if element.__rxpbWasTextOnly == nil then
                element.__rxpbWasTextOnly = element.textOnly and 1 or 0
            end
            element.textOnly = false
            element.completed = nil
            element.skip = nil
        end
    end
end

function maintainReview()
    local step = reviewStep
    if not step then
        return
    end
    local guide = currentGuide()
    local now = primaryStep()
    if guide and guide.steps and step.index and guide.steps[step.index] ~= step and now ~= step then
        releaseReview()
        return
    end
    if now and now ~= step and step.index and now.index and now.index > step.index then
        pinStep(step)
        local setStep = stepSetter()
        if setStep then
            pcall(setStep, step.index)
        end
        now = primaryStep()
        if not now or now.index ~= step.index then
            releaseReview()
            return
        end
        lastSignature = nil
        if ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end
    pinStep(step)
end

local function reopenStep(step)
    pinStep(step)
end

function earlierStep(guide, index)
    local steps = guide and guide.steps
    if type(steps) ~= "table" then
        if index > 1 then
            return index - 1
        end
        return nil
    end
    for n = index - 1, 1, -1 do
        local step = steps[n]
        if step and not step.sticky and not step.tip and not step.hidewindow then
            return n
        end
    end
end

local function holdReview(now, previousIndex)
    if not now or not now.index or not previousIndex or now.index >= previousIndex then
        return
    end
    if reviewStep and reviewStep ~= now then
        local previous = reviewStep
        reviewStep = nil
        restorePinnedText(previous)
    end
    reviewStep = now
    pinStep(now)
end

function goToStep(index)
    local setStep = stepSetter()
    if not setStep or type(index) ~= "number" or index < 1 then
        return
    end
    releaseReview()
    if not pcall(setStep, index) then
        return
    end
    lastSignature = nil
    ns.RefreshTracker(true)
end

function goBackward()
    local setStep = stepSetter()
    local step = primaryStep()
    if not setStep or not step then
        return
    end
    local guide = currentGuide()
    local steps = guide and guide.steps
    local current = step.index
    local n = current - 1
    local tries = 0
    while n >= 1 and tries < 12 do
        local candidate = steps and steps[n]
        if candidate and (candidate.sticky or candidate.tip or candidate.hidewindow) then
            n = n - 1
        else
            tries = tries + 1
            if candidate then
                reopenStep(candidate)
            end
            if not pcall(setStep, n) then
                return
            end
            local now = primaryStep()
            if now and now.index < current then
                holdReview(now, current)
                break
            end
            n = n - 1
        end
    end
    lastSignature = nil
    ns.RefreshTracker(true)
end

local function jumpToStep(index)
    index = tonumber(index)
    if not index then
        return
    end
    index = math.floor(index)
    if index < 1 then
        return
    end
    if ns.db and ns.db.standaloneGuide and ns.GuideJump then
        ns.GuideJump(index)
        return
    end
    local guide = currentGuide()
    local steps = guide and guide.steps
    if type(steps) == "table" and #steps > 0 then
        if index > #steps then
            index = #steps
        end
        local step = steps[index]
        if not step or step.sticky or step.tip or step.hidewindow then
            local found = earlierStep(guide, index + 1)
            if found then
                index = found
            end
        end
    end
    local current = primaryStep()
    local currentIndex = current and current.index or 0
    if index < currentIndex then
        local candidate = steps and steps[index]
        if candidate then
            reopenStep(candidate)
        end
        local setStep = stepSetter()
        if not setStep or not pcall(setStep, index) then
            return
        end
        holdReview(primaryStep(), currentIndex)
        lastSignature = nil
        ns.RefreshTracker(true)
        return
    end
    goToStep(index)
end

function skipListedStep(index, sticky)
    if type(index) ~= "number" then
        return
    end
    if ns.db and ns.db.standaloneGuide and ns.GuideSkip then
        ns.GuideSkip(index)
        return
    end
    local guide = currentGuide()
    local step = guide and guide.steps and guide.steps[index]
    if not step then
        return
    end
    if sticky or step.sticky then
        if not _G.RXPCData then
            return
        end
        _G.RXPCData.stepSkip = _G.RXPCData.stepSkip or {}
        _G.RXPCData.stepSkip[index] = true
        step.completed = true
        step.active = nil
        if reviewStep == step then
            releaseReview()
        end
        local current = primaryStep()
        local stay = current and current.index
        if not stay and type(_G.RXPCData.currentStep) == "number" then
            stay = _G.RXPCData.currentStep
        end
        if stay == index then
            stay = index + 1
        end
        local setStep = stepSetter()
        if setStep and stay then
            pcall(setStep, stay)
        end
        lastSignature = nil
        ns.RefreshTracker(true)
        return
    end
    goToStep(index + 1)
end

if not StaticPopupDialogs["RestedXPBetterJump"] then
    StaticPopupDialogs["RestedXPBetterJump"] = {
        text = "Jump to step number",
        button1 = "Jump",
        button2 = "Cancel",
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            local box = self.editBox
            if not box and self.GetName then
                box = _G[self:GetName() .. "EditBox"]
            end
            if not box then
                return
            end
            box:SetNumeric(true)
            box:SetMaxLetters(4)
            box:SetText("")
            box:SetFocus()
        end,
        OnAccept = function(self)
            local box = self.editBox
            if not box and self.GetName then
                box = _G[self:GetName() .. "EditBox"]
            end
            local number = box and tonumber(box:GetText())
            if number then
                jumpToStep(number)
            end
        end,
        EditBoxOnEnterPressed = function(editBox)
            local dialog = editBox:GetParent()
            if dialog and dialog.button1 and dialog.button1.Click then
                dialog.button1:Click()
                return
            end
            local number = tonumber(editBox:GetText())
            if number then
                jumpToStep(number)
            end
            if dialog and dialog.Hide then
                dialog:Hide()
            end
        end,
    }
end

function guideTitle()
    if ns.db and ns.db.standaloneGuide and ns.GuideTitle then
        return ns.GuideTitle()
    end
    local rxp = _G.RXPFrame
    local widget = rxp and rxp.GuideName and rxp.GuideName.text
    local shown = widget and widget.GetText and widget:GetText()
    local title = plainText(shown)
    if title then
        title = title:match("^[^\n]+") or title
        title = strtrim(title)
        if title ~= "" and not title:find("Welcome to RestedXP") then
            return title
        end
    end
    if RXPCData and type(RXPCData.currentGuideName) == "string" and RXPCData.currentGuideName ~= "" then
        return RXPCData.currentGuideName:gsub("\\n", " ")
    end
    return "RestedXP"
end

local function stepFrame(activeIndex)
    local rxp = _G.RXPFrame
    local current = rxp and rxp.CurrentStepFrame
    local pool = current and current.framePool
    return pool and pool[activeIndex]
end

function isProgress(text)
    local plain = plainText(text)
    if not plain then
        return false
    end
    if plain:match("^%d+%s*/%s*%d+") then
        return true
    end
    if plain:match("%d+%s*/%s*%d+%s*$") then
        return true
    end
    return false
end

function progressItemName(text)
    local plain = plainText(text)
    if not plain or not isProgress(plain) then
        return nil
    end
    local name = plain:match("^%d+%s*/%s*%d+%s+(.+)$")
    if not name then
        name = plain:match("^(.-)%s*:%s*%d+%s*/%s*%d+%s*$")
    end
    if not name then
        name = plain:match("^(.-)%s+%d+%s*/%s*%d+%s*$")
    end
    if not name then
        return nil
    end
    name = strtrim(name)
    if name == "" or name:match("^%d+%s*/%s*%d+$") then
        return nil
    end
    return name
end

local function rememberName(into, seen, name)
    name = plainText(name)
    if not name then
        return
    end
    local key = name:lower()
    if seen[key] then
        return
    end
    seen[key] = true
    into[#into + 1] = name
end

local function namesFromValue(value, into, seen)
    if type(value) == "string" then
        rememberName(into, seen, value)
    elseif type(value) == "table" then
        if type(value.name) == "string" then
            rememberName(into, seen, value.name)
        end
        for key, entry in pairs(value) do
            if key ~= "name" and entry ~= value then
                namesFromValue(entry, into, seen)
            end
        end
    end
end

local function questTitle(id)
    if type(id) ~= "number" then
        return nil
    end
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local ok, name = pcall(C_QuestLog.GetTitleForQuestID, id)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    if C_QuestLog and C_QuestLog.GetQuestInfo then
        local ok, name = pcall(C_QuestLog.GetQuestInfo, id)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    local cache = _G.RXPCData and _G.RXPCData.questNameCache
    if type(cache) == "table" and type(cache[id]) == "string" and cache[id] ~= "" then
        return cache[id]
    end
    local saved = _G.RXPData and _G.RXPData.questNames
    if type(saved) == "table" and type(saved[id]) == "string" and saved[id] ~= "" then
        return saved[id]
    end
end

local function rememberQuest(element, into, seen)
    if type(element) ~= "table" then
        return
    end
    local id = element.questId
    if type(id) ~= "number" and type(element.ids) == "table" then
        id = element.ids[1]
    end
    rememberName(into, seen, questTitle(id))
    if type(element.ids) == "table" then
        for _, questId in ipairs(element.ids) do
            rememberName(into, seen, questTitle(questId))
        end
    end
    if element.arrow or element.objIndex then
        return
    end
    if type(id) ~= "number" and type(element.ids) ~= "table" then
        return
    end
    local title = plainText(element.title)
    if title and not title:match("^Step %d+$") then
        rememberName(into, seen, title)
    end
end

local function collectTaggedNames(raw, into, seen)
    if type(raw) ~= "string" then
        return
    end
    for _, tag in ipairs({ "RXP_ENEMY_", "RXP_FRIENDLY_", "RXP_LOOT_", "RXP_PICK_", "RXP_BUY_" }) do
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
            rememberName(into, seen, raw:sub(finish + 1, close - 1))
            startAt = close + 2
        end
    end
end

local function itemName(id)
    if type(id) ~= "number" then
        return nil
    end

    if C_Item and C_Item.RequestLoadItemDataByID then
        pcall(C_Item.RequestLoadItemDataByID, id)
    end

    if C_Item and C_Item.GetItemInfo then
        local ok, name = pcall(C_Item.GetItemInfo, id)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
        if ok and type(name) == "table" then
            local fromTable = name.itemName or name.name
            if type(fromTable) == "string" and fromTable ~= "" then
                return fromTable
            end
        end
    end

    if GetItemInfo then
        local ok, name = pcall(GetItemInfo, id)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
end

local function buttonItemName(button)
    if not button or not button.IsShown or not button:IsShown() then
        return nil
    end
    if type(button.name) == "string" and button.name ~= "" then
        return button.name
    end
    if type(button.itemName) == "string" then
        return button.itemName
    end
    if type(button.itemLink) == "string" then
        return button.itemLink:match("%[(.-)%]")
    end
    local id = button.itemId or button.itemID or button.id
    local name = itemName(id)
    if name then
        return name
    end
    if button.GetAttribute then
        local ok, attr = pcall(button.GetAttribute, button, "item")
        if ok and type(attr) == "string" then
            return attr:match("%[(.-)%]") or attr
        end
    end
end

function itemWindow()
    return _G.RXPItemFrame or (_G.RXPFrame and _G.RXPFrame.activeItemFrame)
end

local function shownItemButtons()
    local frame = itemWindow()
    local buttons = {}
    if not frame or type(frame.buttonList) ~= "table" then
        return buttons
    end
    for _, button in ipairs(frame.buttonList) do
        if button and button.IsShown and button:IsShown() then
            buttons[#buttons + 1] = button
        end
    end
    return buttons
end

local function shownTargetButtons()
    local frame = _G.RXPTargetFrame
    local buttons = {}
    if not frame then
        return buttons
    end
    local function take(list)
        for _, button in ipairs(list or {}) do
            if button and button.IsShown and button:IsShown() and button.targetData and button.targetData.name then
                buttons[#buttons + 1] = button
            end
        end
    end
    take(frame.enemyTargetButtons)
    take(frame.friendlyTargetButtons)
    return buttons
end

local function stepItemNames(step)
    local names = {}
    local seen = {}
    for key, value in pairs(step.activeItems or {}) do
        if type(value) == "string" then
            rememberName(names, seen, value)
        elseif type(key) == "string" and not tonumber(key) then
            rememberName(names, seen, key)
        end
        local id = type(key) == "number" and key or type(value) == "number" and value
        if type(value) == "table" then
            id = value.id or value.itemID or id
            if type(value.name) == "string" then
                rememberName(names, seen, value.name)
            end
        end
        rememberName(names, seen, itemName(id))
    end
    return names
end

local function appendDetail(details, seen, text)
    local plain = plainText(text)
    if not plain or seen[plain:lower()] then
        return
    end
    seen[plain:lower()] = true
    details[#details + 1] = text
end

local function buildObjective(step, lines, extras)
    local seen = {}
    local details = {}
    local headline
    local title = niceTitle(step)
    if title then
        headline = title
        seen[title:lower()] = true
    end

    for _, text in ipairs(lines) do
        local plain = plainText(text)
        if plain and not headline and not isProgress(text) and not seen[plain:lower()] then
            headline = text
            seen[plain:lower()] = true
        end
    end

    for _, text in ipairs(lines) do
        local plain = plainText(text)
        if plain and not seen[plain:lower()] then
            if not headline then
                headline = text
                seen[plain:lower()] = true
            else
                appendDetail(details, seen, text)
            end
        end
    end

    for _, text in ipairs(extras) do
        appendDetail(details, seen, text)
    end

    if not headline then
        return nil
    end

    return {
        number = step.index or 0,
        headline = headline,
        details = details,
        actions = {},
    }
end

local function visibleLines(step, activeIndex)
    local frame = stepFrame(activeIndex)
    if frame and frame.GetAlpha and frame:GetAlpha() <= 0 then
        return nil
    end

    local lines = {}
    local wantsTargets = false
    local targetNames = {}
    local targetSeen = {}
    local questNames = {}
    local questSeen = {}

    for elementIndex, element in ipairs(step.elements or {}) do
        if element and not element.skip then
            rememberQuest(element, questNames, questSeen)
            if element.mobs or element.targets or element.unitscan then
                wantsTargets = true
                namesFromValue(element.mobs, targetNames, targetSeen)
                namesFromValue(element.targets, targetNames, targetSeen)
                namesFromValue(element.unitscan, targetNames, targetSeen)
            end
            collectTaggedNames(element.text, targetNames, targetSeen)

            local elementFrame = frame and frame.elements and frame.elements[elementIndex]
            local hidden = elementFrame and elementFrame.GetAlpha and elementFrame:GetAlpha() <= 0
            local finished = element.completed and not element.textOnly
            if not hidden and not finished then
                local raw
                if elementFrame and elementFrame.text and elementFrame.text.GetText then
                    raw = elementFrame.text:GetText()
                end
                if not raw or raw == "" or raw == " " then
                    raw = element.text
                end
                collectTaggedNames(raw, targetNames, targetSeen)
                local text = objectiveText(raw)
                if text then
                    lines[#lines + 1] = text
                end
            end
        end
    end

    return lines, wantsTargets, targetNames, questNames
end

function hereBeDragons()
    if not LibStub then
        return nil
    end
    local ok, lib = pcall(LibStub, "HereBeDragons-2.0")
    if ok then
        return lib
    end
end

local function elementWorld(element, hbd)
    if type(element.wx) == "number" and type(element.wy) == "number" then
        return element.wx, element.wy, element.instance
    end
    if hbd and type(element.x) == "number" and type(element.y) == "number" and element.zone then
        local wx, wy, instance = hbd:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.zone)
        if wx and wy then
            return wx, wy, instance or element.instance
        end
    end
end

local function arrowElementUsable(element)
    if not element or not element.arrow or element.skip or element.hidden then
        return false
    end
    local parent = element.parent
    if type(parent) == "table" and (parent.completed or parent.skip) and not parent.textOnly then
        return false
    end
    return true
end

local function stepWaypoint(step)
    if not step then
        return nil
    end
    local arrow = _G.RXPG_ARROW
    local current = arrow and arrow.element
    if current and current.step == step and arrowElementUsable(current) then
        local hbd = hereBeDragons()
        local wx, wy, instance = elementWorld(current, hbd)
        if wx and wy then
            return { wx = wx, wy = wy, instance = instance }
        end
    end

    local hbd = hereBeDragons()
    local px, py, instance
    if hbd then
        px, py, instance = hbd:GetPlayerWorldPosition()
    end
    local best, bestDist, bestLow
    for _, element in ipairs(step.elements or {}) do
        if arrowElementUsable(element) then
            local wx, wy, inst = elementWorld(element, hbd)
            if wx and wy then
                local low = element.lowPrio and true or false
                local dist
                if hbd and px and (not inst or inst == instance or instance == -1) then
                    local _, yards = hbd:GetWorldVector(instance, px, py, wx, wy)
                    dist = yards
                end
                local replace = not best
                if best then
                    if bestLow and not low then
                        replace = true
                    elseif bestLow == low and dist and (not bestDist or dist < bestDist) then
                        replace = true
                    end
                end
                if replace then
                    best = { wx = wx, wy = wy, instance = inst }
                    bestDist = dist
                    bestLow = low
                end
            end
        end
    end
    return best
end

function playerOnQuest(id)
    if type(id) ~= "number" then
        return false
    end
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

local function zoneLabel(zone)
    if type(zone) == "string" and zone ~= "" then
        return zone
    end
    if type(zone) == "number" and C_Map and C_Map.GetMapInfo then
        local ok, info = pcall(C_Map.GetMapInfo, zone)
        if ok and type(info) == "table" and type(info.name) == "string" and info.name ~= "" then
            return info.name
        end
    end
end

local function stepPlace(step)
    local fallback
    for _, element in ipairs(step and step.elements or {}) do
        if element and type(element.x) == "number" and type(element.y) == "number" and not element.skip then
            local place = {
                x = element.x,
                y = element.y,
                zone = zoneLabel(element.zone),
            }
            if element.arrow then
                return place
            end
            if not fallback then
                fallback = place
            end
        end
    end
    return fallback
end

local function stepQuests(step)
    local list = {}
    local seen = {}
    local function add(id)
        if type(id) ~= "number" or id <= 0 or seen[id] then
            return
        end
        seen[id] = true
        list[#list + 1] = {
            id = id,
            name = questTitle(id),
            on = playerOnQuest(id),
        }
    end
    for _, element in ipairs(step and step.elements or {}) do
        if element then
            add(element.questId)
            if type(element.ids) == "table" then
                for _, id in ipairs(element.ids) do
                    add(id)
                end
            end
        end
    end
    table.sort(list, function(a, b)
        if a.on ~= b.on then
            return a.on and not b.on
        end
        return a.id < b.id
    end)
    return list
end

function collectObjectives()
    if ns.db and ns.db.standaloneGuide and ns.GuideObjectives then
        local ok, items = pcall(ns.GuideObjectives)
        if ok and type(items) == "table" then
            return items
        end
        return {
            {
                number = 0,
                headline = "The guide could not be read.",
                details = {},
                actions = {},
                names = {},
                quests = {},
                stepQuests = {},
            },
        }
    end
    local rxp = _G.RXPFrame
    local steps = rxp and rxp.activeSteps
    local list = {}
    if type(steps) ~= "table" then
        return list
    end

    local order = {}
    local primaryIndex
    for index, step in ipairs(steps) do
        if step and not step.tip and not step.sticky and not primaryIndex then
            primaryIndex = index
        end
    end
    if not primaryIndex and ns.db and ns.db.simpleMode then
        for index, step in ipairs(steps) do
            if step and not step.tip then
                primaryIndex = index
                break
            end
        end
    end
    if primaryIndex then
        order[#order + 1] = primaryIndex
    end
    if not (ns.db and ns.db.simpleMode) then
        for index, step in ipairs(steps) do
            if index ~= primaryIndex and step and not step.tip then
                order[#order + 1] = index
            end
        end
    end

    local targetButtons = shownTargetButtons()
    local itemButtons = shownItemButtons()
    local usedButtons = {}
    local targetClaim = nil
    local itemClaim = nil

    local function claimButton(objective, button)
        if not objective or not button or usedButtons[button] then
            return false
        end
        usedButtons[button] = true
        objective.actions[#objective.actions + 1] = button
        return true
    end

    local function targetButtonFor(name)
        local key = type(name) == "string" and name:lower() or nil
        if not key then
            return nil
        end
        for _, button in ipairs(targetButtons) do
            if not usedButtons[button] then
                local buttonName = button.targetData and button.targetData.name
                if type(buttonName) == "string" and buttonName:lower() == key then
                    return button
                end
            end
        end
    end

    local function itemButtonFor(name, id)
        for _, button in ipairs(itemButtons) do
            if not usedButtons[button] then
                if id and button.itemId == id then
                    return button
                end
                local buttonName = buttonItemName(button)
                if name and buttonName and buttonName:lower() == name:lower() then
                    return button
                end
            end
        end
    end

    local function hostFor(step)
        if step then
            for _, objective in ipairs(list) do
                if objective._step == step then
                    return objective
                end
            end
        end
        return list[1]
    end

    for _, activeIndex in ipairs(order) do
        local step = steps[activeIndex]
        local lines, wantsTargets, targetNames, questNames = visibleLines(step, activeIndex)
        if lines then
            if wantsTargets and not targetClaim then
                targetClaim = step
            end
            if step.activeItems and not itemClaim then
                itemClaim = step
            end

            local objective = buildObjective(step, lines, {})
            if objective then
                objective._step = step
                objective.names = targetNames
                objective.quests = questNames
                local seen = {}
                seen[(plainText(objective.headline) or ""):lower()] = true

                local claimedTarget = false
                for _, name in ipairs(targetNames) do
                    if claimButton(objective, targetButtonFor(name)) then
                        claimedTarget = true
                    end
                end
                if not claimedTarget then
                    for _, name in ipairs(targetNames) do
                        appendDetail(objective.details, seen, "Target: " .. name)
                    end
                end

                local claimedItems = {}
                for key, value in pairs(step.activeItems or {}) do
                    local id = type(key) == "number" and key or type(value) == "number" and value
                    if type(value) == "table" then
                        id = value.id or value.itemID or id
                    end
                    local button = itemButtonFor(nil, id)
                    if claimButton(objective, button) then
                        local buttonName = buttonItemName(button)
                        if buttonName then
                            claimedItems[buttonName:lower()] = true
                        end
                    end
                end
                for _, name in ipairs(stepItemNames(step)) do
                    if not claimedItems[name:lower()] and not claimButton(objective, itemButtonFor(name)) then
                        appendDetail(objective.details, seen, "Use: " .. name)
                    end
                end

                objective.waypoint = stepWaypoint(step)
                objective.stepIndex = step.index
                objective.sticky = step.sticky and true or false
                objective.place = stepPlace(step)
                objective.stepQuests = stepQuests(step)
                local quest = objective.stepQuests[1]
                objective.questId = quest and quest.id
                objective.questName = quest and quest.name
                list[#list + 1] = objective
            end
        end
    end

    local targetHost = hostFor(targetClaim)
    for _, button in ipairs(targetButtons) do
        claimButton(targetHost, button)
    end
    local itemHost = hostFor(itemClaim)
    for _, button in ipairs(itemButtons) do
        claimButton(itemHost, button)
    end

    for _, objective in ipairs(list) do
        objective._step = nil
    end
    return list
end
end -- guide helpers

local COLUMN = 26
local TRACKER_WIDTH = 300
local mouseBusy = false
local alphaBusy = false
local buttonBusy = false
local parked = {}
local hookedMouse = {}
local rows = {}
local sizeKey = ""
local remeasure = false
local pointRestored = false

local tracker = CreateFrame("Frame", "RestedXPBetterTracker", UIParent, "BackdropTemplate")
tracker:SetSize(TRACKER_WIDTH, 72)
tracker:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 24, -180)
tracker:SetFrameStrata("MEDIUM")
tracker:SetClampedToScreen(true)
tracker:SetMovable(true)
tracker:EnableMouse(true)
tracker:RegisterForDrag("LeftButton")
tracker:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
tracker:SetBackdropColor(0, 0, 0, 0.4)
tracker:SetBackdropBorderColor(1, 0.82, 0, 0.45)
tracker:Hide()

local header = tracker:CreateFontString(nil, "OVERLAY")
header:SetPoint("TOPLEFT", 10, -7)
header:SetPoint("TOPRIGHT", -110, -7)
header:SetHeight(16)
paint(header, 13, ns.Color("accent"))
if header.SetMaxLines then
    header:SetMaxLines(1)
end
if header.SetWordWrap then
    header:SetWordWrap(false)
end

local guidePercent
local jumpButton
local function guidePercentLabel()
    if ns.db and ns.db.standaloneGuide and ns.GuidePercentLabel then
        return ns.GuidePercentLabel()
    end
    if not (ns.db and ns.db.showGuidePercent) then
        return nil
    end
    local guide = currentGuide()
    local steps = guide and guide.steps
    local total = type(steps) == "table" and #steps or 0
    if total < 1 then
        return nil
    end
    local current = tonumber(_G.RXPCData and _G.RXPCData.currentStep)
    if not current then
        local step = primaryStep()
        current = step and step.index
    end
    if type(current) ~= "number" or current < 1 then
        current = 1
    elseif current > total then
        current = total
    end
    return string.format("%d%%", math.floor(current / total * 100 + 0.5))
end

local function placeGuidePercent()
    if not guidePercent then
        return
    end
    local label = guidePercentLabel()
    if not label then
        guidePercent:Hide()
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", 10, -7)
        header:SetPoint("TOPRIGHT", -110, -7)
        return
    end
    local r, g, b = ns.Color("accent")
    paint(guidePercent, 12, r, g, b)
    guidePercent:SetText(label)
    guidePercent:Show()
    guidePercent:ClearAllPoints()
    if jumpButton then
        guidePercent:SetPoint("TOPRIGHT", jumpButton, "TOPLEFT", -6, 1)
    else
        guidePercent:SetPoint("TOPRIGHT", -110, -7)
    end
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", 10, -7)
    header:SetPoint("TOPRIGHT", guidePercent, "TOPLEFT", -6, 0)
end

local WHITE = "Interface\\BUTTONS\\WHITE8X8"
local HEADER_BOTTOM = 27
local RING_PAD = 2
local CORNER_PAD = 2
local CIRCLE_PAD = 4
local CIRCLE_SIZE = 128

local function texSpan(a, b, inset)
    if a < b then
        return a + inset, b - inset
    end
    return a - inset, b + inset
end

local function useSolid(texture)
    texture.__rxpbSolid = true
    if texture.SetColorTexture then
        texture:SetColorTexture(1, 1, 1, 1)
        return
    end
    texture:SetTexture(WHITE)
    texture:SetTexCoord(0.375, 0.625, 0.375, 0.625)
end

local function paintTexture(texture, r, g, b, a)
    a = a or 1
    if texture.__rxpbSolid and texture.SetColorTexture then
        texture:SetColorTexture(r, g, b, a)
        return
    end
    texture:SetVertexColor(r, g, b, a)
end

local function media(file)
    return "Interface\\AddOns\\" .. addonName .. "\\Media\\" .. file
end

local function clampCornerRadius(radius)
    radius = math.floor((radius or 0) + 0.5)
    if radius < 4 then
        return 4
    elseif radius > 16 then
        return 16
    end
    return radius
end

local function setQuarterCorner(texture, radius, left, right, top, bottom)
    radius = clampCornerRadius(radius)
    local inset = CORNER_PAD / (radius + CORNER_PAD * 2)
    texture:SetTexture(media("corner-" .. radius .. ".tga"))
    texture.__rxpbSolid = nil
    local u0, u1 = texSpan(left, right, inset)
    local v0, v1 = texSpan(top, bottom, inset)
    texture:SetTexCoord(u0, u1, v0, v1)
end

local function setCircleTexture(texture)
    local inset = CIRCLE_PAD / (CIRCLE_SIZE + CIRCLE_PAD * 2)
    texture:SetTexture(media("circle.tga"))
    texture:SetTexCoord(inset, 1 - inset, inset, 1 - inset)
end

local function setLayer(texture, layer, sub)
    if not texture.SetDrawLayer then
        return
    end
    if sub ~= nil and pcall(texture.SetDrawLayer, texture, layer, sub) then
        return
    end
    texture:SetDrawLayer(layer)
end

local function makeTexture(parent, layer, sub, file)
    local texture = parent:CreateTexture(nil, layer)
    setLayer(texture, layer, sub)
    if not file or file == WHITE then
        useSolid(texture)
    else
        texture:SetTexture(file)
    end
    texture:Hide()
    return texture
end

local function makePlate(parent, layer, sub)
    local plate = { list = {} }
    local function add(name, file)
        local texture = makeTexture(parent, layer, sub, file)
        plate[name] = texture
        plate.list[#plate.list + 1] = texture
    end
    local function addCorner(name)
        local texture = parent:CreateTexture(nil, layer)
        setLayer(texture, layer, sub)
        texture:Hide()
        plate[name] = texture
        plate.list[#plate.list + 1] = texture
    end
    addCorner("tl")
    addCorner("tr")
    addCorner("bl")
    addCorner("br")
    add("t")
    add("b")
    add("l")
    add("r")
    add("c")
    return plate
end

local function hidePlate(plate)
    if not plate then
        return
    end
    for index = 1, #plate.list do
        plate.list[index]:Hide()
    end
end

local function paintPlate(plate, r, g, b, a)
    if not plate then
        return
    end
    for index = 1, #plate.list do
        paintTexture(plate.list[index], r, g, b, a)
    end
end

local function showPlate(plate, anchor, insetL, insetR, insetT, insetB, radius)
    radius = math.floor((radius or 0) + 0.5)
    if radius < 0 then
        radius = 0
    end
    local width = (anchor:GetWidth() or 0) - insetL - insetR
    local height = (anchor:GetHeight() or 0) - insetT - insetB
    if width >= 2 and height >= 2 then
        local maxRadius = math.floor(math.min(width, height) / 2)
        if radius > maxRadius then
            radius = maxRadius
        end
    end

    if radius < 1 then
        hidePlate(plate)
        plate.c:ClearAllPoints()
        plate.c:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL, -insetT)
        plate.c:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -insetR, insetB)
        plate.c:Show()
        return
    end

    local function placeCorner(texture, point, x, y, left, right, top, bottom)
        setQuarterCorner(texture, radius, left, right, top, bottom)
        texture:ClearAllPoints()
        texture:SetPoint(point, anchor, point, x, y)
        texture:SetSize(radius, radius)
        texture:Show()
    end
    placeCorner(plate.tl, "TOPLEFT", insetL, -insetT, 0, 1, 0, 1)
    placeCorner(plate.tr, "TOPRIGHT", -insetR, -insetT, 1, 0, 0, 1)
    placeCorner(plate.bl, "BOTTOMLEFT", insetL, insetB, 0, 1, 1, 0)
    placeCorner(plate.br, "BOTTOMRIGHT", -insetR, insetB, 1, 0, 1, 0)

    local gapW = width - (radius * 2)
    local gapH = height - (radius * 2)
    if gapW >= 1 then
        plate.t:ClearAllPoints()
        plate.t:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL + radius, -insetT)
        plate.t:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -(insetR + radius), -insetT)
        plate.t:SetHeight(radius)
        plate.t:Show()
        plate.b:ClearAllPoints()
        plate.b:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", insetL + radius, insetB)
        plate.b:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -(insetR + radius), insetB)
        plate.b:SetHeight(radius)
        plate.b:Show()
    else
        plate.t:Hide()
        plate.b:Hide()
    end
    if gapH >= 1 then
        plate.l:ClearAllPoints()
        plate.l:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL, -(insetT + radius))
        plate.l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", insetL, insetB + radius)
        plate.l:SetWidth(radius)
        plate.l:Show()
        plate.r:ClearAllPoints()
        plate.r:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -insetR, -(insetT + radius))
        plate.r:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -insetR, insetB + radius)
        plate.r:SetWidth(radius)
        plate.r:Show()
    else
        plate.l:Hide()
        plate.r:Hide()
    end
    if gapW >= 1 and gapH >= 1 then
        plate.c:ClearAllPoints()
        plate.c:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL + radius, -(insetT + radius))
        plate.c:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -(insetR + radius), insetB + radius)
        plate.c:Show()
    else
        plate.c:Hide()
    end
end

local function showHeader(plate, anchor, insetL, insetR, top, bottom, radius)
    plate.bl:Hide()
    plate.br:Hide()
    plate.b:Hide()
    plate.l:Hide()
    plate.r:Hide()
    local width = (anchor:GetWidth() or 0) - insetL - insetR
    local span = bottom - top
    if span < 1 or width < 1 then
        hidePlate(plate)
        return
    end
    radius = math.floor((radius or 0) + 0.5)
    if radius < 0 then
        radius = 0
    end
    if radius > span - 1 then
        radius = span - 1
    end
    if radius > math.floor(width / 2) then
        radius = math.floor(width / 2)
    end
    if radius < 1 then
        plate.tl:Hide()
        plate.tr:Hide()
        plate.t:Hide()
        plate.c:ClearAllPoints()
        plate.c:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL, -top)
        plate.c:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -insetR, -top)
        plate.c:SetHeight(span)
        plate.c:Show()
        return
    end

    setQuarterCorner(plate.tl, radius, 0, 1, 0, 1)
    plate.tl:ClearAllPoints()
    plate.tl:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL, -top)
    plate.tl:SetSize(radius, radius)
    plate.tl:Show()
    setQuarterCorner(plate.tr, radius, 1, 0, 0, 1)
    plate.tr:ClearAllPoints()
    plate.tr:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -insetR, -top)
    plate.tr:SetSize(radius, radius)
    plate.tr:Show()

    if width - (radius * 2) >= 1 then
        plate.t:ClearAllPoints()
        plate.t:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL + radius, -top)
        plate.t:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -(insetR + radius), -top)
        plate.t:SetHeight(radius)
        plate.t:Show()
    else
        plate.t:Hide()
    end

    local body = span - radius
    if body >= 1 then
        plate.c:ClearAllPoints()
        plate.c:SetPoint("TOPLEFT", anchor, "TOPLEFT", insetL, -(top + radius))
        plate.c:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -insetR, -(top + radius))
        plate.c:SetHeight(body)
        plate.c:Show()
    else
        plate.c:Hide()
    end
end

local function showBorder(plate, anchor, radius)
    radius = math.floor((radius or 0) + 0.5)
    local width = anchor:GetWidth() or 0
    local height = anchor:GetHeight() or 0
    if width >= 2 and height >= 2 then
        local maxRadius = math.floor(math.min(width, height) / 2)
        if radius > maxRadius then
            radius = maxRadius
        end
    end
    if radius < 4 or radius > 16 then
        hidePlate(plate)
        return
    end

    local path = media("ring-" .. radius .. ".tga")
    local ringInset = RING_PAD / (radius + RING_PAD * 2)
    local function corner(texture, point, left, right, top, bottom)
        texture:SetTexture(path)
        local u0, u1 = texSpan(left, right, ringInset)
        local v0, v1 = texSpan(top, bottom, ringInset)
        texture:SetTexCoord(u0, u1, v0, v1)
        texture:ClearAllPoints()
        texture:SetPoint(point, anchor, point, 0, 0)
        texture:SetSize(radius, radius)
        texture:Show()
    end
    corner(plate.tl, "TOPLEFT", 0, 1, 0, 1)
    corner(plate.tr, "TOPRIGHT", 1, 0, 0, 1)
    corner(plate.bl, "BOTTOMLEFT", 0, 1, 1, 0)
    corner(plate.br, "BOTTOMRIGHT", 1, 0, 1, 0)
    plate.c:Hide()

    local gapW = width - (radius * 2)
    local gapH = height - (radius * 2)
    if gapW >= 1 then
        plate.t:ClearAllPoints()
        plate.t:SetPoint("TOPLEFT", anchor, "TOPLEFT", radius - 1, 0)
        plate.t:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -(radius - 1), 0)
        plate.t:SetHeight(1)
        plate.t:Show()
        plate.b:ClearAllPoints()
        plate.b:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", radius - 1, 0)
        plate.b:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -(radius - 1), 0)
        plate.b:SetHeight(1)
        plate.b:Show()
    else
        plate.t:Hide()
        plate.b:Hide()
    end
    if gapH >= 1 then
        plate.l:ClearAllPoints()
        plate.l:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -(radius - 1))
        plate.l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, radius - 1)
        plate.l:SetWidth(1)
        plate.l:Show()
        plate.r:ClearAllPoints()
        plate.r:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 0, -(radius - 1))
        plate.r:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, radius - 1)
        plate.r:SetWidth(1)
        plate.r:Show()
    else
        plate.l:Hide()
        plate.r:Hide()
    end
end

local function styleBadge(badge, r, g, b)
    if ns.db and ns.db.roundBadges then
        if not badge.circle then
            badge.ring = badge:CreateTexture(nil, "BORDER")
            setCircleTexture(badge.ring)
            badge.ring:SetPoint("TOPLEFT", -1, 1)
            badge.ring:SetPoint("BOTTOMRIGHT", 1, -1)
            badge.circle = badge:CreateTexture(nil, "ARTWORK")
            setCircleTexture(badge.circle)
            badge.circle:SetPoint("TOPLEFT", 1, -1)
            badge.circle:SetPoint("BOTTOMRIGHT", -1, 1)
        end
        badge:SetBackdropColor(0, 0, 0, 0)
        badge:SetBackdropBorderColor(0, 0, 0, 0)
        badge.ring:SetVertexColor(0, 0, 0, 0.7)
        badge.ring:Show()
        badge.circle:SetVertexColor(r, g, b, 1)
        badge.circle:Show()
    else
        if badge.circle then
            badge.circle:Hide()
            badge.ring:Hide()
        end
        badge:SetBackdropColor(r, g, b, 1)
        badge:SetBackdropBorderColor(0, 0, 0, 0.45)
    end
end

local function styleChromeButton(button, fillR, fillG, fillB, fillA, edgeR, edgeG, edgeB, edgeA)
    local rounded = ns.db and ns.db.roundedEdges
    if button.glow then
        paintTexture(button.glow, 1, 1, 1, rounded and 0 or 0.14)
    end
    if not rounded then
        hidePlate(button.fillPlate)
        hidePlate(button.edgePlate)
        button:SetBackdropColor(fillR, fillG, fillB, fillA)
        button:SetBackdropBorderColor(edgeR, edgeG, edgeB, edgeA)
        return
    end
    if not button.fillPlate then
        button.fillPlate = makePlate(button, "BACKGROUND", 1)
        button.edgePlate = makePlate(button, "BORDER", 1)
    end
    local radius = math.floor((button:GetHeight() or 16) / 2)
    if radius < 4 then
        radius = 4
    elseif radius > 16 then
        radius = 16
    end
    showPlate(button.fillPlate, button, 0, 0, 0, 0, radius)
    paintPlate(button.fillPlate, fillR, fillG, fillB, fillA)
    showBorder(button.edgePlate, button, radius)
    paintPlate(button.edgePlate, edgeR, edgeG, edgeB, edgeA)
    button:SetBackdropColor(0, 0, 0, 0)
    button:SetBackdropBorderColor(0, 0, 0, 0)
end

local shadowHost = CreateFrame("Frame", nil, UIParent)
shadowHost:SetFrameStrata("LOW")
shadowHost:EnableMouse(false)
shadowHost:Hide()

local headerBar = makeTexture(tracker, "BACKGROUND", 2, WHITE)
local panelFill = makePlate(tracker, "BACKGROUND", 1)
local panelHeader = makePlate(tracker, "BACKGROUND", 3)
local panelBorder = makePlate(tracker, "BORDER", 1)
local panelShadow = makePlate(shadowHost, "ARTWORK", 1)

local stepButtons = {}
local styleStepButtons
local stylingButtons = false

local function createStepButton(direction, anchorX)
    local button = CreateFrame("Button", nil, tracker, "BackdropTemplate")
    button:SetSize(16, 16)
    button:SetPoint("TOPRIGHT", anchorX, -6)
    button:SetFrameLevel(tracker:GetFrameLevel() + 25)
    button:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button:RegisterForClicks("LeftButtonUp")
    button.direction = direction

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    useSolid(highlight)
    paintTexture(highlight, 1, 1, 1, 0.14)
    button.glow = highlight

    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetSize(11, 11)
    button.icon:SetPoint("CENTER", 0, 0)
    button.icon:SetTexture(media("arrow.tga"))
    button.icon:SetRotation(direction < 0 and (math.pi / 2) or (-math.pi / 2))

    button:SetScript("OnClick", function(self)
        if ns.db and ns.db.standaloneGuide and ns.GuideStep then
            ns.GuideStep(self.direction)
            styleStepButtons()
            return
        end
        local step = primaryStep()
        if not step then
            return
        end
        if self.direction < 0 then
            goBackward()
        else
            goToStep(step.index + 1)
        end
        styleStepButtons()
    end)
    button:SetScript("OnEnter", function(self)
        self.hovered = true
        styleStepButtons()
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.direction < 0 then
            GameTooltip:SetText("Previous step", r, g, b)
        else
            GameTooltip:SetText("Next step", r, g, b)
        end
        ns.FinishTooltip()
    end)
    button:SetScript("OnLeave", function(self)
        self.hovered = false
        styleStepButtons()
        GameTooltip:Hide()
    end)
    button:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() then
            self.icon:SetPoint("CENTER", 1, -1)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.icon:SetPoint("CENTER", 0, 0)
    end)

    stepButtons[#stepButtons + 1] = button
    return button
end

local function stepButtonEnabled(button)
    if ns.db and ns.db.standaloneGuide then
        return ns.GuideCanStep and ns.GuideCanStep(button.direction) or false
    end
    local step = primaryStep()
    if not step then
        return false
    end
    if button.direction < 0 then
        return earlierStep(currentGuide(), step.index) ~= nil
    end
    return true
end

styleStepButtons = function()
    if stylingButtons then
        return
    end
    stylingButtons = true
    local r, g, b = ns.Color("accent")
    for _, button in ipairs(stepButtons) do
        local enabled = stepButtonEnabled(button)
        if button.icon.SetDesaturated then
            button.icon:SetDesaturated(true)
        end
        button.icon:SetVertexColor(r, g, b, enabled and 1 or 0.35)
        if enabled then
            if not button:IsEnabled() then
                button:Enable()
            end
        elseif button:IsEnabled() then
            button:Disable()
        end
        if button.hovered and enabled then
            styleChromeButton(button, r, g, b, 0.22, r, g, b, 1)
        else
            styleChromeButton(button, 0, 0, 0, enabled and 0.55 or 0.3, r, g, b, enabled and 0.75 or 0.28)
        end
    end
    if jumpButton then
        jumpButton.text:SetTextColor(r, g, b)
        if jumpButton.hovered then
            styleChromeButton(jumpButton, r, g, b, 0.22, r, g, b, 1)
        else
            styleChromeButton(jumpButton, 0, 0, 0, 0.55, r, g, b, 0.75)
        end
    end
    stylingButtons = false
end

createStepButton(-1, -42)
createStepButton(1, -24)

jumpButton = CreateFrame("Button", nil, tracker, "BackdropTemplate")
jumpButton:SetSize(40, 16)
jumpButton:SetPoint("TOPRIGHT", -64, -6)
jumpButton:SetFrameLevel(tracker:GetFrameLevel() + 25)
jumpButton:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local jumpGlow = jumpButton:CreateTexture(nil, "HIGHLIGHT")
jumpGlow:SetAllPoints()
useSolid(jumpGlow)
paintTexture(jumpGlow, 1, 1, 1, 0.14)
jumpButton.glow = jumpGlow
jumpButton:RegisterForClicks("LeftButtonUp")
jumpButton.text = jumpButton:CreateFontString(nil, "OVERLAY")
jumpButton.text:SetPoint("CENTER", 0, 0)
applyFont(jumpButton.text, 10, "OUTLINE")
jumpButton.text:SetText("Jump")
jumpButton:SetScript("OnClick", function()
    if StaticPopup_Show then
        StaticPopup_Show("RestedXPBetterJump")
    end
end)
jumpButton:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Jump to step", r, g, b)
    GameTooltip:AddLine("Enter a step number.", 1, 1, 1, true)
    ns.FinishTooltip()
end)
jumpButton:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
jumpButton:SetScript("OnMouseDown", function(self)
    self.text:SetPoint("CENTER", 1, -1)
end)
jumpButton:SetScript("OnMouseUp", function(self)
    self.text:SetPoint("CENTER", 0, 0)
end)

guidePercent = tracker:CreateFontString(nil, "OVERLAY")
guidePercent:SetHeight(16)
guidePercent:SetJustifyH("RIGHT")
guidePercent:SetJustifyV("MIDDLE")
if guidePercent.SetWordWrap then
    guidePercent:SetWordWrap(false)
end
applyFont(guidePercent, 12, "OUTLINE")
guidePercent:Hide()

local rule = tracker:CreateTexture(nil, "ARTWORK")
rule:SetPoint("TOPLEFT", 0, -26)
rule:SetPoint("TOPRIGHT", 0, -26)
rule:SetHeight(1)
useSolid(rule)
paintTexture(rule, 1, 0.82, 0, 0.5)

local scroller = CreateFrame("ScrollFrame", nil, tracker)
scroller:SetPoint("TOPLEFT", 8, -34)
scroller:SetPoint("BOTTOMRIGHT", -8, 10)
scroller:EnableMouse(false)
scroller:EnableMouseWheel(true)

local body = CreateFrame("Frame", nil, scroller)
body:SetSize(TRACKER_WIDTH - 16, 20)
scroller:SetScrollChild(body)

local scrollBar = CreateFrame("Frame", nil, tracker)
scrollBar:SetWidth(3)
scrollBar:SetPoint("TOPRIGHT", -4, -36)
scrollBar:SetPoint("BOTTOMRIGHT", -4, 12)
scrollBar:SetFrameLevel(tracker:GetFrameLevel() + 8)
scrollBar:EnableMouse(false)
scrollBar:Hide()
local scrollThumb = scrollBar:CreateTexture(nil, "OVERLAY")
useSolid(scrollThumb)
scrollThumb:SetWidth(3)
paintTexture(scrollThumb, 1, 0.82, 0, 0.55)

local empty = body:CreateFontString(nil, "OVERLAY")
empty:SetPoint("TOPLEFT", 4, 0)
empty:SetPoint("RIGHT", -4, 0)
paint(empty, 13, 0.85, 0.85, 0.85)
empty:SetText("Right-click to choose a guide")
empty:Hide()

local divider = body:CreateTexture(nil, "ARTWORK")
divider:SetHeight(1)
useSolid(divider)
paintTexture(divider, 1, 1, 1, 0.16)
divider:Hide()

local FLIGHT_STRIP = 26
local flight = { chrome = 0 }
local updateFlightStrip

do
    local strip = CreateFrame("Frame", nil, tracker)
    strip:SetHeight(FLIGHT_STRIP)
    strip:SetPoint("BOTTOMLEFT", 1, 1)
    strip:SetPoint("BOTTOMRIGHT", -1, 1)
    strip:Hide()

    local flightRule = strip:CreateTexture(nil, "ARTWORK")
    flightRule:SetPoint("TOPLEFT", 8, 0)
    flightRule:SetPoint("TOPRIGHT", -8, 0)
    flightRule:SetHeight(1)
    useSolid(flightRule)
    paintTexture(flightRule, 1, 0.82, 0, 0.45)

    local track = CreateFrame("Frame", nil, strip)
    track:SetPoint("BOTTOMLEFT", 10, 6)
    track:SetPoint("BOTTOMRIGHT", -10, 6)
    track:SetHeight(3)
    local trackBg = track:CreateTexture(nil, "BACKGROUND")
    useSolid(trackBg)
    trackBg:SetAllPoints()
    paintTexture(trackBg, 1, 1, 1, 0.12)
    local trackFill = track:CreateTexture(nil, "ARTWORK")
    useSolid(trackFill)
    trackFill:SetPoint("TOPLEFT")
    trackFill:SetPoint("BOTTOMLEFT")
    trackFill:SetWidth(1)
    paintTexture(trackFill, 1, 0.82, 0, 0.9)

    local destText = strip:CreateFontString(nil, "OVERLAY")
    destText:SetPoint("TOPLEFT", 10, -4)
    destText:SetPoint("RIGHT", strip, "RIGHT", -58, 0)
    destText:SetHeight(12)
    destText:SetJustifyH("LEFT")
    destText:SetJustifyV("MIDDLE")
    if destText.SetWordWrap then
        destText:SetWordWrap(false)
    end
    applyFont(destText, 11, "")
    destText:SetTextColor(0.9, 0.9, 0.86)

    local timeText = strip:CreateFontString(nil, "OVERLAY")
    timeText:SetPoint("TOPRIGHT", -10, -4)
    timeText:SetHeight(12)
    timeText:SetJustifyH("RIGHT")
    timeText:SetJustifyV("MIDDLE")
    applyFont(timeText, 11, "OUTLINE")
    timeText:SetTextColor(1, 0.82, 0)

    flight.strip = strip
    flight.rule = flightRule
    flight.track = track
    flight.trackBg = trackBg
    flight.fill = trackFill
    flight.dest = destText
    flight.time = timeText

    local state = {
        pending = false,
        flying = false,
        route = nil,
        destName = nil,
        started = nil,
        duration = nil,
    }

    local function placeScroller(bottom)
        scroller:ClearAllPoints()
        scroller:SetPoint("TOPLEFT", 8, -34)
        scroller:SetPoint("BOTTOMRIGHT", -8, bottom)
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPRIGHT", -4, -36)
        scrollBar:SetPoint("BOTTOMRIGHT", -4, bottom + 2)
    end

    local function shortTaxiName(name)
        if type(name) ~= "string" or name == "" then
            return nil
        end
        return name:match("^[^,]+") or name
    end

    local function taxiNodeKey(index)
        local x, y = TaxiNodePosition(index)
        if type(x) ~= "number" or type(y) ~= "number" then
            return nil
        end
        return string.format("%0.2f:%0.2f", x, y)
    end

    local function currentTaxiNode()
        local count = NumTaxiNodes and NumTaxiNodes() or 0
        for index = 1, count do
            if TaxiNodeGetType(index) == "CURRENT" then
                return index
            end
        end
    end

    local function continentKey()
        if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo) then
            return "0"
        end
        local mapID = C_Map.GetBestMapForUnit("player")
        while mapID do
            local info = C_Map.GetMapInfo(mapID)
            if not info then
                break
            end
            if info.mapType == 2 then
                return tostring(mapID)
            end
            mapID = info.parentMapID
        end
        return "0"
    end

    local function buildRoute(destIndex)
        local current = currentTaxiNode()
        if not current or type(destIndex) ~= "number" then
            return
        end
        local keys = {}
        local names = {}
        local function add(index)
            keys[#keys + 1] = taxiNodeKey(index) or ("#" .. index)
            names[#names + 1] = shortTaxiName(TaxiNodeName(index)) or ("Node " .. index)
        end
        add(current)
        local hops = GetNumRoutes and GetNumRoutes(destIndex) or 0
        if type(hops) == "number" and hops > 0 and TaxiGetNodeSlot then
            for hop = 2, hops + 1 do
                local slot = TaxiGetNodeSlot(destIndex, hop, true)
                if type(slot) == "number" then
                    add(slot)
                end
            end
        end
        local destKey = taxiNodeKey(destIndex)
        local route = table.concat(keys, ":")
        if destKey and not route:find(destKey, 1, true) then
            add(destIndex)
            route = table.concat(keys, ":")
        elseif #names == 1 then
            add(destIndex)
            route = table.concat(keys, ":")
        end
        return continentKey() .. "|" .. route, names[1], names[#names]
    end

    local function timesDB()
        if not ns.db then
            return nil
        end
        if type(ns.db.flightTimes) ~= "table" then
            ns.db.flightTimes = {}
        end
        return ns.db.flightTimes
    end

    local function savedDuration(route)
        local db = timesDB()
        local value = db and route and db[route]
        if type(value) == "number" and value > 0 then
            return value
        end
    end

    local function rememberDuration(route, seconds)
        if not route or type(seconds) ~= "number" then
            return
        end
        seconds = math.floor(seconds + 0.5)
        if seconds < 5 or seconds > 3600 then
            return
        end
        local db = timesDB()
        if not db then
            return
        end
        local previous = db[route]
        if type(previous) == "number" and previous > 0 then
            db[route] = math.floor((previous * 0.65) + (seconds * 0.35) + 0.5)
        else
            db[route] = seconds
        end
    end

    local function formatClock(seconds)
        seconds = math.max(0, math.floor((seconds or 0) + 0.5))
        return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
    end

    local function setChrome(want)
        want = want or 0
        if flight.chrome == want then
            return
        end
        flight.chrome = want
        placeScroller(10 + want)
        remeasure = true
        lastSignature = nil
        if tracker:IsShown() and ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end

    local function showStrip(on)
        if on then
            strip:Show()
            setChrome(FLIGHT_STRIP)
        else
            strip:Hide()
            setChrome(0)
        end
    end

    local function resetState()
        state.pending = false
        state.flying = false
        state.route = nil
        state.destName = nil
        state.started = nil
        state.duration = nil
        state.armed = nil
    end

    local function paintFlight()
        if not ns.db then
            return
        end
        local edgeR, edgeG, edgeB = ns.Color("accent")
        local textR, textG, textB = ns.Color("secondary")
        paintTexture(flightRule, edgeR, edgeG, edgeB, 0.45)
        paintTexture(trackFill, edgeR, edgeG, edgeB, 0.9)
        destText:SetTextColor(textR, textG, textB)
        timeText:SetTextColor(edgeR, edgeG, edgeB)
    end

    flight.paint = paintFlight

    local watcher
    function updateFlightStrip()
        local onTaxi = UnitOnTaxi and UnitOnTaxi("player")
        if state.pending then
            if onTaxi then
                state.pending = false
                state.flying = true
                state.started = GetTime()
                state.duration = state.duration or savedDuration(state.route)
                if watcher then
                    watcher:Show()
                end
            elseif (GetTime() - (state.armed or 0)) > 8 then
                resetState()
            end
        elseif state.flying then
            if not onTaxi then
                if state.started and state.route then
                    rememberDuration(state.route, GetTime() - state.started)
                end
                resetState()
            end
        elseif onTaxi then
            state.flying = true
            state.started = GetTime()
            state.destName = state.destName or "Flight path"
            state.duration = savedDuration(state.route)
            if watcher then
                watcher:Show()
            end
        end

        local showUI = tracker:IsShown() and ns.db and ns.db.showFlightTimer ~= false and state.flying
        if not showUI then
            if flight.chrome > 0 then
                showStrip(false)
            end
            return
        end

        showStrip(true)
        local elapsed = GetTime() - (state.started or GetTime())
        destText:SetText(state.destName or "Flight path")
        if state.duration and state.duration > 0 then
            local left = state.duration - elapsed
            if left < 0 then
                left = 0
            end
            timeText:SetText(formatClock(left))
            local width = track:GetWidth() or 1
            if width < 1 then
                width = 1
            end
            local ratio = elapsed / state.duration
            if ratio < 0 then
                ratio = 0
            elseif ratio > 1 then
                ratio = 1
            end
            trackFill:SetWidth(math.max(1, width * ratio))
            trackFill:Show()
        else
            timeText:SetText(formatClock(elapsed))
            trackFill:SetWidth(1)
            trackFill:Hide()
        end
    end

    watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_CONTROL_GAINED")
    watcher:SetScript("OnEvent", function()
        if state.flying or state.pending then
            updateFlightStrip()
        end
    end)
    watcher:SetScript("OnUpdate", function(self)
        if not state.pending and not state.flying then
            self:Hide()
            return
        end
        updateFlightStrip()
    end)
    watcher:Hide()

    if type(TakeTaxiNode) == "function" then
        hooksecurefunc("TakeTaxiNode", function(node)
            if type(node) ~= "number" then
                return
            end
            local route, _, destName = buildRoute(node)
            state.pending = true
            state.flying = false
            state.route = route
            state.destName = destName or shortTaxiName(TaxiNodeName(node)) or "Flight path"
            state.started = nil
            state.duration = savedDuration(route)
            state.armed = GetTime()
            watcher:Show()
        end)
    end
end

local function lowerStrata(strata)
    if strata == "HIGH" then
        return "MEDIUM"
    elseif strata == "MEDIUM" then
        return "LOW"
    elseif strata == "LOW" then
        return "BACKGROUND"
    end
    return "BACKGROUND"
end

local function useBackdrop(mode)
    if tracker.__rxpbBackdropMode == mode then
        return
    end
    tracker.__rxpbBackdropMode = mode
    if mode == "none" then
        tracker:SetBackdrop(nil)
    elseif mode == "border" then
        tracker:SetBackdrop({
            bgFile = WHITE,
            edgeFile = WHITE,
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    else
        tracker:SetBackdrop({
            bgFile = WHITE,
        })
    end
end

local function headerTone(panelR, panelG, panelB, background)
    local shade = ns.db.headerShade
    if type(shade) ~= "number" then
        shade = 0.55
    elseif shade < 0 then
        shade = 0
    elseif shade > 1 then
        shade = 1
    end
    local alpha = background + ((1 - background) * shade * 0.85)
    if alpha < 0 then
        alpha = 0
    elseif alpha > 1 then
        alpha = 1
    end
    local keep = 1 - shade
    return panelR * keep, panelG * keep, panelB * keep, alpha
end

local function styleTracker()
    if not ns.db then
        return
    end
    local background = ns.db.trackerBackground
    if type(background) ~= "number" then
        background = 0.4
    end
    local panelR, panelG, panelB = ns.Color("background")
    local edgeR, edgeG, edgeB = ns.Color("accent")
    local edgeA = math.max(0.25, math.min(0.85, background + 0.2))
    local rounded = ns.db.roundedEdges and true or false
    local borderOn = ns.db.trackerBorder and true or false
    local radius = 0
    if rounded then
        radius = ns.db.cornerRadius or 8
        if type(radius) ~= "number" then
            radius = 8
        end
        radius = math.floor(radius + 0.5)
        if radius < 4 then
            radius = 4
        elseif radius > 16 then
            radius = 16
        end
    end

    paint(header, 13, edgeR, edgeG, edgeB)
    if guidePercent then
        paint(guidePercent, 12, edgeR, edgeG, edgeB)
    end
    paintTexture(rule, edgeR, edgeG, edgeB, 0.55)
    if flight.paint then
        flight.paint()
    end

    if rounded then
        useBackdrop("none")
        showPlate(panelFill, tracker, 0, 0, 0, 0, radius)
        paintPlate(panelFill, panelR, panelG, panelB, background)
        if borderOn then
            showBorder(panelBorder, tracker, radius)
            paintPlate(panelBorder, edgeR, edgeG, edgeB, edgeA)
        else
            hidePlate(panelBorder)
        end
        headerBar:Hide()
    else
        hidePlate(panelFill)
        hidePlate(panelHeader)
        hidePlate(panelBorder)
        useBackdrop(borderOn and "border" or "plain")
        tracker:SetBackdropColor(panelR, panelG, panelB, background)
        if borderOn then
            tracker:SetBackdropBorderColor(edgeR, edgeG, edgeB, edgeA)
        end
    end

    if ns.db.darkHeader then
        local hr, hg, hb, ha = headerTone(panelR, panelG, panelB, background)
        if rounded then
            showHeader(panelHeader, tracker, 0, 0, 0, HEADER_BOTTOM, radius)
            paintPlate(panelHeader, hr, hg, hb, ha)
            headerBar:Hide()
        else
            hidePlate(panelHeader)
            local inset = borderOn and 1 or 0
            headerBar:ClearAllPoints()
            headerBar:SetPoint("TOPLEFT", tracker, "TOPLEFT", inset, -inset)
            headerBar:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -inset, -inset)
            headerBar:SetHeight(math.max(1, HEADER_BOTTOM - inset))
            paintTexture(headerBar, hr, hg, hb, ha)
            headerBar:Show()
        end
    else
        headerBar:Hide()
        hidePlate(panelHeader)
    end

    if ns.db.trackerShadow and tracker:IsShown() then
        local spread = 8
        local drop = 4
        local parentScale = UIParent:GetEffectiveScale() or 1
        local frameScale = tracker:GetEffectiveScale() or parentScale
        if parentScale == 0 then
            parentScale = 1
        end
        shadowHost:SetScale(frameScale / parentScale)
        shadowHost:SetFrameStrata(lowerStrata(tracker:GetFrameStrata() or "MEDIUM"))
        shadowHost:ClearAllPoints()
        shadowHost:SetPoint("TOPLEFT", tracker, "TOPLEFT", -spread, spread - drop)
        shadowHost:SetPoint("BOTTOMRIGHT", tracker, "BOTTOMRIGHT", spread, -(spread + drop))
        shadowHost:Show()
        showPlate(panelShadow, shadowHost, 0, 0, 0, 0, rounded and (radius + spread) or 0)
        paintPlate(panelShadow, 0, 0, 0, 0.4)
    else
        hidePlate(panelShadow)
        shadowHost:Hide()
    end
end

local function savePoint()
    if not ns.db then
        return
    end
    local point, _, relativePoint, x, y = tracker:GetPoint()
    if point and type(x) == "number" and type(y) == "number" then
        ns.db.trackerPoint = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end
end

local function restorePoint()
    local saved = ns.db and ns.db.trackerPoint
    if type(saved) ~= "table" or type(saved.point) ~= "string" or type(saved.x) ~= "number" or type(saved.y) ~= "number" then
        return
    end
    tracker:ClearAllPoints()
    tracker:SetPoint(saved.point, UIParent, saved.relativePoint or saved.point, saved.x, saved.y)
end

local function openGuideMenu()
    if ns.db and ns.db.standaloneGuide and ns.ToggleGuideMenu then
        ns.ToggleGuideMenu()
        return
    end
    local rxp = _G.RXPFrame
    if rxp and rxp.DropDownMenu then
        pcall(rxp.DropDownMenu)
    end
end

local function onMouseUp(_, button)
    if button == "RightButton" then
        openGuideMenu()
    end
end

tracker:EnableMouseWheel(true)
tracker:SetScript("OnDragStart", function()
    if InCombatLockdown() then
        return
    end
    tracker:StartMoving()
end)
tracker:SetScript("OnDragStop", function()
    tracker:StopMovingOrSizing()
    savePoint()
    if ns.PlaceGuideCog then
        ns.PlaceGuideCog()
    end
end)
local function uiCoord(frame, value)
    local uiScale = UIParent:GetEffectiveScale()
    if not value or not uiScale or uiScale == 0 then
        return value or 0
    end
    return value * frame:GetEffectiveScale() / uiScale
end

local function tooltipOwnedBy(owner)
    if GameTooltip.IsOwned then
        return GameTooltip:IsOwned(owner)
    end
    return GameTooltip.GetOwner and GameTooltip:GetOwner() == owner
end

local function tooltipOwnerUnder(root)
    if not root or not GameTooltip:IsShown() then
        return false
    end
    local owner = GameTooltip.GetOwner and GameTooltip:GetOwner()
    while owner do
        if owner == root then
            return true
        end
        owner = owner.GetParent and owner:GetParent()
    end
    return false
end

local clearGuideTips

local function placeCursorTooltip(owner)
    if not GameTooltip:IsShown() then
        return
    end
    if owner and not tooltipOwnedBy(owner) then
        return
    end
    if tracker and tracker.IsMouseOver and not tracker:IsMouseOver() then
        if clearGuideTips then
            clearGuideTips()
        end
        return
    end
    local uiScale = UIParent:GetEffectiveScale()
    if not uiScale or uiScale == 0 then
        return
    end
    local cursorX, cursorY = GetCursorPosition()
    cursorX = cursorX / uiScale
    cursorY = cursorY / uiScale
    local gapX = 28
    local gapY = 24
    local tipWidth = uiCoord(GameTooltip, GameTooltip:GetWidth())
    local tipHeight = uiCoord(GameTooltip, GameTooltip:GetHeight())
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    local x = cursorX + gapX
    local y = cursorY - gapY
    if x + tipWidth > screenWidth then
        x = math.max(0, cursorX - gapX - tipWidth)
    end
    if y - tipHeight < 0 then
        y = math.min(screenHeight, cursorY + gapY + tipHeight)
    end
    if y > screenHeight then
        y = screenHeight
    end
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

local function placeTrackerTooltip()
    if not GameTooltip:IsShown() or not tooltipOwnedBy(tracker) then
        return
    end

    local uiScale = UIParent:GetEffectiveScale()
    local _, cursorY = GetCursorPosition()
    if not uiScale or uiScale == 0 then
        return
    end
    cursorY = cursorY / uiScale

    local left = uiCoord(tracker, tracker:GetLeft())
    local right = uiCoord(tracker, tracker:GetRight())
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    local tipWidth = uiCoord(GameTooltip, GameTooltip:GetWidth())
    local tipHeight = uiCoord(GameTooltip, GameTooltip:GetHeight())
    local gap = 8

    local roomLeft = left - gap
    local roomRight = screenWidth - right - gap
    local placeLeft = roomLeft >= tipWidth or roomLeft >= roomRight

    local tipTop = cursorY + tipHeight * 0.5
    if tipTop > screenHeight then
        tipTop = screenHeight
    end
    if tipTop - tipHeight < 0 then
        tipTop = math.min(screenHeight, tipHeight)
    end

    GameTooltip:ClearAllPoints()
    if placeLeft then
        GameTooltip:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", left - gap, tipTop)
    else
        GameTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", right + gap, tipTop)
    end
end

tracker:SetScript("OnMouseUp", onMouseUp)
tracker:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    local ar, ag, ab = ns.Color("accent")
    GameTooltip:SetText(guideTitle(), ar, ag, ab, 1, true)
    GameTooltip:AddLine("Drag to move. Right-click to choose a guide. The header arrows change step, and Jump opens a step number.", 1, 1, 1, true)
    ns.FinishTooltip()
    placeTrackerTooltip()
end)
tracker:SetScript("OnLeave", function(self)
    if self:IsMouseOver() then
        return
    end
    clearGuideTips()
end)

local ARROW_TEXTURE = media("arrow.tga")
local ARROW_COLUMN = 48

local function arrowTint()
    local r, g, b = ns.Color("accent")
    return math.min(1, r * 0.72 + 0.28), math.min(1, g * 0.72 + 0.28), math.min(1, b * 0.72 + 0.28)
end

local function tintArrow(texture, r, g, b, alpha)
    if texture.SetDesaturated then
        texture:SetDesaturated(true)
    end
    local paint = alpha or 1
    texture:SetVertexColor(r, g, b, 0)
    texture:SetVertexColor(r, g, b, paint)
end

local function formatYards(dist)
    if type(dist) ~= "number" then
        return ""
    end
    local yards = math.floor(dist + 0.5)
    if yards >= 10000 then
        return string.format("%dk", math.floor(yards / 1000 + 0.5))
    end
    return yards .. " yd"
end

local function waypointDistance(wp)
    if not wp or type(wp.wx) ~= "number" or type(wp.wy) ~= "number" then
        return nil
    end
    local hbd = hereBeDragons()
    if not hbd or not hbd.GetPlayerWorldPosition or not hbd.GetWorldVector then
        return nil
    end
    local x, y, instance = hbd:GetPlayerWorldPosition()
    if not x then
        return nil
    end
    local _, dist = hbd:GetWorldVector(instance, x, y, wp.wx, wp.wy)
    if type(dist) ~= "number" then
        return nil
    end
    return dist
end

local function formatPlace(place)
    if not place then
        return nil
    end
    local coords = string.format("%.1f, %.1f", place.x, place.y)
    if place.zone then
        return place.zone .. " " .. coords
    end
    return coords
end

local function questLogIndex(questID)
    if not GetNumQuestLogEntries or not GetQuestLogTitle then
        return nil
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local _, _, _, isHeader, _, _, _, logID = GetQuestLogTitle(index)
        local id = logID
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            local ok, qid = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
            if ok and type(qid) == "number" then
                id = qid
            end
        end
        if not isHeader and id == questID then
            return index
        end
    end
end

local function expandQuestHeaders()
    if not ExpandQuestHeader or not GetNumQuestLogEntries or not GetQuestLogTitle then
        return
    end
    local index = 1
    local guard = 0
    while index <= GetNumQuestLogEntries() and guard < 80 do
        guard = guard + 1
        local _, _, _, isHeader, isCollapsed = GetQuestLogTitle(index)
        if isHeader and isCollapsed then
            ExpandQuestHeader(index)
        else
            index = index + 1
        end
    end
end

local function openStepQuest(questID)
    if type(questID) ~= "number" then
        return
    end
    if not playerOnQuest(questID) then
        return
    end
    if QuestLogFrame and SelectQuestLogEntry and GetQuestLogTitle then
        expandQuestHeaders()
        local index = questLogIndex(questID)
        if not index then
            return
        end
        SelectQuestLogEntry(index)
        if QuestLog_SetSelection then
            QuestLog_SetSelection(index)
        end
        if not QuestLogFrame:IsShown() then
            if ShowUIPanel then
                ShowUIPanel(QuestLogFrame)
            else
                QuestLogFrame:Show()
            end
        end
        if QuestLog_Update then
            QuestLog_Update()
        end
        return
    end
    if QuestMapFrame_OpenToQuestDetails then
        QuestMapFrame_OpenToQuestDetails(questID)
        return
    end
    if C_QuestLog and C_QuestLog.SetSelectedQuest then
        if ToggleQuestLog and not (QuestMapFrame and QuestMapFrame:IsShown()) then
            ToggleQuestLog()
        end
        C_QuestLog.SetSelectedQuest(questID)
    end
end

local function showStepTooltip(row)
    if not row or not row.stepIndex then
        return
    end
    local r, g, b = ns.Color("accent")
    local title = row.tipTitle
    if not title or title == "" then
        title = "Step " .. row.stepIndex
    end
    GameTooltip:SetOwner(row, "ANCHOR_NONE")
    GameTooltip:SetText(title, r, g, b, 1, true)
    GameTooltip:AddLine("Step " .. row.stepIndex, 0.8, 0.8, 0.8)
    local shownQuest = false
    for index, quest in ipairs(row.stepQuests or {}) do
        if index > 3 then
            break
        end
        local name = quest.name or ("Quest " .. quest.id)
        if quest.on then
            GameTooltip:AddLine("Quest: " .. name, 1, 1, 1, true)
            shownQuest = true
        else
            GameTooltip:AddLine("Quest: " .. name .. " (not in your log)", 0.7, 0.7, 0.7, true)
        end
    end
    local where = formatPlace(row.place)
    if where then
        GameTooltip:AddLine("Location: " .. where, 1, 1, 1, true)
    end
    local dist = waypointDistance(row.tipWaypoint)
    if dist then
        GameTooltip:AddLine("Distance: " .. formatYards(dist), 1, 1, 1)
    end
    if shownQuest then
        GameTooltip:AddLine("Click to open this quest.", 0.9, 0.82, 0.45, true)
    end
    ns.FinishTooltip()
    placeCursorTooltip(row)
end

local function bindStepTip(row, item)
    row.stepIndex = item.stepIndex
    row.sticky = item.sticky
    row.questId = item.questId
    row.stepQuests = item.stepQuests
    row.place = item.place
    row.tipWaypoint = item.waypoint
    row.tipTitle = plainText(item.headline)
end

local function updateArrows()
    if not ns.db or not tracker:IsShown() or (not ns.db.standaloneGuide and not ns.db.replaceGuide) then
        return
    end
    local facing = GetPlayerFacing and GetPlayerFacing()
    local hbd = hereBeDragons()
    local x, y, instance
    if hbd and hbd.GetPlayerWorldPosition then
        x, y, instance = hbd:GetPlayerWorldPosition()
    end
    local canAim = facing and hbd and x
    for _, row in ipairs(rows) do
        local arrow = row.arrow
        local wp = arrow and arrow.__rxpbWp
        if arrow and arrow:IsShown() and wp and wp.wx and wp.wy then
            local tintR, tintG, tintB = arrowTint()
            tintArrow(arrow, tintR, tintG, tintB, 1)
            if row.arrowShadow then
                row.arrowShadow:SetDrawLayer("ARTWORK", 1)
            end
            arrow:SetDrawLayer("OVERLAY", 2)
            if row.distance then
                row.distance:SetTextColor(tintR, tintG, tintB)
            end
            local angle, dist
            if canAim and arrow.SetRotation then
                angle, dist = hbd:GetWorldVector(instance, x, y, wp.wx, wp.wy)
            end
            if angle then
                arrow:SetAlpha(1)
                arrow:SetRotation(angle - facing)
                if row.arrowShadow and row.arrowShadow:IsShown() and row.arrowShadow.SetRotation then
                    row.arrowShadow:SetRotation(angle - facing)
                end
                if row.distance then
                    row.distance:SetText(formatYards(dist))
                end
            elseif canAim then
                arrow:SetAlpha(0.35)
                if row.distance then
                    row.distance:SetText("")
                end
            end
        end
    end
end

local function setRowHover(row, on)
    if not row or not row.hover then
        return
    end
    if on then
        paintTexture(row.hover, 0, 0, 0, 0.38)
        row.hover:Show()
    else
        row.hover:Hide()
    end
end

clearGuideTips = function()
    for index = 1, #rows do
        local row = rows[index]
        if row then
            row.tipShown = false
            row.__rxpbActionTip = 0
            if row.badge then
                row.badge.tipShown = false
            end
            setRowHover(row, false)
        end
    end
    if tooltipOwnerUnder(tracker) then
        GameTooltip:Hide()
    end
end

local function rowStillHovered(row)
    return row and row:IsVisible() and row:IsMouseOver()
end

local function rowStepTipBlocked(row)
    if not row then
        return true
    end
    if row.badge and row.badge.tipShown then
        return true
    end
    if (row.__rxpbActionTip or 0) > 0 then
        return true
    end
    return false
end

local function pauseRowStepTip(row)
    if not row then
        return
    end
    row.tipShown = false
    row.__rxpbActionTip = (row.__rxpbActionTip or 0) + 1
end

local function resumeRowStepTip(row)
    if not row then
        return
    end
    row.__rxpbActionTip = math.max(0, (row.__rxpbActionTip or 0) - 1)
    if rowStepTipBlocked(row) then
        return
    end
    if rowStillHovered(row) then
        row.tipShown = true
        showStepTooltip(row)
        return
    end
    setRowHover(row, false)
    row.tipShown = false
end

local function acquireRow(index)
    local row = rows[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, body)
    row:EnableMouse(true)
    row:RegisterForDrag("LeftButton")
    row.hover = row:CreateTexture(nil, "BACKGROUND")
    row.hover:SetAllPoints()
    useSolid(row.hover)
    paintTexture(row.hover, 0, 0, 0, 0.38)
    row.hover:Hide()
    row:SetScript("OnEnter", function(self)
        setRowHover(self, true)
        self.tipShown = true
        showStepTooltip(self)
    end)
    row:SetScript("OnLeave", function(self)
        if rowStillHovered(self) then
            return
        end
        setRowHover(self, false)
        self.tipShown = false
        if self.badge then
            self.badge.tipShown = false
        end
        if tooltipOwnedBy(self) or tooltipOwnerUnder(self) then
            GameTooltip:Hide()
        end
    end)
    row:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.tipDragged = false
        end
    end)
    row:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then
            return
        end
        self.tipDragged = true
        tracker:StartMoving()
    end)
    row:SetScript("OnDragStop", function()
        tracker:StopMovingOrSizing()
        savePoint()
        if ns.PlaceGuideCog then
            ns.PlaceGuideCog()
        end
    end)
    row:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            openGuideMenu()
            return
        end
        if button == "LeftButton" and not self.tipDragged then
            openStepQuest(self.questId)
        end
    end)
    local tipElapsed = 0
    row:SetScript("OnUpdate", function(self, delta)
        if not self.tipShown or rowStepTipBlocked(self) then
            return
        end
        if not tracker:IsMouseOver() then
            clearGuideTips()
            return
        end
        tipElapsed = tipElapsed + (delta or 0)
        if tipElapsed >= 0.25 then
            tipElapsed = 0
            showStepTooltip(self)
        else
            placeCursorTooltip(self)
        end
    end)
    row.badge = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.badge:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    row.badge.text = row.badge:CreateFontString(nil, "OVERLAY")
    row.badge.text:SetPoint("CENTER", 0, 0)
    applyFont(row.badge.text, 12, "OUTLINE")
    row.badge:EnableMouse(true)
    row.badge:SetFrameLevel(row:GetFrameLevel() + 8)
    row.badge:SetScript("OnEnter", function(self)
        local parent = self:GetParent()
        setRowHover(parent, true)
        if parent then
            parent.tipShown = false
        end
        if not self.stepIndex then
            return
        end
        self.tipShown = true
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetText("Skip step " .. self.stepIndex, r, g, b)
        GameTooltip:AddLine("Click to skip this step.", 1, 1, 1, true)
        ns.FinishTooltip()
        placeCursorTooltip(self)
    end)
    row.badge:SetScript("OnLeave", function(self)
        self.tipShown = false
        local parent = self:GetParent()
        if rowStillHovered(parent) then
            if parent then
                parent.tipShown = true
                showStepTooltip(parent)
            end
            return
        end
        GameTooltip:Hide()
        setRowHover(parent, false)
        if parent then
            parent.tipShown = false
        end
    end)
    row.badge:SetScript("OnUpdate", function(self)
        if not self.tipShown then
            return
        end
        if not tracker:IsMouseOver() then
            clearGuideTips()
            return
        end
        placeCursorTooltip(self)
    end)
    row.badge:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" or not self.stepIndex then
            return
        end
        GameTooltip:Hide()
        skipListedStep(self.stepIndex, self.sticky)
    end)

    row.arrowShadow = row:CreateTexture(nil, "ARTWORK")
    row.arrowShadow:SetDrawLayer("ARTWORK", 1)
    row.arrowShadow:SetTexture(ARROW_TEXTURE)
    tintArrow(row.arrowShadow, 0, 0, 0, 0.8)
    row.arrowShadow:Hide()

    row.arrow = row:CreateTexture(nil, "OVERLAY")
    row.arrow:SetDrawLayer("OVERLAY", 2)
    row.arrow:SetTexture(ARROW_TEXTURE)
    tintArrow(row.arrow, 1, 0.82, 0, 1)
    row.arrow:Hide()

    row.distance = row:CreateFontString(nil, "OVERLAY")
    applyFont(row.distance, 10, "OUTLINE")
    row.distance:SetJustifyH("CENTER")
    row.distance:SetJustifyV("TOP")
    row.distance:Hide()

    row.text = row:CreateFontString(nil, "OVERLAY")
    paint(row.text, 13, 1, 1, 1)
    row.details = row:CreateFontString(nil, "OVERLAY")
    paint(row.details, 12, 0.82, 0.82, 0.82)
    rows[index] = row
    return row
end

local function rememberHome(button)
    if button.__rxpbHome or not button.GetPoint then
        return
    end
    local point, relative, relativePoint, x, y = button:GetPoint(1)
    button.__rxpbHome = {
        parent = button:GetParent(),
        point = point,
        relative = relative,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

local function applyPlace(button)
    local place = button.__rxpbPlace
    if not place or not place.parent or InCombatLockdown() then
        return
    end
    buttonBusy = true
    button:SetParent(place.parent)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", place.parent, "TOPLEFT", place.x, place.y)
    button:SetSize(22, 22)
    local level = place.parent.GetFrameLevel and place.parent:GetFrameLevel() or 1
    button:SetFrameLevel(level + 6)
    button:SetAlpha(1)
    pcall(button.EnableMouse, button, true)
    button:Show()
    buttonBusy = false
end

local function hookAction(button)
    if not button or not button.SetPoint then
        return
    end
    if not button.__rxpbHooked then
        button.__rxpbHooked = true
        hooksecurefunc(button, "SetPoint", function(self)
            if buttonBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() or not self.__rxpbPlace then
                return
            end
            local place = self.__rxpbPlace
            local _, relativeTo = self:GetPoint(1)
            if self:GetParent() == place.parent and relativeTo == place.parent then
                return
            end
            applyPlace(self)
        end)
    end
    if not button.__rxpbTipHooked and button.HookScript then
        button.__rxpbTipHooked = true
        button:HookScript("OnEnter", function(self)
            local place = self.__rxpbPlace
            pauseRowStepTip(place and place.parent)
        end)
        button:HookScript("OnLeave", function(self)
            local place = self.__rxpbPlace
            resumeRowStepTip(place and place.parent)
        end)
    end
end

local function placeAction(button, parent, x, y)
    if not button then
        return
    end
    rememberHome(button)
    hookAction(button)
    button.__rxpbPlace = { parent = parent, x = x, y = y }
    parked[button] = true
    applyPlace(button)
end

local function restoreAction(button)
    local home = button.__rxpbHome
    button.__rxpbPlace = nil
    parked[button] = nil
    if not home or InCombatLockdown() then
        return
    end
    buttonBusy = true
    if home.parent then
        button:SetParent(home.parent)
    end
    button:ClearAllPoints()
    if home.point and home.relative then
        button:SetPoint(home.point, home.relative, home.relativePoint or home.point, home.x or 0, home.y or 0)
    end
    button:SetSize(25, 25)
    buttonBusy = false
end

local function restoreAllActions()
    local held = {}
    for button in pairs(parked) do
        held[#held + 1] = button
    end
    for _, button in ipairs(held) do
        restoreAction(button)
    end
end

local function reassertActions()
    if InCombatLockdown() then
        return
    end
    for button in pairs(parked) do
        local place = button.__rxpbPlace
        if place and place.parent then
            local _, relativeTo = button:GetPoint(1)
            if button:GetParent() ~= place.parent or relativeTo ~= place.parent then
                applyPlace(button)
            end
        end
    end
end

local function colorChannel(value)
    value = math.floor((value or 0) * 255 + 0.5)
    if value < 0 then
        value = 0
    elseif value > 255 then
        value = 255
    end
    return string.format("%02x", value)
end

local function colorCode(r, g, b)
    return "|cff" .. colorChannel(r) .. colorChannel(g) .. colorChannel(b)
end

local function spansOverlap(spans, first, last)
    for _, span in ipairs(spans) do
        if first <= span.finish and last >= span.start then
            return true
        end
    end
end

local function wordByte(text, index)
    if index < 1 or index > #text then
        return false
    end
    return text:sub(index, index):match("[%w]") and true or false
end

local function findNameSpans(plain, names, allowPlural)
    local spans = {}
    local lower = plain:lower()
    local sorted = {}
    local seenNeedle = {}
    for _, name in ipairs(names or {}) do
        if type(name) == "string" and #name >= 3 then
            local key = name:lower()
            if not seenNeedle[key] then
                seenNeedle[key] = true
                sorted[#sorted + 1] = name
            end
            if allowPlural ~= false then
                local singular = name:match("^(.-)s$")
                if singular and #singular >= 3 and not name:match("ss$") and not seenNeedle[singular:lower()] then
                    seenNeedle[singular:lower()] = true
                    sorted[#sorted + 1] = singular
                end
            end
        end
    end
    table.sort(sorted, function(a, b)
        return #a > #b
    end)

    for _, name in ipairs(sorted) do
        local needle = name:lower()
        local startAt = 1
        while true do
            local first, last = lower:find(needle, startAt, true)
            if not first then
                break
            end
            if allowPlural ~= false then
                local plural = lower:sub(last + 1, last + 1)
                if plural == "s" and not wordByte(lower, last + 2) then
                    last = last + 1
                end
            end
            if not wordByte(lower, first - 1) and not wordByte(lower, last + 1) and not spansOverlap(spans, first, last) then
                spans[#spans + 1] = { start = first, finish = last }
            end
            startAt = last + 1
        end
    end

    table.sort(spans, function(a, b)
        return a.start < b.start
    end)
    return spans
end

local function findBracketSpans(plain)
    local spans = {}
    local startAt = 1
    while true do
        local first, last = plain:find("%b[]", startAt)
        if not first then
            break
        end
        if last > first + 1 then
            spans[#spans + 1] = { start = first, finish = last }
        end
        startAt = last + 1
    end
    return spans
end

local function findProgressNameSpans(plain)
    local spans = {}
    local name = progressItemName(plain)
    if not name then
        return spans
    end
    local first, last = plain:find(name, 1, true)
    if first then
        spans[#spans + 1] = { start = first, finish = last }
    end
    return spans
end

local function colorSpans(plain, spans)
    if #spans == 0 then
        return plain
    end
    table.sort(spans, function(a, b)
        return a.start < b.start
    end)
    local code = colorCode(ns.Color("accent"))
    local out = {}
    local cursor = 1
    for _, span in ipairs(spans) do
        if span.start > cursor then
            out[#out + 1] = plain:sub(cursor, span.start - 1)
        end
        if span.start >= cursor then
            out[#out + 1] = code .. plain:sub(span.start, span.finish) .. "|r"
            cursor = span.finish + 1
        end
    end
    if cursor <= #plain then
        out[#out + 1] = plain:sub(cursor)
    end
    return table.concat(out)
end

local function addSpans(spans, extra)
    for _, span in ipairs(extra) do
        if not spansOverlap(spans, span.start, span.finish) then
            spans[#spans + 1] = span
        end
    end
end

local function presentPlain(plain, names, quests, highlightNames)
    local spans = findBracketSpans(plain)
    addSpans(spans, findProgressNameSpans(plain))
    addSpans(spans, findNameSpans(plain, quests, false))
    if highlightNames then
        addSpans(spans, findNameSpans(plain, names, true))
    end
    return colorSpans(plain, spans)
end

local function presentHeadline(item)
    local plain = plainText(item.headline)
    if not plain then
        return ""
    end
    return presentPlain(plain, item.names, item.quests, true)
end

local function presentDetails(item)
    local accentR, accentG, accentB = ns.Color("accent")
    local bullet = colorCode(accentR, accentG, accentB) .. "\226\128\162|r "
    local lines = {}
    for _, line in ipairs(item.details or {}) do
        local plain = plainText(line)
        if plain then
            lines[#lines + 1] = bullet .. presentPlain(plain, item.names, item.quests, true)
        end
    end
    return table.concat(lines, "\n")
end

local function applyRowText(row, item, index)
    row.__rxpbItem = item
    local main = index == 1
    local textR, textG, textB = ns.Color(main and "text" or "secondary")
    paint(row.text, main and 16 or 13, textR, textG, textB)
    row.text:SetText(presentHeadline(item))
    if item.details and #item.details > 0 then
        local detailR, detailG, detailB = ns.Color("detail")
        paint(row.details, main and 13 or 12, detailR, detailG, detailB)
        row.details:SetText(presentDetails(item))
        row.details:Show()
    elseif row.details then
        row.details:SetText("")
        row.details:Hide()
    end
end

local function badgeLabel(item, index)
    local number = item.number > 0 and item.number or index
    return number, tostring(number)
end

local TRACKER_CHROME = 44
local MIN_TRACKER_WIDTH = 220
local MAX_TRACKER_WIDTH = 640
local MIN_TRACKER_HEIGHT = 120
local MAX_TRACKER_HEIGHT = 800

local function readTrackerWidth()
    local width = ns.db and ns.db.trackerWidth or TRACKER_WIDTH
    if type(width) ~= "number" then
        width = TRACKER_WIDTH
    end
    width = math.floor(width + 0.5)
    if width < MIN_TRACKER_WIDTH then
        width = MIN_TRACKER_WIDTH
    elseif width > MAX_TRACKER_WIDTH then
        width = MAX_TRACKER_WIDTH
    end
    return width
end

local function readTrackerHeight()
    if not ns.db or ns.db.trackerFitHeight ~= false then
        return nil
    end
    local height = ns.db.trackerHeight or 360
    if type(height) ~= "number" then
        height = 360
    end
    height = math.floor(height + 0.5)
    if height < MIN_TRACKER_HEIGHT then
        height = MIN_TRACKER_HEIGHT
    elseif height > MAX_TRACKER_HEIGHT then
        height = MAX_TRACKER_HEIGHT
    end
    return height
end

local function updateScrollThumb(view, content, offset, maxScroll)
    local edgeR, edgeG, edgeB = ns.Color("accent")
    paintTexture(scrollThumb, edgeR, edgeG, edgeB, 0.55)
    if maxScroll <= 1 or view < 8 then
        scrollBar:Hide()
        return
    end
    scrollBar:Show()
    local barHeight = scrollBar:GetHeight() or 0
    if barHeight < 8 then
        barHeight = view
    end
    local thumbHeight = math.max(18, barHeight * (view / math.max(content, 1)))
    if thumbHeight > barHeight then
        thumbHeight = barHeight
    end
    local travel = barHeight - thumbHeight
    local top = 0
    if maxScroll > 0 then
        top = travel * (offset / maxScroll)
    end
    scrollThumb:ClearAllPoints()
    scrollThumb:SetPoint("TOP", scrollBar, "TOP", 0, -top)
    scrollThumb:SetHeight(thumbHeight)
end

local function scrollRange()
    local chrome = TRACKER_CHROME + (flight.chrome or 0)
    local view = (tracker:GetHeight() or 0) - chrome
    local content = body:GetHeight() or 0
    if view < 1 then
        view = 1
    end
    local maxScroll = content - view
    if maxScroll < 0 then
        maxScroll = 0
    end
    return maxScroll, view, content
end

local function scrollWheel(_, delta)
    local maxScroll = scrollRange()
    if maxScroll <= 0 then
        return
    end
    local offset = (scroller:GetVerticalScroll() or 0) - (delta * 40)
    if offset < 0 then
        offset = 0
    elseif offset > maxScroll then
        offset = maxScroll
    end
    scroller:SetVerticalScroll(offset)
    local _, view, content = scrollRange()
    updateScrollThumb(view, content, offset, maxScroll)
end

scroller:SetScript("OnMouseWheel", scrollWheel)
tracker:SetScript("OnMouseWheel", scrollWheel)

local function applyTrackerBox(contentHeight, resetScroll)
    local width = readTrackerWidth()
    tracker:SetWidth(width)
    local inner = width - 16
    if inner < 40 then
        inner = 40
    end
    if contentHeight < 20 then
        contentHeight = 20
    end
    body:SetWidth(inner)
    body:SetHeight(contentHeight)
    local chrome = TRACKER_CHROME + (flight.chrome or 0)
    local limit = readTrackerHeight()
    local height = chrome + contentHeight
    if limit then
        height = limit
    end
    tracker:SetHeight(height)
    local view = height - chrome
    if view < 1 then
        view = 1
    end
    local maxScroll = contentHeight - view
    if maxScroll < 0 then
        maxScroll = 0
    end
    local offset = 0
    if not resetScroll then
        offset = scroller:GetVerticalScroll() or 0
    end
    if offset < 0 then
        offset = 0
    elseif offset > maxScroll then
        offset = maxScroll
    end
    scroller:SetVerticalScroll(offset)
    updateScrollThumb(view, contentHeight, offset, maxScroll)
end

local function badgeFontSize(main, number)
    if number >= 100 then
        return main and 8 or 7
    end
    return main and 12 or 11
end

local function progressRatio(text)
    local plain = plainText(text)
    if not plain or not isProgress(plain) then
        return nil
    end
    local done, total = plain:match("(%d+)%s*/%s*(%d+)")
    done = tonumber(done)
    total = tonumber(total)
    if not done or not total or total <= 1 then
        return nil
    end
    if done < 0 then
        done = 0
    elseif done > total then
        done = total
    end
    return done / total
end

local function stepRatios(item)
    local ratios = {}
    local function take(text)
        local ratio = progressRatio(text)
        if ratio then
            ratios[#ratios + 1] = ratio
        end
    end
    if item then
        take(item.headline)
        for _, line in ipairs(item.details or {}) do
            take(line)
        end
    end
    return ratios
end

local PROGRESS_BAR_HEIGHT = 6
local PROGRESS_BAR_GAP = 2

local function ensureProgressBar(row, index)
    row.progressBars = row.progressBars or {}
    local holder = row.progressBars[index]
    if holder then
        return holder
    end
    holder = CreateFrame("Frame", nil, row, "BackdropTemplate")
    holder:SetHeight(PROGRESS_BAR_HEIGHT)
    holder:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    holder.bar = CreateFrame("StatusBar", nil, holder)
    holder.bar:SetPoint("TOPLEFT", 1, -1)
    holder.bar:SetPoint("BOTTOMRIGHT", -1, 1)
    holder.bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
    holder.bar:SetMinMaxValues(0, 1)
    holder.bar:SetFrameLevel(holder:GetFrameLevel() + 1)
    row.progressBars[index] = holder
    return holder
end

local function syncProgressBars(row, item, textLeft, rightInset)
    if textLeft then
        row.__rxpbBarLeft = textLeft
        row.__rxpbBarRight = rightInset or 0
    end
    textLeft = textLeft or row.__rxpbBarLeft
    rightInset = rightInset or row.__rxpbBarRight or 0
    local ratios = stepRatios(item)
    local bars = row.progressBars
    if not textLeft then
        if bars then
            for _, holder in ipairs(bars) do
                holder:Hide()
            end
        end
        return 0
    end
    local accentR, accentG, accentB = ns.Color("accent")
    for index, ratio in ipairs(ratios) do
        local holder = ensureProgressBar(row, index)
        holder:Show()
        holder:ClearAllPoints()
        local y = 1 + (#ratios - index) * (PROGRESS_BAR_HEIGHT + PROGRESS_BAR_GAP)
        holder:SetPoint("BOTTOMLEFT", textLeft, y)
        holder:SetPoint("BOTTOMRIGHT", -rightInset, y)
        holder:SetBackdropColor(0, 0, 0, 0.6)
        holder:SetBackdropBorderColor(accentR, accentG, accentB, 0.4)
        holder.bar:SetStatusBarColor(accentR, accentG, accentB, 1)
        holder.bar:SetValue(ratio)
    end
    if bars then
        for index = #ratios + 1, #bars do
            bars[index]:Hide()
        end
    end
    if #ratios == 0 then
        return 0
    end
    return #ratios * PROGRESS_BAR_HEIGHT + (#ratios - 1) * PROGRESS_BAR_GAP + 4
end

local function layout(items, resetScroll)
    local measured = true
    local y = 0
    local count = #items
    local width = readTrackerWidth()
    tracker:SetWidth(width)
    body:SetWidth(math.max(40, width - 16))

    if count == 0 then
        for index = 1, #rows do
            rows[index]:Hide()
        end
        empty:Show()
        divider:Hide()
        local waiting = guideTitle() ~= "RestedXP"
        empty:SetText(waiting and "Waiting for the next step" or "Right-click to choose a guide")
        applyTrackerBox(20, resetScroll)
        restoreAllActions()
        return true
    end

    empty:Hide()
    local seenActions = {}

    for index, item in ipairs(items) do
        local row = acquireRow(index)
        local main = index == 1
        local br, bg, bb = ns.BadgeColor(index)
        local badgeSize = main and 22 or 18

        row:Show()
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -y)
        row:SetPoint("RIGHT", body, "RIGHT", 0, 0)

        row.badge:ClearAllPoints()
        row.badge:SetSize(badgeSize, badgeSize)
        row.badge:SetPoint("TOPLEFT", (COLUMN - badgeSize) / 2, main and -1 or 0)
        styleBadge(row.badge, br, bg, bb)
        local badgeNumber, badgeText = badgeLabel(item, index)
        applyFont(row.badge.text, badgeFontSize(main, badgeNumber), "OUTLINE")
        row.badge.text:ClearAllPoints()
        row.badge.text:SetAllPoints(row.badge)
        row.badge.text:SetJustifyH("CENTER")
        row.badge.text:SetJustifyV("MIDDLE")
        if row.badge.text.SetWordWrap then
            row.badge.text:SetWordWrap(false)
        end
        row.badge.text:SetText(badgeText)
        row.badge.stepIndex = item.stepIndex
        row.badge.sticky = item.sticky
        bindStepTip(row, item)
        row.badge.text:SetTextColor(1, 1, 1)
        row.badge.text:SetShadowColor(0, 0, 0, 1)
        row.badge.text:SetShadowOffset(0, 0)

        local textLeft = COLUMN + 8
        local rightInset = 0
        local arrowSize = main and 20 or 15
        if item.waypoint and row.arrow then
            local tintR, tintG, tintB = arrowTint()
            local centerX = -2 - (ARROW_COLUMN / 2)
            tintArrow(row.arrow, tintR, tintG, tintB, 1)
            row.arrow:Show()
            row.arrow:ClearAllPoints()
            row.arrow:SetSize(arrowSize, arrowSize)
            row.arrow:SetPoint("CENTER", row, "TOPRIGHT", centerX, -arrowSize / 2)
            row.arrow.__rxpbWp = item.waypoint
            if row.arrowShadow then
                tintArrow(row.arrowShadow, 0, 0, 0, 0.9)
                row.arrowShadow:Show()
                row.arrowShadow:ClearAllPoints()
                row.arrowShadow:SetSize(arrowSize + 2, arrowSize + 2)
                row.arrowShadow:SetPoint("CENTER", row, "TOPRIGHT", centerX, -arrowSize / 2)
                row.arrowShadow:SetDrawLayer("ARTWORK", 1)
            end
            row.arrow:SetDrawLayer("OVERLAY", 2)
            if row.distance then
                row.distance:Show()
                row.distance:ClearAllPoints()
                row.distance:SetPoint("TOPRIGHT", -2, -(arrowSize + 5))
                row.distance:SetWidth(ARROW_COLUMN)
                applyFont(row.distance, main and 10 or 9, "OUTLINE")
                row.distance:SetJustifyH("CENTER")
                row.distance:SetTextColor(tintR, tintG, tintB)
            end
            rightInset = ARROW_COLUMN + 6
        elseif row.arrow then
            row.arrow:Hide()
            row.arrow.__rxpbWp = nil
            if row.arrowShadow then
                row.arrowShadow:Hide()
            end
            if row.distance then
                row.distance:Hide()
                row.distance:SetText("")
            end
        end

        row.text:ClearAllPoints()
        row.text:SetPoint("TOPLEFT", textLeft, 0)
        row.text:SetPoint("TOPRIGHT", -rightInset, 0)
        applyRowText(row, item, index)

        local textHeight = row.text:GetStringHeight() or 0
        if textHeight < 1 then
            measured = false
            textHeight = main and 18 or 14
        end

        local detailHeight = 0
        if item.details and #item.details > 0 then
            row.details:Show()
            row.details:ClearAllPoints()
            row.details:SetPoint("TOPLEFT", textLeft, -(textHeight + 2))
            row.details:SetPoint("TOPRIGHT", -rightInset, -(textHeight + 2))
            detailHeight = row.details:GetStringHeight() or 0
            if detailHeight < 1 then
                measured = false
                detailHeight = (main and 14 or 12) * #item.details
            end
            detailHeight = detailHeight + 2
        else
            row.details:Hide()
        end

        local actionHeight = 0
        local actions = item.actions or {}
        if #actions > 0 then
            local stride = 26
            local avail = width - 24 - textLeft - rightInset
            local perRow = math.max(1, math.floor(avail / stride))
            local yBase = textHeight + detailHeight + 4
            for actionIndex, button in ipairs(actions) do
                local col = (actionIndex - 1) % perRow
                local line = math.floor((actionIndex - 1) / perRow)
                placeAction(button, row, textLeft + (col * stride), -(yBase + (line * stride)))
                seenActions[button] = true
            end
            actionHeight = (math.floor((#actions - 1) / perRow) + 1) * stride + 2
        end

        local navHeight = item.waypoint and (arrowSize + 17) or 0
        local barHeight = syncProgressBars(row, item, textLeft, rightInset)
        local blockHeight = math.max(badgeSize, textHeight + detailHeight + actionHeight, navHeight) + barHeight
        row:SetHeight(blockHeight)
        y = y + blockHeight + (main and 10 or 6)
    end

    for index = count + 1, #rows do
        rows[index]:Hide()
    end

    local stale = {}
    for button in pairs(parked) do
        if not seenActions[button] then
            stale[#stale + 1] = button
        end
    end
    for _, button in ipairs(stale) do
        restoreAction(button)
    end

    if count > 1 then
        local mainRow = rows[1]
        divider:ClearAllPoints()
        divider:SetPoint("TOPLEFT", body, "TOPLEFT", COLUMN + 8, -(mainRow:GetHeight() + 4))
        divider:SetPoint("TOPRIGHT", body, "TOPRIGHT", 0, -(mainRow:GetHeight() + 4))
        divider:Show()
    else
        divider:Hide()
    end

    applyTrackerBox(math.max(20, y), resetScroll)
    return measured
end

local function paintRowColors()
    for index, row in ipairs(rows) do
        if row:IsShown() and row.badge then
            local r, g, b = ns.BadgeColor(index)
            styleBadge(row.badge, r, g, b)
            local item = row.__rxpbItem
            if item then
                applyRowText(row, item, index)
                syncProgressBars(row, item)
            end
            if row.arrow and row.arrow:IsShown() then
                local tintR, tintG, tintB = arrowTint()
                tintArrow(row.arrow, tintR, tintG, tintB, 1)
                if row.distance then
                    row.distance:SetTextColor(tintR, tintG, tintB)
                end
            end
        end
    end
end

function ns.RefreshTracker(force)
    if not ns.db or not tracker:IsShown() or (not ns.db.standaloneGuide and not ns.db.replaceGuide) then
        return
    end

    local items = collectObjectives()
    local parts = {}
    for index, item in ipairs(items) do
        local actionNames = {}
        for _, button in ipairs(item.actions or {}) do
            local label = button.targetData and button.targetData.name or button.name or button.itemId or "?"
            actionNames[#actionNames + 1] = tostring(label)
        end
        local wp = item.waypoint
        local wpText = wp and string.format("%.0f,%.0f", wp.wx, wp.wy) or "-"
        parts[index] = tostring(item.number) .. "\t" .. item.headline .. "\t" .. table.concat(item.details or {}, "|") .. "\t" .. table.concat(item.names or {}, ",") .. "\t" .. table.concat(item.quests or {}, ",") .. "\t" .. table.concat(actionNames, ",") .. "\t" .. wpText
    end
    local percentLabel = guidePercentLabel() or ""
    local signature = guideTitle() .. "\n" .. percentLabel .. "\n" .. table.concat(parts, "\n")

    header:SetText(guideTitle())
    placeGuidePercent()

    local scale = ns.db.trackerScale or 1.2
    if math.abs((tracker:GetScale() or 1) - scale) > 0.001 then
        tracker:SetScale(scale)
    end

    if InCombatLockdown() and next(parked) then
        for index, item in ipairs(items) do
            local row = rows[index]
            if row and row.text then
                local main = index == 1
                if row.badge and row.badge.text then
                    local badgeNumber, badgeText = badgeLabel(item, index)
                    applyFont(row.badge.text, badgeFontSize(main, badgeNumber), "OUTLINE")
                    row.badge.text:SetText(badgeText)
                    row.badge.stepIndex = item.stepIndex
                    row.badge.sticky = item.sticky
                    bindStepTip(row, item)
                end
                if row.arrow then
                    row.arrow.__rxpbWp = item.waypoint
                end
                applyRowText(row, item, index)
            end
        end
        paintRowColors()
        styleTracker()
        styleStepButtons()
        return
    end

    local sizeNow = readTrackerWidth() .. ":" .. (readTrackerHeight() or 0)
    local sizeChanged = sizeNow ~= sizeKey
    sizeKey = sizeNow
    local contentChanged = signature ~= lastSignature
    if force or contentChanged or sizeChanged or remeasure then
        if layout(items, contentChanged) then
            lastSignature = signature
            remeasure = sizeChanged
        else
            remeasure = true
        end
    end
    styleTracker()
    paintRowColors()
    styleStepButtons()
    reassertActions()
end

local function hookMouse(frame)
    if not frame or hookedMouse[frame] or not frame.EnableMouse or not frame.GetObjectType then
        return
    end
    if frame.IsForbidden and frame:IsForbidden() then
        return
    end

    hookedMouse[frame] = true
    hooksecurefunc(frame, "EnableMouse", function(self, enabled)
        if mouseBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
            return
        end
        if enabled then
            mouseBusy = true
            pcall(self.EnableMouse, self, false)
            mouseBusy = false
        end
    end)
end

local function isGuideAction(frame)
    if not frame then
        return false
    end
    if frame.targetData or frame.itemId or frame.macro then
        return true
    end
    local name = frame.GetName and frame:GetName()
    if type(name) == "string" then
        if name:find("RXPItemFrameButton", 1, true) or name:find("RXPTargetFrame_", 1, true) then
            return true
        end
    end
    return false
end

local function walkMouse(frame, depth)
    if not frame or depth > 8 then
        return
    end
    if frame.IsForbidden and frame:IsForbidden() then
        return
    end
    if isGuideAction(frame) then
        return
    end

    local unseen = not hookedMouse[frame]
    hookMouse(frame)
    if unseen and ns.ReplacingGuide() and frame.EnableMouse then
        mouseBusy = true
        pcall(frame.EnableMouse, frame, false)
        mouseBusy = false
    end

    if frame.GetNumChildren then
        for index = 1, frame:GetNumChildren() do
            walkMouse(select(index, frame:GetChildren()), depth + 1)
        end
    end
end

local chromeHooked = {}

local function chromeFrames(rxp)
    return {
        rxp.BottomFrame,
        rxp.GuideName,
        rxp.Footer,
        rxp.CurrentStepFrame,
    }
end

local function hookChromeAlpha(frame)
    if not frame or chromeHooked[frame] or not frame.SetAlpha then
        return
    end
    chromeHooked[frame] = true
    hooksecurefunc(frame, "SetAlpha", function(self, alpha)
        if alphaBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
            return
        end
        if (alpha or 1) > 0 then
            alphaBusy = true
            self:SetAlpha(0)
            alphaBusy = false
        end
    end)
end

local cogBusy = false
local cogHome
local satelliteHooked = {}

local function guideCog()
    local rxp = _G.RXPFrame
    return rxp and rxp.Footer and rxp.Footer.cog
end

local function rememberCog(cog)
    if cogHome or not cog then
        return
    end
    local point, relative, relativePoint, x, y = cog:GetPoint(1)
    cogHome = {
        parent = cog:GetParent(),
        point = point,
        relative = relative,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

local function placeCog()
    local cog = guideCog()
    if not cog or not ns.ReplacingGuide or not ns.ReplacingGuide() then
        return
    end
    rememberCog(cog)
    if not cog.__rxpbHooked then
        cog.__rxpbHooked = true
        hooksecurefunc(cog, "SetPoint", function(self)
            if cogBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
                return
            end
            local _, relativeTo = self:GetPoint(1)
            if relativeTo == tracker then
                return
            end
            cogBusy = true
            self:SetParent(tracker)
            self:ClearAllPoints()
            self:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -4, -4)
            cogBusy = false
        end)
    end

    cogBusy = true
    cog:SetParent(tracker)
    cog:SetFrameStrata(tracker:GetFrameStrata())
    cog:SetFrameLevel(tracker:GetFrameLevel() + 20)
    cog:ClearAllPoints()
    cog:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -4, -4)
    cog:SetAlpha(1)
    cog:EnableMouse(true)
    cog:Show()
    cogBusy = false
end

ns.PlaceGuideCog = placeCog

local function restoreCog()
    local cog = guideCog()
    if not cog or not cogHome then
        return
    end
    cogBusy = true
    if cogHome.parent then
        cog:SetParent(cogHome.parent)
    end
    cog:ClearAllPoints()
    if cogHome.point and cogHome.relative then
        cog:SetPoint(cogHome.point, cogHome.relative, cogHome.relativePoint or cogHome.point, cogHome.x or 0, cogHome.y or 0)
    end
    cogBusy = false
end

local function satelliteFrames()
    local frames = {}
    if _G.RXPTargetFrame then
        frames[#frames + 1] = _G.RXPTargetFrame
    end
    local items = itemWindow()
    if items then
        frames[#frames + 1] = items
    end
    return frames
end

local function concealSatellite(frame)
    if not frame then
        return
    end
    if not satelliteHooked[frame] and frame.SetAlpha then
        satelliteHooked[frame] = true
        hooksecurefunc(frame, "SetAlpha", function(self, alpha)
            if alphaBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
                return
            end
            if (alpha or 1) > 0 then
                alphaBusy = true
                self:SetAlpha(0)
                alphaBusy = false
            end
        end)
        if frame.Show then
            hooksecurefunc(frame, "Show", function(self)
                if alphaBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
                    return
                end
                self.__rxpbWasShown = true
                alphaBusy = true
                self:SetAlpha(0)
                if not InCombatLockdown() then
                    pcall(self.Hide, self)
                end
                alphaBusy = false
            end)
        end
    end
    hookMouse(frame)
    if frame.IsShown and frame:IsShown() then
        frame.__rxpbWasShown = true
    end
    alphaBusy = true
    frame:SetAlpha(0)
    if not InCombatLockdown() then
        pcall(frame.Hide, frame)
    end
    alphaBusy = false
    walkMouse(frame, 0)
end

local function revealSatellite(frame)
    if not frame or not frame.SetAlpha then
        return
    end
    local showAgain = frame.__rxpbWasShown
    frame.__rxpbWasShown = nil
    alphaBusy = true
    frame:SetAlpha(1)
    if showAgain and frame.Show and not InCombatLockdown() then
        pcall(frame.Show, frame)
    end
    alphaBusy = false
end

local function concealGuide(rxp)
    alphaBusy = true
    rxp:SetAlpha(1)
    alphaBusy = false

    for _, frame in ipairs(chromeFrames(rxp)) do
        if frame then
            hookChromeAlpha(frame)
            alphaBusy = true
            frame:SetAlpha(0)
            alphaBusy = false
            walkMouse(frame, 0)
        end
    end

    hookMouse(rxp)
    if rxp.EnableMouse then
        mouseBusy = true
        rxp:EnableMouse(false)
        mouseBusy = false
    end

    for _, frame in ipairs(satelliteFrames()) do
        concealSatellite(frame)
    end
    placeCog()
end

local function revealGuide(rxp)
    alphaBusy = true
    for _, frame in ipairs(chromeFrames(rxp)) do
        if frame and frame.SetAlpha then
            frame:SetAlpha(1)
        end
    end
    alphaBusy = false

    mouseBusy = true
    for frame in pairs(hookedMouse) do
        if frame.EnableMouse then
            frame:EnableMouse(true)
        end
    end
    mouseBusy = false

    for _, frame in ipairs(satelliteFrames()) do
        revealSatellite(frame)
    end
    restoreAllActions()
    restoreCog()
end

local function hookStepText()
    local current = _G.RXPFrame and _G.RXPFrame.CurrentStepFrame
    if not current or not current.UpdateText or current.__rxpbTextHook then
        return
    end
    current.__rxpbTextHook = true
    hooksecurefunc(current, "UpdateText", function()
        pcall(ns.RefreshTracker)
    end)
end

local standaloneWas = false

function ns.OnGuideScan()
    local rxp = _G.RXPFrame
    if not rxp then
        return
    end
    hookStepText()
    if ns.ReplacingGuide() then
        if not tracker:IsShown() then
            ns.SyncReplacement()
            return
        end
        concealGuide(rxp)
        ns.RefreshTracker()
    elseif ns.db and ns.db.standaloneGuide then
        ns.RefreshTracker()
    end
end

function ns.SyncReplacement()
    if not ns.db then
        return
    end

    if not ns.db.standaloneGuide and ns.HideGuideMenu then
        ns.HideGuideMenu()
    end
    if ns.db.standaloneGuide and not standaloneWas then
        if ns.GuideEnsure then
            ns.GuideEnsure()
        end
        if ns.GuideCatchUp then
            ns.GuideCatchUp()
        end
    end
    standaloneWas = ns.db.standaloneGuide and true or false

    local rxp = _G.RXPFrame
    local showTracker = ns.db.standaloneGuide or (ns.db.replaceGuide and rxp)
    if showTracker then
        if ns.db.standaloneGuide then
            if rxp then
                revealGuide(rxp)
            end
        elseif rxp then
            concealGuide(rxp)
        end
        if not pointRestored then
            restorePoint()
            pointRestored = true
        end
        tracker:SetScale(ns.db.trackerScale or 1.2)
        tracker:Show()
        ns.RefreshTracker(true)
    else
        tracker:Hide()
        lastSignature = nil
        if rxp then
            revealGuide(rxp)
        end
    end
end

local elapsed = 0
tracker:SetScript("OnUpdate", function(self, delta)
    if not self:IsMouseOver() then
        clearGuideTips()
    else
        placeTrackerTooltip()
    end
    pcall(updateArrows)
    pcall(updateFlightStrip)
    if not (ns.db and ns.db.standaloneGuide) then
        pcall(maintainReview)
    end
    elapsed = elapsed + delta
    if elapsed < 0.2 then
        return
    end
    elapsed = 0
    ns.RefreshTracker()
end)

tracker:SetScript("OnShow", function()
    lastSignature = nil
    ns.RefreshTracker(true)
    pcall(updateFlightStrip)
end)

tracker:SetScript("OnHide", function()
    clearGuideTips()
    shadowHost:Hide()
    if flight.strip then
        flight.strip:Hide()
    end
end)
