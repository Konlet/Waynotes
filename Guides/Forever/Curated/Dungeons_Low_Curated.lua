local _, ns = ...

-- Curated low-level dungeon guides for Forever.
-- dungeon = instance name so Waynotes prompts to load them on enter.
-- Shared steps are the route. faction on a step hides it from the other side,
-- so quest instructions swap automatically.
-- Outdoor steps carry Era UiMap pins (map/x/y) so the arrow and travel
-- recommendations (flight, boat, zeppelin) can route between hubs.

ns.RegisterGuide({
    id = "dungeon-ragefire-chasm",
    name = "Ragefire Chasm",
    group = "Dungeons",
    faction = "Horde",
    forever = true,
    listed = true,
    dungeon = "Ragefire Chasm",
    minLevel = 13,
    maxLevel = 18,
    steps = {
        {
            text = "Travel into the Cleft of Shadow in Orgrimmar. The Ragefire Chasm entrance is the crack in the ground there.",
            map = 1454,
            x = 52.5,
            y = 49.0,
            note = "Bring Testing an Enemy's Strength (Rahauro, Thunder Bluff), Searching for the Lost Satchel (same), Slaying the Beast (Neeru Fireblade), Hidden Enemies (Thrall), and The Power to Destroy (Varimathras) if you picked them up.",
        },
        {
            text = "Enter Ragefire Chasm with your group.",
            map = 1454,
            x = 52.5,
            y = 49.0,
        },
        {
            text = "Just inside, talk to [FRIENDLY]Maur Grimtotem[/] for [QUEST]Searching for the Lost Satchel[/]. Turn it in and accept [QUEST]Returning the Lost Satchel[/].",
            note = "Skip if you do not have the quest.",
        },
        {
            text = "Clear the first trogg tunnel. Kill 8 [ENEMY]Ragefire Troggs[/] and 8 [ENEMY]Ragefire Shaman[/] for [QUEST]Testing an Enemy's Strength[/] while you move. At the end, crowd-control one of [ENEMY]Oggleflint[/]'s guards if you can, kill the adds, then kill [ENEMY]Oggleflint[/]. Keep him faced away from the group so Cleave does not hit everyone.",
        },
        {
            text = "Cross to the lava platform and kill [ENEMY]Taragaman the Hungerer[/]. Loot [LOOT]Taragaman the Hungerer's Heart[/] for [QUEST]Slaying the Beast[/]. The tank should stay off the platform edge so Uppercut does not knock them into the lava. Healers and damage stay back from Fire Nova.",
        },
        {
            text = "Continue to [ENEMY]Jergosh the Invoker[/]. Crowd-control one guard, kill the adds, then kill Jergosh. This is one of the two bosses for [QUEST]Hidden Enemies[/]. Loot [LOOT]Spells of Shadow[/] and [LOOT]Incantations from the Nether[/] from Searing Blade cultists for [QUEST]The Power to Destroy[/] as you clear this wing.",
        },
        {
            text = "In the last room, pull and kill the [ENEMY]Searing Blade Cultist[/] on the right by itself. Crowd-control the second cultist, then kill [ENEMY]Bazzalan[/]. That finishes the boss kills for [QUEST]Hidden Enemies[/].",
        },
        {
            text = "Leave Ragefire Chasm. Talk to [FRIENDLY]Neeru Fireblade[/] in the Cleft of Shadow. Turn in [QUEST]Slaying the Beast[/], then follow any [QUEST]Hidden Enemies[/] steps through Neeru if you are on that chain.",
            map = 1454,
            x = 49.5,
            y = 50.6,
        },
        {
            text = "Travel to [FRIENDLY]Thrall[/] in Grommash Hold. Turn in [QUEST]Hidden Enemies[/] and finish that chain.",
            map = 1454,
            x = 31.7,
            y = 37.8,
        },
        {
            text = "Travel to Undercity. Talk to [FRIENDLY]Varimathras[/] in the Royal Quarter. Turn in [QUEST]The Power to Destroy[/].",
            map = 1458,
            x = 56.3,
            y = 92.2,
        },
        {
            text = "Travel to Thunder Bluff's Elder Rise. Talk to [FRIENDLY]Rahauro[/]. Turn in [QUEST]Returning the Lost Satchel[/] and [QUEST]Testing an Enemy's Strength[/].",
            map = 1456,
            x = 70.5,
            y = 31.8,
        },
    },
})

