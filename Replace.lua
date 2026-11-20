local addonName, ns = ...

-- Tracker UI. Guide/RXP helpers live in ReplaceGuide.lua (ns.RG) so this
-- chunk stays under Lua 5.1's 200-local limit.

local RG = ns.RG
local State = ns.ReplaceState

local UI = {
    COLUMN = 26,
    TRACKER_WIDTH = 300,
    HEADER_RIGHT = -144,
    HEADER_BOTTOM = 27,
    WHITE = "Interface\\BUTTONS\\WHITE8X8",
    FLIGHT_STRIP = 26,
    FLY_REC_STRIP = 28,
    HEARTH_REC_STRIP = 28,
    NAV_STRIP = 28,
    TRAIN_NOTICE = 22,
    CORPSE_STRIP = 28,
    GLOW_MAX_SPREAD = 16,
    PI2 = math.pi * 2,
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
        RB_SKILL_ = "FF7EB6FF",
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
State.flyRec = { chrome = 0 }
State.hearthRec = { chrome = 0 }
State.nav = { chrome = 0 }
State.train = { chrome = 0 }
State.corpse = { chrome = 0 }
State.mapPins = { frames = {}, signature = nil }
State.stickyShown = {}
State.completing = {}
State.pinVisits = {}
State.pinCycle = {}
State.guideConcealed = false
State.concealWalkKey = nil
State.trackerDirty = true
State.trackerForce = true
State.dirtyAt = 0
State.travelElapsed = 0
State.positionElapsed = 0
State.lastPulseX = nil
State.lastPulseY = nil
State.lastPulseInstance = nil


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

-- Header chrome shares one table so this file stays under the 200-local limit.
local chrome = {}
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
    if not chrome.percent then
        return
    end
    local label = guidePercentLabel()
    if not label then
        chrome.percent:Hide()
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", 10, -7)
        header:SetPoint("TOPRIGHT", UI.HEADER_RIGHT, -7)
        return
    end
    local r, g, b = ns.Color("accent")
    RG.paint(chrome.percent, 12, r, g, b)
    chrome.percent:SetText(label)
    chrome.percent:Show()
    chrome.percent:ClearAllPoints()
    local rightOf = chrome.nav or chrome.sync or chrome.jump
    if rightOf then
        chrome.percent:SetPoint("TOPRIGHT", rightOf, "TOPLEFT", -6, 1)
    else
        chrome.percent:SetPoint("TOPRIGHT", UI.HEADER_RIGHT, -7)
    end
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", 10, -7)
    header:SetPoint("TOPRIGHT", chrome.percent, "TOPLEFT", -6, 0)
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
UI.GPS_ARROW = media("gps_arrow.png")
UI.GPS_PIN = media("gps_pin.png")
UI.GPS_CYCLE = media("gps_cycle.png")
UI.GPS_CHECK = media("gps_check.png")
UI.GPS_NOTICE = media("gps_notice.png")
-- gps_arrow.png is drawn tip-up-right, 45 degrees northeast.
-- Aim math treats rotation 0 as tip-up. SetRotation turns counterclockwise
-- (a positive quarter-turn aims the up-arrow header chevron to the left).
UI.GPS_ARROW_OFFSET = math.pi / 4
-- The arrow art is inset so a cardinal rotation keeps the tip inside the frame.
-- These sizes restore the on-screen arrow to the previous 14 / 15 / 20 px.
UI.GPS_ARROW_NAV = 17
UI.GPS_ARROW_ROW = 18
UI.GPS_ARROW_MAIN = 24
UI.GLOW_EDGE = media("glow-edge.tga")
UI.GLOW_CORNER = media("glow-corner.tga")
-- Same-zone yards at which a kill objective swaps the arrow for the pin.
UI.KILL_AREA_YARDS = 100
UI.AIM_RESOLVE_SECONDS = 0.2
UI.STRIP_UPDATE_SECONDS = 0.25
UI.TRAIN_UPDATE_SECONDS = 1
-- Full step rebuilds are event-driven. These only gate light pulse work.
UI.TRACKER_COALESCE_SECONDS = 0.05
UI.TRACKER_COMBAT_COALESCE_SECONDS = 0.2
UI.TRAVEL_PULSE_SECONDS = 0.5
UI.POSITION_PULSE_SECONDS = 0.5
UI.POSITION_DIRTY_YARDS = 40
-- Sticky complete: brief hold on the green check, then fade the row out.
UI.STICKY_COMPLETE_HOLD = 0.15
UI.STICKY_COMPLETE_FADE = 0.45
UI.STICKY_COMPLETE_GREEN = { 0.2, 0.85, 0.35 }

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

local function clampGlowSpread(spread)
    spread = math.floor((spread or 4) + 0.5)
    if spread < 1 then
        return 1
    elseif spread > UI.GLOW_MAX_SPREAD then
        return UI.GLOW_MAX_SPREAD
    end
    return spread
end

local function glowRoundPath(radius, spread)
    return media("glow-round-" .. radius .. "-" .. spread .. ".tga")
end

-- Eight exterior pieces only. Nothing is drawn over the panel interior.
local function makeSoftGlow(parent)
    local plate = { list = {}, soft = true, outside = true }
    local function add(name)
        local texture = parent:CreateTexture(nil, "ARTWORK")
        setLayer(texture, "ARTWORK", 1)
        texture:SetBlendMode("ADD")
        texture:Hide()
        plate[name] = texture
        plate.list[#plate.list + 1] = texture
    end
    add("tl")
    add("tr")
    add("bl")
    add("br")
    add("t")
    add("b")
    add("l")
    add("r")
    return plate
end

local function hideSoftGlow(plate)
    if not plate then
        return
    end
    if plate.layers then
        for index = 1, UI.GLOW_MAX_SPREAD do
            if plate[index] then
                hidePlate(plate[index])
            end
        end
        return
    end
    hidePlate(plate)
end

local function paintSoftGlow(plate, r, g, b)
    if not plate or not plate.list then
        return
    end
    for index = 1, #plate.list do
        plate.list[index]:SetVertexColor(r, g, b, 1)
    end
end

local function placeGlowHost(host, frame, parentScale, frameScale, strata, level)
    host:SetScale(frameScale / parentScale)
    host:SetFrameStrata(strata)
    host:SetFrameLevel(level)
    host:ClearAllPoints()
    host:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    host:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    host:Show()
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

local function showSoftGlow(plate, anchor, spread, cornerRadius, glowR, glowG, glowB)
    if not plate or not plate.outside then
        return
    end
    spread = clampGlowSpread(spread)
    local width = anchor:GetWidth() or 0
    local height = anchor:GetHeight() or 0
    if width < 2 or height < 2 then
        hideSoftGlow(plate)
        return
    end

    local rounded = type(cornerRadius) == "number" and cornerRadius >= 4
    if rounded then
        cornerRadius = clampCornerRadius(cornerRadius)
        local maxCorner = math.floor(math.min(width, height) / 2)
        if cornerRadius > maxCorner then
            cornerRadius = maxCorner
        end
        if cornerRadius < 4 then
            rounded = false
        end
    else
        cornerRadius = 0
    end

    local function showEdge(texture, pointA, relA, xA, yA, pointB, relB, xB, yB, along, coord)
        texture:SetTexture(UI.GLOW_EDGE)
        texture:SetTexCoord(coord[1], coord[2], coord[3], coord[4], coord[5], coord[6], coord[7], coord[8])
        texture:ClearAllPoints()
        texture:SetPoint(pointA, anchor, relA, xA, yA)
        texture:SetPoint(pointB, anchor, relB, xB, yB)
        if along == "h" then
            texture:SetHeight(spread)
        else
            texture:SetWidth(spread)
        end
        texture:Show()
    end

    -- Straight bands sit fully outside the frame and stop where the corner arc starts.
    local inset = rounded and cornerRadius or 0
    local gapW = width - (inset * 2)
    local gapH = height - (inset * 2)
    if gapW >= 1 then
        showEdge(plate.t, "BOTTOMLEFT", "TOPLEFT", inset, 0, "BOTTOMRIGHT", "TOPRIGHT", -inset, 0, "h", { 0, 0, 0, 1, 1, 0, 1, 1 })
        showEdge(plate.b, "TOPLEFT", "BOTTOMLEFT", inset, 0, "TOPRIGHT", "BOTTOMRIGHT", -inset, 0, "h", { 0, 1, 0, 0, 1, 1, 1, 0 })
    else
        plate.t:Hide()
        plate.b:Hide()
    end
    if gapH >= 1 then
        showEdge(plate.l, "TOPRIGHT", "TOPLEFT", 0, -inset, "BOTTOMRIGHT", "BOTTOMLEFT", 0, inset, "v", { 0, 0, 1, 0, 0, 1, 1, 1 })
        showEdge(plate.r, "TOPLEFT", "TOPRIGHT", 0, -inset, "BOTTOMLEFT", "BOTTOMRIGHT", 0, inset, "v", { 0, 1, 1, 1, 0, 0, 1, 0 })
    else
        plate.l:Hide()
        plate.r:Hide()
    end

    local function showRoundCorner(texture, point, relPoint, x, y, flipU, flipV)
        local u0, u1 = 0, 1
        local v0, v1 = 0, 1
        if flipU then
            u0, u1 = 1, 0
        end
        if flipV then
            v0, v1 = 1, 0
        end
        texture:SetTexture(glowRoundPath(cornerRadius, spread))
        texture:SetTexCoord(u0, u1, v0, v1)
        texture:ClearAllPoints()
        -- Same falloff distance as the straight edges. Interior texels are clear.
        texture:SetPoint(point, anchor, relPoint, x, y)
        texture:SetSize(cornerRadius + spread, cornerRadius + spread)
        texture:Show()
    end

    local function showSquareCorner(texture, point, relPoint, flipU, flipV)
        local u0, u1 = 0, 1
        local v0, v1 = 0, 1
        if flipU then
            u0, u1 = 1, 0
        end
        if flipV then
            v0, v1 = 1, 0
        end
        texture:SetTexture(UI.GLOW_CORNER)
        texture:SetTexCoord(u0, u1, v0, v1)
        texture:ClearAllPoints()
        texture:SetPoint(point, anchor, relPoint, 0, 0)
        texture:SetSize(spread, spread)
        texture:Show()
    end

    if rounded then
        showRoundCorner(plate.tl, "BOTTOMRIGHT", "TOPLEFT", cornerRadius, -cornerRadius, false, false)
        showRoundCorner(plate.tr, "BOTTOMLEFT", "TOPRIGHT", -cornerRadius, -cornerRadius, true, false)
        showRoundCorner(plate.bl, "TOPRIGHT", "BOTTOMLEFT", cornerRadius, cornerRadius, false, true)
        showRoundCorner(plate.br, "TOPLEFT", "BOTTOMRIGHT", -cornerRadius, cornerRadius, true, true)
    else
        showSquareCorner(plate.tl, "BOTTOMRIGHT", "TOPLEFT", false, false)
        showSquareCorner(plate.tr, "BOTTOMLEFT", "TOPRIGHT", true, false)
        showSquareCorner(plate.bl, "TOPRIGHT", "BOTTOMLEFT", false, true)
        showSquareCorner(plate.br, "TOPLEFT", "BOTTOMRIGHT", true, true)
    end

    paintSoftGlow(plate, glowR, glowG, glowB)
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
    local light = ns.IsLightBackground and ns.IsLightBackground()
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
        badge.ring:SetVertexColor(0, 0, 0, light and 0.35 or 0.7)
        badge.ring:Show()
        badge.circle:SetVertexColor(r, g, b, 1)
        badge.circle:Show()
    else
        if badge.circle then
            badge.circle:Hide()
            badge.ring:Hide()
        end
        badge:SetBackdropColor(r, g, b, 1)
        badge:SetBackdropBorderColor(0, 0, 0, light and 0.22 or 0.45)
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

local glowHost = CreateFrame("Frame", nil, UIParent)
glowHost:SetFrameStrata("MEDIUM")
glowHost:EnableMouse(false)
glowHost:Hide()

local headerBar = makeTexture(tracker, "BACKGROUND", 2, UI.WHITE)
local panelFill = makePlate(tracker, "BACKGROUND", 1)
local panelHeader = makePlate(tracker, "BACKGROUND", 3)
local panelBorder = makePlate(tracker, "BORDER", 1)
local panelShadow = makePlate(shadowHost, "ARTWORK", 1)
local panelGlow = makeSoftGlow(glowHost)

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
    button:SetScript("OnMouseUp", function(self, button)
        self.icon:SetPoint("CENTER", 0, 0)
        if button == "RightButton" and ns.OpenGuideMenu then
            ns.OpenGuideMenu()
        end
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
    if chrome.placeActions then
        chrome.placeActions()
    end
    local r, g, b = ns.Color("accent")
    local light = ns.IsLightBackground and ns.IsLightBackground()
    local idleFillR, idleFillG, idleFillB = 0, 0, 0
    local idleFillA, idleFillDimA = 0.55, 0.3
    local idleEdgeA, idleEdgeDimA = 0.75, 0.28
    local hoverFillA = 0.22
    if light then
        idleFillR, idleFillG, idleFillB = r, g, b
        idleFillA, idleFillDimA = 0.12, 0.06
        idleEdgeA, idleEdgeDimA = 0.55, 0.28
        hoverFillA = 0.24
    end
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
            styleChromeButton(button, r, g, b, hoverFillA, r, g, b, 1)
        else
            styleChromeButton(
                button,
                idleFillR,
                idleFillG,
                idleFillB,
                enabled and idleFillA or idleFillDimA,
                r,
                g,
                b,
                enabled and idleEdgeA or idleEdgeDimA
            )
        end
    end
    if chrome.jump then
        chrome.jump.text:SetTextColor(r, g, b)
        if chrome.jump.hovered then
            styleChromeButton(chrome.jump, r, g, b, hoverFillA, r, g, b, 1)
        else
            styleChromeButton(chrome.jump, idleFillR, idleFillG, idleFillB, idleFillA, r, g, b, idleEdgeA)
        end
    end
    if chrome.sync and chrome.sync:IsShown() then
        chrome.sync.text:SetTextColor(r, g, b)
        if chrome.sync.hovered then
            styleChromeButton(chrome.sync, r, g, b, hoverFillA, r, g, b, 1)
        else
            styleChromeButton(chrome.sync, idleFillR, idleFillG, idleFillB, idleFillA, r, g, b, idleEdgeA)
        end
    end
    if chrome.nav then
        chrome.nav.text:SetTextColor(r, g, b)
        if chrome.nav.hovered then
            styleChromeButton(chrome.nav, r, g, b, hoverFillA, r, g, b, 1)
        else
            styleChromeButton(chrome.nav, idleFillR, idleFillG, idleFillB, idleFillA, r, g, b, idleEdgeA)
        end
    end
    if chrome.settings then
        local standalone = ns.db and ns.db.standaloneGuide
        if standalone then
            chrome.settings:Show()
            if chrome.settings.icon then
                chrome.settings.icon:SetVertexColor(r, g, b, 1)
            end
            if chrome.settings.hovered then
                styleChromeButton(chrome.settings, r, g, b, hoverFillA, r, g, b, 1)
            else
                styleChromeButton(chrome.settings, idleFillR, idleFillG, idleFillB, idleFillA, r, g, b, idleEdgeA)
            end
        else
            chrome.settings:Hide()
        end
    end
    stylingButtons = false
end

createStepButton(-1, -42)
createStepButton(1, -24)

chrome.settings = CreateFrame("Button", nil, tracker, "BackdropTemplate")
chrome.settings:SetSize(16, 16)
chrome.settings:SetPoint("TOPRIGHT", -4, -6)
chrome.settings:SetFrameLevel(tracker:GetFrameLevel() + 25)
chrome.settings:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local settingsGlow = chrome.settings:CreateTexture(nil, "HIGHLIGHT")
settingsGlow:SetAllPoints()
useSolid(settingsGlow)
paintTexture(settingsGlow, 1, 1, 1, 0.14)
chrome.settings.glow = settingsGlow
chrome.settings:RegisterForClicks("LeftButtonUp")
chrome.settings.icon = chrome.settings:CreateTexture(nil, "OVERLAY")
chrome.settings.icon:SetSize(12, 12)
chrome.settings.icon:SetPoint("CENTER", 0, 0)
chrome.settings.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
chrome.settings:SetScript("OnClick", function()
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
chrome.settings:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Options", r, g, b)
    GameTooltip:AddLine("Open Waynotes settings.", 1, 1, 1, true)
    ns.FinishTooltip()
end)
chrome.settings:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
chrome.settings:SetScript("OnMouseDown", function(self)
    self.icon:SetPoint("CENTER", 1, -1)
end)
chrome.settings:SetScript("OnMouseUp", function(self, button)
    self.icon:SetPoint("CENTER", 0, 0)
    if button == "RightButton" and ns.OpenGuideMenu then
        ns.OpenGuideMenu()
    end
end)

chrome.jump = CreateFrame("Button", nil, tracker, "BackdropTemplate")
chrome.jump:SetSize(40, 16)
chrome.jump:SetPoint("TOPRIGHT", -64, -6)
chrome.jump:SetFrameLevel(tracker:GetFrameLevel() + 25)
chrome.jump:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local jumpGlow = chrome.jump:CreateTexture(nil, "HIGHLIGHT")
jumpGlow:SetAllPoints()
useSolid(jumpGlow)
paintTexture(jumpGlow, 1, 1, 1, 0.14)
chrome.jump.glow = jumpGlow
chrome.jump:RegisterForClicks("LeftButtonUp")
chrome.jump.text = chrome.jump:CreateFontString(nil, "OVERLAY")
chrome.jump.text:SetPoint("CENTER", 0, 0)
RG.applyFont(chrome.jump.text, 10, "OUTLINE")
chrome.jump.text:SetText("Jump")
chrome.jump:SetScript("OnClick", function()
    if StaticPopup_Show then
        StaticPopup_Show("WaynotesJump")
    end
end)
chrome.jump:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Jump to step", r, g, b)
    GameTooltip:AddLine("Enter a step number.", 1, 1, 1, true)
    ns.FinishTooltip()
end)
chrome.jump:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
chrome.jump:SetScript("OnMouseDown", function(self)
    self.text:SetPoint("CENTER", 1, -1)
end)
chrome.jump:SetScript("OnMouseUp", function(self, button)
    self.text:SetPoint("CENTER", 0, 0)
    if button == "RightButton" and ns.OpenGuideMenu then
        ns.OpenGuideMenu()
    end
end)

chrome.sync = CreateFrame("Button", nil, tracker, "BackdropTemplate")
chrome.sync:SetSize(36, 16)
chrome.sync:SetPoint("TOPRIGHT", -110, -6)
chrome.sync:SetFrameLevel(tracker:GetFrameLevel() + 25)
chrome.sync:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local syncGlow = chrome.sync:CreateTexture(nil, "HIGHLIGHT")
syncGlow:SetAllPoints()
useSolid(syncGlow)
paintTexture(syncGlow, 1, 1, 1, 0.14)
chrome.sync.glow = syncGlow
chrome.sync:RegisterForClicks("LeftButtonUp")
chrome.sync.text = chrome.sync:CreateFontString(nil, "OVERLAY")
chrome.sync.text:SetPoint("CENTER", 0, 0)
RG.applyFont(chrome.sync.text, 10, "OUTLINE")
chrome.sync.text:SetText("Sync")
chrome.sync:Hide()
chrome.sync:SetScript("OnClick", function(self)
    if ns.PartySyncOpenPicker then
        ns.PartySyncOpenPicker(self)
    end
end)
chrome.sync:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Sync with party", r, g, b)
    local target = ns.PartySyncFollowTarget and ns.PartySyncFollowTarget()
    if target then
        GameTooltip:AddLine("Following " .. target .. ". Click to change or stop.", 1, 1, 1, true)
    else
        GameTooltip:AddLine("Follow another Waynotes user's guide step.", 1, 1, 1, true)
    end
    ns.FinishTooltip()
end)
chrome.sync:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
chrome.sync:SetScript("OnMouseDown", function(self)
    self.text:SetPoint("CENTER", 1, -1)
end)
chrome.sync:SetScript("OnMouseUp", function(self, button)
    self.text:SetPoint("CENTER", 0, 0)
    if button == "RightButton" and ns.OpenGuideMenu then
        ns.OpenGuideMenu()
    end
end)

chrome.placeActions = function()
    local standalone = ns.UsingStandalone and ns.UsingStandalone()
    local showSync = standalone
        and chrome.sync
        and (
            (ns.PartySyncHasPeers and ns.PartySyncHasPeers())
            or (ns.PartySyncFollowing and ns.PartySyncFollowing())
        )
    if chrome.jump then
        chrome.jump:ClearAllPoints()
        chrome.jump:SetPoint("TOPRIGHT", -64, -6)
    end
    if showSync then
        chrome.sync:Show()
        chrome.sync:ClearAllPoints()
        chrome.sync:SetPoint("TOPRIGHT", -110, -6)
        if ns.PartySyncFollowing and ns.PartySyncFollowing() then
            chrome.sync.text:SetText("Synced")
            chrome.sync:SetWidth(44)
            if chrome.nav then
                chrome.nav:ClearAllPoints()
                chrome.nav:SetPoint("TOPRIGHT", -160, -6)
            end
            UI.HEADER_RIGHT = -194
        else
            chrome.sync.text:SetText("Sync")
            chrome.sync:SetWidth(36)
            if chrome.nav then
                chrome.nav:ClearAllPoints()
                chrome.nav:SetPoint("TOPRIGHT", -152, -6)
            end
            UI.HEADER_RIGHT = -186
        end
    else
        if chrome.sync then
            chrome.sync:Hide()
        end
        if chrome.nav then
            chrome.nav:ClearAllPoints()
            chrome.nav:SetPoint("TOPRIGHT", -110, -6)
        end
        UI.HEADER_RIGHT = -144
    end
    placeGuidePercent()
end

ns.RefreshPartySyncChrome = function()
    if chrome.placeActions then
        chrome.placeActions()
    end
    styleStepButtons()
end

chrome.nav = CreateFrame("Button", nil, tracker, "BackdropTemplate")
chrome.nav:SetSize(28, 16)
chrome.nav:SetPoint("TOPRIGHT", -110, -6)
chrome.nav:SetFrameLevel(tracker:GetFrameLevel() + 25)
chrome.nav:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
local navGlow = chrome.nav:CreateTexture(nil, "HIGHLIGHT")
navGlow:SetAllPoints()
useSolid(navGlow)
paintTexture(navGlow, 1, 1, 1, 0.14)
chrome.nav.glow = navGlow
chrome.nav:RegisterForClicks("LeftButtonUp")
chrome.nav.text = chrome.nav:CreateFontString(nil, "OVERLAY")
chrome.nav.text:SetPoint("CENTER", 0, 0)
RG.applyFont(chrome.nav.text, 10, "OUTLINE")
chrome.nav.text:SetText("Go")
chrome.nav:SetScript("OnClick", function(self)
    if ns.ToggleNavMenu then
        ns.ToggleNavMenu(self)
    end
end)
chrome.nav:SetScript("OnEnter", function(self)
    self.hovered = true
    styleStepButtons()
    local r, g, b = ns.Color("accent")
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Navigate", r, g, b)
    GameTooltip:AddLine("Find the nearest inn, bank, repair, class or profession trainer, and more.", 1, 1, 1, true)
    ns.FinishTooltip()
end)
chrome.nav:SetScript("OnLeave", function(self)
    self.hovered = false
    styleStepButtons()
    GameTooltip:Hide()
end)
chrome.nav:SetScript("OnMouseDown", function(self)
    self.text:SetPoint("CENTER", 1, -1)
end)
chrome.nav:SetScript("OnMouseUp", function(self, button)
    self.text:SetPoint("CENTER", 0, 0)
    if button == "RightButton" and ns.OpenGuideMenu then
        ns.OpenGuideMenu()
    end
end)

chrome.percent = tracker:CreateFontString(nil, "OVERLAY")
chrome.percent:SetHeight(16)
chrome.percent:SetJustifyH("RIGHT")
chrome.percent:SetJustifyV("MIDDLE")
if chrome.percent.SetWordWrap then
    chrome.percent:SetWordWrap(false)
end
RG.applyFont(chrome.percent, 12, "OUTLINE")
chrome.percent:Hide()

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
local updateFlyRecStrip
local updateHearthRecStrip
local updateNavStrip
local updateTrainStrip
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
        local bottom = 10
            + (State.flight.chrome or 0)
            + (State.flyRec.chrome or 0)
            + (State.hearthRec.chrome or 0)
            + (State.nav.chrome or 0)
            + (State.train.chrome or 0)
            + (State.corpse.chrome or 0)
        placeScroller(bottom)
        if State.flyRec.layout then
            State.flyRec.layout()
        end
        if State.hearthRec.layout then
            State.hearthRec.layout()
        end
        if State.nav.layout then
            State.nav.layout()
        end
        if State.train.layout then
            State.train.layout()
        end
        if State.corpse.layout then
            State.corpse.layout()
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
        if tracker:IsShown() then
            ns.MarkTrackerDirty(false)
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
        RG.applyFont(destText, 11, "")
        RG.applyFont(timeText, 11, "OUTLINE")
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
                if updateFlyRecStrip then
                    updateFlyRecStrip()
                end
            end
            return
        end

        if State.flyRec.chrome and State.flyRec.chrome > 0 and updateFlyRecStrip then
            updateFlyRecStrip()
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
    strip:SetHeight(UI.FLY_REC_STRIP)
    strip:SetPoint("BOTTOMLEFT", 1, 1)
    strip:SetPoint("BOTTOMRIGHT", -1, 1)
    strip:Hide()
    strip:EnableMouse(true)

    local flyRule = strip:CreateTexture(nil, "ARTWORK")
    flyRule:SetPoint("TOPLEFT", 8, 0)
    flyRule:SetPoint("TOPRIGHT", -8, 0)
    flyRule:SetHeight(1)
    useSolid(flyRule)
    paintTexture(flyRule, 1, 0.82, 0, 0.45)

    local title = strip:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 8, -3)
    title:SetPoint("RIGHT", strip, "RIGHT", -28, 0)
    title:SetHeight(12)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")
    if title.SetWordWrap then
        title:SetWordWrap(false)
    end
    RG.applyFont(title, 11, "")
    title:SetTextColor(0.9, 0.9, 0.86)

    local detail = strip:CreateFontString(nil, "OVERLAY")
    detail:SetPoint("TOPLEFT", 8, -14)
    detail:SetPoint("RIGHT", strip, "RIGHT", -28, 0)
    detail:SetHeight(11)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("MIDDLE")
    if detail.SetWordWrap then
        detail:SetWordWrap(false)
    end
    RG.applyFont(detail, 10, "")
    detail:SetTextColor(0.82, 0.82, 0.82)

    local close = CreateFrame("Button", nil, strip)
    close:SetSize(16, 16)
    close:SetPoint("TOPRIGHT", -8, -5)
    close:SetFrameLevel(strip:GetFrameLevel() + 5)
    close:RegisterForClicks("LeftButtonUp")
    close.text = close:CreateFontString(nil, "OVERLAY")
    close.text:SetPoint("CENTER", 0, 0)
    RG.applyFont(close.text, 12, "OUTLINE")
    close.text:SetText("x")

    State.flyRec.strip = strip
    State.flyRec.rule = flyRule
    State.flyRec.title = title
    State.flyRec.detail = detail
    State.flyRec.close = close
    State.flyRec.route = nil
    State.flyRec.dismissed = nil

    State.flyRec.layout = function()
        local lift = State.flight.chrome or 0
        strip:ClearAllPoints()
        strip:SetPoint("BOTTOMLEFT", 1, 1 + lift)
        strip:SetPoint("BOTTOMRIGHT", -1, 1 + lift)
    end

    local function setFlyRecChrome(want)
        want = want or 0
        if State.flyRec.chrome == want then
            return
        end
        State.flyRec.chrome = want
        if placeBottomChrome then
            placeBottomChrome()
        end
        State.remeasure = true
        State.lastSignature = nil
        if tracker:IsShown() then
            ns.MarkTrackerDirty(false)
        end
    end

    local function showFlyRec(on)
        if on then
            strip:Show()
            setFlyRecChrome(UI.FLY_REC_STRIP)
        else
            strip:Hide()
            setFlyRecChrome(0)
        end
    end

    local painted = false
    local lastTitle, lastDetail

    local function paintFlyRec(force)
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
        paintTexture(flyRule, edgeR, edgeG, edgeB, 0.45)
        RG.applyFont(title, 11, "")
        RG.applyFont(detail, 10, "")
        RG.applyFont(close.text, 12, "OUTLINE")
        title:SetTextColor(textR, textG, textB)
        detail:SetTextColor(detailR, detailG, detailB)
        close.text:SetTextColor(edgeR, edgeG, edgeB)
    end

    State.flyRec.paint = function()
        painted = false
        paintFlyRec(true)
    end

    local function routeKey(route)
        if type(route) ~= "table" then
            return nil
        end
        return tostring(route.departId or "") .. ":" .. tostring(route.arriveId or "")
    end

    local function goToDepart(route)
        local depart = route and route.depart
        if type(depart) ~= "table" or not ns.NavSetTarget then
            return
        end
        -- Prefer zone percents (e.g. Omusa 44.4, 59.2) over Forever map-world
        -- wx/wy so PinToPlayerWorld aims in UnitPosition space.
        ns.NavSetTarget({
            kind = "flight",
            name = depart.name or depart.hub,
            zone = depart.zone or depart.hub,
            hub = depart.hub,
            map = depart.map,
            x = depart.x,
            y = depart.y,
            wx = depart.wx,
            wy = depart.wy,
            instance = depart.instance,
            nodeId = depart.nodeId or route.departId,
            npc = depart.npc,
            forever = true,
        })
    end

    local function dismissFlyRec()
        State.flyRec.dismissed = routeKey(State.flyRec.route)
        State.flyRec.route = nil
        lastTitle, lastDetail = nil, nil
        updateFlyRecStrip()
    end

    close:SetScript("OnClick", function()
        dismissFlyRec()
    end)
    close:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            dismissFlyRec()
        end
    end)
    close:SetScript("OnEnter", function(self)
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Dismiss recommendation", r, g, b)
        ns.FinishTooltip()
    end)
    close:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    strip:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            dismissFlyRec()
            return
        end
        if button ~= "LeftButton" or close:IsMouseOver() then
            return
        end
        goToDepart(State.flyRec.route)
    end)
    strip:SetScript("OnEnter", function(self)
        if close:IsMouseOver() then
            return
        end
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Fly instead", r, g, b)
        GameTooltip:AddLine("Left-click to navigate to the departure flight master.", 1, 1, 1, true)
        GameTooltip:AddLine("Right-click to dismiss.", 0.75, 0.75, 0.75, true)
        ns.FinishTooltip()
    end)
    strip:SetScript("OnLeave", function()
        if close:IsMouseOver() then
            return
        end
        GameTooltip:Hide()
    end)

    function updateFlyRecStrip()
        local enabled = ns.db and ns.db.showFlightRecommend ~= false
        local onTaxi = UnitOnTaxi and UnitOnTaxi("player")
        local flying = (State.flight.chrome or 0) > 0 or onTaxi
        -- Paint only. Heavy TravelFlightRecommendation runs on route pulse.
        local route
        if enabled and not flying and tracker:IsShown() then
            route = ns.TravelActiveFlightRecommendation and ns.TravelActiveFlightRecommendation()
        end
        local key = routeKey(route)
        if key and State.flyRec.dismissed and State.flyRec.dismissed == key then
            route = nil
        elseif key and State.flyRec.dismissed and State.flyRec.dismissed ~= key then
            State.flyRec.dismissed = nil
        end

        if not route then
            if State.flyRec.chrome > 0 then
                showFlyRec(false)
            end
            State.flyRec.route = nil
            lastTitle, lastDetail = nil, nil
            return
        end

        State.flyRec.route = route
        if State.flyRec.chrome == 0 then
            showFlyRec(true)
            paintFlyRec(true)
        elseif not strip:IsShown() then
            strip:Show()
        end

        local titleText = route.summary or "Fly instead"
        if titleText ~= lastTitle then
            lastTitle = titleText
            title:SetText(titleText)
        end
        local savings = route.savingsYards
        local detailText
        if type(savings) == "number" then
            local yards = math.floor(savings + 0.5)
            if ns.NavFormatYards then
                detailText = "Saves " .. ns.NavFormatYards(yards) .. " on foot · click to go"
            else
                detailText = "Saves " .. yards .. " yd on foot · click to go"
            end
        else
            detailText = "Click to navigate to the flight master"
        end
        if detailText ~= lastDetail then
            lastDetail = detailText
            detail:SetText(detailText)
        end
    end
