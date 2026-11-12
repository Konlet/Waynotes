local _, ns = ...

-- Converted from Guides/REFERENCE/Horde-1-12_Mulgore.lua
-- Class tags from the RXP source are kept in [brackets] on the step text.
-- Era pins come from --c:Zone,x,y comments when present; otherwise QuestieDB supplies NPC coords.

ns.RegisterGuide({
    id = "horde-1-6-mulgore",
    name = "1-6 Mulgore",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            text = "[!Tauren] You have selected a guide meant for Tauren. This zone will NOT work well for you due to missing one of the main questlines that are gated for Tauren only. It is recommended you choose the same starter zone that you start in.",
            map = 1412,
            x = 44.92,
            y = 77.12,
        },
        {
            text = "Talk to Grull Hawkwind. Accept The Hunt Begins.",
            quest = 747,
            when = "accepted",
            map = 1412,
            x = 44.92,
            y = 77.12,
        },
        {
            text = "Talk to Chief Hawkwind. Accept A Humble Task.",
            quest = 752,
            when = "accepted",
            map = 1412,
            x = 44.18,
            y = 76.07,
        },
        {
            text = "[Warrior/Shaman] Kill Plainstriders. Loot them until you have 10 copper worth of vendor items (including your armor).",
            map = 1412,
            x = 46.05,
            y = 75.32,
            details = {
                "Kill Plainstrider",
            },
        },
        {
            text = "[Warrior/Shaman] Talk to Kawnie Softbreeze. Vendor Trash.",
            map = 1412,
            x = 45.3,
            y = 76.52,
        },
        {
            text = "[Warrior] Talk to Harutt Thunderhorn. Train [Battle Shout].",
            map = 1412,
            x = 44.02,
            y = 76.14,
        },
        {
            text = "[Shaman] Talk to Meela Dawnstrider. Train [Rockbiter Weapon].",
            map = 1412,
            x = 45.01,
            y = 75.95,
        },
        {
            text = "Kill Plainstriders. Loot them for their Meat and Feathers.",
            quest = 747,
            details = {
                "Plainstrider Meat (7)",
                "Plainstrider Feather (7)",
                "Kill Plainstrider",
            },
        },
        {
            text = "Talk to Greatmother Hawkwind. Turn in A Humble Task. Accept A Humble Task.",
            quest = 753,
            when = "accepted",
            map = 1412,
            x = 50.03,
            y = 81.16,
            details = {
                "Turn in A Humble Task",
            },
        },
        {
            text = "Loot the Water Pitcher on the well behind Greatmother Hawkwind.",
            quest = 753,
            map = 1412,
            x = 50.22,
            y = 81.37,
            details = {
                "Water Pitcher (1)",
            },
        },
        {
            text = "Kill Plainstriders. Loot them for their Meat and Feathers.",
            quest = 747,
            map = 1412,
            x = 47.36,
            y = 83.05,
            details = {
                "Plainstrider Meat (7)",
                "Plainstrider Feather (7)",
                "Kill Plainstrider",
            },
        },
        {
            text = "Talk to Grull Hawkwind. Turn in The Hunt Begins. Accept Simple Note. Accept Etched Note. Accept Rune-Inscribed Note. Accept Verdant Note. Accept The Hunt Continues.",
            quests = { 3091, 3092, 3093, 3094, 750 },
            when = "accepted",
            map = 1412,
            x = 44.92,
            y = 77.12,
            details = {
                "Turn in The Hunt Begins",
            },
        },
        {
            text = "Talk to Kawnie Softbreeze. Buy [Light Shots] from her. Vendor Trash.",
            map = 1412,
            x = 45.3,
            y = 76.52,
            details = {
                "Light Shot (1000)",
            },
        },
        {
            text = "Talk to Chief Hawkwind. Turn in A Humble Task. Accept Rites of the Earthmother.",
            quest = 755,
            when = "accepted",
            map = 1412,
            x = 44.18,
            y = 76.07,
            details = {
                "Turn in A Humble Task",
            },
        },
        {
            text = "[Shaman] Talk to Marjak. Vendor trash. Sell your weapon if it gives you enough money for a [Short Staff] (1s 02c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 44.07,
            y = 77.47,
            details = {
                "NPC: Marjak Keenblade",
            },
        },
        {
            text = "[Shaman] Talk to Marjak Keenblade. Buy a [Short Staff] from him.",
            map = 1412,
            x = 44.07,
            y = 77.47,
            details = {
                "Collect Short Staff (1)",
            },
        },
        {
            text = "[Shaman] Equip the [Short Staff].",
        },
        {
            text = "Kill Mountain Cougars. Loot them for their Pelts.",
            quest = 750,
            details = {
                "Mountain Cougar Pelt (10)",
                "Kill Mountain Cougar",
            },
        },
        {
            text = "Talk to Seer Graytongue. This starts a 10-minute timed quest. Turn in Rites of the Earthmother. Accept Rite of Strength. Accept Grace of An'she and Mu'sha.",
            quests = { 757, 95805 },
            when = "accepted",
            map = 1412,
            x = 42.58,
            y = 92.18,
            details = {
                "Turn in Rites of the Earthmother",
            },
        },
        {
            text = "Kill Mountain Cougars. Loot them for their Pelts.",
            quest = 750,
            map = 1412,
            x = 44.6,
            y = 90.86,
            details = {
                "Mountain Cougar Pelt (10)",
                "Kill Mountain Cougar",
            },
        },
        {
            text = "Kill Plainstrider",
            map = 1412,
            x = 43.9,
            y = 86.08,
        },
        {
            text = "[Warrior/Druid] Grind Plainstriders. Loot them until you have 2 silver worth of vendor items.",
            details = {
                "Kill Plainstrider",
            },
        },
        {
            text = "[!Warrior !Druid] Grind Plainstriders. Loot them until you have 1 silver worth of vendor items.",
            details = {
                "Kill Plainstrider",
            },
        },
        {
            text = "Talk to Grull Hawkwind. Turn in The Hunt Continues. Accept The Battleboars.",
            quest = 780,
            when = "accepted",
            map = 1412,
            x = 44.92,
            y = 77.12,
            details = {
                "Turn in The Hunt Continues",
            },
        },
        {
            text = "Talk to Kawnie Softbreeze. Vendor Trash.",
            map = 1412,
            x = 45.3,
            y = 76.52,
        },
        {
            text = "Talk to Brave Windfeather. She patrols around. Accept Break Sharptusk!",
            quest = 3376,
            when = "accepted",
            map = 1412,
            x = 44.67,
            y = 76.68,
        },
        {
            text = "[Warrior] Talk to Harutt Thunderhorn. Turn in Simple Note. Train [Charge]. Train [Rend].",
            quest = 3091,
            when = "complete",
            map = 1412,
            x = 44.02,
            y = 76.14,
        },
        {
            text = "[Warrior] Talk to Harutt Thunderhorn. Turn in Simple Note. Train [Rend].",
            quest = 3091,
            when = "complete",
            map = 1412,
            x = 44.02,
            y = 76.14,
        },
        {
            text = "[Hunter] Talk to Lanka Farshot. Turn in Etched Note. Train [Serpent Sting].",
            quest = 3092,
            when = "complete",
            map = 1412,
            x = 44.26,
            y = 75.7,
        },
        {
            text = "[Druid] Talk to Gart Mistrunner. Turn in Verdant Note. Train [Moonfire].",
            quest = 3094,
            when = "complete",
            map = 1412,
            x = 45.09,
            y = 75.93,
        },
        {
            text = "[Shaman] Talk to Seer Ravenfeather. Accept Call of Earth.",
            quest = 1519,
            when = "accepted",
            map = 1412,
            x = 44.73,
            y = 76.18,
        },
        {
            text = "[Shaman] Talk to Meela Dawnstrider. Turn in Rune-Inscribed Note. Train [Earth Shock].",
            quest = 3093,
            when = "complete",
            map = 1412,
            x = 45.01,
            y = 75.95,
        },
        {
            text = "[Druid] Talk to Kawnie Softbreeze. Buy [Refreshing Spring Water] from her.",
            map = 1412,
            x = 45.3,
            y = 76.52,
            details = {
                "Collect Refreshing Spring Water (10)",
            },
        },
        {
            text = "Kill Battleboars. Loot them for their Flanks and Snouts.",
            quest = 780,
            details = {
                "Battleboar Flank (8)",
                "Battleboar Snout (8)",
                "Kill Battleboar",
            },
        },
        {
            text = "Click the Shrine. Make sure the timer does not run out. Turn in Grace of An'she and Mu'sha.",
            quest = 95805,
            when = "complete",
        },
        {
            text = "Kill Battleboars. Loot them for their Flanks and Snouts.",
            quest = 780,
            map = 1412,
            x = 55.99,
            y = 85.46,
            details = {
                "Battleboar Flank (8)",
                "Battleboar Snout (8)",
                "Kill Battleboar",
            },
        },
        {
            text = "Travel through the cave.",
            map = 1412,
            x = 59.67,
            y = 83.33,
        },
        {
            text = "Kill Bristleback Quilboars. Loot them for their Belts.",
            quest = 757,
            details = {
                "Bristleback Belt (12)",
                "Kill Bristleback Quilboar",
            },
        },
        {
            text = "[Shaman] Kill Bristleback Shamans. Loot them for their Salves.",
            quest = 1519,
            details = {
                "Ritual Salve (2)",
                "Kill Bristleback Shaman",
            },
        },
        {
            text = "Kill Chief Sharptusk Thornmantle inside the big hut. Loot him for his Head.",
            quest = 3376,
            map = 1412,
            x = 64.71,
            y = 77.67,
            details = {
                "Chief Sharptusk Thornmantle's Head (1)",
                "Kill Chief Sharptusk Thornmantle",
            },
        },
        {
            text = "Enter the Cave.",
            map = 1412,
            x = 63.24,
            y = 82.7,
        },
        {
            text = "Loot the [Dirt-stained Map] on the ground. Use it to start the quest. Accept Attack on Camp Narache.",
            quest = 781,
            when = "accepted",
            map = 1412,
            x = 63.24,
            y = 82.7,
        },
        {
            text = "[Shaman] Kill Bristleback Shamans. Loot them for their Salves.",
            quest = 1519,
            details = {
                "Ritual Salve (2)",
                "Kill Bristleback Shaman",
            },
        },
        {
            text = "Kill Bristleback Quilboars. Loot them for their Belts.",
            quest = 757,
            map = 1412,
            x = 63.93,
            y = 78.34,
            details = {
                "Bristleback Belt (12)",
                "Kill Bristleback Quilboar",
            },
        },
        {
            text = "[Shaman] Kill Bristleback Shamans. Loot them for their Salves.",
            quest = 1519,
            map = 1412,
            x = 63.86,
            y = 80.14,
            details = {
                "Ritual Salve (2)",
                "Kill Bristleback Shaman",
            },
        },
        {
            text = "Talk to Grull Hawkwind. Turn in The Battleboars.",
            quest = 780,
            when = "complete",
            map = 1412,
            x = 44.92,
            y = 77.12,
        },
        {
            text = "Talk to Brave Windfeather. She patrols around. Turn in Break Sharptusk!",
            quest = 3376,
            when = "complete",
        },
        {
            text = "Talk to Kawnie Softbreeze. Vendor Trash.",
            map = 1412,
            x = 45.3,
            y = 76.52,
        },
        {
            text = "Talk to Brave Windfeather. She patrols around. Turn in Break Sharptusk!",
            quest = 3376,
            when = "complete",
            map = 1412,
            x = 44.67,
            y = 76.68,
        },
        {
            text = "[Shaman] Talk to Seer Ravenfeather. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1520,
            when = "accepted",
            map = 1412,
            x = 44.73,
            y = 76.18,
            details = {
                "Turn in Call of Earth",
            },
        },
        {
            text = "Talk to Chief Hawkwind. Turn in Attack on Camp Narache. Turn in Rite of Strength. Accept Rites of the Earthmother. Accept The Adventurer.",
            quests = { 763, 96659 },
            when = "accepted",
            map = 1412,
            x = 44.18,
            y = 76.07,
            details = {
                "Turn in Rite of Strength",
                "Turn in Attack on Camp Narache",
            },
        },
        {
            text = "[Shaman] Travel toward the rock.",
            map = 1412,
            x = 53.74,
            y = 80.15,
        },
        {
            text = "[Shaman] Use the [Earth Sapta].",
        },
        {
            text = "[Shaman] Talk to the Manifestation. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1521,
            when = "accepted",
            map = 1412,
            x = 53.74,
            y = 80.15,
            details = {
                "Turn in Call of Earth",
                "NPC: Minor Manifestation of Earth",
            },
        },
        {
            text = "[Shaman] Talk to Seer Ravenfeather. Turn in Call of Earth.",
            quest = 1521,
            when = "complete",
            map = 1412,
            x = 44.73,
            y = 76.18,
        },
        {
            text = "[Shaman] Talk to Meela Dawnstrider. Train [Healing Wave].",
            map = 1412,
            x = 45.01,
            y = 75.95,
        },
        {
            text = "[Hunter] Talk to Lanka Farshot. Train [Hunter's Mark]. Train [Arcane Shot].",
            map = 1412,
            x = 44.26,
            y = 75.7,
        },
        {
            text = "[Hunter] Talk to Lanka Farshot. Train [Arcane Shot].",
            map = 1412,
            x = 44.26,
            y = 75.7,
        },
        {
            text = "[Druid] Talk to Gart Mistrunner. Train [Thorns]. Train [Wrath].",
            map = 1412,
            x = 45.09,
            y = 75.93,
        },
        {
            text = "[Druid] Talk to Gart Mistrunner. Train [Wrath].",
            map = 1412,
            x = 45.09,
            y = 75.93,
        },
        {
            text = "[Warrior] Talk to Harutt Thunderhorn. Train [Parry]. Train [Thunder Clap].",
            map = 1412,
            x = 44.02,
            y = 76.14,
        },
        {
            text = "[Warrior] Talk to Harutt Thunderhorn. Train [Parry].",
            map = 1412,
            x = 44.02,
            y = 76.14,
        },
        {
            text = "Talk to Antur Fallow. Accept A Task Unfinished.",
            quest = 1656,
            when = "accepted",
            map = 1412,
            x = 38.51,
            y = 81.54,
        },
    },
})

