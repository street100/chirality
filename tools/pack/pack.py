#!/usr/bin/env python3
"""pack — assemble the ENTIRE worked-example input bundle for one catalog
element in ONE command, and scaffold its artifact + INDEX row.

Why this exists: the worked-example pre-run's cost is dominated not by file
*sizes* but by the number of model-driven tool calls — every grep/read turn
re-bills the whole accumulated context. This script does the deterministic
foraging (catalog row, OURS source slices, chirality reference, template) as a
single Bash turn, so the agent goes from ~17 tool calls to ~3.

Usage, PRE-MINT (no element number exists yet — decision-design-before-mint):
    tools/pack/pack.py --goal local-ai        # goal bundle + scaffold docs/goals/local-ai.md
    tools/pack/pack.py --arc unit-lane        # arc bundle + scaffold docs/arcs/unit-lane-arc.md
    tools/pack/pack.py unit-lane/N24          # design bundle + scaffold arcs/parts/unit-lane-N24.md
    tools/pack/pack.py unit-lane/N24 --audit  # read-only design gate bundle
    tools/pack/pack.py unit-lane/N24 --mint   # THE GRADUATION: allocate the E#,
                                              #   write the catalog and ledger rows from §6
Usage, POST-MINT:
    tools/pack/pack.py E13 --spec        # spec stage -> docs/elements/specs/E13-<slug>-SPEC.md
    tools/pack/pack.py E13 --spec <slug> # ... naming the slug instead of deriving it
    tools/pack/pack.py E13 --audit spec  # read-only audit bundle for the SPEC
    tools/pack/pack.py E13 --audit       # audits the furthest artifact that exists
    tools/pack/pack.py E13 --kb          # standalone scoped kb slices for any run
    tools/pack/pack.py E13 --mark audited    # post-audit flip: specced -> audited
Usage, RECONSIDERING:
    tools/pack/pack.py --revisit              # worklist: records rows whose evidence
                                              #   moved after they were last checked
    tools/pack/pack.py <target> --revisit <trigger>   # one artifact beside one trigger

The example stage is RETIRED. `pack.py E13 <slug>` still scaffolds a
docs/examples/ artifact and that path is kept only for the 132 files already
there; new work runs the design stage above.

The POST-MINT modes read whichever tier holds the element's rationale — see
pipeline_artifact(). An element worked up before 2026-09-05 has an example; one
minted from a design has docs/arcs/parts/<arc>-<id>.md and never gets one, and
its registry is the arc roster rather than docs/examples/INDEX.md.

An element marked `status: superseded` (its work reshaped into a DIFFERENT
element, named by `superseded_by:`) is REFUSED at every stage — see
superseded_stop() and the Status section of docs/examples/INDEX.md.

Four LANES, one pipeline. The element id's prefix selects its SOURCE ADAPTER —
which document holds the rows, how a row is recognised, what plays the role of
the catalog's Location/state and Kind/reference_class columns:

    E13   core self-implementation   docs/elements/catalog.md
    U13   the user layer             .planning/USER-LAYER-GAP.md
    S19   the scriba editor floor    .planning/SCRIBA-PRIMITIVE-CHECKLIST.md
    N1    the native protocol        .planning/NATIVE-PROTOCOL-CHECKLIST.md

Everything downstream of the row lookup (bundles, scaffolds, audits, kb slices,
INDEX rows) is lane-agnostic; artifact tags are prefix-keyed (E13-/U13-/S19-/N01-)
so the four lanes cannot collide in examples/ or docs/elements/specs/.
"""
import glob, os, re, sys, datetime

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CATALOG = os.path.join(ROOT, "docs/elements/catalog.md")
TEMPLATE = os.path.join(ROOT, "docs/examples/_TEMPLATE.md")
CHEAT = os.path.join(ROOT, "docs/examples/_CHEATSHEET.md")
INDEX = os.path.join(ROOT, "docs/examples/INDEX.md")
CONFMAP = os.path.join(ROOT, "records/conformance-map.md")
SPECDIR = os.path.join(ROOT, "docs/elements/specs")
SPEC_TEMPLATE = os.path.join(SPECDIR, "_TEMPLATE.md")
GAPDOC = os.path.join(ROOT, ".planning/USER-LAYER-GAP.md")
SCRIBADOC = os.path.join(ROOT, ".planning/SCRIBA-PRIMITIVE-CHECKLIST.md")
NATIVEDOC = os.path.join(ROOT, ".planning/NATIVE-PROTOCOL-CHECKLIST.md")


# ------------------------------------------------------------- source adapters
# A lane is NOT a fork of this tool: it is a handful of facts about its rows.
# Per prefix: the document, how its table header is recognised (everything above
# it is the legend), how a row is recognised, which section header carries the
# element's KIND, which columns are prose worth scanning for backticked names,
# and where an OURS Python baseline may be resolved from.
#
# The catalog's Location/state column has no counterpart in the lane docs (their
# columns are State | Gate | Note), and neither lane has a Cites column, so
# `reference_class` is DERIVED there: OURS when an in-tree .py baseline resolves,
# EXTERNAL when the conventional comparator is not in this repo at all.


def _kind_E(ln):
    m = re.match(r"^##.*—\s*([A-Z][A-Z-]+)", ln)
    return (m.group(1), m.group(1)) if m else None


def _kind_U(ln):
    m = re.match(r"^##\s+(§\d+)\s+·\s+(.+?)\s*$", ln)
    if not m:
        return None
    sm = re.match(r"Surface\s+([A-Za-z])\b", m.group(2))
    return (m.group(1), f"SURFACE-{sm.group(1).upper()}" if sm else m.group(1))


def _kind_S(ln):
    m = re.match(r"^###\s+Tier\s+([A-Za-z])\b", ln)
    return (f"Tier {m.group(1)}", f"TIER-{m.group(1).upper()}") if m else None


def _kind_N(ln):
    m = re.match(r"^###\s+Layer\s+([A-Za-z])\b", ln)
    return (f"Layer {m.group(1)}", f"LAYER-{m.group(1).upper()}") if m else None


SOURCES = {
    "E": dict(
        path=CATALOG, header="| E#", kind=_kind_E,
        row=lambda eid: rf"\|\s*{eid}\s*\|",
        tick_cols=(1, 2), py_roots=("tools/*",),
        # the catalog names its baseline IN the row (`terms.py`), bare. Those bare
        # names were the compiler oracle under scaffold/chirality/, which is CUT;
        # the only Python left in this tree is tools/<name>/<name>.py, so `*` in a
        # root expands to the candidate's own stem. A compiler .py resolves nowhere
        # now, and the bundle says so rather than printing a path that cannot exist.
        section_baselines={}, derive_refclass=False,
    ),
    "U": dict(
        path=GAPDOC, header="| U#", kind=_kind_U,
        row=lambda eid: rf"\|\s*\*{{0,2}}{eid}\*{{0,2}}\s*\|",
        # Element + Note carry the prose; State/Gate are backticked STATUS
        # words (`design`, `blocked`) and would be read as symbol names.
        tick_cols=(1, 4), py_roots=("", "bin", "tools/*"),
        # §6 (the KB surface) is the one place where the conventional baseline is
        # OURS and in-tree: this repo's KB is run by these four tools, and they
        # are the specification the row refracts. §4/§5/§7 have NO in-tree
        # baseline — the comparator is org-mode/emacs, i.e. EXTERNAL.
        section_baselines={"§6": ["tools/ledger-lint/ledger-lint.py", "tools/doc/doc.py",
                                  "tools/capture/capture.py", "tools/frontier/frontier.py"]},
        derive_refclass=True,
    ),
    "S": dict(
        path=SCRIBADOC, header="| S#", kind=_kind_S,
        row=lambda eid: rf"\|\s*\*{{0,2}}{eid}\*{{0,2}}\s*\|",
        tick_cols=(1, 4), py_roots=("", "bin", "tools/*"),
        section_baselines={}, derive_refclass=True,
    ),
    "N": dict(
        path=NATIVEDOC, header="| N#", kind=_kind_N,
        row=lambda eid: rf"\|\s*\*{{0,2}}{eid}\*{{0,2}}\s*\|",
        tick_cols=(1, 4), py_roots=("", "bin", "tools/*"),
        section_baselines={}, derive_refclass=True,
    ),
}


def id_parts(eid):
    """(prefix, number, suffix) — `S20b` is a real id in the scriba lane."""
    m = re.match(r"^([EUSN])(\d+)([a-z]?)$", eid)
    return (m.group(1), int(m.group(2)), m.group(3)) if m else (None, 0, "")


def source_for(eid):
    return SOURCES[id_parts(eid)[0]]


def id_rx(eid):
    """The word-boundary regex that recognises this element id in prose."""
    p, n, sfx = id_parts(eid)
    return re.compile(rf"\b{p}0*{n}{sfx}\b")


def short_title(cell: str) -> str:
    """A SHORT noun phrase from the catalog's Element cell.

    The cell is an essay: E168's is 1,798 characters, E161's 2,272. Substituted
    raw into the template's `title:` / `# E<NN> — …` it produced a page whose
    heading was the whole row, and an INDEX row whose title column was the same
    essay a second time — which every pre-run then hand-shortened, differently.
    So the shortening is done here, deterministically, and stays editable
    afterwards: the FULL row is still printed verbatim as the bundle's section
    2, so nothing is lost, only the *title* is a title.

    Rule: the leading bold run if the cell opens with one (the house style —
    `**Diagnostics as typed values.** …`), else the first sentence-or-clause
    boundary, then a word-boundary cap. Markup is preserved, unlike
    frontier's `first_sentence`, because a title like `` `tal-c` `` reads
    wrong without its code span.
    """
    cell = cell.strip()
    CAP = 140
    m = re.match(r"\*\*(.+?)\*\*", cell)
    if m:
        t = m.group(1).strip().rstrip(".")
        t = f"**{t}**"
    else:
        m = re.search(r"(.+?[.:])(?:\s|$)", cell)
        t = m.group(1).strip().rstrip(".:") if m else cell
        if len(t) < 24:                       # `bput-u16-le`: — a name, not a title
            t = cell
    if len(t) > CAP:
        t = t[:CAP].rsplit(" ", 1)[0].rstrip(",;:—-") + " …"
    return t


