# Curated Guide Standards

This document is the authoring and review standard for Waynotes curated guides. It is written for two audiences:

- **Human authors and reviewers** who write or proofread guide files.
- **AI agents** that generate, convert, or edit guide files. Agents must treat every "Must" and "Do not" in this file as a hard rule.

Every rule here is tied to how `Guides.lua` and `Travel.lua` actually read guide data. If a rule and the engine ever disagree, the engine wins, and this file should be updated.

---

## 1. Where curated guides live

| Item | Rule |
| --- | --- |
| Folder | `Guides/Forever/Curated/` |
| File name | `<Faction>_<Zone>_Curated.lua`, for example `Horde_Stonetalon_Curated.lua`. Use `Dungeons_`, `Professions_`, or a race prefix such as `Skyborne_` for non-zone packs. |
| Load order | The file must be listed in `Waynotes.toc`. `scripts/export-forever.ps1` refuses any guide outside `Guides/Forever/Curated/*_Curated.lua`. |
| Linked guides | Any guide referenced by `next` or a step's `guide` field must also be in a file listed in the TOC. Class side guides live in `Guides/Forever/Curated/<Faction>_<Zone>_Class_Curated.lua`. Do not link into unshipped `*_ClassQuests.lua` files. |
| Reference material | `Guides/REFERENCE/` holds third-party source guides (RestedXP, Zygor). Read them for routing ideas only. Never copy their wording directly, and never ship them. |

### File header

Every file starts with `local _, ns = ...`, then a short comment block that tells a reviewer what the guide covers, the level band, and what the player should already have.

```lua
local _, ns = ...

-- Horde Stonetalon Mountains.
-- First pass from the Barrens border into Windshear and Malaka'jin,
-- then the Sun Rock Retreat sweep through the peak and Charred Vale.
-- Start after Barrens 20-25 with The Spirits of Stonetalon.
```

---

## 2. Guide fields (`ns.RegisterGuide({...})`)

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `id` | string | Yes | Unique, lowercase, hyphenated: `<faction>-<zone>-<min>-<max>`, for example `"horde-stonetalon-17-26"`. Never rename a shipped id; saved progress is keyed on it. |
| `name` | string | Yes | Menu label: `"<min>-<max> <Zone Name>"`, for example `"17-26 Stonetalon Mountains"`. Dungeons use the instance name. |
| `group` | string | Yes | Menu section: `"Horde"`, `"Alliance"`, `"Dungeons"`, `"Professions"`, or a race name. |
| `faction` | `"Horde"` or `"Alliance"` | Recommended | Marks the guide for recommendations and default menu collapse. The other faction's section stays visible but minimized. Leave out for shared guides. |
| `forever` | boolean | Yes for curated | Always `true`. Marks coordinates as Forever-native so they are not converted again. |
| `listed` | boolean | Yes | `true` to show in the guide picker. Defaults to `false` when omitted, so a missing value hides the guide. |
| `minLevel`, `maxLevel` | number | Yes | Level band used for recommendations. Must match `name`. |
| `next` | string | Recommended | `id` of the guide that follows. Must exist and be loaded. |
| `starter` | boolean | Optional | `true` only for level 1 starting zone guides. |
| `dungeon` | string | Dungeons only | Exact instance name, for example `"Wailing Caverns"`. Waynotes offers the guide when the player zones in. |
| `races`, `excludeRaces` | list of strings | Optional | Limit the whole guide by race. |
| `classes`, `excludeClasses` | list of strings | Optional | Limit the whole guide by class. A single class moves the guide under that class in the menu. |
| `steps` | list of tables | Yes | Ordered steps. A guide with zero valid steps is rejected. |

Race and class names are case and space insensitive (`"NightElf"`, `"Night Elf"`, and `"nightelf"` all work). Use the in-game spelling with capitals, for example `"Night Elf"` or `"Undead"`.

### Example guide block

```lua
ns.RegisterGuide({
    id = "horde-stonetalon-17-26",
    name = "17-26 Stonetalon Mountains",
    group = "Horde",
    faction = "Horde",
    forever = true,
    listed = true,
    next = "horde-ashenvale-21-22",
    minLevel = 17,
    maxLevel = 26,
    steps = {
        -- steps go here
    },
})
```

---

## 3. Step fields

