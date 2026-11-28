local _, ns = ...

-- Optional damage meter attached under the guide (and under the step list when
-- that is shown). Toggle: showDamageMeter. Default on,
-- shown only while in a group (damageMeterGroupOnly, default on).
--
-- Forever blocks addons from reading the combat log, so this displays the
-- client's built-in C_DamageMeter data (you, your group, pets merged by the
-- client). Values can be "secret" during combat, so numbers are only used for
-- math when they are plain, and are otherwise handed straight to widgets.
-- Rows use class icons and class colors.

local GAP = 6
local HEADER = 18
local ROW = 18
local FONT_SIZE = 12
local ICON_BORDER = 2 -- thickness of the black outline around class icons
local ICON_SIZE = ROW - (ICON_BORDER * 2) - 2
-- Column widths scale with the font size (these match FONT_SIZE 12).
local PCT_W = 42
local DPS_W = 46
local VALUE_W = 52
local PAD = 4
local MAX_ROWS = 6
local ICON_TEXTURE = "Interface\\WorldStateFrame\\Icons-Classes"
local BAR_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

local FALLBACK_COORDS = {
    WARRIOR = { 0, 0.25, 0, 0.25 },
    MAGE = { 0.25, 0.5, 0, 0.25 },
    ROGUE = { 0.5, 0.75, 0, 0.25 },
    DRUID = { 0.75, 1, 0, 0.25 },
    HUNTER = { 0, 0.25, 0.25, 0.5 },
    SHAMAN = { 0.25, 0.5, 0.25, 0.5 },
    PRIEST = { 0.5, 0.75, 0.25, 0.5 },
    WARLOCK = { 0.75, 1, 0.25, 0.5 },
    PALADIN = { 0, 0.25, 0.5, 0.75 },
}

local EMPTY = {}
local filtered = {}

-- Which session the meter shows. Stored in ns.db.damageMeterView.
ns.DamageMeterViews = {
    {
        id = "auto",
        label = "Overall, current while in combat",
        tip = "Shows overall damage. While you are in combat it switches to the current fight, and goes back to overall when combat ends.",
    },
    {
        id = "hold",
        label = "Overall, then keep current after combat",
        tip = "Shows overall damage until you enter combat, then stays on the current fight until you reset or click the title.",
    },
    {
        id = "overall",
        label = "Always overall",
        tip = "Always shows the overall total.",
    },
    {
        id = "current",
        label = "Always current fight",
        tip = "Always shows the current (or most recent) fight.",
    },
}

local panel
local headerBar
local titleButton
local titleText
local resetButton
local emptyText
local rows = {}
local painted = false
local anchoredTo
local manualOverall -- click override: true, false, or nil (follow the setting)
local inCombat = false
local heldCurrent = false
local scrollOffset = 0
local sourceCount = 0
local running = false
local reported = false

local driver = CreateFrame("Frame")

local function tracker()
    return _G.WaynotesTracker
end

local function enabled()
    return ns.db and ns.db.showDamageMeter and true or false
end

-- ROW, HEADER, FONT_SIZE and the column widths follow the options. Returns
-- true when anything changed so the caller can re-layout existing frames.
local function readMetrics()
    local rowHeight = ns.db and ns.db.damageMeterRowHeight
    local fontSize = ns.db and ns.db.damageMeterFontSize
    if type(rowHeight) ~= "number" then
        rowHeight = 18
    end
    if type(fontSize) ~= "number" then
        fontSize = 12
    end
    rowHeight = math.max(14, math.min(32, math.floor(rowHeight + 0.5)))
    fontSize = math.max(8, math.min(20, math.floor(fontSize + 0.5)))
    if rowHeight == ROW and fontSize == FONT_SIZE then
        return false
    end
    ROW = rowHeight
    HEADER = rowHeight
    FONT_SIZE = fontSize
    ICON_SIZE = math.max(8, ROW - (ICON_BORDER * 2) - 2)
    PCT_W = math.ceil(FONT_SIZE * 3.5)
    DPS_W = math.ceil(FONT_SIZE * 3.85)
    VALUE_W = math.ceil(FONT_SIZE * 4.35)
    return true
end

