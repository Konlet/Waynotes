local _, ns = ...

-- Minimap edge button with the Waynotes logo.
-- Left-click toggles the guide tracker; right-click opens the guide browser
-- (the same context menu as right-clicking the tracker). Drag to reposition.

local BUTTON_SIZE = 31
local EDGE_RADIUS = 5
local LOGO = "Interface\\AddOns\\Waynotes\\logo"
local BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"
local BACKGROUND = "Interface\\Minimap\\UI-Minimap-Background"
local HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"

local button
local dragging = false

local function updatePosition(frame, angle)
    if not Minimap then
        return
    end
    angle = tonumber(angle) or 220
    local rad = math.rad(angle)
    local half = (Minimap:GetWidth() / 2) + EDGE_RADIUS
    local x = math.cos(rad) * half
    local y = math.sin(rad) * half
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function saveAngle(angle)
    if not ns.db then
        return
    end
    angle = angle % 360
    if angle < 0 then
        angle = angle + 360
    end
    ns.db.minimapPos = angle
end

local function currentAngle()
    if ns.db and type(ns.db.minimapPos) == "number" then
        return ns.db.minimapPos
    end
    return 220
end

local function buildButton()
    if button or not Minimap then
        return
    end

    button = CreateFrame("Button", "WaynotesMinimapButton", Minimap)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture(HIGHLIGHT, "ADD")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture(BACKGROUND)
    background:SetSize(20, 20)
    background:SetPoint("CENTER", 0, 0)
    button.background = background

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(LOGO)
    icon:SetSize(32, 32)
    icon:SetPoint("CENTER", 1, -1)
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture(BORDER)
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", 0, 0)
    button.border = border

    button:SetScript("OnEnter", function(self)
        local r, g, b = 1, 0.82, 0
        if ns.Color then
            r, g, b = ns.Color("accent")
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Waynotes", r, g, b)
        GameTooltip:AddLine("Left-click: show or hide the guide", 1, 1, 1, true)
        GameTooltip:AddLine("Right-click: open the guide menu", 1, 1, 1, true)
        GameTooltip:AddLine("Drag to move", 0.75, 0.75, 0.75, true)
        if ns.FinishTooltip then
            ns.FinishTooltip()
        else
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnClick", function(_, mouseButton)
        if dragging then
            return
        end
        if mouseButton == "LeftButton" then
            if ns.ToggleTracker then
                ns.ToggleTracker()
            end
            return
        end
        if mouseButton == "RightButton" then
            if ns.OpenGuideMenu then
                ns.OpenGuideMenu()
            elseif ns.ToggleGuideMenu then
                ns.ToggleGuideMenu()
            end
        end
    end)

    button:SetScript("OnDragStart", function(self)
        dragging = true
        self:LockHighlight()
        GameTooltip:Hide()
        self:SetScript("OnUpdate", function(frame)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            if not scale or scale == 0 then
                scale = 1
            end
            px, py = px / scale, py / scale
            local angle = math.deg(math.atan2(py - my, px - mx)) % 360
            saveAngle(angle)
            updatePosition(frame, angle)
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self:UnlockHighlight()
        C_Timer.After(0, function()
            dragging = false
        end)
    end)

    updatePosition(button, currentAngle())
end

local function refreshVisibility()
    if not button then
        return
    end
    if ns.db and ns.db.showMinimapButton == false then
        button:Hide()
        return
    end
    button:Show()
    updatePosition(button, currentAngle())
end

function ns.RefreshMinimapButton()
    if not button then
        buildButton()
    end
    refreshVisibility()
end

local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    ns.InitDB()
    buildButton()
    refreshVisibility()
end)