ns.RegisterGuide({
    id = "dungeon-wailing-caverns",
    name = "Wailing Caverns",
    group = "Dungeons",
    forever = true,
    listed = true,
    dungeon = "Wailing Caverns",
    minLevel = 15,
    maxLevel = 25,
    steps = {
        {
            text = "Travel to the Wailing Caverns cave in the Barrens, above the Lushwater Oasis.",
            map = 1413,
            x = 45.9,
            y = 36.2,
        },
        {
            text = "Talk to [FRIENDLY]Nalpak[/]. Accept [QUEST]Deviate Hides[/] (20 [LOOT]Deviate Hides[/]). Talk to [FRIENDLY]Ebru[/]. Accept [QUEST]Deviate Eradication[/] (7 [ENEMY]Deviate Ravagers[/], 7 [ENEMY]Deviate Vipers[/], 7 [ENEMY]Deviate Shamblers[/], 7 [ENEMY]Deviate Dreadfangs[/]).",
            map = 1413,
            x = 46.0,
            y = 35.7,
        },
        {
            text = "Follow the tunnels deeper. Kill [ENEMY]Mad Magglish[/] and loot [LOOT]99-Year-Old Port[/] for [QUEST]Trouble at the Docks[/] from [FRIENDLY]Crane Operator Bigglefuzz[/] in Ratchet. He paces the side tunnels before the instance portal.",
            map = 1413,
            x = 45.7,
            y = 33.6,
            note = "Skip if you are not on that quest or he is not up.",
        },
        {
            faction = "Horde",
            text = "Before you zone in, make sure you also have [QUEST]Leaders of the Fang[/] from [FRIENDLY]Nara Wildmane[/] in Thunder Bluff, [QUEST]Serpentbloom[/] from [FRIENDLY]Apothecary Zamah[/], and [QUEST]Smart Drinks[/] from [FRIENDLY]Mebok Mizzyrix[/] in Ratchet.",
            map = 1413,
            x = 45.9,
            y = 36.3,
        },
        {
            faction = "Alliance",
            text = "Before you zone in, make sure you also have [QUEST]Smart Drinks[/] from [FRIENDLY]Mebok Mizzyrix[/] in Ratchet. [QUEST]Deviate Hides[/] and [QUEST]Deviate Eradication[/] are the cave pickups you just took.",
            map = 1413,
            x = 45.9,
            y = 36.3,
        },
        {
            text = "Enter the Wailing Caverns instance with your group. Loot [LOOT]Deviate Hides[/] from deviate beasts the whole run. Loot [PICK]Serpentbloom[/] off the ground for [QUEST]Serpentbloom[/]. Kill [ENEMY]Ectoplasms[/] for 6 [LOOT]Wailing Essence[/] for [QUEST]Smart Drinks[/].",
            map = 1413,
            x = 45.9,
            y = 36.3,
        },
        {
            text = "Optional: kill [ENEMY]Kresh[/], the large turtle, if your group wants him. He has no special abilities.",
            note = "Skip if the group is skipping him.",
        },
        {
            text = "Kill [ENEMY]Lady Anacondra[/] in the first fang chamber. Interrupt Sleep. Loot the [LOOT]Gem of Anacondra[/] for [QUEST]Leaders of the Fang[/]. [ENEMY]Deviate Ravagers[/] for [QUEST]Deviate Eradication[/] are in this wing.",
        },
        {
            text = "Kill the three [ENEMY]Deviate Pythons[/] with [ENEMY]Lord Cobrahn[/] before you focus him. Interrupt Sleep. Loot the [LOOT]Gem of Cobrahn[/] for [QUEST]Leaders of the Fang[/]. [ENEMY]Deviate Vipers[/] are in this wing.",
        },
        {
            text = "Optional: in the Winding Chasm, before Lord Pythas, kill the [ENEMY]Deviate Faerie Dragon[/] if it is up.",
            note = "Rare. Skip if it is not spawned.",
        },
        {
            text = "Pull [ENEMY]Lord Pythas[/]. Crowd-control the Druid of the Fang, kill the other add, then kill Pythas. Interrupt Sleep. Loot the [LOOT]Gem of Pythas[/] for [QUEST]Leaders of the Fang[/].",
        },
        {
            text = "Optional: kill [ENEMY]Skum[/]. Spread melee apart so Chained Bolt does not jump through the group.",
            note = "Skip if the group is skipping him.",
        },
        {
            text = "Kill [ENEMY]Lord Serpentis[/]. Interrupt Sleep. Loot the [LOOT]Gem of Serpentis[/] to finish the four gems for [QUEST]Leaders of the Fang[/]. [ENEMY]Deviate Dreadfangs[/] are in the Winding Chasm.",
        },
        {
            text = "Kill [ENEMY]Verdan the Everliving[/] in the Crag of the Everliving. Grasping Vines roots and knocks down anyone within 10 yards, so the healer should keep the group topped. [ENEMY]Deviate Shamblers[/] for [QUEST]Deviate Eradication[/] are in this wing. Finish any hide, bloom, or essence counts before the escort.",
        },
        {
            text = "Go back to the [FRIENDLY]Disciple of Naralex[/] at the start of the instance. Tell him to let the event begin and escort him to Naralex. Clear the waves at the ritual stone, then kill [ENEMY]Mutanus the Devourer[/]. Ranged damage is safer: Thunderclap hits the tank and nearby melee. Terrify and Naralex's Nightmare stun or sleep people, so keep health high. Loot the [LOOT]Glowing Shard[/] and accept [QUEST]The Glowing Shard[/].",
        },
        {
            text = "Leave the instance and the cave. Turn in [QUEST]Deviate Hides[/] at [FRIENDLY]Nalpak[/] and [QUEST]Deviate Eradication[/] at [FRIENDLY]Ebru[/].",
            map = 1413,
            x = 46.0,
            y = 35.7,
        },
        {
            text = "Travel to Ratchet. Turn in [QUEST]Smart Drinks[/] at [FRIENDLY]Mebok Mizzyrix[/] and [QUEST]Trouble at the Docks[/] at [FRIENDLY]Crane Operator Bigglefuzz[/]. Talk to [FRIENDLY]Sputtervalve[/] about the [LOOT]Glowing Shard[/].",
            map = 1413,
            x = 62.4,
            y = 37.6,
            pins = {
                { x = 62.4, y = 37.6, note = "Mebok Mizzyrix" },
                { x = 63.1, y = 37.6, note = "Crane Operator Bigglefuzz" },
                { x = 63.0, y = 37.2, note = "Sputtervalve" },
            },
        },
        {
            text = "Travel to [FRIENDLY]Falla Sagewind[/] on the rise above the caverns. Turn in the Glowing Shard follow-up.",
            map = 1413,
            x = 48.2,
            y = 32.8,
        },
        {
            faction = "Horde",
            text = "Travel to Thunder Bluff. Turn in [QUEST]Leaders of the Fang[/] at [FRIENDLY]Nara Wildmane[/] on Elder Rise.",
            map = 1456,
            x = 75.7,
            y = 31.6,
        },
        {
            faction = "Horde",
            text = "In the Spirit Rise pools, talk to [FRIENDLY]Apothecary Zamah[/]. Turn in [QUEST]Serpentbloom[/].",
            map = 1456,
            x = 22.8,
            y = 20.9,
        },
        {
            faction = "Horde",
            text = "On Elder Rise, talk to [FRIENDLY]Arch Druid Hamuul Runetotem[/]. Turn in [QUEST]In Nightmares[/].",
            map = 1456,
            x = 78.6,
            y = 28.6,
        },
    },
})