local function inGroup()
    if IsInGroup then
        return IsInGroup() and true or false
    end
    return GetNumGroupMembers ~= nil and GetNumGroupMembers() > 1
end

local function isSecret(value)
    return issecretvalue ~= nil and issecretvalue(value) and true or false
end

local function plainNumber(value)
    return type(value) == "number" and not isSecret(value)
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

-- Create a font string that already has a font, so SetText is always safe.
local function makeText(parent, size, flags)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    applyFont(fs, size, flags)
    return fs
end

local function classColor(class)
    if type(class) == "string" and not isSecret(class) then
        local colors = _G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS
        local c = colors and colors[class]
        if c then
            return c.r, c.g, c.b
        end
    end
    return 0.6, 0.6, 0.6
end

local function shortNumber(n)
    if n >= 1000000 then
        return string.format("%.2fM", n / 1000000)
    elseif n >= 10000 then
        return string.format("%.1fK", n / 1000)
    end
    return tostring(math.floor(n + 0.5))
end

-- Plain numbers are formatted here; secret ones go through the client's own
-- abbreviator, which accepts them.
local function formatAmount(value)
    if plainNumber(value) then
        return shortNumber(value)
    end
    if value ~= nil and AbbreviateNumbers then
        local ok, text = pcall(AbbreviateNumbers, value)
        if ok and text then
            return text
        end
    end
    return ""
end

local function clock(seconds)
    seconds = math.floor(seconds + 0.5)
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

---------------------------------------------------------------------------
-- Data (C_DamageMeter)
---------------------------------------------------------------------------

local function apiReady()
    return C_DamageMeter
        and C_DamageMeter.GetCombatSessionFromType
        and Enum
        and Enum.DamageMeterSessionType
        and Enum.DamageMeterType
        and true
        or false
end

local function wantOverall()
    if manualOverall ~= nil then
        return manualOverall
    end
    local mode = ns.db and ns.db.damageMeterView or "auto"
    if mode == "overall" then
        return true
    elseif mode == "current" then
        return false
    elseif mode == "hold" then
        return not heldCurrent
    end
    return not inCombat
end

local function currentSessionType()
    local types = Enum.DamageMeterSessionType
    if wantOverall() then
        return types.Overall
    end
    return types.Current
end

-- Returns session table, or nil plus a reason ("api" or "off" or "none").
local function getSession()
    if not apiReady() then
        return nil, "api"
    end
    if C_DamageMeter.IsDamageMeterAvailable then
        local ok, available = pcall(C_DamageMeter.IsDamageMeterAvailable)
        if ok and available == false then
            return nil, "off"
        end
    end
    local ok, session = pcall(C_DamageMeter.GetCombatSessionFromType, currentSessionType(), Enum.DamageMeterType.DamageDone)
    if ok and type(session) == "table" then
        return session
    end
    return nil, "none"
end

-- The client normally returns sources highest first. Re-sort only when every
-- amount is plain, since secret values cannot be compared.
local function sortIfPlain(sources)
    for index = 1, #sources do
        local source = sources[index]
        if type(source) ~= "table" or not plainNumber(source.totalAmount) then
            return
        end
    end
    table.sort(sources, function(a, b)
        return a.totalAmount > b.totalAmount
    end)
end

local function validClass(class)
    local colors = _G.RAID_CLASS_COLORS
    return colors ~= nil and colors[class] ~= nil
end

-- True when a source looks like a player. Anything the client hides from us
-- (secret values) gets the benefit of the doubt.
local function isPlayerSource(source)
    local guid = source.sourceGUID
    if type(guid) == "string" and not isSecret(guid) then
        return guid:find("^Player") ~= nil
    end
    local creatureID = source.sourceCreatureID
    if plainNumber(creatureID) and creatureID > 0 then
        return false
    end
    local class = source.classFilename
    if isSecret(class) then
        return true
    end
    -- Players always have a class; NPCs do not.
    return type(class) == "string" and validClass(class)
end

