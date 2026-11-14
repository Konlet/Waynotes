local addonName, ns = ...

local busy = 0
local hookedBackdrop = {}
local hookedListAlpha = {}
local hookedSatellite = {}
local hookedFont = {}
local watchedKids = {}

local STRATA = {
    BACKGROUND = true,
    LOW = true,
    MEDIUM = true,
    HIGH = true,
}

ns.layers = {
    { id = "BACKGROUND", label = "Background" },
    { id = "LOW", label = "Low" },
    { id = "MEDIUM", label = "Medium" },
    { id = "HIGH", label = "High" },
}

ns.defaults = {
    backgroundAlpha = 1,
    bannerAlpha = 1,
    borderAlpha = 1,
    stepListAlpha = 0.5,
    textOutline = false,
    strata = "BACKGROUND",
    fadeUnlessHover = false,
    idleAlpha = 0.4,
    fadeInCombat = false,
    combatAlpha = 0.3,
    arrowAlpha = 1,
    activeItemAlpha = 1,
    targetAlpha = 1,
    replaceGuide = true,
    simpleMode = false,
    trackerScale = 1.2,
    trackerWidth = 300,
    trackerFitHeight = true,
    trackerHeight = 360,
    trackerBackground = 0.4,
    darkHeader = true,
    headerShade = 0.55,
    roundedEdges = true,
    cornerRadius = 8,
    roundBadges = false,
    trackerBorder = false,
    trackerShadow = false,
    menuBorderGlow = true,
    menuGlowRadius = 8,
    showGuidePercent = true,
    showFlightTimer = true,
    showTrainReminders = true,
    standaloneGuide = true,
    hardcoreGuide = false,
    promptOffStepJump = true,
    promptDungeonGuide = true,
    showIrrelevantGuides = false,
    theme = "rested",
}

local function rgb(r, g, b)
    return { r, g, b }
end

ns.themeList = {
    {
        id = "rested",
        name = "Rested",
        backgroundAlpha = 0.4,
        accent = rgb(1.00, 0.82, 0.00),
        background = rgb(0.00, 0.00, 0.00),
        text = rgb(1.00, 1.00, 1.00),
        secondary = rgb(0.90, 0.90, 0.86),
        detail = rgb(0.82, 0.82, 0.82),
        badges = {
            rgb(1.00, 0.82, 0.00),
            rgb(0.36, 0.63, 0.92),
            rgb(0.45, 0.74, 0.42),
            rgb(0.88, 0.54, 0.28),
            rgb(0.66, 0.50, 0.80),
            rgb(0.80, 0.68, 0.42),
        },
    },
    {
        id = "quest",
        name = "Quest",
        backgroundAlpha = 0.45,
        accent = rgb(1.00, 0.82, 0.00),
        background = rgb(0.05, 0.05, 0.05),
        text = rgb(1.00, 0.82, 0.00),
        secondary = rgb(1.00, 1.00, 1.00),
        detail = rgb(0.90, 0.90, 0.90),
        badges = {
            rgb(1.00, 0.82, 0.00),
            rgb(0.95, 0.62, 0.15),
            rgb(0.78, 0.62, 0.22),
            rgb(0.85, 0.72, 0.35),
            rgb(0.62, 0.48, 0.18),
            rgb(0.92, 0.78, 0.40),
        },
    },
    {
        id = "alliance",
        name = "Alliance",
        backgroundAlpha = 0.55,
        accent = rgb(0.35, 0.62, 0.95),
        background = rgb(0.04, 0.07, 0.14),
        text = rgb(0.88, 0.94, 1.00),
        secondary = rgb(0.72, 0.82, 0.95),
        detail = rgb(0.62, 0.74, 0.88),
        badges = {
            rgb(0.25, 0.48, 0.90),
            rgb(0.95, 0.82, 0.35),
            rgb(0.55, 0.75, 0.95),
            rgb(0.75, 0.78, 0.85),
            rgb(0.20, 0.35, 0.62),
            rgb(0.40, 0.70, 0.85),
        },
    },
    {
        id = "horde",
        name = "Horde",
        backgroundAlpha = 0.55,
        accent = rgb(0.86, 0.18, 0.14),
        background = rgb(0.12, 0.03, 0.03),
        text = rgb(1.00, 0.88, 0.80),
        secondary = rgb(0.95, 0.72, 0.62),
        detail = rgb(0.85, 0.62, 0.55),
        badges = {
            rgb(0.75, 0.12, 0.10),
            rgb(0.95, 0.75, 0.25),
            rgb(0.55, 0.08, 0.08),
            rgb(0.90, 0.45, 0.18),
            rgb(0.85, 0.78, 0.62),
            rgb(0.45, 0.18, 0.12),
        },
    },
    {
        id = "night",
        name = "Night",
        backgroundAlpha = 0.55,
        accent = rgb(0.72, 0.45, 0.95),
        background = rgb(0.06, 0.04, 0.10),
        text = rgb(0.95, 0.90, 1.00),
        secondary = rgb(0.82, 0.74, 0.95),
        detail = rgb(0.70, 0.64, 0.82),
        badges = {
            rgb(0.58, 0.32, 0.85),
            rgb(0.75, 0.55, 0.95),
            rgb(0.40, 0.25, 0.62),
            rgb(0.85, 0.70, 0.95),
            rgb(0.30, 0.45, 0.75),
            rgb(0.62, 0.48, 0.78),
        },
    },
    {
        id = "fel",
        name = "Fel",
        backgroundAlpha = 0.5,
        accent = rgb(0.40, 0.92, 0.28),
        background = rgb(0.02, 0.08, 0.03),
        text = rgb(0.86, 1.00, 0.78),
        secondary = rgb(0.70, 0.90, 0.62),
        detail = rgb(0.55, 0.75, 0.50),
        badges = {
            rgb(0.30, 0.72, 0.22),
            rgb(0.55, 0.90, 0.30),
            rgb(0.18, 0.48, 0.16),
            rgb(0.70, 0.85, 0.25),
            rgb(0.25, 0.55, 0.40),
            rgb(0.45, 0.65, 0.20),
        },
    },
    {
        id = "arcane",
        name = "Arcane",
        backgroundAlpha = 0.5,
        accent = rgb(0.45, 0.78, 1.00),
        background = rgb(0.03, 0.06, 0.12),
        text = rgb(0.86, 0.94, 1.00),
        secondary = rgb(0.68, 0.82, 0.98),
        detail = rgb(0.58, 0.72, 0.88),
        badges = {
            rgb(0.30, 0.62, 0.95),
            rgb(0.45, 0.85, 0.95),
            rgb(0.25, 0.40, 0.75),
            rgb(0.70, 0.85, 1.00),
            rgb(0.35, 0.55, 0.85),
            rgb(0.55, 0.45, 0.90),
        },
    },
    {
        id = "parchment",
        name = "Parchment",
        backgroundAlpha = 0.92,
        accent = rgb(0.45, 0.28, 0.10),
        background = rgb(0.86, 0.76, 0.55),
        text = rgb(0.22, 0.12, 0.05),
        secondary = rgb(0.32, 0.20, 0.10),
        detail = rgb(0.40, 0.28, 0.16),
        badges = {
            rgb(0.55, 0.32, 0.10),
            rgb(0.25, 0.40, 0.62),
            rgb(0.30, 0.48, 0.22),
            rgb(0.62, 0.28, 0.16),
            rgb(0.42, 0.28, 0.50),
            rgb(0.48, 0.40, 0.18),
        },
    },
}

