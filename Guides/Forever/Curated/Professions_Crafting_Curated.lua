local _, ns = ...

-- Curated Forever crafting professions 1-300.
-- Cheap ForeverDB client routes (skill colours from the Forever client).
-- Craft counts are estimates; yellow/green crafts can miss a point. Press Next at the listed skill.
-- Trainer/vendor locations use Classic data until Forever-confirmed.

ns.RegisterGuide({
    id = "profession-alchemy-1-300",
    name = "Alchemy 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Train |cRB_LOOT_Alchemy|r. Pair with Herbalism. Buy Empty Vials from a trade vendor.",
            note = "Horde: Yelmak (Orgrimmar), Bena Winterhoof (Thunder Bluff), Doctor Herbert Halsey (Undercity).",
            details = {
                "Forever camp: Mana Well (20), Fermenter (140), Alchemy Laboratory (300).",
            },
            map = 1454,
            x = 56.6,
            y = 34.1,
        },
        {
            text = "Skill 1-13: craft |cRB_LOOT_Minor Arcane Elixir|r (~13). 1 Peacebloom, 1 Empty Vial each.",
            note = "New in Forever. Learned automatically.",
        },
        {
            text = "Skill 13-50: craft |cRB_LOOT_Elixir of Minor Defense|r (~37). 1 Silverleaf, 1 Peacebloom, 1 Empty Vial each.",
            note = "Train Journeyman Alchemy at 50 (level 10).",
        },
        {
            text = "Skill 50-80: craft |cRB_LOOT_Minor Discolored Healing Potion|r (~43). 1 Peacebloom, 1 Murloc Eye, 1 Empty Vial each.",
            note = "Recipe from the Wild Eyes, Wild Hearts quest reward.",
        },
        {
            text = "Skill 80-92: craft |cRB_LOOT_Blackmouth Oil|r (~18). 2 Oily Blackmouth, 1 Empty Vial each.",
            note = "Learn from an Alchemy trainer.",
        },
        {
            text = "Skill 92-100: craft |cRB_LOOT_Rage Potion|r (~9). 1 Sharp Claw, 1 Briarthorn, 1 Empty Vial each.",
            note = "Recipe sold by Ranik in The Barrens (Ratchet).",
            map = 1413,
            x = 62.7,
            y = 36.3,
        },
        {
            text = "Skill 100-148: craft |cRB_LOOT_Swim Speed Potion|r (~54). 1 Swiftthistle, 1 Blackmouth Oil, 1 Empty Vial each.",
            note = "Train Expert Alchemy at 125 (level 20). Blackmouth Oil needs more Oily Blackmouth.",
        },
        {
            text = "Skill 148-165: craft |cRB_LOOT_Fire Oil|r (~28). 2 Firefin Snapper, 1 Empty Vial each.",
            note = "Learn from an Alchemy trainer.",
        },
        {
            text = "Skill 165-250: craft |cRB_LOOT_Fire Protection Potion|r (~216). 1 Small Flame Sac, 1 Fire Oil, 1 Leaded Vial each.",
            note = "Recipe sold by Nandar Branson (Hillsbrad). Train Artisan at 200 (level 35).",
            map = 1424,
            x = 50.9,
            y = 57.1,
        },
        {
            text = "Skill 250-260: craft |cRB_LOOT_Stonescale Oil|r (~29). 1 Stonescale Eel, 1 Leaded Vial each.",
            note = "Learn from an Artisan Alchemy trainer (for example Kylanna Windwhisper in Feralas).",
        },
        {
            text = "Skill 260-265: craft |cRB_LOOT_Draught of Detect Undead|r (~9). 1 Arthas' Tears, 1 Crystal Vial each.",
            note = "Learn from an Artisan Alchemy trainer.",
        },
        {
            text = "Skill 265-300: craft |cRB_LOOT_Elixir of Greater Defense|r (~42). 2 Stonescale Oil, 1 Sungrass, 1 Crystal Vial each.",
            note = "Recipe sold by Soolie Berryfizz (Ironforge) / check Horde recipe vendors if listed. Finish Stonescale Oil as needed.",
        },
    },
})