-- Keep only real players. The client's list can include non-player sources
-- (for example a dungeon boss). Returns the list plus a max and total computed
-- from it, or nil for those when any amount is secret.
local function playersOnly(sources)
    wipe(filtered)
    local allPlain = true
    local top, sum = 0, 0
    for index = 1, #sources do
        local source = sources[index]
        if type(source) == "table" and isPlayerSource(source) then
            filtered[#filtered + 1] = source
            if plainNumber(source.totalAmount) then
                sum = sum + source.totalAmount
                if source.totalAmount > top then
                    top = source.totalAmount
                end
            else
                allPlain = false
            end
        end
    end
    if allPlain then
        return filtered, top, sum
    end
    return filtered, nil, nil
end

local function resetData()
    if C_DamageMeter and C_DamageMeter.ResetAllCombatSessions then
        pcall(C_DamageMeter.ResetAllCombatSessions)
    end
    heldCurrent = false
    scrollOffset = 0
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

local function stylePanel()
    if not panel or not ns.db then
        return
    end
    if ns.StylePopupFrame then
        ns.StylePopupFrame(panel, { matchTracker = true })
    end
    painted = true
end

local function spellName(spellID)
    if not spellID then
        return "Unknown"
    end
    if C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, spellID)
        if ok and name then
            return name
        end
    end
    if GetSpellInfo then
        local ok, name = pcall(GetSpellInfo, spellID)
        if ok and name then
            return name
        end
    end
    return "Spell " .. tostring(spellID)
end

local function fillTooltip(row)
    GameTooltip:SetText(row.name:GetText() or "Unknown", row.r or 1, row.g or 1, row.b or 1)
    GameTooltip:AddDoubleLine("Damage", row.value:GetText() or "", 0.9, 0.9, 0.9, 1, 1, 1)
    if not (C_DamageMeter and C_DamageMeter.GetCombatSessionSourceFromType) then
        return
    end
    local ok, detail = pcall(
        C_DamageMeter.GetCombatSessionSourceFromType,
        row.sessionType,
        Enum.DamageMeterType.DamageDone,
        row.guid
    )
    local spells = ok and type(detail) == "table" and detail.combatSpells
    if type(spells) ~= "table" then
        return
    end
    sortIfPlain(spells)
    for index = 1, math.min(10, #spells) do
        local spell = spells[index]
        GameTooltip:AddDoubleLine(spellName(spell.spellID), formatAmount(spell.totalAmount), 0.85, 0.85, 0.85, 1, 1, 1)
    end
end

local function showRowTip(row)
    if not row.guid then
        return
    end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    local ok = pcall(fillTooltip, row)
    if not ok then
        GameTooltip:ClearLines()
        GameTooltip:SetText(row.name:GetText() or "Unknown", 1, 1, 1)
    end
    if ns.FinishTooltip then
        ns.FinishTooltip()
    else
        GameTooltip:Show()
    end
end

-- Re-apply the current size and font to an existing row.
local function layoutRow(row, index)
    row:SetHeight(ROW)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -(PAD + HEADER + (index - 1) * ROW))
    row:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, -(PAD + HEADER + (index - 1) * ROW))
    row.icon:SetSize(ICON_SIZE, ICON_SIZE)
    for _, stamp in ipairs(row.outline) do
        stamp:SetSize(ICON_SIZE, ICON_SIZE)
    end
    for _, fs in ipairs({ row.pct, row.dps, row.value, row.name }) do
        applyFont(fs, FONT_SIZE, "OUTLINE")
    end
    row.pct:SetWidth(PCT_W)
    row.dps:SetWidth(DPS_W)
    row.value:SetWidth(VALUE_W)
end

