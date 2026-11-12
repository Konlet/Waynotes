local _, ns = ...

-- Durotar class side quests. Open these when the curated main guide points
-- to them, finish the chain, then resume the main route.

ns.RegisterGuide({
    id = "horde-durotar-warlock-familiars",
    name = "Durotar Warlock Familiars",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    classes = { "Warlock" },
    minLevel = 1,
    maxLevel = 4,
    steps = {
        {
            text = "Talk to Ruzan near the den. Accept Vile Familiars.",
            quest = 1485,
            when = "accepted",
            map = 1411,
            x = 42.6,
            y = 69.0,
        },
        {
            text = "Talk to Nartok and train Immolate if you have not already.",
            map = 1411,
            x = 40.7,
            y = 68.5,
        },
        {
            text = "Travel north to the Burning Blade Coven. Kill Vile Familiars for their heads. Finish Mottled Boars for Cutting Teeth on the way back if needed.",
            quest = 1485,
            when = "objectives",
            details = {
                "Vile Familiar Head (6)",
                "Kill Vile Familiar",
            },
        },
        {
            text = "Talk to Ruzan. Turn in Vile Familiars. Accept Vile Familiars.",
            quest = 1499,
            when = "accepted",
            map = 1411,
            x = 42.6,
            y = 69.0,
            details = {
                "Turn in Vile Familiars",
            },
        },
        {
            text = "Summon your Imp, then talk to Zureetha Fargaze. Turn in Vile Familiars. Accept Burning Blade Medallion.",
            quest = 794,
            when = "accepted",
            map = 1411,
            x = 42.9,
            y = 69.2,
            details = {
                "Turn in Vile Familiars",
            },
        },
        {
            text = "Return to the curated 1-6 Durotar guide. You already have Burning Blade Medallion.",
            note = "Resume after Cutting Teeth / Sarkoth turn-ins as needed.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-shaman-earth",
    name = "Durotar Shaman Call of Earth",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    classes = { "Shaman" },
    minLevel = 4,
    maxLevel = 6,
    steps = {
        {
            text = "Talk to Canaga Earthcaller. Accept Call of Earth.",
            quest = 1516,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 69.2,
        },
        {
            text = "Enter the Burning Blade Coven with Thazz'ril's Pick and the medallion quest. Kill Felstalkers for Felstalker Hooves while you clear the cave.",
            quest = 1516,
            when = "objectives",
            details = {
                "Felstalker Hoof (2)",
                "Kill Felstalker",
            },
        },
        {
            text = "Talk to Canaga. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1517,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 69.2,
            details = {
                "Turn in Call of Earth",
            },
        },
        {
            text = "Travel to the Spirit Rock west of the den. Use the Earth Sapta, then talk to the Minor Manifestation of Earth. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1518,
            when = "accepted",
            details = {
                "Turn in Call of Earth",
                "Use Earth Sapta",
            },
        },
        {
            text = "Talk to Canaga. Turn in Call of Earth.",
            quest = 1518,
            when = "complete",
            map = 1411,
            x = 42.4,
            y = 69.2,
        },
        {
            text = "Return to the curated 1-6 Durotar guide and finish leaving the Valley of Trials.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-priest-spirituality",
    name = "Durotar Priest Spirituality",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    classes = { "Priest" },
    minLevel = 5,
    maxLevel = 10,
    steps = {
        {
            text = "Talk to Tai'jin in Razor Hill. Turn in In Favor of Spirituality. Accept Garments of Spirituality.",
            quest = 5648,
            when = "accepted",
            map = 1411,
            x = 54.3,
            y = 42.9,
            details = {
                "Turn in In Favor of Spirituality",
                "NPC: Tai'jin",
            },
        },
        {
            text = "Find Grunt Kor'ja outside Razor Hill. Cast Lesser Heal and Power Word: Fortitude on her.",
            quest = 5648,
            when = "objectives",
            details = {
                "Heal and fortify Grunt Kor'ja",
            },
        },
        {
            text = "Talk to Tai'jin. Turn in Garments of Spirituality. Train your spells.",
            quest = 5648,
            when = "complete",
            map = 1411,
            x = 54.3,
            y = 42.9,
        },
        {
            races = { "Troll" },
            text = "Talk to Tai'jin. Accept Hex of Weakness when you are level 10.",
            quest = 5654,
            when = "accepted",
            note = "Turn this in at Ur'kyo in Orgrimmar later.",
        },
        {
            text = "Return to the curated 6-10 Durotar guide.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-hunter-taming",
    name = "Durotar Hunter Taming",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    classes = { "Hunter" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to Thotar inside the Razor Hill bunker. Accept Taming the Beast. Train your spells.",
            quest = 6062,
            when = "accepted",
            map = 1411,
            x = 51.9,
            y = 43.5,
        },
        {
            text = "Use the Taming Rod on a Dire Mottled Boar south of Razor Hill.",
            quest = 6062,
            when = "objectives",
            details = {
                "Tame a Dire Mottled Boar",
            },
        },
        {
            text = "Talk to Thotar. Turn in Taming the Beast. Accept Taming the Beast.",
            quest = 6083,
            when = "accepted",
            details = {
                "Turn in Taming the Beast",
            },
        },
        {
            text = "Dismiss your boar. Use the Taming Rod on a Surf Crawler on the eastern coast.",
            quest = 6083,
            when = "objectives",
            details = {
                "Tame a Surf Crawler",
            },
        },
        {
            text = "Talk to Thotar. Turn in Taming the Beast. Accept Taming the Beast.",
            quest = 6082,
            when = "accepted",
            details = {
                "Turn in Taming the Beast",
            },
        },
        {
            text = "Dismiss your crawler. Use the Taming Rod on an Armored Scorpid north of Razor Hill.",
            quest = 6082,
            when = "objectives",
            details = {
                "Tame an Armored Scorpid",
            },
        },
        {
            text = "Talk to Thotar. Turn in Taming the Beast. Accept Training the Beast.",
            quest = 6081,
            when = "accepted",
            details = {
                "Turn in Taming the Beast",
            },
        },
        {
            text = "In Orgrimmar, talk to Ormak Grimshot. Turn in Training the Beast.",
            quest = 6081,
            when = "complete",
            map = 1454,
            x = 66.0,
            y = 18.5,
        },
        {
            text = "Return to the curated Durotar guide.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-shaman-fire",
    name = "Durotar Shaman Call of Fire",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    classes = { "Shaman" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to Swart in Razor Hill. Accept Call of Fire. Train your spells.",
            quest = 2983,
            when = "accepted",
            map = 1411,
            x = 54.4,
            y = 42.6,
        },
        {
            text = "Talk to Takrin Pathseeker if you still need Conscript of the Horde.",
            quest = 840,
            when = "accepted",
        },
        {
            text = "Travel west to Far Watch Post in The Barrens. Talk to Kargal. Turn in Conscript of the Horde. Accept Crossroads Conscription.",
            quest = 842,
            when = "accepted",
            details = {
                "Turn in Conscript of the Horde",
                "NPC: Kargal Battlescar",
            },
        },
        {
            text = "Talk to Kranal Fiss. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1524,
            when = "accepted",
            details = {
                "Turn in Call of Fire",
                "NPC: Kranal Fiss",
            },
        },
        {
            text = "Follow the narrow path up the mountain to Telf Joolam. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1525,
            when = "accepted",
            note = "Stay on the path. Falling can kill you.",
            details = {
                "Turn in Call of Fire",
                "NPC: Telf Joolam",
            },
        },
        {
            text = "Enter Dustwind Cave east of Razor Hill. Kill Burning Blade Cultists for a Reagent Pouch.",
            quest = 1525,
            when = "objectives",
            details = {
                "Reagent Pouch (1)",
                "Kill Burning Blade Cultist",
            },
        },
        {
            text = "You still need Fire Tar later in The Barrens. Return to the curated 10-12 Durotar guide for Skull Rock and Orgrimmar, then finish Call of Fire with the Barrens guide.",
            note = "Fire Tar comes from Razormane spellcasters in The Barrens.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-rogue-shattered-hand",
    name = "Durotar Rogue Shattered Hand",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    classes = { "Rogue" },
    minLevel = 10,
    maxLevel = 16,
    steps = {
        {
            text = "In Orgrimmar's Cleft of Shadow, talk to Therzok. Accept The Shattered Hand.",
            quest = 1963,
            when = "accepted",
            map = 1454,
            x = 42.7,
            y = 53.5,
        },
        {
            text = "This chain continues in The Barrens. Kill Tazan later for his satchel, then return to Therzok.",
            note = "Resume the curated Durotar guide, then finish this from the Barrens.",
        },
    },
})
