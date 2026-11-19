#!/usr/bin/env python3
"""Scaffold Forever Alliance curated draft guides from Zygor REFERENCE packs.

Reads:
    Guides/REFERENCE/Zygor/Alliance_01-13_Starters.lua
    Guides/REFERENCE/Zygor/Alliance_13-30.lua
    Guides/REFERENCE/Zygor/Alliance_30-40.lua
    Guides/REFERENCE/Zygor/Alliance_40-50.lua
    Guides/REFERENCE/Zygor/Alliance_50-60.lua

Writes net-new Guides/Forever/Curated/Alliance_<Zone>_Curated.lua files.
Does NOT overwrite Teldrassil, Darkshore, or Redridge curated files.
Patches Darkshore / Redridge next and hand-off links into the new spine.

Night Elf starter and Zygor Darkshore packs are skipped (curated already exists).
Redridge map steps inside composite packs are dropped (curated Redridge kept).

Usage:
    python Data/scaffold_alliance_curated.py
"""
from __future__ import annotations

import importlib.util
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ZYGOR = ROOT / "Guides" / "REFERENCE" / "Zygor"
CURATED = ROOT / "Guides" / "Forever" / "Curated"

# Load Horde scaffold helpers (parser, convert_step, emit_step, etc.).
_spec = importlib.util.spec_from_file_location(
    "scaffold_horde_late_curated", ROOT / "Data" / "scaffold_horde_late_curated.py"
)
assert _spec and _spec.loader
sh = importlib.util.module_from_spec(_spec)
sys.modules["scaffold_horde_late_curated"] = sh
_spec.loader.exec_module(sh)

SOURCES = [
    "Alliance_01-13_Starters.lua",
    "Alliance_13-30.lua",
    "Alliance_30-40.lua",
    "Alliance_40-50.lua",
    "Alliance_50-60.lua",
]

# Existing curated ids we must not regenerate, but may link to.
EXISTING = {
    "alliance-teldrassil-1-6",
    "alliance-teldrassil-6-12-curated",
    "alliance-darkshore-11-16",
    "alliance-darkshore-16-20",
    "alliance-redridge-19-21",
}


@dataclass
class OutGuide:
    zone: str
    lo: int
    hi: int
    maps: frozenset[int]
    races: tuple[str, ...] | None = None
    starter: bool = False
    steps: list[dict] = field(default_factory=list)

    @property
    def gid(self) -> str:
        return f"alliance-{ZONES[self.zone]['slug']}-{self.lo}-{self.hi}"

    @property
    def name(self) -> str:
        band = f"{self.lo}" if self.lo == self.hi else f"{self.lo}-{self.hi}"
        return f"{band} {ZONES[self.zone]['title']}"


