local _, ns = ...

-- The guide tracker joins Blizzard Edit Mode. While Edit Mode is open the
-- window is highlighted and draggable, and selecting it shows scale, width,
-- and height. Each layout keeps its own position. Clients without Edit Mode
-- keep the tracker's own drag.

local State = ns.ReplaceState
local manager
local selection
local dialog
local seenLayout

local function clampStep(value, minValue, maxValue, step)
    local snapped = math.floor((value / step) + 0.5) * step
    if snapped < minValue then
        return minValue
    end
    if snapped > maxValue then
        return maxValue
    end
    return snapped
end

local settingsQueued = false

local function applyTrackerSettingsNow()
    local tracker = _G.WaynotesTracker
    if tracker and ns.db then
        tracker:SetScale(ns.db.trackerScale or 1.2)
        tracker:SetWidth(ns.db.trackerWidth or 300)
        if ns.db.trackerFitHeight == false then
            tracker:SetHeight(ns.db.trackerHeight or 360)
        end
    end
    if ns.RefreshTracker then
        ns.RefreshTracker(true)
    end
    if ns.RefreshOptions then
        ns.RefreshOptions()
    end
end

local function applyTrackerSettings()
    if not C_Timer or not C_Timer.After then
        applyTrackerSettingsNow()
        return
    end
    if settingsQueued then
        return
    end
    settingsQueued = true
    C_Timer.After(0, function()
        settingsQueued = false
        applyTrackerSettingsNow()
    end)
end

local function createSettingsDialog()
    local frame = CreateFrame("Frame", "WaynotesEditModeDialog", UIParent, "BackdropTemplate")
    frame:SetSize(250, 206)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(400)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.94)
    frame:SetBackdropBorderColor(1, 0.82, 0, 0.85)
    frame:Hide()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText("Waynotes")

    local function addSlider(y, name, label, minValue, maxValue, step, fallback, formatValue, key)
        local holder = CreateFrame("Frame", nil, frame)
        holder:SetPoint("TOPLEFT", 12, y)
        holder:SetPoint("TOPRIGHT", -12, y)
        holder:SetHeight(40)

        local caption = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        caption:SetPoint("TOPLEFT", 0, 0)
        caption:SetText(label)

        local valueText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valueText:SetPoint("TOPRIGHT", 0, 0)

        local slider = CreateFrame("Slider", name, holder, "UISliderTemplate")
        slider:SetPoint("TOPLEFT", 4, -18)
        slider:SetPoint("TOPRIGHT", -4, -18)
        slider:SetHeight(16)
        slider:SetMinMaxValues(minValue, maxValue)
        slider:SetValueStep(step)
        if slider.SetObeyStepOnDrag then
            slider:SetObeyStepOnDrag(true)
        end
        local sliderName = slider:GetName()
        for _, piece in ipairs({ "Low", "High", "Text" }) do
            local fs = _G[sliderName .. piece]
            if fs then
                fs:Hide()
            end
        end

        local suppress = false
        slider:SetScript("OnValueChanged", function(_, value)
            local snapped = clampStep(value, minValue, maxValue, step)
            valueText:SetText(formatValue(snapped))
            if suppress or not ns.db then
                return
            end
            local current = ns.db[key]
            if type(current) == "number" and math.abs(current - snapped) < (step * 0.25) then
                return
            end
            ns.db[key] = snapped
            applyTrackerSettings()
        end)

        function holder:SetEnabled(enabled)
            if enabled then
                slider:Enable()
            else
                slider:Disable()
            end
            local fade = enabled and 1 or 0.4
            caption:SetAlpha(fade)
            valueText:SetAlpha(fade)
            slider:SetAlpha(fade)
        end

        function holder:Refresh()
            local value = ns.db and ns.db[key]
            if type(value) ~= "number" then
                value = fallback
            end
            value = clampStep(value, minValue, maxValue, step)
            suppress = true
            slider:SetValue(value)
            suppress = false
            valueText:SetText(formatValue(value))
        end

        return holder
    end

    local function percentText(value)
        return string.format("%d%%", math.floor(value * 100 + 0.5))
    end

    local function pixelText(value)
        return string.format("%d px", math.floor(value + 0.5))
    end

    local scaleSlider = addSlider(-32, "WaynotesEditModeScale", "Scale", 0.8, 2, 0.05, 1.2, percentText, "trackerScale")
    local widthSlider = addSlider(-76, "WaynotesEditModeWidth", "Width", 220, 640, 10, 300, pixelText, "trackerWidth")

    local fit = CreateFrame("CheckButton", "WaynotesEditModeFitHeight", frame, "UICheckButtonTemplate")
    fit:SetPoint("TOPLEFT", 8, -116)
    local fitText = _G.WaynotesEditModeFitHeightText
    if fitText then
        fitText:SetFontObject(GameFontHighlight)
        fitText:SetText("Fit height to steps")
    end

    local heightSlider = addSlider(-148, "WaynotesEditModeHeight", "Height", 120, 800, 10, 360, pixelText, "trackerHeight")
    local fitting = false

    fit:SetScript("OnClick", function(self)
        if fitting or not ns.db then
            return
        end
        ns.db.trackerFitHeight = self:GetChecked() and true or false
        heightSlider:SetEnabled(ns.db.trackerFitHeight == false)
        applyTrackerSettings()
    end)

    function frame:Refresh()
        scaleSlider:Refresh()
        widthSlider:Refresh()
        heightSlider:Refresh()
        local fitOn = not ns.db or ns.db.trackerFitHeight ~= false
        fitting = true
        fit:SetChecked(fitOn)
        fitting = false
        heightSlider:SetEnabled(not fitOn)
    end

    -- Pinned to the screen, not the tracker. Anchoring to the tracker made the
    -- panel move as the window resized, which fought the slider being dragged.
    function frame:Place(tracker)
        local ratio = tracker:GetEffectiveScale() / (UIParent:GetEffectiveScale() or 1)
        local left = tracker:GetLeft()
        local right = tracker:GetRight()
        local top = tracker:GetTop()
        if not left or not right or not top then
            return
        end
        left, right, top = left * ratio, right * ratio, top * ratio
        local screenWidth = UIParent:GetWidth() or 0
        local width = self:GetWidth() or 250
        local x
        if (left + right) / 2 > screenWidth / 2 then
            x = left - 8 - width
        else
            x = right + 8
        end
        if x < 0 then
            x = 0
        elseif x + width > screenWidth then
            x = math.max(0, screenWidth - width)
        end
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, top)
    end

    frame:Refresh()
    return frame
