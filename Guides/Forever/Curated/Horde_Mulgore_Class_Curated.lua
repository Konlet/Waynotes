local _, ns = ...

-- Horde Mulgore class side guides.
-- Opened from pointer steps in the main Mulgore curated route.
-- Finish the chain, then resume the linked main guide.

ns.RegisterGuide({
    id = "horde-mulgore-shaman-earth",
    name = "Mulgore Shaman Call of Earth",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Shaman" },
    minLevel = 3,
    maxLevel = 6,
    steps = {
        {
            text = "Talk to [FRIENDLY]Seer Ravenfeather[/]. Turn in [QUEST]Call of Earth[/]. Accept [QUEST]Call of Earth[/].",
            map = 1412,
            x = 44.7,
            y = 76.2,
            quest = 1520,
            when = "accepted",
            details = {
                "Turn in [QUEST]Call of Earth[/]",
            },
        },
        {
            text = "At the Kodo Rock east of camp, use the [LOOT]Earth Sapta[/]. Talk to the [FRIENDLY]Minor Manifestation of Earth[/]. Turn in [QUEST]Call of Earth[/]. Accept [QUEST]Call of Earth[/].",
            map = 1412,
            x = 53.7,
            y = 80.2,
            quest = 1521,
            when = "accepted",
            details = {
                "Turn in [QUEST]Call of Earth[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Seer Ravenfeather[/]. Turn in [QUEST]Call of Earth[/].",
            map = 1412,
            x = 44.7,
            y = 76.2,
            quest = 1521,
            when = "complete",
        },
        {
            text = "Return to the 1-6 Mulgore guide.",
            guide = "horde-mulgore-1-6-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-mulgore-hunter-taming",
    name = "Mulgore Hunter Taming",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Hunter" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to [FRIENDLY]Yaw Sharpmane[/]. Accept [QUEST]Taming the Beast[/].",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6061,
            when = "accepted",
        },
        {
            text = "Use the [LOOT]Taming Rod[/] on an [ENEMY]Adult Plainstrider[/] west of Bloodhoof Village.",
            map = 1412,
            x = 43.0,
            y = 52.0,
            quest = 6061,
            when = "objectives",
            details = {
                "Tame an [ENEMY]Adult Plainstrider[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Yaw Sharpmane[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Taming the Beast[/].",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6087,
            when = "accepted",
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "Dismiss your plainstrider. Use the [LOOT]Taming Rod[/] on a [ENEMY]Prairie Stalker[/] north of town.",
            map = 1412,
            x = 46.0,
            y = 47.0,
            quest = 6087,
            when = "objectives",
            details = {
                "Tame a [ENEMY]Prairie Stalker[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Yaw Sharpmane[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Taming the Beast[/].",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6088,
            when = "accepted",
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "Dismiss your stalker. Use the [LOOT]Taming Rod[/] on a [ENEMY]Swoop[/] southeast of town.",
            map = 1412,
            x = 52.0,
            y = 64.0,
            quest = 6088,
            when = "objectives",
            details = {
                "Tame a [ENEMY]Swoop[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Yaw Sharpmane[/]. Turn in [QUEST]Taming the Beast[/]. Accept [QUEST]Training the Beast[/].",
            map = 1412,
            x = 47.8,
            y = 55.7,
            quest = 6089,
            when = "accepted",
            details = {
                "Turn in [QUEST]Taming the Beast[/]",
            },
        },
        {
            text = "In Thunder Bluff, talk to [FRIENDLY]Holt Thunderhorn[/] on Hunter Rise. Turn in [QUEST]Training the Beast[/].",
            map = 1456,
            x = 57.3,
            y = 89.8,
            quest = 6089,
            when = "complete",
        },
        {
            text = "Return to the 10-12 Mulgore guide.",
            guide = "horde-mulgore-10-12-curated",
        },
    },
})

ns.RegisterGuide({
    id = "horde-mulgore-druid-moonglade",
    name = "Mulgore Druid Moonglade",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    races = { "Tauren" },
    classes = { "Druid" },
    minLevel = 10,
    maxLevel = 12,
    steps = {
        {
            text = "Talk to [FRIENDLY]Gennia Runetotem[/] in Bloodhoof Village. Accept [QUEST]Heeding the Call[/].",
            map = 1412,
            x = 48.5,
            y = 59.6,
            quest = 5928,
            when = "accepted",
        },
        {
            text = "In Thunder Bluff, talk to [FRIENDLY]Turak Runetotem[/] on Elder Rise. Turn in [QUEST]Heeding the Call[/]. Accept [QUEST]Moonglade[/].",
            map = 1456,
            x = 76.5,
            y = 27.2,
            quest = 5922,
            when = "accepted",
            details = {
                "Turn in [QUEST]Heeding the Call[/]",
            },
        },
        {
            text = "Cast [SKILL]Teleport: Moonglade[/]. Talk to [FRIENDLY]Dendrite Starblaze[/]. Turn in [QUEST]Moonglade[/]. Accept [QUEST]Great Bear Spirit[/].",
            map = 1450,
            x = 56.4,
            y = 30.5,
            quest = 5930,
            when = "accepted",
            details = {
                "Turn in [QUEST]Moonglade[/]",
            },
        },
        {
            text = "Talk to the [FRIENDLY]Great Bear Spirit[/] northwest of Nighthaven and complete its dialogue.",
            map = 1450,
            x = 39.1,
            y = 27.5,
            quest = 5930,
            when = "objectives",
        },
        {
            text = "Return to [FRIENDLY]Dendrite Starblaze[/]. Turn in [QUEST]Great Bear Spirit[/]. Accept [QUEST]Back to Thunder Bluff[/].",
            map = 1450,
            x = 56.21,
            y = 30.64,
            quest = 5932,
            when = "accepted",
            details = {
                "Turn in [QUEST]Great Bear Spirit[/]",
            },
        },
        {
            text = "Talk to [FRIENDLY]Bunthen Plainswind[/] and fly to Thunder Bluff.",
            map = 1450,
            x = 44.28,
            y = 45.87,
            quest = 5932,
            when = "travel",
        },
        {
            text = "Talk to [FRIENDLY]Turak Runetotem[/]. Turn in [QUEST]Back to Thunder Bluff[/]. Accept [QUEST]Body and Heart[/].",
            map = 1456,
            x = 76.5,
            y = 27.2,
            quest = 6002,
            when = "accepted",
            details = {
                "Turn in [QUEST]Back to Thunder Bluff[/]",
            },
        },
        {
            text = "Return to the 10-12 Mulgore guide.",
            note = "Finish [QUEST]Body and Heart[/] at the Moonkin Stone near Camp Taurajo when the main route reaches it, or open the Barrens Druid Body and Heart side guide.",
            guide = "horde-mulgore-10-12-curated",
        },
    },
})
