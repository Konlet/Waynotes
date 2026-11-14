import re
from pathlib import Path

files = list(Path(r"d:\!Mods\Waynotes\Guides\Forever\Curated").glob("Horde_*.lua"))
files += list(Path(r"d:\!Mods\Waynotes\Guides\Forever\Curated").glob("Skyborne_*.lua"))

note_re = re.compile(r'^(\s*)note\s*=\s*"([^"]*)"(,?\s*)$')
# Drop whole notes that are only skip / press-next guidance.
drop_whole = re.compile(
    r"(?is)^\s*(?:\|cRB_WARN_)?(?:optional(?:\s+xp)?\.\s*)?(?:press\s+next\s+to\s+skip\b|skip\b)"
    r"|^\s*optional(?:\s+xp)?\.\s*press\s+next"
    r"|^\s*.*\bare optional and skipped\b"
    r"|^\s*the optional\b.*\biskipped\b"
    r"|^\s*optional deathskip\b"
    r"|^\s*.*press\s+next\s+to\s+skip\b"
    r"|^\s*.*press\s+next\s+if\s+you\s+walk\b"
)

# Trim trailing skip clauses from otherwise useful notes.
trim_skip = re.compile(
    r"(?i)(?:\s*[.|]\s*|\s+)Skip\b[^.|]*\.?(?:\s*Press\s+Next[^.|]*)?\s*(?:\|r)?\s*$"
)
trim_press_next = re.compile(r"(?i)\s*\.?\s*Press\s+Next(?:\s+to\s+skip)?[^.|]*\.?\s*$")

changed = []

for path in files:
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    dirty = False
    for line in lines:
        raw = line.rstrip("\r\n")
        m = note_re.match(raw)
        if m:
            indent, note, comma = m.group(1), m.group(2), m.group(3)
            plain = re.sub(r"\|cRB_[^|]*", "", note)
            plain = re.sub(r"\|r", "", plain)
            plain = re.sub(r"\|c[0-9A-Fa-f]{8}", "", plain).strip()

            if drop_whole.search(plain) or drop_whole.search(note):
                changed.append(f"DROP {path.name}: {note}")
                dirty = True
                continue

            new_note = note
            new_note = trim_skip.sub("", new_note)
            new_note = trim_press_next.sub("", new_note)
            new_note = new_note.rstrip(" .")
            # Restore warn close tag if we stripped it.
            if "|cRB_WARN_" in new_note and not new_note.endswith("|r"):
                new_note += "|r"
            if new_note != note:
                if new_note.strip() == "" or new_note.strip() in ("|cRB_WARN_|r", "|cRB_WARN_.|r"):
                    changed.append(f"DROP {path.name}: {note}")
                    dirty = True
                    continue
                changed.append(f"TRIM {path.name}: {note} -> {new_note}")
                line = f'{indent}note = "{new_note}"{comma}\n'
                dirty = True
        # Fix missing terminal period on Optional texts.
        tm = re.match(r'^(\s*text\s*=\s*")(.+)(",?\s*)$', raw)
        if tm:
            body = tm.group(2)
            if body.startswith("Optional:") and not body.endswith((".", "!", "?", "|r", '"')):
                line = f'{tm.group(1)}{body}.{tm.group(3)}\n'
                dirty = True
                changed.append(f"PERIOD {path.name}")
        out.append(line if line.endswith("\n") else line + "\n")

    if dirty:
        text = "".join(out)
        path.write_text(text, encoding="utf-8")

print(f"{len(changed)} edits")
for c in changed:
    print(c)