ns.themesById = {}
for _, theme in ipairs(ns.themeList) do
    ns.themesById[theme.id] = theme
end

local function clamp01(value, fallback)
    if type(value) ~= "number" then
        return fallback
    end
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end
    return value
end

local colorKeys = { "accent", "background", "text", "secondary", "detail", "glow" }

local function themeColor(theme, key)
    if theme and theme[key] then
        return theme[key]
    end
    if key == "glow" and theme and theme.accent then
        return theme.accent
    end
    local rested = ns.themesById.rested
    if key == "glow" then
        return rested.accent
    end
    return rested[key]
end

local function copyColor(color)
    return { color[1], color[2], color[3] }
end

function ns.CopyTheme(theme)
    local colors = { badges = {} }
    for _, key in ipairs(colorKeys) do
        colors[key] = copyColor(themeColor(theme, key))
    end
    for index, badge in ipairs(theme.badges) do
        colors.badges[index] = copyColor(badge)
    end
    return colors
end

local function clampColor(color, fallback)
    if type(color) ~= "table" or type(color[1]) ~= "number" or type(color[2]) ~= "number" or type(color[3]) ~= "number" then
        return copyColor(fallback)
    end
    return { clamp01(color[1], fallback[1]), clamp01(color[2], fallback[2]), clamp01(color[3], fallback[3]) }
end

function ns.SanitizeColors(db)
    if db.theme ~= "custom" and not ns.themesById[db.theme] then
        db.theme = "rested"
    end
    local theme = ns.themesById[db.theme] or ns.themesById.rested
    if type(db.colors) ~= "table" then
        db.colors = ns.CopyTheme(theme)
    end
    for _, key in ipairs(colorKeys) do
        db.colors[key] = clampColor(db.colors[key], themeColor(theme, key))
    end
    if type(db.colors.badges) ~= "table" then
        db.colors.badges = {}
    end
    local palette = theme.badges or ns.themesById.rested.badges
    for index = 1, #palette do
        db.colors.badges[index] = clampColor(db.colors.badges[index], palette[index])
    end
end

