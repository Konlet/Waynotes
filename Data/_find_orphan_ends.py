from pathlib import Path
import re

lines = Path(r"d:/!Mods/RestedXP-Better/Replace.lua").read_text(encoding="utf-8").splitlines()

# Find top-level-looking 'end' that aren't closing a top-level function/do,
# and find indented blocks that appear between top-level functions.
# Also list top-level constructs.

top = []
for i, line in enumerate(lines, 1):
    if re.match(r"^(local )?function |^do$|^end$|^ns\.|^tracker:|^function ns\.", line):
        top.append((i, line[:100]))

print("Top-level markers:")
for item in top:
    print(f"{item[0]:4d} {item[1]}")

# Detect sequences: blank line, indented code, end - outside function
print("\nSuspicious indented chunks at column>=4 after a top-level end:")
prev_top_end = False
chunk = []
for i, line in enumerate(lines, 1):
    if line.startswith("end") and not line.startswith("end)"):
        # could be top-level end
        if not line.startswith(" ") and not line.startswith("\t"):
            prev_top_end = True
            if chunk:
                print("--- chunk before", i)
                for c in chunk[:15]:
                    print(c)
                chunk = []
            continue
    if prev_top_end:
        if line.strip() == "":
            continue
        if line.startswith(" ") or line.startswith("\t"):
            chunk.append((i, line[:100]))
        else:
            prev_top_end = False
            chunk = []
