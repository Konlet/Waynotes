local _, ns = ...

-- Curated Orc/Troll Durotar 1-12.
-- Hybrid of RestedXP Forever quest coverage and Zygor-style chaining.
-- Multi-step class lines live in Horde_Durotar_ClassQuests.lua; this file
-- only drops pointer steps at the right hubs.
-- Pins omitted: QuestieDB supplies NPC coordinates for accept and turn-in steps.

ns.RegisterGuide({
    id = "horde-durotar-1-6-curated",
    name = "1-6 Durotar (Curated)",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    minLevel = 1,
    maxLevel = 6,
    steps = {
        {
            excludeRaces = { "Orc", "Troll" },
            text = "This guide is meant for Orcs and Trolls. Choose the starter zone you began in.",
        },
        {
            text = "Talk to Kaltunk. Accept Your Place In The World.",
            quest = 4641,
            when = "accepted",
            map = 1411,
            x = 43.3,
            y = 68.5,
        },
        {
            text = "Talk to Gornek. Turn in Your Place In The World. Accept Cutting Teeth.",
            quest = 788,
            when = "accepted",
            map = 1411,
            x = 42.1,
            y = 68.3,
            details = {
                "Turn in Your Place In The World",
                "NPC: Gornek",
            },
        },
        {
            classes = { "Warlock" },
            text = "Warlocks: open the side guide Durotar Warlock Familiars, finish it, then resume here.",
            note = "Guide id: horde-durotar-warlock-familiars",
        },
        {
            text = "Talk to Hana'zua southeast of the den. Accept Sarkoth.",
            quest = 790,
            when = "accepted",
            map = 1411,
            x = 40.6,
            y = 62.6,
        },
        {
            text = "Kill Sarkoth on the ridge. Loot Sarkoth's Mangled Claw.",
            quest = 790,
            when = "objectives",
            map = 1411,
            x = 40.6,
            y = 67.6,
            details = {
                "Sarkoth's Mangled Claw (1)",
                "Kill Sarkoth",
            },
        },
        {
            text = "Talk to Hana'zua. Turn in Sarkoth. Accept Sarkoth.",
            quest = 804,
            when = "accepted",
            map = 1411,
            x = 40.6,
            y = 62.6,
            details = {
                "Turn in Sarkoth",
            },
        },
        {
            text = "Kill Mottled Boars until Cutting Teeth is finished.",
            quest = 788,
            when = "objectives",
            details = {
                "Mottled Boar (10)",
                "Kill Mottled Boar",
            },
        },
        {
            text = "Talk to Gornek. Turn in Cutting Teeth and Sarkoth. Accept Sting of the Scorpid. Accept your class parchment or tablet.",
            quest = 789,
            when = "accepted",
            map = 1411,
            x = 42.1,
            y = 68.3,
            details = {
                "Turn in Cutting Teeth",
                "Turn in Sarkoth",
            },
        },
        {
            classes = { "Warrior" },
            races = { "Orc" },
            text = "Talk to Frang. Turn in Simple Parchment.",
            quest = 2383,
            when = "complete",
        },
        {
            classes = { "Warrior" },
            races = { "Troll" },
            text = "Talk to Frang. Turn in Simple Tablet.",
            quest = 3065,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            races = { "Orc" },
            text = "Talk to Jen'shan. Turn in Etched Parchment.",
            quest = 3087,
            when = "complete",
        },
        {
            classes = { "Hunter" },
            races = { "Troll" },
            text = "Talk to Jen'shan. Turn in Etched Tablet.",
            quest = 3082,
            when = "complete",
        },
        {
            classes = { "Rogue" },
            races = { "Orc" },
            text = "Talk to Rwag. Turn in Encrypted Parchment.",
            quest = 3088,
            when = "complete",
        },
        {
            classes = { "Rogue" },
            races = { "Troll" },
            text = "Talk to Rwag. Turn in Encrypted Tablet.",
            quest = 3083,
            when = "complete",
        },
        {
            classes = { "Shaman" },
            races = { "Orc" },
            text = "Talk to Shikrik. Turn in Rune-Inscribed Parchment.",
            quest = 3089,
            when = "complete",
        },
        {
            classes = { "Shaman" },
            races = { "Troll" },
            text = "Talk to Shikrik. Turn in Rune-Inscribed Tablet.",
            quest = 3084,
            when = "complete",
        },
        {
            classes = { "Priest" },
            races = { "Troll" },
            text = "Talk to Ken'jai. Turn in Hallowed Tablet.",
            quest = 3085,
            when = "complete",
        },
        {
            classes = { "Mage" },
            races = { "Troll" },
            text = "Talk to Mai'ah. Turn in Glyphic Tablet.",
            quest = 3086,
            when = "complete",
        },
        {
            classes = { "Mage" },
            races = { "Orc" },
            text = "Talk to Mai'ah. Turn in Glyphic Parchment.",
            quest = 98576,
            when = "complete",
        },
        {
            classes = { "Warlock" },
            races = { "Orc" },
            text = "Talk to Nartok. Turn in Tainted Parchment.",
            quest = 3090,
            when = "complete",
        },
        {
            classes = { "Warlock" },
            races = { "Troll" },
            text = "Talk to Nartok. Turn in Tainted Tablet.",
            quest = 98575,
            when = "complete",
        },
        {
            text = "Talk to Galgar. Accept Galgar's Cactus Apple Surprise.",
            quest = 4402,
            when = "accepted",
            map = 1411,
            x = 42.7,
            y = 67.2,
        },
        {
            excludeClasses = { "Warlock" },
            text = "Talk to Zureetha Fargaze. Accept Vile Familiars.",
            quest = 792,
            when = "accepted",
            map = 1411,
            x = 42.9,
            y = 69.2,
        },
        {
            text = "Talk to Foreman Thazz'ril. Accept Lazy Peons.",
            quest = 5441,
            when = "accepted",
            map = 1411,
            x = 44.6,
            y = 68.6,
        },
        {
            text = "West of the den: loot Cactus Apples, wake Lazy Peons with the Foreman's Blackjack, and kill Scorpid Workers for tails.",
            quests = { 4402, 5441, 789 },
            when = "objectives",
            details = {
                "Cactus Apple (10)",
                "Peons Awoken (5)",
                "Scorpid Worker Tail (10)",
                "Kill Scorpid Worker",
                "Use Foreman's Blackjack on Lazy Peon",
            },
        },
        {
            excludeClasses = { "Warlock" },
            text = "North toward the Burning Blade Coven. Kill Vile Familiars.",
            quest = 792,
            when = "objectives",
            details = {
                "Vile Familiar (12)",
                "Kill Vile Familiar",
            },
        },
        {
            text = "Talk to Galgar. Turn in Galgar's Cactus Apple Surprise.",
            quest = 4402,
            when = "complete",
            map = 1411,
            x = 42.7,
            y = 67.2,
        },
        {
            text = "Talk to Gornek. Turn in Sting of the Scorpid.",
            quest = 789,
            when = "complete",
            map = 1411,
            x = 42.1,
            y = 68.3,
        },
        {
            classes = { "Shaman" },
            text = "Shamans: open the side guide Durotar Shaman Call of Earth, finish it through the cave, then resume here for the medallion turn-in.",
            note = "Guide id: horde-durotar-shaman-earth",
        },
        {
            excludeClasses = { "Warlock" },
            text = "Talk to Zureetha. Turn in Vile Familiars. Accept Burning Blade Medallion.",
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
            text = "Talk to Foreman Thazz'ril. Turn in Lazy Peons. Accept Thazz'ril's Pick.",
            quest = 6394,
            when = "accepted",
            map = 1411,
            x = 44.6,
            y = 68.6,
            details = {
                "Turn in Lazy Peons",
            },
        },
        {
            text = "Enter the Burning Blade Coven. Loot Thazz'ril's Pick, then kill Yarrog Baneshadow for the Burning Blade Medallion.",
            quests = { 6394, 794 },
            when = "objectives",
            map = 1411,
            x = 42.7,
            y = 52.9,
            details = {
                "Thazz'ril's Pick (1)",
                "Burning Blade Medallion (1)",
                "Kill Yarrog Baneshadow",
            },
        },
        {
            text = "Return to the den. Talk to Foreman Thazz'ril. Turn in Thazz'ril's Pick.",
            quest = 6394,
            when = "complete",
            map = 1411,
            x = 44.6,
            y = 68.6,
        },
        {
            text = "Talk to Zureetha. Turn in Burning Blade Medallion. Accept Report to Sen'jin Village.",
            quest = 805,
            when = "accepted",
            map = 1411,
            x = 42.9,
            y = 69.2,
            details = {
                "Turn in Burning Blade Medallion",
            },
        },
        {
            text = "Click the Lost Journal on the barrel near Zureetha if it is there. Accept The Adventurer, then press Next.",
            note = "Quest 96652. Skip if the journal is missing.",
            map = 1411,
            x = 42.9,
            y = 69.2,
        },
        {
            classes = { "Priest" },
            text = "Talk to Ken'jai. Accept In Favor of Spirituality.",
            quest = 5649,
            when = "accepted",
            map = 1411,
            x = 42.4,
            y = 68.8,
        },
        {
            text = "Leave the Valley of Trials east toward Sen'jin. Talk to Ukor on the road. Accept A Peon's Burden.",
            quest = 2161,
            when = "accepted",
            map = 1411,
            x = 52.1,
            y = 68.3,
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-6-10-curated",
    name = "6-10 Durotar (Curated)",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    minLevel = 6,
    maxLevel = 10,
    steps = {
        {
            text = "Travel to Sen'jin Village.",
            map = 1411,
            x = 56.0,
            y = 74.7,
        },
        {
            text = "Talk to Lar Prowltusk as he patrols. Accept Thwarting Kolkar Aggression.",
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
            text = "Talk to Vel'rin, Vornal, and Gadrin. Accept Practical Prey, Legging It, A Solvent Spirit, and Forgotten Loa Idols. Turn in Report to Sen'jin Village. Accept Minshina's Skull, Zalazane, and Report to Orgnil.",
            quests = { 817, 96821, 818, 97225, 808, 826, 823 },
            when = "accepted",
            details = {
                "Turn in Report to Sen'jin Village",
                "NPC: Vel'rin Fang, Master Vornal, Master Gadrin",
            },
        },
        {
            text = "Head southwest into Kolkar Crag. Burn the three Attack Plans (Valley of Trials, Sen'jin Village, Orgrimmar).",
            quest = 786,
            when = "objectives",
            details = {
                "Attack Plan: Valley of Trials destroyed",
                "Attack Plan: Sen'jin Village destroyed",
                "Attack Plan: Orgrimmar destroyed",
            },
        },
        {
            text = "Optional: talk to Pal'juh in Kolkar Crag for Lost in the Shadows and escort him out. Skip if he is missing, then press Next.",
            note = "Escort quest 99123. Skip freely if unavailable.",
        },
        {
            text = "Return to Sen'jin. Talk to Lar. Turn in Thwarting Kolkar Aggression.",
            quest = 786,
            when = "complete",
            details = {
                "NPC: Lar Prowltusk",
            },
        },
        {
            text = "Travel north toward Razor Hill. Kill Ridgeshade Lurkers and Creepers for Legging It along the way.",
            quest = 96821,
            when = "objectives",
            details = {
                "Ridgeshade Lurker (6)",
                "Ridgeshade Creeper (6)",
            },
        },
        {
            text = "Optional: talk to Brakk at the camp south of Razor Hill. Turn in The Adventurer if you have it, sit at the campfire for The Great Outdoors, then accept Camping 101: Cooking. Press Next.",
            note = "Quests 96652, 96604, 96655.",
        },
        {
            text = "Enter Razor Hill. Talk to Orgnil, Gar'Thok, and Cook Torka. Turn in Report to Orgnil. Accept Dark Storms, Vanquish the Betrayers, Encroachment, Break a Few Eggs, and This Fruit Could Bite Back. Turn in Camping 101: Cooking if you have it.",
            quests = { 806, 784, 837, 815, 96825 },
            when = "accepted",
            details = {
                "Turn in Report to Orgnil",
                "NPC: Orgnil Soulscar, Gar'Thok, Cook Torka",
            },
        },
        {
            text = "Climb the watchtower northeast of town. Talk to Furl Scornbrow. Accept Carry Your Weight.",
            quest = 791,
            when = "accepted",
        },
        {
            text = "Talk to Turroc in the barracks. Accept For Honor.",
            quest = 96822,
            when = "accepted",
        },
        {
            text = "Talk to Innkeeper Grosk. Turn in A Peon's Burden. Set your hearth to Razor Hill.",
            quest = 2161,
            when = "complete",
        },
        {
            classes = { "Priest" },
            text = "Priests: open the side guide Durotar Priest Spirituality, finish it, then resume here.",
            note = "Guide id: horde-durotar-priest-spirituality",
        },
        {
            text = "Travel southeast to Tiragarde Keep. Kill Sailors and Marines, loot Canvas Scraps, kill Lieutenant Benedict, and open Benedict's Chest for the Aged Envelope.",
            quests = { 784, 791 },
            when = "objectives",
            details = {
                "Kul Tiras Sailor (10)",
                "Kul Tiras Marine (8)",
                "Lieutenant Benedict (1)",
                "Canvas Scraps (8)",
            },
        },
        {
            text = "Use the Aged Envelope from Benedict's Chest. Accept The Admiral's Orders.",
            quest = 830,
            when = "accepted",
            details = {
                "Use Aged Envelope",
            },
        },
        {
            text = "Around Tiragarde, loot the Raider's Bow, Raider's Battleaxe, and Raider's Shield for For Honor.",
            quest = 96822,
            when = "objectives",
            details = {
                "Raider's Bow (1)",
                "Raider's Battleaxe (1)",
                "Raider's Shield (1)",
            },
        },
        {
            text = "Talk to Gar'Thok. Turn in Vanquish the Betrayers, The Admiral's Orders, and Legging It. Accept From The Wreckage and The Admiral's Orders.",
            quests = { 825, 831 },
            when = "accepted",
            details = {
                "Turn in Vanquish the Betrayers",
                "Turn in The Admiral's Orders",
                "Turn in Legging It",
                "NPC: Gar'Thok",
            },
        },
        {
            text = "Talk to Furl on the tower. Turn in Carry Your Weight. Talk to Turroc. Turn in For Honor.",
            quests = { 791, 96822 },
            when = "complete",
        },
        {
            text = "Optional at level 8+: talk to Orgnil for A Missing Hand, then Heglan Shadeeye on the eastern shore for Threat from Below. Loot the dagger, banner scrap, and trident. Press Next if you skip.",
            note = "Quests 99048 and 99049.",
        },
        {
            text = "Loot Gnomish Toolboxes from the shipwrecks east of Tiragarde. Finish crawler mucus and makrura eyes for A Solvent Spirit while you are on the coast.",
            quests = { 825, 818 },
            when = "objectives",
            details = {
                "Gnomish Tools (3)",
                "Crawler Mucus (8)",
                "Intact Makrura Eye (4)",
            },
        },
        {
            text = "Swim to the islands south of Sen'jin. Kill the Bloodtalon Matriarch for her eggs, then clear Echo Isles for Minshina's Skull, Zalazane, Hexed and Voodoo Trolls, Forgotten Loa Idols, tiger furs, and taillasher eggs.",
            quests = { 97223, 808, 826, 97225, 817, 815 },
            when = "objectives",
            details = {
                "Bloodtalon Matriarch Eggs (1)",
                "Minshina's Skull (1)",
                "Zalazane's Head (1)",
                "Hexed Troll (8)",
                "Voodoo Troll (8)",
                "Forgotten Loa Idols (8)",
                "Durotar Tiger Fur (4)",
                "Taillasher Egg (3)",
            },
        },
        {
            text = "Return to Sen'jin Village. Turn in Minshina's Skull, Zalazane, Forgotten Loa Idols, A Solvent Spirit, Practical Prey, and Bloodtalon Matriarch.",
            quests = { 808, 826, 97225, 818, 817, 97223 },
            when = "complete",
            details = {
                "NPC: Master Gadrin, Master Vornal, Vel'rin Fang, Xar'Ti",
            },
        },
        {
            text = "Travel northwest toward Razor Hill. Kill Razormane Quilboars and Scouts. Loot Prickly Pear Fruit for This Fruit Could Bite Back.",
            quests = { 837, 96825 },
            when = "objectives",
            note = "Finish the first two Encroachment objectives here. Higher quilboars come next.",
            details = {
                "Razormane Quilboar (4)",
                "Razormane Scout (4)",
                "Prickly Pear Fruit (8)",
            },
        },
        {
            text = "West of Razor Hill, kill Razormane Dustrunners and Battleguards to finish Encroachment.",
            quest = 837,
            when = "objectives",
            details = {
                "Razormane Dustrunner (4)",
                "Razormane Battleguard (4)",
            },
        },
        {
            text = "Return to Razor Hill. Talk to Gar'Thok. Turn in From The Wreckage and Encroachment.",
            quests = { 825, 837 },
            when = "complete",
        },
        {
            text = "Talk to Cook Torka. Turn in Break a Few Eggs and This Fruit Could Bite Back. Turn in Threat from Below at Orgnil if you did it.",
            quests = { 815, 96825 },
            when = "complete",
        },
        {
            classes = { "Hunter" },
            text = "Hunters: open the side guide Durotar Hunter Taming, finish it, then resume here.",
            note = "Guide id: horde-durotar-hunter-taming",
        },
        {
            text = "Travel north to Rezlak. Accept Winds in the Desert.",
            quest = 834,
            when = "accepted",
        },
        {
            text = "Loot Stolen Supply Sacks in the desert west of Rezlak.",
            quest = 834,
            when = "objectives",
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
            text = "Optional hard elite: enter Thunder Ridge and kill Fizzle Darkstorm for Dark Storms. Group up if needed.",
            quest = 806,
            when = "objectives",
            note = "Dangerous. Skip and return later if needed.",
            details = {
                "Fizzle's Claw (1)",
                "Kill Fizzle Darkstorm",
            },
        },
        {
            text = "Return to Razor Hill. Talk to Orgnil. Turn in Dark Storms. Accept Margoz.",
            quest = 828,
            when = "accepted",
            details = {
                "Turn in Dark Storms",
            },
        },
        {
            text = "Optional timed chain: talk to Rhinag near Orgrimmar for Need for a Cure, then Kor'ghan in Orgrimmar for Finding the Antidote. Press Next if you skip.",
            note = "Quests 812 and 813. Do not take 812 unless you can finish poison sacs soon.",
        },
        {
            classes = { "Shaman" },
            text = "Shamans: open the side guide Durotar Shaman Call of Fire when you are ready for the Barrens detour, then return for Skull Rock.",
            note = "Guide id: horde-durotar-shaman-fire",
        },
        {
            text = "At level 10+, talk to Takrin Pathseeker outside Razor Hill for Conscript of the Horde, and Misha Tor'kren west of town for Lost But Not Forgotten. Press Next.",
            note = "Quests 840 and 816.",
        },
    },
})

ns.RegisterGuide({
    id = "horde-durotar-10-12-curated",
    name = "10-12 Durotar (Curated)",
    group = "Forever Horde",
    faction = "Horde",
    races = { "Orc", "Troll" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Travel northeast to Margoz. Turn in Margoz. Accept Skull Rock.",
            quest = 827,
            when = "accepted",
            details = {
                "Turn in Margoz",
                "NPC: Margoz",
            },
        },
        {
            text = "Enter Drygulch Ravine. Kill Dustwind Savages and Storm Witches for Securing the Lines.",
            quest = 835,
            when = "objectives",
            details = {
                "Dustwind Savage (12)",
                "Dustwind Storm Witch (8)",
            },
        },
        {
            text = "Loot a Dull Storm Orb from Dustwind Storm Witches if it drops. Use it to accept A Simmering Storm, then press Next.",
            note = "Quest 97281. Skip if no orb dropped.",
        },
        {
            text = "Talk to Rezlak. Turn in Securing the Lines. Turn in A Simmering Storm if you have it. Accept Stormy Potential if offered.",
            quest = 835,
            when = "complete",
            details = {
                "NPC: Rezlak",
            },
        },
        {
            text = "In Thunder Ridge, kill Lightning Hides and Thunder Lizards for Charged Thunder Lizard Organs if you have Stormy Potential. Optional: kill Halikor for his hoof. Press Next when done or if skipping.",
            note = "Quest 97282 and optional 96877.",
        },
        {
            text = "Talk to Rezlak again if you still need to turn in Stormy Potential, then press Next.",
            note = "Skip if you never accepted Stormy Potential.",
        },
        {
            text = "Enter Skull Rock. Kill Burning Blade orcs for Searing Collars. Loot a Lieutenant's Insignia for Hidden Enemies if you still need it.",
            quest = 827,
            when = "objectives",
            details = {
                "Searing Collar (6)",
                "Kill Burning Blade Fanatic",
                "Kill Burning Blade Apprentice",
            },
        },
        {
            text = "Optional: kill Gazz'uz for the Eye of Burning Shadow and accept Burning Shadows. Kill Venomtail Scorpids for Finding the Antidote if you took that chain. Press Next.",
            note = "Quests 832 and 813.",
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
            map = 1454,
            x = 45.5,
            y = 13.0,
        },
        {
            text = "Talk to Thatog upstairs near the Drag. Accept Meal Appeal.",
            quest = 97246,
            when = "accepted",
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
            text = "Talk to Kamari if you have Halikor's Hoof and turn it in, then press Next.",
            note = "Quest 96877. Skip if you never accepted it.",
        },
        {
            text = "Talk to Kor'geld. Accept Yelmak's Medley.",
            quest = 97242,
            when = "accepted",
        },
        {
            text = "In the Valley of Honor ponds, loot Handfuls of Cattails and Speargrass Cuttings.",
            quest = 97242,
            when = "objectives",
            details = {
                "Handful of Cattails (2)",
                "Speargrass Cuttings (4)",
            },
        },
        {
            text = "Talk to Kor'geld. Turn in Yelmak's Medley.",
            quest = 97242,
            when = "complete",
        },
        {
            text = "Talk to Yelmak. Accept Whuut's the Rush. Talk to Whuut and turn it in.",
            quest = 97275,
            when = "complete",
            details = {
                "Accept Whuut's the Rush",
            },
        },
        {
            text = "Talk to Migi. Turn in Favorite Food.",
            quest = 97249,
            when = "complete",
        },
        {
            text = "Talk to Thra. Accept Rocks to Rests. Loot Smooth Boulders nearby, then turn it in.",
            quest = 97326,
            when = "complete",
            details = {
                "Smooth Boulder (8)",
            },
        },
        {
            text = "Talk to Nazgrel in Grommash Hold. Turn in The Admiral's Orders.",
            quest = 831,
            when = "complete",
        },
        {
            text = "Talk to Thrall. Turn in Hidden Enemies if you have the Lieutenant's Insignia and accept the follow-up. If you still need the insignia, accept Hidden Enemies and return to Skull Rock later.",
            note = "Quests 5726 and 5727.",
        },
        {
            text = "Talk to Neeru Fireblade in the Cleft of Shadow. Turn in Neeru Fireblade and Burning Shadows if you have them. Accept Ak'Zeloth. Speak with him to progress Hidden Enemies.",
            quest = 809,
            when = "accepted",
            details = {
                "Turn in Neeru Fireblade",
                "Turn in Burning Shadows",
            },
        },
        {
            text = "Talk to Thrall. Turn in Hidden Enemies if you spoke with Neeru for the follow-up, then press Next.",
            note = "Quest 5727.",
        },
        {
            classes = { "Rogue" },
            text = "Rogues: open the side guide Durotar Rogue Shattered Hand, finish it, then resume here.",
            note = "Guide id: horde-durotar-rogue-shattered-hand",
        },
        {
            classes = { "Priest" },
            races = { "Troll" },
            text = "Talk to Ur'kyo. Turn in Hex of Weakness if you still have it, then press Next.",
            note = "Quest 5654.",
        },
        {
            text = "Talk to Kor'ghan. Turn in Finding the Antidote if you finished the poison sacs, then press Next.",
            note = "Quest 813. Skip if you never started Need for a Cure.",
        },
        {
            text = "Leave Orgrimmar west. Talk to Rhinag. Turn in Need for a Cure if you still have it, then press Next.",
            note = "Quest 812. Skip if unfinished or expired.",
        },
        {
            text = "Kill Dreadmaw Crocolisks along the Southfury for Kron's Amulet if you have Lost But Not Forgotten. Talk to Misha Tor'kren to turn it in, then press Next.",
            note = "Quest 816. Abandon if the amulet will not drop.",
        },
        {
            text = "If you still need Conscript of the Horde, talk to Takrin outside Razor Hill, then press Next.",
            note = "Quest 840.",
        },
        {
            text = "Travel west into The Barrens. Talk to Kargal Battlescar at Far Watch Post. Turn in Conscript of the Horde. Accept Crossroads Conscription.",
            quest = 842,
            when = "accepted",
            details = {
                "Turn in Conscript of the Horde",
                "NPC: Kargal Battlescar",
            },
        },
        {
            text = "Talk to Ak'Zeloth at Far Watch Post. Turn in Ak'Zeloth, then press Next.",
            note = "Quest 809.",
        },
        {
            text = "Continue with the Barrens guide from The Crossroads.",
            note = "Next: 12-17 The Barrens.",
        },
    },
})