ns.RegisterGuide({
    id = "profession-blacksmithing-1-300",
    name = "Blacksmithing 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Train |cRB_LOOT_Blacksmithing|r at a forge. Pair with Mining.",
            note = "Horde: Saru Steelfury (Orgrimmar), Karn Stonehoof (Thunder Bluff), Basil Frye (Undercity).",
            map = 1454,
            x = 82.0,
            y = 23.0,
        },
        {
            text = "Skill 1-25: craft |cRB_LOOT_Rough Sharpening Stone|r (~25). 1 Rough Stone each.",
        },
        {
            text = "Skill 25-81: craft |cRB_LOOT_Rough Grinding Stone|r (~108). 2 Rough Stone each.",
            note = "Train Journeyman at 50 (level 10). Save grinding stones for later recipes.",
        },
        {
            text = "Skill 81-87: craft |cRB_LOOT_Silver Skeleton Key|r (~11). 1 Silver Bar, 1 Rough Grinding Stone each.",
        },
        {
            text = "Skill 87-100: craft |cRB_LOOT_Runed Copper Belt|r (~16). 10 Copper Bar each.",
        },
        {
            text = "Skill 100-113: craft |cRB_LOOT_Heavy Sharpening Stone|r (~27). 1 Heavy Stone each.",
        },
        {
            text = "Skill 113-132: craft |cRB_LOOT_Rough Bronze Leggings|r (~22). 6 Bronze Bar each.",
        },
        {
            text = "Skill 132-144: craft |cRB_LOOT_Silvered Bronze Boots|r (~13). 6 Bronze Bar, 1 Silver Bar, 2 Coarse Grinding Stone each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 144-175: craft |cRB_LOOT_Bronze Warhammer|r (~43). 8 Bronze Bar, 1 Strong Flux, 1 Medium Leather each.",
        },
        {
            text = "Skill 175-185: craft |cRB_LOOT_Solid Sharpening Stone|r (~29). 1 Solid Stone each.",
        },
        {
            text = "Skill 185-200: craft |cRB_LOOT_Golden Scale Bracers|r (~22). 5 Steel Bar, 2 Heavy Grinding Stone each.",
        },
        {
            text = "Skill 200-210: craft |cRB_LOOT_Heavy Mithril Gauntlet|r (~13). 6 Mithril Bar, 4 Mageweave Cloth each.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 210-243: craft |cRB_LOOT_Mithril Spurs|r (~40). 4 Mithril Bar, 3 Solid Grinding Stone each.",
            note = "Recipe is a world drop. Farm or buy the plans.",
        },
        {
            text = "Skill 243-250: craft |cRB_LOOT_Runed Mithril Hammer|r (~7). 18 Mithril Bar, 2 Core of Earth, 1 Solid Grinding Stone, 4 Thick Leather each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 250-258: craft |cRB_LOOT_Arcanite Skeleton Key|r (~14). 1 Arcanite Bar, 1 Dense Grinding Stone each.",
            note = "Artisan trainer teaches this (Brikk Keencraft in STV).",
        },
        {
            text = "Skill 258-281: craft |cRB_LOOT_Thorium Shield Spike|r (~27). 4 Thorium Bar, 4 Dense Grinding Stone, 2 Essence of Earth each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 281-291: craft |cRB_LOOT_Radiant Boots|r (~11). 14 Thorium Bar, 4 Heart of Fire each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 291-300: craft |cRB_LOOT_Radiant Leggings|r (~9). 20 Thorium Bar, 4 Heart of Fire each.",
            note = "Recipe is a world drop.",
        },
    },
})

