local _, ns = ...

-- Horde Durotar class side guides.
-- Opened from pointer steps in the main Durotar curated route.
-- Finish the chain, then resume the linked main guide.

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
            text = "Talk to [FRIENDLY]Ruzan[/] near the den. Accept [QUEST]Vile Familiars[/].",
            quest = 1485,
            when = "accepted",
            map = 1411,
            x = 42.6,
            y = 69.0,
        },
        {
            text = "Talk to [FRIENDLY]Nartok[/]. Train [SKILL]Immolate[/].",
            map = 1411,
            x = 40.7,
            y = 68.5,
        },
        {
            text = "Travel north to the Burning Blade Coven. Kill [ENEMY]Vile Familiars[/] for their heads.",
            quest = 1485,
            when = "objectives",
            map = 1411,
            x = 45.0,
            y = 57.0,
            details = {
                "[LOOT]Vile Familiar Head[/] (6)",
                "Kill [ENEMY]Vile Familiar[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Ruzan[/]. Turn in [QUEST]Vile Familiars[/]. Accept [QUEST]Vile Familiars[/].",
            quest = 1499,
            when = "accepted",
            map = 1411,
            x = 42.6,
            y = 69.0,
            details = {
                "Turn in [QUEST]Vile Familiars[/]",
            },
        },
        {
            text = "Summon your Imp, then talk to [FRIENDLY]Zureetha Fargaze[/]. Turn in [QUEST]Vile Familiars[/]. Accept [QUEST]Burning Blade Medallion[/].",
            quest = 794,
            when = "accepted",
            map = 1411,
            x = 42.9,
            y = 69.2,
            details = {
                "Turn in [QUEST]Vile Familiars[/]",
            },
        },
        {
            text = "Return to the 1-6 Durotar guide.",
            note = "Resume after the early Valley turn-ins. You already accepted [QUEST]Burning Blade Medallion[/].",
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
            text = "Talk to [FRIENDLY]Canaga Earthcaller[/]. Accept [QUEST]Call of Earth[/].",
            quest = 1516,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 69.2,
        },
        {
            text = "Enter the Burning Blade Coven. Kill [ENEMY]Felstalkers[/] for [LOOT]Felstalker Hooves[/].",
            quest = 1516,
            when = "objectives",
            map = 1411,
            x = 45.3,
            y = 56.0,
            details = {
                "[LOOT]Felstalker Hoof[/] (2)",
                "Kill [ENEMY]Felstalker[/]",
            },
            note = "Clear the cave with [QUEST]Thazz'ril's Pick[/] and [QUEST]Burning Blade Medallion[/] at the same time.",
        },
        {
            text = "Talk to [FRIENDLY]Canaga Earthcaller[/]. Turn in [QUEST]Call of Earth[/]. Accept [QUEST]Call of Earth[/].",
            quest = 1517,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 69.2,
            details = {
                "Turn in [QUEST]Call of Earth[/]",
            },
        },
        {
            text = "Travel to the Spirit Rock west of the den. Use the [LOOT]Earth Sapta[/], then talk to the [FRIENDLY]Minor Manifestation of Earth[/]. Turn in [QUEST]Call of Earth[/]. Accept [QUEST]Call of Earth[/].",
            quest = 1518,
            when = "accepted",
            map = 1411,
            x = 44.0,
            y = 76.2,
            details = {
                "Turn in [QUEST]Call of Earth[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Canaga Earthcaller[/]. Turn in [QUEST]Call of Earth[/].",
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
            text = "Talk to [FRIENDLY]Tai'jin[/] in Razor Hill. Turn in [QUEST]In Favor of Spirituality[/]. Accept [QUEST]Garments of Spirituality[/].",
            quest = 5648,
            when = "accepted",
            map = 1411,
            x = 54.3,
            y = 42.9,
            details = {
                "Turn in [QUEST]In Favor of Spirituality[/]",
            },
        },
        {
            text = "Find [FRIENDLY]Grunt Kor'ja[/] outside Razor Hill. Cast [SKILL]Lesser Heal[/] and [SKILL]Power Word: Fortitude[/] on her.",
            quest = 5648,
            when = "objectives",
            map = 1411,
            x = 53.1,
            y = 46.5,
            details = {
                "Heal and fortify [FRIENDLY]Grunt Kor'ja[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Tai'jin[/]. Turn in [QUEST]Garments of Spirituality[/].",
            quest = 5648,
            when = "complete",
            map = 1411,
            x = 54.3,
            y = 42.9,
        },
        {
            races = { "Troll" },
            text = "[WARN]Optional:[/] Talk to [FRIENDLY]Tai'jin[/]. Accept [QUEST]Hex of Weakness[/].",
            quest = 5654,
            when = "accepted",
            map = 1411,
            x = 54.3,
            y = 42.9,
            note = "Turn this in at [FRIENDLY]Ur'kyo[/] in Orgrimmar later.",
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
            text = "Talk to [FRIENDLY]Thotar[/] inside the Razor Hill bunker. Accept [QUEST]Taming the Beast[/].",
            quest = 6062,
            when = "accepted",
            map = 1411,
            x = 51.9,
            y = 43.5,
        },
        {
            text = "Use the [LOOT]Taming Rod[/] on a [ENEMY]Dire Mottled Boar[/] south of Razor Hill.",
            quest = 6062,
            when = "objectives",
            map = 1411,
            x = 51.5,
            y = 54.0,
            details = {
                "Tame a [ENEMY]Dire Mottled Boar[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Thotar[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Taming the Beast[/].",
            quest = 6083,
            when = "accepted",
            map = 1411,
            x = 51.9,
            y = 43.5,
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "Dismiss your boar. Use the [LOOT]Taming Rod[/] on a [ENEMY]Surf Crawler[/] on the eastern coast.",
            quest = 6083,
            when = "objectives",
            map = 1411,
            x = 59.0,
            y = 29.0,
            details = {
                "Tame a [ENEMY]Surf Crawler[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Thotar[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Taming the Beast[/].",
            quest = 6082,
            when = "accepted",
            map = 1411,
            x = 51.9,
            y = 43.5,
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "Dismiss your crawler. Use the [LOOT]Taming Rod[/] on an [ENEMY]Armored Scorpid[/] north of Razor Hill.",
            quest = 6082,
            when = "objectives",
            map = 1411,
            x = 52.0,
            y = 37.0,
            details = {
                "Tame an [ENEMY]Armored Scorpid[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Thotar[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Training the Beast[/].",
            quest = 6081,
            when = "accepted",
            map = 1411,
            x = 51.9,
            y = 43.5,
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "In Orgrimmar, talk to [FRIENDLY]Ormak Grimshot[/]. Turn in [QUEST]Training the Beast[/].",
            quest = 6081,
            when = "complete",
            map = 1454,
            x = 66.0,
            y = 18.5,
        },
        {
            text = "Return to the 6-10 Durotar guide.",
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
            text = "Talk to [FRIENDLY]Swart[/] in Razor Hill. Accept [QUEST]Call of Fire[/].",
            quest = 2983,
            when = "accepted",
            map = 1411,
            x = 54.4,
            y = 42.6,
        },
        {
            text = "Talk to [FRIENDLY]Takrin Pathseeker[/]. Accept [QUEST]Conscript of the Horde[/].",
            quest = 840,
            when = "accepted",
            map = 1411,
            x = 50.8,
            y = 43.6,
        },
        {
            text = "Travel west to Far Watch Post in The Barrens. Talk to [FRIENDLY]Kargal Battlescar[/]. Turn in [QUEST]Conscript of the Horde[/]. Accept [QUEST]Crossroads Conscription[/].",
            quest = 842,
            when = "accepted",
            map = 1413,
            x = 62.3,
            y = 19.4,
            details = {
                "Turn in [QUEST]Conscript of the Horde[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Kranal Fiss[/]. Turn in [QUEST]Call of Fire[/]. Accept [QUEST]Call of Fire[/].",
            quest = 1524,
            when = "accepted",
            map = 1413,
            x = 56.0,
            y = 19.8,
            details = {
                "Turn in [QUEST]Call of Fire[/]",
            },
        },
        {
            text = "Follow the narrow path up the mountain to [FRIENDLY]Telf Joolam[/]. Turn in [QUEST]Call of Fire[/]. Accept [QUEST]Call of Fire[/].",
            quest = 1525,
            when = "accepted",
            map = 1411,
            x = 38.6,
            y = 58.9,
            note = "[WARN]Stay on the path.[/] Falling can kill you.",
            details = {
                "Turn in [QUEST]Call of Fire[/]",
            },
        },
        {
            text = "Enter Dustwind Cave east of Razor Hill. Kill [ENEMY]Burning Blade Cultists[/] for a [LOOT]Reagent Pouch[/].",
            quest = 1525,
            when = "objectives",
            map = 1411,
            x = 52.8,
            y = 28.7,
            objective = 2,
            details = {
                "[LOOT]Reagent Pouch[/] (1)",
                "Kill [ENEMY]Burning Blade Cultist[/]",
            },
        },
        {
            text = "Return to the 10-12 Durotar guide for Skull Rock and Orgrimmar.",
            note = "Finish [LOOT]Fire Tar[/] from Razormane spellcasters in the Barrens Shaman Call of Fire side guide.",
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
            text = "In Orgrimmar's Cleft of Shadow, talk to [FRIENDLY]Therzok[/]. Accept [QUEST]The Shattered Hand[/].",
            quest = 1963,
            when = "accepted",
            map = 1454,
            x = 42.7,
            y = 53.5,
        },
        {
            text = "Return to the 10-12 Durotar guide.",
            note = "Kill [ENEMY]Tazan[/] in The Barrens for his satchel, then turn in at [FRIENDLY]Therzok[/].",
            guide = "horde-durotar-10-12-curated",
        },
    },
})
