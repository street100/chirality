#!/usr/bin/env python3
"""lens: the four lenses this repo keeps on itself, and the views over them.

decision-four-lenses (2026-09-05) split what used to share every home:

    PRB-  problem   the tree does something wrong          a fix is owed
    GAP-  gap       wanted, nothing schedules it yet       it could be scheduled today
    LIM-  limit     a shortfall against what we claim      it bounds a cited claim
    UNS-  unspoken  no stated intent                       nobody has ruled on it

Three sit on one graduation chain, the same chain design-before-mint built:

    unspoken -> gap -> roster row -> element
      UNS-      GAP-   <arc>/<id>      E##

Every row carries TWO axes: its lens state, and an author marker with a note
holding the author's own words. records/lenses/README.md is the schema and this
file is what enforces it.

Usage:
    tools/lens/lens.py check          schema + citations. ledger-lint calls this
    tools/lens/lens.py author         what is awaiting a ruling, across all four
    tools/lens/lens.py overview       regenerate docs/definitions/OVERVIEW.md
    tools/lens/lens.py overview --check   compare only, write nothing, exit 1 on drift
    tools/lens/lens.py chain          the census over goal -> arc -> element
    tools/lens/lens.py trace <unit>   what a goal/arc/row/element carries
    tools/lens/lens.py new <lens> <title>    append a scaffolded row, next id
"""
import os, re, sys, glob, subprocess, datetime, hashlib, difflib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LENSDIR = os.path.join(ROOT, "records/lenses")
GOALDIR = os.path.join(ROOT, "docs/goals")
ARCDIR = os.path.join(ROOT, "docs/arcs")
CATALOG = os.path.join(ROOT, "docs/elements/catalog.md")
LEDGER = os.path.join(ROOT, "docs/elements/ledger.md")
OVERVIEW = os.path.join(ROOT, "docs/definitions/OVERVIEW.md")

# lens -> (file, id prefix, closed state set)
LENSES = {
    "problem":  ("problems.md", "PRB", ("OPEN", "FIXED", "RETIRED")),
    "gap":      ("gaps.md",     "GAP", ("open", "scheduled", "closed")),
    "limit":    ("limits.md",   "LIM", ("accepted", "to-plan", "planned",
                                        "in-works", "covered")),
    "unspoken": ("unspoken.md", "UNS", ("open", "ruled")),
}
FIELDS = ("state", "author", "note", "level", "about", "claim",
          "measured", "evidence", "checked", "owner", "from")
LEVELS = ("goal", "arc", "row", "element", "doc", "source")


def rows(lens):
    """Every row of one lens: (id, title, {field: value}, line-number)."""
    fn, pfx, _ = LENSES[lens]
    path = os.path.join(LENSDIR, fn)
    if not os.path.exists(path):
        return []
    text = open(path).read()
    out = []
    for m in re.finditer(r"^### (\S+)[ \t]*(.*)$", text, re.M):
        start = m.start()
        nxt = re.search(r"^### ", text[m.end():], re.M)
        blk = text[m.end(): m.end() + nxt.start()] if nxt else text[m.end():]
        f = {}
        for fm in re.finditer(r"^- (\w+):[ \t]*(.*(?:\n(?![-#]).*)*)$", blk, re.M):
            f[fm.group(1)] = fm.group(2).strip()
        out.append((m.group(1), m.group(2).strip(), f,
                    text.count("\n", 0, start) + 1))
    return out


def all_rows():
    for lens in LENSES:
        for r in rows(lens):
            yield (lens,) + r


