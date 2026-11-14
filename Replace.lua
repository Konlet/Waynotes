local addonName, ns = ...

-- Tracker UI. Guide/RXP helpers live in ReplaceGuide.lua (ns.RG) so this
-- chunk stays under Lua 5.1's 200-local limit.

local RG = ns.RG
local State = ns.ReplaceState

local UI = {
    COLUMN = 26,
    TRACKER_WIDTH = 300,
    MORE_TIP_THRESHOLD = 2,
    HEADER_RIGHT = -144,
    HEADER_BOTTOM = 27,
    WHITE = "Interface\\BUTTONS\\WHITE8X8",
    FLIGHT_STRIP = 26,
    NAV_STRIP = 28,
    ARROW_TEXTURE = nil,
    ARROW_COLUMN = 48,
    PROGRESS_BAR_HEIGHT = 6,
    PROGRESS_BAR_GAP = 2,
    TRACKER_CHROME = 44,
    MIN_TRACKER_WIDTH = 220,
    MAX_TRACKER_WIDTH = 640,
    MIN_TRACKER_HEIGHT = 120,
    MAX_TRACKER_HEIGHT = 800,
    MEDIA = { ringPad = 2, ringThickness = 2, cornerPad = 2, circlePad = 4, circleSize = 128 },
    GUIDE_TAG_COLORS = {
        RB_FRIENDLY_ = "FF00FF25",
        RB_ENEMY_ = "FFFF5722",
        RB_LOOT_ = "FF00BCD4",
        RB_WARN_ = "FFFCDC00",
        RB_PICK_ = "FFDB2EEF",
        RB_BUY_ = "FF0E8312",
        RB_QUEST_ = "FFFFD100",
    },
}

State.lastSignature = nil
State.mouseBusy = false
State.alphaBusy = false
State.buttonBusy = false
State.parked = {}
State.hookedMouse = {}
State.rows = {}
State.sizeKey = ""
State.remeasure = false
State.pointRestored = false
State.expandedTips = {}
State.chromeHooked = {}
State.cogBusy = false
State.cogHome = nil
State.satelliteHooked = {}
State.standaloneWas = false
State.hardcoreWas = false
State.elapsed = 0
State.flight = { chrome = 0 }
State.nav = { chrome = 0 }
State.mapPins = { frames = {}, signature = nil }


local tracker = CreateFrame("Frame", "WaynotesTracker", UIParent, "BackdropTemplate")
tracker:SetSize(UI.TRACKER_WIDTH, 72)
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
header:SetPoint("TOPRIGHT", UI.HEADER_RIGHT, -7)
header:SetHeight(16)
RG.paint(header, 13, ns.Color("accent"))
if header.SetMaxLines then
    header:SetMaxLines(1)
end
if header.SetWordWrap then
    header:SetWordWrap(false)
end

local guidePercent
local jumpButton
local navButton
local settingsButton
local function guidePercentLabel()
    if ns.db and ns.db.standaloneGuide and ns.GuidePercentLabel then
        return ns.GuidePercentLabel()
    end
    if not (ns.db and ns.db.showGuidePercent) then
        return nil
    end
    local guide = RG.currentGuide()
    local steps = guide and guide.steps
    local total = type(steps) == "table" and #steps or 0
    if total < 1 then
        return nil
    end
    local current = tonumber(_G.RXPCData and _G.RXPCData.currentStep)
    if not current then
        local step = RG.primaryStep()
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
        header:SetPoint("TOPRIGHT", UI.HEADER_RIGHT, -7)
        return
    end
    local r, g, b = ns.Color("accent")
    RG.paint(guidePercent, 12, r, g, b)
    guidePercent:SetText(label)
    guidePercent:Show()
    guidePercent:ClearAllPoints()
    local rightOf = navButton or jumpButton
    if rightOf then
        guidePercent:SetPoint("TOPRIGHT", rightOf, "TOPLEFT", -6, 1)
    else
        guidePercent:SetPoint("TOPRIGHT", UI.HEADER_RIGHT, -7)
    end
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", 10, -7)
    header:SetPoint("TOPRIGHT", guidePercent, "TOPLEFT", -6, 0)
end

-- Keep pad/size knobs on one table so this chunk stays under Lua's 200-local limit.

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
    texture:SetTexture(UI.WHITE)
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

UI.ARROW_TEXTURE = media("arrow.tga")

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
    local inset = UI.MEDIA.cornerPad / (radius + UI.MEDIA.cornerPad * 2)
    texture:SetTexture(media("corner-" .. radius .. ".tga"))
    texture.__rxpbSolid = nil
    local u0, u1 = texSpan(left, right, inset)
    local v0, v1 = texSpan(top, bottom, inset)
    texture:SetTexCoord(u0, u1, v0, v1)
end

local function setCircleTexture(texture)
    local inset = UI.MEDIA.circlePad / (UI.MEDIA.circleSize + UI.MEDIA.circlePad * 2)
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
    if not file or file == UI.WHITE then
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
    local ringInset = UI.MEDIA.ringPad / (radius + UI.MEDIA.ringPad * 2)
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

    local thick = UI.MEDIA.ringThickness
    if thick < 1 then
        thick = 1
    end
    local overlap = thick
    local gapW = width - (radius * 2)
    local gapH = height - (radius * 2)
    if gapW >= 1 then
        plate.t:ClearAllPoints()
        plate.t:SetPoint("TOPLEFT", anchor, "TOPLEFT", radius - overlap, 0)
        plate.t:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -(radius - overlap), 0)
        plate.t:SetHeight(thick)
        plate.t:Show()
        plate.b:ClearAllPoints()
        plate.b:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", radius - overlap, 0)
        plate.b:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -(radius - overlap), 0)
        plate.b:SetHeight(thick)
        plate.b:Show()
    else
        plate.t:Hide()
        plate.b:Hide()
    end
    if gapH >= 1 then
        plate.l:ClearAllPoints()
        plate.l:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -(radius - overlap))
        plate.l:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, radius - overlap)
        plate.l:SetWidth(thick)
        plate.l:Show()
        plate.r:ClearAllPoints()
        plate.r:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 0, -(radius - overlap))
        plate.r:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, radius - overlap)
        plate.r:SetWidth(thick)
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
        button.edgePlate = makePlate(button, "BACKGROUND", 1)
        button.fillPlate = makePlate(button, "BACKGROUND", 2)
        button.__rxpbDualFill = true
    elseif not button.__rxpbDualFill then
        for index = 1, #button.edgePlate.list do
            setLayer(button.edgePlate.list[index], "BACKGROUND", 1)
        end
        for index = 1, #button.fillPlate.list do
            setLayer(button.fillPlate.list[index], "BACKGROUND", 2)
        end
        button.__rxpbDualFill = true
    end
    local radius = math.floor((button:GetHeight() or 16) / 2)
    if radius < 4 then
        radius = 4
    elseif radius > 16 then
        radius = 16
    end
    local thick = UI.MEDIA.ringThickness
    if thick < 1 then
        thick = 1
    end
    local innerRadius = radius - thick
    if innerRadius < 0 then
        innerRadius = 0
    end

    showPlate(button.edgePlate, button, 0, 0, 0, 0, radius)
    paintPlate(button.edgePlate, edgeR, edgeG, edgeB, edgeA)

    showPlate(button.fillPlate, button, thick, thick, thick, thick, innerRadius)
    -- Dual-fill needs an opaque inner plate so edge color does not bleed through.
    local fr, fg, fb, fa = fillR, fillG, fillB, fillA or 1
    if fa < 0.999 then
        local br, bg, bb = ns.Color("background")
        local panelA = ns.db and ns.db.trackerBackground
        if type(panelA) ~= "number" then
            panelA = 0.4
        end
        br, bg, bb = br * panelA, bg * panelA, bb * panelA
        local keep = 1 - fa
        fr, fg, fb = fr * fa + br * keep, fg * fa + bg * keep, fb * fa + bb * keep
        fa = 1
    end
    paintPlate(button.fillPlate, fr, fg, fb, fa)

    button:SetBackdropColor(0, 0, 0, 0)
    button:SetBackdropBorderColor(0, 0, 0, 0)
end

local shadowHost = CreateFrame("Frame", nil, UIParent)
shadowHost:SetFrameStrata("LOW")
shadowHost:EnableMouse(false)
shadowHost:Hide()

local headerBar = makeTexture(tracker, "BACKGROUND", 2, UI.WHITE)
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
        local step = RG.primaryStep()
        if not step then
            return
        end
        if self.direction < 0 then
            RG.goBackward()
        else
            RG.goToStep(step.index + 1)
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
    local step = RG.primaryStep()
    if not step then
        return false
    end
    if button.direction < 0 then
        return RG.earlierStep(RG.currentGuide(), step.index) ~= nil
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
    if navButton then
        navButton.text:SetTextColor(r, g, b)
        if navButton.hovered then
            styleChromeButton(navButton, r, g, b, 0.22, r, g, b, 1)
        else
            styleChromeButton(navButton, 0, 0, 0, 0.55, r, g, b, 0.75)
        end
    end
    if settingsButton then
        local standalone = ns.db and ns.db.standaloneGuide
        if standalone then
            settingsButton:Show()
            if settingsButton.icon then
                settingsButton.icon:SetVertexColor(r, g, b, 1)
            end
            if settingsButton.hovered then
                styleChromeButton(settingsButton, r, g, b, 0.22, r, g, b, 1)
            else
                styleChromeButton(settingsButton, 0, 0, 0, 0.55, r, g, b, 0.75)
            end
        else
            settingsButton:Hide()
        end
    end
    stylingButtons = false
end

createStepButton(-1, -42)
createStepButton(1, -24)

settingsButton = CreateFrame("Button", nil, tracker, "BackdropTemplate")
settingsButton:SetSize(16, 16)
settingsButton:SetPoint("TOPRIGHT", -4, -6)
settingsButton:SetFrameLevel(tracker:GetFrameLevel() + 25)
settingsButton:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local settingsGlow = settingsButton:CreateTexture(nil, "HIGHLIGHT")
settingsGlow:SetAllPoints()
useSolid(settingsGlow)
paintTexture(settingsGlow, 1, 1, 1, 0.14)
settingsButton.glow = settingsGlow
settingsButton:RegisterForClicks("LeftButtonUp")
settingsButton.icon = settingsButton:CreateTexture(nil, "OVERLAY")
settingsButton.icon:SetSize(12, 12)
settingsButton.icon:SetPoint("CENTER", 0, 0)
settingsButton.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
settingsButton:SetScript("OnClick", function()
    if ns.HideGuideMenu then
        ns.HideGuideMenu()
    end
    if ns.HideNavMenu then
        ns.HideNavMenu()
    end
    if ns.OpenOptions then
        ns.OpenOptions()
    end
end)
settingsButton:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Options", r, g, b)
    GameTooltip:AddLine("Open Waynotes settings.", 1, 1, 1, true)
    ns.FinishTooltip()