def title_lines(t: str) -> tuple[str, str]:
    """(frontmatter value, heading text). A title carrying `: ` is quoted so the
    frontmatter stays parseable; otherwise it is left bare, as the corpus has
    it."""
    return (f'"{t}"' if ": " in t or t.endswith(":") else t), t


def examples_for(tag):
    """Every examples/<tag>-*.md, THE PIPELINE ARTIFACT FIRST.

    An element may carry companion files beside its worked example (E161 ships
    `E161-REQUIREMENTS.md` as its scope authority). Plain `sorted(glob(...))[0]`
    picked the companion — uppercase sorts before lowercase — so `--spec` and
    `--audit spec` read the wrong file and looked for a SPEC under the wrong
    slug. The pipeline artifact is the one the INDEX row links, so ask the INDEX
    first and fall back to the glob only when no row names a file.
    """
    exs = sorted(glob.glob(os.path.join(ROOT, "docs", "examples", f"{tag}-*.md")))
    named = None
    if os.path.exists(INDEX):
        rx = re.compile(r"\((%s-[^)]+\.md)\)" % re.escape(tag))
        for line in open(INDEX).read().splitlines():
            cells = line.split("|")
            if len(cells) > 2 and cells[1].strip() == tag:
                m = rx.search(line)
                if m:
                    named = os.path.join(ROOT, "docs", "examples", m.group(1))
                break
    if named and named in exs:
        exs.remove(named)
        exs.insert(0, named)
    return exs


def design_rows(eid):
    """Every (arc, rid, abspath) whose roster row's element cell reads this id.

    The roster is the only pointer from an element number back to its design:
    decision-work-ids cites a row as <arc>/<id> and decision-design-before-mint
    puts its design at docs/arcs/parts/<arc>-<id>.md. Rows written before the
    design tier carry an E# with no part file, and one E# can sit in two rosters
    (E173, E196), so the FILE existing is the test and every hit is returned in
    arc order.
    """
    out = []
    for f in sorted(glob.glob(os.path.join(ARCDIR, "*-arc.md"))):
        arc = os.path.basename(f)[:-len("-arc.md")]
        for line in roster_all(open(f).read()):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if not cells or cells[-1].strip("`") != eid:
                continue
            rid = cells[0].strip("`").partition("/")[2]
            p = os.path.join(PARTSDIR, f"{arc}-{rid}.md")
            if rid and os.path.exists(p):
                out.append((arc, rid, p))
    return out


def pipeline_artifact(eid, tag):
    """The element's RATIONALE artifact: (kind, relpath, text, origin).

    Two tiers can hold one. Before 2026-09-05 an element was worked up in a
    docs/examples/ artifact and 133 of those are on disk; since
    decision-design-before-mint the work is designed BEFORE the number exists,
    at docs/arcs/parts/<arc>-<id>.md, and no example is ever written for it.

    The EXAMPLE WINS where one exists. It is what the SPEC beside it was built
    from and what that SPEC's filename is spelled from, so preferring the design
    for an element that has both would repoint 133 elements' primary input and
    rename their SPEC files — a repointing, not a repair. The design is the
    fallback, and for an element minted from one it is the only rationale there
    is. `origin` is (arc, rid) for a design and None for an example: the design
    tier's registry is the arc roster, not docs/examples/INDEX.md.
    """
    exs = examples_for(tag)
    if exs:
        return ("example", os.path.relpath(exs[0], ROOT), open(exs[0]).read(), None)
    for arc, rid, p in design_rows(eid):
        return ("design", os.path.relpath(p, ROOT), open(p).read(), (arc, rid))
    return (None, "", "", None)


def slugify(title):
    """A filename slug from a title cell: markup dropped, apostrophes closed up,
    the joining words dropped, the first five words kept."""
    t = re.sub(r"[`*_]", "", title).replace("'", "").replace("\u2019", "")
    words = [w for w in re.split(r"[^A-Za-z0-9]+", t.lower()) if w]
    drop = {"the", "a", "an", "of", "and", "or", "its", "is", "as", "to", "for", "in"}
    return "-".join(([w for w in words if w not in drop] or words)[:5]) or "untitled"


def spec_slug(tag, kind, rel, title):
    """The `<slug>` in docs/elements/specs/<tag>-<slug>-SPEC.md.

    An example spells it in its own filename. A design does not: its filename is
    the roster id, which is stable but says nothing about the subject. So a
    design-sourced element takes the slug from a SPEC already on disk — a re-run,
    or one written by hand, keeps its file instead of growing a second one — and
    otherwise from the catalog title, deterministically."""
    if kind == "example":
        return os.path.basename(rel)[len(tag) + 1:-3]
    specs = sorted(glob.glob(os.path.join(SPECDIR, f"{tag}-*-SPEC.md")))
    if specs:
        return os.path.basename(specs[0])[len(tag) + 1:-len("-SPEC.md")]
    return slugify(title)


def _frontmatter(path):
    """The YAML block between the leading `---` fences, or "" if there is none."""
    m = re.match(r"^---\n(.*?)\n---\n", open(path).read(), re.S)
    return m.group(1) if m else ""


def superseded_stop(eid, tag):
    """Refuse every stage for an element whose artifacts are marked superseded.

    `superseded` is the pipeline's one EXIT off the drafted -> reviewed ->
    specced -> audited -> implemented chain (vocabulary and rules: the Status
    section of docs/examples/INDEX.md). It says the element stopped being the
    thing that gets built because its work was reshaped into a DIFFERENT
    element, named by the `superseded_by:` frontmatter field. Its artifacts are
    kept, unrewritten, as the record of what was decided.

    Without this the tool would walk a retired element forward, because every
    stage keys off the artifact FILE existing, not off its state: `--spec` would
    scaffold a fresh SPEC over a superseded example, `--audit` would bundle one
    for review, and `--mark` would die with a predecessor-mismatch message that
    reads like a fixable slip instead of a closed element.

    The flip INTO superseded is deliberately not a `--mark`. A `--mark` is a
    deterministic flip with one legal predecessor to check; supersession has no
    predecessor (it is reachable from any state) and its target element is an
    author's call, so it is written by hand.
    """
    hits = []
    for path in (examples_for(tag)
                 + [p for _a, _r, p in design_rows(eid)]
                 + sorted(glob.glob(os.path.join(SPECDIR, f"{tag}-*-SPEC.md")))):
        fm = _frontmatter(path)
        if re.search(r"^status:\s*superseded\s*$", fm, re.M):
            by = re.search(r"^superseded_by:\s*(\S+)", fm, re.M)
            hits.append((os.path.relpath(path, ROOT), by.group(1) if by else "(unnamed)"))
    if not hits:
        return
    die(f"{eid} is SUPERSEDED — refusing to run any pipeline stage on it.\n"
        + "\n".join(f"  {rel}  superseded_by: {by}" for rel, by in hits)
        + "\nThose artifacts are the record of what was decided, not a live design.\n"
          "Work the successor element instead.")


def die(m):
    print(m, file=sys.stderr)
    sys.exit(1)


def conf_rows(eid):
    """CONFORMANCE-MAP table rows naming this element."""
    return [ln for ln in open(CONFMAP).read().splitlines()
            if ln.startswith("|") and re.search(rf"\b{eid}\b", ln)]


def resolve_py(cand, roots):
    """(relpath, abspath-or-None) for ONE baseline .py. The oracle root
    scaffold/chirality/ is CUT; the only Python left is tools/<name>/<name>.py,
    so a root of `tools/*` expands with the candidate's own stem. Unresolved
    returns the first root's spelling and None, so the caller can name what it
    looked for."""
    stem = os.path.splitext(os.path.basename(cand))[0]
    for r in roots:
        rel = os.path.join(r.replace("*", stem), cand) if r else cand
        if os.path.exists(os.path.join(ROOT, rel)):
            return rel, os.path.join(ROOT, rel)
    first = roots[0].replace("*", stem) if roots else ""
    return (os.path.join(first, cand) if first else cand), None


def target_outlines(text):
    """Structural outlines of every in-tree source file named in the text.
    Extensions are the post-rename set: .chiral module, .prog entry, .py tool."""
    paths = sorted(set(re.findall(
        r"(?:lib|prog|tools)/[A-Za-z0-9_/.-]*\.(?:py|chiral|prog)", text)))
    sec = []
    for rel in paths:
        p = os.path.join(ROOT, rel)
        if not os.path.exists(p):
            sec.append(f"### {rel} — NEW FILE (does not exist yet)")
            continue
        src = open(p).read().splitlines()
        pat = r"\s*(def |class )" if rel.endswith(".py") else r"\("
        heads = [f"{i+1:>5}  {l.rstrip()}" for i, l in enumerate(src) if re.match(pat, l)]
        sec.append(f"### {rel} ({len(src)} lines — outline; grep it for a body you need)\n"
                   "```\n" + "\n".join(heads) + "\n```")
    return sec


def ours_block(rel, path, syms):
    """(heading suffix, fenced python) for ONE baseline .py — whole file when it
    is small, else the head plus a window around each named symbol. Shared by
    every lane so the baseline section reads identically wherever it comes
    from."""
    src = open(path).read().splitlines()
    if len(src) <= 120:
        return (f"{rel} ({len(src)} lines, full)",
                "```python\n" + "\n".join(src) + "\n```")
    shown = set(range(0, min(24, len(src))))       # module docstring / head
    for sym in syms:
        for i, l in enumerate(src):
            if re.match(r"\s*(def|class)\s", l) and re.search(rf"\b{re.escape(sym)}\b", l):
                shown.update(range(max(0, i - 1), min(len(src), i + 24)))
    buf, prev = [], -2
    for i in sorted(shown):
        if i > prev + 1:
            buf.append(f"# … [line {i+1}]")
        buf.append(src[i])
        prev = i
    return (f"{rel} ({len(src)} lines; slices around {', '.join(syms) or 'head'} — "
            "grep the file for anything specific still missing)",
            "```python\n" + "\n".join(buf) + "\n```")


def test_baseline():
    """There is no test-function baseline any more. The Python oracle suite
    (scaffold/tests/test_*.py) went with external judgment, so quoting a count
    here would quote zero and read as a measurement."""
    sh = "tools/test/run-tests.sh"
    if not os.path.exists(os.path.join(ROOT, sh)):
        return f"NO TEST FLOOR: {sh} is missing from this tree."
    return ("The Python oracle suite (scaffold/tests/test_*.py) is CUT, so there is no "
            f"test-function count to quote. The gating floor is {sh}, which prints its "
            "unported phases by name and reason on every run. Your green line is a phase "
            "there. No pytest function will do.")


