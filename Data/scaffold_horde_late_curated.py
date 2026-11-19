#!/usr/bin/env python3
"""Scaffold Horde 36-59 curated draft guides from the Zygor REFERENCE packs.

Reads:
    Guides/REFERENCE/Zygor/Horde_30-40.lua
    Guides/REFERENCE/Zygor/Horde_40-50.lua
    Guides/REFERENCE/Zygor/Horde_50-60.lua

Writes (one file per zone, several RegisterGuide blocks each):
    Guides/Forever/Curated/Horde_<Zone>_Curated.lua

Also patches the `next` chain and hand-off steps in the existing Horde curated
files that feed into this spine (Thousand Needles, Desolace, Dustwallow,
Arathi, Badlands).

The output follows Guides/CURATED_GUIDE_STANDARDS.md as closely as an automatic
conversion can: color tags, "Get the Hub flight path", details count lines,
classes / races / mode fields instead of leading brackets, explicit `when`.
Everything produced here is a DRAFT. Coordinates, nearYards, pins, stickies and
wording still need a human pass.

Usage:
    python Data/scaffold_horde_late_curated.py
"""
from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ZYGOR = ROOT / "Guides" / "REFERENCE" / "Zygor"
CURATED = ROOT / "Guides" / "Forever" / "Curated"

SOURCES = ["Horde_30-40.lua", "Horde_40-50.lua", "Horde_50-60.lua"]

# ---------------------------------------------------------------------------
# Minimal Lua table parser (enough for the Zygor/Waynotes RegisterGuide files)
# ---------------------------------------------------------------------------


class LuaParser:
    def __init__(self, text: str, pos: int = 0):
        self.s = text
        self.i = pos

    def skip(self) -> None:
        s = self.s
        while self.i < len(s):
            c = s[self.i]
            if c in " \t\r\n":
                self.i += 1
            elif s.startswith("--", self.i):
                if s.startswith("--[[", self.i):
                    end = s.find("]]", self.i + 4)
                    self.i = len(s) if end < 0 else end + 2
                else:
                    end = s.find("\n", self.i)
                    self.i = len(s) if end < 0 else end + 1
            else:
                break

    def parse_string(self) -> str:
        s = self.s
        q = s[self.i]
        self.i += 1
        out: list[str] = []
        while self.i < len(s):
            c = s[self.i]
            if c == "\\":
                n = s[self.i + 1]
                out.append({"n": "\n", "t": "\t"}.get(n, n))
                self.i += 2
            elif c == q:
                self.i += 1
                return "".join(out)
            else:
                out.append(c)
                self.i += 1
        raise ValueError("unterminated string")

    def parse_value(self):
        self.skip()
        s = self.s
        c = s[self.i]
        if c == "{":
            return self.parse_table()
        if c in "\"'":
            return self.parse_string()
        m = re.compile(r"-?\d+(?:\.\d+)?").match(s, self.i)
        if m:
            self.i = m.end()
            t = m.group(0)
            return float(t) if "." in t else int(t)
        for word, val in (("true", True), ("false", False), ("nil", None)):
            if s.startswith(word, self.i):
                self.i += len(word)
                return val
        raise ValueError(f"unexpected token at {self.i}: {s[self.i:self.i + 30]!r}")

    def parse_table(self):
        s = self.s
        self.i += 1  # {
        named: dict = {}
        items: list = []
        while True:
            self.skip()
            if s[self.i] == "}":
                self.i += 1
                break
            m = re.compile(r"([A-Za-z_]\w*)\s*=(?!=)").match(s, self.i)
            if m:
                self.i = m.end()
                named[m.group(1)] = self.parse_value()
            else:
                items.append(self.parse_value())
            self.skip()
            if s[self.i] in ",;":
                self.i += 1
        return named if named else items


def parse_guides(text: str) -> list[dict]:
    out = []
    pos = 0
    while True:
        i = text.find("ns.RegisterGuide(", pos)
        if i < 0:
            break
        p = LuaParser(text, i + len("ns.RegisterGuide("))
        p.skip()
        out.append(p.parse_table())
        pos = p.i
    return out


# ---------------------------------------------------------------------------
# Output spine
# ---------------------------------------------------------------------------


@dataclass
class OutGuide:
    zone: str
    lo: int
    hi: int
    maps: frozenset[int]
    steps: list[dict] = field(default_factory=list)

    @property
    def gid(self) -> str:
        return f"horde-{ZONES[self.zone]['slug']}-{self.lo}-{self.hi}"

    @property
    def name(self) -> str:
        band = f"{self.lo}" if self.lo == self.hi else f"{self.lo}-{self.hi}"
        return f"{band} {ZONES[self.zone]['title']}"