ns.RegisterGuide({
    id = "dungeon-the-deadmines",
    name = "The Deadmines",
    group = "Dungeons",
    forever = true,
    listed = true,
    dungeon = "The Deadmines",
    minLevel = 17,
    maxLevel = 26,
    steps = {
        {
            text = "Travel to Moonbrook in Westfall. The Deadmines entrance is the large mine building on the west side of town.",
            map = 1436,
            x = 42.6,
            y = 71.8,
        },
        {
            faction = "Alliance",
            text = "Before the instance, finish the entrance-mine quests. [QUEST]The Defias Brotherhood[/] escort from the Defias Traitor at Sentinel Hill ends at this mine. Inside the tunnels, kill [ENEMY]Foreman Thistlenettle[/] for [LOOT]Thistlenettle's Badge[/] ([QUEST]Oh Brother...[/]) and loot 4 [LOOT]Miners' Union Cards[/] from the undead miners ([QUEST]Collecting Memories[/]). Also bring [QUEST]Underground Assault[/] from [FRIENDLY]Shoni the Silent[/] in Stormwind and [QUEST]Red Silk Bandanas[/] from [FRIENDLY]Scout Riell[/] at Sentinel Hill.",
            map = 1436,
            x = 41.1,
            y = 80.1,
        },
        {
            text = "Enter the mine building. Drop down the first ledge, follow the tunnel, then drop again to the instance portal. Enter The Deadmines with your group.",
            map = 1436,
            x = 39.6,
            y = 78.1,
            note = "Alliance: Keep killing Defias for 10 Red Silk Bandanas the whole dungeon.",
        },
        {
            text = "In the first goblin room, pull the two [ENEMY]Defias Watchmen[/] off [ENEMY]Rhahk'Zor[/] if you can, or crowd-control one archer. Kill the adds, then kill [ENEMY]Rhahk'Zor[/]. Watch for patrolling elites in the hall behind him.",
        },
        {
            text = "Optional: if [ENEMY]Miner Johnson[/] is up, pick off the non-elite [ENEMY]Defias Miners[/] around him, then kill him.",
            note = "Rare. Skip if he is not spawned.",
        },
        {
            text = "Clear the lumber room, then kill [ENEMY]Sneed's Shredder[/]. Terrify makes you run in fear, so fight with space behind you. When the shredder dies, [ENEMY]Sneed[/] jumps out and disarms the tank. Let the tank pick him up before you damage him.",
            note = "Alliance: Loot Gnoam Sprecklesprocket from the shredder for Underground Assault.",
        },
        {
            text = "Kill [ENEMY]Gilnid[/] at the foundry. A [ENEMY]Goblin Engineer[/] joins the pull. Crowd-control that engineer. If he summons a Remote Controlled Golem, kill the engineer first. The golem is immune to most control.",
        },
        {
            text = "Board the ship. At the plank, [ENEMY]Mr. Smite[/] charges and two stealthed [ENEMY]Defias Blackguards[/] appear. Kill the blackguards before you damage Smite. At about two-thirds and one-third health he stuns the group for several seconds. At one-third he can also stun the tank, so the healer should be ready before those breaks.",
        },
        {
            text = "On the deck, crowd-control the adds beside [ENEMY]Captain Greenskin[/], kill the adds, then kill the captain.",
        },
        {
            text = "In the cabin, two stealthed [ENEMY]Defias Blackguards[/] open on [ENEMY]Edwin VanCleef[/]. Crowd-control and kill them first. At half health he calls two more. Kill those, then finish VanCleef.",
            note = "Alliance: Loot Head of VanCleef for The Defias Brotherhood. If An Unsent Letter drops, accept The Unsent Letter.",
        },
        {
            text = "Optional: drop to the small lower deck and kill [ENEMY]Cookie[/]. Clear the adds below before you jump if the group is low. Interrupt Cookie's Cooking or he heals.",
            note = "Skip if the group is skipping him.",
        },
        {
            faction = "Alliance",
            text = "Leave the mine. Travel to Sentinel Hill. Turn in [QUEST]The Defias Brotherhood[/] at [FRIENDLY]Gryan Stoutmantle[/] and [QUEST]Red Silk Bandanas[/] at [FRIENDLY]Scout Riell[/].",
            map = 1436,
            x = 56.3,
            y = 47.5,
            pins = {
                { x = 56.3, y = 47.5, note = "Gryan Stoutmantle" },
                { x = 56.7, y = 47.4, note = "Scout Riell" },
            },
        },
        {
            faction = "Alliance",
            text = "Travel to Stormwind. Turn in [QUEST]The Unsent Letter[/] at [FRIENDLY]Baros Alexston[/] in Cathedral Square.",
            map = 1453,
            x = 57.7,
            y = 47.9,
        },
        {
            faction = "Alliance",
            text = "Talk to [FRIENDLY]Shoni the Silent[/] in the Dwarven District. Turn in [QUEST]Underground Assault[/].",
            map = 1453,
            x = 62.6,
            y = 34.1,
        },
        {
            faction = "Alliance",
            text = "Talk to [FRIENDLY]Wilder Thistlenettle[/] in the Dwarven District. Turn in [QUEST]Oh Brother. . .[/] and [QUEST]Collecting Memories[/].",
            map = 1453,
            x = 70.3,
            y = 40.8,
        },
        {
            faction = "Horde",
            text = "Leave the mine. The Deadmines clear is done. Head back toward your leveling route.",
            map = 1436,
            x = 42.6,
            y = 71.8,
        },
    },
})

