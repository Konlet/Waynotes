import re
from pathlib import Path

root = Path(r"d:/!Mods/RestedXP-Better/Guides/Forever")

CLEANUP = re.compile(
    r"^(?:"
    r"\[.*?\]\s*"
    r")*"
    r"(?:"
    r"Optional:\s*)?"
    r"(?:"
    r"Destroy .+"
    r"|Delete .+"
    r"|You can delete .+"
    r")$",
    re.I,
)

KEEP = re.compile(
    r"Attack Plan|Flying Machine|Hillsbrad Proclamation|Eggs? of Onyxia|"
    r"Command Tent|Ju-ju Heap|Bael Modan|Core Fragment|Morphaz|"
    r"Power to Destroy|Scourge Banner|Fireguard Destroyer|Burning Destroyer|"
    r"Incendrites|Collect ",
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
        t = t.strip()
        if KEEP.search(t):
            return False
        if not CLEANUP.match(t):
            return False
        # Must be inventory cleanup, not a kill/click objective sentence that
        # happens to include Destroy as a quest verb mid-route.
        if not re.search(
            r"\b(?:Destroy|Delete)\b.+\b(?:from your bags|no longer need|These Items|Hearthstone|Parchment|Potion|Scroll|Manual|Package|Ore|Shrinker|Photograph|Torch|Canteen|Elixir|Bottle|Beacon|Journal|Carapace|Seeds|Horn|Whistle|Flare Gun|Water of the Seers|Prospector)",
            t,
            re.I,
        ) and not re.match(
            r"^(?:\[.*?\]\s*)*(?:Optional:\s*)?(?:Destroy|Delete|You can delete)\b",
            t,
            re.I,
        ):
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

print("\nRemaining Destroy/Delete/no longer needed steps:")
for path in sorted(root.rglob("*.lua")):
    for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if 'text = "' not in line:
            continue
        if re.search(r"Destroy |Delete |no longer need", line, re.I):
            print(f"  {path.relative_to(root).as_posix()}:{i}: {line.strip()[:140]}")
