local _, ns = ...

-- Mulgore class side quests. Open these when the main Mulgore guide points
-- to them, finish the chain, then resume the main route.

ns.RegisterGuide({
    id = "horde-mulgore-shaman-earth",
    name = "Mulgore Shaman Call of Earth",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Shaman" },
    minLevel = 3,
    maxLevel = 6,
    steps = {
        {
            text = "After Brambleblade, talk to |cRB_FRIENDLY_Seer Ravenfeather|r. Turn in |cRB_QUEST_Call of Earth|r. Accept |cRB_QUEST_Call of Earth|r. Train if needed at |cRB_FRIENDLY_Meela|r.",
            map = 1412,
            x = 44.7,
            y = 76.2,
            quest = 1520,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Earth|r",
            },
            note = "Accept and Ritual Salves are done in the main 1-6 Mulgore guide.",
        },
        {
            text = "At the Kodo Rock east of camp, use the |cRB_LOOT_Earth Sapta|r. Talk to the |cRB_FRIENDLY_Minor Manifestation of Earth|r. Turn in |cRB_QUEST_Call of Earth|r. Accept |cRB_QUEST_Call of Earth|r.",
            map = 1412,
            x = 53.7,
            y = 80.2,
            quest = 1521,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Earth|r",
                "Use |cRB_LOOT_Earth Sapta|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Seer Ravenfeather|r. Turn in |cRB_QUEST_Call of Earth|r. Train Healing Wave at |cRB_FRIENDLY_Meela|r.",
            map = 1412,
            x = 44.7,
            y = 76.2,
            quest = 1521,
            when = "complete",
        },
        {
            text = "Return to the 1-6 Mulgore guide.",
            guide = "horde-mulgore-1-6-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-mulgore-hunter-taming",
    name = "Mulgore Hunter Taming",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Hunter" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Yaw Sharpmane|r. Accept |cRB_QUEST_Taming the Beast|r. Train your spells.",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6061,
            when = "accepted",
        },
        {
            text = "Use the |cRB_LOOT_Taming Rod|r on an |cRB_ENEMY_Adult Plainstrider|r west of Bloodhoof Village.",
            map = 1412,
            x = 43.0,
            y = 52.0,
            quest = 6061,
            when = "objectives",
            details = {
                "Tame an |cRB_ENEMY_Adult Plainstrider|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Yaw Sharpmane|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Taming the Beast|r.",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6087,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "Dismiss your plainstrider. Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Prairie Stalker|r north of town.",
            map = 1412,
            x = 46.0,
            y = 47.0,
            quest = 6087,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Prairie Stalker|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Yaw Sharpmane|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Taming the Beast|r.",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6088,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "Dismiss your stalker. Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Swoop|r southeast of town.",
            map = 1412,
            x = 52.0,
            y = 64.0,
            quest = 6088,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Swoop|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Yaw Sharpmane|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Training the Beast|r.",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6089,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "In Thunder Bluff, talk to |cRB_FRIENDLY_Holt Thunderhorn|r on Hunter Rise. Turn in |cRB_QUEST_Training the Beast|r.",
            map = 1456,
            x = 57.3,
            y = 89.8,
            quest = 6089,
            when = "complete",
        },
        {
            text = "Return to the 10-12 Mulgore guide.",
            guide = "horde-mulgore-10-12-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-mulgore-druid-moonglade",
    name = "Mulgore Druid Moonglade",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Gennia Runetotem|r in Bloodhoof Village. Accept |cRB_QUEST_Heeding the Call|r.",
            map = 1412,
            x = 48.5,
            y = 59.6,
            quest = 5928,
            when = "accepted",
        },
        {
            text = "In Thunder Bluff, talk to |cRB_FRIENDLY_Turak Runetotem|r on Elder Rise. Turn in |cRB_QUEST_Heeding the Call|r. Accept |cRB_QUEST_Moonglade|r.",
            map = 1456,
            x = 76.5,
            y = 27.2,
            quest = 5922,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Heeding the Call|r",
            },
        },
        {
            text = "Cast Teleport: Moonglade. Talk to |cRB_FRIENDLY_Dendrite Starblaze|r. Turn in |cRB_QUEST_Moonglade|r. Accept |cRB_QUEST_Great Bear Spirit|r.",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 5930,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Moonglade|r",
            },
        },
        {
            text = "Talk to the |cRB_FRIENDLY_Great Bear Spirit|r northwest of Nighthaven, then return to Dendrite. Turn in |cRB_QUEST_Great Bear Spirit|r. Accept |cRB_QUEST_Back to Thunder Bluff|r.",
            map = 1450,
            x = 39.1,
            y = 27.5,
            quest = 5932,
            when = "accepted",
            details = {
                "Speak with the Great Bear Spirit",
                "Turn in |cRB_QUEST_Great Bear Spirit|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Bunthen Plainswind|r for a flight to Thunder Bluff. Talk to |cRB_FRIENDLY_Turak Runetotem|r. Turn in |cRB_QUEST_Back to Thunder Bluff|r. Accept |cRB_QUEST_Body and Heart|r.",
            map = 1456,
            x = 76.5,
            y = 27.2,
            quest = 6002,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Back to Thunder Bluff|r",
            },
        },
        {
            text = "Return to the 10-12 Mulgore guide. Finish |cRB_QUEST_Body and Heart|r at the Moonkin Stone near Camp Taurajo when the main route reaches it.",
            note = "Use |cRB_LOOT_Cenarion Lunardust|r at the stone, kill Lunaclaw, then turn in at Turak.",
            guide = "horde-mulgore-10-12-curated",
        },
    },
})