local function acquireRow(index)
    local row = rows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, panel)
    row:SetHeight(ROW)
    row:EnableMouse(true)
    row:EnableMouseWheel(true)
    row:RegisterForClicks("RightButtonUp")
    row:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -(PAD + HEADER + (index - 1) * ROW))
    row:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, -(PAD + HEADER + (index - 1) * ROW))

    row.back = row:CreateTexture(nil, "BACKGROUND")
    row.back:SetPoint("TOPLEFT", 0, 0)
    row.back:SetPoint("BOTTOMRIGHT", 0, 1)
    row.back:SetTexture(BAR_TEXTURE)

    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetPoint("TOPLEFT", 0, 0)
    row.bar:SetPoint("BOTTOMRIGHT", 0, 1)
    row.bar:SetStatusBarTexture(BAR_TEXTURE)
    row.bar:SetMinMaxValues(0, 1)
    row.bar:SetValue(0)
    row.bar:SetFrameLevel(row:GetFrameLevel() + 1)

    local overlay = CreateFrame("Frame", nil, row)
    overlay:SetAllPoints()
    overlay:SetFrameLevel(row:GetFrameLevel() + 2)

    row.icon = overlay:CreateTexture(nil, "OVERLAY")
    row.icon:SetSize(ICON_SIZE, ICON_SIZE)
    row.icon:SetPoint("LEFT", ICON_BORDER + 1, 0)
    row.icon:SetTexture(ICON_TEXTURE)

    -- Black outline that follows the icon's own shape: black copies of the
    -- icon stamped around it in eight directions, drawn behind the real one.
    row.outline = {}
    local d = ICON_BORDER
    local offsets = { { -d, 0 }, { d, 0 }, { 0, -d }, { 0, d }, { -d, -d }, { d, -d }, { -d, d }, { d, d } }
    for index, offset in ipairs(offsets) do
        local stamp = overlay:CreateTexture(nil, "ARTWORK")
        stamp:SetSize(ICON_SIZE, ICON_SIZE)
        stamp:SetPoint("CENTER", row.icon, "CENTER", offset[1], offset[2])
        stamp:SetTexture(ICON_TEXTURE)
        stamp:SetVertexColor(0, 0, 0, 1)
        row.outline[index] = stamp
    end

    row.pct = makeText(overlay, FONT_SIZE, "OUTLINE")
    row.pct:SetPoint("RIGHT", -4, 0)
    row.pct:SetWidth(PCT_W)
    row.pct:SetJustifyH("RIGHT")

    row.dps = makeText(overlay, FONT_SIZE, "OUTLINE")
    row.dps:SetPoint("RIGHT", row.pct, "LEFT", -4, 0)
    row.dps:SetWidth(DPS_W)
    row.dps:SetJustifyH("RIGHT")

    row.value = makeText(overlay, FONT_SIZE, "OUTLINE")
    row.value:SetPoint("RIGHT", row.dps, "LEFT", -4, 0)
    row.value:SetWidth(VALUE_W)
    row.value:SetJustifyH("RIGHT")

    row.name = makeText(overlay, FONT_SIZE, "OUTLINE")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", ICON_BORDER + 4, 0)
    row.name:SetPoint("RIGHT", row.value, "LEFT", -6, 0)
    row.name:SetJustifyH("LEFT")
    if row.name.SetWordWrap then
        row.name:SetWordWrap(false)
    end
    if row.name.SetMaxLines then
        row.name:SetMaxLines(1)
    end

    for _, fs in ipairs({ row.pct, row.dps, row.value, row.name }) do
        fs:SetTextColor(1, 1, 1)
    end

    row:SetScript("OnEnter", showRowTip)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(_, button)
        if button == "RightButton" and ns.OpenGuideMenu then
            ns.OpenGuideMenu("damageMeter")
        end
    end)
    row:SetScript("OnMouseWheel", function(_, delta)
        ns.DamageMeterScroll(delta)
    end)

    rows[index] = row
    return row
end

local function paintRow(row, source, maxAmount, total, sessionType)
    local class = source.classFilename
    if isSecret(class) or type(class) ~= "string" then
        class = nil
    end
    local r, g, b = classColor(class)
    row.r, row.g, row.b = r, g, b
    row.guid = source.sourceGUID
    row.sessionType = sessionType

    local coords = class and ((_G.CLASS_ICON_TCOORDS and _G.CLASS_ICON_TCOORDS[class]) or FALLBACK_COORDS[class])
    if coords then
        row.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        row.icon:Show()
        for _, stamp in ipairs(row.outline) do
            stamp:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            stamp:Show()
        end
    else
        row.icon:Hide()
        for _, stamp in ipairs(row.outline) do
            stamp:Hide()
        end
    end

    row.back:SetVertexColor(r, g, b, 0.22)
    row.bar:SetStatusBarColor(r, g, b, 0.85)

    if not isSecret(maxAmount) and (type(maxAmount) ~= "number" or maxAmount <= 0) then
        maxAmount = 1
    end
    pcall(row.bar.SetMinMaxValues, row.bar, 0, maxAmount)
    pcall(row.bar.SetValue, row.bar, source.totalAmount or 0)

    local okName = source.name ~= nil and pcall(row.name.SetText, row.name, source.name)
    if not okName then
        row.name:SetText("Unknown")
    end
    row.value:SetText(formatAmount(source.totalAmount))
    row.dps:SetText(formatAmount(source.amountPerSecond))

    if plainNumber(total) and plainNumber(source.totalAmount) and total > 0 then
        row.pct:SetText(string.format("%d%%", math.floor(source.totalAmount / total * 100 + 0.5)))
    else
        row.pct:SetText("")
    end
    row:Show()
