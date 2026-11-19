local _, ns = ...

-- Alliance Alterac Mountains.
-- 39-40 pass interleaved with Arathi Highlands.
-- DRAFT: scaffolded from Zygor reference by Data/scaffold_alliance_curated.py.
-- Needs a hand pass for coordinates, nearYards, stickies, pins and wording.

ns.RegisterGuide({
    id = "alliance-alterac-39-40",
    name = "39-40 Alterac Mountains",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    next = "alliance-dustwallow-40-40",
    minLevel = 39,
    maxLevel = 40,
    steps = {
        {
            text = "Talk to [FRIENDLY]Phin Odelic[/]. Turn in [QUEST]Hints of a New Plague?[/].",
            quest = 661,
            when = "complete",
            map = 1424,
            x = 50.34,
            y = 59.04,
        },
        {
            text = "Talk to [FRIENDLY]Innkeeper Anderson[/]. Set your Hearthstone to Southshore.",
            map = 1424,
            x = 51.17,
            y = 58.93,
        },
        {
            text = "Talk to [FRIENDLY]Marshal Redpath[/]. Accept [QUEST]Crushridge Bounty[/].",
            quest = 500,
            when = "accepted",
            map = 1424,
            x = 49.48,
            y = 58.73,
        },
        {
            text = "Talk to [FRIENDLY]Magistrate Henry Maleb[/]. Turn in [QUEST]Further Mysteries[/]. Accept [QUEST]Dark Council[/] and [QUEST]Noble Deaths[/].",
            quests = { 537, 512 },
            when = "accepted",
            map = 1424,
            x = 48.14,
            y = 59.11,
            details = {
                "Turn in [QUEST]Further Mysteries[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Archmage Ansirem Runeweaver[/]. Turn in [QUEST]Magical Analysis[/].",
            quest = 602,
            when = "complete",
            map = 1416,
            x = 18.84,
            y = 78.49,
        },
        {
            text = "Talk to [FRIENDLY]Archmage Ansirem Runeweaver[/]. Accept [QUEST]Ansirem's Key[/].",
            quest = 603,
            when = "accepted",
            map = 1416,
            x = 18.84,
            y = 78.49,
        },
        {
            text = "Kill [ENEMY]Nagaz[/].",
            quest = 537,
            when = "objectives",
            map = 1416,
            x = 39.22,
            y = 14.31,
            details = {
                "Kill [ENEMY]Nagaz[/]",
                "[LOOT]Head of Nagaz[/] (1)",
            },
        },
        {
            text = "Click the [PICK]Worn Wooden Chest[/]. Use the [LOOT]Ensorcelled Parchment[/]. Accept [QUEST]The Ensorcelled Parchment[/].",
            quest = 551,
            when = "accepted",
            map = 1416,
            x = 39.18,
            y = 14.66,
            details = {
                "[LOOT]Ensorcelled Parchment[/] (1)",
            },
        },
        {
            text = "Kill [ENEMY]Argus Shadow Mages[/].",
            quest = 537,
            when = "objectives",
            map = 1416,
            x = 63.4,
            y = 43.8,
            details = {
                "[ENEMY]Argus Shadow Mage[/] (4)",
            },
            note = "Inside buildings.",
        },
        {
            text = "Kill [ENEMY]Syndicate Spies[/], [ENEMY]Syndicate Wizards[/], [ENEMY]Syndicate Sentries[/], [ENEMY]Syndicate Saboteurs[/], [ENEMY]Syndicate Enforcers[/], and [ENEMY]Syndicate Assassins[/].",
            quest = 512,
            when = "objectives",
            map = 1416,
            x = 62.2,
            y = 45.6,
            details = {
                "[LOOT]Alterac Signet Ring[/] (7)",
            },
            note = "Careful, these spies are stealthed.",
        },
        {
            text = "Kill [ENEMY]Crushridge Ogres[/] and [ENEMY]Crushridge Brutes[/].",
            quest = 500,
            when = "objectives",
            map = 1416,
            x = 54.4,
            y = 52.4,
            details = {
                "[LOOT]Dirty Knucklebones[/] (9)",
            },
        },
        {
            text = "Use the [LOOT]Nature Protection Potion[/].",
            quest = 1713,
            when = "objectives",
        },
        {
            classes = { "Warrior" },
            text = "Click the [PICK]Bah'rah's Cauldron[/].",
            quest = 1712,
            when = "objectives",
            map = 1416,
            x = 79.32,
            y = 66.81,
            details = {
                "[LOOT]Essence of the Exile[/] (1)",
            },
        },
        {
            classes = { "Warrior" },
            text = "Talk to [FRIENDLY]Bath'rah the Windwatcher[/]. Turn in [QUEST]Cyclonian[/]. Accept [QUEST]The Summoning[/].",
            quest = 1713,
            when = "accepted",
            map = 1416,
            x = 80.5,
            y = 66.92,
            details = {
                "Turn in [QUEST]Cyclonian[/]",
            },
        },
        {
            classes = { "Warrior" },
            text = "Kill [ENEMY]Cyclonians[/].",
            quest = 1713,
            when = "objectives",
            map = 1416,
            x = 80.6,
            y = 62.52,
            details = {
                "[LOOT]Whirlwind Heart[/] (1)",
            },
            note = "Use another Nature Protection Potion when first one wears off.",
        },
        {
            classes = { "Warrior" },
            text = "Talk to [FRIENDLY]Bath'rah the Windwatcher[/]. Turn in [QUEST]The Summoning[/]. Accept [QUEST]Whirlwind Weapon[/].",
            quest = 1792,
            when = "accepted",
            map = 1416,
            x = 80.5,
            y = 66.92,
            details = {
                "Turn in [QUEST]The Summoning[/]",
            },
        },
        {
            text = "This pass is done. Continue to Dustwallow Marsh.",
            guide = "alliance-dustwallow-40-40",
        },
    },
})