end)
settingsButton:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
settingsButton:SetScript("OnMouseDown", function(self)
    self.icon:SetPoint("CENTER", 1, -1)
end)
settingsButton:SetScript("OnMouseUp", function(self)
    self.icon:SetPoint("CENTER", 0, 0)
end)

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
RG.applyFont(jumpButton.text, 10, "OUTLINE")
jumpButton.text:SetText("Jump")
jumpButton:SetScript("OnClick", function()
    if StaticPopup_Show then
        StaticPopup_Show("WaynotesJump")
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

navButton = CreateFrame("Button", nil, tracker, "BackdropTemplate")
navButton:SetSize(28, 16)
navButton:SetPoint("TOPRIGHT", -110, -6)
navButton:SetFrameLevel(tracker:GetFrameLevel() + 25)
navButton:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local navGlow = navButton:CreateTexture(nil, "HIGHLIGHT")
navGlow:SetAllPoints()
useSolid(navGlow)
paintTexture(navGlow, 1, 1, 1, 0.14)
navButton.glow = navGlow
navButton:RegisterForClicks("LeftButtonUp")
navButton.text = navButton:CreateFontString(nil, "OVERLAY")
navButton.text:SetPoint("CENTER", 0, 0)
RG.applyFont(navButton.text, 10, "OUTLINE")
navButton.text:SetText("Go")
navButton:SetScript("OnClick", function(self)
    if ns.ToggleNavMenu then
        ns.ToggleNavMenu(self)
    end
end)
navButton:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Navigate", r, g, b)
    GameTooltip:AddLine("Find the nearest inn, bank, trainer, and more.", 1, 1, 1, true)
    ns.FinishTooltip()
end)
navButton:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
navButton:SetScript("OnMouseDown", function(self)
    self.text:SetPoint("CENTER", 1, -1)
end)
navButton:SetScript("OnMouseUp", function(self)
    self.text:SetPoint("CENTER", 0, 0)
end)

guidePercent = tracker:CreateFontString(nil, "OVERLAY")
guidePercent:SetHeight(16)
guidePercent:SetJustifyH("RIGHT")
guidePercent:SetJustifyV("MIDDLE")
if guidePercent.SetWordWrap then
    guidePercent:SetWordWrap(false)
end
RG.applyFont(guidePercent, 12, "OUTLINE")
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
body:SetSize(UI.TRACKER_WIDTH - 16, 20)
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
RG.paint(empty, 13, 0.85, 0.85, 0.85)
empty:SetText("Right-click to choose a guide")
empty:Hide()

local divider = body:CreateTexture(nil, "ARTWORK")
divider:SetHeight(1)
useSolid(divider)
paintTexture(divider, 1, 1, 1, 0.16)
divider:Hide()

local updateFlightStrip
local updateNavStrip
local placeBottomChrome