| Field | Type | Meaning |
| --- | --- | --- |
| `text` | string | The headline the player reads. Required in practice. See section 7 for wording rules. |
| `quest` | number | One quest id that gates this step. |
| `quests` | list of numbers | Several quest ids that gate this step together. Use instead of `quest` when a step accepts or turns in more than one quest. |
| `when` | string | How the step completes. One of `"accepted"`, `"complete"`, `"objectives"`, `"travel"`, `"grind"`. See section 4. |
| `objective` | number | 1-based quest log objective index. With `when = "objectives"`, the step completes once only that objective is done. |
| `level` | number | Target character level for `when = "grind"`. |
| `xp` | number | Optional XP into `level` for grind steps. Values in `(0, 1)` are a fraction of the bar (`0.5` = mid-level). Values `>= 1` are absolute XP. |
| `map`, `x`, `y` | number | Pin. `map` is a UiMap id, `x` and `y` are 0 to 100 map percentages. See section 5. |
| `pins` | list of tables | Several pins for one step. See section 5. |
| `details` | list of strings | Sub-lines under the headline: objective counts and extra turn-ins. See section 7.3. |
| `note` | string | One extra hint shown behind the "more notes" control. See section 7.4. |
| `sticky` | boolean | Keep this step on screen while later steps proceed. See section 6. |
| `locale` | string | Optional place name for sticky grouping, for example `"Razor Hill"` or `"Tiragarde Keep"`. See section 6. |
| `faction` | `"Horde"` or `"Alliance"` | Show the step only to that faction. |
| `races`, `excludeRaces` | list of strings | Show or hide the step by race. |
| `classes`, `excludeClasses` | list of strings | Show or hide the step by class. |
| `minLevel`, `maxLevel` | number | Show the step only within this character level range. Below `minLevel` or above `maxLevel`, the step is skipped. |
| `mode` | `"softcore"` or `"hardcore"` | Show the step only in that guide mode. |
| `guide` | string | Points at another guide id (side guide or hand-off). The step completes once that guide's quest steps are finished. |
| `fpath` | string | Flight path pickup. Names the flight hub, for example `"Crossroads"`. The step completes once that node is learned. |
| `travel` | string, table, or `true` | Explicit travel destination for routing. See section 4.4. |
| `arriveYards` | number | Arrival radius for `when = "travel"` steps. Default is 10 yards. |
| `nearYards` | number | Radius for kill/loot/pick objective steps to show NEAR and to mark multi-pin spots visited. Default is 100 yards, or 5 yards when the step only needs one kill, loot, or pick. |

Fields not in this table are ignored by the loader. In particular, do not put `text` inside a `pins` entry; use `note`.

---

## 4. Step types (the `when` field)

Pick the step type from what actually finishes the step in game. A step that the game can detect must be gated by a quest or travel check, never left manual.

### 4.1 `when = "accepted"`

Completes once every listed quest is in the quest log (or already turned in). Use for pickups, and for "turn in X, accept Y" steps where `quest` is the **newly accepted** quest.

```lua
{
    text = "Talk to [FRIENDLY]Makaba Flathoof[/]. Accept [QUEST]Avenge My Village[/].",
    quest = 6548,
    when = "accepted",
    map = 1413,
    x = 35.19,
    y = 27.79,
},
```

Turn in one quest and pick up its follow-up:

```lua
{
    text = "Talk to [FRIENDLY]Makaba Flathoof[/]. Turn in [QUEST]Avenge My Village[/]. Accept [QUEST]Kill Grundig Darkcloud[/].",
    quest = 6629,
    when = "accepted",
    map = 1413,
    x = 35.19,
    y = 27.79,
    details = {
        "Turn in [QUEST]Avenge My Village[/]",
    },
},
```

Accept several quests from one NPC:

```lua
{
    text = "Talk to [FRIENDLY]Tsunaman[/] up the path. Accept [QUEST]Elemental War[/] and [QUEST]Trouble in the Deeps[/].",
    quests = { 6393, 6562 },
    when = "accepted",
    map = 1442,
    x = 47.4,
    y = 64.3,
},
```

### 4.2 `when = "complete"`

Completes once every listed quest is turned in. Use for turn-ins that do not lead to a new pickup at the same NPC.

```lua
{
    text = "Talk to [FRIENDLY]Xen'Zilla[/]. Turn in [QUEST]Blood Feeders[/].",
    quest = 6461,
    when = "complete",
    map = 1442,
    x = 71.2,
    y = 95.0,
},
```

