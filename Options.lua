local _, ns = ...

local refreshers = {}

local function addRefresher(widget)
    refreshers[#refreshers + 1] = widget
end

local sliderCount = 0

local function createSlider(parent, text, tooltip, key, isEnabled, range)
    local minValue = range and range.min or 0
    local maxValue = range and range.max or 1
    local step = range and range.step or 0.01
    local asPercent = not range or range.percent ~= false
    local decimals = range and range.decimals
    local suffix = range and range.suffix or ""
    sliderCount = sliderCount + 1
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(46)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(text)

    local valueText = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("TOPRIGHT", 0, 0)

    local slider = CreateFrame("Slider", "WaynotesSlider" .. sliderCount, holder, "UISliderTemplate")
    slider:SetPoint("TOPLEFT", 4, -20)
    slider:SetPoint("TOPRIGHT", -4, -20)
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

    local function showValue(value)
        if asPercent then
            valueText:SetText(string.format("%d%%", math.floor(value * 100 + 0.5)))
        elseif decimals == 0 then
            valueText:SetText(string.format("%d%s", math.floor(value + 0.5), suffix))
        else
            valueText:SetText(string.format("%.2f", value))
        end
    end

    local function storedValue()
        local value = ns.db and ns.db[key]
        if type(value) ~= "number" then
            if asPercent then
                return 1
            end
            return minValue
        end
        return value
    end

    local ready = false

    slider:SetScript("OnValueChanged", function(self, value)
        local snapped = math.floor(value / step + 0.5) * step
        showValue(snapped)
        if suppress or not ready or not ns.db then
            return
        end
        ns.db[key] = snapped
        if ns.ApplySoon then
            ns.ApplySoon()
        else
            ns.Apply()
        end
    end)

    if tooltip then
        slider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(text, 1, 1, 1)
            GameTooltip:AddLine(tooltip, 0.9, 0.9, 0.9, true)
            ns.FinishTooltip()
        end)
        slider:SetScript("OnLeave", GameTooltip_Hide)
    end

    function holder:Refresh()
        local enabled = not isEnabled or isEnabled()
        local value = storedValue()
        ready = false
        suppress = true
        slider:SetValue(value)
        suppress = false
        ready = true
        showValue(value)
        if enabled then
            slider:Enable()
        else
            slider:Disable()
        end
        local fade = enabled and 1 or 0.45
        label:SetAlpha(fade)
        valueText:SetAlpha(fade)
    end

    addRefresher(holder)
    return holder
end

local checkCount = 0

local function createCheck(parent, text, tooltip, key)
    checkCount = checkCount + 1
    local name = "WaynotesCheck" .. checkCount
    local box = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    local fs = _G[name .. "Text"]
    if fs then
        fs:SetFontObject(GameFontHighlight)
        fs:SetText(text)
    end

    box:SetScript("OnClick", function(self)
        if not ns.db then
            return
        end
        ns.db[key] = self:GetChecked() and true or false
        ns.Apply()
        if ns.RefreshOptions then
            ns.RefreshOptions()
        end
    end)

    if tooltip then
        box:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(text, 1, 1, 1)
            GameTooltip:AddLine(tooltip, 0.9, 0.9, 0.9, true)
            ns.FinishTooltip()
        end)
        box:SetScript("OnLeave", GameTooltip_Hide)
    end

    function box:Refresh()
        self:SetChecked(ns.db[key] and true or false)
    end

    addRefresher(box)
    return box
end