ns.RegisterGuide({
    id = "dungeon-hall-of-thanes",
    name = "Hall of Thanes",
    group = "Dungeons",
    forever = true,
    listed = true,
    dungeon = "Hall of Thanes",
    minLevel = 15,
    maxLevel = 25,
    steps = {
        {
            faction = "Alliance",
            text = "Travel to Ironforge. Go to the High Seat, run down the ramp into Old Ironforge, and stop at the Hall of Thanes door.",
            map = 1455,
            x = 39.1,
            y = 56.2,
            note = "Bring Old Ironforge Incursion from Earthseer Farsen in Dun Morogh (64.9, 58.5).",
        },
        {
            faction = "Horde",
            text = "Travel to Ironforge and down into Old Ironforge. The Hall of Thanes door is at the bottom of that ramp. Move carefully. Ironforge is an Alliance city.",
            map = 1455,
            x = 28.0,
            y = 47.8,
        },
        {
            faction = "Alliance",
            text = "On the way down, talk to [FRIENDLY]Afadra Dunwall[/]. Accept [QUEST]The Restless Dead[/] (15 [ENEMY]Enraged Apparitions[/], 10 [ENEMY]Tormented Souls[/]).",
            map = 1455,
            x = 32.8,
            y = 47.7,
        },
        {
            faction = "Alliance",
            text = "Talk to [FRIENDLY]Thom Filch[/]. Accept [QUEST]Important Heirlooms[/] (8 [LOOT]Dwarven Heirlooms[/] from coffers).",
            map = 1455,
            x = 32.2,
            y = 44.4,
        },
        {
            text = "Enter the Hall of Thanes with your group.",
            map = 1455,
            x = 28.0,
            y = 47.8,
        },
        {
            text = "Talk to the [FRIENDLY]Ghostly Attendant[/] near the entrance. Accept [QUEST]An Ancient Grudge[/].",
        },
        {
            faction = "Alliance",
            text = "As you clear, kill 15 [ENEMY]Enraged Apparitions[/] and 10 [ENEMY]Tormented Souls[/] for [QUEST]The Restless Dead[/]. Open [PICK]Heirloom Coffers[/] for 8 [LOOT]Dwarven Heirlooms[/] for [QUEST]Important Heirlooms[/].",
        },
        {
            text = "Find [ENEMY]Faldrim Anvilmar[/] patrolling Anvilmar's Rest. Clear the trash around his path, then kill him for [QUEST]An Ancient Grudge[/]. Anvilmar's Curse slows the tank's attacks, so threat builds slower than usual. Give the tank a moment before you damage.",
        },
        {
            text = "Kill [ENEMY]Magmatus[/]. Pull him off the [ENEMY]Dark Iron Summoner[/] and kill the summoner first. Magmatus casts Combust on a random player and pulses Fire Nova. Spread so the nova does not hit the whole group.",
        },
        {
            text = "Kill [ENEMY]Plunder[/]. Knockback is the only mechanic. The tank should stand with their back to a wall, and the group should pick that wall before the pull so nobody gets knocked into more trash.",
        },
        {
            text = "Clear the [ENEMY]Dark Iron Looters[/] in the last room, then kill the [ENEMY]Lesser Stone Golems[/] one at a time. Kill [ENEMY]Durgen Dirgehammer[/]. Stun him when he winds up the area Fear. The tank takes extra damage from Rend, so keep them healed.",
            note = "Alliance: Loot Durgen Dirgehammer's Head for Old Ironforge Incursion. If you see the Treaty of Understanding, accept that quest.",
        },
        {
            text = "Return to the [FRIENDLY]Ghostly Attendant[/]. Turn in [QUEST]An Ancient Grudge[/].",
        },
        {
            faction = "Alliance",
            text = "Leave the instance. Turn in [QUEST]Important Heirlooms[/] at [FRIENDLY]Thom Filch[/].",
            map = 1455,
            x = 32.2,
            y = 44.4,
        },
        {
            faction = "Alliance",
            text = "Talk to [FRIENDLY]Afadra Dunwall[/]. Turn in [QUEST]The Restless Dead[/].",
            map = 1455,
            x = 32.8,
            y = 47.7,
        },
        {
            faction = "Alliance",
            text = "Travel up to the High Seat. Talk to [FRIENDLY]King Magni Bronzebeard[/]. Turn in [QUEST]The Treaty of Understanding[/] and [QUEST]Old Ironforge Incursion[/].",
            map = 1455,
            x = 39.1,
            y = 56.2,
        },
        {
            faction = "Horde",
            text = "Leave the Hall of Thanes and get out of Ironforge. The clear is done.",
            map = 1455,
            x = 28.0,
            y = 47.8,
        },
    },
})