# ─────────────────────────────────────────────────────────────────────── check
def check():
    """Every row against records/lenses/README.md. Returns a list of findings,
    each naming the file, the line, and both sides of the disagreement."""
    errs = []
    seen = {}
    # `from:` names a predecessor id. That is a lens row on the graduation chain,
    # or a records-tier row where a lens migrated one in: BA-03 stayed where it
    # was and points forward, because "never renumber a row that already exists"
    # outranks tidiness.
    ids = {r[1] for r in all_rows()}
    for rf in glob.glob(os.path.join(ROOT, "records", "*.md")):
        ids |= set(re.findall(r"^### (\S+)", open(rf).read(), re.M))
    for lens, rid, title, f, ln in all_rows():
        fn, pfx, states = LENSES[lens]
        where = f"records/lenses/{fn}:{ln}"

        if not re.fullmatch(rf"{pfx}-\d+", rid):
            errs.append(f"[LN] {where} id '{rid}' is not {pfx}-<n>")
        if rid in seen:
            errs.append(f"[LN] {where} id '{rid}' already used at line {seen[rid]}")
        seen[rid] = ln
        if not title:
            errs.append(f"[LN] {where} {rid} has no short title on its heading")

        for fld in FIELDS:
            if fld not in f:
                errs.append(f"[LN] {where} {rid} has no `{fld}:` field")
        if not f:
            continue

        st = f.get("state", "")
        if st and st not in states:
            errs.append(f"[LN] {where} {rid} state '{st}' is outside "
                        f"{lens}'s set ({' '.join(states)})")

        au = f.get("author", "")
        if au and au != "unreviewed" and not re.fullmatch(r"ruled \d{4}-\d{2}-\d{2}", au):
            errs.append(f"[LN] {where} {rid} author '{au}' is not `unreviewed` "
                        f"or `ruled <YYYY-MM-DD>`")
        note = f.get("note", "")
        if au.startswith("ruled") and note in ("", "none"):
            errs.append(f"[LN] {where} {rid} is `ruled` with no note. The note "
                        f"holds the author's words and is what stops the "
                        f"question being reopened")
        if au == "unreviewed" and note not in ("", "none") and "⚑" not in note:
            errs.append(f"[LN] {where} {rid} carries a note while `unreviewed`. "
                        f"A note is the author's words: mark the ruling or "
                        f"move the text to `measured:`")

        lv = f.get("level", "")
        if lv and lv not in LEVELS:
            errs.append(f"[LN] {where} {rid} level '{lv}' is outside "
                        f"({' '.join(LEVELS)})")

        if f.get("owner", "").strip().startswith("UNASSIGNED"):
            errs.append(f"[LN] {where} {rid} owner reads UNASSIGNED. "
                        f"decision-work-ids replaced that form on 2026-09-01: "
                        f"name an arc-local roster row, or `none`")

        frm = f.get("from", "").strip()
        if frm and frm != "none" and frm not in ids:
            errs.append(f"[LN] {where} {rid} graduated `from: {frm}` and no such "
                        f"row exists in any lens")

        ck = f.get("checked", "")
        if ck and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", ck):
            errs.append(f"[LN] {where} {rid} checked '{ck}' is not YYYY-MM-DD")

        ev = f.get("evidence", "")
        if ev in ("", "none"):
            errs.append(f"[LN] {where} {rid} has no evidence. A row nobody can "
                        f"re-run is worthless")
        else:
            seen_p = set()
            for path in re.findall(r"([A-Za-z0-9_./-]+\.(?:chiral|prog|py|sh|md))", ev):
                # A path inside a re-runnable command is not a repo citation.
                # PRB-18 and PRB-19 carry `printf ... > /tmp/t.chiral && ...`,
                # which is what makes them reproducible; an absolute path is by
                # definition outside this tree.
                if path.startswith("/") or path in seen_p:
                    continue
                seen_p.add(path)
                if not os.path.exists(os.path.join(ROOT, path)) and \
                   not glob.glob(os.path.join(ROOT, "**", os.path.basename(path)),
                                 recursive=True):
                    errs.append(f"[LN] {where} {rid} cites '{path}' and no such "
                                f"file is in the tree")

        # A limit that claims an owner must name one; one that claims none must not.
        if lens == "limit":
            own = f.get("owner", "none").strip()
            if st in ("planned", "in-works") and own in ("", "none"):
                errs.append(f"[LN] {where} {rid} is '{st}' and names no owner. "
                            f"That state means a GAP- row or a roster row has it")
            if st in ("accepted", "to-plan") and own not in ("", "none"):
                errs.append(f"[LN] {where} {rid} is '{st}' and names owner "
                            f"'{own}'. Nothing owns a limit in those states")
    return errs


