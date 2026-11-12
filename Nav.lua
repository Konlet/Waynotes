local _, ns = ...

-- Nav.lua: quick navigation to the nearest inn, bank, auction house, mailbox,
-- flight master or class trainer.
--
-- Innkeepers and flight masters come from Data/Innkeepers.lua and
-- Data/FlightMasters.lua (Forever-sourced). Inns use Forever zone percent
-- coords and skip EraToForever. Flight masters keep classic continent world
-- coords as a fallback; aiming prefers HBD world coords from the resolved
-- zone pin so the Go-button arrow matches the player coordinate system.
--
-- Banks, mailboxes, auction houses, and trainers stay as Classic Era UiMap
-- percent presets and are converted with LibQuestieDB.EraToForeverByUiMapId
-- on Forever, matching authored guide pins.
--
-- Questie override: when a preset has an npc id and QuestieDB can resolve it
-- (ns.NpcPin), the live spawn data replaces the preset coordinates.

local PRESETS = {
    -- Banks
    { kind = "bank", faction = "Horde", map = 1454, x = 49.6, y = 69.4, name = "Bank of Orgrimmar", zone = "Orgrimmar" },
    { kind = "bank", faction = "Horde", map = 1456, x = 47.7, y = 58.9, name = "Thunder Bluff Bank", zone = "Thunder Bluff" },
    { kind = "bank", faction = "Horde", map = 1458, x = 66.6, y = 44.1, name = "Undercity Bank", zone = "Undercity" },
    { kind = "bank", faction = "Alliance", map = 1453, x = 61.5, y = 75.0, name = "Stormwind Bank", zone = "Stormwind City" },
    { kind = "bank", faction = "Alliance", map = 1455, x = 35.5, y = 60.7, name = "Ironforge Bank", zone = "Ironforge" },
    { kind = "bank", faction = "Alliance", map = 1457, x = 39.9, y = 42.2, name = "Darnassus Bank", zone = "Darnassus" },

    -- Auction houses
    { kind = "auction", faction = "Horde", map = 1454, x = 55.7, y = 62.9, name = "Auction House", zone = "Orgrimmar" },
    { kind = "auction", faction = "Horde", map = 1456, x = 40.4, y = 51.8, name = "Auction House", zone = "Thunder Bluff" },
    { kind = "auction", faction = "Horde", map = 1458, x = 60.7, y = 44.1, name = "Auction House", zone = "Undercity" },
    { kind = "auction", faction = "Alliance", map = 1453, x = 60.9, y = 70.3, name = "Auction House", zone = "Stormwind City" },
    { kind = "auction", faction = "Alliance", map = 1455, x = 25.2, y = 74.3, name = "Auction House", zone = "Ironforge" },
    { kind = "auction", faction = "Alliance", map = 1457, x = 40.4, y = 41.6, name = "Auction House", zone = "Darnassus" },

    -- Mailboxes: Horde
    { kind = "mail", faction = "Horde", map = 1454, x = 52.4, y = 66.4, name = "Mailbox", zone = "Orgrimmar" },
    { kind = "mail", faction = "Horde", map = 1456, x = 45.3, y = 63.2, name = "Mailbox", zone = "Thunder Bluff" },
    { kind = "mail", faction = "Horde", map = 1458, x = 67.3, y = 39.1, name = "Mailbox", zone = "Undercity" },
    { kind = "mail", faction = "Horde", map = 1411, x = 52.4, y = 42.1, name = "Mailbox", zone = "Razor Hill" },
    { kind = "mail", faction = "Horde", map = 1413, x = 51.9, y = 30.8, name = "Mailbox", zone = "The Crossroads" },
    { kind = "mail", faction = "Horde", map = 1413, x = 45.0, y = 58.6, name = "Mailbox", zone = "Camp Taurajo" },
    { kind = "mail", faction = "Horde", map = 1412, x = 46.9, y = 60.4, name = "Mailbox", zone = "Bloodhoof Village" },
    { kind = "mail", faction = "Horde", map = 1420, x = 60.4, y = 52.9, name = "Mailbox", zone = "Brill" },
    { kind = "mail", faction = "Horde", map = 1421, x = 43.6, y = 40.8, name = "Mailbox", zone = "The Sepulcher" },
    { kind = "mail", faction = "Horde", map = 1440, x = 73.9, y = 60.2, name = "Mailbox", zone = "Splintertree Post" },
    { kind = "mail", faction = "Horde", map = 1440, x = 12.0, y = 33.8, name = "Mailbox", zone = "Zoram'gar Outpost" },
    { kind = "mail", faction = "Horde", map = 1442, x = 45.8, y = 59.6, name = "Mailbox", zone = "Sun Rock Retreat" },

    -- Mailboxes: Alliance
    { kind = "mail", faction = "Alliance", map = 1453, x = 52.2, y = 66.4, name = "Mailbox", zone = "Stormwind City" },
    { kind = "mail", faction = "Alliance", map = 1455, x = 33.1, y = 57.1, name = "Mailbox", zone = "Ironforge" },
    { kind = "mail", faction = "Alliance", map = 1457, x = 66.5, y = 14.7, name = "Mailbox", zone = "Darnassus" },
    { kind = "mail", faction = "Alliance", map = 1429, x = 42.2, y = 66.0, name = "Mailbox", zone = "Goldshire" },
    { kind = "mail", faction = "Alliance", map = 1426, x = 47.3, y = 52.8, name = "Mailbox", zone = "Kharanos" },
    { kind = "mail", faction = "Alliance", map = 1438, x = 55.9, y = 59.1, name = "Mailbox", zone = "Dolanaar" },
    { kind = "mail", faction = "Alliance", map = 1439, x = 36.8, y = 43.9, name = "Mailbox", zone = "Auberdine" },
    { kind = "mail", faction = "Alliance", map = 1436, x = 52.7, y = 53.3, name = "Mailbox", zone = "Sentinel Hill" },
    { kind = "mail", faction = "Alliance", map = 1432, x = 35.0, y = 48.2, name = "Mailbox", zone = "Thelsamar" },
    { kind = "mail", faction = "Alliance", map = 1433, x = 26.7, y = 44.5, name = "Mailbox", zone = "Lakeshire" },
    { kind = "mail", faction = "Alliance", map = 1440, x = 36.5, y = 49.7, name = "Mailbox", zone = "Astranaar" },

    -- Class trainers: Horde (Orgrimmar and Thunder Bluff)
    { kind = "trainer", faction = "Horde", class = "Warrior", map = 1454, x = 79.8, y = 31.4, name = "Sorek", zone = "Orgrimmar", npc = 3354 },
    { kind = "trainer", faction = "Horde", class = "Hunter", map = 1454, x = 66.1, y = 18.5, name = "Hunter Trainer", zone = "Orgrimmar" },
    { kind = "trainer", faction = "Horde", class = "Rogue", map = 1454, x = 42.2, y = 53.5, name = "Shenthul", zone = "Orgrimmar", npc = 3401 },
    { kind = "trainer", faction = "Horde", class = "Priest", map = 1454, x = 36.4, y = 84.8, name = "Priest Trainer", zone = "Orgrimmar" },
    { kind = "trainer", faction = "Horde", class = "Shaman", map = 1454, x = 38.0, y = 36.1, name = "Kardris Dreamseeker", zone = "Orgrimmar", npc = 3344 },
    { kind = "trainer", faction = "Horde", class = "Mage", map = 1454, x = 38.4, y = 85.7, name = "Mage Trainer", zone = "Orgrimmar" },
    { kind = "trainer", faction = "Horde", class = "Warlock", map = 1454, x = 48.8, y = 46.5, name = "Dhugru Gorelust", zone = "Orgrimmar", npc = 3324 },
    { kind = "trainer", faction = "Horde", class = "Druid", map = 1456, x = 75.0, y = 26.8, name = "Druid Trainer", zone = "Thunder Bluff" },

    -- Class trainers: Alliance (Stormwind, Ironforge, Darnassus)
    { kind = "trainer", faction = "Alliance", class = "Warrior", map = 1453, x = 78.4, y = 46.6, name = "Warrior Trainer", zone = "Stormwind City" },
    { kind = "trainer", faction = "Alliance", class = "Paladin", map = 1453, x = 37.5, y = 32.3, name = "Paladin Trainer", zone = "Stormwind City" },
    { kind = "trainer", faction = "Alliance", class = "Priest", map = 1453, x = 39.5, y = 27.5, name = "Priest Trainer", zone = "Stormwind City" },
    { kind = "trainer", faction = "Alliance", class = "Rogue", map = 1453, x = 74.5, y = 39.0, name = "Rogue Trainer", zone = "Stormwind City" },
    { kind = "trainer", faction = "Alliance", class = "Mage", map = 1453, x = 25.9, y = 78.0, name = "Mage Trainer", zone = "Stormwind City" },
    { kind = "trainer", faction = "Alliance", class = "Warlock", map = 1453, x = 25.2, y = 78.6, name = "Gakin the Darkbinder", zone = "Stormwind City", npc = 5172 },
    { kind = "trainer", faction = "Alliance", class = "Warrior", map = 1455, x = 75.9, y = 10.6, name = "Warrior Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Paladin", map = 1455, x = 23.4, y = 8.7, name = "Paladin Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Hunter", map = 1455, x = 70.9, y = 84.1, name = "Hunter Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Priest", map = 1455, x = 25.3, y = 7.9, name = "Priest Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Rogue", map = 1455, x = 61.0, y = 87.3, name = "Rogue Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Mage", map = 1455, x = 27.0, y = 8.6, name = "Mage Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Warlock", map = 1455, x = 50.8, y = 6.0, name = "Warlock Trainer", zone = "Ironforge" },
    { kind = "trainer", faction = "Alliance", class = "Warrior", map = 1457, x = 58.9, y = 21.5, name = "Warrior Trainer", zone = "Darnassus" },
    { kind = "trainer", faction = "Alliance", class = "Hunter", map = 1457, x = 59.8, y = 19.7, name = "Hunter Trainer", zone = "Darnassus" },
    { kind = "trainer", faction = "Alliance", class = "Rogue", map = 1457, x = 42.4, y = 78.6, name = "Rogue Trainer", zone = "Darnassus" },
    { kind = "trainer", faction = "Alliance", class = "Priest", map = 1457, x = 38.6, y = 22.0, name = "Priest Trainer", zone = "Darnassus" },
    { kind = "trainer", faction = "Alliance", class = "Druid", map = 1457, x = 35.4, y = 8.4, name = "Mathrengyl Bearwalker", zone = "Darnassus", npc = 3060 },
}