function ns.Color(name)
    local colors = ns.db and ns.db.colors
    local color = colors and colors[name]
    if type(color) ~= "table" or type(color[1]) ~= "number" then
        color = themeColor(ns.themesById.rested, name)
    end
    return color[1], color[2], color[3]
end

ns.TOOLTIP_MAX_WIDTH = 280

local function paintTooltipBackground(tip)
    if not tip then
        return
    end
    local r, g, b = 0.02, 0.02, 0.02
    if ns.Color then
        r, g, b = ns.Color("background")
    end
    -- Near-opaque so guide/options tip text stays readable on bright world UI.
    local alpha = 0.94
    if tip.SetBackdropColor then
        pcall(tip.SetBackdropColor, tip, r, g, b, alpha)
    end
    if tip.NineSlice then
        local slice = tip.NineSlice
        if slice.SetCenterColor then
            pcall(slice.SetCenterColor, slice, r, g, b, alpha)
        end
        if slice.Center and slice.Center.SetVertexColor then
            pcall(slice.Center.SetVertexColor, slice.Center, r, g, b, alpha)
        end
        if slice.Center and slice.Center.SetColorTexture then
            pcall(slice.Center.SetColorTexture, slice.Center, r, g, b, alpha)
        end
    end
    local bg = tip.__waynotesBg
    if not bg then
        bg = tip:CreateTexture(nil, "BACKGROUND", nil, -8)
        tip.__waynotesBg = bg
        tip:HookScript("OnHide", function(self)
            if self.__waynotesBg then
                self.__waynotesBg:Hide()
            end
        end)
    end
    bg:ClearAllPoints()
    bg:SetPoint("TOPLEFT", tip, "TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", tip, "BOTTOMRIGHT", -1, 1)
    if bg.SetColorTexture then
        bg:SetColorTexture(r, g, b, alpha)
    else
        bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        bg:SetVertexColor(r, g, b, alpha)
    end
    bg:Show()
    local edgeR, edgeG, edgeB = 1, 0.82, 0
    if ns.Color then
        edgeR, edgeG, edgeB = ns.Color("accent")
    end
    if tip.SetBackdropBorderColor then
        pcall(tip.SetBackdropBorderColor, tip, edgeR, edgeG, edgeB, 0.85)
    end
end

function ns.FinishTooltip(maxWidth)
    maxWidth = maxWidth or ns.TOOLTIP_MAX_WIDTH
    if type(maxWidth) ~= "number" or maxWidth < 120 then
        maxWidth = 120
    end
    local tip = GameTooltip
    tip:Show()
    paintTooltipBackground(tip)
    local textWidth = maxWidth - 24
    if textWidth < 80 then
        textWidth = 80
    end
    local count = tip.NumLines and tip:NumLines() or 0
    local changed = tip:GetWidth() > maxWidth + 2
    for i = 1, count do
        local left = _G["GameTooltipTextLeft" .. i]
        if left and left:IsShown() then
            local stringWidth = left:GetStringWidth() or 0
            if changed or stringWidth > textWidth + 1 then
                left:SetWidth(textWidth)
                if left.SetWordWrap then
                    left:SetWordWrap(true)
                end
                changed = true
            end
        end
    end
    if changed then
        tip:Show()
        paintTooltipBackground(tip)
    end
end