# ──────────────────────────────────────────────────────────────────── the sweep
def author_view():
    pend = [r for r in all_rows() if r[3].get("author", "") == "unreviewed"]
    ruled = [r for r in all_rows() if r[3].get("author", "").startswith("ruled")]
    print("# AWAITING A RULING\n")
    print("records/lenses/README.md: every limit is walked with the author and "
          "marked when the ruling comes. This is that sweep, plus the same "
          "question over the other three lenses.\n")
    for lens in LENSES:
        mine = [r for r in pend if r[0] == lens]
        tot = len(rows(lens))
        print(f"## {lens}: {len(mine)} unreviewed of {tot}")
        if not mine:
            print("  (none)\n")
            continue
        for _, rid, title, f, _ in mine:
            print(f"  {rid}  [{f.get('state','?')}]  {title}")
            print(f"        about: {f.get('about','?')}")
        print()
    print(f"## ruled: {len(ruled)}")
    for _, rid, title, f, _ in ruled:
        print(f"  {rid}  {f.get('author')}  {title}")
        print(f"        note: {f.get('note','')[:160]}")
    print(f"\nTOTAL unreviewed: {len(pend)} of {len(list(all_rows()))}")


# ──────────────────────────────────────────────────────────────────── the spine
def goals():
    for p in sorted(glob.glob(os.path.join(GOALDIR, "*.md"))):
        b = os.path.basename(p)
        if b.startswith("_") or b == "README.md":
            continue
        yield b[:-3], open(p).read()


def arcs():
    for p in sorted(glob.glob(os.path.join(ARCDIR, "*-arc.md"))):
        b = os.path.basename(p)
        if b.startswith("_"):
            continue
        yield b[:-3], open(p).read()


def arc_goal(text):
    m = re.search(r"^- goals?:\s*\[\[goals/([a-z0-9-]+)\]\]", text, re.M)
    return m.group(1) if m else ""


def roster_of(text):
    out = []
    for m in re.finditer(r"^\|\s*`?([a-z0-9-]+/[A-Z]+\d+)`?\s*\|(.*)$", text, re.M):
        cells = [c.strip() for c in m.group(2).strip().strip("|").split("|")]
        out.append((m.group(1), cells))
    return out


def conditions(gtext):
    """The numbered done-conditions of a goal, and whether each names an arc.

    Returns (found_section, rows). A condition that declares itself UNOPENED is
    unopened even when its body links an arc: goals/display condition 4 says
    "Unopened, and it holds no arc file" and then cites native-protocol-arc for
    the question it waits behind. Reading that link as the scheduling arc
    reports unscheduled work as scheduled, which is the reverse of this file's
    job."""
    m = re.search(r"^## What done means\s*$", gtext, re.M)
    if not m:
        return False, []
    rest = gtext[m.end():]
    n = re.search(r"^## ", rest, re.M)
    sec = rest[:n.start()] if n else rest
    out = []
    for cm in re.finditer(r"^(\d+)\.\s+(.+?)(?=^\d+\.\s|\Z)", sec, re.M | re.S):
        body = cm.group(2)
        unopened = bool(re.search(r"[Uu]nopened", body))
        arc = [] if unopened else re.findall(r"\[\[arcs/([a-z0-9-]+)\]\]", body)
        title = re.sub(r"\s+", " ", re.sub(r"\*\*", "", body)).strip()[:90]
        out.append((cm.group(1), title, arc, unopened))
    return True, out