end

local function hideSettings()
    if dialog then
        dialog:Hide()
    end
end

local function showSettings(tracker)
    if not dialog or not tracker then
        return
    end
    dialog:Refresh()
    dialog:Place(tracker)
    dialog:Show()
end

local function copyPoint(saved)
    if type(saved) ~= "table" or type(saved.point) ~= "string" then
        return nil
    end
    if type(saved.x) ~= "number" or type(saved.y) ~= "number" then
        return nil
    end
    return {
        point = saved.point,
        relativePoint = type(saved.relativePoint) == "string" and saved.relativePoint or saved.point,
        x = saved.x,
        y = saved.y,
    }
end

local function readPoint(frame)
    local point, _, relativePoint, x, y = frame:GetPoint()
    return copyPoint({
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
    })
end

local function applyPoint(frame, saved)
    saved = copyPoint(saved)
    if not saved then
        return false
    end
    frame:ClearAllPoints()
    frame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
    return true
end

local function characterTag()
    local name, realm
    if UnitFullName then
        name, realm = UnitFullName("player")
    end
    if type(name) ~= "string" or name == "" then
        name = UnitName("player")
    end
    if type(name) ~= "string" or name == "" then
        return nil
    end
    if type(realm) ~= "string" or realm == "" then
        realm = GetRealmName()
    end
    if type(realm) == "string" and realm ~= "" then
        return name .. "-" .. realm
    end
    return name
end

local function layoutKind(layoutType)
    local kinds = Enum and Enum.EditModeLayoutType
    if kinds then
        if layoutType == kinds.Preset then
            return "preset"
        end
        if layoutType == kinds.Character then
            return "character"
        end
        if layoutType == kinds.Account then
            return "account"
        end
    end
    return "layout"
end

local function layoutKey()
    if not manager or not manager.GetActiveLayoutInfo then
        return nil
    end
    local ok, info = pcall(manager.GetActiveLayoutInfo, manager)
    if not ok or type(info) ~= "table" then
        return nil
    end
    local name = info.layoutName
    if type(name) ~= "string" or name == "" then
        local index = manager.layoutInfo and manager.layoutInfo.activeLayout
        if type(index) == "number" then
            return "index:" .. index
        end
        return nil
    end
    local kind = layoutKind(info.layoutType)
    if kind == "character" then
        local who = characterTag()
        if who then
            return "character:" .. who .. ":" .. name
        end
    end
    return kind .. ":" .. name
end

local function savedLayoutPoint()
    local key = layoutKey()
    local layouts = ns.db and ns.db.trackerLayouts
    if not key or type(layouts) ~= "table" then
        return nil
    end
    return copyPoint(layouts[key])
end

function ns.ApplyTrackerLayout()
    local tracker = _G.WaynotesTracker
    if not tracker then
        return
    end
    local saved = savedLayoutPoint()
    if saved then
        applyPoint(tracker, saved)
        seenLayout = layoutKey()
    end
end

local function commitPoint(tracker)
    if not ns.db then
        return
    end
    local saved = readPoint(tracker)
    if not saved then
        return
    end
    ns.db.trackerPoint = {
        point = saved.point,
        relativePoint = saved.relativePoint,
        x = saved.x,
        y = saved.y,
    }
    local key = layoutKey()
    if key then
        if type(ns.db.trackerLayouts) ~= "table" then
            ns.db.trackerLayouts = {}
        end
        ns.db.trackerLayouts[key] = {
            point = saved.point,
            relativePoint = saved.relativePoint,
            x = saved.x,
            y = saved.y,
        }
        seenLayout = key
    end
    if ns.PlaceGuideCog then
        ns.PlaceGuideCog()
    end
