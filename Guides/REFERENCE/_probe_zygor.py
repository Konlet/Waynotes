import re
from pathlib import Path

p = Path(__file__).with_name("ZygorLevelingHordeCLASSIC.lua")
text = p.read_text(encoding="utf-8", errors="replace")
guides = re.findall(r'ZygorGuidesViewer:RegisterGuide\("([^"]+)"', text)
print(len(guides), "guides")
for g in guides:
    print(g)