ZONES = {
    "elwynn": {
        "slug": "elwynn",
        "title": "Elwynn Forest",
        "file": "Alliance_Elwynn_Curated.lua",
        "header": [
            "Alliance Elwynn Forest.",
            "Human starter: Northshire Abbey through Goldshire and the Elwynn loop to about 13.",
            "Continues to Westfall 13-15.",
        ],
    },
    "dun-morogh": {
        "slug": "dun-morogh",
        "title": "Dun Morogh",
        "file": "Alliance_DunMorogh_Curated.lua",
        "header": [
            "Alliance Dun Morogh.",
            "Dwarf and Gnome starter: Coldridge Valley through Kharanos and the Dun Morogh loop.",
            "Continues to Westfall 13-15.",
        ],
    },
    "westfall": {
        "slug": "westfall",
        "title": "Westfall",
        "file": "Alliance_Westfall_Curated.lua",
        "header": [
            "Alliance Westfall.",
            "13-15 Sentinel Hill hub and Defias farmland, then a short 19-20 return after Loch Modan.",
            "Human and Dwarf/Gnome starters arrive at 13. Night Elves usually skip 13-15.",
        ],
    },
    "loch-modan": {
        "slug": "loch-modan",
        "title": "Loch Modan",
        "file": "Alliance_LochModan_Curated.lua",
        "header": [
            "Alliance Loch Modan.",
            "Thelsamar hub, Algaz, Ironband dig site, and the mid-loch crocolisk loop around 18-19.",
            "Start after Westfall 13-15, or after curated Darkshore for Night Elves.",
        ],
    },
    "ashenvale": {
        "slug": "ashenvale",
        "title": "Ashenvale",
        "file": "Alliance_Ashenvale_Curated.lua",
        "header": [
            "Alliance Ashenvale.",
            "21-24 Astranaar and Maestra's Post with the Stonetalon hand-off, then 29-30 Forest Song.",
            "Start after curated Redridge 19-21.",
        ],
    },
    "stonetalon": {
        "slug": "stonetalon",
        "title": "Stonetalon Mountains",
        "file": "Alliance_Stonetalon_Curated.lua",
        "header": [
            "Alliance Stonetalon Mountains.",
            "Stonetalon Peak hub interleaved with the Ashenvale 21-24 pass.",
        ],
    },
    "wetlands": {
        "slug": "wetlands",
        "title": "Wetlands",
        "file": "Alliance_Wetlands_Curated.lua",
        "header": [
            "Alliance Wetlands.",
            "Menethil Harbor hub: 24-25 opener and 27-29 return through the raptors and dragonmaw.",
        ],
    },
    "duskwood": {
        "slug": "duskwood",
        "title": "Duskwood",
        "file": "Alliance_Duskwood_Curated.lua",
        "header": [
            "Alliance Duskwood.",
            "Darkshire hub for 25-27 and the 30-32 pass before Stranglethorn Vale.",
            "Redridge return steps from the Zygor pack were dropped; use curated Redridge.",
        ],
    },
    "stranglethorn": {
        "slug": "stranglethorn",
        "title": "Stranglethorn Vale",
        "file": "Alliance_Stranglethorn_Curated.lua",
        "header": [
            "Alliance Stranglethorn Vale.",
            "Nesingwary camp, Booty Bay, Bloodsail and the late Green Hills / Kurzen legs.",
        ],
    },
    "hillsbrad": {
        "slug": "hillsbrad",
        "title": "Hillsbrad Foothills",
        "file": "Alliance_Hillsbrad_Curated.lua",
        "header": [
            "Alliance Hillsbrad Foothills.",
            "Southshore hub around 32-33 with the Arathi Highlands hand-off.",
        ],
    },
    "arathi": {
        "slug": "arathi",
        "title": "Arathi Highlands",
        "file": "Alliance_Arathi_Curated.lua",
        "header": [
            "Alliance Arathi Highlands.",
            "Refuge Pointe hub for 32-33 and the 39-40 return with Alterac.",
        ],
    },
    "dustwallow": {
        "slug": "dustwallow",
        "title": "Dustwallow Marsh",
        "file": "Alliance_Dustwallow_Curated.lua",
        "header": [
            "Alliance Dustwallow Marsh.",
            "Theramore hub for 33-34 with Thousand Needles, then the short 40 return.",
        ],
    },
    "thousand-needles": {
        "slug": "thousand-needles",
        "title": "Thousand Needles",
        "file": "Alliance_ThousandNeedles_Curated.lua",
        "header": [
            "Alliance Thousand Needles.",
            "Shimmering Flats and the raceway around 33-34 from the Dustwallow pass.",
        ],
    },
    "desolace": {
        "slug": "desolace",
        "title": "Desolace",
        "file": "Alliance_Desolace_Curated.lua",
        "header": [
            "Alliance Desolace.",
            "Nijel's Point hub for 35-37, then the 40-41 return.",
        ],
    },
    "swamp-of-sorrows": {
        "slug": "swamp-of-sorrows",
        "title": "Swamp of Sorrows",
        "file": "Alliance_SwampOfSorrows_Curated.lua",
        "header": [
            "Alliance Swamp of Sorrows.",
            "38-39 opener and the short 43 return before Tanaris.",
        ],
    },
    "alterac": {
        "slug": "alterac",
        "title": "Alterac Mountains",
        "file": "Alliance_Alterac_Curated.lua",
        "header": [
            "Alliance Alterac Mountains.",
            "39-40 pass interleaved with Arathi Highlands.",
        ],
    },
    "badlands": {
        "slug": "badlands",
        "title": "Badlands",
        "file": "Alliance_Badlands_Curated.lua",
        "header": [
            "Alliance Badlands.",
            "41-42 dig sites, Lotwil, and the Angor Fortress loop.",
        ],
    },
    "tanaris": {
        "slug": "tanaris",
        "title": "Tanaris",
        "file": "Alliance_Tanaris_Curated.lua",
        "header": [
            "Alliance Tanaris.",
            "Gadgetzan hub across 43-44, the Feralas return, 49, and related Wastewander work.",
        ],
    },
    "feralas": {
        "slug": "feralas",
        "title": "Feralas",
        "file": "Alliance_Feralas_Curated.lua",
        "header": [
            "Alliance Feralas.",
            "Feathermoon Stronghold for 44-48 and the 52-53 Azshara-linked return.",
        ],
    },
    "hinterlands": {
        "slug": "hinterlands",
        "title": "The Hinterlands",
        "file": "Alliance_Hinterlands_Curated.lua",
        "header": [
            "Alliance The Hinterlands.",
            "Aerie Peak hub around 48-49.",
        ],
    },
    "un-goro": {
        "slug": "un-goro",
        "title": "Un'Goro Crater",
        "file": "Alliance_UnGoro_Curated.lua",
        "header": [
            "Alliance Un'Goro Crater.",
            "Marshal's Refuge for 49-50 and the 53-54 crystal pylon return.",
        ],
    },
    "searing-gorge": {
        "slug": "searing-gorge",
        "title": "Searing Gorge",
        "file": "Alliance_SearingGorge_Curated.lua",
        "header": [
            "Alliance Searing Gorge.",
            "Thorium Point hub around 50-51.",
        ],
    },
    "blasted-lands": {
        "slug": "blasted-lands",
        "title": "Blasted Lands",
        "file": "Alliance_BlastedLands_Curated.lua",
        "header": [
            "Alliance Blasted Lands.",
            "Nethergarde Keep and the 51 pass with Burning Steppes.",
        ],
    },
    "burning-steppes": {
        "slug": "burning-steppes",
        "title": "Burning Steppes",
        "file": "Alliance_BurningSteppes_Curated.lua",
        "header": [
            "Alliance Burning Steppes.",
            "Morgan's Vigil for 51 and the 56-57 return.",
        ],
    },
    "western-plaguelands": {
        "slug": "western-plaguelands",
        "title": "Western Plaguelands",
        "file": "Alliance_WesternPlaguelands_Curated.lua",
        "header": [
            "Alliance Western Plaguelands.",
            "Chillwind Camp for 51-52 and the 57-58 pass with Eastern Plaguelands.",
        ],
    },
    "eastern-plaguelands": {
        "slug": "eastern-plaguelands",
        "title": "Eastern Plaguelands",
        "file": "Alliance_EasternPlaguelands_Curated.lua",
        "header": [
            "Alliance Eastern Plaguelands.",
            "Light's Hope Chapel hub on the 57-58 pass.",
        ],
    },
    "azshara": {
        "slug": "azshara",
        "title": "Azshara",
        "file": "Alliance_Azshara_Curated.lua",
        "header": [
            "Alliance Azshara.",
            "52 and 52-53 legs interleaved with Felwood and Feralas.",
        ],
    },
    "felwood": {
        "slug": "felwood",
        "title": "Felwood",
        "file": "Alliance_Felwood_Curated.lua",
        "header": [
            "Alliance Felwood.",
            "Talonbranch and Jaedenar work across 52 and 54-56 with Winterspring.",
        ],
    },
    "winterspring": {
        "slug": "winterspring",
        "title": "Winterspring",
        "file": "Alliance_Winterspring_Curated.lua",
        "header": [
            "Alliance Winterspring.",
            "Everlook hub for 54-56 and the 58-59 capstone before Silithus.",
        ],
    },
    "silithus": {
        "slug": "silithus",
        "title": "Silithus",
        "file": "Alliance_Silithus_Curated.lua",
        "header": [
            "Alliance Silithus.",
            "Cenarion Hold leveling closeout for 59-60.",
        ],
    },
}

