local _, ns = ...

local COLUMN = 26
local TRACKER_WIDTH = 300
local mouseBusy = false
local alphaBusy = false
local buttonBusy = false
local parked = {}
local hookedMouse = {}
local rows = {}
local lastSignature
local pointRestored = false

local function uiFont()
    if GameFontHighlight then
        local font = GameFontHighlight:GetFont()
        if font then
            return font
        end
    end
    return "Fonts\\FRIZQT__.TTF"
end

local function paint(fs, size, r, g, b)
    fs:SetFont(uiFont(), size, "")
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
    text = text:gsub("RXP_[A-Z]+_", "")
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
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
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

local function reopenStep(step)
    step.completed = false
    if step.tipWindow then
        step.tipWindow.completed = false
    end
    if _G.RXPCData and _G.RXPCData.stepSkip and step.index then
        _G.RXPCData.stepSkip[step.index] = nil
    end
    if type(step.elements) == "table" then
        for _, element in ipairs(step.elements) do
            if not element.textOnly then
                element.completed = false
            end
        end
    end
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

local function goToStep(index)
    local setStep = stepSetter()
    if not setStep or type(index) ~= "number" or index < 1 then
        return
    end
    if not pcall(setStep, index) then
        return
    end
    lastSignature = nil
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
            if not now or now.index < current then
                break
            end
            n = n - 1
        end
    end
    lastSignature = nil
    ns.RefreshTracker(true)
end

