#!/usr/bin/env python3
"""Display-layer review sheet: the goal's conditions, the five arcs that serve it,
every roster row by kind, and the 61-row gap roster with what is rostered and what
is not. Scoped deliberately: this is the display layer, not the tree."""
import re, os, glob, collections, subprocess, datetime

ROOT = "/workspace/chirality"
ARCS = ["display-calculus", "terminal", "canvas", "native-window", "native-document"]
def rd(p): return open(os.path.join(ROOT, p), encoding="utf-8").read()
def cells(s): return [c.strip() for c in s.split("|")]
def trunc(s, n=480):
    s = " ".join(s.split())
    return s if len(s) <= n else s[:n].rsplit(" ", 1)[0] + " …"

# ---- ledger + catalog ----
ledger, cat, cols = {}, None, None
for line in rd("docs/elements/ledger.md").splitlines():
    m = re.match(r"^##\s+(.+?)\s*$", line)
    if m and "·" in m.group(1):
        cat = re.sub(r"\s*\*\(.*?\)\*", "", m.group(1)).strip(); continue
    if re.match(r"^\|\s*(E#|Slot)\s*\|", line):
        cols = cells(line.strip().strip("|")); continue
    if not re.match(r"^\|\s*E\d+\s*\|", line) or not cols: continue
    p = cells(line.strip().strip("|")); n = len(cols)
    ti = cols.index("Title") if "Title" in cols else len(cols) - 1
    if len(p) > n:
        x = len(p) - n; p = p[:ti] + ["|".join(p[ti:ti+x+1])] + p[ti+x+1:]
    p += [""] * (n - len(p))
    r = dict(zip(cols, p)); e = r.get("E#") or r.get("Slot")
    if e and e not in ledger:
        raw = re.sub(r"[*`]", "", r.get("State", "")).strip()
        tok = raw.split()[0].lower().rstrip(".,:;") if raw else ""
        st = tok if tok in ("built","design","flight","superseded","part") else ("no-state" if not raw else "unparsed")
        ledger[e] = dict(state=st, note=raw[len(raw.split()[0]):].strip() if raw and st!="unparsed" else raw,
                         module=r.get("Module",""), category=cat or "?", title=r.get("Title",""))
catalog = {}
for line in rd("docs/elements/catalog.md").splitlines():
    m = re.match(r"^\|\s*(E\d+)\s*\|\s*(.+?)\s*\|", line)
    if m and m.group(1) not in catalog: catalog[m.group(1)] = m.group(2).strip()

specs = {m.group(1) for p in glob.glob(os.path.join(ROOT,"docs/elements/specs/*.md"))
         if (m := re.match(r"^(E\d+)-", os.path.basename(p)))}
designs = {os.path.basename(p)[:-3] for p in glob.glob(os.path.join(ROOT,"docs/arcs/parts/*.md"))}

# ---- author calls ----
calls = []
for line in rd("records/author-calls.md").splitlines():
    m = re.match(r"^\|\s*`?([a-z]+)`?\s*\|\s*\*\*(.+?)\*\*", line)
    if m: calls.append(dict(state=m.group(1), title=m.group(2), body=line))

# ---- arc rows ----
arc_rows = collections.OrderedDict()
arc_goal = {}
for a in ARCS:
    f = f"docs/arcs/{a}-arc.md"
    gs = []
    for ln in rd(f)[:6000].splitlines():
        if re.match(r"^-\s+goals?:", ln): gs += re.findall(r"goals/([a-z-]+)", ln)
    arc_goal[a] = list(dict.fromkeys(gs)) or ["UNSTATED"]
    rows = []
    for line in open(os.path.join(ROOT, f), encoding="utf-8"):
        m = re.match(r"^\|\s*`([a-z-]+)/([A-Z]+\d+)`\s*\|(.*)\|\s*$", line)
        if not m: continue
        c = cells(m.group(3))
        if len(c) < 7: continue
        ids = re.findall(r"[EST]\d+[a-z]?", c[-1])
        rows.append(dict(arc=a, rid=f"{m.group(1)}/{m.group(2)}", local=m.group(2),
                         what=c[0], group=c[1], kind=c[2].strip("`"), origin=c[3],
                         req=c[4], state=c[-2].strip("` "), elems=ids,
                         flagged="⚑" in line))
    arc_rows[a] = rows

# ---- the 61-row gap roster ----
gap, lane, lane_title = [], None, {}
for line in rd(".planning/DISPLAY-LAYER-GAP.md").splitlines():
    m = re.match(r"^###\s+Lane\s+([A-Z])\s+·\s+(.*)$", line)
    if m:
        lane = m.group(1); lane_title[lane] = m.group(2).strip(); continue
    m = re.match(r"^\|\s*([A-Z]\d+)\s*\|(.*)\|\s*$", line)
    if not m or not lane: continue
    c = cells(m.group(2))
    if len(c) < 5: continue
    gap.append(dict(id=m.group(1), lane=lane, goal=c[0].strip("*"),
                    ref=c[1], ours=c[2], kind=re.sub(r"[`*]","",c[3]).strip(),
                    cls=re.sub(r"[`*]","",c[4]).strip()))

