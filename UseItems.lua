local _, ns = ...

-- Item buttons for guide steps that tell the player to use an item.
-- "Use the [LOOT]Item[/]", "Equip the [LOOT]Item[/]", and "use it" after a
-- tagged item in the same sentence. The button is a secure item click.

local USE_VERBS = {
    use = true,
    equip = true,
    drink = true,
    plant = true,
    throw = true,
    place = true,
    apply = true,
    open = true,
    read = true,
    combine = true,
    light = true,
    activate = true,
}

local PRONOUNS = {
    it = true,
    them = true,
    this = true,
    these = true,
}

local TAG_PATTERNS = {
    "%[LOOT%]([^%[%]]-)%[/%w*%]",
    "%[BUY%]([^%[%]]-)%[/%w*%]",
    "|cRB_LOOT_(.-)|r",
    "|cRB_BUY_(.-)|r",
}

local POOL_START = 8
local POOL_MAX = 24
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"

local pool = {}
local shown = 0
local pending = false
local retryUntil = 0
local retryFrame
local infoFrame

local trim = strtrim or function(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function inCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function now()
    return GetTime and GetTime() or 0
end

local function requestRefresh()
    if ns.MarkTrackerDirty then
        ns.MarkTrackerDirty(false)
    end
end

local function armRetry()
    if not CreateFrame then
        return
    end
    if not retryFrame then
        retryFrame = CreateFrame("Frame")
        local elapsed = 0
        retryFrame:SetScript("OnUpdate", function(self, dt)
            elapsed = elapsed + (dt or 0)
            if elapsed < 1 then
                return
            end
            elapsed = 0
            if not pending then
                self:Hide()
                return
            end
            pending = false
            requestRefresh()
        end)
    end
    retryFrame:Show()
end

local function watchItemInfo()
    if infoFrame or not CreateFrame then
        return
    end
    infoFrame = CreateFrame("Frame")
    infoFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    infoFrame:SetScript("OnEvent", function()
        if not pending then
            return
        end
        pending = false
        requestRefresh()
    end)
end

local function pluralKey(name)
    local key = name:lower()
    if key:match("[^aeiou]ies$") then
        return key:sub(1, -4) .. "y"
    end
    if key:match("[^s]s$") and not key:match("ss$") then
        return key:sub(1, -2)
    end
    return key
end

local function namesMatch(a, b)
    if type(a) ~= "string" or type(b) ~= "string" then
        return false
    end
    return pluralKey(a) == pluralKey(b)
end

local function isBreak(ch)
    return ch == "." or ch == "!" or ch == "?" or ch == "\n" or ch == ";"
end

local function sentenceBounds(text, pos)
    local startAt = 1
    local index = pos
    while index > 1 do
        if isBreak(text:sub(index - 1, index - 1)) then
            startAt = index
            break
        end
        index = index - 1
    end
    local finish = #text
    index = pos
    while index <= #text do
        if isBreak(text:sub(index, index)) then
            finish = index
            break
        end
        index = index + 1
    end
    return startAt, finish
end

local function scanTags(text, tags)
    for _, pattern in ipairs(TAG_PATTERNS) do
        local startAt = 1
        while startAt <= #text do
            local first, last, name = text:find(pattern, startAt)
            if not first then
                break
            end
            name = trim(name or "")
            if name ~= "" then
                tags[#tags + 1] = { name = name, pos = first }
            end
            startAt = last + 1
        end
    end
    table.sort(tags, function(a, b)
        return a.pos < b.pos
    end)
end

local function scanVerbs(text, verbs)
    local lower = text:lower()
    local startAt = 1
    while startAt <= #lower do
        local first, last = lower:find("[%a]+", startAt)
        if not first then
            break
        end
        if USE_VERBS[lower:sub(first, last)] then
            verbs[#verbs + 1] = first
        end
        startAt = last + 1
    end
end

local function wordAfter(text, verbPos)
    local lower = text:lower()
    local _, last = lower:find("[%a]+", verbPos)
    if not last then
        return nil
    end
    return lower:sub(last + 1):match("^%s*([%a]+)")
end

local function addName(into, seen, name)
    local key = pluralKey(name)
    if seen[key] then
        return
    end
    seen[key] = true
    into[#into + 1] = name
end

local function collectFrom(text, into, seen)
    if type(text) ~= "string" or text == "" then
        return
    end
    if not text:find("[", 1, true) and not text:find("|c", 1, true) then
        return
    end
    local tags = {}
    scanTags(text, tags)
    if #tags == 0 then
        return
    end
    local verbs = {}
    scanVerbs(text, verbs)
    if #verbs == 0 then
        return
    end

    for index, verbPos in ipairs(verbs) do
        local sentenceStart, sentenceEnd = sentenceBounds(text, verbPos)
        local regionEnd = sentenceEnd
        local nextVerb = verbs[index + 1]
        if nextVerb and nextVerb > verbPos and nextVerb <= sentenceEnd then
            regionEnd = nextVerb
        end
        local found = false
        for _, tag in ipairs(tags) do
            if tag.pos > verbPos and tag.pos < regionEnd and tag.pos >= sentenceStart then
                addName(into, seen, tag.name)
                found = true
            end
        end
        if not found then
            local pronoun = wordAfter(text, verbPos)
            if pronoun and PRONOUNS[pronoun] then
                if pronoun == "them" or pronoun == "these" then
                    for _, tag in ipairs(tags) do
                        if tag.pos >= sentenceStart and tag.pos < verbPos then
                            addName(into, seen, tag.name)
                        end
                    end
                else
                    local best
                    for _, tag in ipairs(tags) do
                        if tag.pos >= sentenceStart and tag.pos < verbPos and (not best or tag.pos > best.pos) then
                            best = tag
                        end
                    end
                    if best then
                        addName(into, seen, best.name)
                    end
                end
            end
        end
    end
end

-- Names a step tells the player to use, in reading order. Nil when none.
function ns.GuideUseItemNames(source)
    local names = {}
    local seen = {}
    if type(source) == "string" then
        collectFrom(source, names, seen)
    elseif type(source) == "table" then
        collectFrom(source.text, names, seen)
        if type(source.details) == "table" then
            for _, line in ipairs(source.details) do
                collectFrom(line, names, seen)
            end
        end
        collectFrom(source.note, names, seen)
    end
    if #names == 0 then
        return nil
    end
    return names
end

local function infoFrom(query)
    if query == nil then
        return nil
    end
    if C_Item and C_Item.GetItemInfo then
        local ok, name = pcall(C_Item.GetItemInfo, query)
        if ok and type(name) == "table" then
            local id = name.itemID
            local link = name.itemLink
            if not id and type(link) == "string" then
                id = tonumber(link:match("item:(%d+)"))
            end
            return name.itemName or name.name, name.iconFileID or name.icon, id
        end
    end
    if GetItemInfo then
        local ok, name, link, _, _, _, _, _, _, _, texture = pcall(GetItemInfo, query)
        if ok and type(name) == "string" and name ~= "" then
            local id = type(link) == "string" and tonumber(link:match("item:(%d+)")) or nil
            if type(query) == "number" then
                id = id or query
            end
            return name, texture, id
        end
    end
end

local function iconFor(id)
    if not id then
        return nil
    end
    if C_Item and C_Item.GetItemIconByID then
        local ok, texture = pcall(C_Item.GetItemIconByID, id)
        if ok and texture then
            return texture
        end
    end
    if GetItemIcon then
        local ok, texture = pcall(GetItemIcon, id)
        if ok and texture then
            return texture
        end
    end
    local _, texture = infoFrom(id)
    return texture
end

local function countInBags(query)
    if query == nil then
        return 0
    end
    if C_Item and C_Item.GetItemCount then
        local ok, count = pcall(C_Item.GetItemCount, query, false, false)
        if ok and type(count) == "number" and count > 0 then
            return count
        end
    end
    if GetItemCount then
        local ok, count = pcall(GetItemCount, query, false)
        if ok and type(count) == "number" and count > 0 then
            return count
        end
    end
    return 0
end

local function countEquipped(id)
    if not id or not GetInventoryItemID then
        return 0
    end
    local count = 0
    for slot = 1, 19 do
        local ok, found = pcall(GetInventoryItemID, "player", slot)
        if ok and found == id then
            count = count + 1
        end
    end
    return count
end

local function resolveName(name)
    local id = ns.EntityIdByName and ns.EntityIdByName("item", name) or nil
    local infoName, texture
    if id then
        infoName, texture = infoFrom(id)
        texture = texture or iconFor(id)
        if not texture and C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, id)
            pending = true
            watchItemInfo()
        end
        if infoName and not namesMatch(name, infoName) then
            id = nil
            infoName = nil
            texture = nil
        end
    end
    if not id then
        local byName, byTexture, byId = infoFrom(name)
        if byName and namesMatch(name, byName) then
            infoName = byName
            texture = byTexture or texture
            id = byId
        end
    end
    local count = countInBags(id) 
    if count < 1 then
        count = countInBags(infoName or name)
    end
    count = count + countEquipped(id)
    if not id and count < 1 then
        return nil
    end
    return {
        name = (infoName and namesMatch(name, infoName)) and infoName or name,
        id = id,
        texture = texture,
        count = count,
    }
end

-- Resolved use-items for a guide step. Nil when the step does not use one.
function ns.CollectUseItems(step)
    local names = ns.GuideUseItemNames(step)
    if not names then
        return nil
    end
    local resolved = {}
    local waiting = false
    local questieReady = not ns.QuestieReady or ns.QuestieReady()
    for _, name in ipairs(names) do
        local entry = resolveName(name)
        if entry then
            resolved[#resolved + 1] = entry
            if not entry.texture then
                waiting = true
            end
        elseif not questieReady then
            waiting = true
        end
    end
    if waiting then
        local stamp = now()
        if retryUntil == 0 then
            retryUntil = stamp + 30
        end
        if stamp < retryUntil then
            pending = true
            armRetry()
        end
    else
        retryUntil = 0
    end
    if #resolved == 0 then
        return nil
    end
    return resolved
end

local function applyCooldown(button)
    local cooldown = button.cooldown
    if not cooldown then
        return
    end
    local id = button.itemId
    local start, duration
    if id and C_Container and C_Container.GetItemCooldown then
        local ok, a, b = pcall(C_Container.GetItemCooldown, id)
        if ok then
            start, duration = a, b
        end
    end
    if id and not start and GetItemCooldown then
        local ok, a, b = pcall(GetItemCooldown, id)
        if ok then
            start, duration = a, b
        end
    end
    if type(start) == "number" and type(duration) == "number" and start > 0 and duration > 0 then
        cooldown:SetCooldown(start, duration)
    elseif cooldown.Clear then
        cooldown:Clear()
    else
        cooldown:SetCooldown(0, 0)
    end
end

local function paintButton(button)
    local count = countInBags(button.itemId)
    if count < 1 then
        count = countInBags(button.itemName)
    end
    count = count + countEquipped(button.itemId)
    button.itemCount = count
    local have = count > 0
    local texture = button.itemTexture or iconFor(button.itemId) or QUESTION
    button.icon:SetTexture(texture)
    button.icon:SetDesaturated(not have)
    if have then
        button.icon:SetVertexColor(1, 1, 1)
    else
        button.icon:SetVertexColor(0.55, 0.55, 0.55)
    end
    if have and ns.Color then
        local r, g, b = ns.Color("accent")
        button.edge:SetVertexColor(r, g, b, 1)
    else
        button.edge:SetVertexColor(0.35, 0.35, 0.35, 1)
    end
    if count > 1 then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:SetText("")
        button.count:Hide()
    end
    applyCooldown(button)
end

local function showTooltip(button)
    if not GameTooltip then
        return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    local shown = false
    if button.itemId and GameTooltip.SetItemByID then
        shown = pcall(GameTooltip.SetItemByID, GameTooltip, button.itemId)
    end
    if not shown and button.itemId then
        shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. button.itemId)
    end
    if not shown then
        GameTooltip:ClearLines()
        GameTooltip:SetText(button.itemName or "Item", 1, 1, 1)
    end
    if (button.itemCount or 0) > 0 then
        GameTooltip:AddLine("Click to use.", 1, 1, 1)
    else
        GameTooltip:AddLine("Not in your bags yet.", 0.9, 0.75, 0.4)
    end
    if ns.FinishTooltip then
        ns.FinishTooltip()
    else
        GameTooltip:Show()
    end
end

local function resetIcon(button)
    button.icon:ClearAllPoints()
    button.icon:SetPoint("TOPLEFT", 1, -1)
    button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
end

local function createButton(index)
    local button = CreateFrame("Button", "WaynotesUseItem" .. index, UIParent, "SecureActionButtonTemplate")
    button:SetSize(22, 22)
    button:RegisterForClicks("LeftButtonUp")
    button:SetAttribute("type", "item")
    button:Hide()
    button.waynotesUseItem = true

    local edge = button:CreateTexture(nil, "BACKGROUND")
    edge:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    edge:SetAllPoints()
    edge:SetVertexColor(0.35, 0.35, 0.35, 1)
    button.edge = edge

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")

    local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    count:SetPoint("BOTTOMRIGHT", -1, 1)
    count:SetJustifyH("RIGHT")
    if count.SetFont then
        local face = NumberFontNormal and NumberFontNormal:GetFont() or (GameFontNormal and GameFontNormal:GetFont())
        if face then
            count:SetFont(face, 10, "OUTLINE")
        end
    end
    count:Hide()
    button.count = count

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(icon)
    if cooldown.SetDrawEdge then
        cooldown:SetDrawEdge(false)
    end
    button.cooldown = cooldown

    button:SetScript("OnEnter", function(self)
        showTooltip(self)
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnHide", function(self)
        if GameTooltip and GameTooltip:IsShown() and GameTooltip.GetOwner and GameTooltip:GetOwner() == self then
            GameTooltip:Hide()
        end
        resetIcon(self)
    end)
    button:SetScript("OnMouseDown", function(self)
        if (self.itemCount or 0) > 0 then
            self.icon:ClearAllPoints()
            self.icon:SetPoint("TOPLEFT", 2, -2)
            self.icon:SetPoint("BOTTOMRIGHT", 0, 0)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        resetIcon(self)
    end)
    return button
end

local function ensureButton(index)
    local button = pool[index]
    if button then
        return button
    end
    if not CreateFrame or inCombat() or index > POOL_MAX then
        return nil
    end
    button = createButton(index)
    pool[index] = button
    return button
end

local function bindButton(index, entry)
    local button = ensureButton(index)
    if not button or type(entry) ~= "table" then
        return nil
    end
    local token = entry.id and ("item:" .. entry.id) or entry.name
    if not token or token == "" then
        return nil
    end
    if button.itemToken ~= token then
        if inCombat() then
            return nil
        end
        button:SetAttribute("type", "item")
        button:SetAttribute("item", token)
        button.itemToken = token
    end
    button.itemId = entry.id
    button.itemName = entry.name
    button.itemTexture = entry.texture
    paintButton(button)
    return button
end

if CreateFrame then
    for index = 1, POOL_START do
        pool[index] = createButton(index)
    end
end

function ns.BeginUseItemButtons()
    shown = 0
end

-- Copy existing action buttons and append secure use-item buttons for this row.
function ns.AppendUseItemButtons(actions, entries)
    if type(entries) ~= "table" or #entries < 1 then
        return actions or {}
    end
    local out = {}
    for index, button in ipairs(actions or {}) do
        out[index] = button
    end
    for _, entry in ipairs(entries) do
        shown = shown + 1
        local button = bindButton(shown, entry)
        if button then
            out[#out + 1] = button
        end
    end
    return out
end

function ns.FinishUseItemButtons()
    for index = shown + 1, #pool do
        local button = pool[index]
        if button then
            button:Hide()
        end
    end
end

function ns.RefreshUseItemButtons()
    for index = 1, shown do
        local button = pool[index]
        if button and button:IsShown() then
            paintButton(button)
        end
    end
end
