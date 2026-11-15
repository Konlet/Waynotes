local _, ns = ...

-- Template guide. Copy this file, change the id, and reload.
--
-- quest: one quest id. quests = { 1, 2 } lists several.
-- when = "accepted" advances once every listed quest is in your log
--        (or already turned in).
-- when = "complete" advances once every listed quest is turned in.
-- when = "objectives" advances once objectives are finished (also the
--        default when a quest is set and when is left out).
-- when = "travel" advances once you arrive near map/x/y (or step.travel).
--        Use for zone transitions and long runs with no quest gate.
--        Optional arriveYards overrides the default arrival radius.
-- nearYards overrides the NEAR radius on kill/loot/pick objective steps
--        (and multi-pin visit distance). Default is 100 yards, or 10 when
--        the step only needs one kill, loot, or pick.
-- objective = N advances an objectives step once quest objective N is
--        done (1-based leaderboard index). Use this to split multi-enemy
--        quests onto different pins when spawn camps are not nearby.
-- Leave when out with no quest and the step waits for the next button.
--
-- Optional guide fields for recommendations:
--   faction, minLevel, maxLevel, races = { "Orc" }, classes = { "Warrior" }
--
-- map, x, y are an optional pin. map is a UiMap ID. Elwynn Forest is 1429.
-- Write Era coordinates. On Forever, QuestieDB converts the zones it knows
-- about. Leave the pin out and the step uses the quest giver's spawn.
-- pins = { { x = 10, y = 20 }, { x = 30, y = 40, note = "Pond" } } lists
-- several spots (map inherited from the step). The arrow goes to the nearest
-- unvisited pin, then the next when you reach it.
--
-- Color tags (preferred authoring form):
--   [FRIENDLY]Deputy Willem[/]   NPCs
--   [ENEMY]Kobold Vermin[/]      mobs
--   [QUEST]A Threat Within[/]   quest names
--   [LOOT]Gold Coin[/]          items you loot
--   [PICK]Box of Spells[/]      objects you click
--   [BUY]Tough Jerky[/]         vendor goods
--   [SKILL]Battle Shout[/]      spells and abilities
--   [WARN]Do not die[/]         warnings
-- Closing [/TAG] also works, e.g. [ENEMY]Foo[/ENEMY].
-- Legacy |cRB_FRIENDLY_Name|r tags still expand the same way.

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
