local _, ns = ...

-- Alliance Blasted Lands.
-- Nethergarde Keep and the 51 pass with Burning Steppes.
-- DRAFT: scaffolded from Zygor reference by Data/scaffold_alliance_curated.py.
-- Needs a hand pass for coordinates, nearYards, stickies, pins and wording.

ns.RegisterGuide({
    id = "alliance-blasted-lands-51-51",
    name = "51 Blasted Lands",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    next = "alliance-burning-steppes-51-51",
    minLevel = 51,
    maxLevel = 51,
    steps = {
        {
            text = "Talk to [FRIENDLY]Ambassador Ardalan[/]. Accept [QUEST]Petty Squabbles[/].",
            quest = 2783,
            when = "accepted",
            map = 1419,
            x = 67.57,
            y = 19.29,
        },
        {
            text = "Talk to [FRIENDLY]Fallen Hero of the Horde[/]. Turn in [QUEST]Petty Squabbles[/]. Accept [QUEST]A Tale of Sorrow[/].",
            quest = 2801,
            when = "accepted",
            map = 1435,
            x = 34.29,
            y = 66.13,
            details = {
                "Turn in [QUEST]Petty Squabbles[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Fallen Hero of the Horde[/]. Listen to a Tale of Sorrow.",
            quest = 2801,
            when = "objectives",
            map = 1435,
            x = 34.29,
            y = 66.13,
        },
        {
            text = "Talk to [FRIENDLY]Fallen Hero of the Horde[/]. Turn in [QUEST]A Tale of Sorrow[/].",
            quest = 2801,
            when = "complete",
            map = 1435,
            x = 34.29,
            y = 66.13,
        },
        {
            text = "While Questing in Blasted Lands.",
            mode = "hardcore",
        },
        {
            text = "Talk to [FRIENDLY]Bloodmage Drazial[/]. Accept [QUEST]Snickerfang Jowls[/], [QUEST]A Boar's Vitality[/], and [QUEST]The Decisive Striker[/].",
            quests = { 2581, 2583, 2585 },
            when = "accepted",
            map = 1419,
            x = 50.55,
            y = 14.21,
        },
        {
            text = "Talk to [FRIENDLY]Bloodmage Lynnore[/]. Accept [QUEST]The Basilisk's Bite[/] and [QUEST]Vulture's Vigor[/].",
            quests = { 2601, 2603 },
            when = "accepted",
            map = 1419,
            x = 50.64,
            y = 14.3,
        },
        {
            text = "Kill [ENEMY]Black Slayers[/] and [ENEMY]Bonepickers[/].",
            map = 1419,
            x = 56.6,
            y = 35.4,
            details = {
                "[LOOT]Vulture Gizzard[/] (14)",
            },
        },
        {
            text = "Kill [ENEMY]Redstone Basilisks[/] and [ENEMY]Redstone Crystalhides[/].",
            map = 1419,
            x = 54.4,
            y = 29.8,
            details = {
                "[LOOT]Basilisk Brain[/] (11)",
            },
            note = "Shared spawns with boars.",
        },
        {
            text = "Kill [ENEMY]Ashmane Boars[/] and [ENEMY]Helboars[/].",
            map = 1419,
            x = 57.2,
            y = 27.2,
            details = {
                "[LOOT]Blasted Boar Lung[/] (6)",
            },
            note = "Shared spawns with basilisks.",
        },
        {
            text = "Kill [ENEMY]Starving Snickerfangs[/] and [ENEMY]Snickerfang Hyenas[/].",
            map = 1419,
            x = 58.2,
            y = 31.8,
            details = {
                "[LOOT]Snickerfang Jowl[/] (5)",
            },
            note = "Shared spawns with scorpions.",
        },
        {
            text = "Kill [ENEMY]Scorpok Stingers[/].",
            map = 1419,
            x = 47.6,
            y = 18.8,
            details = {
                "[LOOT]Scorpok Pincer[/] (6)",
            },
            note = "Shared spawns with hyenas.",
        },
        {
            text = "Talk to [FRIENDLY]Kum'isha the Collector[/]. Accept [QUEST]Everything Counts In Large Amounts[/] and [QUEST]To Serve Kum'isha[/].",
            quests = { 3501, 2521 },
            when = "accepted",
            map = 1419,
            x = 51.8,
            y = 35.64,
        },
        {
            text = "Talk to [FRIENDLY]Kum'isha the Collector[/]. Turn in [QUEST]Everything Counts In Large Amounts[/] and [QUEST]To Serve Kum'isha[/].",
            quests = { 3501, 2521 },
            when = "complete",
            map = 1419,
            x = 51.8,
            y = 35.64,
        },
        {
            text = "Talk to [FRIENDLY]Bloodmage Lynnore[/]. Turn in [QUEST]The Basilisk's Bite[/] and [QUEST]Vulture's Vigor[/].",
            quests = { 2601, 2603 },
            when = "complete",
            map = 1419,
            x = 50.64,
            y = 14.3,
        },
        {
            text = "Talk to [FRIENDLY]Bloodmage Drazial[/]. Turn in [QUEST]Snickerfang Jowls[/], [QUEST]A Boar's Vitality[/], and [QUEST]The Decisive Striker[/].",
            quests = { 2581, 2583, 2585 },
            when = "complete",
            map = 1419,
            x = 50.55,
            y = 14.21,
        },
        {
            text = "This pass is done. Continue to Burning Steppes.",
            guide = "alliance-burning-steppes-51-51",
        },
    },
})