local function guideTitle()
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
    return false
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

    for elementIndex, element in ipairs(step.elements or {}) do
        if element and not element.skip then
            if element.mobs or element.targets or element.unitscan then
                wantsTargets = true
                namesFromValue(element.mobs, targetNames, targetSeen)
                namesFromValue(element.targets, targetNames, targetSeen)
                namesFromValue(element.unitscan, targetNames, targetSeen)
            end

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
                local text = objectiveText(raw)
                if text then
                    lines[#lines + 1] = text
                end
            end
        end
    end

    return lines, wantsTargets, targetNames
end

local function hereBeDragons()
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

local function collectObjectives()
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
    if primaryIndex then
        order[#order + 1] = primaryIndex
    end
    for index, step in ipairs(steps) do
        if index ~= primaryIndex and step and not step.tip then
            order[#order + 1] = index
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
        local lines, wantsTargets, targetNames = visibleLines(step, activeIndex)
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
                local seen = {}
                seen[(plainText(objective.headline) or ""):lower()] = true

                for _, name in ipairs(targetNames) do
                    if not claimButton(objective, targetButtonFor(name)) then
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
header:SetPoint("TOPRIGHT", -60, -7)
header:SetHeight(16)
paint(header, 13, ns.Color("accent"))
if header.SetMaxLines then
    header:SetMaxLines(1)
end
if header.SetWordWrap then
    header:SetWordWrap(false)
end

local stepButtons = {}
local styleStepButtons

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
    highlight:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    highlight:SetVertexColor(1, 1, 1, 0.14)

    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetSize(11, 11)
    button.icon:SetPoint("CENTER", 0, 0)
    button.icon:SetTexture("Interface\\AddOns\\RXPGuides\\Textures\\rxp_navigation_arrow-1")
    button.icon:SetRotation(direction < 0 and (math.pi / 2) or (-math.pi / 2))

    button:SetScript("OnClick", function(self)
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
        GameTooltip:Show()
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
    local r, g, b = ns.Color("accent")
    for _, button in ipairs(stepButtons) do
        local enabled = stepButtonEnabled(button)
        if button.icon.SetDesaturated then
            button.icon:SetDesaturated(true)
        end
        button.icon:SetVertexColor(r, g, b, enabled and 1 or 0.35)
        if enabled then
            button:Enable()
        else
            button:Disable()
        end
        if button.hovered and enabled then
            button:SetBackdropColor(r, g, b, 0.22)
            button:SetBackdropBorderColor(r, g, b, 1)
        else
            button:SetBackdropColor(0, 0, 0, enabled and 0.55 or 0.3)
            button:SetBackdropBorderColor(r, g, b, enabled and 0.75 or 0.28)
        end
    end
end

createStepButton(-1, -42)
createStepButton(1, -24)

local rule = tracker:CreateTexture(nil, "ARTWORK")
rule:SetPoint("TOPLEFT", 8, -26)
rule:SetPoint("TOPRIGHT", -8, -26)
rule:SetHeight(1)
rule:SetTexture("Interface\\BUTTONS\\WHITE8X8")
rule:SetVertexColor(1, 0.82, 0, 0.5)

local body = CreateFrame("Frame", nil, tracker)
body:SetPoint("TOPLEFT", 8, -34)
body:SetPoint("TOPRIGHT", -8, -34)
body:SetHeight(20)

local empty = body:CreateFontString(nil, "OVERLAY")
empty:SetPoint("TOPLEFT", 4, 0)
empty:SetPoint("RIGHT", -4, 0)
paint(empty, 13, 0.85, 0.85, 0.85)
empty:SetText("Right-click to choose a guide")
empty:Hide()

local divider = body:CreateTexture(nil, "ARTWORK")
divider:SetHeight(1)
divider:SetTexture("Interface\\BUTTONS\\WHITE8X8")
divider:SetVertexColor(1, 1, 1, 0.16)
divider:Hide()

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
    GameTooltip:SetText(guideTitle(), ar, ag, ab)
    GameTooltip:AddLine("Drag to move. Right-click to choose a guide. The header arrows change step.", 1, 1, 1, true)
    GameTooltip:Show()
    placeTrackerTooltip()
end)
tracker:SetScript("OnLeave", GameTooltip_Hide)

local ARROW_TEXTURE = "Interface\\AddOns\\RXPGuides\\Textures\\rxp_navigation_arrow-1"
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

local function updateArrows()
    if not ns.db or not ns.db.replaceGuide or not tracker:IsShown() then
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

local function acquireRow(index)
    local row = rows[index]
    if row then
        return row
    end

    row = CreateFrame("Frame", nil, body)
    row.badge = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.badge:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    row.badge.text = row.badge:CreateFontString(nil, "OVERLAY")
    row.badge.text:SetPoint("CENTER", 0, 0)

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
    row.distance:SetFont(uiFont(), 10, "OUTLINE")
    row.distance:SetJustifyH("CENTER")
    row.distance:SetJustifyV("TOP")
    row.distance:Hide()

    row.text = row:CreateFontString(nil, "OVERLAY")
    row.details = row:CreateFontString(nil, "OVERLAY")
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
    if button.__rxpbHooked or not button.SetPoint then
        return
    end
    button.__rxpbHooked = true
    hooksecurefunc(button, "SetPoint", function(self)
        if buttonBusy or not ns.db or not ns.db.replaceGuide or not self.__rxpbPlace then
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

local function badgeLabel(item, index)
    local number = item.number > 0 and item.number or index
    return number, tostring(number)
end

local function badgeFontSize(main, number)
    if number >= 100 then
        return main and 8 or 7
    end
    return main and 12 or 11
end

local function layout(items)
    local measured = true
    local y = 0
    local count = #items

    if count == 0 then
        for index = 1, #rows do
            rows[index]:Hide()
        end
        empty:Show()
        divider:Hide()
        local waiting = guideTitle() ~= "RestedXP"
        empty:SetText(waiting and "Waiting for the next step" or "Right-click to choose a guide")
        body:SetHeight(20)
        tracker:SetHeight(62)
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
        row.badge:SetBackdropColor(br, bg, bb, 1)
        row.badge:SetBackdropBorderColor(0, 0, 0, 0.45)
        local badgeNumber, badgeText = badgeLabel(item, index)
        row.badge.text:SetFont(uiFont(), badgeFontSize(main, badgeNumber), "OUTLINE")
        row.badge.text:ClearAllPoints()
        row.badge.text:SetAllPoints(row.badge)
        row.badge.text:SetJustifyH("CENTER")
        row.badge.text:SetJustifyV("MIDDLE")
        if row.badge.text.SetWordWrap then
            row.badge.text:SetWordWrap(false)
        end
        row.badge.text:SetText(badgeText)
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
                row.distance:SetFont(uiFont(), main and 10 or 9, "OUTLINE")
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
        local tr, tg, tb = ns.Color(main and "text" or "secondary")
        paint(row.text, main and 16 or 13, tr, tg, tb)
        row.text:SetText(item.headline)

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
            local dr, dg, db = ns.Color("detail")
            paint(row.details, main and 13 or 12, dr, dg, db)
            row.details:SetText(table.concat(item.details, "\n"))
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
            local avail = TRACKER_WIDTH - 24 - textLeft - rightInset
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
        local blockHeight = math.max(badgeSize, textHeight + detailHeight + actionHeight, navHeight)
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

    body:SetHeight(math.max(20, y))
    tracker:SetHeight(34 + body:GetHeight() + 10)
    return measured
end

local function paintRowColors()
    for index, row in ipairs(rows) do
        if row:IsShown() and row.badge then
            local r, g, b = ns.BadgeColor(index)
            row.badge:SetBackdropColor(r, g, b, 1)
            local main = index == 1
            local tr, tg, tb = ns.Color(main and "text" or "secondary")
            row.text:SetTextColor(tr, tg, tb)
            local dr, dg, db = ns.Color("detail")
            row.details:SetTextColor(dr, dg, db)
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
    if not ns.db or not ns.db.replaceGuide or not tracker:IsShown() then
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
        parts[index] = tostring(item.number) .. "\t" .. item.headline .. "\t" .. table.concat(item.details or {}, "|") .. "\t" .. table.concat(actionNames, ",") .. "\t" .. wpText
    end
    local signature = guideTitle() .. "\n" .. table.concat(parts, "\n")

    header:SetText(guideTitle())

    if InCombatLockdown() and next(parked) then
        for index, item in ipairs(items) do
            local row = rows[index]
            if row and row.text then
                if row.badge and row.badge.text then
                    local badgeNumber, badgeText = badgeLabel(item, index)
                    row.badge.text:SetFont(uiFont(), badgeFontSize(index == 1, badgeNumber), "OUTLINE")
                    row.badge.text:SetText(badgeText)
                end
                if row.arrow then
                    row.arrow.__rxpbWp = item.waypoint
                end
                row.text:SetText(item.headline)
                if item.details and #item.details > 0 then
                    row.details:SetText(table.concat(item.details, "\n"))
                    row.details:Show()
                elseif row.details then
                    row.details:Hide()
                end
            end
        end
        paintRowColors()
        styleStepButtons()
        return
    end

    local scale = ns.db.trackerScale or 1.2
    if math.abs((tracker:GetScale() or 1) - scale) > 0.001 then
        tracker:SetScale(scale)
    end
    local background = ns.db.trackerBackground
    if type(background) ~= "number" then
        background = 0.4
    end
    local panelR, panelG, panelB = ns.Color("background")
    local edgeR, edgeG, edgeB = ns.Color("accent")
    tracker:SetBackdropColor(panelR, panelG, panelB, background)
    tracker:SetBackdropBorderColor(edgeR, edgeG, edgeB, math.max(0.25, math.min(0.85, background + 0.2)))
    paint(header, 13, edgeR, edgeG, edgeB)
    rule:SetVertexColor(edgeR, edgeG, edgeB, 0.55)

    if force or signature ~= lastSignature then
        if layout(items) then
            lastSignature = signature
        end
    end
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
        if mouseBusy or not ns.db or not ns.db.replaceGuide then
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
    if unseen and ns.db and ns.db.replaceGuide and frame.EnableMouse then
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
        if alphaBusy or not ns.db or not ns.db.replaceGuide then
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
    if not cog or not ns.db or not ns.db.replaceGuide then
        return
    end
    rememberCog(cog)
    if not cog.__rxpbHooked then
        cog.__rxpbHooked = true
        hooksecurefunc(cog, "SetPoint", function(self)
            if cogBusy or not ns.db or not ns.db.replaceGuide then
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
            if alphaBusy or not ns.db or not ns.db.replaceGuide then
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
                if alphaBusy or not ns.db or not ns.db.replaceGuide then
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

function ns.OnGuideScan()
    local rxp = _G.RXPFrame
    if not rxp then
        return
    end
    hookStepText()
    if ns.db and ns.db.replaceGuide then
        concealGuide(rxp)
        ns.RefreshTracker()
    end
end

function ns.SyncReplacement()
    if not ns.db then
        return
    end

    local rxp = _G.RXPFrame
    if ns.db.replaceGuide then
        if rxp then
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
tracker:SetScript("OnUpdate", function(_, delta)
    pcall(updateArrows)
    placeTrackerTooltip()
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
end)
