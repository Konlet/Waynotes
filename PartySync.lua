local addonName, ns = ...

-- One-way party guide sync: follow another Waynotes user's guide id, step,
-- quest/kill/loot progress, and currently shown sticky steps.

local PREFIX = "Waynotes"
local PEER_TTL = 30
local BROADCAST_INTERVAL = 5
local WARN_COOLDOWN = 20
local MSG_MAX = 240

local peers = {}
local followName
local remoteQuests
local remoteQuestSig
local remoteStickies
local remoteStickySig
local remoteProgress
local remoteProgressSig
local applying
local lastWarnAt = 0
local lastWarnGuide
local registered
local ticker
local dropdown
local broadcastPending
local combatBroadcastPending
-- Let Guides.lua's dirty coalesce refresh lastSync* before we encode.
local BROADCAST_COALESCE = 0.15
-- Ability reagents / ammo / thrown fire BAG_UPDATE often. Never encode that fast.
local BROADCAST_BAG_COALESCE = 1.0

local function say(text)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffce7bffWaynotes|r " .. text)
    end
end

local function shortName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    -- Addon senders are often "Name-Realm"; UnitName is usually just "Name".
    if Ambiguate then
        name = Ambiguate(name, "short") or name
    end
    return name:match("^([^%-]+)") or name
end

local function samePlayer(a, b)
    a = shortName(a)
    b = shortName(b)
    if not a or not b then
        return false
    end
    return a:lower() == b:lower()
end

local function playerName()
    if UnitFullName then
        local name = UnitFullName("player")
        if type(name) == "string" and name ~= "" then
            return shortName(name)
        end
    end
    local name = UnitName and UnitName("player")
    return shortName(name)
end

local function isSelf(sender)
    if type(sender) ~= "string" or sender == "" then
        return false
    end
    if samePlayer(sender, playerName()) then
        return true
    end
    if GetUnitName then
        local full = GetUnitName("player", true)
        if type(full) == "string" and full ~= "" and samePlayer(sender, full) then
            return true
        end
    end
    return false
end

local function inGroup()
    if IsInGroup then
        return IsInGroup()
    end
    if GetNumGroupMembers then
        return (GetNumGroupMembers() or 0) > 0
    end
    if GetNumPartyMembers then
        return (GetNumPartyMembers() or 0) > 0
    end
    return false
end

local function standaloneReady()
    return ns.UsingStandalone and ns.UsingStandalone()
end

local function sendAddon(channel, message, target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, message, channel, target)
        return
    end
    if SendAddonMessage then
        SendAddonMessage(PREFIX, message, channel, target)
    end
end

local function registerPrefix()
    if registered then
        return
    end
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        registered = true
        return
    end
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(PREFIX)
        registered = true
    end
end

local function currentState()
    local guideId = ns.GuideId and ns.GuideId()
    if type(guideId) ~= "string" or guideId == "" then
        return nil, nil
    end
    local db = WaynotesCharDB
    local entry = db and db.progress and db.progress[guideId]
    local step = tonumber(entry and entry.step) or 1
    return guideId, step
end

local function notifyUI()
    if ns.RefreshPartySyncChrome then
        ns.RefreshPartySyncChrome()
    end
end

local function prunePeers()
    local now = GetTime and GetTime() or 0
    local changed = false
    for name, peer in pairs(peers) do
        if (now - (peer.at or 0)) > PEER_TTL then
            peers[name] = nil
            changed = true
            if followName and samePlayer(followName, name) then
                followName = nil
                say("Lost sync with " .. name .. " (no longer advertising).")
            end
        end
    end
    return changed
end

local function peerList()
    prunePeers()
    local list = {}
    for name, peer in pairs(peers) do
        if not isSelf(name) then
            list[#list + 1] = {
                name = name,
                guideId = peer.guideId,
                step = peer.step,
            }
        else
            peers[name] = nil
        end
    end
    table.sort(list, function(a, b)
        return (a.name or ""):lower() < (b.name or ""):lower()
    end)
    return list
end