### 4.3 `when = "objectives"`

Completes once the quest's objectives are finished. This is also the default when a step has a quest and no `when`, but always write it out.

Kill, loot, and pick objectives show **NEAR** once the player is within range of the pin (and the arrow becomes a pin). The default radius is **100 yards** for grind counts (2+), and **5 yards** when the step only needs one kill, loot, or pick (a named target or a `(1)` detail). Set `nearYards` when the camp is larger or tighter than that default. The same radius marks multi-pin spots as visited.

```lua
{
    text = "Enter Stonetalon. Kill [ENEMY]Grimtotem Ruffians[/] and [ENEMY]Grimtotem Mercenaries[/] at Camp Aparaje.",
    quest = 6548,
    when = "objectives",
    map = 1442,
    x = 81.5,
    y = 88.4,
    nearYards = 150,
    details = {
        "[ENEMY]Grimtotem Ruffian[/] (8)",
        "[ENEMY]Grimtotem Mercenary[/] (6)",
    },
},
```

When one quest has objectives in different camps, split it with `objective`:

```lua
{
    text = "Kill [ENEMY]Thistle Boars[/] south of Aldrassil.",
    quest = 457,
    objective = 2,
    when = "objectives",
    map = 1438,
    x = 56.2,
    y = 37.6,
    details = {
        "[ENEMY]Thistle Boar[/] (7)",
    },
},
```

### 4.4 `when = "travel"`

Completes once the player arrives within 10 yards of the pin (unless `arriveYards` is set), or once the player enters the zone the step names. Use for zone transitions and long runs with no quest gate. With several `pins`, they are waypoints in order: the arrow advances to each next pin, there is no cycle button, and the step completes at the last pin.

The zone check uses the destination from `travel` (a string, or `travel.name`), otherwise the text after "Travel to", "Fly to", "Run to", and similar openers. It must match the in-game zone name exactly, ignoring a leading "The", case, and apostrophes. So `Travel to Stonetalon Mountains.` completes on crossing the border, while `Travel to the Barrens / Stonetalon border camp.` and `Travel to The Crossroads.` still need the pin. Write the full zone name for "reach the zone" steps, not a short form like "Stonetalon".

```lua
{
    text = "Travel to Stonetalon Mountains.",
    when = "travel",
    map = 1413,
    x = 35.9,
    y = 28.9,
},
```

`travel` can name the destination for the route planner when the pin alone is not enough:

```lua
travel = "Thunder Bluff",                                  -- named place
travel = { map = 1456, x = 45.0, y = 55.0, name = "Thunder Bluff" },
```

Steps whose text starts with "Travel", "Fly", "Hearth", "Run to", or "Take the flight path" are also treated as travel steps for routing, but they only auto-complete when `when = "travel"` is set.

### 4.5 `when = "grind"`

Completes once the player reaches `level`, optionally with experience into that level. Use for camps where the guide needs a level or XP gate and there is no quest objective. The tracker shows live XP progress. The pin uses the enemy NEAR radius (override with `nearYards`).

```lua
{
    text = "Keep killing [ENEMY]Felmusk[/] satyrs at Night Run until you are close to level 27.",
    when = "grind",
    level = 26,
    xp = 0.8,
    map = 1440,
    x = 66.98,
    y = 54.97,
},
```

```lua
{
    text = "Grind mobs around Mystral Lake until you are mid level 27 before heading back.",
    when = "grind",
    level = 27,
    xp = 0.5,
    map = 1440,
    x = 52.4,
    y = 62.8,
},
```

- `level = 27` alone finishes at character level 27.
- `level = 27, xp = 300` finishes at level 27 with at least 300 XP into the bar.
- `level = 27, xp = 0.5` finishes at mid level 27 (half the bar).
- Already at or above the target (including XP) skips the step during catch-up.

Do not use a manual "grind to level N" step when a grind check would work.

### 4.6 Flight path pickup

Text that says "Get the `<Hub>` flight path" completes automatically once the node is learned, including when the player already had it. Add `fpath` when the hub name is not in the text.

```lua
{
    text = "Talk to [FRIENDLY]Devrak[/]. Get the Crossroads flight path.",
    map = 1413,
    x = 51.5,
    y = 30.3,
},
```

### 4.7 Guide link (side guide or hand-off)

Set `guide` to another guide id. The step completes once every quest step in that guide is done. Use it for class side guides and for the final hand-off to the next zone.

