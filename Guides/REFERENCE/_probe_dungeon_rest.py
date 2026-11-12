import re
from pathlib import Path

for name in ("ZygorDungeonHordeCLASSIC.lua", "ZygorDungeonAllianceCLASSIC.lua"):
    text = (Path(__file__).parent / "Dungeons" / name).read_text(encoding="utf-8", errors="replace")
    guides = [g.replace("\\\\", "\\") for g in re.findall(r'ZygorGuidesViewer:RegisterGuide\("([^"]+)"', text)]
    print(f"\n=== {name} ({len(guides)}) ===")
    for g in guides:
        print(g)
