import re
from pathlib import Path

root = Path(r"d:\!Mods\Waynotes\Guides\Forever\Curated")
note_re = re.compile(r'^(\s*)note\s*=\s*"([^"]*)",?\s*$')
# Notes that only tell the player they can skip.
skip_note_re = re.compile(
    r"(?is)^\s*(?:\|cRB_WARN_)?(?:optional\.\s*)?skip(?:\s+freely)?(?:\s|$|[.,])"
    r"|^\s*(?:\|cRB_WARN_)?optional\.\s*skip"
)

# Also strip trailing skip clauses from step text when Optional: already labels it.
text_skip_clause_re = re.compile(
    r"(?i)(?:,?\s*|\.\s+)Skip(?:\s+freely)?(?:\s+if|\s+and)?[^.]*\.?(?:\s*then\s+press\s+Next\.?)?\s*$"
)

removed_notes = []
changed_texts = []

for path in sorted(root.glob("*.lua")):
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    out = []
    dirty = False
    for line in lines:
        m = note_re.match(line.rstrip("\r\n"))
        if m:
            note = m.group(2).strip()
            plain = re.sub(r"\|cRB_[^|]*\|r", "", note)
            plain = re.sub(r"\|c[0-9A-Fa-f]{8}", "", plain)
            plain = plain.replace("|r", "").strip()
            if skip_note_re.search(plain) or skip_note_re.search(note):
                removed_notes.append(f"{path.name}: {note}")
                dirty = True
                continue
        # Clean "..., Skip if ...." from Optional step text.
        tm = re.match(r'^(\s*text\s*=\s*")(.*)(",?\s*)$', line.rstrip("\r\n"))
        if tm:
            prefix, body, suffix = tm.group(1), tm.group(2), tm.group(3)
            if re.search(r"(?i)\boptional\b", body) and re.search(r"(?i)\bskip\b", body):
                new_body = text_skip_clause_re.sub("", body).rstrip(" ,.")
                if new_body != body and new_body:
                    # Keep a period at end of sentence if it still looks like prose.
                    if not new_body.endswith((".", "!", "?", "|r")):
                        new_body += "."
                    changed_texts.append(f"{path.name}: {body} -> {new_body}")
                    line = prefix + new_body + suffix + ("\n" if line.endswith("\n") else "")
                    dirty = True
        out.append(line if line.endswith("\n") or not lines else line)
    # Normalize: ensure we preserve final newline if original had one
    text = "".join(out)
    if dirty:
        if path.read_text(encoding="utf-8").endswith("\n") and not text.endswith("\n"):
            text += "\n"
        path.write_text(text, encoding="utf-8")

print(f"removed {len(removed_notes)} notes")
for s in removed_notes:
    print("  -", s)
print(f"cleaned {len(changed_texts)} texts")
for s in changed_texts:
    print("  -", s)