do
    local strip = CreateFrame("Frame", nil, tracker)
    strip:SetHeight(UI.FLIGHT_STRIP)
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
    RG.applyFont(destText, 11, "")
    destText:SetTextColor(0.9, 0.9, 0.86)

    local timeText = strip:CreateFontString(nil, "OVERLAY")
    timeText:SetPoint("TOPRIGHT", -10, -4)
    timeText:SetHeight(12)
    timeText:SetJustifyH("RIGHT")
    timeText:SetJustifyV("MIDDLE")
    RG.applyFont(timeText, 11, "OUTLINE")
    timeText:SetTextColor(1, 0.82, 0)

    State.flight.strip = strip
    State.flight.rule = flightRule
    State.flight.track = track
    State.flight.trackBg = trackBg
    State.flight.fill = trackFill
    State.flight.dest = destText
    State.flight.time = timeText

    local state = {
        pending = false,
        flying = false,
        route = nil,
        nodeIds = nil,
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

    placeBottomChrome = function()
        local bottom = 10 + (State.flight.chrome or 0) + (State.nav.chrome or 0)
        placeScroller(bottom)
        if State.nav.layout then
            State.nav.layout()
        end
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

    local function matchNodeId(taxiName)
        if ns.MatchFlightNodeId then
            return ns.MatchFlightNodeId(taxiName)
        end
    end

    local function nodePathKey(nodeIds)
        if type(nodeIds) ~= "table" or #nodeIds < 2 then
            return nil
        end
        return "n:" .. table.concat(nodeIds, ":")
    end

    local function buildRoute(destIndex)
        local current = currentTaxiNode()
        if not current or type(destIndex) ~= "number" then
            return
        end
        local keys = {}
        local names = {}
        local nodeIds = {}
        local function add(index)
            local taxiName = TaxiNodeName(index)
            keys[#keys + 1] = taxiNodeKey(index) or ("#" .. index)
            names[#names + 1] = shortTaxiName(taxiName) or ("Node " .. index)
            local nodeId = matchNodeId(taxiName)
            if nodeId and nodeIds[#nodeIds] ~= nodeId then
                nodeIds[#nodeIds + 1] = nodeId
            end
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
        if #nodeIds < 2 then
            local fromId = matchNodeId(TaxiNodeName(current))
            local toId = matchNodeId(TaxiNodeName(destIndex))
            if fromId and toId and fromId ~= toId then
                nodeIds = { fromId, toId }
            end
        end
        return continentKey() .. "|" .. route, names[1], names[#names], nodeIds
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

    local function blendSeconds(previous, seconds)
        if type(previous) == "number" and previous > 0 then
            return math.floor((previous * 0.65) + (seconds * 0.35) + 0.5)
        end
        return seconds
    end

    local function savedDuration(route, nodeIds)
        local db = timesDB()
        if db then
            local value = route and db[route]
            if type(value) == "number" and value > 0 then
                return value
            end
            local nodeKey = nodePathKey(nodeIds)
            value = nodeKey and db[nodeKey]
            if type(value) == "number" and value > 0 then
                return value
            end
        end
        if ns.DefaultFlightSeconds then
            local defaults = ns.DefaultFlightSeconds(nodeIds)
            if type(defaults) == "number" and defaults > 0 then
                return math.floor(defaults + 0.5)
            end
        end
    end

    local function rememberDuration(route, seconds, nodeIds)
        if type(seconds) ~= "number" then
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
        if route then
            db[route] = blendSeconds(db[route], seconds)
        end
        local nodeKey = nodePathKey(nodeIds)
        if nodeKey then
            db[nodeKey] = blendSeconds(db[nodeKey], seconds)
        end
    end

    local function formatClock(seconds)
        seconds = math.max(0, math.floor((seconds or 0) + 0.5))
        return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
    end

    local function setChrome(want)
        want = want or 0
        if State.flight.chrome == want then
            return
        end
        State.flight.chrome = want
        placeBottomChrome()
        State.remeasure = true
        State.lastSignature = nil
        if tracker:IsShown() and ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end

    local function showStrip(on)
        if on then
            strip:Show()
            setChrome(UI.FLIGHT_STRIP)
        else
            strip:Hide()
            setChrome(0)
        end
    end

    local function resetState()
        state.pending = false
        state.flying = false
        state.route = nil
        state.nodeIds = nil
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

    State.flight.paint = paintFlight

    local watcher
    function updateFlightStrip()
        local onTaxi = UnitOnTaxi and UnitOnTaxi("player")
        if state.pending then
            if onTaxi then
                state.pending = false
                state.flying = true
                state.started = GetTime()
                state.duration = state.duration or savedDuration(state.route, state.nodeIds)
                if watcher then
                    watcher:Show()
                end
            elseif (GetTime() - (state.armed or 0)) > 8 then
                resetState()
            end
        elseif state.flying then
            if not onTaxi then
                if state.started and (state.route or state.nodeIds) then
                    rememberDuration(state.route, GetTime() - state.started, state.nodeIds)
                end
                resetState()
            end
        elseif onTaxi then
            state.flying = true
            state.started = GetTime()
            state.destName = state.destName or "Flight path"
            state.duration = savedDuration(state.route, state.nodeIds)
            if watcher then
                watcher:Show()
            end
        end

        local showUI = tracker:IsShown() and ns.db and ns.db.showFlightTimer ~= false and state.flying
        if not showUI then
            if State.flight.chrome > 0 then
                showStrip(false)
            end
            return
        end

        showStrip(true)
        local flown = GetTime() - (state.started or GetTime())
        destText:SetText(state.destName or "Flight path")
        if state.duration and state.duration > 0 then
            local left = state.duration - flown
            if left < 0 then
                left = 0
            end
            timeText:SetText(formatClock(left))
            local width = track:GetWidth() or 1
            if width < 1 then
                width = 1
            end
            local ratio = flown / state.duration
            if ratio < 0 then
                ratio = 0
            elseif ratio > 1 then
                ratio = 1
            end
            trackFill:SetWidth(math.max(1, width * ratio))
            trackFill:Show()
        else
            timeText:SetText(formatClock(flown))
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
            local route, _, destName, nodeIds = buildRoute(node)
            state.pending = true
            state.flying = false
            state.route = route
            state.nodeIds = nodeIds
            state.destName = destName or shortTaxiName(TaxiNodeName(node)) or "Flight path"
            state.started = nil
            state.duration = savedDuration(route, nodeIds)
            state.armed = GetTime()
            watcher:Show()
        end)
    end
end

do
    local strip = CreateFrame("Frame", nil, tracker)
    strip:SetHeight(UI.NAV_STRIP)
    strip:SetPoint("BOTTOMLEFT", 1, 1)
    strip:SetPoint("BOTTOMRIGHT", -1, 1)
    strip:Hide()

    local navRule = strip:CreateTexture(nil, "ARTWORK")
    navRule:SetPoint("TOPLEFT", 8, 0)
    navRule:SetPoint("TOPRIGHT", -8, 0)
    navRule:SetHeight(1)
    useSolid(navRule)
    paintTexture(navRule, 1, 0.82, 0, 0.45)

    local arrow = strip:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(14, 14)
    arrow:SetPoint("LEFT", 8, -1)
    arrow:SetTexture(media("arrow.tga"))
    arrow:SetDrawLayer("OVERLAY", 2)

    local title = strip:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 26, -3)
    title:SetPoint("RIGHT", strip, "RIGHT", -78, 0)
    title:SetHeight(12)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")
    if title.SetWordWrap then
        title:SetWordWrap(false)
    end
    RG.applyFont(title, 11, "")
    title:SetTextColor(0.9, 0.9, 0.86)

    local detail = strip:CreateFontString(nil, "OVERLAY")
    detail:SetPoint("TOPLEFT", 26, -14)
    detail:SetPoint("RIGHT", strip, "RIGHT", -78, 0)
    detail:SetHeight(11)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("MIDDLE")
    if detail.SetWordWrap then
        detail:SetWordWrap(false)
    end
    RG.applyFont(detail, 10, "")
    detail:SetTextColor(0.82, 0.82, 0.82)

    local distText = strip:CreateFontString(nil, "OVERLAY")
    distText:SetPoint("TOPRIGHT", -28, -4)
    distText:SetHeight(12)
    distText:SetJustifyH("RIGHT")
    distText:SetJustifyV("MIDDLE")
    RG.applyFont(distText, 11, "OUTLINE")
    distText:SetTextColor(1, 0.82, 0)

    local clear = CreateFrame("Button", nil, strip)
    clear:SetSize(16, 16)
    clear:SetPoint("TOPRIGHT", -8, -5)
    clear:SetFrameLevel(strip:GetFrameLevel() + 5)
    clear:RegisterForClicks("LeftButtonUp")
    clear.text = clear:CreateFontString(nil, "OVERLAY")
    clear.text:SetPoint("CENTER", 0, 0)
    RG.applyFont(clear.text, 12, "OUTLINE")
    clear.text:SetText("x")
    clear:SetScript("OnClick", function()
        if ns.NavClearTarget then
            ns.NavClearTarget()
        end
    end)
    clear:SetScript("OnEnter", function(self)
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Clear destination", r, g, b)
        ns.FinishTooltip()
    end)
    clear:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    State.nav.strip = strip
    State.nav.rule = navRule
    State.nav.arrow = arrow
    State.nav.title = title
    State.nav.detail = detail
    State.nav.dist = distText
    State.nav.clear = clear

    State.nav.layout = function()
        local lift = State.flight.chrome or 0
        strip:ClearAllPoints()
        strip:SetPoint("BOTTOMLEFT", 1, 1 + lift)
        strip:SetPoint("BOTTOMRIGHT", -1, 1 + lift)
    end

    local function setNavChrome(want)
        want = want or 0
        if State.nav.chrome == want then
            return
        end
        State.nav.chrome = want
        if placeBottomChrome then
            placeBottomChrome()
        end
        State.remeasure = true
        State.lastSignature = nil
        if tracker:IsShown() and ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end

    local function showNav(on)
        if on then
            strip:Show()
            setNavChrome(UI.NAV_STRIP)
        else
            strip:Hide()
            setNavChrome(0)
        end
    end

    local painted = false
    local lastTitle, lastDetail, lastDist

    local function paintNav(force)
        if not ns.db then
            return
        end
        if painted and not force then
            return
        end
        painted = true
        local edgeR, edgeG, edgeB = ns.Color("accent")
        local textR, textG, textB = ns.Color("secondary")
        local detailR, detailG, detailB = ns.Color("detail")
        paintTexture(navRule, edgeR, edgeG, edgeB, 0.45)
        title:SetTextColor(textR, textG, textB)
        detail:SetTextColor(detailR, detailG, detailB)
        distText:SetTextColor(edgeR, edgeG, edgeB)
        clear.text:SetTextColor(edgeR, edgeG, edgeB)
        if arrow.SetDesaturated then
            arrow:SetDesaturated(true)
        end
        arrow:SetVertexColor(edgeR, edgeG, edgeB, 0)
        arrow:SetVertexColor(edgeR, edgeG, edgeB, 1)
    end

    State.nav.paint = function()
        painted = false
        paintNav(true)
    end

    local function kindLabel(dest)
        if not dest then
            return "Destination"
        end
        if dest.kind == "trainer" and dest.class then
            return dest.class .. " Trainer"
        end
        if ns.NavKindLabel and dest.kind and ns.NavKindLabel[dest.kind] then
            return ns.NavKindLabel[dest.kind]
        end
        return "Destination"
    end

    local function ensureWaypoint(dest)
        if type(dest) ~= "table" then
            return nil
        end
        if ns.PinToPlayerWorld and type(dest.x) == "number" and type(dest.y) == "number" then
            local wx, wy, instance = ns.PinToPlayerWorld(dest.map, dest.x, dest.y, dest.zone)
            if type(wx) == "number" and type(wy) == "number" then
                dest.waypoint = { wx = wx, wy = wy, instance = instance }
                return dest.waypoint
            end
        end
        local hbd = RG.hereBeDragons()
        local function zoneToWorld(map, x, y)
            if not hbd or not hbd.GetWorldCoordinatesFromZone or type(map) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
                return nil
            end
            local zx, zy = x, y
            if zx > 1 or zy > 1 then
                zx, zy = zx / 100, zy / 100
            end
            local wx, wy, instance = hbd:GetWorldCoordinatesFromZone(zx, zy, map)
            if type(wx) == "number" and type(wy) == "number" then
                return wx, wy, instance
            end
            return nil
        end

        local px, py, pinstance
        if hbd and hbd.GetPlayerWorldPosition then
            px, py, pinstance = hbd:GetPlayerWorldPosition()
        end
        local pzx, pzy, pmap
        if hbd and hbd.GetPlayerZonePosition then
            local ok, x, y, map = pcall(hbd.GetPlayerZonePosition, hbd, true)
            if ok and type(x) == "number" and type(map) == "number" then
                pzx, pzy, pmap = x, y, map
            end
        end

        local sameZone = type(dest.map) == "number" and dest.map == pmap
        if not sameZone and type(dest.zone) == "string" and GetRealZoneText then
            local a = dest.zone:lower():gsub("^the%s+", "")
            local b = tostring(GetRealZoneText() or ""):lower():gsub("^the%s+", "")
            sameZone = a ~= "" and b ~= "" and (a == b or a:find(b, 1, true) or b:find(a, 1, true))
        end

        -- Same-zone: rebuild every refresh in UnitPosition space. Forever's
        -- UiMap zone→world origin disagrees with UnitPosition, so a cached
        -- absolute convert stays ~500 yd wrong even when standing on the NPC.
        if sameZone and type(pmap) == "number" and type(pzx) == "number" and type(px) == "number" and type(dest.x) == "number" then
            local playerWx, playerWy = zoneToWorld(pmap, pzx, pzy)
            local pinWx, pinWy = zoneToWorld(pmap, dest.x, dest.y)
            if not pinWx and type(dest.map) == "number" then
                pinWx, pinWy = zoneToWorld(dest.map, dest.x, dest.y)
                playerWx, playerWy = zoneToWorld(dest.map, pzx, pzy)
            end
            if type(playerWx) == "number" and type(pinWx) == "number" then
                dest.waypoint = {
                    wx = px + (pinWx - playerWx),
                    wy = py + (pinWy - playerWy),
                    instance = pinstance,
                }
                return dest.waypoint
            end
        end

        local wp = dest.waypoint
        if type(wp) == "table" and type(wp.wx) == "number" and type(wp.wy) == "number" then
            return wp
        end

        local wx, wy, instance = zoneToWorld(pmap or dest.map, dest.x, dest.y)
        if type(wx) ~= "number" then
            wx, wy, instance = zoneToWorld(dest.map, dest.x, dest.y)
        end
        if type(wx) == "number" then
            dest.waypoint = { wx = wx, wy = wy, instance = instance }
            return dest.waypoint
        end

        if type(dest.wx) == "number" and type(dest.wy) == "number" then
            dest.waypoint = { wx = dest.wx, wy = dest.wy, instance = dest.instance }
            return dest.waypoint
        end
        return nil
    end

    function updateNavStrip()
        local dest = ns.NavTarget and ns.NavTarget()
        local showUI = tracker:IsShown() and dest ~= nil
        if not showUI then
            arrow.__rxpbWp = nil
            if State.nav.chrome > 0 then
                showNav(false)
            end
            lastTitle, lastDetail, lastDist = nil, nil, nil
            return
        end

        if State.nav.chrome == 0 then
            showNav(true)
            paintNav(true)
        elseif not strip:IsShown() then
            strip:Show()
        end

        local where = dest.zone or (dest.map and ns.MapName and ns.MapName(dest.map)) or ""
        local name = dest.name or kindLabel(dest)
        local titleText = kindLabel(dest) .. " · " .. name
        if titleText ~= lastTitle then
            lastTitle = titleText
            title:SetText(titleText)
        end

        local coords = ns.NavFormatCoords and ns.NavFormatCoords(dest) or ""
        local detailText
        if where ~= "" and coords ~= "" then
            detailText = where .. "  " .. coords
        elseif coords ~= "" then
            detailText = coords
        else
            detailText = where
        end
        if detailText ~= lastDetail then
            lastDetail = detailText
            detail:SetText(detailText)
        end

        -- Aiming + distance are handled in updateArrows via __rxpbWp.
        arrow.__rxpbWp = ensureWaypoint(dest)
    end

    -- Filled after formatYards/tintArrow exist (same file, later locals).
    State.nav._arrow = arrow
    State.nav._distText = distText
    State.nav._getLastDist = function()
        return lastDist
    end
    State.nav._setLastDist = function(value)
        lastDist = value
    end

    ns.NavOnTargetChanged = function()
        painted = false
        lastTitle, lastDetail, lastDist = nil, nil, nil
        if tracker:IsShown() then
            updateNavStrip()
        end
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
            bgFile = UI.WHITE,
            edgeFile = UI.WHITE,
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    else
        tracker:SetBackdrop({
            bgFile = UI.WHITE,
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

    RG.paint(header, 13, edgeR, edgeG, edgeB)
    if guidePercent then
        RG.paint(guidePercent, 12, edgeR, edgeG, edgeB)
    end
    paintTexture(rule, edgeR, edgeG, edgeB, 0.55)
    if State.flight.paint then
        State.flight.paint()
    end
    if State.nav.paint then
        State.nav.paint()
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
            showHeader(panelHeader, tracker, 0, 0, 0, UI.HEADER_BOTTOM, radius)
            paintPlate(panelHeader, hr, hg, hb, ha)
            headerBar:Hide()
        else
            hidePlate(panelHeader)
            local inset = borderOn and 1 or 0
            headerBar:ClearAllPoints()
            headerBar:SetPoint("TOPLEFT", tracker, "TOPLEFT", inset, -inset)
            headerBar:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -inset, -inset)
            headerBar:SetHeight(math.max(1, UI.HEADER_BOTTOM - inset))
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

    if ns.StyleRegisteredPopups then
        ns.StyleRegisteredPopups()
    end
end

local styledPopups = {}

local function usePopupBackdrop(frame, chrome, mode)
    if chrome.mode == mode then
        return
    end
    chrome.mode = mode
    if mode == "none" then
        frame:SetBackdrop(nil)
    elseif mode == "border" then
        frame:SetBackdrop({
            bgFile = UI.WHITE,
            edgeFile = UI.WHITE,
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    else
        frame:SetBackdrop({
            bgFile = UI.WHITE,
        })
    end
end

local function ensurePopupChrome(frame)
    local chrome = frame.__waynotesChrome
    if chrome then
        return chrome
    end
    chrome = {
        fill = makePlate(frame, "BACKGROUND", 1),
        border = makePlate(frame, "BORDER", 1),
        mode = nil,
    }
    chrome.shadowHost = CreateFrame("Frame", nil, UIParent)
    chrome.shadowHost:Hide()
    chrome.shadow = makePlate(chrome.shadowHost, "ARTWORK", 1)
    if not frame.__waynotesChromeHideHook then
        frame.__waynotesChromeHideHook = true
        frame:HookScript("OnHide", function()
            local stored = frame.__waynotesChrome
            if stored and stored.shadowHost then
                stored.shadowHost:Hide()
            end
        end)
    end
    frame.__waynotesChrome = chrome
    styledPopups[#styledPopups + 1] = frame
    return chrome
end

function ns.StylePopupFrame(frame)
    if not frame or not ns.db then
        return
    end
    local chrome = ensurePopupChrome(frame)
    local background = ns.db.trackerBackground
    if type(background) ~= "number" then
        background = 0.4
    end
    local panelR, panelG, panelB = ns.Color("background")
    local edgeR, edgeG, edgeB = ns.Color("accent")
    local edgeA = math.max(0.25, math.min(0.85, background + 0.2))
    local borderAlpha = ns.db.borderAlpha
    if type(borderAlpha) == "number" then
        edgeA = edgeA * math.max(0, math.min(1, borderAlpha))
    end
    local rounded = ns.db.roundedEdges and true or false
    local borderOn = ns.db.trackerBorder and true or false
    local radius = 0
    if rounded then
        radius = clampCornerRadius(ns.db.cornerRadius or 8)
    end

    if rounded then
        usePopupBackdrop(frame, chrome, "none")
        showPlate(chrome.fill, frame, 0, 0, 0, 0, radius)
        paintPlate(chrome.fill, panelR, panelG, panelB, background)
        if borderOn then
            showBorder(chrome.border, frame, radius)
            paintPlate(chrome.border, edgeR, edgeG, edgeB, edgeA)
        else
            hidePlate(chrome.border)
        end
    else
        hidePlate(chrome.fill)
        hidePlate(chrome.border)
        usePopupBackdrop(frame, chrome, borderOn and "border" or "plain")
        frame:SetBackdropColor(panelR, panelG, panelB, background)
        if borderOn then
            frame:SetBackdropBorderColor(edgeR, edgeG, edgeB, edgeA)
        end
    end

    if ns.db.trackerShadow and frame:IsShown() then
        local spread = 8
        local drop = 4
        local parentScale = UIParent:GetEffectiveScale() or 1
        local frameScale = frame:GetEffectiveScale() or parentScale
        if parentScale == 0 then
            parentScale = 1
        end
        local host = chrome.shadowHost
        host:SetScale(frameScale / parentScale)
        host:SetFrameStrata(lowerStrata(frame:GetFrameStrata() or "DIALOG"))
        host:SetFrameLevel(math.max(1, (frame:GetFrameLevel() or 20) - 2))
        host:ClearAllPoints()
        host:SetPoint("TOPLEFT", frame, "TOPLEFT", -spread, spread - drop)
        host:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", spread, -(spread + drop))
        host:Show()
        showPlate(chrome.shadow, host, 0, 0, 0, 0, rounded and (radius + spread) or 0)
        paintPlate(chrome.shadow, 0, 0, 0, 0.4)
    else
        hidePlate(chrome.shadow)
        chrome.shadowHost:Hide()
    end

    return radius
end

function ns.StyleRegisteredPopups()
    for index = 1, #styledPopups do
        local frame = styledPopups[index]
        if frame and frame.IsShown and frame:IsShown() then
            ns.StylePopupFrame(frame)
        end
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
    if ns.HideNavMenu then
        ns.HideNavMenu()
    end
    if ns.db and (ns.db.standaloneGuide or ns.db.restedXPGuides) and ns.ToggleGuideMenu then
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
    GameTooltip:SetText(RG.guideTitle(), ar, ag, ab, 1, true)
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


local function arrowTint()
    local r, g, b = ns.Color("accent")
    return math.min(1, r * 0.72 + 0.28), math.min(1, g * 0.72 + 0.28), math.min(1, b * 0.72 + 0.28)
end

local function tintArrow(texture, r, g, b, alpha)
    if not texture then
        return
    end
    if texture.SetDesaturated then
        texture:SetDesaturated(true)
    end
    -- Do not poke alpha to 0 first: that flashes every frame when called from OnUpdate.
    texture:SetVertexColor(r, g, b, alpha or 1)
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

local function setArrowAlpha(texture, alpha)
    if not texture then
        return
    end
    if texture.__rxpbAlpha ~= alpha then
        texture.__rxpbAlpha = alpha
        texture:SetAlpha(alpha)
    end
end

-- Match HereBeDragons:GetWorldVector so angle - GetPlayerFacing() is relative.
local PI2 = math.pi * 2
local function facingBearing(deltaX, deltaY)
    if type(deltaX) ~= "number" or type(deltaY) ~= "number" then
        return nil
    end
    if deltaX * deltaX + deltaY * deltaY <= 1e-12 then
        return nil
    end
    local angle = math.atan2(-deltaX, deltaY)
    if angle > 0 then
        return PI2 - angle
    end
    return -angle
end

local function setArrowRotation(texture, rotation)
    if not texture or type(rotation) ~= "number" then
        return false
    end
    if texture.__rxpbRot == rotation then
        return true
    end
    texture.__rxpbRot = rotation
    -- Same arrow.tga as the header step buttons, which already use SetRotation
    -- on Forever. TomTom's SetTexCoord path is for diagonal edge-arrows and
    -- leaves an up-pointing chevron aimed the wrong way.
    if texture.SetTexCoord then
        texture:SetTexCoord(0, 1, 0, 1)
    end
    if texture.SetRotation then
        texture:SetRotation(rotation)
        return true
    end
    return false
end

local function playerZonePosForAim(hbd)
    if hbd and type(hbd.GetPlayerZonePosition) == "function" then
        local ok, x, y, map = pcall(hbd.GetPlayerZonePosition, hbd, true)
        if ok and type(x) == "number" and type(y) == "number" then
            return x, y, map
        end
    end
    -- Same C_Map fallback as Nav.lua: Forever often has yards without HBD zone pos.
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition then
        local map = C_Map.GetBestMapForUnit("player")
        if type(map) == "number" then
            local ok, pos = pcall(C_Map.GetPlayerMapPosition, map, "player")
            if ok and type(pos) == "table" then
                local x = pos.GetXY and pos:GetXY() or pos.x
                local y = pos.GetXY and select(2, pos:GetXY()) or pos.y
                if type(x) == "number" and type(y) == "number" then
                    return x, y, map
                end
            end
        end
    end
end

local function aimDeg(angle)
    if type(angle) ~= "number" then
        return nil
    end
    local degrees = angle * 180 / math.pi
    degrees = degrees % 360
    if degrees < 0 then
        degrees = degrees + 360
    end
    return degrees
end

local function aimNum(value)
    if type(value) ~= "number" then
        return "-"
    end
    return string.format("%.1f", value)
end

-- +x east, +y south on the zone map. 0 degrees is north, clockwise.
local function mapCardinal(east, south)
    if type(east) ~= "number" or type(south) ~= "number" then
        return "-"
    end
    if east * east + south * south <= 1e-12 then
        return "HERE"
    end
    local degrees = aimDeg(math.atan2(east, -south)) or 0
    local names = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
    local index = math.floor((degrees + 22.5) / 45) % 8 + 1
    return names[index]
end

-- Aim bearing for tracker arrows. Prefer same-zone percent bearing (matches the
-- yards we already show). World-space only when zone aim is unavailable.
local function aimAngle(hbd, instance, px, py, wp, place, facing)
    local angle
    local source
    local youX, youY, pinX, pinY, east, south

    if type(place) == "table" and type(place.x) == "number" and type(place.y) == "number" then
        pinX = place.x > 1 and place.x or place.x * 100
        pinY = place.y > 1 and place.y or place.y * 100
        local pzx, pzy = playerZonePosForAim(hbd)
        if type(pzx) == "number" then
            if pzx > 1 then
                pzx = pzx / 100
            end
            if type(pzy) == "number" and pzy > 1 then
                pzy = pzy / 100
            end
            youX = pzx * 100
            youY = (pzy or 0) * 100
            local dx = place.x > 1 and place.x / 100 or place.x
            local dy = place.y > 1 and place.y / 100 or place.y
            east, south = dx - pzx, dy - (pzy or 0)
            if east * east + south * south > 1e-12 then
                -- Zone y grows south. On this client zone x grows west, so east is negated.
                -- Checked with /wn aim: facing the NPC matched facingBearing(-east, -south).
                angle = facingBearing(-east, -south)
                source = "zone"
            elseif type(facing) == "number" then
                angle = facing
                source = "onpin"
            end
        end
    end

    local worldEast, worldNorth, hbdAngle
    if type(px) == "number" and wp and type(wp.wx) == "number" and type(wp.wy) == "number" then
        worldEast, worldNorth = wp.wx - px, wp.wy - py
        if hbd and type(hbd.GetWorldVector) == "function" then
            local ok, a = pcall(hbd.GetWorldVector, hbd, instance or 0, px, py, wp.wx, wp.wy)
            if ok and type(a) == "number" then
                hbdAngle = a
            end
        end
    end

    if type(angle) ~= "number" and type(hbdAngle) == "number" then
        angle = hbdAngle
        source = "hbd"
    end

    if type(angle) ~= "number" and type(worldEast) == "number" then
        angle = facingBearing(worldEast, worldNorth)
        source = "world"
    end

    ns.AimTrace = {
        source = source or "none",
        pinX = pinX,
        pinY = pinY,
        youX = youX,
        youY = youY,
        east = east,
        south = south,
        map = mapCardinal(east, south),
        bear = aimDeg(angle),
        face = aimDeg(facing),
        worldEast = worldEast,
        worldNorth = worldNorth,
        hbd = aimDeg(hbdAngle),
        zoneEN = aimDeg(facingBearing(east or 0, -(south or 0))),
        zoneNegE = aimDeg(type(east) == "number" and facingBearing(-east, -(south or 0)) or nil),
        zoneES = aimDeg(type(east) == "number" and facingBearing(east, south or 0) or nil),
        zoneSW = aimDeg(type(east) == "number" and facingBearing(-east, south or 0) or nil),
        worldEN = aimDeg(type(worldEast) == "number" and facingBearing(worldEast, worldNorth) or nil),
        worldSwap = aimDeg(type(worldEast) == "number" and facingBearing(worldNorth, worldEast) or nil),
        worldNegE = aimDeg(type(worldEast) == "number" and facingBearing(-worldEast, worldNorth) or nil),
    }

    return angle
end

local aimLogUntil = 0
local aimLogNext = 0

function ns.PrintAim()
    local trace = ns.AimTrace
    if type(trace) ~= "table" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r No aim sample yet. Show the guide arrow, then run /wn aim again.")
        return
    end
    local rot
    if type(trace.bear) == "number" and type(trace.face) == "number" then
        rot = (trace.bear - trace.face) % 360
    end
    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        "|cffce7bffWaynotes aim|r src=%s map=%s pin=%s,%s you=%s,%s face=%s bear=%s rot=%s hbd=%s",
        trace.source,
        trace.map,
        aimNum(trace.pinX), aimNum(trace.pinY),
        aimNum(trace.youX), aimNum(trace.youY),
        aimNum(trace.face), aimNum(trace.bear), aimNum(rot),
        aimNum(trace.hbd)
    ))
    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        "|cffce7bffWaynotes aim|r zone EN=%s -E=%s ES=%s SW=%s | world EN=%s swap=%s -E=%s",
        aimNum(trace.zoneEN), aimNum(trace.zoneNegE), aimNum(trace.zoneES), aimNum(trace.zoneSW),
        aimNum(trace.worldEN), aimNum(trace.worldSwap), aimNum(trace.worldNegE)
    ))
end

function ns.StartAimLog()
    aimLogUntil = (GetTime and GetTime() or 0) + 12
    aimLogNext = 0
    DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r Logging aim for 12s. Walk around the target and keep it in front of you. Paste both lines from each sample.")
end

-- Nav strip arrow shares the step-arrow aiming path (defined after tint helpers).
State.nav.syncArrow = function(facing, hbd, px, py, instance, canAim)
    local arrow = State.nav._arrow
    local distText = State.nav._distText
    if not arrow then
        return
    end
    local wp = arrow.__rxpbWp
    local lastDist = State.nav._getLastDist and State.nav._getLastDist() or nil
    if not wp or not wp.wx or not wp.wy then
        if lastDist ~= "" then
            if State.nav._setLastDist then
                State.nav._setLastDist("")
            end
            if distText then
                distText:SetText("")
            end
        end
        setArrowAlpha(arrow, 0.35)
        return
    end

    local dest = ns.NavTarget and ns.NavTarget()
    local angle = aimAngle(hbd, instance, px, py, wp, dest, facing)
    local dist = ns.NavDistance and ns.NavDistance(dest) or nil
    if type(dist) ~= "number" and dest and ns.PinZoneDistance and type(dest.x) == "number" then
        dist = ns.PinZoneDistance(dest.map, dest.x, dest.y, dest.zone)
    end

    local distLabel = type(dist) == "number" and formatYards(dist) or ""
    if distLabel ~= lastDist then
        if State.nav._setLastDist then
            State.nav._setLastDist(distLabel)
        end
        if distText then
            distText:SetText(distLabel)
        end
    end

    if type(angle) == "number" and type(facing) == "number" and setArrowRotation(arrow, angle - facing) then
        setArrowAlpha(arrow, 1)
    else
        setArrowAlpha(arrow, 0.35)
    end
end

local function waypointDistance(wp)
    if not wp or type(wp.wx) ~= "number" or type(wp.wy) ~= "number" then
        return nil
    end
    local hbd = RG.hereBeDragons()
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
    if not RG.playerOnQuest(questID) then
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
    -- Same yards as the arrow label. Raw map-world distance is an axis swap
    -- (~5150 yd on a Durotar pin) and must not override the zone measurement.
    local dist
    local place = row.place
    if place and ns.PinZoneDistance and type(place.x) == "number" and type(place.y) == "number" then
        dist = ns.PinZoneDistance(place.map, place.x, place.y, place.zone)
    end
    if type(dist) ~= "number" then
        dist = waypointDistance(row.tipWaypoint)
    end
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
    row.tipTitle = RG.plainText(item.headline)
end

local function refreshRowWaypoint(row)
    local place = row and row.place
    if type(place) ~= "table" or type(place.x) ~= "number" or type(place.y) ~= "number" then
        return row and row.arrow and row.arrow.__rxpbWp or nil
    end
    if ns.PinToPlayerWorld then
        local wx, wy, inst = ns.PinToPlayerWorld(place.map, place.x, place.y, place.zone)
        if type(wx) == "number" and type(wy) == "number" then
            local wp = { wx = wx, wy = wy, instance = inst }
            if row.arrow then
                row.arrow.__rxpbWp = wp
            end
            row.tipWaypoint = wp
            return wp
        end
    end
    return row.arrow and row.arrow.__rxpbWp or nil
end

local function rowPinDistance(row, wp, hbd, x, y, instance)
    -- Same-zone HBD/C_Map yards first. Synthetic PinToPlayerWorld coords can be
    -- percent*4000 approximations whose world length is not real yards.
    local place = row and row.place
    if place and ns.PinZoneDistance then
        local zoneDist = ns.PinZoneDistance(place.map, place.x, place.y, place.zone)
        if type(zoneDist) == "number" then
            return zoneDist
        end
    end
    if wp and type(wp.wx) == "number" and hbd and type(x) == "number" then
        if hbd.GetWorldDistance then
            local ok, dist = pcall(hbd.GetWorldDistance, hbd, instance or 0, x, y, wp.wx, wp.wy)
            if ok and type(dist) == "number" then
                return dist
            end
        end
        if hbd.GetWorldVector then
            local ok, _, dist = pcall(hbd.GetWorldVector, hbd, instance or 0, x, y, wp.wx, wp.wy)
            if ok and type(dist) == "number" then
                return dist
            end
        end
    end
end

local function playerFacing()
    local facing = GetPlayerFacing and GetPlayerFacing()
    if type(facing) ~= "number" then
        return nil
    end
    -- Some clients return [-pi, pi]; HBD bearings are [0, 2pi).
    if facing < 0 then
        facing = facing + PI2
    end
    return facing
end

local function updateArrows()
    if not ns.db or not tracker:IsShown() or (not ns.db.standaloneGuide and not ns.db.replaceGuide) then
        return
    end
    local facing = playerFacing()
    local hbd = RG.hereBeDragons()
    local x, y, instance
    if hbd and hbd.GetPlayerWorldPosition then
        x, y, instance = hbd:GetPlayerWorldPosition()
    end
    local canAim = facing and hbd and x
    for _, row in ipairs(State.rows) do
        local arrow = row.arrow
        if arrow and arrow:IsShown() then
            local wp = refreshRowWaypoint(row)
            local angle = aimAngle(hbd, instance, x, y, wp, row.place, facing)
            local dist = rowPinDistance(row, wp, hbd, x, y, instance)

            local distLabel = type(dist) == "number" and formatYards(dist) or ""
            if row.distance and row.__rxpbDistLabel ~= distLabel then
                row.__rxpbDistLabel = distLabel
                row.distance:SetText(distLabel)
            end

            if type(angle) == "number" and type(facing) == "number" and setArrowRotation(arrow, angle - facing) then
                setArrowAlpha(arrow, 1)
                if row.arrowShadow and row.arrowShadow:IsShown() then
                    setArrowRotation(row.arrowShadow, angle - facing)
                    setArrowAlpha(row.arrowShadow, 0.9)
                end
            else
                setArrowAlpha(arrow, 0.35)
            end
            local now = GetTime and GetTime() or 0
            if now < aimLogUntil and now >= aimLogNext then
                aimLogNext = now + 1
                if ns.PrintAim then
                    ns.PrintAim()
                end
            end
        end
    end
    if State.nav.syncArrow then
        State.nav.syncArrow(facing, hbd, x, y, instance, canAim)
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
    for index = 1, #State.rows do
        local row = State.rows[index]
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
    local row = State.rows[index]
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
    RG.applyFont(row.badge.text, 12, "OUTLINE")
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
        RG.skipListedStep(self.stepIndex, self.sticky)
    end)

    row.arrowShadow = row:CreateTexture(nil, "ARTWORK")
    row.arrowShadow:SetDrawLayer("ARTWORK", 1)
    row.arrowShadow:SetTexture(UI.ARROW_TEXTURE)
    tintArrow(row.arrowShadow, 0, 0, 0, 0.8)
    row.arrowShadow:Hide()

    row.arrow = row:CreateTexture(nil, "OVERLAY")
    row.arrow:SetDrawLayer("OVERLAY", 2)
    row.arrow:SetTexture(UI.ARROW_TEXTURE)
    tintArrow(row.arrow, 1, 0.82, 0, 1)
    row.arrow:Hide()

    row.distance = row:CreateFontString(nil, "OVERLAY")
    RG.applyFont(row.distance, 10, "OUTLINE")
    row.distance:SetJustifyH("CENTER")
    row.distance:SetJustifyV("TOP")
    row.distance:Hide()

    row.text = row:CreateFontString(nil, "OVERLAY")
    RG.paint(row.text, 13, 1, 1, 1)
    row.details = row:CreateFontString(nil, "OVERLAY")
    RG.paint(row.details, 12, 0.82, 0.82, 0.82)
    row.more = CreateFrame("Button", nil, row)
    row.more:SetHeight(14)
    row.more:EnableMouse(true)
    row.more:RegisterForClicks("LeftButtonUp")
    row.more:Hide()
    row.more.text = row.more:CreateFontString(nil, "OVERLAY")
    row.more.text:SetAllPoints()
    row.more.text:SetJustifyH("LEFT")
    row.more.text:SetJustifyV("MIDDLE")
    RG.paint(row.more.text, 12, ns.Color("accent"))
    row.more:SetScript("OnEnter", function(self)
        local parent = self:GetParent()
        setRowHover(parent, true)
        pauseRowStepTip(parent)
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetText("Step notes", r, g, b)
        local tips = parent and parent.__rxpbTips
        local shown = 0
        for _, line in ipairs(tips or {}) do
            local plain = RG.plainText(line)
            if plain then
                shown = shown + 1
                if shown > 8 then
                    GameTooltip:AddLine("...", 0.7, 0.7, 0.7)
                    break
                end
                GameTooltip:AddLine("\226\128\162 " .. plain, 1, 1, 1, true)
            end
        end
        if shown == 0 then
            GameTooltip:AddLine("Show or hide the tip notes for this step. Progress and objectives stay visible.", 1, 1, 1, true)
        elseif parent and parent.__rxpbTipsExpanded then
            GameTooltip:AddLine("Click to hide these notes in the tracker.", 0.9, 0.82, 0.45, true)
        else
            GameTooltip:AddLine("Click to show these notes in the tracker.", 0.9, 0.82, 0.45, true)
        end
        ns.FinishTooltip()
        placeCursorTooltip(self)
    end)
    row.more:SetScript("OnLeave", function(self)
        resumeRowStepTip(self:GetParent())
    end)
    row.more:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        local item = parent and parent.__rxpbItem
        if not item then
            return
        end
        local key = item.stepIndex or item.number or 1
        State.expandedTips[key] = not State.expandedTips[key]
        if ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end)
    row.loadGuide = CreateFrame("Button", nil, row, "BackdropTemplate")
    row.loadGuide:SetHeight(18)
    row.loadGuide:EnableMouse(true)
    row.loadGuide:RegisterForClicks("LeftButtonUp")
    row.loadGuide:Hide()
    row.loadGuide:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    row.loadGuide.label = row.loadGuide:CreateFontString(nil, "OVERLAY")
    row.loadGuide.label:SetPoint("LEFT", 8, 0)
    row.loadGuide.label:SetPoint("RIGHT", -8, 0)
    row.loadGuide.label:SetJustifyH("CENTER")
    row.loadGuide.label:SetJustifyV("MIDDLE")
    RG.applyFont(row.loadGuide.label, 12, "OUTLINE")
    row.loadGuide:SetScript("OnEnter", function(self)
        local parent = self:GetParent()
        setRowHover(parent, true)
        pauseRowStepTip(parent)
        local r, g, b = ns.Color("accent")
        local target = self.guideName or "this guide"
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetText("Load guide", r, g, b)
        GameTooltip:AddLine("Click to switch to " .. target .. ".", 1, 1, 1, true)
        ns.FinishTooltip()
        placeCursorTooltip(self)
    end)
    row.loadGuide:SetScript("OnLeave", function(self)
        resumeRowStepTip(self:GetParent())
    end)
    row.loadGuide:SetScript("OnClick", function(self)
        if type(self.guideId) ~= "string" or self.guideId == "" then
            return
        end
        if ns.GuideSelect then
            ns.GuideSelect(self.guideId)
        end
    end)
    State.rows[index] = row
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
    State.buttonBusy = true
    button:SetParent(place.parent)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", place.parent, "TOPLEFT", place.x, place.y)
    button:SetSize(22, 22)
    local level = place.parent.GetFrameLevel and place.parent:GetFrameLevel() or 1
    button:SetFrameLevel(level + 6)
    button:SetAlpha(1)
    pcall(button.EnableMouse, button, true)
    button:Show()
    State.buttonBusy = false
end

local function hookAction(button)
    if not button or not button.SetPoint then
        return
    end
    if not button.__rxpbHooked then
        button.__rxpbHooked = true
        hooksecurefunc(button, "SetPoint", function(self)
            if State.buttonBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() or not self.__rxpbPlace then
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
    State.parked[button] = true
    applyPlace(button)
end

local function restoreAction(button)
    local home = button.__rxpbHome
    button.__rxpbPlace = nil
    State.parked[button] = nil
    if not home or InCombatLockdown() then
        return
    end
    State.buttonBusy = true
    if home.parent then
        button:SetParent(home.parent)
    end
    button:ClearAllPoints()
    if home.point and home.relative then
        button:SetPoint(home.point, home.relative, home.relativePoint or home.point, home.x or 0, home.y or 0)
    end
    button:SetSize(25, 25)
    State.buttonBusy = false
end

local function restoreAllActions()
    local held = {}
    for button in pairs(State.parked) do
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
    for button in pairs(State.parked) do
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

-- Our guide text tags use |cRB_*| (Waynotes). Colors live on UI.GUIDE_TAG_COLORS.

local function expandGuideTags(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    text = text:gsub("|T.-|t", "")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|n", "\n")

    -- Innermost tags first so nested FRIENDLY/ENEMY inside WARN resolve.
    local tags = { "FRIENDLY", "ENEMY", "LOOT", "PICK", "BUY", "QUEST", "WARN" }
    for _ = 1, 8 do
        local changed = false
        for _, name in ipairs(tags) do
            local key = "RB_" .. name .. "_"
            local hex = UI.GUIDE_TAG_COLORS[key]
            if hex then
                local nextText, count = text:gsub("|c" .. key .. "(.-)|r", "|c" .. hex .. "%1|r")
                if count > 0 then
                    text = nextText
                    changed = true
                end
            end
        end
        if not changed then
            break
        end
    end
    return text
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

local function addNameNeedle(sorted, seenNeedle, name)
    if type(name) ~= "string" or #name < 3 then
        return
    end
    local key = name:lower()
    if seenNeedle[key] then
        return
    end
    seenNeedle[key] = true
    sorted[#sorted + 1] = name
end

local function nameMatchForms(name, allowPlural)
    local forms = { name }
    if allowPlural == false then
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

local function findNameSpans(plain, names, allowPlural)
    local spans = {}
    local lower = plain:lower()
    local sorted = {}
    local seenNeedle = {}
    for _, name in ipairs(names or {}) do
        for _, form in ipairs(nameMatchForms(name, allowPlural)) do
            addNameNeedle(sorted, seenNeedle, form)
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
    local name = RG.progressItemName(plain)
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

local function accentPlain(plain, names, quests, highlightNames)
    if type(plain) ~= "string" or plain == "" then
        return plain or ""
    end
    local spans = findBracketSpans(plain)
    addSpans(spans, findProgressNameSpans(plain))
    addSpans(spans, findNameSpans(plain, quests, false))
    if highlightNames then
        addSpans(spans, findNameSpans(plain, names, true))
    end
    return colorSpans(plain, spans)
end

-- Accent-color untagged spans; leave already-colored |cffRRGGBB|r segments alone.
local function presentPlain(text, names, quests, highlightNames)
    if type(text) ~= "string" or text == "" then
        return ""
    end
    local expanded = expandGuideTags(text)
    local out = {}
    local cursor = 1
    while true do
        local first, last, hex, body = expanded:find("|c(%x%x%x%x%x%x%x%x)(.-)|r", cursor)
        if not first then
            out[#out + 1] = accentPlain(expanded:sub(cursor), names, quests, highlightNames)
            break
        end
        if first > cursor then
            out[#out + 1] = accentPlain(expanded:sub(cursor, first - 1), names, quests, highlightNames)
        end
        out[#out + 1] = "|c" .. hex .. body .. "|r"
        cursor = last + 1
    end
    return table.concat(out)
end

local function presentHeadline(item)
    local raw = item and item.headline
    if type(raw) ~= "string" or raw == "" then
        return ""
    end
    local presented = presentPlain(raw, item.names, item.quests, true)
    if presented == "" then
        return ""
    end
    return presented
end

local function isObjectiveDetail(text)
    if RG.isProgress(text) then
        return true
    end
    local plain = RG.plainText(text)
    if not plain then
        return false
    end
    local lower = plain:lower()
    if lower:match("^accept%s") or lower:match("^turn%s+in%s") or lower:match("^complete%s") then
        return true
    end
    if lower:match("^train%s") or lower:match("^trainer%s") or lower:match("^learn%s") then
        return true
    end
    if lower:match("^use:") or lower:match("^target:") then
        return true
    end
    if lower:match("^collect%s") or lower:match("^loot%s:") or lower:match("^gather%s") then
        return true
    end
    return false
end

local function objectiveRank(text)
    if RG.isProgress(text) then
        return 1
    end
    local plain = RG.plainText(text)
    local lower = plain and plain:lower() or ""
    if lower:match("^accept%s") or lower:match("^turn%s+in%s") or lower:match("^complete%s") then
        return 2
    end
    if lower:match("^train%s") or lower:match("^trainer%s") or lower:match("^learn%s") then
        return 3
    end
    if lower:match("^use:") or lower:match("^target:") then
        return 4
    end
    return 5
end

local function tipKey(item, index)
    return item and (item.stepIndex or item.number or index) or index
end

local function splitDetails(details)
    local objectives = {}
    local tips = {}
    for _, line in ipairs(details or {}) do
        if isObjectiveDetail(line) then
            objectives[#objectives + 1] = line
        else
            tips[#tips + 1] = line
        end
    end
    table.sort(objectives, function(a, b)
        local rankA = objectiveRank(a)
        local rankB = objectiveRank(b)
        if rankA == rankB then
            return false
        end
        return rankA < rankB
    end)
    return objectives, tips
end

local function joinDetails(objectives, tips)
    local lines = {}
    for _, line in ipairs(objectives or {}) do
        lines[#lines + 1] = line
    end
    for _, line in ipairs(tips or {}) do
        lines[#lines + 1] = line
    end
    return lines
end

local function presentDetailLines(lines, item)
    local accentR, accentG, accentB = ns.Color("accent")
    local bullet = colorCode(accentR, accentG, accentB) .. "\226\128\162|r "
    local out = {}
    for _, line in ipairs(lines or {}) do
        if type(line) == "string" and strtrim(line) ~= "" then
            local presented = presentPlain(line, item.names, item.quests, true)
            local check = RG.plainText(presented)
            if check and check ~= "" then
                out[#out + 1] = bullet .. presented
            end
        end
    end
    return table.concat(out, "\n")
end

local function presentDetails(item)
    local objectives, tips = splitDetails(item.details)
    return presentDetailLines(joinDetails(objectives, tips), item)
end

local function visibleDetailLines(item, index)
    local details = item and item.details or {}
    local objectives, tips = splitDetails(details)
    -- Nest notes whenever objective lines are present, or when there are several notes alone.
    local shouldNest = #tips >= 1 and (#objectives >= 1 or #tips >= UI.MORE_TIP_THRESHOLD)
    if not shouldNest then
        return joinDetails(objectives, tips), false, false, #tips
    end
    local expanded = State.expandedTips[tipKey(item, index)] and true or false
    if expanded then
        return joinDetails(objectives, tips), true, true, #tips
    end
    return objectives, true, false, #tips
end

local function applyRowText(row, item, index)
    row.__rxpbItem = item
    local main = index == 1
    local textR, textG, textB = ns.Color(main and "text" or "secondary")
    RG.paint(row.text, main and 16 or 13, textR, textG, textB)
    row.text:SetText(presentHeadline(item))
    local _, tipLines = splitDetails(item and item.details)
    row.__rxpbTips = tipLines
    local shown, canToggle, expanded = visibleDetailLines(item, index)
    row.__rxpbTipsExpanded = expanded and true or false
    if shown and #shown > 0 then
        local detailR, detailG, detailB = ns.Color("detail")
        RG.paint(row.details, main and 13 or 12, detailR, detailG, detailB)
        row.details:SetText(presentDetailLines(shown, item))
        row.details:Show()
    elseif row.details then
        row.details:SetText("")
        row.details:Hide()
    end
    if row.more then
        if canToggle then
            local accentR, accentG, accentB = ns.Color("accent")
            RG.paint(row.more.text, main and 12 or 11, accentR, accentG, accentB)
            row.more.text:SetText(expanded and "- fewer notes" or "+ more notes")
            row.more:Show()
        else
            row.more:Hide()
        end
    end
    if row.loadGuide then
        local linked = item and item.loadGuide
        if linked and type(linked.id) == "string" and linked.id ~= "" then
            local accentR, accentG, accentB = ns.Color("accent")
            local label = "Load: " .. (linked.name or linked.id)
            RG.paint(row.loadGuide.label, main and 12 or 11, 1, 1, 1)
            row.loadGuide.label:SetText(label)
            row.loadGuide.guideId = linked.id
            row.loadGuide.guideName = linked.name or linked.id
            row.loadGuide:SetBackdropColor(accentR * 0.25, accentG * 0.25, accentB * 0.25, 0.92)
            row.loadGuide:SetBackdropBorderColor(accentR, accentG, accentB, 0.9)
            row.loadGuide:Show()
        else
            row.loadGuide.guideId = nil
            row.loadGuide.guideName = nil
            row.loadGuide:Hide()
        end
    end
end

local function badgeLabel(item, index)
    local number = item.number > 0 and item.number or index
    return number, tostring(number)
end


local function readTrackerWidth()
    local width = ns.db and ns.db.trackerWidth or UI.TRACKER_WIDTH
    if type(width) ~= "number" then
        width = UI.TRACKER_WIDTH
    end
    width = math.floor(width + 0.5)
    if width < UI.MIN_TRACKER_WIDTH then
        width = UI.MIN_TRACKER_WIDTH
    elseif width > UI.MAX_TRACKER_WIDTH then
        width = UI.MAX_TRACKER_WIDTH
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
    if height < UI.MIN_TRACKER_HEIGHT then
        height = UI.MIN_TRACKER_HEIGHT
    elseif height > UI.MAX_TRACKER_HEIGHT then
        height = UI.MAX_TRACKER_HEIGHT
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
    local chrome = UI.TRACKER_CHROME + (State.flight.chrome or 0) + (State.nav.chrome or 0)
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
    local chrome = UI.TRACKER_CHROME + (State.flight.chrome or 0) + (State.nav.chrome or 0)
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
    local plain = RG.plainText(text)
    if not plain or not RG.isProgress(plain) then
        return nil
    end
    local done, total = plain:match("(%d+)%s*/%s*(%d+)")
    done = tonumber(done)
    total = tonumber(total)
    if not total then
        -- Authored gather counts like "Durotar Tiger Fur (4)" start at 0/N
        -- until live quest log text replaces them.
        total = tonumber(plain:match("%((%d+)%)%s*$"))
        if total then
            done = 0
        end
    end
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


local function ensureProgressBar(row, index)
    row.progressBars = row.progressBars or {}
    local holder = row.progressBars[index]
    if holder then
        return holder
    end
    holder = CreateFrame("Frame", nil, row, "BackdropTemplate")
    holder:SetHeight(UI.PROGRESS_BAR_HEIGHT)
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
        local y = 1 + (#ratios - index) * (UI.PROGRESS_BAR_HEIGHT + UI.PROGRESS_BAR_GAP)
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
    return #ratios * UI.PROGRESS_BAR_HEIGHT + (#ratios - 1) * UI.PROGRESS_BAR_GAP + 4
end

local function layout(items, resetScroll)
    local measured = true
    local y = 0
    local count = #items
    local width = readTrackerWidth()
    tracker:SetWidth(width)
    body:SetWidth(math.max(40, width - 16))

    if count == 0 then
        for index = 1, #State.rows do
            State.rows[index]:Hide()
        end
        empty:Show()
        divider:Hide()
        local waiting = RG.guideTitle() ~= "RestedXP"
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
        row.badge:SetPoint("TOPLEFT", (UI.COLUMN - badgeSize) / 2, main and -1 or 0)
        styleBadge(row.badge, br, bg, bb)
        local badgeNumber, badgeText = badgeLabel(item, index)
        RG.applyFont(row.badge.text, badgeFontSize(main, badgeNumber), "OUTLINE")
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

        local textLeft = UI.COLUMN + 8
        local rightInset = 0
        local arrowSize = main and 20 or 15
        local hasPin = item.waypoint or (item.place and type(item.place.x) == "number" and type(item.place.y) == "number")
        if hasPin and row.arrow then
            local tintR, tintG, tintB = arrowTint()
            local centerX = -2 - (UI.ARROW_COLUMN / 2)
            tintArrow(row.arrow, tintR, tintG, tintB, 1)
            row.arrow:Show()
            row.arrow:ClearAllPoints()
            row.arrow:SetSize(arrowSize, arrowSize)
            row.arrow:SetPoint("CENTER", row, "TOPRIGHT", centerX, -arrowSize / 2)
            -- Force aim path to re-apply texcoords after layout resize.
            row.arrow.__rxpbRot = nil
            row.arrow.__rxpbWp = item.waypoint
            row.place = item.place
            if not row.arrow.__rxpbWp then
                refreshRowWaypoint(row)
            end
            if row.arrowShadow then
                tintArrow(row.arrowShadow, 0, 0, 0, 0.9)
                row.arrowShadow:Show()
                row.arrowShadow:ClearAllPoints()
                row.arrowShadow:SetSize(arrowSize + 2, arrowSize + 2)
                row.arrowShadow:SetPoint("CENTER", row, "TOPRIGHT", centerX, -arrowSize / 2)
                row.arrowShadow:SetDrawLayer("ARTWORK", 1)
                row.arrowShadow.__rxpbRot = nil
            end
            row.arrow:SetDrawLayer("OVERLAY", 2)
            if row.distance then
                row.distance:Show()
                row.distance:ClearAllPoints()
                row.distance:SetPoint("TOPRIGHT", -2, -(arrowSize + 5))
                row.distance:SetWidth(UI.ARROW_COLUMN)
                RG.applyFont(row.distance, main and 10 or 9, "OUTLINE")
                row.distance:SetJustifyH("CENTER")
                row.distance:SetTextColor(tintR, tintG, tintB)
            end
            rightInset = UI.ARROW_COLUMN + 6
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

        local shownDetails = visibleDetailLines(item, index)
        local detailHeight = 0
        if shownDetails and #shownDetails > 0 then
            row.details:Show()
            row.details:ClearAllPoints()
            row.details:SetPoint("TOPLEFT", textLeft, -(textHeight + 2))
            row.details:SetPoint("TOPRIGHT", -rightInset, -(textHeight + 2))
            detailHeight = row.details:GetStringHeight() or 0
            if detailHeight < 1 then
                measured = false
                detailHeight = (main and 14 or 12) * #shownDetails
            end
            detailHeight = detailHeight + 2
        else
            row.details:Hide()
        end

        local moreHeight = 0
        if row.more and row.more:IsShown() then
            row.more:ClearAllPoints()
            row.more:SetPoint("TOPLEFT", textLeft, -(textHeight + detailHeight + 2))
            row.more:SetPoint("TOPRIGHT", -rightInset, -(textHeight + detailHeight + 2))
            row.more:SetHeight(14)
            moreHeight = 16
        elseif row.more then
            row.more:Hide()
        end

        local loadHeight = 0
        if row.loadGuide and row.loadGuide:IsShown() then
            local label = row.loadGuide.label:GetText() or "Load guide"
            local labelWidth = row.loadGuide.label:GetStringWidth() or 80
            local buttonWidth = math.min(math.max(labelWidth + 20, 120), math.max(80, width - 24 - textLeft - rightInset))
            row.loadGuide:ClearAllPoints()
            row.loadGuide:SetPoint("TOPLEFT", textLeft, -(textHeight + detailHeight + moreHeight + 4))
            row.loadGuide:SetSize(buttonWidth, 18)
            row.loadGuide.label:SetText(label)
            loadHeight = 22
        elseif row.loadGuide then
            row.loadGuide:Hide()
        end

        local actionHeight = 0
        local actions = item.actions or {}
        if #actions > 0 then
            local stride = 26
            local avail = width - 24 - textLeft - rightInset
            local perRow = math.max(1, math.floor(avail / stride))
            local yBase = textHeight + detailHeight + moreHeight + loadHeight + 4
            for actionIndex, button in ipairs(actions) do
                local col = (actionIndex - 1) % perRow
                local line = math.floor((actionIndex - 1) / perRow)
                placeAction(button, row, textLeft + (col * stride), -(yBase + (line * stride)))
                seenActions[button] = true
            end
            actionHeight = (math.floor((#actions - 1) / perRow) + 1) * stride + 2
        end

        local navHeight = hasPin and (arrowSize + 17) or 0
        local barHeight = syncProgressBars(row, item, textLeft, rightInset)
        local blockHeight = math.max(badgeSize, textHeight + detailHeight + moreHeight + loadHeight + actionHeight, navHeight) + barHeight
        row:SetHeight(blockHeight)
        y = y + blockHeight + (main and 10 or 6)
    end

    for index = count + 1, #State.rows do
        State.rows[index]:Hide()
    end

    local stale = {}
    for button in pairs(State.parked) do
        if not seenActions[button] then
            stale[#stale + 1] = button
        end
    end
    for _, button in ipairs(stale) do
        restoreAction(button)
    end

    if count > 1 then
        local mainRow = State.rows[1]
        divider:ClearAllPoints()
        divider:SetPoint("TOPLEFT", body, "TOPLEFT", UI.COLUMN + 8, -(mainRow:GetHeight() + 4))
        divider:SetPoint("TOPRIGHT", body, "TOPRIGHT", 0, -(mainRow:GetHeight() + 4))
        divider:Show()
    else
        divider:Hide()
    end

    applyTrackerBox(math.max(20, y), resetScroll)
    return measured
end

local function paintRowColors()
    for index, row in ipairs(State.rows) do
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

do
    local PIN_REF = addonName .. "-step-pins"
    local SHOW_WORLD = (rawget(_G, "HBD_PINS_WORLDMAP_SHOW_WORLD")) or 3
    local BADGE = {
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    }

    local function pinsLib()
        if not LibStub then
            return nil
        end
        local ok, lib = pcall(LibStub, "HereBeDragons-Pins-2.0")
        if ok then
            return lib
        end
    end

    local function clearStepMapPins()
        local pins = pinsLib()
        if pins then
            if pins.RemoveAllWorldMapIcons then
                pins:RemoveAllWorldMapIcons(PIN_REF)
            end
            if pins.RemoveAllMinimapIcons then
                pins:RemoveAllMinimapIcons(PIN_REF)
            end
        end
        for _, frame in ipairs(State.mapPins.frames) do
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetParent(UIParent)
        end
        State.mapPins.signature = nil
    end

    local function acquireStepMapPin(index)
        local frame = State.mapPins.frames[index]
        if frame then
            return frame
        end
        frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        frame:SetSize(22, 22)
        frame:SetBackdrop(BADGE)
        frame.ring = frame:CreateTexture(nil, "BORDER")
        setCircleTexture(frame.ring)
        frame.ring:SetPoint("TOPLEFT", -1, 1)
        frame.ring:SetPoint("BOTTOMRIGHT", 1, -1)
        frame.circle = frame:CreateTexture(nil, "ARTWORK")
        setCircleTexture(frame.circle)
        frame.circle:SetPoint("TOPLEFT", 1, -1)
        frame.circle:SetPoint("BOTTOMRIGHT", -1, 1)
        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetAllPoints()
        frame.text:SetJustifyH("CENTER")
        frame.text:SetJustifyV("MIDDLE")
        RG.applyFont(frame.text, 12, "OUTLINE")
        frame.text:SetTextColor(1, 1, 1)
        frame:EnableMouse(true)
        frame:SetScript("OnEnter", function(self)
            if not self.tipTitle then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tipTitle, 1, 0.82, 0)
            if self.tipPlace then
                GameTooltip:AddLine(self.tipPlace, 0.9, 0.9, 0.9, true)
            end
            if self.tipWorld then
                GameTooltip:AddLine(self.tipWorld, 0.75, 0.75, 0.75, true)
            end
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        State.mapPins.frames[index] = frame
        return frame
    end

    local function paintStepMapPin(frame, index, badgeText)
        local r, g, b = ns.BadgeColor(index)
        local rounded = ns.db and ns.db.roundBadges
        if rounded then
            frame:SetBackdropColor(0, 0, 0, 0)
            frame:SetBackdropBorderColor(0, 0, 0, 0)
            frame.ring:SetVertexColor(0, 0, 0, 0.7)
            frame.ring:Show()
            frame.circle:SetVertexColor(r, g, b, 1)
            frame.circle:Show()
        else
            frame.ring:Hide()
            frame.circle:Hide()
            frame:SetBackdropColor(r, g, b, 1)
            frame:SetBackdropBorderColor(0, 0, 0, 0.45)
        end
        frame.text:SetText(badgeText)
        local size = index == 1 and 22 or 18
        frame:SetSize(size, size)
        RG.applyFont(frame.text, index == 1 and 12 or 10, "OUTLINE")
    end

    local function fraction(value)
        if type(value) ~= "number" then
            return nil
        end
        if value > 1 then
            return value / 100
        end
        return value
    end

    local function sameZoneAsPlayer(place)
        if type(place) ~= "table" then
            return false
        end
        local pmap = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        if type(place.map) == "number" and type(pmap) == "number" and place.map == pmap then
            return true, pmap
        end
        local pinZone = place.zone or (place.map and ns.MapName and ns.MapName(place.map))
        local pzone = GetRealZoneText and GetRealZoneText()
        if type(pinZone) == "string" and type(pzone) == "string" then
            local a = pinZone:lower():gsub("^the%s+", "")
            local b = pzone:lower():gsub("^the%s+", "")
            if a ~= "" and b ~= "" and (a == b or a:find(b, 1, true) or b:find(a, 1, true)) then
                return true, pmap
            end
        end
        return false, pmap
    end

    local function placePin(pins, frame, item, index)
        local place = item.place
        local wp = item.waypoint
        if (not wp or type(wp.wx) ~= "number") and place and ns.PinToPlayerWorld then
            local wx, wy, inst = ns.PinToPlayerWorld(place.map, place.x, place.y, place.zone)
            if type(wx) == "number" then
                wp = { wx = wx, wy = wy, instance = inst }
            end
        end

        local zx = place and fraction(place.x)
        local zy = place and fraction(place.y)
        local placed = false

        -- Prefer authored zone percents on a map HBD can show (live map when
        -- Forever remaps classic ids).
        if type(zx) == "number" and type(zy) == "number" then
            local same, pmap = sameZoneAsPlayer(place)
            local maps = {}
            if same and type(pmap) == "number" then
                maps[#maps + 1] = pmap
            end
            if type(place.map) == "number" then
                maps[#maps + 1] = place.map
            end
            for _, mapId in ipairs(maps) do
                pins:AddWorldMapIconMap(PIN_REF, frame, mapId, zx, zy, SHOW_WORLD)
                if pins.AddMinimapIconMap then
                    pins:AddMinimapIconMap(PIN_REF, frame, mapId, zx, zy, true, true)
                end
                -- HBD silently no-ops when zone→world fails; detect via registry.
                if pins.worldmapPinRegistry and pins.worldmapPinRegistry[PIN_REF] and pins.worldmapPinRegistry[PIN_REF][frame] then
                    placed = true
                    break
                end
                if pins.RemoveWorldMapIcon then
                    pins:RemoveWorldMapIcon(PIN_REF, frame)
                end
                if pins.RemoveMinimapIcon then
                    pins:RemoveMinimapIcon(PIN_REF, frame)
                end
            end
        end

        if not placed and wp and type(wp.wx) == "number" and type(wp.wy) == "number" then
            pins:AddWorldMapIconWorld(PIN_REF, frame, wp.instance or 0, wp.wx, wp.wy, SHOW_WORLD)
            if pins.AddMinimapIconWorld then
                pins:AddMinimapIconWorld(PIN_REF, frame, wp.instance or 0, wp.wx, wp.wy, true)
            end
            placed = true
        end

        if not placed then
            return false
        end

        local _, badgeText = badgeLabel(item, index)
        paintStepMapPin(frame, index, badgeText)
        frame.tipTitle = string.format("Step %s", badgeText)
        if place and type(place.x) == "number" then
            local mapLabel = place.zone or (place.map and tostring(place.map)) or "?"
            frame.tipPlace = string.format("%s  %.1f, %.1f", mapLabel, place.x > 1 and place.x or place.x * 100, place.y > 1 and place.y or place.y * 100)
        else
            frame.tipPlace = nil
        end
        if wp and type(wp.wx) == "number" then
            frame.tipWorld = string.format("world %.0f, %.0f  i%s", wp.wx, wp.wy, tostring(wp.instance or "?"))
        else
            frame.tipWorld = nil
        end
        frame:Show()
        return true
    end

    function State.syncStepMapPins(items)
        local pins = pinsLib()
        if not pins or not pins.AddWorldMapIconMap then
            return
        end
        if type(items) ~= "table" or not tracker:IsShown() then
            clearStepMapPins()
            return
        end
        if not ns.db or (not ns.db.standaloneGuide and not ns.db.replaceGuide) then
            clearStepMapPins()
            return
        end

        local parts = {}
        for index, item in ipairs(items) do
            local place = item.place
            local wp = item.waypoint
            local px = place and place.x or "-"
            local py = place and place.y or "-"
            local pm = place and place.map or "-"
            local wx = wp and wp.wx or "-"
            local wy = wp and wp.wy or "-"
            parts[index] = tostring(item.number or index) .. ":" .. tostring(pm) .. ":" .. tostring(px) .. ":" .. tostring(py) .. ":" .. tostring(wx) .. ":" .. tostring(wy)
        end
        local signature = table.concat(parts, "|")
        if signature == State.mapPins.signature then
            return
        end

        clearStepMapPins()
        State.mapPins.signature = signature

        local used = 0
        for index, item in ipairs(items) do
            local hasPin = item.waypoint or (item.place and type(item.place.x) == "number" and type(item.place.y) == "number")
            if hasPin then
                used = used + 1
                local frame = acquireStepMapPin(used)
                if not placePin(pins, frame, item, index) then
                    frame:Hide()
                    used = used - 1
                end
            end
        end
        for index = used + 1, #State.mapPins.frames do
            State.mapPins.frames[index]:Hide()
        end
    end

    State.clearStepMapPins = clearStepMapPins
end

function ns.RefreshTracker(force)
    if not ns.db or not tracker:IsShown() or (not ns.db.standaloneGuide and not ns.db.replaceGuide) then
        if State.clearStepMapPins then
            State.clearStepMapPins()
        end
        return
    end

    local items = RG.collectObjectives()
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
    local signature = RG.guideTitle() .. "\n" .. percentLabel .. "\n" .. table.concat(parts, "\n")

    header:SetText(RG.guideTitle())
    placeGuidePercent()

    local scale = ns.db.trackerScale or 1.2
    if math.abs((tracker:GetScale() or 1) - scale) > 0.001 then
        tracker:SetScale(scale)
    end

    if InCombatLockdown() and next(State.parked) then
        for index, item in ipairs(items) do
            local row = State.rows[index]
            if row and row.text then
                local main = index == 1
                if row.badge and row.badge.text then
                    local badgeNumber, badgeText = badgeLabel(item, index)
                    RG.applyFont(row.badge.text, badgeFontSize(main, badgeNumber), "OUTLINE")
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
        if State.syncStepMapPins then
            State.syncStepMapPins(items)
        end
        return
    end

    local sizeNow = readTrackerWidth() .. ":" .. (readTrackerHeight() or 0)
    local sizeChanged = sizeNow ~= State.sizeKey
    State.sizeKey = sizeNow
    local contentChanged = signature ~= State.lastSignature
    if force or contentChanged or sizeChanged or State.remeasure then
        if layout(items, contentChanged) then
            State.lastSignature = signature
            State.remeasure = sizeChanged
        else
            State.remeasure = true
        end
    end
    styleTracker()
    paintRowColors()
    styleStepButtons()
    reassertActions()
    if State.syncStepMapPins then
        State.syncStepMapPins(items)
    end
end

local function hookMouse(frame)
    if not frame or State.hookedMouse[frame] or not frame.EnableMouse or not frame.GetObjectType then
        return
    end
    if frame.IsForbidden and frame:IsForbidden() then
        return
    end

    State.hookedMouse[frame] = true
    hooksecurefunc(frame, "EnableMouse", function(self, enabled)
        if State.mouseBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
            return
        end
        if enabled then
            State.mouseBusy = true
            pcall(self.EnableMouse, self, false)
            State.mouseBusy = false
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

    local unseen = not State.hookedMouse[frame]
    hookMouse(frame)
    if unseen and ns.ReplacingGuide() and frame.EnableMouse then
        State.mouseBusy = true
        pcall(frame.EnableMouse, frame, false)
        State.mouseBusy = false
    end

    if frame.GetNumChildren then
        for index = 1, frame:GetNumChildren() do
            walkMouse(select(index, frame:GetChildren()), depth + 1)
        end
    end
end

local function chromeFrames(rxp)
    return {
        rxp.BottomFrame,
        rxp.GuideName,
        rxp.Footer,
        rxp.CurrentStepFrame,
    }
end

local function satelliteFrames()
    local frames = {}
    if _G.RXPTargetFrame then
        frames[#frames + 1] = _G.RXPTargetFrame
    end
    local items = RG.itemWindow and RG.itemWindow()
    if items then
        frames[#frames + 1] = items
    end
    return frames
end

local function hookChromeAlpha(frame)
    if not frame or State.chromeHooked[frame] or not frame.SetAlpha then
        return
    end
    State.chromeHooked[frame] = true
    hooksecurefunc(frame, "SetAlpha", function(self, alpha)
        if State.alphaBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
            return
        end
        if (alpha or 1) > 0 then
            State.alphaBusy = true
            self:SetAlpha(0)
            State.alphaBusy = false
        end
    end)
end


local function guideCog()
    local rxp = _G.RXPFrame
    return rxp and rxp.Footer and rxp.Footer.cog
end

local function rememberCog(cog)
    if State.cogHome or not cog then
        return
    end
    local point, relative, relativePoint, x, y = cog:GetPoint(1)
    State.cogHome = {
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
            if State.cogBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
                return
            end
            local _, relativeTo = self:GetPoint(1)
            if relativeTo == tracker then
                return
            end
            State.cogBusy = true
            self:SetParent(tracker)
            self:ClearAllPoints()
            self:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -4, -4)
            State.cogBusy = false
        end)
    end

    State.cogBusy = true
    cog:SetParent(tracker)
    cog:SetFrameStrata(tracker:GetFrameStrata())
    cog:SetFrameLevel(tracker:GetFrameLevel() + 20)
    cog:ClearAllPoints()
    cog:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -4, -4)
    cog:SetAlpha(1)
    cog:EnableMouse(true)
    cog:Show()
    State.cogBusy = false
end

ns.PlaceGuideCog = placeCog

local function restoreCog()
    local cog = guideCog()
    if not cog or not State.cogHome then
        return
    end
    State.cogBusy = true
    if State.cogHome.parent then
        cog:SetParent(State.cogHome.parent)
    end
    cog:ClearAllPoints()
    if State.cogHome.point and State.cogHome.relative then
        cog:SetPoint(State.cogHome.point, State.cogHome.relative, State.cogHome.relativePoint or State.cogHome.point, State.cogHome.x or 0, State.cogHome.y or 0)
    end
    State.cogBusy = false
end

local function concealSatellite(frame)
    if not frame then
        return
    end
    if not State.satelliteHooked[frame] and frame.SetAlpha then
        State.satelliteHooked[frame] = true
        hooksecurefunc(frame, "SetAlpha", function(self, alpha)
            if State.alphaBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
                return
            end
            if (alpha or 1) > 0 then
                State.alphaBusy = true
                self:SetAlpha(0)
                State.alphaBusy = false
            end
        end)
        if frame.Show then
            hooksecurefunc(frame, "Show", function(self)
                if State.alphaBusy or not ns.ReplacingGuide or not ns.ReplacingGuide() then
                    return
                end
                self.__rxpbWasShown = true
                State.alphaBusy = true
                self:SetAlpha(0)
                if not InCombatLockdown() then
                    pcall(self.Hide, self)
                end
                State.alphaBusy = false
            end)
        end
    end
    hookMouse(frame)
    if frame.IsShown and frame:IsShown() then
        frame.__rxpbWasShown = true
    end
    State.alphaBusy = true
    frame:SetAlpha(0)
    if not InCombatLockdown() then
        pcall(frame.Hide, frame)
    end
    State.alphaBusy = false
    walkMouse(frame, 0)
end

local function revealSatellite(frame)
    if not frame or not frame.SetAlpha then
        return
    end
    local showAgain = frame.__rxpbWasShown
    frame.__rxpbWasShown = nil
    State.alphaBusy = true
    frame:SetAlpha(1)
    if showAgain and frame.Show and not InCombatLockdown() then
        pcall(frame.Show, frame)
    end
    State.alphaBusy = false
end

local function concealGuide(rxp)
    State.alphaBusy = true
    rxp:SetAlpha(1)
    State.alphaBusy = false

    for _, frame in ipairs(chromeFrames(rxp)) do
        if frame then
            hookChromeAlpha(frame)
            State.alphaBusy = true
            frame:SetAlpha(0)
            State.alphaBusy = false
            walkMouse(frame, 0)
        end
    end

    hookMouse(rxp)
    if rxp.EnableMouse then
        State.mouseBusy = true
        rxp:EnableMouse(false)
        State.mouseBusy = false
    end

    for _, frame in ipairs(satelliteFrames()) do
        concealSatellite(frame)
    end
    placeCog()
end

local function revealGuide(rxp)
    State.alphaBusy = true
    for _, frame in ipairs(chromeFrames(rxp)) do
        if frame and frame.SetAlpha then
            frame:SetAlpha(1)
        end
    end
    State.alphaBusy = false

    State.mouseBusy = true
    for frame in pairs(State.hookedMouse) do
        if frame.EnableMouse then
            frame:EnableMouse(true)
        end
    end
    State.mouseBusy = false

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
    if ns.ReplacingGuide() then
        if not tracker:IsShown() then
            ns.SyncReplacement()
            return
        end
        concealGuide(rxp)
        ns.RefreshTracker()
    elseif ns.db and ns.db.standaloneGuide then
        concealGuide(rxp)
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
    local hardcore = ns.db.hardcoreGuide and true or false
    if ns.db.standaloneGuide and not State.standaloneWas then
        if ns.GuideEnsure then
            ns.GuideEnsure()
        end
        if ns.GuideCatchUp then
            ns.GuideCatchUp()
        end
    elseif ns.db.standaloneGuide and hardcore ~= State.hardcoreWas and ns.GuideCatchUp then
        ns.GuideCatchUp()
    end
    State.standaloneWas = ns.db.standaloneGuide and true or false
    State.hardcoreWas = hardcore

    local rxp = _G.RXPFrame
    local showTracker = ns.db.standaloneGuide or (ns.db.replaceGuide and rxp)
    if showTracker then
        if rxp then
            concealGuide(rxp)
        end
        if not State.pointRestored then
            restorePoint()
            State.pointRestored = true
        end
        tracker:SetScale(ns.db.trackerScale or 1.2)
        tracker:Show()
        ns.RefreshTracker(true)
    else
        tracker:Hide()
        State.lastSignature = nil
        if rxp then
            revealGuide(rxp)
        end
    end
end

tracker:SetScript("OnUpdate", function(self, delta)
    if not self:IsMouseOver() then
        clearGuideTips()
    else
        placeTrackerTooltip()
    end
    pcall(updateArrows)
    pcall(updateFlightStrip)
    pcall(updateNavStrip)
    if not (ns.db and ns.db.standaloneGuide) then
        pcall(RG.maintainReview)
    end
    State.elapsed = State.elapsed + delta
    if State.elapsed < 0.2 then
        return
    end
    State.elapsed = 0
    ns.RefreshTracker()
end)

tracker:SetScript("OnShow", function()
    State.lastSignature = nil
    ns.RefreshTracker(true)
    pcall(updateFlightStrip)
    pcall(updateNavStrip)
end)

tracker:SetScript("OnHide", function()
    clearGuideTips()
    shadowHost:Hide()
    if State.flight.strip then
        State.flight.strip:Hide()
    end
    if State.nav.strip then
        State.nav.strip:Hide()
    end
    if State.clearStepMapPins then
        State.clearStepMapPins()
    end
    if ns.HideNavMenu then
        ns.HideNavMenu()
    end
end)