# ---------------------------------------------------------------- kb slicing
# The docs tier is a typed graph: thin notes carry `related:` frontmatter and
# [[links]]; banks are a fixed 6-section schema whose shard headers, cross-cuts
# and residue items are E#-tagged. That structure is machine-resolvable, so the
# audit stages pull EXACTLY the element's slice of the kb in one deterministic
# pass instead of reading whole notes (or worse, skipping them).

def _split_blocks(text):
    """Blank-line-separated blocks, frontmatter stripped."""
    if text.startswith("---"):
        e = text.find("\n---", 3)
        if e != -1:
            text = text[e + 4:]
    out, cur = [], []
    for ln in text.splitlines():
        if ln.strip():
            cur.append(ln)
        elif cur:
            out.append("\n".join(cur))
            cur = []
    if cur:
        out.append("\n".join(cur))
    return out


def _slice_note(rel, erx, base_pats):
    """Head (title + orientation, and a bank's §1 opening truth) + every block
    matching an anchor. The element id matches anywhere; file-basename anchors
    match only a bank's build-state-carrying sections (§2 refraction, §3
    cross-cuts, §5 residue) — in §1/§4/§6 prose a shared filename like kernel.py
    is incidental, not a slice. Each heading context is emitted once."""
    is_bank = "/banks/" in rel
    blocks = _split_blocks(open(os.path.join(ROOT, rel)).read())
    keep = {}  # index -> rendered block
    for i, b in enumerate(blocks[:2]):
        keep[i] = b
    for i, b in enumerate(blocks):
        if b.splitlines()[0].startswith("## 1"):
            keep.setdefault(i, b)
            if i + 1 < len(blocks):
                keep.setdefault(i + 1, blocks[i + 1])
            break
    seen_heads = {b.splitlines()[0] for b in keep.values()
                  if re.match(r"#{1,4} ", b.splitlines()[0])}
    heading, secnum, matched = "", 0, 0
    for i, b in enumerate(blocks):
        first = b.splitlines()[0]
        m = re.match(r"##\s+(\d)", first)
        if m:
            secnum = int(m.group(1))
        if re.match(r"#{1,4} ", first):
            heading = first
        base_ok = not (is_bank and secnum not in (2, 3, 5))
        if erx.search(b) or (base_ok and any(p.search(b) for p in base_pats)):
            matched += 1
            if i not in keep:
                if re.match(r"#{1,4} ", first) or not heading or heading in seen_heads:
                    keep[i] = b
                else:
                    keep[i] = heading + "\n" + b
                    seen_heads.add(heading)
            if re.match(r"#{1,4} ", first):
                seen_heads.add(first)
    body = "\n\n".join(keep[i] for i in sorted(keep))
    return (f"### {rel} — head + {matched} anchor-matched of {len(blocks)} blocks "
            "(grep it for what's elided)\n\n" + body)


def kb_slices(eid, seed_texts):
    """Resolve a seed artifact's relational anchors into sliced kb notes.
    Resolution: seed [[links]] and docs/ paths -> notes; each linked thin note
    promotes the banks/* in its `related:` frontmatter (the depth tier behind
    it); PLUS every bank naming the element is swept in even if unlinked.
    Slicing: keep blocks matching the element id or a seed-named source file."""
    seed = "\n".join(seed_texts)
    notes = []

    def add(rel):
        if rel not in notes and os.path.exists(os.path.join(ROOT, rel)):
            notes.append(rel)

    for l in sorted(set(re.findall(r"\[\[([A-Za-z0-9/_-]+)\]\]", seed))):
        add(f"docs/{l}.md")
    for d in sorted(set(re.findall(r"docs/[A-Za-z0-9_/.-]+\.md", seed))):
        add(d)
    for rel in [n for n in notes if "/banks/" not in n]:
        m = re.search(r"^related:\s*\[([^\]]*)\]",
                      open(os.path.join(ROOT, rel)).read(), re.M)
        for r in (m.group(1).split(",") if m else []):
            if r.strip().startswith("banks/"):
                add(f"docs/{r.strip()}.md")
    erx = id_rx(eid)
    for f in sorted(glob.glob(os.path.join(ROOT, "docs/banks/*.md"))):
        if os.path.basename(f) != "INDEX.md" and erx.search(open(f).read()):
            add(os.path.relpath(f, ROOT))

    bases = sorted({os.path.basename(b) for b in
                    re.findall(r"`([A-Za-z0-9_./-]+\.(?:py|chiral|prog))`", seed)})
    base_pats = [re.compile(rf"\b{re.escape(b)}\b") for b in bases]
    caveat = ("Slices are E#/file-anchored; an E-RANGE in a note (e.g. E30–E33) "
              "will not match an interior number — grep the named note if a "
              "claim seems unsupported before calling it wrong.")
    return ("\n\n".join(_slice_note(rel, erx, base_pats) for rel in notes),
            notes, caveat)


# ---------------------------------------------------------------- audit modes

EX_CHARTER = """## 0. Audit charter — EXAMPLE level (the pre-spec gate)
Verify the drafted example against this bundle. Your ONLY write surface is the
example file itself. Checks, in order:
1. **Phantom-feature check** — every "chirality needs/lacks X" claim vs the bank
   slices: is X already refracted into built shards? (the cardinal error here)
2. **Settled-decision conformance** — §4 claims vs the sliced decision notes
   and banks; nothing may re-argue a settled decision.
3. **Build-state accuracy** — §6 lands-in / conformance target vs the map rows
   and bank build-states; nothing rounded to done or to undone.
4. **Syntax legality** — the §5 snippet vs the idioms reference below.
5. **Internal consistency** — §5 exhibits exactly what §4 claims.
Protocol: FIX mechanical defects in place (edit the example) · FLAG author-tier
issues in your report, never resolve them yourself · only if no FLAG blocks,
finish with `python3 tools/pack/pack.py E<#> --mark reviewed`."""

SPEC_CHARTER = """## 0. Audit charter — SPEC level (the implement-ready gate)
Verify the SPEC against this bundle. Your ONLY write surface is the SPEC file
itself. Checks, in order:
1. **Citation truth** — every RESOLVED disposition's cited doc must actually
   say what is claimed (check the kb slices; grep the cited note if its slice
   is silent before judging).
2. **Baseline honesty** — SPEC §2 vs map rows + live outlines: no respeccing a
   built shard; the stated delta is the real delta.
3. **Right homes** — each change-plan target vs the banks' cross-cuts: does the
   change land in the shard's principled home?
4. **Gate soundness** — SPEC §5 vs the live test baseline: green-line
   arithmetic right, tests named, differential floors stated.
5. **Disposition discipline** — nothing decidable parked as NEEDS-AUTHOR;
   nothing author-tier silently RESOLVED.
Protocol: FIX in the SPEC · FLAG author-tier issues · only if no FLAG blocks,
finish with `python3 tools/pack/pack.py E<#> --mark audited`."""


def audit_mode(eid, tag, title, row, row_kind, level):
    kind, rel, art, origin = pipeline_artifact(eid, tag)
    if not kind:
        die(f"nothing to audit for {eid}: no example examples/{tag}-*.md and no design "
            f"under docs/arcs/parts/ reached from a roster row naming it — the design "
            f"run comes first")
    slug = spec_slug(tag, kind, rel, title)
    spec_path = os.path.join(SPECDIR, f"{tag}-{slug}-SPEC.md")
    if not level:  # default: audit the furthest artifact that exists
        level = ("spec" if os.path.exists(spec_path)
                 else "example" if kind == "example" else "design")
    if level == "design":
        if not origin:
            die(f"{eid} was worked up in an example, not a design — the pre-spec gate "
                f"for it is `--audit example`")
        print(f"[audit] {eid} was designed as {origin[0]}/{origin[1]}; running the "
              f"DESIGN gate on it", file=sys.stderr)
        part_audit_mode(*origin)
        return
    if level not in ("example", "spec"):
        die("--audit takes: design | example | spec")
    if level == "example" and kind != "example":
        die(f"{eid} has no worked example — it was designed at {rel}. Its pre-spec gate "
            f"is `python3 tools/pack/pack.py {origin[0]}/{origin[1]} --audit`")

    out = [f"# AUDIT BUNDLE ({level.upper()}) — {cat_label(eid)}: {title}",
           "Read THIS ONLY; grep only to chase a specific claim the bundle "
           "leaves unsettled. This bundle is read-only — no file was scaffolded "
           "and no status changed.",
           EX_CHARTER.replace("E<#>", eid) if level == "example"
           else SPEC_CHARTER.replace("E<#>", eid),
           f"## 1. Catalog row\n{row}\n\n**kind**={row_kind}"]

    if level == "example":
        out.append(f"## 2. ARTIFACT UNDER AUDIT — {rel}\n\n{art.strip()}")
        hits = conf_rows(eid)
        out.append(f"## 3. Conformance-map rows naming {eid} (build-state authority)\n"
                   + ("\n".join(hits) if hits else "(none — postdates the map snapshot)"))
        body, notes, caveat = kb_slices(eid, [art])
        out.append(f"## 4. KB slices — {len(notes)} notes resolved from the example's "
                   f"anchors\n{caveat}\n\n{body}")
        out.append("## 5. chirality idioms & vocabulary (syntax-legality reference)\n"
                   + open(CHEAT).read().strip())
    else:
        if not os.path.exists(spec_path):
            die(f"no SPEC docs/elements/specs/{tag}-{slug}-SPEC.md — run --spec first")
        sp = open(spec_path).read()
        out.append(f"## 2. ARTIFACT UNDER AUDIT — docs/elements/specs/{tag}-{slug}-SPEC.md"
                   f"\n\n{sp.strip()}")
        out.append(f"## 3. Its {kind} (the rationale it must not contradict) — "
                   f"{rel}\n\n{art.strip()}")
        hits = conf_rows(eid)
        out.append(f"## 4. Conformance-map rows naming {eid} (build-state authority)\n"
                   + ("\n".join(hits) if hits else "(none — postdates the map snapshot)"))
        sec = target_outlines(sp + "\n" + art)
        out.append("## 5. Live targets (outlines)\n"
                   + ("\n\n".join(sec) or "(no lib/, prog/ or tools/ paths named)"))
        out.append("## 6. Test baseline\n" + test_baseline())
        body, notes, caveat = kb_slices(eid, [sp, art])
        out.append(f"## 7. KB slices — {len(notes)} notes; every RESOLVED citation "
                   f"is checked against these\n{caveat}\n\n{body}")
    print("\n\n".join(out))