UI = {
    "elwynn": 1429,
    "dunmorogh": 1426,
    "westfall": 1436,
    "loch": 1432,
    "ashenvale": 1440,
    "stonetalon": 1442,
    "wetlands": 1437,
    "duskwood": 1431,
    "redridge": 1433,
    "stv": 1434,
    "hillsbrad": 1424,
    "arathi": 1417,
    "dustwallow": 1445,
    "needles": 1441,
    "desolace": 1443,
    "sos": 1435,
    "alterac": 1416,
    "badlands": 1418,
    "tanaris": 1446,
    "feralas": 1444,
    "hinterlands": 1425,
    "ungoro": 1449,
    "searing": 1427,
    "blasted": 1419,
    "bsteppes": 1428,
    "wpl": 1422,
    "epl": 1423,
    "azshara": 1447,
    "felwood": 1448,
    "winterspring": 1452,
    "silithus": 1451,
    "darkshore": 1439,
    "teldrassil": 1438,
    "stormwind": 1453,
    "ironforge": 1455,
    "darnassus": 1457,
}


def G(
    zone: str,
    lo: int,
    hi: int,
    *map_keys: str,
    races: tuple[str, ...] | None = None,
    starter: bool = False,
) -> OutGuide:
    maps = frozenset(UI[k] for k in map_keys)
    return OutGuide(zone, lo, hi, maps, races=races, starter=starter)


