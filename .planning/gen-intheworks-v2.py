#!/usr/bin/env python3
"""Single source for the in-the-works TOT definitions.

Emits two renderings of the same content:
  intheworks-definitions.md    the readable prose
  intheworks-v2.excalidraw     the canvas, laid out on a grid

Edit CONTENT here and regenerate. Editing either output directly will
drift it from the other.
"""
import json, textwrap, pathlib

HERE = pathlib.Path(__file__).parent

# --------------------------------------------------------------------------
# content
# --------------------------------------------------------------------------

SHARED_SHAPE = """Every primitive runs the same three steps. A primitive is
defined by what it changes, what its criterion is, and what
it emits. Nothing else varies between them.

1. ACT
   Do the operation, given directions and inputs.

2. ASSESS
   Test the result against this primitive's named criterion.
   The criterion is fixed per primitive and is never a
   general "is this good".

3. ROUTE
   Loop back to ACT with a sharpened input, or emit.
   Every loop must be bounded. A loop that cannot make its
   input strictly sharper emits with the failure recorded.

Format failure is separate from criterion failure. A
malformed result is retried mechanically and never reaches
ASSESS."""

STREAM_TYPES = """Streams are typed message streams. Each entry is
modifiable and retains its previous states. Every stream
cites the entry that created it.

ORIGIN STREAM
Opens with the first message of a conversation. Exactly one
per conversation.

MAJOR STREAM
A child of the origin stream, created by the first Split.
One per top-level thought.

TOT STREAM
Forms inside a major stream, created by any later Split.
Tight-scoped, one line of thought.

Note: as written, Major and TOT differ only by depth, not
by kind. See open question 1."""

DISPATCH = """The type is assigned when the entry is written.
Dispatch is a lookup, not a judgment call.

  COMPOUND    carries more than one thought   -> Split
  QUESTION    asks for something not present  -> Recall
  INFO        asserts something               -> Substantiate
  OPEN SPLIT  has live children               -> Merge

An entry whose type cannot be assigned is a COMPOUND by
default and gets Split. Splitting an atom is cheap; running
Substantiate on a compound is not."""

PRIMITIVES = [
    {
        "name": "SPLIT",
        "changes": "topology: 1 stream -> n streams",
        "color": ("#a5d8ff", "#1971c2"),
        "act": "Source message in scratchpad. Carve it into distinct\nthoughts, one per intended stream. Emit as a formatted\nset, each piece citing the source entry.",
        "assess": "COVERAGE AND DISJOINTNESS\nDo the pieces together account for the whole source?\nDoes any piece overlap another?",
        "route": "Fails coverage: re-carve with the uncovered remainder\nnamed as input.\nFails disjointness: re-carve with the overlap named.\nPasses: the mechanical process creates the streams from\nthe final format.",
        "emits": "n typed streams, each citing the source entry.",
    },
    {
        "name": "RECALL",
        "changes": "content: entry -> entry + retrieved",
        "color": ("#b2f2bb", "#2f9e44"),
        "act": "Given the thing to recall about, plus directions on which\nmemory types to search, retrieve into a specified format.",
        "assess": "SPAN\nIs the recalled set the right width for what was asked?\nToo wide means the ask was vague. Too narrow means it\nwas mis-scoped.",
        "route": "Fails: hand back to ACT with a clearer piece to recall\nabout, carrying the original recall along as new fields.\nBound: each loop the piece must be strictly narrower\nthan the last. If it cannot be narrowed, emit with the\nspan failure recorded.",
        "emits": "Retrieved content, plus the full recall trail.",
    },
    {
        "name": "SUBSTANTIATE",
        "changes": "metadata: entry + retrieved -> + confidence",
        "color": ("#ffec99", "#f08c00"),
        "act": "Takes recalled info as an INPUT. It does not fetch it;\nthe caller runs Recall first.\nGiven the claim and the recalled info, use dispatchable\ntools to falsify or substantiate the claim.",
        "assess": "EVIDENTIAL SUFFICIENCY\nDid the tools reach the claim at all? A tool that could\nnot address the claim is no evidence, not weak evidence.",
        "route": "Insufficient, another tool could reach it: loop to ACT\nwith that tool named.\nInsufficient, no tool can reach it: emit as unreachable.\nSufficient: emit with a confidence measure.",
        "emits": "The claim, its confidence, and what was tried.",
    },
    {
        "name": "MERGE",
        "changes": "topology: n streams -> 1 entry",
        "color": ("#d0bfff", "#6741d9"),
        "act": "The inverse of Split, called automatically per split.\nCollect the terminal entries of the child streams and\ncompose them against the source entry the split cited.",
        "assess": "AGREEMENT\nDo the children contradict each other, or contradict\neach other's confidence?",
        "route": "Contradiction: Split a new TOT whose subject is the\ncontradiction. Do not resolve it here.\nAgreement: write the composed result into the parent\nstream as a new entry.",
        "emits": "One parent entry, citing every child.",
    },
]

OPEN = """1. Major vs TOT. As written the difference is depth alone, which makes one
   of the two names redundant. Either give Major a property TOT lacks, or
   collapse to one name plus a depth field.

2. Nothing commits. Recall fetches, Substantiate checks, Split divides,
   Merge composes. No primitive takes a position. If that is deliberate,
   say so, so the absence reads as a decision rather than a gap.

3. Merge on contradiction Splits a new TOT, which can itself Merge into a
   contradiction. That recursion needs a bound.

4. Retry budgets. Split, Recall and Substantiate each loop. Is the budget
   per-primitive, per-stream, or per-conversation?

5. Confidence is produced by Substantiate and consumed by Merge. Nothing
   says what scale it is on or how two of them compare."""

