local _, ns = ...

-- Curated Forever secondary professions 1-300.
-- ForeverDB client routes. Horde Cooking uses Dig Rat Stew where it saves mats.
-- Press Next when you reach the listed skill.
-- Trainer/zone tips use Horde: / Alliance: labels (filtered to your faction).

ns.RegisterGuide({
    id = "profession-cooking-1-300",
    name = "Cooking 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            faction = "Horde",
            text = "Train |cRB_LOOT_Cooking|r at a fire or stove. Buy Mild Spices and Hot Spices from cooking suppliers.",
            note = "Horde: Cook Torka (Durotar), Pyall Silentstride (Mulgore), Eunice Burch (Undercity), Zamja (Orgrimmar).",
            map = 1454,
            x = 57.4,
            y = 53.9,
        },
        {
            faction = "Alliance",
            text = "Train |cRB_LOOT_Cooking|r at a fire or stove. Buy Mild Spices and Hot Spices from cooking suppliers.",
            note = "Alliance: Tomas (Elwynn), Stephen Ryback (Stormwind), Daryl Riknussun (Ironforge), Alegorn (Darnassus).",
            map = 1453,
            x = 78.2,
            y = 53.0,
        },
        {
            text = "Skill 1-65: craft |cRB_LOOT_Charred Wolf Meat|r (~71). 1 Stringy Wolf Meat each.",
            note = "Learned automatically. Train Journeyman at 50 (level 10).",
        },
        {
            text = "Skill 65-90: craft |cRB_LOOT_Coyote Steak|r (~40 toward 103 if not doing Dig Rat). 1 Coyote Meat each.",
            note = "Horde: skip ahead with Dig Rat Stew when you can. Alliance: stay on Coyote Steak longer.",
        },
        {
            faction = "Horde",
            text = "Skill ~90-167: craft |cRB_LOOT_Dig Rat Stew|r (~138). 1 Dig Rat each.",
            note = "Recipe from the Dig Rat Stew quest (Gruel in Bael Modan / The Barrens). Excellent cheap stretch.",
            map = 1413,
            x = 47.0,
            y = 85.0,
        },
        {
            faction = "Horde",
            text = "Skill 167-190: craft |cRB_LOOT_Hot Lion Chops|r (~27). 1 Lion Meat, 1 Hot Spices each.",
            note = "Recipe sold by Zargh (Crossroads) or from Elixir of Pain.",
            map = 1413,
            x = 52.6,
            y = 29.9,
        },
        {
            faction = "Alliance",
            text = "Skill ~90-150: craft |cRB_LOOT_Cooked Crab Claw|r, then |cRB_LOOT_Curiously Tasty Omelet|r.",
            note = "Train Expert Cooking at 125 (level 20) via the Expert Cookbook quest.",
        },
        {
            faction = "Horde",
            text = "If Dig Rat did not carry you past mid game: |cRB_LOOT_Cooked Crab Claw|r to ~150, then |cRB_LOOT_Curiously Tasty Omelet|r.",
            note = "Train Expert Cooking at 125 (level 20) via the Expert Cookbook quest. Skip if Dig Rat already carried you past this.",
        },
        {
            text = "Skill ~187-233: craft |cRB_LOOT_Jungle Stew|r (~52). 1 Tiger Meat, 1 Refreshing Spring Water, 2 Shiny Red Apple each.",
            note = "Recipe sold by Corporal Bluth (Rebel Camp, Stranglethorn). Train Artisan Cooking at 200 (level 35).",
            map = 1434,
            x = 38.0,
            y = 3.0,
        },
        {
            text = "Skill 233-272: craft |cRB_LOOT_Spiced Chili Crab|r (~40). 1 Tender Crab Meat, 2 Hot Spices each.",
            note = "Horde: check cooking vendors or AH. Alliance: recipe sold by Kriggon Talsone (Westfall).",
        },
        {
            text = "Skill 272-300: craft |cRB_LOOT_Poached Sunscale Salmon|r (~29). 1 Raw Sunscale Salmon each.",
            note = "Recipe sold by Gikkix (Steamwheedle Port, Tanaris). Fish them with high Fishing skill.",
            map = 1446,
            x = 66.6,
            y = 22.1,
        },
    },
})

ns.RegisterGuide({
    id = "profession-first-aid-1-300",
    name = "First Aid 1-300",
    group = "Professions",
    forever = true,
    listed = true,
    minLevel = 1,
    maxLevel = 60,
    steps = {
        {
            faction = "Horde",
            text = "Train |cRB_LOOT_First Aid|r. Farm cloth while questing.",
            note = "Horde: Arnok (Orgrimmar), Pand Stonebinder (Thunder Bluff), Mary Edras (Undercity).",
            details = {
                "Forever moves some healing potions onto First Aid. Bandages remain the leveling path.",
            },
            map = 1454,
            x = 34.0,
            y = 84.5,
        },
        {
            faction = "Alliance",
            text = "Train |cRB_LOOT_First Aid|r. Farm cloth while questing.",
            note = "Alliance: Michelle Belle (Elwynn), Shaina Fuller (Stormwind), Nissa Firestone (Ironforge), Dannelor (Darnassus).",
            details = {
                "Forever moves some healing potions onto First Aid. Bandages remain the leveling path.",
            },
            map = 1453,
            x = 52.9,
            y = 44.8,
        },
        {
            text = "Skill 1-41: craft |cRB_LOOT_Linen Bandage|r (~42). 1 Linen Cloth each.",
        },
        {
            text = "Skill 41-80: craft |cRB_LOOT_Heavy Linen Bandage|r (~54). 2 Linen Cloth each.",
            note = "Train Journeyman First Aid at 50 (level 10).",
        },
        {
            text = "Skill 80-115: craft |cRB_LOOT_Wool Bandage|r (~48). 1 Wool Cloth each.",
        },
        {
            text = "Skill 115-150: craft |cRB_LOOT_Heavy Wool Bandage|r (~48). 2 Wool Cloth each.",
            note = "Train Expert First Aid at 125 (level 20) with the Expert First Aid book / quest.",
        },
        {
            text = "Skill 150-180: craft |cRB_LOOT_Silk Bandage|r (~41). 1 Silk Cloth each.",
        },
        {
            text = "Skill 180-210: craft |cRB_LOOT_Heavy Silk Bandage|r (~41). 2 Silk Cloth each.",
            note = "Horde: manual sold by Balai Lok'Wein (Dustwallow). Alliance: manual sold by Deneb Walker (Arathi).",
            map = 1445,
            x = 36.0,
            y = 30.0,
        },
        {
            text = "Skill 210-260: craft |cRB_LOOT_Mageweave Bandage|r (~105). 1 Mageweave Cloth each.",
            note = "Train Artisan First Aid at 200 (level 35). Same vendors sell the Mageweave manual.",
        },
        {
            text = "Skill 260-300: craft |cRB_LOOT_Runecloth Bandage|r (~65). 1 Runecloth each.",
            note = "Horde: Doctor Gregory Victor (Arathi, Hammerfall). Alliance: Doctor Gustaf VanHowzen (Theramore).",
        },
    },
})