def lens_for(unit):
    """Every lens row whose `about:` names this unit."""
    hits = []
    for lens, rid, title, f, _ in all_rows():
        if unit and unit in f.get("about", ""):
            hits.append((lens, rid, f.get("state", "?"), f.get("author", "?"), title))
    return hits


# ───────────────────────────────────────────────────────────────────── the chain
# The model's spine is goal -> arc -> element, and docs/arcs/README.md states it.
# Four gates stand on pieces of it and every one of them was green on 2026-09-13
# while 99 catalog elements sat in no roster: check V on the goal-arc FILE link,
# AF on a done-condition naming its arc, AG on a requirement and a row covering
# each other, AE on an element's home. A gate reports an UNADMITTED hole, because
# each one gives a hole an escape: AF takes `unopened`, AG takes a gap row, AE
# takes an unspoken row. The census below counts the holes themselves, admitted
# or not, so the shape of the spine is visible without reading four checks.
#
# It duplicates no gate's verdict. Every rung names the check that gates it, and
# two rungs name that nothing does.
#
# One parser serves both. ledger-lint's `_homed`, `_minted`,
# `_ledger_state`, `_lens_about` and `arc_req_section` are loaded through the
# same importlib seam ledger-lint uses on pack.py, so a number here and the
# number a check raises come from one definition and cannot drift.

_LANE = re.compile(r"\b([EUSN])(\d+)([a-z]?)")


def _sibling(name, relpath):
    """One sibling tool, as a module. None when it is absent."""
    import importlib.util
    path = os.path.join(ROOT, relpath)
    if not os.path.exists(path):
        return None
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        return None
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _gated_goals():
    """Goals docs/goals/README.md marks `none open`, exactly as check AF reads it.

    A goal held by a standing gate carries no arc and that is its finished
    shape: goals/README.md, `Rules`. goals/self-hosting is the case and its
    three done-conditions name no arc on purpose. Counting them as holes would
    report the recorded reason check V already reads as a defect."""
    p = os.path.join(GOALDIR, "README.md")
    if not os.path.exists(p):
        return set()
    return set(re.findall(r"^\|\s*\[\[goals/([a-z0-9-]+)\]\].*?\|\s*none open",
                          open(p).read(), re.M))