def build_packs() -> dict[str, tuple[list[OutGuide], set[int]]]:
    """pack id -> (out guides, maps to drop)."""
    return {
        # Starters (Night Elf skipped; Teldrassil curated exists).
        "zygor-alliance-human-starter-1-13": (
            [G("elwynn", 1, 13, "elwynn", "stormwind", races=("Human",), starter=True)],
            set(),
        ),
        "zygor-alliance-dwarf-and-gnome-starter-1-13": (
            [G("dun-morogh", 1, 13, "dunmorogh", "ironforge", races=("Dwarf", "Gnome"), starter=True)],
            set(),
        ),
        # Early
        "zygor-alliance-westfall-13-15": ([G("westfall", 13, 15, "westfall")], set()),
        "zygor-alliance-loch-modan-18-19": ([G("loch-modan", 18, 19, "loch")], set()),
        "zygor-alliance-redridge-and-westfall-19-20": (
            [G("westfall", 19, 20, "westfall")],
            {UI["redridge"]},
        ),
        # Mid
        "zygor-alliance-ashenvale-and-stonetalon-mountains-21-24": (
            [
                G("ashenvale", 21, 24, "ashenvale"),
                G("stonetalon", 21, 24, "stonetalon"),
            ],
            set(),
        ),
        "zygor-alliance-wetlands-24-25": ([G("wetlands", 24, 25, "wetlands")], set()),
        "zygor-alliance-duskwood-and-redridge-mountains-25-27": (
            [G("duskwood", 25, 27, "duskwood")],
            {UI["redridge"]},
        ),
        "zygor-alliance-wetlands-27-29": ([G("wetlands", 27, 29, "wetlands")], set()),
        "zygor-alliance-ashenvale-29-30": ([G("ashenvale", 29, 30, "ashenvale")], set()),
        "zygor-alliance-duskwood-and-stranglethorn-vale-30-32": (
            [
                G("duskwood", 30, 32, "duskwood"),
                G("stranglethorn", 30, 32, "stv"),
            ],
            set(),
        ),
        "zygor-alliance-hillsbrad-foothills-and-arathi-highlands-32-33": (
            [
                G("hillsbrad", 32, 33, "hillsbrad"),
                G("arathi", 32, 33, "arathi"),
            ],
            set(),
        ),
        "zygor-alliance-dustwallow-marsh-and-thousand-needles-33-34": (
            [
                G("dustwallow", 33, 34, "dustwallow"),
                G("thousand-needles", 33, 34, "needles"),
            ],
            set(),
        ),
        "zygor-alliance-stranglethorn-vale-34-35": ([G("stranglethorn", 34, 35, "stv")], set()),
        "zygor-alliance-desolace-35-37": ([G("desolace", 35, 37, "desolace")], set()),
        "zygor-alliance-stranglethorn-vale-37-38": ([G("stranglethorn", 37, 38, "stv")], set()),
        "zygor-alliance-swamp-of-sorrows-38-39": ([G("swamp-of-sorrows", 38, 39, "sos")], set()),
        "zygor-alliance-arathi-highlands-and-alterac-mountains-39-40": (
            [
                G("arathi", 39, 40, "arathi"),
                G("alterac", 39, 40, "alterac"),
            ],
            set(),
        ),
        "zygor-alliance-dustwallow-marsh-40-40": ([G("dustwallow", 40, 40, "dustwallow")], set()),
        "zygor-alliance-desolace-40-41": ([G("desolace", 40, 41, "desolace")], set()),
        "zygor-alliance-badlands-41-42": ([G("badlands", 41, 42, "badlands")], set()),
        "zygor-alliance-stranglethorn-vale-42-43": ([G("stranglethorn", 42, 43, "stv")], set()),
        "zygor-alliance-swamp-of-sorrows-43-43": ([G("swamp-of-sorrows", 43, 43, "sos")], set()),
        "zygor-alliance-tanaris-43-44": ([G("tanaris", 43, 44, "tanaris")], set()),
        "zygor-alliance-feralas-and-tanaris-44-48": (
            [
                G("feralas", 44, 48, "feralas"),
                G("tanaris", 44, 48, "tanaris"),
            ],
            set(),
        ),
        "zygor-alliance-the-hinterlands-48-49": ([G("hinterlands", 48, 49, "hinterlands")], set()),
        "zygor-alliance-tanaris-49-49": ([G("tanaris", 49, 49, "tanaris")], set()),
        "zygor-alliance-un-goro-crater-49-50": ([G("un-goro", 49, 50, "ungoro")], set()),
        "zygor-alliance-stranglethorn-vale-50-50": ([G("stranglethorn", 50, 50, "stv")], set()),
        "zygor-alliance-searing-gorge-50-51": ([G("searing-gorge", 50, 51, "searing")], set()),
        "zygor-alliance-blasted-lands-and-burning-steppes-51-51": (
            [
                G("blasted-lands", 51, 51, "blasted"),
                G("burning-steppes", 51, 51, "bsteppes"),
            ],
            set(),
        ),
        "zygor-alliance-western-plaguelands-51-52": (
            [G("western-plaguelands", 51, 52, "wpl")],
            set(),
        ),
        "zygor-alliance-azshara-and-felwood-52-52": (
            [
                G("azshara", 52, 52, "azshara"),
                G("felwood", 52, 52, "felwood"),
            ],
            set(),
        ),
        "zygor-alliance-feralas-and-azshara-52-53": (
            [
                G("feralas", 52, 53, "feralas"),
                G("azshara", 52, 53, "azshara"),
            ],
            set(),
        ),
        "zygor-alliance-un-goro-crater-53-54": ([G("un-goro", 53, 54, "ungoro")], set()),
        "zygor-alliance-winterspring-and-felwood-54-56": (
            [
                G("winterspring", 54, 56, "winterspring"),
                G("felwood", 54, 56, "felwood"),
            ],
            set(),
        ),
        "zygor-alliance-burning-steppes-56-57": (
            [G("burning-steppes", 56, 57, "bsteppes")],
            set(),
        ),
        "zygor-alliance-western-and-eastern-plaguelands-57-58": (
            [
                G("western-plaguelands", 57, 58, "wpl"),
                G("eastern-plaguelands", 57, 58, "epl"),
            ],
            set(),
        ),
        "zygor-alliance-winterspring-58-59": (
            [G("winterspring", 58, 59, "winterspring")],
            set(),
        ),
        "zygor-alliance-silithus-59-60": ([G("silithus", 59, 60, "silithus")], set()),
    }


