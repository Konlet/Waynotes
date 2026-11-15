local _, ns = ...

-- Horde Tirisfal class side guides.
-- Opened from pointer steps in the main Tirisfal curated route.
-- Finish the chain, then resume the linked main guide.

ns.RegisterGuide({
    id = "horde-tirisfal-warlock-halgar",
    name = "Tirisfal Warlock Halgar's Summons",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Undead" },
    classes = { "Warlock" },
    minLevel = 8,
    maxLevel = 12,
    steps = {
        {
            text = "Enter Undercity. Talk to [FRIENDLY]Carendin Halgar[/] in the Magic Quarter. Turn in [QUEST]Halgar's Summons[/]. Accept [QUEST]Creature of the Void[/].",
            map = 1458,
            x = 85.0,
            y = 26.0,
            quest = 1473,
            when = "accepted",
            details = {
                "Turn in [QUEST]Halgar's Summons[/]",
            },
        },
        {
            text = "Loot [PICK]Perrine's Chest[/] upstairs in Captain Perrine's tower west of Brill for [LOOT]Egalin's Grimoire[/].",
            map = 1420,
            x = 51.1,
            y = 67.6,
            quest = 1473,
            when = "objectives",
            details = {
                "[LOOT]Egalin's Grimoire[/] (1)",
            },
        },
        {
            text = "Talk to [FRIENDLY]Carendin Halgar[/]. Turn in [QUEST]Creature of the Void[/]. Accept [QUEST]The Binding[/].",
            map = 1458,
            x = 85.0,
            y = 26.0,
            quest = 1471,
            when = "accepted",
            details = {
                "Turn in [QUEST]Creature of the Void[/]",
            },
        },
        {
            text = "Use the [LOOT]Runes of Summoning[/] in the summoning circle. Kill the [ENEMY]Summoned Voidwalker[/].",
            map = 1458,
            x = 86.6,
            y = 27.1,
            quest = 1471,
            when = "objectives",
            details = {
                "Kill [ENEMY]Summoned Voidwalker[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Carendin Halgar[/]. Turn in [QUEST]The Binding[/].",
            map = 1458,
            x = 85.0,
            y = 26.0,
            quest = 1471,
            when = "complete",
        },
        {
            text = "Return to the 10-13 Tirisfal guide.",
            guide = "horde-tirisfal-10-13-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-tirisfal-paladin-bandarion",
    name = "Tirisfal Paladin Bandarion Keep",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Undead" },
    classes = { "Paladin" },
    minLevel = 10,
    maxLevel = 13,
    steps = {
        {
            text = "In Brill, talk to [FRIENDLY]Shari Stilwell[/]. Accept [QUEST]A Second Home[/].",
            map = 1420,
            x = 60.2,
            y = 52.7,
            quest = 91282,
            when = "accepted",
        },
        {
            text = "Travel west to Bandarion Keep. Talk to [FRIENDLY]Breton Samuels[/]. Turn in [QUEST]A Second Home[/]. Accept [QUEST]Murlocs at the Gates[/].",
            map = 1420,
            x = 21.9,
            y = 45.2,
            quest = 91285,
            when = "accepted",
            details = {
                "Turn in [QUEST]A Second Home[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Danitha Morr[/]. Accept [QUEST]A Lesson in Divinity[/].",
            map = 1420,
            x = 22.1,
            y = 44.7,
            quest = 94427,
            when = "accepted",
        },
        {
            text = "On the western shore, kill [ENEMY]Vile Fin Attackers[/] and [ENEMY]Vile Fin Seers[/].",
            map = 1420,
            x = 14.7,
            y = 54.8,
            quest = 91285,
            when = "objectives",
            details = {
                "[ENEMY]Vile Fin Attacker[/] (8)",
                "[ENEMY]Vile Fin Seer[/] (8)",
            },
        },
        {
            text = "Talk to [FRIENDLY]Breton Samuels[/]. Turn in [QUEST]Murlocs at the Gates[/]. Accept [QUEST]Touring the Grounds[/].",
            map = 1420,
            x = 21.9,
            y = 45.2,
            quest = 91294,
            when = "accepted",
            details = {
                "Turn in [QUEST]Murlocs at the Gates[/]",
            },
        },
        {
            text = "Speak with [FRIENDLY]Jorin Croge[/], [FRIENDLY]Hilda[/], [FRIENDLY]Ander[/], and [FRIENDLY]Danitha Morr[/].",
            map = 1420,
            x = 21.9,
            y = 45.2,
            quest = 91294,
            when = "objectives",
        },
        {
            text = "Talk to [FRIENDLY]Danitha Morr[/]. Turn in [QUEST]Touring the Grounds[/]. Accept [QUEST]The Tarnished[/]. Talk to [FRIENDLY]Jorin Croge[/]. Accept [QUEST]Making Repairs[/].",
            map = 1420,
            x = 22.1,
            y = 44.7,
            quests = { 91317, 91316 },
            when = "accepted",
            details = {
                "Turn in [QUEST]Touring the Grounds[/]",
            },
        },
        {
            text = "In the crypt, loot [PICK]Lumber Piles[/]. Outside, kill [ENEMY]Rudolph Gelhardt[/], [ENEMY]Tarnished Zealots[/], and [ENEMY]Tarnished Drudges[/].",
            map = 1420,
            x = 11.5,
            y = 64.2,
            quests = { 91316, 91317 },
            when = "objectives",
            details = {
                "[LOOT]Sturdy Lumber[/] (12)",
                "[LOOT]Rudolph Gelhardt's Head[/] (1)",
                "[ENEMY]Tarnished Zealot[/] (6)",
                "[ENEMY]Tarnished Drudge[/] (8)",
            },
        },
        {
            text = "Talk to [FRIENDLY]Jorin Croge[/] and [FRIENDLY]Danitha Morr[/]. Turn in [QUEST]Making Repairs[/] and [QUEST]The Tarnished[/]. Accept [QUEST]A Token of Good Faith[/].",
            map = 1420,
            x = 22.1,
            y = 44.7,
            quest = 95803,
            when = "accepted",
            details = {
                "Turn in [QUEST]Making Repairs[/]",
                "Turn in [QUEST]The Tarnished[/]",
            },
        },
        {
            text = "In Undercity, talk to [FRIENDLY]Tanis Alderwood[/] for Divinity turn-ins, then talk to [FRIENDLY]Lady Sylvanas Windrunner[/]. Turn in [QUEST]A Token of Good Faith[/].",
            map = 1458,
            x = 58.1,
            y = 91.8,
            quest = 95803,
            when = "complete",
        },
        {
            text = "Return to the 10-13 Tirisfal guide.",
            guide = "horde-tirisfal-10-13-curated",
        },
    },
})
