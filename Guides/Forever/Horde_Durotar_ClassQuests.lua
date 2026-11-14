local _, ns = ...

-- Durotar class side quests. Open these when the main Durotar guide points
-- to them, finish the chain, then resume the main route.

ns.RegisterGuide({
    id = "horde-durotar-warlock-familiars",
    name = "Durotar Warlock Familiars",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll" },
    classes = { "Warlock" },
    minLevel = 1,
    maxLevel = 4,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Ruzan|r near the den. Accept |cRB_QUEST_Vile Familiars|r.",
            quest = 1485,
            when = "accepted",
            map = 1411,
            x = 42.6,
            y = 69.0,
        },
        {
            text = "Talk to |cRB_FRIENDLY_Nartok|r and train Immolate if you have not already.",
            map = 1411,
            x = 40.7,
            y = 68.5,
        },
        {
            text = "Travel north to the Burning Blade Coven. Kill |cRB_ENEMY_Vile Familiars|r for their heads. Finish |cRB_ENEMY_Mottled Boars|r for |cRB_QUEST_Cutting Teeth|r on the way back if needed.",
            quest = 1485,
            when = "objectives",
            details = {
                "|cRB_ENEMY_Vile Familiar|r Head (6)",
                "Kill |cRB_ENEMY_Vile Familiar|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Ruzan|r. Turn in |cRB_QUEST_Vile Familiars|r. Accept |cRB_QUEST_Vile Familiars|r.",
            quest = 1499,
            when = "accepted",
            map = 1411,
            x = 42.6,
            y = 69.0,
            details = {
                "Turn in |cRB_QUEST_Vile Familiars|r",
            },
        },
        {
            text = "Summon your Imp, then talk to |cRB_FRIENDLY_Zureetha Fargaze|r. Turn in |cRB_QUEST_Vile Familiars|r. Accept |cRB_QUEST_Burning Blade Medallion|r.",
            quest = 794,
            when = "accepted",
            map = 1411,
            x = 42.9,
            y = 69.2,
            details = {
                "Turn in |cRB_QUEST_Vile Familiars|r",
            },
        },
        {
            text = "Return to the 1-6 Durotar guide. You already have |cRB_LOOT_Burning Blade Medallion|r.",
            note = "Resume after |cRB_QUEST_Cutting Teeth|r / |cRB_QUEST_Sarkoth|r turn-ins as needed.",
            guide = "horde-durotar-1-6-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-shaman-earth",
    name = "Durotar Shaman Call of Earth",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll" },
    classes = { "Shaman" },
    minLevel = 4,
    maxLevel = 6,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Canaga Earthcaller|r. Accept |cRB_QUEST_Call of Earth|r.",
            quest = 1516,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 69.2,
        },
        {
            text = "Enter the Burning Blade Coven with |cRB_LOOT_Thazz'ril's Pick|r and the medallion quest. Kill |cRB_ENEMY_Felstalkers|r for |cRB_LOOT_Felstalker Hooves|r while you clear the cave.",
            quest = 1516,
            when = "objectives",
            details = {
                "|cRB_LOOT_Felstalker Hoof|r (2)",
                "Kill |cRB_ENEMY_Felstalker|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Canaga|r. Turn in |cRB_QUEST_Call of Earth|r. Accept |cRB_QUEST_Call of Earth|r.",
            quest = 1517,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 69.2,
            details = {
                "Turn in |cRB_QUEST_Call of Earth|r",
            },
        },
        {
            text = "Travel to the Spirit Rock west of the den. Use the |cRB_LOOT_Earth Sapta|r, then talk to the |cRB_FRIENDLY_Minor Manifestation of Earth|r. Turn in |cRB_QUEST_Call of Earth|r. Accept |cRB_QUEST_Call of Earth|r.",
            quest = 1518,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Earth|r",
                "Use |cRB_LOOT_Earth Sapta|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Canaga|r. Turn in |cRB_QUEST_Call of Earth|r.",
            quest = 1518,
            when = "complete",
            map = 1411,
            x = 42.4,
            y = 69.2,
        },
        {
            text = "Return to the 1-6 Durotar guide and finish leaving the Valley of Trials.",
            guide = "horde-durotar-1-6-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-priest-spirituality",
    name = "Durotar Priest Spirituality",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll" },
    classes = { "Priest" },
    minLevel = 5,
    maxLevel = 10,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Tai'jin|r in Razor Hill. Turn in |cRB_QUEST_In Favor of Spirituality|r. Accept |cRB_QUEST_Garments of Spirituality|r.",
            quest = 5648,
            when = "accepted",
            map = 1411,
            x = 54.3,
            y = 42.9,
            details = {
                "Turn in |cRB_QUEST_In Favor of Spirituality|r",
                "NPC: |cRB_FRIENDLY_Tai'jin|r",
            },
        },
        {
            text = "Find |cRB_FRIENDLY_Grunt Kor'ja|r outside Razor Hill. Cast Lesser Heal and Power Word: Fortitude on her.",
            quest = 5648,
            when = "objectives",
            details = {
                "Heal and fortify |cRB_FRIENDLY_Grunt Kor'ja|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Tai'jin|r. Turn in |cRB_QUEST_Garments of Spirituality|r. Train your spells.",
            quest = 5648,
            when = "complete",
            map = 1411,
            x = 54.3,
            y = 42.9,
        },
        {
            races = { "Troll" },
            text = "Optional at level 10: talk to |cRB_FRIENDLY_Tai'jin|r. Accept |cRB_QUEST_Hex of Weakness|r.",
            note = "Turn this in at |cRB_FRIENDLY_Ur'kyo|r in Orgrimmar later. Skip for now if you are not level 10.",
        },
        {
            text = "Return to the 6-10 Durotar guide.",
            guide = "horde-durotar-6-10-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-hunter-taming",
    name = "Durotar Hunter Taming",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll" },
    classes = { "Hunter" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Thotar|r inside the Razor Hill bunker. Accept |cRB_QUEST_Taming the Beast|r. Train your spells.",
            quest = 6062,
            when = "accepted",
            map = 1411,
            x = 51.9,
            y = 43.5,
        },
        {
            text = "Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Dire Mottled Boar|r south of Razor Hill.",
            quest = 6062,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Dire Mottled Boar|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Thotar|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Taming the Beast|r.",
            quest = 6083,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "Dismiss your boar. Use the |cRB_LOOT_Taming Rod|r on a |cRB_ENEMY_Surf Crawler|r on the eastern coast.",
            quest = 6083,
            when = "objectives",
            details = {
                "Tame a |cRB_ENEMY_Surf Crawler|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Thotar|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Taming the Beast|r.",
            quest = 6082,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "Dismiss your crawler. Use the |cRB_LOOT_Taming Rod|r on an |cRB_ENEMY_Armored Scorpid|r north of Razor Hill.",
            quest = 6082,
            when = "objectives",
            details = {
                "Tame an |cRB_ENEMY_Armored Scorpid|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Thotar|r. Turn in |cRB_QUEST_Taming the Beast|r. Accept |cRB_QUEST_Training the Beast|r.",
            quest = 6081,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Taming the Beast|r",
            },
        },
        {
            text = "In Orgrimmar, talk to |cRB_FRIENDLY_Ormak Grimshot|r. Turn in |cRB_QUEST_Training the Beast|r.",
            quest = 6081,
            when = "complete",
            map = 1454,
            x = 66.0,
            y = 18.5,
        },
        {
            text = "Return to the Durotar guide.",
            guide = "horde-durotar-6-10-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-shaman-fire",
    name = "Durotar Shaman Call of Fire",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll" },
    classes = { "Shaman" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to |cRB_FRIENDLY_Swart|r in Razor Hill. Accept |cRB_QUEST_Call of Fire|r. Train your spells.",
            quest = 2983,
            when = "accepted",
            map = 1411,
            x = 54.4,
            y = 42.6,
        },
        {
            text = "Talk to |cRB_FRIENDLY_Takrin Pathseeker|r if you still need Conscript of the Horde.",
            quest = 840,
            when = "accepted",
        },
        {
            text = "Travel west to Far Watch Post in The Barrens. Talk to |cRB_FRIENDLY_Kargal|r. Turn in |cRB_QUEST_Conscript of the Horde|r. Accept |cRB_QUEST_Crossroads Conscription|r.",
            quest = 842,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Conscript of the Horde|r",
                "NPC: |cRB_FRIENDLY_Kargal Battlescar|r",
            },
        },
        {
            text = "Talk to |cRB_FRIENDLY_Kranal Fiss|r. Turn in |cRB_QUEST_Call of Fire|r. Accept |cRB_QUEST_Call of Fire|r.",
            quest = 1524,
            when = "accepted",
            details = {
                "Turn in |cRB_QUEST_Call of Fire|r",
                "NPC: |cRB_FRIENDLY_Kranal Fiss|r",
            },
        },
        {
            text = "Follow the narrow path up the mountain to |cRB_FRIENDLY_Telf Joolam|r. Turn in |cRB_QUEST_Call of Fire|r. Accept |cRB_QUEST_Call of Fire|r.",
            quest = 1525,
            when = "accepted",
            note = "|cRB_WARN_Stay on the path. Falling can kill you.|r",
            details = {
                "Turn in |cRB_QUEST_Call of Fire|r",
                "NPC: |cRB_FRIENDLY_Telf Joolam|r",
            },
        },
        {
            text = "Enter Dustwind Cave east of Razor Hill. Kill |cRB_ENEMY_Burning Blade Cultists|r for a |cRB_LOOT_Reagent Pouch|r.",
            quest = 1525,
            when = "objectives",
            details = {
                "|cRB_LOOT_Reagent Pouch|r (1)",
                "Kill |cRB_ENEMY_Burning Blade Cultist|r",
            },
        },
        {
            text = "You still need |cRB_LOOT_Fire Tar|r later in The Barrens. Return to the 10-12 Durotar guide for Skull Rock and Orgrimmar, then open Barrens Shaman Call of Fire when you reach Kranal again.",
            note = "|cRB_LOOT_Fire Tar|r comes from Razormane spellcasters. Continue with guide Barrens Shaman Call of Fire.",
            guide = "horde-durotar-10-12-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-rogue-shattered-hand",
    name = "Durotar Rogue Shattered Hand",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Orc", "Troll" },
    classes = { "Rogue" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "In Orgrimmar's Cleft of Shadow, talk to |cRB_FRIENDLY_Therzok|r. Accept |cRB_QUEST_The Shattered Hand|r.",
            quest = 1963,
            when = "accepted",
            map = 1454,
            x = 42.7,
            y = 53.5,
        },
        {
            text = "This chain continues in The Barrens. Kill |cRB_ENEMY_Tazan|r later for his satchel, then return to |cRB_FRIENDLY_Therzok|r.",
            note = "Resume the Durotar guide, then finish this from the Barrens.",
            guide = "horde-durotar-10-12-curated",
        },
    },
})
