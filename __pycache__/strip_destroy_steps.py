import re
from pathlib import Path

root = Path(r"d:/!Mods/RestedXP-Better/Guides/Forever")

# Whole-step inventory cleanup. Keep quest objectives like Attack Plans.
CLEANUP = re.compile(
    r"^(?:"
    r"\[.*?\]\s*"
    r")*"
    r"(?:"
    r"Destroy Hearthstone\.?"
    r"|Destroy Inert Potion\.?"
    r"|Destroy Water of the Seers\.?"
    r"|Destroy Belamoore's Research Journal\.?"
    r"|Destroy Cracked Silithid Carapace\.?"
    r"|Destroy Control Console Operating Manual\.?"
    r"|Destroy Horn of Echeyakee\.?"
    r"|Destroy Dried Seeds\.?"
    r"|Destroy Kodo Skin Scroll\.?"
    r"|Destroy Gadgetzan Water Co\. Care Package\.?"
    r"|Destroy Sample of Indurium Ore\.?"
    r"|Destroy Zorbin's Ultra-Shrinker\.?"
    r"|Destroy Faded Photograph\. Destroy Heavy Throwing Dagger\.?"
    r"|Destroy Torch of Retribution\.?"
    r"|Destroy Spraggle's Canteen\.?"
    r"|Destroy Crystal Pylon User's Manual\.?"
    r"|Destroy Videre Elixir\.?"
    r"|Destroy Flame in a Bottle\.?"
    r"|Destroy Beacon Torch\.?"
    r"|Destroy These Items\..+"
    r"|Destroy or Sell These Items\..+"
    r")$",
    re.I,
)

step_re = re.compile(
    r"\n(?P<indent>[ \t]*)\{\n(?P<body>.*?)\n(?P=indent)\},",
    re.S,
)


def is_cleanup_step(body: str) -> bool:
    texts = re.findall(r'text\s*=\s*"((?:\\.|[^"\\])*)"', body)
    if not texts:
        return False
    for t in texts:
        if "Attack Plan" in t:
            return False
        if not CLEANUP.match(t.strip()):
            return False
    return True


changed = []
for path in sorted(root.rglob("*.lua")):
    text = path.read_text(encoding="utf-8")
    removed = [0]

    def repl(m: re.Match) -> str:
        if is_cleanup_step(m.group("body")):
            removed[0] += 1
            return ""
        return m.group(0)

    new = step_re.sub(repl, text)
    if removed[0]:
        path.write_text(new, encoding="utf-8", newline="\n")
        changed.append((path.relative_to(root).as_posix(), removed[0]))

print(f"Files changed: {len(changed)}")
for p, n in changed:
    print(f"  {p}: removed {n}")

# Verify leftovers
print("\nRemaining Destroy steps:")
for path in sorted(root.rglob("*.lua")):
    for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if 'text = "' in line and "Destroy" in line:
            print(f"  {path.relative_to(root).as_posix()}:{i}: {line.strip()}")
