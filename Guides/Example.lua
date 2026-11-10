local _, ns = ...

-- Template guide. Copy this file, change the id, and reload.
--
-- quest: one quest id. quests = { 1, 2 } lists several.
-- when = "accepted" advances once every listed quest is in your log
--        (or already turned in).
-- when = "complete" advances once every listed quest is turned in.
-- Leave when out and the step waits for the next button.
--
-- map, x, y are an optional pin. map is a UiMap ID. Elwynn Forest is 1429.
-- Write Era coordinates. On Forever, QuestieDB converts the zones it knows
-- about. Leave the pin out and the step uses the quest giver's spawn.

ns.RegisterGuide({
    id = "example-northshire",
    name = "Example: Northshire",
    group = "Examples",
    faction = "Alliance",
    steps = {
        {
            text = "Accept A Threat Within from Deputy Willem.",
            note = "He stands in front of Northshire Abbey.",
            quest = 783,
            when = "accepted",
            map = 1429,
            x = 48.2,
            y = 42.6,
        },
        {
            text = "Clean the kobold camps, then investigate Echo Ridge.",
            quests = { 7, 15 },
            when = "complete",
        },
        {
            text = "Finish the skirmish at Echo Ridge.",
            quest = 21,
            when = "complete",
        },
        {
            text = "Run south to Goldshire and speak with Marshal Dughan.",
            note = "The road out of Northshire leads into Elwynn Forest.",
            quest = 54,
            when = "accepted",
            map = 1429,
            x = 42.1,
            y = 65.9,
        },
    },
})
