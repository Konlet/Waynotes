local _, ns = ...

-- Optional slim step overview under the tracker. Toggle: showStepList.

local GAP = 6
local HEIGHT = 112
local ROW = 16
local PAD = 4

local panel
local scroll
local body
local rows = {}
local scrollBar
local scrollThumb
local lastGuideId
local lastCurrent
local lastCount
local pinnedCurrent
local painted = false
local cachedEntries
local cachedGuideId
local rowsLaidOut = false

local function tracker()
    return _G.WaynotesTracker
end

local function enabled()
    return ns.db and ns.db.showStepList and true or false
end

local function plainText(text)
    if ns.RG and ns.RG.plainText then
        return ns.RG.plainText(text)
    end
    if type(text) ~= "string" then
        return nil
    end
    text = text:gsub("%[%a+%]([^%[%]]-)%[%/%a*%]", "%1")
    text = text:gsub("|cRB_[A-Z]+_", ""):gsub("|cRXP_[A-Z]+_", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = strtrim(text:gsub("|n", " "):gsub("\n", " "))
    if text == "" then
        return nil
    end
    return text
end

local function rxpEntries()
    local RG = ns.RG
    if not RG or not RG.currentGuide then
        return nil, nil, nil
    end
    local guide = RG.currentGuide()
    local steps = guide and guide.steps
    if type(steps) ~= "table" or #steps < 1 then
        return nil, nil, nil
    end
    local current = 1
    local primary = RG.primaryStep and RG.primaryStep()
    if primary and type(primary.index) == "number" then
        current = primary.index
    elseif _G.RXPCData and type(_G.RXPCData.currentStep) == "number" then
        current = _G.RXPCData.currentStep
    end
    if current < 1 then
        current = 1
    elseif current > #steps then
        current = #steps
    end

    local entries = {}
    for index, step in ipairs(steps) do
        local header
        if step then
            header = plainText(step.title)
            if header and header:match("^Step %d+$") then
                header = nil
            end
            if not header and type(step.elements) == "table" then
                for _, element in ipairs(step.elements) do
                    header = plainText(element and element.text)
                    if header then
                        header = header:match("^[^\n]+") or header
                        break
                    end
                end
            end
        end
        header = header or ("Step " .. index)
        local details = {}
        local quests
        local seenQuest
        local function addQuest(id)
            id = tonumber(id)
            if not id or id <= 0 then
                return
            end
            if not quests then
                quests = {}
                seenQuest = {}
            end
            if seenQuest[id] then
                return
            end
            seenQuest[id] = true
            quests[#quests + 1] = id
        end
        if step and type(step.quests) == "table" then
            for _, id in ipairs(step.quests) do
                addQuest(id)
            end
        end
        if step then
            addQuest(step.quest)
        end
        if step and type(step.elements) == "table" then
            for _, element in ipairs(step.elements) do
                if element then
                    addQuest(element.questId)
                    if type(element.ids) == "table" then
                        for _, id in ipairs(element.ids) do
                            addQuest(id)
                        end
                    end
                end
            end
            for _, element in ipairs(step.elements) do
                local line = plainText(element and element.text)
                if line and line ~= header then
                    details[#details + 1] = line
                    if #details >= 8 then
                        break
                    end
                end
            end
        end
        entries[index] = {
            index = index,
            header = header,
            details = details,
            quests = quests,
        }
    end
    local guideId = guide.name or guide.key or guide.group or tostring(guide)
    return entries, current, guideId
end

local function collectEntries()
    if ns.db and ns.db.standaloneGuide and ns.GuideStepListData then
        return ns.GuideStepListData()
    end
    return rxpEntries()
end

local function applyFont(fs, size, flags)
    if ns.RG and ns.RG.applyFont then
        ns.RG.applyFont(fs, size, flags or "")
        return
    end
    local font = GameFontHighlight and GameFontHighlight:GetFont() or "Fonts\\FRIZQT__.TTF"
    if not fs:SetFont(font, size, flags or "") then
        fs:SetFont(font, size)
    end
end

local function stylePanel()
    if not panel or not ns.db then
        return
    end
    -- Match tracker theme colors and trackerBackground alpha (not menu opacity).
    if ns.StylePopupFrame then
        ns.StylePopupFrame(panel, { matchTracker = true })
    end
    painted = true
end

local function updateScrollThumb()
    if not scrollBar or not scrollThumb or not scroll then
        return
    end
    local view = scroll:GetHeight() or 1
    local content = body:GetHeight() or 0
    local maxScroll = content - view
    if maxScroll < 1 then
        scrollBar:Hide()
        return
    end
    scrollBar:Show()
    local barH = scrollBar:GetHeight() or view
    local thumbH = math.max(16, barH * (view / content))
    local offset = scroll:GetVerticalScroll() or 0
    local travel = barH - thumbH
    local y = 0
    if maxScroll > 0 and travel > 0 then
        y = -(offset / maxScroll) * travel
    end
    scrollThumb:ClearAllPoints()
    scrollThumb:SetPoint("TOPRIGHT", scrollBar, "TOPRIGHT", 0, y)
    scrollThumb:SetHeight(thumbH)
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    if ns.Color then
        edgeR, edgeG, edgeB = ns.Color("accent")
    end
    scrollThumb:SetVertexColor(edgeR, edgeG, edgeB, 0.55)
end

local function paintRow(row, current, restyle)
    local isCurrent = row.stepIndex == current
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    local textR, textG, textB = 0.9, 0.9, 0.86
    local detailR, detailG, detailB = 0.82, 0.82, 0.82
    if ns.Color then
        edgeR, edgeG, edgeB = ns.Color("accent")
        textR, textG, textB = ns.Color("secondary")
        detailR, detailG, detailB = ns.Color("detail")
    end
    -- SetFont is expensive; only reapply on create / theme restyle.
    if restyle then
        applyFont(row.number, 10, "OUTLINE")
        applyFont(row.header, 10, "")
    end
    if isCurrent then
        row.number:SetTextColor(edgeR, edgeG, edgeB)
        row.header:SetTextColor(edgeR, edgeG, edgeB)
        if row.glow then
            row.glow:SetVertexColor(edgeR, edgeG, edgeB, 0.12)
            row.glow:Show()
        end
    else
        row.number:SetTextColor(detailR, detailG, detailB)
        row.header:SetTextColor(textR, textG, textB)
        if row.glow then
            row.glow:Hide()
        end
    end
end

local function showRowTip(row)
    if not row or not row.stepIndex then
        return
    end
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    if ns.Color then
        edgeR, edgeG, edgeB = ns.Color("accent")
    end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(tostring(row.stepIndex) .. ". " .. (row.tipHeader or "Step"), edgeR, edgeG, edgeB)
    local details = row.tipDetails
    if type(details) == "table" then
        for _, line in ipairs(details) do
            GameTooltip:AddLine(line, 1, 1, 1, true)
        end
    end
    GameTooltip:AddLine("Click to jump to this step.", 0.9, 0.82, 0.45, true)
    if type(row.quests) == "table" and #row.quests > 0 then
        if #row.quests > 1 then
            GameTooltip:AddLine("Shift-click to link these quests in chat.", 0.9, 0.82, 0.45, true)
        else
            GameTooltip:AddLine("Shift-click to link this quest in chat.", 0.9, 0.82, 0.45, true)
        end
    end
    if ns.FinishTooltip then
        ns.FinishTooltip()
    else
        GameTooltip:Show()
    end
end

local function acquireRow(index)
    local row = rows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, body)
    row:SetHeight(ROW)
    row:EnableMouse(true)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local glow = row:CreateTexture(nil, "BACKGROUND")
    glow:SetAllPoints()
    glow:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    glow:Hide()
    row.glow = glow

    row.number = row:CreateFontString(nil, "OVERLAY")
    row.number:SetPoint("LEFT", 6, 0)
    row.number:SetWidth(28)
    row.number:SetJustifyH("LEFT")
    row.number:SetJustifyV("MIDDLE")
    applyFont(row.number, 10, "OUTLINE")
    if row.number.SetWordWrap then
        row.number:SetWordWrap(false)
    end
    if row.number.SetMaxLines then
        row.number:SetMaxLines(1)
    end

    row.header = row:CreateFontString(nil, "OVERLAY")
    row.header:SetPoint("LEFT", row.number, "RIGHT", 4, 0)
    row.header:SetPoint("RIGHT", -6, 0)
    row.header:SetJustifyH("LEFT")
    row.header:SetJustifyV("MIDDLE")
    applyFont(row.header, 10, "")
    if row.header.SetWordWrap then
        row.header:SetWordWrap(false)
    end
    if row.header.SetMaxLines then
        row.header:SetMaxLines(1)
    end

    row:SetScript("OnEnter", function(self)
        paintRow(self, pinnedCurrent)
        showRowTip(self)
    end)
    row:SetScript("OnLeave", function(self)
        paintRow(self, pinnedCurrent)
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if ns.OpenGuideMenu then
                ns.OpenGuideMenu()
            end
            return
        end
        if IsShiftKeyDown and IsShiftKeyDown() and ns.PutQuestsInChat and ns.PutQuestsInChat(self.quests) then
            return
        end
        if type(self.stepIndex) ~= "number" then
            return
        end
        if ns.RG and ns.RG.jumpToStep then
            ns.RG.jumpToStep(self.stepIndex)
        elseif ns.GuideJump then
            ns.GuideJump(self.stepIndex)
        end
    end)

    rows[index] = row
    return row
end

local function scrollToCurrent(current)
    if not scroll or type(current) ~= "number" or current < 1 then
        return
    end
    local view = scroll:GetHeight() or HEIGHT
    local content = body:GetHeight() or 0
    local maxScroll = content - view
    if maxScroll < 0 then
        maxScroll = 0
    end
    local offset = (current - 1) * ROW
    if offset < 0 then
        offset = 0
    elseif offset > maxScroll then
        offset = maxScroll
    end
    scroll:SetVerticalScroll(offset)
    updateScrollThumb()
end

local function ensurePanel()
    if panel then
        return panel
    end

    panel = CreateFrame("Frame", "WaynotesStepList", UIParent, "BackdropTemplate")
    panel:SetHeight(HEIGHT)
    panel:SetFrameStrata("MEDIUM")
    panel:EnableMouse(true)
    panel:EnableMouseWheel(true)
    panel:Hide()
    panel.__waynotesMatchTracker = true
    panel:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    local background = ns.db and ns.db.trackerBackground
    if type(background) ~= "number" then
        background = 0.4
    end
    local panelR, panelG, panelB = 0, 0, 0
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    if ns.Color then
        panelR, panelG, panelB = ns.Color("background")
        edgeR, edgeG, edgeB = ns.Color("accent")
    end
    panel:SetBackdropColor(panelR, panelG, panelB, background)
    panel:SetBackdropBorderColor(edgeR, edgeG, edgeB, math.max(0.25, math.min(0.85, background + 0.2)))

    scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", PAD, -PAD)
    scroll:SetPoint("BOTTOMRIGHT", -(PAD + 4), PAD)
    scroll:EnableMouseWheel(true)

    body = CreateFrame("Frame", nil, scroll)
    body:SetSize(100, ROW)
    scroll:SetScrollChild(body)

    scrollBar = CreateFrame("Frame", nil, panel)
    scrollBar:SetWidth(3)
    scrollBar:SetPoint("TOPRIGHT", -3, -PAD)
    scrollBar:SetPoint("BOTTOMRIGHT", -3, PAD)
    scrollBar:Hide()
    scrollThumb = scrollBar:CreateTexture(nil, "OVERLAY")
    scrollThumb:SetWidth(3)
    scrollThumb:SetTexture("Interface\\BUTTONS\\WHITE8X8")

    local function onWheel(_, delta)
        local view = scroll:GetHeight() or 1
        local content = body:GetHeight() or 0
        local maxScroll = content - view
        if maxScroll < 1 then
            return
        end
        local offset = (scroll:GetVerticalScroll() or 0) - (delta * ROW * 2)
        if offset < 0 then
            offset = 0
        elseif offset > maxScroll then
            offset = maxScroll
        end
        scroll:SetVerticalScroll(offset)
        updateScrollThumb()
    end
    scroll:SetScript("OnMouseWheel", onWheel)
    panel:SetScript("OnMouseWheel", onWheel)
    panel:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" and ns.OpenGuideMenu then
            ns.OpenGuideMenu()
        end
    end)
    panel:SetScript("OnShow", function()
        stylePanel()
    end)

    return panel
end

local function placePanel()
    local host = tracker()
    if not panel or not host or not host:IsShown() then
        return
    end
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", host, "BOTTOMLEFT", 0, -GAP)
    panel:SetPoint("TOPRIGHT", host, "BOTTOMRIGHT", 0, -GAP)
    panel:SetHeight(HEIGHT)
    local strata = host:GetFrameStrata() or "MEDIUM"
    if panel:GetFrameStrata() ~= strata then
        panel:SetFrameStrata(strata)
    end
    local level = (host:GetFrameLevel() or 1) + 2
    if panel:GetFrameLevel() ~= level then
        panel:SetFrameLevel(level)
    end
end

function ns.SetStepListAlpha(alpha)
    if not panel then
        return
    end
    if type(alpha) ~= "number" then
        return
    end
    if alpha < 0 then
        alpha = 0
    elseif alpha > 1 then
        alpha = 1
    end
    panel:SetAlpha(alpha)
end

function ns.RefreshStepList(force)
    if not enabled() then
        if panel then
            panel:Hide()
        end
        lastGuideId, lastCurrent, lastCount, pinnedCurrent = nil, nil, nil, nil
        cachedEntries, cachedGuideId, rowsLaidOut = nil, nil, false
        return
    end

    local host = tracker()
    if not host or not host:IsShown() then
        if panel then
            panel:Hide()
        end
        return
    end

    ensurePanel()
    placePanel()

    -- Authored headers are static per guide. Cache them so tracker refreshes
    -- do not re-run authoredPresentation across every step.
    local entries, current, guideId
    if ns.db and ns.db.standaloneGuide and ns.GuideId and ns.GuideStepListCurrent then
        guideId = ns.GuideId()
        current = ns.GuideStepListCurrent()
        if cachedEntries and cachedGuideId == guideId then
            entries = cachedEntries
        end
    end

    if not entries then
        entries, current, guideId = collectEntries()
        if entries and guideId then
            cachedEntries = entries
            cachedGuideId = guideId
        end
    end

    if not entries or #entries < 1 then
        panel:Hide()
        return
    end

    local count = #entries
    local rebuilt = guideId ~= lastGuideId or count ~= lastCount or not rowsLaidOut
    local currentChanged = current ~= lastCurrent
    local previousCurrent = lastCurrent
    lastGuideId = guideId
    lastCurrent = current
    lastCount = count
    pinnedCurrent = current

    local restyle = force or not painted
    if restyle then
        stylePanel()
        painted = true
    end

    -- Cheap path: same guide, only the active step moved.
    if not rebuilt and currentChanged and rowsLaidOut then
        if type(previousCurrent) == "number" and rows[previousCurrent] then
            paintRow(rows[previousCurrent], current, false)
        end
        if type(current) == "number" and rows[current] then
            paintRow(rows[current], current, false)
        end
        scrollToCurrent(current)
        panel:Show()
        local hostAlpha = host:GetAlpha()
        if type(hostAlpha) == "number" then
            panel:SetAlpha(hostAlpha)
        end
        return
    end

    -- force/restyle alone must not rebuild every row; that was a combat hitch
    -- whenever objective text dirtied the tracker with force=false but
    -- contentChanged was treated as force upstream.
    if not rebuilt and not currentChanged then
        panel:Show()
        local hostAlpha = host:GetAlpha()
        if type(hostAlpha) == "number" then
            panel:SetAlpha(hostAlpha)
        end
        return
    end

    local width = (panel:GetWidth() or host:GetWidth() or 300) - (PAD * 2) - 4
    if width < 40 then
        width = 40
    end
    body:SetWidth(width)
    body:SetHeight(math.max(ROW, count * ROW))

    for index = 1, count do
        local entry = entries[index]
        local row = acquireRow(index)
        if rebuilt then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -((index - 1) * ROW))
            row:SetPoint("TOPRIGHT", body, "TOPRIGHT", 0, -((index - 1) * ROW))
            row.stepIndex = entry.index
            row.tipHeader = entry.header
            row.tipDetails = entry.details
            row.quests = entry.quests
            row.number:SetText(tostring(entry.index))
            row.header:SetText(entry.header or "")
        end
        paintRow(row, current, restyle or rebuilt)
        row:Show()
    end
    for index = count + 1, #rows do
        rows[index]:Hide()
    end
    rowsLaidOut = true

    panel:Show()
    -- Re-pin the current step to the top when the guide or step changes,
    -- not on every tracker restyle (that would fight manual scrolling).
    if rebuilt or currentChanged then
        scrollToCurrent(current)
    else
        updateScrollThumb()
    end

    local hostAlpha = host:GetAlpha()
    if type(hostAlpha) == "number" then
        panel:SetAlpha(hostAlpha)
    end
end

-- Keep the list tied to tracker show/hide and theme restyles.
local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    local host = tracker()
    if not host then
        return
    end
    host:HookScript("OnShow", function()
        if ns.RefreshStepList then
            ns.RefreshStepList(true)
        end
    end)
    host:HookScript("OnHide", function()
        if panel then
            panel:Hide()
        end
    end)
    if host:IsShown() and ns.RefreshStepList then
        ns.RefreshStepList(true)
    end
end)
