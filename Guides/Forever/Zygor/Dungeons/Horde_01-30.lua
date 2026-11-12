local _, ns = ...

-- Converted from Guides/REFERENCE/Dungeons/ZygorDungeonHordeCLASSIC.lua
-- Zygor Classic dungeon guides. Confirm/click-here gates removed.

ns.RegisterGuide({
    id = "zygor-horde-dungeon-hall-of-thanes-15-25",
    name = "Hall of Thanes (15-25)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 15,
    maxLevel = 25,
    steps = {
        {
            text = "Enter the Hall of Thanes Dungeon with Your Group.",
            map = 1455,
            x = 27.98,
            y = 47.78,
        },
        {
            text = "Inside the Hall of Thanes Dungeon. Kill Faldrim Anvilmar. Slay Faldrim Anvilmar.",
            quest = 96395,
        },
        {
            text = "Inside the Hall of Thanes Dungeon. Kill Magmatus. Kill Dark Iron Summoner.",
        },
        {
            text = "Inside the Hall of Thanes Dungeon. Kill Plunder.",
        },
        {
            text = "Inside the Hall of Thanes Dungeon. Kill Dark Iron Looter. Kill Lesser Stone Golem. Kill Durgen Dirgehammer.",
            note = "The tank will be taking additional damage from Rend",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-ragefire-chasm-13-18",
    name = "Ragefire Chasm (13-18)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 13,
    maxLevel = 18,
    steps = {
        {
            text = "Enter the Ragefire Chasm Dungeon with Your Group.",
        },
        {
            text = "Kill Oggleflint.",
        },
        {
            text = "Kill Taragaman the Hungerer.",
        },
        {
            text = "Kill Jergosh the Invoker.",
        },
        {
            text = "Kill Bazzalan.",
            note = "CC the second Searing Blade Cultist and then focus on kill Bazzalan",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-wailing-caverns-15-25",
    name = "Wailing Caverns (15-25)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 15,
    maxLevel = 25,
    steps = {
        {
            text = "Enter the Wailing Caverns Dungeon with Your Group.",
        },
        {
            text = "Kill Kresh.",
        },
        {
            text = "Kill Lady Anacondra.",
        },
        {
            text = "Kill Lord Cobrahn.",
        },
        {
            text = "Kill Deviate Faerie Dragon.",
        },
        {
            text = "Kill Lord Pythas.",
        },
        {
            text = "Kill Skum.",
        },
        {
            text = "Kill Lord Serpentis.",
        },
        {
            text = "Kill Verdan the Everliving.",
        },
        {
            text = "Kill Mutanus the Devourer.",
            note = "He also has two abilities, \"Terrify\" and \"Naralex's Nightmare\" that both stun/sleep players so the healer should try to keep the group's health topped off as much as possible",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-ruins-of-lordaeron-15-20",
    name = "Ruins of Lordaeron (15-20)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 15,
    maxLevel = 20,
    steps = {
        {
            text = "Enter the Ruins of Lordaeron Dungeon with Your Group.",
            note = "Then down, (South)",
        },
        {
            text = "Kill Witherfang.",
        },
        {
            text = "Kill The Baron.",
        },
        {
            text = "Kill The Abandoned.",
        },
        {
            text = "Kill Viktor the Vile.",
        },
        {
            text = "Kill Bjork.",
        },
        {
            text = "Kill Rath'mael.",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-the-deadmines-17-26",
    name = "The Deadmines (17-26)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 17,
    maxLevel = 26,
    steps = {
        {
            text = "Enter the building. Jump down here. Follow the path. Enter the Deadmines Dungeon with Your Group.",
        },
        {
            text = "Kill Rhahk'Zor.",
        },
        {
            text = "Kill Miner Johnson.",
        },
        {
            text = "Kill Sneed's Shredder.",
        },
        {
            text = "Kill Gilnid.",
        },
        {
            text = "Kill Mr. Smite.",
        },
        {
            text = "Kill Captain Greenskin.",
        },
        {
            text = "Kill Edwin VanCleef.",
        },
        {
            text = "Kill Cookie.",
            note = "Interrupt \"Cookie's Cooking\" spell or it heals him",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-shadowfang-keep-22-30",
    name = "Shadowfang Keep (22-30)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 22,
    maxLevel = 30,
    steps = {
        {
            text = "Enter the Shadowfang Keep Dungeon with Your Group.",
        },
        {
            text = "Kill Rethilgore.",
        },
        {
            text = "Kill Shadow Charger.",
        },
        {
            text = "Kill Razorclaw the Butcher.",
        },
        {
            text = "Kill Baron Silverlaine.",
        },
        {
            text = "Kill Commander Springvale.",
        },
        {
            text = "Kill Odo the Blindwatcher.",
        },
        {
            text = "Kill Deathsworn Captain.",
        },
        {
            text = "Kill Fenrus the Devourer.",
        },
        {
            text = "Kill Wolf Master Nados.",
        },
        {
            text = "Kill Archmage Arugal.",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-excavation-site-24-29",
    name = "Excavation Site (24-29)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 24,
    maxLevel = 29,
    steps = {
        {
            text = "Follow the path. Enter the Excavation Site Dungeon with Your Group.",
            map = 1437,
            x = 48.22,
            y = 56.49,
        },
        {
            text = "Inside the Excavation Site Wetlands Dungeon. Kill Saltspine.",
        },
        {
            text = "Inside the Excavation Site Wetlands Dungeon. Kill Shardtooth.",
        },
        {
            text = "Inside the Excavation Site Wetlands Dungeon. Click Archival Panel. Kill Relic Guardian.",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-blackfathom-deeps-24-32",
    name = "Blackfathom Deeps (24-32)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 24,
    maxLevel = 32,
    steps = {
        {
            text = "Jump into the water. Swim underwater into the cave. Follow the path. Enter the Blackfathom Deeps Dungeon with Your Group.",
        },
        {
            text = "Kill Ghamoo-ra.",
        },
        {
            text = "Kill Lady Sarevess.",
        },
        {
            text = "Kill Gelihast.",
        },
        {
            text = "Kill Twilight Lord Kelris.",
        },
        {
            text = "Kill Old Serra'kis.",
        },
        {
            text = "Kill Aku'mai.",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-gnomeregan-29-38",
    name = "Gnomeregan (29-38)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 29,
    maxLevel = 38,
    steps = {
        {
            text = "Enter the building. Ride the elevator down. Follow the path. Enter the Gnomeregan Dungeon with Your Group.",
        },
        {
            text = "Kill Grubbis.",
        },
        {
            text = "Kill Viscous Fallout.",
        },
        {
            text = "Kill Electrocutioner 6000.",
        },
        {
            text = "Kill Crowd Pummeler 9-60.",
        },
        {
            text = "Kill Dark Iron Ambassador.",
        },
        {
            text = "Kill Mekgineer Thermaplugg.",
        },
    },
})

ns.RegisterGuide({
    id = "zygor-horde-dungeon-scarlet-monastery-graveyard-29-35",
    name = "Scarlet Monastery (Graveyard) (29-35)",
    group = "Zygor Dungeons Horde",
    faction = "Horde",
    minLevel = 29,
    maxLevel = 35,
    steps = {
        {
            text = "Enter the building. Enter the Portal. Enter the Scarlet Monastery - Graveyard Dungeon with Your Group.",
        },
        {
            text = "Kill Interrogator Vishas.",
        },
        {
            text = "Kill Bloodmage Thalnos.",
        },
        {
            text = "Kill Azshir the Sleepless.",
        },
        {
            text = "Kill Fallen Champion.",
        },
        {
            text = "Kill Ironspine.",
        },
    },
})
