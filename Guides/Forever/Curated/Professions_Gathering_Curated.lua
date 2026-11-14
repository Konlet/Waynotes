local _, ns = ...

-- Curated Forever gathering professions 1-300.
-- Routes from Forever client / ForeverDB skill colours and zone tiers.
-- Press Next when you reach the listed skill. No auto skill tracking yet.
-- Trainer/zone tips use Horde: / Alliance: labels (filtered to your faction).

ns.RegisterGuide({
    id = "profession-herbalism-1-300",
    name = "Herbalism 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            faction = "Horde",
            text = "Train [LOOT]Herbalism[/] and learn Find Herbs. Buy an herb pouch if offered.",
            note = "Horde: Mishiki (Durotar), Faruza (Tirisfal), Komin Winterhoof (Thunder Bluff), Jandi (Orgrimmar). Also on Zephras Isle.",
            map = 1454,
            x = 55.4,
            y = 39.7,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Herbalism[/] and learn Find Herbs. Buy an herb pouch if offered.",
            note = "Alliance: Herbalist Pomeroy (Elwynn), Malorne Bladeleaf (Teldrassil), Reyna Stonebranch (Ironforge). Also on Zephras Isle.",
            map = 1453,
            x = 55.6,
            y = 85.0,
        },
        {
            text = "Skill 1-70: pick [LOOT]Peacebloom[/], [LOOT]Silverleaf[/], and [LOOT]Earthroot[/] (from 15).",
            note = "Any starting zone. Horde: Durotar, Mulgore, Tirisfal, or Zephras Isle. Alliance: Elwynn, Dun Morogh, Teldrassil, or Zephras Isle. Train Journeyman at 50 (level 10).",
            details = {
                "Incense Candle (camp) unlocks at Herbalism 20.",
            },
        },
        {
            text = "Skill 70-115: pick [LOOT]Mageroyal[/], [LOOT]Briarthorn[/], and [LOOT]Stranglekelp[/] (85, underwater).",
            note = "Horde: Silverpine Forest or The Barrens. Alliance: Westfall, Loch Modan, or Darkshore. Keep Swiftthistle and Frilled Lichen.",
        },
        {
            text = "Skill 115-170: pick [LOOT]Bruiseweed[/], [LOOT]Wild Steelbloom[/], [LOOT]Kingsblood[/] (125), and [LOOT]Liferoot[/] (150).",
            note = "Horde: Hillsbrad, Stonetalon, or Ashenvale. Alliance: Wetlands, Redridge, Ashenvale, or Hillsbrad. Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 170-205: pick [LOOT]Fadeleaf[/], [LOOT]Goldthorn[/], [LOOT]Khadgar's Whisker[/] (185), plus leftover Kingsblood and Liferoot.",
            note = "Stranglethorn Vale or Arathi Highlands. Train Artisan at 200 (level 35).",
            map = 1434,
            x = 35.0,
            y = 30.0,
        },
        {
            text = "Skill 205-230: pick [LOOT]Firebloom[/], [LOOT]Purple Lotus[/], and [LOOT]Wintersbite[/] (Alterac only).",
            note = "Tanaris, Searing Gorge, Badlands, or Alterac for Wintersbite. Purple Lotus can drop Wildvine.",
            map = 1446,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 230-260: pick [LOOT]Sungrass[/], [LOOT]Blindweed[/], [LOOT]Ghost Mushroom[/] (245, caves), and leftover Purple Lotus.",
            note = "Feralas, The Hinterlands, or Swamp of Sorrows for Blindweed. Greenhouse (camp) needs skill 140.",
            map = 1444,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 260-285: pick [LOOT]Golden Sansam[/], [LOOT]Dreamfoil[/] (270), [LOOT]Mountain Silversage[/] (280), and Sungrass.",
            note = "Un'Goro Crater or Felwood. Felwood also has Gromsblood, Arthas' Tears, and Plaguebloom.",
            map = 1448,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 285-300: pick [LOOT]Plaguebloom[/], [LOOT]Icecap[/] (290), Dreamfoil, and Mountain Silversage.",
            note = "Felwood, Eastern/Western Plaguelands, or Winterspring for Icecap. Black Lotus at 300 in Burning Steppes, EPL, Silithus, Winterspring.",
            details = {
                "Seed Hybridizer (camp) unlocks at Herbalism 300.",
            },
            map = 1448,
            x = 50.0,
            y = 40.0,
        },
    },
})