def chain():
    """The census over every rung of goal -> arc -> element.

    Returns a list of rungs, each (title, covered, total, gate, [hole, ...]).
    `gate` is the ledger-lint check that fails on this rung, or the sentence
    saying nothing does."""
    lint = _sibling("chirality_ledger_lint", "tools/ledger-lint/ledger-lint.py")
    pack = _sibling("chirality_pack", "tools/pack/pack.py")
    if lint is None or pack is None:
        return None

    gated = _gated_goals()
    arc_text = dict(arcs())
    goal_text = dict(goals())
    out = []

    # ── rung 1: a goal's done-condition reaches an arc
    named, tot, cov, unop, held, blind = set(), 0, 0, 0, 0, []
    for g, gtext in sorted(goal_text.items()):
        for num, title, carcs, unopened in conditions(gtext)[1]:
            tot += 1
            if carcs:
                cov += 1
                named |= set(carcs)
            elif unopened:
                unop += 1
            elif g in gated:
                held += 1
            else:
                blind.append(f"goals/{g}.md condition {num} names no arc and "
                             f"does not say unopened: {title}")
    out.append(("goal done-condition -> arc", cov, tot, "check AF",
                [f"{unop} condition(s) declare themselves unopened",
                 f"{held} sit under a goal docs/goals/README.md marks `none "
                 f"open`, held by a standing gate"] + blind))

    # ── rung 2: the same link read from the arc's end
    holes = []
    for a in sorted(arc_text):
        if a in named:
            continue
        g = arc_goal(arc_text[a])
        cited = re.search(r"condition\s+(\d+)", pack.arc_field(arc_text[a], "goal"))
        conds = {c[0]: c for c in conditions(goal_text.get(g, ""))[1]}
        c = conds.get(cited.group(1)) if cited else None
        if g not in goal_text:
            why = (f"its `- goals:` field names goals/{g} and docs/goals/{g}.md "
                   f"is absent, which is check V's finding")
        elif c is None:
            why = (f"it cites goals/{g} condition {cited.group(1)} and that goal "
                   f"states no such condition" if cited else
                   f"its `- goals:` field names goals/{g} and no condition in it")
        elif c[3]:
            why = (f"it serves goals/{g} condition {cited.group(1)}, and that "
                   f"condition declares itself unopened")
        else:
            why = (f"it serves goals/{g} condition {cited.group(1)}, and that "
                   f"condition names {', '.join(c[2])} instead")
        holes.append(f"{a} is named by no goal condition: {why}")
    out.append(("arc -> goal done-condition", len(arc_text) - len(holes),
                len(arc_text), "NOTHING. No check reads this direction", holes))

    # ── rung 3: a requirement and a roster row cover each other
    admit = lint._lens_about("gaps.md") | lint._lens_about("unspoken.md")
    reqs, rows, served = {}, {}, {}
    for a, t in arc_text.items():
        reqs[a] = set(re.findall(r"^(\d+)\.\s+\*\*", lint.arc_req_section(t), re.M))
        rows[a] = [[c.strip() for c in ln.strip().strip("|").split("|")]
                   for ln in pack.roster_all(t)]
        served.setdefault(a, set())
    for a, rs in rows.items():
        for cells in rs:
            if len(cells) < 7:
                continue
            # check AG's own two reads of a `req` cell, kept verbatim: the loose
            # digit scan for this arc's own numbers, and `<arc>/req<N>` for a
            # requirement DELEGATED to another arc's row.
            served[a] |= set(re.findall(r"\d+", cells[-3]))
            for other in arc_text:
                on = other[:-4] if other.endswith("-arc") else other
                served[other] |= set(re.findall(rf"{re.escape(on)}/req(\d+)",
                                                cells[-3]))
    tot = sum(len(v) for v in reqs.values())
    holes, adm = [], 0
    for a in sorted(reqs):
        an = a[:-4] if a.endswith("-arc") else a
        for r in sorted(reqs[a] - served[a], key=int):
            if f"{an}/req{r}" in admit:
                adm += 1
            holes.append(f"{a} requirement {r} is served by no roster row"
                         + (f", and a lens row is about `{an}/req{r}`"
                            if f"{an}/req{r}" in admit else ""))
    out.append(("arc requirement -> roster row", tot - len(holes), tot,
                "check AG",
                [f"admitted by a gap or unspoken row, the escape check AG "
                 f"takes: {adm} of {len(holes)}"] + holes))

    nrows = sum(len(v) for v in rows.values())
    blind = [f"{a} row {c[0]} serves no numbered requirement"
             for a in sorted(rows) for c in rows[a]
             if len(c) >= 7 and not re.findall(r"\d+", c[-3])]
    out.append(("roster row -> arc requirement", nrows - len(blind), nrows,
                "check AG", blind))

    # ── rung 4: an arc reaches a minted id
    mint, zero = set(), []
    for a in sorted(rows):
        ids = {m for c in rows[a] if c[-1].strip() != "unminted"
               for m in _LANE.findall(c[-1])}
        mint |= {f"{l}{n}{s}" for l, n, s in ids}
        if not ids:
            zero.append(f"{a} rosters {len(rows[a])} row(s) and no minted id")
    out.append(("arc -> minted id", len(rows) - len(zero), len(rows),
                "NOTHING. An unminted arc is a stage, and no check reads it",
                [f"{len(mint)} distinct minted id(s) across every roster, in the "
                 f"four lanes E, U, S and N"] + zero))

    # ── rung 5: a catalog element reaches an arc
    cat, _led = lint._minted()
    homed = lint._homed()
    if homed is None:
        out.append(("catalog element -> arc roster row", 0, 0,
                    "check AE", ["tools/pack/pack.py is absent, so no roster "
                                 "element cell parses and this rung is "
                                 "UNMEASURED. The missing parser is the "
                                 "finding"]))
        return out
    spoken, st = lint._lens_about("unspoken.md"), lint._ledger_state()
    unhomed = [n for n in sorted(cat) if n not in homed]
    # The author's two rulings of 2026-09-13, in records/author-calls.md: homing
    # covers the whole catalog with `built` rows inside it, and `superseded` is
    # exempt because the successor's row is the home.
    sup = [n for n in unhomed if st.get(n) == "superseded"]
    adm = [n for n in unhomed if f"E{n}" in spoken and st.get(n) != "superseded"]
    owed = len(unhomed) - len(sup) - len(adm)
    out.append(("catalog element -> arc roster row", len(cat) - len(unhomed),
                len(cat), "check AE",
                [f"`superseded` and exempt by the author's ruling of "
                 f"2026-09-13: {len(sup)} of the {len(unhomed)} unhomed",
                 f"admitted by a row in records/lenses/unspoken.md: "
                 f"{len(adm)}",
                 f"owed a home: {owed}, which is the count check AE raises. "
                 f"records/homing-triage.md proposes one for each and rules on "
                 f"none"]))
    return out