end

local function drawRows()
    if not panel or not panel:IsShown() then
        return
    end
    local session, why = getSession()
    local sources = session and session.combatSources
    local maxAmount = session and session.maxAmount
    local total = session and session.totalAmount
    if type(sources) ~= "table" then
        sources = EMPTY
    else
        local top, sum
        sources, top, sum = playersOnly(sources)
        sortIfPlain(sources)
        if top and sum then
            maxAmount, total = top, sum
        end
    end
    local count = #sources
    sourceCount = count

    local maxOffset = math.max(0, count - MAX_ROWS)
    if scrollOffset > maxOffset then
        scrollOffset = maxOffset
    end

    local sessionType = apiReady() and currentSessionType() or nil
    local shown = math.min(MAX_ROWS, count)
    for index = 1, MAX_ROWS do
        local source = sources[scrollOffset + index]
        if index <= shown and type(source) == "table" then
            paintRow(acquireRow(index), source, maxAmount, total, sessionType)
        elseif rows[index] then
            rows[index].guid = nil
            rows[index]:Hide()
        end
    end

    if count == 0 then
        if why == "api" then
            emptyText:SetText("Damage data is not available on this client.")
        elseif why == "off" then
            emptyText:SetText("Turn on the built-in damage meter to collect data.")
        else
            emptyText:SetText("No damage recorded yet.")
        end
        emptyText:Show()
    else
        emptyText:Hide()
    end

    panel:SetHeight(HEADER + (PAD * 2) + math.max(1, shown) * ROW)

    local label = wantOverall() and "Overall" or "Current"
    local duration = session and session.durationSeconds
    if plainNumber(duration) then
        titleText:SetText(string.format("Damage: %s  %s", label, clock(duration)))
    else
        titleText:SetText("Damage: " .. label)
    end
end

function ns.DamageMeterScroll(delta)
    local maxOffset = math.max(0, sourceCount - MAX_ROWS)
    local nextOffset = scrollOffset - delta
    if nextOffset < 0 then
        nextOffset = 0
    elseif nextOffset > maxOffset then
        nextOffset = maxOffset
    end
    if nextOffset ~= scrollOffset then
        scrollOffset = nextOffset
        drawRows()
    end
end

local function paintHeader()
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    local detailR, detailG, detailB = 0.82, 0.82, 0.82
    if ns.Color then
        edgeR, edgeG, edgeB = ns.Color("accent")
        detailR, detailG, detailB = ns.Color("detail")
    end
    titleText:SetTextColor(edgeR, edgeG, edgeB)
    resetButton.text:SetTextColor(detailR, detailG, detailB)
    emptyText:SetTextColor(detailR, detailG, detailB)
    applyFont(titleText, FONT_SIZE, "OUTLINE")
    applyFont(resetButton.text, FONT_SIZE - 1, "")
    applyFont(emptyText, FONT_SIZE, "")
end

-- Apply new row height / font size to a panel that already exists.
local function relayout()
    if not panel then
        return
    end
    headerBar:SetHeight(HEADER)
    resetButton:SetSize(math.ceil(FONT_SIZE * 3.7), HEADER)
    emptyText:ClearAllPoints()
    emptyText:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD + 4, -(PAD + HEADER))
    emptyText:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(PAD + 4), -(PAD + HEADER))
    emptyText:SetHeight(ROW)
    for index, row in pairs(rows) do
        layoutRow(row, index)
    end
    paintHeader()
end