# Spine next links. Existing curated Redridge is the early bridge into Ashenvale.
NEXT = {
    "alliance-elwynn-1-13": "alliance-westfall-13-15",
    "alliance-dun-morogh-1-13": "alliance-westfall-13-15",
    "alliance-westfall-13-15": "alliance-loch-modan-18-19",
    "alliance-loch-modan-18-19": "alliance-westfall-19-20",
    "alliance-westfall-19-20": "alliance-redridge-19-21",
    "alliance-ashenvale-21-24": "alliance-stonetalon-21-24",
    "alliance-stonetalon-21-24": "alliance-wetlands-24-25",
    "alliance-wetlands-24-25": "alliance-duskwood-25-27",
    "alliance-duskwood-25-27": "alliance-wetlands-27-29",
    "alliance-wetlands-27-29": "alliance-ashenvale-29-30",
    "alliance-ashenvale-29-30": "alliance-duskwood-30-32",
    "alliance-duskwood-30-32": "alliance-stranglethorn-30-32",
    "alliance-stranglethorn-30-32": "alliance-hillsbrad-32-33",
    "alliance-hillsbrad-32-33": "alliance-arathi-32-33",
    "alliance-arathi-32-33": "alliance-dustwallow-33-34",
    "alliance-dustwallow-33-34": "alliance-thousand-needles-33-34",
    "alliance-thousand-needles-33-34": "alliance-stranglethorn-34-35",
    "alliance-stranglethorn-34-35": "alliance-desolace-35-37",
    "alliance-desolace-35-37": "alliance-stranglethorn-37-38",
    "alliance-stranglethorn-37-38": "alliance-swamp-of-sorrows-38-39",
    "alliance-swamp-of-sorrows-38-39": "alliance-arathi-39-40",
    "alliance-arathi-39-40": "alliance-alterac-39-40",
    "alliance-alterac-39-40": "alliance-dustwallow-40-40",
    "alliance-dustwallow-40-40": "alliance-desolace-40-41",
    "alliance-desolace-40-41": "alliance-badlands-41-42",
    "alliance-badlands-41-42": "alliance-stranglethorn-42-43",
    "alliance-stranglethorn-42-43": "alliance-swamp-of-sorrows-43-43",
    "alliance-swamp-of-sorrows-43-43": "alliance-tanaris-43-44",
    "alliance-tanaris-43-44": "alliance-feralas-44-48",
    "alliance-feralas-44-48": "alliance-tanaris-44-48",
    "alliance-tanaris-44-48": "alliance-hinterlands-48-49",
    "alliance-hinterlands-48-49": "alliance-tanaris-49-49",
    "alliance-tanaris-49-49": "alliance-un-goro-49-50",
    "alliance-un-goro-49-50": "alliance-stranglethorn-50-50",
    "alliance-stranglethorn-50-50": "alliance-searing-gorge-50-51",
    "alliance-searing-gorge-50-51": "alliance-blasted-lands-51-51",
    "alliance-blasted-lands-51-51": "alliance-burning-steppes-51-51",
    "alliance-burning-steppes-51-51": "alliance-western-plaguelands-51-52",
    "alliance-western-plaguelands-51-52": "alliance-azshara-52-52",
    "alliance-azshara-52-52": "alliance-felwood-52-52",
    "alliance-felwood-52-52": "alliance-feralas-52-53",
    "alliance-feralas-52-53": "alliance-azshara-52-53",
    "alliance-azshara-52-53": "alliance-un-goro-53-54",
    "alliance-un-goro-53-54": "alliance-winterspring-54-56",
    "alliance-winterspring-54-56": "alliance-felwood-54-56",
    "alliance-felwood-54-56": "alliance-burning-steppes-56-57",
    "alliance-burning-steppes-56-57": "alliance-western-plaguelands-57-58",
    "alliance-western-plaguelands-57-58": "alliance-eastern-plaguelands-57-58",
    "alliance-eastern-plaguelands-57-58": "alliance-winterspring-58-59",
    "alliance-winterspring-58-59": "alliance-silithus-59-60",
}