def kb_mode(eid, tag, title):
    """Standalone scoped-kb fetch: slices seeded from whatever artifacts exist."""
    seeds, names = [], []
    for p in sorted(glob.glob(os.path.join(ROOT, "docs", "examples", f"{tag}-*.md"))) + \
             [d for _a, _r, d in design_rows(eid)] + \
             sorted(glob.glob(os.path.join(SPECDIR, f"{tag}-*-SPEC.md"))):
        seeds.append(open(p).read())
        names.append(os.path.relpath(p, ROOT))
    if not seeds:
        die(f"no artifacts for {eid} to seed the kb walk from")
    body, notes, caveat = kb_slices(eid, seeds)
    print(f"# KB SLICES — {cat_label(eid)}: {title}\nSeeded from: {', '.join(names)} — "
          f"{len(notes)} notes resolved.\n{caveat}\n\n{body}")


def mark_mode(eid, tag, state, no_index):
    """Post-audit status flip: reviewed (example audit passed) or audited
    (spec audit passed; also flips the SPEC's frontmatter)."""
    if state not in ("reviewed", "audited"):
        die("--mark takes: reviewed (example audit passed) | audited (spec audit passed)")
    want = "drafted" if state == "reviewed" else "specced"
    if state == "audited":
        specs = sorted(glob.glob(os.path.join(SPECDIR, f"{tag}-*-SPEC.md")))
        if not specs:
            die(f"no SPEC to mark audited for {eid}")
        sp = open(specs[0]).read()
        sp2 = re.sub(r"^status:\s*\S+\s*$", "status: audited", sp, count=1, flags=re.M)
        if sp2 != sp:
            open(specs[0], "w").write(sp2)
            print("[mark] SPEC frontmatter status -> audited", file=sys.stderr)
    idx = open(INDEX).read().splitlines()
    for i, ln in enumerate(idx):
        if re.match(rf"\|\s*{eid}\s*\|", ln):
            cells = ln.split("|")
            if len(cells) >= 7 and cells[5].strip().startswith(want):
                cells[5] = cells[5].replace(want, state, 1)
                if no_index:
                    print("[mark] --no-index: row to patch later:\n" + "|".join(cells),
                          file=sys.stderr)
                else:
                    idx[i] = "|".join(cells)
                    open(INDEX, "w").write("\n".join(idx) + "\n")
                    print(f"[mark] INDEX {eid}: {want} -> {state}", file=sys.stderr)
                return
            die(f"INDEX {eid} status {cells[5].strip()!r} — expected {want!r}; not marked")
    die(f"INDEX row for {eid} not found")


def spec_mode(eid, tag, title, row, row_kind, no_index, slug_arg=""):
    """rationale -> spec: print the spec input bundle, scaffold the SPEC
    artifact, flip the element's registry row to `specced`. Which registry is
    which tier's: the INDEX row for an element worked up in an example, the arc
    roster row for one designed under docs/arcs/parts/."""
    kind, rel, art, origin = pipeline_artifact(eid, tag)
    if not kind:
        die(f"no rationale artifact for {eid}: no example examples/{tag}-*.md and no "
            f"design at docs/arcs/parts/<arc>-<id>.md reached from a roster row whose "
            f"element cell reads {eid}. A SPEC is written from one of the two")
    slug = slug_arg or spec_slug(tag, kind, rel, title)
    label = "The drafted example" if kind == "example" else "The design"

    out = [f"# SPEC BUNDLE — {cat_label(eid)}: {title}",
           "Read THIS ONLY. The artifact below is your primary input; the map rows are "
           "the build-state authority; the outlines show the live targets. Grep/read "
           "the repo only for a specific body or fact an outline lacks.",
           f"## 1. Catalog row\n{row}\n\n**kind**={row_kind}",
           f"## 2. {label} — {rel} (PRIMARY INPUT)\n\n{art.strip()}"]

    hits = conf_rows(eid)
    out.append(f"## 3. Conformance-map rows naming {eid} (authoritative build-state)\n"
               + ("\n".join(hits) if hits
                  else f"(none — {eid} postdates the map snapshot; treat as BUILD)"))
    sec = target_outlines(art)
    out.append("## 4. Live targets (outlines)\n"
               + ("\n\n".join(sec) or "(no lib/, prog/ or tools/ paths named in the artifact)"))
    out.append("## 5. Test baseline — your §5 green line starts here\n" + test_baseline())

    out.append("## 6. Next\nYour SPEC is scaffolded (frontmatter filled) at "
               f"`docs/elements/specs/{tag}-{slug}-SPEC.md`. Open THAT file and fill sections "
               "1–6. §3 decisions are dispositioned (RESOLVED with a cited settled doc / "
               "DEFERRED to a named home / NEEDS-AUTHOR) — never silently resolved.")
    print("\n\n".join(out))

    # ---- scaffold the SPEC artifact ----
    os.makedirs(SPECDIR, exist_ok=True)
    dest = os.path.join(SPECDIR, f"{tag}-{slug}-SPEC.md")
    if os.path.exists(dest):
        print(f"\n[scaffold] {tag}-{slug}-SPEC.md already exists — left as-is", file=sys.stderr)
    else:
        t = open(SPEC_TEMPLATE).read()
        fm, hd = title_lines(title)
        t = t.replace("title: <human title>", f"title: {fm}")
        repl = {"E<NN>": tag, "<slug>": slug, "<human title>": hd,
                "SELF-HOST | REPLACE-CRUTCH | BUILD-PROPER": row_kind,
                "<YYYY-MM-DD>": datetime.date.today().isoformat()}
        if origin:
            # the template's frontmatter `design:` and its opening blockquote both
            # spell the design as <arc>-<id>; only this tier can resolve them.
            repl["<arc>-<id>"] = f"{origin[0]}-{origin[1]}"
        for a, b in repl.items():
            t = t.replace(a, b)
        open(dest, "w").write(t)
        print(f"\n[scaffold] wrote docs/elements/specs/{tag}-{slug}-SPEC.md", file=sys.stderr)

    # ---- the registry row: status -> specced ----
    if origin:
        # A design-minted element has no INDEX row: docs/examples/INDEX.md is the
        # retired tier's registry and the roster is this one's. ledger-lint check
        # AH pairs a `specced` row against a SPEC on disk, so the flip belongs to
        # the run that writes the SPEC.
        roster_flip(origin, ("designed", "minted"), "specced", no_index)
        return
    # ---- INDEX row: status -> specced, artifact cell gains the SPEC link ----
    idx = open(INDEX).read().splitlines()
    patched = None
    for i, ln in enumerate(idx):
        if re.match(rf"\|\s*{eid}\s*\|", ln):
            cells = ln.split("|")
            if len(cells) >= 7 and "-SPEC.md" not in cells[6]:
                st = cells[5].strip()
                if st.startswith(("drafted", "reviewed")):
                    cells[5] = cells[5].replace("drafted", "specced", 1) \
                                       .replace("reviewed", "specced", 1)
                else:
                    print(f"[scaffold] INDEX status {st!r} not drafted/reviewed — "
                          "linking SPEC, status left", file=sys.stderr)
                cells[6] = cells[6].rstrip() + \
                    f" · [SPEC](../../docs/elements/specs/{tag}-{slug}-SPEC.md) "
                patched = (i, "|".join(cells))
    if patched is None:
        print(f"[scaffold] INDEX row for {eid} missing or already SPEC-linked — untouched",
              file=sys.stderr)
    elif no_index:
        print(f"[scaffold] --no-index: NOT editing INDEX. Row to patch later:\n{patched[1]}",
              file=sys.stderr)
    else:
        idx[patched[0]] = patched[1]
        open(INDEX, "w").write("\n".join(idx) + "\n")
        print(f"[scaffold] INDEX row for {eid}: status → specced, SPEC linked", file=sys.stderr)


LEDGER = os.path.join(ROOT, "docs/elements/ledger.md")


def ledger_lookup(eid):
    """(category, module) for eid from the LEDGER, or (None, None) if untagged."""
    if not os.path.exists(LEDGER):
        return (None, None)
    cat = "?"
    for ln in open(LEDGER):
        hm = re.match(r"^#{2,3}\s+([A-Za-z0-9]+)\s+·", ln)
        if hm:
            cat = hm.group(1)
            continue
        if re.match(rf"\|\s*\*{{0,2}}{eid}\*{{0,2}}\s*\|", ln):
            cells = [c.strip() for c in ln.strip().strip("|").split("|")]
            mod = cells[1].strip("*") if len(cells) > 1 else "?"
            return (cat, mod)
    return (None, None)


def cat_label(eid):
    """The CAT·E# display label (bare E# if the element is not in the ledger)."""
    cat, _ = ledger_lookup(eid)
    return f"{cat}·{eid}" if cat else eid


def ledger_note(eid):
    """One-line authoring nudge: where does this E# sit in the category ledger?
    ledger-lint check J is the hard gate; this is the reminder at pack time so a
    new element gets tagged the moment it is touched."""
    cat, mod = ledger_lookup(eid)
    if cat:
        print(f"[ledger] {cat}·{eid}  (module {mod})  (docs/elements/ledger.md)", file=sys.stderr)
    elif not os.path.exists(LEDGER):
        pass
    elif id_parts(eid)[0] == "E":
        print(f"[ledger] {eid} NOT in docs/elements/ledger.md — add its category+module row "
              f"(ledger-lint check J fails until you do)", file=sys.stderr)
    else:
        # check J ratchets the E# space only; a U#/S#/N# row's authority is its own
        # lane doc, so an absent LEDGER row here is normal, not a defect.
        print(f"[ledger] {eid} not LEDGER-tagged (normal for this lane) — row authority is "
              f"{os.path.relpath(source_for(eid)['path'], ROOT)}", file=sys.stderr)



# ══════════════════════════════════════════════════════════ the pre-mint tier ══
# decision-design-before-mint (2026-09-05) moved minting to the end of the
# pipeline. Everything below works a unit of work that has NO element number:
# it is named in its arc's roster, cited as <arc>/<id>, and gets an E# only when
# its design passes audit. decision-work-ids gives that id its stability.

