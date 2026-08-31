#!/usr/bin/env python3
"""pack — assemble the ENTIRE worked-example input bundle for one catalog
element in ONE command, and scaffold its artifact + INDEX row.

Why this exists: the worked-example pre-run's cost is dominated not by file
*sizes* but by the number of model-driven tool calls — every grep/read turn
re-bills the whole accumulated context. This script does the deterministic
foraging (catalog row, OURS source slices, chirality reference, template) as a
single Bash turn, so the agent goes from ~17 tool calls to ~3.

Usage:
    tools/pack/pack.py E13 debruijn      # example stage: bundle + scaffold examples/E13-debruijn.md
    tools/pack/pack.py E13               # example bundle only (no scaffold)
    tools/pack/pack.py E13 --spec        # spec stage: example -> .planning/specs/E13-<slug>-SPEC.md
                                        #   (slug inferred from the existing drafted example)
    tools/pack/pack.py E13 --audit example   # read-only audit bundle for the drafted example
    tools/pack/pack.py E13 --audit spec      # read-only audit bundle for the SPEC
    tools/pack/pack.py E13 --audit           # audits the furthest artifact that exists
    tools/pack/pack.py E13 --kb              # standalone scoped kb slices for any run
    tools/pack/pack.py E13 --mark reviewed   # post-audit flip: drafted -> reviewed
    tools/pack/pack.py E13 --mark audited    # post-audit flip: specced -> audited (+ SPEC frontmatter)

Three LANES, one pipeline. The element id's prefix selects its SOURCE ADAPTER —
which document holds the rows, how a row is recognised, what plays the role of
the catalog's Location/state and Kind/reference_class columns:

    E13   core self-implementation   .planning/SELF-IMPLEMENT-CATALOG.md
    U13   the user layer             .planning/USER-LAYER-GAP.md
    S19   the scriba editor floor    .planning/SCRIBA-PRIMITIVE-CHECKLIST.md

Everything downstream of the row lookup (bundles, scaffolds, audits, kb slices,
INDEX rows) is lane-agnostic; artifact tags are prefix-keyed (E13-/U13-/S19-)
so the three lanes cannot collide in examples/ or .planning/specs/.
"""
import glob, os, re, sys, datetime

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CATALOG = os.path.join(ROOT, ".planning/SELF-IMPLEMENT-CATALOG.md")
TEMPLATE = os.path.join(ROOT, "docs/examples/_TEMPLATE.md")
CHEAT = os.path.join(ROOT, "docs/examples/_CHEATSHEET.md")
INDEX = os.path.join(ROOT, "docs/examples/INDEX.md")
CONFMAP = os.path.join(ROOT, ".planning/audit/CONFORMANCE-MAP.md")
SPECDIR = os.path.join(ROOT, ".planning/specs")
SPEC_TEMPLATE = os.path.join(SPECDIR, "_TEMPLATE.md")
GAPDOC = os.path.join(ROOT, ".planning/USER-LAYER-GAP.md")
SCRIBADOC = os.path.join(ROOT, ".planning/SCRIBA-PRIMITIVE-CHECKLIST.md")


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
}


def id_parts(eid):
    """(prefix, number, suffix) — `S20b` is a real id in the scriba lane."""
    m = re.match(r"^([EUS])(\d+)([a-z]?)$", eid)
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
    exs = examples_for(tag)
    if not exs:
        die(f"no example examples/{tag}-*.md to audit — run the pre-run first")
    slug = os.path.basename(exs[0])[len(tag) + 1:-3]
    ex = open(exs[0]).read()
    spec_path = os.path.join(SPECDIR, f"{tag}-{slug}-SPEC.md")
    if not level:  # default: audit the furthest artifact that exists
        level = "spec" if os.path.exists(spec_path) else "example"
    if level not in ("example", "spec"):
        die("--audit takes: example | spec")

    out = [f"# AUDIT BUNDLE ({level.upper()}) — {cat_label(eid)}: {title}",
           "Read THIS ONLY; grep only to chase a specific claim the bundle "
           "leaves unsettled. This bundle is read-only — no file was scaffolded "
           "and no status changed.",
           EX_CHARTER.replace("E<#>", eid) if level == "example"
           else SPEC_CHARTER.replace("E<#>", eid),
           f"## 1. Catalog row\n{row}\n\n**kind**={row_kind}"]

    if level == "example":
        out.append(f"## 2. ARTIFACT UNDER AUDIT — examples/{tag}-{slug}.md\n\n{ex.strip()}")
        hits = conf_rows(eid)
        out.append(f"## 3. Conformance-map rows naming {eid} (build-state authority)\n"
                   + ("\n".join(hits) if hits else "(none — postdates the map snapshot)"))
        body, notes, caveat = kb_slices(eid, [ex])
        out.append(f"## 4. KB slices — {len(notes)} notes resolved from the example's "
                   f"anchors\n{caveat}\n\n{body}")
        out.append("## 5. chirality idioms & vocabulary (syntax-legality reference)\n"
                   + open(CHEAT).read().strip())
    else:
        if not os.path.exists(spec_path):
            die(f"no SPEC .planning/specs/{tag}-{slug}-SPEC.md — run --spec first")
        sp = open(spec_path).read()
        out.append(f"## 2. ARTIFACT UNDER AUDIT — .planning/specs/{tag}-{slug}-SPEC.md"
                   f"\n\n{sp.strip()}")
        out.append(f"## 3. Its example (the rationale it must not contradict) — "
                   f"docs/examples/{tag}-{slug}.md\n\n{ex.strip()}")
        hits = conf_rows(eid)
        out.append(f"## 4. Conformance-map rows naming {eid} (build-state authority)\n"
                   + ("\n".join(hits) if hits else "(none — postdates the map snapshot)"))
        sec = target_outlines(sp + "\n" + ex)
        out.append("## 5. Live targets (outlines)\n"
                   + ("\n\n".join(sec) or "(no lib/, prog/ or tools/ paths named)"))
        out.append("## 6. Test baseline\n" + test_baseline())
        body, notes, caveat = kb_slices(eid, [sp, ex])
        out.append(f"## 7. KB slices — {len(notes)} notes; every RESOLVED citation "
                   f"is checked against these\n{caveat}\n\n{body}")
    print("\n\n".join(out))


