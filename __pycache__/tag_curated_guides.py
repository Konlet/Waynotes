"""Add |cRB_*| color tags to curated Durotar guide strings."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"d:/!Mods/RestedXP-Better/Guides/Forever")
FILES = [
    ROOT / "Horde_Durotar_Curated.lua",
    ROOT / "Horde_Durotar_ClassQuests.lua",
]

FRIENDLY = sorted(
    [
        "Minor Manifestation of Earth",
        "Ormak Grimshot",
        "Kargal Battlescar",
        "Takrin Pathseeker",
        "Misha Tor'kren",
        "Neeru Fireblade",
        "Foreman Thazz'ril",
        "Zureetha Fargaze",
        "Canaga Earthcaller",
        "Lar Prowltusk",
        "Furl Scornbrown",
        "Furl Scornbrow",
        "Innkeeper Grosk",
        "Cook Torka",
        "Master Vornal",
        "Master Gadrin",
        "Vel'rin Fang",
        "Grunt Kor'ja",
        "Kranal Fiss",
        "Telf Joolam",
        "Spirit Healer",
        "Jen'shan",
        "Shikrik",
        "Ken'jai",
        "Mai'ah",
        "Nartok",
        "Galgar",
        "Zureetha",
        "Hana'zua",
        "Kaltunk",
        "Gornek",
        "Frang",
        "Rwag",
        "Ukor",
        "Xar'Ti",
        "Vel'rin",
        "Vornal",
        "Gadrin",
        "Pal'juh",
        "Brakk",
        "Orgnil",
        "Gar'Thok",
        "Turroc",
        "Rezlak",
        "Rhinag",
        "Kor'ghan",
        "Takrin",
        "Margoz",
        "Thatog",
        "Borstan",
        "Kamari",
        "Kor'geld",
        "Yelmak",
        "Whuut",
        "Migi",
        "Thra",
        "Nazgrel",
        "Thrall",
        "Ur'kyo",
        "Kargal",
        "Ak'Zeloth",
        "Ruzan",
        "Canaga",
        "Tai'jin",
        "Thotar",
        "Swart",
        "Therzok",
        "Hraug",
        "Duokna",
        "Lar",
        "Furl",
    ],
    key=len,
    reverse=True,
)

ENEMY = sorted(
    [
        "Lieutenant Benedict",
        "Yarrog Baneshadow",
        "Bloodtalon Matriarch",
        "Fizzle Darkstorm",
        "Dustwind Storm Witches",
        "Dustwind Storm Witch",
        "Dustwind Savages",
        "Dustwind Savage",
        "Burning Blade Fanatic",
        "Burning Blade Apprentice",
        "Burning Blade Cultists",
        "Burning Blade Cultist",
        "Burning Blade orcs",
        "Razormane Battleguards",
        "Razormane Battleguard",
        "Razormane Dustrunners",
        "Razormane Dustrunner",
        "Razormane Quilboars",
        "Razormane Quilboar",
        "Razormane Scouts",
        "Razormane Scout",
        "Ridgeshade Lurkers",
        "Ridgeshade Lurker",
        "Ridgeshade Creepers",
        "Ridgeshade Creeper",
        "Kul Tiras Sailors",
        "Kul Tiras Sailor",
        "Kul Tiras Marines",
        "Kul Tiras Marine",
        "Dire Mottled Boar",
        "Mottled Boars",
        "Mottled Boar",
        "Scorpid Workers",
        "Scorpid Worker",
        "Vile Familiars",
        "Vile Familiar",
        "Hexed and Voodoo Trolls",
        "Hexed Troll",
        "Voodoo Troll",
        "Venomtail Scorpids",
        "Venomtail Scorpid",
        "Dreadmaw Crocolisks",
        "Dreadmaw Crocolisk",
        "Lightning Hides",
        "Lightning Hide",
        "Thunder Lizards",
        "Thunder Lizard",
        "Felstalkers",
        "Felstalker",
        "Surf Crawler",
        "Armored Scorpid",
        "Sailors and Marines",
        "Sarkoth",
        "Gazz'uz",
        "Halikor",
        "Zalazane",
        "Tazan",
    ],
    key=len,
    reverse=True,
)

LOOT = sorted(
    [
        "Sarkoth's Mangled Claw",
        "Burning Blade Medallion",
        "Thazz'ril's Pick",
        "Foreman's Blackjack",
        "Scorpid Worker Tail",
        "Cactus Apples",
        "Cactus Apple",
        "Canvas Scraps",
        "Aged Envelope",
        "Raider's Battleaxe",
        "Raider's Shield",
        "Raider's Bow",
        "Gnomish Toolboxes",
        "Gnomish Tools",
        "Crawler Mucus",
        "Intact Makrura Eye",
        "Bloodtalon Matriarch Eggs",
        "Minshina's Skull",
        "Zalazane's Head",
        "Forgotten Loa Idols",
        "Durotar Tiger Fur",
        "Taillasher eggs",
        "Taillasher Egg",
        "Prickly Pear Fruit",
        "Stolen Supply Sacks",
        "Sack of Supplies",
        "Fizzle's Claw",
        "Dull Storm Orb",
        "Searing Collars",
        "Searing Collar",
        "Lieutenant's Insignia",
        "Eye of Burning Shadow",
        "Handfuls of Cattails",
        "Handful of Cattails",
        "Speargrass Cuttings",
        "Smooth Boulders",
        "Smooth Boulder",
        "Kron's Amulet",
        "Earth Sapta",
        "Felstalker Hooves",
        "Felstalker Hoof",
        "Reagent Pouch",
        "Taming Rod",
        "Fire Tar",
        "Charged Thunder Lizard Organs",
        "tiger furs",
        "poison sacs",
    ],
    key=len,
    reverse=True,
)

PICK = sorted(
    [
        "Attack Plans",
        "Benedict's Chest",
        "Lost Journal",
        "Stolen Supply Sacks",
    ],
    key=len,
    reverse=True,
)

QUEST = sorted(
    [
        "Your Place In The World",
        "Galgar's Cactus Apple Surprise",
        "Report to Sen'jin Village",
        "Thwarting Kolkar Aggression",
        "Bloodtalon Matriarch",
        "Practical Prey",
        "Forgotten Loa Idols",
        "A Solvent Spirit",
        "Legging It",
        "Minshina's Skull",
        "Report to Orgnil",
        "The Adventurer",
        "The Great Outdoors",
        "Camping 101: Cooking",
        "Dark Storms",
        "Vanquish the Betrayers",
        "Encroachment",
        "Break a Few Eggs",
        "This Fruit Could Bite Back",
        "Carry Your Weight",
        "For Honor",
        "A Peon's Burden",
        "In Favor of Spirituality",
        "Garments of Spirituality",
        "The Admiral's Orders",
        "From The Wreckage",
        "A Missing Hand",
        "Threat from Below",
        "Winds in the Desert",
        "Securing the Lines",
        "Need for a Cure",
        "Finding the Antidote",
        "Conscript of the Horde",
        "Lost But Not Forgotten",
        "Crossroads Conscription",
        "A Simmering Storm",
        "Stormy Potential",
        "Burning Shadows",
        "Hidden Enemies",
        "Neeru Fireblade",
        "Skull Rock",
        "Meal Appeal",
        "Favorite Food",
        "Yelmak's Medley",
        "Whuut's the Rush",
        "Rocks to Rests",
        "Hex of Weakness",
        "The Shattered Hand",
        "Taming the Beast",
        "Training the Beast",
        "Call of Earth",
        "Call of Fire",
        "Cutting Teeth",
        "Sting of the Scorpid",
        "Vile Familiars",
        "Lazy Peons",
        "Burning Blade Medallion",
        "Thazz'ril's Pick",
        "Simple Parchment",
        "Simple Tablet",
        "Etched Parchment",
        "Etched Tablet",
        "Encrypted Parchment",
        "Encrypted Tablet",
        "Rune-Inscribed Parchment",
        "Rune-Inscribed Tablet",
        "Hallowed Tablet",
        "Glyphic Tablet",
        "Glyphic Parchment",
        "Tainted Parchment",
        "Tainted Tablet",
        "Lost in the Shadows",
        "Ak'Zeloth",
        "Margoz",
        "Zalazane",
        "Sarkoth",
    ],
    key=len,
    reverse=True,
)

SMALL = {"of", "the", "a", "an", "in", "to", "for", "from", "and", "or", "on", "at"}


def covered(text: str, start: int, end: int) -> bool:
    i = 0
    while i < len(text):
        if text.startswith("|cRB_", i):
            close = text.find("|r", i)
            if close == -1:
                return False
            if start >= i and end <= close + 2:
                return True
            if start < close + 2 and end > i:
                return True
            i = close + 2
        else:
            i += 1
    return False


def wrap_matches(text: str, kind: str, names: list[str]) -> str:
    for name in names:
        out = []
        last = 0
        lower = text.lower()
        needle = name.lower()
        start = 0
        changed = False
        while True:
            idx = lower.find(needle, start)
            if idx == -1:
                break
            end = idx + len(name)
            left_ok = idx == 0 or not (text[idx - 1].isalnum() or text[idx - 1] == "'")
            right_ok = end >= len(text) or not (text[end].isalnum() or text[end] == "'")
            if left_ok and right_ok and not covered(text, idx, end):
                window = text[max(0, idx - 28) : idx].lower()
                ok = True
                if "side guide" in window or "guide id:" in window:
                    ok = False
                # Loot/pick names that double as quest titles stay quest-colored on accept/turn-in.
                if kind in ("LOOT", "PICK") and re.search(r"(?:accept|turn in)\s+$", window):
                    ok = False
                if ok:
                    out.append(text[last:idx])
                    out.append(f"|cRB_{kind}_{text[idx:end]}|r")
                    last = end
                    changed = True
            start = end
        if changed:
            out.append(text[last:])
            text = "".join(out)
    return text


def wrap_title_case_runs(text: str, verb: str, kind: str) -> str:
    """Talk to / Kill Proper Name Words..."""

    def repl(m: re.Match) -> str:
        name = m.group(1)
        if name.startswith("|cRB_"):
            return m.group(0)
        return f"{verb} |cRB_{kind}_{name}|r"

    # One or more Capitalized tokens; allow internal small words only after first token.
    pattern = re.compile(
        rf"\b{re.escape(verb)} (?!\|cRB_)((?:[A-Z][\w']+)(?:\s+(?:[A-Z][\w']+|{'|'.join(SMALL)}))*?)"
        rf"(?=(?:[.!?,:;]| and | then | if | for | when | while | until | outside | inside | upstairs | near | on | in | at | south|north|east|west| with | from | to |$))"
    )
    return pattern.sub(repl, text)


def wrap_known_quests_after_verbs(text: str) -> str:
    """Tag known quest titles after Accept/Turn in, then keep tagging comma/and lists."""
    for _ in range(12):
        changed = False
        for name in QUEST:
            pattern = re.compile(
                rf"(?:(?:Accept|Turn in)\s+|\|cRB_QUEST_[^|]+\|r\s*(?:,|and)\s+)"
                rf"(?P<name>{re.escape(name)})"
                r"(?=(?:[.!?,:;]| and | then | if | for | when | at | near |$))",
                re.I,
            )
            out = []
            last = 0
            for m in pattern.finditer(text):
                start, end = m.start("name"), m.end("name")
                if covered(text, start, end):
                    continue
                out.append(text[last:start])
                out.append(f"|cRB_QUEST_{m.group('name')}|r")
                last = end
                changed = True
            if out:
                out.append(text[last:])
                text = "".join(out)
        if not changed:
            break
    return text


def wrap_quest_verbs(text: str) -> str:
    return wrap_known_quests_after_verbs(text)


def tag_string(text: str) -> str:
    # Quest titles first so loot substrings cannot split them.
    text = wrap_quest_verbs(text)
    text = wrap_matches(text, "PICK", PICK)
    text = wrap_matches(text, "LOOT", LOOT)
    text = wrap_title_case_runs(text, "Talk to", "FRIENDLY")
    text = wrap_title_case_runs(text, "Kill", "ENEMY")
    text = wrap_matches(text, "FRIENDLY", FRIENDLY)
    text = wrap_matches(text, "ENEMY", ENEMY)
    return text


STRING_RE = re.compile(r'(text|note)\s*=\s*"((?:\\.|[^"\\])*)"')
DETAIL_RE = re.compile(r'^(\s*)"((?:\\.|[^"\\])*)"(\s*,?\s*)$')


def process_file(path: Path) -> None:
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    in_details = False
    for line in lines:
        if re.search(r"details\s*=\s*\{", line):
            in_details = True
            out.append(line)
            continue
        if in_details:
            if re.search(r"^\s*\},?\s*$", line):
                in_details = False
                out.append(line)
                continue
            m = DETAIL_RE.match(line.rstrip("\n\r"))
            if m:
                indent, raw, suffix = m.group(1), m.group(2), m.group(3)
                tagged = tag_string(raw)
                # Detail lines that are pure quest/item/mob labels: tag via dictionaries.
                if "|cRB_" not in tagged:
                    tagged = wrap_matches(tagged, "LOOT", LOOT)
                    tagged = wrap_matches(tagged, "ENEMY", ENEMY)
                    tagged = wrap_matches(tagged, "FRIENDLY", FRIENDLY)
                    tagged = wrap_matches(tagged, "PICK", PICK)
                    # "Turn in Quest" details
                    tagged = wrap_quest_verbs(tagged)
                out.append(f'{indent}"{tagged}"{suffix}\n')
                continue
            out.append(line)
            continue

        def repl(m: re.Match) -> str:
            return f'{m.group(1)} = "{tag_string(m.group(2))}"'

        out.append(STRING_RE.sub(repl, line))
    path.write_text("".join(out), encoding="utf-8", newline="\n")
    print(f"Tagged {path.name}")


def main() -> None:
    for path in FILES:
        process_file(path)


if __name__ == "__main__":
    main()