ZONES = {
    "stranglethorn": {
        "slug": "stranglethorn",
        "title": "Stranglethorn Vale",
        "file": "Horde_Stranglethorn_Curated.lua",
        "header": [
            "Horde Stranglethorn Vale.",
            "Four legs: 36-37 Grom'gol and the Nesingwary hunting camp, 40-41 Booty Bay",
            "pickups and the Bloodscalp / Skullsplitter clean-up, 44-45 Green Hills chapters",
            "and the Bloodsail Buccaneers, 50 Nesingwary capstones and the Keelhaul bottle chain.",
            "Start 36-37 after Desolace 34-36 with Hunting in Stranglethorn ready for the camp.",
        ],
    },
    "swamp-of-sorrows": {
        "slug": "swamp-of-sorrows",
        "title": "Swamp of Sorrows",
        "file": "Horde_SwampOfSorrows_Curated.lua",
        "header": [
            "Horde Swamp of Sorrows.",
            "Stonard flight path, Fallow Sanctuary and Splinterspear Junction quests, the",
            "Fallen Hero chain, Katar's murloc sweeps, and the late Swamp Talker / Cortello leg.",
            "Bring Report to Helgrum from Badlands and Ongeku from Desolace.",
        ],
    },
    "tanaris": {
        "slug": "tanaris",
        "title": "Tanaris",
        "file": "Horde_Tanaris_Curated.lua",
        "header": [
            "Horde Tanaris.",
            "Gadgetzan pickups, Wastewander bounty work, the sampling quests and the",
            "Southsea / Dunemaul / Thistleshrub round, with the Orgrimmar and Thunder Bluff",
            "runs that open each pass. Bring Tran'rek and Stoley's Debt from Stranglethorn Vale.",
        ],
    },
    "feralas": {
        "slug": "feralas",
        "title": "Feralas",
        "file": "Horde_Feralas_Curated.lua",
        "header": [
            "Horde Feralas.",
            "Camp Mojache hub: Woodpaw, Gordunni and Zukk'ash clean-up for 43-44, then the",
            "Uzer'i muisek chain, Zorbin's giants and the Northspring harpies for 49-50.",
            "Start after Tanaris 42-43 with Return to Witch Doctor Uzer'i queued from Orgrimmar.",
        ],
    },
    "hinterlands": {
        "slug": "hinterlands",
        "title": "The Hinterlands",
        "file": "Horde_Hinterlands_Curated.lua",
        "header": [
            "Horde The Hinterlands.",
            "Undercity opener, Revantusk Village hub, Vilebranch / Silvermane / Highvale",
            "sweeps, Rin'ji's escort and Shadra'Alor for the Atal'ai Exile chain.",
            "Bring Return to Apothecary Zinge and The Atal'ai Exile from Tanaris and Swamp of Sorrows.",
        ],
    },
    "searing-gorge": {
        "slug": "searing-gorge",
        "title": "Searing Gorge",
        "file": "Horde_SearingGorge_Curated.lua",
        "header": [
            "Horde Searing Gorge.",
            "Dreadmaul Rock handoff, Thorium Point hub, the Flawless Flame / Torch of Retribution",
            "chain, Squire Maltrake's tower ablaze run, and the Dark Iron work orders.",
            "Start after Swamp of Sorrows 50 with Dreadmaul Rock from Thal'trak Proudtusk.",
        ],
    },
    "un-goro": {
        "slug": "un-goro",
        "title": "Un'Goro Crater",
        "file": "Horde_UnGoro_Curated.lua",
        "header": [
            "Horde Un'Goro Crater.",
            "49-50: Marshal's Refuge pickups, ravasaur hunts and the Linken / J.D. Collie chain.",
            "53-54: Larion, Spark Nilminer and Williden quests, the three crystal pylons,",
            "U'cha, A-Me 01 and the Thunder Bluff / Orgrimmar turn-in loop.",
        ],
    },
    "felwood": {
        "slug": "felwood",
        "title": "Felwood",
        "file": "Horde_Felwood_Curated.lua",
        "header": [
            "Horde Felwood.",
            "Bloodvenom Post hub: Deadwood furbolgs, Jaedenar cultists, Cleansing Felwood,",
            "the Timbermaw reputation turn-ins, Corrupted Sabers and the brazier run.",
            "Felwood legs are split from the Winterspring legs by map; hand-offs run Felwood to Winterspring.",
        ],
    },
    "burning-steppes": {
        "slug": "burning-steppes",
        "title": "Burning Steppes",
        "file": "Horde_BurningSteppes_Curated.lua",
        "header": [
            "Horde Burning Steppes.",
            "Flame Crest flight path, Tinkee Steamboil's broodling essence, Maxwort's tablet",
            "transcript and Cyrus Therepentous. Azshara steps from the Zygor pack were dropped.",
            "Start after Searing Gorge 51 and enter through Blackrock Mountain.",
        ],
    },
    "western-plaguelands": {
        "slug": "western-plaguelands",
        "title": "Western Plaguelands",
        "file": "Horde_WesternPlaguelands_Curated.lua",
        "header": [
            "Horde Western Plaguelands.",
            "Undercity and Tirisfal openers, Argent Dawn commission, the Scourge cauldron",
            "chain, Chromie in Andorhal and the Redpath family hand-offs.",
            "The Eastern Plaguelands leg begins when the Zygor pack crosses into EPL.",
        ],
    },
    "eastern-plaguelands": {
        "slug": "eastern-plaguelands",
        "title": "Eastern Plaguelands",
        "file": "Horde_EasternPlaguelands_Curated.lua",
        "header": [
            "Horde Eastern Plaguelands.",
            "Light's Hope Chapel hub: Tirion's Redemption chain, Pamela's doll, Darrowshire",
            "spirits, Augustus' receipt book and the Villains of Darrowshire turn-ins.",
            "Includes the return trips to Western Plaguelands that the Zygor route interleaves.",
        ],
    },
    "winterspring": {
        "slug": "winterspring",
        "title": "Winterspring",
        "file": "Horde_Winterspring_Curated.lua",
        "header": [
            "Horde Winterspring.",
            "Everlook hub: Winterfall and Ice Thistle sweeps, Donova Snowden's chain, Chillwind",
            "horns, Moonglade turn-ins and the Aquementas run for 58-59.",
            "52-53 and 54-56 also carry the return trips to Felwood that the Zygor route interleaves.",
        ],
    },
}

UI = {
    "stv": 1434,
    "sos": 1435,
    "tanaris": 1446,
    "feralas": 1444,
    "ungoro": 1449,
    "hinterlands": 1425,
    "searing": 1427,
    "bsteppes": 1428,
    "felwood": 1448,
    "winterspring": 1452,
    "wpl": 1422,
    "epl": 1423,
    "azshara": 1447,
    "dustwallow": 1445,
}


def G(zone: str, lo: int, hi: int, map_key: str) -> OutGuide:
    return OutGuide(zone, lo, hi, frozenset({UI[map_key]}))