SECTIONS = [
    ("The shared shape", SHARED_SHAPE),
    ("Stream types", STREAM_TYPES),
    ("Type dispatch", DISPATCH),
]

# --------------------------------------------------------------------------
# markdown
# --------------------------------------------------------------------------

def emit_md():
    out = ["# Trains of thought: definitions", "",
           "Generated by `gen-intheworks-v2.py`. Edit the script, not this file.", ""]
    for title, body in SECTIONS:
        out += [f"## {title}", "", "```", body, "```", ""]
    out += ["## The four primitives", ""]
    out += ["| primitive | changes | criterion |", "|---|---|---|"]
    for p in PRIMITIVES:
        crit = p["assess"].split("\n")[0]
        out.append(f"| {p['name']} | {p['changes']} | {crit} |")
    out.append("")
    for p in PRIMITIVES:
        out += [f"### {p['name']}", "", f"*{p['changes']}*", ""]
        for slot in ("act", "assess", "route", "emits"):
            out += [f"**{slot.upper()}**", "", "```", p[slot], "```", ""]
    out += ["## Open questions", "", "```", OPEN, "```", ""]
    (HERE / "intheworks-definitions.md").write_text("\n".join(out))

# --------------------------------------------------------------------------
# excalidraw
# --------------------------------------------------------------------------

_n = [0]
def nid(pfx):
    _n[0] += 1
    return f"{pfx}{_n[0]:04d}"

BODY_FONT, TITLE_FONT = 2, 1   # 2 = Helvetica, 1 = Virgil
CHAR_W = 7.0                    # ~14px Helvetica
PAD = 10

def base(t, x, y, w, h, **kw):
    e = {"id": nid("e"), "type": t, "x": x, "y": y, "width": w, "height": h,
         "angle": 0, "strokeColor": "#1e1e1e", "backgroundColor": "transparent",
         "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid",
         "roughness": 1, "opacity": 100, "groupIds": [], "frameId": None,
         "roundness": {"type": 3} if t == "rectangle" else None,
         "seed": _n[0] * 7919 % 2**31, "version": 1, "versionNonce": _n[0] * 104729 % 2**31,
         "isDeleted": False, "boundElements": [], "updated": 1,
         "link": None, "locked": False}
    e.update(kw)
    return e

def text(s, x, y, size=14, font=BODY_FONT, color="#1e1e1e", w=None):
    lines = s.split("\n")
    lh = size * 1.25
    e = base("text", x, y, w or max(len(l) for l in lines) * size * 0.5,
             len(lines) * lh, strokeColor=color)
    e.update({"text": s, "fontSize": size, "fontFamily": font, "textAlign": "left",
              "verticalAlign": "top", "containerId": None, "originalText": s,
              "lineHeight": 1.25, "autoResize": True})
    return e

def boxed(s, x, y, w, size=14, font=BODY_FONT, bg="transparent", stroke="#1e1e1e"):
    """A rectangle with text bound inside it. Returns [rect, text]."""
    lines = s.split("\n")
    lh = size * 1.25
    h = len(lines) * lh + 2 * PAD
    r = base("rectangle", x, y, w, h, backgroundColor=bg, strokeColor=stroke)
    t = base("text", x + PAD, y + PAD, w - 2 * PAD, len(lines) * lh)
    t.update({"text": s, "fontSize": size, "fontFamily": font, "textAlign": "left",
              "verticalAlign": "top", "containerId": r["id"], "originalText": s,
              "lineHeight": 1.25, "autoResize": False})
    r["boundElements"] = [{"id": t["id"], "type": "text"}]
    return [r, t], h

def emit_canvas():
    els = []
    els.append(text("Trains of thought", 0, -110, size=36, font=TITLE_FONT))
    els.append(text("four primitives on one shape. generated, do not hand-edit "
                    "without regenerating", 0, -56, size=14, color="#868e96"))

    # top row: the three definition panels
    x = 0
    for title, body in SECTIONS:
        w = 640
        els.append(text(title, x, 0, size=22, font=TITLE_FONT))
        grp, h = boxed(body, x, 36, w, bg="#f1f3f5", stroke="#495057")
        els += grp
        x += w + 40

    top_h = 36 + max(len(b.split("\n")) for _, b in SECTIONS) * 17.5 + 2 * PAD
    y0 = top_h + 90

    # primitive columns
    x = 0
    colw = 560
    for p in PRIMITIVES:
        bg, stroke = p["color"]
        y = y0
        els.append(text(p["name"], x, y, size=26, font=TITLE_FONT, color=stroke))
        y += 38
        els.append(text(p["changes"], x, y, size=13, color="#495057"))
        y += 28
        for slot in ("act", "assess", "route", "emits"):
            els.append(text(slot.upper(), x, y, size=12, font=TITLE_FONT, color=stroke))
            y += 20
            grp, h = boxed(p[slot], x, y, colw,
                           bg=bg if slot == "assess" else "transparent", stroke=stroke)
            els += grp
            y += h + 14
        x += colw + 40

    els.append(text("Open questions", 0, y + 60, size=22, font=TITLE_FONT))
    grp, _ = boxed(OPEN, 0, y + 96, 1240, bg="#fff5f5", stroke="#c92a2a")
    els += grp

    doc = {"type": "excalidraw", "version": 2, "source": "https://excalidraw.com",
           "elements": els, "appState": {"gridSize": None, "viewBackgroundColor": "#ffffff"},
           "files": {}}
    (HERE / "intheworks-v2.excalidraw").write_text(json.dumps(doc, indent=2))
    return len(els)

if __name__ == "__main__":
    emit_md()
    n = emit_canvas()
    print(f"wrote intheworks-definitions.md and intheworks-v2.excalidraw ({n} elements)")
