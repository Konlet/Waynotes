local _, ns = ...

-- The Barrens leveling for WoW Forever.
-- classes and excludeClasses choose who sees a step. races and excludeRaces do the same for race.
-- when = "accepted" moves on once the quest is in your log.
-- when = "complete" moves on once the quest is turned in.
-- when = "objectives" moves on once its objectives are finished.
-- mode = "softcore" or "hardcore" is that branch. Hardcore steps in options follows the other one.
-- Pins omitted: QuestieDB supplies NPC coordinates for accept and turn-in steps.

ns.RegisterGuide({
    id = "horde-12-17-the-barrens",
    name = "12-17 The Barrens",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Talk to Takrin. Accept Conscript of the Horde.",
            quest = 840,
            when = "accepted",
            details = {
                "NPC: Takrin Pathseeker",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Go into Dustwind Cave.",
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Kill Cultists. Loot them for a Reagent Pouch.",
            quest = 1525,
            when = "objectives",
            details = {
                "Reagent Pouch (1)",
                "Kill Burning Blade Cultist",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Talk to Kargal. Turn in Conscript of the Horde. Accept Crossroads Conscription.",
            quest = 842,
            when = "accepted",
            details = {
                "Turn in Conscript of the Horde",
                "NPC: Kargal Battlescar",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Travel to the top of the mountain.",
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Talk to Thun'grim. Turn in Thun'grim Firegaze. Accept Forged Steel.",
            quest = 1503,
            when = "accepted",
            details = {
                "Turn in Thun'grim Firegaze",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Loot the Stolen Iron Chest for its Forged Steel Bars.",
            quest = 1503,
            when = "objectives",
            details = {
                "Forged Steel Bars (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Travel to the top of the mountain.",
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Talk to Thun'grim. Turn in Forged Steel.",
            quest = 1503,
            when = "complete",
            details = {
                "NPC: Thun'grim Firegaze",
            },
        },
        {
            excludeRaces = { "Tauren" },
            text = "Travel to The Crossroads.",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Tonga. Accept The Forgotten Pools.",
            quest = 870,
            when = "accepted",
            mode = "softcore",
            details = {
                "NPC: Tonga Runetotem",
            },
        },
        {
            races = { "Orc", "Troll" },
            text = "Talk to Zargh. Accept Meats to Orgrimmar.",
            quest = 6365,
            when = "accepted",
            mode = "hardcore",
        },
        {
            excludeClasses = { "Druid" },
            excludeRaces = { "Tauren" },
            text = "Talk to Sergra. Turn in Crossroads Conscription.",
            quest = 842,
            when = "complete",
            details = {
                "NPC: Sergra Darkthorn",
            },
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Sergra Darkthorn. Accept Plainstrider Menace.",
            quest = 844,
            when = "accepted",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Sergra. Accept Plainstrider Menace.",
            quest = 844,
            when = "accepted",
            details = {
                "NPC: Sergra Darkthorn",
            },
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Tonga. Accept The Forgotten Pools.",
            quest = 870,
            when = "accepted",
            mode = "hardcore",
            details = {
                "NPC: Tonga Runetotem",
            },
        },
        {
            races = { "Skyborne" },
            text = "Talk to Thork. Turn in Journey to the Crossroads.",
            quest = 98024,
            when = "complete",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Thork. Accept Disrupt the Attacks. Accept Supplies for the Crossroads.",
            quests = { 871, 5041 },
            when = "accepted",
        },
        {
            races = { "Skyborne" },
            text = "Optional: Talk to Thork. Turn in Journey to the Crossroads.",
            quest = 98024,
            when = "complete",
        },
        {
            races = { "Orc", "Troll" },
            text = "Talk to Devrak. Do NOT fly to Orgrimmar! Turn in Meats to Orgrimmar. Accept Ride to Orgrimmar.",
            quest = 6384,
            when = "accepted",
            mode = "hardcore",
            details = {
                "Turn in Meats to Orgrimmar",
            },
        },
        {
            races = { "Undead", "Skyborne" },
            text = "Talk to Devrak. Get the Crossroads flight path.",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Helbrim. Accept Wharfmaster Dizzywig. Accept Fungal Spores. Turn in Sample for Helbrim.",
            quests = { 1492, 848 },
            when = "accepted",
            details = {
                "Turn in Sample for Helbrim",
                "NPC: Apothecary Helbrim",
            },
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Helbrim. Accept Wharfmaster Dizzywig. Accept Fungal Spores.",
            quests = { 1492, 848 },
            when = "accepted",
            details = {
                "NPC: Apothecary Helbrim",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll", "Skyborne" },
            text = "Talk to Uthrok. Buy a [Laminated Recurve Bow] from him.",
            details = {
                "Collect Laminated Recurve Bow (1)",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll", "Skyborne" },
            text = "Optional: Equip the [Laminated Recurve Bow].",
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Talk to Uthrok. Buy a [Hunter's Boomstick] from him.",
            details = {
                "Collect Hunter's Boomstick (1)",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Optional: Equip the [Hunter's Boomstick].",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Gazrog. Accept Raptor Thieves.",
            quest = 869,
            when = "accepted",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Innkeeper Boorand. Set your Hearthstone to Crossroads.",
            details = {
                "NPC: Innkeeper Boorand Plainswind",
            },
        },
        {
            races = { "Orc", "Troll" },
            text = "Talk to Zargh. Accept Meats to Orgrimmar.",
            quest = 6365,
            when = "accepted",
            mode = "softcore",
        },
        {
            excludeRaces = { "Undead", "Tauren", "Skyborne" },
            text = "Travel to the top of the mountain.",
        },
        {
            excludeRaces = { "Undead", "Tauren", "Skyborne" },
            text = "Go inside Dreadmist Den.",
        },
        {
            excludeRaces = { "Undead", "Tauren", "Skyborne" },
            text = "Right click the Altar. Make sure you have a [Flawed Power Stone] (30 minute duration) on you.",
            quest = 924,
            when = "objectives",
            details = {
                "Destroy the Demon Seed (1)",
            },
        },
        {
            text = "Loot Chen's Empty Keg from the ground and start the quest. You can get it later if it's not there. Accept Chen's Empty Keg.",
            quest = 819,
            when = "accepted",
        },
        {
            text = "Kill Water Seekers, Thornweavers and Hunters.",
            quest = 871,
            when = "objectives",
            details = {
                "Razormane Water Seeker (8)",
                "Kill Razormane Water Seeker",
                "Razormane Thornweaver (8)",
                "Kill Razormane Thornweaver",
                "Razormane Hunter (3)",
                "Kill Razormane Hunter",
                "Optional: Kill Water Seekers, Thornweavers and Hunters",
            },
        },
        {
            text = "Kill Plainstriders. Loot them for their Beaks.",
            quest = 844,
            when = "objectives",
            details = {
                "Plainstrider Beak (7)",
                "Kill Greater Plainstrider",
                "Kill Fleeting Plainstrider",
                "Optional: Kill Plainstriders. Loot them for their Beaks",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Talk to Sergra. Turn in Crossroads Conscription.",
            quest = 842,
            when = "complete",
            details = {
                "NPC: Sergra Darkthorn",
            },
        },
        {
            text = "Talk to Sergra Darkthorn. Turn in Plainstrider Menace. Accept The Zhevra.",
            quest = 845,
            when = "accepted",
            details = {
                "Turn in Plainstrider Menace",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Optional: Talk to Sergra. Turn in Plainstrider Menace. Accept The Zhevra.",
            quest = 845,
            when = "accepted",
            details = {
                "Turn in Plainstrider Menace",
                "NPC: Sergra Darkthorn",
            },
        },
        {
            text = "Talk to Thork. Turn in Disrupt the Attacks. Accept The Disruption Ends.",
            quest = 872,
            when = "accepted",
            details = {
                "Turn in Disrupt the Attacks",
            },
        },
        {
            text = "Optional: Talk to Thork. Accept The Disruption Ends.",
            quest = 872,
            when = "accepted",
        },
        {
            text = "Talk to Darsok. He is at the top of the tower. Accept Harpy Raiders.",
            quest = 867,
            when = "accepted",
            details = {
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            races = { "Orc", "Troll" },
            text = "Talk to Devrak. Do NOT fly to Orgrimmar! Turn in Meats to Orgrimmar. Accept Ride to Orgrimmar.",
            quest = 6384,
            when = "accepted",
            mode = "softcore",
            details = {
                "Turn in Meats to Orgrimmar",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll", "Skyborne" },
            text = "Optional: Talk to Uthrok. Buy a [Laminated Recurve Bow] from him.",
            details = {
                "Collect Laminated Recurve Bow (1)",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Optional: Talk to Uthrok. Buy a [Hunter's Boomstick] from him.",
            details = {
                "Collect Hunter's Boomstick (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc", "Tauren", "Troll", "Skyborne" },
            text = "Check if Lizzarik is in the Crossroads. He sells potions and [Heavy Spiked Mace] which is a limited supply item. Look for Lizzarik.",
        },
        {
            excludeClasses = { "Warrior", "Rogue" },
            text = "Talk to Innkeeper Boorand. Stock up on food and water.",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Stock up on food.",
        },
        {
            text = "Loot Chen's Empty Keg from the ground and start the quest. Wait for the respawn if it's not up. Accept Chen's Empty Keg.",
            quest = 819,
            when = "accepted",
        },
        {
            text = "Kill Kreenig Snarlsnout. Loot him for his Tusk.",
            quest = 872,
            when = "objectives",
            details = {
                "Kreenig Snarlsnout's Tusk (1)",
                "Kill Kreenig Snarlsnout",
                "Optional: Kill Razormane Geomancers and Razormane Defenders",
                "Razormane Geomancer (8)",
                "Kill Razormane Geomancer",
                "Razormane Defender (8)",
                "Kill Razormane Defender",
            },
        },
        {
            text = "Loot the Crossroads' Supply Crates. It has multiple spawn locations.",
            quest = 5041,
            when = "objectives",
            details = {
                "Crossroads' Supply Crates (1)",
                "Optional: Loot the Crossroads' Supply Crates. It has multiple spawn locations",
            },
        },
        {
            text = "Kill Razormane Geomancers and Razormane Defenders.",
            quest = 872,
            when = "objectives",
            details = {
                "Razormane Geomancer (8)",
                "Kill Razormane Geomancer",
                "Razormane Defender (8)",
                "Kill Razormane Defender",
                "Optional: Kill Razormane Geomancers and Razormane Defenders",
            },
        },
        {
            excludeRaces = { "Undead", "Tauren", "Skyborne" },
            text = "Talk to Ak'Zeloth. Turn in The Demon Seed.",
            quest = 924,
            when = "complete",
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Travel toward Durotar.",
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Travel the path up the mountain toward Telf.",
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Talk to Telf. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1526,
            when = "accepted",
            details = {
                "Turn in Call of Fire",
                "NPC: Telf Joolam",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Use the [Fire Sapta].",
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Kill the Minor Manifestation of Fire. Loot him for a Glowing Ember.",
            quest = 1526,
            when = "objectives",
            details = {
                "Glowing Ember (1)",
                "Kill Minor Manifestation of Fire",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Click the Brazier on the ground. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1527,
            when = "accepted",
            details = {
                "Turn in Call of Fire",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Talk to Kranal. Turn in Call of Fire.",
            quest = 1527,
            when = "complete",
            details = {
                "NPC: Kranal Fiss",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Loot Chen's Empty Keg from the ground and start the quest. Wait for the respawn if it's not up. Accept Chen's Empty Keg.",
            quest = 819,
            when = "accepted",
        },
        {
            text = "Travel to Ratchet.",
        },
        {
            text = "Talk to Wrenix. Accept Parts and Pieces.",
            quest = 97253,
            when = "accepted",
            details = {
                "NPC: Wrenix the Wretched",
            },
        },
        {
            text = "Talk to Gazlowe. Accept Southsea Freebooters.",
            quest = 887,
            when = "accepted",
        },
        {
            text = "Talk to Bragok. Get the Ratchet flight path.",
        },
        {
            text = "Talk to Sputtervalve and the Wanted Poster. Accept Samophlange. Accept WANTED: Baron Longshore.",
            quests = { 894, 895 },
            when = "accepted",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Talk to Ironzar. Buy a [Espadon] from him.",
            details = {
                "Collect Espadon (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Optional: Equip the [Espadon] when you are level 16.",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Optional: Equip the [Espadon].",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Ironzar. Buy a [Gnarled Staff] from him.",
            details = {
                "Collect Gnarled Staff (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Optional: Equip the [Gnarled Staff].",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Ironzar. Buy a [Bearded Axe] from him.",
            details = {
                "Collect Bearded Axe (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Optional: Equip the [Bearded Axe].",
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Talk to Ironzar. Buy a [Rock Hammer] from him.",
            details = {
                "Collect Rock Hammer (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Optional: Equip the [Rock Hammer] when you are level 16.",
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Optional: Equip the [Rock Hammer].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Ironzar. Buy a [Gnarled Staff] from him.",
            details = {
                "Collect Gnarled Staff (1)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Equip the [Gnarled Staff].",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Ironzar. Buy a [Scimitar] from him.",
            details = {
                "Collect Scimitar (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Optional: Equip the [Scimitar].",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Ironzar. Buy a second [Scimitar] from him for your off-hand.",
            details = {
                "Collect Scimitar(1)",
            },
        },
        {
            text = "Talk to Drohn. Turn in Chen's Empty Keg. Accept Chen's Empty Keg.",
            quest = 821,
            when = "accepted",
            details = {
                "Turn in Chen's Empty Keg",
                "NPC: Brewmaster Drohn",
            },
        },
        {
            text = "Optional: Talk to Drohn. Accept Chen's Empty Keg.",
            quest = 821,
            when = "accepted",
            details = {
                "NPC: Brewmaster Drohn",
            },
        },
        {
            classes = { "Priest", "Shaman", "Mage", "Warlock", "Druid" },
            text = "Talk to Innkeeper Wiley. Buy [Melon Juice] from him. Vendor Trash.",
            details = {
                "Melon Juice (10)",
            },
        },
        {
            text = "Kill Baron Longshore. Loot him for his Head. He can be found in one of the camps. Look for Baron Longshore.",
            quest = 895,
            when = "objectives",
            details = {
                "Baron Longshore's Head (1)",
            },
        },
        {
            text = "Kill Southsea Brigands and Southsea Cannoneers.",
            quest = 887,
            when = "objectives",
            details = {
                "Southsea Brigand (12)",
                "Kill Southsea Brigand",
                "Southsea Cannoneer (6)",
                "Kill Southsea Cannoneer",
                "Optional: Kill Southsea Brigands and Southsea Cannoneers",
            },
        },
        {
            text = "Loot the Handful of Complicated Parts on the ground.",
            quest = 97253,
            when = "objectives",
            details = {
                "5/5 Handful of Complicated Parts",
            },
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Kill Tazan. Loot him for his Satchel. He spawns at the first camp and patrols up the hill. Look for Tazan.",
            quest = 1963,
            when = "objectives",
            details = {
                "Tazan's Satchel (1)",
                "Optional: Kill Tazan. Loot him for his Satchel. He spawns at the first camp and patrols up the hill. Look for Tazan",
            },
        },
        {
            text = "Talk to Gazlowe. Turn in Southsea Freebooters. Turn in WANTED: Baron Longshore. Accept The Missing Shipment.",
            quest = 890,
            when = "accepted",
            details = {
                "Turn in WANTED: Baron Longshore",
                "Turn in Southsea Freebooters",
            },
        },
        {
            text = "Talk to Wrenix. Turn in Parts and Pieces.",
            quest = 97253,
            when = "complete",
            details = {
                "NPC: Wrenix the Wretched",
            },
        },
        {
            text = "Talk to Dizzywig. Turn in Wharfmaster Dizzywig. Turn in The Missing Shipment. Accept The Missing Shipment. Accept Miner's Fortune.",
            quests = { 892, 896 },
            when = "accepted",
            details = {
                "Turn in The Missing Shipment",
                "Turn in Wharfmaster Dizzywig",
            },
        },
        {
            text = "Talk to Gazlowe. Turn in The Missing Shipment. Accept Stolen Booty.",
            quest = 888,
            when = "accepted",
            details = {
                "Turn in The Missing Shipment",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Talk to Ironzar. Buy a [Espadon] from him.",
            details = {
                "Collect Espadon (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Optional: Equip the [Espadon] when you are level 16.",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Optional: Equip the [Espadon].",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Ironzar. Buy a [Gnarled Staff] from him.",
            details = {
                "Collect Gnarled Staff (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Optional: Equip the [Gnarled Staff].",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Ironzar. Buy a [Bearded Axe] from him.",
            details = {
                "Collect Bearded Axe (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Optional: Equip the [Bearded Axe].",
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Talk to Ironzar. Buy a [Rock Hammer] from him.",
            details = {
                "Collect Rock Hammer (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Optional: Equip the [Rock Hammer] when you are level 16.",
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Optional: Equip the [Rock Hammer].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Ironzar. Buy a [Gnarled Staff] from him.",
            details = {
                "Collect Gnarled Staff (1)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Equip the [Gnarled Staff].",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Ironzar. Buy a [Scimitar] from him.",
            details = {
                "Collect Scimitar (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Optional: Equip the [Scimitar].",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Ironzar. Buy a second [Scimitar] from him for your off-hand.",
            details = {
                "Collect Scimitar (1)",
            },
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Bragok. Fly to The Crossroads.",
        },
        {
            text = "Finish killing Zhevras. Loot them for their Hooves.",
            quest = 845,
            when = "objectives",
            details = {
                "Zhevra Hooves (4)",
                "Kill Zhevra Runner",
                "Optional: Kill any Zhevra you see. Loot them for their Hooves",
                "Optional: Kill Zhevra Runners. Loot them for their Hooves",
            },
        },
        {
            classes = { "Druid" },
            races = { "Tauren" },
            text = "Cast [Teleport: Moonglade].",
        },
        {
            classes = { "Druid" },
            races = { "Tauren" },
            text = "Talk to Loganaar. Train your class spells.",
        },
        {
            classes = { "Druid" },
            races = { "Tauren" },
            text = "Talk to Loganaar. Train your class spells.",
        },
        {
            races = { "Tauren" },
            text = "Hearth to Thunder Bluff.",
        },
        {
            races = { "Tauren" },
            text = "Talk to Ahanu. Turn in Ride to Thunder Bluff. Accept Tal the Wind Rider Master.",
            quest = 6363,
            when = "accepted",
            details = {
                "Turn in Ride to Thunder Bluff",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Talk to Tigor. Train your class spells.",
            details = {
                "NPC: Tigor Skychaser",
            },
        },
        {
            classes = { "Shaman" },
            races = { "Tauren" },
            text = "Optional: Talk to Tigor. Train your class spells.",
            details = {
                "NPC: Tigor Skychaser",
            },
        },
        {
            classes = { "Warrior", "Hunter" },
            races = { "Tauren" },
            text = "Travel to the Hunter Rise.",
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Talk to Urek. Train your class spells.",
            details = {
                "NPC: Urek Thunderhorn",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Talk to Hesuwa. Train your pet spells.",
            details = {
                "NPC: Hesuwa Thunderhorn",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Talk to Torm. Train your class spells.",
            details = {
                "NPC: Torm Ragetotem",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Tauren" },
            text = "Talk to Torm. Train your class spells.",
            details = {
                "NPC: Torm Ragetotem",
            },
        },
        {
            races = { "Tauren" },
            text = "Turn in Tal the Wind Rider Master. Accept Return to Jahan.",
            quest = 6364,
            when = "accepted",
            details = {
                "Turn in Tal the Wind Rider Master",
            },
        },
        {
            races = { "Tauren" },
            text = "Talk to Tal. Fly to Crossroads.",
        },
        {
            races = { "Tauren" },
            text = "Talk to Innkeeper Boorand. Set your Hearthstone to Crossroads.",
            details = {
                "NPC: Innkeeper Boorand Plainswind",
            },
        },
        {
            text = "Talk to Thork. Turn in Supplies for the Crossroads. Turn in The Disruption Ends.",
            quests = { 5041, 872 },
            when = "complete",
        },
        {
            text = "Talk to Sergra. Turn in The Zhevra. Accept Prowlers of the Barrens.",
            quest = 903,
            when = "accepted",
            details = {
                "Turn in The Zhevra",
                "NPC: Sergra Darkthorn",
            },
        },
        {
            races = { "Tauren" },
            text = "Talk to Jahan. Turn in Return to Jahan.",
            quest = 6364,
            when = "complete",
            details = {
                "NPC: Jahan Hawkwing",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll" },
            text = "Talk to Barg. Buy [Sharp Arrows] from him.",
            details = {
                "Sharp Arrow (1200)",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Talk to Barg. Buy [Heavy Shots] from him.",
            details = {
                "Heavy Shot (1000)",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll", "Skyborne" },
            text = "Talk to Uthrok. Buy a [Fine Longbow] from him if it's available and stock up on arrows. If it's not up, buy a [Reinforced Bow] instead.",
            details = {
                "Sharp Arrow (1200)",
            },
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Talk to Uthrok. Buy a [Hunter's Boomstick] from him.",
            details = {
                "Collect Hunter's Boomstick (1)",
            },
        },
        {
            text = "Talk to Regthar. Accept Kolkar Leaders. Accept Centaur Bracers.",
            quests = { 850, 855 },
            when = "accepted",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Optional: Talk to Regthar. Accept Kolkar Leaders.",
            quest = 850,
            when = "accepted",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Dive underwater to the Bubbling Fissure.",
            quest = 870,
            when = "objectives",
            details = {
                "Explore the waters of the Forgotten Pools",
            },
        },
        {
            text = "Kill Barak Kodobane. Loot him for his Head. Be careful as Barak Kodobane's melee hits deal a LOT of damage and he is protected by a Kolkar Wrangler. They can net you and shoot at you from ranged distance.",
            quest = 850,
            when = "objectives",
            details = {
                "Kodobane's Head (1)",
                "Kill Barak Kodobane",
            },
        },
        {
            text = "Talk to Regthar. Turn in Kolkar Leaders. Accept Verog the Dervish. Turn in Centaur Bracers.",
            quest = 851,
            when = "accepted",
            details = {
                "Turn in Centaur Bracers",
                "Turn in Kolkar Leaders",
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Kolkar Leaders. Accept Verog the Dervish.",
            quest = 851,
            when = "accepted",
            details = {
                "Turn in Kolkar Leaders",
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Optional: Talk to Regthar. Accept Verog the Dervish.",
            quest = 851,
            when = "accepted",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Kill Witchwing Harpies and Witchwing Roguefeathers. Loot them for their Talons.",
            quest = 867,
            when = "objectives",
            details = {
                "Witchwing Talon (8)",
                "Kill Witchwing Harpy",
                "Kill Witchwing Roguefeather",
            },
        },
        {
            text = "Be careful of Sunscale Scytheclaws in the area. They are up to level 18 and can [Thrash].",
        },
        {
            text = "Talk to Vrang. Accept Bruised Pride and Lion Hides. Accept Vrang's Game.",
            quests = { 95494, 95507 },
            when = "accepted",
            details = {
                "NPC: Vrang Wildgore",
            },
        },
        {
            classes = { "Warrior", "Shaman" },
            races = { "Tauren" },
            text = "Talk to Vrang. Vrang sells [Heavy Spiked Mace] which is a limited supply item.",
        },
        {
            classes = { "Druid" },
            text = "Talk to Vrang. Vrang sells [Heavy Spiked Mace] which is a limited supply item.",
        },
        {
            text = "Talk to Vrang Wildgore. Vendor trash and repair.",
        },
        {
            text = "Kill Savannah Patriarchs. Loot them for their Hides and Tusks. If the Savannah Patriarchs are heavily contested consider skipping this quest for now, it can be completed later.",
            quests = { 95494, 821 },
            when = "objectives",
            details = {
                "6/6 Savannah Lion Hide",
                "Savannah Lion Tusk (5)",
                "Kill Savannah Patriarch",
                "Optional: Kill Plainstriders. Loot them for their Kidneys",
                "Plainstrider Kidney (5)",
                "Kill Greater Plainstrider",
                "Kill Fleeting Plainstrider",
                "Kill Savannah Prowlers. Loot them for their Claws and Tusks",
            },
        },
        {
            text = "Optional: Kill Savannah Patriarchs. Loot them for their Hides. If the Savannah Patriarchs are heavily contested consider skipping this quest for now, it can be completed later.",
            quest = 95494,
            when = "objectives",
            details = {
                "6/6 Savannah Lion Hide",
                "Kill Savannah Patriarch",
            },
        },
        {
            text = "Loot the Sprung Traps on the ground.",
            quest = 95507,
            when = "objectives",
            details = {
                "8/8 Trapped Game",
            },
        },
        {
            text = "Turn in Bruised Pride and Lion Hides. Turn in Vrang's Game. Accept The Hermit Tanner.",
            quest = 95495,
            when = "accepted",
            details = {
                "Turn in Vrang's Game",
                "Turn in Bruised Pride and Lion Hides",
                "NPC: Vrang Wildgore",
            },
        },
        {
            text = "Travel up the mountain.",
        },
        {
            text = "Talk to Walton. Turn in The Hermit Tanner. Accept Trouble in the Valley.",
            quest = 95621,
            when = "accepted",
            details = {
                "Turn in The Hermit Tanner",
            },
        },
        {
            text = "Kill Corporal Adamore. Be careful! You may aggro 2-3 mobs at the same time.",
            quest = 95621,
            when = "objectives",
            details = {
                "1/1 Learn why the Kul Tirans are here",
                "Kill Corporal Adamore",
            },
        },
        {
            text = "Travel up the mountain.",
        },
        {
            text = "Talk to Walton. Turn in Trouble in the Valley. Accept Unwelcome Guests.",
            quest = 95508,
            when = "accepted",
            details = {
                "Turn in Trouble in the Valley",
            },
        },
        {
            text = "Move behind the house as you wait for the RP to finish to avoid getting aggro by all mobs at once. You don't actually need to assist Walton, he will survive with the help of Vrang Wildgore.",
            quest = 95508,
            when = "objectives",
            details = {
                "1/1 Assist Walton",
                "Kill Terry Longdrink",
            },
        },
        {
            text = "Talk to Walton. Turn in Unwelcome Guests.",
            quest = 95508,
            when = "complete",
        },
        {
            text = "Click on the Control Console. Turn in Samophlange. Accept Samophlange.",
            quest = 900,
            when = "accepted",
            details = {
                "Turn in Samophlange",
            },
        },
        {
            text = "Click the Valve. Be careful! Two mobs will spawn after you shut off the Valve.",
            quest = 900,
            when = "objectives",
            details = {
                "Shut off Main Control Valve (1)",
            },
        },
        {
            text = "Click the Valve. One mob will spawn after you shut off the Valve.",
            quest = 900,
            when = "objectives",
            details = {
                "Shut off Regulator Valve (1)",
            },
        },
        {
            text = "Click the Valve.",
            quest = 900,
            when = "objectives",
            details = {
                "Shut off Fuel Control Valve (1)",
            },
        },
        {
            text = "Click the Control Console. Turn in Samophlange. Accept Samophlange.",
            quest = 901,
            when = "accepted",
            details = {
                "Turn in Samophlange",
            },
        },
        {
            text = "Kill Tinkerer Sniggles in the building. Loot him for his Console Key.",
            quest = 901,
            when = "objectives",
            details = {
                "Console Key (1)",
                "Kill Tinkerer Sniggles",
            },
        },
        {
            text = "Click the Control Console. Turn in Samophlange. Accept Samophlange.",
            quest = 902,
            when = "accepted",
            details = {
                "Turn in Samophlange",
            },
        },
        {
            text = "Kill Raptors. Loot them for their Heads.",
            quest = 869,
            when = "objectives",
            details = {
                "Raptor Head (12)",
                "Kill Sunscale Lashtail",
                "Kill Sunscale Screecher",
                "Kill Sunscale Scytheclaw",
                "Optional: Kill every Raptor you see. Loot them for their Heads",
                "Kill every Raptor you see. Loot them for their Heads",
            },
        },
        {
            text = "Kill Savannah Prowlers. Loot them for their Claws and Tusks.",
            quests = { 903, 821 },
            when = "objectives",
            details = {
                "Prowler Claws (7)",
                "Savannah Lion Tusk (5)",
                "Kill Savannah Prowler",
                "Optional: Kill Savannah Prowlers. Loot them for their Claws",
                "Optional: Kill Plainstriders. Loot them for their Kidneys",
                "Plainstrider Kidney (5)",
                "Kill Greater Plainstrider",
                "Kill Fleeting Plainstrider",
            },
        },
        {
            text = "Optional: Kill Savannah Prowlers. Loot them for their Claws.",
            quest = 903,
            when = "objectives",
            details = {
                "Prowler Claws (7)",
                "Kill Savannah Prowler",
            },
        },
        {
            text = "Optional: Grinding to level 16 here is important, due to the next 3 quests being quite hard.",
        },
        {
            text = "Talk to Wizzlecrank's Shredder in The Sludge Fen. Wizzlecrank's Shredder has a long respawn timer. Consider skipping this quest if there is a lot of competition. Accept Ignition.",
            quest = 858,
            when = "accepted",
        },
        {
            text = "Look for Foreman Grills. Look for Sludge Beast.",
            note = "Be careful if Foreman Grills or Sludge Beast is up. They are strong level 19 rare mobs",
        },
        {
            text = "Kill Supervisor Lugwizzle. Loot him for his Key. He patrols up and down the platform.",
            quest = 858,
            when = "objectives",
            details = {
                "Ignition Key (1)",
                "Kill Supervisor Lugwizzle",
            },
        },
        {
            text = "Wizzlecrank's Shredder has a long respawn timer. Consider skipping this quest if there is a lot of competition. This will begin an escort. Make sure you're at full health. Turn in Ignition.",
            quest = 858,
            when = "complete",
        },
        {
            text = "Optional: Wizzlecrank's Shredder has a long respawn timer. Consider skipping this quest if there is a lot of competition. This will begin an escort. Make sure you're at full health.",
        },
        {
            text = "Two Venture Co. Mercenaries will spawn when the shredder moves onto the higher ground. Kill them then wait for his RP event at the end.",
            quest = 863,
            when = "objectives",
            details = {
                "Escort Wizzlecrank out of the Venture Co. drill site (1)",
                "Kill Venture Co. Mercenary",
                "Kill Venture Co. Drudger",
                "Kill Overseer Glibby",
            },
        },
        {
            text = "Kill Venture Co. Enforcers and Venture Co. Overseers. Loot them for Cats Eye Emerald. If it hasn't dropped after 25+ mobs, feel free to skip this quest.",
            quest = 896,
            when = "objectives",
            details = {
                "Cats Eye Emerald (1)",
                "Kill Venture Co. Enforcer",
                "Kill Venture Co. Overseer",
            },
        },
        {
            text = "Enter Orgrimmar through the western entrance.",
        },
        {
            text = "Talk to Arnok. Skip this step if you did not have enough [Linen Cloth] to reach 40 skill. Train [Heavy Linen Bandage].",
        },
        {
            text = "Talk to Arnok. Skip this step if you did not have enough [Linen Cloth] to reach 50 skill. Train Journeyman First Aid.",
        },
        {
            classes = { "Priest" },
            text = "Optional: Talk to Ur'kyo. Train your class spells.",
        },
        {
            classes = { "Priest" },
            text = "Optional: Talk to Ur'kyo. Train your class spells.",
        },
        {
            classes = { "Mage" },
            text = "Talk to Pephredo. Train your class spells.",
        },
        {
            classes = { "Mage" },
            text = "Optional: Talk to Pephredo. Train your class spells.",
        },
        {
            races = { "Orc", "Troll" },
            text = "Talk to Gryshka. Turn in Ride to Orgrimmar. Accept Doras the Wind Rider Master.",
            quest = 6385,
            when = "accepted",
            details = {
                "Turn in Ride to Orgrimmar",
                "NPC: Innkeeper Gryshka",
            },
        },
        {
            races = { "Orc", "Troll" },
            text = "Turn in Doras the Wind Rider Master. Accept Return to the Crossroads.",
            quest = 6386,
            when = "accepted",
            details = {
                "Turn in Doras the Wind Rider Master",
            },
        },
        {
            races = { "Orc", "Troll" },
            text = "Optional: Talk to Doras. Accept Return to the Crossroads.",
            quest = 6386,
            when = "accepted",
        },
        {
            races = { "Undead", "Tauren" },
            text = "Talk to Doras. Don't fly anywhere! Get the Orgrimmar flight path.",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Grezz. Train your class spells.",
            details = {
                "NPC: Grezz Ragefist",
            },
        },
        {
            classes = { "Warrior" },
            text = "Optional: Talk to Grezz. Train your class spells.",
            details = {
                "NPC: Grezz Ragefist",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ormak. Train your class spells.",
            details = {
                "NPC: Ormak Grimshot",
            },
        },
        {
            classes = { "Hunter" },
            text = "Optional: Talk to Ormak. Train your class spells.",
            details = {
                "NPC: Ormak Grimshot",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Xao'tsu. Train your pet spells.",
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll" },
            text = "Talk to Hanashi. Train Staves.",
        },
        {
            classes = { "Priest" },
            text = "Talk to Hanashi. Train Staves.",
        },
        {
            classes = { "Hunter" },
            races = { "Tauren" },
            text = "Talk to Hanashi. Train Bows.",
        },
        {
            classes = { "Warrior" },
            excludeRaces = { "Skyborne" },
            text = "Talk to Hanashi. Train Two-Handed Axes. Train Staves.",
        },
        {
            classes = { "Warrior", "Paladin", "Shaman" },
            excludeRaces = { "Skyborne" },
            text = "Optional: Talk to Hanashi. Train Two-Handed Axes.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Zendo'jian. Buy a [Reinforced Bow] from him. Train a new skill.",
            details = {
                "Collect Reinforced Bow (1)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Optional: Equip the [Reinforced Bow].",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Zendo'jian. Buy a [Battle Axe] from him. Train a new skill.",
            details = {
                "Collect Battle Axe (1)",
            },
        },
        {
            classes = { "Warrior" },
            text = "Optional: Equip the [Battle Axe] when you are level 20.",
        },
        {
            classes = { "Warrior" },
            text = "Optional: Equip the [Battle Axe].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kardris. Train your class spells.",
            details = {
                "NPC: Kardris Dreamseeker",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Talk to Kardris. Train your class spells.",
            details = {
                "NPC: Kardris Dreamseeker",
            },
        },
        {
            text = "Talk to Zor. Accept The Spirits of Stonetalon.",
            quest = 1061,
            when = "accepted",
            details = {
                "NPC: Zor Lonetree",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Shenthul. Train [Pick Lock]. Train [Pick Pocket]. Accept Zando'Zan.",
            quest = 2379,
            when = "accepted",
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Talk to Therzok. Turn in The Shattered Hand. Accept The Shattered Hand.",
            quest = 1858,
            when = "accepted",
            details = {
                "Turn in The Shattered Hand",
            },
        },
        {
            classes = { "Rogue" },
            text = "Turn in Zando'zan. Accept Wrenix of Ratchet.",
            quest = 2382,
            when = "accepted",
            details = {
                "Turn in Zando'zan",
            },
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Optional: Talk to Rekkul. Buy a [Thieves' Tools] from him.",
            details = {
                "Collect Thieves' Tools (1)",
            },
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Use [Pick Lock] to open [Tazan's Satchel].",
            quest = 1858,
            when = "objectives",
            details = {
                "Tazan's Logbook (1)",
            },
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Talk to Therzok. Turn in The Shattered Hand.",
            quest = 1858,
            when = "complete",
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Use [Pick Pocket] on Gamon in the Inn. Use his key to open [Tazan's Satchel].",
            quest = 1858,
            when = "objectives",
            details = {
                "Tazan's Logbook (1)",
            },
        },
        {
            classes = { "Rogue" },
            races = { "Orc", "Troll" },
            text = "Talk to Therzok. Turn in The Shattered Hand.",
            quest = 1858,
            when = "complete",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Mirket. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Optional: Talk to Mirket. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Kurgul and buy [Grimoire of Sacrifice].",
            details = {
                "Grimoire of Sacrifice (Rank 1) (1)",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Kurgul and buy [Grimoire of Firebolt (Rank 3)].",
            details = {
                "Grimoire of Firebolt (Rank 3) (1)",
            },
        },
        {
            text = "Hearth to The Crossroads.",
        },
        {
            text = "Talk to Doras. Fly to The Crossroads.",
        },
        {
            excludeClasses = { "Warrior", "Rogue" },
            text = "Talk to Innkeeper Boorand. Sell your junk, then restock on food and water if necessary.",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Sell your junk, then restock on food if necessary.",
        },
        {
            text = "Talk to Gazrog. Turn in Raptor Thieves. Accept Stolen Silver.",
            quest = 3281,
            when = "accepted",
            details = {
                "Turn in Raptor Thieves",
            },
        },
        {
            text = "Talk to Helbrim. Turn in Fungal Spores.",
            quest = 848,
            when = "complete",
            details = {
                "NPC: Apothecary Helbrim",
            },
        },
        {
            text = "Talk to Darsok. Turn in Harpy Raiders. Accept Harpy Lieutenants.",
            quest = 875,
            when = "accepted",
            details = {
                "Turn in Harpy Raiders",
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            text = "Talk to Mankrik. Accept Consumed by Hatred. Accept Lost in Battle.",
            quests = { 899, 4921 },
            when = "accepted",
        },
        {
            text = "Talk to Tonga. Turn in The Forgotten Pools. Accept The Stagnant Oasis.",
            quest = 877,
            when = "accepted",
            details = {
                "Turn in The Forgotten Pools",
                "NPC: Tonga Runetotem",
            },
        },
        {
            text = "Talk to Sergra. Turn in Prowlers of the Barrens. Accept Echeyakee.",
            quest = 881,
            when = "accepted",
            details = {
                "Turn in Prowlers of the Barrens",
                "NPC: Sergra Darkthorn",
            },
        },
        {
            races = { "Orc", "Troll" },
            text = "Talk to Zargh. Turn in Return to the Crossroads.",
            quest = 6386,
            when = "complete",
        },
        {
            text = "Talk to Gur'ak. Accept Chol'aruk the Ravener.",
            quest = 97003,
            when = "accepted",
        },
        {
            text = "Completing this will give 4100xp. The entrance to the cave where he is located is marked on your map (Razormane area).",
            note = "As you continue to quest through The Barrens, try to find a 5-man group for \"Chol'aruk the Ravener\" at some point",
        },
        {
            text = "Use the [Horn of Echeyakee] to summon Echeyakee. Kill Echeyakee. Loot him for Echeyakee's Hide. If Echeyakee doesn't spawn after using the [Horn of Echeyakee] or you didn't get the tag when it did spawn, skip this step.",
            quest = 881,
            when = "objectives",
            details = {
                "Echeyakee's Hide (1)",
                "Kill Echeyakee",
            },
        },
        {
            text = "Optional: If Echeyakee didn't spawn after using the [Horn of Echeyakee]or you didn't get the tag when it did spawn, abandon Echeyakee, then return to town and accept it again.",
        },
        {
            text = "Talk to Sergra. Accept Echeyakee.",
            quest = 881,
            when = "accepted",
            details = {
                "NPC: Sergra Darkthorn",
            },
        },
        {
            text = "Use the [Horn of Echeyakee] to summon Echeyakee. Kill Echeyakee. Loot him for Echeyakee's Hide.",
            quest = 881,
            when = "objectives",
            details = {
                "Echeyakee's Hide (1)",
                "Kill Echeyakee",
            },
        },
        {
            text = "Talk to Sergra. Turn in Echeyakee. Accept The Angry Scytheclaws.",
            quest = 905,
            when = "accepted",
            details = {
                "Turn in Echeyakee",
                "NPC: Sergra Darkthorn",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Barg. Buy [Sharp Arrows] from him.",
            details = {
                "Sharp Arrow (1800)",
            },
        },
        {
            text = "Talk to Devrak. Fly to Ratchet.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Wrenix. Turn in Wrenix of Ratchet. Accept Plundering the Plunderers.",
            quest = 2381,
            when = "accepted",
            details = {
                "Turn in Wrenix of Ratchet",
                "NPC: Wrenix the Wretched",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Wrenix's Gizmotronic Apparatus. Obtain an [E.C.A.C.] and a [Thieves' Tools].",
            details = {
                "E.C.A.C. (1)",
                "Thieves' Tools (1)",
            },
        },
        {
            text = "Talk to Sputtervalve and Dizzywig. Turn in Samophlange. Turn in The Escape.",
            quests = { 902, 863 },
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Sputtervalve and Dizzywig. Accept Wenikee Boltbucket.",
            quest = 3921,
            when = "accepted",
        },
        {
            text = "Talk to Sputtervalve. Accept Ziz Fizziks.",
            quest = 1483,
            when = "accepted",
        },
        {
            text = "Optional: Talk to Sputtervalve and Dizzywig. Turn in Samophlange.",
            quest = 902,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Optional: Talk to Sputtervalve and Dizzywig. Accept Wenikee Boltbucket.",
            quest = 3921,
            when = "accepted",
        },
        {
            text = "Optional: Talk to Sputtervalve. Accept Ziz Fizziks.",
            quest = 1483,
            when = "accepted",
        },
        {
            text = "Talk to Dizzywig. Turn in Miner's Fortune.",
            quest = 896,
            when = "complete",
            details = {
                "NPC: Wharfmaster Dizzywig",
            },
        },
        {
            text = "Talk to Mebok. Accept Raptor Horns. Accept Deepmoss Spider Eggs.",
            quests = { 865, 1069 },
            when = "accepted",
            details = {
                "NPC: Mebok Mizzyrix",
            },
        },
        {
            classes = { "Rogue" },
            text = "Jump onto the ship, go down to the 2nd floor and level your lockpicking up to at least 70.",
        },
        {
            classes = { "Rogue" },
            text = "Once your lockpicking is 70, go to the bottom floor of the ship and open The Jewel of the Southsea. Use the [E.C.A.C.] on Polly.",
            quest = 2381,
            when = "objectives",
            details = {
                "Southsea Treasure (1)",
                "Kill Polly",
            },
        },
        {
            text = "Loot the Crate on the ground.",
            quest = 888,
            when = "objectives",
            details = {
                "Telescopic Lens (1)",
            },
        },
        {
            text = "Loot the Crate on the ground.",
            quest = 888,
            when = "objectives",
            details = {
                "Shipment of Boots (1)",
            },
        },
        {
            text = "Optional: Kill Sunscale Scytheclaws. Loot them for their Horns and Feathers. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds).",
            quest = 865,
            when = "objectives",
            details = {
                "Intact Raptor Horn (5)",
                "Sunscale Feather (3)",
                "Kill Sunscale Scytheclaw",
            },
        },
        {
            text = "Loot the Stolen Silver on the ground.",
            quest = 3281,
            when = "objectives",
            details = {
                "Stolen Silver (1)",
            },
        },
        {
            text = "Click the Bubbling Fissure underwater.",
            quest = 877,
            when = "objectives",
            details = {
                "Test the Dried Seeds (1)",
            },
        },
        {
            text = "Kill Verog. Loot him for his Head. He has a chance of spawning every time a Kolkar is killed. On a highly populated server or fresh launch, your best option is camping his spawnpoint. Look for Verog the Dervish.",
            quest = 851,
            when = "objectives",
            details = {
                "Verog's Head (1)",
            },
        },
        {
            text = "Collect Laden Mushrooms around The Stagnant Oasis.",
            quest = 848,
            when = "objectives",
            details = {
                "Collect Fungal Spores (x4)",
                "Optional: Collect Laden Mushrooms around The Forgotten Pools. This quest does not have to be completed now",
                "Optional: Collect Laden Mushrooms around The Stagnant Oasis",
            },
        },
        {
            text = "Click the Blue Raptor Nest. Kill more Sunscale Scytheclaws if you don't have a [Sunscale Feather]. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds).",
            quest = 905,
            when = "objectives",
            details = {
                "Visit Blue Raptor Nest (1)",
                "Kill Sunscale Scytheclaw",
            },
        },
        {
            text = "Click the Red Raptor Nest. Kill more Sunscale Scytheclaws if you don't have a [Sunscale Feather]. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds).",
            quest = 905,
            when = "objectives",
            details = {
                "Visit Red Raptor Nest (1)",
                "Kill Sunscale Scytheclaw",
            },
        },
        {
            text = "Click the Yellow Raptor Nest. Kill more Sunscale Scytheclaws if you don't have a [Sunscale Feather]. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds).",
            quest = 905,
            when = "objectives",
            details = {
                "Visit Yellow Raptor Nest (1)",
                "Kill Sunscale Scytheclaw",
            },
        },
        {
            text = "Optional: Kill Sunscale Scytheclaws. Loot them for their Horns. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds).",
            quest = 865,
            when = "objectives",
            details = {
                "Intact Raptor Horn (5)",
                "Kill Sunscale Scytheclaw",
            },
        },
        {
            text = "Talk to the Beaten Corpse.",
            quest = 4921,
            when = "objectives",
            details = {
                "Find Mankrik's Wife (1)",
            },
        },
        {
            text = "Kill Lakota'mani. Loot him for the [Hoof of Lakota'mani]. Use the [Hoof of Lakota'mani] to start the quest. He has 4 spawnpoints (marked on the map). Skip this step if you can't find him or can't kill him. You can come back for him later. Accept Lakota'Mani. Look for Lakota'mani.",
            quest = 883,
            when = "accepted",
        },
        {
            text = "Travel to Camp Taurajo.",
        },
        {
            text = "Talk to Innkeeper Byula. Set your Hearthstone to Camp Taurajo.",
        },
        {
            text = "Talk to Jorn Skyseer. Turn in Lakota'mani.",
            quest = 883,
            when = "complete",
        },
        {
            text = "Talk to Mangletooth. Accept Tribes at War.",
            quest = 878,
            when = "accepted",
        },
        {
            excludeRaces = { "Tauren" },
            text = "Talk to Omusa. Get the Camp Taurajo flight path.",
            details = {
                "NPC: Omusa Thunderhorn",
            },
        },
        {
            text = "Talk to Omusa Thunderhorn. Fly to The Crossroads.",
        },
        {
            text = "Talk to Helbrim. Turn in Fungal Spores.",
            quest = 848,
            when = "complete",
            details = {
                "NPC: Apothecary Helbrim",
            },
        },
        {
            text = "Talk to Mankrik, Tonga, Sergra and Gazrog. Turn in Lost in Battle. Accept Her Name Is Olgra. Turn in The Stagnant Oasis. Accept Altered Beings. Turn in The Angry Scytheclaws. Accept Jorn Skyseer. Turn in Stolen Silver.",
            quests = { 95774, 880, 3261 },
            when = "accepted",
            details = {
                "Turn in Stolen Silver",
                "Turn in The Angry Scytheclaws",
                "Turn in The Stagnant Oasis",
                "Turn in Lost in Battle",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Uthrok. Buy a [Medium Quiver] from him.",
            details = {
                "Medium Quiver (1)",
                "Sharp Arrow (2200)",
            },
        },
        {
            text = "Talk to Regthar. Turn in Verog the Dervish. Accept Hezrul Bloodmark. Turn in Centaur Bracers.",
            quest = 852,
            when = "accepted",
            details = {
                "Turn in Centaur Bracers",
                "Turn in Verog the Dervish",
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Verog the Dervish. Accept Hezrul Bloodmark.",
            quest = 852,
            when = "accepted",
            details = {
                "Turn in Verog the Dervish",
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Travel to the Lushwater Oasis.",
        },
        {
            text = "Optional: Kill Oasis Snapjaws as you're looking for Hezrul Bloodmark. Loot them for their Shells.",
            quest = 880,
            when = "objectives",
            details = {
                "Altered Snapjaw Shell (8)",
                "Kill Oasis Snapjaw",
            },
        },
        {
            text = "Find & kill Hezrul Bloodmark. Loot him for his Head. Hezrul patrols around the lake. Look for Hezrul Bloodmark.",
            quest = 852,
            when = "objectives",
            details = {
                "Hezrul's Head",
            },
        },
        {
            text = "Kill Kolkar around the oasis. Loot them for their Bracers. Feel free to skip this quest if you haven't had many drops yet so far.",
            quest = 855,
            when = "objectives",
            details = {
                "Centaur Bracers (15)",
                "Kill Kolkar Bloodcharger",
                "Kill Kolkar Pack runner",
                "Kill Kolkar Marauder",
                "Optional: Kill Kolkar Wranglers and Kolkar Stormers. Loot them for their Bracers. This quest does not have to be completed now",
                "Kill Kolkar Wrangler",
                "Kill Kolkar Stormer",
                "Optional: Kill Kolkar around the oasis. Loot them for their Bracers",
            },
        },
        {
            text = "Optional: Abandon Centaur Bracers as you have not looted enough previously to make it worthwhile to finish.",
        },
        {
            text = "Talk to Regthar. Turn in Hezrul Bloodmark. Turn in Centaur Bracers.",
            quests = { 852, 855 },
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Hezrul Bloodmark.",
            quest = 852,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Centaur Bracers.",
            quest = 855,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Skip it if you can't do this quest. You will have another opportunity to complete it at higher level.",
            note = "This next quest is very hard & grouping up is recommended. You can kite Warlord Krom'zar around using the building where the quest giver is located",
        },
        {
            text = "Talk to Regthar. Accept Counterattack!",
            quest = 4021,
            when = "accepted",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Kill Warlord Krom'zar (elite lvl 20) once he appears. Loot the Banner that he drops on the ground. Be careful! He is strong and is guarded by at least two Kolkar mobs. It can take up to 3 minutes until he spawns. Click here for a guide video on how you can kite Warlord Krom'zar. Look for Warlord Krom'zar.",
            quest = 4021,
            when = "objectives",
            details = {
                "Piece of Krom'zar's Banner (1)",
            },
        },
        {
            text = "Talk to Regthar. Turn in Counterattack!",
            quest = 4021,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Centaur Bracers.",
            quest = 855,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Counterattack!",
            quest = 4021,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Centaur Bracers.",
            quest = 855,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Kill Witchwing Slayers. Loot them for their Rings. Be careful as Witchwing Slayers cast [Execute] (deals a LOT of damage when you're at <20% health), and Witchwing Ambushers are [Stealthed] and patrol around. Watch out for Witchwing Ambushers. They are stealthed and patrol in the area.",
            quest = 875,
            when = "objectives",
            details = {
                "Harpy Lieutenant Ring (6)",
                "Kill Witchwing Slayer",
                "Kill Witchwing Ambusher",
            },
        },
        {
            text = "Travel toward Seereth.",
        },
        {
            text = "Talk to Seereth and Makaba. Turn in The Spirits of Stonetalon. Accept Goblin Invaders. Accept Avenge My Village.",
            quests = { 1062, 6548 },
            when = "accepted",
            details = {
                "Turn in The Spirits of Stonetalon",
                "NPC: Seereth Stonebreak, Makaba Flathoof",
            },
        },
        {
            text = "Optional: Talk to Seereth. Turn in The Spirits of Stonetalon. Accept Goblin Invaders.",
            quest = 1062,
            when = "accepted",
            details = {
                "Turn in The Spirits of Stonetalon",
                "NPC: Seereth Stonebreak",
            },
        },
    },
})

ns.RegisterGuide({
    id = "horde-17-22-stonetalon-barrens-ashenvale",
    name = "17-22 Stonetalon/Barrens/Ashenvale",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            text = "Kill Grimtotem Ruffians and Grimtotem Mercenaries.",
            quest = 6548,
            when = "objectives",
            details = {
                "Kill Grimtotem Ruffian (x8)",
                "Kill Grimtotem Ruffian",
                "Kill Grimtotem Mercenary (x6)",
                "Kill Grimtotem Mercenary",
            },
        },
        {
            text = "Talk to Makaba. Turn in Avenge My Village. Accept Kill Grundig Darkcloud.",
            quest = 6629,
            when = "accepted",
            details = {
                "Turn in Avenge My Village",
                "NPC: Makaba Flathoof",
            },
        },
        {
            text = "Optional: Talk to Makaba. Accept Kill Grundig Darkcloud.",
            quest = 6629,
            when = "accepted",
            details = {
                "NPC: Makaba Flathoof",
            },
        },
        {
            text = "Travel up the path to the bonfire.",
        },
        {
            text = "Kill Grundig Darkcloud and Grimtotem Brutes. Make sure you kill all six Grimtotem Brutes before starting the quest inside.",
            quest = 6629,
            when = "objectives",
            details = {
                "Kill Grundig Darkcloud (x1)",
                "Kill Grundig Darkcloud",
                "Kill Grimtotem Brute (x6)",
                "Kill Grimtotem Brute",
            },
        },
        {
            text = "Talk to Kaya.",
            details = {
                "NPC: Kaya Flathoof",
            },
        },
        {
            text = "Escort Kaya and stay close to her. Be careful! Three Grimtotems will spawn when you reach the bonfire in Camp Aparaje.",
            quest = 6523,
            when = "objectives",
            details = {
                "Kaya Escorted to Camp Aparaje",
                "NPC: Kaya Flathoof",
            },
        },
        {
            text = "Talk to Xen'Zilla. Accept Blood Feeders.",
            quest = 6461,
            when = "accepted",
        },
        {
            classes = { "Priest", "Mage", "Warlock" },
            text = "Click the Wanted Poster. Accept Arachnophobia.",
            quest = 6284,
            when = "accepted",
        },
        {
            classes = { "Priest", "Mage", "Warlock" },
            text = "Kill Besseleth. Loot her for for her Fang.",
        },
        {
            classes = { "Warlock" },
            text = "Clear the area around Besseleth. Be careful as she webs you. Keep her permanently feared with dots. This quest is optional. If you can't do it, skip this quest. You can try it again later.",
        },
        {
            classes = { "Priest", "Mage", "Warlock" },
            text = "Look for Besseleth.",
            quest = 6284,
            when = "objectives",
            details = {
                "Collect Besseleth's Fang (x1)",
            },
        },
        {
            classes = { "Priest", "Mage", "Warlock" },
            text = "Kill Deepmoss Creepers.",
            quest = 6461,
            when = "objectives",
            details = {
                "Kill Deepmoss Creeper (x10)",
                "Kill Deepmoss Creeper",
                "Kill every Deepmoss Creeper you see",
                "Kill Deepmoss Venomspitters and Deepmoss Creepers",
                "Kill Deepmoss Venomspitter (x7)",
                "Kill Deepmoss Venomspitter",
            },
        },
        {
            excludeClasses = { "Warlock" },
            text = "Kill Deepmoss Creepers.",
        },
        {
            classes = { "Rogue" },
            text = "Save any [Small Venom Sacs] you loot.",
        },
        {
            excludeClasses = { "Warlock" },
            text = "Kill Deepmoss Creeper (x10).",
            quest = 6461,
            when = "objectives",
            details = {
                "Kill Deepmoss Creeper",
            },
        },
        {
            text = "Travel to Sun Rock Retreat.",
        },
        {
            excludeClasses = { "Warrior", "Rogue" },
            text = "Talk to Innkeeper Jayka. Sell your junk, then restock on food and water if necessary.",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Sell your junk, then restock on food if necessary.",
        },
        {
            excludeClasses = { "Warrior" },
            text = "Talk to Jeeda on the second floor of the inn. Buy [Healing Potions] from her if they're up.",
        },
        {
            classes = { "Warrior" },
            text = "Buy [Healing Potions] and [Liferoot] from her if they're up.",
        },
        {
            text = "Talk to Maggran. Turn in Arachnophobia.",
            quest = 6284,
            when = "complete",
            details = {
                "NPC: Maggran Earthbinder",
            },
        },
        {
            text = "Talk to Tharm. Get the Sun Rock Retreat flight path.",
        },
        {
            text = "Travel toward Ziz.",
        },
        {
            text = "Talk to Ziz. Turn in Ziz Fizziks. Accept Super Reaper 6000.",
            quest = 1093,
            when = "accepted",
            details = {
                "Turn in Ziz Fizziks",
            },
        },
        {
            text = "Kill Deepmoss Venomspitters.",
        },
        {
            classes = { "Rogue" },
            text = "Save any [Small Venom Sacs] you loot.",
        },
        {
            text = "Kill Deepmoss Venomspitter (x7).",
            quest = 6461,
            when = "objectives",
            details = {
                "Kill Deepmoss Venomspitter",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Talk to Veenix. Buy a [Long Staff] from him.",
            details = {
                "Collect Long Staff (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc", "Tauren", "Troll" },
            text = "Optional: Equip the [Long Staff].",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Talk to Veenix. Buy an [Executioner's Sword] from him. If it's not up, buy a [Dacian Falx] instead.",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Optional: Equip the [Executioner's Sword].",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Skyborne" },
            text = "Optional: Equip the [Dacian Falx].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Veenix. Buy a [Long Staff] from him.",
            details = {
                "Collect Long Staff (1)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Equip the [Long Staff].",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Veenix. Buy a [Longsword] from him.",
            details = {
                "Collect Longsword (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Optional: Equip the [Longsword].",
        },
        {
            text = "Travel to Windshear Crag.",
        },
        {
            text = "Kill Venture Co. Operators. Loot them for their Blueprints.",
            quest = 1093,
            when = "objectives",
            details = {
                "Collect Super Reaper 6000 Blueprints (x1)",
                "Kill Venture Co. Operator",
            },
        },
        {
            text = "Kill Venture Co. Loggers.",
            quest = 1062,
            when = "objectives",
            details = {
                "Kill Venture Co. Logger (x15)",
                "Kill Venture Co. Logger",
            },
        },
        {
            text = "Loot the Spider Eggs near the trees. Be careful! The Deepmoss Hatchlings have a chance of summoning a level 22 Deepmoss Matriarch.",
            quest = 1069,
            when = "objectives",
            details = {
                "Collect Deepmoss Egg (x15)",
            },
        },
        {
            text = "Talk to Ziz. Turn in Super Reaper 6000. Accept Further Instructions.",
            quest = 1094,
            when = "accepted",
            details = {
                "Turn in Super Reaper 6000",
                "NPC: Ziz Fizziks",
            },
        },
        {
            text = "Finish killing Deepmoss Creepers.",
        },
        {
            classes = { "Rogue" },
            text = "Save any [Small Venom Sacs] you loot.",
        },
        {
            text = "Kill Deepmoss Creeper (x10).",
            quest = 6461,
            when = "objectives",
            details = {
                "Kill Deepmoss Creeper",
            },
        },
        {
            classes = { "Druid" },
            text = "Cast [Teleport: Moonglade].",
        },
        {
            classes = { "Druid" },
            text = "Talk to Loganaar. Train your class spells.",
        },
        {
            classes = { "Druid" },
            text = "Talk to Loganaar. Train your class spells.",
        },
        {
            text = "Hearth to Camp Taurajo.",
        },
        {
            excludeClasses = { "Warrior", "Rogue" },
            text = "Talk to Innkeeper Byula. Sell your junk, then restock on food and water if necessary.",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Sell your junk, then restock on food if necessary.",
        },
        {
            text = "Turn in Jorn Skyseer. Accept Ishamuhale.",
            quest = 882,
            when = "accepted",
            details = {
                "Turn in Jorn Skyseer",
            },
        },
        {
            text = "Kill Lakota'mani. Loot him for the [Hoof of Lakota'mani]. Use the [Hoof of Lakota'mani] to start the quest. He has 4 spawnpoints (marked on the map). Skip this step if you can't find him. Accept Lakota'Mani. Look for Lakota'mani.",
            quest = 883,
            when = "accepted",
        },
        {
            text = "Kill Razormane Raiders. Loot them for Olgra's Adornments.",
            quest = 95774,
            when = "objectives",
            details = {
                "4/4 Olgra's Adornments",
                "Kill Razormane Raider",
            },
        },
        {
            text = "Kill Bristleback Quilboars. Loot them for their Tusks. Save the [Blood Shards] you get.",
            quests = { 878, 899 },
            when = "objectives",
            details = {
                "Kill Bristleback Water Seeker (x6)",
                "Kill Bristleback Water Seeker",
                "Kill Bristleback Thornweaver (x12)",
                "Kill Bristleback Thornweaver",
                "Kill Bristleback Geomancer (x12)",
                "Kill Bristleback Geomancer",
                "Collect Bristleback Quilboar Tusk (x60)",
            },
        },
        {
            text = "Kill Stormsnouts. Loot them for a Horn.",
            quest = 821,
            when = "objectives",
            details = {
                "Thunder Lizard Horn (1)",
                "Kill Stormsnout",
                "Optional: Kill Stormsnouts. Loot them for a Horn",
            },
        },
        {
            text = "Finish killing Plainstriders. Loot them for their Kidneys.",
            quest = 821,
            when = "objectives",
            details = {
                "Plainstrider Kidney (5)",
                "Kill Greater Plainstrider",
            },
        },
        {
            text = "Finish killing Sunscale Scytheclaws. Loot them for their Horns. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds).",
            quest = 865,
            when = "objectives",
            details = {
                "Intact Raptor Horn (5)",
                "Kill Sunscale Scytheclaw",
                "Kill Sunscale Scytheclaws. Loot them for their Horns. Be careful as they cast [Thrash] (Charges 2 extra attacks every 10 seconds)",
            },
        },
        {
            text = "Kill any Zhevra. Loot it for a Fresh Zhevra Carcass.",
            details = {
                "Kill Zhevra Charger",
            },
        },
        {
            text = "Kill Oasis Snapjaws in and around the lake. Loot them for their Shells.",
            quest = 880,
            when = "objectives",
            details = {
                "Altered Snapjaw Shell (8)",
                "Kill Oasis Snapjaw",
            },
        },
        {
            text = "Kill any Zhevra. Loot it for a Fresh Zhevra Carcass.",
            details = {
                "Kill Zhevra Charger",
            },
        },
        {
            text = "Use the [Fresh Zhevra Carcass] at the dead tree to summon Ishamuhale. Kill and loot him for his Fang. The Carcass only has a 30 minute duration!",
            quest = 882,
            when = "objectives",
            details = {
                "Ishamuhale's Fang (1)",
                "Kill Ishamuhale",
            },
        },
        {
            text = "Kill Savannah Matriarchs and Savannah Patriarchs. Loot them for their Hides.",
            quest = 95494,
            when = "objectives",
            details = {
                "6/6 Savannah Lion Hide",
                "Kill Savannah Matriarch",
                "Kill Savannah Patriarch",
            },
        },
        {
            text = "Travel to Ratchet.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Wrenix. Turn in Plundering the Plunderers.",
            quest = 2381,
            when = "complete",
        },
        {
            classes = { "Rogue" },
            text = "Optional: Talk to Wrenix. Turn in Plundering the Plunderers.",
            quest = 2381,
            when = "complete",
            details = {
                "NPC: Wrenix the Wretched",
            },
        },
        {
            text = "Talk to Gazlowe. Turn in Stolen Booty.",
            quest = 888,
            when = "complete",
        },
        {
            text = "Talk to Sputtervalve. Turn in Further Instructions. Accept Further Instructions.",
            quest = 1095,
            when = "accepted",
            details = {
                "Turn in Further Instructions",
            },
        },
        {
            text = "Click the Wanted Poster. Accept WANTED: Bruuz.",
            quest = 92706,
            when = "accepted",
        },
        {
            text = "Talk to Mebok. Turn in Raptor Horns. Turn in Deepmoss Spider Eggs.",
            quests = { 865, 1069 },
            when = "complete",
            details = {
                "NPC: Mebok Mizzyrix",
            },
        },
        {
            text = "Talk to Drohn. Turn in Chen's Empty Keg.",
            quest = 821,
            when = "complete",
            details = {
                "NPC: Brewmaster Drohn",
            },
        },
        {
            classes = { "Warrior" },
            text = "Talk to Grazlix. Buy [Mighty Chain Pants] from him if it's up.",
        },
        {
            classes = { "Warrior", "Hunter", "Rogue", "Shaman", "Druid" },
            text = "Talk to Vexspindle. Buy [Wolf Bracers] from him if they're up.",
        },
        {
            classes = { "Warrior" },
            text = "Optional: Equip the [Mighty Chain Pants].",
        },
        {
            classes = { "Warrior", "Hunter", "Rogue", "Shaman", "Druid" },
            text = "Optional: Equip the [Wolf Bracers].",
        },
        {
            text = "Kill Bruuz (lvl 20 elite) in the sea near Ratchet.",
        },
        {
            excludeClasses = { "Warrior", "Rogue" },
            text = "This is hard! Group up if possible.",
        },
        {
            text = "Try to kite him to Ratchet to guards who will help, but make sure to deal at least 50% damage!",
            quest = 92706,
            when = "objectives",
            details = {
                "Kill Bruuz",
            },
        },
        {
            text = "Talk to Gazlowe. Turn in WANTED: Bruuz.",
            quest = 92706,
            when = "complete",
        },
        {
            text = "Talk to Bragok. Fly to The Crossroads.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Thork. Accept Report to Kadrak.",
            quest = 6541,
            when = "accepted",
        },
        {
            text = "Talk to Darsok. He is at the top of the tower. Turn in Harpy Lieutenants. Accept Serena Bloodfeather.",
            quest = 876,
            when = "accepted",
            details = {
                "Turn in Harpy Lieutenants",
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            text = "Optional: Talk to Darsok. He is at the top of the tower. Accept Serena Bloodfeather.",
            quest = 876,
            when = "accepted",
            details = {
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            text = "Talk to Mankrik and Tonga. Turn in Consumed by Hatred. Turn in Her Name Is Olgra. Turn in Altered Beings. Accept Hamuul Runetotem. Accept Mura Runetotem.",
            quests = { 1489, 3301 },
            when = "accepted",
            details = {
                "Turn in Altered Beings",
                "Turn in Her Name Is Olgra",
                "Turn in Consumed by Hatred",
            },
        },
        {
            text = "Talk to Korran. Accept Egg Hunt.",
            quest = 868,
            when = "accepted",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Devrak. Fly to Orgrimmar.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Searn. Accept Call of Water.",
            quest = 1528,
            when = "accepted",
            details = {
                "NPC: Searn Firewarder",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kardris. Train your class spells.",
            details = {
                "NPC: Kardris Dreamseeker",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Devrak. Fly to Orgrimmar.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Gan'rul. Train your class spells. Accept Devourer of Souls.",
            quest = 1507,
            when = "accepted",
            details = {
                "NPC: Gan'rul Bloodeye",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Kurgul and buy [Grimoire of Torment (Rank 2)].",
        },
        {
            classes = { "Warlock" },
            text = "Turn in Devourer of Souls. Accept Blind Cazul.",
            quest = 1508,
            when = "accepted",
            details = {
                "Turn in Devourer of Souls",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Katis. Buy a [Burning Wand] from her.",
            details = {
                "Collect Burning Wand (1)",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Zankaja. Turn in Blind Cazul. Accept News of Dogran.",
            quest = 1509,
            when = "accepted",
            details = {
                "Turn in Blind Cazul",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Doras. Fly to The Crossroads.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Gazrog. Turn in News of Dogran. Accept News of Dogran.",
            quest = 1510,
            when = "accepted",
            details = {
                "Turn in News of Dogran",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Doras. Fly to Ratchet.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Islen. Turn in Call of Water. Accept Call of Water.",
            quest = 1530,
            when = "accepted",
            details = {
                "Turn in Call of Water",
                "NPC: Islen Waterseer",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Bragok. Fly to Crossroads.",
        },
        {
            text = "Talk to Helbrim. Helbrim Starts a 45-minute timed quest. Accept Apothecary Zamah.",
            quest = 853,
            when = "accepted",
            details = {
                "NPC: Apothecary Helbrim",
            },
        },
        {
            text = "You are on a timed quest, don't go afk. It will get turned 20-30 minutes after pick-up.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Bragok. Fly to Camp Taurajo.",
        },
        {
            text = "Talk to Devrak. Fly to Camp Taurajo.",
        },
        {
            text = "Kill Bristleback Quilboars. Loot them for a [Blood Shard].",
            details = {
                "Blood Shard (1)",
                "Kill Bristleback Water Seeker",
                "Kill Bristleback Thornweaver",
                "Kill Bristleback Geomancer",
            },
        },
        {
            text = "Talk to Mangletooth. Turn in Tribes at War. Accept Blood Shards of Agamaggan. Turn in Blood Shards of Agamaggan.",
            quest = 5052,
            when = "accepted",
            details = {
                "Turn in Blood Shards of Agamaggan",
                "Turn in Tribes at War",
            },
        },
        {
            races = { "Tauren" },
            text = "Talk to Mangletooth.",
            note = "Use your [Blood Shards] to get buffs. Save at least 4 of them for later",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Mangletooth.",
            note = "Use your [Blood Shards] to get buffs. Save at least 4 of them for later",
        },
        {
            classes = { "Warrior" },
            races = { "Orc", "Troll" },
            text = "Talk to Mangletooth.",
            note = "Use your [Blood Shards] to get buffs. Save at least 4 of them for later",
        },
        {
            excludeClasses = { "Warrior", "Shaman" },
            excludeRaces = { "Tauren" },
            text = "Use your [Blood Shards] to get buffs. Save at least 4 of them for later.",
        },
        {
            races = { "Undead" },
            text = "Use your [Blood Shards] to get buffs. Save at least 4 of them for later.",
        },
        {
            text = "Talk to Mangletooth.",
            note = "Make sure to turn off any autocomplete functions from addons such as Questie or Leatrix Plus for this!",
        },
        {
            text = "Talk to Jorn Skyseer. Turn in Ishamuhale. Accept Enraged Thunder Lizards. Turn in Lakota'mani.",
            quest = 907,
            when = "accepted",
            details = {
                "Turn in Lakota'mani",
                "Turn in Ishamuhale",
            },
        },
        {
            text = "Talk to Jorn Skyseer. Turn in Ishamuhale. Accept Enraged Thunder Lizards.",
            quest = 907,
            when = "accepted",
            details = {
                "Turn in Ishamuhale",
            },
        },
        {
            text = "Kill Owatanka. Loot him for [Owatanka's Tailspike]. Use the [Owatanka's Tailspike] to start the quest. He has 4 spawnpoints (marked on the map). Accept Owatanka. Look for Owatanka.",
            quest = 884,
            when = "accepted",
        },
        {
            text = "Click the Burned-Out Remains on the ground. Accept ...and that note you found.",
            quest = 79007,
            when = "accepted",
        },
        {
            text = "Kill Thunder Lizards. Loot them for their Blood.",
            quest = 907,
            when = "objectives",
            details = {
                "Thunder Lizard Blood (3)",
                "Kill Thunderhead",
                "Kill Stormsnout",
            },
        },
        {
            text = "Talk to Jorn. Turn in Owatanka. Turn in Enraged Thunder Lizards. Accept Cry of the Thunderhawk.",
            quest = 913,
            when = "accepted",
            details = {
                "Turn in Enraged Thunder Lizards",
                "Turn in Owatanka",
                "NPC: Jorn Skyseer",
            },
        },
        {
            text = "Talk to Jorn. Turn in Enraged Thunder Lizards. Accept Cry of the Thunderhawk.",
            quest = 913,
            when = "accepted",
            details = {
                "Turn in Enraged Thunder Lizards",
                "NPC: Jorn Skyseer",
            },
        },
        {
            classes = { "Shaman" },
            text = "Kill Owatanka. Loot him for [Owatanka's Tailspike]. Use the [Owatanka's Tailspike] to start the quest. He has 4 spawnpoints (marked on the map). Accept Owatanka. Look for Owatanka.",
            quest = 884,
            when = "accepted",
        },
        {
            classes = { "Shaman" },
            text = "Travel South toward Brine.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Brine. Turn in Call of Water. Accept Call of Water.",
            quest = 1535,
            when = "accepted",
            details = {
                "Turn in Call of Water",
            },
        },
        {
            classes = { "Shaman" },
            text = "Fill your [Empty Brown Waterskin] in the watering hole below Brine's hut.",
            quest = 1535,
            when = "objectives",
            details = {
                "Filled Brown Waterskin (1)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Brine. Turn in Call of Water. Accept Call of Water.",
            quest = 1536,
            when = "accepted",
            details = {
                "Turn in Call of Water",
            },
        },
        {
            classes = { "Shaman" },
            text = "Travel back toward Camp Taurajo.",
        },
        {
            text = "Kill Owatanka. Loot him for [Owatanka's Tailspike]. Use the [Owatanka's Tailspike] to start the quest. He has 4 spawnpoints (marked on the map). Accept Owatanka. Look for Owatanka.",
            quest = 884,
            when = "accepted",
        },
        {
            text = "Kill a Thunderhawk Hatchling or a Thunderhawk Cloudscraper. Loot it for its Thunderhawk Wings.",
            quest = 913,
            when = "objectives",
            details = {
                "Thunderhawk Wings (1)",
                "Kill Thunderhawk Hatchling",
                "Kill Thunderhawk Cloudscraper",
                "Kill a Thunderhawk. Loot it for its Wings",
                "Kill Greater Thunderhawk",
            },
        },
        {
            text = "Talk to Jorn Skyseer. Turn in Owatanka. Turn in Cry of the Thunderhawk. Accept Mahren Skyseer.",
            quest = 874,
            when = "accepted",
            details = {
                "Turn in Cry of the Thunderhawk",
                "Turn in Owatanka",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Jorn Skyseer. Accept The Ashenvale Hunt.",
            quest = 6382,
            when = "accepted",
        },
        {
            text = "Talk to Jorn Skyseer. Turn in Cry of the Thunderhawk. Accept Mahren Skyseer.",
            quest = 874,
            when = "accepted",
            details = {
                "Turn in Cry of the Thunderhawk",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Jorn Skyseer. Accept The Ashenvale Hunt.",
            quest = 6382,
            when = "accepted",
        },
        {
            excludeRaces = { "Tauren", "Skyborne" },
            text = "Talk to Mangletooth. Skip this step if you have the Thunder Bluff flight path.",
        },
        {
            classes = { "Shaman" },
            excludeRaces = { "Tauren", "Skyborne" },
            text = "Train a new skill.",
        },
        {
            classes = { "Hunter" },
            excludeRaces = { "Tauren", "Skyborne" },
            text = "Train a new skill.",
        },
        {
            excludeRaces = { "Tauren", "Skyborne" },
            text = "Travel into Mulgore.",
        },
        {
            excludeRaces = { "Tauren", "Skyborne" },
            text = "Take the lift into Thunder Bluff. If you have the Thunder Bluff flight path, fly there instead.",
        },
        {
            races = { "Tauren", "Skyborne" },
            text = "Talk to Omusa. Fly to Thunder Bluff.",
            details = {
                "NPC: Omusa Thunderhorn",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc", "Undead", "Troll" },
            text = "Talk to Ansekhwa. Train Two-Handed Maces. Train Staves.",
        },
        {
            classes = { "Shaman" },
            races = { "Orc", "Troll" },
            text = "Talk to Ansekhwa. Train Two-Handed Maces. Train Staves.",
        },
        {
            classes = { "Hunter" },
            races = { "Orc", "Troll" },
            text = "Talk to Ansekhwa. Train Staves.",
        },
        {
            classes = { "Warrior" },
            races = { "Undead" },
            text = "Talk to Ansekhwa. Train Staves.",
        },
        {
            classes = { "Priest", "Warlock" },
            text = "Talk to Ansekhwa. Train Staves.",
        },
        {
            classes = { "Rogue" },
            excludeRaces = { "Skyborne" },
            text = "Talk to Ansekhwa. Train Maces.",
        },
        {
            classes = { "Rogue" },
            text = "Optional: Talk to Boarton Shadetotem. He is [Stealthed]. Train your class spells.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Boarton Shadetotem. He is [Stealthed]. Train your class spells.",
        },
        {
            text = "Talk to Chesmu. Deposit your [Blood Shards]. Deposit your [Digging Claw].",
        },
        {
            text = "Optional: Talk to Chesmu. Deposit your [Blood Shards].",
        },
        {
            text = "Talk to Innkeeper Pala. Set your Hearthstone to Thunder Bluff.",
        },
        {
            classes = { "Hunter" },
            text = "Travel to the Hunter Rise.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Urek. Train your class spells.",
            details = {
                "NPC: Urek Thunderhorn",
            },
        },
        {
            classes = { "Hunter" },
            text = "Optional: Talk to Urek. Train your class spells.",
            details = {
                "NPC: Urek Thunderhorn",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Hesuwa. Train your pet spells.",
            details = {
                "NPC: Hesuwa Thunderhorn",
            },
        },
        {
            classes = { "Warrior" },
            text = "Travel to the Hunter Rise.",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Torm. Train your class spells. Accept Speak with Ruga.",
            quest = 1823,
            when = "accepted",
            details = {
                "NPC: Torm Ragetotem",
            },
        },
        {
            text = "Travel to the Spirit Rise and enter the pools of vision.",
        },
        {
            text = "Talk to Clarice. Accept Until Death Do Us Part.",
            quest = 264,
            when = "accepted",
            details = {
                "NPC: Clarice Foster",
            },
        },
        {
            text = "Optional: Talk to Zamah. Turn in Apothecary Zamah.",
            quest = 853,
            when = "complete",
        },
        {
            classes = { "Priest" },
            races = { "Undead" },
            text = "Talk to Miles. Accept Devouring Plague.",
            quest = 5644,
            when = "accepted",
            details = {
                "NPC: Miles Welsh",
            },
        },
        {
            classes = { "Priest" },
            races = { "Troll" },
            text = "Talk to Miles Welsh. Accept Shadowguard.",
            quest = 5642,
            when = "accepted",
        },
        {
            classes = { "Priest" },
            text = "Talk to Miles Welsh. Train your class spells.",
        },
        {
            classes = { "Mage" },
            text = "Talk to Shymm. Train your class spells.",
            details = {
                "NPC: Archmage Shymm",
            },
        },
        {
            classes = { "Mage" },
            text = "Optional: Talk to Shymm. Train your class spells.",
            details = {
                "NPC: Archmage Shymm",
            },
        },
        {
            classes = { "Paladin" },
            text = "Talk to Alodan. Train your class spells.",
            details = {
                "NPC: Alodan the Hopeful",
            },
        },
        {
            classes = { "Paladin" },
            text = "Optional: Talk to Alodan. Train your class spells.",
            details = {
                "NPC: Alodan the Hopeful",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Tigor outside. Train your class spells.",
            details = {
                "NPC: Tigor Skychaser",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Talk to Tigor outside. Train your class spells.",
            details = {
                "NPC: Tigor Skychaser",
            },
        },
        {
            text = "Talk to Pand. Skip this step if you did not have enough [Linen Cloth] to reach 80 skill. Train [Wool Bandage].",
        },
        {
            classes = { "Rogue" },
            text = "Train [Anti-Venom].",
        },
        {
            classes = { "Rogue" },
            text = "Create [Anti-Venom] if you found any [Small Venom Sacs]. Save them for later.",
        },
        {
            text = "Travel to the Elder Rise.",
        },
        {
            text = "Talk to Hamuul. Turn in Hamuul Runetotem. Accept Nara Wildmane.",
            quest = 1490,
            when = "accepted",
            details = {
                "Turn in Hamuul Runetotem",
                "NPC: Arch Druid Hamuul Runetotem",
            },
        },
        {
            text = "Talk to Nara. Turn in Nara Wildmane.",
            quest = 1490,
            when = "complete",
        },
        {
            classes = { "Druid" },
            text = "Talk to Turak. Train your class spells. Accept A Lesson to Learn. Accept The Great Cat Spirit.",
            quests = { 27, 98340 },
            when = "accepted",
            details = {
                "NPC: Turak Runetotem",
            },
        },
        {
            classes = { "Druid" },
            text = "Cast [Teleport: Moonglade].",
        },
        {
            classes = { "Druid" },
            text = "Talk to Dendrite. Turn in A Lesson to Learn. Accept Trial of the Lake. Turn in The Great Cat Spirit.",
            quest = 28,
            when = "accepted",
            details = {
                "Turn in The Great Cat Spirit",
                "Turn in A Lesson to Learn",
            },
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "Talk to Dendrite. Accept The Great Windborne Cat Spirit.",
            quest = 98341,
            when = "accepted",
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "Talk to Dendrite. Accept The Great Cat Spirit.",
            quest = 98405,
            when = "accepted",
        },
        {
            classes = { "Druid" },
            text = "Loot the Bauble Container at the bottom of the lake for a [Shrine Bauble]. Do not go underwater until you arive right above the Bauble.",
        },
        {
            classes = { "Druid" },
            text = "Use the [Shrine Bauble] at the Shrine of Remulos.",
            quest = 28,
            when = "objectives",
            details = {
                "Complete the Trial of the Lake",
            },
        },
        {
            classes = { "Druid" },
            text = "Talk to Tajarri. Turn in Trial of the Lake. Accept Trial of the Sea Lion.",
            quest = 30,
            when = "accepted",
            details = {
                "Turn in Trial of the Lake",
            },
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "Turn in The Great Cat Spirit. Accept The Great Cat Spirit.",
            quest = 98342,
            when = "accepted",
            details = {
                "Turn in The Great Cat Spirit",
            },
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "Talk to Avatar of Saeyleenan::272054. Turn in The Great Windborne Cat Spirit. Accept The Great Windborne Cat Spirit.",
            quest = 98404,
            when = "accepted",
            details = {
                "Turn in The Great Windborne Cat Spirit",
            },
        },
        {
            classes = { "Druid" },
            text = "Head to the Stormrage Barrow Dens.",
        },
        {
            classes = { "Druid" },
            text = "Go deep into the cave, travel across the bridge, look for a cat statue inside an alcove and click on the small orb next to the statue. Loot Relic of the Claw.",
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "1/1 Relic of the Claw.",
            quest = 98404,
            when = "objectives",
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "1/1 Relic of the Claw.",
            quest = 98342,
            when = "objectives",
        },
        {
            classes = { "Druid" },
            text = "Click on the small orb next to the cat statue. Loot Relic of the Silent Shadow.",
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "1/1 Relic of the Silent Shadow.",
            quest = 98404,
            when = "objectives",
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "1/1 Relic of the Silent Shadow.",
            quest = 98342,
            when = "objectives",
        },
        {
            classes = { "Druid" },
            text = "Click on the small orb next to the cat statue. Loot Relic of the Fang.",
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "1/1 Relic of the Fang.",
            quest = 98404,
            when = "objectives",
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "1/1 Relic of the Fang.",
            quest = 98342,
            when = "objectives",
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "Turn in The Great Cat Spirit. Accept Blessings of the Great Cat Spirit.",
            quest = 98739,
            when = "accepted",
            details = {
                "Turn in The Great Cat Spirit",
            },
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "Talk to Avatar of Saeyleenan::272054. Turn in The Great Windborne Cat Spirit. Accept Blessings of the Great Windborne Cat Spirit.",
            quest = 98738,
            when = "accepted",
            details = {
                "Turn in The Great Windborne Cat Spirit",
            },
        },
        {
            classes = { "Druid" },
            text = "Cast [Teleport: Moonglade].",
        },
        {
            classes = { "Druid" },
            races = { "Skyborne" },
            text = "Talk to Dendrite Starblaze::11802. Turn in Blessings of the Great Windborne Cat Spirit.",
            quest = 98738,
            when = "complete",
        },
        {
            classes = { "Druid" },
            excludeRaces = { "Skyborne" },
            text = "Talk to Dendrite Starblaze::11802. Turn in Blessings of the Great Cat Spirit.",
            quest = 98739,
            when = "complete",
        },
        {
            classes = { "Druid" },
            text = "Talk to Dendrite Starblaze::11802. Accept To Thunder Bluff.",
            quest = 98362,
            when = "accepted",
        },
        {
            classes = { "Druid" },
            text = "Hearth to Thunder Bluff.",
        },
        {
            classes = { "Druid" },
            text = "Talk to Bunthen. Fly to Thunder Bluff.",
            details = {
                "NPC: Bunthen Plainswind",
            },
        },
        {
            classes = { "Druid" },
            text = "Talk to Turak. Turn in Thunder Bluff.",
            quest = 98362,
            when = "complete",
            details = {
                "NPC: Turak Runetotem",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Kard. Buy a [Longsword] from him.",
            details = {
                "Collect Longsword (1)",
                "NPC: Kard Ragetotem",
            },
        },
        {
            classes = { "Rogue" },
            text = "Optional: Equip the [Longsword].",
        },
        {
            classes = { "Warrior", "Shaman" },
            text = "Optional: If it's cheaper you can buy a green weapon from the auction house instead.",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Etu. Buy a [Long Staff] from him.",
            details = {
                "Collect Long Staff (1)",
                "NPC: Etu Ragetotem",
            },
        },
        {
            classes = { "Warrior" },
            text = "Optional: Equip the [Long Staff].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Etu. Buy a [Long Staff] from him.",
            details = {
                "Collect Long Staff (1)",
                "NPC: Etu Ragetotem",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Equip the [Long Staff].",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Kuna. Buy a [Heavy Recurve Bow] from her.",
            details = {
                "Collect Heavy Recurve Bow (1)",
                "NPC: Kuna Thunderhorn",
            },
        },
        {
            classes = { "Hunter" },
            text = "Optional: Equip the [Heavy Recurve Bow].",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Kuna. Buy [Sharp Arrows] from her.",
            details = {
                "Sharp Arrow (1600)",
                "NPC: Kuna Thunderhorn",
            },
        },
        {
            text = "Talk to Tal. Fly to The Crossroads.",
        },
        {
            text = "Talk to Regthar. Turn in Hezrul Bloodmark.",
            quest = 852,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Centaur Bracers.",
            quest = 855,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Optional: Abandon Centaur Bracers.",
        },
        {
            text = "This next quest is very hard & grouping up is recommended. You can kite Warlord Krom'zar around using the building where the quest giver is located.",
        },
        {
            text = "Talk to Regthar. Accept Counterattack!",
            quest = 4021,
            when = "accepted",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Kill Warlord Krom'zar once he appears. Loot the Banner that he drops on the ground. Be careful! He is a strong elite and is guarded by at least two Kolkar mobs. It can take up to 3 minutes until he spawns. Click here for a guide video on how you can kite Warlord Krom'zar. Look for Warlord Krom'zar.",
            quest = 4021,
            when = "objectives",
            details = {
                "Piece of Krom'zar's Banner (1)",
            },
        },
        {
            text = "Talk to Regthar. Turn in Counterattack!",
            quest = 4021,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Talk to Regthar. Turn in Centaur Bracers.",
            quest = 855,
            when = "complete",
            details = {
                "NPC: Regthar Deathgate",
            },
        },
        {
            text = "Kill Serena Bloodfeather. Loot her for her Head.",
            quest = 876,
            when = "objectives",
            details = {
                "Serena's Head (1)",
                "Kill Serena Bloodfeather",
            },
        },
        {
            text = "Kill Savannah Patriarchs. Loot them for their Hides.",
            quest = 95494,
            when = "objectives",
            details = {
                "6/6 Savannah Lion Hide",
                "Kill Savannah Patriarch",
            },
        },
        {
            text = "Loot the Sprung Traps on the ground.",
            quest = 95507,
            when = "objectives",
            details = {
                "8/8 Trapped Game",
            },
        },
        {
            text = "Turn in Bruised Pride and Lion Hides. Turn in Vrang's Game. Accept The Hermit Tanner.",
            quest = 95495,
            when = "accepted",
            details = {
                "Turn in Vrang's Game",
                "Turn in Bruised Pride and Lion Hides",
                "NPC: Vrang Wildgore",
            },
        },
        {
            text = "Travel up the mountain.",
        },
        {
            text = "Talk to Walton. Turn in The Hermit Tanner. Accept Trouble in the Valley.",
            quest = 95621,
            when = "accepted",
            details = {
                "Turn in The Hermit Tanner",
            },
        },
        {
            text = "Kill Corporal Adamore. Be careful! You may aggro 2-3 mobs at the same time.",
            quest = 95621,
            when = "objectives",
            details = {
                "1/1 Learn why the Kul Tirans are here",
                "Kill Corporal Adamore",
            },
        },
        {
            text = "Travel up the mountain.",
        },
        {
            text = "Talk to Walton. Turn in Trouble in the Valley. Accept Unwelcome Guests.",
            quest = 95508,
            when = "accepted",
            details = {
                "Turn in Trouble in the Valley",
            },
        },
        {
            text = "Move behind the house as you wait for the RP to finish to avoid getting aggro by all mobs at once. You don't actually need to assist Walton, he will survive with the help of Vrang Wildgore.",
            quest = 95508,
            when = "objectives",
            details = {
                "1/1 Assist Walton",
                "Kill Terry Longdrink",
            },
        },
        {
            text = "Talk to Walton. Turn in Unwelcome Guests.",
            quest = 95508,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Wenikee. Turn in Wenikee Boltbucket.",
            quest = 3921,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Torek. Turn in Report to Kadrak.",
            quest = 6541,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Optional: Talk to Torek. Accept The Runed Scroll. Turn in The Runed Scroll.",
            quest = 3513,
            when = "accepted",
            details = {
                "Turn in The Runed Scroll",
                "NPC: Kadrak",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Torek to start the escort. Torek has a 5 minute respawn time. Accept Torek's Assault.",
            quest = 6544,
            when = "accepted",
        },
        {
            classes = { "Hunter" },
            text = "Follow Torek. Let Torek and his Splintertree Raiders tank the Silverwing Warriors and Silverwing Sentinels. When you clear the building, run toward the Balcony. When Duriel Moonfire comes, let Torek and his Splintertree Raiders take aggro before you deal damage. Look for Duriel Moonfire.",
            quest = 6544,
            when = "objectives",
            details = {
                "Take Silverwing Outpost",
                "Kill Silverwing Warrior",
                "Kill Silverwing Sentinel",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ertog. Turn in Torek's Assault.",
            quest = 6544,
            when = "complete",
            details = {
                "NPC: Ertog Ragetusk",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Senani. Turn in The Ashenvale Hunt.",
            quests = { 6382, 6383 },
            when = "complete",
            details = {
                "NPC: Senani Thunderheart",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Vhulgra. Get the Splintertree Post flight path.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Vhulgra. Fly to Crossroads.",
        },
        {
            excludeClasses = { "Hunter" },
            text = "Die and respawn at the Spirit Healer.",
            mode = "softcore",
        },
        {
            excludeClasses = { "Hunter" },
            text = "Travel to Crossroads.",
            mode = "hardcore",
        },
        {
            text = "Talk to Darsok. Turn in Serena Bloodfeather. Accept Letter to Jin'Zil.",
            quest = 1060,
            when = "accepted",
            details = {
                "Turn in Serena Bloodfeather",
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            text = "Optional: Talk to Darsok. Accept Letter to Jin'Zil.",
            quest = 1060,
            when = "accepted",
            details = {
                "NPC: Darsok Swiftdagger",
            },
        },
        {
            text = "Talk to Korran. Accept Egg Hunt.",
            quest = 868,
            when = "accepted",
        },
        {
            text = "Travel to Stonetalon Mountains.",
        },
        {
            text = "Talk to Seereth and Makaba. Turn in Goblin Invaders. Accept The Elder Crone. Accept Shredding Machines. Turn in Kill Grundig Darkcloud. Turn in Protect Kaya. Accept Kaya's Alive.",
            quests = { 1063, 1068, 6401 },
            when = "accepted",
            details = {
                "Turn in Protect Kaya",
                "Turn in Kill Grundig Darkcloud",
                "Turn in Goblin Invaders",
                "NPC: Seereth Stonebreak, Makaba Flathoof",
            },
        },
        {
            text = "Optional: Talk to Seereth and Makaba. Turn in Goblin Invaders. Accept The Elder Crone. Accept Shredding Machines. Turn in Kill Grundig Darkcloud.",
            quests = { 1063, 1068 },
            when = "accepted",
            details = {
                "Turn in Kill Grundig Darkcloud",
                "Turn in Goblin Invaders",
                "NPC: Seereth Stonebreak, Makaba Flathoof",
            },
        },
        {
            text = "Optional: Talk to Seereth and Makaba. Turn in Goblin Invaders. Accept The Elder Crone. Accept Shredding Machines. Turn in Protect Kaya. Accept Kaya's Alive.",
            quests = { 1063, 1068, 6401 },
            when = "accepted",
            details = {
                "Turn in Protect Kaya",
                "Turn in Goblin Invaders",
                "NPC: Seereth Stonebreak, Makaba Flathoof",
            },
        },
        {
            text = "Optional: Talk to Seereth. Turn in Goblin Invaders. Accept The Elder Crone. Accept Shredding Machines.",
            quests = { 1063, 1068 },
            when = "accepted",
            details = {
                "Turn in Goblin Invaders",
                "NPC: Seereth Stonebreak",
            },
        },
        {
            text = "Follow the path on the left upward.",
        },
        {
            text = "Talk to Jin'Zil. Turn in Letter to Jin'Zil. Accept Jin'Zils Forest Magic.",
            quest = 1058,
            when = "accepted",
            details = {
                "Turn in Letter to Jin'Zil",
                "NPC: Witch Doctor Jin'Zil",
            },
        },
        {
            text = "Talk to Jin'Zil. Accept Jin'Zils Forest Magic.",
            quest = 1058,
            when = "accepted",
            details = {
                "NPC: Witch Doctor Jin'Zil",
            },
        },
        {
            classes = { "Warlock" },
            text = "Turn in News of Dogran. Accept Ken'zigla's Draught.",
            quest = 1511,
            when = "accepted",
            details = {
                "Turn in News of Dogran",
            },
        },
        {
            text = "Talk to Xen'Zilla. Turn in Blood Feeders.",
            quest = 6461,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Click the Wanted Poster. Accept Arachnophobia.",
            quest = 6284,
            when = "accepted",
        },
        {
            classes = { "Hunter" },
            text = "Kill Besseleth. Loot her for for her Fang. Clear the area around Besseleth. Be careful as she webs you. This quest is optional. If you can't do it, skip this quest. Look for Besseleth.",
            quest = 6284,
            when = "objectives",
            details = {
                "Collect Besseleth's Fang (x1)",
            },
        },
        {
            text = "Travel to Sun Rock Retreat.",
        },
        {
            text = "Run up the path to the right.",
        },
        {
            text = "Talk to Tsunaman. Accept Trouble in the Deeps. Accept Elemental War.",
            quests = { 6562, 6393 },
            when = "accepted",
        },
        {
            text = "Talk to Maggran. Turn in Arachnophobia.",
            quest = 6284,
            when = "complete",
            details = {
                "NPC: Maggran Earthbinder",
            },
        },
        {
            text = "Talk to Innkeeper Jayka. Do NOT set your [Hearthstone].",
        },
        {
            excludeClasses = { "Warrior", "Rogue" },
            text = "Talk to Innkeeper Jayka. Sell your junk, then restock on food and water if necessary.",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Innkeeper Jayka. Sell your junk, then restock on food if necessary.",
        },
        {
            text = "Talk to Innkeeper Jayka. Vendor Trash.",
        },
        {
            excludeClasses = { "Warrior" },
            text = "Talk to Jeeda on the second floor of the inn. Buy [Healing Potions] from her if they're up.",
        },
        {
            classes = { "Warrior" },
            text = "Buy [Healing Potions] and [Liferoot] from her if they're up.",
        },
        {
            text = "Talk to Tammra. Turn in Kaya's Alive. Accept Cycle of Rebirth.",
            quest = 6301,
            when = "accepted",
            details = {
                "Turn in Kaya's Alive",
                "NPC: Tammra Windfield",
            },
        },
        {
            text = "Talk to Ziz. Turn in Further Instructions. Accept Gerenzo Wrenchwhistle.",
            quest = 1096,
            when = "accepted",
            details = {
                "Turn in Further Instructions",
                "NPC: Ziz Fizziks",
            },
        },
        {
            text = "Kill XT:9. It patrols the southern side of the river. His spawn point is marked on your map. Look for XT:9.",
            quest = 1068,
            when = "objectives",
            details = {
                "XT:9 (1)",
            },
        },
        {
            text = "Enter the Windshear Mine.",
        },
        {
            text = "Talk to Piznik. This quest takes 5 minutes, and will spawn 3 waves of Kobolds at set times:. First wave at 15 seconds (3 Kobolds), Second wave at 2 minutes 15 seconds (4 Kobolds, 2 casters 2 melee), and the Third wave at 3 minutes 20 seconds (4 Kobolds). The objective completes at 5 minutes. Accept Gerenzo's Orders.",
            quest = 1090,
            when = "accepted",
        },
        {
            text = "Protect Piznik from incoming Windshear Vermin. First wave at 15 seconds (3 Kobolds), Second wave at 2 minutes 15 seconds (4 Kobolds, 2 casters 2 melee), and the Third wave at 3 minutes 20 seconds (4 Kobolds). The objective completes at 5 minutes.",
            quest = 1090,
            when = "objectives",
            details = {
                "Keep Piznik safe while he mines the mysterious ore",
                "Kill Windshear Vermin",
            },
        },
        {
            text = "Talk to Piznik. Turn in Gerenzo's Orders. Accept Gerenzo's Orders.",
            quest = 1092,
            when = "accepted",
            details = {
                "Turn in Gerenzo's Orders",
            },
        },
        {
            text = "Enter the Talondeep Path.",
        },
        {
            text = "Talk to Va'xug Firefure. Accept Never Coming Back.",
            quest = 98251,
            when = "accepted",
        },
        {
            text = "Kill Ashenvale Bears and Shadowhorn Stags. Be careful of Ursangous (strong lvl 25) that patrols in the area.",
            quest = 98251,
            when = "objectives",
            details = {
                "6/6 Ashenvale Bear slain",
                "Kill Ashenvale Bear",
                "6/6 Shadowhorn Stag slain",
                "Kill Shadowhorn Stag",
            },
        },
        {
            text = "Talk to Va'xug Firefure. Turn in Never Coming Back. Accept A Void Path.",
            quest = 98252,
            when = "accepted",
            details = {
                "Turn in Never Coming Back",
            },
        },
        {
            text = "Run to the main road as the Eye of Kilrogg follows you.",
            quest = 98252,
            when = "objectives",
            details = {
                "1/1 Eye of Kilrogg guided to the road",
            },
        },
        {
            text = "Talk to Eye of Kilrogg. Turn in A Void Path.",
            quest = 98252,
            when = "complete",
        },
        {
            text = "Travel toward the Zoram'gar Outpost. Make sure to avoid Astranaar guards en route. Follow the waypoint for safety. Look for Astranaar Sentinel.",
        },
        {
            text = "Talk to Andruk. Get the Zoram'gar Outpost flight path.",
        },
        {
            text = "Talk to Je'neu, Karang, Mitsuwa and Marukai. Turn in Trouble in the Deeps. Accept Between a Rock and a Thistlefur. Accept Troll Charm. Accept Naga at the Zoram Strand.",
            quests = { 216, 6462, 6442 },
            when = "accepted",
            details = {
                "Turn in Trouble in the Deeps",
            },
        },
        {
            text = "Save all the [Shredder Operating Manual Pages] you loot.",
        },
        {
            text = "Talk to Muglash. This will start an escort quest. Be careful as it's difficult.",
        },
        {
            text = "Click the Brazier when you get there. There will be waves of Naga that spawn. Be careful once Vorsha comes out, he hits very hard. You can let Muglash get some aggro before fighting him.",
            quest = 6641,
            when = "objectives",
            details = {
                "Defeat Vorsha the Lasher",
                "Kill Vorsha the Lasher",
            },
        },
        {
            text = "Kill Wrathtail Nagas. Loot them for their Heads.",
            quest = 6442,
            when = "objectives",
            details = {
                "Wrathtail Head (20)",
                "Kill Wrathtail Razortail",
                "Kill Wrathtail Wave Rider",
                "Kill Wrathtail Sorceress",
                "Kill Wrathtail Sea Witch",
                "Kill Wrathtail Priestess",
                "Kill Wrathtail Myrmidon",
                "Kill Lady Vespia",
            },
        },
        {
            text = "Talk to Warsong Runner and Marukai. Turn in Vorsha the Lasher. Turn in Naga at the Zoram Strand.",
            quests = { 6641, 6442 },
            when = "complete",
        },
        {
            text = "Talk to Karang. Accept Between a Rock and a Thistlefur.",
            quest = 216,
            when = "accepted",
            details = {
                "NPC: Karang Amakkar",
            },
        },
        {
            text = "Talk to Andruk. Fly to Thunder Bluff.",
        },
        {
            text = "Hearth to Thunder Bluff.",
        },
        {
            text = "Travel to the Elder Rise.",
        },
        {
            text = "Talk to Magatha. Wait for the RP to finish. Turn in The Elder Crone. Accept Forsaken Aid.",
            quest = 1064,
            when = "accepted",
            details = {
                "Turn in The Elder Crone",
                "NPC: Magatha Grimtotem",
            },
        },
        {
            text = "Travel to the Spirit Rise and enter the pools of vision.",
        },
        {
            text = "Talk to Zamah. Turn in Forsaken Aid. Accept Journey to Tarren Mill.",
            quest = 1065,
            when = "accepted",
            details = {
                "Turn in Forsaken Aid",
                "NPC: Apothecary Zamah",
            },
        },
        {
            classes = { "Paladin" },
            text = "Talk to Alodan. Train your class spells.",
            details = {
                "NPC: Alodan the Hopeful",
            },
        },
        {
            classes = { "Paladin" },
            text = "Optional: Talk to Alodan. Train your class spells.",
            details = {
                "NPC: Alodan the Hopeful",
            },
        },
        {
            text = "Talk to Chesmu. Deposit all your [Shredder Operating Manual Pages].",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Tal. Fly to Camp Taurajo.",
        },
        {
            excludeClasses = { "Warlock" },
            text = "Talk to Tal. Fly to Orgrimmar.",
        },
        {
            classes = { "Warlock" },
            text = "Optional: Talk to Andruk. Fly to Camp Taurajo.",
        },
        {
            excludeClasses = { "Warlock" },
            text = "Optional: Talk to Andruk. Fly to Orgrimmar.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Logmar. Turn in Ken'zigla's Draught. Accept Dogran's Captivity.",
            quest = 1515,
            when = "accepted",
            details = {
                "Turn in Ken'zigla's Draught",
                "NPC: Grunt Logmar",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Dogran. Turn in Dogran's Captivity. Accept Love's Gift.",
            quest = 1512,
            when = "accepted",
            details = {
                "Turn in Dogran's Captivity",
                "NPC: Grunt Dogran",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Omusa. Fly to Orgrimmar.",
            details = {
                "NPC: Omusa Thunderhorn",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Gan'rul. Turn in Love's Gift. Accept The Binding.",
            quest = 1513,
            when = "accepted",
            details = {
                "Turn in Love's Gift",
                "NPC: Gan'rul Bloodeye",
            },
        },
        {
            classes = { "Warlock" },
            text = "Use [Dogran's Pendant] at the Summoning Circle.",
        },
        {
            classes = { "Warlock" },
            text = "Kill the Summoned Succubus.",
            quest = 1513,
            when = "objectives",
            details = {
                "Kill Summoned Succubus (1)",
                "Kill Summoned Succubus",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Gan'rul. Turn in The Binding.",
            quest = 1513,
            when = "complete",
            details = {
                "NPC: Gan'rul Bloodeye",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Mirket. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Optional: Talk to Mirket. Train your class spells.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Kareth. Buy a [Jambiya] from him if you do not have a dagger.",
            details = {
                "Collect Jambiya (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Shenthul. Train [Pick Pocket]. Train [Ambush]. Train [Rupture]. Train [Vanish]. Train [Distract]. Train [Stealth Rank 2]. Accept The Shattered Salute.",
            quest = 2460,
            when = "accepted",
        },
        {
            classes = { "Rogue" },
            text = "After Shenthul does his salute, type /Salute while targeting him.",
            quest = 2460,
            when = "objectives",
            details = {
                "Shattered Salute Performed (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Shenthul. Turn in The Shattered Salute. Accept Deep Cover.",
            quest = 2458,
            when = "accepted",
            details = {
                "Turn in The Shattered Salute",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Rekkul. Buy [Flash Powder] from him.",
            details = {
                "Collect Dust of Decay (40)",
                "Collect Empty Vial (40)",
                "Collect Flash Powder (20)",
            },
        },
        {
            classes = { "Priest", "Warlock" },
            text = "Talk to Katis. Buy a [Burning Wand] from her.",
            details = {
                "Collect Burning Wand (1)",
            },
        },
        {
            classes = { "Mage" },
            text = "Talk to Pephredo. Train your class spells.",
        },
        {
            classes = { "Mage" },
            text = "Optional: Talk to Pephredo. Train your class spells.",
        },
        {
            classes = { "Mage" },
            text = "Talk to Thuul at the top of the hut. Train [Teleport: Orgrimmar].",
        },
        {
            classes = { "Priest" },
            races = { "Troll" },
            text = "Talk to Ur'kyo. Turn in Shadowguard. Train your class spells.",
            quest = 5642,
            when = "complete",
        },
        {
            classes = { "Priest" },
            races = { "Undead" },
            text = "Talk to Ur'kyo. Train your class spells.",
        },
        {
            classes = { "Priest" },
            races = { "Undead" },
            text = "Optional: Talk to Ur'kyo. Train your class spells.",
        },
        {
            classes = { "Rogue", "Druid" },
            text = "Enter The Barrens through the Western Exit.",
        },
        {
            classes = { "Rogue", "Druid" },
            text = "Travel toward The Sludge Fen.",
        },
        {
            classes = { "Druid" },
            text = "Loot the Strange Lockbox in the water for the [Half Pendant of Aquatic Agility].",
            details = {
                "Half Pendant of Aquatic Agility (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Taskmaster Fizzule. Be careful! Do NOT approach him until he becomes friendly or he will attack you!",
            note = "Target Taskmaster Fizzule, then use your [Flare Gun] TWICE and type /Salute",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Taskmaster Fizzule. Turn in Deep Cover. Accept Mission: Possible But Not Probable.",
            quest = 2478,
            when = "accepted",
            details = {
                "Turn in Deep Cover",
            },
        },
        {
            classes = { "Rogue" },
            text = "Use [Pick Pocket] on Foreman Silixiz for his Tower Key.",
            quest = 2478,
            when = "objectives",
            details = {
                "Silixiz's Tower Key (1)",
                "Kill Foreman Silixiz",
            },
        },
        {
            classes = { "Rogue" },
            text = "Use [Ambush] on the Mutated Venture Co. Drones. Use [Rupture] on the Venture Co. Patrollers. Use [Eviscerate] on the Venture Co. Lookouts once (1 combo point).",
            note = "Each mob here will take increased damage to certain abilities",
        },
        {
            classes = { "Rogue" },
            text = "Run into the Rogue Tower and kill Drones, Patrollers and Lookouts.",
            quest = 2478,
            when = "objectives",
            details = {
                "Mutated Venture Co. Drone (2)",
                "Kill Mutated Venture Co. Drone",
                "Venture Co. Patroller (2)",
                "Kill Venture Co. Patroller",
                "Venture Co. Lookout (2)",
                "Kill Venture Co. Lookout",
            },
        },
        {
            classes = { "Rogue" },
            text = "At the top of the tower you'll find Gallywix. Loot him for his Head. Use [Ambush] to reduce his HP to half. Use [Gouge] to restore energy and use [Evasion]. Remember to use a Potion and [Thistle Tea] if needed.",
            quest = 2478,
            when = "objectives",
            details = {
                "Gallywix's Head (1)",
                "Kill Grand Foreman Puzik Gallywix",
            },
        },
        {
            classes = { "Rogue" },
            text = "Use your lock picking to open Gallywix's Lockbox & loot the Mixture.",
            quest = 2478,
            when = "objectives",
            details = {
                "Cache of Zanzil's Altered Mixture (1)",
            },
        },
        {
            classes = { "Rogue", "Druid" },
            text = "Die and respawn at the Spirit Healer.",
            mode = "softcore",
        },
        {
            classes = { "Rogue", "Druid" },
            text = "Talk to Devrak. Fly to Orgrimmar.",
            mode = "softcore",
        },
        {
            classes = { "Rogue", "Druid" },
            text = "Enter Orgrimmar through the western entrance.",
            mode = "hardcore",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Shenthul. Turn in Mission: Possible But Not Probable. Accept Hinott's Assistance.",
            quest = 2479,
            when = "accepted",
            details = {
                "Turn in Mission: Possible But Not Probable",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Rekkul. Buy [Dust of Decay] and [Empty Vials] from him.",
            details = {
                "Collect Dust of Decay (20)",
                "Collect Empty Vial (20)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kardris. Train your class spells.",
            details = {
                "NPC: Kardris Dreamseeker",
            },
        },
        {
            classes = { "Shaman" },
            text = "Optional: Talk to Kardris. Train your class spells.",
            details = {
                "NPC: Kardris Dreamseeker",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Tauren", "Troll" },
            text = "Talk to Hanashi. Train Two-Handed Axes.",
        },
        {
            classes = { "Paladin" },
            races = { "Undead" },
            text = "Talk to Hanashi. Train Two-Handed Axes.",
        },
        {
            classes = { "Warrior" },
            races = { "Undead", "Tauren", "Troll" },
            text = "Train Thrown.",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Hanashi. Train Thrown.",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Grezz. Train your class spells.",
            details = {
                "NPC: Grezz Ragefist",
            },
        },
        {
            classes = { "Warrior" },
            text = "Optional: Talk to Grezz. Train your class spells.",
            details = {
                "NPC: Grezz Ragefist",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ormak. Train your class spells.",
            details = {
                "NPC: Ormak Grimshot",
            },
        },
        {
            classes = { "Hunter" },
            text = "Optional: Talk to Ormak. Train your class spells.",
            details = {
                "NPC: Ormak Grimshot",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Xao'tsu. Train your pet spells.",
        },
        {
            text = "Talk to Sovik.",
        },
        {
            text = "Talk to Sovik. Pay attention! You need to go through his dialogue first, after which you will accept the quest automatically. Accept Chief Engineer Scooty.",
            quest = 2842,
            when = "accepted",
        },
        {
            classes = { "Rogue" },
            text = "If you have any [Anti-Venom], use one to cure yourself of [Touch of Zanzil].",
        },
        {
            text = "Optional: Abandon Boulderslide Ravine.",
        },
        {
            text = "Optional: Abandon Counterattack!",
        },
        {
            text = "Optional: Abandon Earthen Arise.",
        },
        {
            text = "Optional: Abandon Arachnophobia.",
        },
        {
            text = "Optional: Abandon Vorsha the Lasher.",
        },
        {
            text = "Optional: Abandon The Essence of Aku'Mai.",
        },
        {
            text = "Optional: Abandon Chol'aruk the Ravener.",
        },
        {
            text = "Leave Orgrimmar.",
        },
    },
})