ARCDIR = os.path.join(ROOT, "docs/arcs")
PARTSDIR = os.path.join(ARCDIR, "parts")
GOALDIR = os.path.join(ROOT, "docs/goals")
ARC_TEMPLATE = os.path.join(ARCDIR, "_TEMPLATE.md")
PART_TEMPLATE = os.path.join(PARTSDIR, "_TEMPLATE.md")
GOAL_TEMPLATE = os.path.join(GOALDIR, "_TEMPLATE.md")
LEDGERDOC = os.path.join(ROOT, "docs/elements/ledger.md")
BANKDIR = os.path.join(ROOT, "docs/banks")
STATUS_LEDGER = os.path.join(ROOT, "docs/definitions/status-ledger.md")
RECORDSDIR = os.path.join(ROOT, "records")


def arc_path(arc):
    """docs/arcs/<arc>-arc.md, accepting the name with or without the suffix."""
    stem = arc[:-4] if arc.endswith("-arc") else arc
    return os.path.join(ARCDIR, f"{stem}-arc.md")


def arc_field(text, name):
    m = re.search(rf"^- {name}s?:\s*(.+?)(?=\n[-#]|\n\n)", text, re.S | re.M)
    return m.group(1).strip() if m else ""


def arc_section(text, head):
    """One '## <head>' section body, or ''."""
    m = re.search(rf"^##+ .*{head}.*$", text, re.M | re.I)
    if not m:
        return ""
    rest = text[m.end():]
    nxt = re.search(r"^## ", rest, re.M)
    return rest[:nxt.start()].strip() if nxt else rest.strip()


def roster_row(text, arc, rid):
    """The roster line for <arc>/<id>. Tolerates `arc/id`, arc/id and a bare id
    in the first cell, because the arcs written before the schema landed spell
    their rows three ways."""
    pats = [rf"^\|\s*`?{re.escape(arc)}/{re.escape(rid)}`?\s*\|",
            rf"^\|\s*`?{re.escape(rid)}`?\s*\|"]
    for pat in pats:
        m = re.search(pat, text, re.M)
        if m:
            line = text[m.start():text.index("\n", m.start())]
            return line, [c.strip() for c in line.strip().strip("|").split("|")]
    return "", []


def roster_all(text):
    """Every roster line, for the sibling-row slice."""
    out = []
    for m in re.finditer(r"^\|\s*`?[a-z0-9-]+/[A-Z]+\d+`?\s*\|.*$", text, re.M):
        out.append(m.group(0))
    return out


def band_of(text):
    """(lo, hi) from the arc's reserved element block, or None."""
    m = re.search(r"E(\d+)\s*[-\u2013]\s*E?(\d+)", arc_field(text, "reserved element block"))
    return (int(m.group(1)), int(m.group(2))) if m else None


def taken_numbers():
    """Every E# already spoken for, catalog and ledger both. A number in either
    is minted: reading only one is how E173 got minted twice."""
    nums = set()
    for f in (CATALOG, LEDGERDOC):
        if os.path.exists(f):
            nums |= {int(n) for n in re.findall(r"\|\s*E(\d+)\s*\|", open(f).read())}
    return nums


def banks_named_by(text):
    """The banks a document points at: [[banks/x]] anywhere, plus `related:`.
    An arc names its own refraction, and that is a far better signal than
    keyword-matching a one-line row description."""
    names = set(re.findall(r"\[\[banks/([a-z0-9-]+)\]\]", text))
    fm = re.search(r"^related:\s*\[(.*?)\]", text, re.M | re.S)
    if fm:
        names |= {m for m in re.findall(r"banks/([a-z0-9-]+)", fm.group(1))}
    return sorted(names)


def bank_hits(terms, named=()):
    """Banks to slice: the ones the arc NAMES (whole leading section, they are the
    refraction this row sits in), then any other bank whose text carries a row
    term. A term shorter than five characters matches too much to be useful."""
    out, seen = [], set()
    for n in named:
        f = os.path.join(BANKDIR, f"{n}.md")
        if not os.path.exists(f):
            continue
        seen.add(f)
        lines = open(f).read().splitlines()
        out.append((os.path.relpath(f, ROOT)
                    + f"  (NAMED BY THE ARC: head of {len(lines)} lines. Read the "
                      f"whole bank before §3)", lines[:40], len(lines)))
    terms = [t for t in terms if len(t) > 4]
    for f in sorted(glob.glob(os.path.join(BANKDIR, "*.md"))):
        if f in seen or os.path.basename(f).startswith("_"):
            continue
        hits = [ln for ln in open(f).read().splitlines()
                if any(re.search(rf"\b{re.escape(t)}\b", ln, re.I) for t in terms)]
        if hits:
            out.append((os.path.relpath(f, ROOT), hits[:8], len(hits)))
    return out


def ledger_rungs(terms):
    lines = []
    if os.path.exists(STATUS_LEDGER):
        for ln in open(STATUS_LEDGER).read().splitlines():
            if any(re.search(rf"\b{re.escape(t)}\b", ln, re.I) for t in terms if len(t) > 3):
                lines.append(ln)
    return lines[:30]


# Pipeline vocabulary is not subject matter. Slicing on it matches every bank
# that mentions an unminted row, which is most of them: measured on unit-lane/N24,
# `unminted` alone pulled three banks and nine noise lines into the slice.
_STOP = {"unminted", "minted", "designed", "specced", "building", "built", "closed",
         "open", "primitive", "law", "port", "decision", "tool", "new", "bind",
         "connect", "UNASSIGNED", "none"}


def _terms_from(cells):
    """Backticked names and capitalised words from a roster row's DESCRIPTION.
    The id, state and element cells carry pipeline vocabulary, not subject
    matter, so they are excluded."""
    joined = cells[1] if len(cells) > 1 else " ".join(cells)
    raw = (re.findall(r"`([^`]+)`", joined)
           + re.findall(r"\b([A-Z][a-zA-Z]{3,})\b", joined)
           + re.findall(r"\b([a-z]{5,})\b", joined))
    return [t for t in dict.fromkeys(raw) if t.lower() not in _STOP]


def _arc_head(atext, arc):
    return "\n".join([
        f"### the arc: docs/arcs/{arc}-arc.md",
        f"- goals: {arc_field(atext, 'goal')}",
        f"- reserved element block: {arc_field(atext, 'reserved element block')}",
        f"- build-state authority: {arc_field(atext, 'build-state authority')}",
    ])


def design_mode(arc, rid, scaffold=True):
    ap = arc_path(arc)
    if not os.path.exists(ap):
        die(f"no arc at {os.path.relpath(ap, ROOT)} — open it with --arc {arc} first")
    atext = open(ap).read()
    line, cells = roster_row(atext, arc, rid)
    if not line:
        die(f"{arc}/{rid} is not in the roster of {os.path.relpath(ap, ROOT)} — "
            f"a design run works a row that exists")
    # The element cell is LAST in every roster shape, the 6-column rows written
    # before the schema landed included. Index 7 misses those.
    if cells and re.fullmatch(r"`?E\d+`?", cells[-1]):
        print(f"[note] {arc}/{rid} already carries {cells[-1].strip('`')}. The design "
              f"stage is behind it; use --spec", file=sys.stderr)

    terms = _terms_from(cells)
    goal = arc_field(atext, "goal")
    gm = re.search(r"goals/([a-z0-9-]+)", goal)
    gtext = ""
    if gm:
        gp = os.path.join(GOALDIR, f"{gm.group(1)}.md")
        if os.path.exists(gp):
            gtext = open(gp).read()

    out = [f"# DESIGN BUNDLE — {arc}/{rid}",
           "Read THIS ONLY. This row has NO element number: it gets one when this "
           "design passes audit. Fill the six sections in order — §2 measures "
           "before §3 names a gap, and §3 sizes the gap before §4 proposes a "
           "shape for it.",
           _arc_head(atext, arc.removesuffix('-arc')),
           f"## 1. Your roster row\n{line}",
           "## 2. The arc's requirements\n" + (arc_section(atext, "REQUIREMENT") or "(none written)"),
           "## 3. What the arc says the tree already holds\n"
           + (arc_section(atext, "already") or "(the arc's §3 is empty — measure it yourself)"),
           "## 4. What the arc says is missing\n"
           + (arc_section(atext, "missing") or "(the arc's §4 is empty)")]

    sibs = [l for l in roster_all(atext) if l != line]
    out.append(f"## 5. Sibling rows ({len(sibs)}) — check none of them owns this work\n"
               + "\n".join(sibs[:60]))

    if gtext:
        cond = arc_section(gtext, "done means")
        out.append(f"## 6. The goal's done-conditions\n{cond or '(none)'}")

    banks = bank_hits(terms, banks_named_by(atext))
    if banks:
        blk = []
        for rel, hits, n in banks:
            blk.append(f"### {rel}"
                       + ("" if "NAMED BY" in rel else f" ({n} naming line(s), "
                          f"{min(len(hits), 8)} shown)")
                       + "\n" + "\n".join(hits))
        out.append("## 7. Banks naming this concept — READ THESE BEFORE §3\n"
                   "A feature that is one thing elsewhere is here a sum of shards, each "
                   "in its own home, usually mostly built. Naming a phantom feature is "
                   "the cardinal working error in this repository.\n\n" + "\n\n".join(blk))
    else:
        out.append("## 7. Banks naming this concept — NONE\n"
                   "No bank in docs/banks/ names these terms: "
                   + ", ".join(terms[:12] or ["(none extracted)"])
                   + ".\nIf this concept has no bank, say so in §2 and build one rather "
                     "than guess.")

    rungs = ledger_rungs(terms)
    out.append("## 8. status-ledger rungs in range\n"
               + ("\n".join(rungs) if rungs else "(no rung names these terms)"))

    outl = target_outlines(line)
    if outl:
        out.append("## 9. Live target outlines\n" + "\n\n".join(outl))

    out.append("## 10. Next\nYour artifact is scaffolded at "
               f"`docs/arcs/parts/{arc}-{rid}.md`. Fill §1-§6. §3 may close the row "
               "with an empty delta, which mints nothing and is a success. §6 is the "
               "packet `--mint` executes.")
    print("\n\n".join(out))

    if scaffold:
        os.makedirs(PARTSDIR, exist_ok=True)
        dest = os.path.join(PARTSDIR, f"{arc}-{rid}.md")
        if os.path.exists(dest):
            print(f"\n[scaffold] {arc}-{rid}.md already exists — left as-is", file=sys.stderr)
        else:
            t = open(PART_TEMPLATE).read()
            what = cells[1] if len(cells) > 1 else rid
            for a, b in {"<arc>/<id>": f"{arc}/{rid}", "<arc>": arc, "<id>": rid,
                         "<human title>": what,
                         "<YYYY-MM-DD>": datetime.date.today().isoformat()}.items():
                t = t.replace(a, b)
            open(dest, "w").write(t)
            print(f"\n[scaffold] wrote docs/arcs/parts/{arc}-{rid}.md", file=sys.stderr)
        set_roster_state(arc, rid, "designed")


