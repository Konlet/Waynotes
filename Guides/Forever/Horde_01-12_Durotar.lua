local _, ns = ...

-- Durotar leveling for WoW Forever.
-- classes and excludeClasses choose who sees a step. races and excludeRaces do the same for race.
-- when = "accepted" moves on once the quest is in your log.
-- when = "complete" moves on once the quest is turned in.
-- A quest step with no when moves on once its objectives are finished.
-- note = "softcore" or "hardcore" is that branch. Hardcore steps in options follows the other one.
-- Pins omitted: QuestieDB supplies NPC coordinates for accept and turn-in steps.

ns.RegisterGuide({
    id = "horde-1-6-durotar",
    name = "1-6 Durotar",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            excludeRaces = { "Orc", "Troll" },
            text = "You have selected a guide meant for Orcs and Trolls. You should choose the same starter zone that you start in.",
        },
        {
            text = "Talk to Kaltunk. Accept Your Place In The World.",
            quest = 4641,
            when = "accepted",
        },
        {
            classes = { "Warrior", "Shaman", "Warlock", "Mage", "Priest" },
            text = "Kill Mottled Boars. Loot them until you have 35 copper worth of vendor items (including your armor).",
            note = "Kill Mottled Boars. Loot them until you have 60 copper worth of vendor items (including your armor)",
            details = {
                "Kill Mottled Boar",
                "Kill Mottled Boars. Loot them until you have 50 copper worth of vendor items (including your armor)",
                "Kill Mottled Boars. Loot them until you have 10 copper worth of vendor items (including your armor)",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Ruzan. Accept Vile Familiars.",
            quest = 1485,
            when = "accepted",
        },
        {
            classes = { "Warrior", "Shaman" },
            text = "Talk to Duokna. Vendor Trash.",
        },
        {
            text = "Talk to Gornek. Turn in Your Place In The World. Accept Cutting Teeth.",
            quest = 788,
            when = "accepted",
            details = {
                "Turn in Your Place In The World",
            },
        },
        {
            classes = { "Warrior", "Shaman" },
            text = "Talk to Shikrik. Train [Battle Shout]. Train [Rockbiter Weapon].",
        },
        {
            classes = { "Warlock" },
            text = "Travel toward Nartok.",
            note = "softcore",
        },
        {
            classes = { "Warlock" },
            text = "Travel toward Hraug.",
            note = "softcore",
        },
        {
            classes = { "Warlock" },
            text = "Travel toward Hraug.",
            note = "hardcore",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Hraug. Vendor Trash.",
            note = "softcore",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Hraug. Vendor Trash.",
            note = "hardcore",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Nartok. Train [Immolate].",
        },
        {
            classes = { "Hunter", "Mage", "Priest" },
            text = "Talk to Duokna. Buy [Refreshing Spring Water] from her. Buy [Rough Arrows] from her.",
            details = {
                "Refreshing Spring Water (10)",
                "Rough Arrow (1000)",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Duokna. Buy [Refreshing Spring Water] from her.",
            details = {
                "Refreshing Spring Water (5)",
            },
        },
        {
            classes = { "Warlock" },
            text = "Kill Mottled Boars en route to the Burning Blade Coven. Try to get to level 2 before getting there.",
            quest = 788,
            details = {
                "Mottled Boar (10)",
                "Kill Mottled Boar",
            },
        },
        {
            classes = { "Warlock" },
            text = "Travel toward the Burning Blade Coven.",
        },
        {
            classes = { "Warlock" },
            text = "Kill Vile Familiars. Loot them for Vile Familiar Heads.",
            quest = 1485,
            details = {
                "Vile Familiar Head (6)",
                "Kill Vile Familiar",
            },
        },
        {
            text = "Kill Mottled Boars.",
            quest = 788,
            details = {
                "Mottled Boar (10)",
                "Kill Mottled Boar",
            },
        },
        {
            text = "Talk to Hana'zua. Accept Sarkoth.",
            quest = 790,
            when = "accepted",
        },
        {
            text = "Kill Sarkoth. Loot him for Sarkoth's Mangled Claw.",
            quest = 790,
            details = {
                "Sarkoth's Mangled Claw (1)",
                "Kill Sarkoth",
            },
        },
        {
            text = "Talk to Hana'zua. Turn in Sarkoth. Accept Sarkoth.",
            quest = 804,
            when = "accepted",
            details = {
                "Turn in Sarkoth",
            },
        },
        {
            text = "Kill Mottled Boars.",
            quest = 788,
            details = {
                "Mottled Boar (10)",
                "Kill Mottled Boar",
            },
        },
        {
            classes = { "Warlock" },
            text = "Kill Mottled Boar",
        },
        {
            classes = { "Warlock" },
            text = "Grind Mottled Boars. Loot them until you have 1 silver worth of vendor items.",
            details = {
                "Kill Mottled Boar",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Duokna. Vendor Trash.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Ruzan. Turn in Vile Familiars. Accept Vile Familiars.",
            quest = 1499,
            when = "accepted",
            details = {
                "Turn in Vile Familiars",
            },
        },
        {
            classes = { "Warlock" },
            text = "Cast [Summon Imp].",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Zureetha. Turn in Vile Familiars. Accept Burning Blade Medallion.",
            quest = 794,
            when = "accepted",
            details = {
                "Turn in Vile Familiars",
                "NPC: Zureetha Fargaze",
            },
        },
        {
            text = "Talk to Gornek. Turn in Cutting Teeth. Accept Sting of the Scorpid. Accept Simple Parchment. Accept Simple Tablet. Accept Etched Tablet. Accept Encrypted Tablet. Accept Rune-Inscribed Tablet. Accept Hallowed Tablet. Accept Glyphic Tablet. Accept Tainted Tablet. Accept Etched Parchment. Accept Encrypted Parchment. Accept Rune-Inscribed Parchment. Accept Tainted Parchment. Accept Glyphic Parchment. Turn in Sarkoth.",
            quests = { 789, 2383, 3065, 3082, 3083, 3084, 3085, 3086, 98575, 3087, 3088, 3089, 3090, 98576 },
            when = "accepted",
            details = {
                "Turn in Sarkoth",
                "Turn in Cutting Teeth",
            },
        },
        {
            classes = { "Rogue" },
            text = "Travel toward Rwag.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Rwag. Turn in Encrypted Tablet. Turn in Encrypted Parchment. Train [Backstab].",
            quests = { 3083, 3088 },
            when = "complete",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Rwag. Turn in Encrypted Tablet. Turn in Encrypted Parchment.",
            quests = { 3083, 3088 },
            when = "complete",
        },
        {
            text = "Talk to Kzan Thornslash in the back of the cave. Turn in Wayward Weapons.",
            quest = 97279,
            when = "complete",
        },
        {
            text = "Abandon Wayward Weapons.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kzan. Vendor trash. Sell your weapon if it gives you enough money for a [Short Staff] (97c).",
            details = {
                "NPC: Kzan Thornslash",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kzan. Buy a [Short Staff] from him.",
            details = {
                "Collect Short Staff (1)",
                "NPC: Kzan Thornslash",
            },
        },
        {
            classes = { "Rogue", "Warrior" },
            text = "Talk to Norzsh. Buy a [Mining Pick] from him. Train [Mining]. This will allow you to find [Rough Stones] from nodes in order to craft [Sharpening Stones] (+2 Weapon Damage for 30 minutes).",
            details = {
                "Mining Pick (1)",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Hraug. Vendor Trash.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Nartok. Turn in Tainted Parchment. Turn in Tainted Tablet. Train [Corruption].",
            quests = { 3090, 98575 },
            when = "complete",
        },
        {
            text = "Accept Galgar's Cactus Apple Surprise.",
            quest = 4402,
            when = "accepted",
        },
        {
            excludeClasses = { "Rogue", "Shaman" },
            text = "Talk to Duokna. Buy [Refreshing Spring Water] from her. Buy [Rough Arrows] from her. Vendor Trash.",
            details = {
                "Refreshing Spring Water (15)",
                "Rough Arrow (1000)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Shikrik. Turn in Rune-Inscribed Tablet. Turn in Rune-Inscribed Parchment.",
            quests = { 3084, 3089 },
            when = "complete",
        },
        {
            classes = { "Mage" },
            text = "Talk to Mai'ah. Turn in Glyphic Tablet. Turn in Glyphic Parchment. Train [Arcane Intellect].",
            quests = { 3086, 98576 },
            when = "complete",
        },
        {
            excludeClasses = { "Warlock" },
            text = "Talk to Zureetha. Accept Vile Familiars.",
            quest = 792,
            when = "accepted",
            details = {
                "NPC: Zureetha Fargaze",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Jen'shan. Turn in Etched Tablet. Turn in Etched Parchment.",
            quests = { 3082, 3087 },
            when = "complete",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Frang. Turn in Simple Parchment. Turn in Simple Tablet.",
            quests = { 2383, 3065 },
            when = "complete",
        },
        {
            text = "Talk to Thazz'ril. Accept Lazy Peons.",
            quest = 5441,
            when = "accepted",
            details = {
                "NPC: Foreman Thazz'ril",
            },
        },
        {
            text = "Loot the Cactus Apples near the Cacti.",
            quest = 4402,
            details = {
                "Cactus Apple (10)",
            },
        },
        {
            text = "Use the [Foreman's Blackjack] on sleeping Lazy Peons.",
            quest = 5441,
            details = {
                "Peons Awoken (5)",
            },
        },
        {
            excludeClasses = { "Warlock" },
            text = "Kill Scorpid Workers. Loot them for Scorpid Worker Tails.",
            quest = 789,
            details = {
                "Scorpid Worker Tail (10)",
                "Kill Scorpid Worker",
            },
        },
        {
            excludeClasses = { "Warlock" },
            text = "Kill Vile Familiars.",
            quest = 792,
            details = {
                "Vile Familiar (12)",
                "Kill Vile Familiar",
            },
        },
        {
            text = "Kill Scorpid Workers. Loot them for Scorpid Worker Tails.",
            quest = 789,
            details = {
                "Scorpid Worker Tail (10)",
                "Kill Scorpid Worker",
            },
        },
        {
            text = "Use the [Foreman's Blackjack] on sleeping Lazy Peons.",
            quest = 5441,
            details = {
                "Peons Awoken (5)",
            },
        },
        {
            text = "Kill Mottled Boar",
            details = {
                "Kill Scorpid Worker",
                "Kill Vile Familiar",
            },
        },
        {
            text = "Turn in Galgar's Cactus Apple Surprise.",
            quest = 4402,
            when = "complete",
        },
        {
            text = "Talk to Duokna. Buy [Refreshing Spring Water] from her. Buy [Rough Arrows] from her. Vendor Trash.",
            details = {
                "Refreshing Spring Water (5)",
                "Rough Arrow (1000)",
            },
        },
        {
            text = "Talk to Gornek. Turn in Sting of the Scorpid.",
            quest = 789,
            when = "complete",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Shikrik and Canaga. Train [Earth Shock]. Accept Call of Earth.",
            quest = 1516,
            when = "accepted",
        },
        {
            classes = { "Mage" },
            text = "Talk to Mai'ah. Train [Frostbolt].",
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Train [Power Word: Fortitude]. Train [Shadow Word: Pain].",
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Train [Shadow Word: Pain].",
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Train your class spells. Turn in Hallowed Tablet.",
            quest = 3085,
            when = "complete",
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Train [Power Word: Fortitude]. Train [Shadow Word: Pain]. Turn in Hallowed Tablet.",
            quest = 3085,
            when = "complete",
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Train [Shadow Word: Pain]. Turn in Hallowed Tablet.",
            quest = 3085,
            when = "complete",
        },
        {
            excludeClasses = { "Warlock" },
            text = "Talk to Zureetha. Turn in Vile Familiars. Accept Burning Blade Medallion.",
            quest = 794,
            when = "accepted",
            details = {
                "Turn in Vile Familiars",
                "NPC: Zureetha Fargaze",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Jen'shan. Train [Serpent Sting].",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Frang. Train [Charge]. Train [Rend]. Train your class spells.",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Frang. Train [Rend].",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Frang. Train [Charge].",
        },
        {
            text = "Talk to Thazz'ril. Turn in Lazy Peons. Accept Thazz'ril's Pick.",
            quest = 6394,
            when = "accepted",
            details = {
                "Turn in Lazy Peons",
                "NPC: Foreman Thazz'ril",
            },
        },
        {
            text = "Kill Mottled Boar",
            details = {
                "Kill Scorpid Worker",
                "Kill Vile Familiar",
            },
        },
        {
            text = "Loot the Cactus Apples near the Cacti.",
            quest = 4402,
            details = {
                "Cactus Apple (10)",
            },
        },
        {
            excludeClasses = { "Warrior", "Rogue", "Shaman" },
            text = "Kill Vile Familiar",
        },
        {
            excludeClasses = { "Warrior", "Rogue", "Shaman" },
            text = "Kill Vile Familiar",
        },
        {
            text = "Enter the cave.",
        },
        {
            text = "Travel toward Thazz'ril's Pick.",
        },
        {
            classes = { "Shaman" },
            text = "Kill Felstalkers. Loot them for Felstalker Hooves.",
            quest = 1516,
            details = {
                "Felstalker Hoof (2)",
                "Kill Felstalker",
            },
        },
        {
            text = "Loot Thazz'ril's Pick against the wall.",
            quest = 6394,
            details = {
                "Thazz'ril's Pick (1)",
            },
        },
        {
            text = "Kill Yarrog Baneshadow. Loot him for the Burning Blade Medallion.",
            quest = 794,
            details = {
                "Burning Blade Medallion (1)",
                "Kill Yarrog Baneshadow",
            },
        },
        {
            classes = { "Shaman" },
            text = "Kill Felstalkers. Loot them for Felstalker Hooves.",
            quest = 1516,
            details = {
                "Felstalker Hoof (2)",
                "Kill Felstalker",
            },
        },
        {
            text = "Die and respawn at the Spirit Healer. Make sure you are on the waypoint arrow when you die!",
            note = "softcore",
        },
        {
            text = "Talk to Gar'thok. You can talk to him from outside or on top of the bunker. Accept Vanquish the Betrayers.",
            note = "softcore",
            quest = 784,
            when = "accepted",
        },
        {
            text = "Talk to Cook Torka. Accept This Fruit Could Bite Back.",
            note = "softcore",
            quest = 96825,
            when = "accepted",
        },
        {
            text = "Travel toward the tower.",
            note = "softcore",
        },
        {
            text = "Travel up the tower toward Furl.",
            note = "softcore",
        },
        {
            text = "Talk to Furl. Accept Carry Your Weight.",
            note = "softcore",
            quest = 791,
            when = "accepted",
            details = {
                "NPC: Furl Scornbrow",
            },
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Krunn. Train [Mining]. This will allow you to find [Rough Stones] from nodes in order to craft [Sharpening Stones] (+2 Weapon Damage for 30 minutes).",
            note = "softcore",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Wuark. Buy a [Mining Pick] from him.",
            note = "softcore",
            details = {
                "Mining Pick (1)",
            },
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Dwukk. Train [Blacksmithing].",
            note = "softcore",
        },
        {
            text = "Talk to Turroc. Accept For Honor.",
            note = "softcore",
            quest = 96822,
            when = "accepted",
        },
        {
            text = "Talk to Thazz'ril. Turn in Thazz'ril's Pick.",
            quest = 6394,
            when = "complete",
            details = {
                "NPC: Foreman Thazz'ril",
            },
        },
        {
            text = "Turn in Galgar's Cactus Apple Surprise.",
            quest = 4402,
            when = "complete",
        },
        {
            text = "Talk to Duokna. Vendor Trash.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Shikrik and Canaga. Train [Healing Wave]. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1517,
            when = "accepted",
            details = {
                "Turn in Call of Earth",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Canaga. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1517,
            when = "accepted",
            details = {
                "Turn in Call of Earth",
                "NPC: Canaga Earthcaller",
            },
        },
        {
            text = "Talk to Zureetha. Turn in Burning Blade Medallion. Accept Report to Sen'jin Village.",
            quest = 805,
            when = "accepted",
            details = {
                "Turn in Burning Blade Medallion",
                "NPC: Zureetha Fargaze",
            },
        },
        {
            text = "Click the Lost Journal on top of the barrel. Accept The Adventurer.",
            quest = 96652,
            when = "accepted",
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Accept In Favor of Spirituality. Train [Smite]. Train [Power Word: Shield].",
            quest = 5649,
            when = "accepted",
        },
        {
            classes = { "Mage" },
            text = "Talk to Mai'ah. Train [Fireball]. Train [Fire Blast].",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Jen'shan. Train [Hunter's Mark]. Train [Arcane Shot].",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Jen'shan. Train [Arcane Shot].",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Frang. Train [Parry]. Train [Thunder Clap].",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Frang. Train [Parry].",
        },
        {
            classes = { "Rogue" },
            text = "Travel toward Rwag.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Rwag. Train [Sinister Strike]. Train [Gouge].",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Rwag. Train [Sinister Strike].",
        },
        {
            classes = { "Warlock" },
            text = "Travel toward Hraug.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Hraug. Buy the [Grimoire of Blood Pact] from him. Vendor Trash. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Nartok. Train [Shadow Bolt]. Train [Life Tap].",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Nartok. Train [Shadow Bolt].",
        },
        {
            classes = { "Shaman" },
            text = "Travel toward the Shaman Shrine.",
        },
        {
            classes = { "Shaman" },
            text = "Use the [Earth Sapta].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to the Manifestation. Turn in Call of Earth. Accept Call of Earth.",
            quest = 1518,
            when = "accepted",
            details = {
                "Turn in Call of Earth",
                "NPC: Minor Manifestation of Earth",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Canaga. Turn in Call of Earth.",
            quest = 1518,
            when = "complete",
            details = {
                "NPC: Canaga Earthcaller",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Shikrik. Train [Healing Wave].",
        },
        {
            text = "Exit the Valley of Trials.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-6-10-durotar",
    name = "6-10 Durotar",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            text = "Talk to Ukor. Accept A Peon's Burden.",
            quest = 2161,
            when = "accepted",
        },
        {
            text = "Travel to Sen'Jin Village.",
        },
        {
            text = "Talk to Lar. He patrols a little. Accept Thwarting Kolkar Aggression.",
            quest = 786,
            when = "accepted",
            details = {
                "NPC: Lar Prowltusk",
            },
        },
        {
            text = "Talk to Xar'Ti. Accept Bloodtalon Matriarch.",
            quest = 97223,
            when = "accepted",
        },
        {
            text = "Talk to Vel'rin, Vornal and Gadrin. Accept Practical Prey. Accept Legging It. Accept A Solvent Spirit. Accept Forgotten Loa Idols. Turn in Report to Sen'jin Village. Accept Minshina's Skull. Accept Zalazane. Accept Report to Orgnil.",
            quests = { 817, 96821, 818, 97225, 808, 826, 823 },
            when = "accepted",
            details = {
                "Turn in Report to Sen'jin Village",
                "NPC: Vel'rin Fang, Master Vornal, Master Gadrin",
            },
        },
        {
            text = "Enter the big hut.",
        },
        {
            excludeClasses = { "Rogue", "Warrior" },
            text = "Talk to Pa'zula. This will unlock a quest. Skip this step if you already have 2 professions. Train [Enchanting].",
        },
        {
            excludeClasses = { "Rogue", "Warrior" },
            text = "Talk to Pa'zula. Accept A Pain in the Neck.",
            quest = 96873,
            when = "accepted",
        },
        {
            classes = { "Rogue" },
            text = "Talk to K'waii. Buy [Weighted Throwing Axe] from her.",
            details = {
                "Weighted Throwing Axe (200)",
            },
        },
        {
            classes = { "Warlock", "Mage", "Priest" },
            text = "Talk to K'waii. Buy [Refreshing Spring Water] from her.",
            details = {
                "Refreshing Spring Water (20)",
            },
        },
        {
            classes = { "Warlock", "Mage", "Priest" },
            text = "Talk to K'waii. Buy [Refreshing Spring Water] from her.",
            details = {
                "Refreshing Spring Water (10)",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Walking Stick] (4s 79c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Trayexir. Buy a [Walking Stick] from him.",
            details = {
                "Collect Walking Stick (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Stiletto] (3s 81c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Trayexir. Buy a [Stiletto] from him.",
            details = {
                "Collect Stiletto (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Large Axe] (4s 60c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Trayexir. Buy a [Large Axe] from him.",
            details = {
                "Collect Large Axe (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Tomahawk] (5s 13c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Trayexir. Buy a [Tomahawk] from him.",
            details = {
                "Collect Tomahawk (1)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Hornwood Recurve Bow] (2s 71c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Trayexir. Buy a [Hornwood Recurve Bow] from him.",
            details = {
                "Collect Hornwood Recurve Bow (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Equip the [Weighted Throwing Axe].",
        },
        {
            classes = { "Shaman" },
            text = "Equip the [Walking Stick].",
        },
        {
            classes = { "Rogue" },
            text = "Equip the [Stiletto].",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Equip the [large Axe].",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Equip the [Tomahawk].",
        },
        {
            classes = { "Hunter" },
            text = "Equip the [Hornwood Recurve Bow].",
        },
        {
            classes = { "Mage" },
            text = "Talk to Un'Thuwa. Train [Fireball]. Train [Fire Blast].",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Train your class spells.",
            note = "softcore",
            details = {
                "Cast [Find Minerals] and mine any Copper Vein you find for [Rough Stones]. Make [Sharpening Stones] from them",
            },
        },
        {
            text = "Run down the beach. Kill Crawlers and Makruras. Loot them for their Mucus and Eyes. You do not have to finish this step here.",
            quest = 818,
            details = {
                "Crawler Mucus (8)",
                "Kill +Pygmy Surf Crawler",
                "Kill +Surf Crawler",
                "Intact Makrura Eye (4)",
                "Kill +Makrura Shellhide",
                "Kill +Makrura Clacker",
            },
        },
        {
            text = "Reach the end of the beach.",
        },
        {
            text = "Kill Kolkar Drudges and Kolkar Outrunners. Loot them for their Canvas Scraps.",
            quest = 791,
            details = {
                "Canvas Scraps (8)",
            },
        },
        {
            text = "Enter the Kolkar base.",
        },
        {
            classes = { "Priest" },
            text = "Start collecting 3 stacks of [Linen Cloth] as you quest throughout Durotar. This will be used to make your wand later. Skip this step if you've already bought a wand or can get one cheap from the AH.",
            note = "softcore",
            details = {
                "Linen Cloth (60)",
            },
        },
        {
            classes = { "Priest" },
            text = "Start collecting 3 stacks of [Linen Cloth] as you quest throughout Durotar. This will be used to make your wand later.",
            note = "hardcore",
            details = {
                "Linen Cloth (60)",
            },
        },
        {
            text = "Be careful if Kolkanis is up, he is a level 9 rare. You may have to use a [Minor Healing Potion] if you have it.",
        },
        {
            text = "Burn the Attack Plan inside the tent on the ground.",
            quest = 786,
            details = {
                "Attack Plan: Valley of Trials destroyed (1)",
            },
        },
        {
            text = "Burn the Attack Plan on the ground.",
            quest = 786,
            details = {
                "Attack Plan: Sen'jin Village destroyed (1)",
            },
        },
        {
            text = "Burn the Attack Plan on the ground.",
            quest = 786,
            details = {
                "Attack Plan: Orgrimmar destroyed (1)",
            },
        },
        {
            text = "This starts an escort quest. If Pal'juh is not there, feel free to skip this step and deathskip back to Sen'jin Village at the Bonfire.",
            note = "softcore",
        },
        {
            text = "This starts an escort quest. If Pal'juh is not there, feel free to skip this step.",
            note = "hardcore",
        },
        {
            text = "Escort Pal'juh out of Kolkar Crag.",
            note = "softcore",
            quest = 99123,
        },
        {
            text = "Talk to Lar. He patrols a little. Turn in Thwarting Kolkar Aggression.",
            quest = 786,
            when = "complete",
            details = {
                "NPC: Lar Prowltusk",
            },
        },
        {
            text = "Talk to Master Vornal. Turn in Lost in the Shadows.",
            quest = 99123,
            when = "complete",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Walking Stick] (4s 79c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Trayexir. Buy a [Walking Stick] from him.",
            details = {
                "Collect Walking Stick (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Stiletto] (3s 81c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Trayexir. Buy a [Stiletto] from him.",
            details = {
                "Collect Stiletto (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Large Axe] (4s 60). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Trayexir. Buy a [large Axe] from him.",
            details = {
                "Collect Large Axe (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Tomahawk] (5s 13c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Trayexir. Buy a [Tomahawk] from him.",
            details = {
                "Collect Tomahawk (1)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Trayexir. Vendor trash. Sell your weapon if it gives you enough money for a [Hornwood Recurve Bow] (2s 71c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Trayexir. Buy a [Hornwood Recurve Bow] from him.",
            details = {
                "Collect Hornwood Recurve Bow (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Equip the [Weighted Throwing Axe].",
        },
        {
            classes = { "Shaman" },
            text = "Equip the [Walking Stick].",
        },
        {
            classes = { "Rogue" },
            text = "Equip the [Stiletto].",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Equip the [large Axe].",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Equip the [Tomahawk].",
        },
        {
            classes = { "Hunter" },
            text = "Equip the [Hornwood Recurve Bow].",
        },
        {
            text = "Talk to Vornal. Turn in A Solvent Spirit.",
            quest = 818,
            when = "complete",
            details = {
                "NPC: Master Vornal",
            },
        },
        {
            classes = { "Warlock", "Mage", "Priest" },
            text = "Talk to K'waii. Buy [Refreshing Spring Water] from her. Vendor trash.",
            details = {
                "Refreshing Spring Water (20)",
            },
        },
        {
            excludeClasses = { "Warlock", "Mage", "Priest" },
            text = "Talk to Hai'zan. Buy [Haunch of Meat] from him if you can afford it. Vendor trash.",
        },
        {
            text = "Talk to Lar. He patrols a little. Turn in Thwarting Kolkar Aggression.",
            note = "softcore",
            quest = 786,
            when = "complete",
            details = {
                "NPC: Lar Prowltusk",
            },
        },
        {
            text = "Kill Ridgeshade Lurkers and Ridgeshade Creepers.",
            quest = 96821,
            details = {
                "6/6 Ridgeshade Lurker slain",
                "Kill +Ridgeshade Lurker",
                "6/6 Ridgeshade Creeper slain",
                "Kill +Ridgeshade Creeper",
            },
        },
        {
            text = "Kill Ukorsbane (elite). Loot him for [Ukor's Lost Pack]. This is hard! Group up if possible. Skip this step if you can't kill it. Accept Ukor's Lost Pack.",
            quest = 96876,
            when = "accepted",
            details = {
                "Kill Ukorsbane",
            },
        },
        {
            text = "Kill Ridgeshade Lurkers and Ridgeshade Creepers.",
            quest = 96821,
            details = {
                "6/6 Ridgeshade Lurker slain",
                "Kill +Ridgeshade Lurker",
                "6/6 Ridgeshade Creeper slain",
                "Kill +Ridgeshade Creeper",
            },
        },
        {
            text = "Talk to Brakk. Turn in The Adventurer. Accept The Great Outdoors.",
            note = "hardcore",
            quest = 96604,
            when = "accepted",
            details = {
                "Turn in The Adventurer",
            },
        },
        {
            text = "Talk to Brakk. Accept The Great Outdoors.",
            note = "hardcore",
            quest = 96604,
            when = "accepted",
        },
        {
            text = "Type /sit at the campfire and wait for one minute until you get the \"Camp Benefits\" buff. /sit.",
            note = "hardcore",
            quest = 96604,
            details = {
                "1/1 Use the /sit emote near the campfire",
                "Gain the Boosted Rest buff",
            },
        },
        {
            text = "Talk to Brakk. Turn in The Great Outdoors. Accept Camping 101: Cooking.",
            note = "hardcore",
            quest = 96655,
            when = "accepted",
            details = {
                "Turn in The Great Outdoors",
            },
        },
        {
            text = "Travel to Razor Hill.",
            note = "hardcore",
        },
        {
            text = "Talk to Orgnil, Gar'Thok and Torka. Turn in Report to Orgnil. Accept Dark Storms. Accept Vanquish the Betrayers. Accept Encroachment. Accept Break a Few Eggs.",
            note = "hardcore",
            quests = { 806, 784, 837, 815 },
            when = "accepted",
            details = {
                "Turn in Report to Orgnil",
            },
        },
        {
            text = "Talk to Torka. Train Cooking. Turn in Camping 101: Cooking.",
            note = "hardcore",
            quest = 96655,
            when = "complete",
            details = {
                "NPC: Cook Torka",
            },
        },
        {
            text = "Talk to Cook Torka. Accept This Fruit Could Bite Back.",
            note = "hardcore",
            quest = 96825,
            when = "accepted",
        },
        {
            text = "Travel toward the tower.",
            note = "hardcore",
        },
        {
            text = "Travel up the tower toward Furl.",
            note = "hardcore",
        },
        {
            text = "Talk to Furl. Accept Carry Your Weight.",
            note = "hardcore",
            quest = 791,
            when = "accepted",
            details = {
                "NPC: Furl Scornbrow",
            },
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Krunn. Train [Mining]. This will allow you to find [Rough Stones] from nodes in order to craft [Sharpening Stones] (+2 Weapon Damage for 30 minutes).",
            note = "hardcore",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Wuark. Buy a [Mining Pick] from him.",
            note = "hardcore",
            details = {
                "Mining Pick (1)",
            },
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Dwukk. Train [Blacksmithing].",
            note = "hardcore",
        },
        {
            text = "Talk to Turroc. Accept For Honor.",
            note = "hardcore",
            quest = 96822,
            when = "accepted",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Train your class spells.",
            note = "hardcore",
            details = {
                "Cast [Find Minerals] and mine any Copper Vein you find for [Rough Stones]. Make [Sharpening Stones] from them",
            },
        },
        {
            text = "Travel to Tiragarde Keep.",
            note = "softcore",
        },
        {
            text = "Travel to Tiragarde Keep.",
            note = "hardcore",
        },
        {
            text = "Kill Kul Tiras Sailors and Kul Tiras Marines. Loot them for their Canvas Scraps.",
            quests = { 784, 791 },
            details = {
                "Kul Tiras Sailor (10)",
                "Kill +Kul Tiras Sailor",
                "Kul Tiras Marine (8)",
                "Kill +Kul Tiras Marine",
                "Canvas Scraps (8)",
            },
        },
        {
            text = "Loot the Raider's Bow on the ground. It has two different spawn locations.",
            quest = 96822,
            details = {
                "1/1 Raider's Bow",
            },
        },
        {
            text = "Loot the Raider's Battleaxe on the ground.",
            quest = 96822,
            details = {
                "1/1 Raider's Battleaxe",
            },
        },
        {
            text = "Be careful if Watch Commander Zalaphil is up, as he is a level 9 rare. You may have to use a [Minor Healing Potion] if you have one.",
        },
        {
            text = "Move toward the second floor of the keep.",
        },
        {
            text = "Kill Lieutenant Benedict. Loot him for his Key.",
            quest = 784,
            details = {
                "Lieutenant Benedict (1)",
                "Collect Benedict's Key (1)",
                "Kill Lieutenant Benedict",
            },
        },
        {
            text = "Go upstairs in the keep. Open Benedict's Chest. Loot it for the [Aged Envelope]. Use the [Aged Envelope] to start the quest. Accept The Admiral's Orders.",
            quest = 830,
            when = "accepted",
            details = {
                "Collect Aged Envelope (1)",
            },
        },
        {
            text = "Loot the Raider's Bow on the ground. It has two different spawn locations.",
            quest = 96822,
            details = {
                "1/1 Raider's Bow",
            },
        },
        {
            text = "Loot the Raider's Shield on the ground.",
            quest = 96822,
            details = {
                "1/1 Raider's Shield",
            },
        },
        {
            text = "Kill Kul Tiras Sailors and Kul Tiras Marines. Loot them for their Canvas Scraps.",
            quests = { 784, 791 },
            details = {
                "Kul Tiras Sailor (10)",
                "Kill +Kul Tiras Sailor",
                "Kul Tiras Marine (8)",
                "Kill +Kul Tiras Marine",
                "Canvas Scraps (8)",
            },
        },
        {
            text = "Kill Kul Tiras Sailors and Kul Tiras Marines.",
            quest = 784,
            details = {
                "Kul Tiras Sailor (10)",
                "Kill +Kul Tiras Sailor",
                "Kul Tiras Marine (8)",
                "Kill +Kul Tiras Marine",
            },
        },
        {
            text = "Kill Kul Tiras Sailors and Kul Tiras Marines. Loot them for their Canvas Scraps.",
            quest = 791,
            details = {
                "Canvas Scraps (8)",
                "Kill Kul Tiras Sailor",
                "Kill Kul Tiras Marine",
            },
        },
        {
            text = "Talk to Brakk. Turn in The Adventurer. Accept The Great Outdoors.",
            note = "softcore",
            quest = 96604,
            when = "accepted",
            details = {
                "Turn in The Adventurer",
            },
        },
        {
            text = "Talk to Brakk. Accept The Great Outdoors.",
            note = "softcore",
            quest = 96604,
            when = "accepted",
        },
        {
            text = "Type /sit at the campfire and wait for one minute until you get the \"Camp Benefits\" buff. /sit.",
            note = "softcore",
            quest = 96604,
            details = {
                "1/1 Use the /sit emote near the campfire",
                "Gain the Boosted Rest buff",
            },
        },
        {
            text = "Talk to Brakk. Turn in The Great Outdoors. Accept Camping 101: Cooking.",
            note = "softcore",
            quest = 96655,
            when = "accepted",
            details = {
                "Turn in The Great Outdoors",
            },
        },
        {
            text = "Travel to Razor Hill.",
        },
        {
            text = "Talk to Orgnil, Gar'Thok and Torka. Turn in Report to Orgnil. Accept Dark Storms. Turn in Vanquish the Betrayers. Turn in The Admiral's Orders. Turn in Legging It. Accept From The Wreckage. Accept The Admiral's Orders. Accept Encroachment. Accept Break a Few Eggs.",
            note = "softcore",
            quests = { 806, 825, 831, 837, 815 },
            when = "accepted",
            details = {
                "Turn in Legging It",
                "Turn in The Admiral's Orders",
                "Turn in Vanquish the Betrayers",
                "Turn in Report to Orgnil",
            },
        },
        {
            text = "Talk to Gar'Thok. Turn in Vanquish the Betrayers. Turn in The Admiral's Orders. Turn in Legging It. Accept From The Wreckage. Accept The Admiral's Orders.",
            note = "hardcore",
            quests = { 825, 831 },
            when = "accepted",
            details = {
                "Turn in Legging It",
                "Turn in The Admiral's Orders",
                "Turn in Vanquish the Betrayers",
            },
        },
        {
            text = "Talk to Orgnil. Accept A Missing Hand.",
            quest = 99048,
            when = "accepted",
            details = {
                "NPC: Orgnil Soulscar",
            },
        },
        {
            text = "Talk to Torka. Train Cooking. Turn in Camping 101: Cooking.",
            note = "softcore",
            quest = 96655,
            when = "complete",
            details = {
                "NPC: Cook Torka",
            },
        },
        {
            text = "Travel toward the tower.",
        },
        {
            text = "Travel up the tower toward Furl.",
        },
        {
            text = "Talk to Furl. Turn in Carry Your Weight.",
            quest = 791,
            when = "complete",
            details = {
                "NPC: Furl Scornbrow",
            },
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Krunn. Train [Mining]. This will allow you to find [Rough Stones] from nodes in order to craft [Sharpening Stones] (+2 Weapon Damage for 30 minutes).",
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Buy a [Mining Pick] from Wuark.",
            details = {
                "Mining Pick (1)",
            },
        },
        {
            classes = { "Warrior", "Rogue" },
            text = "Talk to Dwukk. Train [Blacksmithing].",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Uhgar. Vendor trash. Sell your weapon if it gives you enough money for a [Walking Stick] (4s 79c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Uhgar. Buy a [Walking Stick] from him.",
            details = {
                "Collect Walking Stick (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Uhgar. Vendor trash. Sell your weapon if it gives you enough money for a [Stiletto] (3s 81c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Uhgar. Buy a [Stiletto] from him.",
            details = {
                "Collect Stiletto (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Uhgar. Vendor trash. Sell your weapon if it gives you enough money for a [Large Axe] (4s 60c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Uhgar. Buy a [large Axe] from him.",
            details = {
                "Collect Large Axe (1)",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Uhgar. Vendor trash. Sell your weapon if it gives you enough money for a [Tomahawk] (5s 13c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Uhgar. Buy a [Tomahawk] from him.",
            details = {
                "Collect Tomahawk (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Equip the [Weighted Throwing Axe].",
        },
        {
            classes = { "Shaman" },
            text = "Equip the [Walking Stick].",
        },
        {
            classes = { "Rogue" },
            text = "Equip the [Stiletto].",
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Equip the [large Axe].",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Equip the [Tomahawk].",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ghrawt. Vendor trash. Sell your weapon if it gives you enough money for a [Hornwood Recurve Bow] (2s 83c). You'll come back later if you don't have enough yet.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ghrawt. Buy a [Hornwood Recurve Bow] from him.",
            details = {
                "Collect Hornwood Recurve Bow (1)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Equip the [Hornwood Recurve Bow].",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ghrawt. Buy [Rough Arrows] from him.",
            details = {
                "Rough Arrow (1000)",
            },
        },
        {
            text = "Set your Hearthstone to Razor Hill.",
            details = {
                "NPC: Innkeeper Grosk",
            },
        },
        {
            text = "Talk to Innkeeper Grosk. Buy [Ice Cold Milk] from him. Buy [Haunch of Meat] from him. Save 4 silver for your class spells!. Save 2 silver for your class spells!. Vendor Trash. Turn in A Peon's Burden. Train your class spells.",
            quest = 2161,
            when = "complete",
        },
        {
            excludeClasses = { "Mage", "Hunter", "Druid" },
            text = "Talk to Innkeeper Grosk. Buy [Ice Cold Milk] from him. Buy [Haunch of Meat] from him. Vendor Trash. Turn in A Peon's Burden. Train your class spells.",
            quest = 2161,
            when = "complete",
        },
        {
            text = "Talk to Turroc. Turn in For Honor.",
            quest = 96822,
            when = "complete",
        },
        {
            classes = { "Warrior" },
            text = "Talk to Tarshaw. Train your class spells.",
            details = {
                "NPC: Tarshaw Jaggedscar",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Swart. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Dhugru. Train your class spells.",
            details = {
                "NPC: Dhugru Gorelust",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Kitha and buy [Firebolt Rank 2]. Train your class spells.",
            details = {
                "Grimoire of Firebolt (Rank 2) (1)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Train your class spells.",
        },
        {
            classes = { "Priest" },
            text = "Talk to Tai'jin. Turn in In Favor of Spirituality. Accept Garments of Spirituality. Train [Lesser Heal Rank 2].",
            quest = 5648,
            when = "accepted",
            details = {
                "Turn in In Favor of Spirituality",
            },
        },
        {
            classes = { "Priest" },
            text = "Cast [Lesser Heal] and [Power Word: Fortitude] on Kor'ja.",
            quest = 5648,
            details = {
                "Heal and fortify Grunt Kor'ja",
                "NPC: Grunt Kor'ja",
            },
        },
        {
            classes = { "Priest" },
            text = "Talk to Tai'jin. Turn in Garments of Spirituality. Train your class spells.",
            quest = 5648,
            when = "complete",
        },
        {
            classes = { "Rogue", "Warrior" },
            text = "Talk to Rawrk. Train [First Aid].",
        },
        {
            text = "Talk to Jark. Buy a [Small Brown Pouch] from him.",
            details = {
                "Small Brown Pouch (1)",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Kaplak. Train your class spells.",
        },
        {
            text = "Talk to Orgnil. Accept A Missing Hand.",
            quest = 99048,
            when = "accepted",
            details = {
                "NPC: Orgnil Soulscar",
            },
        },
        {
            text = "Talk to Heglan Shadeeye. Turn in A Missing Hand. Accept Threat from Below.",
            quest = 99049,
            when = "accepted",
            details = {
                "Turn in A Missing Hand",
            },
        },
        {
            text = "Loot the Abandoned Dagger on the ground.",
            quest = 99049,
            details = {
                "1/1 Orcish Dagger",
            },
        },
        {
            text = "Loot the Weapon Piece on the ground.",
            quest = 99049,
            details = {
                "1/1 Broken Bone Trident",
            },
        },
        {
            text = "Loot the Strange Debris on the ground.",
            quest = 99049,
            details = {
                "1/1 Banner Scrap",
            },
        },
        {
            text = "Kill Pygmy Surf Crawlers and Surf Crawlers. Loot them for their Mucus. Kill Makrura Shellhides and Makrura Clackers. Loot them for their Eyes.",
            quest = 818,
            details = {
                "Crawler Mucus (8)",
                "Kill +Pygmy Surf Crawler",
                "Kill +Surf Crawler",
                "Intact Makrura Eye (4)",
                "Kill +Makrura Shellhide",
                "Kill +Makrura Clacker",
            },
        },
        {
            text = "Loot the Gnomish Toolboxes inside and around the boats.",
            quest = 825,
            details = {
                "Gnomish Tools (3)",
            },
        },
        {
            text = "Swim to the Island.",
        },
        {
            text = "Loot the Taillasher Eggs on the ground. They're usually guarded by a Bloodtalon Taillasher.",
            quest = 815,
            details = {
                "Taillasher Egg (3)",
                "Kill Bloodtalon Taillasher",
            },
        },
        {
            text = "Kill Durotar Tigers. Loot them for their Fur.",
            quest = 817,
            details = {
                "Durotar Tiger Fur (4)",
                "Kill Durotar Tiger",
            },
        },
        {
            text = "Kill Pygmy Surf Crawlers and Surf Crawlers. Loot them for their Mucus. Kill Makrura Shellhides and Makrura Clackers. Loot them for their Eyes.",
            quest = 818,
            details = {
                "Crawler Mucus (8)",
                "Kill +Pygmy Surf Crawler",
                "Kill +Surf Crawler",
                "Intact Makrura Eye (4)",
                "Kill +Makrura Shellhide",
                "Kill +Makrura Clacker",
            },
        },
        {
            text = "Kill the Bloodtalon Matriarch. Loot it for the Bloodtalon Matriarch Eggs.",
            quest = 97223,
            details = {
                "1/1 Bloodtalon Matriarch Eggs",
                "Kill Bloodtalon Matriarch",
            },
        },
        {
            text = "Swim to the main island.",
        },
        {
            text = "Kill Hexed Trolls and Voodoo Trolls. Loot them for Hexed Pendants. Use [Disenchant] on the Hexed Pendants to obtain [Luminous Residue].",
            quests = { 826, 96873 },
            details = {
                "Hexed Troll (8)",
                "Kill +Hexed Troll",
                "Voodoo Troll (8)",
                "Kill +Voodoo Troll",
                "Luminous Residue (x3)",
            },
        },
        {
            text = "Kill Hexed Trolls and Voodoo Trolls.",
            quest = 826,
            details = {
                "Hexed Troll (8)",
                "Kill +Hexed Troll",
                "Voodoo Troll (8)",
                "Kill +Voodoo Troll",
            },
        },
        {
            text = "Loot the Loa Idols on the ground. They are mainly found near the stone walls in the area.",
            quest = 97225,
            details = {
                "Forgotten Loa Idols (x8)",
            },
        },
        {
            text = "Kill Zalazane. Loot him for his Head. Save your [Earth Shock] for when he casts [Healing Wave]. Save your [Gouge] for when he casts [Healing Wave].",
            quest = 826,
            details = {
                "Zalazane's Head (1)",
                "Kill Zalazane",
            },
        },
        {
            text = "Loot one of the Skulls on the ground.",
            quest = 808,
            details = {
                "Minshina's Skull (1)",
            },
        },
        {
            text = "Kill Zalazane. Loot him for his Head. Save your [Earth Shock] for when he casts [Healing Wave]. Save your [Gouge] for when he casts [Healing Wave].",
            quest = 826,
            details = {
                "Zalazane's Head (1)",
                "Kill Zalazane",
            },
        },
        {
            text = "Kill Durotar Tigers. Loot them for their Fur.",
            quest = 817,
            details = {
                "Durotar Tiger Fur (4)",
                "Kill Durotar Tiger",
            },
        },
        {
            text = "Kill Hexed Trolls and Voodoo Trolls. Loot them for Hexed Pendants. Use [Disenchant] on the Hexed Pendants to obtain [Luminous Residue].",
            quests = { 826, 96873 },
            details = {
                "Hexed Troll (8)",
                "Kill +Hexed Troll",
                "Voodoo Troll (8)",
                "Kill +Voodoo Troll",
                "Luminous Residue (x3)",
            },
        },
        {
            text = "Kill Hexed Trolls and Voodoo Trolls.",
            quest = 826,
            details = {
                "Hexed Troll (8)",
                "Kill +Hexed Troll",
                "Voodoo Troll (8)",
                "Kill +Voodoo Troll",
            },
        },
        {
            text = "Loot the Loa Idols on the ground. They are mainly found near the stone walls in the area.",
            quest = 97225,
            details = {
                "Forgotten Loa Idols (x8)",
            },
        },
        {
            text = "Kill Pygmy Surf Crawlers and Surf Crawlers. Loot them for their Mucus. Kill Makrura Shellhides and Makrura Clackers. Loot them for their Eyes.",
            quest = 818,
            details = {
                "Crawler Mucus (8)",
                "Kill +Pygmy Surf Crawler",
                "Kill +Surf Crawler",
                "Intact Makrura Eye (4)",
                "Kill +Makrura Shellhide",
                "Kill +Makrura Clacker",
            },
        },
        {
            text = "Kill Durotar Tigers. Loot them for their Fur.",
            quest = 817,
            details = {
                "Durotar Tiger Fur (4)",
                "Kill Durotar Tiger",
            },
        },
        {
            text = "Loot the Taillasher Eggs on the ground. They're usually guarded by a Bloodtalon Taillasher.",
            quest = 815,
            details = {
                "Taillasher Egg (3)",
                "Kill Bloodtalon Taillasher",
            },
        },
        {
            text = "Kill Pygmy Surf Crawlers and Surf Crawlers. Loot them for their Mucus. Kill Makrura Shellhides and Makrura Clackers. Loot them for their Eyes.",
            quest = 818,
            details = {
                "Crawler Mucus (8)",
                "Kill +Pygmy Surf Crawler",
                "Kill +Surf Crawler",
                "Intact Makrura Eye (4)",
                "Kill +Makrura Shellhide",
                "Kill +Makrura Clacker",
            },
        },
        {
            text = "Die and respawn at the Spirit Healer, or run back.",
            note = "softcore",
        },
        {
            text = "Travel to Sen'Jin Village.",
            note = "hardcore",
        },
        {
            text = "Talk to Trayexir. Jump into the hut. Vendor trash and repair.",
        },
        {
            text = "Talk to Pa'zula. Turn in A Pain in the Neck.",
            quest = 96873,
            when = "complete",
        },
        {
            classes = { "Mage" },
            text = "Talk to Un'Thuwa. Train your class spells.",
        },
        {
            text = "Talk to Gadrin, Vornal and Vel'rin. Turn in Minshina's Skull. Turn in Zalazane. Turn in Forgotten Loa Idols. Turn in A Solvent Spirit. Turn in Practical Prey.",
            quests = { 808, 826, 97225, 818, 817 },
            when = "complete",
            details = {
                "NPC: Master Gadrin, Master Vornal, Vel'rin Fang",
            },
        },
        {
            text = "Talk to Xar'Ti. Turn in Bloodtalon Matriarch.",
            quest = 97223,
            when = "complete",
        },
        {
            text = "Bind your [Faintly Glowing Skull] and [Really Sticky Glue]. Save them for emergency situations.",
        },
        {
            text = "Turn in Ukor's Lost Pack.",
            quest = 96876,
            when = "complete",
        },
        {
            text = "Loot the Prickly Pear Fruit on the ground.",
            quest = 96825,
            details = {
                "8/8 Prickly Pear Fruit",
            },
        },
        {
            text = "Kill Razormane Quilboars and Razormane Scouts.",
            quest = 837,
            details = {
                "Razormane Quilboar (4)",
                "Kill +Razormane Quilboar",
                "Razormane Scout (4)",
                "Kill +Razormane Scout",
            },
        },
        {
            text = "Loot the Prickly Pear Fruit on the ground.",
            quest = 96825,
            details = {
                "8/8 Prickly Pear Fruit",
            },
        },
        {
            classes = { "Hunter" },
            text = "Kill Razormane Dustrunners and Razormane Battleguards.",
            quest = 837,
            details = {
                "Razormane Dustrunner (4)",
                "Kill +Razormane Dustrunner",
                "Razormane Battleguard (4)",
                "Kill +Razormane Battleguard",
            },
        },
        {
            text = "Talk to Gar'Thok. Turn in From The Wreckage. Turn in Encroachment.",
            quests = { 825, 837 },
            when = "complete",
        },
        {
            text = "Talk to Orgnil Soulscar. Turn in Threat from Below.",
            quest = 99049,
            when = "complete",
        },
        {
            text = "Talk to Torka. Turn in Break a Few Eggs. Turn in This Fruit Could Bite Back.",
            quests = { 815, 96825 },
            when = "complete",
            details = {
                "NPC: Cook Torka",
            },
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Accept Taming the Beast. Train your class spells.",
            quest = 6062,
            when = "accepted",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ghrawt. Buy [Sharp Arrows] and a [Medium Quiver] from him.",
            details = {
                "Sharp Arrow (1200)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ghrawt. Buy [Sharp Arrows] from him.",
            details = {
                "Sharp Arrow (1200)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Use your [Taming Rod] on a Dire Mottled Boar at max range.",
            quest = 6062,
            details = {
                "Tame a Dire Mottled Boar",
                "Kill Dire Mottled Boar",
            },
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Turn in Taming the Beast. Accept Taming the Beast.",
            quest = 6083,
            when = "accepted",
            details = {
                "Turn in Taming the Beast",
            },
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Accept Taming the Beast.",
            quest = 6083,
            when = "accepted",
        },
        {
            classes = { "Hunter" },
            text = "Dismiss your Dire Mottled Boar by right clicking its unit frame and clicking dismiss, otherwise you'll be unable to tame a Surf Crawler.",
        },
        {
            classes = { "Hunter" },
            text = "Don't kill the Armored Scorpids you see. You'll need them later. Use your [Taming Rod] on a Surf Crawler at max range.",
            quest = 6083,
            details = {
                "Tame a Surf Crawler",
                "Kill Surf Crawler",
            },
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Turn in Taming the Beast. Accept Taming the Beast.",
            quest = 6082,
            when = "accepted",
            details = {
                "Turn in Taming the Beast",
            },
        },
        {
            classes = { "Hunter" },
            text = "Dismiss your Surf Crawler by right clicking its unit frame and clicking dismiss, otherwise you'll be unable to tame an Armored Scorpid.",
        },
        {
            classes = { "Hunter" },
            text = "Use your [Taming Rod] on an Armored Scorpid at max range.",
            quest = 6082,
            details = {
                "Tame an Armored Scorpid",
                "Kill Armored Scorpid",
            },
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Turn in Taming the Beast. Accept Training the Beast.",
            quest = 6081,
            when = "accepted",
            details = {
                "Turn in Taming the Beast",
            },
        },
        {
            classes = { "Hunter" },
            text = "Put [Tame Beast], [Dismiss Pet], and [Call Pet] onto your Action Bars.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Grimtak. Buy [Tough Jerky] from him. You will use this to feed your pet later. Vendor Trash.",
            details = {
                "Tough Jerky (5)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Takrin. Accept Conscript of the Horde.",
            quest = 840,
            when = "accepted",
            details = {
                "NPC: Takrin Pathseeker",
            },
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Misha. Accept Lost But Not Forgotten.",
            quest = 816,
            when = "accepted",
            details = {
                "NPC: Misha Tor'kren",
            },
        },
        {
            classes = { "Warrior" },
            text = "Talk to Tarshaw. Train your class spells.",
            details = {
                "NPC: Tarshaw Jaggedscar",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Swart. Train your class spells. Accept Call of Fire.",
            quest = 2983,
            when = "accepted",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Swart. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Dhugru. Train your class spells.",
            details = {
                "NPC: Dhugru Gorelust",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Kitha and buy [Firebolt Rank 2]. Train your class spells.",
            details = {
                "Grimoire of Firebolt (Rank 2) (1)",
            },
        },
        {
            classes = { "Priest" },
            text = "Talk to Tai'jin. Accept Hex of Weakness. Accept Touch of Weakness. Train your class spells.",
            quests = { 5654, 5660 },
            when = "accepted",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Kaplak. Train your class spells.",
        },
        {
            excludeClasses = { "Hunter" },
            text = "Kill Razormane Dustrunners and Razormane Battleguards.",
            quest = 837,
            details = {
                "Razormane Dustrunner (4)",
                "Kill +Razormane Dustrunner",
                "Razormane Battleguard (4)",
                "Kill +Razormane Battleguard",
            },
        },
        {
            text = "Travel to Rezlak.",
        },
        {
            text = "Talk to Rezlak. Accept Winds in the Desert.",
            quest = 834,
            when = "accepted",
        },
        {
            text = "Loot the Stolen Supply Sacks on the ground.",
            quest = 834,
            details = {
                "Sack of Supplies (5)",
            },
        },
        {
            text = "Talk to Rezlak. Turn in Winds in the Desert. Accept Securing the Lines.",
            quest = 835,
            when = "accepted",
            details = {
                "Turn in Winds in the Desert",
            },
        },
        {
            text = "Jump into Thunder Ridge. Dismiss your [Imp] by right clicking its unit frame and clicking dismiss. Cast [Dismiss Pet] and then jump into Thunder Ridge.",
        },
        {
            text = "Kill Fizzle Darkstorm and loot him for his Claw. Be careful. Kill the patrolling Burning Blade Fanatic and the Lightning Hides in the back before you pull him. Pull him backwards towards the Lightning Hides you just killed. Otherwise you may bodypull additional Burning Blade mobs. Don't be afraid to die for the Claw as you will be respawning at the Spirit Healer after. Kill the imp first. Use [Gouge] when he casts [Soul Siphon]. Kill the imp first. Use [Earth Shock] when he casts [Soul Siphon]. You can cast [Polymorph] on Fizzle and kill the Imp first. Kill the imp first. Use a [Minor Healing Potion] if you have it and your [Faintly Glowing Skull] if needed. Use a [Minor Healing Potion], [Minor Healthstone] if you have it and your [Faintly Glowing Skull] if needed.",
            note = "softcore",
            quest = 806,
            details = {
                "Fizzle's Claw (1)",
                "Kill Fizzle Darkstorm",
                "Kill Imp Minion",
                "Kill Burning Blade Fanatic",
                "Kill Lightning Hide",
            },
        },
        {
            text = "Kill Fizzle Darkstorm and loot him for his Claw. Be careful. Kill the patrolling Burning Blade Fanatic and the Lightning Hides in the back before you pull him. Pull him backwards towards the Lightning Hides you just killed. Otherwise you may bodypull additional Burning Blade mobs. Kill the imp first. Use [Gouge] when he casts [Soul Siphon]. Kill the imp first. Use [Earth Shock] when he casts [Soul Siphon]. You can cast [Polymorph] on Fizzle and kill the Imp first. Kill the imp first. Use a [Minor Healing Potion] if you have it and your [Faintly Glowing Skull] if needed. Use a [Minor Healing Potion], [Minor Healthstone] if you have it and your [Faintly Glowing Skull] if needed.",
            note = "hardcore",
            quest = 806,
            details = {
                "Fizzle's Claw (1)",
                "Kill Fizzle Darkstorm",
                "Kill Imp Minion",
                "Kill Burning Blade Fanatic",
                "Kill Lightning Hide",
            },
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Die and respawn at the Spirit Healer.",
            note = "softcore",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Fight your way out of Thunder Ridge.",
            note = "softcore",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Fight your way out of Thunder Ridge.",
            note = "hardcore",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Rhinag. This will start a 45 minute timer for the quest. Do NOT go AFK or log out for the next 5 minutes. Accept Need for a Cure.",
            quest = 812,
            when = "accepted",
        },
        {
            classes = { "Shaman" },
            text = "Grind until your hearthstone cooldown is <5 minutes.",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Enter Orgrimmar.",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Thatog. He is upstairs in the building. Accept Meal Appeal.",
            quest = 97246,
            when = "accepted",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Borstan. Turn in Meal Appeal. Accept Favorite Food.",
            quest = 97249,
            when = "accepted",
            details = {
                "Turn in Meal Appeal",
            },
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Kamari. Turn in Halikor's Hoof.",
            quest = 96877,
            when = "complete",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Kor'geld. Accept Yelmak's Medley.",
            quest = 97242,
            when = "accepted",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Travel to the Valley of Honor.",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Loot the Handful of Cattails and Speargrass Cuttings in the water.",
            quest = 97242,
            details = {
                "2/2 Handful of Cattails",
                "4/4 Speargrass Cuttings",
            },
        },
        {
            classes = { "Hunter" },
            text = "Talk to Ormak. Turn in Training the Beast.",
            quest = 6081,
            when = "complete",
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
            text = "Remember to train your pet whenever they get Training Points for [Beast Training].",
            note = "Put [Beast Training](under the General tab), [Revive Pet], and [Feed Pet] onto your Action Bars",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Zendo'jian. Buy a [Laminated Recurve Bow] from him.",
            details = {
                "Collect Laminated Recurve Bow (1)",
            },
        },
        {
            classes = { "Hunter" },
            text = "Equip the [Laminated Recurve Bow] when you are level 11.",
        },
        {
            classes = { "Hunter" },
            text = "Equip the [Laminated Recurve Bow].",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Kor'geld. Turn in Yelmak's Medley.",
            quest = 97242,
            when = "complete",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Yelmak. You may have to wait about 10 seconds before you can accept this quest. Accept Whuut's the Rush.",
            quest = 97275,
            when = "accepted",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Turn in Whuut's the Rush.",
            quest = 97275,
            when = "complete",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Migi. Turn in Favorite Food.",
            quest = 97249,
            when = "complete",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Thra. Accept Rocks to Rests.",
            quest = 97326,
            when = "accepted",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Loot the orange Rocks on the ground. Skip this quest if there is a lot of competition! There aren't that many Rocks and they do not respawn quickly.",
            quest = 97326,
            details = {
                "8/8 Smooth Boulder",
            },
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Thra. Turn in Rocks to Rests.",
            quest = 97326,
            when = "complete",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Nazgrel. Turn in The Admiral's Orders.",
            quest = 831,
            when = "complete",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Thrall. Accept Hidden Enemies.",
            quest = 5726,
            when = "accepted",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Talk to Kor'ghan in the Cleft of Shadow. Accept Finding the Antidote.",
            quest = 813,
            when = "accepted",
        },
        {
            classes = { "Hunter", "Shaman" },
            text = "Abandon Need for a Cure. This will remove the timer on the quest but you will still be able to do it. Abandon Need for a Cure.",
        },
        {
            text = "Travel to Razor Hill.",
        },
        {
            text = "Talk to Innkeeper Grosk. Vendor Trash. Buy [Ice Cold Milk] from him. Buy [Haunch of Meat] from him.",
            details = {
                "Ice Cold Milk (15)",
                "Haunch of Meat (15)",
            },
        },
        {
            text = "Talk to Orgnil and Gar'Thok. Turn in Dark Storms. Accept Margoz. Turn in Encroachment.",
            quest = 828,
            when = "accepted",
            details = {
                "Turn in Encroachment",
                "Turn in Dark Storms",
            },
        },
        {
            classes = { "Warrior" },
            text = "Talk to Tarshaw. Train your class spells.",
            details = {
                "NPC: Tarshaw Jaggedscar",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Swart. Train your class spells. Accept Call of Fire.",
            quest = 2983,
            when = "accepted",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Swart. Train your class spells.",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Dhugru. Train your class spells.",
            details = {
                "NPC: Dhugru Gorelust",
            },
        },
        {
            classes = { "Warlock" },
            text = "Talk to Kitha and buy [Firebolt Rank 2]. Train your class spells.",
            details = {
                "Grimoire of Firebolt (Rank 2) (1)",
            },
        },
        {
            classes = { "Priest" },
            text = "Talk to Tai'jin. Accept Hex of Weakness. Accept Touch of Weakness. Train your class spells.",
            quests = { 5654, 5660 },
            when = "accepted",
        },
        {
            classes = { "Hunter" },
            text = "Go inside the bunker. Talk to Thotar inside. Train your class spells.",
        },
        {
            classes = { "Rogue" },
            text = "Talk to Kaplak. Train your class spells.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-10-12-durotar",
    name = "10-12 Durotar",
    group = "Forever Horde",
    faction = "Horde",
    steps = {
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Takrin. Accept Conscript of the Horde.",
            quest = 840,
            when = "accepted",
            details = {
                "NPC: Takrin Pathseeker",
            },
        },
        {
            classes = { "Shaman" },
            text = "Travel to Far Watch Post.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kargal. Turn in Conscript of the Horde. Accept Crossroads Conscription.",
            quest = 842,
            when = "accepted",
            details = {
                "Turn in Conscript of the Horde",
                "NPC: Kargal Battlescar",
            },
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kranal. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1524,
            when = "accepted",
            details = {
                "Turn in Call of Fire",
                "NPC: Kranal Fiss",
            },
        },
        {
            classes = { "Shaman" },
            text = "Kill Dreadmaw Crocolisks on the way. Loot them for Kron's Amulet.",
            quest = 816,
            details = {
                "Kron's Amulet (1)",
                "Kill Dreadmaw Crocolisk",
            },
        },
        {
            classes = { "Shaman" },
            text = "Travel the path up the mountain toward Telf. Be careful to not fall of the mountain, the path is very narrow. You could die if you fall.",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Telf. Turn in Call of Fire. Accept Call of Fire.",
            quest = 1525,
            when = "accepted",
            details = {
                "Turn in Call of Fire",
                "NPC: Telf Joolam",
            },
        },
        {
            classes = { "Hunter" },
            text = "Train your class spells.",
            note = "Tame a Venomtail Scorpid",
            details = {
                "Kill Venomtail Scorpid",
            },
        },
        {
            classes = { "Shaman" },
            text = "Travel toward Dustwind Cave.",
        },
        {
            classes = { "Shaman" },
            text = "Kill Burning Blade Cultists. Loot them for a Reagent Pouch.",
            quest = 1525,
            details = {
                "Reagent Pouch (1)",
                "Kill Burning Blade Cultist",
            },
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Travel to Margoz.",
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Turn in Margoz. Accept Skull Rock.",
            quest = 827,
            when = "accepted",
            details = {
                "Turn in Margoz",
            },
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Travel toward Dustwind Cave.",
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Kill Burning Blade Orcs. Loot them for their Collars.",
            quest = 827,
            details = {
                "Searing Collar (6)",
                "Kill Burning Blade Thug",
                "Kill Burning Blade Neophyte",
                "Kill Burning Blade Cultist",
            },
        },
        {
            text = "Drop down into Drygulch Ravine.",
        },
        {
            text = "Kill Dustwind Savages and Dustwind Storm Witches. Loot Dustwind Storm Witches for a [Dull Storm Orb]. Use it to accept the quest. Accept A Simmering Storm.",
            quest = 97281,
            when = "accepted",
            details = {
                "Dustwind Savage (12)",
                "Kill +Dustwind Savage",
                "Dustwind Storm Witch (8)",
                "Kill +Dustwind Storm Witch",
            },
        },
        {
            text = "Travel through the cave toward Rezlak.",
            note = "hardcore",
        },
        {
            text = "Talk to Rezlak. Turn in Securing the Lines. Turn in A Simmering Storm. Accept Stormy Potential.",
            quest = 97282,
            when = "accepted",
            details = {
                "Turn in A Simmering Storm",
                "Turn in Securing the Lines",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Finish killing Venomtail Scorpids. Loot them for their Poison Sacs.",
            quest = 813,
            details = {
                "Venomtail Poison Sac (4)",
                "Kill Venomtail Scorpid",
            },
        },
        {
            text = "Kill Thunder Lizards and Lightning Hides. Loot them for their Charged Thunder Lizard Organs.",
            quest = 97282,
            details = {
                "5/5 Charged Thunder Lizard Organ",
                "Kill Lightning Hide",
                "Kill Charged Thunder Lizard Organ",
            },
        },
        {
            text = "Kill Halikor (elite). Loot him for [Halikor's Hoof]. This is hard! Group up if possible. It has 800 health but his damage is manageable. Skip this step if you can't kill it. He has at least two different spawn locations inside Thunder Ridge. Accept Halikor's Hoof.",
            quest = 96877,
            when = "accepted",
            details = {
                "Kill Halikor",
            },
        },
        {
            text = "Kill Thunder Lizards and Lightning Hides. Loot them for their Charged Thunder Lizard Organs.",
            quest = 97282,
            details = {
                "5/5 Charged Thunder Lizard Organ",
                "Kill Lightning Hide",
                "Kill Charged Thunder Lizard Organ",
            },
        },
        {
            text = "Talk to Rezlak. Turn in Stormy Potential.",
            quest = 97282,
            when = "complete",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Travel to Margoz.",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Turn in Margoz. Accept Skull Rock.",
            quest = 827,
            when = "accepted",
            details = {
                "Turn in Margoz",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Travel toward Skull Rock.",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Kill Venomtail Scorpids. Loot them for their Poison Sacs.",
            quest = 813,
            details = {
                "Venomtail Poison Sac (4)",
                "Kill Venomtail Scorpid",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Kill Burning Blade Orcs. Loot them for their Collars and for a Lieutenant's Insignia.",
            quests = { 827, 5726 },
            details = {
                "Searing Collar (6)",
                "Lieutenant's Insignia (1)",
                "Kill Burning Blade Fanatic",
                "Kill Burning Blade Apprentice",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Kill Gazz'uz. Loot him for his [Eye of Burning Shadow]. Use the [Eye of Burning Shadow] to start the quest. Use your [Really Sticky Glue] on the Voidwalker to avoid being hit, and [Healing Potions] to restore health. Use LoS (line of sight) to avoid Gazz'uz his Shadow Bolts. You can run to bodies of water found within the cave to evade the Voidwalker after killing Gazz'uz. Be careful as he is VERY difficult. You can skip this quest if you need. Accept Burning Shadows.",
            quest = 832,
            when = "accepted",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Kill Burning Blade Orcs. Loot them for their Collars and for a Lieutenant's Insignia. Skip the Lieutenant's Insignia if you're unlucky with the drop.",
            quests = { 827, 5726 },
            details = {
                "Searing Collar (6)",
                "Lieutenant's Insignia (1)",
                "Kill Burning Blade Fanatic",
                "Kill Burning Blade Apprentice",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Kill Venomtail Scorpids. Loot them for their Poison Sacs.",
            quest = 813,
            details = {
                "Venomtail Poison Sac (4)",
                "Kill Venomtail Scorpid",
            },
        },
        {
            text = "Talk to Margoz. Turn in Skull Rock. Accept Neeru Fireblade.",
            quest = 829,
            when = "accepted",
            details = {
                "Turn in Skull Rock",
            },
        },
        {
            text = "Enter Orgrimmar.",
        },
        {
            text = "Talk to Trak'gen. Vendor your trash.",
        },
        {
            classes = { "Priest" },
            races = { "Troll" },
            text = "Talk to Ur'kyo. Turn in Hex of Weakness. Train your class spells.",
            quest = 5654,
            when = "complete",
        },
        {
            classes = { "Priest" },
            races = { "Troll" },
            text = "Talk to Ur'kyo. Turn in Hex of Weakness. Train your class spells.",
            quest = 5652,
            when = "complete",
        },
        {
            text = "Talk to Thatog. He is upstairs in the building. Accept Meal Appeal.",
            quest = 97246,
            when = "accepted",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Urtharo. Buy a [Quarter Staff] from him.",
            details = {
                "Collect Quarter Staff (1)",
                "NPC: Benijah Fenner",
            },
        },
        {
            classes = { "Shaman" },
            text = "Equip the [Quarter Staff].",
        },
        {
            text = "Talk to Borstan. Turn in Meal Appeal. Accept Favorite Food.",
            quest = 97249,
            when = "accepted",
            details = {
                "Turn in Meal Appeal",
            },
        },
        {
            text = "Talk to Kamari. Turn in Halikor's Hoof.",
            quest = 96877,
            when = "complete",
        },
        {
            text = "Talk to Kor'geld. Accept Yelmak's Medley.",
            quest = 97242,
            when = "accepted",
        },
        {
            text = "Travel to the Valley of Honor.",
        },
        {
            text = "Loot the Handful of Cattails and Speargrass Cuttings in the water.",
            quest = 97242,
            details = {
                "2/2 Handful of Cattails",
                "4/4 Speargrass Cuttings",
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
            text = "Talk to Xao'tsu. Train your pet spells.",
        },
        {
            text = "Talk to Kor'geld. Turn in Yelmak's Medley.",
            quest = 97242,
            when = "complete",
        },
        {
            text = "Talk to Yelmak. You may have to wait about 10 seconds before you can accept this quest. Accept Whuut's the Rush.",
            quest = 97275,
            when = "accepted",
        },
        {
            text = "Turn in Whuut's the Rush.",
            quest = 97275,
            when = "complete",
        },
        {
            text = "Talk to Migi. Turn in Favorite Food.",
            quest = 97249,
            when = "complete",
        },
        {
            text = "Talk to Thra. Accept Rocks to Rests.",
            quest = 97326,
            when = "accepted",
        },
        {
            text = "Loot the orange Rocks on the ground.",
            quest = 97326,
            details = {
                "8/8 Smooth Boulder",
            },
        },
        {
            text = "Talk to Thra. Turn in Rocks to Rests.",
            quest = 97326,
            when = "complete",
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Talk to Nazgrel. Turn in The Admiral's Orders.",
            quest = 831,
            when = "complete",
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Talk to Thrall. Accept Hidden Enemies.",
            quest = 5726,
            when = "accepted",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Thrall. Turn in Hidden Enemies. Accept Hidden Enemies.",
            quest = 5727,
            when = "accepted",
            details = {
                "Turn in Hidden Enemies",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Thrall. Turn in Hidden Enemies.",
            quest = 5726,
            when = "complete",
        },
        {
            classes = { "Shaman" },
            text = "Talk to Kardris. Train your class spells.",
            details = {
                "NPC: Kardris Dreamseeker",
            },
        },
        {
            text = "Repair your gear.",
            details = {
                "NPC: Kareth",
            },
        },
        {
            classes = { "Rogue" },
            text = "Talk to Therzok. Accept The Shattered Hand.",
            quest = 1963,
            when = "accepted",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Kor'ghan. Turn in Finding the Antidote.",
            quest = 813,
            when = "complete",
        },
        {
            classes = { "Warlock" },
            text = "Talk to Mirket. Train your class spells.",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Neeru. Turn in Neeru Fireblade. Turn in Burning Shadows. Accept Ak'Zeloth.",
            quest = 809,
            when = "accepted",
            details = {
                "Turn in Burning Shadows",
                "Turn in Neeru Fireblade",
            },
        },
        {
            text = "Talk to Neeru. Turn in Neeru Fireblade. Accept Ak'Zeloth.",
            quest = 809,
            when = "accepted",
            details = {
                "Turn in Neeru Fireblade",
            },
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Leave Orgrimmar.",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Leave Orgrimmar.",
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Rhinag. Accept Need for a Cure. Turn in Need for a Cure.",
            quest = 812,
            when = "accepted",
            details = {
                "Turn in Need for a Cure",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Travel south alongside the river toward Far Watch Post. Kill Dreadmaw Crocolisks on the way. Loot them for Kron's Amulet. Skip and abandon this quest if it won't drop.",
            quest = 816,
            details = {
                "Kron's Amulet (1)",
                "Kill Dreadmaw Crocolisk",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Talk to Misha. Turn in Lost But Not Forgotten.",
            quest = 816,
            when = "complete",
            details = {
                "NPC: Misha Tor'kren",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Travel to Far Watch Post.",
        },
        {
            classes = { "Hunter" },
            text = "Talk to Kargal. Turn in Conscript of the Horde. Accept Crossroads Conscription.",
            quest = 842,
            when = "accepted",
            details = {
                "Turn in Conscript of the Horde",
                "NPC: Kargal Battlescar",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Turn in Ak'Zeloth. Accept The Demon Seed.",
            quest = 924,
            when = "accepted",
            details = {
                "Turn in Ak'Zeloth",
            },
        },
        {
            classes = { "Shaman", "Hunter" },
            text = "Loot the [Flawed Power Stone] next to Ak'Zeloth. This item has a 30 minute timer, so be sure to be quick. Turn in Flawed Power Stone.",
            quest = 926,
            when = "complete",
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Kill Burning Blade Orcs. Loot them for a Lieutenant's Insignia. This is a pre-quest for RFC. It has a low droprate.",
            quest = 5726,
            details = {
                "Lieutenant's Insignia (1)",
                "Kill Burning Blade Fanatic",
                "Kill Burning Blade Apprentice",
            },
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Kill Gazz'uz. Loot him for his [Eye of Burning Shadow]. Be careful as he is VERY difficult. Feel free to skip this quest if you can't group up or solo him. Use the [Eye of Burning Shadow] to start the quest. Use LoS (line of sight) to avoid Gazz'uz his Shadow Bolts. You can run to bodies of water found within the cave to evade the Voidwalker after killing Gazz'uz. Accept Burning Shadows.",
            quest = 832,
            when = "accepted",
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Kill Burning Blade Orcs. Loot them for a Lieutenant's Insignia. This is a pre-quest for RFC. It has a low droprate.",
            quest = 5726,
            details = {
                "Lieutenant's Insignia (1)",
                "Kill Burning Blade Fanatic",
                "Kill Burning Blade Apprentice",
            },
        },
        {
            excludeClasses = { "Shaman", "Hunter" },
            text = "Go up the Zeppelin Tower. Take the Zeppelin to Tirisfal Glades. Conjure water while waiting.",
        },
        {
            text = "Abandon Lost But Not Forgotten.",
        },
    },
})
