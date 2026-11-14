local _, ns = ...

-- Darkshore class side quests. Open these when the main Darkshore guide points
-- to them, finish the chain, then resume the main route.

ns.RegisterGuide({
    id = "alliance-darkshore-druid-body",
    name = "Darkshore Druid Body and Heart",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "NightElf" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "At the Moonkin Stone east of Auberdine, use |cRB_LOOT_Cenarion Moondust|r. Kill |cRB_ENEMY_Lunaclaw|r, then speak with its spirit.",
            map = 1439,
            x = 43.5,
            y = 45.9,
            quest = 6001,
            when = "objectives",
            details = {
                "Face Lunaclaw and earn the strength of body and heart",
            },
            note = "Accept |cRB_QUEST_Body and Heart|r from Mathrengyl in Darnassus first.",
        },
        {
            text = "In Darnassus, talk to |cRB_FRIENDLY_Mathrengyl Bearwalker|r. Turn in |cRB_QUEST_Body and Heart|r.",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 6001,
            when = "complete",
        },
        {
            text = "Return to the Darkshore guide.",
            guide = "alliance-darkshore-11-16",
        },
    },
})

ns.RegisterGuide({
    id = "alliance-darkshore-druid-cure",
    name = "Darkshore Druid Cure Poison",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "NightElf" },
    classes = { "Druid" },
    minLevel = 14,
    maxLevel = 20,
    steps = {
        {
            text = "In Darnassus, talk to |cRB_FRIENDLY_Mathrengyl Bearwalker|r. Accept |cRB_QUEST_Lessons Anew|r.",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 6121,
            when = "accepted",
        },
        {
            text = "Cast Teleport: Moonglade. Talk to |cRB_FRIENDLY_Dendrite Starblaze|r. Turn in |cRB_QUEST_Lessons Anew|r. Accept |cRB_QUEST_The Principal Source|r.",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 6122,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Lessons Anew|r",
            },
        },
        {
            text = "At Cliffspring Falls in northern Darkshore, fill the |cRB_LOOT_Empty Cliffspring Falls Sampler|r.",
            map = 1439,
            x = 54.9,
            y = 33.3,
            quest = 6122,
            when = "objectives",
            details = {
                "|cRB_LOOT_Filled Cliffspring Falls Sampler|r (1)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Alanndarian Nightsong|r in Auberdine. Turn in |cRB_QUEST_The Principal Source|r. Accept |cRB_QUEST_Gathering the Cure|r.",
            map = 1439,
            x = 37.7,
            y = 40.7,
            quest = 6123,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_The Principal Source|r",
            },
        },
        {
            text = "Gather |cRB_LOOT_Earthroot|r and kill |cRB_ENEMY_Rabid Thistle Bears|r for |cRB_LOOT_Tumors|r around Darkshore.",
            map = 1439,
            x = 45.0,
            y = 50.0,
            quest = 6123,
            when = "objectives",
            details = {
                "|cRB_LOOT_Earthroot|r (5)",
                "|cRB_LOOT_Tumor|r (12)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Alanndarian Nightsong|r. Turn in |cRB_QUEST_Gathering the Cure|r. Accept |cRB_QUEST_Curing the Sick|r.",
            map = 1439,
            x = 37.7,
            y = 40.7,
            quest = 6124,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Gathering the Cure|r",
            },
        },
        {
            text = "Use the |cRB_LOOT_Curative Animal Salve|r on |cRB_ENEMY_Sickly Deer|r throughout Darkshore.",
            map = 1439,
            x = 45.0,
            y = 50.0,
            quest = 6124,
            when = "objectives",
            details = {
                "Cure |cRB_ENEMY_Sickly Deer|r (10)",
            },
        },
        {
            text = "Cast Teleport: Moonglade. Talk to |cRB_FRIENDLY_Dendrite Starblaze|r. Turn in |cRB_QUEST_Curing the Sick|r. Accept |cRB_QUEST_Power over Poison|r.",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 6125,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Curing the Sick|r",
            },
        },
        {
            text = "In Darnassus, talk to |cRB_FRIENDLY_Mathrengyl Bearwalker|r. Turn in |cRB_QUEST_Power over Poison|r.",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 6125,
            when = "complete",
        },
        {
            text = "Return to the Darkshore guide.",
            guide = "alliance-darkshore-11-16",
        },
    },
})
