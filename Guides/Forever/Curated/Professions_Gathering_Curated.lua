local _, ns = ...

-- Curated Forever gathering professions 1-300.
-- Routes from Forever client / ForeverDB skill colours and zone tiers.
-- Press Next when you reach the listed skill. No auto skill tracking yet.

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
            text = "Train |cRB_LOOT_Herbalism|r and learn Find Herbs. Buy an herb pouch if offered.",
            note = "Horde: Mishiki (Durotar), Faruza (Tirisfal), Komin Winterhoof (Thunder Bluff), Jandi (Orgrimmar). Also on Zephras Isle.",
            map = 1454,
            x = 55.4,
            y = 39.7,
        },
        {
            text = "Skill 1-70: pick |cRB_LOOT_Peacebloom|r, |cRB_LOOT_Silverleaf|r, and |cRB_LOOT_Earthroot|r (from 15).",
            note = "Any starting zone. Horde: Durotar, Mulgore, Tirisfal, or Zephras Isle. Train Journeyman at 50 (level 10).",
            details = {
                "Incense Candle (camp) unlocks at Herbalism 20.",
            },
            map = 1411,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 70-115: pick |cRB_LOOT_Mageroyal|r, |cRB_LOOT_Briarthorn|r, and |cRB_LOOT_Stranglekelp|r (85, underwater).",
            note = "Horde: Silverpine Forest or The Barrens. Keep Swiftthistle and Frilled Lichen.",
            map = 1421,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 115-170: pick |cRB_LOOT_Bruiseweed|r, |cRB_LOOT_Wild Steelbloom|r, |cRB_LOOT_Kingsblood|r (125), and |cRB_LOOT_Liferoot|r (150).",
            note = "Horde: Hillsbrad, Stonetalon, or Ashenvale. Train Expert at 125 (level 20).",
            map = 1424,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 170-205: pick |cRB_LOOT_Fadeleaf|r, |cRB_LOOT_Goldthorn|r, |cRB_LOOT_Khadgar's Whisker|r (185), plus leftover Kingsblood and Liferoot.",
            note = "Stranglethorn Vale or Arathi Highlands. Train Artisan at 200 (level 35).",
            map = 1434,
            x = 35.0,
            y = 30.0,
        },
        {
            text = "Skill 205-230: pick |cRB_LOOT_Firebloom|r, |cRB_LOOT_Purple Lotus|r, and |cRB_LOOT_Wintersbite|r (Alterac only).",
            note = "Tanaris, Searing Gorge, Badlands, or Alterac for Wintersbite. Purple Lotus can drop Wildvine.",
            map = 1446,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 230-260: pick |cRB_LOOT_Sungrass|r, |cRB_LOOT_Blindweed|r, |cRB_LOOT_Ghost Mushroom|r (245, caves), and leftover Purple Lotus.",
            note = "Feralas, The Hinterlands, or Swamp of Sorrows for Blindweed. Greenhouse (camp) needs skill 140.",
            map = 1444,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 260-285: pick |cRB_LOOT_Golden Sansam|r, |cRB_LOOT_Dreamfoil|r (270), |cRB_LOOT_Mountain Silversage|r (280), and Sungrass.",
            note = "Un'Goro Crater or Felwood. Felwood also has Gromsblood, Arthas' Tears, and Plaguebloom.",
            map = 1448,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 285-300: pick |cRB_LOOT_Plaguebloom|r, |cRB_LOOT_Icecap|r (290), Dreamfoil, and Mountain Silversage.",
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
            text = "Train |cRB_LOOT_Mining|r, buy a |cRB_LOOT_Mining Pick|r, and learn Find Minerals.",
            note = "Horde: Makaru (Orgrimmar), Brek Stonehoof (Thunder Bluff), Brom Killian (Undercity). Smelt as you go for extra skill.",
            map = 1454,
            x = 73.0,
            y = 26.4,
        },
        {
            text = "Skill 1-65: mine |cRB_LOOT_Copper Vein|r. Smelt Copper at a forge.",
            note = "Horde: Durotar, The Barrens, or Silverpine. Train Journeyman at 50 (level 10).",
            map = 1411,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 65-125: mine |cRB_LOOT_Tin Vein|r and |cRB_LOOT_Silver Vein|r (75). Smelt Tin, Bronze, and Silver.",
            note = "Horde: Hillsbrad, Ashenvale, or Wetlands / Redridge / Loch Modan if you go east. Train Expert at 125 (level 20).",
            map = 1424,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 125-175: mine |cRB_LOOT_Iron Deposit|r and |cRB_LOOT_Gold Vein|r (155). Smelt Iron, Gold, and Steel.",
            note = "Arathi Highlands, Alterac Mountains, or Stranglethorn Vale.",
            map = 1417,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 175-245: mine |cRB_LOOT_Mithril Deposit|r, |cRB_LOOT_Truesilver Deposit|r (230), and |cRB_LOOT_Dark Iron Deposit|r (230).",
            note = "Badlands, Alterac, Arathi, or Searing Gorge. Train Artisan at 200 (level 35).",
            map = 1418,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 245-300: mine |cRB_LOOT_Small Thorium Vein|r and |cRB_LOOT_Rich Thorium Vein|r (275), plus leftover Mithril and Truesilver.",
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
            text = "Train |cRB_LOOT_Skinning|r and buy a |cRB_LOOT_Skinning Knife|r.",
            note = "Horde: Mooranta / Yonn Deepcut (Mulgore), Thuwd (Orgrimmar), Killian Hagey (Undercity). Skin any looted beast, including other players' kills.",
            map = 1454,
            x = 62.0,
            y = 45.0,
        },
        {
            text = "Skill 1-50: skin beasts up to about level 10-15.",
            note = "Horde: Mulgore, Durotar, or Tirisfal while questing. Train Journeyman at 50 (level 10).",
            map = 1412,
            x = 50.0,
            y = 50.0,
        },
        {
            text = "Skill 50-150: skin beasts up to about level 30.",
            note = "The Barrens is ideal. From skill 100, max beast level is roughly skill / 5. Train Expert at 125 (level 20).",
            map = 1413,
            x = 50.0,
            y = 50.0,
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
            text = "Train |cRB_LOOT_Fishing|r. Buy a |cRB_LOOT_Fishing Pole|r and a lure (|cRB_LOOT_Shiny Bauble|r).",
            note = "Horde: Lumak (Orgrimmar), Kah Mistrunner (Thunder Bluff), Armand Cromwell (Undercity). Equip the pole and attach the lure.",
            map = 1454,
            x = 69.8,
            y = 29.6,
        },
        {
            text = "Skill 1-75: fish any starting-zone water.",
            note = "Durotar, Mulgore, Tirisfal, or Zephras Isle. Train Journeyman at 50.",
            map = 1411,
            x = 53.0,
            y = 42.0,
        },
        {
            text = "Skill 75-150: fish mid zones (skill ~55 water).",
            note = "Ashenvale, Hillsbrad, Stonetalon, or Zephras Isle. Use lures if fish get away. Train Expert at 125.",
            map = 1440,
            x = 12.0,
            y = 34.0,
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