end

do
    local strip = CreateFrame("Frame", nil, tracker)
    strip:SetHeight(UI.HEARTH_REC_STRIP)
    strip:SetPoint("BOTTOMLEFT", 1, 1)
    strip:SetPoint("BOTTOMRIGHT", -1, 1)
    strip:Hide()
    strip:EnableMouse(true)

    local hearthRule = strip:CreateTexture(nil, "ARTWORK")
    hearthRule:SetPoint("TOPLEFT", 8, 0)
    hearthRule:SetPoint("TOPRIGHT", -8, 0)
    hearthRule:SetHeight(1)
    useSolid(hearthRule)
    paintTexture(hearthRule, 1, 0.82, 0, 0.45)

    local title = strip:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 8, -3)
    title:SetPoint("RIGHT", strip, "RIGHT", -52, 0)
    title:SetHeight(12)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")
    if title.SetWordWrap then
        title:SetWordWrap(false)
    end
    RG.applyFont(title, 11, "")
    title:SetTextColor(0.9, 0.9, 0.86)

    local detail = strip:CreateFontString(nil, "OVERLAY")
    detail:SetPoint("TOPLEFT", 8, -14)
    detail:SetPoint("RIGHT", strip, "RIGHT", -52, 0)
    detail:SetHeight(11)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("MIDDLE")
    if detail.SetWordWrap then
        detail:SetWordWrap(false)
    end
    RG.applyFont(detail, 10, "")
    detail:SetTextColor(0.82, 0.82, 0.82)

    local close = CreateFrame("Button", nil, strip)
    close:SetSize(16, 16)
    close:SetPoint("TOPRIGHT", -8, -5)
    close:SetFrameLevel(strip:GetFrameLevel() + 5)
    close:RegisterForClicks("LeftButtonUp")
    close.text = close:CreateFontString(nil, "OVERLAY")
    close.text:SetPoint("CENTER", 0, 0)
    RG.applyFont(close.text, 12, "OUTLINE")
    close.text:SetText("x")

    State.hearthRec.strip = strip
    State.hearthRec.rule = hearthRule
    State.hearthRec.title = title
    State.hearthRec.detail = detail
    State.hearthRec.close = close
    State.hearthRec.route = nil
    State.hearthRec.dismissed = nil

    State.hearthRec.layout = function()
        local lift = (State.flight.chrome or 0) + (State.flyRec.chrome or 0)
        strip:ClearAllPoints()
        strip:SetPoint("BOTTOMLEFT", 1, 1 + lift)
        strip:SetPoint("BOTTOMRIGHT", -1, 1 + lift)
    end

    local function setHearthRecChrome(want)
        want = want or 0
        if State.hearthRec.chrome == want then
            return
        end
        State.hearthRec.chrome = want
        if placeBottomChrome then
            placeBottomChrome()
        end
        State.remeasure = true
        State.lastSignature = nil
        if tracker:IsShown() then
            ns.MarkTrackerDirty(false)
        end
    end

    local function showHearthRec(on)
        if on then
            strip:Show()
            setHearthRecChrome(UI.HEARTH_REC_STRIP)
        else
            strip:Hide()
            setHearthRecChrome(0)
        end
    end

    local painted = false
    local lastTitle, lastDetail
    local hearthOnStrip = false

    local function paintHearthRec(force)
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
        paintTexture(hearthRule, edgeR, edgeG, edgeB, 0.45)
        RG.applyFont(title, 11, "")
        RG.applyFont(detail, 10, "")
        RG.applyFont(close.text, 12, "OUTLINE")
        title:SetTextColor(textR, textG, textB)
        detail:SetTextColor(detailR, detailG, detailB)
        close.text:SetTextColor(edgeR, edgeG, edgeB)
    end

    State.hearthRec.paint = function()
        painted = false
        paintHearthRec(true)
    end

    local function routeKey(route)
        if type(route) ~= "table" then
            return nil
        end
        return "hearth:" .. tostring(route.bindName or "")
    end

    local function detachHearthButton()
        if not hearthOnStrip or InCombatLockdown() then
            return
        end
        local button = ns.TravelHearthButton and ns.TravelHearthButton()
        if button then
            button:Hide()
            button:SetParent(UIParent)
            button:ClearAllPoints()
        end
        hearthOnStrip = false
    end

    local function attachHearthButton(bindName)
        local button = ns.TravelHearthButton and ns.TravelHearthButton()
        if not button then
            return
        end
        button.bindName = bindName
        if InCombatLockdown() then
            return
        end
        button:SetParent(strip)
        button:ClearAllPoints()
        button:SetSize(22, 22)
        button:SetPoint("RIGHT", close, "LEFT", -4, -2)
        button:SetFrameLevel(strip:GetFrameLevel() + 6)
        button:Show()
        hearthOnStrip = true
    end

    local function dismissHearthRec()
        State.hearthRec.dismissed = routeKey(State.hearthRec.route)
        State.hearthRec.route = nil
        lastTitle, lastDetail = nil, nil
        detachHearthButton()
        updateHearthRecStrip()
    end

    close:SetScript("OnClick", function()
        dismissHearthRec()
    end)
    close:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            dismissHearthRec()
        end
    end)
    close:SetScript("OnEnter", function(self)
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Dismiss recommendation", r, g, b)
        ns.FinishTooltip()
    end)
    close:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    strip:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            dismissHearthRec()
        end
    end)
    strip:SetScript("OnEnter", function(self)
        if close:IsMouseOver() then
            return
        end
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Hearth instead", r, g, b)
        GameTooltip:AddLine("Use the Hearthstone button when it saves walking distance.", 1, 1, 1, true)
        GameTooltip:AddLine("Right-click to dismiss.", 0.75, 0.75, 0.75, true)
        ns.FinishTooltip()
    end)
    strip:SetScript("OnLeave", function()
        if close:IsMouseOver() then
            return
        end
        GameTooltip:Hide()
    end)

    function updateHearthRecStrip()
        local onTaxi = UnitOnTaxi and UnitOnTaxi("player")
        local flying = (State.flight.chrome or 0) > 0 or onTaxi
        local route
        if not flying and tracker:IsShown() then
            route = ns.TravelActiveHearthRecommendation and ns.TravelActiveHearthRecommendation()
        end
        local key = routeKey(route)
        if key and State.hearthRec.dismissed and State.hearthRec.dismissed == key then
            route = nil
        elseif key and State.hearthRec.dismissed and State.hearthRec.dismissed ~= key then
            State.hearthRec.dismissed = nil
        end

        if not route then
            if State.hearthRec.chrome > 0 then
                showHearthRec(false)
            end
            State.hearthRec.route = nil
            lastTitle, lastDetail = nil, nil
            detachHearthButton()
            return
        end

        State.hearthRec.route = route
        if State.hearthRec.chrome == 0 then
            showHearthRec(true)
            paintHearthRec(true)
        elseif not strip:IsShown() then
            strip:Show()
        end

        attachHearthButton(route.bindName)

        local titleText = route.summary or "Hearth instead"
        if titleText ~= lastTitle then
            lastTitle = titleText
            title:SetText(titleText)
        end
        local savings = route.savingsYards
        local detailText
        if type(savings) == "number" and savings < math.huge then
            local yards = math.floor(savings + 0.5)
            if ns.NavFormatYards then
                detailText = "Saves " .. ns.NavFormatYards(yards) .. " on foot"
            else
                detailText = "Saves " .. yards .. " yd on foot"
            end
        else
            detailText = "Faster than walking from here"
        end
        if detailText ~= lastDetail then
            lastDetail = detailText
            detail:SetText(detailText)
        end
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
    arrow:SetSize(UI.GPS_ARROW_NAV, UI.GPS_ARROW_NAV)
    arrow:SetPoint("RIGHT", strip, "RIGHT", -28, -1)
    arrow:SetTexture(UI.GPS_ARROW)
    arrow:SetDrawLayer("OVERLAY", 2)

    local title = strip:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 8, -3)
    title:SetPoint("RIGHT", strip, "RIGHT", -102, 0)
    title:SetHeight(12)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")
    if title.SetWordWrap then
        title:SetWordWrap(false)
    end
    RG.applyFont(title, 11, "")
    title:SetTextColor(0.9, 0.9, 0.86)

    local detail = strip:CreateFontString(nil, "OVERLAY")
    detail:SetPoint("TOPLEFT", 8, -14)
    detail:SetPoint("RIGHT", strip, "RIGHT", -102, 0)
    detail:SetHeight(11)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("MIDDLE")
    if detail.SetWordWrap then
        detail:SetWordWrap(false)
    end
    RG.applyFont(detail, 10, "")
    detail:SetTextColor(0.82, 0.82, 0.82)

    local distText = strip:CreateFontString(nil, "OVERLAY")
    distText:SetPoint("TOPRIGHT", -46, -4)
    distText:SetWidth(52)
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
    clear:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" and ns.OpenGuideMenu then
            ns.OpenGuideMenu()
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
        local lift = (State.flight.chrome or 0)
            + (State.flyRec.chrome or 0)
            + (State.hearthRec.chrome or 0)
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
        if tracker:IsShown() then
            ns.MarkTrackerDirty(false)
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
        RG.applyFont(title, 11, "")
        RG.applyFont(detail, 10, "")
        RG.applyFont(distText, 11, "OUTLINE")
        RG.applyFont(clear.text, 12, "OUTLINE")
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
        if dest.kind == "profession" and dest.profession then
            return dest.profession .. " Trainer"
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
        -- Flight masters often arrive with Forever wx/wy only. Resolve once.
        if (type(dest.x) ~= "number" or type(dest.y) ~= "number") and ns.NavResolveTargetPin then
            ns.NavResolveTargetPin(dest)
        end
        if ns.PinToPlayerWorld and type(dest.x) == "number" and type(dest.y) == "number" then
            local wx, wy, instance = ns.PinToPlayerWorld(dest.map, dest.x, dest.y, dest.zone)
            if type(wx) == "number" and type(wy) == "number" then
                local wp = dest.waypoint
                if type(wp) == "table" then
                    wp.wx, wp.wy, wp.instance = wx, wy, instance
                else
                    dest.waypoint = { wx = wx, wy = wy, instance = instance }
                end
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
            if updateFlyRecStrip then
                updateFlyRecStrip()
            end
            if updateHearthRecStrip then
                updateHearthRecStrip()
            end
            if updateTrainStrip then
                updateTrainStrip()
            end
        end
    end