dc_local = {r["local"] for r in arc_rows["display-calculus"]}
for g in gap:
    g["rostered"] = g["id"] in dc_local

# ---- the goal's conditions ----
conds = []
txt = rd("docs/goals/display.md")
sec = txt.split("## What done means",1)[1].split("## What condition 2 does not reach")[0]
for m in re.finditer(r"^\d+\.\s+\*\*(.+?)\.\*\*\s*(.*?)(?=^\d+\.\s+\*\*|\Z)", sec, re.M|re.S):
    body = " ".join(m.group(2).split())
    conds.append(dict(name=m.group(1), body=body,
                      unopened="Unopened" in body or "unopened" in body))

def needs(row):
    n = []
    for c in calls:
        hit_t = row["rid"] in c["title"] or any(re.search(rf"\b{e}\b", c["title"]) for e in row["elems"])
        if hit_t:
            mk = "**" if c["state"] in ("unreviewed","open") else ""
            n.append(f"{mk}author call `{c['state']}`{mk}: {trunc(c['title'],150)}")
        elif c["state"] in ("unreviewed","open") and row["rid"] in c["body"]:
            n.append(f"**named in the body of an open author call**: {trunc(c['title'],150)}")
        elif c["state"] in ("unreviewed","open") and any(re.search(rf"\b{e}\b", c["body"]) for e in row["elems"]):
            n.append(f"its element is mentioned in an open author call (may be incidental): {trunc(c['title'],120)}")
    if row["flagged"]: n.append("the roster row carries a ⚑ flag")
    d = f"{row['arc']}-{row['local']}"
    if row["state"] in ("designed","minted") and d not in designs:
        n.append(f"row is `{row['state']}` with no design artifact under `docs/arcs/parts/`")
    if not row["elems"]:
        if row["state"] in ("built","building","designed","specced"):
            n.append(f"**row is `{row['state']}` and names no element** — work happened with nothing minted to carry it")
        else:
            n.append("`unminted` — no element, no SPEC, nothing scheduled")
    for e in row["elems"]:
        rec = ledger.get(e)
        if not rec: n.append(f"`{e}` is named by this row and has **no ledger row**"); continue
        if rec["state"] == "design":
            n.append(f"`{e}` is ledger `design` with a SPEC, build not run" if e in specs
                     else f"**`{e}` is ledger `design`, no SPEC** — minted, unbuilt, unplanned")
        if rec["note"]: n.append(f"`{e}`'s ledger State cell carries prose beside the state: {trunc(rec['note'],240)}")
    return n

head = subprocess.run(["git","-C",ROOT,"rev-parse","--short","HEAD"],capture_output=True,text=True).stdout.strip()
today = datetime.date.today().isoformat()
allrows = [r for a in ARCS for r in arc_rows[a]]
K = collections.Counter(r["kind"] for r in allrows)
S = collections.Counter(r["state"] for r in allrows)
nmint = sum(1 for r in allrows if r["elems"])
gap_un = [g for g in gap if not g["rostered"]]
GK = collections.Counter(g["kind"] for g in gap_un)
dcalls = [c for c in calls if c["state"] in ("unreviewed","open")
          and re.search(r"display|terminal|canvas|render|E128|E199|E200|R3|Terminal", c["body"])]

o=[]; w=o.append
w(f"""# Display layer review sheet

> Generated {today} at `{head}` by `.planning/build-display-review.py`.
> Regenerating overwrites this file and your comments with it.

**Scope: the display layer only.** Five arcs — the two that declare
[[goals/display]] as their goal, and the three that goal names as serving it —
plus the 61-row roster in `.planning/DISPLAY-LAYER-GAP.md`, which is the agent
tier and is where most of this layer still lives.

Rows are grouped by **kind**, because that is your goal's own axis: *"a design
feature arrives as primitives plus tools that harness them"*
(`docs/goals/display.md:36`), and the arc rosters carry a `kind` cell precisely
so a row has to say which half it is.

## The numbers

| | |
|---|---|
| roster rows across the five arcs | **{len(allrows)}** |
| of those, minted | **{nmint}** |
| **of those, never minted** | **{len(allrows)-nmint}** |
| by kind | {", ".join(f"{v} {k}" for k,v in K.most_common())} |
| by row state | {", ".join(f"{v} `{k}`" for k,v in S.most_common())} |
| rows in the gap roster | **{len(gap)}** |
| **gap rows no arc rosters** | **{len(gap_un)}** — {", ".join(f"{v} {k}" for k,v in GK.most_common())} |
| goal conditions | **{len(conds)}**, {sum(1 for c in conds if c['unopened'])} unopened |
| standing author calls touching display | **{len(dcalls)}** |

## How to use it

Every condition, arc, row and lane has a `**Comment:**` line. Nothing here
pre-closes a question.

`KEEP` / `DROP` / `RESCOPE` / `BUILD NEXT` / `NOT MINE` / `ASK ME AGAIN`.

---

## Part 1 · The goal's conditions
""")
for i,c in enumerate(conds,1):
    w(f"\n### Condition {i}: {c['name']}\n")
    w(f"\n{trunc(c['body'],700)}\n")
    if c["unopened"] and "nopened" not in c["body"]:
        w("\n⚑ **Unopened, and it holds no arc file.**\n")
    w("\n- **Comment:** \n")