# pack id -> (builder for the OutGuide list, set of maps to drop outright)
def build_packs() -> dict[str, tuple[list[OutGuide], set[int]]]:
    return {
        "zygor-horde-stranglethorn-vale-36-37": ([G("stranglethorn", 36, 37, "stv")], set()),
        "zygor-horde-stranglethorn-vale-and-swamp-of-sorrows-40-41": (
            [G("stranglethorn", 40, 41, "stv"), G("swamp-of-sorrows", 40, 41, "sos")],
            set(),
        ),
        "zygor-horde-tanaris-41-42": ([G("tanaris", 41, 42, "tanaris")], set()),
        "zygor-horde-tanaris-42-43": ([G("tanaris", 42, 43, "tanaris")], set()),
        "zygor-horde-feralas-43-44": ([G("feralas", 43, 44, "feralas")], set()),
        "zygor-horde-stranglethorn-vale-44-45": ([G("stranglethorn", 44, 45, "stv")], set()),
        "zygor-horde-swamp-of-sorrows-45-46": ([G("swamp-of-sorrows", 45, 46, "sos")], set()),
        "zygor-horde-tanaris-and-dustwallow-marsh-46-48": (
            [G("tanaris", 46, 48, "tanaris")],
            {UI["dustwallow"]},
        ),
        "zygor-horde-the-hinterlands-48-49": ([G("hinterlands", 48, 49, "hinterlands")], set()),
        "zygor-horde-feralas-and-un-goro-crater-49-50": (
            [G("feralas", 49, 50, "feralas"), G("un-goro", 49, 50, "ungoro")],
            set(),
        ),
        "zygor-horde-stranglethorn-vale-and-swamp-of-sorrows-50-50": (
            [G("stranglethorn", 50, 50, "stv"), G("swamp-of-sorrows", 50, 50, "sos")],
            set(),
        ),
        "zygor-horde-searing-gorge-51-51": ([G("searing-gorge", 51, 51, "searing")], set()),
        "zygor-horde-burning-steppes-and-azshara-51-52": (
            [G("burning-steppes", 51, 52, "bsteppes")],
            {UI["azshara"]},
        ),
        "zygor-horde-felwood-and-winterspring-52-53": (
            [G("felwood", 52, 53, "felwood"), G("winterspring", 52, 53, "winterspring")],
            set(),
        ),
        "zygor-horde-un-goro-crater-53-54": ([G("un-goro", 53, 54, "ungoro")], set()),
        "zygor-horde-felwood-and-winterspring-54-56": (
            [G("felwood", 54, 56, "felwood"), G("winterspring", 54, 56, "winterspring")],
            set(),
        ),
        "zygor-horde-western-and-eastern-plaguelands-56-58": (
            [G("western-plaguelands", 56, 58, "wpl"), G("eastern-plaguelands", 56, 58, "epl")],
            {UI["azshara"]},
        ),
        "zygor-horde-winterspring-58-59": ([G("winterspring", 58, 59, "winterspring")], set()),
    }


NEXT = {
    "horde-stranglethorn-36-37": "horde-dustwallow-37-38",
    "horde-stranglethorn-40-41": "horde-swamp-of-sorrows-40-41",
    "horde-swamp-of-sorrows-40-41": "horde-desolace-41-41",
    "horde-tanaris-41-42": "horde-dustwallow-41-42",
    "horde-tanaris-42-43": "horde-feralas-43-44",
    "horde-feralas-43-44": "horde-stranglethorn-44-45",
    "horde-stranglethorn-44-45": "horde-swamp-of-sorrows-45-46",
    "horde-swamp-of-sorrows-45-46": "horde-tanaris-46-48",
    "horde-tanaris-46-48": "horde-hinterlands-48-49",
    "horde-hinterlands-48-49": "horde-feralas-49-50",
    "horde-feralas-49-50": "horde-un-goro-49-50",
    "horde-un-goro-49-50": "horde-stranglethorn-50-50",
    "horde-stranglethorn-50-50": "horde-swamp-of-sorrows-50-50",
    "horde-swamp-of-sorrows-50-50": "horde-searing-gorge-51-51",
    "horde-searing-gorge-51-51": "horde-burning-steppes-51-52",
    "horde-burning-steppes-51-52": "horde-felwood-52-53",
    "horde-felwood-52-53": "horde-winterspring-52-53",
    "horde-winterspring-52-53": "horde-un-goro-53-54",
    "horde-un-goro-53-54": "horde-felwood-54-56",
    "horde-felwood-54-56": "horde-winterspring-54-56",
    "horde-winterspring-54-56": "horde-western-plaguelands-56-58",
    "horde-western-plaguelands-56-58": "horde-eastern-plaguelands-56-58",
    "horde-eastern-plaguelands-56-58": "horde-winterspring-58-59",
}

# ---------------------------------------------------------------------------
# Text helpers
# ---------------------------------------------------------------------------

CLASS_NAMES = {
    "warrior": "Warrior",
    "paladin": "Paladin",
    "hunter": "Hunter",
    "rogue": "Rogue",
    "priest": "Priest",
    "shaman": "Shaman",
    "mage": "Mage",
    "warlock": "Warlock",
    "druid": "Druid",
}
RACE_NAMES = {
    "orc": "Orc",
    "troll": "Troll",
    "tauren": "Tauren",
    "undead": "Undead",
    "human": "Human",
    "dwarf": "Dwarf",
    "gnome": "Gnome",
    "nightelf": "Night Elf",
}

MASS_WORDS = {
    "meat", "cloth", "dust", "soil", "ash", "tar", "amber", "wool", "silk", "ore",
    "blood", "water", "flesh", "residue", "sinew", "iron", "mithril", "thorium",
    "linen", "mageweave", "runecloth", "ammo", "grog", "ripple",
}