def assign(steps: list[dict], guides: list[OutGuide]) -> None:
    """Attach steps to the guide that owns their map.

    Unlike the Horde forward-only walk, Alliance packs often visit the second
    zone first (Tanaris before Feralas, Felwood before Winterspring). Switching
    freely on map ownership keeps each zone file non-empty and puts return
    trips in the zone they belong to. City / travel steps without a zone map
    stay with the current guide.
    """
    idx: dict[int, int] = {}
    for i, g in enumerate(guides):
        for m in g.maps:
            idx[m] = i
    cur = 0
    pending: list[dict] = []
    for s in steps:
        i = idx.get(s.get("map"))
        if i is None:
            pending.append(s)
            continue
        cur = i
        guides[cur].steps.extend(pending)
        pending.clear()
        guides[cur].steps.append(s)
    guides[cur].steps.extend(pending)


JUNK_TEXT = re.compile(
    r"(?i)^(?:note\.?\s*)?(?:wrong character race|manage your ammo)\.?$"
)


def is_junk_step(step: dict) -> bool:
    text = (step.get("text") or "").strip()
    if JUNK_TEXT.match(text):
        return True
    if text.lower() in {"note.", "note"}:
        return True
    # Race-gated "wrong race" leftovers inside a race-limited starter.
    if "Wrong Character Race" in text:
        return True
    return False


def convert_pack(pack: dict, guides: list[OutGuide], drop_maps: set[int]) -> int:
    state: dict = {"carry_note": None}
    converted = []
    for raw in pack["steps"]:
        if raw.get("map") in drop_maps:
            continue
        step = sh.convert_step(raw, state)
        if step and not is_junk_step(step):
            converted.append(step)
    assign(converted, guides)
    return len(converted)


def emit_guide(g: OutGuide) -> str:
    out = ["ns.RegisterGuide({"]
    out.append(f"    id = {sh.lua_str(g.gid)},")
    out.append(f"    name = {sh.lua_str(g.name)},")
    out.append('    group = "Alliance",')
    out.append('    faction = "Alliance",')
    out.append("    forever = true,")
    out.append("    listed = true,")
    if g.starter:
        out.append("    starter = true,")
    if g.races:
        out.append("    races = { " + ", ".join(sh.lua_str(r) for r in g.races) + " },")
    nxt = NEXT.get(g.gid)
    if nxt:
        out.append(f"    next = {sh.lua_str(nxt)},")
    out.append(f"    minLevel = {g.lo},")
    out.append(f"    maxLevel = {g.hi},")
    out.append("    steps = {")
    for s in g.steps:
        out.append(sh.emit_step(s))
    # Hand-off step when we know the next guide.
    if nxt:
        dest_name = None
        if nxt == "alliance-redridge-19-21":
            dest_name = "Redridge Mountains"
        else:
            # Longest slug match so swamp-of-sorrows wins over swamp.
            for zinfo in sorted(ZONES.values(), key=lambda z: len(z["slug"]), reverse=True):
                if nxt.startswith(f"alliance-{zinfo['slug']}-"):
                    dest_name = zinfo["title"]
                    break
        if dest_name:
            out.append(
                sh.emit_step(
                    {
                        "text": f"This pass is done. Continue to {dest_name}.",
                        "guide": nxt,
                    }
                )
            )
    out.append("    },")
    out.append("})")
    return "\n".join(out)


