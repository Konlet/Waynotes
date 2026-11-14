import re
from pathlib import Path

root = Path(r"d:\!Mods\Waynotes\Guides\Forever\Curated")

# Exact / prefix match for notes that are only skip guidance.
drop_prefixes = (
    "Skip freely",
    "Skip if",
    "Skip the",
    "Skip steps",
    "Optional. Skip",
    "Optional XP.",
    "Optional deathskip",
)

drop_contains = (
    "are optional and skipped",
    "is optional and skipped",
    "optional Orgrimmar food chain is skipped",
    "Press Next to skip",
    "Optional. Press Next",
    "Press Next.",
    "Press Next when",
    "Press Next after",
    "Press Next if you walk",
)

note_re = re.compile(r'^(\s*)note\s*=\s*"([^"]*)"(,?\s*)$')
trim_skip_tail = re.compile(
    r"(?i)\.\s+Skip\b[^.]*\.?\s*$"
)
trim_press_next_tail = re.compile(
    r"(?i)\.\s+Press\s+Next(?:\s+to\s+skip)?[^.]*\.?\s*$"
)
text_skip_tail = re.compile(
    r"(?i)(?:,?\s*|\.\s+)Skip(?:\s+freely)?(?:\s+if|\s+and)?[^.]*\.?(?:\s*then\s+press\s+Next\.?)?\s*$"
)

changed = []

for path in sorted(root.glob("*.lua")):
    if path.name.startswith("Professions_"):
        continue
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines(keepends=True)
    out = []
    dirty = False
    for line in lines:
        raw = line.rstrip("\r\n")
        m = note_re.match(raw)
        if m:
            indent, note, comma = m.group(1), m.group(2), m.group(3)
            plain = re.sub(r"\|c[^|]*\|r", lambda mm: re.sub(r"\|c[^|]+\|?", "", mm.group(0)).replace("|r", ""), note)
            plain = re.sub(r"\|cRB_[^|]*\|r", "", note)
            plain = re.sub(r"\|cRB_[^|]*", "", plain)
            plain = plain.replace("|r", "").strip()

            should_drop = False
            for p in drop_prefixes:
                if plain.startswith(p) or note.startswith(p):
                    should_drop = True
                    break
            if not should_drop:
                for c in drop_contains:
                    if c.lower() in plain.lower() or c.lower() in note.lower():
                        # Only drop if the note is mostly that guidance.
                        if len(plain) < 120 or plain.lower().startswith("optional") or "press next" in plain.lower():
                            should_drop = True
                            break
            if should_drop:
                changed.append(f"DROP {path.name}: {note}")
                dirty = True
                continue

            new_note = note
            new_note2 = trim_skip_tail.sub(".", new_note)
            if new_note2 != new_note:
                new_note = new_note2.rstrip()
                if new_note.endswith(".."):
                    new_note = new_note[:-1]
                changed.append(f"TRIM {path.name}: {note} -> {new_note}")
            new_note2 = trim_press_next_tail.sub(".", new_note)
            if new_note2 != new_note:
                new_note = new_note2.rstrip()
                if new_note.endswith(".."):
                    new_note = new_note[:-1]
                changed.append(f"TRIM {path.name}: {note} -> {new_note}")

            # Restore trailing period if we accidentally lack one on a prose note.
            if new_note and not new_note.endswith((".", "!", "?", "|r")):
                new_note += "."
                dirty = True

            if new_note != note:
                dirty = True
                line = f'{indent}note = "{new_note}"{comma}\n'
                if f"TRIM {path.name}: {note} -> {new_note}" not in changed and not note.endswith((".", "|r")):
                    changed.append(f"PERIOD {path.name}: {note} -> {new_note}")

        tm = re.match(r'^(\s*text\s*=\s*")(.*)(",?\s*)$', raw)
        if tm:
            body = tm.group(2)
            if re.search(r"(?i)\boptional\b", body) and re.search(r"(?i)\bskip\b", body):
                new_body = text_skip_tail.sub("", body).rstrip(" ,")
                if new_body and new_body != body:
                    if not new_body.endswith((".", "!", "?", "|r")):
                        new_body += "."
                    changed.append(f"TEXT {path.name}")
                    line = f'{tm.group(1)}{new_body}{tm.group(3)}\n'
                    dirty = True

        out.append(line if line.endswith("\n") else line + "\n")

    if dirty:
        path.write_text("".join(out), encoding="utf-8")

print(f"{len(changed)} edits")
for c in changed:
    print(c)