TITLE_PREFIXES = (
    "King ", "Queen ", "Captain ", "Overlord ", "Lord ", "Princess ", "Prince ",
    "Foreman ", "Cauldron Lord ", "Huntsman ", "Cavalier ", "Fleet Master ",
    "Baron ", "Commander ", "General ",
)
KNOWN_UNIQUE_MOBS = {"Swamp Talker", "Stinglasher", "Gammerita", "Aquementas", "Ongeku", "Tethis"}

ABBREV_END = re.compile(r"(?:^|\s)(?:S|J|Co|Mr|Mrs|Dr|St|J\.D)$")

DROP_FRAG = re.compile(
    r"^(?:During the Next|While in|Optional Dungeon|Begin Finding|Starting Dungeon|"
    r"Timed Quest|Long Timed Quest|Keep All Untested|Abandon the|Equip Your Normal|"
    r"Save |Ammo available|tickystart|stickystart|stickystop|expcollect|path |map |"
    r"Type /|Wait outside|Watch the dialogue|Select |Destroy |Buy a mount|"
    r"Resurrect At)",
    re.I,
)
MOVE_FRAG = re.compile(
    r"^(?:Follow the (?:path|road|river)|Follow |Run (?:up|down|around|along|through)|"
    r"Leave the (?:cave|building|Cauldron)|Leave Shadra|Leave Lost|Jump |Cross |Climb |Walk |"
    r"Run to )",
    re.I,
)
ACTION_FRAG = re.compile(
    r"^(?:Talk to|Turn in|Accept|Kill|Collect|Click|Use|Loot|Learn|Train|Buy|Stable|Retrieve|"
    r"Teach|Locate|Discover|Explore|Equip|Escort|Burn|Protect|Free|Drink|Set |Mark|Deliver|"
    r"Scare|Create|Reach|Gain|Witness|Enter|Visit|Grind|fpath|home|bank|turninany|equip|buy)",
    re.I,
)


