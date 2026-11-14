local _, ns = ...

-- Barrens class side quests. Open these when a Durotar or Barrens guide
-- points to them, finish the chain, then resume the main route.

ns.RegisterGuide({
    id = "horde-barrens-shaman-fire",
    name = "Barrens Shaman Call of Fire",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll", "Tauren" },
    classes = { "Shaman" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Kranal Fiss|r north of the Crossroads. Turn in |cRB_QUEST_Call of Fire|r. Accept |cRB_QUEST_Call of Fire|r.",
            map = 1413,
            x = 56.0,
            y = 19.8,
            quest = 1525,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Fire|r",
            },
            note = "Pickup 2984/1524 comes from Durotar trainers before this step.",
        },
        {
            text = "Kill |cRB_ENEMY_Razormane Water Seekers|r, Thornweavers, and Geomancers for |cRB_LOOT_Fire Tar|r. Kill a |cRB_ENEMY_Burning Blade Cultist|r in Durotar for |cRB_LOOT_Reagent Pouch|r if you still need it.",
            map = 1413,
            x = 54.0,
            y = 25.0,
            quest = 1525,
            when = "objectives",
            details = {
                "|cRB_LOOT_Fire Tar|r (1)",
                "|cRB_LOOT_Reagent Pouch|r (1)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Kranal Fiss|r. Turn in |cRB_QUEST_Call of Fire|r. Accept |cRB_QUEST_Call of Fire|r.",
            map = 1413,
            x = 56.0,
            y = 19.8,
            quest = 1526,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Fire|r",
            },
        },
        {
            text = "At the top of Durotar's Thunder Ridge, use the |cRB_LOOT_Fire Sapta|r. Kill the |cRB_ENEMY_Minor Manifestation of Fire|r. Loot the |cRB_PICK_Brazier|r for |cRB_LOOT_Glowing Ember|r.",
            map = 1411,
            x = 39.0,
            y = 32.0,
            quest = 1526,
            when = "objectives",
            details = {
                "|cRB_LOOT_Glowing Ember|r (1)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Kranal Fiss|r. Turn in |cRB_QUEST_Call of Fire|r. Accept |cRB_QUEST_Call of Fire|r.",
            map = 1413,
            x = 56.0,
            y = 19.8,
            quest = 1527,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Fire|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Telf Joolam|r in Durotar. Turn in |cRB_QUEST_Call of Fire|r.",
            map = 1411,
            x = 38.6,
            y = 58.9,
            quest = 1527,
            when = "complete",
        },
        {
            text = "Return to the Barrens or Durotar guide you left.",
            guide = "horde-barrens-12-16",
        },
    },
})

ns.RegisterGuide({
    id = "horde-barrens-warrior-path",
    name = "Barrens Warrior Path of Defense",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll", "Tauren", "Undead" },
    classes = { "Warrior" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Uzzek|r at Far Watch Post. Turn in |cRB_QUEST_Veteran Uzzek|r. Accept |cRB_QUEST_Path of Defense|r.",
            map = 1413,
            x = 61.4,
            y = 21.1,
            quest = 1498,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Veteran Uzzek|r",
            },
            note = "Pickup 1505 comes from Durotar warriors.",
        },
        {
            text = "In Thunder Ridge, kill |cRB_ENEMY_Lightning Hides|r for |cRB_LOOT_Singed Scales|r.",
            map = 1411,
            x = 39.0,
            y = 28.0,
            quest = 1498,
            when = "objectives",
            details = {
                "|cRB_LOOT_Singed Scale|r (5)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Uzzek|r. Turn in |cRB_QUEST_Path of Defense|r.",
            map = 1413,
            x = 61.4,
            y = 21.1,
            quest = 1498,
            when = "complete",
        },
        {
            text = "Return to the Barrens or Durotar guide you left.",
            guide = "horde-barrens-12-16",
        },
    },
})

ns.RegisterGuide({
    id = "horde-barrens-druid-body",
    name = "Barrens Druid Body and Heart",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "At the Moonkin Stone west of Camp Taurajo, use |cRB_LOOT_Cenarion Lunardust|r. Kill |cRB_ENEMY_Lunaclaw|r, then speak with its spirit.",
            map = 1413,
            x = 42.0,
            y = 60.9,
            quest = 6002,
            when = "objectives",
            details = {
                "Face Lunaclaw and earn the strength of body and heart",
            },
            note = "Accept |cRB_QUEST_Body and Heart|r from Turak in Thunder Bluff first.",
        },
        {
            text = "In Thunder Bluff, talk to |cRB_FRIENDLY_Turak Runetotem|r. Turn in |cRB_QUEST_Body and Heart|r.",
            map = 1456,
            x = 76.5,
            y = 27.2,
            quest = 6002,
            when = "complete",
        },
        {
            text = "Return to the Barrens guide.",
            guide = "horde-barrens-12-16",
        },
    },
})