CHAIN_UNMEASURED = (
    "No author call stands inside rung 2 today. records/author-calls.md "
    "carries the one about whether a design or a SPEC for an `OT` element "
    "counts as planning, ruled 2026-09-17 that both are planning, and the "
    "four new-arc proposals of records/homing-triage.md opened as arcs on "
    "2026-09-14. This rung still reports which arcs no condition names and "
    "says nothing about which of them is wrong: an arc whose condition does "
    "not name it and a condition naming the wrong arc read the same here.")


def chain_view(width=2):
    """The census as lines. `width` is how many holes per rung to enumerate,
    or 0 for all of them: OVERVIEW.md takes the summary and the subcommand
    takes the enumeration, from this one computation."""
    rungs = chain()
    if rungs is None:
        return ["  tools/ledger-lint/ledger-lint.py or tools/pack/pack.py is "
                "absent, so the chain cannot be walked. A view aimed at nothing "
                "cannot report a hole: the missing parser is the finding"]
    L = ["| rung | covered | of | gated by |", "|---|---|---|---|"]
    for title, cov, tot, gate, _ in rungs:
        L.append(f"| {title} | {cov} | {tot} | {gate} |")
    L.append("")
    for title, cov, tot, _gate, holes in rungs:
        if not holes:
            continue
        L.append(f"**{title}**: {cov} of {tot}.")
        show = holes if width == 0 else holes[:width]
        for h in show:
            L.append(f"- {h}")
        if len(holes) > len(show):
            L.append(f"- {len(holes) - len(show)} more, listed by "
                     f"`python3 tools/lens/lens.py chain`")
        L.append("")
    L.append(CHAIN_UNMEASURED)
    return L


