import re
from pathlib import Path
lines = Path(r"d:\!Mods\RestedXP-Better\Replace.lua").read_text(encoding="utf-8").splitlines()

# Find end of first do block starting line 12
stack = [("do", 12)]
for i in range(12, len(lines)):
    raw = lines[i]
    code = raw.split("--")[0]
    code = re.sub(r'"([^"\\]|\\.)*"', '""', code)
    code = re.sub(r"'([^'\\]|\\.)*'", "''", code)
    # find keywords as whole words
    for m in re.finditer(r"\b(function|then|do|repeat|end|until)\b", code):
        kw = m.group(1)
        if kw in ("function", "then", "do", "repeat"):
            # 'for ... do' and 'while ... do' already counted as do
            # avoid double: if line has for/while and do, only do matters for block
            stack.append((kw, i + 1))
        elif kw == "until":
            while stack and stack[-1][0] != "repeat":
                stack.pop()
            if stack:
                stack.pop()
        elif kw == "end":
            if stack:
                kind, start = stack.pop()
                if start == 12 and kind == "do" and not stack:
                    print("first do ends at", i + 1)
                    break
    else:
        continue
    break

# Count active locals in main function using a proper-ish parser
# Per-function active local stacks
class Func:
    def __init__(self, name, line):
        self.name = name
        self.line = line
        self.blocks = [[]]  # stack of lists of local names in block
        self.max_active = 0
        self.max_line = 0
    def active(self):
        return sum(len(b) for b in self.blocks)
    def add_local(self, name, line):
        self.blocks[-1].append(name)
        a = self.active()
        if a > self.max_active:
            self.max_active = a
            self.max_line = line

funcs = [Func("main", 1)]
# block kinds stack parallel to open blocks that affect locals: each opens a block on funcs[-1]
# function opens new Func; then/do/repeat open block on current func

pending_function = None  # name

def strip(code):
    code = code.split("--")[0]
    code = re.sub(r'"([^"\\]|\\.)*"', '""', code)
    code = re.sub(r"'([^'\\]|\\.)*'", "''", code)
    return code

for i, raw in enumerate(lines, 1):
    code = strip(raw)
    if not code.strip():
        continue

    # local declarations before processing ends on same line carefully
    s = code.strip()

    # local function name
    m = re.match(r"^local\s+function\s+([A-Za-z_][\w:]*)\s*\(", s)
    if m:
        funcs[-1].add_local(m.group(1).split(":")[-1], i)
        funcs.append(Func(m.group(1), i))
        funcs[-1].blocks.append([])  # params block - simplify: params counted separately
        # parse params
        params = s.split("(", 1)[1].rsplit(")", 1)[0]
        for p in params.split(","):
            p = p.strip()
            if p and p != "...":
                funcs[-1].add_local(p, i)
        continue

    m = re.match(r"^function\s+([A-Za-z_][\w.:]*)\s*\(", s)
    if m:
        funcs.append(Func(m.group(1), i))
        params = s.split("(", 1)[1].rsplit(")", 1)[0]
        for p in params.split(","):
            p = p.strip()
            if p and p != "...":
                funcs[-1].add_local(p, i)
        continue

    # anonymous function assigned - handle "local x = function(" 
    m = re.match(r"^local\s+([^=]+)=\s*function\s*\(", s)
    if m:
        left = m.group(1)
        for part in left.split(","):
            name = part.strip()
            if name:
                funcs[-1].add_local(name, i)
        funcs.append(Func("<anon@"+str(i)+">", i))
        params = s.split("function", 1)[1]
        params = params.split("(", 1)[1].rsplit(")", 1)[0]
        for p in params.split(","):
            p = p.strip()
            if p and p != "...":
                funcs[-1].add_local(p, i)
        continue

    if re.match(r"^local\s+", s) and "function" not in s.split("=",1)[0]:
        rest = s[6:]
        left = rest.split("=", 1)[0]
        for part in left.split(","):
            name = part.strip()
            if name:
                funcs[-1].add_local(name, i)
        # if RHS has function( later on same line
        if re.search(r"=\s*function\s*\(", s):
            funcs.append(Func("<anon@"+str(i)+">", i))
            params = s.split("function", 1)[1].split("(",1)[1].rsplit(")",1)[0]
            for p in params.split(","):
                p=p.strip()
                if p and p != "...":
                    funcs[-1].add_local(p,i)
            continue

    # control keywords
    # process all keywords in order
    for m in re.finditer(r"\b(function|then|do|repeat|end|until)\b", code):
        kw = m.group(1)
        if kw == "function":
            # might be inline already handled; if inline mid-expression
            # skip if we already created from local function / function at start
            # For mid-line: create anon
            prefix = code[:m.start()].strip()
            if prefix.endswith("=") or prefix.endswith("(") or prefix.endswith("{") or prefix.endswith(",") or prefix=="":
                # likely already handled if line started with local/function
                if not re.match(r"^(local\s+)?function\b", s) and not re.search(r"local\s+.*=\s*function\s*\(", s):
                    funcs.append(Func(f"<inline@{i}>", i))
        elif kw in ("then", "do", "repeat"):
            # for/while do opens block; then opens block
            funcs[-1].blocks.append([])
        elif kw == "until":
            # close until repeat
            if len(funcs[-1].blocks) > 1:
                funcs[-1].blocks.pop()
        elif kw == "end":
            if len(funcs[-1].blocks) > 1:
                funcs[-1].blocks.pop()
            else:
                # end of function
                if len(funcs) > 1:
                    finished = funcs.pop()
                else:
                    pass

main = funcs[0]
print("main max active", main.max_active, "at line", main.max_line)
print("current active", main.active(), "blocks", len(main.blocks))
print("top-level locals sample count", len(main.blocks[0]))
print("last 40 main locals:")
for name in main.blocks[0][-40:]:
    print(" ", name)
print("total main locals in root block", len(main.blocks[0]))