ns.RegisterGuide({
    id = "profession-enchanting-1-300",
    name = "Enchanting 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Train |cRB_LOOT_Enchanting|r. Disenchant greens for mats. Pair with Tailoring.",
            note = "Horde: Godan (Orgrimmar), Teg Dawnstrider (Thunder Bluff), Lavinia Crowe (Undercity). Forever starts with Mote of Magic on Inferior Stamina.",
            map = 1454,
            x = 53.4,
            y = 38.2,
        },
        {
            text = "Horde 1-23: craft |cRB_LOOT_Enchant Bracer - Inferior Stamina|r (~23). 1 Mote of Magic each.",
            note = "Alliance stays on Inferior Stamina a bit longer (to ~25), then Minor Deflect / Minor Absorption.",
        },
        {
            text = "Horde 23-90: craft |cRB_LOOT_Enchant Chest - Inferior Stamina|r (~74). 1 Strange Dust each.",
            note = "Train Journeyman at 50 (level 10). Alliance: Enchant Chest - Minor Absorption with Lesser Magic Essence.",
        },
        {
            text = "Horde 90-128: craft |cRB_LOOT_Enchant Cloak - Minor Protection|r (~44). 2 Strange Dust each.",
            note = "Alliance often uses Enchant Cloak - Minor Agility (Lesser Astral Essence from Dalria in Ashenvale).",
        },
        {
            text = "Horde 128-164: craft |cRB_LOOT_Enchant Boots - Minor Stamina|r (~39). 4 Strange Dust each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 164-210: craft |cRB_LOOT_Enchant Boots - Lesser Agility|r (~70). 1 Soul Dust each.",
            note = "Horde trainer Hgarth (Stonetalon). Shared with Alliance from here.",
            map = 1442,
            x = 49.2,
            y = 57.2,
        },
        {
            text = "Skill 210-264: craft |cRB_LOOT_Enchant Gloves - Agility|r (~93). 1 Vision Dust each.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 264-285: craft |cRB_LOOT_Enchant Gloves - Minor Haste|r (~25). 1 Large Radiant Shard, 1 Wildvine each.",
            note = "Taught by Annora (Uldaman).",
        },
        {
            text = "Skill 285-300: craft |cRB_LOOT_Enchant Shield - Greater Stamina|r (~19). 6 Dream Dust each.",
            note = "Horde recipe sold by Daniel Bartlett (Undercity). Alliance: Mythrin'dir (Darnassus).",
            map = 1458,
            x = 64.0,
            y = 38.0,
        },
    },
})

ns.RegisterGuide({
    id = "profession-engineering-1-300",
    name = "Engineering 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Train |cRB_LOOT_Engineering|r at an anvil. Pair with Mining.",
            note = "Horde: Roxxik (Orgrimmar), Tinkerwiz (Ratchet), Graham Van Talen (Undercity).",
            map = 1454,
            x = 76.0,
            y = 25.0,
        },
        {
            text = "Skill 1-33: craft |cRB_LOOT_Rough Blasting Powder|r (~39). 1 Rough Stone each.",
        },
        {
            text = "Skill 33-54: craft |cRB_LOOT_Handful of Copper Bolts|r (~25). 1 Copper Bar each.",
        },
        {
            text = "Skill 54-75: craft |cRB_LOOT_Copper Tube|r (~21). 2 Copper Bar, 1 Weak Flux each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 75-91: craft |cRB_LOOT_Coarse Blasting Powder|r (~18). 1 Coarse Stone each.",
        },
        {
            text = "Skill 91-125: craft |cRB_LOOT_Silver Contact|r (~39). 1 Silver Bar each.",
        },
        {
            text = "Skill 125-138: craft |cRB_LOOT_Heavy Blasting Powder|r (~20). 1 Heavy Stone each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 138-145: craft |cRB_LOOT_Whirring Bronze Gizmo|r (~10). 2 Bronze Bar, 1 Wool Cloth each.",
        },
        {
            text = "Skill 145-150: craft |cRB_LOOT_Bronze Framework|r (~5). 2 Bronze Bar, 1 Medium Leather, 1 Wool Cloth each.",
        },
        {
            text = "Skill 150-158: craft |cRB_LOOT_Aquadynamic Fish Attractor|r (~10). 2 Bronze Bar, 1 Nightcrawlers, 1 Coarse Blasting Powder each.",
        },
        {
            text = "Skill 158-175: craft more |cRB_LOOT_Bronze Framework|r (~30).",
        },
        {
            text = "Skill 175-185: craft |cRB_LOOT_Solid Blasting Powder|r (~13). 2 Solid Stone each.",
        },
        {
            text = "Skill 185-216: craft |cRB_LOOT_Flash Bomb|r (~58). 1 Blue Pearl, 1 Heavy Blasting Powder, 1 Silk Cloth each.",
            note = "Recipe from the Flash Bomb Recipe quest. Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 216-245: craft |cRB_LOOT_Hi-Impact Mithril Slugs|r (~73). 1 Mithril Bar, 1 Solid Blasting Powder each.",
        },
        {
            text = "Skill 245-250: craft |cRB_LOOT_Mithril Gyro-Shot|r (~5). 2 Mithril Bar, 2 Solid Blasting Powder each.",
            note = "Buzzek Bracketswing in Gadgetzan teaches late Engineering.",
            map = 1446,
            x = 52.3,
            y = 27.7,
        },
        {
            text = "Skill 250-258: craft |cRB_LOOT_Dense Blasting Powder|r (~14). 2 Dense Stone each.",
        },
        {
            text = "Skill 258-276: craft more |cRB_LOOT_Mithril Gyro-Shot|r (~42).",
        },
        {
            text = "Skill 276-285: craft |cRB_LOOT_Thorium Widget|r (~10). 3 Thorium Bar, 1 Runecloth each.",
        },
        {
            text = "Skill 285-300: craft |cRB_LOOT_Delicate Arcanite Converter|r (~15). 1 Arcanite Bar, 1 Ironweb Spider Silk each.",
            note = "Recipe sold by Xizzer Fizzbolt (Winterspring).",
            map = 1452,
            x = 60.9,
            y = 38.6,
        },
    },
})

