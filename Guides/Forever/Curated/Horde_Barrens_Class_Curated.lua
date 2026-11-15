local _, ns = ...

-- Horde Barrens class side guides.
-- Opened from pointer steps in Durotar or Barrens curated routes.
-- Finish the chain, then resume the linked main guide.

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
            text = "Talk to [FRIENDLY]Kranal Fiss[/] north of the Crossroads. Turn in [QUEST]Call of Fire[/]. Accept [QUEST]Call of Fire[/].",
            map = 1413,
            x = 56.0,
            y = 19.8,
            quest = 1525,
            when = "accepted",
            details = {
                "Turn in [QUEST]Call of Fire[/]",
            },
            note = "Start [QUEST]Call of Fire[/] from your Durotar trainer before this step.",
        },
        {
            text = "Kill [ENEMY]Razormane Water Seekers[/], [ENEMY]Razormane Thornweavers[/], and [ENEMY]Razormane Geomancers[/] for [LOOT]Fire Tar[/].",
            map = 1413,
            x = 54.0,
            y = 25.0,
            quest = 1525,
            when = "objectives",
            objective = 1,
            details = {
                "[LOOT]Fire Tar[/] (1)",
            },
        },
        {
            text = "In Dustwind Cave east of Razor Hill, kill a [ENEMY]Burning Blade Cultist[/] for a [LOOT]Reagent Pouch[/].",
            map = 1411,
            x = 52.8,
            y = 28.7,
            quest = 1525,
            when = "objectives",
            objective = 2,
            details = {
                "[LOOT]Reagent Pouch[/] (1)",
                "Kill [ENEMY]Burning Blade Cultist[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Kranal Fiss[/]. Turn in [QUEST]Call of Fire[/]. Accept [QUEST]Call of Fire[/].",
            map = 1413,
            x = 56.0,
            y = 19.8,
            quest = 1526,
            when = "accepted",
            details = {
                "Turn in [QUEST]Call of Fire[/]",
            },
        },
        {
            text = "At the top of Thunder Ridge in Durotar, use the [LOOT]Fire Sapta[/]. Kill the [ENEMY]Minor Manifestation of Fire[/]. Loot the [PICK]Brazier[/] for a [LOOT]Glowing Ember[/].",
            map = 1411,
            x = 39.0,
            y = 32.0,
            quest = 1526,
            when = "objectives",
            details = {
                "[LOOT]Glowing Ember[/] (1)",
                "Kill [ENEMY]Minor Manifestation of Fire[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Kranal Fiss[/]. Turn in [QUEST]Call of Fire[/]. Accept [QUEST]Call of Fire[/].",
            map = 1413,
            x = 56.0,
            y = 19.8,
            quest = 1527,
            when = "accepted",
            details = {
                "Turn in [QUEST]Call of Fire[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Telf Joolam[/] in Durotar. Turn in [QUEST]Call of Fire[/].",
            map = 1411,
            x = 38.6,
            y = 58.9,
            quest = 1527,
            when = "complete",
        },
        {
            text = "Return to the Barrens guide.",
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
            text = "Talk to [FRIENDLY]Uzzek[/] at Far Watch Post. Turn in [QUEST]Veteran Uzzek[/]. Accept [QUEST]Path of Defense[/].",
            map = 1413,
            x = 61.4,
            y = 21.1,
            quest = 1498,
            when = "accepted",
            details = {
                "Turn in [QUEST]Veteran Uzzek[/]",
            },
            note = "Start [QUEST]Veteran Uzzek[/] from your Durotar warrior trainer.",
        },
        {
            text = "In Thunder Ridge, kill [ENEMY]Lightning Hides[/] for [LOOT]Singed Scales[/].",
            map = 1411,
            x = 39.0,
            y = 28.0,
            quest = 1498,
            when = "objectives",
            details = {
                "[LOOT]Singed Scale[/] (5)",
                "Kill [ENEMY]Lightning Hide[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Uzzek[/]. Turn in [QUEST]Path of Defense[/].",
            map = 1413,
            x = 61.4,
            y = 21.1,
            quest = 1498,
            when = "complete",
        },
        {
            text = "Return to the Barrens guide.",
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
            text = "At the Moonkin Stone west of Camp Taurajo, use [LOOT]Cenarion Lunardust[/]. Kill [ENEMY]Lunaclaw[/], then speak with its spirit.",
            map = 1413,
            x = 42.0,
            y = 60.9,
            quest = 6002,
            when = "objectives",
            details = {
                "Face [ENEMY]Lunaclaw[/] and earn the strength of body and heart",
            },
            note = "Accept [QUEST]Body and Heart[/] from [FRIENDLY]Turak Runetotem[/] in Thunder Bluff first.",
        },
        {
            text = "In Thunder Bluff, talk to [FRIENDLY]Turak Runetotem[/]. Turn in [QUEST]Body and Heart[/].",
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
