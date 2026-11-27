local addonName, ns = ...

-- RXP / standalone guide helpers used by the tracker UI.
-- Kept in its own file so Replace.lua stays under Lua's 200-local limit.

ns.ReplaceState = ns.ReplaceState or {}
local State = ns.ReplaceState

local RG = {}
ns.RG = RG

local function uiFont()
    if GameFontHighlight then
        local font = GameFontHighlight:GetFont()
        if font then
            return font
        end
    end
    return "Fonts\\FRIZQT__.TTF"
end

local function outlineFlags(flags)
    if flags == "OUTLINE" or flags == "THICKOUTLINE" then
        return flags
    end
    if ns.db and ns.db.textOutline then
        return "OUTLINE"
    end
    return flags or ""
end

local function applyFont(fs, size, flags)
    local font = uiFont()
    flags = outlineFlags(flags)
    if not fs:SetFont(font, size, flags) then
        fs:SetFont(font, size)
    end
end

local function paint(fs, size, r, g, b)
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
    text = text:gsub("|cRB_[A-Z]+_(.-)|r", "%1")
    text = text:gsub("RB_[A-Z]+_", "")
    text = text:gsub("|n", "\n")
    text = strtrim(text)
    if text == "" or text == " " then
        return nil
    end
    return text
end

local function plainText(text)
    text = objectiveText(text)
    if not text then
        return nil
    end
    -- Keep the body of [FRIENDLY]Name[/] / [FRIENDLY]Name[/FRIENDLY] authoring tags.
    text = text:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|cRB_[A-Z]+_", "")
    text = text:gsub("|cRXP_[A-Z]+_", "")
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

local function primaryStep()
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

local function currentGuide()
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

local function maintainReview()
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
        State.lastSignature = nil
        if ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end
    pinStep(step)
end

local function reopenStep(step)
    pinStep(step)
end

local function earlierStep(guide, index)
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

local function goToStep(index)
    local setStep = stepSetter()
    if not setStep or type(index) ~= "number" or index < 1 then
        return
    end
    releaseReview()
    if not pcall(setStep, index) then
        return
    end
    State.lastSignature = nil
    ns.RefreshTracker(true)
end

local function goBackward()
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
    State.lastSignature = nil
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
        State.lastSignature = nil
        ns.RefreshTracker(true)
        return
    end
    goToStep(index)
end

local function skipListedStep(index, sticky)
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
        State.lastSignature = nil
        ns.RefreshTracker(true)
        return
    end
    goToStep(index + 1)
end

if not StaticPopupDialogs["WaynotesJump"] then
    StaticPopupDialogs["WaynotesJump"] = {
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

local function guideTitle()
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

local function isProgress(text)
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
    -- Authored gather counts: "Durotar Tiger Fur (4)".
    if plain:match("%S.+%(%d+%)%s*$") then
        return true
    end
    return false
end

local function progressItemName(text)
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
    for _, tag in ipairs({ "RXP_ENEMY_", "RXP_FRIENDLY_", "RXP_LOOT_", "RXP_PICK_", "RXP_BUY_", "RXP_QUEST_" }) do
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

local function itemWindow()
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

-- Questie 12.12+ no longer registers HereBeDragons-2.0 with LibStub. It keeps
-- its copy as a QuestieLoader module named "HBD". Step arrows and distances
-- need a working HBD, so try LibStub first (RXP, older Questie, standalone
-- HBD) and then Questie's module. The result is cached once it is usable.
local hereBeDragons
do
    local cached

    local function usable(lib)
        return type(lib) == "table"
            and type(lib.GetPlayerWorldPosition) == "function"
            and type(lib.GetWorldVector) == "function"
    end

    hereBeDragons = function()
        if cached then
            return cached
        end
        if type(LibStub) == "table" or type(LibStub) == "function" then
            -- Silent lookup: the plain call raises an error when the lib is absent.
            local ok, lib = pcall(function()
                return LibStub:GetLibrary("HereBeDragons-2.0", true)
            end)
            if ok and usable(lib) then
                cached = lib
                return lib
            end
        end
        -- Only import when Questie is present. ImportModule creates an empty
        -- stub for unknown names, so verify the methods before trusting it.
        if type(QuestieLoader) == "table" and type(QuestieLoader.ImportModule) == "function" then
            local ok, lib = pcall(QuestieLoader.ImportModule, QuestieLoader, "HBD")
            if ok and usable(lib) then
                cached = lib
                return lib
            end
        end
        return nil
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
    local best, bestDist, bestLow, bestRoute
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
                local route
                local aim = { wx = wx, wy = wy, instance = inst }
                if ns.TravelBestPath and (element.tag == "goto" or element.tag == "fly" or element.tag == "hs" or element.arrow) then
                    local prefer
                    if element.tag == "hs" then
                        prefer = "hearth"
                    elseif element.tag == "fly" then
                        prefer = "fly"
                    end
                    route = ns.TravelBestPath({
                        name = element.zone,
                        zone = element.zone,
                        wx = wx,
                        wy = wy,
                        instance = inst,
                        prefer = prefer,
                    }, { prefer = prefer })
                    if route then
                        if route.waypoint then
                            aim = route.waypoint
                        end
                        if type(route.seconds) == "number" then
                            dist = route.seconds * 10
                        end
                    end
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
                    best = aim
                    bestDist = dist
                    bestLow = low
                    bestRoute = route
                end
            end
        end
    end
    if best and bestRoute and bestRoute.waypoint then
        return bestRoute.waypoint
    end
    return best
end

local function playerOnQuest(id)
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

local function collectObjectives()
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
    local overflow = false
    local expanded = ns.IsMoreStepsExpanded and ns.IsMoreStepsExpanded()
    local primaryIndex
    for index, step in ipairs(steps) do
        if step and not step.tip and not step.sticky and not primaryIndex then
            primaryIndex = index
        end
    end
    if ns.db and ns.db.simpleMode then
        -- Show the earliest active step, sticky or not.
        local showIndex = primaryIndex
        for index, step in ipairs(steps) do
            if step and not step.tip then
                showIndex = index
                break
            end
        end
        if showIndex then
            order[#order + 1] = showIndex
        end
    else
        if primaryIndex then
            order[#order + 1] = primaryIndex
        end
        for index, step in ipairs(steps) do
            if index ~= primaryIndex and step and not step.tip then
                order[#order + 1] = index
            end
        end
        local cap = ns.MaxTrackerSteps and ns.MaxTrackerSteps() or 4
        if #order > cap then
            overflow = true
            if not expanded then
                while #order > cap do
                    order[#order] = nil
                end
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
    if overflow then
        list[#list + 1] = {
            number = 0,
            headline = expanded and "Show less" or "More steps...",
            details = {},
            actions = {},
            names = {},
            quests = {},
            stepQuests = {},
            moreSteps = true,
            moreStepsExpanded = expanded and true or false,
        }
    end
    return list
end

-- Public surface for Replace.lua
RG.applyFont = applyFont
RG.paint = paint
RG.plainText = plainText
RG.primaryStep = primaryStep
RG.currentGuide = currentGuide
RG.maintainReview = maintainReview
RG.earlierStep = earlierStep
RG.goToStep = goToStep
RG.goBackward = goBackward
RG.jumpToStep = jumpToStep
RG.skipListedStep = skipListedStep
RG.guideTitle = guideTitle
RG.isProgress = isProgress
RG.progressItemName = progressItemName
RG.itemWindow = itemWindow
RG.hereBeDragons = hereBeDragons
RG.playerOnQuest = playerOnQuest
RG.collectObjectives = collectObjectives