ns.RegisterGuide({
    id = "profession-leatherworking-1-300",
    name = "Leatherworking 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Train |cRB_LOOT_Leatherworking|r. Pair with Skinning.",
            note = "Horde: Karolek (Orgrimmar), Una (Thunder Bluff), Arthur Moore (Undercity).",
            map = 1454,
            x = 62.8,
            y = 44.5,
        },
        {
            text = "Skill 1-48: craft |cRB_LOOT_Light Armor Kit|r (~56). 1 Light Leather each.",
        },
        {
            text = "Skill 48-55: craft |cRB_LOOT_Cured Light Hide|r (~8). 1 Light Hide, 1 Salt each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 55-84: craft |cRB_LOOT_Embossed Leather Gloves|r (~33). 3 Light Leather, 2 Coarse Thread each.",
        },
        {
            text = "Skill 84-103: craft |cRB_LOOT_Fine Leather Belt|r (~28). 6 Light Leather, 2 Coarse Thread each.",
            note = "Save belts if you will craft Dark Leather Belt later.",
        },
        {
            text = "Skill 103-120: craft |cRB_LOOT_Light Leather Pants|r (~29). 10 Light Leather, 1 Cured Light Hide, 1 Fine Thread each.",
        },
        {
            text = "Skill 120-125: craft |cRB_LOOT_Nimble Leather Gloves|r (~5). 1 Elixir of Minor Agility, 6 Medium Leather, 1 Fine Thread each.",
        },
        {
            text = "Skill 125-135: craft |cRB_LOOT_Dark Leather Belt|r (~12). 1 Fine Leather Belt, 1 Cured Medium Hide, 2 Fine Thread, 1 Gray Dye each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 135-145: craft |cRB_LOOT_Cured Heavy Hide|r (~29). 1 Heavy Hide, 3 Salt each.",
        },
        {
            text = "Skill 145-150: craft |cRB_LOOT_Heavy Armor Kit|r (~6). 5 Heavy Leather, 1 Fine Thread each.",
        },
        {
            text = "Skill 150-160: craft |cRB_LOOT_Mystic Heavy Armor Kit|r (~11). 1 Heavy Armor Kit, 2 Soul Dust, 2 Lesser Mana Potion each.",
            note = "New Forever recipe. Alliance vendor Saenorion (Darnassus); check Horde leather vendors / AH for the pattern.",
        },
        {
            text = "Skill 160-170: craft |cRB_LOOT_Raptor Hide Belt|r (~13). 4 Raptor Hide, 4 Heavy Leather, 2 Fine Thread each.",
            note = "Horde alternative around here: Barbaric Leggings from Keena (Arathi). Alliance uses Barbaric Shoulders next.",
        },
        {
            text = "Skill 170-185: craft |cRB_LOOT_Barbaric Shoulders|r then |cRB_LOOT_Green Leather Bracers|r to about 185.",
            note = "Trainer recipes. Skip Barbaric Shoulders if you used the Horde Barbaric Leggings path.",
        },
        {
            text = "Skill 185-200: craft |cRB_LOOT_Guardian Gloves|r (~13) then |cRB_LOOT_Thick Armor Kit|r (~6).",
        },
        {
            text = "Skill 200-212: craft |cRB_LOOT_Nightscape Headband|r (~18). 5 Thick Leather, 2 Silken Thread each.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 212-225: craft Wild Leather Shoulders then Wild Leather Helmet (quest recipes).",
            note = "Pratt McGrubben (A) / Jangdor Swiftstrider (H) Wild Leather chain in Feralas.",
            map = 1444,
            x = 74.5,
            y = 42.9,
        },
        {
            text = "Skill 225-236: craft |cRB_LOOT_Cured Rugged Hide|r (~8) then |cRB_LOOT_Rugged Armor Kit|r (~8).",
        },
        {
            text = "Skill 236-258: craft |cRB_LOOT_Wicked Leather Gauntlets|r (~22). 8 Rugged Leather, 1 Black Dye, 1 Rune Thread each.",
            note = "Recipe sold by Leonard Porter (Western Plaguelands).",
        },
        {
            text = "Skill 258-278: craft |cRB_LOOT_Frostsaber Boots|r (~22). 4 Rugged Leather, 6 Frostsaber Leather, 1 Rune Thread each.",
            note = "Recipe sold by Qia (Winterspring).",
            map = 1452,
            x = 61.3,
            y = 37.1,
        },
        {
            text = "Skill 278-300: craft |cRB_LOOT_Wicked Leather Belt|r (~23). 14 Rugged Leather, 2 Black Dye, 2 Rune Thread each.",
            note = "Recipe is a world drop.",
        },
    },
})