```lua
{
    classes = { "Shaman" },
    text = "Talk to [FRIENDLY]Kranal Fiss[/]. Finish the Call of Fire side guide, then resume here.",
    guide = "horde-barrens-shaman-fire",
},
```

### 4.8 Manual step (no `when`, no quest)

Waits for the player to press the next arrow. Use only for actions the game cannot detect: setting a hearthstone, training, buying, or a one-time warning.

```lua
{
    text = "Talk to [FRIENDLY]Innkeeper Boorand Plainswind[/]. Set your Hearthstone to Crossroads.",
    map = 1413,
    x = 52.0,
    y = 29.9,
},
```

Do not use a manual step when a quest id, travel check, or grind check would work.

---

## 5. Pins and coordinates

- `map` is a Classic UiMap id. `x` and `y` are percentages from 0 to 100, rounded to one or two decimals.
- Curated guides set `forever = true`, so pins must already be Forever-correct. Do not paste unconverted Era coordinates from reference guides without checking them.
- Leave the pin off a quest step only when the quest giver or turn-in NPC is the correct target. The engine falls back to the QuestieDB spawn.
- For accept steps, pin the quest giver. For complete steps, pin the turn-in NPC. For objective steps, pin the center of the kill or loot area, not the quest giver.

### Common UiMap ids

| Zone | id | Zone | id |
| --- | --- | --- | --- |
| Durotar | 1411 | Orgrimmar | 1454 |
| Mulgore | 1412 | Thunder Bluff | 1456 |
| The Barrens | 1413 | Undercity | 1458 |
| Tirisfal Glades | 1420 | Stormwind City | 1453 |
| Hillsbrad Foothills | 1424 | Darnassus | 1457 |
| Redridge Mountains | 1433 | Ironforge | 1455 |
| Teldrassil | 1438 | Elwynn Forest | 1429 |
| Darkshore | 1439 | Stonetalon Mountains | 1442 |
| Ashenvale | 1440 | Thousand Needles | 1441 |
| Zephras (Skyborne start) | 2521 | | |

### Multiple pins

Use `pins` when the same objective spawns in several separate spots, or when a travel step follows a short path of waypoints.

- **Objectives** (`when = "objectives"`): the arrow goes to the nearest unvisited pin, and the player can cycle pins with the pin button.
- **Travel** (`when = "travel"`): pins are a path. The arrow follows them in authored order with no cycle button, and the step completes at the last pin.

`map` is inherited from the step unless a pin sets its own. Each pin accepts `map`, `x`, `y`, and `note` (or `label`). Any other key is dropped.

```lua
{
    sticky = true,
    text = "Kill [ENEMY]Sunscale Scytheclaws[/].",
    quest = 865,
    when = "objectives",
    map = 1413,
    x = 52.0,
    y = 46.5,
    pins = {
        { x = 52.0, y = 46.5, note = "Sunscale Scytheclaws" },
        { x = 48.2, y = 49.8, note = "Sunscale Scytheclaws" },
        { x = 44.6, y = 44.4, note = "Sunscale Scytheclaws" },
    },
    details = {
        "[LOOT]Intact Raptor Horn[/] (5)",
        "[LOOT]Sunscale Feather[/] (3)",
    },
},
```

### Verifying pins

Run the coordinate audit against QuestieDB before submitting:

```powershell
python Data/audit_curated_coords.py Guides/Forever/Curated/Horde_Stonetalon_Curated.lua
```

Pins farther than 8 map units from the expected NPC or objective are warnings. Pins farther than 20 are failures. Objective-area pins may legitimately warn; failures must be fixed or explained in review.

---

## 6. Sticky steps

`sticky = true` keeps an unfinished objective on screen while the player works on later steps. Use it for "kill or loot while you go" objectives that overlap other work.

Rules:

- **Must** be an `objectives` step. Never make an accept, turn-in, or travel step sticky.
- **Must** be near the steps it rides along with. The engine hides a sticky that is more than 750 yards from both the player and the current step, so a far sticky silently disappears. Keep every sticky's pin within the same area as the steps that follow it.
- **Must** be placed immediately before the steps it overlaps, not at the start of the zone.
- Do not chain more than about three active stickies at once; the tracker becomes unreadable.

Optional `locale` tags a place (camp, keep, hold). Matching is trim + case-insensitive. Accept and turn-in steps may carry `locale` even though they are not sticky, so the current step has a place identity.