function ns.BadgeColor(index)
    local badges = ns.db and ns.db.colors and ns.db.colors.badges
    local palette = type(badges) == "table" and #badges > 0 and badges or ns.themesById.rested.badges
    local color = palette[((index - 1) % #palette) + 1]
    return color[1], color[2], color[3]
end

function ns.ApplyTheme(id)
    local theme = ns.themesById[id]
    if not theme or not ns.db then
        return
    end
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

local PROFILE_LIMIT = 20

local percentKeys = {
    backgroundAlpha = true,
    bannerAlpha = true,
    borderAlpha = true,
    stepListAlpha = true,
    idleAlpha = true,
    combatAlpha = true,
    arrowAlpha = true,
    activeItemAlpha = true,
    targetAlpha = true,
    trackerBackground = true,
    headerShade = true,
}

local boolKeys = {
    textOutline = true,
    fadeUnlessHover = true,
    fadeInCombat = true,
    replaceGuide = true,
    simpleMode = true,
    trackerFitHeight = true,
    darkHeader = true,
    roundedEdges = true,
    roundBadges = true,
    trackerBorder = true,
    trackerShadow = true,
    menuBorderGlow = true,
    showGuidePercent = true,
    showFlightTimer = true,
    showTrainReminders = true,
    standaloneGuide = true,
    hardcoreGuide = true,
    promptOffStepJump = true,
    promptDungeonGuide = true,
    showIrrelevantGuides = true,
}

local function sanitizeOptionValue(key, value, default)
    if value == nil then
        return default
    end
    if percentKeys[key] then
        return clamp01(value, default)
    end
    if boolKeys[key] then
        if type(value) ~= "boolean" then
            return default
        end
        return value
    end
    if key == "strata" then
        if not STRATA[value] then
            return default
        end
        return value
    end
    if key == "trackerScale" then
        if type(value) ~= "number" then
            return default
        end
        if value < 0.8 then
            return 0.8
        end
        if value > 2 then
            return 2
        end
        return value
    end
    if key == "trackerWidth" then
        if type(value) ~= "number" then
            return default
        end
        value = math.floor(value + 0.5)
        if value < 220 then
            return 220
        end
        if value > 640 then
            return 640
        end
        return value
    end
    if key == "trackerHeight" then
        if type(value) ~= "number" then
            return default
        end
        value = math.floor(value + 0.5)
        if value < 120 then
            return 120
        end
        if value > 800 then
            return 800
        end
        return value
    end
    if key == "cornerRadius" then
        if type(value) ~= "number" then
            return default
        end
        value = math.floor(value + 0.5)
        if value < 4 then
            return 4
        end
        if value > 16 then
            return 16
        end
        return value
    end
    if key == "menuGlowRadius" then
        if type(value) ~= "number" then
            return default
        end
        value = math.floor(value + 0.5)
        if value < 1 then
            return 1
        end
        if value > 16 then
            return 16
        end
        return value
    end
    if key == "theme" then
        if value ~= "custom" and not ns.themesById[value] then
            return default
        end
        return value
    end
    if type(default) == "number" then
        if type(value) ~= "number" then
            return default
        end
        return value
    end
    if type(default) == "boolean" then
        if type(value) ~= "boolean" then
            return default
        end
        return value
    end
    return value
end

local function cleanProfileName(name)
    if type(name) ~= "string" then
        return nil
    end
    name = strtrim(name)
    if name == "" then
        return nil
    end
    if #name > 24 then
        name = name:sub(1, 24)
    end
    return name
end

local function profileColors(source)
    local theme = ns.themesById.rested
    local raw = source and (source.colors or source) or nil
    local colors = { badges = {} }
    for _, key in ipairs(colorKeys) do
        colors[key] = clampColor(raw and raw[key], themeColor(theme, key))
    end
    local badges = raw and raw.badges
    for index = 1, #theme.badges do
        colors.badges[index] = clampColor(badges and badges[index], theme.badges[index])
    end
    return colors
end

local function optionValueForProfile(db, key)
    if key == "standaloneGuide" and db.restedXPMode and db.savedStandaloneGuide ~= nil then
        return db.savedStandaloneGuide and true or false
    end
    if key == "replaceGuide" and db.restedXPMode and db.savedReplaceGuide ~= nil then
        return db.savedReplaceGuide and true or false
    end
    return db[key]
end

local function snapshotProfile(name, db)
    local profile = {
        name = name,
        colors = profileColors(db),
    }
    for key, default in pairs(ns.defaults) do
        profile[key] = sanitizeOptionValue(key, optionValueForProfile(db, key), default)
    end
    return profile
end

local function sanitizeProfileEntry(profile)
    local name = type(profile) == "table" and cleanProfileName(profile.name) or nil
    if not name then
        return nil
    end
    local entry = {
        name = name,
        colors = profileColors(profile),
    }
    for key, default in pairs(ns.defaults) do
        if profile[key] ~= nil then
            entry[key] = sanitizeOptionValue(key, profile[key], default)
        end
    end
    return entry
end

function ns.SanitizeProfiles(db)
    local source = type(db.profiles) == "table" and db.profiles or {}
    local clean = {}
    local seen = {}
    for _, profile in ipairs(source) do
        local entry = sanitizeProfileEntry(profile)
        if entry and not seen[entry.name] then
            seen[entry.name] = true
            clean[#clean + 1] = entry
            if #clean >= PROFILE_LIMIT then
                break
            end
        end
    end
    db.profiles = clean
    if type(db.activeProfile) ~= "string" or not seen[db.activeProfile] then
        db.activeProfile = nil
    end
end

local function profileMessage(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r " .. text)
    end
end

function ns.SaveProfile(name)
    ns.InitDB()
    name = cleanProfileName(name)
    if not name then
        profileMessage("Enter a name, then save the profile.")
        return false
    end
    local profile = snapshotProfile(name, ns.db)
    local replaced = false
    for index, existing in ipairs(ns.db.profiles) do
        if existing.name == name then
            ns.db.profiles[index] = profile
            replaced = true
            break
        end
    end
    if not replaced and #ns.db.profiles >= PROFILE_LIMIT then
        profileMessage("You can save up to " .. PROFILE_LIMIT .. " profiles. Delete one first.")
        return false
    end
    if not replaced then
        ns.db.profiles[#ns.db.profiles + 1] = profile
    end
    ns.db.activeProfile = name
    profileMessage((replaced and "Updated profile " or "Saved profile ") .. name .. ".")
    return true
end

function ns.LoadProfile(name)
    ns.InitDB()
    for _, profile in ipairs(ns.db.profiles) do
        if profile.name == name then
            for key, default in pairs(ns.defaults) do
                if profile[key] ~= nil then
                    ns.db[key] = sanitizeOptionValue(key, profile[key], default)
                end
            end
            if profile.colors then
                ns.db.colors = profileColors(profile)
            end
            ns.db.activeProfile = name
            if ns.db.restedXPMode then
                if profile.standaloneGuide ~= nil then
                    ns.db.savedStandaloneGuide = profile.standaloneGuide and true or false
                end
                if profile.replaceGuide ~= nil then
                    ns.db.savedReplaceGuide = profile.replaceGuide and true or false
                end
            end
            ns.SanitizeColors(ns.db)
            ns.ApplyRestedXPMode()
            ns.Apply()
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
            profileMessage("Loaded profile " .. name .. ".")
            return true
        end
    end
    return false
end

function ns.DeleteProfile(name)
    ns.InitDB()
    local kept = {}
    for _, profile in ipairs(ns.db.profiles) do
        if profile.name ~= name then
            kept[#kept + 1] = profile
        end
    end
    ns.db.profiles = kept
    if ns.db.activeProfile == name then
        ns.db.activeProfile = nil
    end
    profileMessage("Deleted profile " .. name .. ".")
end

ns.visualKeys = {
    "backgroundAlpha",
    "bannerAlpha",
    "borderAlpha",
    "stepListAlpha",
    "textOutline",
    "strata",
    "fadeUnlessHover",
    "idleAlpha",
    "fadeInCombat",
    "combatAlpha",
    "arrowAlpha",
    "activeItemAlpha",
    "targetAlpha",
    "replaceGuide",
    "simpleMode",
    "trackerScale",
    "trackerWidth",
    "trackerFitHeight",
    "trackerHeight",
    "trackerBackground",
    "darkHeader",
    "headerShade",
    "roundedEdges",
    "cornerRadius",
    "roundBadges",
    "trackerBorder",
    "trackerShadow",
    "menuBorderGlow",
    "menuGlowRadius",
    "standaloneGuide",
    "hardcoreGuide",
}

function ns.Visuals()
    return ns.db or ns.defaults
end

function ns.UsingStandalone()
    return ns.db and ns.db.standaloneGuide and true or false
end

function ns.RestedXP()
    local rxp = _G.RXP
    if type(rxp) == "table" and type(rxp.guideList) == "table" and type(rxp.LoadGuide) == "function" then
        return rxp
    end
end

function ns.RestedXPActive()
    if ns.RestedXP() then
        return true
    end
    local loaded = false
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        loaded = C_AddOns.IsAddOnLoaded("RXPGuides") and true or false
    elseif IsAddOnLoaded then
        loaded = IsAddOnLoaded("RXPGuides") and true or false
    end
    return loaded
end

-- While RestedXP is loaded, keep Replace RestedXP off and show its guides
-- in this tracker. The previous choice is restored once RestedXP is gone.
function ns.ApplyRestedXPMode()
    local db = ns.db
    if not db then
        return
    end
    if ns.RestedXPActive() then
        if not db.restedXPMode then
            db.savedStandaloneGuide = db.standaloneGuide and true or false
            db.savedReplaceGuide = db.replaceGuide and true or false
            db.restedXPMode = true
        end
        db.standaloneGuide = false
        db.replaceGuide = true
        db.restedXPGuides = ns.RestedXP() and true or false
        return
    end
    if not db.restedXPMode then
        return
    end
    if db.savedStandaloneGuide ~= nil then
        db.standaloneGuide = db.savedStandaloneGuide and true or false
    end
    if db.savedReplaceGuide ~= nil then
        db.replaceGuide = db.savedReplaceGuide and true or false
    end
    db.savedStandaloneGuide = nil
    db.savedReplaceGuide = nil
    db.restedXPMode = nil
    db.restedXPGuides = false
end

function ns.ReplacingGuide()
    return ns.db and ns.db.replaceGuide and not ns.db.standaloneGuide and true or false
end

function ns.InitDB()
    if type(WaynotesDB) ~= "table" then
        if type(RestedXPBetterDB) == "table" then
            WaynotesDB = RestedXPBetterDB
        else
            WaynotesDB = {}
        end
    end
    if ns.db == WaynotesDB then
        ns.ApplyRestedXPMode()
        return ns.db
    end

    local db = WaynotesDB

    for key, value in pairs(ns.defaults) do
        if db[key] == nil then
            db[key] = value
        else
            db[key] = sanitizeOptionValue(key, db[key], value)
        end
    end

    -- Replace RestedXP now means custom guides entirely. Flip once for older saves.
    if db.replaceRestedXPDefault == nil then
        db.standaloneGuide = true
        db.replaceRestedXPDefault = true
    end

    ns.SanitizeColors(db)
    ns.SanitizeProfiles(db)
    ns.db = db
    ns.ApplyRestedXPMode()
    return db
end

local function guide()
    return _G.RXPFrame
end

local reportedCall = false

local function call(fn)
    busy = busy + 1
    local ok, err = pcall(fn)
    busy = busy - 1
    if not ok and not reportedCall then
        reportedCall = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8080Waynotes:|r " .. tostring(err))
    end
end

local function applyBorder(frame)
    if not frame.GetBackdrop or not frame:GetBackdrop() then
        return
    end
    if not frame.SetBackdropBorderColor then
        return
    end

    local visuals = ns.Visuals()
    local r = frame.__rxpbBorderR
    local g = frame.__rxpbBorderG
    local b = frame.__rxpbBorderB
    if r == nil then
        r, g, b = frame:GetBackdropBorderColor()
        if r == nil then
            r, g, b = 1, 1, 1
        end
        frame.__rxpbBorderR, frame.__rxpbBorderG, frame.__rxpbBorderB = r, g, b
    end

    call(function()
        frame:SetBackdropBorderColor(r, g, b, visuals.borderAlpha)
    end)
end

local function repaint(frame)
    local r, g, b, a = frame.__rxpbR, frame.__rxpbG, frame.__rxpbB, frame.__rxpbA
    if r == nil or not frame.SetBackdropColor then
        return
    end
    if frame.GetBackdrop and not frame:GetBackdrop() then
        return
    end

    local want = a * ns.Visuals().backgroundAlpha
    call(function()
        frame:SetBackdropColor(r, g, b, want)
    end)
    applyBorder(frame)
end

local function hookBackdrop(frame)
    if not frame or hookedBackdrop[frame] or not frame.SetBackdropColor then
        return
    end
    if frame.IsForbidden and frame:IsForbidden() then
        return
    end

    hookedBackdrop[frame] = true
    hooksecurefunc(frame, "SetBackdropColor", function(self, r, g, b, a)
        if busy > 0 then
            return
        end
        a = a or 1
        self.__rxpbR, self.__rxpbG, self.__rxpbB, self.__rxpbA = r, g, b, a
        local want = a * ns.Visuals().backgroundAlpha
        if math.abs(want - a) >= 0.005 then
            call(function()
                self:SetBackdropColor(r, g, b, want)
            end)
        end
        applyBorder(self)
    end)

    if frame.__rxpbR == nil and frame.GetBackdropColor then
        local r, g, b, a = frame:GetBackdropColor()
        if r ~= nil then
            frame.__rxpbR, frame.__rxpbG, frame.__rxpbB, frame.__rxpbA = r, g, b, a or 1
        end
    end
    repaint(frame)
end

-- RestedXP sets completed rows to 0.5, hides rows at 0, and uses 1 for the
-- current row and for mouseover. Only the faded values are rewritten.
local function hookListAlpha(frame)
    if not frame or hookedListAlpha[frame] or not frame.SetAlpha then
        return
    end

    hookedListAlpha[frame] = true
    hooksecurefunc(frame, "SetAlpha", function(self, alpha)
        if busy > 0 or not alpha then
            return
        end
        if alpha <= 0 or alpha >= 0.99 then
            self.__rxpbFaded = nil
            return
        end
        self.__rxpbFaded = true
        local want = ns.Visuals().stepListAlpha
        if math.abs(alpha - want) < 0.01 then
            return
        end
        call(function()
            self:SetAlpha(want)
        end)
    end)

    local alpha = frame:GetAlpha()
    if alpha and alpha > 0.01 and alpha < 0.99 then
        frame.__rxpbFaded = true
        local want = ns.Visuals().stepListAlpha
        if math.abs(alpha - want) >= 0.01 then
            call(function()
                frame:SetAlpha(want)
            end)
        end
    end
end

local function satelliteAlpha(key)
    local visuals = ns.Visuals()
    local alpha = visuals[key] or 1
    if visuals.fadeInCombat and UnitAffectingCombat("player") then
        alpha = math.min(alpha, visuals.combatAlpha)
    end
    return alpha
end

local function hookSatellite(frame, key)
    if not frame or hookedSatellite[frame] or not frame.SetAlpha then
        return
    end

    hookedSatellite[frame] = key
    hooksecurefunc(frame, "SetAlpha", function(self, alpha)
        if busy > 0 or not alpha or alpha <= 0 then
            return
        end
        local key = hookedSatellite[self]
        if ns.ReplacingGuide() and (key == "activeItemAlpha" or key == "targetAlpha") then
            return
        end
        local want = satelliteAlpha(key)
        if math.abs(alpha - want) < 0.01 then
            return
        end
        call(function()
            self:SetAlpha(want)
        end)
    end)

    local current = frame:GetAlpha() or 0
    if current > 0 then
        call(function()
            frame:SetAlpha(satelliteAlpha(key))
        end)
    end
end

local function setSatellite(frame, key)
    if not frame or not frame.SetAlpha then
        return
    end
    if ns.ReplacingGuide() and (key == "activeItemAlpha" or key == "targetAlpha") then
        return
    end
    hookSatellite(frame, key)
    local current = frame:GetAlpha() or 1
    if current <= 0 then
        return
    end
    call(function()
        frame:SetAlpha(satelliteAlpha(key))
    end)
end

local function hookFont(fs)
    if not fs or hookedFont[fs] or not fs.SetFont then
        return
    end
    if fs.IsForbidden and fs:IsForbidden() then
        return
    end

    hookedFont[fs] = true
    hooksecurefunc(fs, "SetFont", function(self, font, size, flags)
        if busy > 0 or not font or not size then
            return
        end
        if not ns.Visuals().textOutline then
            return
        end
        if flags == "OUTLINE" or flags == "THICKOUTLINE" then
            return
        end
        call(function()
            self:SetFont(font, size, "OUTLINE")
        end)
    end)
end

local function walkFonts(frame, depth)
    if not frame or depth > 3 then
        return
    end
    if frame.IsForbidden and frame:IsForbidden() then
        return
    end

    if frame.GetNumRegions then
        for i = 1, frame:GetNumRegions() do
            local region = select(i, frame:GetRegions())
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                hookFont(region)
            end
        end
    end

    if frame.GetNumChildren then
        for i = 1, frame:GetNumChildren() do
            walkFonts(select(i, frame:GetChildren()), depth + 1)
        end
    end
end

local function watchContents(frame)
    if not frame or not frame.GetNumChildren then
        return
    end

    local sig = (frame:GetNumChildren() or 0) * 1000 + (frame:GetNumRegions() or 0)
    if watchedKids[frame] == sig then
        return
    end
    watchedKids[frame] = sig
    walkFonts(frame, 0)
    if frame.number then
        hookBackdrop(frame.number)
        walkFonts(frame.number, 0)
    end
end

local function watchPool(pool, isList)
    if type(pool) ~= "table" then
        return
    end
    for _, frame in ipairs(pool) do
        if type(frame) == "table" and frame.GetObjectType then
            hookBackdrop(frame)
            if isList then
                hookListAlpha(frame)
            end
            watchContents(frame)
        end
    end
end

local function paintBanner(texture, alpha)
    if texture and texture.SetAlpha then
        texture:SetAlpha(alpha)
    end
end

local function applyStrata(frame, strata)
    if frame and frame.SetFrameStrata and frame:GetFrameStrata() ~= strata then
        frame:SetFrameStrata(strata)
    end
end

function ns.MouseOverGuide()
    local rxp = guide()
    if not rxp then
        return false
    end

    local function over(frame)
        return frame and frame.IsVisible and frame:IsVisible() and frame:IsMouseOver()
    end

    return over(rxp)
        or over(rxp.CurrentStepFrame)
        or over(rxp.GuideName)
        or over(rxp.BottomFrame)
        or over(rxp.Footer)
end

function ns.RefreshFonts()
    local outline = ns.Visuals().textOutline
    for fs in pairs(hookedFont) do
        local font, size, flags = fs:GetFont()
        if font and size then
            local want = outline and "OUTLINE" or ""
            if flags ~= want then
                call(function()
                    fs:SetFont(font, size, want)
                end)
            end
        end
    end
end

function ns.Scan()
    local rxp = guide()
    if not rxp then
        return false
    end

    hookBackdrop(rxp.BottomFrame)
    hookBackdrop(rxp.GuideName)
    hookBackdrop(rxp.Footer)
    watchContents(rxp.GuideName)
    watchContents(rxp.Footer)

    if rxp.CurrentStepFrame then
        watchPool(rxp.CurrentStepFrame.framePool, false)
    end
    if rxp.ScrollChild then
        watchPool(rxp.ScrollChild.framePool, true)
    end

    local arrow = _G.RXPG_ARROW
    local target = _G.RXPTargetFrame
    local items = _G.RXPItemFrame or rxp.activeItemFrame
    hookSatellite(arrow, "arrowAlpha")
    hookSatellite(target, "targetAlpha")
    hookSatellite(items, "activeItemAlpha")

    local visuals = ns.Visuals()
    paintBanner(rxp.GuideName and rxp.GuideName.bg, visuals.bannerAlpha)
    paintBanner(rxp.Footer and rxp.Footer.bg, visuals.bannerAlpha)

    if ns.OnGuideScan then
        ns.OnGuideScan()
    end

    if rxp.UpdateVisuals and not rxp.__rxpbVisualHook then
        rxp.__rxpbVisualHook = true
        hooksecurefunc(rxp, "UpdateVisuals", function()
            C_Timer.After(0, ns.Apply)
        end)
    end

    return true
end

function ns.Apply()
    if not ns.db then
        return
    end

    local visuals = ns.Visuals()
    local rxp = guide()

    for frame in pairs(hookedBackdrop) do
        repaint(frame)
    end

    for frame in pairs(hookedListAlpha) do
        if frame.__rxpbFaded then
            local want = visuals.stepListAlpha
            local alpha = frame:GetAlpha()
            if alpha and math.abs(alpha - want) >= 0.01 then
                call(function()
                    frame:SetAlpha(want)
                end)
            end
        end
    end

    if rxp then
        paintBanner(rxp.GuideName and rxp.GuideName.bg, visuals.bannerAlpha)
        paintBanner(rxp.Footer and rxp.Footer.bg, visuals.bannerAlpha)

        local scroll = rxp.ScrollFrame
        local bar = scroll and (scroll.ScrollBar or scroll.scrollBar)
        if bar and bar.SetAlpha then
            bar:SetAlpha(visuals.borderAlpha)
        end

        applyStrata(rxp, visuals.strata)
        applyStrata(rxp.CurrentStepFrame, visuals.strata)
        if rxp.CurrentStepFrame and rxp.CurrentStepFrame.framePool then
            for _, frame in ipairs(rxp.CurrentStepFrame.framePool) do
                applyStrata(frame, visuals.strata)
            end
        end
        applyStrata(_G.RXPG_ARROW, visuals.strata)
        applyStrata(_G.RXPItemFrame or rxp.activeItemFrame, visuals.strata)
        applyStrata(_G.RXPTargetFrame, visuals.strata)
    end

    setSatellite(_G.RXPG_ARROW, "arrowAlpha")
    setSatellite(_G.RXPItemFrame or (rxp and rxp.activeItemFrame), "activeItemAlpha")
    setSatellite(_G.RXPTargetFrame, "targetAlpha")
    ns.RefreshFonts()
    if ns.SyncReplacement then
        ns.SyncReplacement()
    end
end

function ns.Reset()
    ns.InitDB()
    for key, value in pairs(ns.defaults) do
        ns.db[key] = value
    end
    ns.db.activeProfile = nil
    ns.db.colors = ns.CopyTheme(ns.themesById.rested)
    ns.ApplyRestedXPMode()
    ns.Apply()
    if ns.RefreshOptions then
        ns.RefreshOptions()
    end
end

local fadeCurrent = 1
local scanElapsed = 0
local fadeElapsed = 0
local started = false
local reported = false

local function safe(fn)
    local ok, err = pcall(fn)
    if not ok and not reported then
        reported = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8080Waynotes:|r " .. tostring(err))
    end
end

local function updateFade(dt)
    if ns.ReplacingGuide() then
        return
    end

    local visuals = ns.Visuals()
    local target = 1
    if visuals.fadeUnlessHover and not ns.MouseOverGuide() then
        target = visuals.idleAlpha
    end
    if visuals.fadeInCombat and UnitAffectingCombat("player") then
        target = math.min(target, visuals.combatAlpha)
    end

    fadeCurrent = fadeCurrent + (target - fadeCurrent) * math.min(1, dt * 10)
    if math.abs(fadeCurrent - target) < 0.01 then
        fadeCurrent = target
    end

    local rxp = guide()
    if rxp and math.abs((rxp:GetAlpha() or 1) - fadeCurrent) > 0.005 then
        rxp:SetAlpha(fadeCurrent)
    end
end

local watcher = CreateFrame("Frame")
watcher:SetScript("OnUpdate", function(_, elapsed)
    if not started then
        return
    end

    fadeElapsed = fadeElapsed + elapsed
    if fadeElapsed >= 0.05 then
        local dt = fadeElapsed
        fadeElapsed = 0
        safe(function()
            updateFade(dt)
        end)
    end

    scanElapsed = scanElapsed + elapsed
    if scanElapsed >= 0.5 then
        scanElapsed = 0
        local start = ns.PerfAdd and debugprofilestop and debugprofilestop()
        safe(ns.Scan)
        if start then
            ns.PerfAdd("scan", debugprofilestop() - start)
        end
    end
end)

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
local greeted = false

local function boot()
    ns.InitDB()
    if not greeted and not ns.db.acknowledged and DEFAULT_CHAT_FRAME then
        greeted = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r loaded. Type |cffffffff/waynotes|r to open options.")
    end
    safe(ns.Scan)
    safe(ns.Apply)
    if ns.RefreshOptions then
        ns.RefreshOptions()
    end
end

events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name == "RXPGuides" and ns.db then
            ns.ApplyRestedXPMode()
            safe(ns.Apply)
            if ns.RefreshOptions then
                ns.RefreshOptions()
            end
            return
        end
        if name ~= addonName then
            return
        end
        started = true
        if type(WaynotesDB) == "table" or type(RestedXPBetterDB) == "table" then
            boot()
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        boot()
        return
    end

    if not ns.db then
        return
    end

    safe(ns.Apply)
end)