local function createHeader(parent, text)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(22)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", 0, 2)
    label:SetText(text)
    label:SetTextColor(0.86, 0.7, 1)

    local line = holder:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("LEFT", label, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
    line:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    line:SetVertexColor(0.55, 0.38, 0.75, 0.9)

    return holder
end

local function createLayers(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(44)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText("Frame layer")

    local buttons = {}
    local positions = { 0, 130, 200, 290 }
    for index, info in ipairs(ns.layers) do
        local name = "WaynotesLayer" .. index
        local radio = CreateFrame("CheckButton", name, holder, "UIRadioButtonTemplate")
        radio:SetPoint("TOPLEFT", positions[index] or 0, -16)
        local fs = _G[name .. "Text"]
        if fs then
            fs:SetFontObject(GameFontHighlightSmall)
            fs:SetText(info.label)
        end

        radio:SetScript("OnClick", function()
            ns.db.strata = info.id
            ns.Apply()
            holder:Refresh()
        end)
        radio:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Frame layer", 1, 1, 1)
            GameTooltip:AddLine("Background sits behind most UI, the way RestedXP starts. High draws the guide, arrow, active items, and target frame above most frames.", 0.9, 0.9, 0.9, true)
            ns.FinishTooltip()
        end)
        radio:SetScript("OnLeave", GameTooltip_Hide)
        buttons[#buttons + 1] = radio
        buttons[radio] = info.id
    end

    function holder:Refresh()
        for _, radio in ipairs(buttons) do
            radio:SetChecked(buttons[radio] == ns.db.strata)
        end
    end

    addRefresher(holder)
    return holder
end

local function openPicker(r, g, b, onChange, onCancel)
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            hasOpacity = false,
            swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                onChange(nr, ng, nb)
            end,
            cancelFunc = function(previous)
                if previous then
                    onCancel(previous.r, previous.g, previous.b)
                else
                    onCancel(r, g, b)
                end
            end,
        })
        return
    end

    ColorPickerFrame.func = function()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        onChange(nr, ng, nb)
    end
    ColorPickerFrame.opacityFunc = nil
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.previousValues = { r = r, g = g, b = b }
    ColorPickerFrame.cancelFunc = function(previous)
        local saved = previous or ColorPickerFrame.previousValues
        onCancel(saved.r, saved.g, saved.b)
    end
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

local function createSwatch(parent, text, tooltip, getter, setter)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(24)

    local border = holder:CreateTexture(nil, "BACKGROUND")
    border:SetSize(20, 20)
    border:SetPoint("LEFT", 0, 0)
    border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    border:SetVertexColor(0, 0, 0, 1)

    local swatch = CreateFrame("Button", nil, holder)
    swatch:SetSize(16, 16)
    swatch:SetPoint("LEFT", 2, 0)
    local fill = swatch:CreateTexture(nil, "ARTWORK")
    fill:SetAllPoints()
    fill:SetTexture("Interface\\BUTTONS\\WHITE8X8")

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    label:SetText(text)

    swatch:SetScript("OnClick", function()
        local previousTheme = ns.db.theme
        local previousProfile = ns.db.activeProfile
        local r, g, b = getter()
        openPicker(r, g, b, function(nr, ng, nb)
            setter(nr, ng, nb)
            ns.db.theme = "custom"
            ns.db.activeProfile = nil
            ns.Apply()
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
        end, function(nr, ng, nb)
            setter(nr, ng, nb)
            ns.db.theme = previousTheme
            ns.db.activeProfile = previousProfile
            ns.Apply()
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
        end)
    end)

    if tooltip then
        swatch:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(text, 1, 1, 1)
            GameTooltip:AddLine(tooltip, 0.9, 0.9, 0.9, true)
            ns.FinishTooltip()
        end)
        swatch:SetScript("OnLeave", GameTooltip_Hide)
    end

    function holder:Refresh()
        local r, g, b = getter()
        fill:SetVertexColor(r, g, b)
    end

    addRefresher(holder)
    return holder
end