w("\n---\n\n## Part 2 · The arcs, by kind\n")
for a in ARCS:
    rows = arc_rows[a]
    k = collections.Counter(r["kind"] for r in rows)
    st = collections.Counter(r["state"] for r in rows)
    nm = sum(1 for r in rows if r["elems"])
    w(f"\n## Arc `{a}-arc`\n")
    w(f"\n- **goal** " + ", ".join(f"`{x}`" for x in arc_goal[a]))
    w(f"\n- **rows** {len(rows)} — " + ", ".join(f"{v} {x}" for x,v in st.most_common()))
    w(f"\n- **kinds** " + ", ".join(f"{v} {x}" for x,v in k.most_common()))
    w(f"\n- **minted** {nm} of {len(rows)}")
    if nm == 0: w("\n- ⚑ **this arc has never minted anything**")
    w(f"\n- **Comment on the arc:** \n")
    for kind in ["primitive","tool","law","port","decision"]:
        sub = sorted([r for r in rows if r["kind"] == kind],
                     key=lambda r: (re.match(r"[A-Z]+", r["local"]).group(0),
                                    int(re.sub(r"\D", "", r["local"]))))
        if not sub: continue
        w(f"\n### `{a}` · {kind} ({len(sub)})\n")
        w(f"\n**Comment on this kind:** \n")
        for r in sub:
            tag = " · ".join(f"`{e}` (ledger `{ledger[e]['state']}`)" if e in ledger else f"`{e}` (no ledger row)" for e in r["elems"]) or "**unminted**"
            w(f"\n#### `{r['rid']}` · {kind} · row `{r['state']}` · {tag}\n")
            whole = " ".join(r["what"].split())
            w(f"\n- **what** {whole}")
            w(f"\n- **group** {r['group']} · **origin** {r['origin']} · **serves req** {r['req']}")
            for e in r["elems"]:
                if e in ledger:
                    w(f"\n- **{e}** `{ledger[e]['module'] or '—'}` · {ledger[e]['category']}")
                    w(f"\n  - {trunc(catalog.get(e) or ledger[e]['title'] or '(no summary)',400)}")
            nd = needs(r)
            w("\n- **ruling needs**" if nd else "\n- **ruling needs** none detected")
            for x in nd: w(f"\n  - {x}")
            w(f"\n- **Comment:** \n")

w("\n---\n\n## Part 3 · The gap roster, and what no arc carries\n")
w(f"\n`.planning/DISPLAY-LAYER-GAP.md` holds {len(gap)} rows across "
  f"{len(lane_title)} lanes. **{len(gap_un)} of them are rostered by no arc**, so "
  "they live only in the session tier and nothing in `docs/` knows they exist. "
  "They are marked ✗ below.\n")
w("\n**Comment on the gap roster as a whole:** \n")
for L in sorted(lane_title):
    sub = [g for g in gap if g["lane"] == L]
    if not sub: continue
    un = sum(1 for g in sub if not g["rostered"])
    w(f"\n### Lane {L} · {lane_title[L]}\n")
    w(f"\n{len(sub)} rows, **{un} rostered by no arc**.\n")
    w(f"\n**Comment on the lane:** \n")
    for g in sub:
        mark = "✓ rostered as `display-calculus/"+g["id"]+"`" if g["rostered"] else "✗ **no arc rosters this**"
        w(f"\n#### {g['id']} · {g['kind']} · {mark}\n")
        w(f"\n- **goal** {trunc(g['goal'],200)}")
        w(f"\n- **ours** {trunc(g['ours'],380)}")
        w(f"\n- **class** {g['cls']}")
        w(f"\n- **Comment:** \n")

w("\n---\n\n## Part 4 · Author calls touching display\n")
w(f"\n{len(dcalls)} of the standing calls mention this layer.\n")
w("\n**Comment on the call queue:** \n")
for c in dcalls:
    w(f"\n- `{c['state']}` — {trunc(c['title'],200)}\n  - **Comment:** ")
w("""

⚑ **One display call is not in that list and cannot be**, because no register
carries it: the `Fix d` × `Fix d` question that blocks `display-calculus/R10`
from minting lives only in `docs/arcs/parts/display-calculus-R10.md:280`. A
design run may not write to `records/`, so check AK cannot see it.

- **Comment:** 
""")

dest = os.path.join(ROOT, ".planning/DISPLAY-REVIEW.md")
open(dest,"w",encoding="utf-8").write("".join(o))
print("wrote", dest)
print(f"arc rows {len(allrows)} ({len(allrows)-nmint} unminted) | gap rows {len(gap)} "
      f"({len(gap_un)} unrostered) | conditions {len(conds)} | display calls {len(dcalls)}")