end

local function showSelection()
    hideSettings()
    if not selection then
        return
    end
    selection:SetFrameStrata("HIGH")
    selection:SetFrameLevel(600)
    if selection.ShowHighlighted then
        local ok = pcall(selection.ShowHighlighted, selection)
        if ok then
            return
        end
    end
    selection:Show()
end

local function enterEditMode(tracker)
    if State.editMode then
        showSelection()
        return
    end
    State.editMode = true
    if not tracker:IsShown() then
        State.editModeHeldOpen = true
        if ns.db then
            tracker:SetScale(ns.db.trackerScale or 1.2)
        end
        tracker:Show()
        if ns.RefreshTracker then
            ns.RefreshTracker(true)
        end
    end
    showSelection()
end

local function exitEditMode()
    hideSettings()
    if selection then
        selection:Hide()
    end
    if not State.editMode then
        return
    end
    State.editMode = false
    State.editModeHeldOpen = false
    local tracker = _G.WaynotesTracker
    local rxp = _G.RXPFrame
    local shouldShow = ns.db and tracker and (ns.db.standaloneGuide or (ns.db.replaceGuide and rxp)) and not ns.db.hideTracker
    if shouldShow and tracker:IsShown() then
        return
    end
    if ns.SyncReplacement then
        ns.SyncReplacement()
    elseif tracker and not shouldShow then
        tracker:Hide()
    end
end

local function editModeActive()
    if manager.IsEditModeActive then
        return manager:IsEditModeActive() and true or false
    end
    return manager:IsShown() and true or false
end

local function onLayoutsUpdated()
    local key = layoutKey()
    if not key or key == seenLayout then
        return
    end
    local tracker = _G.WaynotesTracker
    if not tracker then
        return
    end
    local saved = savedLayoutPoint()
    if saved then
        applyPoint(tracker, saved)
    end
    seenLayout = key
end

local function install()
    if selection then
        return true
    end
    manager = _G.EditModeManagerFrame
    local tracker = _G.WaynotesTracker
    if not manager or not tracker or not _G.C_EditMode or not State then
        return false
    end

    local ok, frame = pcall(CreateFrame, "Frame", "WaynotesEditModeSelection", tracker, "EditModeSystemSelectionTemplate")
    if not ok or not frame then
        return false
    end
    selection = frame
    selection:SetAllPoints(tracker)
    selection:EnableMouse(true)
    selection:RegisterForDrag("LeftButton")
    selection:Hide()
    selection.system = {
        GetSystemName = function()
            return "Waynotes"
        end,
    }
    function selection:GetLabelText()
        if self.IsSelected and self:IsSelected() then
            return "Waynotes"
        end
        local instructions = _G.HUD_EDIT_MODE_INSTRUCTIONS_CLICK_TO_EDIT
        if type(instructions) == "string" and instructions ~= "" then
            return instructions
        end
        return "Waynotes"
    end

    selection:SetScript("OnMouseDown", function(self, button)
        if button and button ~= "LeftButton" then
            return
        end
        if InCombatLockdown() then
            return
        end
        if manager.ClearSelectedSystem then
            pcall(manager.ClearSelectedSystem, manager)
        end
        tracker:SetMovable(true)
        if self.ShowSelected then
            pcall(self.ShowSelected, self)
        end
        showSettings(tracker)
    end)
    selection:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then
            return
        end
        tracker:SetMovable(true)
        tracker:StartMoving()
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
    end)
    selection:SetScript("OnDragStop", function(self)
        tracker:StopMovingOrSizing()
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
        if dialog and dialog:IsShown() then
            dialog:Place(tracker)
        end
    end)
    selection:SetScript("OnEvent", function(self)
        tracker:StopMovingOrSizing()
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end)

    hooksecurefunc(tracker, "StopMovingOrSizing", function()
        commitPoint(tracker)
    end)

    if manager.SelectSystem then
        hooksecurefunc(manager, "SelectSystem", function()
            if State.editMode then
                showSelection()
            end
        end)
    end

    manager:HookScript("OnShow", function()
        if editModeActive() then
            enterEditMode(tracker)
        end
    end)
    manager:HookScript("OnHide", function()
        if editModeActive() then
            selection:Hide()
            hideSettings()
        else
            exitEditMode()
        end
    end)

    if EventRegistry and EventRegistry.RegisterFrameEventAndCallback then
        pcall(EventRegistry.RegisterFrameEventAndCallback, EventRegistry, "EDIT_MODE_LAYOUTS_UPDATED", onLayoutsUpdated, tracker)
    end

    local created, built = pcall(createSettingsDialog)
    if created then
        dialog = built
    end

    if editModeActive() then
        enterEditMode(tracker)
    end
    onLayoutsUpdated()
    return true
end

if not install() then
    local boot = CreateFrame("Frame")
    boot:RegisterEvent("PLAYER_LOGIN")
    boot:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        self:SetScript("OnEvent", nil)
        install()
    end)
end
