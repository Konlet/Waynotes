local _, ns = ...

-- Teldrassil class side quests. Open these when the main Teldrassil guide points
-- to them, finish the chain, then resume the main route.

ns.RegisterGuide({
    id = "alliance-teldrassil-hunter-taming",
    name = "Teldrassil Hunter Taming",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "NightElf" },
    classes = { "Hunter" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Dazalar|r in Dolanaar. Accept |cRB_QUEST_Taming the Beast|r. Train your spells.",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6063,
            when = "accepted",
        },
        {
            text = "Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Webwood Lurker|r near Dolanaar.",
            map = 1438,
            x = 58.0,
            y = 60.0,
            quest = 6063,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Webwood Lurker|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Dazalar|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Taming the Beast|r.",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6101,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "Dismiss your spider. Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Nightsaber Stalker|r.",
            map = 1438,
            x = 55.0,
            y = 72.0,
            quest = 6101,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Nightsaber Stalker|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Dazalar|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Taming the Beast|r.",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6102,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "Dismiss your nightsaber. Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Strigid Screecher|r.",
            map = 1438,
            x = 44.0,
            y = 50.0,
            quest = 6102,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Strigid Screecher|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Dazalar|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Training the Beast|r.",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6103,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "In Darnassus, talk to |cRB_FRIENDLY_Jocaste|r. Turn in |cRB_QUEST_Training the Beast|r.",
            map = 1457,
            x = 40.4,
            y = 8.6,
            quest = 6103,
            when = "complete",
        },
        {
            text = "Return to the 6-12 Teldrassil guide.",
            guide = "alliance-teldrassil-6-12-curated",
        },
    },
})

ns.RegisterGuide({
    id = "alliance-teldrassil-druid-moonglade",
    name = "Teldrassil Druid Moonglade",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "NightElf" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 14,
    steps = {
        {
            text = "In Darnassus, talk to |cRB_FRIENDLY_Mathrengyl Bearwalker|r. Accept |cRB_QUEST_Heeding the Call|r if you do not have it, then turn it in. Accept |cRB_QUEST_Moonglade|r.",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 5921,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Heeding the Call|r",
            },
            note = "Pickup may be 5923 or 5925 depending on your trainer.",
        },
        {
            text = "Cast Teleport: Moonglade. Talk to |cRB_FRIENDLY_Dendrite Starblaze|r. Turn in |cRB_QUEST_Moonglade|r. Accept |cRB_QUEST_Great Bear Spirit|r.",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 5929,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Moonglade|r",
            },
        },
        {
            text = "Talk to the |cRB_FRIENDLY_Great Bear Spirit|r, then return to Dendrite. Turn in |cRB_QUEST_Great Bear Spirit|r. Accept |cRB_QUEST_Back to Darnassus|r.",
            map = 1450,
            x = 39.1,
            y = 27.5,
            quest = 5931,
            when = "accepted",
            details = {
                "Speak with the Great Bear Spirit",
                "Turn in |cRB_QUEST_Great Bear Spirit|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Silva Fil'naveth|r for a flight to Rut'theran, then enter Darnassus. Talk to |cRB_FRIENDLY_Mathrengyl Bearwalker|r. Turn in |cRB_QUEST_Back to Darnassus|r. Accept |cRB_QUEST_Body and Heart|r.",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 6001,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Back to Darnassus|r",
            },
        },
        {
            text = "Return to the Teldrassil guide, then open the Darkshore Druid Body and Heart side guide when you reach Auberdine.",
            note = "Lunaclaw is completed in Darkshore.",
            guide = "alliance-teldrassil-6-12-curated",
        },
    },
})