| Sticky `locale` | Primary `locale` | Behavior |
| --- | --- | --- |
| unset | any | Distance / contiguous / gating rules only |
| set | same place | Show (same camp; no 750-yard hide) |
| set | different place | Hide, unless the sticky gates the primary |
| set | unset | Distance / contiguous / gating fallback |

Good: a sticky loot objective followed by a kill objective in the same camp.

```lua
{
    sticky = true,
    text = "Loot [LOOT]Super Reaper 6000 Blueprints[/] from [ENEMY]Operators[/].",
    quest = 1093,
    when = "objectives",
    map = 1442, x = 66.4, y = 55.9,
    details = { "[LOOT]Super Reaper 6000 Blueprints[/] (1)" },
},
{
    text = "Kill [ENEMY]Venture Co. Loggers[/].",
    quest = 1062,
    when = "objectives",
    map = 1442, x = 66.4, y = 55.9,
    details = { "[ENEMY]Venture Co. Logger[/] (15)" },
},
```

Good: hub accepts and field stickies use different locales so Tiragarde stickies do not ride along during Razor Hill turns.

```lua
{
    text = "Talk to [FRIENDLY]Gar'Thok[/]. Accept [QUEST]Vanquish the Betrayers[/].",
    quest = 784,
    when = "accepted",
    locale = "Razor Hill",
    map = 1411, x = 52.0, y = 43.5,
},
{
    sticky = true,
    text = "Loot [LOOT]Canvas Scraps[/] from Kul Tiras at Tiragarde.",
    quest = 791,
    when = "objectives",
    locale = "Tiragarde Keep",
    map = 1411, x = 58.1, y = 55.8,
    details = { "[LOOT]Canvas Scraps[/] (8)" },
},
```

Bad: a south oasis sticky followed by steps at the northern harpy camps 1,000 yards away.

---

## 7. Verbiage

The player reads the headline in a small tracker while playing. Every word must tell them what to do, where, or to whom. Write in plain, imperative, present-tense sentences.

### 7.1 Color tags

Wrap every proper noun the player acts on in a color tag. Close with `[/]` (the long form `[/ENEMY]` also works, but use `[/]`).

| Tag | Use for | Example |
| --- | --- | --- |
| `[FRIENDLY]` | NPCs you talk to | `[FRIENDLY]Seereth Stonebreak[/]` |
| `[ENEMY]` | Mobs you kill | `[ENEMY]Grimtotem Brutes[/]` |
| `[QUEST]` | Quest names | `[QUEST]Goblin Invaders[/]` |
| `[LOOT]` | Items you loot, carry, or use | `[LOOT]Gaea Seeds[/]` |
| `[PICK]` | World objects you click | `[PICK]Control Console[/]` |
| `[BUY]` | Vendor goods | `[BUY]Tough Jerky[/]` |
| `[SKILL]` | Spells and abilities | `[SKILL]Battle Shout[/]` |
| `[WARN]` | Danger or optional labels | `[WARN]Optional group:[/]` |

Tag rules:

- Tag the exact in-game name. Plurals in the headline are fine (`[ENEMY]Grimtotem Brutes[/]`); details use the singular (`[ENEMY]Grimtotem Brute[/] (6)`).
- Tag each name once per sentence. Do not tag generic words such as "harpies" or "the hut".
- Do not tag place names. Zones and subzones stay plain text.
- Do not use legacy `|cRB_FRIENDLY_Name|r` strings in new work.
- Do not start `text` with a bracketed class or race word such as `[Warrior]` or `[!Troll]`. The loader parses that as a filter and strips it. Use the `classes` and `races` fields instead.

### 7.2 Headline (`text`) patterns

Use these sentence shapes, in this order when combined: location, NPC, turn-ins, accepts.