-- Merge Forever innkeeper / flight-master tables loaded from Data/*.lua.
do
    local inns = ns.NavInnkeepers
    if type(inns) == "table" then
        for index = 1, #inns do
            local entry = inns[index]
            if type(entry) == "table" and type(entry.map) == "number" and type(entry.x) == "number" and type(entry.y) == "number" then
                PRESETS[#PRESETS + 1] = {
                    kind = "inn",
                    faction = entry.faction,
                    map = entry.map,
                    x = entry.x,
                    y = entry.y,
                    name = entry.name,
                    zone = entry.zone,
                    forever = true,
                    npc = entry.npc,
                }
            end
        end
    end

    local flights = ns.NavFlightMasters
    if type(flights) == "table" then
        for index = 1, #flights do
            local entry = flights[index]
            if type(entry) == "table" and type(entry.wx) == "number" and type(entry.wy) == "number" and type(entry.instance) == "number" then
                PRESETS[#PRESETS + 1] = {
                    kind = "flight",
                    faction = entry.faction,
                    name = entry.name,
                    zone = entry.hub or entry.zone,
                    forever = true,
                    npc = entry.npc,
                    nodeId = entry.nodeId,
                    wx = entry.wx,
                    wy = entry.wy,
                    wz = entry.wz,
                    instance = entry.instance,
                }
            end
        end
    end
end

local KIND_LABEL = {
    inn = "Inn",
    bank = "Bank",
    auction = "Auction House",
    mail = "Mailbox",
    flight = "Flight Master",
    trainer = "Class Trainer",
}

local TRAINER_CLASSES = {
    "Warrior",
    "Paladin",
    "Hunter",
    "Rogue",
    "Priest",
    "Shaman",
    "Mage",
    "Warlock",
    "Druid",
}

local FAR_AWAY = 1e12

local target

ns.NavPresets = PRESETS
ns.NavKindLabel = KIND_LABEL
ns.NavTrainerClasses = TRAINER_CLASSES

-- Helpers

local function isNumber(value)
    return type(value) == "number"
end

local function playerFaction()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    if faction == "Horde" or faction == "Alliance" then
        return faction
    end
    return nil
end

local function playerClassName()
    if ns.PlayerClass then
        return ns.PlayerClass()
    end
    local _, token = UnitClass("player")
    if type(token) ~= "string" or token == "" then
        return nil
    end
    return token:sub(1, 1):upper() .. token:sub(2):lower()
end

local hbdCache

local function getHBD()
    if hbdCache then
        return hbdCache
    end
    if type(LibStub) ~= "function" then
        return nil
    end
    local ok, lib = pcall(LibStub, "HereBeDragons-2.0")
    if ok and type(lib) == "table" then
        hbdCache = lib
        return lib
    end
    return nil
end

local function worldPoint(map, x, y)
    if not isNumber(map) or not isNumber(x) or not isNumber(y) then
        return nil
    end
    local zx, zy = x, y
    -- Accept either percent (0-100) or fraction (0-1) zone coordinates.
    if zx > 1 or zy > 1 then
        zx, zy = zx / 100, zy / 100
    end

    local hbd = getHBD()
    if hbd and type(hbd.GetWorldCoordinatesFromZone) == "function" then
        local ok, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, zx, zy, map)
        if ok and isNumber(wx) and isNumber(wy) then
            return wx, wy, instance
        end
    end

    -- Fallback when HereBeDragons has no map data for this UiMap.
    if C_Map and C_Map.GetWorldPosFromMapPos then
        local vector
        if CreateVector2D then
            vector = CreateVector2D(zx, zy)
        else
            vector = { x = zx, y = zy }
        end
        local ok, continent, worldPos = pcall(C_Map.GetWorldPosFromMapPos, map, vector)
        if ok and type(worldPos) == "table" and isNumber(worldPos.x) and isNumber(worldPos.y) then
            return worldPos.x, worldPos.y, continent
        end
    end
    return nil
end

local function zoneFromWorld(wx, wy, instance)
    local hbd = getHBD()
    if not hbd or not isNumber(wx) or not isNumber(wy) or not isNumber(instance) then
        return nil
    end
    if type(hbd.GetZoneCoordinatesFromWorld) ~= "function" then
        return nil
    end
    local ok, x, y, map = pcall(hbd.GetZoneCoordinatesFromWorld, hbd, wx, wy, instance, true)
    if not ok or not isNumber(x) or not isNumber(y) or not isNumber(map) then
        return nil
    end
    return map, x * 100, y * 100
end

local function playerPoint()
    local hbd = getHBD()
    if not hbd or type(hbd.GetPlayerWorldPosition) ~= "function" then
        return nil
    end
    local ok, wx, wy, instance = pcall(hbd.GetPlayerWorldPosition, hbd)
    if not ok or not isNumber(wx) or not isNumber(wy) then
        return nil
    end
    return wx, wy, instance
end

-- Resolve destination world coords. Prefer HBD conversion from the resolved
-- zone pin (Questie / Forever percents) so aiming shares the player coordinate
-- space. Raw flight wx/wy are the fallback when zone conversion is unavailable.
local function entryWorld(entry, map, x, y)
    local wx, wy, instance = worldPoint(map, x, y)
    if wx then
        return wx, wy, instance
    end
    if type(entry) == "table" then
        if type(entry.waypoint) == "table" and isNumber(entry.waypoint.wx) and isNumber(entry.waypoint.wy) then
            return entry.waypoint.wx, entry.waypoint.wy, entry.waypoint.instance
        end
        if isNumber(entry.wx) and isNumber(entry.wy) then
            return entry.wx, entry.wy, entry.instance
        end
    end
    return nil
end

-- Same convention as tracker step arrows: use the player's instance id.
-- HereBeDragons GetWorldVector does not require the destination's stored
-- continent id, and Forever flight JSON uses 0/1 which may not match HBD.
local function worldDistance(hbd, instance, px, py, wx, wy)
    if not hbd or not isNumber(px) or not isNumber(wx) then
        return nil
    end
    if not isNumber(instance) then
        instance = 0
    end
    if type(hbd.GetWorldDistance) == "function" then
        local ok, yards = pcall(hbd.GetWorldDistance, hbd, instance, px, py, wx, wy)
        if ok and isNumber(yards) then
            return yards
        end
    end
    if type(hbd.GetWorldVector) == "function" then
        local ok, _, yards = pcall(hbd.GetWorldVector, hbd, instance, px, py, wx, wy)
        if ok and isNumber(yards) then
            return yards
        end
    end
    return nil
end

local function destWorld(dest)
    if type(dest) ~= "table" then
        return nil
    end
    if type(dest.waypoint) == "table" and isNumber(dest.waypoint.wx) and isNumber(dest.waypoint.wy) then
        return dest.waypoint.wx, dest.waypoint.wy, dest.waypoint.instance
    end
    local wx, wy, instance = entryWorld(dest, dest.map, dest.x, dest.y)
    if wx then
        dest.waypoint = { wx = wx, wy = wy, instance = instance }
    end
    return wx, wy, instance
end

-- Returns map, x, y for a preset. Questie spawn data wins when an npc id is set.
local function resolvePin(entry)
    if entry.npc and ns.NpcPin then
        local ok, pin = pcall(ns.NpcPin, entry.npc)
        if ok and type(pin) == "table" and isNumber(pin.map) and isNumber(pin.x) and isNumber(pin.y) then
            return pin.map, pin.x, pin.y
        end
    end

    if isNumber(entry.wx) and isNumber(entry.wy) and isNumber(entry.instance) then
        local map, x, y = zoneFromWorld(entry.wx, entry.wy, entry.instance)
        if map then
            return map, x, y
        end
        return entry.map, entry.x, entry.y
    end

    local x, y = entry.x, entry.y
    -- Forever-sourced pins already use Forever percents; do not convert again.
    if not entry.forever and ns.IsForever and ns.IsForever() and LibQuestieDB and type(LibQuestieDB.EraToForeverByUiMapId) == "function" then
        local ok, nx, ny = pcall(LibQuestieDB.EraToForeverByUiMapId, entry.map, x, y)
        if ok and isNumber(nx) and isNumber(ny) then
            x, y = nx, ny
        end
    end
    return entry.map, x, y
end

local function copyResolved(entry, map, x, y)
    local dest = {}
    for key, value in pairs(entry) do
        dest[key] = value
    end
    dest.map = map
    dest.x = x
    dest.y = y
    -- Waypoint is filled by NavFindNearest via entryWorld after resolvePin.
    dest.waypoint = nil
    return dest
end

-- Public API: target state

local function notifyChanged()
    if ns.NavOnTargetChanged then
        ns.NavOnTargetChanged(target)
    end
end

function ns.NavTarget()
    return target
end

function ns.NavSetTarget(dest)
    if type(dest) ~= "table" then
        return ns.NavClearTarget()
    end
    target = dest
    notifyChanged()
end

function ns.NavClearTarget()
    target = nil
    notifyChanged()
end

-- Public API: search

function ns.NavFindNearest(kind, className)
    local faction = playerFaction()
    if kind == "trainer" and (type(className) ~= "string" or className == "") then
        className = playerClassName()
    end

    local px, py, pinstance = playerPoint()
    local hbd = getHBD()

    local best, bestScore
    for index, entry in ipairs(PRESETS) do
        local matches = entry.kind == kind
        -- nil faction means usable by both (neutral inns / flight hubs).
        if matches and faction and entry.faction and entry.faction ~= faction then
            matches = false
        end
        if matches and kind == "trainer" and entry.class ~= className then
            matches = false
        end
        if matches then
            local map, x, y = resolvePin(entry)
            local score = FAR_AWAY + index
            if px and hbd then
                local wx, wy = entryWorld(entry, map, x, y)
                if wx then
                    local dist = worldDistance(hbd, pinstance, px, py, wx, wy)
                    if dist then
                        score = dist
                    end
                end
            else
                score = index
            end
            if not bestScore or score < bestScore then
                bestScore = score
                best = copyResolved(entry, map, x, y)
                local wx, wy, instance = entryWorld(best, map, x, y)
                if wx then
                    -- Store player continent when the source had none, so later
                    -- reads stay usable even if JSON continent ids differ.
                    best.waypoint = {
                        wx = wx,
                        wy = wy,
                        instance = instance or pinstance,
                    }
                else
                    best.waypoint = nil
                end
            end
        end
    end
    return best
end

function ns.NavChoose(kind, className)
    local dest = ns.NavFindNearest(kind, className)
    if not dest then
        local label = KIND_LABEL[kind] or "destination"
        if kind == "trainer" and className and className ~= "" then
            label = className .. " Trainer"
        end
        if UIErrorsFrame and UIErrorsFrame.AddMessage then
            UIErrorsFrame:AddMessage("No " .. label .. " found for your faction.", 1, 0.1, 0.1, 1)
        end
        return nil
    end
    ns.NavSetTarget(dest)
    return dest
end

-- Public API: formatting and measurement

function ns.NavFormatCoords(dest)
    if type(dest) ~= "table" or not isNumber(dest.x) or not isNumber(dest.y) then
        return ""
    end
    return string.format("%.1f, %.1f", dest.x, dest.y)
end

function ns.NavFormatYards(dist)
    if not isNumber(dist) then
        return ""
    end
    if dist >= 1000 then
        return string.format("%.1fk yd", dist / 1000)
    end
    return string.format("%d yd", math.floor(dist + 0.5))
end

-- Returns distance in yards, or nil when the player / destination world point
-- cannot be resolved. Continent ids on the destination are ignored; measurement
-- always uses the player's HereBeDragons instance like tracker step arrows.
function ns.NavDistance(dest)
    if type(dest) ~= "table" then
        return nil
    end
    local hbd = getHBD()
    local px, py, pinstance = playerPoint()
    if not hbd or not px then
        return nil
    end
    local wx, wy = destWorld(dest)
    if not wx then
        return nil
    end
    return worldDistance(hbd, pinstance, px, py, wx, wy)
end

-- Returns relative facing angle (tracker step-arrow convention) and distance.
-- Distance is still returned when GetPlayerFacing is unavailable so the strip
-- can show yards even if the arrow cannot rotate yet.
function ns.NavFacing(dest)
    if type(dest) ~= "table" then
        return nil
    end
    local hbd = getHBD()
    local px, py, pinstance = playerPoint()
    if not hbd or not px or type(hbd.GetWorldVector) ~= "function" then
        return nil
    end
    local wx, wy = destWorld(dest)
    if not wx then
        return nil
    end
    local ok, angle, dist = pcall(hbd.GetWorldVector, hbd, pinstance or 0, px, py, wx, wy)
    if not ok or not isNumber(angle) then
        return nil
    end
    local facing = GetPlayerFacing and GetPlayerFacing() or nil
    if not isNumber(facing) then
        return nil, dist
    end
    return angle - facing, dist
end

-- Dropdown menu

local MENU_WIDTH = 168
local SUB_WIDTH = 150
local ROW_HEIGHT = 20
local PAD = 4

local catcher
local menu
local subMenu
local menuRows = {}
local subRows = {}
local trainerRow

local function styleFrame(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.04, 0.04, 0.04, 0.96)
    frame:SetBackdropBorderColor(1, 0.82, 0, 0.85)
end

local function applyAccent(frame)
    local r, g, b = 1, 0.82, 0
    if ns.Color then
        r, g, b = ns.Color("accent")
    end
    frame:SetBackdropBorderColor(r, g, b, 0.9)
end

local function hideMenus()
    if subMenu then
        subMenu:Hide()
    end
    if menu then
        menu:Hide()
    end
end

local function acquireRow(parent, rows, index)
    local row = rows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.label:SetPoint("LEFT", 8, 0)
    row.label:SetPoint("RIGHT", -8, 0)
    row.label:SetJustifyH("LEFT")
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    rows[index] = row
    return row
end

local function placeRow(row, parent, offset)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -(PAD + offset))
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -(PAD + offset))
    row:Show()
end

local function chooseAndClose(kind, className)
    hideMenus()
    ns.NavChoose(kind, className)
end

local function presentSubMenu()
    local entries = {}
    local mine = playerClassName()
    if mine then
        entries[#entries + 1] = { text = "My class (" .. mine .. ")", class = mine, mine = true }
    end
    for _, className in ipairs(TRAINER_CLASSES) do
        entries[#entries + 1] = { text = className, class = className }
    end

    for index, entry in ipairs(entries) do
        local row = acquireRow(subMenu, subRows, index)
        row.label:SetText(entry.text)
        if entry.mine and ns.Color then
            local r, g, b = ns.Color("accent")
            row.label:SetTextColor(r, g, b)
        else
            row.label:SetTextColor(1, 1, 1)
        end
        row.className = entry.class
        row:SetScript("OnClick", function(self)
            chooseAndClose("trainer", self.className)
        end)
        placeRow(row, subMenu, (index - 1) * ROW_HEIGHT)
    end
    for extra = #entries + 1, #subRows do
        subRows[extra]:Hide()
        subRows[extra].className = nil
    end
    subMenu:SetHeight(#entries * ROW_HEIGHT + PAD * 2)
end

local function openSubMenu()
    if not trainerRow then
        return
    end
    presentSubMenu()
    applyAccent(subMenu)
    subMenu:ClearAllPoints()
    subMenu:SetPoint("TOPLEFT", trainerRow, "TOPRIGHT", PAD + 2, PAD)
    subMenu:Show()
end

local function presentMenu()
    local items = {
        { text = KIND_LABEL.inn, kind = "inn" },
        { text = KIND_LABEL.bank, kind = "bank" },
        { text = KIND_LABEL.auction, kind = "auction" },
        { text = KIND_LABEL.mail, kind = "mail" },
        { text = KIND_LABEL.flight, kind = "flight" },
        { text = "Class Trainers  >", submenu = true },
    }
    if target then
        items[#items + 1] = { text = "Clear destination", clear = true }
    end

    trainerRow = nil
    for index, item in ipairs(items) do
        local row = acquireRow(menu, menuRows, index)
        row.label:SetText(item.text)
        if item.clear then
            row.label:SetTextColor(1, 0.5, 0.5)
        else
            row.label:SetTextColor(1, 1, 1)
        end
        if item.submenu then
            trainerRow = row
            row:SetScript("OnEnter", openSubMenu)
            row:SetScript("OnClick", openSubMenu)
        else
            row:SetScript("OnEnter", function()
                if subMenu then
                    subMenu:Hide()
                end
            end)
            row:SetScript("OnClick", function()
                hideMenus()
                if item.clear then
                    ns.NavClearTarget()
                else
                    ns.NavChoose(item.kind)
                end
            end)
        end
        placeRow(row, menu, (index - 1) * ROW_HEIGHT)
    end
    for extra = #items + 1, #menuRows do
        menuRows[extra]:Hide()
        menuRows[extra]:SetScript("OnEnter", nil)
        menuRows[extra]:SetScript("OnClick", nil)
    end
    menu:SetSize(MENU_WIDTH, #items * ROW_HEIGHT + PAD * 2)
end

local function buildMenu()
    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints()
    catcher:SetFrameStrata("DIALOG")
    catcher:SetFrameLevel(1)
    catcher:Hide()
    catcher:RegisterForClicks("AnyUp")
    catcher:SetScript("OnClick", hideMenus)

    menu = CreateFrame("Frame", "RestedXPBetterNavMenu", UIParent, "BackdropTemplate")
    menu:SetSize(MENU_WIDTH, 80)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(20)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:Hide()
    styleFrame(menu)
    menu:SetScript("OnShow", function(self)
        catcher:Show()
        applyAccent(self)
    end)
    menu:SetScript("OnHide", function()
        catcher:Hide()
        if subMenu then
            subMenu:Hide()
        end
    end)

    subMenu = CreateFrame("Frame", "RestedXPBetterNavSubMenu", UIParent, "BackdropTemplate")
    subMenu:SetSize(SUB_WIDTH, 80)
    subMenu:SetFrameStrata("DIALOG")
    subMenu:SetFrameLevel(30)
    subMenu:SetClampedToScreen(true)
    subMenu:EnableMouse(true)
    subMenu:Hide()
    styleFrame(subMenu)
end

buildMenu()

function ns.HideNavMenu()
    hideMenus()
end

function ns.ToggleNavMenu(anchor)
    if menu:IsShown() then
        hideMenus()
        return
    end
    if ns.HideGuideMenu then
        ns.HideGuideMenu()
    end
    anchor = anchor or UIParent
    presentMenu()
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -2)
    menu:Show()
end
