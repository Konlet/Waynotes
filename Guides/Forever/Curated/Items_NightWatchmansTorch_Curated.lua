local _, ns = ...

-- Night Watchman's Torch (Alliance + Horde).
-- Duskwood, Night Watch Guard in western Duskwood (about 17.0, 54.8).
-- Alliance uses quest 99267, Horde uses quest 98372. Both are accept and turn-in
-- at the same guard and reward the torch. Level 1 is enough.

ns.RegisterGuide({
    id = "item-night-watchmans-torch-1-60",
    name = "1-60 Night Watchman's Torch",
    group = "Items",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            text = "Travel to Duskwood.",
            when = "travel",
            map = 1431,
            x = 17.0,
            y = 54.8,
        },
        {
            faction = "Alliance",
            text = "Talk to [FRIENDLY]Night Watch Guard[/]. Accept [QUEST]An Unfortunate End[/].",
            quest = 99267,
            when = "accepted",
            map = 1431,
            x = 17.0,
            y = 54.8,
            note = "The Night Watch Guard is a dead body on the ground at this spot, not a standing NPC.",
        },
        {
            faction = "Horde",
            text = "Talk to [FRIENDLY]Night Watch Guard[/]. Accept [QUEST]An Unfortunate End[/].",
            quest = 98372,
            when = "accepted",
            map = 1431,
            x = 17.0,
            y = 54.8,
            note = "The Night Watch Guard is a dead body on the ground at this spot, not a standing NPC.",
        },
        {
            faction = "Alliance",
            text = "Talk to [FRIENDLY]Night Watch Guard[/]. Turn in [QUEST]An Unfortunate End[/].",
            quest = 99267,
            when = "complete",
            map = 1431,
            x = 17.0,
            y = 54.8,
            note = "The [LOOT]Night Watchman's Torch[/] binds when picked up. It lights dark areas for 5 minutes and goes out in combat.",
        },
        {
            faction = "Horde",
            text = "Talk to [FRIENDLY]Night Watch Guard[/]. Turn in [QUEST]An Unfortunate End[/].",
            quest = 98372,
            when = "complete",
            map = 1431,
            x = 17.0,
            y = 54.8,
            note = "The [LOOT]Night Watchman's Torch[/] binds when picked up. It lights dark areas for 5 minutes and goes out in combat.",
        },
    },
})