ns.RegisterGuide({
    id = "dungeon-ruins-of-lordaeron",
    name = "Ruins of Lordaeron",
    group = "Dungeons",
    forever = true,
    listed = true,
    dungeon = "Ruins of Lordaeron",
    minLevel = 15,
    maxLevel = 20,
    steps = {
        {
            text = "Travel to the Undercity Courtyard. The Ruins of Lordaeron entrance is in the ruins above the city.",
            map = 1458,
            x = 72.3,
            y = 11.4,
        },
        {
            faction = "Horde",
            text = "Pick up before you zone in: [QUEST]The New Plague[/] from [FRIENDLY]Theodore Griffs[/] in the Apothecarium, [QUEST]Light's Justice[/] from [FRIENDLY]Morbin Lightbane[/] near Lady Sylvanas, [QUEST]A Frightened Request[/] from [FRIENDLY]Tabitha Heartweaver[/] in Silverpine, and [QUEST]The Wrath of Rath'mael[/] from [FRIENDLY]Deathguard Kristof[/] on the road outside Undercity.",
            map = 1458,
            pins = {
                { x = 46.3, y = 71.9, note = "Theodore Griffs" },
                { x = 58.1, y = 89.5, note = "Morbin Lightbane" },
            },
        },
        {
            faction = "Horde",
            text = "Outside Undercity on the Tirisfal road, talk to [FRIENDLY]Deathguard Kristof[/] for [QUEST]The Wrath of Rath'mael[/].",
            map = 1420,
            x = 65.3,
            y = 60.2,
            note = "Skip if you already have it or are skipping it.",
        },
        {
            faction = "Horde",
            text = "In Silverpine at the Sepulcher, talk to [FRIENDLY]Tabitha Heartweaver[/] for [QUEST]A Frightened Request[/], then return to the courtyard entrance.",
            map = 1421,
            x = 44.5,
            y = 43.0,
            note = "Skip if you already have it or are skipping it.",
        },
        {
            text = "Enter the Ruins of Lordaeron with your group. After you zone in, go forward through the first street, then down the slope into the lower ruins.",
            map = 1458,
            x = 72.0,
            y = 11.5,
        },
        {
            faction = "Alliance",
            text = "Near the entrance, talk to [FRIENDLY]Captain Truman[/]. Accept [QUEST]Abominable Creatures[/].",
        },
        {
            faction = "Horde",
            text = "Kill undead as you clear and loot 25 [LOOT]Intact Limbs[/] for [QUEST]Light's Justice[/]. Any corpse-type mob in here can drop them.",
        },
        {
            text = "Kill [ENEMY]Witherfang[/]. He patrols just past the entrance, a short way down the first street. Kill his adds before you focus him. Dispel Leech Poison off the tank when it lands.",
            note = "Horde: Loot the Highly Toxic Strain for The New Plague.",
        },
        {
            text = "Follow that same street to the end of the first area and kill [ENEMY]The Baron[/]. His cleave is a full circle, so stay out of melee unless you are the tank. He knocks the tank into the air. The tank should fight with their back to a wall or they will lose threat when they land.",
            note = "Alliance: Loot Head of the Baron for Abominable Creatures. Horde: If Abominable Head drops, accept Unending Torment.",
        },
        {
            text = "From The Baron, cross to the far corner of the map. Click the statue to start [ENEMY]The Abandoned[/]. Three waves spawn, then the boss. Interrupt or stun Drain Life.",
        },
        {
            text = "Along the outer edge of that same side, use the fireplace to summon [ENEMY]Viktor the Vile[/]. Clear three waves, then the boss. Let the tank pick up each wave before you attack. Dispel Leech Poison off the tank.",
        },
        {
            text = "Move back toward the middle of the western ruins and kill [ENEMY]Bjork[/]. He knocks the tank back. Fight him with the tank's back to a wall.",
        },
        {
            text = "Still on that side, closer to the center, kill [ENEMY]Rath'mael[/]. Interrupt or stun Flamestrike. He also pulses damage on anyone in melee for the whole fight, so ranged should stay out.",
            note = "Horde: This finishes The Wrath of Rath'mael. In the graveyard beside him, investigate the disappearance for A Frightened Request.",
        },
        {
            text = "Optional: search tower bases, ramparts, and crypts for a [LOOT]Crest of Lordaeron[/]. If it starts a quest, accept it.",
            note = "Skip if you do not find one.",
        },
        {
            faction = "Alliance",
            text = "Return to [FRIENDLY]Captain Truman[/] near the entrance and turn in [QUEST]Abominable Creatures[/]. If you looted a [LOOT]Bloodied Insignia[/] or a [LOOT]Blood-Stained Letter[/], accept those quests before you leave.",
        },
        {
            faction = "Horde",
            text = "Leave the ruins. Travel to [FRIENDLY]Deathguard Kristof[/] on the Tirisfal road. Turn in [QUEST]The Wrath of Rath'mael[/].",
            map = 1420,
            x = 65.3,
            y = 60.2,
        },
        {
            faction = "Horde",
            text = "Travel into Undercity. Talk to [FRIENDLY]Morbin Lightbane[/] near Lady Sylvanas. Turn in [QUEST]Light's Justice[/].",
            map = 1458,
            x = 58.1,
            y = 89.5,
        },
        {
            faction = "Horde",
            text = "In the Apothecarium, talk to [FRIENDLY]Theodore Griffs[/]. Turn in [QUEST]The New Plague[/].",
            map = 1458,
            x = 46.3,
            y = 71.9,
        },
        {
            faction = "Horde",
            text = "Turn in [QUEST]Unending Torment[/] at [FRIENDLY]Master Apothecary Faranell[/], then the abomination in the next room, then Faranell again.",
            map = 1458,
            x = 48.8,
            y = 69.3,
            pins = {
                { x = 48.8, y = 69.3, note = "Master Apothecary Faranell" },
                { x = 45.9, y = 61.8, note = "Abomination" },
            },
            note = "Skip if you do not have Unending Torment.",
        },
        {
            faction = "Horde",
            text = "Talk to [FRIENDLY]Oran Snakewrithe[/] in Undercity if you found a Crest of Lordaeron.",
            map = 1458,
            x = 73.1,
            y = 32.9,
            note = "Skip if you did not find a crest.",
        },
        {
            faction = "Horde",
            text = "Travel to the Sepulcher in Silverpine. Turn in [QUEST]A Frightened Request[/] at [FRIENDLY]Tabitha Heartweaver[/].",
            map = 1421,
            x = 44.5,
            y = 43.0,
        },
        {
            faction = "Alliance",
            text = "Leave the ruins. Travel to Stormwind. Turn in [QUEST]Bloodied Insignia[/] at [FRIENDLY]General Marcus Jonathan[/].",
            map = 1453,
            x = 69.2,
            y = 82.7,
            note = "Skip if you do not have Bloodied Insignia.",
        },
        {
            faction = "Alliance",
            text = "Turn in the letter chain at [FRIENDLY]Orphan Matron Nightingale[/].",
            map = 1453,
            x = 56.3,
            y = 54.0,
            note = "Skip if you do not have the letter quest.",
        },
        {
            faction = "Alliance",
            text = "In Stormwind Keep, talk to [FRIENDLY]Lady Dena Kennedy[/]. Turn in [QUEST]Crest of Lordaeron[/] if you found the crest.",
            map = 1453,
            x = 68.0,
            y = 28.9,
            note = "Skip if you did not find a crest.",
        },
    },
})
