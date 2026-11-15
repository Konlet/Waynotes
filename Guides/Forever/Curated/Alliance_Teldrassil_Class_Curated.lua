local _, ns = ...

-- Alliance Teldrassil class side guides.
-- Opened from pointer steps in the main Teldrassil curated route.
-- Finish the chain, then resume the linked main guide.

ns.RegisterGuide({
    id = "alliance-teldrassil-hunter-taming",
    name = "Teldrassil Hunter Taming",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "Night Elf" },
    classes = { "Hunter" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to [FRIENDLY]Dazalar[/] in Dolanaar. Accept [QUEST]Taming the Beast[/].",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6063,
            when = "accepted",
        },
        {
            text = "Use the [LOOT]Taming Rod[/] on a [ENEMY]Webwood Lurker[/] near Dolanaar.",
            map = 1438,
            x = 58.0,
            y = 60.0,
            quest = 6063,
            when = "objectives",
            details = {
                "Tame a [ENEMY]Webwood Lurker[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Dazalar[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Taming the Beast[/].",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6101,
            when = "accepted",
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "Dismiss your spider. Use the [LOOT]Taming Rod[/] on a [ENEMY]Nightsaber Stalker[/].",
            map = 1438,
            x = 55.0,
            y = 72.0,
            quest = 6101,
            when = "objectives",
            details = {
                "Tame a [ENEMY]Nightsaber Stalker[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Dazalar[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Taming the Beast[/].",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6102,
            when = "accepted",
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "Dismiss your nightsaber. Use the [LOOT]Taming Rod[/] on a [ENEMY]Strigid Screecher[/].",
            map = 1438,
            x = 44.0,
            y = 50.0,
            quest = 6102,
            when = "objectives",
            details = {
                "Tame a [ENEMY]Strigid Screecher[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Dazalar[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Training the Beast[/].",
            map = 1438,
            x = 56.7,
            y = 59.5,
            quest = 6103,
            when = "accepted",
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "In Darnassus, talk to [FRIENDLY]Jocaste[/]. Turn in [QUEST]Training the Beast[/].",
            map = 1457,
            x = 40.4,
            y = 8.6,
            quest = 6103,
            when = "complete",
        },
        {
            text = "Return to the 6-12 Teldrassil guide.",
            guide = "alliance-teldrassil-6-12-curated",
        },
    },
})

ns.RegisterGuide({
    id = "alliance-teldrassil-druid-moonglade",
    name = "Teldrassil Druid Moonglade",
    group = "Alliance",
    faction = "Alliance",
    forever = true,
    listed = true,
    races = { "Night Elf" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 14,
    steps = {
        {
            text = "In Darnassus, talk to [FRIENDLY]Mathrengyl Bearwalker[/]. Turn in [QUEST]Heeding the Call[/]. Accept [QUEST]Moonglade[/].",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 5921,
            when = "accepted",
            details = {
                "Turn in [QUEST]Heeding the Call[/]",
            },
            note = "Pickup [QUEST]Heeding the Call[/] from your Dolanaar or Darnassus trainer first.",
        },
        {
            text = "Cast [SKILL]Teleport: Moonglade[/]. Talk to [FRIENDLY]Dendrite Starblaze[/]. Turn in [QUEST]Moonglade[/]. Accept [QUEST]Great Bear Spirit[/].",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 5929,
            when = "accepted",
            details = {
                "Turn in [QUEST]Moonglade[/]",
            },
        },
        {
            text = "Talk to the [FRIENDLY]Great Bear Spirit[/], then return to [FRIENDLY]Dendrite Starblaze[/]. Turn in [QUEST]Great Bear Spirit[/]. Accept [QUEST]Back to Darnassus[/].",
            map = 1450,
            x = 39.1,
            y = 27.5,
            quest = 5931,
            when = "accepted",
            details = {
                "Turn in [QUEST]Great Bear Spirit[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Silva Fil'naveth[/] for a flight to Rut'theran, then enter Darnassus. Talk to [FRIENDLY]Mathrengyl Bearwalker[/]. Turn in [QUEST]Back to Darnassus[/]. Accept [QUEST]Body and Heart[/].",
            map = 1457,
            x = 35.4,
            y = 8.4,
            quest = 6001,
            when = "accepted",
            details = {
                "Turn in [QUEST]Back to Darnassus[/]",
            },
        },
        {
            text = "Return to the 6-12 Teldrassil guide.",
            note = "Open the Darkshore Druid Body and Heart side guide when you reach Auberdine.",
            guide = "alliance-teldrassil-6-12-curated",
        },
    },
})