| Action | Pattern |
| --- | --- |
| Pick up | `Talk to [FRIENDLY]NPC[/]. Accept [QUEST]Quest[/].` |
| Turn in | `Talk to [FRIENDLY]NPC[/]. Turn in [QUEST]Quest[/].` |
| Turn in and pick up | `Talk to [FRIENDLY]NPC[/]. Turn in [QUEST]A[/]. Accept [QUEST]B[/].` |
| Several quests | `Turn in [QUEST]A[/], [QUEST]B[/], and [QUEST]C[/].` (Oxford comma) |
| Kill | `Kill [ENEMY]Mobs[/] at Location.` |
| Loot from mobs | `Loot [LOOT]Item[/] from [ENEMY]Mobs[/].` |
| Click object | `Click the [PICK]Object[/].` |
| Use item | `Use the [LOOT]Item[/] at Location.` |
| Escort | `Talk to [FRIENDLY]NPC[/]. Accept [QUEST]Quest[/]. Escort her to Location.` |
| Travel | `Travel to Location.` or `Fly to Hub.` or `Hearth to Town.` |
| Flight path | `Talk to [FRIENDLY]NPC[/]. Get the Hub flight path.` |
| Hearth | `Set your Hearthstone to Town.` |
| Optional | `[WARN]Optional group:[/] Accept [QUEST]Quest[/] ...` |

Do not write "until [QUEST]… is finished" (or "done" / "complete"). The step already advances when the objectives are done. Name the mobs and, if useful, the place.

Do not write "for [QUEST]Quest[/]" (or "for QuestName" without the tag). The player already sees the quest by mousing over or clicking the step. Name the action, target, and place; leave the quest name to Accept/Turn in lines and to the step's quest link.

Do not write "Accept [QUEST]… if you do not have it" (or "them", "if you haven't picked it up", and similar). Quest-gated Accept steps already skip when the player already has the quest or finished it. Just say Accept.

A short location lead-in is allowed only when the player is arriving somewhere new: `In the Charred Vale, kill ...`, `At Thorn Hill, loot ...`. Do not restate the place the player is already in from the previous step or travel pin (`In Windshear Crag, ...` right after talking to Ziz in that crag). Prefer `Return to Location` when they left and come back.

### 7.3 Details lines

Details are the objective tracker under the headline. Keep them short and structured so the live progress readout ("2/5 Intact Raptor Horn") lines up with them.

| Detail type | Format | Example |
| --- | --- | --- |
| Kill count | `[ENEMY]Singular Name[/] (N)` | `"[ENEMY]Deepmoss Creeper[/] (10)"` |
| Loot count | `[LOOT]Singular Name[/] (N)` | `"[LOOT]Gaea Seed[/] (10)"` |
| Named kill | `Kill [ENEMY]Name[/]` | `"Kill [ENEMY]Grundig Darkcloud[/]"` |
| Extra turn-in | `Turn in [QUEST]Quest[/]` | `"Turn in [QUEST]Avenge My Village[/]"` |
| Action count | `Verb [LOOT]Item[/] (N)` | `"Plant [LOOT]Gaea Seed[/] (10)"` |

Detail rules:

- No trailing period.
- No more than six lines. The tracker drops the rest.
- Every quest objective in an `objectives` step gets its own count line.
- Every turn-in on an `accepted` step that also turns in quests gets a `Turn in` line.
- Do not repeat the headline as a detail.
- Never put `Talk to` or `Speak with` in `details`. Those belong only in `text`. Prefer one sentence that names the NPC first: `Talk to [FRIENDLY]Lar[/] in Sen'jin. Turn in [QUEST]X[/].` not `Return to Sen'jin. Talk to Lar. Turn in X.`
- Do not add an `NPC: [FRIENDLY]Name[/]` line when that NPC is already named in `text`. The headline is enough. Only use an NPC detail when the giver or turn-in is not in the headline (rare).

### 7.4 Notes

`note` is a single optional hint for things a player cannot see from the headline: a rare spawn, a patrol, a trap, a faction split. If there is nothing like that to say, leave `note` out.

- One or two sentences, ending with a period.
- Faction-specific sentences start with `Horde:` or `Alliance:`. The engine drops the other faction's sentence.
- The values `"softcore"` and `"hardcore"` in `note` are read as `mode`. Use `mode` instead.

```lua
note = "Verog only spawns after enough Razormane die. Camp his spawn point if it is contested.",
```

### 7.5 Allowed and not allowed

**Allowed**

| Allowed | Why |
| --- | --- |
| `Talk to [FRIENDLY]Ziz Fizziks[/] in the hut.` | Direct action plus a landmark. |
| `Climb to the platform and kill [ENEMY]Gerenzo Wrenchwhistle[/].` | Tells the player how to reach the target. |
| `Kill [ENEMY]Sons of Cenarius[/] near the lake.` | Action, target, location. |
| `[WARN]Optional escort:[/] Talk to [FRIENDLY]Gilthares Firebough[/].` | Optional content flagged with the `WARN` prefix. |
| `Return to Windshear around level 20.` | A concrete level gate. |
| `note = "Horde: Fly from the Crossroads. Alliance: Fly from Ratchet."` | Faction split that the engine filters per player. |

