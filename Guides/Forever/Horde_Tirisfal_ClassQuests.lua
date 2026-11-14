local _, ns = ...

-- Tirisfal class side quests. Open these when the main Tirisfal guide points
-- to them, finish the chain, then resume the main route.

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
            text = "Enter Undercity. Talk to |cRB_FRIENDLY_Carendin Halgar|r in the Magic Quarter. Turn in |cRB_QUEST_Halgar's Summons|r. Accept |cRB_QUEST_Creature of the Void|r.",
            map = 1458,
            x = 85.0,
            y = 26.0,
            quest = 1473,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Halgar's Summons|r",
            },
            note = "Accept Halgar's Summons and loot Egalin's Grimoire in the main Tirisfal guide first.",
        },
        {
            text = "If you still need |cRB_LOOT_Egalin's Grimoire|r, loot |cRB_PICK_Perrine's Chest|r upstairs in Captain Perrine's tower west of Brill.",
            map = 1420,
            x = 51.1,
            y = 67.6,
            quest = 1473,
            when = "objectives",
            details = {
                "|cRB_LOOT_Egalin's Grimoire|r (1)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Carendin Halgar|r. Turn in |cRB_QUEST_Creature of the Void|r. Accept |cRB_QUEST_The Binding|r.",
            map = 1458,
            x = 85.0,
            y = 26.0,
            quest = 1471,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Creature of the Void|r",
            },
        },
        {
            text = "Use the |cRB_LOOT_Runes of Summoning|r in the summoning circle. Kill the |cRB_ENEMY_Summoned Voidwalker|r.",
            map = 1458,
            x = 86.6,
            y = 27.1,
            quest = 1471,
            when = "objectives",
            details = {
                "Kill the Summoned Voidwalker",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Carendin Halgar|r. Turn in |cRB_QUEST_The Binding|r.",
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
            text = "In Brill, talk to |cRB_FRIENDLY_Shari Stilwell|r. Accept |cRB_QUEST_A Second Home|r if offered, then travel west to Bandarion Keep.",
            map = 1420,
            x = 60.2,
            y = 52.7,
            quest = 91282,
            when = "accepted",
            note = "Skip accepts you already finished.",
        },
        {
            text = "Talk to |cRB_FRIENDLY_Breton Samuels|r. Turn in |cRB_QUEST_A Second Home|r. Accept |cRB_QUEST_Murlocs at the Gates|r.",
            map = 1420,
            x = 21.9,
            y = 45.2,
            quest = 91285,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_A Second Home|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Danitha Morr|r. Accept |cRB_QUEST_A Lesson in Divinity|r if offered.",
            map = 1420,
            x = 22.1,
            y = 44.7,
            quest = 94427,
            when = "accepted",
        },
        {
            text = "Kill |cRB_ENEMY_Vile Fin Attackers|r and Seers on the western shore for |cRB_QUEST_Murlocs at the Gates|r while clearing the Bandarion crypt with the main guide.",
            map = 1420,
            x = 14.7,
            y = 54.8,
            quest = 91285,
            when = "objectives",
            details = {
                "|cRB_ENEMY_Vile Fin Attacker|r (8)",
                "|cRB_ENEMY_Vile Fin Seer|r (8)",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Breton Samuels|r. Turn in |cRB_QUEST_Murlocs at the Gates|r. Accept |cRB_QUEST_Touring the Grounds|r and speak with Jorin, Hilda, Ander, and Danitha.",
            map = 1420,
            x = 21.9,
            y = 45.2,
            quest = 91294,
            when = "objectives",
            details = {
                "Turn in |cRB_QUEST_Murlocs at the Gates|r",
                "Speak with the Bandarion NPCs",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Danitha Morr|r. Turn in |cRB_QUEST_Touring the Grounds|r. Accept |cRB_QUEST_The Tarnished|r. Talk to |cRB_FRIENDLY_Jorin Croge|r for |cRB_QUEST_Making Repairs|r.",
            map = 1420,
            x = 22.1,
            y = 44.7,
            quests = { 91317, 91316 },
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Touring the Grounds|r",
            },
        },
        {
            text = "In the crypt, loot |cRB_PICK_Lumber Piles|r. Outside, kill |cRB_ENEMY_Rudolph Gelhardt|r and Tarnished zealots and drudges.",
            map = 1420,
            x = 11.5,
            y = 64.2,
            quests = { 91316, 91317 },
            when = "objectives",
            details = {
                "|cRB_LOOT_Sturdy Lumber|r (12)",
                "|cRB_LOOT_Rudolph Gelhardt's Head|r (1)",
                "|cRB_ENEMY_Tarnished Zealot|r (6)",
                "|cRB_ENEMY_Tarnished Drudge|r (8)",
            },
        },
        {
            text = "Turn in Making Repairs and The Tarnished. Accept |cRB_QUEST_A Token of Good Faith|r.",
            map = 1420,
            x = 22.1,
            y = 44.7,
            quest = 95803,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Making Repairs|r",
                "Turn in |cRB_QUEST_The Tarnished|r",
            },
        },
        {
            text = "In Undercity, talk to |cRB_FRIENDLY_Tanis Alderwood|r for Divinity turn-ins, then |cRB_FRIENDLY_Lady Sylvanas Windrunner|r for |cRB_QUEST_A Token of Good Faith|r.",
            map = 1458,
            x = 58.1,
            y = 91.8,
            quest = 95803,
            when = "complete",
            note = "Skip steps you are not on.",
        },
        {
            text = "Return to the 10-13 Tirisfal guide.",
            guide = "horde-tirisfal-10-13-curated",
        },
    },
})
