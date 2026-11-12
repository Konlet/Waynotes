import re
from pathlib import Path

root = Path(r"d:/!Mods/RestedXP-Better")
ref = (root / "Guides/REFERENCE/Horde-01-12_Durotar.lua").read_text(encoding="utf-8", errors="replace")
parts = re.split(r"RXPGuides\.RegisterGuide", ref)
durotar = []
for p in parts[1:]:
    name = re.search(r"#name\s+(.+)", p)
    n = name.group(1).strip() if name else "?"
    if "Tirisfal" in n:
        continue
    durotar.append((n, p))

active_accept = set()
commented_accept = set()
active_turnin = set()
accept_names = {}
for _, p in durotar:
    for line in p.splitlines():
        s = line.strip()
        m = re.match(r"(--)?\s*\.(accept|turnin)\s+(\d+)(?:\s*,\d+)?\s*>>\s*(Accept|Turn in)\s*(.+)?", s, re.I)
        if not m:
            m2 = re.match(r"(--)?\s*\.(accept|turnin)\s+(\d+)", s)
            if not m2:
                continue
            commented = bool(m2.group(1))
            kind = m2.group(2)
            q = int(m2.group(3))
            title = "?"
        else:
            commented = bool(m.group(1))
            kind = m.group(2)
            q = int(m.group(3))
            title = (m.group(5) or "?").strip()
        if kind == "accept":
            accept_names.setdefault(q, title)
            if commented:
                commented_accept.add(q)
            else:
                active_accept.add(q)
        else:
            if not commented:
                active_turnin.add(q)

cur = (root / "Guides/Forever/Horde_Durotar_Curated.lua").read_text(encoding="utf-8")
cls = (root / "Guides/Forever/Horde_Durotar_ClassQuests.lua").read_text(encoding="utf-8")
both = cur + "\n" + cls

covered = set(int(x) for x in re.findall(r"quest\s*=\s*(\d+)", both))
for block in re.findall(r"quests\s*=\s*\{([^}]+)\}", both):
    covered.update(int(n) for n in re.findall(r"\d+", block))
covered.update(int(x) for x in re.findall(r"\b[Qq]uests?\s+(\d{3,5})\b", both))
for m in re.finditer(r"\b[Qq]uests?\s+((?:\d{3,5})(?:(?:\s*,\s*|\s+and\s+)\d{3,5})*)", both):
    covered.update(int(n) for n in re.findall(r"\d+", m.group(1)))

missing = sorted(active_accept - covered)
print("RXP Durotar sections:", ", ".join(n for n, _ in durotar))
print("Active accepts in RXP Durotar:", len(active_accept))
print("Covered in curated+class:", len(covered & (active_accept | active_turnin | commented_accept)))
print("Missing active accepts:", len(missing))
for q in missing:
    print(f"  {q}: {accept_names.get(q, '?')}")
print("RXP commented accepts:", sorted(commented_accept))
print("Covered note/quest ids not in RXP accept set:", sorted(covered - active_accept))