local function decodeQuests(blob)
    local map = {}
    if type(blob) ~= "string" or blob == "" then
        return map
    end
    for piece in string.gmatch(blob, "[^;]+") do
        local idText, flagsText, objText = string.match(piece, "^(%d+):(%d+):?(.*)$")
        local id = tonumber(idText)
        local flags = tonumber(flagsText) or 0
        if id then
            local objectives = {}
            if type(objText) == "string" and objText ~= "" then
                for pair in string.gmatch(objText, "[^,]+") do
                    local filled, need = string.match(pair, "^(%d+)/(%d+)$")
                    filled = tonumber(filled) or 0
                    need = tonumber(need) or 0
                    local finished = need > 0 and filled >= need
                    objectives[#objectives + 1] = {
                        filled = filled,
                        need = need,
                        finished = finished,
                    }
                end
            end
            map[id] = {
                on = (flags % 2) >= 1,
                completed = (math.floor(flags / 2) % 2) >= 1,
                objDone = (math.floor(flags / 4) % 2) >= 1,
                objectives = objectives,
            }
        end
    end
    return map
end

local function decodeStickies(blob)
    local map = {}
    if type(blob) ~= "string" or blob == "" then
        return map
    end
    for piece in string.gmatch(blob, "[^,]+") do
        local index = tonumber(piece)
        if index and index > 0 then
            map[index] = true
        end
    end
    return map
end