local function createThemes(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(44)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText("Theme")

    local dropdown = CreateFrame("Frame", "WaynotesThemeMenu", holder, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", -14, -16)
    UIDropDownMenu_SetWidth(dropdown, 184)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    local previewState = nil
    local previewCommitted = false

    local function captureState()
        return {
            theme = ns.db.theme,
            activeProfile = ns.db.activeProfile,
            trackerBackground = ns.db.trackerBackground,
            colors = ns.CopyTheme(ns.db.colors),
        }
    end

    local function restoreState(state)
        if not state or not ns.db then
            return
        end
        ns.db.theme = state.theme
        ns.db.activeProfile = state.activeProfile
        ns.db.trackerBackground = state.trackerBackground
        ns.db.colors = state.colors
        ns.Apply()
        if ns.RefreshOptions then
            ns.RefreshOptions()
        end
    end

    local function previewTheme(id)
        local theme = ns.themesById[id]
        if not theme or not ns.db then
            return
        end
        if not previewState then
            previewState = captureState()
        end
        previewCommitted = false
        ns.db.theme = id
        ns.db.activeProfile = nil
        ns.db.colors = ns.CopyTheme(theme)
        if type(theme.backgroundAlpha) == "number" then
            ns.db.trackerBackground = theme.backgroundAlpha
        end
        ns.Apply()
        if ns.RefreshOptions then
            ns.RefreshOptions()
        end
    end

    local function endPreview()
        if previewCommitted then
            previewCommitted = false
            previewState = nil
            return
        end
        if not previewState then
            return
        end
        local state = previewState
        previewState = nil
        restoreState(state)
    end

    local function commitTheme(id)
        previewCommitted = true
        previewState = nil
        ns.ApplyTheme(id)
    end

    local function ensureHideHook()
        local list = _G.DropDownList1
        if not list or list.waynotesThemeHideHooked then
            return
        end
        list.waynotesThemeHideHooked = true
        list:HookScript("OnHide", endPreview)
    end

    ensureHideHook()

    UIDropDownMenu_Initialize(dropdown, function()
        previewCommitted = false
        ensureHideHook()
        for index, theme in ipairs(ns.themeList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = theme.name
            info.value = theme.id
            info.checked = ns.db and ns.db.theme == theme.id
            info.func = function()
                commitTheme(theme.id)
            end
            UIDropDownMenu_AddButton(info)

            local button = _G["DropDownList1Button" .. index]
            if button then
                button.waynotesPreviewTheme = theme.id
                if not button.waynotesPreviewHooked then
                    button.waynotesPreviewHooked = true
                    button:HookScript("OnEnter", function(self)
                        if UIDROPDOWNMENU_OPEN_MENU ~= dropdown then
                            return
                        end
                        if self.waynotesPreviewTheme then
                            previewTheme(self.waynotesPreviewTheme)
                        end
                    end)
                end
            end
        end
    end)

    local dropButton = _G[dropdown:GetName() .. "Button"]
    if dropButton then
        dropButton:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Theme", 1, 1, 1)
            GameTooltip:AddLine("Hover a theme to preview it on the tracker. Click to apply. Individual colors can be changed afterward.", 0.9, 0.9, 0.9, true)
            ns.FinishTooltip()
        end)
        dropButton:HookScript("OnLeave", GameTooltip_Hide)
    end

    function holder:Refresh()
        local id = ns.db and ns.db.theme
        if id == "custom" then
            UIDropDownMenu_SetText(dropdown, "Custom")
            return
        end
        local theme = id and ns.themesById[id]
        UIDropDownMenu_SetText(dropdown, theme and theme.name or "Select a theme")
    end

    addRefresher(holder)
    return holder
end

local function createColors(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(196)

    local fields = {
        { key = "accent", label = "Accent", tip = "Header, border, and guide name." },
        { key = "background", label = "Background", tip = "Panel color. The background slider controls how solid it is." },
        { key = "text", label = "Current objective", tip = "Color of the main objective." },
        { key = "secondary", label = "Other objectives", tip = "Color of the objectives listed under the current one." },
        { key = "detail", label = "Details", tip = "Progress lines and extra notes." },
        { key = "glow", label = "Border glow", tip = "Color of the soft glow around the tracker and the guide/travel menus." },
    }

    for index, field in ipairs(fields) do
        local swatch = createSwatch(holder, field.label, field.tip, function()
            return ns.Color(field.key)
        end, function(r, g, b)
            ns.db.colors[field.key] = { r, g, b }
        end)
        swatch:SetPoint("TOPLEFT", 0, -(index - 1) * 28)
        swatch:SetPoint("TOPRIGHT", holder, "TOP", -8, -(index - 1) * 28)
    end

    for index = 1, 6 do
        local swatch = createSwatch(holder, "Badge " .. index, "Color of step badge " .. index .. ". Later objectives repeat these colors.", function()
            return ns.BadgeColor(index)
        end, function(r, g, b)
            ns.db.colors.badges[index] = { r, g, b }
        end)
        swatch:SetPoint("TOPLEFT", holder, "TOP", 8, -(index - 1) * 28)
        swatch:SetPoint("TOPRIGHT", 0, -(index - 1) * 28)
    end

    return holder
end

local function createProfiles(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(96)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText("Settings profiles")

    local hint = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 0, -16)
    hint:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText("Save all current addon options. Choose a saved profile from the menu to restore them.")

    local edit = CreateFrame("EditBox", "WaynotesProfileName", holder, "InputBoxTemplate")
    edit:SetSize(200, 20)
    edit:SetPoint("TOPLEFT", 8, -36)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(24)
    edit:SetFontObject(GameFontHighlightSmall)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    local save = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
    save:SetSize(80, 22)
    save:SetPoint("LEFT", edit, "RIGHT", 8, 0)
    save:SetText("Save")
    save:SetScript("OnClick", function()
        if ns.SaveProfile(edit:GetText()) then
            edit:SetText("")
            edit:ClearFocus()
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
        end
    end)
    edit:SetScript("OnEnterPressed", function()
        save:Click()
    end)

    local dropdown = CreateFrame("Frame", "WaynotesProfileMenu", holder, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", -14, -60)
    UIDropDownMenu_SetWidth(dropdown, 184)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    UIDropDownMenu_Initialize(dropdown, function()
        local profiles = ns.db and ns.db.profiles or {}
        if #profiles == 0 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = "No saved profiles"
            info.notCheckable = true
            info.disabled = true
            UIDropDownMenu_AddButton(info)
            return
        end
        for _, profile in ipairs(profiles) do
            local name = profile.name
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = name
            info.checked = ns.db.activeProfile == name
            info.func = function(button)
                local picked = button and button.value or name
                ns.LoadProfile(picked)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local delete = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
    delete:SetSize(80, 22)
    delete:SetPoint("TOPLEFT", 230, -64)
    delete:SetText("Delete")
    delete:SetScript("OnClick", function()
        local name = ns.db and ns.db.activeProfile
        if not name then
            return
        end
        if StaticPopup_Show then
            StaticPopup_Show("WaynotesDeleteProfile", name, nil, name)
        else
            ns.DeleteProfile(name)
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
        end
    end)

    function holder:Refresh()
        local name = ns.db and ns.db.activeProfile
        UIDropDownMenu_SetText(dropdown, name or "Select a profile")
        if name then
            delete:Enable()
        else
            delete:Disable()
        end
    end

    addRefresher(holder)
    return holder
end

if not StaticPopupDialogs["WaynotesDeleteProfile"] then
    StaticPopupDialogs["WaynotesDeleteProfile"] = {
        text = "Delete the settings profile \"%s\"?",
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function(self, data)
            local name = data or (self and self.data)
            if name then
                ns.DeleteProfile(name)
                if ns.RefreshOptions then
                    ns.RefreshOptions()
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function ns.RefreshOptions()
    if not ns.db then
        return
    end
    for _, widget in ipairs(refreshers) do
        if widget.Refresh then
            widget:Refresh()
        end
    end
end

local applyQueued = false

function ns.ApplySoon()
    if applyQueued then
        return
    end
    applyQueued = true
    C_Timer.After(0, function()
        applyQueued = false
        ns.Apply()
    end)
end

local function place(widget, parent, y)
    widget:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)
    widget:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, y)
end

local function trackerOn()
    return ns.db and (ns.db.standaloneGuide or ns.db.replaceGuide) and true or false
end

local function build(parent)
    local y = -4

    local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 16, y)
    desc:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("TOP")
    desc:SetText("Tracker style and colors. Replace RestedXP runs your custom guides and hides the RestedXP window.")
    y = y - 36

    local profiles = createProfiles(parent)
    place(profiles, parent, y)
    y = y - 104

    local ourHeader = createHeader(parent, "Replace RestedXP")
    place(ourHeader, parent, y)
    y = y - 28

    local standalone = createCheck(parent, "Replace RestedXP", "Uses guides from the Guides folder in this tracker and hides RestedXP. Quest names, givers, and pins come from QuestieDB when it is installed.", "standaloneGuide")
    standalone:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    local standaloneRefresh = standalone.Refresh
    function standalone:Refresh()
        if standaloneRefresh then
            standaloneRefresh(self)
        end
        local locked = ns.RestedXPActive and ns.RestedXPActive()
        local label = _G[self:GetName() .. "Text"]
        if locked then
            self:SetChecked(false)
            self:Disable()
            if label then
                label:SetAlpha(0.45)
            end
        else
            self:Enable()
            if label then
                label:SetAlpha(1)
            end
        end
    end
    standalone:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Replace RestedXP", 1, 1, 1)
        if ns.RestedXPActive and ns.RestedXPActive() then
            GameTooltip:AddLine("RestedXP is loaded, so this stays off. Right-click the tracker to open its guides in this window.", 0.9, 0.9, 0.9, true)
        else
            GameTooltip:AddLine("Uses guides from the Guides folder in this tracker and hides RestedXP. Quest names, givers, and pins come from QuestieDB when it is installed.", 0.9, 0.9, 0.9, true)
        end
        ns.FinishTooltip()
    end)
    standalone:SetScript("OnClick", function(self)
        if not ns.db or (ns.RestedXPActive and ns.RestedXPActive()) then
            self:SetChecked(false)
            return
        end
        ns.db.standaloneGuide = self:GetChecked() and true or false
        ns.Apply()
        if ns.RefreshOptions then
            ns.RefreshOptions()
        end
    end)
    y = y - 28

    local hardcore = createCheck(parent, "Hardcore steps", "Follows the hardcore branch of a guide and hides the softcore branch.", "hardcoreGuide")
    hardcore:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 28

    local offStep = createCheck(parent, "Suggest jump on other-step progress", "When you kill or advance an objective that belongs to another step in the active guide, asks if you want to jump there. Turn this back on after choosing Don't Ask Again.", "promptOffStepJump")
    offStep:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 28

    local dungeonGuide = createCheck(parent, "Suggest dungeon guide on enter", "When you enter a dungeon, asks if you want to load the matching dungeon guide. Turn this back on after choosing Don't Ask Again.", "promptDungeonGuide")
    dungeonGuide:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 28

    local allGuides = createCheck(parent, "Show unrelated guides", "Lists class, race, and faction guides that do not match this character in the right-click guide menu. Leave off to only show guides relevant to you.", "showIrrelevantGuides")
    allGuides:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 28

    local guideStatus = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    guideStatus:SetJustifyH("LEFT")
    guideStatus:SetJustifyV("TOP")
    if guideStatus.SetWordWrap then
        guideStatus:SetWordWrap(true)
    end
    guideStatus:SetHeight(32)
    place(guideStatus, parent, y)
    function guideStatus:Refresh()
        if ns.RestedXPActive and ns.RestedXPActive() then
            local title = "RestedXP"
            local rxp = ns.RestedXP and ns.RestedXP()
            local current = rxp and rxp.currentGuide
            if type(current) == "table" and type(rxp.GetGuideName) == "function" then
                local ok, name = pcall(rxp.GetGuideName, current)
                if ok and type(name) == "string" then
                    name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                    name = strtrim(name:match("^[^\n]+") or name)
                    if name ~= "" then
                        title = name
                    end
                end
            end
            self:SetText(title .. ". RestedXP is loaded, so Replace RestedXP stays off. Right-click the tracker to choose one of its guides.")
            self:SetTextColor(0.9, 0.9, 0.9)
            return
        end
        if not ns.db or not ns.db.standaloneGuide then
            self:SetText("Replace RestedXP is off. The tracker follows RestedXP while Replace the guide window is on.")
            self:SetTextColor(0.7, 0.7, 0.7)
            return
        end
        local title = ns.GuideTitle and ns.GuideTitle() or "Guide"
        if ns.PlayerRace and ns.PlayerClass and ns.PlayerRace() and ns.PlayerClass() then
            title = ns.PlayerRace() .. " " .. ns.PlayerClass() .. ", " .. title
        end
        local source
        if ns.QuestieReady and ns.QuestieReady() then
            source = "QuestieDB is installed."
        else
            source = "QuestieDB is not installed, so steps use the text you wrote."
        end
        local tip = "Right-click the tracker to choose a guide."
        if ns.RecommendedGuide then
            local recommended = ns.RecommendedGuide()
            if recommended then
                tip = "Recommended: " .. recommended.name .. ". " .. tip
            end
        end
        self:SetText(title .. ". " .. source .. " " .. tip)
        self:SetTextColor(0.9, 0.9, 0.9)
    end
    addRefresher(guideStatus)
    y = y - 40

    local replaceHeader = createHeader(parent, "Tracker")
    place(replaceHeader, parent, y)
    y = y - 28

    local replace = createCheck(parent, "Replace the guide window", "Shows the current objective in a WoW-style tracker and keeps RestedXP running behind it. Right-click the tracker to open the guide list. While Replace RestedXP is on, this stays paused and RestedXP stays hidden.", "replaceGuide")
    replace:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local simple = createCheck(parent, "Simple mode", "Shows only one step at a time: the earliest incomplete active step, including sticky steps.", "simpleMode")
    simple:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local guidePercent = createCheck(parent, "Show guide progress", "Shows how far you are through the current guide as a percentage in the tracker header.", "showGuidePercent")
    guidePercent:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local flightTimer = createCheck(parent, "Show flight timer", "While you are on a flight path, shows the destination and remaining time at the bottom of the tracker. Uses Forever flight-time data by default, then updates your local times after each flight.", "showFlightTimer")
    flightTimer:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local trainReminders = createCheck(parent, "Train spell reminders", "At even levels, shows a closable note at the bottom of the guide. Click it to navigate to your nearest class trainer.", "showTrainReminders")
    trainReminders:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 36

    local themes = createThemes(parent)
    place(themes, parent, y)
    y = y - 52

    local colors = createColors(parent)
    place(colors, parent, y)
    y = y - 204

    local trackerScale = createSlider(parent, "Tracker scale", "Zooms the whole tracker, including the text. 120% is a bit larger than a standard quest tracker.", "trackerScale", function()
        return trackerOn()
    end, { min = 0.8, max = 2, step = 0.05, percent = true })
    place(trackerScale, parent, y)
    y = y - 52

    local trackerWidth = createSlider(parent, "Tracker width", "Width of the panel. The steps wrap to fit. This does not change the font size.", "trackerWidth", function()
        return trackerOn()
    end, { min = 220, max = 640, step = 10, percent = false, decimals = 0, suffix = " px" })
    place(trackerWidth, parent, y)
    y = y - 52

    local fitHeight = createCheck(parent, "Fit height to steps", "The panel grows with the steps. Turn this off to set a height and scroll the rest.", "trackerFitHeight")
    fitHeight:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local trackerHeight = createSlider(parent, "Tracker height", "Height of the panel. Extra steps scroll inside it.", "trackerHeight", function()
        return trackerOn() and not ns.db.trackerFitHeight
    end, { min = 120, max = 800, step = 10, percent = false, decimals = 0, suffix = " px" })
    place(trackerHeight, parent, y)
    y = y - 52

    local trackerBackground = createSlider(parent, "Tracker background", "Darkness of the panel behind the objectives. The text stays solid.", "trackerBackground", function()
        return trackerOn()
    end)
    place(trackerBackground, parent, y)
    y = y - 58

    local styleHeader = createHeader(parent, "Style")
    place(styleHeader, parent, y)
    y = y - 28

    local darkHeader = createCheck(parent, "Darkened header", "Draws a darker bar behind the guide name and the step buttons.", "darkHeader")
    darkHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local headerShade = createSlider(parent, "Header shade", "How much darker that bar is than the tracker background.", "headerShade", function()
        return trackerOn() and ns.db.darkHeader
    end)
    place(headerShade, parent, y)
    y = y - 52

    local rounded = createCheck(parent, "Rounded edges", "Rounds the tracker corners and the header buttons.", "roundedEdges")
    rounded:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local cornerSize = createSlider(parent, "Corner size", "Radius of the tracker corners.", "cornerRadius", function()
        return trackerOn() and ns.db.roundedEdges
    end, { min = 4, max = 16, step = 1, percent = false, decimals = 0, suffix = " px" })
    place(cornerSize, parent, y)
    y = y - 52

    local roundBadges = createCheck(parent, "Round step numbers", "Draws each step number as a circle.", "roundBadges")
    roundBadges:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local trackerBorder = createCheck(parent, "Tracker border", "Draws an accent line around the tracker.", "trackerBorder")
    trackerBorder:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local trackerShadow = createCheck(parent, "Drop shadow", "Draws a shadow behind the tracker so it stands out from the world.", "trackerShadow")
    trackerShadow:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local menuGlow = createCheck(parent, "Border glow", "Draws a soft glow around the tracker and the guide/travel menus. Color is under Theme colors as Menu glow.", "menuBorderGlow")
    menuGlow:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local glowRadius = createSlider(parent, "Glow radius", "How far the glow spreads outward from the tracker and menu edges.", "menuGlowRadius", function()
        return trackerOn() and ns.db.menuBorderGlow
    end, { min = 1, max = 16, step = 1, percent = false, decimals = 0, suffix = " px" })
    place(glowRadius, parent, y)
    y = y - 52

    local guideHeader = createHeader(parent, "Guide window")
    place(guideHeader, parent, y)
    y = y - 30

    local background = createSlider(parent, "Background", "Fades the dark fill behind the guide. Text, icons, and the logo stay solid.", "backgroundAlpha")
    place(background, parent, y)
    y = y - 52

    local banner = createSlider(parent, "Banner", "Fades the header and footer artwork. The logo and buttons stay solid.", "bannerAlpha")
    place(banner, parent, y)
    y = y - 52

    local border = createSlider(parent, "Border", "Fades the frame edges and the step list scrollbar.", "borderAlpha")
    place(border, parent, y)
    y = y - 52

    local steps = createSlider(parent, "Faded steps", "How visible completed, skipped, and past steps are in the step list. Current and upcoming steps stay solid.", "stepListAlpha")
    place(steps, parent, y)
    y = y - 50

    local outline = createCheck(parent, "Outline guide text", "Draws a dark outline on guide text so it stays readable when the background is faint.", "textOutline")
    outline:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 32

    local layers = createLayers(parent)
    place(layers, parent, y)
    y = y - 52

    local fadeHeader = createHeader(parent, "Fade")
    place(fadeHeader, parent, y)
    y = y - 30

    local hover = createCheck(parent, "Fade unless the cursor is over the guide", "Dims the whole guide, including text, until you mouse over it.", "fadeUnlessHover")
    hover:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local idle = createSlider(parent, "Idle visibility", "How visible the guide is while the cursor is somewhere else.", "idleAlpha", function()
        return ns.db.fadeUnlessHover
    end)
    place(idle, parent, y)
    y = y - 52

    local combat = createCheck(parent, "Fade while in combat", "Caps the guide, arrow, active items, and target frame while you are in combat.", "fadeInCombat")
    combat:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    y = y - 30

    local combatAlpha = createSlider(parent, "Combat visibility", "Visibility used during combat. The guide fades to this, and the arrow, active items, and target frame are capped at it.", "combatAlpha", function()
        return ns.db.fadeInCombat
    end)
    place(combatAlpha, parent, y)
    y = y - 56

    local otherHeader = createHeader(parent, "Other frames")
    place(otherHeader, parent, y)
    y = y - 30

    local arrow = createSlider(parent, "Waypoint arrow", "Opacity of the arrow and its distance text. RestedXP still hides the arrow when it has no destination.", "arrowAlpha")
    place(arrow, parent, y)
    y = y - 52

    local items = createSlider(parent, "Active items", "Opacity of the active item button.", "activeItemAlpha")
    place(items, parent, y)
    y = y - 52

    local target = createSlider(parent, "Target frame", "Opacity of the RestedXP target frame.", "targetAlpha")
    place(target, parent, y)
    y = y - 58

    local reset = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    reset:SetSize(150, 24)
    reset:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)
    reset:SetText("Reset defaults")
    reset:SetScript("OnClick", function()
        ns.Reset()
    end)

    parent:SetHeight(math.abs(y) + 48)
end

local canvas = CreateFrame("Frame", "WaynotesOptions")
canvas.name = "Waynotes"
canvas:SetSize(520, 400)
if canvas.SetClipsChildren then
    canvas:SetClipsChildren(true)
end

local scroll = CreateFrame("ScrollFrame", "WaynotesOptionsScroll", canvas, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 0, -4)
scroll:SetPoint("BOTTOMRIGHT", -28, 4)

local child = CreateFrame("Frame", nil, scroll)
child:SetSize(480, 800)
scroll:SetScrollChild(child)
build(child)

local function fitScroll()
    local width = canvas:GetWidth() or 520
    if width < 200 then
        width = 520
    end
    child:SetWidth(width - 36)
end

local function refreshCanvas()
    ns.InitDB()
    fitScroll()
    ns.RefreshOptions()
end

canvas.refresh = refreshCanvas
canvas:SetScript("OnSizeChanged", fitScroll)
canvas:SetScript("OnShow", refreshCanvas)

scroll:EnableMouseWheel(true)
scroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = self:GetVerticalScrollRange()
    local nextScroll = current - delta * 48
    if nextScroll < 0 then
        nextScroll = 0
    elseif nextScroll > maxScroll then
        nextScroll = maxScroll
    end
    self:SetVerticalScroll(nextScroll)
end)