def set_roster_state(arc, rid, state, element=None):
    """Rewrite the row's state cell (and element cell) in place. The roster is
    the pipeline's authority for a row."""
    ap = arc_path(arc)
    atext = open(ap).read()
    line, cells = roster_row(atext, arc, rid)
    if not line or len(cells) < 8:
        print(f"[roster] {arc}/{rid} predates the 8-column schema "
              f"({len(cells)} columns). Set its state by hand.", file=sys.stderr)
        return
    cells[-2] = state
    if element:
        cells[-1] = f"`{element}`"
    new = "| " + " | ".join(cells) + " |"
    open(ap, "w").write(atext.replace(line, new, 1))
    print(f"[roster] {arc}/{rid} -> state {state}"
          + (f", element {element}" if element else ""), file=sys.stderr)


def roster_flip(origin, want, state, no_index):
    """Advance a roster row's state cell, refusing a predecessor that is not one
    of `want` — the roster's half of what mark_mode does to an INDEX row."""
    arc, rid = origin
    line, cells = roster_row(open(arc_path(arc)).read(), arc, rid)
    st = cells[-2] if len(cells) >= 2 else ""
    if st not in want:
        print(f"[roster] {arc}/{rid} state {st!r} not {'/'.join(want)} — artifact "
              f"written, state left", file=sys.stderr)
    elif no_index:
        print(f"[roster] --no-index: NOT editing the roster. {arc}/{rid} owes "
              f"{st} -> {state}", file=sys.stderr)
    else:
        set_roster_state(arc, rid, state)


def part_audit_mode(arc, rid):
    dest = os.path.join(PARTSDIR, f"{arc}-{rid}.md")
    if not os.path.exists(dest):
        die(f"no design at docs/arcs/parts/{arc}-{rid}.md — the element-design run "
            f"comes first")
    dtext = open(dest).read()
    if re.search(r"^status:\s*superseded", dtext, re.M):
        m = re.search(r"^superseded_by:\s*(\S+)", dtext, re.M)
        die(f"REFUSED: {arc}/{rid} is superseded by {m.group(1) if m else '(unnamed)'}. "
            f"There is nothing to gate.")
    ap = arc_path(arc)
    atext = open(ap).read()
    line, cells = roster_row(atext, arc, rid)
    terms = _terms_from(cells)

    charter = """## 0. THE DESIGN CHARTER — run these five, in order

| # | check | fails when |
|---|---|---|
| 1 | Citation truth | a §2 claim's `file:line` does not say what the artifact says it says, or carries no citation at all |
| 2 | Phantom feature | §3's delta names work the bank refraction shows already built. The cardinal working error, and why this gate exists |
| 3 | Shape honesty | §4 lists one shape with no citation that the tree settles it, or lists shapes that are one shape described twice |
| 4 | Decision discipline | a §5 RESOLVED cites no settled doc, a DEFERRED points at something unminted, or a NEEDS-AUTHOR was answered inside the run |
| 5 | Mint packet soundness | §6's band is unreserved, a row is incomplete, the split reason does not hold, or it names an unminted `E#` |

FIX what is decidable from this bundle. FLAG what is author-tier, with the
question verbatim. On PASS run `pack.py {a}/{r} --mint`. Where §3 closed the row
on an empty delta, verify the shards cover it and report CLOSED: mint nothing.""".format(a=arc, r=rid)

    out = [f"# DESIGN AUDIT BUNDLE — {arc}/{rid}", charter,
           f"## 1. The artifact under audit\n{dtext}",
           _arc_head(atext, arc.removesuffix('-arc')),
           f"## 2. Its roster row\n{line}",
           "## 3. The arc's requirements\n" + (arc_section(atext, "REQUIREMENT") or "(none)")]
    banks = bank_hits(terms, banks_named_by(atext))
    if banks:
        out.append("## 4. Banks naming this concept (check 2 runs against these)\n"
                   + "\n\n".join(f"### {rel} ({n} line(s))\n" + "\n".join(h)
                                   for rel, h, n in banks))
    rungs = ledger_rungs(terms)
    if rungs:
        out.append("## 5. status-ledger rungs in range\n" + "\n".join(rungs))
    band = band_of(atext)
    free = sorted(set(range(band[0], band[1] + 1)) - taken_numbers())[:6] if band else []
    out.append("## 6. The band (check 5 runs against this)\n"
               + (f"reserved `E{band[0]}-E{band[1]}`; next free: "
                  + ", ".join(f"E{n}" for n in free) if band
                  else "this arc holds NO reserved band. §6 must read UNASSIGNED."))
    out.append("## 7. Nothing is scaffolded and no status changes. This bundle is pure input.")
    print("\n\n".join(out))


def mint_mode(arc, rid):
    """The graduation. Allocates the E#, writes the catalog and ledger rows from
    the design's §6, and flips the roster row."""
    dest = os.path.join(PARTSDIR, f"{arc}-{rid}.md")
    if not os.path.exists(dest):
        die(f"no design at docs/arcs/parts/{arc}-{rid}.md — minting reads its §6")
    dtext = open(dest).read()
    ap = arc_path(arc)
    atext = open(ap).read()
    line, cells = roster_row(atext, arc, rid)
    if cells and re.fullmatch(r"`?E\d+`?", cells[-1]):
        die(f"{arc}/{rid} already minted as {cells[-1].strip('`')}. A row mints once")

    # Bands may OVERLAP and are advisory (decision-lane-split, ruled 2026-09-06).
    # A band says where to look first; it owns nothing. An arc with no band, or
    # with a full one, mints the next number free tree-wide instead of stopping.
    # Lane A's E184-E189 is spent and twelve arcs hold no band at all, and under
    # the old rule that blocked 146 rows from ever minting.
    taken = taken_numbers()
    band = band_of(atext)
    num = None
    if band:
        free = sorted(set(range(band[0], band[1] + 1)) - taken)
        if free:
            num = free[0]
        else:
            print(f"[mint] band E{band[0]}-E{band[1]} is full; taking the next "
                  f"number free tree-wide", file=sys.stderr)
    if num is None:
        num = max(taken) + 1 if taken else 1
        while num in taken:
            num += 1
        if not band:
            print(f"[mint] {arc} holds no band; taking the next number free "
                  f"tree-wide", file=sys.stderr)
    eid = f"E{num}"

    # An unfilled template still carries every placeholder AND the §3 guidance
    # blockquote, whose prose contains the string this used to scan for. Read the
    # Verdict line itself, and refuse a template that was never filled.
    if "<the refraction" in dtext or "<one line, what must become true>" in dtext:
        die(f"docs/arcs/parts/{arc}-{rid}.md is still the unfilled template. "
            f"The element-design run fills §1-§6 before anything mints.")
    verdict = re.search(r"^\*\*Verdict:\*\*\s*`?([a-z ]+)", arc_section(dtext, "delta"), re.M)
    if verdict and verdict.group(1).strip().startswith("closed"):
        die("this design closed the row on an empty delta (§3). It mints nothing: "
            "the work is already built. Set the roster row to `closed`.")

    packet = arc_section(dtext, "mint packet")
    if not packet:
        die("the design has no §6 mint packet. Minting executes what it wrote.")

    cat = re.search(r"^\s*`?(\|\s*E<NN>.*\|)`?\s*$", packet, re.M)
    led = re.findall(r"^\s*`?(\|\s*E<NN>.*\|)`?\s*$", packet, re.M)
    if len(led) < 2:
        die("§6 must carry BOTH rows verbatim, the catalog row and the ledger row, "
            "each starting `| E<NN> |`. Found "
            f"{len(led)}. Fill the packet before minting.")
    catrow, ledrow = led[0].replace("E<NN>", eid), led[1].replace("E<NN>", eid)

    with open(CATALOG, "a") as f:
        f.write(catrow.rstrip() + "\n")
    with open(LEDGERDOC, "a") as f:
        f.write(ledrow.rstrip() + "\n")
    set_roster_state(arc, rid, "minted", element=eid)

    print(f"[mint] {arc}/{rid} -> {eid}", file=sys.stderr)
    print(f"[mint] catalog.md += {catrow.strip()}", file=sys.stderr)
    print(f"[mint] ledger.md  += {ledrow.strip()}", file=sys.stderr)
    print(f"[mint] APPENDED at end of file. Move each row into its section by hand: "
          f"the catalog sorts by kind and the ledger by category.", file=sys.stderr)
    print(f"\nMinted **{eid}** for {arc}/{rid}. Next: "
          f"`python3 tools/pack/pack.py {eid} --spec`, which reads THIS row's design "
          f"at docs/arcs/parts/{arc}-{rid}.md — the element has no worked example and "
          f"never gets one.")