**Not allowed**

| Not allowed | Problem | Write instead |
| --- | --- | --- |
| `Grab the quest from Makaba if needed.` | "if needed" and similar hedges. The guide already skips steps that do not apply. | `Talk to [FRIENDLY]Makaba Flathoof[/]. Accept [QUEST]Avenge My Village[/].` |
| `Accept [QUEST]Quest[/] if you do not have it.`, `... if you do not have them.`, `... if you haven't picked it up.` | Redundant. Quest-gated Accept steps already skip when the player has the quest (or finished it). | `Accept [QUEST]Quest[/].` |
| `You may want to`, `if you want`, `feel free to`, `consider`, `optionally` | Suggestions instead of instructions. | State the action, or mark it `[WARN]Optional:[/]`. |
| `Skip if you cannot find them.`, `Skip freely.`, `Skip if you do not have the quest.` | Skip advice. Players can always skip, and quest-gated steps skip themselves. | Delete it. |
| `Press Next when done.`, `Click Next to continue.` | UI instructions. The engine strips them. | Delete it. |
| `Accept quest 6548.`, `Guide ID: horde-barrens-16-20` | Raw ids. The engine strips them and leaves broken sentences. | Use the quest name in a `[QUEST]` tag. |
| `Kill [ENEMY]Grellkin[/] for [LOOT]Fel Moss[/].` when details already list `[LOOT]Fel Moss[/] (8)` | Restates the objective that the details show. | `Kill [ENEMY]Grellkin[/] at the lake.` |
| `Kill [ENEMY]Mottled Boars[/] until [QUEST]Cutting Teeth[/] is finished.` | "Until the quest is finished" is obvious; the step already waits on objectives. | `Kill [ENEMY]Mottled Boars[/].` |
| `Kill [ENEMY]Bloodfury Harpies[/] for [QUEST]Harpies Threaten[/].` | "For [quest]" restates the step link; the player can mouse over or click the step. | `Kill [ENEMY]Bloodfury Harpies[/].` |
| `Talk to [FRIENDLY]Wiley[/] upstairs for [QUEST]The Defias Brotherhood[/].` | Same "for [quest]" filler on an accept. | `Talk to [FRIENDLY]Wiley[/] upstairs. Accept [QUEST]The Defias Brotherhood[/].` |
| `Destroy the [LOOT]Manual[/].`, `Delete these items.` | Inventory cleanup steps. | Remove the step. |
| `Turn in Avenge My Village and get the next one.` | Vague follow-up wording. | Name the follow-up quest. |
| `In Windshear Crag, kill [ENEMY]Venture Co. Loggers[/].` right after talking to Ziz there | Restates a place the player already knows. | `Kill [ENEMY]Venture Co. Loggers[/].` |
| `Go kill some harpies over there.` | No target name or location. | `In the Charred Vale, kill [ENEMY]Bloodfury Harpies[/].` |
| `This quest is kind of annoying, so...` | Opinion and filler. | Delete it. |
| Second person chatter (`You'll love this area`, `Good luck!`) | Not an instruction. | Delete it. |
| Em dashes (`Kill boars - then return`) and arrows (`A -> B`) | House style. | Use a period or comma. |
| `[Warrior] Train Battle Shout.` | Leading bracket is parsed as a filter. | `classes = { "Warrior" }` and plain `text`. |

### 7.6 Punctuation and style

- End every `text` and `note` sentence with a period. Details have no period.
- Use straight quotes and apostrophes (`'`), never curly quotes.
- Spell out "and" in lists. Use the Oxford comma.
- Numbers as digits: `Kill 8 [ENEMY]Ragefire Troggs[/]`, `level 20`.
- Directions in lowercase: `north of`, `southeast of`.
- No em dashes, en dashes as punctuation, or ellipses.

---

## 8. Filters

Use filters so each player sees only their own steps.

