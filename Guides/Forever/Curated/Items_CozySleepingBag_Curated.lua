local _, ns = ...

-- Cozy Sleeping Bag (Alliance + Horde).
-- A chain of object clicks with no quest NPC. Level 14 is required.
-- Alliance uses quest 79008 and Horde uses quest 79007 for the first hand-in.
-- Both factions then follow the same route: Stonetalon, Loch Modan,
-- and the Thoradin's Wall climb between Hillsbrad and Arathi.

ns.RegisterGuide({
    id = "item-cozy-sleeping-bag-14-60",
    name = "14-60 Cozy Sleeping Bag",
    group = "Items",
    forever = true,
    listed = true,
    minLevel = 14,
    maxLevel = 60,
    steps = {
        {
            faction = "Alliance",
            text = "Click the [PICK]Burned-Out Remains[/] in the cart at Alexston Farmstead. Accept [QUEST]... and that note you found[/].",
            quest = 79008,
            when = "accepted",
            map = 1436,
            x = 37.4,
            y = 50.6,
            note = "Both factions follow the same route. Only the first hand-in swaps zones.",
        },
        {
            faction = "Horde",
            text = "Click the [PICK]Burned-Out Remains[/] at the burned tower south of Camp Taurajo. Accept [QUEST]... and that note you found[/].",
            quest = 79007,
            when = "accepted",
            map = 1413,
            x = 46.4,
            y = 73.9,
            note = "Both factions follow the same route. Only the first hand-in swaps zones.",
        },
        {
            faction = "Alliance",
            text = "Click the [PICK]Nailed Plank[/] at the burned tower south of Camp Taurajo. Turn in [QUEST]... and that note you found[/]. Accept [QUEST]Stepping Stones[/].",
            quest = 79192,
            when = "accepted",
            map = 1413,
            x = 46.4,
            y = 73.8,
            details = {
                "Turn in [QUEST]... and that note you found[/]",
            },
        },
        {
            faction = "Horde",
            text = "Click the [PICK]Nailed Plank[/] in the cart at Alexston Farmstead. Turn in [QUEST]... and that note you found[/]. Accept [QUEST]Stepping Stones[/].",
            quest = 79192,
            when = "accepted",
            map = 1436,
            x = 37.4,
            y = 50.9,
            details = {
                "Turn in [QUEST]... and that note you found[/]",
            },
        },
        {
            text = "Travel to Stonetalon Mountains.",
            when = "travel",
            map = 1442,
            x = 40.7,
            y = 52.4,
        },
        {
            text = "Click the [PICK]Pocket Litter[/] on the crate at the abandoned camp. Turn in [QUEST]Stepping Stones[/]. Accept [QUEST]Scramble[/].",
            quest = 79980,
            when = "accepted",
            map = 1442,
            x = 40.7,
            y = 52.4,
            note = "The path up starts northeast of Sun Rock Retreat and winds west to the camp.",
            details = {
                "Turn in [QUEST]Stepping Stones[/]",
            },
        },
        {
            text = "Click the [PICK]Mound of Dirt[/] on the hilltop north of the camp. Turn in [QUEST]Scramble[/]. Accept [QUEST]Wet Job[/].",
            quest = 79974,
            when = "accepted",
            map = 1442,
            x = 39.6,
            y = 49.9,
            note = "Do not miss the jump across the gap near the top, or you have to go all the way around again.",
            details = {
                "Turn in [QUEST]Scramble[/]",
            },
        },
        {
            text = "Travel to Loch Modan.",
            when = "travel",
            map = 1432,
            x = 49.4,
            y = 12.9,
        },
        {
            text = "Click the [PICK]Carved Figurine[/] on the carved dwarf heads at the Stonewrought Dam. Turn in [QUEST]Wet Job[/]. Accept [QUEST]Eagle's Fist[/].",
            quest = 79975,
            when = "accepted",
            map = 1432,
            x = 49.4,
            y = 12.9,
            note = "Drop onto the eastern-most dwarf head, then work along to the figurine. Horde: Loch Modan guards are level 30, so get in and out quickly.",
            details = {
                "Turn in [QUEST]Wet Job[/]",
            },
        },
        {
            text = "Travel to the broken cart on the Hillsbrad side of Thoradin's Wall.",
            when = "travel",
            map = 1424,
            x = 87.3,
            y = 49.6,
            note = "Jump onto the cart, then from the cart onto the wall. Follow the top of the wall into the room inside it.",
        },
        {
            text = "Click the [PICK]Messenger Bag[/] hanging by the doorway on top of the wall. Turn in [QUEST]Eagle's Fist[/]. Accept [QUEST]This Must Be The Place[/].",
            quest = 79976,
            when = "accepted",
            map = 1417,
            x = 22.5,
            y = 24.2,
            details = {
                "Turn in [QUEST]Eagle's Fist[/]",
            },
        },
        {
            text = "Click the [PICK]Hastily Rolled-Up Satchel[/] on the ground beneath the bag. Turn in [QUEST]This Must Be The Place[/].",
            quest = 79976,
            when = "complete",
            map = 1417,
            x = 22.5,
            y = 24.2,
            note = "The [LOOT]Cozy Sleeping Bag[/] binds when picked up. Use it outside cities and inns to gain the Well-Rested buff.",
        },
    },
})