ns.RegisterGuide({
    id = "profession-tailoring-1-300",
    name = "Tailoring 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Train |cRB_LOOT_Tailoring|r. Farm cloth from humanoids. Pair with Enchanting.",
            note = "Horde: Magar (Orgrimmar), Tepa (Thunder Bluff), Josef Gregorian (Undercity).",
            map = 1454,
            x = 63.0,
            y = 49.7,
        },
        {
            text = "Skill 1-27: craft |cRB_LOOT_Bolt of Linen Cloth|r (~26). 2 Linen Cloth each.",
        },
        {
            text = "Skill 27-73: craft |cRB_LOOT_Linen Belt|r (~60). 1 Bolt of Linen Cloth, 1 Coarse Thread each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 73-81: craft |cRB_LOOT_Reinforced Linen Cape|r (~15). 2 Bolt of Linen Cloth, 3 Coarse Thread each.",
        },
        {
            text = "Skill 81-110: craft |cRB_LOOT_Woolen Cape|r (~64). 1 Bolt of Woolen Cloth, 1 Fine Thread each.",
            note = "Make Wool bolts as needed (3 Wool Cloth each).",
        },
        {
            text = "Skill 110-140: craft |cRB_LOOT_Stylish Red Shirt|r (~65). 3 Bolt of Woolen Cloth, 2 Red Dye, 1 Fine Thread each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 140-170: craft |cRB_LOOT_Azure Silk Cloak|r (~32). 3 Bolt of Silk Cloth, 2 Blue Dye, 2 Fine Thread each.",
            note = "Recipe sold by Brienna Starglow (Feralas).",
        },
        {
            text = "Skill 170-185: craft |cRB_LOOT_Crimson Silk Vest|r then |cRB_LOOT_Crimson Silk Pantaloons|r.",
        },
        {
            text = "Skill 185-205: craft |cRB_LOOT_Orange Mageweave Shirt|r, |cRB_LOOT_Black Mageweave Leggings|r, then |cRB_LOOT_Black Mageweave Gloves|r.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 205-218: craft |cRB_LOOT_Black Mageweave Shoulders|r (~17). 3 Bolt of Mageweave, 2 Heavy Silken Thread each.",
        },
        {
            text = "Skill 218-225: craft |cRB_LOOT_Admiral's Hat|r (~9). 3 Bolt of Mageweave, 6 Long Elegant Feather, 2 Heavy Silken Thread each.",
            note = "Recipe sold by Cowardly Crosby (Stranglethorn).",
            map = 1434,
            x = 27.0,
            y = 82.5,
        },
        {
            text = "Skill 225-236: craft |cRB_LOOT_Runecloth Belt|r (~13). 3 Bolt of Runecloth, 1 Rune Thread each.",
        },
        {
            text = "Skill 236-251: craft |cRB_LOOT_Runecloth Gloves|r (~16). 4 Bolt of Runecloth, 4 Rugged Leather, 1 Rune Thread each.",
            note = "Recipe sold by Qia (Winterspring).",
            map = 1452,
            x = 61.3,
            y = 37.1,
        },
        {
            text = "Skill 251-281: craft |cRB_LOOT_Runecloth Headband|r (~36). 4 Bolt of Runecloth, 2 Ironweb Spider Silk, 1 Rune Thread each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 281-300: craft |cRB_LOOT_Mooncloth Shoulders|r (~21). 5 Bolt of Runecloth, 5 Mooncloth, 1 Rune Thread each.",
            note = "Recipe is a world drop. Mooncloth is crafted from Felcloth at a moonwell.",
        },
    },
})