def emit_file(zone: str, guides: list[OutGuide]) -> str:
    info = ZONES[zone]
    lines = ["local _, ns = ...", ""]
    for h in info["header"]:
        lines.append(f"-- {h}")
    lines.append("-- DRAFT: scaffolded from Zygor reference by Data/scaffold_alliance_curated.py.")
    lines.append("-- Needs a hand pass for coordinates, nearYards, stickies, pins and wording.")
    lines.append("")
    body = "\n\n".join(emit_guide(g) for g in guides if g.steps)
    return "\n".join(lines) + "\n" + body + "\n"


def read_text(path: Path) -> tuple[str, str]:
    data = path.read_bytes().decode("utf-8")
    nl = "\r\n" if "\r\n" in data else "\n"
    return data.replace("\r\n", "\n"), nl


def write_text(path: Path, text: str, nl: str) -> None:
    path.write_bytes(text.replace("\n", nl).encode("utf-8"))


def guide_span(text: str, gid: str) -> tuple[int, int]:
    m = re.search(r'^    id = "' + re.escape(gid) + r'",$', text, re.M)
    if not m:
        raise SystemExit(f"guide not found: {gid}")
    start = text.rfind("ns.RegisterGuide({", 0, m.start())
    end = text.find("\n})", m.end())
    return start, end + 3


def set_next(path: Path, gid: str, nxt: str) -> str:
    text, nl = read_text(path)
    start, end = guide_span(text, gid)
    block = text[start:end]
    head_end = block.find("    steps = {")
    head = block[:head_end]
    if re.search(r"^    next = ", head, re.M):
        new_head = re.sub(r'^    next = ".*?",$', f'    next = "{nxt}",', head, flags=re.M)
    else:
        new_head = re.sub(
            r"^(    listed = true,)$",
            r"\1" + f'\n    next = "{nxt}",',
            head,
            flags=re.M,
        )
    if new_head == head:
        return f"{path.name}: {gid} next already {nxt}"
    text = text[:start] + new_head + block[head_end:] + text[end:]
    write_text(path, text, nl)
    return f"{path.name}: {gid} next = {nxt}"


def patch_step(path: Path, gid: str, marker: str, new_text: str | None, new_guide: str | None) -> str:
    text, nl = read_text(path)
    start, end = guide_span(text, gid)
    block = text[start:end]
    pos = block.find(marker)
    if pos < 0:
        return f"{path.name}: marker not found in {gid}: {marker[:40]}"
    s0 = block.rfind("        {\n", 0, pos)
    s1 = block.find("\n        },", pos) + len("\n        },")
    step = block[s0:s1]
    new_step = step
    if new_text is not None:
        new_step = re.sub(
            r'^            text = ".*",$',
            lambda _m: f"            text = {sh.lua_str(new_text)},",
            new_step,
            count=1,
            flags=re.M,
        )
    if new_guide is not None:
        if re.search(r"^            guide = ", new_step, re.M):
            new_step = re.sub(
                r'^            guide = ".*",$',
                f'            guide = "{new_guide}",',
                new_step,
                count=1,
                flags=re.M,
            )
        else:
            new_step = re.sub(
                r"^(            text = .*,)$",
                lambda _m: _m.group(1) + f'\n            guide = "{new_guide}",',
                new_step,
                count=1,
                flags=re.M,
            )
    if new_step == step:
        return f"{path.name}: {gid} hand-off step already patched"
    block = block[:s0] + new_step + block[s1:]
    text = text[:start] + block + text[end:]
    write_text(path, text, nl)
    return f"{path.name}: {gid} hand-off step -> {new_guide or 'text only'}"