local function decodeProgress(blob)
    local map = {}
    if type(blob) ~= "string" or blob == "" then
        return map
    end
    for piece in string.gmatch(blob, "[^;]+") do
        local stepText, countsText = string.match(piece, "^(%d+):(.+)$")
        local stepIndex = tonumber(stepText)
        if stepIndex and type(countsText) == "string" then
            local counts = {}
            for pair in string.gmatch(countsText, "[^,]+") do
                local filled, need = string.match(pair, "^(%d+)/(%d+)$")
                filled = tonumber(filled)
                need = tonumber(need)
                if filled and need and need > 0 then
                    counts[#counts + 1] = { filled = filled, need = need }
                end
            end
            if #counts > 0 then
                map[stepIndex] = counts
            end
        end
    end
    return map
end

local function looksLikeQuestBlob(text)
    return type(text) == "string" and text:find("%d+:%d+") ~= nil
end

local function looksLikeProgressBlob(text)
    if type(text) ~= "string" or text == "" then
        return false
    end
    local saw = false
    for piece in string.gmatch(text, "[^;]+") do
        -- Quest rows use id:flags:objs. Progress rows are step:have/need,...
        if piece:match("^%d+:%d+:") or piece:match("^%d+:%d+$") then
            return false
        end
        if not piece:match("^%d+:%d+/%d+") then
            return false
        end
        saw = true
    end
    return saw
end

-- Never call RefreshTracker(true) from party sync: that bypasses coalesce and
-- was causing 40ms+ hitches whenever the player was in a group.
local function markTrackerDirty(force)
    if ns.MarkTrackerDirty then
        ns.MarkTrackerDirty(force and true or false)
    elseif ns.RefreshTracker then
        ns.RefreshTracker(force and true or false)
    end
end

-- Quest/bag spam is frequent in a group. Coalesce broadcasts and let the normal
-- tracker dirty pass update sticky/progress caches first.
local function scheduleBroadcast(delay)
    if applying or not standaloneReady() or not inGroup() then
        return
    end
    -- Mid-fight encodes hitch the caster; flush once combat ends.
    if InCombatLockdown and InCombatLockdown() then
        combatBroadcastPending = true
        return
    end
    delay = tonumber(delay) or BROADCAST_COALESCE
    if broadcastPending then
        return
    end
    broadcastPending = true
    local function fire()
        broadcastPending = false
        if standaloneReady() and inGroup() then
            ns.PartySyncBroadcast()
        end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(delay, fire)
    else
        fire()
    end
end

local function rememberPeer(name, guideId, step, questSig, quests, stickySig, stickies, progressSig, progress)
    name = shortName(name)
    if not name or isSelf(name) then
        return false
    end
    local prev = peers[name]
    peers[name] = {
        guideId = guideId,
        step = tonumber(step) or 1,
        questSig = questSig,
        quests = quests,
        stickySig = stickySig,
        stickies = stickies,
        progressSig = progressSig,
        progress = progress,
        at = GetTime and GetTime() or 0,
    }
    local wasNew = not prev
    return wasNew
end

local function applyFollowState(guideId, step, fromName, quests, questSig, stickies, stickySig, progress, progressSig)
    if not standaloneReady() then
        return
    end
    if type(guideId) ~= "string" or guideId == "" then
        return
    end
    step = tonumber(step) or 1
    local questsChanged = questSig ~= remoteQuestSig
    local stickiesChanged = stickySig ~= remoteStickySig
    local progressChanged = progressSig ~= remoteProgressSig
    if type(quests) == "table" then
        remoteQuests = quests
        remoteQuestSig = questSig
    end
    if stickySig ~= nil and type(stickies) == "table" then
        remoteStickies = stickies
        remoteStickySig = stickySig
    end
    if progressSig ~= nil and type(progress) == "table" then
        remoteProgress = progress
        remoteProgressSig = progressSig
    end
    local currentId = ns.GuideId and ns.GuideId()
    local db = WaynotesCharDB
    local entry = db and db.progress and currentId and db.progress[currentId]
    local currentStep = tonumber(entry and entry.step)
    if currentId == guideId and currentStep == step then
        if questsChanged or stickiesChanged or progressChanged then
            -- Progress/quest text only: never force a full rebuild. Sticky set
            -- changes may add/remove rows, but MarkTrackerDirty(false) still
            -- rebuilds when the signature changes. Forcing was a 40-60ms hitch
            -- on every peer bag/ability broadcast while following.
            markTrackerDirty(stickiesChanged and true or false)
        end
        return
    end
    if not ns.GuideExists or not ns.GuideExists(guideId) then
        local now = GetTime and GetTime() or 0
        if guideId ~= lastWarnGuide or (now - lastWarnAt) >= WARN_COOLDOWN then
            lastWarnAt = now
            lastWarnGuide = guideId
            say("Synced to " .. (fromName or "party") .. ", but guide \"" .. guideId .. "\" is not installed.")
        end
        return
    end
    applying = true
    if ns.GuideApplySync then
        ns.GuideApplySync(guideId, step)
    end
    applying = false
end

function ns.PartySyncRemoteQuest(id)
    if not followName or type(remoteQuests) ~= "table" then
        return nil
    end
    id = tonumber(id)
    if not id then
        return nil
    end
    return remoteQuests[id]
end

-- Quest ids present in the leader snapshot (for title lookups while following).
function ns.PartySyncRemoteQuestIds()
    if not followName or type(remoteQuests) ~= "table" then
        return nil
    end
    local ids = {}
    for id in pairs(remoteQuests) do
        id = tonumber(id)
        if id then
            ids[#ids + 1] = id
        end
    end
    return ids
end

function ns.PartySyncRemoteStickies()
    if not followName or type(remoteStickies) ~= "table" then
        return nil
    end
    return remoteStickies
end

function ns.PartySyncRemoteStepProgress(stepIndex)
    if not followName or type(remoteProgress) ~= "table" then
        return nil
    end
    stepIndex = tonumber(stepIndex)
    if not stepIndex then
        return nil
    end
    return remoteProgress[stepIndex]
end

function ns.PartySyncApplying()
    return applying and true or false
end

function ns.PartySyncFollowing()
    return followName ~= nil
end

function ns.PartySyncFollowTarget()
    return followName
end

function ns.PartySyncHasPeers()
    return #peerList() > 0
end

function ns.PartySyncPeerNames()
    local names = {}
    for _, peer in ipairs(peerList()) do
        names[#names + 1] = peer.name
    end
    return names
end

function ns.PartySyncClear(silent)
    if not followName then
        if not silent then
            say("Not syncing to anyone.")
        end
        return
    end
    local was = followName
    followName = nil
    remoteQuests = nil
    remoteQuestSig = nil
    remoteStickies = nil
    remoteStickySig = nil
    remoteProgress = nil
    remoteProgressSig = nil
    if not silent then
        say("Stopped syncing to " .. was .. ".")
    end
    markTrackerDirty(true)
    notifyUI()
end

function ns.PartySyncFollow(name)
    if not standaloneReady() then
        say("Party sync needs Replace RestedXP (standalone guide) on.")
        return false
    end
    name = shortName(name)
    if not name or name == "" then
        say("Pick a party member to sync to.")
        return false
    end
    if isSelf(name) then
        say("You cannot sync to yourself.")
        return false
    end
    prunePeers()
    local peer
    for key, entry in pairs(peers) do
        if not isSelf(key) and samePlayer(key, name) then
            peer = entry
            name = key
            break
        end
    end
    if not peer then
        say(name .. " is not advertising Waynotes in your party.")
        return false
    end
    followName = name
    say("Syncing to " .. name .. ". Auto-progress is off until you stop.")
    applyFollowState(
        peer.guideId,
        peer.step,
        name,
        peer.quests,
        peer.questSig,
        peer.stickies,
        peer.stickySig,
        peer.progress,
        peer.progressSig
    )
    notifyUI()
    return true
end

function ns.PartySyncBroadcast()
    if applying then
        return
    end
    if not standaloneReady() or not inGroup() then
        return
    end
    -- Encoding quests/progress walks the log. Doing that on every combat
    -- bag tick (reagents, ammo) was a group-only cast hitch.
    if InCombatLockdown and InCombatLockdown() then
        combatBroadcastPending = true
        return
    end
    combatBroadcastPending = false
    registerPrefix()
    local guideId, step = currentState()
    if not guideId then
        return
    end
    local stickyBlob = ""
    if ns.GuideEncodeSyncStickies then
        stickyBlob = ns.GuideEncodeSyncStickies() or ""
    end
    local head = "S\t" .. guideId .. "\t" .. tostring(step) .. "\t" .. stickyBlob
    local progressBlob = ""
    if ns.GuideEncodeSyncProgress then
        local budget = math.max(20, math.floor((MSG_MAX - #head - 2) * 0.45))
        progressBlob = ns.GuideEncodeSyncProgress(budget) or ""
    end
    local mid = head .. "\t" .. progressBlob
    local questBlob = ""
    if ns.GuideEncodeSyncQuests then
        local budget = MSG_MAX - #mid - 1
        if budget > 20 then
            questBlob = ns.GuideEncodeSyncQuests(budget) or ""
        end
    end
    local payload = mid
    if questBlob ~= "" then
        payload = mid .. "\t" .. questBlob
    end
    if #payload > MSG_MAX then
        payload = head
    end
    local channel = "PARTY"
    if IsInRaid and IsInRaid() then
        channel = "RAID"
    end
    sendAddon(channel, payload)
end

local function onAddonMessage(prefix, message, _, sender)
    if prefix ~= PREFIX then
        return
    end
    if isSelf(sender) then
        return
    end
    sender = shortName(sender)
    if not sender then
        return
    end
    if type(message) ~= "string" then
        return
    end
    local kind, guideId, stepText, field4, field5, field6 = strsplit("\t", message)
    if kind ~= "S" then
        return
    end
    local step = tonumber(stepText) or 1
    local stickyBlob -- nil when the peer did not send a sticky field
    local progressBlob -- nil when absent
    local questBlob
    if type(field6) == "string" then
        stickyBlob = field4 or ""
        progressBlob = field5 or ""
        questBlob = field6
    elseif type(field5) == "string" then
        stickyBlob = field4 or ""
        if looksLikeProgressBlob(field5) then
            progressBlob = field5
        else
            questBlob = field5
        end
    elseif looksLikeQuestBlob(field4) then
        questBlob = field4
    elseif looksLikeProgressBlob(field4) then
        progressBlob = field4
    elseif type(field4) == "string" then
        stickyBlob = field4
    end
    local quests = decodeQuests(questBlob)
    local questSig = type(questBlob) == "string" and questBlob or ""
    local stickies = stickyBlob ~= nil and decodeStickies(stickyBlob) or nil
    local stickySig = stickyBlob
    local progress = progressBlob ~= nil and decodeProgress(progressBlob) or nil
    local progressSig = progressBlob
    local wasNew = rememberPeer(sender, guideId, step, questSig, quests, stickySig, stickies, progressSig, progress)
    if wasNew then
        notifyUI()
    end
    if followName and samePlayer(followName, sender) then
        followName = sender
        applyFollowState(guideId, step, sender, quests, questSig, stickies, stickySig, progress, progressSig)
    end
end

local function clearPeersLeft()
    if inGroup() then
        return
    end
    local had = next(peers) ~= nil or followName ~= nil
    if wipe then
        wipe(peers)
    else
        for name in pairs(peers) do
            peers[name] = nil
        end
    end
    if followName then
        followName = nil
        remoteQuests = nil
        remoteQuestSig = nil
        remoteStickies = nil
        remoteStickySig = nil
        remoteProgress = nil
        remoteProgressSig = nil
        say("Left the group; party sync cleared.")
        markTrackerDirty(true)
    end
    if had then
        notifyUI()
    end
end

local function pulse()
    if prunePeers() then
        notifyUI()
    end
    clearPeersLeft()
    -- Broadcast only. A forced tracker rebuild here was the group-join lag.
    ns.PartySyncBroadcast()
end

local function ensureTicker()
    if ticker then
        return
    end
    if C_Timer and C_Timer.NewTicker then
        ticker = C_Timer.NewTicker(BROADCAST_INTERVAL, pulse)
        return
    end
    local frame = CreateFrame("Frame")
    local elapsed = 0
    frame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed >= BROADCAST_INTERVAL then
            elapsed = 0
            pulse()
        end
    end)
    ticker = frame
end

local function initMenu()
    if dropdown then
        return
    end
    dropdown = CreateFrame("Frame", "WaynotesPartySyncMenu", UIParent, "UIDropDownMenuTemplate")
end

local function menuInitialize(self, level)
    if not level or level ~= 1 then
        return
    end
    local list = peerList()
    if followName then
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Synced to " .. followName
        info.isTitle = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Stop syncing"
        info.notCheckable = true
        info.func = function()
            ns.PartySyncClear()
        end
        UIDropDownMenu_AddButton(info, level)
    else
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Sync to..."
        info.isTitle = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
    end

    if #list == 0 then
        local info = UIDropDownMenu_CreateInfo()
        info.text = "No Waynotes peers in party"
        info.notCheckable = true
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
        return
    end

    for _, peer in ipairs(list) do
        local info = UIDropDownMenu_CreateInfo()
        local label = peer.name
        if peer.guideId then
            label = label .. "  |cffaaaaaa" .. peer.guideId .. " #" .. tostring(peer.step or "?") .. "|r"
        end
        info.text = label
        info.notCheckable = true
        info.checked = followName and samePlayer(followName, peer.name)
        info.func = function()
            ns.PartySyncFollow(peer.name)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

function ns.PartySyncOpenPicker(anchor)
    if not standaloneReady() then
        say("Party sync needs Replace RestedXP (standalone guide) on.")
        return
    end
    initMenu()
    prunePeers()
    UIDropDownMenu_Initialize(dropdown, menuInitialize, "MENU")
    if type(anchor) == "table" then
        ToggleDropDownMenu(1, nil, dropdown, anchor, 0, 0)
    else
        ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
    end
end

function ns.PartySyncSlash(args)
    args = strtrim(args or "")
    if not standaloneReady() then
        say("Party sync needs Replace RestedXP (standalone guide) on.")
        return
    end
    if args == "" then
        ns.PartySyncOpenPicker()
        return
    end
    local lower = args:lower()
    if lower == "off" or lower == "stop" or lower == "clear" then
        ns.PartySyncClear()
        return
    end
    if lower == "status" then
        if followName then
            say("Syncing to " .. followName .. ".")
        else
            say("Not syncing. Peers: " .. table.concat(ns.PartySyncPeerNames(), ", "))
        end
        return
    end
    ns.PartySyncFollow(args)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("GROUP_ROSTER_UPDATE")
events:RegisterEvent("CHAT_MSG_ADDON")
events:RegisterEvent("QUEST_LOG_UPDATE")
events:RegisterEvent("QUEST_ACCEPTED")
events:RegisterEvent("QUEST_TURNED_IN")
events:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        registerPrefix()
        ensureTicker()
        pulse()
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        if combatBroadcastPending then
            combatBroadcastPending = false
            scheduleBroadcast(BROADCAST_COALESCE)
        end
        return
    end
    if event == "GROUP_ROSTER_UPDATE" then
        clearPeersLeft()
        ns.PartySyncBroadcast()
        notifyUI()
        return
    end
    if event == "CHAT_MSG_ADDON" then
        onAddonMessage(...)
        return
    end
    if event == "UNIT_QUEST_LOG_CHANGED" then
        local unit = ...
        if unit ~= "player" then
            return
        end
    end
    if event == "QUEST_LOG_UPDATE"
        or event == "QUEST_ACCEPTED"
        or event == "QUEST_TURNED_IN"
        or event == "UNIT_QUEST_LOG_CHANGED"
    then
        -- Guides.lua already dirties the tracker; wait for that paint so
        -- sticky/progress encode is fresh, then send one coalesced broadcast.
        scheduleBroadcast(BROADCAST_COALESCE)
        return
    end
    if event == "BAG_UPDATE_DELAYED" then
        -- Collect/loot steps need bag sync, but casts that spend reagents also
        -- fire this. Use a long coalesce and never encode during combat.
        scheduleBroadcast(BROADCAST_BAG_COALESCE)
    end
end)