local function ensurePanel()
    if panel then
        return panel
    end

    panel = CreateFrame("Frame", "WaynotesDamageMeter", UIParent, "BackdropTemplate")
    panel:SetHeight(HEADER + (PAD * 2) + ROW)
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

    headerBar = CreateFrame("Frame", nil, panel)
    headerBar:SetHeight(HEADER)
    headerBar:SetPoint("TOPLEFT", PAD, -PAD)
    headerBar:SetPoint("TOPRIGHT", -PAD, -PAD)

    resetButton = CreateFrame("Button", nil, headerBar)
    resetButton:SetSize(math.ceil(FONT_SIZE * 3.7), HEADER)
    resetButton:SetPoint("RIGHT", 0, 0)
    resetButton.text = makeText(resetButton, FONT_SIZE - 1, "")
    resetButton.text:SetAllPoints()
    resetButton.text:SetJustifyH("RIGHT")
    resetButton.text:SetText("Reset")
    resetButton:SetScript("OnClick", function()
        resetData()
        drawRows()
    end)
    resetButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset damage meter", 1, 1, 1)
        GameTooltip:AddLine("Clears the current and overall damage data.", 0.9, 0.9, 0.9, true)
        if ns.FinishTooltip then
            ns.FinishTooltip()
        else
            GameTooltip:Show()
        end
    end)
    resetButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    titleButton = CreateFrame("Button", nil, headerBar)
    titleButton:SetPoint("TOPLEFT", 0, 0)
    titleButton:SetPoint("BOTTOMRIGHT", resetButton, "BOTTOMLEFT", -4, 0)
    titleButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    titleText = makeText(titleButton, FONT_SIZE, "OUTLINE")
    titleText:SetAllPoints()
    titleText:SetJustifyH("LEFT")
    titleText:SetText("Damage")
    titleButton:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            if ns.OpenGuideMenu then
                ns.OpenGuideMenu("damageMeter")
            end
            return
        end
        -- Manual switch holds until combat starts or ends.
        manualOverall = not wantOverall()
        scrollOffset = 0
        drawRows()
    end)
    titleButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Damage meter", 1, 1, 1)
        GameTooltip:AddLine("Click to switch between the current fight and the overall total.", 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine("Mouse wheel scrolls. Hover a row for a spell breakdown.", 0.9, 0.9, 0.9, true)
        if ns.FinishTooltip then
            ns.FinishTooltip()
        else
            GameTooltip:Show()
        end
    end)
    titleButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    emptyText = makeText(panel, FONT_SIZE, "")
    emptyText:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD + 4, -(PAD + HEADER))
    emptyText:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(PAD + 4), -(PAD + HEADER))
    emptyText:SetHeight(ROW)
    emptyText:SetJustifyH("LEFT")
    emptyText:SetJustifyV("MIDDLE")
    emptyText:SetText("No damage recorded yet.")

    panel:SetScript("OnMouseWheel", function(_, delta)
        ns.DamageMeterScroll(delta)
    end)
    panel:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" and ns.OpenGuideMenu then
            ns.OpenGuideMenu("damageMeter")
        end
    end)
    panel:SetScript("OnShow", function()
        stylePanel()
        paintHeader()
    end)

    paintHeader()
    return panel
end

local function placePanel()
    local host = tracker()
    if not panel or not host or not host:IsShown() then
        return
    end
    -- Sit under the step list when it is showing, otherwise under the tracker.
    local stepList = _G.WaynotesStepList
    local target = host
    if stepList and stepList:IsShown() then
        target = stepList
    end
    if target ~= anchoredTo or not panel:GetPoint() then
        anchoredTo = target
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 0, -GAP)
        panel:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -GAP)
    end
    local strata = host:GetFrameStrata() or "MEDIUM"
    if panel:GetFrameStrata() ~= strata then
        panel:SetFrameStrata(strata)
    end
    local level = (host:GetFrameLevel() or 1) + 2
    if panel:GetFrameLevel() ~= level then
        panel:SetFrameLevel(level)
    end
end

function ns.SetDamageMeterAlpha(alpha)
    if not panel or type(alpha) ~= "number" then
        return
    end
    if alpha < 0 then
        alpha = 0
    elseif alpha > 1 then
        alpha = 1
    end
    panel:SetAlpha(alpha)