local optionsCategory

local function registerSettings()
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        optionsCategory = Settings.RegisterCanvasLayoutCategory(canvas, canvas.name)
        Settings.RegisterAddOnCategory(optionsCategory)
        return
    end
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(canvas)
    end
end

function ns.OpenOptions()
    ns.InitDB()
    ns.db.acknowledged = true
    if optionsCategory and Settings and Settings.OpenToCategory and optionsCategory.GetID then
        Settings.OpenToCategory(optionsCategory:GetID())
        return
    end
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(canvas.name)
        return
    end
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(canvas)
        InterfaceOptionsFrame_OpenToCategory(canvas)
    end
end

local registrar = CreateFrame("Frame")
registrar:RegisterEvent("PLAYER_LOGIN")
registrar:SetScript("OnEvent", function()
    pcall(registerSettings)
    registrar:UnregisterAllEvents()
end)

SLASH_WAYNOTES1 = "/waynotes"
SLASH_WAYNOTES2 = "/wn"
SlashCmdList.WAYNOTES = function(message)
    ns.InitDB()
    local text = strtrim(message or "")
    local command = string.lower(text)
    if command == "reset" then
        ns.Reset()
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r options reset.")
        return
    end
    if command == "mapdebug" then
        if ns.MapBadgeDebug then
            ns.MapBadgeDebug()
        end
        return
    end
    if command == "perf" then
        if ns.StartPerf then
            ns.StartPerf(10)
        end
        return
    end
    if command == "guides" or command == "guide" then
        if ns.PrintGuides then
            ns.PrintGuides()
        end
        return
    end
    if command == "recommend" or command == "recommended" then
        if not ns.RecommendedGuide then
            return
        end
        local guide = ns.RecommendedGuide()
        if not guide then
            DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r No recommended guide for this character.")
            return
        end
        if ns.GuideSelect then
            ns.GuideSelect(guide.id)
        end
        return
    end
    if command:sub(1, 6) == "guide " then
        if ns.GuideSelect then
            ns.GuideSelect(strtrim(text:sub(7)))
        end
        return
    end
    if command:sub(1, 5) == "step " then
        if ns.GuideJump then
            ns.GuideJump(tonumber(text:match("%d+")))
        end
        return
    end
    if command == "next" then
        if ns.GuideStep then
            ns.GuideStep(1)
        end
        return
    end
    if command == "back" or command == "prev" then
        if ns.GuideStep then
            ns.GuideStep(-1)
        end
        return
    end
    if command == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r /waynotes guides, /waynotes recommend, /waynotes guide <id>, /waynotes step <n>, /waynotes next, /waynotes back, /waynotes aim, /waynotes aimlog")
        return
    end
    if command == "aim" then
        if ns.PrintAim then
            ns.PrintAim()
        end
        return
    end
    if command == "aimlog" then
        if ns.StartAimLog then
            ns.StartAimLog()
        end
        return
    end
    ns.OpenOptions()
end
