from pathlib import Path
import re
lines = Path(r"d:\!Mods\RestedXP-Better\Replace.lua").read_text(encoding="utf-8").splitlines()

# Count root-level local declarations after line 1183 (tracker section) that remain in scope.
# Heuristic: locals whose indentation is 0 (start of line is "local ").
names = []
for i, raw in enumerate(lines, 1):
    if i <= 1183:
        continue
    if raw.startswith("local function "):
        name = raw[len("local function "):].split("(",1)[0].strip()
        names.append((i, name))
    elif raw.startswith("local "):
        rest = raw[6:].split("--",1)[0]
        if rest.startswith("function "):
            name = rest[9:].split("(",1)[0].strip()
            names.append((i, name))
            continue
        left = rest.split("=",1)[0]
        for part in left.split(","):
            name = part.strip()
            if name:
                names.append((i, name))

print("tracker-section top-level locals:", len(names))
# Plus forward decls still active from lines 1-8
fwd = 1+1+1+5+5+5+2  # addonName,ns,lastSignature + groups
print("approx forward from header:", 3+5+5+5+2)
print("approx total active if all tracker locals stay:", len(names) + 3+5+5+5+2)
print("\nAll tracker locals:")
for item in names:
    print(f"  {item[0]}: {item[1]}")