ns.RegisterGuide({
    id = "horde-6-12-mulgore",
    name = "6-12 Mulgore",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            text = "Die and respawn at the Spirit Healer.",
            note = "softcore",
        },
        {
            text = "Travel to Bloodhoof Village.",
            note = "hardcore",
        },
        {
            text = "Talk to Kaga Wildhoof. Turn in The Adventurer. Accept The Great Outdoors.",
            note = "hardcore",
            quest = 96605,
            when = "accepted",
            details = {
                "Turn in The Adventurer",
            },
        },
        {
            text = "Type /sit at the campfire and wait for one minute until you get the \"Camp Benefits\" buff. /sit.",
            note = "hardcore",
            quest = 96605,
            details = {
                "1/1 Use the /sit emote near the campfire",
                "Gain the Boosted Rest buff",
            },
        },
        {
            text = "Talk to Kaga Wildhoof. Turn in The Great Outdoors. Accept Camping 101: Cooking.",
            note = "hardcore",
            quest = 96661,
            when = "accepted",
            details = {
                "Turn in The Great Outdoors",
            },
        },
        {
            text = "Talk to Yaw Sharpmane. Accept Chakuyak.",
            note = "softcore",
            quest = 96130,
            when = "accepted",
        },
        {
            text = "Talk to Ahab Wheathoof. Accept Kyle's Gone Missing!",
            note = "softcore",
            quest = 99411,
            when = "accepted",
        },
        {
            text = "Talk to Maur. Accept Mazzranache.",
            note = "softcore",
            quest = 766,
            when = "accepted",
            map = 1412,
            x = 46.97,
            y = 57.07,
            details = {
                "NPC: Maur Raincaller",
            },
        },
        {
            text = "Talk to Ruul. Accept Dangers of the Windfury.",
            note = "hardcore",
            quest = 743,
            when = "accepted",
            map = 1412,
            x = 47.36,
            y = 62.01,
            details = {
                "NPC: Ruul Eagletalon",
            },
        },
        {
            text = "[Shaman/Druid] Talk to Mahnott. Vendor trash. Sell your weapon if it gives you enough money for a [Walking Stick] (5s 04c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "NPC: Mahnott Roughwound",
            },
        },
        {
            text = "[Shaman/Druid] Talk to Mahnott. Buy a [Walking Stick] from him.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "Collect Walking Stick (1)",
            },
        },
        {
            text = "[Warrior] Talk to Mahnott. Vendor trash. Sell your weapon if it gives you enough money for a [Wooden Mallet] (7s 1c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "NPC: Mahnott Roughwound",
            },
        },
        {
            text = "[Warrior] Talk to Mahnott. Buy a [Wooden Mallet] from him.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "Collect Wooden Mallet (1)",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Vendor trash. Sell your weapon if it gives you enough money for a [Ornate Blunderbuss] (4s 14c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "NPC: Kennah Hawkseye",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Buy a [Ornate Blunderbuss] from him.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "Collect Ornate Blunderbuss (1)",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Buy [Light Shots] from him.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "Light Shot (1000)",
                "NPC: Kennah Hawkseye",
            },
        },
        {
            text = "[Shaman/Druid] Equip the [Walking Stick].",
        },
        {
            text = "[Warrior] Equip the [Wooden Mallet].",
        },
        {
            text = "[Hunter] Equip the [Ornate Blunderbuss].",
        },
        {
            text = "Talk to Innkeeper Kauth. Turn in A Task Unfinished.",
            quest = 1656,
            when = "complete",
            map = 1412,
            x = 46.63,
            y = 61.09,
        },
        {
            text = "Talk to Innkeeper Kauth. Turn in A Task Unfinished. Set your Hearthstone to Bloodhoof Village.",
            quest = 1656,
            when = "complete",
            map = 1412,
            x = 46.63,
            y = 61.09,
        },
        {
            text = "Talk to Baine. Turn in Rites of the Earthmother. Accept Sharing the Land. Accept Rite of Vision. Accept Dwarven Digging.",
            quests = { 745, 767, 746 },
            when = "accepted",
            map = 1412,
            x = 47.51,
            y = 60.16,
            details = {
                "Turn in Rites of the Earthmother",
                "NPC: Baine Bloodhoof",
            },
        },
        {
            text = "Talk to Zarlman. Turn in Rite of Vision. Accept Rite of Vision.",
            quest = 771,
            when = "accepted",
            map = 1412,
            x = 47.76,
            y = 57.53,
            details = {
                "Turn in Rite of Vision",
                "NPC: Zarlman Two-Moons",
            },
        },
        {
            text = "Talk to Maur. Accept Mazzranache.",
            note = "hardcore",
            quest = 766,
            when = "accepted",
            map = 1412,
            x = 46.97,
            y = 57.07,
            details = {
                "NPC: Maur Raincaller",
            },
        },
        {
            text = "Talk to Yaw Sharpmane. Accept Chakuyak.",
            note = "hardcore",
            quest = 96130,
            when = "accepted",
        },
        {
            text = "Talk to Ahab Wheathoof. Accept Kyle's Gone Missing!",
            note = "hardcore",
            quest = 99411,
            when = "accepted",
        },
        {
            text = "Talk to Harken. Accept Swoop Hunting.",
            quest = 761,
            when = "accepted",
            map = 1412,
            x = 48.71,
            y = 59.32,
            details = {
                "NPC: Harken Windtotem",
            },
        },
        {
            text = "Talk to Krang Stonehoof. Accept Sparring Match.",
            quest = 99108,
            when = "accepted",
        },
        {
            text = "Talk to a Novice Warrior, then defeat it in combat.",
            quest = 99108,
            details = {
                "3/3 Player Duels won or Novice Warriors defeated",
            },
        },
        {
            text = "Talk to Krang Stonehoof. Turn in Sparring Match.",
            quest = 99108,
            when = "complete",
        },
        {
            text = "[Tauren] Talk to Mull. Accept Poison Water.",
            quest = 748,
            when = "accepted",
            map = 1412,
            x = 48.53,
            y = 60.4,
            details = {
                "NPC: Mull Thunderhorn",
            },
        },
        {
            text = "Talk to Brave Wildrunner. He patrols around a bit. Accept Longwalker Malah.",
            quest = 99079,
            when = "accepted",
        },
        {
            text = "Talk to Ruul. Accept Dangers of the Windfury.",
            note = "softcore",
            quest = 743,
            when = "accepted",
            map = 1412,
            x = 47.36,
            y = 62.01,
            details = {
                "NPC: Ruul Eagletalon",
            },
        },
        {
            text = "Talk to Kaga Wildhoof. Turn in The Adventurer. Accept The Great Outdoors.",
            note = "softcore",
            quest = 96605,
            when = "accepted",
            details = {
                "Turn in The Adventurer",
            },
        },
        {
            text = "Type /sit at the campfire and wait for one minute until you get the \"Camp Benefits\" buff. /sit.",
            note = "softcore",
            quest = 96605,
            details = {
                "1/1 Use the /sit emote near the campfire",
                "Gain the Boosted Rest buff",
            },
        },
        {
            text = "Talk to Kaga Wildhoof. Turn in The Great Outdoors. Accept Camping 101: Cooking.",
            note = "softcore",
            quest = 96661,
            when = "accepted",
            details = {
                "Turn in The Great Outdoors",
            },
        },
        {
            text = "Get the items for Mazzranache as you quest throughout the zone.",
            quest = 766,
            details = {
                "Prairie Wolf Heart (1)",
                "Flatland Cougar Femur (1)",
                "Plainstrider Scale (1)",
                "Swoop Gizzard (1)",
            },
        },
        {
            text = "[Tauren] Kill Prairie Wolves. Loot them for their Paws. Kill Adult Plainstriders. Loot them for their [Tender Strider Meat] and Talons.",
            quest = 748,
            details = {
                "Prairie Wolf Paw (6)",
                "Kill +Prairie Wolf",
                "Plainstrider Talon (4)",
                "Collect Tender Strider Meat (1)",
                "Kill +Adult Plainstrider",
            },
        },
        {
            text = "[!Tauren] Kill Adult Plainstriders. Loot them for their [Tender Strider Meat].",
            details = {
                "Collect Tender Strider Meat (1)",
                "Kill Adult Plainstrider",
            },
        },
        {
            text = "Collect the Ambercorns. They can be found under the trees on the ground.",
            quest = 771,
            map = 1412,
            x = 50.36,
            y = 66.49,
            details = {
                "Ambercorn (2)",
            },
        },
        {
            text = "Kill Swoops throughout Mulgore. Loot them for their Quills.",
            quest = 761,
            details = {
                "Trophy Swoop Quill (8)",
                "Kill Wiry Swoop",
                "Kill Swoop",
            },
        },
        {
            text = "[Tauren] Kill Prairie Wolves. Loot them for their Paws. Kill Adult Plainstriders. Loot them for their [Tender Strider Meat] and Talons.",
            quest = 748,
            map = 1412,
            x = 48.58,
            y = 67.37,
            details = {
                "Prairie Wolf Paw (6)",
                "Kill +Prairie Wolf",
                "Plainstrider Talon (4)",
                "Collect Tender Strider Meat (1)",
                "Kill +Adult Plainstrider",
            },
        },
        {
            text = "[!Tauren] Kill Adult Plainstriders. Loot them for their [Tender Strider Meat].",
            map = 1412,
            x = 48.58,
            y = 67.37,
            details = {
                "Collect Tender Strider Meat (1)",
                "Kill Adult Plainstrider",
            },
        },
        {
            text = "[Tauren] Find Kyle. Use the [Tender Strider Meat] to feed him. He runs clockwise in circles around Bloodhoof Village.",
            quest = 99411,
            details = {
                "1/1 Kyle fed",
            },
        },
        {
            text = "[Tauren] Talk to Mull. Turn in Poison Water. Accept Winterhoof Cleansing.",
            quest = 754,
            when = "accepted",
            map = 1412,
            x = 48.53,
            y = 60.4,
            details = {
                "Turn in Poison Water",
                "NPC: Mull Thunderhorn",
            },
        },
        {
            text = "[Tauren] Collect the Well Stones around the Well.",
            quest = 771,
            details = {
                "Well Stone (2)",
            },
        },
        {
            text = "[Tauren] Use the [Winterhoof Cleansing Totem] at the Well.",
            quest = 754,
            map = 1412,
            x = 53.68,
            y = 66.28,
            details = {
                "Cleanse the Winterhoof Water Well (1)",
            },
        },
        {
            text = "Collect the Well Stones around the Well.",
            quest = 771,
            map = 1412,
            x = 54.06,
            y = 66.4,
            details = {
                "Well Stone (2)",
            },
        },
        {
            text = "Find Kyle. Use the [Tender Strider Meat] to feed him. He runs clockwise in circles around Bloodhoof Village.",
            quest = 99411,
            details = {
                "1/1 Kyle fed",
            },
        },
        {
            text = "Talk to Jhawna. Buy [Ice Cold Milk] from her. Buy [Freshly Baked Bread] from her. Vendor trash.",
            map = 1412,
            x = 47.63,
            y = 61.49,
            details = {
                "Ice Cold Milk (10)",
                "Freshly Baked Bread (10)",
                "NPC: Jhawna Oatwind",
            },
        },
        {
            text = "[Tauren] Talk to Mull. Turn in Winterhoof Cleansing. Accept Thunderhorn Totem.",
            quest = 756,
            when = "accepted",
            map = 1412,
            x = 48.53,
            y = 60.4,
            details = {
                "Turn in Winterhoof Cleansing",
                "NPC: Mull Thunderhorn",
            },
        },
        {
            text = "[Warrior] Talk to Vira. Train [First Aid].",
            map = 1412,
            x = 46.8,
            y = 60.85,
            details = {
                "NPC: Vira Younghoof",
            },
        },
        {
            text = "[Shaman/Druid] Talk to Mahnott. Vendor trash. Sell your weapon if it gives you enough money for a [Walking Stick] (5s 04c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "NPC: Mahnott Roughwound",
            },
        },
        {
            text = "[Shaman/Druid] Talk to Mahnott. Buy a [Walking Stick] from him.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "Collect Walking Stick (1)",
            },
        },
        {
            text = "[Warrior] Talk to Mahnott. Vendor trash. Sell your weapon if it gives you enough money for a [Wooden Mallet] (7s 1c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "NPC: Mahnott Roughwound",
            },
        },
        {
            text = "[Warrior] Talk to Mahnott. Buy a [Wooden Mallet] from him.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "Collect Wooden Mallet (1)",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Vendor trash. Sell your weapon if it gives you enough money for a [Ornate Blunderbuss] (4s 14c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "NPC: Kennah Hawkseye",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Buy a [Ornate Blunderbuss] from him.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "Collect Ornate Blunderbuss (1)",
            },
        },
        {
            text = "[Shaman/Druid] Equip the [Walking Stick].",
        },
        {
            text = "[Warrior] Equip the [Wooden Mallet].",
        },
        {
            text = "[Hunter] Equip the [Ornate Blunderbuss].",
        },
        {
            text = "Talk to Pyall. Train Cooking. Turn in Camping 101: Cooking.",
            quest = 96661,
            when = "complete",
            details = {
                "NPC: Pyall Silentstride",
            },
        },
        {
            text = "Talk to Zarlman. Do not follow the wolf that spawns. Turn in Rite of Vision. Accept Rite of Vision.",
            quest = 772,
            when = "accepted",
            map = 1412,
            x = 47.76,
            y = 57.53,
            details = {
                "Turn in Rite of Vision",
                "NPC: Zarlman Two-Moons",
            },
        },
        {
            text = "Talk to Ahab Wheathoof. Turn in Kyle's Gone Missing!",
            quest = 99411,
            when = "complete",
        },
        {
            text = "[Hunter] Talk to Yaw. Train your class spells.",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "[Druid] Talk to Gennia. Train your class spells.",
            map = 1412,
            x = 48.48,
            y = 59.64,
            details = {
                "NPC: Gennia Runetotem",
            },
        },
        {
            text = "[Warrior] Talk to Krang. Train your class spells.",
            map = 1412,
            x = 49.52,
            y = 60.58,
            details = {
                "NPC: Krang Stonehoof",
            },
        },
        {
            text = "[Shaman] Talk to Narm. Train your class spells.",
            map = 1412,
            x = 48.38,
            y = 59.15,
            details = {
                "NPC: Narm Skychaser",
            },
        },
        {
            text = "Talk to Morin. He patrols along the eastern road. Accept The Ravaged Caravan.",
            quest = 749,
            when = "accepted",
            map = 1412,
            x = 55.14,
            y = 60.65,
        },
        {
            text = "Turn in Longwalker Malah. Accept Grim Tidings.",
            quest = 99081,
            when = "accepted",
            details = {
                "Turn in Longwalker Malah",
                "NPC: Malah Longwind",
            },
        },
        {
            text = "Get the items for Mazzranache as you quest throughout the zone.",
            quest = 766,
            details = {
                "Prairie Wolf Heart (1)",
                "Flatland Cougar Femur (1)",
                "Plainstrider Scale (1)",
                "Swoop Gizzard (1)",
            },
        },
        {
            text = "[Tauren] Kill Stalkers and Cougars. Loot them for their Claws.",
            quest = 756,
            details = {
                "Stalker Claws (6)",
                "Kill +Prairie Stalker",
                "Cougar Claws (6)",
                "Kill +Flatland Cougar",
            },
        },
        {
            text = "Kill Swoops throughout Mulgore. Loot them for their Quills.",
            quest = 761,
            details = {
                "Trophy Swoop Quill (8)",
                "Kill Wiry Swoop",
                "Kill Swoop",
            },
        },
        {
            text = "Click the Sealed Supply Crate. Turn in The Ravaged Caravan. Accept The Ravaged Caravan.",
            quest = 751,
            when = "accepted",
            map = 1412,
            x = 53.74,
            y = 48.17,
            details = {
                "Turn in The Ravaged Caravan",
            },
        },
        {
            text = "[Tauren] Kill Stalkers and Cougars. Loot them for their Claws.",
            quest = 756,
            map = 1412,
            x = 46.4,
            y = 50.7,
            details = {
                "Stalker Claws (6)",
                "Kill +Prairie Stalker",
                "Cougar Claws (6)",
                "Kill +Flatland Cougar",
            },
        },
        {
            text = "Die and respawn at the Spirit Healer.",
            note = "softcore",
        },
        {
            text = "[Hunter] Talk to Yaw. Train your class spells.",
            note = "softcore",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "[Druid] Talk to Gennia. Train your class spells.",
            note = "softcore",
            map = 1412,
            x = 48.48,
            y = 59.64,
            details = {
                "NPC: Gennia Runetotem",
            },
        },
        {
            text = "[Warrior] Talk to Krang. Train your class spells.",
            note = "softcore",
            map = 1412,
            x = 49.52,
            y = 60.58,
            details = {
                "NPC: Krang Stonehoof",
            },
        },
        {
            text = "[Shaman] Talk to Narm. Train your class spells.",
            note = "softcore",
            map = 1412,
            x = 48.38,
            y = 59.15,
            details = {
                "NPC: Narm Skychaser",
            },
        },
        {
            text = "Kill Chakuyak. Loot it for its Pelt.",
            quest = 96130,
            details = {
                "1/1 Chakuyak's Pelt",
                "Kill Chakuyak",
            },
        },
        {
            text = "Enter the cave.",
        },
        {
            text = "Kill Palemane Tanners, Palemane Skinners and Palemane Poachers.",
            quest = 745,
            details = {
                "Palemane Tanner (10)",
                "Kill +Palemane Tanner",
                "Palemane Skinner (8)",
                "Kill +Palemane Skinner",
                "Palemane Poacher (5)",
                "Kill +Palemane Poacher",
            },
        },
        {
            text = "Talk to Perith Stormhoof. This starts an escort quest. Accept The Longwalkers.",
            quest = 98430,
            when = "accepted",
        },
        {
            text = "Escort Perith Stormhoof out of the cave.",
            quest = 98430,
            details = {
                "escort (manually entered cords where its completed)",
            },
        },
        {
            text = "Kill Palemane Tanners, Palemane Skinners and Palemane Poachers.",
            quest = 745,
            details = {
                "Palemane Tanner (10)",
                "Kill +Palemane Tanner",
                "Palemane Skinner (8)",
                "Kill +Palemane Skinner",
                "Palemane Poacher (5)",
                "Kill +Palemane Poacher",
            },
        },
        {
            text = "Die and respawn at the Spirit Healer.",
            note = "softcore",
        },
        {
            text = "Travel back to Bloodhoof Village.",
            note = "hardcore",
        },
        {
            text = "Find Kyle. Use the [Tender Strider Meat] to feed him. He runs clockwise in circles around Bloodhoof Village.",
            quest = 99411,
            details = {
                "1/1 Kyle fed",
            },
        },
        {
            text = "Talk to Yaw Sharpmane. Turn in Chakuyak.",
            quest = 96130,
            when = "complete",
        },
        {
            text = "[Hunter] Talk to Yaw. Train your class spells.",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "Talk to Maur. Turn in Mazzranache.",
            quest = 766,
            when = "complete",
            map = 1412,
            x = 46.97,
            y = 57.07,
            details = {
                "NPC: Maur Raincaller",
            },
        },
        {
            text = "[Shaman/Druid] Talk to Mahnott. Vendor trash. Sell your weapon if it gives you enough money for a [Walking Stick] (5s 04c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "NPC: Mahnott Roughwound",
            },
        },
        {
            text = "[Shaman/Druid] Talk to Mahnott. Buy a [Walking Stick] from him.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "Collect Walking Stick (1)",
            },
        },
        {
            text = "[Warrior] Talk to Mahnott. Vendor trash. Sell your weapon if it gives you enough money for a [Wooden Mallet] (7s 1c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "NPC: Mahnott Roughwound",
            },
        },
        {
            text = "[Warrior] Talk to Mahnott. Buy a [Wooden Mallet] from him.",
            map = 1412,
            x = 45.66,
            y = 58.6,
            details = {
                "Collect Wooden Mallet (1)",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Vendor trash. Sell your weapon if it gives you enough money for a [Ornate Blunderbuss] (4s 14c). You'll come back later if you don't have enough yet.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "NPC: Kennah Hawkseye",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Buy a [Ornate Blunderbuss] from him.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "Collect Ornate Blunderbuss (1)",
            },
        },
        {
            text = "[Hunter] Talk to Moorat.",
            map = 1412,
            x = 45.86,
            y = 57.67,
            details = {
                "Light Shot (1000)",
                "NPC: Moorat Longstride",
            },
        },
        {
            text = "[Shaman/Druid] Equip the [Walking Stick].",
        },
        {
            text = "[Warrior] Equip the [Wooden Mallet].",
        },
        {
            text = "[Hunter] Equip the [Ornate Blunderbuss].",
        },
        {
            text = "Talk to Harant. Vendor trash and repair.",
            map = 1412,
            x = 45.9,
            y = 58.73,
            details = {
                "NPC: Harant Ironbrace",
            },
        },
        {
            text = "Talk to Pyall. Train Cooking. Turn in Camping 101: Cooking.",
            quest = 96661,
            when = "complete",
            details = {
                "NPC: Pyall Silentstride",
            },
        },
        {
            text = "Talk to Brave Wildrunner. He patrols around a bit. Turn in Grim Tidings. Accept Our Ancient Enemy.",
            quest = 99101,
            when = "accepted",
            details = {
                "Turn in Grim Tidings",
            },
        },
        {
            text = "Talk to Baine Bloodhoof. Turn in Sharing the Land. Turn in Our Ancient Enemy. Accept Drive Them Out.",
            quest = 99080,
            when = "accepted",
            details = {
                "Turn in Our Ancient Enemy",
                "Turn in Sharing the Land",
            },
        },
        {
            text = "Talk to Harken. Turn in Swoop Hunting.",
            quest = 761,
            when = "complete",
            map = 1412,
            x = 48.71,
            y = 59.32,
            details = {
                "NPC: Harken Windtotem",
            },
        },
        {
            text = "[Tauren] Talk to Mull. Turn in Thunderhorn Totem. Accept Thunderhorn Cleansing.",
            quest = 758,
            when = "accepted",
            map = 1412,
            x = 48.53,
            y = 60.4,
            details = {
                "Turn in Thunderhorn Totem",
                "NPC: Mull Thunderhorn",
            },
        },
        {
            text = "[Shaman] Talk to Narm. Train your class spells.",
            map = 1412,
            x = 48.38,
            y = 59.15,
            details = {
                "NPC: Narm Skychaser",
            },
        },
        {
            text = "[Druid] Talk to Gennia. Train your class spells.",
            map = 1412,
            x = 48.48,
            y = 59.64,
            details = {
                "NPC: Gennia Runetotem",
            },
        },
        {
            text = "[Warrior] Talk to Krang. Train your class spells.",
            map = 1412,
            x = 49.52,
            y = 60.58,
            details = {
                "NPC: Krang Stonehoof",
            },
        },
        {
            text = "[Hunter] Talk to Yaw. Train your class spells.",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "Talk to Innkeeper Kauth. Buy [Ice Cold Milk] from him. Buy [Freshly Baked Bread] from him. Vendor Trash.",
            map = 1412,
            x = 46.63,
            y = 61.08,
            details = {
                "Ice Cold Milk (10)",
                "Freshly Baked Bread (10)",
            },
        },
        {
            text = "Find Kyle. Use the [Tender Strider Meat] to feed him. He runs clockwise in circles around Bloodhoof Village.",
            quest = 99411,
            details = {
                "1/1 Kyle fed",
            },
        },
        {
            text = "Talk to Ahab Wheathoof. Turn in Kyle's Gone Missing!",
            quest = 99411,
            when = "complete",
        },
        {
            text = "Finish getting the items for Mazzranache.",
            quest = 766,
            details = {
                "Prairie Wolf Heart (1)",
                "Flatland Cougar Femur (1)",
                "Plainstrider Scale (1)",
                "Swoop Gizzard (1)",
            },
        },
        {
            text = "Kill Swoops throughout Mulgore. Loot them for their Quills.",
            quest = 761,
            details = {
                "Trophy Swoop Quill (8)",
                "Kill Wiry Swoop",
                "Kill Swoop",
            },
        },
        {
            text = "[Tauren] Use the [Thunderhorn Cleansing Totem] at the Well.",
            quest = 758,
            map = 1412,
            x = 44.49,
            y = 45.36,
            details = {
                "Cleanse the Thunderhorn Water Well (1)",
            },
        },
        {
            text = "Kill Bael'dun Diggers and Bael'dun Appraisers. Loot them for their Prospector's Picks. Smash the [Picks] at the Forge. Be careful as Bael'dun Appraisers cast [Lesser Heal] (Ranged Cast: Heals themselves or a nearby mob below 50% health for about 75 health).",
            quest = 746,
            map = 1412,
            x = 31.27,
            y = 49.87,
            details = {
                "Broken Tools (5)",
                "Kill Bael'dun Digger",
                "Kill Bael'dun Appraiser",
            },
        },
        {
            text = "Kill Windfury Wind Witches and Windfury Harpies. Loot them for their Talons.",
            quest = 743,
            map = 1412,
            x = 34.5,
            y = 42.29,
            details = {
                "Windfury Talon (8)",
                "Kill Windfury Wind Witch",
                "Kill Windfury Harpy",
            },
        },
        {
            text = "Enter the cave just north of the Windfury Harpies.",
            map = 1412,
            x = 33.37,
            y = 36.52,
        },
        {
            text = "Talk to Wiserunner. Turn in Rite of Vision. Accept Rite of Wisdom.",
            quest = 773,
            when = "accepted",
            map = 1412,
            x = 32.72,
            y = 36.09,
            details = {
                "Turn in Rite of Vision",
                "NPC: Seer Wiserunner",
            },
        },
        {
            text = "Take the elevator into Thunder Bluff.",
        },
        {
            text = "Talk to Boarton Shadetotem. He is [Stealthed]. Accept Stalk With The Earthmother.",
            quest = 76156,
            when = "accepted",
        },
        {
            text = "Set your Hearthstone to Thunder Bluff.",
            map = 1456,
            x = 45.83,
            y = 64.74,
            details = {
                "NPC: Innkeeper Pala",
            },
        },
        {
            text = "Exit Thunder Bluff.",
        },
        {
            text = "Finish getting the items for Mazzranache.",
            quest = 766,
            details = {
                "Prairie Wolf Heart (1)",
                "Flatland Cougar Femur (1)",
                "Plainstrider Scale (1)",
                "Swoop Gizzard (1)",
            },
        },
        {
            text = "Keep an eye out for Ghost Howl. Loot him for his [Demon Scarred Cloak]. Use it to start the quest. Be careful as Ghost Howl is difficult due to being level 12. Accept The Demon Scarred Cloak.",
            quest = 770,
            when = "accepted",
        },
        {
            text = "Kill Swoops throughout Mulgore. Loot them for their Quills.",
            quest = 761,
            details = {
                "Trophy Swoop Quill (8)",
                "Kill Wiry Swoop",
                "Kill Swoop",
                "Kill Taloned Swoop",
            },
        },
        {
            text = "Talk to Raintotem. Accept A Sacred Burial.",
            quest = 833,
            when = "accepted",
            map = 1412,
            x = 59.85,
            y = 25.62,
            details = {
                "NPC: Lorekeeper Raintotem",
            },
        },
        {
            text = "Kill Bristleback Interlopers.",
            quest = 833,
            details = {
                "Bristleback Interloper (8)",
                "Kill Bristleback Interloper",
            },
        },
        {
            text = "Talk to the Ancestral Spirit. Turn in Rite of Wisdom. Accept Journey into Thunder Bluff.",
            quest = 775,
            when = "accepted",
            map = 1412,
            x = 61.45,
            y = 21.01,
            details = {
                "Turn in Rite of Wisdom",
            },
        },
        {
            text = "Kill Bristleback Interlopers.",
            quest = 833,
            map = 1412,
            x = 61.12,
            y = 22.88,
            details = {
                "Bristleback Interloper (8)",
                "Kill Bristleback Interloper",
            },
        },
        {
            text = "Talk to Raintotem. Turn in A Sacred Burial.",
            quest = 833,
            when = "complete",
            map = 1412,
            x = 59.85,
            y = 25.62,
            details = {
                "NPC: Lorekeeper Raintotem",
            },
        },
        {
            text = "Finish getting the items for Mazzranache.",
            quest = 766,
            details = {
                "Prairie Wolf Heart (1)",
                "Flatland Cougar Femur (1)",
                "Plainstrider Scale (1)",
                "Swoop Gizzard (1)",
            },
        },
        {
            text = "Kill Swoops. Loot them for their Quills.",
            quest = 761,
            map = 1412,
            x = 59.52,
            y = 23.36,
            details = {
                "Trophy Swoop Quill (8)",
                "Kill Wiry Swoop",
                "Kill Swoop",
                "Kill Taloned Swoop",
            },
        },
        {
            text = "Finish getting the items for Mazzranache.",
            quest = 766,
            map = 1412,
            x = 48.67,
            y = 44.84,
            details = {
                "Prairie Wolf Heart (1)",
                "Kill +Prairie Wolf Alpha",
                "Kill +Prairie Stalker",
                "Flatland Cougar Femur (1)",
                "Kill +Flatland Cougar",
                "Plainstrider Scale (1)",
            },
        },
        {
            text = "Die at the waypoint arrow (or further south of it) and respawn at the Spirit Healer.",
        },
        {
            text = "Travel back to Bloodhoof Village.",
            note = "hardcore",
        },
        {
            text = "Talk to Innkeeper Kauth. Vendor trash.",
            map = 1412,
            x = 46.62,
            y = 61.08,
        },
        {
            text = "Talk to Skorn. Turn in The Demon Scarred Cloak.",
            quest = 770,
            when = "complete",
            map = 1412,
            x = 46.75,
            y = 60.24,
            details = {
                "NPC: Skorn Whitecloud",
            },
        },
        {
            text = "Talk to Skorn. Accept The Hunter's Way.",
            quest = 861,
            when = "accepted",
            map = 1412,
            x = 46.75,
            y = 60.24,
            details = {
                "NPC: Skorn Whitecloud",
            },
        },
        {
            text = "[Tauren] Talk to Baine, Ruul, Mull and Harken. Turn in Dwarven Digging. Turn in Dangers of the Windfury. Turn in Thunderhorn Cleansing. Accept Wildmane Totem. Turn in Swoop Hunting.",
            quest = 759,
            when = "accepted",
            map = 1412,
            x = 48.71,
            y = 59.32,
            details = {
                "Turn in Swoop Hunting",
                "Turn in Thunderhorn Cleansing",
                "Turn in Dangers of the Windfury",
                "Turn in Dwarven Digging",
                "NPC: Baine Bloodhoof, Ruul Eagletalon, Mull Thunderhorn, Harken Windtotem",
            },
        },
        {
            text = "[Tauren] Talk to Baine, Ruul, and Mull. Turn in Dwarven Digging. Turn in Dangers of the Windfury. Turn in Thunderhorn Cleansing. Accept Wildmane Totem.",
            quest = 759,
            when = "accepted",
            map = 1412,
            x = 48.54,
            y = 60.38,
            details = {
                "Turn in Thunderhorn Cleansing",
                "Turn in Dangers of the Windfury",
                "Turn in Dwarven Digging",
                "NPC: Baine Bloodhoof, Ruul Eagletalon, Mull Thunderhorn",
            },
        },
        {
            text = "[!Tauren] Talk to Baine, Ruul and Harken. Turn in Dwarven Digging. Turn in Dangers of the Windfury. Turn in Swoop Hunting.",
            quests = { 746, 743, 761 },
            when = "complete",
            map = 1412,
            x = 48.71,
            y = 59.32,
            details = {
                "NPC: Baine Bloodhoof, Ruul Eagletalon, Harken Windtotem",
            },
        },
        {
            text = "[!Tauren] Talk to Baine and Ruul. Turn in Dwarven Digging. Turn in Dangers of the Windfury.",
            quests = { 746, 743 },
            when = "complete",
            map = 1412,
            x = 47.35,
            y = 62.02,
            details = {
                "NPC: Baine Bloodhoof, Ruul Eagletalon",
            },
        },
        {
            text = "[Hunter] Talk to Kennah. Buy [Heavy Shots] from him.",
            map = 1412,
            x = 45.5,
            y = 58.47,
            details = {
                "Heavy Shot (1000)",
                "NPC: Kennah Hawkseye",
            },
        },
        {
            text = "Talk to Maur. Turn in Mazzranache.",
            quest = 766,
            when = "complete",
            map = 1412,
            x = 46.97,
            y = 57.07,
            details = {
                "NPC: Maur Raincaller",
            },
        },
        {
            text = "[Warrior] Talk to Krang. Train your class spells. Accept Veteran Uzzek.",
            quest = 1505,
            when = "accepted",
            map = 1412,
            x = 49.52,
            y = 60.58,
            details = {
                "NPC: Krang Stonehoof",
            },
        },
        {
            text = "[Shaman] Talk to Narm. Accept Call of Fire. Train your class spells.",
            quest = 2984,
            when = "accepted",
            map = 1412,
            x = 48.38,
            y = 59.15,
            details = {
                "NPC: Narm Skychaser",
            },
        },
        {
            text = "[Hunter] Talk to Yaw. Accept Taming the Beast. Train your class spells.",
            quest = 6061,
            when = "accepted",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "[Druid] Talk to Gennia. Train your class spells. Accept Heeding the Call.",
            quest = 5928,
            when = "accepted",
            map = 1412,
            x = 48.48,
            y = 59.64,
            details = {
                "NPC: Gennia Runetotem",
            },
        },
        {
            text = "[Druid] Talk to Gennia. Train your class spells.",
            map = 1412,
            x = 48.48,
            y = 59.64,
            details = {
                "NPC: Gennia Runetotem",
            },
        },
        {
            text = "[Hunter] Use your [Taming Rod] on an Adult Plainstrider at max range.",
            quest = 6061,
            map = 1412,
            x = 39.38,
            y = 57.43,
            details = {
                "Tame an Adult Plainstrider (1)",
                "Kill Adult Plainstrider",
            },
        },
        {
            text = "[Hunter] Talk to Yaw. Turn in Taming the Beast. Accept Taming the Beast.",
            quest = 6087,
            when = "accepted",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "Turn in Taming the Beast",
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "[Hunter] Use your [Taming Rod] on a Prairie Stalker at max range.",
            quest = 6087,
            map = 1412,
            x = 49.49,
            y = 42.27,
            details = {
                "Tame a Prairie Stalker (1)",
                "Kill Prairie Stalker",
            },
        },
        {
            text = "[Hunter] Talk to Yaw. Turn in Taming the Beast. Accept Taming the Beast.",
            quest = 6088,
            when = "accepted",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "Turn in Taming the Beast",
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "[Hunter] Use your [Taming Rod] on a Swoop at max range and re-cast it immediately if they knock you down. If you fail and run out of Taming Rod Charges, abandon the quest, then pick it up again and come back.",
            quest = 6088,
            map = 1412,
            x = 51.57,
            y = 44.4,
            details = {
                "Tame a Swoop (1)",
                "Kill Swoop",
            },
        },
        {
            text = "[Hunter] Talk to Yaw. Turn in Taming the Beast. Accept Training the Beast.",
            quest = 6089,
            when = "accepted",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "Turn in Taming the Beast",
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "Talk to Jhawna. Buy [Ice Cold Milk] from her. Buy [Freshly Baked Bread] from her.",
            map = 1412,
            x = 47.63,
            y = 61.49,
            details = {
                "Ice Cold Milk (20)",
                "Freshly Baked Bread (20)",
                "NPC: Innkeeper Grosk, Jhawna Oatwind",
            },
        },
        {
            text = "Talk to Skorn. Accept The Hunter's Way.",
            quest = 861,
            when = "accepted",
            map = 1412,
            x = 46.75,
            y = 60.24,
            details = {
                "NPC: Skorn Whitecloud",
            },
        },
        {
            text = "Talk to Morin. He patrols along the eastern road. Turn in The Ravaged Caravan. Accept The Venture Co. Accept Supervisor Fizsprocket.",
            quests = { 764, 765 },
            when = "accepted",
            map = 1412,
            x = 55.14,
            y = 60.65,
            details = {
                "Turn in The Ravaged Caravan",
            },
        },
        {
            text = "Kill Flatland Prowlers. Loot them for their Claws.",
            quest = 861,
            details = {
                "Flatland Prowler Claw (4)",
                "Kill Flatland Prowler",
            },
        },
        {
            text = "[Hunter] Tame a Prairie Wolf Alpha. This will allow you to train [Bite Rank 2].",
            map = 1412,
            x = 67.62,
            y = 59.06,
            details = {
                "Kill Prairie Wolf Alpha",
            },
        },
        {
            text = "[Tauren] Kill Prairie Wolf Alphas in the area. Loot them for their Teeth.",
            quest = 759,
            details = {
                "Prairie Alpha Tooth (8)",
                "Kill Prairie Wolf Alpha",
            },
        },
        {
            text = "Kill Galak Outrunners and Galak Centaurs.",
            quest = 99080,
            details = {
                "4/4 Galak Outrunner slain",
                "Kill +Galak Outrunner",
                "6/6 Galak Centaur slain",
                "Kill +Galak Centaur",
            },
        },
        {
            text = "Kill Herak the Pillager. Loot him for his Head.",
            quest = 99080,
            details = {
                "1/1 Herak's Head",
                "Kill Herak the Pillager",
            },
        },
        {
            text = "Kill Galak Outrunners and Galak Centaurs.",
            quest = 99080,
            details = {
                "4/4 Galak Outrunner slain",
                "Kill +Galak Outrunner",
                "6/6 Galak Centaur slain",
                "Kill +Galak Centaur",
            },
        },
        {
            text = "[Tauren] Kill Prairie Wolf Alphas in the area. Loot them for their Teeth.",
            quest = 759,
            map = 1412,
            x = 67.62,
            y = 59.06,
            details = {
                "Prairie Alpha Tooth (8)",
                "Kill Prairie Wolf Alpha",
            },
        },
        {
            text = "Travel to The Venture Co. Mine.",
            map = 1412,
            x = 61.51,
            y = 47.29,
        },
        {
            text = "Kill Venture Co. Workers and Venture Co. Supervisors.",
            quest = 764,
            details = {
                "Venture Co. Worker (14)",
                "Kill +Venture Co. Worker",
                "Venture Co. Supervisor (6)",
                "Kill +Venture Co. Supervisor",
            },
        },
        {
            text = "Open the Blasting Supplies inside the mine and outside on the other side. Loot them for the Seaforium Mining Charges. Stay on the upper levels of the cave if possible.",
            quest = 76156,
            details = {
                "5/5 Seaforium Mining Charge",
            },
        },
        {
            text = "Kill Supervisor Fizsprocket. Loot him for his Clipboard and [Mulgore Expansion Plans]. Use the [Mulgore Expansion Plans] to start the quest. Accept Fizsprocket's Notes.",
            quest = 98424,
            when = "accepted",
            map = 1412,
            x = 64.95,
            y = 43.33,
            details = {
                "Fizsprocket's Clipboard (1)",
                "Kill Supervisor Fizsprocket",
            },
        },
        {
            text = "Loot the Documents on the ground.",
            quest = 98424,
            details = {
                "1/1 Shredder Operation Instructions",
            },
        },
        {
            text = "Loot the Documents on the ground.",
            quest = 98424,
            details = {
                "1/1 Barrens Operations Best Practices",
            },
        },
        {
            text = "Loot the Documents on the ground.",
            quest = 98424,
            details = {
                "1/1 One \"Gerenzo\", of Stonetalon",
            },
        },
        {
            text = "Kill Venture Co. Workers and Venture Co. Supervisors.",
            quest = 764,
            map = 1412,
            x = 61.89,
            y = 47.84,
            details = {
                "Venture Co. Worker (14)",
                "Kill +Venture Co. Worker",
                "Venture Co. Supervisor (6)",
                "Kill +Venture Co. Supervisor",
            },
        },
        {
            text = "Open the Blasting Supplies inside the mine and outside on the other side. Loot them for the Seaforium Mining Charges. Stay on the upper levels of the cave if possible.",
            quest = 76156,
            map = 1412,
            x = 61.72,
            y = 35.15,
            details = {
                "Seaforium Mining Charge (5)",
            },
        },
        {
            text = "Talk to Morin. He patrols along the eastern road. Turn in The Venture Co. Turn in Supervisor Fizsprocket. Turn in Fizsprocket's Notes.",
            quests = { 764, 765, 98424 },
            when = "complete",
            map = 1412,
            x = 55.14,
            y = 60.65,
        },
        {
            text = "[Tauren] Travel to Bloodhoof Village.",
        },
        {
            text = "Talk to Baine Bloodhoof. Turn in Drive Them Out. Accept The High Chieftain.",
            quest = 99082,
            when = "accepted",
            details = {
                "Turn in Drive Them Out",
            },
        },
        {
            text = "[Tauren] Talk to Mull. Turn in Wildmane Totem. Accept Wildmane Cleansing.",
            quest = 760,
            when = "accepted",
            map = 1412,
            x = 48.53,
            y = 60.4,
            details = {
                "Turn in Wildmane Totem",
                "NPC: Mull Thunderhorn",
            },
        },
        {
            text = "[!Druid].",
        },
        {
            text = "[Druid] Travel to Thunder Bluff.",
        },
        {
            text = "Talk to Boarton Shadetotem. He is [Stealthed]. Turn in Stalk With The Earthmother. Accept Stalk With The Earthmother.",
            quest = 76160,
            when = "accepted",
            details = {
                "Turn in Stalk With The Earthmother",
            },
        },
        {
            text = "[Hunter] Talk to Melor. Turn in The Hunter's Way. Accept Sergra Darkthorn.",
            quest = 860,
            when = "accepted",
            map = 1456,
            x = 61.3,
            y = 80.9,
            details = {
                "Turn in The Hunter's Way",
                "NPC: Melor Stonehoof",
            },
        },
        {
            text = "[Hunter] Talk to Melor. Accept Sergra Darkthorn.",
            quest = 860,
            when = "accepted",
            map = 1456,
            x = 61.3,
            y = 80.9,
            details = {
                "NPC: Melor Stonehoof",
            },
        },
        {
            text = "[Hunter] Talk to Holt. Turn in Training the Beast.",
            quest = 6089,
            when = "complete",
            map = 1456,
            x = 57.4,
            y = 89.4,
            details = {
                "NPC: Holt Thunderhorn",
            },
        },
        {
            text = "[Hunter] Talk to Hesuwa. Train your pet spells.",
            map = 1456,
            x = 54.08,
            y = 84.08,
            details = {
                "NPC: Hesuwa Thunderhorn",
            },
        },
        {
            text = "[Hunter] Drag [Beast Training] onto your Action Bars. Teach skills to your pet.",
        },
        {
            text = "[Shaman/Druid] Talk to Ansekhwa. Train Two-Handed Maces.",
            map = 1456,
            x = 40.93,
            y = 62.73,
        },
        {
            text = "[Hunter] Talk to Ansekhwa. Train Staves.",
            map = 1456,
            x = 40.93,
            y = 62.73,
        },
        {
            text = "Talk to Eyahn. Accept Preparation for Ceremony.",
            quest = 744,
            when = "accepted",
            map = 1456,
            x = 37.8,
            y = 59.4,
            details = {
                "NPC: Eyahn Eagletalon",
            },
        },
        {
            text = "Talk to Cairne. Turn in Journey into Thunder Bluff. Accept Rites of the Earthmother. Turn in The High Chieftain. Turn in The Longwalkers.",
            quest = 776,
            when = "accepted",
            map = 1456,
            x = 60.0,
            y = 51.7,
            details = {
                "Turn in The Longwalkers",
                "Turn in The High Chieftain",
                "Turn in Journey into Thunder Bluff",
                "NPC: Cairne Bloodhoof",
            },
        },
        {
            text = "Talk to Cairne. Turn in Journey into Thunder Bluff. Accept Rites of the Earthmother. Turn in The Longwalkers.",
            quest = 776,
            when = "accepted",
            map = 1456,
            x = 60.0,
            y = 51.7,
            details = {
                "Turn in The Longwalkers",
                "Turn in Journey into Thunder Bluff",
                "NPC: Cairne Bloodhoof",
            },
        },
        {
            text = "[Tauren Druid] Talk to Hamuul Runetotem. Accept The Barrens Oases.",
            quest = 886,
            when = "accepted",
            map = 1456,
            x = 78.1,
            y = 28.6,
            details = {
                "NPC: Arch Druid Hamuul Runetotem",
            },
        },
        {
            text = "[Tauren Druid] Travel to the Elder Rise.",
            map = 1456,
            x = 71.6,
            y = 30.15,
        },
        {
            text = "[Tauren Druid] Talk to Turak. Turn in Heeding the Call. Accept Moonglade.",
            quest = 5922,
            when = "accepted",
            map = 1456,
            x = 76.7,
            y = 27.3,
            details = {
                "Turn in Heeding the Call",
                "NPC: Arch Druid Hamuul Runetotem, Turak Runetotem",
            },
        },
        {
            text = "[Tauren Druid] Talk to Turak. Accept Moonglade.",
            quest = 5922,
            when = "accepted",
            map = 1456,
            x = 76.7,
            y = 27.3,
            details = {
                "NPC: Arch Druid Hamuul Runetotem, Turak Runetotem",
            },
        },
        {
            text = "[Tauren Druid] Cast [Teleport: Moonglade].",
        },
        {
            text = "[Tauren Druid] Talk to Dendrite. Turn in Moonglade. Accept Great Bear Spirit.",
            quest = 5930,
            when = "accepted",
            details = {
                "Turn in Moonglade",
                "NPC: Dendrite Starblaze",
            },
        },
        {
            text = "[Tauren Druid] Talk to the Great Bear Spirit.",
            quest = 5930,
            details = {
                "Seek out the Great Bear Spirit and learn what it has to share with you about the nature of the bear. (1)",
            },
        },
        {
            text = "[Tauren Druid] Cast [Teleport: Moonglade].",
        },
        {
            text = "[Tauren Druid] Talk to Dendrite. Turn in Great Bear Spirit. Accept Back to Thunder Bluff.",
            quest = 5932,
            when = "accepted",
            details = {
                "Turn in Great Bear Spirit",
                "NPC: Dendrite Starblaze",
            },
        },
        {
            text = "[Tauren Druid].",
        },
        {
            text = "[Tauren Druid] Talk to Bunthen. Fly to Thunder Bluff.",
            details = {
                "NPC: Bunthen Plainswind",
            },
        },
        {
            text = "[Tauren Druid] Talk to Turak. Turn in Back to Thunder Bluff. Accept Body and Heart.",
            quest = 6002,
            when = "accepted",
            map = 1456,
            x = 76.7,
            y = 27.3,
            details = {
                "Turn in Back to Thunder Bluff",
                "NPC: Turak Runetotem",
            },
        },
        {
            text = "Talk to Mooranta. This will unlock an easy quest. If you already have 2 professions, skip this step. Train [Skinning].",
            map = 1456,
            x = 44.43,
            y = 43.19,
        },
        {
            text = "Talk to Veren. Accept Gathering Leather.",
            quest = 768,
            when = "accepted",
            map = 1456,
            x = 44.39,
            y = 44.72,
            details = {
                "NPC: Veren Tallstrider",
            },
        },
        {
            text = "Talk to Auctioneer Stampi. Buy Twelve [Light Leather] from the Auction House.",
            map = 1456,
            x = 40.39,
            y = 51.77,
            details = {
                "Light Leather (12)",
            },
        },
        {
            text = "Talk to Veren. Turn in Gathering Leather.",
            quest = 768,
            when = "complete",
            map = 1456,
            x = 44.39,
            y = 44.72,
            details = {
                "NPC: Veren Tallstrider",
            },
        },
        {
            text = "[Hunter] Talk to Kaga. Buy [Tough Jerky] from her to feed your pet.",
            map = 1456,
            x = 52.32,
            y = 47.79,
            details = {
                "Tough Jerky (5)",
                "NPC: Kaga Mistrunner",
            },
        },
        {
            text = "Exit Thunder Bluff.",
        },
        {
            text = "Keep an eye out for Ghost Howl. Loot him for his [Demon Scarred Cloak]. Use it to start the quest. Skip this step if you're unable to find him. Accept The Demon Scarred Cloak.",
            quest = 770,
            when = "accepted",
        },
        {
            text = "Kill Flatland Prowlers. Loot them for their Claws.",
            quest = 861,
            details = {
                "Flatland Prowler Claw (4)",
                "Kill Flatland Prowler",
            },
        },
        {
            text = "Loot Windfury Cones on the ground. They are mainly found underneath/near the trees.",
            details = {
                "Windfury Cone (8)",
            },
        },
        {
            text = "Kill Windfury Sorceresses. Loot them for their Azure Feathers. Kill Windfury Matriarchs. Loot them for their Bronze Feathers.",
            quest = 744,
            map = 1412,
            x = 30.2,
            y = 19.5,
            details = {
                "Azure Feather (6)",
                "Kill +Windfury Sorceress",
                "Bronze Feather (6)",
                "Kill +Windfury Matriarch",
            },
        },
        {
            text = "Loot Windfury Cones on the ground. They are mainly found underneath/near the trees.",
            details = {
                "Windfury Cone (8)",
            },
        },
        {
            text = "[Tauren] Use the [Wildmane Cleansing Totem] at the Well.",
            quest = 760,
            map = 1412,
            x = 42.5,
            y = 13.8,
            details = {
                "Cleanse the Wildmane Well (1)",
            },
        },
        {
            text = "Kill Arra'Chea (Big black kodo). Kill and loot him for his Horn. He patrols clockwise around Northern Mulgore.",
            quest = 776,
            map = 1412,
            x = 56.2,
            y = 32.9,
            details = {
                "Horn of Arra'chea (1)",
            },
        },
        {
            text = "Kill Flatland Prowlers. Loot them for their Claws.",
            quest = 861,
            map = 1412,
            x = 48.7,
            y = 20.85,
            details = {
                "Flatland Prowler Claw (4)",
                "Kill Flatland Prowler",
            },
        },
        {
            text = "Travel back to Thunder Bluff.",
        },
        {
            text = "Talk to Rahauro. Accept Searching for the Lost Satchel. Accept Testing an Enemy's Strength.",
            quests = { 5722, 5723 },
            when = "accepted",
            map = 1456,
            x = 70.4,
            y = 29.6,
        },
        {
            text = "Talk to Cairne. Turn in Rites of the Earthmother.",
            quest = 776,
            when = "complete",
            map = 1456,
            x = 60.0,
            y = 51.7,
            details = {
                "NPC: Cairne Bloodhoof",
            },
        },
        {
            text = "Talk to Eyahn. Turn in Preparation for Ceremony.",
            quest = 744,
            when = "complete",
            map = 1456,
            x = 37.8,
            y = 59.4,
            details = {
                "NPC: Eyahn Eagletalon",
            },
        },
        {
            text = "Talk to Boarton Shadetotem. He is [Stealthed]. Turn in Stalk With The Earthmother. Accept Stalk With The Earthmother.",
            quest = 76240,
            when = "accepted",
            map = 1456,
            x = 39.45,
            y = 65.86,
            details = {
                "Turn in Stalk With The Earthmother",
            },
        },
        {
            text = "Talk to Auctioneer Stampi. Buy a [Raw Brilliant Smallfish] from the Auction House.",
            map = 1456,
            x = 40.41,
            y = 51.78,
            details = {
                "Raw Brilliant Smallfish (1)",
            },
        },
        {
            text = "Travel toward Sewa Mistrunner.",
            map = 1456,
            x = 55.78,
            y = 47.02,
        },
        {
            text = "Talk to Kah Mistrunner. Train [Fishing].",
            map = 1456,
            x = 56.13,
            y = 46.39,
        },
        {
            text = "Talk to Sewa Mistrunner. Buy a [Fishing Pole] and [Shiny Bauble] from her.",
            map = 1456,
            x = 55.78,
            y = 47.02,
            details = {
                "Fishing Pole (1)",
                "Shiny Bauble (1)",
            },
        },
        {
            text = "Equip the [Fishing Pole].",
        },
        {
            text = "Attach the [Shiny Bauble] to your [Fishing Pole].",
        },
        {
            text = "Fish in the pond until you get a [Raw Brilliant Smallfish].",
            map = 1456,
            x = 40.42,
            y = 58.55,
            details = {
                "Raw Brilliant Smallfish (1)",
            },
        },
        {
            text = "Use the [Knife Set] to create [Fish Chunks].",
            quest = 76240,
            details = {
                "Fish Chunks (1)",
            },
        },
        {
            text = "Talk to Boarton Shadetotem. He is [Stealthed]. Turn in Stalk With The Earthmother.",
            quest = 76240,
            when = "complete",
            map = 1456,
            x = 39.45,
            y = 65.86,
        },
        {
            text = "Talk to Melor. Turn in The Hunter's Way. Accept Sergra Darkthorn.",
            quest = 860,
            when = "accepted",
            map = 1456,
            x = 61.3,
            y = 80.9,
            details = {
                "Turn in The Hunter's Way",
                "NPC: Melor Stonehoof",
            },
        },
        {
            text = "Jump down the Hunter Rise onto the small hill to exit Thunder Bluff. Follow the arrow precisely to avoid dying. Regain some health before the second jump.",
        },
        {
            text = "Travel to Bloodhoof Village.",
        },
        {
            text = "Talk to Skorn. Turn in The Demon Scarred Cloak.",
            quest = 770,
            when = "complete",
            map = 1412,
            x = 46.75,
            y = 60.24,
            details = {
                "NPC: Skorn Whitecloud",
            },
        },
        {
            text = "[Tauren] Talk to Mull. Turn in Wildmane Cleansing.",
            quest = 760,
            when = "complete",
            map = 1412,
            x = 48.53,
            y = 60.4,
            details = {
                "NPC: Mull Thunderhorn",
            },
        },
        {
            text = "[Shaman] Talk to Narm. Train your class spells.",
            map = 1412,
            x = 48.38,
            y = 59.15,
            details = {
                "NPC: Narm Skychaser",
            },
        },
        {
            text = "[Druid] Talk to Gennia. Train your class spells.",
            map = 1412,
            x = 48.48,
            y = 59.64,
            details = {
                "NPC: Gennia Runetotem",
            },
        },
        {
            text = "[Warrior] Talk to Krang. Train your class spells.",
            map = 1412,
            x = 49.52,
            y = 60.58,
            details = {
                "NPC: Krang Stonehoof",
            },
        },
        {
            text = "[Hunter] Talk to Yaw. Train your class spells.",
            map = 1412,
            x = 47.81,
            y = 55.69,
            details = {
                "NPC: Yaw Sharpmane",
            },
        },
        {
            text = "Travel to The Barrens.",
            map = 1412,
            x = 69.6,
            y = 60.4,
        },
        {
            text = "[Tauren Druid] Use [Cenarion Lunardust] at the Moonkin Stone. Kill Lunaclaw as he spawns. Talk to the Lunaclaw Spirit afterwards. Be careful! Lunaclaw casts [Thrash] (Charges 2 extra attacks every 10 seconds). Steer clear of the Thunderheads in the area.",
            quest = 6002,
            map = 1413,
            x = 42.0,
            y = 60.86,
            details = {
                "Face Lunaclaw and earn the strength of body and heart it possesses. (1)",
                "Kill Lunaclaw",
            },
        },
        {
            text = "[!Druid] Talk to Omusa. Get the Camp Taurajo flight path.",
            map = 1413,
            x = 44.45,
            y = 59.15,
            details = {
                "NPC: Omusa Thunderhorn",
            },
        },
        {
            text = "[Druid] Talk to Omusa. Get the Camp Taurajo flight path. Fly to Thunder Bluff.",
            map = 1413,
            x = 44.45,
            y = 59.15,
            details = {
                "NPC: Omusa Thunderhorn",
            },
        },
        {
            text = "[Tauren Druid] Travel to the Elder Rise.",
            map = 1456,
            x = 71.6,
            y = 30.15,
        },
        {
            text = "[Tauren Druid] Talk to Turak. Turn in Body and Heart.",
            quest = 6002,
            when = "complete",
            map = 1456,
            x = 76.477,
            y = 27.221,
            details = {
                "NPC: Turak Runetotem",
            },
        },
        {
            text = "[Tauren Druid] Fly to Camp Taurajo.",
            map = 1456,
            x = 47.0,
            y = 49.82,
            details = {
                "NPC: Tal",
            },
        },
        {
            text = "[Tauren] Talk to Kirge Sternhorn. Accept Journey to the Crossroads.",
            quest = 854,
            when = "accepted",
            map = 1413,
            x = 44.9,
            y = 58.6,
        },
        {
            text = "Travel north toward The Crossroads.",
        },
        {
            text = "Talk to Tonga. Turn in The Barrens Oases. Accept The Forgotten Pools.",
            quest = 870,
            when = "accepted",
            map = 1413,
            x = 52.26,
            y = 31.93,
            details = {
                "Turn in The Barrens Oases",
                "NPC: Tonga Runetotem",
            },
        },
        {
            text = "Talk to Sergra. Turn in Sergra Darkthorn. Accept Plainstrider Menace.",
            quest = 844,
            when = "accepted",
            map = 1413,
            x = 52.23,
            y = 31.0,
            details = {
                "Turn in Sergra Darkthorn",
            },
        },
        {
            text = "Talk to Thork. Turn in Journey to the Crossroads. Accept Disrupt the Attacks. Accept Supplies for the Crossroads.",
            quests = { 871, 5041 },
            when = "accepted",
            map = 1413,
            x = 51.5,
            y = 30.87,
            details = {
                "Turn in Journey to the Crossroads",
            },
        },
        {
            text = "Talk to Darsok. He is at the top of the tower. Accept Harpy Raiders.",
            quest = 867,
            when = "accepted",
            map = 1413,
            x = 51.62,
            y = 30.9,
            details = {
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            text = "Talk to Helbrim. Accept Fungal Spores. Accept Wharfmaster Dizzywig.",
            quests = { 848, 1492 },
            when = "accepted",
            map = 1413,
            x = 51.44,
            y = 30.15,
            details = {
                "NPC: Apothecary Helbrim",
            },
        },
        {
            text = "Talk to Jahan. Accept A Bundle of Hides.",
            quest = 6361,
            when = "accepted",
            map = 1413,
            x = 51.21,
            y = 29.05,
            details = {
                "NPC: Jahan Hawkwing",
            },
        },
        {
            text = "Talk to Devrak. Do NOT fly anywhere!. Turn in A Bundle of Hides. Accept Ride to Thunder Bluff.",
            quest = 6362,
            when = "accepted",
            map = 1413,
            x = 51.5,
            y = 30.34,
            details = {
                "Turn in A Bundle of Hides",
            },
        },
        {
            text = "Talk to Gazrog. Accept Raptor Thieves.",
            quest = 869,
            when = "accepted",
            map = 1413,
            x = 51.93,
            y = 30.32,
        },
        {
            text = "[Shaman] Check for Chen's Empty Keg next to Kranal. Loot it and start the quest. You can get it later if it's not there. Accept Chen's Empty Keg.",
            quest = 819,
            when = "accepted",
        },
        {
            text = "[Shaman] Talk to Kranal. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1524,
            when = "accepted",
            map = 1413,
            x = 55.86,
            y = 19.95,
            details = {
                "Turn in Call of Fire",
                "NPC: Kranal Fiss",
            },
        },
        {
            text = "[Shaman] Travel the path up the mountain to Telf. Be careful to not fall of the mountain, the path is very narrow. You could die if you fall.",
            map = 1411,
            x = 39.16,
            y = 58.56,
        },
        {
            text = "[Shaman] Talk to Telf. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1525,
            when = "accepted",
            map = 1411,
            x = 38.52,
            y = 58.93,
            details = {
                "Turn in Call of Fire",
                "NPC: Telf Joolam",
            },
        },
        {
            text = "[Warrior] Turn in Veteran Uzzek. Accept Path of Defense.",
            quest = 1498,
            when = "accepted",
            map = 1413,
            x = 61.4,
            y = 21.1,
            details = {
                "Turn in Veteran Uzzek",
            },
        },
        {
            text = "[Warrior] Kill Lightning Hides. Loot them for their Scales.",
            quest = 1498,
            map = 1411,
            x = 39.34,
            y = 28.25,
            details = {
                "Singed Scale (5)",
                "Kill Lightning Hide",
            },
        },
        {
            text = "[Warrior] Talk to Uzzek. Turn in Path of Defense. Accept Thun'grim Firegaze.",
            quest = 1502,
            when = "accepted",
            map = 1413,
            x = 61.4,
            y = 21.1,
            details = {
                "Turn in Path of Defense",
            },
        },
    },
})