end

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok and not reported then
        reported = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8080Waynotes damage meter:|r " .. tostring(err))
    end
end

local tickElapsed = 0

local function onTick(_, elapsed)
    tickElapsed = tickElapsed + elapsed
    if tickElapsed < 0.5 then
        return
    end
    tickElapsed = 0
    -- Show or hide as the group state changes (the "only in a group" option).
    local shown = panel and panel:IsShown() or false
    local host = tracker()
    local want = host ~= nil and host:IsShown() and (not (ns.db and ns.db.damageMeterGroupOnly) or inGroup())
    if want ~= shown then
        ns.RefreshDamageMeter(true)
        return
    end
    if not shown then
        return
    end
    safe(placePanel)
    safe(drawRows)
end

local function setRunning(on)
    if on == running then
        return
    end
    running = on
    if on then
        tickElapsed = 1
        inCombat = UnitAffectingCombat and UnitAffectingCombat("player") and true or false
        heldCurrent = inCombat
        manualOverall = nil
        driver:RegisterEvent("PLAYER_REGEN_DISABLED")
        driver:RegisterEvent("PLAYER_REGEN_ENABLED")
        driver:SetScript("OnEvent", function(_, event)
            inCombat = event == "PLAYER_REGEN_DISABLED"
            if inCombat then
                heldCurrent = true
            end
            -- A manual switch only lasts until the next combat change.
            manualOverall = nil
            scrollOffset = 0
            safe(drawRows)
        end)
        driver:SetScript("OnUpdate", onTick)
    else
        driver:UnregisterAllEvents()
        driver:SetScript("OnEvent", nil)
        driver:SetScript("OnUpdate", nil)
    end
end

-- Called when the view setting changes so a stale click override is dropped.
function ns.ResetDamageMeterView()
    manualOverall = nil
    scrollOffset = 0
    if inCombat then
        heldCurrent = true
    end
end

function ns.RefreshDamageMeter(force)
    if not enabled() then
        setRunning(false)
        if panel then
            panel:Hide()
        end
        return
    end
    setRunning(true)

    local host = tracker()
    if not host or not host:IsShown() then
        if panel then
            panel:Hide()
        end
        return
    end

    -- Only show while grouped (default on); keep running so it appears on joining.
    if ns.db.damageMeterGroupOnly and not inGroup() then
        if panel then
            panel:Hide()
        end
        return
    end

    local metricsChanged = readMetrics()
    ensurePanel()
    if metricsChanged then
        relayout()
    end
    placePanel()
    if force or not painted then
        stylePanel()
        paintHeader()
    end
    panel:Show()
    safe(drawRows)

    local hostAlpha = host:GetAlpha()
    if type(hostAlpha) == "number" then
        panel:SetAlpha(hostAlpha)
    end
end

-- Keep the meter tied to tracker show/hide.
local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    local host = tracker()
    if host then
        host:HookScript("OnShow", function()
            ns.RefreshDamageMeter(true)
        end)
        host:HookScript("OnHide", function()
            if panel then
                panel:Hide()
            end
        end)
    end
    ns.RefreshDamageMeter(true)
end)

-- Debug: /wndm prints the raw fields of every source the client returns, so
-- filtering problems can be diagnosed. Secret values print as "secret".
SLASH_WAYNOTESDM1 = "/wndm"
SlashCmdList["WAYNOTESDM"] = function()
    local session, why = getSession()
    if not session then
        print("Waynotes damage meter: no session (" .. tostring(why) .. ")")
        return
    end
    local sources = session.combatSources
    if type(sources) ~= "table" then
        print("Waynotes damage meter: no sources")
        return
    end
    local function show(value)
        if isSecret(value) then
            return "secret"
        end
        return tostring(value)
    end
    for index = 1, #sources do
        local source = sources[index]
        print(string.format(
            "%d: name=%s guid=%s creature=%s class=%s player=%s",
            index,
            show(source.name),
            show(source.sourceGUID),
            show(source.sourceCreatureID),
            show(source.classFilename),
            tostring(isPlayerSource(source))
        ))
    end
end
