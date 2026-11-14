from pathlib import Path
import re

text = Path(r"d:\!Mods\Waynotes\_questiedb\data\Forever\foreverNpcDB.lua").read_text(
    encoding="utf-8", errors="ignore"
)
ot = Path(r"d:\!Mods\Waynotes\_questiedb\data\Forever\foreverObjectDB.lua").read_text(
    encoding="utf-8", errors="ignore"
)

names = [
    "Wenikee Boltbucket",
    "Darsok Swiftdagger",
    "Omusa Thunderhorn",
    "Brewmaster Drohn",
    "Innkeeper Byula",
    "Isha Awak",
]
for name in names:
    m = re.search(re.escape(name), text)
    if not m:
        print("MISS NPC", name)
        continue
    chunk = text[max(0, m.start() - 120) : m.start() + 260]
    print(name, "=>", chunk.replace("\n", " ")[:280])
    print()

for name in [
    "Control Console",
    "Stolen Silver",
    "Beaten Corpse",
    "Chen's Empty Keg",
    "Bubbling Fissure",
]:
    m = re.search(re.escape(name), ot)
    if not m:
        print("MISS OBJ", name)
        continue
    chunk = ot[max(0, m.start() - 120) : m.start() + 280]
    print(name, "=>", chunk.replace("\n", " ")[:320])
    print()