def goal_mode(name):
    dest = os.path.join(GOALDIR, f"{name}.md")
    hits = []
    for d in ("", "docs", "records"):
        base = os.path.join(ROOT, d) if d else ROOT
        for f in sorted(glob.glob(os.path.join(base, "*.md"))
                        + (glob.glob(os.path.join(base, "**/*.md"), recursive=True) if d else [])):
            if "/goals/" in f or os.path.basename(f).startswith("_"):
                continue
            for i, ln in enumerate(open(f, errors="ignore").read().splitlines(), 1):
                if re.search(rf"\b{re.escape(name.replace('-', '[- ]'))}\b", ln, re.I):
                    hits.append(f"{os.path.relpath(f, ROOT)}:{i}  {ln.strip()[:150]}")
    hits = list(dict.fromkeys(hits))[:60]

    others = []
    for f in sorted(glob.glob(os.path.join(GOALDIR, "*.md"))):
        if os.path.basename(f).startswith("_") or os.path.basename(f) == "README.md":
            continue
        t = open(f).read()
        m = re.search(r"^# (Goal:.*)$", t, re.M)
        others.append(f"- {os.path.basename(f)[:-3]}: {m.group(1) if m else ''}")

    out = [f"# GOAL BUNDLE — {name}",
           "Adding a goal means CITING where the project already claims it. Every "
           "goal here is a derivation from repo text, or it declares itself an "
           "author call in its own first section. If §1 below is empty, report that "
           "and stop: authoring a new ambition is an author call.",
           f"## 1. Repo text naming '{name}' ({len(hits)} line(s))\n"
           + ("\n".join(hits) if hits else "NONE. There is no claim to derive from."),
           "## 2. The standing goals — check none of them already claims this\n"
           + "\n".join(others),
           "## 3. Author calls that may block it\n"
           + "\n".join(ln for ln in open(os.path.join(RECORDSDIR, "author-calls.md")).read().splitlines()
                       if re.search(name.split("-")[0], ln, re.I))[:2000],
           "## 4. Next\nFill five sections. Done-conditions are NUMBERED and each "
           "names its arc or says it is unopened. `## Honest limits` is what keeps "
           "the goal from reading as a pitch."]
    print("\n\n".join(out))

    if os.path.exists(dest):
        print(f"\n[scaffold] goals/{name}.md already exists — left as-is", file=sys.stderr)
    else:
        t = open(GOAL_TEMPLATE).read().replace("<name>", name).replace(
            "<YYYY-MM-DD>", datetime.date.today().isoformat())
        open(dest, "w").write(t)
        print(f"\n[scaffold] wrote docs/goals/{name}.md", file=sys.stderr)


def arc_mode(name):
    stem = name[:-4] if name.endswith("-arc") else name
    dest = arc_path(stem)
    bands = ""
    lp = os.path.join(ROOT, "docs/decisions/decision-lane-split.md")
    if os.path.exists(lp):
        bands = "\n".join(ln for ln in open(lp).read().splitlines()
                           if re.search(r"E\d+\s*[-\u2013]\s*E?\d+", ln))[:1500]
    rows = []
    for f in sorted(glob.glob(os.path.join(ARCDIR, "*-arc.md"))):
        t = open(f).read()
        rows.append(f"- {os.path.basename(f)[:-3]}: goal {arc_field(t, 'goal')[:60]} | "
                    f"band {arc_field(t, 'reserved element block')[:40]} | "
                    f"{len(roster_all(t))} roster row(s)")
    out = [f"# ARC BUNDLE — {stem}",
           "An arc schedules ONE goal condition. Read the overlapping arcs first: "
           "two arcs owning one row is the collision this stage catches.",
           "## 1. The standing arcs\n" + "\n".join(rows),
           "## 2. Reserved element bands (decision-lane-split)\n"
           + (bands or "(none parsed)"),
           "## 3. The banks\n"
           + open(os.path.join(BANKDIR, "INDEX.md")).read()[:4000],
           "## 4. Next\nFill six sections. §4 carries the GROUPS and the EDGES that "
           "run against their order: an ordering with no stated back-edges reads as "
           "a build sequence and reading it that way is usually wrong. Then run the "
           "coverage check: every requirement named by a row, every row naming a "
           "requirement, every `origin` defensible from §3."]
    print("\n\n".join(out))

    if os.path.exists(dest):
        print(f"\n[scaffold] {os.path.basename(dest)} already exists — left as-is", file=sys.stderr)
    else:
        t = open(ARC_TEMPLATE).read().replace("<name>", stem).replace(
            "<YYYY-MM-DD>", datetime.date.today().isoformat())
        open(dest, "w").write(t)
        print(f"\n[scaffold] wrote docs/arcs/{stem}-arc.md", file=sys.stderr)


def _git_last_change(rel):
    import subprocess
    try:
        r = subprocess.run(["git", "-C", ROOT, "log", "-1", "--format=%cs", "--", rel],
                           capture_output=True, text=True, timeout=20)
        return r.stdout.strip()
    except Exception:
        return ""


def revisit_scan():
    """records/ rows whose evidence changed after the row was last checked.
    records/README.md already states this as a rule and nothing acted on it."""
    stale = []
    for f in sorted(glob.glob(os.path.join(RECORDSDIR, "*.md"))):
        if os.path.basename(f) == "README.md":
            continue
        txt = open(f).read()
        for blk in re.split(r"\n(?=### )", txt):
            h = re.match(r"### (\S+)\s*(.*)", blk)
            if not h:
                continue
            chk = re.search(r"^- checked:\s*(\d{4}-\d{2}-\d{2})", blk, re.M)
            ev = re.search(r"^- evidence:\s*(.+)$", blk, re.M)
            st = re.search(r"^- state:\s*(\S+)", blk, re.M)
            if not (chk and ev):
                continue
            for path in re.findall(r"([A-Za-z0-9_./-]+\.(?:chiral|prog|py|sh|md))", ev.group(1)):
                if not os.path.exists(os.path.join(ROOT, path)):
                    continue
                last = _git_last_change(path)
                if last and last > chk.group(1):
                    stale.append((os.path.relpath(f, ROOT), h.group(1),
                                  st.group(1) if st else "?", chk.group(1), path, last,
                                  h.group(2)[:70]))
                    break
    stale.sort(key=lambda r: r[3])
    print("# REVISIT WORKLIST — rows whose evidence moved after they were checked")
    print("\nrecords/README.md: \"A row whose `checked:` date predates the last change "
          "to the files it cites is unverified.\" This is that list. Taking a row off "
          "it is a SEPARATE run: `pack.py <target> --revisit <trigger>`.\n")
    if not stale:
        print("None. Every records row's evidence predates its check date.")
        return
    print(f"{len(stale)} row(s), oldest check first.\n")
    print("| record | row | state | checked | evidence | last changed | title |")
    print("|---|---|---|---|---|---|---|")
    for r in stale:
        print("| " + " | ".join(r) + " |")


def revisit_mode(target, trigger):
    """One artifact beside one named trigger. Never re-derives the artifact."""
    cands = [target,
             os.path.join(PARTSDIR, f"{target}.md"),
             os.path.join(ARCDIR, f"{target}.md"), arc_path(target),
             os.path.join(GOALDIR, f"{target}.md")]
    if "/" in target and not target.endswith(".md"):
        a, _, r = target.partition("/")
        cands.insert(0, os.path.join(PARTSDIR, f"{a}-{r}.md"))
    path = next((c for c in cands if os.path.exists(c)
                 and os.path.isfile(c)), "")
    if not path:
        die(f"no artifact resolves for '{target}' — tried "
            + ", ".join(os.path.relpath(c, ROOT) for c in cands[:4]))
    art = open(path).read()

    tpath = trigger if os.path.exists(trigger) else os.path.join(ROOT, trigger)
    tsrc = open(tpath).read()[:6000] if os.path.exists(tpath) and os.path.isfile(tpath) else ""

    cites = []
    for m in re.finditer(r"`?([A-Za-z0-9_./-]+\.(?:chiral|prog|py|sh|md)):(\d+)(?:-(\d+))?`?", art):
        rel, a = m.group(1), int(m.group(2))
        b = int(m.group(3)) if m.group(3) else a
        fp = os.path.join(ROOT, rel)
        if not os.path.exists(fp):
            # Docs in this tree cite a bare basename as often as a repo-relative
            # path (goals/enforcement cites `compile-emit.chiral:300`). Resolve
            # it, and say when the basename is ambiguous rather than picking one.
            hits = [h for h in glob.glob(os.path.join(ROOT, "**", os.path.basename(rel)),
                                         recursive=True) if os.path.isfile(h)]
            if len(hits) == 1:
                fp, rel = hits[0], os.path.relpath(hits[0], ROOT)
            elif len(hits) > 1:
                cites.append(f"### {rel}:{a} — AMBIGUOUS basename, {len(hits)} files: "
                             + ", ".join(os.path.relpath(h, ROOT) for h in hits[:5]))
                continue
            else:
                cites.append(f"### {rel}:{a} — FILE GONE (no such path, and no file "
                             f"of that basename anywhere in the tree)")
                continue
        lines = open(fp, errors="ignore").read().splitlines()
        body = "\n".join(f"{i:>5}  {lines[i-1]}" for i in range(a, min(b, len(lines)) + 1)
                         if 0 < i <= len(lines))
        cites.append(f"### {rel}:{a}{'-'+str(b) if b != a else ''} "
                     f"(last changed {_git_last_change(rel)})\n```\n{body}\n```")

    print("\n\n".join([
        f"# REVISIT BUNDLE — {os.path.relpath(path, ROOT)} against {trigger}",
        """## 0. THE RULES

**Read the trigger before the artifact.** A run that opens the artifact and goes
looking for problems is an audit, and it is the unbounded re-read this stage
replaces.

**Bounded by the delta.** Work only the claims the trigger reaches. If more than
its reach is wrong, the verdict is REOPEN and the owning stage re-runs.

| verdict | when | writes |
|---|---|---|
| HOLDS | the trigger changes nothing | the `checked:` date. The artifact stays as it is |
| AMEND | right shape, wrong detail | the correction in place, marked `⚑` |
| RESCOPE | the row's boundary moved | the roster row, and a new row where the work divides |
| REOPEN | the stage is invalidated | the roster row's `state` drops back |
| SUPERSEDE | the row stops being what gets built | FLAG only. An author's call |

Every run writes one `records/<arc>.md` row, six fields, `checked:` today,
including a HOLDS: a check that leaves no trace gets redone.""",
        f"## 1. The trigger\n{tsrc or '(not a file — the trigger is the argument text: ' + trigger + ')'}",
        f"## 2. The artifact\n{art}",
        f"## 3. Live state of every `file:line` it cites ({len(cites)})\n"
        + ("\n\n".join(cites) if cites else "(the artifact cites no file:line)"),
    ]))