def overview_body():
    el_state = {}
    for ln in open(LEDGER):
        m = re.match(r"\|\s*E(\d+)\s*\|\s*([^|]*?)\s*\|\s*([a-z]+)\s*\|", ln)
        if m:
            el_state[f"E{m.group(1)}"] = m.group(3)
    cat_els = {f"E{n}" for n in re.findall(r"\|\s*E(\d+)\s*\|", open(CATALOG).read())}
    arc_by_goal = {}
    arc_text = {}
    for a, t in arcs():
        arc_text[a] = t
        arc_by_goal.setdefault(arc_goal(t), []).append(a)

    L = ["---", "node: overview", "layer: generated", "tier: orientation",
         f"updated: {datetime.date.today().isoformat()}", "---", "",
         "# Overview: goal to element, with what each level carries", "",
         "> GENERATED by `python3 tools/lens/lens.py overview`. Do not hand-edit.",
         "> It EXTRACTS from docs/goals/, docs/arcs/, docs/elements/ and the four",
         "> lenses in records/lenses/. Regenerating twice is byte-identical.",
         "> `records/lenses/README.md` is the schema; `decisions/decision-four-lenses`",
         "> is why there are four.", ""]

    tot_rows = tot_el = 0
    for g, gtext in goals():
        has_sec, conds = conditions(gtext)
        L += [f"## {g}", ""]
        gl = lens_for(f"goals/{g}")
        if gl:
            L.append("  " + " · ".join(f"{r[1]}[{r[2]}/{r[3].split()[0]}]" for r in gl))
            L.append("")
        if not conds:
            L += ["  " + ("`## What done means` carries no NUMBERED conditions"
                          if has_sec else
                          "NO `## What done means` section. Nothing states what "
                          "done is for this goal"), ""]
        for num, title, carcs, unopened in conds:
            mark = "UNOPENED" if (unopened and not carcs) else (
                ", ".join(carcs) if carcs else "NO ARC, NOT MARKED UNOPENED")
            L.append(f"- **{num}.** {title}")
            L.append(f"      arc: {mark}")
        L.append("")
        for a in arc_by_goal.get(g, []):
            t = arc_text[a]
            ros = roster_of(t)
            tot_rows += len(ros)
            L.append(f"### arc `{a}`: {len(ros)} roster row(s)")
            al = lens_for(a)
            if al:
                L.append("  " + " · ".join(f"{r[1]}[{r[2]}/{r[3].split()[0]}]" for r in al))
            byst = {}
            for rid, cells in ros:
                st = cells[-2] if len(cells) >= 7 else "?"
                byst[st] = byst.get(st, 0) + 1
                if cells and re.fullmatch(r"`?E\d+`?", cells[-1]):
                    tot_el += 1
            if byst:
                L.append("  state: " + ", ".join(f"{k} {v}" for k, v in sorted(byst.items())))
            L.append("")

    orph = sorted((e for e in cat_els if el_state.get(e) in ("design", "flight")
                   and not any(e in t for _, t in arcs())),
                  key=lambda x: int(x[1:]))
    L += ["## Unscheduled", "",
          f"{len(orph)} unbuilt element(s) named by no arc. Each is territory with "
          f"no ruling, and the unspoken lens is where that gets tracked.", "",
          "  " + ", ".join(orph) if orph else "  (none)", ""]

    L += ["## The chain", "",
          "goal -> arc -> element is the model docs/arcs/README.md states, and "
          "this is its coverage, one rung at a time. Recipe: "
          "`python3 tools/lens/lens.py chain`, which enumerates every hole "
          "summarised here.", ""]
    L += chain_view(width=4)
    L += [""]

    L += ["## The lenses", ""]
    for lens in LENSES:
        rs = rows(lens)
        un = sum(1 for r in rs if r[2].get("author") == "unreviewed")
        byst = {}
        for _, _, f, _ in rs:
            byst[f.get("state", "?")] = byst.get(f.get("state", "?"), 0) + 1
        L.append(f"- **{lens}** ({LENSES[lens][1]}-): {len(rs)} row(s), "
                 f"{un} unreviewed. "
                 + (", ".join(f"{k} {v}" for k, v in sorted(byst.items())) or "empty"))
    L += ["", f"Roster rows across every arc: {tot_rows}. Minted from them: {tot_el}.", ""]
    return "\n".join(L)


UPDATED = re.compile(r"^updated: \d{4}-\d{2}-\d{2}$", re.M)


def substantive(body):
    """One body with its `updated:` date blanked, for comparison only.

    The header stamps the day the build ran, so a file generated yesterday
    differs from a build today on that one line and on nothing else. Comparing
    the blanked form is what stops `--check` reporting a midnight crossing as
    drift, and stops the write path rewriting a file whose only change is the
    date. A tree that has not moved did not update the overview, so the date
    already on disk is the honest one."""
    return UPDATED.sub("updated: -", body)