def lua_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def sanitize(s: str) -> str:
    s = s.replace("\u2014", ",").replace("\u2013", "-").replace("\u2019", "'")
    s = s.replace("\u2018", "'").replace("\u201c", '"').replace("\u201d", '"')
    s = s.replace("->", "to")
    s = s.replace("{}", "")
    s = re.sub(r"##[\w']*", "", s)
    s = re.sub(r"#(\d+)#", r"\1", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def oxford(items: list[str]) -> str:
    if len(items) == 1:
        return items[0]
    if len(items) == 2:
        return f"{items[0]} and {items[1]}"
    return ", ".join(items[:-1]) + f", and {items[-1]}"


def pluralize(name: str) -> str:
    m = re.match(r"^(.*?)\s+(of|from)\s+(.+)$", name)
    if m:
        return f"{pluralize(m.group(1))} {m.group(2)} {m.group(3)}"
    words = name.split()
    last = words[-1]
    low = last.lower()
    if low in MASS_WORDS:
        return name
    if low == "wolf":
        new = "Wolves"
    elif low == "thief":
        new = "Thieves"
    elif low.endswith("man") and low not in ("shaman", "human", "german"):
        new = last[:-3] + "men"
    elif low.endswith("y") and len(low) > 1 and low[-2] not in "aeiou":
        new = last[:-1] + "ies"
    elif low.endswith("arch"):
        new = last + "s"
    elif low.endswith(("sh", "ch", "x", "z", "ss")):
        new = last + "es"
    elif low.endswith("s"):
        new = last
    else:
        new = last + "s"
    return " ".join(words[:-1] + [new])


def with_article(name: str, article: str = "the") -> str:
    """Return a name prefixed with 'the' unless the in-game name starts with an article."""
    if re.match(r"^(?:A|An|The)\s", name):
        return name
    return f"{article} {name}"


def fix_name(name: str) -> str:
    name = name.strip().rstrip(".").strip()
    if name.endswith(" Jr"):
        name += "."
    return name


# ---------------------------------------------------------------------------
# Bracket conditions
# ---------------------------------------------------------------------------


def classify_bracket(content: str):
    low = content.strip().lower()
    if "guideflag" in low or "discountgold" in low:
        return ("drop",)
    if re.search(r"(?<![!\w])hardcore\(\)", low) and "!hardcore()" not in low:
        return ("mode", "hardcore")
    if "!hardcore()" in low:
        return ("mode", "softcore")
    toks = re.findall(r"!?[A-Za-z']+(?:\s+Elf)?", content)
    if not toks:
        return ("ignore",)
    classes: list[str] = []
    exclude: list[str] = []
    races: list[str] = []
    exrace: list[str] = []
    for tok in toks:
        neg = tok.startswith("!")
        key = tok.lstrip("!").lower().replace(" ", "")
        if key in ("or", "and"):
            continue
        if key in CLASS_NAMES:
            (exclude if neg else classes).append(CLASS_NAMES[key])
        elif key in RACE_NAMES:
            (exrace if neg else races).append(RACE_NAMES[key])
        else:
            return ("ignore",)
    if not (classes or exclude or races or exrace):
        return ("ignore",)
    return ("filter", classes, exclude, races, exrace)


LEAD_BRACKET = re.compile(r"^\s*\[([^\]]*)\]\s*")
ANY_BRACKET = re.compile(r"\[([^\]]*)\]\s*")


# ---------------------------------------------------------------------------
# Fragment parsing
# ---------------------------------------------------------------------------


def split_fragments(text: str) -> list[str]:
    parts = re.split(r"\.\s+", text.strip())
    merged: list[str] = []
    for p in parts:
        if merged and ABBREV_END.search(merged[-1]):
            merged[-1] = merged[-1] + ". " + p
        else:
            merged.append(p)
    out = []
    for p in merged:
        p = p.strip()
        if p.endswith(".") and not p.endswith(".."):
            p = p[:-1]
        if p:
            out.append(p)
    return out


def parse_count(s: str) -> tuple[int | None, str]:
    m = re.match(r"^(\d+)\s+(.+)$", s.strip())
    if m:
        return int(m.group(1)), m.group(2).strip()
    return None, s.strip()


def parse_ops(fragments: list[str]) -> tuple[list[tuple], dict]:
    """Return (ops, meta). meta carries mode / drop flags found in fragment brackets."""
    ops: list[tuple] = []
    meta = {"drop": False, "bank": False, "save_note": None}
    for frag in fragments:
        # fragment-level brackets (mid-text conditions)
        skip = False
        if re.search(r"\[\d+(?:\.\d+)?,\s*\d+(?:\.\d+)?\]", frag):
            continue  # "Turn in X at [52.4,28.4]" style coordinate hints
        while True:
            m = LEAD_BRACKET.match(frag)
            if not m:
                break
            kind = classify_bracket(m.group(1))
            frag = frag[m.end():]
            if kind[0] == "drop":
                skip = True
            elif kind[0] == "mode" and kind[1] == "hardcore":
                skip = True
        frag = ANY_BRACKET.sub("", frag).strip() if "[" in frag else frag.strip()
        frag = frag.strip(" .")
        if skip or not frag:
            continue
        if re.match(r"^Save Green Hills", frag, re.I):
            meta["save_note"] = "Keep the Green Hills of Stranglethorn pages you collect."
            continue
        if re.match(r"^bank\b", frag):
            meta["bank"] = True
            continue
        if DROP_FRAG.match(frag):
            continue
        if MOVE_FRAG.match(frag):
            continue
        m = re.match(r"^Grind to (\d+)(?:,\d+)?$", frag)
        if m:
            ops.append(("text", f"Grind to level {m.group(1)}"))
            continue
        m = re.match(r"^turninany\s+(.+?)(?:,\d+)+$", frag)
        if m:
            ops.append(("turnin", fix_name(m.group(1))))
            continue
        m = re.match(r"^Talk to (.+)$", frag)
        if m:
            ops.append(("talk", fix_name(m.group(1))))
            continue
        m = re.match(r"^Turn in (.+)$", frag)
        if m:
            ops.append(("turnin", fix_name(m.group(1))))
            continue
        m = re.match(r"^Accept (.+)$", frag)
        if m:
            ops.append(("accept", fix_name(m.group(1))))
            continue
        m = re.match(r"^Kill (.+)$", frag)
        if m:
            body = m.group(1).strip()
            if body.lower() in ("enemies", "enemy"):
                ops.append(("text", "Kill enemies"))
                continue
            names = [n.strip() for n in re.split(r",\s+", body) if n.strip()]
            ops.append(("kill", [parse_count(n) for n in names]))
            continue
        m = re.match(r"^Collect (.+)$", frag)
        if m:
            ops.append(("collect",) + parse_count(m.group(1)))
            continue
        m = re.match(r"^Click (.+)$", frag)
        if m:
            ops.append(("click", m.group(1).strip()))
            continue
        m = re.match(r"^Use (.+)$", frag)
        if m:
            ops.append(("use", m.group(1).strip()))
            continue
        m = re.match(r"^[Ee]quip (.+)$", frag)
        if m:
            ops.append(("equip", m.group(1).strip()))
            continue
        m = re.match(r"^fpath (.+)$", frag)
        if m:
            ops.append(("fpath", m.group(1).strip()))
            continue
        m = re.match(r"^home (.+)$", frag)
        if m:
            ops.append(("home", m.group(1).strip()))
            continue
        m = re.match(r"^[Bb]uy (.+)$", frag)
        if m:
            ops.append(("buy", m.group(1).strip()))
            continue
        ops.append(("text", frag[0].upper() + frag[1:]))
    return ops, meta


def is_unique_mob(name: str, count: int | None, collects: list[str], group_size: int) -> bool:
    if count is not None:
        return count == 1
    if name in KNOWN_UNIQUE_MOBS:
        return True
    if " the " in name or name.startswith(TITLE_PREFIXES):
        return True
    first = name.split()[0]
    last = name.split()[-1]
    for item in collects:
        if f"{name}'s" in item or f"{first}'s" in item or f"{last}'s" in item or re.search(r"\bof\s+" + re.escape(name), item):
            return True
    if not collects and group_size == 1:
        return True
    return False


def build_text(ops: list[tuple], has_quest: bool) -> tuple[str, list[str], str | None]:
    """Return (headline, details, first_mob_phrase)."""
    collects = [o[2] for o in ops if o[0] == "collect"]
    parts: list[str] = []
    details_turnin: list[str] = []
    details_obj: list[str] = []
    seen_source = False
    first_mob = None
    i = 0
    while i < len(ops):
        op = ops[i]
        kind = op[0]
        if kind == "talk":
            parts.append(f"Talk to [FRIENDLY]{op[1]}[/]")
            i += 1
        elif kind in ("turnin", "accept"):
            group = []
            while i < len(ops) and ops[i][0] == kind:
                group.append(ops[i][1])
                i += 1
            verb = "Turn in" if kind == "turnin" else "Accept"
            parts.append(f"{verb} " + oxford([f"[QUEST]{n}[/]" for n in group]))
            if kind == "turnin":
                details_turnin.extend(f"Turn in [QUEST]{n}[/]" for n in group)
        elif kind == "kill":
            seen_source = True
            group: list[tuple[int | None, str]] = []
            while i < len(ops) and ops[i][0] == "kill":
                group.extend(ops[i][1])
                i += 1
            tagged = []
            for count, name in group:
                uniq = is_unique_mob(name, count, collects, len(group))
                shown = name if uniq else pluralize(name)
                tag = f"[ENEMY]{shown}[/]"
                if tag not in tagged:
                    tagged.append(tag)
                if first_mob is None:
                    first_mob = shown
                if count is not None and count > 1:
                    details_obj.append(f"[ENEMY]{name}[/] ({count})")
                elif uniq and has_quest:
                    details_obj.append(f"Kill [ENEMY]{name}[/]")
            parts.append("Kill " + oxford(tagged))
        elif kind == "collect":
            group = []
            while i < len(ops) and ops[i][0] == "collect":
                group.append((ops[i][1], ops[i][2]))
                i += 1
            for count, name in group:
                details_obj.append(f"[LOOT]{name}[/] ({count or 1})")
            if not seen_source:
                tagged = []
                for count, name in group:
                    shown = pluralize(name) if (count or 1) > 1 else name
                    tagged.append(f"[LOOT]{shown}[/]")
                parts.append("Collect " + oxford(tagged))
        elif kind == "click":
            seen_source = True
            group = []
            while i < len(ops) and ops[i][0] == "click":
                group.append(ops[i][1])
                i += 1
            tagged = [f"[PICK]{n}[/]" for n in group]
            first = group[0]
            lead = "Click " + ("" if re.match(r"^(?:A|An|The)\s", first) else "the ")
            parts.append(lead + oxford(tagged))
        elif kind == "use":
            seen_source = True
            parts.append("Use " + ("" if re.match(r"^(?:A|An|The)\s", op[1]) else "the ") + f"[LOOT]{op[1]}[/]")
            i += 1
        elif kind == "equip":
            parts.append("Equip " + ("" if re.match(r"^(?:A|An|The)\s", op[1]) else "the ") + f"[LOOT]{op[1]}[/]")
            i += 1
        elif kind == "fpath":
            parts.append(f"Get the {op[1]} flight path")
            i += 1
        elif kind == "home":
            parts.append(f"Set your Hearthstone to {op[1]}")
            i += 1
        elif kind == "buy":
            parts.append(f"Buy [BUY]{op[1]}[/]")
            i += 1
        else:
            if op[1] == "Kill enemies":
                seen_source = True
            parts.append(op[1].replace(" Out of ", " out of "))
            i += 1
    text = ". ".join(parts)
    if text and not text.endswith((".", "!", "?")):
        text += "."
    return text, details_turnin + details_obj, first_mob


def clean_note(raw: str, first_mob: str | None) -> str | None:
    n = sanitize(raw)
    if not n:
        return None
    low = n.lower()
    if re.search(r"\bskip\b|^not needed$|click here", low):
        return None
    if "stealthed" in low:
        mob = "enemies"
        if first_mob:
            mob = pluralize(first_mob.split()[-1]).lower() if not first_mob.endswith("s") else first_mob.split()[-1].lower()
        if low.startswith("careful"):
            n = f"Careful, these {mob} are stealthed"
        else:
            n = f"These {mob} are stealthed"
    n = n[0].upper() + n[1:]
    if not n.endswith((".", "!", "?")):
        n += "."
    return n


# ---------------------------------------------------------------------------
# Step conversion
# ---------------------------------------------------------------------------

PASSTHROUGH = ("sticky", "objective", "pins", "nearYards", "arriveYards", "faction", "travel", "fpath", "guide")


def convert_step(step: dict, state: dict) -> dict | None:
    raw = step.get("text")
    if not isinstance(raw, str) or not raw.strip():
        return None
    text = raw.replace('\\"', '"')
    text = text.replace("{}", "")
    text = re.sub(r"##[\w']*", "", text)
    text = re.sub(r"#(\d+)#", r"\1", text)
    text = text.replace("\u2019", "'")

    classes: list[str] = []
    exclude: list[str] = []
    races: list[str] = []
    exrace: list[str] = []
    mode = None
    while True:
        m = LEAD_BRACKET.match(text)
        if not m:
            break
        kind = classify_bracket(m.group(1))
        text = text[m.end():]
        if kind[0] == "drop":
            return None
        if kind[0] == "mode":
            mode = kind[1]
        elif kind[0] == "filter":
            classes += kind[1]
            exclude += kind[2]
            races += kind[3]
            exrace += kind[4]
    text = re.sub(r"\s+", " ", text).strip()

    if re.match(r"^(?:map|path)\s", text):
        return None
    if re.fullmatch(r"[\s.]*", text):
        return None

    fragments = split_fragments(text)
    ops, meta = parse_ops(fragments)
    if meta["save_note"]:
        state["carry_note"] = meta["save_note"]
    if not ops:
        return None

    kinds = [o[0] for o in ops]
    # Bank / auction house runs are inventory shuffling, not routing.
    if ops[0][0] == "talk":
        npc = ops[0][1]
        rest = ops[1:]
        if npc.startswith("Auctioneer"):
            return None
        only_withdrawals = all(
            o[0] == "collect" or (o[0] == "text" and o[1].startswith("Chapter")) for o in rest
        )
        if (meta["bank"] or any(o[0] == "collect" for o in rest)) and only_withdrawals:
            if step.get("when") not in ("accepted", "complete"):
                return None

    # Bare "Enter the cave" steps are navigation filler.
    if all(o[0] == "text" and re.match(r"^Enter (?:the|an?) [\w' ]*(?:cave|entrance)$", o[1], re.I) for o in ops):
        if step.get("quest") is None and not step.get("quests"):
            return None

    quest = step.get("quest")
    quests = step.get("quests")
    # Zygor leaves a quest id on vendor / hearth / flight path steps. Without a when it
    # would gate on objectives that never exist, so drop the gate.
    if step.get("when") is None and all(k in ("talk", "buy", "fpath", "home") for k in kinds):
        quest = None
        quests = None
    has_quest = quest is not None or bool(quests)
    headline, details, first_mob = build_text(ops, has_quest)
    if not headline:
        return None

    out: dict = {}
    if classes:
        out["classes"] = classes
    if exclude:
        out["excludeClasses"] = exclude
    if races:
        out["races"] = races
    if exrace:
        out["excludeRaces"] = exrace
    for key in ("sticky",):
        if key in step:
            out[key] = step[key]
    out["text"] = headline
    if isinstance(quests, list) and quests:
        out["quests"] = quests
    elif quest is not None:
        out["quest"] = quest
    if "objective" in step:
        out["objective"] = step["objective"]

    when = step.get("when")
    if when is None and has_quest:
        when = "objectives"
    elif when is None and len(ops) == 1 and ops[0][0] == "text" and ops[0][1].startswith("Travel to"):
        when = "travel"
    if when:
        out["when"] = when
    if "map" in step:
        out["map"] = step["map"]
        out["x"] = step["x"]
        out["y"] = step["y"]
    for key in ("nearYards", "arriveYards", "pins", "faction", "travel", "fpath", "guide"):
        if key in step:
            out[key] = step[key]
    if mode:
        out["mode"] = mode
    elif step.get("mode") in ("softcore", "hardcore"):
        out["mode"] = step["mode"]

    # Zygor "details" are turn-in lines (regenerated from text) and tips (moved to note).
    note_parts: list[str] = []
    if isinstance(step.get("note"), str):
        note_parts.append(step["note"])
    for d in step.get("details") or []:
        if isinstance(d, str) and not d.startswith("Turn in "):
            note_parts.append(d)
    if when != "accepted":
        details = [d for d in details if not d.startswith("Turn in ")]
    elif not any(o[0] == "accept" for o in ops):
        details = [d for d in details if not d.startswith("Turn in ")]
    seen = set()
    final_details = []
    for d in details:
        if d not in seen:
            seen.add(d)
            final_details.append(d)
    if final_details:
        out["details"] = final_details[:6]

    notes = []
    for raw_note in note_parts:
        n = clean_note(raw_note, first_mob)
        if n and n not in notes:
            notes.append(n)
    if not notes and state.get("carry_note"):
        notes.append(state["carry_note"])
        state["carry_note"] = None
    if notes:
        out["note"] = " ".join(notes[:2])
    return out


# ---------------------------------------------------------------------------
# Lua emit
# ---------------------------------------------------------------------------


def emit_value(v, indent: str) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return lua_str(v)
    if isinstance(v, list):
        if all(isinstance(x, (int, float, str)) for x in v):
            return "{ " + ", ".join(emit_value(x, indent) for x in v) + " }"
        inner = indent + "    "
        return "{\n" + "".join(f"{inner}{emit_value(x, inner)},\n" for x in v) + indent + "}"
    if isinstance(v, dict):
        inner = indent + "    "
        parts = [f"{k} = {emit_value(x, inner)}" for k, x in v.items()]
        return "{ " + ", ".join(parts) + " }"
    raise TypeError(type(v))


STEP_ORDER = [
    "classes", "excludeClasses", "races", "excludeRaces", "sticky", "text", "quest", "quests",
    "objective", "when", "map", "x", "y", "nearYards", "arriveYards", "pins", "faction",
    "travel", "fpath", "guide", "mode", "details", "note",
]


def emit_step(step: dict) -> str:
    ind = "            "
    lines = ["        {"]
    for key in STEP_ORDER:
        if key not in step:
            continue
        v = step[key]
        if key == "details":
            lines.append(f"{ind}details = {{")
            for d in v:
                lines.append(f"{ind}    {lua_str(d)},")
            lines.append(f"{ind}}},")
        elif key == "pins":
            lines.append(f"{ind}pins = {{")
            for pin in v:
                lines.append(f"{ind}    {emit_value(pin, ind + '    ')},")
            lines.append(f"{ind}}},")
        else:
            lines.append(f"{ind}{key} = {emit_value(v, ind)},")
    lines.append("        },")
    return "\n".join(lines)


def emit_guide(g: OutGuide) -> str:
    out = ["ns.RegisterGuide({"]
    out.append(f"    id = {lua_str(g.gid)},")
    out.append(f"    name = {lua_str(g.name)},")
    out.append('    group = "Horde",')
    out.append('    faction = "Horde",')
    out.append("    forever = true,")
    out.append("    listed = true,")
    nxt = NEXT.get(g.gid)
    if nxt:
        out.append(f"    next = {lua_str(nxt)},")
    out.append(f"    minLevel = {g.lo},")
    out.append(f"    maxLevel = {g.hi},")
    out.append("    steps = {")
    for s in g.steps:
        out.append(emit_step(s))
    out.append("    },")
    out.append("})")
    return "\n".join(out)


def emit_file(zone: str, guides: list[OutGuide]) -> str:
    info = ZONES[zone]
    lines = ["local _, ns = ...", ""]
    for h in info["header"]:
        lines.append(f"-- {h}")
    lines.append("-- DRAFT: scaffolded from Zygor reference by Data/scaffold_horde_late_curated.py.")
    lines.append("-- Needs a hand pass for coordinates, nearYards, stickies, pins and wording.")
    lines.append("")
    body = "\n\n".join(emit_guide(g) for g in guides)
    return "\n".join(lines) + "\n" + body + "\n"


# ---------------------------------------------------------------------------
# Pack conversion + zone assignment
# ---------------------------------------------------------------------------


def assign(steps: list[dict], guides: list[OutGuide]) -> None:
    """Walk steps in route order. Guide index only moves forward.

    A step whose map belongs to a later guide advances the walk; a step whose map
    belongs to an earlier guide (a return trip) stays in the current guide so the
    chronology of the Zygor route is preserved. Steps on other maps (cities,
    travel) join the guide that follows them when the walk advances, otherwise
    the current guide.
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
        if i > cur:
            cur = i
        guides[cur].steps.extend(pending)
        pending.clear()
        guides[cur].steps.append(s)
    guides[cur].steps.extend(pending)


def convert_pack(pack: dict, guides: list[OutGuide], drop_maps: set[int]) -> int:
    state: dict = {"carry_note": None}
    converted = []
    for raw in pack["steps"]:
        if raw.get("map") in drop_maps:
            continue
        step = convert_step(raw, state)
        if step:
            converted.append(step)
    assign(converted, guides)
    return len(converted)


# ---------------------------------------------------------------------------
# Patch existing curated files
# ---------------------------------------------------------------------------


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
    if re.search(r'^    next = ', head, re.M):
        new_head = re.sub(r'^    next = ".*?",$', f'    next = "{nxt}",', head, flags=re.M)
    else:
        new_head = re.sub(r'^(    listed = true,)$', r'\1' + f'\n    next = "{nxt}",', head, flags=re.M)
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
        new_step = re.sub(r'^            text = ".*",$', lambda _m: f"            text = {lua_str(new_text)},", new_step, count=1, flags=re.M)
    if new_guide is not None:
        if re.search(r"^            guide = ", new_step, re.M):
            new_step = re.sub(r'^            guide = ".*",$', f'            guide = "{new_guide}",', new_step, count=1, flags=re.M)
        else:
            new_step = re.sub(r'^(            text = .*,)$', lambda _m: _m.group(1) + f'\n            guide = "{new_guide}",', new_step, count=1, flags=re.M)
    if new_step == step:
        return f"{path.name}: {gid} hand-off step already patched"
    block = block[:s0] + new_step + block[s1:]
    text = text[:start] + block + text[end:]
    write_text(path, text, nl)
    return f"{path.name}: {gid} hand-off step -> {new_guide or 'text only'}"


def patch_existing() -> list[str]:
    log: list[str] = []
    tn = CURATED / "Horde_ThousandNeedles_Curated.lua"
    log.append(set_next(tn, "horde-thousand-needles-33-34", "horde-desolace-34-36"))
    log.append(
        patch_step(
            tn,
            "horde-thousand-needles-33-34",
            'text = "Thousand Needles is done',
            "Thousand Needles is done for now. Hold [QUEST]Family Tree[/] for Desolace, "
            "[QUEST]Goblin Sponsorship[/] for Stranglethorn Vale, and [QUEST]Martek the Exiled[/] "
            "for the Badlands later. Continue to Desolace.",
            "horde-desolace-34-36",
        )
    )

    de = CURATED / "Horde_Desolace_Curated.lua"
    log.append(set_next(de, "horde-desolace-34-36", "horde-stranglethorn-36-37"))
    log.append(set_next(de, "horde-desolace-41-41", "horde-tanaris-41-42"))
    log.append(
        patch_step(
            de,
            "horde-desolace-34-36",
            'text = "First Desolace pass done.',
            "First Desolace pass done. Hold [QUEST]Ongeku[/] for Swamp of Sorrows and "
            "[QUEST]Hunting in Stranglethorn[/] for Stranglethorn Vale. Continue to Stranglethorn Vale.",
            "horde-stranglethorn-36-37",
        )
    )

    dw = CURATED / "Horde_Dustwallow_Curated.lua"
    log.append(set_next(dw, "horde-dustwallow-37-38", "horde-alterac-38-39"))
    log.append(set_next(dw, "horde-dustwallow-41-42", "horde-tanaris-42-43"))
    log.append(
        patch_step(
            dw,
            "horde-dustwallow-37-38",
            'text = "First Dustwallow pass done.',
            "First Dustwallow pass done. Hold [QUEST]The Troll Witchdoctor[/] for Kin'weelay in Grom'gol "
            "and [QUEST]Deadmire[/] for the 41-42 return. Continue to Alterac Mountains.",
            "horde-alterac-38-39",
        )
    )

    ar = CURATED / "Horde_Arathi_Curated.lua"
    log.append(set_next(ar, "horde-arathi-38-39", "horde-badlands-39-40"))

    ba = CURATED / "Horde_Badlands_Curated.lua"
    log.append(set_next(ba, "horde-badlands-39-40", "horde-stranglethorn-40-41"))
    return log


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> int:
    packs: dict[str, dict] = {}
    for name in SOURCES:
        path = ZYGOR / name
        for g in parse_guides(path.read_text(encoding="utf-8")):
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
        guides.sort(key=lambda g: (g.lo, g.hi))
        path = CURATED / ZONES[zone]["file"]
        path.write_text(emit_file(zone, guides), encoding="utf-8", newline="\n")
        written.append(path)
        for g in guides:
            summary.append((path.name, g.gid, len(g.steps)))

    # Every next target must exist after this run, or be one of the known existing guides.
    produced = {g.gid for gl in by_zone.values() for g in gl}
    existing_targets = {
        "horde-dustwallow-37-38", "horde-dustwallow-41-42", "horde-desolace-41-41",
    }
    for src, dst in NEXT.items():
        if src not in produced:
            print(f"WARNING: spine source not produced: {src}")
        if dst not in produced and dst not in existing_targets:
            print(f"WARNING: spine target not produced: {dst}")
    for g in sorted(produced):
        if g not in NEXT and g != "horde-winterspring-58-59":
            print(f"WARNING: guide without next: {g}")
        if not any(g == dst for dst in NEXT.values()) and g != "horde-stranglethorn-36-37":
            print(f"NOTE: guide not referenced as next: {g}")

    print("Guides written:")
    total_steps = 0
    for fname, gid, n in summary:
        print(f"  {fname:<42} {gid:<36} {n:>4} steps")
        total_steps += n
    print(f"Total: {len(summary)} guides, {total_steps} steps in {len(written)} files")
    print()
    print("Patched existing files:")
    for line in patch_existing():
        print("  " + line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