def main():
    no_index = "--no-index" in sys.argv  # skip INDEX append (safe for parallel runs)
    pos = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = [a for a in sys.argv[1:] if a.startswith("--")]

    # ---- the pre-mint tier dispatches BEFORE the element-id parse, because none
    # ---- of its targets has an element number yet. decision-design-before-mint.
    if "--goal" in flags:
        if not pos:
            die("usage: pack.py --goal <name>")
        goal_mode(pos[0]); return
    if "--arc" in flags:
        if not pos:
            die("usage: pack.py --arc <name>")
        arc_mode(pos[0]); return
    if "--revisit" in flags and not pos:
        revisit_scan(); return
    if pos and "/" in pos[0] and not pos[0].startswith("E"):
        arc, _, rid = pos[0].partition("/")
        arc = arc[:-4] if arc.endswith("-arc") else arc
        if "--revisit" in flags:
            revisit_mode(pos[0], pos[1] if len(pos) > 1 else "(unnamed)"); return
        if "--mint" in flags:
            mint_mode(arc, rid); return
        if "--audit" in flags:
            part_audit_mode(arc, rid); return
        design_mode(arc, rid, scaffold="--no-scaffold" not in flags); return
    if "--revisit" in flags and pos:
        revisit_mode(pos[0], pos[1] if len(pos) > 1 else "(unnamed)"); return

    if not pos:
        die("usage: tools/pack/pack.py E<#> [slug] [--no-index]\n"
            "       tools/pack/pack.py --goal <name> | --arc <name>\n"
            "       tools/pack/pack.py <arc>/<id> [--audit | --mint]\n"
            "       tools/pack/pack.py --revisit | <target> --revisit <trigger>")
    # accept the CAT·E# display form (MEM·E120, SYS.E121, mem/E120) as input and
    # strip to the bare stable E# key — the category prefix is a label, not the id.
    m = re.match(r"^[A-Za-z]{2,4}[·./]E?(\d+)$", pos[0])
    eid = f"E{m.group(1)}" if m else pos[0]
    m2 = re.match(r"^([EeUuSsNn])(\d+)([A-Za-z]?)$", eid)
    if not m2:
        die("element id must look like E13 / U13 / S19 / N1 (or the CAT·E# form, "
            "e.g. MEM·E120)")
    eid = m2.group(1).upper() + m2.group(2) + m2.group(3).lower()
    src = source_for(eid)
    prefix, num, sfx = id_parts(eid)
    tag = f"{prefix}{num:02d}{sfx}"
    slug = pos[1] if len(pos) > 1 else ""
    ledger_note(eid)
    superseded_stop(eid, tag)

    if not os.path.exists(src["path"]):
        die(f"{prefix}# row source {os.path.relpath(src['path'], ROOT)} does not exist "
            f"— the lane's source adapter points at a missing file")
    lines = open(src["path"]).read().splitlines()

    # legend = everything before the first table header row
    legend = []
    for ln in lines:
        if ln.startswith(src["header"]):
            break
        legend.append(ln)
    if len(legend) == len(lines):
        die(f"no {src['header']} table header in {os.path.relpath(src['path'], ROOT)} "
            f"— the lane's source adapter no longer matches the document")

    # locate the element row, plus the section key and KIND it sits under
    row, row_kind, row_sec = "", "", ""
    cur_kind, cur_sec = "", ""
    row_rx = re.compile(src["row"](eid))
    for ln in lines:
        k = src["kind"](ln)
        if k:
            cur_sec, cur_kind = k
        if row_rx.match(ln):
            row, row_kind, row_sec = ln, cur_kind, cur_sec
    if not row:
        die(f"{eid} not found in {os.path.relpath(src['path'], ROOT)}")

    cols = [c.strip() for c in row.strip().strip("|").split("|")]
    title = short_title(cols[1])
    if src["derive_refclass"]:
        # no Cites column in the lane docs: OURS iff an in-tree baseline resolves.
        refclass = "?"
    else:
        refcol = cols[3]
        refclass = "/".join(dict.fromkeys(re.findall(r"OURS|SPEC|PAPER|IMPL", refcol))) or "?"

    if "--spec" in sys.argv:
        spec_mode(eid, tag, title, row, row_kind, no_index, slug)
        return
    if "--audit" in sys.argv:
        audit_mode(eid, tag, title, row, row_kind, pos[1] if len(pos) > 1 else "")
        return
    if "--kb" in sys.argv:
        kb_mode(eid, tag, title)
        return
    if "--mark" in sys.argv:
        mark_mode(eid, tag, pos[1] if len(pos) > 1 else "", no_index)
        return

    # OURS .py + the symbols named in the row (the adapter's prose columns)
    ticks = re.findall(r"`([^`]+)`",
                       " ".join(cols[i] for i in src["tick_cols"] if i < len(cols)))
    pyfile = next((t for t in ticks if t.endswith(".py")), "")
    syms = [t for t in ticks if re.match(r"[a-z_][a-zA-Z0-9_]*$", t) and not t.endswith(".py")]

    # Baselines, lane-general: a .py named in the ROW wins; else the adapter's
    # declared per-section baseline; else there is NO in-tree baseline and the
    # bundle must SAY so rather than emit an empty slice.
    baselines = []                       # [(relpath, abspath-or-None)]
    if src["derive_refclass"]:
        for cand in ([pyfile] if pyfile else src["section_baselines"].get(row_sec, [])):
            baselines.append(resolve_py(cand, src["py_roots"]))
        refclass = "OURS" if any(f for _, f in baselines) else "EXTERNAL"
        ours_label = (", ".join(r for r, _ in baselines) if baselines
                      else "EXTERNAL (no in-tree baseline — research the comparator)")
    else:
        if pyfile:
            _rel, _found = resolve_py(pyfile, src["py_roots"])
            ours_label = _rel if _found else f"{pyfile} — NOT IN TREE (the oracle is CUT)"
        else:
            ours_label = "(none — design from spec)"

    out = [f"# INPUT BUNDLE — {cat_label(eid)}: {title}",
           "Read THIS ONLY. Everything you need to write the artifact is below. "
           "Do not grep glossary/PRINCIPLES or read a lib file — the reference section "
           "replaces them. Grep the repo only for a single specific missing fact.",
           "## 1. Catalog legend\n" + "\n".join(legend).strip(),
           f"## 2. Your element row\n{row}\n\n**kind**={row_kind}  **reference_class**={refclass}"
           f"  **ours**={ours_label}"]

    # OURS baseline: whole file if small, else slices around named symbols + head
    if not src["derive_refclass"]:
        if pyfile:
            rel, p = resolve_py(pyfile, src["py_roots"])
            if p:
                head, code = ours_block(rel, p, syms)
                out.append(f"## 3. OURS baseline — {head}\n{code}")
            else:
                out.append(f"## 3. OURS baseline — {pyfile} NOT IN TREE. The compiler "
                           "oracle (scaffold/chirality/) is CUT, so a catalog row naming "
                           "one of its files has no in-tree baseline left. Write the OURS "
                           "section from the reference class and say the baseline is gone. "
                           "Do not invent a file.")
        else:
            out.append("## 3. OURS baseline — none named (BUILD-PROPER: design from the reference/spec)")
    elif not baselines:
        out.append("## 3. OURS baseline — NONE IN TREE (EXTERNAL comparator)\n"
                   f"There is **no in-tree OURS baseline** for {eid}; the conventional "
                   "comparator is EXTERNAL to this repo (org-mode / an editor's own "
                   "implementation / a published format) and **must be researched** "
                   "before the example is written. Name the external system you "
                   "compared against and cite it — do not invent a baseline, and do "
                   "not write the OURS section as if a file existed.")
    else:
        blocks, found = [], 0
        for rel, path in baselines:
            if path:
                found += 1
                head, code = ours_block(rel, path, syms)
                blocks.append(f"### {head}\n{code}")
            else:
                blocks.append(f"### {rel} — DECLARED BASELINE NOT FOUND (grep the tree; "
                              "the adapter's section_baselines may have rotted)")
        if not found:
            # every declared baseline is gone: the bundle would promise an OURS
            # section and deliver nothing. Fail loudly instead.
            die(f"none of the {len(baselines)} declared {row_sec} baselines exist "
                f"({', '.join(r for r, _ in baselines)}) — the {prefix}# adapter's "
                f"section_baselines has rotted")
        out.append(f"## 3. OURS baseline — {found} of {len(baselines)} declared file(s) "
                   f"resolve in-tree (the {row_sec} baseline this row refracts)\n"
                   + "\n\n".join(blocks))

    out.append("## 4. chirality idioms & vocabulary (use INSTEAD of glossary/PRINCIPLES/lib)\n"
               + open(CHEAT).read().strip())
    out.append("## 5. Next\nYour artifact is scaffolded (frontmatter filled) at "
               f"`docs/examples/{tag}-{slug}.md` with the six section headers. Open THAT file "
               "and fill sections 1–6. Do not re-read the template — it is already in your file.")

    print("\n\n".join(out))

    # ---- scaffold the artifact + INDEX row (only when a slug is given) ----
    if slug:
        dest = os.path.join(ROOT, "docs", "examples", f"{tag}-{slug}.md")
        today = datetime.date.today().isoformat()
        if os.path.exists(dest):
            print(f"\n[scaffold] {tag}-{slug}.md already exists — left as-is", file=sys.stderr)
        else:
            t = open(TEMPLATE).read()
            fm, hd = title_lines(title)
            t = t.replace("title: <human title>", f"title: {fm}")
            repl = {"E<NN>": tag, "<slug>": slug, "<human title>": hd,
                    "SELF-HOST | REPLACE-CRUTCH | BUILD-PROPER": row_kind,
                    "OURS | SPEC | PAPER | IMPL": refclass,
                    "tools/<name>/<name>.py": (resolve_py(pyfile, src["py_roots"])[0]
                                               if pyfile else "(none)"),
                    "<YYYY-MM-DD>": today}
            for a, b in repl.items():
                t = t.replace(a, b)
            open(dest, "w").write(t)
            print(f"\n[scaffold] wrote examples/{tag}-{slug}.md", file=sys.stderr)

        rowmd = f"| {eid} | {title} | {row_kind} | {refclass} | drafted | [{tag}-{slug}.md]({tag}-{slug}.md) |"
        if no_index:
            print(f"[scaffold] --no-index: NOT appending. Row to add later:\n{rowmd}", file=sys.stderr)
        else:
            idx = open(INDEX).read()
            if not re.search(rf"\|\s*{eid}\s*\|", idx):
                with open(INDEX, "a") as f:
                    f.write(rowmd + "\n")
                print(f"[scaffold] appended INDEX row for {eid}", file=sys.stderr)
            else:
                print(f"[scaffold] INDEX already has {eid}", file=sys.stderr)


if __name__ == "__main__":
    main()
