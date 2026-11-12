import re
from pathlib import Path

root = Path(__file__).parent / "Dungeons"
for path in sorted(root.glob("*.lua")):
    text = path.read_text(encoding="utf-8", errors="replace")
    guides = re.findall(r'ZygorGuidesViewer:RegisterGuide\("([^"]+)"', text)
    print(f"\n{path.name}: {len(guides)} guides, {len(text.splitlines())} lines")
    for g in guides[:40]:
        print(" ", g.replace("\\\\", "\\"))
    if len(guides) > 40:
        print(f"  ... +{len(guides)-40} more")