def kb_mode(eid, tag, title):
    """Standalone scoped-kb fetch: slices seeded from whatever artifacts exist."""
    seeds, names = [], []
    for p in sorted(glob.glob(os.path.join(ROOT, "docs", "examples", f"{tag}-*.md"))) + \
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


def spec_mode(eid, tag, title, row, row_kind, no_index):
    """example -> spec: print the spec input bundle, scaffold the SPEC artifact,
    flip the element's INDEX row to `specced`."""
    exs = examples_for(tag)
    if not exs:
        die(f"no drafted example examples/{tag}-*.md — run the worked-example pre-run first")
    ex_path = exs[0]
    slug = os.path.basename(ex_path)[len(tag) + 1:-3]
    ex = open(ex_path).read()

    out = [f"# SPEC BUNDLE — {cat_label(eid)}: {title}",
           "Read THIS ONLY. The example below is your primary input; the map rows are "
           "the build-state authority; the outlines show the live targets. Grep/read "
           "the repo only for a specific body or fact an outline lacks.",
           f"## 1. Catalog row\n{row}\n\n**kind**={row_kind}",
           f"## 2. The drafted example — examples/{tag}-{slug}.md (PRIMARY INPUT)\n\n{ex.strip()}"]

    hits = conf_rows(eid)
    out.append(f"## 3. Conformance-map rows naming {eid} (authoritative build-state)\n"
               + ("\n".join(hits) if hits
                  else f"(none — {eid} postdates the map snapshot; treat as BUILD)"))
    sec = target_outlines(ex)
    out.append("## 4. Live targets (outlines)\n"
               + ("\n\n".join(sec) or "(no lib/, prog/ or tools/ paths named in the example)"))
    out.append("## 5. Test baseline — your §5 green line starts here\n" + test_baseline())

    out.append("## 6. Next\nYour SPEC is scaffolded (frontmatter filled) at "
               f"`.planning/specs/{tag}-{slug}-SPEC.md`. Open THAT file and fill sections "
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
        for a, b in repl.items():
            t = t.replace(a, b)
        open(dest, "w").write(t)
        print(f"\n[scaffold] wrote .planning/specs/{tag}-{slug}-SPEC.md", file=sys.stderr)

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
                    f" · [SPEC](../.planning/specs/{tag}-{slug}-SPEC.md) "
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


LEDGER = os.path.join(ROOT, ".planning/LEDGER.md")


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
        print(f"[ledger] {cat}·{eid}  (module {mod})  (.planning/LEDGER.md)", file=sys.stderr)
    elif not os.path.exists(LEDGER):
        pass
    elif id_parts(eid)[0] == "E":
        print(f"[ledger] {eid} NOT in .planning/LEDGER.md — add its category+module row "
              f"(ledger-lint check J fails until you do)", file=sys.stderr)
    else:
        # check J ratchets the E# space only; a U#/S# row's authority is its own
        # lane doc, so an absent LEDGER row here is normal, not a defect.
        print(f"[ledger] {eid} not LEDGER-tagged (normal for this lane) — row authority is "
              f"{os.path.relpath(source_for(eid)['path'], ROOT)}", file=sys.stderr)


def main():
    no_index = "--no-index" in sys.argv  # skip INDEX append (safe for parallel runs)
    pos = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not pos:
        die("usage: tools/pack/pack.py E<#> [slug] [--no-index]")
    # accept the CAT·E# display form (MEM·E120, SYS.E121, mem/E120) as input and
    # strip to the bare stable E# key — the category prefix is a label, not the id.
    m = re.match(r"^[A-Za-z]{2,4}[·./]E?(\d+)$", pos[0])
    eid = f"E{m.group(1)}" if m else pos[0]
    m2 = re.match(r"^([EeUuSs])(\d+)([A-Za-z]?)$", eid)
    if not m2:
        die("element id must look like E13 / U13 / S19 (or the CAT·E# form, "
            "e.g. MEM·E120)")
    eid = m2.group(1).upper() + m2.group(2) + m2.group(3).lower()
    src = source_for(eid)
    prefix, num, sfx = id_parts(eid)
    tag = f"{prefix}{num:02d}{sfx}"
    slug = pos[1] if len(pos) > 1 else ""
    ledger_note(eid)

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
        spec_mode(eid, tag, title, row, row_kind, no_index)
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