ns.RegisterGuide({
    id = "profession-mining-1-300",
    name = "Mining 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            faction = "Horde",
            text = "Train [LOOT]Mining[/], buy a [LOOT]Mining Pick[/], and learn Find Minerals.",
            note = "Horde: Makaru (Orgrimmar), Brek Stonehoof (Thunder Bluff), Brom Killian (Undercity). Smelt as you go for extra skill.",
            map = 1454,
            x = 73.0,
            y = 26.4,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Mining[/], buy a [LOOT]Mining Pick[/], and learn Find Minerals.",
            note = "Alliance: Brock Stoneseeker (Loch Modan), Dank Drizzlecut (Dun Morogh), Geofram Bouldertoe (Ironforge). Smelt as you go for extra skill.",
            map = 1455,
            x = 50.0,
            y = 26.0,
        },
        {
            text = "Skill 1-65: mine [LOOT]Copper Vein[/]. Smelt Copper at a forge.",
            note = "Horde: Durotar, The Barrens, or Silverpine. Alliance: Elwynn, Dun Morogh, or Westfall. Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 65-125: mine [LOOT]Tin Vein[/] and [LOOT]Silver Vein[/] (75). Smelt Tin, Bronze, and Silver.",
            note = "Horde: Hillsbrad, Ashenvale, or Wetlands / Redridge / Loch Modan if you go east. Alliance: Wetlands, Redridge, Loch Modan, or Darkshore. Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 125-175: mine [LOOT]Iron Deposit[/] and [LOOT]Gold Vein[/] (155). Smelt Iron, Gold, and Steel.",
            note = "Arathi Highlands, Alterac Mountains, or Stranglethorn Vale.",
            map = 1417,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 175-245: mine [LOOT]Mithril Deposit[/], [LOOT]Truesilver Deposit[/] (230), and [LOOT]Dark Iron Deposit[/] (230).",
            note = "Badlands, Alterac, Arathi, or Searing Gorge. Train Artisan at 200 (level 35).",
            map = 1418,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 245-300: mine [LOOT]Small Thorium Vein[/] and [LOOT]Rich Thorium Vein[/] (275), plus leftover Mithril and Truesilver.",
            note = "Un'Goro Crater, Winterspring, Burning Steppes, or Searing Gorge. Smelt Thorium at a forge.",
            details = {
                "Forever also adds Lodestone, Rock Garden, Molten Foundry, and late Azerothium / Heavy Thorium smelts.",
            },
            map = 1449,
            x = 50.0,
            y = 50.0,
        },
    },
})

ns.RegisterGuide({
    id = "profession-skinning-1-300",
    name = "Skinning 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            faction = "Horde",
            text = "Train [LOOT]Skinning[/] and buy a [LOOT]Skinning Knife[/].",
            note = "Horde: Mooranta / Yonn Deepcut (Mulgore), Thuwd (Orgrimmar), Killian Hagey (Undercity). Skin any looted beast, including other players' kills.",
            map = 1454,
            x = 62.0,
            y = 45.0,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Skinning[/] and buy a [LOOT]Skinning Knife[/].",
            note = "Alliance: Helene Peltskinner (Elwynn), Maris Granger (Stormwind), Eladriel (Darnassus). Skin any looted beast, including other players' kills.",
            map = 1453,
            x = 71.6,
            y = 62.2,
        },
        {
            text = "Skill 1-50: skin beasts up to about level 10-15.",
            note = "Horde: Mulgore, Durotar, or Tirisfal while questing. Alliance: Elwynn, Dun Morogh, or Teldrassil while questing. Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 50-150: skin beasts up to about level 30.",
            note = "Horde: The Barrens is ideal. Alliance: Westfall, Loch Modan, Darkshore, or Wetlands. From skill 100, max beast level is roughly skill / 5. Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 150-180: skin beasts up to about level 36.",
            note = "Ashenvale, Stonetalon, or northern Barrens leftovers.",
            map = 1440,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 180-205: skin beasts up to about level 41.",
            note = "Desolace, Thousand Needles, or Ashenvale elites / higher camps.",
            map = 1443,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 205-235: skin beasts up to about level 47. Train Artisan at 200 (level 35).",
            note = "Dustwallow Marsh, Desolace, or Stranglethorn Vale.",
            map = 1445,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 235-300: skin beasts up to level 60.",
            note = "Tanaris, Feralas, Un'Goro, Winterspring, or Plaguelands. Pairs with Leatherworking.",
            details = {
                "Forever camp crafts: Camp Chair, Field Guide, Trapper's Workbench.",
            },
            map = 1446,
            x = 50.0,
            y = 50.0,
        },
    },
})

ns.RegisterGuide({
    id = "profession-fishing-1-300",
    name = "Fishing 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            faction = "Horde",
            text = "Train [LOOT]Fishing[/]. Buy a [LOOT]Fishing Pole[/] and a lure ([LOOT]Shiny Bauble[/]).",
            note = "Horde: Lumak (Orgrimmar), Kah Mistrunner (Thunder Bluff), Armand Cromwell (Undercity). Equip the pole and attach the lure.",
            map = 1454,
            x = 69.8,
            y = 29.6,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Fishing[/]. Buy a [LOOT]Fishing Pole[/] and a lure ([LOOT]Shiny Bauble[/]).",
            note = "Alliance: Lee Brown (Elwynn), Arnold Leland (Stormwind), Grimnur Stonebrand (Ironforge). Equip the pole and attach the lure.",
            map = 1453,
            x = 54.9,
            y = 69.6,
        },
        {
            text = "Skill 1-75: fish any starting-zone water.",
            note = "Horde: Durotar, Mulgore, Tirisfal, or Zephras Isle. Alliance: Elwynn, Dun Morogh, Teldrassil, or Zephras Isle. Train Journeyman at 50.",
        },
        {
            text = "Skill 75-150: fish mid zones (skill ~55 water).",
            note = "Ashenvale, Hillsbrad, Stonetalon, Darkshore, Wetlands, or Zephras Isle. Use lures if fish get away. Train Expert at 125.",
        },
        {
            text = "Skill 150-225: fish higher inland / coastal water (skill ~130).",
            note = "Desolace, Dustwallow, Stranglethorn, Alterac, Arathi, or Swamp of Sorrows. Train Artisan at 200.",
            map = 1445,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 225-300: fish endgame water (skill ~205).",
            note = "Azshara, Felwood, Feralas, Moonglade, Tanaris, or The Hinterlands. Cast into pools when you see them.",
            details = {
                "Keep Oily Blackmouth, Firefin Snapper, and Stonescale Eel for Alchemy oils.",
                "Forever camp crafts: Fish Bowl, Fishing Rack, Fishing Hut.",
            },
            map = 1447,
            x = 50.0,
            y = 50.0,
        },
    },
})