end

do
    local size = UI.TRAIN_NOTICE
    local strip = CreateFrame("Frame", nil, tracker)
    strip:SetSize(size + 12, size + 10)
    strip:SetPoint("BOTTOMRIGHT", -4, 4)
    strip:Hide()
    strip:SetFrameLevel((tracker:GetFrameLevel() or 0) + 20)
    strip:EnableMouse(false)

    local notice = CreateFrame("Button", nil, strip)
    notice:SetSize(size, size)
    notice:SetPoint("BOTTOMRIGHT", strip, "BOTTOMRIGHT", 0, 0)
    notice:RegisterForClicks("LeftButtonUp")
    notice:EnableMouse(true)

    local icon = notice:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(UI.GPS_NOTICE)

    local close = CreateFrame("Button", nil, strip)
    close:SetSize(14, 14)
    close:SetPoint("TOPRIGHT", notice, "TOPRIGHT", 5, 6)
    close:SetFrameLevel(notice:GetFrameLevel() + 5)
    close:RegisterForClicks("LeftButtonUp")
    close.text = close:CreateFontString(nil, "OVERLAY")
    close.text:SetPoint("CENTER", 0, 1)
    RG.applyFont(close.text, 11, "OUTLINE")
    close.text:SetText("x")

    State.train.strip = strip
    State.train.notice = notice
    State.train.icon = icon
    State.train.close = close
    State.train.level = nil
    State.train.chrome = 0

    local function trainDB()
        if type(WaynotesCharDB) ~= "table" then
            WaynotesCharDB = {}
        end
        if type(WaynotesCharDB.trainDismissed) ~= "table" then
            WaynotesCharDB.trainDismissed = {}
        end
        return WaynotesCharDB.trainDismissed
    end

    local function currentTrainLevel()
        local level = UnitLevel and UnitLevel("player") or 0
        if type(level) ~= "number" or level < 1 then
            return nil
        end
        if level > 60 then
            level = 60
        end
        return level
    end

    local function isDismissed(level)
        if not level then
            return true
        end
        return trainDB()[level] and true or false
    end

    local function dismissLevel(level)
        if not level then
            return
        end
        trainDB()[level] = true
        State.train.level = nil
    end

    local function spellKnown(spellId)
        if type(spellId) ~= "number" then
            return false
        end
        if IsPlayerSpell and IsPlayerSpell(spellId) then
            return true
        end
        if IsSpellKnown and IsSpellKnown(spellId) then
            return true
        end
        if C_SpellBook and C_SpellBook.IsSpellKnown then
            local ok, known = pcall(C_SpellBook.IsSpellKnown, spellId)
            if ok and known then
                return true
            end
        end
        return false
    end

    -- Live class-trainer window: count services marked "available".
    local function openTrainerAvailableCount()
        if IsTradeskillTrainer and IsTradeskillTrainer() then
            return nil
        end
        if type(GetNumTrainerServices) ~= "function" then
            return nil
        end
        local count = GetNumTrainerServices()
        if type(count) ~= "number" or count < 1 then
            return nil
        end
        local available = 0
        for index = 1, count do
            local _, _, category = GetTrainerServiceInfo(index)
            if category == "available" then
                available = available + 1
            end
        end
        return available
    end

    local missingCache = { at = -1, value = false }

    local function missingFromWhatsTraining()
        if type(WT_API) ~= "table" then
            return nil
        end
        local availableKey = WT_API.Status and WT_API.Status.AVAILABLE
        if type(availableKey) ~= "string" then
            return nil
        end
        -- Prefer live statuses once WT finishes its login cache.
        if WT_API.IsReady and WT_API.IsReady() and type(WT_API.GetSpells) == "function" then
            local spells = WT_API.GetSpells()
            if type(spells) ~= "table" then
                return false
            end
            for index = 1, #spells do
                local spell = spells[index]
                if type(spell) == "table"
                    and spell.status == availableKey
                    and not spell.quest
                    and not spell.isItem
                then
                    local source = WT_API.GetSource and WT_API.GetSource(spell.id)
                    if not source or source.kind == "trainer" then
                        if not (WT_API.IsIgnored and WT_API.IsIgnored(spell.id)) then
                            return true
                        end
                    end
                end
            end
            return false
        end
        -- Before Ready: walk the static catalog with IsSpellKnown.
        if type(WT_API.GetCatalog) ~= "function" or type(UnitClass) ~= "function" then
            return nil
        end
        local _, classToken = UnitClass("player")
        if type(classToken) ~= "string" then
            return nil
        end
        local ok, catalog = pcall(WT_API.GetCatalog, classToken)
        if not ok or type(catalog) ~= "table" then
            return nil
        end
        local level = UnitLevel and UnitLevel("player") or 0
        for index = 1, #catalog do
            local entry = catalog[index]
            if type(entry) == "table"
                and entry.kind == "trainer"
                and type(entry.id) == "number"
                and type(entry.level) == "number"
                and entry.level <= level
                and not spellKnown(entry.id)
            then
                local blocked = false
                if entry.requiredTalentId and not spellKnown(entry.requiredTalentId) then
                    blocked = true
                end
                if not blocked and type(entry.requiredIds) == "table" then
                    for reqIndex = 1, #entry.requiredIds do
                        if not spellKnown(entry.requiredIds[reqIndex]) then
                            blocked = true
                            break
                        end
                    end
                end
                if not blocked and not (WT_API.IsIgnored and WT_API.IsIgnored(entry.id)) then
                    return true
                end
            end
        end
        return false
    end

    -- Event-driven cache. TTL is only a safety net; SPELLS_CHANGED / trainer /
    -- level events invalidate. A short TTL re-walked What's Training for ~10ms+.
    local MISSING_CACHE_SECONDS = 120

    local function hasMissingAvailableSpells()
        local now = GetTime and GetTime() or 0
        if missingCache.value ~= nil and (now - missingCache.at) < MISSING_CACHE_SECONDS then
            return missingCache.value
        end
        local openCount = openTrainerAvailableCount()
        if type(openCount) == "number" then
            missingCache.at = now
            missingCache.value = openCount > 0
            if type(WaynotesCharDB) == "table" then
                WaynotesCharDB.trainHasAvailable = missingCache.value
            end
            return missingCache.value
        end
        local fromWt = missingFromWhatsTraining()
        if fromWt ~= nil then
            missingCache.at = now
            missingCache.value = fromWt and true or false
            return missingCache.value
        end
        -- Last known scan from a class trainer visit.
        if type(WaynotesCharDB) == "table" and WaynotesCharDB.trainHasAvailable ~= nil then
            missingCache.at = now
            missingCache.value = WaynotesCharDB.trainHasAvailable and true or false
            return missingCache.value
        end
        missingCache.at = now
        missingCache.value = false
        return false
    end

    local function invalidateMissingCache()
        missingCache.at = -1
    end

    -- SPELLS_CHANGED also fires for weapon swaps / skill noise. Debounce so a
    -- grind does not re-walk What's Training on every tick. Combat defers.
    local trainEventAt = 0
    local trainPending = false
    local function queueTrainStrip()
        if not tracker:IsShown() then
            return
        end
        if InCombatLockdown and InCombatLockdown() then
            trainPending = true
            return
        end
        local now = GetTime and GetTime() or 0
        if (now - trainEventAt) < 0.35 then
            return
        end
        trainEventAt = now
        C_Timer.After(0.35, function()
            if tracker:IsShown() and updateTrainStrip then
                updateTrainStrip()
            end
        end)
    end

    State.train.layout = function()
        local lift = (State.flight.chrome or 0)
            + (State.flyRec.chrome or 0)
            + (State.hearthRec.chrome or 0)
            + (State.nav.chrome or 0)
            + (State.corpse.chrome or 0)
        strip:ClearAllPoints()
        strip:SetPoint("BOTTOMRIGHT", -4, 4 + lift)
    end

    local function showTrain(on)
        if on then
            strip:Show()
            if State.train.layout then
                State.train.layout()
            end
        else
            strip:Hide()
        end
    end

    local painted = false

    local function paintTrain(force)
        if not ns.db then
            return
        end
        if painted and not force then
            return
        end
        painted = true
        local edgeR, edgeG, edgeB = ns.Color("accent")
        icon:SetVertexColor(edgeR, edgeG, edgeB, 1)
        RG.applyFont(close.text, 11, "OUTLINE")
        close.text:SetTextColor(edgeR, edgeG, edgeB)
    end

    State.train.paint = function()
        painted = false
        paintTrain(true)
    end

    local function trainerHint()
        local className = ns.PlayerClass and ns.PlayerClass() or nil
        local dest = ns.NavFindNearest and ns.NavFindNearest("trainer", className) or nil
        if not dest then
            return "Left-click to navigate to your nearest class trainer."
        end
        local where = dest.zone or dest.name or "trainer"
        if dest.name and dest.zone and dest.name ~= dest.zone then
            return "Left-click for " .. dest.name .. " · " .. dest.zone
        end
        return "Left-click for " .. where
    end

    local function goToTrainer()
        if ns.NavChoose then
            ns.NavChoose("trainer")
        end
    end

    local function dismissTrainNotice()
        dismissLevel(State.train.level or currentTrainLevel())
        updateTrainStrip()
    end

    close:SetScript("OnClick", function()
        dismissTrainNotice()
    end)
    close:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            dismissTrainNotice()
        end
    end)

    local tipShown = false
    local tipElapsed = 0

    local function placeTrainTip(owner)
        if State.placeCursorTooltip then
            State.placeCursorTooltip(owner)
        end
    end

    local function showNoticeTip(owner)
        tipShown = true
        tipElapsed = 0
        local level = State.train.level or currentTrainLevel()
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(owner, "ANCHOR_NONE")
        if level then
            GameTooltip:SetText("Train spells · level " .. level, r, g, b)
        else
            GameTooltip:SetText("Train class spells", r, g, b)
        end
        GameTooltip:AddLine(trainerHint(), 1, 1, 1, true)
        GameTooltip:AddLine("Right-click to dismiss for this level.", 0.75, 0.75, 0.75, true)
        ns.FinishTooltip()
        placeTrainTip(owner)
    end

    close:SetScript("OnEnter", function(self)
        tipShown = false
        local r, g, b = ns.Color("accent")
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetText("Dismiss for this level", r, g, b)
        ns.FinishTooltip()
        placeTrainTip(self)
        tipShown = true
    end)
    close:SetScript("OnLeave", function()
        tipShown = false
        GameTooltip:Hide()
        if notice:IsMouseOver() then
            showNoticeTip(notice)
        end
    end)

    notice:SetScript("OnClick", function()
        goToTrainer()
    end)
    notice:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            dismissTrainNotice()
        end
    end)
    notice:SetScript("OnEnter", function(self)
        if close:IsMouseOver() then
            return
        end
        showNoticeTip(self)
    end)
    notice:SetScript("OnLeave", function()
        if close:IsMouseOver() then
            return
        end
        tipShown = false
        GameTooltip:Hide()
    end)
    strip:SetScript("OnUpdate", function(_, delta)
        if not tipShown then
            return
        end
        if not notice:IsMouseOver() and not close:IsMouseOver() then
            tipShown = false
            GameTooltip:Hide()
            return
        end
        tipElapsed = tipElapsed + (delta or 0)
        if tipElapsed < 0.05 then
            return
        end
        tipElapsed = 0
        local owner = close:IsMouseOver() and close or notice
        placeTrainTip(owner)
    end)

    function updateTrainStrip()
        -- Trainer reminder never needs a mid-fight scan (~10ms What's Training walk).
        if InCombatLockdown and InCombatLockdown() then
            trainPending = true
            return
        end
        trainPending = false
        local enabled = ns.db and ns.db.showTrainReminders
        if not enabled or not tracker:IsShown() then
            if strip:IsShown() then
                showTrain(false)
            end
            State.train.level = nil
            return
        end
        local level = currentTrainLevel()
        -- Dismissed for this level: skip the spell catalog walk entirely.
        if not level or isDismissed(level) then
            if strip:IsShown() then
                showTrain(false)
            end
            State.train.level = nil
            return
        end
        local missing = hasMissingAvailableSpells()
        if not missing then
            if strip:IsShown() then
                showTrain(false)
            end
            State.train.level = nil
            return
        end

        State.train.level = level
        if not strip:IsShown() then
            showTrain(true)
            paintTrain(true)
        elseif State.train.layout then
            State.train.layout()
        end
    end

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_LEVEL_UP")
    watcher:RegisterEvent("TRAINER_SHOW")
    watcher:RegisterEvent("TRAINER_UPDATE")
    watcher:RegisterEvent("TRAINER_CLOSED")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    watcher:RegisterEvent("SPELLS_CHANGED")
    pcall(watcher.RegisterEvent, watcher, "LEARNED_SPELL_IN_TAB")
    pcall(watcher.RegisterEvent, watcher, "LEARNED_SPELL_IN_SKILL_LINE")
    watcher:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_ENABLED" then
            if trainPending then
                invalidateMissingCache()
                queueTrainStrip()
            end
            return
        end
        -- Combat: remember to rescan after, do not walk spells mid-fight.
        if InCombatLockdown and InCombatLockdown()
            and event ~= "TRAINER_SHOW"
            and event ~= "TRAINER_UPDATE"
            and event ~= "TRAINER_CLOSED"
            and event ~= "PLAYER_LEVEL_UP"
        then
            trainPending = true
            return
        end
        invalidateMissingCache()
        if event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
            if not (IsTradeskillTrainer and IsTradeskillTrainer()) then
                local available = openTrainerAvailableCount()
                if type(available) == "number" then
                    if type(WaynotesCharDB) ~= "table" then
                        WaynotesCharDB = {}
                    end
                    WaynotesCharDB.trainHasAvailable = available > 0
                    missingCache.at = GetTime and GetTime() or 0
                    missingCache.value = available > 0
                    -- Caught up: nothing left to train at this level.
                    if available <= 0 then
                        local level = State.train.level or currentTrainLevel()
                        if level then
                            dismissLevel(level)
                        end
                    end
                end
            end
        elseif event == "PLAYER_LEVEL_UP" then
            -- New level may unlock spells the static scan has not seen yet.
            if type(WaynotesCharDB) == "table" then
                WaynotesCharDB.trainHasAvailable = nil
            end
        end
        if event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" or event == "PLAYER_LEVEL_UP" then
            if tracker:IsShown() then
                updateTrainStrip()
            end
        else
            queueTrainStrip()
        end
    end)

    -- Prefer What's Training live status when that addon is present.
    if type(WT_API) == "table" and type(WT_API.RegisterCallback) == "function" then
        local owner = {}
        local function onWtEvent()
            invalidateMissingCache()
            queueTrainStrip()
        end
        pcall(WT_API.RegisterCallback, owner, WT_API.Event and WT_API.Event.READY or "Ready", onWtEvent)
        pcall(WT_API.RegisterCallback, owner, WT_API.Event and WT_API.Event.SPELLS_CHANGED or "SpellsChanged", onWtEvent)
        pcall(WT_API.RegisterCallback, owner, WT_API.Event and WT_API.Event.LEVEL_CHANGED or "LevelChanged", onWtEvent)
        pcall(WT_API.RegisterCallback, owner, WT_API.Event and WT_API.Event.IGNORED_CHANGED or "IgnoredChanged", onWtEvent)
    end
