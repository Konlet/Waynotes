local _, ns = ...

-- Alliance Darkshore class side guides.
-- Opened from pointer steps in the main Darkshore curated route.
-- Finish the chain, then resume the linked main guide.

ns.RegisterGuide({
    id = "alliance-darkshore-druid-body",
    name = "Darkshore Druid Body and Heart",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "Night Elf" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "At the Moonkin Stone east of Auberdine, use [LOOT]Cenarion Moondust[/]. Kill [ENEMY]Lunaclaw[/], then speak with its spirit.",
            map = 1439,
            x = 43.5,
            y = 45.9,
            quest = 6001,
            when = "objectives",
            details = {
                "Face [ENEMY]Lunaclaw[/] and earn the strength of body and heart",
            },
            note = "Accept [QUEST]Body and Heart[/] from [FRIENDLY]Mathrengyl Bearwalker[/] in Darnassus first.",
        },
        {
            text = "In Darnassus, talk to [FRIENDLY]Mathrengyl Bearwalker[/]. Turn in [QUEST]Body and Heart[/].",
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
    races = { "Night Elf" },
    classes = { "Druid" },
    minLevel = 14,
    maxLevel = 20,
    steps = {
        {
            text = "In Darnassus, talk to [FRIENDLY]Mathrengyl Bearwalker[/]. Accept [QUEST]Lessons Anew[/].",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 6121,
            when = "accepted",
        },
        {
            text = "Cast [SKILL]Teleport: Moonglade[/]. Talk to [FRIENDLY]Dendrite Starblaze[/]. Turn in [QUEST]Lessons Anew[/]. Accept [QUEST]The Principal Source[/].",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 6122,
            when = "accepted",
            details = {
                "Turn in [QUEST]Lessons Anew[/]",
            },
        },
        {
            text = "At Cliffspring Falls in northern Darkshore, fill the [LOOT]Empty Cliffspring Falls Sampler[/].",
            map = 1439,
            x = 54.9,
            y = 33.3,
            quest = 6122,
            when = "objectives",
            details = {
                "[LOOT]Filled Cliffspring Falls Sampler[/] (1)",
            },
        },
        {
            text = "Talk to [FRIENDLY]Alanndarian Nightsong[/] in Auberdine. Turn in [QUEST]The Principal Source[/]. Accept [QUEST]Gathering the Cure[/].",
            map = 1439,
            x = 37.7,
            y = 40.7,
            quest = 6123,
            when = "accepted",
            details = {
                "Turn in [QUEST]The Principal Source[/]",
            },
        },
        {
            sticky = true,
            text = "Gather [LOOT]Earthroot[/] with Herbalism, or buy it from the Auction House.",
            map = 1439,
            x = 45.0,
            y = 50.0,
            quest = 6123,
            objective = 1,
            when = "objectives",
            details = {
                "[LOOT]Earthroot[/] (5)",
            },
            note = "Earthroot is not Darkshore-only. Skip herbalism if you already bought 5.",
        },
        {
            text = "Loot [PICK]Lunar Fungus[/] in the caves around Darkshore.",
            map = 1439,
            x = 43.1,
            y = 45.9,
            quest = 6123,
            objective = 2,
            when = "objectives",
            details = {
                "[LOOT]Lunar Fungus[/] (12)",
            },
            nearYards = 200,
        },
        {
            text = "Talk to [FRIENDLY]Alanndarian Nightsong[/]. Turn in [QUEST]Gathering the Cure[/]. Accept [QUEST]Curing the Sick[/].",
            map = 1439,
            x = 37.7,
            y = 40.7,
            quest = 6124,
            when = "accepted",
            details = {
                "Turn in [QUEST]Gathering the Cure[/]",
            },
        },
        {
            text = "Use the [LOOT]Curative Animal Salve[/] on [ENEMY]Sickly Deer[/] throughout Darkshore.",
            map = 1439,
            x = 45.0,
            y = 50.0,
            quest = 6124,
            when = "objectives",
            details = {
                "Cure [ENEMY]Sickly Deer[/] (10)",
            },
            nearYards = 200,
        },
        {
            text = "Cast [SKILL]Teleport: Moonglade[/]. Talk to [FRIENDLY]Dendrite Starblaze[/]. Turn in [QUEST]Curing the Sick[/]. Accept [QUEST]Power over Poison[/].",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 6125,
            when = "accepted",
            details = {
                "Turn in [QUEST]Curing the Sick[/]",
            },
        },
        {
            text = "In Darnassus, talk to [FRIENDLY]Mathrengyl Bearwalker[/]. Turn in [QUEST]Power over Poison[/].",
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