```lua
{
    races = { "Orc", "Troll" },
    text = "Talk to [FRIENDLY]Takrin Pathseeker[/] on the Durotar road. Accept [QUEST]Conscript of the Horde[/].",
    quest = 840,
    when = "accepted",
    map = 1411, x = 50.8, y = 43.6,
},
{
    faction = "Alliance",
    text = "Travel to Stormwind. Turn in [QUEST]The Unsent Letter[/] at [FRIENDLY]Baros Alexston[/].",
    map = 1453, x = 57.7, y = 47.9,
},
{
    mode = "softcore",
    text = "Follow the road into Feralas. Talk to [FRIENDLY]Shyn[/]. Get the Camp Mojache flight path.",
    map = 1444, x = 75.5, y = 44.3,
},
{
    minLevel = 8,
    text = "Talk to [FRIENDLY]Orgnil Soulscar[/]. Accept [QUEST]A Missing Hand[/].",
    quest = 99048,
    when = "accepted",
    map = 1411, x = 52.2, y = 43.2,
},
```

- `classes` and `races` show the step only to those players.
- `excludeClasses` and `excludeRaces` hide the step from those players.
- `minLevel` / `maxLevel` skip the step outside that character level. Put the same gate on every step in an optional chain so underleveled players are not parked on the follow-ups.
- Do not write "Optional at level 8+" or "At level 10+" in `text` when `minLevel` already gates the step.
- Do not start text with "Warriors:" or "Orcs and Trolls:" when the filter already limits it. The filter does the targeting.
- Do not use `mode = "hardcore"` for steps that are only less safe. Use it for steps that hardcore players must not do (deathskips, risky elites).

---

## 9. Canonical step order for a quest hub

1. Travel step into the hub (`when = "travel"`).
2. Flight path pickup.
3. Hearthstone set, if the guide returns here.
4. Turn-ins, each combined with their follow-up accept.
5. Remaining accepts.
6. Objective steps in route order, with stickies placed directly before the steps they overlap.
7. Return turn-ins.
8. Hand-off step with `guide = "<next-id>"`.

---

## 10. Review checklist

Run through every item. Agents should report any failed item instead of silently fixing unrelated content.

**Structure**

- [ ] File is in `Guides/Forever/Curated/`, named `*_Curated.lua`, and listed in `Waynotes.toc`.
- [ ] `id` is unique and follows `<faction>-<zone>-<min>-<max>`.
- [ ] `forever = true` and `listed = true` are set (or `listed = false` on purpose).
- [ ] `minLevel` and `maxLevel` match `name`.
- [ ] `next` and every step `guide` value point at a guide that is loaded.
- [ ] The file loads in game with no Lua errors (watch for missing commas and unbalanced braces).

**Steps**

- [ ] Every step that accepts, turns in, or completes a quest has `quest` or `quests` and the correct `when`.
- [ ] Turn-in-plus-accept steps use the accepted quest id with `when = "accepted"` and list turn-ins in `details`.
- [ ] Every objective step has a count line per objective in `details`.
- [ ] No step is gated on a quest that is only accepted by a later step. The guide cannot advance past such a step on its own.
- [ ] Zone transitions and "go here" steps use `when = "travel"` with no quest.
- [ ] Level / XP grind camps use `when = "grind"` with `level` (and `xp` when not a clean ding).
- [ ] Manual steps are only for actions the game cannot detect.
- [ ] Sticky steps are `objectives` steps and sit within about 750 yards of the steps that follow them.
- [ ] `pins` entries use `note` or `label`, never `text`.

**Coordinates**

- [ ] `python Data/audit_curated_coords.py <file>` reports no failures, or each failure is explained.
- [ ] Objective pins point at the mobs or objects, not the quest giver.

**Verbiage**

- [ ] Every NPC, mob, quest, item, and object name is color tagged.
- [ ] No "if needed", "if you do not have it/them", "skip", "optional" (outside a `[WARN]` prefix), "Press Next", raw ids, or cleanup steps.
- [ ] No headline repeats the loot or kill target that the details already count.
- [ ] No "until [QUEST]… is finished/done/complete" (or similar) in kill or loot headlines.
- [ ] No "for [QUEST]…" (or untagged "for QuestName") in step text or details; quest names belong on Accept/Turn in lines only.
- [ ] No `NPC:` detail when that NPC is already named in `text`.
- [ ] No `Talk to` or `Speak with` lines in `details`.
- [ ] Sentences end with periods; details do not.
- [ ] No em dashes, arrows, or curly quotes.

**Build**

- [ ] The default build task (Export Waynotes zip, then Deploy) succeeds.