end

do
    local strip = CreateFrame("Frame", nil, tracker)
    strip:SetHeight(UI.CORPSE_STRIP)
    strip:SetPoint("BOTTOMLEFT", 1, 1)
    strip:SetPoint("BOTTOMRIGHT", -1, 1)
    strip:Hide()

    local corpseRule = strip:CreateTexture(nil, "ARTWORK")
    corpseRule:SetPoint("TOPLEFT", 8, 0)
    corpseRule:SetPoint("TOPRIGHT", -8, 0)
    corpseRule:SetHeight(1)
    useSolid(corpseRule)
    paintTexture(corpseRule, 1, 0.82, 0, 0.45)

    local arrow = strip:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(UI.GPS_ARROW_NAV, UI.GPS_ARROW_NAV)
    arrow:SetPoint("RIGHT", strip, "RIGHT", -10, -1)
    arrow:SetTexture(UI.GPS_ARROW)
    arrow:SetDrawLayer("OVERLAY", 2)

    local title = strip:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 8, -3)
    title:SetPoint("RIGHT", strip, "RIGHT", -78, 0)
    title:SetHeight(12)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")
    if title.SetWordWrap then
        title:SetWordWrap(false)
    end
    RG.applyFont(title, 11, "")
    title:SetTextColor(0.9, 0.9, 0.86)
    title:SetText("Your corpse")

    local detail = strip:CreateFontString(nil, "OVERLAY")
    detail:SetPoint("TOPLEFT", 8, -14)
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
    distText:SetWidth(48)
    distText:SetHeight(12)
    distText:SetJustifyH("RIGHT")
    distText:SetJustifyV("MIDDLE")
    RG.applyFont(distText, 11, "OUTLINE")
    distText:SetTextColor(1, 0.82, 0)

    State.corpse.strip = strip
    State.corpse.rule = corpseRule
    State.corpse.arrow = arrow
    State.corpse.title = title
    State.corpse.detail = detail
    State.corpse.dist = distText
    State.corpse.dest = nil

    State.corpse.layout = function()
        local lift = (State.flight.chrome or 0)
            + (State.flyRec.chrome or 0)
            + (State.hearthRec.chrome or 0)
            + (State.nav.chrome or 0)
            + (State.train.chrome or 0)
        strip:ClearAllPoints()
        strip:SetPoint("BOTTOMLEFT", 1, 1 + lift)
        strip:SetPoint("BOTTOMRIGHT", -1, 1 + lift)
    end

    local function setCorpseChrome(want)
        want = want or 0
        if State.corpse.chrome == want then
            return
        end
        State.corpse.chrome = want
        if placeBottomChrome then
            placeBottomChrome()
        end
        State.remeasure = true
        State.lastSignature = nil
        if tracker:IsShown() then
            ns.MarkTrackerDirty(false)
        end
    end

    local function showCorpse(on)
        if on then
            strip:Show()
            setCorpseChrome(UI.CORPSE_STRIP)
        else
            strip:Hide()
            setCorpseChrome(0)
        end
    end

    local painted = false
    local lastDetail, lastDist

    local function paintCorpse(force)
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
        paintTexture(corpseRule, edgeR, edgeG, edgeB, 0.45)
        RG.applyFont(title, 11, "")
        RG.applyFont(detail, 10, "")
        RG.applyFont(distText, 11, "OUTLINE")
        title:SetTextColor(textR, textG, textB)
        detail:SetTextColor(detailR, detailG, detailB)
        distText:SetTextColor(edgeR, edgeG, edgeB)
        if arrow.SetDesaturated then
            arrow:SetDesaturated(true)
        end
        arrow:SetVertexColor(edgeR, edgeG, edgeB, 1)
    end

    State.corpse.paint = function()
        painted = false
        paintCorpse(true)
    end

    local function readVectorXY(pos)
        if type(pos) ~= "table" then
            return nil
        end
        if type(pos.GetXY) == "function" then
            local ok, x, y = pcall(pos.GetXY, pos)
            if ok and type(x) == "number" and type(y) == "number" then
                return x, y
            end
        end
        if type(pos.x) == "number" and type(pos.y) == "number" then
            return pos.x, pos.y
        end
        return nil
    end

    local function toPercent(x, y)
        if type(x) ~= "number" or type(y) ~= "number" then
            return nil
        end
        if x <= 1 and y <= 1 then
            return x * 100, y * 100
        end
        return x, y
    end

    local function corpseMapPosition(map)
        if type(map) ~= "number" then
            return nil
        end
        if C_DeathInfo and type(C_DeathInfo.GetCorpseMapPosition) == "function" then
            local ok, pos = pcall(C_DeathInfo.GetCorpseMapPosition, map)
            if ok and pos then
                local x, y = toPercent(readVectorXY(pos))
                if x and (x ~= 0 or y ~= 0) then
                    return x, y
                end
            end
        end
        return nil
    end

    local function resolveCorpseDest()
        if not (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player")) then
            return nil
        end
        if C_Map and C_Map.GetBestMapForUnit then
            local map = C_Map.GetBestMapForUnit("player")
            local seen = {}
            while type(map) == "number" and not seen[map] do
                seen[map] = true
                local x, y = corpseMapPosition(map)
                if x then
                    local zone = (ns.MapName and ns.MapName(map))
                        or (ns.MapZoneName and ns.MapZoneName(map))
                        or (GetRealZoneText and GetRealZoneText())
                        or ""
                    return {
                        kind = "corpse",
                        name = "Your corpse",
                        map = map,
                        x = x,
                        y = y,
                        zone = zone,
                    }
                end
                local info = C_Map.GetMapInfo and C_Map.GetMapInfo(map)
                map = info and info.parentMapID or nil
            end
        end
        if type(GetCorpseMapPosition) == "function" then
            local x, y = GetCorpseMapPosition()
            x, y = toPercent(x, y)
            if x and (x ~= 0 or y ~= 0) then
                local map = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or nil
                local zone = (map and ns.MapName and ns.MapName(map))
                    or (GetRealZoneText and GetRealZoneText())
                    or ""
                return {
                    kind = "corpse",
                    name = "Your corpse",
                    map = map,
                    x = x,
                    y = y,
                    zone = zone,
                }
            end
        end
        return nil
    end

    local function ensureCorpseWaypoint(dest)
        if type(dest) ~= "table" or type(dest.x) ~= "number" or type(dest.y) ~= "number" then
            return nil
        end
        if ns.PinToPlayerWorld then
            local wx, wy, instance = ns.PinToPlayerWorld(dest.map, dest.x, dest.y, dest.zone)
            if type(wx) == "number" and type(wy) == "number" then
                dest.waypoint = { wx = wx, wy = wy, instance = instance }
                return dest.waypoint
            end
        end
        local hbd = RG.hereBeDragons()
        if hbd and hbd.GetWorldCoordinatesFromZone and type(dest.map) == "number" then
            local zx, zy = dest.x, dest.y
            if zx > 1 or zy > 1 then
                zx, zy = zx / 100, zy / 100
            end
            local wx, wy, instance = hbd:GetWorldCoordinatesFromZone(zx, zy, dest.map)
            if type(wx) == "number" and type(wy) == "number" then
                dest.waypoint = { wx = wx, wy = wy, instance = instance }
                return dest.waypoint
            end
        end
        return dest.waypoint
    end

    local function updateCorpseStrip()
        local enabled = not ns.db or ns.db.showCorpseTracker ~= false
        local dest = enabled and tracker:IsShown() and resolveCorpseDest() or nil
        State.corpse.dest = dest
        if not dest then
            arrow.__rxpbWp = nil
            if State.corpse.chrome > 0 then
                showCorpse(false)
            end
            lastDetail, lastDist = nil, nil
            return
        end

        if State.corpse.chrome == 0 then
            showCorpse(true)
            paintCorpse(true)
        elseif not strip:IsShown() then
            strip:Show()
        end

        local where = dest.zone or ""
        local coords = ns.NavFormatCoords and ns.NavFormatCoords(dest) or ""
        local detailText
        if where ~= "" and coords ~= "" then
            detailText = where .. "  " .. coords
        elseif coords ~= "" then
            detailText = coords
        else
            detailText = where ~= "" and where or "Run back to your body"
        end
        if detailText ~= lastDetail then
            lastDetail = detailText
            detail:SetText(detailText)
        end

        arrow.__rxpbWp = ensureCorpseWaypoint(dest)
    end

    State.corpse.update = updateCorpseStrip
    State.corpse._arrow = arrow
    State.corpse._distText = distText
    State.corpse._getLastDist = function()
        return lastDist
    end
    State.corpse._setLastDist = function(value)
        lastDist = value
    end

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_DEAD")
    watcher:RegisterEvent("PLAYER_ALIVE")
    watcher:RegisterEvent("PLAYER_UNGHOST")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:SetScript("OnEvent", function()
        lastDetail, lastDist = nil, nil
        if tracker:IsShown() then
            updateCorpseStrip()
        end
    end)
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
    if chrome.percent then
        RG.paint(chrome.percent, 12, edgeR, edgeG, edgeB)
    end
    local lightPanel = ns.IsLightBackground and ns.IsLightBackground()
    paintTexture(rule, edgeR, edgeG, edgeB, lightPanel and 0.28 or 0.55)
    if State.flight.paint then
        State.flight.paint()
    end
    if State.flyRec.paint then
        State.flyRec.paint()
    end
    if State.hearthRec.paint then
        State.hearthRec.paint()
    end
    if State.nav.paint then
        State.nav.paint()
    end
    if State.train.paint then
        State.train.paint()
    end
    if State.corpse.paint then
        State.corpse.paint()
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

    local wantStrata = ns.db.strata or "MEDIUM"
    if tracker:GetFrameStrata() ~= wantStrata then
        tracker:SetFrameStrata(wantStrata)
    end

    local parentScale = UIParent:GetEffectiveScale() or 1
    local frameScale = tracker:GetEffectiveScale() or parentScale
    if parentScale == 0 then
        parentScale = 1
    end
    local frameStrata = tracker:GetFrameStrata() or wantStrata
    local frameLevel = tracker:GetFrameLevel() or 10

    -- Glow/shadow live on UIParent so outside edges can draw freely; keep them
    -- matched to the tracker for fade, scale, and strata.
    local chromeAlpha = tracker:GetAlpha() or 1

    if ns.db.menuBorderGlow and tracker:IsShown() then
        local spread = clampGlowSpread(ns.db.menuGlowRadius)
        local glowR, glowG, glowB = ns.Color("glow")
        placeGlowHost(glowHost, tracker, parentScale, frameScale, frameStrata, math.max(1, frameLevel - 1))
        showSoftGlow(panelGlow, glowHost, spread, rounded and radius or 0, glowR, glowG, glowB)
        glowHost:SetAlpha(chromeAlpha)
    else
        hideSoftGlow(panelGlow)
        glowHost:Hide()
    end

    if ns.db.trackerShadow and tracker:IsShown() then
        local spread = 8
        local drop = 4
        shadowHost:SetScale(frameScale / parentScale)
        shadowHost:SetFrameStrata(lowerStrata(frameStrata))
        shadowHost:ClearAllPoints()
        shadowHost:SetPoint("TOPLEFT", tracker, "TOPLEFT", -spread, spread - drop)
        shadowHost:SetPoint("BOTTOMRIGHT", tracker, "BOTTOMRIGHT", spread, -(spread + drop))
        shadowHost:Show()
        showPlate(panelShadow, shadowHost, 0, 0, 0, 0, rounded and (radius + spread) or 0)
        paintPlate(panelShadow, 0, 0, 0, 0.4)
        shadowHost:SetAlpha(chromeAlpha)
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
    if not chrome then
        chrome = {
            fill = makePlate(frame, "BACKGROUND", 1),
            border = makePlate(frame, "BORDER", 1),
            mode = nil,
        }
        chrome.shadowHost = CreateFrame("Frame", nil, UIParent)
        chrome.shadowHost:Hide()
        chrome.shadow = makePlate(chrome.shadowHost, "ARTWORK", 1)
        frame.__waynotesChrome = chrome
        styledPopups[#styledPopups + 1] = frame
    end
    if not chrome.glowHost then
        chrome.glowHost = CreateFrame("Frame", nil, UIParent)
        chrome.glowHost:EnableMouse(false)
        chrome.glowHost:Hide()
        chrome.glow = makeSoftGlow(chrome.glowHost)
    elseif not chrome.glow or not chrome.glow.outside then
        if chrome.glow then
            hideSoftGlow(chrome.glow)
        end
        chrome.glow = makeSoftGlow(chrome.glowHost)
    end
    if not frame.__waynotesChromeHideHook then
        frame.__waynotesChromeHideHook = true
        frame:HookScript("OnHide", function()
            local stored = frame.__waynotesChrome
            if not stored then
                return
            end
            if stored.shadowHost then
                stored.shadowHost:Hide()
            end
            if stored.glowHost then
                stored.glowHost:Hide()
            end
        end)
    end
    return chrome
end

-- opts.matchTracker: use trackerBackground as-is (step list). Menus stay
-- near-opaque so they remain readable over bright world UI.
function ns.StylePopupFrame(frame, opts)
    if not frame or not ns.db then
        return
    end
    opts = opts or {}
    local matchTracker = opts.matchTracker or frame.__waynotesMatchTracker and true or false
    frame.__waynotesMatchTracker = matchTracker and true or nil
    local chrome = ensurePopupChrome(frame)
    local background = ns.db.trackerBackground
    if type(background) ~= "number" then
        background = 0.4
    end
    if not matchTracker and background < 0.94 then
        background = 0.94
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

    local parentScale = UIParent:GetEffectiveScale() or 1
    local frameScale = frame:GetEffectiveScale() or parentScale
    if parentScale == 0 then
        parentScale = 1
    end
    local frameStrata = frame:GetFrameStrata() or "DIALOG"
    local frameLevel = frame:GetFrameLevel() or 20
    local shadowStrata = lowerStrata(frameStrata)
    local shadowLevel = math.max(1, frameLevel - 2)

    if ns.db.menuBorderGlow and frame:IsShown() then
        local spread = clampGlowSpread(ns.db.menuGlowRadius)
        local glowR, glowG, glowB = ns.Color("glow")
        placeGlowHost(chrome.glowHost, frame, parentScale, frameScale, frameStrata, math.max(1, frameLevel - 1))
        showSoftGlow(chrome.glow, chrome.glowHost, spread, rounded and radius or 0, glowR, glowG, glowB)
    else
        hideSoftGlow(chrome.glow)
        chrome.glowHost:Hide()
    end

    if ns.db.trackerShadow and frame:IsShown() then
        local spread = 8
        local drop = 4
        local host = chrome.shadowHost
        host:SetScale(frameScale / parentScale)
        host:SetFrameStrata(shadowStrata)
        host:SetFrameLevel(shadowLevel)
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
            ns.StylePopupFrame(frame, {
                matchTracker = frame.__waynotesMatchTracker and true or false,
            })
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

function ns.OpenGuideMenu()
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
        ns.OpenGuideMenu()
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

-- Train strip (defined earlier) places tips through State.
State.placeCursorTooltip = placeCursorTooltip

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
    local visuals = ns.Visuals and ns.Visuals() or ns.db
    if visuals then
        local cap = visuals.arrowAlpha
        if type(cap) ~= "number" then
            cap = 1
        end
        if visuals.fadeInCombat and UnitAffectingCombat and UnitAffectingCombat("player") then
            local combat = visuals.combatAlpha
            if type(combat) == "number" and combat < cap then
                cap = combat
            end
        end
        alpha = alpha * cap
    end
    if texture.__rxpbAlpha ~= alpha then
        texture.__rxpbAlpha = alpha
        texture:SetAlpha(alpha)
    end
end

-- Match HereBeDragons:GetWorldVector so angle - GetPlayerFacing() is relative.
local function facingBearing(deltaX, deltaY)
    if type(deltaX) ~= "number" or type(deltaY) ~= "number" then
        return nil
    end
    if deltaX * deltaX + deltaY * deltaY <= 1e-12 then
        return nil
    end
    local angle = math.atan2(-deltaX, deltaY)
    if angle > 0 then
        return UI.PI2 - angle
    end
    return -angle
end

local function setNavIcon(texture, usePin)
    if not texture then
        return
    end
    local path = usePin and UI.GPS_PIN or UI.GPS_ARROW
    if texture.__rxpbNav == path then
        return
    end
    texture.__rxpbNav = path
    texture:SetTexture(path)
    texture.__rxpbRot = nil
    if texture.SetTexCoord then
        texture:SetTexCoord(0, 1, 0, 1)
    end
end

local function stickyCompleteGreen()
    local color = UI.STICKY_COMPLETE_GREEN
    return color[1], color[2], color[3]
end

local function beginStickyCompletions(items)
    State.completing = State.completing or {}
    State.stickyShown = State.stickyShown or {}
    local alive = {}
    for _, item in ipairs(items) do
        if item.sticky and type(item.stepIndex) == "number" then
            alive[item.stepIndex] = true
        end
    end
    for stepIndex, prev in pairs(State.stickyShown) do
        if not alive[stepIndex] and not State.completing[stepIndex] then
            State.completing[stepIndex] = {
                item = prev,
                alpha = 1,
                elapsed = 0,
            }
        end
    end
    local nextShown = {}
    for _, item in ipairs(items) do
        if item.sticky and type(item.stepIndex) == "number" then
            nextShown[item.stepIndex] = item
        end
    end
    State.stickyShown = nextShown
end

local function appendCompletingItems(items)
    if not State.completing or not next(State.completing) then
        return items
    end
    local out = {}
    for index, item in ipairs(items) do
        out[index] = item
    end
    for stepIndex, entry in pairs(State.completing) do
        local ghost = entry.item
        if ghost then
            ghost.__rxpbCompleting = true
            ghost.sticky = true
            ghost.stepIndex = stepIndex
            out[#out + 1] = ghost
        end
    end
    return out
end

local function updateCompletingStickies(dt)
    if not State.completing or not next(State.completing) then
        return
    end
    local finished = {}
    for stepIndex, entry in pairs(State.completing) do
        entry.elapsed = (entry.elapsed or 0) + (dt or 0)
        local hold = UI.STICKY_COMPLETE_HOLD or 0.15
        local fade = UI.STICKY_COMPLETE_FADE or 0.45
        local alpha = 1
        if entry.elapsed > hold then
            local t = fade > 0 and ((entry.elapsed - hold) / fade) or 1
            if t >= 1 then
                alpha = 0
                finished[#finished + 1] = stepIndex
            else
                alpha = 1 - t
            end
        end
        entry.alpha = alpha
        for _, row in ipairs(State.rows) do
            if row.__rxpbCompleting and row.stepIndex == stepIndex then
                row:SetAlpha(alpha)
                break
            end
        end
    end
    if #finished == 0 then
        return
    end
    for _, stepIndex in ipairs(finished) do
        State.completing[stepIndex] = nil
    end
    State.lastSignature = nil
    if ns.RefreshTracker then
        ns.RefreshTracker(true)
    end
end

local function rowNearYards(row)
    if row and row.pinOrder then
        local arrive = tonumber(row.arriveYards)
        if arrive and arrive > 0 then
            return arrive
        end
        if ns.DefaultNearYards then
            return ns.DefaultNearYards("travel")
        end
        return 10
    end
    local yards = row and tonumber(row.nearYards)
    if yards and yards > 0 then
        return yards
    end
    if ns.DefaultNearYards then
        return ns.DefaultNearYards("enemy")
    end
    return UI.KILL_AREA_YARDS
end

local function killAreaPin(row, dist)
    local nearYards = rowNearYards(row)
    if not row or not row.kill or type(dist) ~= "number" or dist > nearYards then
        return false
    end
    local place = row.place
    if not place or not ns.PinZoneDistance or type(place.x) ~= "number" then
        return false
    end
    -- PinZoneDistance is nil until the player is in the pin's zone.
    local zoneDist = ns.PinZoneDistance(place.map, place.x, place.y, place.zone)
    return type(zoneDist) == "number" and zoneDist <= nearYards
end

local function placeDistance(place)
    if type(place) ~= "table" or type(place.x) ~= "number" or type(place.y) ~= "number" then
        return nil
    end
    if ns.PinZoneDistance then
        local zoneDist = ns.PinZoneDistance(place.map, place.x, place.y, place.zone)
        if type(zoneDist) == "number" then
            return zoneDist
        end
    end
    if ns.CrossZoneVector then
        local cross = ns.CrossZoneVector(place.map, place.x, place.y, place.zone)
        if cross and type(cross.dist) == "number" then
            return cross.dist
        end
    end
end

local function pinVisitKey(row)
    if not row or type(row.stepIndex) ~= "number" then
        return nil
    end
    local guideId = ns.UsingStandalone and ns.UsingStandalone() and WaynotesCharDB and WaynotesCharDB.guide or "rxp"
    return tostring(guideId) .. ":" .. tostring(row.stepIndex)
end

local function pinVisitSet(row)
    local key = pinVisitKey(row)
    if not key then
        return nil
    end
    local set = State.pinVisits[key]
    if type(set) ~= "table" then
        set = {}
        State.pinVisits[key] = set
    end
    return set
end

-- Multi-pin steps: arrow the nearest unvisited spot; mark reached within
-- nearYards (default KILL_AREA_YARDS), then switch to the next nearest remaining pin.
-- Pins that leave out map share the step's map and zone, so distance and
-- arrow lookups do not fail on them.
local function inheritPinMaps(places, base)
    if type(places) ~= "table" then
        return places
    end
    if type(base) ~= "table" or type(base.map) ~= "number" then
        base = nil
        for _, place in ipairs(places) do
            if type(place) == "table" and type(place.map) == "number" then
                base = place
                break
            end
        end
    end
    if not base then
        return places
    end
    for _, place in ipairs(places) do
        if type(place) == "table" and type(place.map) ~= "number" then
            place.map = base.map
            place.zone = place.zone or base.zone
        end
    end
    return places
end

-- State.pinCycle[key] forces a pin until the player reaches it (Next Pin button).
-- The forced pin is only released after the player has been away from it, so
-- picking a pin the player is already standing on is not undone on the next refresh.
local function chooseStepPlace(row)
    local places = row and row.places
    if type(places) ~= "table" or #places == 0 then
        return row and row.place or nil
    end
    if #places == 1 then
        return places[1]
    end

    local visited = pinVisitSet(row) or {}
    local key = pinVisitKey(row)
    local nearYards = rowNearYards(row)

    -- Travel paths: walk pins in authored order. No nearest-jump, no cycle.
    if row.pinOrder then
        local targetIndex
        for index = 1, #places do
            if not visited[index] then
                targetIndex = index
                break
            end
        end
        if not targetIndex then
            targetIndex = #places
        else
            local dist = placeDistance(places[targetIndex])
            if type(dist) == "number" and dist <= nearYards then
                visited[targetIndex] = true
                if targetIndex < #places then
                    targetIndex = targetIndex + 1
                end
            end
        end
        local pending = 0
        for index = 1, #places do
            if not visited[index] then
                pending = pending + 1
            end
        end
        row.place = places[targetIndex]
        row.pinIndex = targetIndex
        row.pinPending = pending
        return places[targetIndex]
    end

    local forced = key and State.pinCycle[key]
    if type(forced) == "table" and places[forced.index] then
        local forcedDist = placeDistance(places[forced.index])
        local within = type(forcedDist) == "number" and forcedDist <= nearYards
        if within and forced.armed then
            visited[forced.index] = true
            State.pinCycle[key] = nil
        else
            if not within then
                forced.armed = true
            end
            local pending = 0
            for index in ipairs(places) do
                if not visited[index] then
                    pending = pending + 1
                end
            end
            row.place = places[forced.index]
            row.pinIndex = forced.index
            row.pinPending = pending
            return places[forced.index]
        end
    end

    local function nearest(onlyUnvisited)
        local best, bestDist, bestIndex
        local pending = 0
        for index, place in ipairs(places) do
            if onlyUnvisited and visited[index] then
                -- already cleared
            else
                if onlyUnvisited then
                    pending = pending + 1
                end
                local dist = placeDistance(place)
                if type(dist) == "number" and (not bestDist or dist < bestDist) then
                    best = place
                    bestDist = dist
                    bestIndex = index
                elseif not best and not onlyUnvisited then
                    best = place
                    bestIndex = index
                end
            end
        end
        return best, bestDist, bestIndex, pending
    end

    local best, bestDist, bestIndex, pending = nearest(true)
    if best and type(bestDist) == "number" and bestDist <= nearYards then
        visited[bestIndex] = true
        local nextPlace, nextDist, nextIndex = nearest(true)
        if nextPlace then
            best, bestDist, bestIndex = nextPlace, nextDist, nextIndex
        else
            -- Tour finished: keep guiding to the overall nearest spot.
            best, bestDist, bestIndex = nearest(false)
        end
    elseif not best then
        best, bestDist, bestIndex = nearest(false)
    end

    if best then
        row.place = best
        row.pinIndex = bestIndex
        row.pinPending = pending
    end
    return best or row.place
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

local function setCheckIcon(texture)
    if not texture then
        return
    end
    local path = UI.GPS_CHECK
    if texture.__rxpbNav ~= path then
        texture.__rxpbNav = path
        texture:SetTexture(path)
        if texture.SetTexCoord then
            texture:SetTexCoord(0, 1, 0, 1)
        end
    end
    setArrowRotation(texture, 0)
end

local function aimNavIcon(texture, shadow, usePin, angle, facing)
    setNavIcon(texture, usePin)
    setNavIcon(shadow, usePin)
    if usePin then
        local aimed = setArrowRotation(texture, 0)
        if shadow then
            setArrowRotation(shadow, 0)
        end
        return aimed
    end
    if type(angle) ~= "number" or type(facing) ~= "number" then
        return false
    end
    local rotation = angle - facing + (UI.GPS_ARROW_OFFSET or 0)
    local aimed = setArrowRotation(texture, rotation)
    if shadow then
        setArrowRotation(shadow, rotation)
    end
    return aimed
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

local function placeSameZoneAsPlayer(place, pmap)
    if type(place) ~= "table" then
        return false
    end
    if type(place.map) == "number" and type(pmap) == "number" and place.map == pmap then
        return true
    end
    local pinZone = place.zone
    if type(pinZone) ~= "string" and place.map and ns.MapZoneName then
        pinZone = ns.MapZoneName(place.map)
    end
    local pzone = GetRealZoneText and GetRealZoneText()
    if type(pinZone) ~= "string" or type(pzone) ~= "string" then
        return false
    end
    local a = pinZone:lower():gsub("^the%s+", "")
    local b = pzone:lower():gsub("^the%s+", "")
    return a ~= "" and b ~= "" and (a == b or a:find(b, 1, true) or b:find(a, 1, true))
end

-- Aim bearing for tracker arrows. Prefer same-zone percent bearing (matches the
-- yards we already show). World-space for other-zone pins — zone percents from
-- two different maps are not comparable and produce nonsense bearings.
-- Cross-zone wp must already be UnitPosition-aligned (see Nav.PinToPlayerWorld).
local function aimAngle(hbd, instance, px, py, wp, place, facing)
    local angle
    local source
    local youX, youY, pinX, pinY, east, south
    local sameZone = false

    if type(place) == "table" and type(place.x) == "number" and type(place.y) == "number" then
        pinX = place.x > 1 and place.x or place.x * 100
        pinY = place.y > 1 and place.y or place.y * 100
        local pzx, pzy, pmap = playerZonePosForAim(hbd)
        sameZone = type(pzx) == "number" and placeSameZoneAsPlayer(place, pmap)
        if sameZone then
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

    -- Cross-zone: C_Map .x/.y for the player and the pin, then the same
    -- zone-axis bearing used in-zone. UnitPosition vs HBD world is a different
    -- space and points the wrong way until the maps match.
    if not sameZone and type(place) == "table" and ns.CrossZoneVector and type(place.x) == "number" then
        local cross = ns.CrossZoneVector(place.map, place.x, place.y, place.zone)
        if cross and type(cross.east) == "number" and type(cross.south) == "number" then
            if cross.east * cross.east + cross.south * cross.south > 1e-12 then
                angle = facingBearing(-cross.east, -cross.south)
                source = "cmap"
            end
        end
    end

    if type(angle) ~= "number" and not sameZone then
        if type(hbdAngle) == "number" then
            angle = hbdAngle
            source = "hbd"
        elseif type(worldEast) == "number" and (worldEast * worldEast + (worldNorth or 0) * (worldNorth or 0) > 1e-12) then
            angle = facingBearing(worldEast, worldNorth)
            source = "world"
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

    -- Raw inputs only, in one reused table; /wn aim derives the rest on demand.
    local trace = ns.AimTrace
    if type(trace) ~= "table" then
        trace = {}
        ns.AimTrace = trace
    end
    trace.source = source or "none"
    trace.pinX, trace.pinY = pinX, pinY
    trace.youX, trace.youY = youX, youY
    trace.east, trace.south = east, south
    trace.angle, trace.facing, trace.hbdAngle = angle, facing, hbdAngle
    trace.worldEast, trace.worldNorth = worldEast, worldNorth

    return angle, source
end

function State.expandAimTrace(raw)
    local east, south = raw.east, raw.south
    local worldEast, worldNorth = raw.worldEast, raw.worldNorth
    return {
        source = raw.source,
        pinX = raw.pinX,
        pinY = raw.pinY,
        youX = raw.youX,
        youY = raw.youY,
        map = mapCardinal(east, south),
        bear = aimDeg(raw.angle),
        face = aimDeg(raw.facing),
        hbd = aimDeg(raw.hbdAngle),
        zoneEN = aimDeg(facingBearing(east or 0, -(south or 0))),
        zoneNegE = aimDeg(type(east) == "number" and facingBearing(-east, -(south or 0)) or nil),
        zoneES = aimDeg(type(east) == "number" and facingBearing(east, south or 0) or nil),
        zoneSW = aimDeg(type(east) == "number" and facingBearing(-east, south or 0) or nil),
        worldEN = aimDeg(type(worldEast) == "number" and facingBearing(worldEast, worldNorth) or nil),
        worldSwap = aimDeg(type(worldEast) == "number" and facingBearing(worldNorth, worldEast) or nil),
        worldNegE = aimDeg(type(worldEast) == "number" and facingBearing(-worldEast, worldNorth) or nil),
    }
end

State.aimLogUntil = 0
State.aimLogNext = 0

function ns.PrintAim()
    if type(ns.AimTrace) ~= "table" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r No aim sample yet. Show the guide arrow, then run /wn aim again.")
        return
    end
    local trace = State.expandAimTrace(ns.AimTrace)
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
    State.aimLogUntil = (GetTime and GetTime() or 0) + 12
    State.aimLogNext = 0
    DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r Logging aim for 12s. Walk around the target and keep it in front of you. Paste both lines from each sample.")
end

-- Shared strip-arrow aiming for nav / corpse (defined after tint helpers).
State.syncStripArrow = function(slot, facing, hbd, px, py, instance, resolve, dest)
    local arrow = slot and slot._arrow
    local distText = slot and slot._distText
    if not arrow then
        return
    end
    local wp = arrow.__rxpbWp
    local lastDist = slot._getLastDist and slot._getLastDist() or nil
    if not wp or not wp.wx or not wp.wy then
        arrow.__rxpbAimWp = nil
        if lastDist ~= "" then
            if slot._setLastDist then
                slot._setLastDist("")
            end
            if distText then
                distText:SetText("")
            end
        end
        setArrowAlpha(arrow, 0.35)
        return
    end

    if resolve or arrow.__rxpbAimWp ~= wp then
        arrow.__rxpbAimWp = wp
        local angle, source = aimAngle(hbd, instance, px, py, wp, dest, facing)
        arrow.__rxpbAngle = source ~= "onpin" and angle or nil
        arrow.__rxpbOnPin = source == "onpin"
        local dist = ns.NavDistance and ns.NavDistance(dest) or nil
        if type(dist) ~= "number" and dest and ns.PinZoneDistance and type(dest.x) == "number" then
            dist = ns.PinZoneDistance(dest.map, dest.x, dest.y, dest.zone)
        end

        local distLabel = type(dist) == "number" and formatYards(dist) or ""
        if distLabel ~= lastDist then
            if slot._setLastDist then
                slot._setLastDist(distLabel)
            end
            if distText then
                distText:SetText(distLabel)
            end
        end
    end

    local angle = arrow.__rxpbOnPin and facing or arrow.__rxpbAngle
    if aimNavIcon(arrow, nil, false, angle, facing) then
        setArrowAlpha(arrow, 1)
    else
        setArrowAlpha(arrow, 0.35)
    end
end

State.nav.syncArrow = function(facing, hbd, px, py, instance, canAim, resolve)
    local dest = ns.NavTarget and ns.NavTarget() or nil
    State.syncStripArrow(State.nav, facing, hbd, px, py, instance, resolve, dest)
end

State.corpse.syncArrow = function(facing, hbd, px, py, instance, canAim, resolve)
    State.syncStripArrow(State.corpse, facing, hbd, px, py, instance, resolve, State.corpse.dest)
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
    if type(place) ~= "table" then
        return nil
    end
    local zone = type(place.zone) == "string" and place.zone ~= "" and place.zone or nil
    if type(place.x) ~= "number" or type(place.y) ~= "number" then
        return zone
    end
    local coords = string.format("%.1f, %.1f", place.x, place.y)
    if zone then
        return zone .. " " .. coords
    end
    return coords
end

local function questLogIndex(questID)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local ok, index = pcall(C_QuestLog.GetLogIndexForQuestID, questID)
        if ok and type(index) == "number" and index > 0 then
            return index
        end
    end
    if not GetNumQuestLogEntries or not GetQuestLogTitle then
        return nil
    end
    local count = GetNumQuestLogEntries()
    for index = 1, count do
        local isHeader, id
        if C_QuestLog and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, index)
            if ok and type(info) == "table" then
                isHeader = info.isHeader
                id = info.questID
            end
        end
        if id == nil then
            local _, _, _, header, _, _, _, logID = GetQuestLogTitle(index)
            isHeader = header
            id = logID
        end
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
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo and C_QuestLog.ExpandQuestHeader then
        local ok, count = pcall(C_QuestLog.GetNumQuestLogEntries)
        count = ok and count or 0
        local index = 1
        local guard = 0
        while index <= count and guard < 80 do
            guard = guard + 1
            local infoOk, info = pcall(C_QuestLog.GetInfo, index)
            if infoOk and type(info) == "table" and info.isHeader and info.isCollapsed then
                pcall(C_QuestLog.ExpandQuestHeader, index)
                ok, count = pcall(C_QuestLog.GetNumQuestLogEntries)
                count = ok and count or count
            else
                index = index + 1
            end
        end
        return
    end
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

local function questLogIsShown()
    if QuestMapFrame and QuestMapFrame.IsShown and QuestMapFrame:IsShown() then
        return true
    end
    if QuestLogFrame and QuestLogFrame.IsShown and QuestLogFrame:IsShown() then
        return true
    end
    return false
end

local function openStepQuest(questID)
    if type(questID) ~= "number" then
        return
    end
    if not RG.playerOnQuest(questID) then
        return
    end

    -- Forever (and retail-style clients) keep legacy QuestLogFrame globals, but
    -- selection only sticks through C_QuestLog. Prefer that path first.
    if C_QuestLog and C_QuestLog.SetSelectedQuest then
        expandQuestHeaders()
        if QuestMapFrame_OpenToQuestDetails then
            pcall(QuestMapFrame_OpenToQuestDetails, questID)
            pcall(C_QuestLog.SetSelectedQuest, questID)
            return
        end
        if ToggleQuestLog and not questLogIsShown() then
            pcall(ToggleQuestLog)
        elseif QuestLogFrame and not questLogIsShown() then
            if ShowUIPanel then
                ShowUIPanel(QuestLogFrame)
            else
                QuestLogFrame:Show()
            end
        end
        pcall(C_QuestLog.SetSelectedQuest, questID)
        local index = questLogIndex(questID)
        if index and SelectQuestLogEntry then
            pcall(SelectQuestLogEntry, index)
        end
        if index and QuestLog_SetSelection then
            pcall(QuestLog_SetSelection, index)
        end
        if QuestLog_Update then
            pcall(QuestLog_Update)
        end
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
    end
end

local function questIdForRow(row)
    if not row then
        return nil
    end
    if type(row.questId) == "number" and RG.playerOnQuest(row.questId) then
        return row.questId
    end
    for _, quest in ipairs(row.stepQuests or {}) do
        local id = quest and quest.id
        if type(id) == "number" and (quest.on or RG.playerOnQuest(id)) then
            return id
        end
    end
    return row.questId
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
        local note = row.place and row.place.note
        if note and note ~= "" then
            where = where .. " · " .. note
        end
        GameTooltip:AddLine("Location: " .. where, 1, 1, 1, true)
    end
    if type(row.places) == "table" and #row.places > 1 then
        local visited = pinVisitSet(row)
        local done = 0
        if visited then
            for index = 1, #row.places do
                if visited[index] then
                    done = done + 1
                end
            end
        end
        GameTooltip:AddLine(string.format("Spots: %d/%d", done, #row.places), 0.8, 0.8, 0.8)
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
    if killAreaPin(row, dist) then
        GameTooltip:AddLine("NEAR", 1, 1, 1)
    elseif dist then
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
    row.places = inheritPinMaps(item.places, item.place)
    row.place = item.place
    row.tipWaypoint = item.waypoint
    row.keepTravelWaypoint = item.travel and true or nil
    row.kill = item.kill and true or nil
    row.nearYards = item.nearYards
    row.arriveYards = item.arriveYards
    row.pinOrder = item.pinOrder and true or nil
    row.tipTitle = RG.plainText(item.headline)
    if type(item.places) == "table" and #item.places > 1 then
        chooseStepPlace(row)
    end
end

local function refreshRowWaypoint(row)
    local place = chooseStepPlace(row)
    local hop = row.tipWaypoint
    if row.keepTravelWaypoint and hop and type(hop.wx) == "number" then
        local pmap = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        if not placeSameZoneAsPlayer(place, pmap) then
            if row.arrow then
                row.arrow.__rxpbWp = hop
            end
            return hop
        end
    end
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

local function cycleStepPin(row)
    local places = row and row.places
    if type(places) ~= "table" or #places < 2 then
        return
    end
    -- Travel paths are sequential; cycling is disabled.
    if row.pinOrder then
        return
    end
    local key = pinVisitKey(row)
    if not key then
        return
    end
    local current = row.pinIndex or 1
    if current < 1 or current > #places then
        current = 1
    end
    local nextIndex = (current % #places) + 1
    State.pinCycle[key] = { index = nextIndex, armed = false }
    row.place = places[nextIndex]
    row.pinIndex = nextIndex
    row.__rxpbAimStale = true
    refreshRowWaypoint(row)
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
    if place and ns.CrossZoneVector and type(place.x) == "number" then
        local cross = ns.CrossZoneVector(place.map, place.x, place.y, place.zone)
        if cross and type(cross.dist) == "number" then
            return cross.dist
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
        facing = facing + UI.PI2
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
    -- Waypoint, bearing, and distance only move as fast as the player walks, so
    -- resolve them at AIM_RESOLVE_SECONDS. Facing is applied every frame.
    local now = GetTime and GetTime() or 0
    local resolve = now >= (State.aimResolveAt or 0)
    if resolve then
        State.aimResolveAt = now + UI.AIM_RESOLVE_SECONDS
    end
    for _, row in ipairs(State.rows) do
        local arrow = row.arrow
        if arrow and arrow:IsShown() and not row.__rxpbCompleting then
            if resolve or row.__rxpbAimStale then
                row.__rxpbAimStale = nil
                local wp = refreshRowWaypoint(row)
                local angle, source = aimAngle(hbd, instance, x, y, wp, row.place, facing)
                local dist = rowPinDistance(row, wp, hbd, x, y, instance)
                row.__rxpbAngle = source ~= "onpin" and angle or nil
                row.__rxpbOnPin = source == "onpin"
                row.__rxpbUsePin = killAreaPin(row, dist)
                local distLabel = row.__rxpbUsePin and "NEAR" or (type(dist) == "number" and formatYards(dist) or "")
                if row.distance and row.__rxpbDistLabel ~= distLabel then
                    row.__rxpbDistLabel = distLabel
                    row.distance:SetText(distLabel)
                end
            end
            local angle = row.__rxpbOnPin and facing or row.__rxpbAngle
            local usePin = row.__rxpbUsePin

            local shadow = row.arrowShadow and row.arrowShadow:IsShown() and row.arrowShadow or nil
            if aimNavIcon(arrow, shadow, usePin, angle, facing) then
                setArrowAlpha(arrow, 1)
                if shadow then
                    setArrowAlpha(shadow, 0.9)
                end
            else
                setArrowAlpha(arrow, 0.35)
            end
            if now < (State.aimLogUntil or 0) and now >= (State.aimLogNext or 0) then
                State.aimLogNext = now + 1
                if ns.PrintAim then
                    ns.PrintAim()
                end
            end
        end
    end
    if State.nav.syncArrow then
        State.nav.syncArrow(facing, hbd, x, y, instance, canAim, resolve)
    end
    if State.corpse.syncArrow then
        State.corpse.syncArrow(facing, hbd, x, y, instance, canAim, resolve)
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
            row.__rxpbLinkTip = false
            row.__rxpbLinkOwner = nil
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

local function enableGuideHyperlinks(owner, fontString)
    if owner and owner.SetHyperlinksEnabled then
        pcall(owner.SetHyperlinksEnabled, owner, true)
    end
    if fontString and fontString.SetHyperlinksEnabled then
        pcall(fontString.SetHyperlinksEnabled, fontString, true)
    end
    if fontString and fontString.SetPropagateHyperlinksToParent then
        pcall(fontString.SetPropagateHyperlinksToParent, fontString, true)
    end
end

local function showGuideLinkTooltip(row, owner, link)
    if type(link) ~= "string" then
        return false
    end
    local kind, name = link:match("^waynotes:(%w+):(.+)$")
    if not kind or not name or not ns.ShowGuideEntityTooltip then
        return false
    end
    owner = owner or row
    setRowHover(row, true)
    if not row.__rxpbLinkTip then
        pauseRowStepTip(row)
    end
    row.__rxpbLinkTip = true
    row.__rxpbLinkOwner = owner
    if ns.ShowGuideEntityTooltip(owner, kind, name) then
        placeCursorTooltip(owner)
        return true
    end
    row.__rxpbLinkTip = false
    row.__rxpbLinkOwner = nil
    resumeRowStepTip(row)
    return false
end

local function hideGuideLinkTooltip(row)
    if not row or not row.__rxpbLinkTip then
        return
    end
    row.__rxpbLinkTip = false
    row.__rxpbLinkOwner = nil
    resumeRowStepTip(row)
end

local function bindGuideHyperlinkScripts(row)
    if not row or row.__rxpbLinkBound then
        return
    end
    row.__rxpbLinkBound = true
    local function onEnter(_, link)
        showGuideLinkTooltip(row, row, link)
    end
    local function onLeave()
        hideGuideLinkTooltip(row)
    end
    if row.SetScript then
        row:SetScript("OnHyperlinkEnter", onEnter)
        row:SetScript("OnHyperlinkLeave", onLeave)
    end
    for _, fs in ipairs({ row.text, row.details }) do
        if fs and fs.SetScript then
            pcall(fs.SetScript, fs, "OnHyperlinkEnter", function(self, link)
                showGuideLinkTooltip(row, self, link)
            end)
            pcall(fs.SetScript, fs, "OnHyperlinkLeave", onLeave)
        end
    end
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
        if self.__rxpbLinkTip then
            return
        end
        self.tipShown = true
        showStepTooltip(self)
    end)
    row:SetScript("OnLeave", function(self)
        if rowStillHovered(self) then
            return
        end
        setRowHover(self, false)
        self.tipShown = false
        self.__rxpbLinkTip = false
        self.__rxpbLinkOwner = nil
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
            ns.OpenGuideMenu()
            return
        end
        if button == "LeftButton" and not self.tipDragged then
            openStepQuest(questIdForRow(self))
        end
    end)
    local tipElapsed = 0
    row:SetScript("OnUpdate", function(self, delta)
        if self.__rxpbLinkTip then
            placeCursorTooltip(self.__rxpbLinkOwner or self)
            return
        end
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
        if button == "RightButton" then
            ns.OpenGuideMenu()
            return
        end
        if button ~= "LeftButton" or not self.stepIndex then
            return
        end
        GameTooltip:Hide()
        RG.skipListedStep(self.stepIndex, self.sticky)
    end)

    row.arrowShadow = row:CreateTexture(nil, "ARTWORK")
    row.arrowShadow:SetDrawLayer("ARTWORK", 1)
            row.arrowShadow:SetTexture(UI.GPS_ARROW)
    tintArrow(row.arrowShadow, 0, 0, 0, 0.8)
    row.arrowShadow:Hide()

    row.arrow = row:CreateTexture(nil, "OVERLAY")
    row.arrow:SetDrawLayer("OVERLAY", 2)
            row.arrow:SetTexture(UI.GPS_ARROW)
    tintArrow(row.arrow, 1, 0.82, 0, 1)
    row.arrow:Hide()

    row.distance = row:CreateFontString(nil, "OVERLAY")
    RG.applyFont(row.distance, 10, "OUTLINE")
    row.distance:SetJustifyH("CENTER")
    row.distance:SetJustifyV("TOP")
    row.distance:Hide()

    row.nextPin = CreateFrame("Button", nil, row)
    row.nextPin:SetSize(14, 14)
    row.nextPin:SetFrameLevel(row:GetFrameLevel() + 8)
    row.nextPin:RegisterForClicks("LeftButtonUp")
    row.nextPin:Hide()
    row.nextPin.icon = row.nextPin:CreateTexture(nil, "OVERLAY")
    row.nextPin.icon:SetAllPoints()
    row.nextPin.icon:SetTexture(UI.GPS_CYCLE)
    if row.nextPin.icon.SetDesaturated then
        row.nextPin.icon:SetDesaturated(true)
    end
    row.nextPin:SetScript("OnClick", function(self)
        cycleStepPin(self:GetParent())
    end)
    row.nextPin:SetScript("OnEnter", function(self)
        local parent = self:GetParent()
        setRowHover(parent, true)
        pauseRowStepTip(parent)
        self.hovered = true
        local ar, ag, ab = ns.Color("accent")
        if self.icon then
            self.icon:SetVertexColor(ar, ag, ab, 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetText("Next Pin", ar, ag, ab)
        GameTooltip:AddLine("Cycle to the next location for this step.", 1, 1, 1, true)
        ns.FinishTooltip()
        placeCursorTooltip(self)
    end)
    row.nextPin:SetScript("OnLeave", function(self)
        self.hovered = false
        local ar, ag, ab = ns.Color("accent")
        if self.icon then
            self.icon:SetVertexColor(ar, ag, ab, 0.85)
        end
        GameTooltip:Hide()
        local parent = self:GetParent()
        if rowStillHovered(parent) then
            if parent then
                parent.tipShown = true
                showStepTooltip(parent)
            end
            return
        end
        setRowHover(parent, false)
        if parent then
            parent.tipShown = false
        end
    end)
    row.nextPin:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() and self.icon then
            self.icon:ClearAllPoints()
            self.icon:SetPoint("TOPLEFT", 1, -1)
            self.icon:SetPoint("BOTTOMRIGHT", 1, -1)
        end
    end)
    row.nextPin:SetScript("OnMouseUp", function(self, button)
        if self.icon then
            self.icon:ClearAllPoints()
            self.icon:SetAllPoints()
        end
        if button == "RightButton" then
            ns.OpenGuideMenu()
        end
    end)

    row.text = row:CreateFontString(nil, "OVERLAY")
    RG.paint(row.text, 13, 1, 1, 1)
    row.details = row:CreateFontString(nil, "OVERLAY")
    RG.paint(row.details, 12, 0.82, 0.82, 0.82)
    enableGuideHyperlinks(row, row.text)
    enableGuideHyperlinks(row, row.details)
    bindGuideHyperlinkScripts(row)
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
        local expanded = parent and parent.__rxpbTipsExpanded
        local tips = parent and ((expanded and parent.__rxpbTips) or parent.__rxpbHiddenTips or parent.__rxpbTips)
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
        elseif expanded then
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
    row.more:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            ns.OpenGuideMenu()
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
    row.loadGuide:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            ns.OpenGuideMenu()
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
        button:HookScript("OnMouseUp", function(_, click)
            if click == "RightButton" then
                ns.OpenGuideMenu()
            end
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

-- Our guide text tags use |cRB_*| (Waynotes) or authoring sugar [TAG]…[/].
-- Colors live on UI.GUIDE_TAG_COLORS.

local GUIDE_TAG_NAMES = { "FRIENDLY", "ENEMY", "LOOT", "PICK", "BUY", "QUEST", "WARN", "SKILL" }

-- Tagged names that resolve through QuestieDB for hover tooltips.
local GUIDE_TAG_LINK = {
    FRIENDLY = "npc",
    ENEMY = "npc",
    LOOT = "item",
    BUY = "item",
    PICK = "object",
}

-- [FRIENDLY]Kaya Flathoof[/] or [FRIENDLY]Kaya Flathoof[/FRIENDLY] → |cRB_FRIENDLY_…|r
-- Body may not contain brackets so nested tags expand innermost-first.
local function expandBracketGuideTags(text)
    if type(text) ~= "string" or not text:find("[", 1, true) then
        return text, 0
    end
    local total = 0
    for _, name in ipairs(GUIDE_TAG_NAMES) do
        local nextText, count = text:gsub(
            "%[" .. name .. "%]([^%[%]]-)%[/" .. name .. "%]",
            "|cRB_" .. name .. "_%1|r"
        )
        text = nextText
        total = total + count
        nextText, count = text:gsub(
            "%[" .. name .. "%]([^%[%]]-)%[/%]",
            "|cRB_" .. name .. "_%1|r"
        )
        text = nextText
        total = total + count
    end
    return text, total
end

local function colorGuideTag(kind, hex, body)
    local colored = "|c" .. hex .. body .. "|r"
    if not kind
        or type(body) ~= "string"
        or body == ""
        or body:find("|", 1, true)
        or not ns.QuestieReady
        or not ns.QuestieReady() then
        return colored
    end
    return "|Hwaynotes:" .. kind .. ":" .. body .. "|h" .. colored .. "|h"
end

local function expandGuideTags(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    text = text:gsub("|T.-|t", "")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|n", "\n")

    -- Innermost tags first so nested FRIENDLY/ENEMY inside WARN resolve.
    for _ = 1, 8 do
        local changed = false
        local bracketed
        text, bracketed = expandBracketGuideTags(text)
        if bracketed > 0 then
            changed = true
        end
        for _, name in ipairs(GUIDE_TAG_NAMES) do
            local key = "RB_" .. name .. "_"
            local hex = UI.GUIDE_TAG_COLORS[key]
            if hex then
                local kind = GUIDE_TAG_LINK[name]
                local nextText, count = text:gsub("|c" .. key .. "(.-)|r", function(body)
                    return colorGuideTag(kind, hex, body)
                end)
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

-- Accent-color untagged spans; leave colored and hyperlink spans alone.
local function presentPlain(text, names, quests, highlightNames)
    if type(text) ~= "string" or text == "" then
        return ""
    end
    local expanded = expandGuideTags(text)
    local out = {}
    local cursor = 1
    while true do
        local linkFirst, linkLast = expanded:find("|H.-|h.-|h", cursor)
        local colorFirst, colorLast, hex, body = expanded:find("|c(%x%x%x%x%x%x%x%x)(.-)|r", cursor)
        local first = linkFirst
        local useLink = true
        if colorFirst and (not linkFirst or colorFirst < linkFirst) then
            first = colorFirst
            useLink = false
        end
        if not first then
            out[#out + 1] = accentPlain(expanded:sub(cursor), names, quests, highlightNames)
            break
        end
        if first > cursor then
            out[#out + 1] = accentPlain(expanded:sub(cursor, first - 1), names, quests, highlightNames)
        end
        if useLink then
            out[#out + 1] = expanded:sub(linkFirst, linkLast)
            cursor = linkLast + 1
        else
            out[#out + 1] = "|c" .. hex .. body .. "|r"
            cursor = colorLast + 1
        end
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

local function tipHiddenWhenCollapsed(line, note)
    if type(note) == "string" and note ~= "" and line == note then
        -- Authored guide notes stay visible while other tips nest.
        return false
    end
    return true
end

local function visibleDetailLines(item, index)
    local details = item and item.details or {}
    local objectives, tips = splitDetails(details)
    local note = item and item.note
    local hiddenTips = 0
    for _, line in ipairs(tips) do
        if tipHiddenWhenCollapsed(line, note) then
            hiddenTips = hiddenTips + 1
        end
    end
    -- Nest tip notes under progress/accept/turn-in lines only, and only when
    -- collapse would actually hide something. A lone authored note already
    -- stays visible, so nesting it behind "+ more notes" is a no-op.
    local shouldNest = hiddenTips >= 1 and #objectives >= 1
    if not shouldNest then
        return joinDetails(objectives, tips), false, false, #tips
    end
    local expanded = State.expandedTips[tipKey(item, index)] and true or false
    if expanded then
        return joinDetails(objectives, tips), true, true, #tips
    end
    local shown = {}
    for _, line in ipairs(objectives) do
        shown[#shown + 1] = line
    end
    if type(note) == "string" and note ~= "" then
        local already = false
        for _, line in ipairs(shown) do
            if line == note then
                already = true
                break
            end
        end
        if not already then
            shown[#shown + 1] = note
        end
    end
    return shown, true, false, #tips
end

local function applyRowText(row, item, index)
    row.__rxpbItem = item
    local main = index == 1
    local textR, textG, textB = ns.Color(main and "text" or "secondary")
    RG.paint(row.text, main and 16 or 13, textR, textG, textB)
    row.text:SetText(presentHeadline(item))
    local _, tipLines = splitDetails(item and item.details)
    local note = item and item.note
    local hiddenTips = {}
    for _, line in ipairs(tipLines or {}) do
        if tipHiddenWhenCollapsed(line, note) then
            hiddenTips[#hiddenTips + 1] = line
        end
    end
    row.__rxpbTips = tipLines
    row.__rxpbHiddenTips = hiddenTips
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
    local chrome = UI.TRACKER_CHROME
        + (State.flight.chrome or 0)
        + (State.flyRec.chrome or 0)
        + (State.hearthRec.chrome or 0)
        + (State.nav.chrome or 0)
        + (State.train.chrome or 0)
        + (State.corpse.chrome or 0)
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
    local chrome = UI.TRACKER_CHROME
        + (State.flight.chrome or 0)
        + (State.flyRec.chrome or 0)
        + (State.hearthRec.chrome or 0)
        + (State.nav.chrome or 0)
        + (State.train.chrome or 0)
        + (State.corpse.chrome or 0)
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
    if done == nil or total == nil or total <= 1 then
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

local function syncProgressBars(row, item, textLeft, rightInset, bottomPad)
    if textLeft then
        row.__rxpbBarLeft = textLeft
        row.__rxpbBarRight = rightInset or 0
    end
    if bottomPad ~= nil then
        row.__rxpbBarPad = bottomPad
    end
    textLeft = textLeft or row.__rxpbBarLeft
    rightInset = rightInset or row.__rxpbBarRight or 0
    bottomPad = bottomPad or row.__rxpbBarPad or 0
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
    local light = ns.IsLightBackground and ns.IsLightBackground()
    for index, ratio in ipairs(ratios) do
        local holder = ensureProgressBar(row, index)
        holder:Show()
        holder:ClearAllPoints()
        -- Stay bottom-anchored (under tall arrow columns). bottomPad lifts the
        -- bars so action buttons can sit beneath them.
        local y = bottomPad + 1 + (#ratios - index) * (UI.PROGRESS_BAR_HEIGHT + UI.PROGRESS_BAR_GAP)
        holder:SetPoint("BOTTOMLEFT", textLeft, y)
        holder:SetPoint("BOTTOMRIGHT", -rightInset, y)
        if light then
            holder:SetBackdropColor(accentR, accentG, accentB, 0.14)
            holder:SetBackdropBorderColor(accentR, accentG, accentB, 0.35)
        else
            holder:SetBackdropColor(0, 0, 0, 0.6)
            holder:SetBackdropBorderColor(accentR, accentG, accentB, 0.4)
        end
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
            local row = State.rows[index]
            row.__rxpbCompleting = nil
            row:SetAlpha(1)
            row:Hide()
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
        local arrowSize = main and UI.GPS_ARROW_MAIN or UI.GPS_ARROW_ROW
        local completing = item.__rxpbCompleting and true or false
        row.__rxpbCompleting = completing or nil
        local hasPin = item.waypoint or (item.place and type(item.place.x) == "number" and type(item.place.y) == "number")
        local multiPin = type(item.places) == "table" and #item.places > 1
        local canCyclePins = multiPin and not item.pinOrder
        if completing and row.arrow then
            local tintR, tintG, tintB = stickyCompleteGreen()
            local centerX = -2 - (UI.ARROW_COLUMN / 2)
            local entry = State.completing and State.completing[item.stepIndex]
            row:SetAlpha(entry and entry.alpha or 1)
            setCheckIcon(row.arrow)
            tintArrow(row.arrow, tintR, tintG, tintB, 1)
            setArrowAlpha(row.arrow, 1)
            row.arrow:Show()
            row.arrow:ClearAllPoints()
            row.arrow:SetSize(arrowSize, arrowSize)
            row.arrow:SetPoint("CENTER", row, "TOPRIGHT", centerX, -arrowSize / 2)
            row.arrow.__rxpbWp = nil
            row.arrow:SetDrawLayer("OVERLAY", 2)
            if row.arrowShadow then
                row.arrowShadow:Hide()
            end
            if row.nextPin then
                row.nextPin:Hide()
            end
            if row.distance then
                row.distance:Hide()
                row.distance:SetText("")
                row.__rxpbDistLabel = nil
            end
            rightInset = UI.ARROW_COLUMN + 6
        elseif hasPin and row.arrow then
            row:SetAlpha(1)
            local tintR, tintG, tintB = arrowTint()
            local cycleSize = 12
            local cycleGap = 2
            local centerX = -2 - (UI.ARROW_COLUMN / 2)
            if canCyclePins then
                centerX = centerX - (cycleSize + cycleGap) / 2
            end
            -- Restore arrow/pin if this row previously showed the sticky check.
            if row.arrow.__rxpbNav == UI.GPS_CHECK then
                row.arrow.__rxpbNav = nil
            end
            tintArrow(row.arrow, tintR, tintG, tintB, 1)
            row.arrow:Show()
            row.arrow:ClearAllPoints()
            row.arrow:SetSize(arrowSize, arrowSize)
            row.arrow:SetPoint("CENTER", row, "TOPRIGHT", centerX, -arrowSize / 2)
            -- Force aim path to re-apply texcoords after layout resize.
            row.arrow.__rxpbRot = nil
            row.places = inheritPinMaps(item.places, item.place)
            row.place = item.place
            row.stepIndex = item.stepIndex
            row.pinOrder = item.pinOrder and true or nil
            row.arriveYards = item.arriveYards
            row.arrow.__rxpbWp = item.waypoint
            refreshRowWaypoint(row)
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
            if canCyclePins and row.nextPin then
                local ar, ag, ab = ns.Color("accent")
                row.nextPin:SetSize(cycleSize, cycleSize)
                row.nextPin:Show()
                row.nextPin:ClearAllPoints()
                row.nextPin:SetPoint("LEFT", row.arrow, "RIGHT", cycleGap, 0)
                if row.nextPin.icon then
                    row.nextPin.icon:SetVertexColor(ar, ag, ab, row.nextPin.hovered and 1 or 0.85)
                end
            elseif row.nextPin then
                row.nextPin:Hide()
            end
            rightInset = UI.ARROW_COLUMN + 6
        elseif row.arrow then
            row:SetAlpha(1)
            row.arrow:Hide()
            row.arrow.__rxpbWp = nil
            if row.arrowShadow then
                row.arrowShadow:Hide()
            end
            if row.nextPin then
                row.nextPin:Hide()
            end
            if row.distance then
                row.distance:Hide()
                row.distance:SetText("")
            end
        else
            row:SetAlpha(1)
            if row.nextPin then
                row.nextPin:Hide()
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

        local contentHeight = textHeight + detailHeight + moreHeight + loadHeight
        local actions = item.actions or {}
        local actionHeight = 0
        local stride = 26
        local perRow = 1
        if #actions > 0 then
            local avail = width - 24 - textLeft - rightInset
            perRow = math.max(1, math.floor(avail / stride))
            actionHeight = (math.floor((#actions - 1) / perRow) + 1) * stride + 2
        end

        local navHeight = (hasPin or completing) and (arrowSize + 17) or 0
        -- Progress stays at the bottom of the row (above any action buttons).
        local barHeight = syncProgressBars(row, item, textLeft, rightInset, actionHeight)
        local blockHeight = math.max(badgeSize, contentHeight, navHeight) + barHeight + actionHeight
        row:SetHeight(blockHeight)

        if #actions > 0 then
            local yBase = blockHeight - actionHeight
            for actionIndex, button in ipairs(actions) do
                local col = (actionIndex - 1) % perRow
                local line = math.floor((actionIndex - 1) / perRow)
                placeAction(button, row, textLeft + (col * stride), -(yBase + (line * stride)))
                seenActions[button] = true
            end
        end

        y = y + blockHeight + (main and 10 or 6)
    end

    for index = count + 1, #State.rows do
        local row = State.rows[index]
        row.__rxpbCompleting = nil
        row:SetAlpha(1)
        row:Hide()
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

-- Nested function keeps map-pin locals off the main chunk's 200-local budget.
(function()
    -- Step badges drawn straight onto the world map canvas. Guide pins carry
    -- Classic UiMap ids, which Forever renumbers, so a pin is matched to the
    -- shown map by zone name rather than converted through world coordinates.
    local BADGE = {
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    }

    local frames = State.mapPins.frames
    local entries = {}
    local provider

    local function isNum(value)
        return type(value) == "number" and value == value
    end

    local function fraction(value)
        if not isNum(value) then
            return nil
        end
        if value > 1 then
            return value / 100
        end
        return value
    end

    local function worldMap()
        local map = rawget(_G, "WorldMapFrame")
        local scroll = map and map.ScrollContainer
        local child = scroll and scroll.Child
        if not child then
            return nil
        end
        return map, scroll, child
    end

    local function clearStepMapPins()
        wipe(entries)
        if provider then
            pcall(provider.RemoveAllData, provider)
        end
        for _, frame in ipairs(frames) do
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetParent(UIParent)
        end
        State.mapPins.signature = nil
    end

    local function acquireStepMapPin(index)
        local frame = frames[index]
        if frame then
            return frame
        end
        frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        frame:Hide()
        frame:SetSize(22, 22)
        frame:SetBackdrop(BADGE)
        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetAllPoints()
        frame.text:SetJustifyH("CENTER")
        frame.text:SetJustifyV("MIDDLE")
        if frame.text.SetWordWrap then
            frame.text:SetWordWrap(false)
        end
        RG.applyFont(frame.text, 12, "OUTLINE")
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
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        frames[index] = frame
        return frame
    end

    -- Same graphic as the tracker row badge: color, shape, size, and number.
    local function paintStepMapPin(frame, index, item)
        local main = index == 1
        local size = main and 22 or 18
        frame:SetSize(size, size)
        styleBadge(frame, ns.BadgeColor(index))
        local badgeNumber, badgeText = badgeLabel(item, index)
        RG.applyFont(frame.text, badgeFontSize(main, badgeNumber), "OUTLINE")
        frame.text:SetText(badgeText)
        frame.text:SetTextColor(1, 1, 1)
        frame.text:SetShadowColor(0, 0, 0, 1)
        frame.text:SetShadowOffset(0, 0)
        return badgeText
    end

    local function pinZoneName(place)
        return (ns.ClassicZoneName and ns.ClassicZoneName(place.map)) or place.zone
    end

    local function childMapNamed(mapId, zoneName)
        if not C_Map or not C_Map.GetMapChildrenInfo then
            return nil
        end
        local ok, children = pcall(C_Map.GetMapChildrenInfo, mapId, nil, true)
        if not ok or type(children) ~= "table" then
            return nil
        end
        for _, child in ipairs(children) do
            if ns.ZoneNamesMatch(child.name, zoneName) then
                return child.mapID
            end
        end
    end

    -- Normalized position of a pin on the shown map: the authored percents on
    -- the zone itself, or scaled into the zone's rectangle on a continent.
    local function pinOnMap(mapId, place)
        local zx, zy = fraction(place.x), fraction(place.y)
        local zoneName = pinZoneName(place)
        if not zx or not zy or not zoneName or not C_Map or not C_Map.GetMapInfo then
            return nil
        end
        local info = C_Map.GetMapInfo(mapId)
        if info and ns.ZoneNamesMatch(info.name, zoneName) then
            return zx, zy
        end
        if not C_Map.GetMapRectOnMap then
            return nil
        end
        local child = childMapNamed(mapId, zoneName)
        if not child then
            return nil
        end
        local ok, minX, maxX, minY, maxY = pcall(C_Map.GetMapRectOnMap, child, mapId)
        if not ok or not isNum(minX) or not isNum(maxX) or not isNum(minY) or not isNum(maxY) then
            return nil
        end
        return minX + zx * (maxX - minX), minY + zy * (maxY - minY)
    end

    -- Badges ride on real map canvas pins, the same way HereBeDragons does it,
    -- so zone maps place, scale, and layer them like their own POIs.
    local PIN_TEMPLATE = "WaynotesStepBadgePinTemplate"

    local function ensureProvider()
        if provider then
            return provider
        end
        local map = worldMap()
        if not map or not map.AddDataProvider or type(map.pinPools) ~= "table"
            or not MapCanvasDataProviderMixin or not MapCanvasPinMixin then
            return nil
        end
        local canvas = map:GetCanvas()

        local pinMixin = CreateFromMixins(MapCanvasPinMixin)
        function pinMixin:OnLoad()
            self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
            self:SetScalingLimits(1, 1.0, 1.2)
        end
        function pinMixin:OnAcquired(badge, x, y)
            self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
            self:SetPosition(x, y)
            self.badge = badge
            badge:SetParent(self)
            badge:SetScale(1)
            badge:SetFrameStrata(self:GetFrameStrata())
            badge:SetFrameLevel(self:GetFrameLevel() + 1)
            badge:ClearAllPoints()
            badge:SetPoint("CENTER", self, "CENTER")
            badge:Show()
        end
        function pinMixin:OnReleased()
            if self.badge then
                self.badge:Hide()
                self.badge:SetParent(UIParent)
                self.badge:ClearAllPoints()
                self.badge = nil
            end
        end
        pinMixin.SetPassThroughButtons = function() end

        local pool
        if CreateUnsecuredRegionPoolInstance then
            pool = CreateUnsecuredRegionPoolInstance(PIN_TEMPLATE)
        else
            pool = CreateFramePool("FRAME")
        end
        pool.parent = canvas
        pool.createFunc = function()
            local pin = CreateFrame("Frame", nil, canvas)
            pin:SetSize(1, 1)
            return Mixin(pin, pinMixin)
        end
        pool.resetFunc = function(_, pin)
            pin:Hide()
            pin:ClearAllPoints()
            pin:OnReleased()
            pin.pinTemplate = nil
            pin.owningMap = nil
        end
        pool.creationFunc = pool.createFunc
        pool.resetterFunc = pool.resetFunc
        map.pinPools[PIN_TEMPLATE] = pool

        provider = CreateFromMixins(MapCanvasDataProviderMixin)
        function provider:RemoveAllData()
            self:GetMap():RemoveAllPinsByTemplate(PIN_TEMPLATE)
        end
        function provider:RefreshAllData()
            self:RemoveAllData()
            local mapId = self:GetMap():GetMapID()
            if not isNum(mapId) then
                return
            end
            for index, place in ipairs(entries) do
                local x, y = pinOnMap(mapId, place)
                if x and frames[index] then
                    self:GetMap():AcquirePin(PIN_TEMPLATE, frames[index], x, y)
                end
            end
        end
        map:AddDataProvider(provider)
        return provider
    end

    local lastLayoutError
    local function safeLayout()
        local ok, err = pcall(function()
            local active = ensureProvider()
            local map = worldMap()
            if active and map and map:IsShown() then
                active:RefreshAllData()
            end
        end)
        if not ok and err ~= lastLayoutError then
            lastLayoutError = err
            DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r map badge error: " .. tostring(err))
        end
    end

    local debugOnOpen = false
    local driver = CreateFrame("Frame")
    driver:SetScript("OnUpdate", function(self)
        -- The world map can load after the first sync; register once it exists.
        if not provider and #entries > 0 and rawget(_G, "WorldMapFrame") then
            safeLayout()
        end
        if provider and not debugOnOpen then
            self:SetScript("OnUpdate", nil)
            return
        end
        if debugOnOpen then
            local map = worldMap()
            if map and map:IsShown() then
                debugOnOpen = false
                ns.MapBadgeDebug()
                if provider then
                    self:SetScript("OnUpdate", nil)
                end
            end
        end
    end)

    function ns.MapBadgeDebug()
        local function say(line)
            DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes map|r " .. line)
        end
        local map, scroll, child = worldMap()
        say(string.format("tracker=%s standalone=%s replace=%s entries=%d frames=%d provider=%s",
            tostring(tracker:IsShown()), tostring(ns.db and ns.db.standaloneGuide), tostring(ns.db and ns.db.replaceGuide), #entries, #frames, tostring(provider ~= nil)))
        if not map then
            say("WorldMapFrame canvas not found")
            return
        end
        if not map:IsShown() then
            debugOnOpen = true
            say("Open the world map; the report prints when it opens.")
            return
        end
        local mapId = map.GetMapID and map:GetMapID()
        local info = isNum(mapId) and C_Map.GetMapInfo(mapId)
        say(string.format("map shown=%s id=%s name=%s scale=%s size=%.0fx%.0f strata=%s level=%s",
            tostring(map:IsShown()), tostring(mapId), tostring(info and info.name), tostring(scroll.GetCanvasScale and scroll:GetCanvasScale()),
            child:GetWidth() or 0, child:GetHeight() or 0, tostring(child:GetFrameStrata()), tostring(child:GetFrameLevel())))
        if lastLayoutError then
            say("last error: " .. tostring(lastLayoutError))
        end
        for index, place in ipairs(entries) do
            local x, y
            if isNum(mapId) then
                x, y = pinOnMap(mapId, place)
            end
            local frame = frames[index]
            local point, _, _, ox, oy = frame:GetPoint(1)
            say(string.format("#%d map=%s zone=%s xy=%s,%s -> %s,%s shown=%s visible=%s parent=%s at=%s %s,%s strata=%s",
                index, tostring(place.map), tostring(pinZoneName(place)), tostring(place.x), tostring(place.y),
                tostring(x), tostring(y), tostring(frame:IsShown()), tostring(frame:IsVisible()),
                tostring(frame:GetParent() and frame:GetParent().badge == frame and "pin" or frame:GetParent() == child and "canvas" or frame:GetParent() and frame:GetParent():GetName()),
                tostring(point), tostring(ox), tostring(oy), tostring(frame:GetFrameStrata())))
        end
    end

    function State.syncStepMapPins(items)
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
            local places = item.places
            if type(places) ~= "table" or #places == 0 then
                places = item.place and { item.place } or {}
            end
            local chunks = {}
            for pinIndex, place in ipairs(places) do
                chunks[pinIndex] = tostring(place.map or "-") .. ":" .. tostring(place.x or "-") .. ":" .. tostring(place.y or "-")
            end
            parts[index] = tostring(item.number or index) .. "=" .. table.concat(chunks, ",")
        end
        local signature = table.concat(parts, "|") .. "|" .. tostring(ns.db.roundBadges)
        if signature == State.mapPins.signature then
            return
        end

        clearStepMapPins()
        State.mapPins.signature = signature

        for index, item in ipairs(items) do
            local places = item.places
            if type(places) ~= "table" or #places == 0 then
                places = item.place and { item.place } or {}
            end
            local _, badgeText = badgeLabel(item, index)
            for _, place in ipairs(places) do
                if type(place) == "table" and isNum(place.x) and isNum(place.y) then
                    local slot = #entries + 1
                    entries[slot] = place
                    local frame = acquireStepMapPin(slot)
                    paintStepMapPin(frame, index, item)
                    frame.tipTitle = string.format("Step %s", badgeText)
                    if place.note and place.note ~= "" then
                        frame.tipTitle = frame.tipTitle .. " · " .. place.note
                    end
                    local x = place.x > 1 and place.x or place.x * 100
                    local y = place.y > 1 and place.y or place.y * 100
                    frame.tipPlace = string.format("%s  %.1f, %.1f", pinZoneName(place) or "?", x, y)
                end
            end
        end
        safeLayout()
    end

    State.clearStepMapPins = clearStepMapPins
end)()

-- Step rebuilds go through one pulse: mark dirty on events, coalesce, then refresh.
-- Glow and drop shadow are UIParent children, so tracker SetAlpha does not
-- reach them. Keep their visibility tied to fade / combat visibility.
function ns.SetTrackerChromeAlpha(alpha)
    if type(alpha) ~= "number" then
        return
    end
    if alpha < 0 then
        alpha = 0
    elseif alpha > 1 then
        alpha = 1
    end
    if glowHost:IsShown() then
        glowHost:SetAlpha(alpha)
    end
    if shadowHost:IsShown() then
        shadowHost:SetAlpha(alpha)
    end
end

function ns.MarkTrackerDirty(force)
    State.trackerDirty = true
    if force then
        State.trackerForce = true
    end
    if not State.dirtyAt or State.dirtyAt == 0 then
        -- Kill/objective spam batches harder in combat so one refresh covers many ticks.
        local delay = UI.TRACKER_COALESCE_SECONDS
        if InCombatLockdown and InCombatLockdown() then
            delay = UI.TRACKER_COMBAT_COALESCE_SECONDS or 0.2
        end
        State.dirtyAt = (GetTime and GetTime() or 0) + delay
    end
end

function ns.RefreshTracker(force)
    if not State.perf then
        return State.refreshTracker(force)
    end
    local key = force and "refresh (forced)" or "refresh"
    local start = debugprofilestop()
    State.refreshTracker(force)
    ns.PerfAdd(key, debugprofilestop() - start)
end

local function rememberPulsePosition()
    local hbd = RG.hereBeDragons and RG.hereBeDragons()
    if not hbd or not hbd.GetPlayerWorldPosition then
        return
    end
    local x, y, instance = hbd:GetPlayerWorldPosition()
    if type(x) == "number" and type(y) == "number" then
        State.lastPulseX, State.lastPulseY, State.lastPulseInstance = x, y, instance
    end
end

-- Keep these on State (not chunk locals) — Replace.lua is at Lua 5.1's 200-local cap.
State.pulseTravelCatchUp = function()
    if not ns.db or not ns.db.standaloneGuide then
        return
    end
    local pulse = ns.GuidePulseTravel or ns.GuideCatchUp
    if not pulse then
        return
    end
    local ok, moved = pcall(pulse)
    if ok and moved then
        ns.MarkTrackerDirty(true)
    end
end

-- BestPath is expensive: only on step load / zone change, never on a timer.
State.requestPrimaryRoute = function()
    State.routeNeeded = true
end
ns.RequestPrimaryRoute = State.requestPrimaryRoute

State.pulsePrimaryRoute = function()
    if not ns.db or not tracker:IsShown() then
        return
    end
    if not (ns.db.standaloneGuide or ns.db.replaceGuide) then
        return
    end
    if ns.TravelPulsePrimaryRoute then
        ns.TravelPulsePrimaryRoute()
    end
end

State.notePrimaryRouteStep = function()
    local step, stepIndex = ns.GuidePrimaryStep and ns.GuidePrimaryStep()
    local guideId = ns.GuideId and ns.GuideId() or (RG.guideTitle and RG.guideTitle()) or "?"
    local key = tostring(guideId) .. ":" .. tostring(stepIndex or 0)
    if State.routeStepKey ~= key then
        State.routeStepKey = key
        State.routeNeeded = true
    end
end

-- Apply BestPath hop + fly-rec paint without rebuilding the whole tracker.
ns.OnTravelRouteReady = function(route, dest, step, stepIndex)
    if type(stepIndex) == "number" then
        for index = 1, #State.rows do
            local row = State.rows[index]
            if row and row.stepIndex == stepIndex then
                if route and type(route.waypoint) == "table" and type(route.waypoint.wx) == "number" then
                    row.tipWaypoint = route.waypoint
                    row.keepTravelWaypoint = route.mode and route.mode ~= "walk" or nil
                    if row.arrow then
                        row.arrow.__rxpbWp = route.waypoint
                        row.arrow.__rxpbAimWp = nil
                    end
                end
                break
            end
        end
    end
    if updateFlyRecStrip then
        updateFlyRecStrip()
    end
    if updateHearthRecStrip then
        updateHearthRecStrip()
    end
end

State.refreshTracker = function(force)
    if not ns.db or not tracker:IsShown() or (not ns.db.standaloneGuide and not ns.db.replaceGuide) then
        if State.clearStepMapPins then
            State.clearStepMapPins()
        end
        if ns.RefreshStepList then
            ns.RefreshStepList(true)
        end
        return
    end

    local items = RG.collectObjectives()
    local guideTitle = RG.guideTitle()
    if State.guideTitle ~= guideTitle then
        State.guideTitle = guideTitle
        State.completing = {}
        State.stickyShown = {}
    end
    beginStickyCompletions(items)
    local displayItems = appendCompletingItems(items)
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

    local contentChanged = signature ~= State.lastSignature

    -- Combat: never restyle chrome / rebuild the step list on every kill tick.
    -- Previously this lite path only ran when secure buttons were parked, so
    -- text-only steps paid the full out-of-combat rebuild (~50ms) in combat.
    if InCombatLockdown() then
        local rowCount = #displayItems
        local rowCountChanged = rowCount ~= (State.combatRowCount or -1)
        if force or rowCountChanged or State.remeasure then
            if layout(displayItems, contentChanged or force) then
                State.lastSignature = signature
                State.remeasure = false
                State.combatRowCount = rowCount
            else
                State.remeasure = true
            end
        elseif contentChanged then
            State.lastSignature = signature
            for index, item in ipairs(displayItems) do
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
                    if row.arrow and not item.__rxpbCompleting then
                        row.arrow.__rxpbWp = item.waypoint
                    end
                    applyRowText(row, item, index)
                    syncProgressBars(row, item)
                end
            end
        end
        if State.syncStepMapPins and (force or contentChanged) then
            State.syncStepMapPins(items)
        end
        -- Step list only needs a pulse when the active step actually moved.
        if force and ns.RefreshStepList then
            ns.RefreshStepList(true)
        end
        State.notePrimaryRouteStep()
        rememberPulsePosition()
        return
    end

    State.combatRowCount = nil
    local sizeNow = readTrackerWidth() .. ":" .. (readTrackerHeight() or 0)
    local sizeChanged = sizeNow ~= State.sizeKey
    State.sizeKey = sizeNow
    local completingPending = State.completing and next(State.completing)
    if force or contentChanged or sizeChanged or State.remeasure or (completingPending and contentChanged) then
        if layout(displayItems, contentChanged) then
            State.lastSignature = signature
            State.remeasure = sizeChanged
        else
            State.remeasure = true
        end
    end
    -- Restyling re-expands every row's text, so unchanged rebuilds only do it
    -- once a second to pick up options changes.
    local now = GetTime and GetTime() or 0
    local needsChrome = force or contentChanged or sizeChanged or now >= (State.restyleAt or 0)
    if needsChrome then
        State.restyleAt = now + 1
        styleTracker()
        paintRowColors()
        styleStepButtons()
        reassertActions()
    end
    if State.syncStepMapPins and (force or contentChanged) then
        State.syncStepMapPins(items)
    end
    -- Paint cached fly/hearth-rec only; BestPath runs on step load / zone change.
    if updateFlyRecStrip then
        updateFlyRecStrip()
    end
    if updateHearthRecStrip then
        updateHearthRecStrip()
    end
    -- Objective text changes must not force a step-list restyle/rebuild.
    if ns.RefreshStepList then
        ns.RefreshStepList(force)
    end
    State.notePrimaryRouteStep()
    rememberPulsePosition()
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
        local children = { frame:GetChildren() }
        for index = 1, #children do
            walkMouse(children[index], depth + 1)
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

local function placeCog(force)
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

    if not force then
        local parent = cog.GetParent and cog:GetParent()
        local _, relativeTo = cog:GetPoint(1)
        if parent == tracker and relativeTo == tracker and cog:IsShown() then
            return
        end
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
    local first = not State.satelliteHooked[frame]
    if first and frame.SetAlpha then
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
    elseif not State.satelliteHooked[frame] then
        State.satelliteHooked[frame] = true
    end
    hookMouse(frame)
    local shown = frame.IsShown and frame:IsShown()
    local visible = shown or (frame.GetAlpha and (frame:GetAlpha() or 0) > 0.01)
    if shown then
        frame.__rxpbWasShown = true
    end
    if visible or first then
        State.alphaBusy = true
        frame:SetAlpha(0)
        if not InCombatLockdown() then
            pcall(frame.Hide, frame)
        end
        State.alphaBusy = false
    end
    if first or not State.guideConcealed then
        walkMouse(frame, 0)
    end
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
    local current = rxp.CurrentStepFrame
    local childCount = current and current.GetNumChildren and current:GetNumChildren() or 0
    local walkKey = tostring(childCount)
    local needWalk = State.concealWalkKey ~= walkKey
    local already = State.guideConcealed and not needWalk

    State.alphaBusy = true
    rxp:SetAlpha(1)
    State.alphaBusy = false

    for _, frame in ipairs(chromeFrames(rxp)) do
        if frame then
            hookChromeAlpha(frame)
            if not already or (frame.GetAlpha and (frame:GetAlpha() or 0) > 0.01) then
                State.alphaBusy = true
                frame:SetAlpha(0)
                State.alphaBusy = false
            end
            if needWalk or not State.guideConcealed then
                walkMouse(frame, 0)
            end
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
    placeCog(false)
    State.guideConcealed = true
    State.concealWalkKey = walkKey
end

local function revealGuide(rxp)
    State.guideConcealed = false
    State.concealWalkKey = nil
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
        if ns.MarkTrackerDirty then
            ns.MarkTrackerDirty(false)
        else
            pcall(ns.RefreshTracker)
        end
    end)
end


function ns.OnGuideScan()
    local rxp = _G.RXPFrame
    if not rxp then
        return
    end
    if ns.WarmQuestieNameIndexes then
        ns.WarmQuestieNameIndexes()
    end
    hookStepText()
    if ns.ReplacingGuide() then
        if not tracker:IsShown() then
            ns.SyncReplacement()
            return
        end
        concealGuide(rxp)
    elseif ns.db and ns.db.standaloneGuide then
        concealGuide(rxp)
        -- A shown tracker rebuilds from the shared dirty pulse.
        if tracker:IsShown() then
            ns.MarkTrackerDirty(false)
        else
            ns.RefreshTracker()
        end
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
    local showTracker = (ns.db.standaloneGuide or (ns.db.replaceGuide and rxp)) and not ns.db.hideTracker
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
        if ns.RefreshStepList then
            ns.RefreshStepList(true)
        end
    else
        tracker:Hide()
        State.lastSignature = nil
        if ns.RefreshStepList then
            ns.RefreshStepList(true)
        end
        if rxp and not ns.db.hideTracker then
            revealGuide(rxp)
        elseif rxp and ns.db.hideTracker and (ns.db.standaloneGuide or ns.db.replaceGuide) then
            concealGuide(rxp)
        end
    end
end

function ns.ToggleTracker()
    if not ns.db then
        ns.InitDB()
    end
    ns.db.hideTracker = not ns.db.hideTracker
    ns.Apply()
end

function ns.TrackerIsShown()
    return tracker:IsShown() and true or false
end

-- /waynotes perf [seconds] [spikeMs]
-- Samples tracker OnUpdate work, prints live spikes, then summarizes maxes.
UI.PERF_SPIKE_MS = 8

function ns.StartPerf(seconds, spikeMs)
    if type(debugprofilestop) ~= "function" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r Profiling is not available on this client.")
        return
    end
    seconds = tonumber(seconds) or 10
    spikeMs = tonumber(spikeMs) or UI.PERF_SPIKE_MS
    State.perf = {}
    State.perfCalls = {}
    State.perfMax = {}
    State.perfSpikes = {}
    State.perfSpikeLog = {}
    State.perfSpikeMs = spikeMs
    State.perfStarted = GetTime()
    State.perfUntil = State.perfStarted + seconds
    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        "|cffce7bffWaynotes|r Profiling %ds (spike >= %.1f ms). Walk with the tracker open.",
        seconds,
        spikeMs
    ))
end

function ns.PerfAdd(key, ms)
    local perf = State.perf
    if not perf or type(key) ~= "string" or type(ms) ~= "number" then
        return
    end
    perf[key] = (perf[key] or 0) + ms
    State.perfCalls[key] = (State.perfCalls[key] or 0) + 1
    local maxes = State.perfMax
    if maxes and (not maxes[key] or ms > maxes[key]) then
        maxes[key] = ms
    end
    local thresh = State.perfSpikeMs or UI.PERF_SPIKE_MS
    if ms >= thresh then
        State.perfSpikes[key] = (State.perfSpikes[key] or 0) + 1
        local log = State.perfSpikeLog
        if type(log) == "table" and #log < 50 then
            log[#log + 1] = {
                key = key,
                ms = ms,
                t = (GetTime() - (State.perfStarted or GetTime())),
            }
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffce7bffWaynotes spike|r %s %.1f ms", key, ms))
    end
end

-- Optional probe for Travel / other modules outside Replace's State.timed.
function ns.PerfProbe(key, fn, ...)
    if not State.perf or type(fn) ~= "function" then
        return fn(...)
    end
    local start = debugprofilestop()
    local ok, a, b, c, d = pcall(fn, ...)
    ns.PerfAdd(key, debugprofilestop() - start)
    if not ok then
        error(a)
    end
    return a, b, c, d
end

function State.finishPerf()
    local perf = State.perf
    if not perf then
        return
    end
    local span = math.max(0.001, GetTime() - (State.perfStarted or 0))
    local maxes = State.perfMax or {}
    local spikes = State.perfSpikes or {}
    local log = State.perfSpikeLog or {}
    local thresh = State.perfSpikeMs or UI.PERF_SPIKE_MS
    State.perf = nil
    State.perfMax = nil
    State.perfSpikes = nil
    State.perfSpikeLog = nil

    local keys, total, spikeTotal = {}, 0, 0
    for key, ms in pairs(perf) do
        keys[#keys + 1] = key
        total = total + ms
        spikeTotal = spikeTotal + (spikes[key] or 0)
    end
    table.sort(keys, function(a, b)
        local ma, mb = maxes[a] or 0, maxes[b] or 0
        if ma ~= mb then
            return ma > mb
        end
        return perf[a] > perf[b]
    end)

    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        "|cffce7bffWaynotes perf|r %.2f ms/s total over %.0fs · %d spikes (>= %.1f ms)",
        total / span,
        span,
        spikeTotal,
        thresh
    ))
    local shown = 0
    for _, key in ipairs(keys) do
        shown = shown + 1
        if shown > 12 then
            break
        end
        local calls = State.perfCalls and State.perfCalls[key] or 0
        local maxMs = maxes[key] or 0
        local spikeN = spikes[key] or 0
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "|cffce7bffWaynotes perf|r   %s: max %.1f ms · %.2f ms/s · %d spikes · %.1f calls/s",
            key,
            maxMs,
            perf[key] / span,
            spikeN,
            calls / span
        ))
    end
    if #log > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes perf|r recent spikes:")
        local from = math.max(1, #log - 9)
        for index = from, #log do
            local row = log[index]
            DEFAULT_CHAT_FRAME:AddMessage(string.format(
                "|cffce7bffWaynotes perf|r   +%.1fs  %s  %.1f ms",
                row.t or 0,
                row.key or "?",
                row.ms or 0
            ))
        end
    end
end

function State.timed(key, fn, ...)
    if not State.perf then
        return pcall(fn, ...)
    end
    local start = debugprofilestop()
    local ok, err = pcall(fn, ...)
    ns.PerfAdd(key, debugprofilestop() - start)
    return ok, err
end

State.trackerOnUpdate = function(self, delta)
    if self:IsMouseOver() then
        State.mouseOver = true
        placeTrackerTooltip()
    elseif State.mouseOver then
        State.mouseOver = false
        clearGuideTips()
    end
    -- Light work every frame / short cadence. Step rebuilds only when dirty.
    State.timed("arrows", updateArrows)
    State.timed("completing", updateCompletingStickies, delta)
    State.timed("flight", updateFlightStrip)
    State.stripElapsed = (State.stripElapsed or 0) + delta
    if State.stripElapsed >= UI.STRIP_UPDATE_SECONDS then
        State.stripElapsed = 0
        State.timed("flyRec", updateFlyRecStrip)
        if updateHearthRecStrip then
            State.timed("hearthRec", updateHearthRecStrip)
        end
        State.timed("nav", updateNavStrip)
        if State.corpse.update then
            State.timed("corpse", State.corpse.update)
        end
    end
    State.trainElapsed = (State.trainElapsed or 0) + delta
    if State.trainElapsed >= UI.TRAIN_UPDATE_SECONDS then
        State.trainElapsed = 0
        State.timed("train", updateTrainStrip)
    end
    if not (ns.db and ns.db.standaloneGuide) then
        State.timed("review", RG.maintainReview)
    end

    State.travelElapsed = (State.travelElapsed or 0) + delta
    if State.travelElapsed >= UI.TRAVEL_PULSE_SECONDS then
        State.travelElapsed = 0
        State.timed("travel", State.pulseTravelCatchUp)
    end
    -- Refresh and BestPath never share a frame. Route only when the primary
    -- step changes or the player changes zones (see requestPrimaryRoute).
    -- Walking no longer dirties the tracker (that was the leftover ~20ms hitch).
    if State.trackerDirty then
        local now = GetTime and GetTime() or 0
        if now >= (State.dirtyAt or 0) then
            local force = State.trackerForce and true or false
            State.trackerDirty = false
            State.trackerForce = false
            State.dirtyAt = 0
            ns.RefreshTracker(force)
        end
    elseif State.routeNeeded then
        State.routeNeeded = false
        State.timed("route", State.pulsePrimaryRoute)
    end

    if State.perf and GetTime() >= State.perfUntil then
        State.finishPerf()
    end
end

tracker:SetScript("OnUpdate", function(self, delta)
    if not State.perf then
        return State.trackerOnUpdate(self, delta)
    end
    -- Whole-tick sample catches stacked strip/travel/refresh work in one frame.
    local start = debugprofilestop()
    State.trackerOnUpdate(self, delta)
    ns.PerfAdd("tick", debugprofilestop() - start)
end)

tracker:SetScript("OnShow", function()
    State.lastSignature = nil
    State.trackerDirty = false
    State.trackerForce = false
    State.dirtyAt = 0
    State.routeStepKey = nil
    State.routeNeeded = true
    ns.RefreshTracker(true)
    pcall(updateFlightStrip)
    pcall(updateNavStrip)
    pcall(updateTrainStrip)
    if State.corpse.update then
        pcall(State.corpse.update)
    end
end)

tracker:SetScript("OnHide", function()
    clearGuideTips()
    State.completing = {}
    State.stickyShown = {}
    glowHost:Hide()
    shadowHost:Hide()
    if State.flight.strip then
        State.flight.strip:Hide()
    end
    if State.flyRec.strip then
        State.flyRec.strip:Hide()
    end
    State.flyRec.chrome = 0
    State.flyRec.route = nil
    if State.hearthRec.strip then
        State.hearthRec.strip:Hide()
    end
    State.hearthRec.chrome = 0
    State.hearthRec.route = nil
    if State.nav.strip then
        State.nav.strip:Hide()
    end
    if State.train.strip then
        State.train.strip:Hide()
    end
    if State.corpse.strip then
        State.corpse.strip:Hide()
    end
    if State.clearStepMapPins then
        State.clearStepMapPins()
    end
    if ns.HideNavMenu then
        ns.HideNavMenu()
    end
end)