def patch_existing() -> list[str]:
    log: list[str] = []
    dark = CURATED / "Alliance_Darkshore_Curated.lua"
    log.append(set_next(dark, "alliance-darkshore-16-20", "alliance-loch-modan-18-19"))
    log.append(
        patch_step(
            dark,
            "alliance-darkshore-16-20",
            "Darkshore is done for now",
            "Darkshore is done for now. Continue to Loch Modan around level 18, "
            "then curated Redridge around level 19.",
            "alliance-loch-modan-18-19",
        )
    )

    red = CURATED / "Alliance_Redridge_Curated.lua"
    log.append(set_next(red, "alliance-redridge-19-21", "alliance-ashenvale-21-24"))
    # Append a hand-off step if the guide has no guide= hand-off yet.
    text, nl = read_text(red)
    if 'guide = "alliance-ashenvale-21-24"' not in text:
        start, end = guide_span(text, "alliance-redridge-19-21")
        block = text[start:end]
        insert = (
            "\n        {\n"
            '            text = "Redridge is done for now. Continue to Ashenvale.",\n'
            '            guide = "alliance-ashenvale-21-24",\n'
            "        },"
        )
        # Insert before closing of steps
        steps_close = block.rfind("\n    },")
        block = block[:steps_close] + insert + block[steps_close:]
        text = text[:start] + block + text[end:]
        write_text(red, text, nl)
        log.append("Alliance_Redridge_Curated.lua: appended Ashenvale hand-off")
    else:
        log.append("Alliance_Redridge_Curated.lua: Ashenvale hand-off already present")
    return log


def toc_entries(files: list[Path]) -> list[str]:
    return [f"Guides/Forever/Curated/{p.name}" for p in files]


def patch_toc(new_files: list[Path]) -> str:
    toc = ROOT / "Waynotes.toc"
    text, nl = read_text(toc)
    entries = toc_entries(sorted(new_files, key=lambda p: p.name))
    # Remove any prior copies of these entries to keep TOC idempotent.
    lines = text.split("\n")
    keep = [ln for ln in lines if ln not in entries]
    # Insert after Alliance_Redridge_Curated.lua
    anchor = "Guides/Forever/Curated/Alliance_Redridge_Curated.lua"
    try:
        idx = keep.index(anchor)
    except ValueError:
        raise SystemExit("TOC missing Alliance_Redridge_Curated.lua anchor")
    keep = keep[: idx + 1] + entries + keep[idx + 1 :]
    write_text(toc, "\n".join(keep), nl)
    return f"Waynotes.toc: inserted {len(entries)} Alliance curated entries"


def main() -> int:
    packs: dict[str, dict] = {}
    for name in SOURCES:
        path = ZYGOR / name
        if not path.is_file():
            print(f"Missing source: {path}", file=sys.stderr)
            return 1
        for g in sh.parse_guides(path.read_text(encoding="utf-8")):
            packs[g["id"]] = g

    spec = build_packs()
    missing = [pid for pid in spec if pid not in packs]
    if missing:
        print("Missing Zygor packs:", missing, file=sys.stderr)
        return 1

    by_zone: dict[str, list[OutGuide]] = {z: [] for z in ZONES}
    for pid, (guides, drop_maps) in spec.items():
        convert_pack(packs[pid], guides, drop_maps)
        for g in guides:
            by_zone[g.zone].append(g)

    CURATED.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    summary: list[tuple[str, str, int]] = []
    for zone, guides in by_zone.items():
        guides = [g for g in guides if g.steps]
        if not guides:
            print(f"WARNING: no steps for zone {zone}")
            continue
        guides.sort(key=lambda g: (g.lo, g.hi))
        path = CURATED / ZONES[zone]["file"]
        # Never overwrite the three hand-authored early Alliance files.
        if path.name in {
            "Alliance_Teldrassil_Curated.lua",
            "Alliance_Darkshore_Curated.lua",
            "Alliance_Redridge_Curated.lua",
        }:
            print(f"SKIP preserve: {path.name}")
            continue
        path.write_text(emit_file(zone, guides), encoding="utf-8", newline="\n")
        written.append(path)
        for g in guides:
            summary.append((path.name, g.gid, len(g.steps)))

    produced = {gid for _, gid, _ in summary}
    for src, dst in NEXT.items():
        if src not in produced and src not in EXISTING:
            # Some NEXT keys are only on produced guides; warn if source missing.
            if any(src.startswith("alliance-") for _ in [0]):
                if src not in produced:
                    print(f"NOTE: spine source not in this run (may be existing): {src}")
        if dst not in produced and dst not in EXISTING:
            print(f"WARNING: spine target not produced: {dst}")

    print("Guides written:")
    total_steps = 0
    for fname, gid, n in summary:
        print(f"  {fname:<42} {gid:<40} {n:>4} steps")
        total_steps += n
    print(f"Total: {len(summary)} guides, {total_steps} steps in {len(written)} files")
    print()
    print("Patched existing files:")
    for line in patch_existing():
        print("  " + line)
    print()
    print(patch_toc(written))
    return 0


if __name__ == "__main__":
    sys.exit(main())