def overview(check=False):
    """Build the body, then decide whether it needs to reach disk.

    `check` is the read-only path: it compares, reports, and writes nothing.
    Both paths take their body from overview_body(), so a check cannot pass on
    a body the write would not have produced."""
    body = overview_body()
    have = open(OVERVIEW).read() if os.path.exists(OVERVIEW) else ""
    built, disk = body.split("\n"), have.split("\n")
    if substantive(body) == substantive(have):
        print(f"[overview] docs/definitions/OVERVIEW.md is current, "
              f"{len(built)} lines. Nothing written")
        return 0
    d = [t for t in difflib.unified_diff(disk, built, "on-disk", "built",
                                         n=1, lineterm="")]
    n = sum(1 for t in d if t[:1] in ("+", "-") and t[:3] not in ("+++", "---"))
    verb = "DRIFTED" if check else "CHANGED"
    print(f"[overview] docs/definitions/OVERVIEW.md {verb}: on disk "
          f"{len(disk)} lines, built {len(built)}, {n} line(s) differ")
    for t in d[:40]:
        print("  " + t)
    if len(d) > 40:
        print(f"  ... {len(d) - 40} more diff line(s)")
    if check:
        return 1
    open(OVERVIEW, "w").write(body)
    print(f"[overview] wrote docs/definitions/OVERVIEW.md ({len(built)} lines)")
    return 0


def trace(unit):
    hits = lens_for(unit)
    print(f"# {unit}\n")
    if not hits:
        print("No lens row names this unit.")
    for lens, rid, st, au, title in hits:
        print(f"  {rid}  {lens:9} [{st}]  author={au}\n        {title}")
    for a, t in arcs():
        for rid, cells in roster_of(t):
            if unit in rid or (cells and unit == cells[-1].strip("`")):
                print(f"\n  roster {rid}: {' | '.join(cells)}")


def new_row(lens, title):
    if lens not in LENSES:
        sys.exit(f"lens must be one of: {', '.join(LENSES)}")
    fn, pfx, states = LENSES[lens]
    path = os.path.join(LENSDIR, fn)
    nums = [int(r[1].split("-")[1]) for r in all_rows()
            if r[1].startswith(pfx + "-") and r[1].split("-")[1].isdigit()]
    rid = f"{pfx}-{max(nums) + 1 if nums else 1:02d}"
    blk = (f"\n### {rid} {title}\n\n"
           f"- state:    {states[0]}\n"
           f"- author:   unreviewed\n"
           f"- note:     none\n"
           f"- level:    <{' | '.join(LEVELS)}>\n"
           f"- about:    <the unit this concerns>\n"
           f"- claim:    <what the repo says, and where>\n"
           f"- measured: <what was observed>\n"
           f"- evidence: <file:line>\n"
           f"- checked:  {datetime.date.today().isoformat()}\n"
           f"- owner:    none\n"
           f"- from:     none\n")
    with open(path, "a") as f:
        f.write(blk)
    print(f"[lens] appended {rid} to records/lenses/{fn}")


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    cmd = sys.argv[1]
    if cmd == "check":
        errs = check()
        for e in errs:
            print(e)
        n = len(list(all_rows()))
        print(f"\nlens: {n} row(s), {len(errs)} finding(s)")
        sys.exit(1 if errs else 0)
    elif cmd == "author":
        author_view()
    elif cmd == "overview":
        sys.exit(overview(check="--check" in sys.argv[2:]))
    elif cmd == "chain":
        for ln in chain_view(width=0):
            print(ln)
    elif cmd == "trace":
        trace(sys.argv[2] if len(sys.argv) > 2 else "")
    elif cmd == "new":
        new_row(sys.argv[2], " ".join(sys.argv[3:]))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
