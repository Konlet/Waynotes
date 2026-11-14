local _, ns = ...

-- Curated Forever crafting professions 1-300.
-- Cheap ForeverDB client routes (skill colours from the Forever client).
-- Craft counts are estimates; yellow/green crafts can miss a point. Advance when you reach the listed skill.
-- Trainer/vendor locations use Classic data until Forever-confirmed.
-- Trainer/zone tips use Horde: / Alliance: labels (filtered to your faction).

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
            faction = "Horde",
            text = "Train [LOOT]Alchemy[/]. Pair with Herbalism. Buy Empty Vials from a trade vendor.",
            note = "Horde: Yelmak (Orgrimmar), Bena Winterhoof (Thunder Bluff), Doctor Herbert Halsey (Undercity).",
            details = {
                "Forever camp: Mana Well (20), Fermenter (140), Alchemy Laboratory (300).",
            },
            map = 1454,
            x = 56.6,
            y = 34.1,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Alchemy[/]. Pair with Herbalism. Buy Empty Vials from a trade vendor.",
            note = "Alliance: Alchemist Mallory (Elwynn), Ainethil (Darnassus), Lilyssia Nightbreeze (Stormwind).",
            details = {
                "Forever camp: Mana Well (20), Fermenter (140), Alchemy Laboratory (300).",
            },
            map = 1453,
            x = 46.4,
            y = 79.6,
        },
        {
            text = "Skill 1-13: craft [LOOT]Minor Arcane Elixir[/] (~13). 1 Peacebloom, 1 Empty Vial each.",
            note = "New in Forever. Learned automatically.",
        },
        {
            text = "Skill 13-50: craft [LOOT]Elixir of Minor Defense[/] (~37). 1 Silverleaf, 1 Peacebloom, 1 Empty Vial each.",
            note = "Train Journeyman Alchemy at 50 (level 10).",
        },
        {
            text = "Skill 50-80: craft [LOOT]Minor Discolored Healing Potion[/] (~43). 1 Peacebloom, 1 Murloc Eye, 1 Empty Vial each.",
            note = "Recipe from the Wild Eyes, Wild Hearts quest reward.",
        },
        {
            text = "Skill 80-92: craft [LOOT]Blackmouth Oil[/] (~18). 2 Oily Blackmouth, 1 Empty Vial each.",
            note = "Learn from an Alchemy trainer.",
        },
        {
            text = "Skill 92-100: craft [LOOT]Rage Potion[/] (~9). 1 Sharp Claw, 1 Briarthorn, 1 Empty Vial each.",
            note = "Recipe sold by Ranik in The Barrens (Ratchet).",
            map = 1413,
            x = 62.7,
            y = 36.3,
        },
        {
            text = "Skill 100-148: craft [LOOT]Swim Speed Potion[/] (~54). 1 Swiftthistle, 1 Blackmouth Oil, 1 Empty Vial each.",
            note = "Train Expert Alchemy at 125 (level 20). Blackmouth Oil needs more Oily Blackmouth.",
        },
        {
            text = "Skill 148-165: craft [LOOT]Fire Oil[/] (~28). 2 Firefin Snapper, 1 Empty Vial each.",
            note = "Learn from an Alchemy trainer.",
        },
        {
            text = "Skill 165-250: craft [LOOT]Fire Protection Potion[/] (~216). 1 Small Flame Sac, 1 Fire Oil, 1 Leaded Vial each.",
            note = "Recipe sold by Nandar Branson (Hillsbrad). Train Artisan at 200 (level 35).",
            map = 1424,
            x = 50.9,
            y = 57.1,
        },
        {
            text = "Skill 250-260: craft [LOOT]Stonescale Oil[/] (~29). 1 Stonescale Eel, 1 Leaded Vial each.",
            note = "Learn from an Artisan Alchemy trainer (for example Kylanna Windwhisper in Feralas).",
        },
        {
            text = "Skill 260-265: craft [LOOT]Draught of Detect Undead[/] (~9). 1 Arthas' Tears, 1 Crystal Vial each.",
            note = "Learn from an Artisan Alchemy trainer.",
        },
        {
            text = "Skill 265-300: craft [LOOT]Elixir of Greater Defense[/] (~42). 2 Stonescale Oil, 1 Sungrass, 1 Crystal Vial each.",
            note = "Alliance: recipe sold by Soolie Berryfizz (Ironforge). Horde: check recipe vendors if listed. Finish Stonescale Oil as needed.",
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
            faction = "Horde",
            text = "Train [LOOT]Blacksmithing[/] at a forge. Pair with Mining.",
            note = "Horde: Saru Steelfury (Orgrimmar), Karn Stonehoof (Thunder Bluff), Basil Frye (Undercity).",
            map = 1454,
            x = 82.0,
            y = 23.0,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Blacksmithing[/] at a forge. Pair with Mining.",
            note = "Alliance: Smith Argus (Elwynn), Therum Deepforge (Stormwind), Bengus Deepforge (Ironforge).",
            map = 1453,
            x = 63.2,
            y = 36.8,
        },
        {
            text = "Skill 1-25: craft [LOOT]Rough Sharpening Stone[/] (~25). 1 Rough Stone each.",
        },
        {
            text = "Skill 25-81: craft [LOOT]Rough Grinding Stone[/] (~108). 2 Rough Stone each.",
            note = "Train Journeyman at 50 (level 10). Save grinding stones for later recipes.",
        },
        {
            text = "Skill 81-87: craft [LOOT]Silver Skeleton Key[/] (~11). 1 Silver Bar, 1 Rough Grinding Stone each.",
        },
        {
            text = "Skill 87-100: craft [LOOT]Runed Copper Belt[/] (~16). 10 Copper Bar each.",
        },
        {
            text = "Skill 100-113: craft [LOOT]Heavy Sharpening Stone[/] (~27). 1 Heavy Stone each.",
        },
        {
            text = "Skill 113-132: craft [LOOT]Rough Bronze Leggings[/] (~22). 6 Bronze Bar each.",
        },
        {
            text = "Skill 132-144: craft [LOOT]Silvered Bronze Boots[/] (~13). 6 Bronze Bar, 1 Silver Bar, 2 Coarse Grinding Stone each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 144-175: craft [LOOT]Bronze Warhammer[/] (~43). 8 Bronze Bar, 1 Strong Flux, 1 Medium Leather each.",
        },
        {
            text = "Skill 175-185: craft [LOOT]Solid Sharpening Stone[/] (~29). 1 Solid Stone each.",
        },
        {
            text = "Skill 185-200: craft [LOOT]Golden Scale Bracers[/] (~22). 5 Steel Bar, 2 Heavy Grinding Stone each.",
        },
        {
            text = "Skill 200-210: craft [LOOT]Heavy Mithril Gauntlet[/] (~13). 6 Mithril Bar, 4 Mageweave Cloth each.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 210-243: craft [LOOT]Mithril Spurs[/] (~40). 4 Mithril Bar, 3 Solid Grinding Stone each.",
            note = "Recipe is a world drop. Farm or buy the plans.",
        },
        {
            text = "Skill 243-250: craft [LOOT]Runed Mithril Hammer[/] (~7). 18 Mithril Bar, 2 Core of Earth, 1 Solid Grinding Stone, 4 Thick Leather each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 250-258: craft [LOOT]Arcanite Skeleton Key[/] (~14). 1 Arcanite Bar, 1 Dense Grinding Stone each.",
            note = "Artisan trainer teaches this (Brikk Keencraft in STV).",
        },
        {
            text = "Skill 258-281: craft [LOOT]Thorium Shield Spike[/] (~27). 4 Thorium Bar, 4 Dense Grinding Stone, 2 Essence of Earth each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 281-291: craft [LOOT]Radiant Boots[/] (~11). 14 Thorium Bar, 4 Heart of Fire each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 291-300: craft [LOOT]Radiant Leggings[/] (~9). 20 Thorium Bar, 4 Heart of Fire each.",
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
            faction = "Horde",
            text = "Train [LOOT]Enchanting[/]. Disenchant greens for mats. Pair with Tailoring.",
            note = "Horde: Godan (Orgrimmar), Teg Dawnstrider (Thunder Bluff), Lavinia Crowe (Undercity). Forever starts with Mote of Magic on Inferior Stamina.",
            map = 1454,
            x = 53.4,
            y = 38.2,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Enchanting[/]. Disenchant greens for mats. Pair with Tailoring.",
            note = "Alliance: Lucan Cordell (Stormwind), Gimble Thistlefuzz (Ironforge), Lalina Lambar (Darnassus). Forever starts with Mote of Magic on Inferior Stamina.",
            map = 1453,
            x = 53.0,
            y = 74.2,
        },
        {
            faction = "Horde",
            text = "Skill 1-23: craft [LOOT]Enchant Bracer - Inferior Stamina[/] (~23). 1 Mote of Magic each.",
        },
        {
            faction = "Alliance",
            text = "Skill 1-25: craft [LOOT]Enchant Bracer - Inferior Stamina[/] (~25). 1 Mote of Magic each.",
            note = "Then Minor Deflect / Minor Absorption.",
        },
        {
            faction = "Horde",
            text = "Skill 23-90: craft [LOOT]Enchant Chest - Inferior Stamina[/] (~74). 1 Strange Dust each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            faction = "Alliance",
            text = "Skill 25-90: craft [LOOT]Enchant Chest - Minor Absorption[/] with Lesser Magic Essence.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            faction = "Horde",
            text = "Skill 90-128: craft [LOOT]Enchant Cloak - Minor Protection[/] (~44). 2 Strange Dust each.",
        },
        {
            faction = "Alliance",
            text = "Skill 90-128: craft [LOOT]Enchant Cloak - Minor Agility[/] (Lesser Astral Essence from Dalria in Ashenvale).",
        },
        {
            text = "Skill 128-164: craft [LOOT]Enchant Boots - Minor Stamina[/] (~39). 4 Strange Dust each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 164-210: craft [LOOT]Enchant Boots - Lesser Agility[/] (~70). 1 Soul Dust each.",
            note = "Horde: trainer Hgarth (Stonetalon). Alliance: shared trainer path from here.",
            map = 1442,
            x = 49.2,
            y = 57.2,
        },
        {
            text = "Skill 210-264: craft [LOOT]Enchant Gloves - Agility[/] (~93). 1 Vision Dust each.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 264-285: craft [LOOT]Enchant Gloves - Minor Haste[/] (~25). 1 Large Radiant Shard, 1 Wildvine each.",
            note = "Taught by Annora (Uldaman).",
        },
        {
            text = "Skill 285-300: craft [LOOT]Enchant Shield - Greater Stamina[/] (~19). 6 Dream Dust each.",
            note = "Horde: recipe sold by Daniel Bartlett (Undercity). Alliance: Mythrin'dir (Darnassus).",
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
            faction = "Horde",
            text = "Train [LOOT]Engineering[/] at an anvil. Pair with Mining.",
            note = "Horde: Roxxik (Orgrimmar), Tinkerwiz (Ratchet), Graham Van Talen (Undercity).",
            map = 1454,
            x = 76.0,
            y = 25.0,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Engineering[/] at an anvil. Pair with Mining.",
            note = "Alliance: Sprite Jumpsprocket (Stormwind), Springspindle Fizzlegear (Ironforge), Tinkerwiz (Ratchet).",
            map = 1453,
            x = 62.4,
            y = 30.2,
        },
        {
            text = "Skill 1-33: craft [LOOT]Rough Blasting Powder[/] (~39). 1 Rough Stone each.",
        },
        {
            text = "Skill 33-54: craft [LOOT]Handful of Copper Bolts[/] (~25). 1 Copper Bar each.",
        },
        {
            text = "Skill 54-75: craft [LOOT]Copper Tube[/] (~21). 2 Copper Bar, 1 Weak Flux each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 75-91: craft [LOOT]Coarse Blasting Powder[/] (~18). 1 Coarse Stone each.",
        },
        {
            text = "Skill 91-125: craft [LOOT]Silver Contact[/] (~39). 1 Silver Bar each.",
        },
        {
            text = "Skill 125-138: craft [LOOT]Heavy Blasting Powder[/] (~20). 1 Heavy Stone each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 138-145: craft [LOOT]Whirring Bronze Gizmo[/] (~10). 2 Bronze Bar, 1 Wool Cloth each.",
        },
        {
            text = "Skill 145-150: craft [LOOT]Bronze Framework[/] (~5). 2 Bronze Bar, 1 Medium Leather, 1 Wool Cloth each.",
        },
        {
            text = "Skill 150-158: craft [LOOT]Aquadynamic Fish Attractor[/] (~10). 2 Bronze Bar, 1 Nightcrawlers, 1 Coarse Blasting Powder each.",
        },
        {
            text = "Skill 158-175: craft more [LOOT]Bronze Framework[/] (~30).",
        },
        {
            text = "Skill 175-185: craft [LOOT]Solid Blasting Powder[/] (~13). 2 Solid Stone each.",
        },
        {
            text = "Skill 185-216: craft [LOOT]Flash Bomb[/] (~58). 1 Blue Pearl, 1 Heavy Blasting Powder, 1 Silk Cloth each.",
            note = "Recipe from the Flash Bomb Recipe quest. Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 216-245: craft [LOOT]Hi-Impact Mithril Slugs[/] (~73). 1 Mithril Bar, 1 Solid Blasting Powder each.",
        },
        {
            text = "Skill 245-250: craft [LOOT]Mithril Gyro-Shot[/] (~5). 2 Mithril Bar, 2 Solid Blasting Powder each.",
            note = "Buzzek Bracketswing in Gadgetzan teaches late Engineering.",
            map = 1446,
            x = 52.3,
            y = 27.7,
        },
        {
            text = "Skill 250-258: craft [LOOT]Dense Blasting Powder[/] (~14). 2 Dense Stone each.",
        },
        {
            text = "Skill 258-276: craft more [LOOT]Mithril Gyro-Shot[/] (~42).",
        },
        {
            text = "Skill 276-285: craft [LOOT]Thorium Widget[/] (~10). 3 Thorium Bar, 1 Runecloth each.",
        },
        {
            text = "Skill 285-300: craft [LOOT]Delicate Arcanite Converter[/] (~15). 1 Arcanite Bar, 1 Ironweb Spider Silk each.",
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
            faction = "Horde",
            text = "Train [LOOT]Leatherworking[/]. Pair with Skinning.",
            note = "Horde: Karolek (Orgrimmar), Una (Thunder Bluff), Arthur Moore (Undercity).",
            map = 1454,
            x = 62.8,
            y = 44.5,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Leatherworking[/]. Pair with Skinning.",
            note = "Alliance: Adele Fielder (Elwynn), Simon Tanner (Stormwind), Telonis (Darnassus).",
            map = 1453,
            x = 71.8,
            y = 62.0,
        },
        {
            text = "Skill 1-48: craft [LOOT]Light Armor Kit[/] (~56). 1 Light Leather each.",
        },
        {
            text = "Skill 48-55: craft [LOOT]Cured Light Hide[/] (~8). 1 Light Hide, 1 Salt each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 55-84: craft [LOOT]Embossed Leather Gloves[/] (~33). 3 Light Leather, 2 Coarse Thread each.",
        },
        {
            text = "Skill 84-103: craft [LOOT]Fine Leather Belt[/] (~28). 6 Light Leather, 2 Coarse Thread each.",
            note = "Save belts if you will craft Dark Leather Belt later.",
        },
        {
            text = "Skill 103-120: craft [LOOT]Light Leather Pants[/] (~29). 10 Light Leather, 1 Cured Light Hide, 1 Fine Thread each.",
        },
        {
            text = "Skill 120-125: craft [LOOT]Nimble Leather Gloves[/] (~5). 1 Elixir of Minor Agility, 6 Medium Leather, 1 Fine Thread each.",
        },
        {
            text = "Skill 125-135: craft [LOOT]Dark Leather Belt[/] (~12). 1 Fine Leather Belt, 1 Cured Medium Hide, 2 Fine Thread, 1 Gray Dye each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 135-145: craft [LOOT]Cured Heavy Hide[/] (~29). 1 Heavy Hide, 3 Salt each.",
        },
        {
            text = "Skill 145-150: craft [LOOT]Heavy Armor Kit[/] (~6). 5 Heavy Leather, 1 Fine Thread each.",
        },
        {
            text = "Skill 150-160: craft [LOOT]Mystic Heavy Armor Kit[/] (~11). 1 Heavy Armor Kit, 2 Soul Dust, 2 Lesser Mana Potion each.",
            note = "New Forever recipe. Alliance: vendor Saenorion (Darnassus). Horde: check leather vendors / AH for the pattern.",
        },
        {
            text = "Skill 160-170: craft [LOOT]Raptor Hide Belt[/] (~13). 4 Raptor Hide, 4 Heavy Leather, 2 Fine Thread each.",
            note = "Horde: Barbaric Leggings from Keena (Arathi) is an alternative around here. Alliance: use Barbaric Shoulders next.",
        },
        {
            text = "Skill 170-185: craft [LOOT]Barbaric Shoulders[/] then [LOOT]Green Leather Bracers[/] to about 185.",
            note = "Trainer recipes. Horde: skip Barbaric Shoulders if you used the Barbaric Leggings path.",
        },
        {
            text = "Skill 185-200: craft [LOOT]Guardian Gloves[/] (~13) then [LOOT]Thick Armor Kit[/] (~6).",
        },
        {
            text = "Skill 200-212: craft [LOOT]Nightscape Headband[/] (~18). 5 Thick Leather, 2 Silken Thread each.",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 212-225: craft Wild Leather Shoulders then Wild Leather Helmet (quest recipes).",
            note = "Alliance: Pratt McGrubben in Feralas. Horde: Jangdor Swiftstrider Wild Leather chain in Feralas.",
            map = 1444,
            x = 74.5,
            y = 42.9,
        },
        {
            text = "Skill 225-236: craft [LOOT]Cured Rugged Hide[/] (~8) then [LOOT]Rugged Armor Kit[/] (~8).",
        },
        {
            text = "Skill 236-258: craft [LOOT]Wicked Leather Gauntlets[/] (~22). 8 Rugged Leather, 1 Black Dye, 1 Rune Thread each.",
            note = "Recipe sold by Leonard Porter (Western Plaguelands).",
        },
        {
            text = "Skill 258-278: craft [LOOT]Frostsaber Boots[/] (~22). 4 Rugged Leather, 6 Frostsaber Leather, 1 Rune Thread each.",
            note = "Recipe sold by Qia (Winterspring).",
            map = 1452,
            x = 61.3,
            y = 37.1,
        },
        {
            text = "Skill 278-300: craft [LOOT]Wicked Leather Belt[/] (~23). 14 Rugged Leather, 2 Black Dye, 2 Rune Thread each.",
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
            faction = "Horde",
            text = "Train [LOOT]Tailoring[/]. Farm cloth from humanoids. Pair with Enchanting.",
            note = "Horde: Magar (Orgrimmar), Tepa (Thunder Bluff), Josef Gregorian (Undercity).",
            map = 1454,
            x = 63.0,
            y = 49.7,
        },
        {
            faction = "Alliance",
            text = "Train [LOOT]Tailoring[/]. Farm cloth from humanoids. Pair with Enchanting.",
            note = "Alliance: Eldrin (Elwynn), Georgio Bolero (Stormwind), Me'lynn (Darnassus).",
            map = 1453,
            x = 53.4,
            y = 81.0,
        },
        {
            text = "Skill 1-27: craft [LOOT]Bolt of Linen Cloth[/] (~26). 2 Linen Cloth each.",
        },
        {
            text = "Skill 27-73: craft [LOOT]Linen Belt[/] (~60). 1 Bolt of Linen Cloth, 1 Coarse Thread each.",
            note = "Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 73-81: craft [LOOT]Reinforced Linen Cape[/] (~15). 2 Bolt of Linen Cloth, 3 Coarse Thread each.",
        },
        {
            text = "Skill 81-110: craft [LOOT]Woolen Cape[/] (~64). 1 Bolt of Woolen Cloth, 1 Fine Thread each.",
            note = "Make Wool bolts as needed (3 Wool Cloth each).",
        },
        {
            text = "Skill 110-140: craft [LOOT]Stylish Red Shirt[/] (~65). 3 Bolt of Woolen Cloth, 2 Red Dye, 1 Fine Thread each.",
            note = "Train Expert at 125 (level 20).",
        },
        {
            text = "Skill 140-170: craft [LOOT]Azure Silk Cloak[/] (~32). 3 Bolt of Silk Cloth, 2 Blue Dye, 2 Fine Thread each.",
            note = "Recipe sold by Brienna Starglow (Feralas).",
        },
        {
            text = "Skill 170-185: craft [LOOT]Crimson Silk Vest[/] then [LOOT]Crimson Silk Pantaloons[/].",
        },
        {
            text = "Skill 185-205: craft [LOOT]Orange Mageweave Shirt[/], [LOOT]Black Mageweave Leggings[/], then [LOOT]Black Mageweave Gloves[/].",
            note = "Train Artisan at 200 (level 35).",
        },
        {
            text = "Skill 205-218: craft [LOOT]Black Mageweave Shoulders[/] (~17). 3 Bolt of Mageweave, 2 Heavy Silken Thread each.",
        },
        {
            text = "Skill 218-225: craft [LOOT]Admiral's Hat[/] (~9). 3 Bolt of Mageweave, 6 Long Elegant Feather, 2 Heavy Silken Thread each.",
            note = "Recipe sold by Cowardly Crosby (Stranglethorn).",
            map = 1434,
            x = 27.0,
            y = 82.5,
        },
        {
            text = "Skill 225-236: craft [LOOT]Runecloth Belt[/] (~13). 3 Bolt of Runecloth, 1 Rune Thread each.",
        },
        {
            text = "Skill 236-251: craft [LOOT]Runecloth Gloves[/] (~16). 4 Bolt of Runecloth, 4 Rugged Leather, 1 Rune Thread each.",
            note = "Recipe sold by Qia (Winterspring).",
            map = 1452,
            x = 61.3,
            y = 37.1,
        },
        {
            text = "Skill 251-281: craft [LOOT]Runecloth Headband[/] (~36). 4 Bolt of Runecloth, 2 Ironweb Spider Silk, 1 Rune Thread each.",
            note = "Recipe is a world drop.",
        },
        {
            text = "Skill 281-300: craft [LOOT]Mooncloth Shoulders[/] (~21). 5 Bolt of Runecloth, 5 Mooncloth, 1 Rune Thread each.",
            note = "Recipe is a world drop. Mooncloth is crafted from Felcloth at a moonwell.",
        },
    },
})
