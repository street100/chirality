#!/usr/bin/env python3
"""ledger-lint — keep the honesty apparatus honest.

Fable audit C6/F3/F4: the status ledger, principle citations, and CONTENTS counts
are maintained by discipline, not substrate, so they rot silently (the exact
failure chirality exists to eliminate, one level up). This is the mechanizable core
of the fix: cross-check the claims that rotted against the tree.

Checks (each independent; any failure -> exit 1):
  A. Ledger evidence paths exist.   Every file-looking `code span` in
     docs/status-ledger.md resolves under repo root or scaffold/.
  B. No stale principle numbers.    A docs/ note whose frontmatter `updated:`
     is after the 2026-07-20 condensation must not cite P6/P7 (old-scheme only).
  C. CONTENTS counts match tree.    CONTENTS's "(N notes)" for decisions and its
     "three sequencing questions" match docs/decision-*.md and open-edges.

Run from anywhere; resolves paths relative to the repo root (this file's ../).
Fails loud, prints every violation. No deps beyond the stdlib.
"""
from __future__ import annotations
import re
import sys
from datetime import date
from pathlib import Path

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = Path(__file__).resolve().parent.parent.parent
# The source tree is lib/ + prog/. `SCAFFOLD` kept its name so the checks that
# resolve a citation by trying several bases still read the same; it now points
# at the tree root, and SRC_ROOTS is the pair a check walks when it wants "every
# source file". Repointed 2026-08-31 against .planning/MIGRATION-MAP.tsv, which
# records where each of the 147 originals went.
SCAFFOLD = ROOT
SRC_ROOTS = (ROOT / "lib", ROOT / "prog")


def src_files(pattern: str = "*.chiral"):
    """Every source file under lib/ and prog/, sorted."""
    return sorted(f for r in SRC_ROOTS for f in r.rglob(pattern))
CONDENSATION = date(2026, 7, 20)  # PRINCIPLES.md seven->five
WORDS = {"one":1,"two":2,"three":3,"four":4,"five":5,"six":6,"seven":7,
         "eight":8,"nine":9,"ten":10,"eleven":11,"twelve":12,"thirteen":13,
         "fourteen":14,"fifteen":15,"sixteen":16,"seventeen":17,"eighteen":18,
         "nineteen":19,"twenty":20}


def as_count(tok: str):
    """A claimed count, written as an English word or as digits.

    WORDS stops at twenty because every count it was built for was small. A tier
    that grows past it has no spelling, so the claim can be correct and the check
    still fails: `docs/decisions/` reached 22 notes and check C reported "claims
    22; tree has 22". Digits are accepted here so the ceiling is gone rather than
    merely raised.
    """
    w = WORDS.get(tok.lower())
    return w if w is not None else (int(tok) if tok.isdigit() else None)

# a code span is a file path if it carries a dir sep or a known extension
PATHISH = re.compile(r"`([^`]+)`")
EXTS = (".py", ".chiral", ".md")


def is_pathish(tok: str) -> bool:
    tok = tok.strip()
    if " " in tok or "|" in tok:
        return False
    return "/" in tok or tok.endswith(EXTS)


# basename index of the tree (built once) — the ledger cites files by bare
# basename ("kernel.py") as shorthand for their real location ("chirality/kernel.py").
_BASENAMES: set[str] | None = None


def _basenames() -> set[str]:
    global _BASENAMES
    if _BASENAMES is None:
        _BASENAMES = {p.name for p in ROOT.rglob("*")
                      if p.is_file() and ".git" not in p.parts}
    return _BASENAMES


def resolve(tok: str) -> bool:
    tok = tok.strip()
    if "/" in tok:  # explicit path: check both roots verbatim
        return (ROOT / tok).exists() or (SCAFFOLD / tok).exists()
    return tok in _basenames()  # bare basename: it must exist somewhere


class Vacuous(Exception):
    """A check whose SUBJECT no longer exists. Raised instead of returning [],
    because an empty loop reporting `ok` is a gate that passes forever. The
    runner prints these under their own heading, the same way the test suite
    prints its unported phases."""


def check_a() -> list[str]:
    """Ledger evidence paths exist."""
    errs: list[str] = []
    led = ROOT / "docs" / "definitions" / "status-ledger.md"
    text = led.read_text()
    for m in PATHISH.finditer(text):
        raw = m.group(1)
        # split compound evidence cells: "chirality/native.py, lib/mach-x64.chiral"
        for tok in re.split(r"[;,]", raw):
            tok = tok.strip()
            # strip trailing prose like "(no LLVM)" and globs like tests/test_*
            tok = re.sub(r"\s*\(.*$", "", tok).strip()
            if not tok or not is_pathish(tok):
                continue
            if "{" in tok:  # brace-shorthand (test_{a,b}.py): skip, unexpandable
                continue
            if "*" in tok:  # glob: check the parent dir exists
                parent = tok.rsplit("/", 1)[0] if "/" in tok else ""
                if parent and not ((ROOT / parent).is_dir()
                                   or (SCAFFOLD / parent).is_dir()):
                    errs.append(f"[A] ledger glob parent missing: {tok}")
                continue
            if not resolve(tok):
                errs.append(f"[A] ledger evidence path not found: {tok}")
    return errs


def frontmatter_date(text: str) -> date | None:
    m = re.search(r"^updated:\s*(\d{4})-(\d{2})-(\d{2})\s*$", text, re.M)
    if not m:
        return None
    return date(int(m.group(1)), int(m.group(2)), int(m.group(3)))


# ── the doc tier is RECURSIVE as of the 2026-08-31 role sort ─────────────────
# Docs live in docs/{definitions,decisions,modules,banks,implementation,
# benchmarks,examples,elements}/ now. Every check below that meant "every doc"
# was spelled (ROOT/"docs").glob("*.md"), which after the sort is one file:
# docs/index.md. Found by the PRINCIPLES.md audit, 2026-08-31, with a live
# miss: docs/banks/evidence-and-split.md is dated 2026-08-24, cites P6 and P7,
# and check B did not see it.
# A leading underscore marks a FORM rather than a claim. `_TEMPLATE.md` carries
# placeholder links ([[goals/<name>]]) and placeholder frontmatter on purpose:
# the scaffolder fills them. Checking a template's placeholders reports rot that
# the next scaffold overwrites, so every enumeration here skips them.
def is_form(p) -> bool:
    return p.name.startswith("_")

def doc_tier(pattern: str = "*.md"):
    """Every markdown doc under docs/, at any depth, sorted and deduped.
    Templates are skipped: see is_form."""
    return sorted(p for p in set((ROOT / "docs").rglob(pattern)) if not is_form(p))

def check_b() -> list[str]:
    """No P6/P7 in docs updated after the condensation."""
    errs: list[str] = []
    for md in doc_tier():
        text = md.read_text()
        d = frontmatter_date(text)
        if d is None or d <= CONDENSATION:
            continue
        # a doc may legitimately name the old *range* while describing the
        # crosswalk ("resolves older P1 through P7 citations") — that is meta,
        # not a stale citation. Blank those spans before scanning.
        scan = re.sub(r"P1\s*(?:through|to|–|-)\s*P7", "", text)
        for m in re.finditer(r"\bP[67]\b", scan):
            line = text.count("\n", 0, m.start()) + 1
            errs.append(f"[B] {md.name}:{line} cites {m.group(0)} "
                        f"(old scheme) but is dated {d} > condensation")
    return errs


def check_c() -> list[str]:
    """CONTENTS decision-note count and sequencing-question count match the tree."""
    errs: list[str] = []
    mapmd = (ROOT / "CONTENTS.md").read_text()

    n_decisions = len(doc_tier("decision-*.md"))
    # accepts the pre-role-sort `docs/decision-*` and the current `docs/decisions/`
    m = re.search(r"`docs/decisions?(?:/|-\*)`\s*\((\w+)\s+notes?\)", mapmd)
    if not m:
        errs.append("[C] CONTENTS.md no '(N notes)' claim for docs/decision-*")
    else:
        claimed = as_count(m.group(1))
        if claimed != n_decisions:
            errs.append(f"[C] CONTENTS claims {m.group(1)} decision notes; "
                        f"tree has {n_decisions}")

    edges = (ROOT / "docs" / "definitions" / "open-edges.md").read_text()
    seq_block = edges.split("Sequencing questions", 1)
    if len(seq_block) == 2:
        n_seq = len(re.findall(r"^\s*\d+\.\s", seq_block[1], re.M)) or \
                len(re.findall(r"^-\s", seq_block[1], re.M))
        m = re.search(r"(\w+)\s+sequencing questions", mapmd)
        if m and as_count(m.group(1)) != n_seq:
            errs.append(f"[C] CONTENTS claims {m.group(1)} sequencing questions; "
                        f"open-edges has {n_seq}")
    return errs


def check_d() -> list[str]:
    """Banks-tier integrity: every bank is listed in the INDEX and carries the
    load-bearing sections (concept / cross-cuts / anchors). Keeps the depth tier
    and its index from silently drifting apart (the same anti-rot logic as A/B/C)."""
    errs: list[str] = []
    banks = ROOT / "docs" / "banks"
    if not banks.is_dir():
        return errs  # tier not present yet; nothing to check
    index = banks / "INDEX.md"
    if not index.exists():
        errs.append("[D] docs/banks/INDEX.md missing (the tier's entry + reverse-link target)")
        return errs
    idx = index.read_text()
    for f in sorted(banks.glob("*.md")):
        if f.name == "INDEX.md":
            continue
        if f"[[banks/{f.stem}]]" not in idx:
            errs.append(f"[D] bank '{f.stem}' not listed in banks/INDEX.md")
        text = f.read_text()
        for sec in ("## 1", "## 3", "## 6"):  # concept / cross-cuts / anchors
            if sec not in text:
                errs.append(f"[D] bank '{f.stem}' missing schema section {sec}")
    return errs


CLASSES = ("CONFORMS", "EXTEND", "REFACTOR", "BUILD", "DECISION")


def _map_classes() -> dict[int, set[str]]:
    """E-number -> set of Class verdicts from CONFORMANCE-MAP rows, with
    E-ranges (E30–E33) expanded so sibling-tagged rows are found."""
    classes: dict[int, set[str]] = {}
    cmap = ROOT / "records" / "conformance-map.md"
    if not cmap.exists():
        return classes
    for ln in cmap.read_text().splitlines():
        if not ln.startswith("|"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 7:
            continue
        verdicts = {c for c in CLASSES if re.search(rf"\b{c}\b", cells[4])}
        if not verdicts:
            continue
        for m in re.finditer(r"E(\d+)(?:[–-]E?(\d+))?", cells[6]):
            a, b = int(m.group(1)), int(m.group(2) or m.group(1))
            for n in range(a, min(b, a + 40) + 1):
                classes.setdefault(n, set()).update(verdicts)
    return classes


def check_e() -> list[str]:
    """Bank shard-header build-state claims agree with the conformance map.
    A shard header `### Shard N — … · **CLAIM (E#s)**` whose map-class tokens
    share nothing with the map's verdicts for those E#s has rotted (or the map
    has). Lenient by design: headers without a map-class token are skipped."""
    errs: list[str] = []
    cmap = _map_classes()
    banks = ROOT / "docs" / "banks"
    if not banks.is_dir() or not cmap:
        return errs
    for f in sorted(banks.glob("*.md")):
        if f.name == "INDEX.md":
            continue
        for i, ln in enumerate(f.read_text().splitlines(), 1):
            m = re.match(r"### Shard \d+.*·\s*\*\*(.+?)\*\*", ln)
            if not m:
                continue
            claim = m.group(1)
            claimed = {c for c in CLASSES if re.search(rf"\b{c}\b(?![-A-Z])", claim)}
            enums = [int(x) for x in re.findall(r"\bE(\d+)\b", claim)]
            mapped: set[str] = set()
            for n in enums:
                mapped |= cmap.get(n, set())
            if claimed and mapped and claimed.isdisjoint(mapped):
                errs.append(f"[E] banks/{f.name}:{i} shard claims "
                            f"{'/'.join(sorted(claimed))} but map has "
                            f"{'/'.join(sorted(mapped))} for "
                            f"{'/'.join('E%d' % n for n in enums)}")
    return errs


def check_f() -> list[str]:
    """[[links]] and `related:` entries resolve to a real note (docs/, banks/,
    examples/, .planning/, root). An E-element link ([[E26-alarms]], [[E38]])
    resolves through its E-number: to the element's artifact under any slug, or
    to the catalog for a not-yet-drafted element — only a nonexistent element is
    rot. In examples/ only link-shaped targets are checked (E…, x/y, a-b);
    [[p]]-style denotational brackets are prose, not links.
    One report per (file, target)."""
    errs: list[str] = []
    catalog = (ROOT / "docs" / "elements" / "catalog.md").read_text() \
        if (ROOT / "docs" / "elements" / "catalog.md").exists() else ""
    catalog_ids = {int(n) for n in re.findall(r"^\|\s*E(\d+)\s*\|", catalog, re.M)}

    def resolves(name: str) -> bool:
        m = re.match(r"E(\d+)(?:-|$)", name)
        if m:
            n = int(m.group(1))
            return bool(list((ROOT / "docs" / "examples").glob(f"E{n:02d}-*.md"))) \
                or n in catalog_ids
        # A [[slug]] is either a bare stem ([[thesis]]) or a path relative to
        # docs/ ([[banks/module]]). Matching stems only made every one of the
        # 60-odd path-form bank links read as dangling.
        docs = ROOT / "docs"
        for f in doc_tier():
            if f.stem == name or f.relative_to(docs).with_suffix("").as_posix() == name:
                return True
        # The agent tier is tracked and nests (.planning/protocol/tone.md), so a
        # top-level probe alone read every [[protocol/tone]] as dangling.
        return (bool(list((ROOT / ".planning").rglob(f"{name}.md")))
                or bool(list((ROOT / ".planning").rglob(f"{name.split('/')[-1]}.md")))
                or (ROOT / f"{name}.md").exists())

    def linkish(f, name: str) -> bool:
        if f.parent.name != "examples":
            return True
        return bool(re.match(r"E\d+", name)) or "/" in name or "-" in name

    files = (doc_tier()
             + sorted((ROOT / "docs" / "examples").glob("*.md")))
    for f in files:
        text = f.read_text()
        # a [[link]] in a code span is mention, not link; blank same-length to keep offsets
        scan = re.sub(r"`[^`\n]*`", lambda m: " " * len(m.group(0)), text)
        seen: set[str] = set()
        for m in re.finditer(r"\[\[([A-Za-z0-9/_.-]+)\]\]", scan):
            t = m.group(1)
            if t in seen or not linkish(f, t) or resolves(t):
                continue
            seen.add(t)
            line = text.count("\n", 0, m.start()) + 1
            errs.append(f"[F] {f.parent.name}/{f.name}:{line} dangling [[{t}]]")
        m = re.search(r"^related:\s*\[([^\]]*)\]", text, re.M)
        for r in (m.group(1).split(",") if m else []):
            r = r.strip()
            if r and r not in seen and not resolves(r):
                seen.add(r)
                errs.append(f"[F] {f.parent.name}/{f.name} related: '{r}' unresolved")
    return errs


# A code span shaped like a path, whatever its extension. G and R carry a `ctx`
# so the banks' detached convention works (`ports.chiral` then a bare `:19`). A span
# this pair cannot open must CLEAR that ctx. Leaving it set attributed a bare
# `:NN` to whichever file resolved last, which was a different file two hundred
# lines up. Measured 2026-09-01: verification.md:193's `:129` was reported
# against alloc-fixed.chiral, and testing-floors.md:309's `:490-499` against
# ddc.chiral, neither of which either line is about.
PATHSPAN = re.compile(r"[A-Za-z0-9_][A-Za-z0-9_/.-]*\.[A-Za-z][A-Za-z0-9]*"
                      r"(?::\d+(?:[–-]\d+)?)?$")


_UNIQUE_SRC: dict | None = None


def _unique_src() -> dict:
    """Bare basename -> the one file under lib/ or prog/ that carries it. A name
    borne by two files is left out, so `mach.chiral` (three homes) stays
    unresolvable. Docs cite by basename constantly (`loader.chiral:39`), and
    without this 269 of the 456 line-numbered .chiral citations resolve to
    nothing and are skipped. Measured 2026-09-01."""
    global _UNIQUE_SRC
    if _UNIQUE_SRC is None:
        homes: dict = {}
        for f in src_files("*"):
            homes.setdefault(f.name, []).append(f)
        _UNIQUE_SRC = {k: v[0] for k, v in homes.items() if len(v) == 1}
    return _UNIQUE_SRC


def _find_src(tok: str):
    for base in (ROOT, SCAFFOLD, SCAFFOLD / "chirality", SCAFFOLD / "lib"):
        p = base / tok
        if p.is_file():
            return p
    if "/" not in tok:
        return _unique_src().get(tok)
    return None


def check_g() -> list[str]:
    """Line-numbered code citations in docs still fit the file. Handles the
    banks' detached convention: `ports.chiral` … (`:19`) — a bare `:NN` span
    resolves against the last file span seen. Two limits on that ctx, both
    because a bare span read against the wrong file is a guess, and a check
    aimed at a guess is worse than one that abstains: an unresolvable file
    CLEARS the ctx rather than leaving the previous one standing, and the ctx
    does not cross a blank line. Measured 2026-09-01 on E174-r-row-width.md,
    where `doc.chiral:179-183` in one paragraph was carrying the `:360` and
    `:368` of render.chiral four lines below it."""
    errs: list[str] = []
    nlines: dict = {}

    def count(p) -> int:
        if p not in nlines:
            nlines[p] = len(p.read_text().splitlines())
        return nlines[p]

    for f in doc_tier():
        ctx = None
        for i, ln in enumerate(f.read_text().splitlines(), 1):
            if not ln.strip():          # ctx does not cross a paragraph break
                ctx = None
            for span in re.findall(r"`([^`]+)`", ln):
                span = span.strip()
                pm = re.match(r"([A-Za-z0-9_/.-]+\.(?:py|chiral))"
                              r"(?::(\d+)(?:[–-](\d+))?)?$", span)
                if pm:
                    ctx = p = _find_src(pm.group(1))
                    if p is None:
                        continue
                    if pm.group(2) and int(pm.group(3) or pm.group(2)) > count(p):
                        errs.append(f"[G] {f.parent.name}/{f.name}:{i} cites "
                                    f"`{span}` but file has {count(p)} lines")
                    continue
                if PATHSPAN.match(span):
                    ctx = None
                    continue
                lm = re.match(r":(\d+)(?:[–-](\d+))?$", span)
                if lm and ctx is not None:
                    if int(lm.group(2) or lm.group(1)) > count(ctx):
                        errs.append(f"[G] {f.parent.name}/{f.name}:{i} cites "
                                    f"`{span}` of {ctx.name} ({count(ctx)} lines)")
    return errs


def _defines(p, name: str) -> list[int]:
    """Line numbers at which source file `p` DEFINES `name`. chirality top-level
    forms only bind at column 0 — `(def x ...)`, `(data X ...)`, `(porttype X)`
    — so anchoring the pattern at `^(` keeps a nested *use* from reading as a
    definition. Python: a `def`/`class` at any indent, or a module-level
    binding."""
    out: list[int] = []
    n = re.escape(name)
    if p.suffix == ".chiral":
        pat = re.compile(rf"^\([A-Za-z][A-Za-z0-9_-]*\s+{n}(?![A-Za-z0-9_?!*<>=+-])")
    else:
        pat = re.compile(rf"^\s*(?:def|class)\s+{n}\b|^{n}\s*[:=]")
    for i, ln in enumerate(p.read_text().splitlines(), 1):
        if pat.search(ln):
            out.append(i)
    return out


def check_r() -> list[str]:
    """R. A line citation lands on the symbol it is cited FOR (added 2026-08-25).

    Check G reads as "line citations are cross-checked against live files" and
    is in fact a BOUNDS test: it fires only when a citation runs off the end of
    the file. `docs/banks/verification.md` carried `ddc.chiral:127` and `:129`
    for `ddc-legc` and `ddc-verdict-code`, which live at 162 and 185 — both
    numbers sit comfortably inside a 191-line file, so G passed them, and both
    were stale before the run that finally noticed. Content was never consulted.
    G stays as it is; this is the second predicate, not a patch to the first.

    The rule, and it is deliberately the narrow one. Fire only where the
    mechanical tier can know what a citation was FOR: the doc names a bare
    symbol in a code span, the very next code span is a single-line citation
    into a file that DEFINES that symbol, and the cited line is not the
    definition. Then the doc is pointing at a definition it has lost track of.

    Three scope limits, each because the wider rule would be unsound rather
    than because it would be inconvenient:
      * SINGLE-LINE citations only. `surface.py:74–216` is a claim about a
        REGION ("the toplevel dispatch"); requiring a name inside a span is not
        a thing a range means.
      * DEFINED-here only. A doc may cite a *use* site, and legitimately: the
        definition line is the one place a mechanical check can name.
      * The symbol must be the code span immediately before the citation, with
        at most a short connective between them (`X` at `f:N`, `X` (`f:N`)).
        Any other span on the line is prose context, not the subject.

    Everything outside those limits is still uncaught and is named in the
    banks' own residue, not papered over here.
    """
    errs: list[str] = []
    ident = re.compile(r"^[A-Za-z_][A-Za-z0-9_?!*<>=+-]*$")
    cite = re.compile(r"([A-Za-z0-9_/.-]+\.(?:py|chiral))(?::(\d+))?$")
    bare = re.compile(r":(\d+)$")

    for f in doc_tier():
        ctx = None
        for i, ln in enumerate(f.read_text().splitlines(), 1):
            if not ln.strip():          # ctx does not cross a paragraph break
                ctx = None
            spans = [(m.start(), m.end(), m.group(1).strip())
                     for m in re.finditer(r"`([^`]+)`", ln)]
            for k, (pos, _end, s) in enumerate(spans):
                cm, bm = cite.match(s), bare.match(s)
                if cm:
                    ctx = p = _find_src(cm.group(1))
                    if p is None:
                        continue
                    if not cm.group(2):
                        continue
                    want = int(cm.group(2))
                elif bm and ctx is not None:
                    p, want = ctx, int(bm.group(1))
                else:
                    if PATHSPAN.match(s):
                        ctx = None
                    continue
                if k == 0:
                    continue
                sym = spans[k - 1][2]
                if not ident.match(sym) or len(sym) < 3:
                    continue
                if len(ln[spans[k - 1][1]:pos]) > 40:
                    continue
                defs = _defines(p, sym)
                if not defs or want in defs:
                    continue
                errs.append(f"[R] {f.parent.name}/{f.name}:{i} cites `{s}` for "
                            f"`{sym}`, but {p.name} defines it at "
                            f"{', '.join(str(d) for d in defs)}")
    return errs


def check_h() -> list[str]:
    """The idioms cheatsheet's refine operators exist in refine.py's _OPS —
    the reference every pre-run copies syntax from must not teach illegal ops."""
    errs: list[str] = []
    cheat = ROOT / "docs" / "examples" / "_CHEATSHEET.md"
    rf = SCAFFOLD / "chirality" / "refine.py"
    if not rf.exists():
        raise Vacuous("refine.py is the Python oracle, CUT by author decision. "
                      "Nothing verifies the cheatsheet's refine operators now.")
    if not cheat.exists():
        return errs
    m = re.search(r"_OPS\s*=\s*\(([^)]*)\)", rf.read_text())
    ops = set(re.findall(r'"([^"]+)"', m.group(1))) if m else set()
    if not ops:
        return errs
    text = cheat.read_text()
    for i, ln in enumerate(text.splitlines(), 1):
        for form in re.findall(r"\(refine\s[^`]*", ln):
            for op in re.findall(r"\((\S+)\s", form)[1:]:
                if op not in ops:
                    errs.append(f"[H] _CHEATSHEET.md:{i} refine op '{op}' not in "
                                f"refine.py _OPS ({', '.join(sorted(ops))})")
    return errs


def _load_frontier():
    """Load tools/frontier/frontier.py (hyphenated name -> importlib) so this check
    and the digest share ONE definition of the source set + hash."""
    import importlib.util
    path = ROOT / "tools" / "frontier" / "frontier.py"
    if not path.exists():
        return None
    spec = importlib.util.spec_from_file_location("chirality_frontier", path)
    if spec is None or spec.loader is None:
        return None
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def check_i() -> list[str]:
    """I. Frontier digest fresh. If docs/definitions/FRONTIER.md exists it must embed the
    current sources hash; a frontier source that moved without a re-condense
    makes the orientation layer silently stale — the exact rot this tier fights.
    Absent digest = clean (it is optional to generate); present + stale = FAIL."""
    errs: list[str] = []
    digest = ROOT / "docs" / "definitions" / "FRONTIER.md"
    if not digest.exists():
        return errs
    mf = _load_frontier()
    if mf is None:
        return ["[I] docs/definitions/FRONTIER.md exists but tools/frontier/frontier.py is "
                "missing; cannot verify freshness"]
    embedded = mf.embedded_hash(digest.read_text(encoding="utf-8"))
    if embedded is None:
        errs.append("[I] docs/definitions/FRONTIER.md has no sources-hash marker; "
                    "regenerate: python3 tools/frontier/frontier.py condense")
    elif embedded != mf.sources_hash():
        errs.append("[I] docs/definitions/FRONTIER.md is stale (a frontier source changed "
                    "without a re-condense); run: python3 tools/frontier/frontier.py condense")
    return errs


LEDGER_CATS = {"CK", "RF", "EF", "CG", "MEM", "SYS", "FMT", "TR", "CRY",
               "VAL", "ORCH", "APP", "NUM", "RT2"}


def check_j() -> list[str]:
    """J. Ledger ⇄ catalog consistency. docs/elements/ledger.md is the category map
    over the E# set; a catalog element that is not tagged there rots out of the
    map (the exact failure this lint fights, one level up). Every catalog E# must
    appear in the ledger; every non-reserved ledger E# must exist in the catalog;
    every `## CODE · …` category header must use a legend code. Skipped if the
    ledger is absent (optional tier, like D/E/I)."""
    errs: list[str] = []
    ledger = ROOT / "docs" / "elements" / "ledger.md"
    catalog = ROOT / "docs" / "elements" / "catalog.md"
    if not ledger.exists() or not catalog.exists():
        return errs
    catalog_ids = {int(n) for n in
                   re.findall(r"^\|\s*E(\d+)\s*\|", catalog.read_text(), re.M)}
    ledger_ids: set[int] = set()
    reserved_ids: set[int] = set()
    reserved = False
    for ln in ledger.read_text().splitlines():
        hm = re.match(r"^#{2,3}\s+([A-Za-z0-9]+)\s+·", ln)
        if hm:
            code = hm.group(1)
            reserved = "reserved" in ln.lower()
            if code not in LEDGER_CATS:
                errs.append(f"[J] LEDGER.md category '{code}' not in legend "
                            f"({', '.join(sorted(LEDGER_CATS))})")
            continue
        rm = re.match(r"^\|\s*\*{0,2}E(\d+)\*{0,2}\s*\|", ln)
        if rm:
            n = int(rm.group(1))
            ledger_ids.add(n)
            if reserved:
                reserved_ids.add(n)
    for n in sorted(catalog_ids - ledger_ids):
        errs.append(f"[J] E{n} in catalog but untagged in LEDGER.md "
                    f"(add its category+module row)")
    for n in sorted((ledger_ids - reserved_ids) - catalog_ids):
        errs.append(f"[J] E{n} in LEDGER.md but not in catalog "
                    f"(reserved slots belong under a '(reserved)' section)")
    return errs


def check_k() -> list[str]:
    """K. CAT·E# prefix consistency. A `CAT·E#` reference (the LEDGER.md convention)
    is a display label over the stable E# key; its prefix must be a real category and
    must match the element's actual ledger category. Flags an invalid prefix or a
    stale one (e.g. `SYS·E120` when E120 is MEM) so recategorization can't leave
    rotted prefixes in prose. Skipped if the ledger is absent."""
    errs: list[str] = []
    ledger = ROOT / "docs" / "elements" / "ledger.md"
    if not ledger.exists():
        return errs
    cat_of: dict[int, str] = {}
    cur = "?"
    for ln in ledger.read_text().splitlines():
        hm = re.match(r"^#{2,3}\s+([A-Za-z0-9]+)\s+·", ln)
        if hm:
            cur = hm.group(1)
            continue
        rm = re.match(r"^\|\s*\*{0,2}E(\d+)\*{0,2}\s*\|", ln)
        if rm:
            cat_of[int(rm.group(1))] = cur
    targets = list((ROOT / ".planning").rglob("*.md")) \
        + list((ROOT / "docs").rglob("*.md"))
    for f in targets:
        try:
            text = f.read_text()
        except OSError:
            continue
        for m in re.finditer(r"\b([A-Z]{2,4})·E(\d+)\b", text):
            pfx, n = m.group(1), int(m.group(2))
            rel = f.relative_to(ROOT)
            if pfx not in LEDGER_CATS:
                errs.append(f"[K] {rel}: '{pfx}·E{n}' — '{pfx}' is not a "
                            f"ledger category")
            elif n in cat_of and cat_of[n] != pfx:
                errs.append(f"[K] {rel}: '{pfx}·E{n}' stale — ledger has "
                            f"E{n} in {cat_of[n]}")
    return errs


# ─────────────────────────────────────────────────────────────────────────────
# L / M — the ALTITUDE ratchets (added 2026-08-22).
#
# `.planning/BUILD-ORDER.md` §1 names five altitude axes on which things rot by
# sitting below the level of generality that owns them. Four of the five had no
# mechanical check, which made the taxonomy policy rather than physics — exactly
# what P4 rejects ("the model is physics, not policy"). These two are the check.
#
# They are RATCHETS, not absolutes: the tree currently HAS these violations, and a
# permanently-red lint stops being a signal. So each records today's count as a
# baseline and fails only when it GROWS. As E151b and E155 land, lower the
# baselines — tightening the ratchet is part of each element's deliverable.

# A1/A2 · definition altitude: a name with no owning module, re-defined per consumer.
# Baseline 2026-08-22, CORRECTED same day: str-cmp EXACT-NAME in 3 files
# (string-utils, ty-cmp, row-infer). It was first recorded as 4 by conflating the
# exact name with the already-prefixed variants `ar-str-cmp` (asm-reloc:79) and
# `cb-str-cmp` (compile-back:128) — so the ratchet was SLACK BY ONE and would have
# let a new duplicate through. There are 5 ad-hoc comparators; 3 share the name.
# data Ord in 4 (collections, row-infer, ty-cmp + TUI/samples/collections.chiral).
# The 4th Ord is an A3 duplicate-module copy, so E155 removes it and E151b takes the
# rest to 1 — the two ratchets overlap by one file, which is honest, not double-count.
# (The Ord baseline was written as 3 from a scaffold/lib-only grep; this check caught
#  that the moment it ran — the reason a ratchet beats a prose claim.)
# E151b Step 6 pins the other three retired names at their post-change count of 1.
# The trailing space in each pattern makes it an EXACT-NAME match: the prefix-dodged
# clones `gate-contains` (manas/core/gate.chiral), `str-has` (manas/core/stop.chiral)
# and the second `str-has` (manas/core/flow.chiral) are deliberately NOT counted —
# they are different names, they belong to E154, and a pattern that caught them would
# be pinning work this element does not do.
OWNERSHIP_BASELINE = {r"^\(def str-cmp ": 1, r"^\(data Ord \(\)": 2,
                      r"^\(def str-contains ": 1, r"^\(def str-lower ": 1,
                      r"^\(def str-trim ": 1}

def check_l() -> list[str]:
    """L. Ownership ratchet (altitude A1/A2). A shared name defined in N files has no
    owning module; N must never grow. Lower the baseline when an element retires
    copies — see LEDGER VAL/E151."""
    errs: list[str] = []
    srcs = src_files()   # the symlink web the old filter dodged no longer exists
    for pat, baseline in OWNERSHIP_BASELINE.items():
        rx = re.compile(pat, re.M)
        hits = [f for f in srcs if rx.search(f.read_text(errors="replace"))]
        if len(hits) > baseline:
            errs.append(f"[L] {pat!r} now defined in {len(hits)} files (baseline {baseline}) — "
                        f"a shared name with no owning module: "
                        f"{', '.join(str(h.relative_to(ROOT)) for h in sorted(hits))}")
    return errs

# A3 · source-tree altitude — CORRECTED TWICE, final version 2026-08-22.
#
# History, because the errors are instructive: first claim was "9 independent copies,
# nothing prevents drift" (cited differing inodes). Second was "they are hardlinks,
# proved by mutation". Both wrong. `ls -l` settles it in one command:
# ALL of them are SYMLINKS, running in BOTH directions —
#   TUI -> lib : prelude(x3), collections, ports, samples/grid
#   lib -> TUI : grid, vt-parser, utf8, apc, render, session (+ the scriba, agent dirs)
# Resolving every path: 9 real files behind 12 shared paths. There is no duplication
# at all, and nothing to reconcile. The lesson: check the simplest direct observation
# (ls -l) before reasoning from indirect evidence (inodes, mutation experiments).
#
# What survives for E155: `resolve.chiral` takes ONE libdir, which is WHY the symlinks
# exist; and its "first occurrence wins" dedup silently drops a module, a P1 hole.
# The check therefore guards the arrangement rather than hunting for divergence.

def check_m() -> list[str]:
    """M. Shared-foundation integrity (altitude A3). A TUI/ module sharing a basename
    with a scaffold/lib module must resolve to the SAME real file (they are symlinked,
    both directions). A path that becomes an independent copy has silently forked the
    foundation — that is the failure this guards, and it cannot happen by editing,
    only by someone replacing a link with a file."""
    errs: list[str] = []
    if not (ROOT / "TUI").is_dir():
        raise Vacuous("the scaffold/lib <-> TUI symlink web this guards was "
                      "dissolved by the 2026-08-31 migration; 153 entries "
                      "resolved to 147 real files and nothing is linked now.")
    lib = {f.stem: f for f in src_files()}
    for f in sorted((ROOT / "TUI").rglob("*.chiral")):
        src = lib.get(f.stem)
        if src and src.resolve() != f.resolve():
            errs.append(f"[M] {f.relative_to(ROOT)} and {src.relative_to(ROOT)} share a "
                        f"basename but resolve to DIFFERENT real files — the shared "
                        f"foundation has forked (they are symlinked in the tree; see E155)")
    return errs


def check_o() -> list[str]:
    """O. Rung-1 python accounting (added 2026-08-24).

    Every `.py` in the tree must resolve to a row in RUNG1-CHECKLIST's
    C-inventory: an IN-SCOPE owner, a JUDGMENT row, or the dated OUT-OF-SCOPE
    harness list. A new `.py` that nobody classified is exactly how "zero python
    in repo" stays permanently one file away from done.

    The patterns are READ FROM THE DOC, not duplicated here — a second copy in
    code is a thing that drifts from the table it is supposed to enforce, which
    is the A1 error this file exists to catch elsewhere.
    """
    import fnmatch
    errs: list[str] = []
    doc = ROOT / ".planning" / "RUNG1-CHECKLIST.md"
    if not doc.exists():
        return ["[O] .planning/RUNG1-CHECKLIST.md missing — the C-inventory is the authority"]
    text = doc.read_text()
    if "### C-inventory" not in text:
        return ["[O] RUNG1-CHECKLIST.md has no '### C-inventory' section to read patterns from"]
    sec = text.split("### C-inventory", 1)[1].split("\n## ", 1)[0]
    pats = sorted(set(re.findall(r"`([^`]*\*?\.py)`", sec)))
    if not pats:
        return ["[O] C-inventory names no .py patterns — it cannot classify anything"]
    for f in sorted(ROOT.rglob("*.py")):
        rel = f.relative_to(ROOT).as_posix()
        if rel.startswith((".git/", ".claude/worktrees/")):
            continue
        if not any(fnmatch.fnmatch(rel, pat) for pat in pats):
            errs.append(f"[O] {rel} is not classified by RUNG1-CHECKLIST's C-inventory "
                        f"— add it to IN-SCOPE (with an owning C-row), JUDGMENT, or the "
                        f"dated OUT-OF-SCOPE harness list")
    return errs


def check_p() -> list[str]:
    """P. The suite-wide compiler override is TOTAL (added 2026-08-25).

    E166's admission gate (G3) works by exporting CHIRALITY_BIN and running the
    whole native suite, so that "the suite ran under chirality-bin-c" is a claim about
    every phase. It was not. Five sub-scripts re-derived the compiler from
    bin/chirality-bin -> scaffold/build/B1 and ignored the override, and two more went
    through bin/chirality, which had its own resolution -- so seven of eleven phases
    ran under B1 while the gate counted their assertions as chirality-bin-c coverage.
    Mechanized because a convention only some scripts honour is precisely the
    kind of thing that rots back, one new test script at a time.

    The rule: a suite script that names `scaffold/build/B1` as a compiler
    candidate must also consult `CHIRALITY_BIN`. A script that reaches the compiler
    THROUGH bin/chirality names no candidate of its own and needs nothing; bin/chirality
    itself is checked here by name, because it is what makes those phases
    overridable at all.
    """
    errs: list[str] = []
    files = sorted((ROOT / "tools" / "test").glob("*.sh")) + [ROOT / "bin" / "chirality"]
    for f in files:
        if not f.exists():
            errs.append(f"[P] {f.relative_to(ROOT)} missing — four suite phases reach the "
                        f"compiler through it, so the override lives or dies here")
            continue
        text = f.read_text()
        if "scaffold/build/B1" not in text:
            continue
        if "CHIRALITY_BIN" not in text:
            errs.append(f"[P] {f.relative_to(ROOT).as_posix()} resolves a compiler (it names "
                        f"scaffold/build/B1) but never consults CHIRALITY_BIN — an exported "
                        f"override would skip it, and E166's admission claim narrows without "
                        f"saying so")
    return errs


def check_q() -> list[str]:
    """Q. The CONFORMANCE-MAP header's LIVE tally is recomputed (added 2026-08-25).

    The header carries two sets of figures and says so: a dated 2026-07-21
    SNAPSHOT of the classification pass, and a LIVE tally of the file's present
    contents. The snapshot is history and is explicitly not maintained. The live
    half is the part that rots -- every row minted after it is written makes all
    six numbers wrong, silently, which is exactly how the snapshot line went
    stale in the first place. So it is derived here instead of trusted.

    The counting rule is the header's own, transliterated from the `sed`+`awk`
    it publishes: a conformance row is a `|`-line of exactly 8 cells whose Class
    cell is one bare verdict. Splitting on UNESCAPED pipes is what makes the
    escaped `\\|` inside one cell (the `Step(go\\|halt)` row) count as one cell
    rather than shifting that row's columns by one -- so if anyone unescapes it,
    the row drops out and this check fails on the row count, which is the
    behaviour we want. The separate 7-row manas-application-layer table further
    down has its own header and no Principle/E# columns; its rows carry no bare
    verdict in cell 5 and are never counted.

    Scope, deliberately: this governs the LIVE paragraph only. The dated
    snapshot line and the header's standing flag -- that 83 - 82 is not
    reconstructible from the file, because rows were merged or dropped without
    leaving a mint marker -- are author-tier and are NOT touched here. A green Q
    means the live figures match the file today; it says nothing about the delta.
    """
    errs: list[str] = []
    cmap = ROOT / "records" / "conformance-map.md"
    if not cmap.exists():
        return ["[Q] records/conformance-map.md missing — the live tally has no subject"]
    text = cmap.read_text()

    rows: list[str] = []
    for ln in text.splitlines():
        if not ln.startswith("|"):
            continue
        cells = re.split(r"(?<!\\)\|", ln)
        if len(cells) != 10:  # leading + trailing empties around 8 data cells
            continue
        verdict = cells[5].strip(" *")
        if verdict in CLASSES:
            rows.append(verdict)
    live = {c: rows.count(c) for c in CLASSES}

    if "**Live, recounted" not in text:
        return ["[Q] CONFORMANCE-MAP header has no '**Live, recounted …**' paragraph — "
                "without one the file states only a dated snapshot, and the present "
                f"contents ({len(rows)} conformance rows) are claimed nowhere"]
    para = " ".join(text.split("**Live, recounted", 1)[1].split("\n\n", 1)[0].split())

    m = re.search(r"\*\*(\d+) conformance rows\*\*", para)
    if not m:
        errs.append("[Q] the live paragraph states no '**N conformance rows**' count "
                    f"(the file has {len(rows)})")
    elif int(m.group(1)) != len(rows):
        errs.append(f"[Q] live paragraph claims {m.group(1)} conformance rows; "
                    f"counting the file now gives {len(rows)}")

    for cls in CLASSES:
        m = re.search(rf"\b{cls} (\d+)", para)
        if not m:
            errs.append(f"[Q] live paragraph names no {cls} tally (the file has {live[cls]})")
        elif int(m.group(1)) != live[cls]:
            errs.append(f"[Q] live paragraph claims {cls} {m.group(1)}; "
                        f"counting the file now gives {live[cls]}")

    m = re.search(r"\(sum (\d+)\)", para)
    if m and int(m.group(1)) != len(rows):
        errs.append(f"[Q] live paragraph's '(sum {m.group(1)})' does not match the "
                    f"{len(rows)} conformance rows counted now")
    return errs



def check_n() -> list[str]:
    """N. LEDGER state vs examples/INDEX pipeline state.

    Reworked 2026-08-22 from a stashed draft that was harmful as written: it
    defined check_l(), which already exists (ownership ratchet), so Python would
    have taken the later definition and SILENTLY DROPPED a live check. Its regex
    also captured column 2 (the category: "chokepoint", "linearity") instead of
    column 3 (the state), so all of its comparisons were dead and it always
    reported ok. Both were measured before rewriting.

    Coarse by design -- the LEDGER state column is a pointer, not a snapshot,
    and CONFORMANCE-MAP wins on disagreement. Only flags pairs that cannot both
    be true.

    `superseded` (added 2026-09-01) is the one state this check pairs EXACTLY
    rather than coarsely. It is not a readiness value that the two documents may
    legitimately see from different distances: it says the element stopped being
    the thing that gets built, and half a supersession -- retired in the LEDGER,
    still live in the pipeline index, or the reverse -- is the same lost history
    the state exists to prevent. Vocabulary: the Status section of
    docs/examples/INDEX.md.
    """
    errs: list[str] = []
    ledger = ROOT / "docs" / "elements" / "ledger.md"
    index = ROOT / "docs" / "examples" / "INDEX.md"
    if not ledger.exists() or not index.exists():
        return errs
    # LEDGER row: | E# | category | state | ... -- the state is column 3.
    lstate: dict[int, str] = {}
    for ln in ledger.read_text().splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) >= 3 and re.match(r"^\*{0,2}E\d+\*{0,2}$", cells[0]):
            num = int(re.sub(r"\D", "", cells[0]))
            # "**built (ENFORCED)**" -> "built"; "part" -> "part"
            lstate[num] = re.sub(r"[*`]", "", cells[2]).split()[0].lower()
    pipe: dict[int, str] = {}
    for ln in index.read_text().splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        # INDEX header: | Element | Title | Kind | Ref | Status | Artifact |
        # Status is cells[4]. (The stashed draft used cells[5] -- the Artifact
        # link -- which is the second reason it could never fire. Verified
        # against the live header 2026-08-22.) The cell carries prose after the
        # word, e.g. "implemented (2026-08-02: ...)", so take the first token.
        if len(cells) >= 5 and re.match(r"^E\d+$", cells[0]):
            st = re.sub(r"[*`]", "", cells[4]).strip()
            if st:
                pipe[int(cells[0][1:])] = st.split()[0].lower()
    if not lstate or not pipe:
        return errs
    # A ledger row carrying the literal marker "UNRESOLVED" is a disagreement
    # someone has SEEN and deliberately not picked (the doc-tier rule: when the
    # disagreement is above this doc, FLAG, never pick). Those are reported on
    # every run but do not fail the gate -- a permanently red lint gets ignored,
    # and that is worse than a visible standing flag.
    flagged: dict[int, bool] = {}
    for ln in ledger.read_text().splitlines():
        fm = re.match(r"^\|\s*\*{0,2}E(\d+)\*{0,2}\s*\|", ln)
        if fm and "UNRESOLVED" in ln:
            flagged[int(fm.group(1))] = True
    for n, ls in sorted(lstate.items()):
        ps = pipe.get(n)
        if ps is None:
            continue
        if flagged.get(n):
            print(f"  [N] E{n} KNOWN disagreement (ledger={ls}, INDEX={ps}) "
                  f"-- flagged in the row, not failing")
            continue
        if "superseded" in (ls, ps) and ls != ps:
            errs.append(f"[N] E{n} is superseded on ONE SIDE ONLY "
                        f"(ledger={ls}, INDEX={ps}) -- supersession retires the "
                        f"element in both registries or in neither")
        if ls == "built" and ps in ("design",):
            errs.append(f"[N] E{n} ledger=built but INDEX={ps} "
                        f"(built is past the pipeline's start)")
        if ps == "implemented" and ls not in ("built",):
            errs.append(f"[N] E{n} INDEX=implemented but ledger={ls} "
                        f"(pipeline says done, ledger disagrees)")
    return errs


def _sexp_args(text: str, start: int) -> list[str] | None:
    """Split the form opening at `text[start] == '('` into its arguments.

    String-aware and paren-balanced, because both matter here: a digest literal
    can contain parens (`(end-module "prelude")` is the tree's first anchor) and
    a path can contain none. Returns [head, arg1, arg2, ...] or None if the form
    does not close.
    """
    if text[start] != "(":
        return None
    i, depth, parts, cur, in_str = start + 1, 1, [], "", False
    while i < len(text):
        c = text[i]
        if in_str:
            cur += c
            if c == "\\" and i + 1 < len(text):
                cur += text[i + 1]; i += 2; continue
            if c == '"':
                in_str = False
            i += 1; continue
        if c == '"':
            in_str = True; cur += c; i += 1; continue
        if c == "(":
            depth += 1; cur += c; i += 1; continue
        if c == ")":
            depth -= 1
            if depth == 0:
                if cur.strip():
                    parts.append(cur.strip())
                return parts
            cur += c; i += 1; continue
        if c in " \t\n\r" and depth == 1:
            if cur.strip():
                parts.append(cur.strip())
            cur = ""; i += 1; continue
        cur += c; i += 1
    return None


def check_s() -> list[str]:
    """S. A rank-2 anchor's PATH is a property of git, not of a run (2026-08-25).

    `oid-prov` ranks every `or-fixed` 2 regardless of the path
    (test-floor.chiral), so a file the harness wrote thirty seconds ago launders
    itself to "a fixed committed artifact, or a reference outside BOTH legs" --
    the rank that caught E161 G0. E170 W0.3 closed the half a type can see (the
    `or-fixed` arm now OPENS the path and compares the digest). This is the half
    it cannot: clauses 1-3 of the admission test
    (docs/testing-floors.md:246-252) are properties of the REPOSITORY -- tracked,
    not matched by .gitignore, digest argument non-empty -- and no value in chirality
    can observe them. `pv-fixed` is worse than `or-fixed`: it is an `ExProv`, and
    NOTHING opens it, before or after W0.3. This check is its only mechanical
    substitute.

    Clauses 4 (independent of both legs) and 5 (small enough to review) stay
    review discipline and are deliberately not mechanised here.

    SCOPE, stated because a check that hides its blind spot is worse than one
    that names it: this reads paths that are WRITTEN DOWN -- a string literal, or
    a bare name bound by `(def <name> Str "…")` in the same file. A path
    assembled at runtime is invisible to it, and so is a path that arrives
    through a `case` pattern (`oid-prov`'s own `(pv-fixed pa dg)` is exactly
    that). Those are skipped rather than reported: an anchor whose path cannot be
    named in the source is not a committed reviewable artifact under clause 5
    either, so the rank is already unavailable to it for a reason this check does
    not have to restate.
    """
    import subprocess
    errs: list[str] = []
    tracked: set[str] = set()
    try:
        out = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT,
                             capture_output=True, text=True, check=True).stdout
        tracked = {x for x in out.split("\0") if x}
    except Exception as e:  # a lint that cannot ask git must say so, not pass
        return [f"[S] cannot read the git index ({e}) — clause 1 (tracked) is "
                f"unverifiable, and passing on that would be the laundering this "
                f"check exists to catch"]

    def ignored(rel: str) -> bool:
        return subprocess.run(["git", "check-ignore", "-q", rel],
                              cwd=ROOT, capture_output=True).returncode == 0

    for f in src_files():
        if f.is_symlink():
            continue
        rel_src = f.relative_to(ROOT).as_posix()
        raw = f.read_text()
        # Comment lines are BLANKED, not deleted -- the same rule E168's G8 lint
        # follows, so the line numbers reported below are the file's own.
        text = "\n".join("" if ln.lstrip().startswith(";") else ln
                          for ln in raw.split("\n"))
        # (def <name> Str "literal") / (def <name> Bytes (str->bytes "literal"))
        strdefs = dict(re.findall(r'\(def\s+([^\s()]+)\s+Str\s+"((?:[^"\\]|\\.)*)"\s*\)', text))
        bytedefs = dict(re.findall(
            r'\(def\s+([^\s()]+)\s+Bytes\s+\(str->bytes\s+"((?:[^"\\]|\\.)*)"\s*\)\s*\)', text))

        def literal(arg: str, table: dict) -> str | None:
            if arg.startswith('"') and arg.endswith('"'):
                return arg[1:-1]
            m = re.fullmatch(r'\(str->bytes\s+"((?:[^"\\]|\\.)*)"\s*\)', arg)
            if m:
                return m.group(1)
            return table.get(arg)

        for m in re.finditer(r"\((or-fixed|pv-fixed)\b", text):
            # `((or-fixed pa dg) …)` is a PATTERN, not a construction -- the same
            # spelling test-e168-floor.sh's G8 lint uses to count mint sites.
            if m.start() > 0 and text[m.start() - 1] == "(":
                continue
            args = _sexp_args(text, m.start())
            if args is None or len(args) < 2:
                continue
            if args[1].startswith("("):
                continue          # the `data` declaration: `(pv-fixed (path Str) …)`
            path = literal(args[1], strdefs)
            if path is None:
                continue          # not written down here; see SCOPE above
            line = text[:m.start()].count("\n") + 1
            where = f"{rel_src}:{line}"
            if path not in tracked:
                errs.append(f"[S] {where} names the rank-2 anchor '{path}', which git does "
                            f"not track — admission clause 1. An untracked file is not a "
                            f"COMMITTED artifact, and rank 2 is the only rank that word "
                            f"carries")
            if ignored(path):
                errs.append(f"[S] {where} names the rank-2 anchor '{path}', which .gitignore "
                            f"matches — admission clause 2. A build-written file laundering "
                            f"itself to rank 2 is the whole reason this check exists")
            if len(args) < 3:
                errs.append(f"[S] {where} carries no digest argument at all — admission "
                            f"clause 3")
                continue
            dig = literal(args[2], bytedefs)
            if dig is not None and dig == "":
                errs.append(f"[S] {where} names '{path}' with an EMPTY digest — admission "
                            f"clause 3. The digest IS the bytes (testing-floors.md:250-252), "
                            f"so an empty one is an anchor that matches every file")
    return errs


def check_t() -> list[str]:
    """T. Every pipeline ARTIFACT ON DISK still has its registry rows (2026-09-01).

    Checks A-S all start FROM a registry and look outward. J walks the catalog
    and the LEDGER against each other; N walks the LEDGER against INDEX; each can
    only see an element that some registry file already names. NOTHING enumerated
    the files. So an element could lose its rows while docs/examples/E<NN>-*.md
    and docs/elements/specs/E<NN>-*-SPEC.md sat on disk, and the whole lint stayed
    blind to it: the artifacts are still there, still readable, still cited, and
    the element is invisible to every "what do we have?" the registry answers.

    Written from E86 (`ioctl` as a sys crossing): both artifacts present,
    implemented 2026-08-06 per .planning/SCRIBA-SYSCALL-HANDOFF.md:102, and zero
    rows in the catalog, the LEDGER or INDEX -- because when E99 reshaped the
    work the row was DELETED rather than marked `superseded`. Deleting a row is
    not retiring an element, it is forgetting one. This check is the reason that
    cannot happen again silently.

    Both pairings are asserted, because the two registries fail differently and
    both failures are live in this tree: a missing CATALOG row (which J then
    chains on to a LEDGER row) and a missing INDEX row (which N then chains on to
    a state, and which tools/pack/pack.py's examples_for() needs to pick the
    pipeline artifact out of an element's companion files).

    E# lane only. U#/S# artifacts key to different source documents
    (.planning/USER-LAYER-GAP.md, .planning/SCRIBA-PRIMITIVE-CHECKLIST.md -- see
    the source adapters in tools/pack/pack.py) and this check does not model
    them; asserting them against the E# catalog would be a check aimed at a
    guess."""
    errs: list[str] = []
    catalog = ROOT / "docs" / "elements" / "catalog.md"
    index = ROOT / "docs" / "examples" / "INDEX.md"
    exdir = ROOT / "docs" / "examples"
    specdir = ROOT / ".planning" / "specs"
    if not catalog.exists() or not exdir.exists():
        return errs
    arts: dict[int, list[str]] = {}
    for d, pat in ((exdir, "E*.md"), (specdir, "E*-SPEC.md")):
        if not d.exists():
            continue
        for f in sorted(d.glob(pat)):
            m = re.match(r"E(\d+)", f.name)
            if m:
                arts.setdefault(int(m.group(1)), []).append(
                    str(f.relative_to(ROOT)))
    if not arts:
        raise Vacuous("no docs/examples/E*.md or docs/elements/specs/E*-SPEC.md on "
                      "disk -- there is no artifact tier to hold to the registry")
    cat_ids = {int(n) for n in
               re.findall(r"^\|\s*E(\d+)\s*\|", catalog.read_text(), re.M)}
    idx_ids = set()
    if index.exists():
        idx_ids = {int(n) for n in
                   re.findall(r"^\|\s*E(\d+)\s*\|", index.read_text(), re.M)}
    for n in sorted(arts):
        files = ", ".join(arts[n])
        if n not in cat_ids:
            errs.append(f"[T] E{n} has artifacts on disk ({files}) but NO row in "
                        f"docs/elements/catalog.md -- an element the "
                        f"registry cannot see. If its work moved to another "
                        f"element, the row is restored as `superseded`, not deleted")
        if index.exists() and n not in idx_ids:
            errs.append(f"[T] E{n} has artifacts on disk ({files}) but NO row in "
                        f"docs/examples/INDEX.md -- the corpus index does not "
                        f"list a file of its own corpus, and check N has no "
                        f"pipeline state to compare")
    return errs

# ⚑ THE PREFLIGHT. Checks A-S read the doc tier directly, with no fallback, so on
# a tree that does not have it the first check dies with a FileNotFoundError and
# says nothing about the other eighteen. That is a crash where a REFUSAL belongs:
# the tool is not broken, its subject is absent. The preflight names every missing
# input at once and exits 2 -- distinct from 0 (clean) and 1 (violations), because
# "there was nothing to lint" is not "the tree is clean".
#
# It does NOT invent a mapping onto this tree's docs/{examples,definitions,elements}/.
# Whether those replace docs/banks/ + .planning/ is an author decision; see
# MIGRATION-NOTES.md. A linter repointed at a guess passes because it is looking at
# nothing, which is the exact failure class this tool exists to catch.
REQUIRED_INPUTS = [
    ("docs/definitions/status-ledger.md",     "check A -- evidence paths"),
    ("CONTENTS.md",                           "check C -- CONTENTS counts"),
    ("docs/definitions/open-edges.md",        "check D -- banks tier"),
    ("docs/banks",                            "checks D/E -- the banks tier"),
    ("docs/definitions/FRONTIER.md",          "check I -- frontier staleness"),
    ("docs/examples",                         "checks J/N -- the worked-example corpus"),
    ("docs/examples/INDEX.md",                "checks J/N -- pipeline state"),
    ("docs/examples/_CHEATSHEET.md",          "check H -- cheatsheet ops"),
    (".planning",                             "the planning tier"),
    ("records/conformance-map.md",    "checks E/Q -- the build-state authority"),
    ("docs/elements/catalog.md",   "checks J/K -- element rows"),
    ("docs/elements/ledger.md",                   "check J -- ledger rows"),
    (".planning/RUNG1-CHECKLIST.md",          "check O -- rung-1 python accounting"),
    ("lib",                                   "checks G/L/R -- the source tree"),
    ("prog",                                  "checks G/L/R -- the source tree"),
]


def preflight() -> int:
    missing = [(p, why) for p, why in REQUIRED_INPUTS if not (ROOT / p).exists()]
    if not missing:
        return 0
    print(f"ledger-lint: cannot run -- {len(missing)} of {len(REQUIRED_INPUTS)} "
          f"required inputs are absent under {ROOT}\n")
    for p, why in missing:
        print(f"  MISSING  {p:<40s} {why}")
    print("Nothing was checked. This is exit 2, which is not a clean run and is")
    print("not a violation either -- see tools/ledger-lint/MIGRATION-NOTES.md.")
    return 2


def check_u() -> list[str]:
    """U. A quote attributed to a file appears in that file.

    A doc citing `FILE`: *"text"* is asserting that FILE says text. Five goal
    files quoted CLAUDE.md verbatim after it was emptied to a pointer table, and
    nothing saw it, because a quotation is evidence and nothing checked it.

    Matches the tree's citation form: a backticked path, a colon, then italic
    text in double quotes. Whitespace is normalised on both sides so a quote
    that wraps across lines still matches. A quote ending in an ellipsis is
    checked on its head only, since the elision is deliberate."""
    errs: list[str] = []
    pat = re.compile(r"`([A-Za-z0-9_./-]+\.(?:md|chiral|prog|port|sh|py))`[^\n]{0,40}?:\s*"
                     r"\*\"(.+?)\"\*", re.S)
    for md in doc_tier() + [ROOT / "README.md", ROOT / "MAP.md",
                            ROOT / "CONTENTS.md", ROOT / "PRINCIPLES.md"]:
        if not md.exists():
            continue
        text = md.read_text()
        for m in pat.finditer(text):
            target, quote = m.group(1), " ".join(m.group(2).split())
            tp = ROOT / target
            if not tp.exists():
                continue                      # check A owns a missing path
            head = quote.split("...")[0].split("\u2026")[0].strip().rstrip(".,;")
            if len(head) < 12:
                continue                      # too short to be evidence
            # A quote reproduces rendered prose. Emphasis markers and link
            # syntax sit inside quoted sentences in the source and never in the
            # quote, so both sides are flattened before comparing.
            def flat(t):
                t = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", t)
                return " ".join(re.sub(r"[*_`]", "", t).split())
            body, head = flat(tp.read_text()), flat(head)
            if head not in body:
                line = text.count("\n", 0, m.start()) + 1
                errs.append(f"[U] {md.name}:{line} quotes {target} as saying "
                            f"\u201c{head[:60]}\u2026\u201d and it does not")
    return errs


def check_v() -> list[str]:
    """V. The goal-arc-element chain holds.

    Three ways it breaks, all seen on 2026-09-01:
      an arc names a goal file that does not exist;
      a goal has no arc and no recorded reason for having none;
      an arc writes UNASSIGNED rows while holding no reserved element block,
      so its work cannot be scheduled.
    The third is not a defect in the arc. It is an author call, and the point of
    the row is that it stays visible until the author makes it."""
    goals_dir, arcs_dir = ROOT / "docs" / "goals", ROOT / "docs" / "arcs"
    if not goals_dir.is_dir() or not arcs_dir.is_dir():
        raise Vacuous("docs/goals or docs/arcs is absent")
    errs: list[str] = []
    goals = {p.stem for p in goals_dir.glob("*.md")
             if not is_form(p)} - {"README"}
    served: set[str] = set()
    for arc in sorted(arcs_dir.glob("*.md")):
        if arc.stem == "README" or is_form(arc):
            continue
        text = arc.read_text()
        m = re.search(r"^- goals?:\s*\[\[goals/([a-z0-9-]+)\]\]", text, re.M)
        if not m:
            if "UNWRITTEN" not in text:
                errs.append(f"[V] {arc.name} names no goal and does not say UNWRITTEN")
            continue
        g = m.group(1)
        served.add(g)
        if g not in goals:
            errs.append(f"[V] {arc.name} names goal '{g}' and docs/goals/{g}.md does not exist")
        # An arc with no band still names its work. decision-work-ids settles the
        # arc-local row id, so an anonymous UNASSIGNED row is the defect now,
        # rather than the missing band.
        blk = re.search(r"^- reserved element block:\s*(.+?)(?=\n[-#]|\n\n)", text, re.S | re.M)
        if blk and "none" in blk.group(1).lower() \
           and "decision-work-ids" not in blk.group(1) \
           and "BA-" not in blk.group(1):
            errs.append(f"[V] {arc.name} holds no reserved element block and names no "
                        f"arc-local row id scheme (decision-work-ids)")
        for m in re.finditer(r"^\|\s*UNASSIGNED\s*\|", text, re.M):
            line = text.count("\n", 0, m.start()) + 1
            errs.append(f"[V] {arc.name}:{line} has an anonymous UNASSIGNED row. "
                        f"decision-work-ids gives it an arc-local id")
    arc_idx = (arcs_dir / "README.md")
    if arc_idx.exists():
        itext = arc_idx.read_text()
        for arc in sorted(arcs_dir.glob("*-arc.md")):
            row = re.search(rf"^\|\s*\[\[arcs/{re.escape(arc.stem)}\]\].*$", itext, re.M)
            if not row:
                errs.append(f"[V] {arc.name} has no row in arcs/README.md")
                continue
            m = re.search(r"^- goals?:\s*\[\[goals/([a-z0-9-]+)\]\]", arc.read_text(), re.M)
            if m and f"goals/{m.group(1)}" not in row.group(0):
                errs.append(f"[V] arcs/README.md gives {arc.name} a different goal "
                            f"than the arc's own goal: field ({m.group(1)})")
    idx = (goals_dir / "README.md").read_text() if (goals_dir / "README.md").exists() else ""
    for g in sorted(goals - served):
        row = re.search(rf"\[\[goals/{re.escape(g)}\]\][^\n]*", idx)
        if row and re.search(r"none, by decision|none open|deferred", row.group(0)):
            continue
        errs.append(f"[V] goal '{g}' has no arc, and goals/README.md records no "
                    f"reason for it having none")
    return errs


# ── the five doc-rot classes: W, X, Y, Z, AA (added 2026-09-04) ──────────────
# records/doc-rot.md measured five rot classes across 310, 131, 21, 18 and 15
# files. Every one of them reached that count by regrowing after a sweep, because
# checks A to V name none of them. A sweep with no detector is undone by the next
# session. These five are the detectors.
#
# The corpus and the excuse rule below are shared by all five, so "what counts as
# a defect" is stated once. MAP.md sorts the doc tier by role and the role
# decides:
#
#   docs/definitions|modules|banks|goals|arcs, and the root docs
#       the present tense of the system. A dead reference is a defect.
#   docs/examples, docs/elements/specs
#       pipeline artifacts. The status in docs/examples/INDEX.md decides. A
#       pre-build status is a live blueprint an implementer will follow, so a
#       dead reference is a defect. `implemented` is a record of what was
#       examined and earns a dated banner, so it is left alone.
#   records/, docs/benchmarks/
#       a claim beside its measurement, dated. History by construction, never
#       scanned.
#   docs/decisions/
#       a settled fork carrying its reason. Historical context is legitimate
#       there and no mechanical rule separates it from a live citation, so the
#       tier is skipped and named as a gap.
#   .planning/, docs/elements/{catalog,ledger}.md, docs/examples/INDEX.md
#       skipped. The registries carry one dated build record per row and the
#       planning tier mixes present-tense protocol with dated passes. Neither
#       splits mechanically, and flagging a dated record pushes a later session
#       toward rewriting it, which is the failure doc-rot.md exists to prevent.
#
# These five under-report by construction. A check that cries wolf is a check
# nobody reads, and the counts here are a worklist rather than a census.
ROT_LIVE_DIRS = ("docs/definitions", "docs/modules", "docs/banks",
                 "docs/goals", "docs/arcs")
ROT_ROOT_DOCS = ("CONTENTS.md", "MAP.md", "PRINCIPLES.md", "README.md",
                 "docs/index.md")
ROT_PIPELINE_DIRS = ("docs/examples", "docs/elements/specs")
# The states BEFORE a build. Vocabulary: the Status section of
# docs/examples/INDEX.md, minted -> drafted -> reviewed -> specced -> audited ->
# implemented. `audited` reads "spec audit passed; implement-ready" there, which
# makes it the most load-bearing blueprint state in the corpus: 44 of the 116
# rows sit on it. `needs-rework` and `superseded` are excluded because both
# already say the artifact stopped being followed.
ROT_LIVE_PIPELINE = frozenset({"minted", "drafted", "reviewed", "specced", "audited"})


def _rot_pipeline_state() -> dict[int, str]:
    """E# -> pipeline status, read from docs/examples/INDEX.md.

    Same row shape check N reads: | Element | Title | Kind | Ref | Status |
    Artifact |, status in cells[4], first token only because the cell carries
    dated prose after the word."""
    st: dict[int, str] = {}
    idx = ROOT / "docs" / "examples" / "INDEX.md"
    if not idx.exists():
        return st
    for ln in idx.read_text().splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) >= 5 and re.match(r"^E\d+$", cells[0]):
            s = re.sub(r"[*`]", "", cells[4]).strip()
            if s:
                st[int(cells[0][1:])] = s.split()[0].lower()
    return st


def rot_corpus() -> list[tuple]:
    """(path, why) for every doc a dead reference is a defect in.

    `why` travels into each finding, so a reader sees which tier rule put the
    file under the check rather than having to look it up."""
    out: list[tuple] = []
    for d in ROT_LIVE_DIRS:
        for p in sorted((ROOT / d).rglob("*.md")):
            out.append((p, "the present tense of the system"))
    for r in ROT_ROOT_DOCS:
        p = ROOT / r
        if p.exists():
            out.append((p, "the present tense of the system"))
    skills = ROOT / ".claude" / "skills"
    if skills.is_dir():
        for p in sorted(skills.rglob("*.md")):
            out.append((p, "live protocol a session follows"))
    state = _rot_pipeline_state()
    for d in ROT_PIPELINE_DIRS:
        for p in sorted((ROOT / d).glob("*.md")):
            m = re.match(r"^E(\d+)-", p.name)
            if not m:
                continue
            s = state.get(int(m.group(1)))
            if s in ROT_LIVE_PIPELINE:
                out.append((p, f"a pipeline artifact at status {s}, "
                               f"a blueprint an implementer follows"))
    return out


# A reference is history when the text around it says so. Two markers do the
# separating, and both are read from the block the reader reads.
_ROT_RETIRED = re.compile(
    r"\b(cut|retire[ds]?|retires|evicted|deleted|absent|removed|no longer|"
    r"formerly|former|historical(ly)?|dead|gone|does not exist|do not exist|"
    r"did not exist|never existed|superseded|supersedes|migration|migrated|"
    r"repointed|renamed|moved|replaced|stale|pre-migration|old tree|doc-rot|"
    r"rewritten|does not resolve|not a subcommand|no such|nonexistent|phantom|"
    r"spent|dissolved|dropped|unlinked|no file)\b", re.I)
_ROT_DATED = re.compile(r"\b20\d\d-\d\d-\d\d\b")


def rot_scope(text: str, pos: int) -> str:
    """The block a reader reads around `pos`, whitespace-flattened.

    A table row is its own record, so a row scopes to itself; one dated row
    would otherwise excuse every other row in the table. Everything else scopes
    to the blank-line paragraph, which keeps a wrapped sentence whole. Scoping
    to the line alone was measured first and it split "no / longer exists"
    across a wrap in status-ledger.md, reporting a repaired sentence as rot."""
    la = text.rfind("\n", 0, pos) + 1
    lb = text.find("\n", pos)
    lb = len(text) if lb < 0 else lb
    if text[la:lb].lstrip().startswith("|"):
        return " ".join(text[la:lb].split())
    a = text.rfind("\n\n", 0, pos)
    a = 0 if a < 0 else a + 2
    b = text.find("\n\n", pos)
    b = len(text) if b < 0 else b
    return " ".join(text[a:b].split())


def rot_excused(text: str, pos: int) -> bool:
    """True when the block names the reference as history.

    Either it carries a retirement word, or it carries a date, which is the
    `status-ledger` pattern doc-rot.md names as the disposition for a figure:
    dated at what it measured. This is the loose half of the rule on purpose.
    It suppressed 456 of 937 raw cut-Python matches, and the suppressed set is
    where the repaired sentences live."""
    s = rot_scope(text, pos)
    return bool(_ROT_RETIRED.search(s) or _ROT_DATED.search(s))


def rot_scan(letter: str, pattern, what: str, fix: str,
             corpus=None) -> list[str]:
    """One finding per FILE, carrying the hit count and the first location.

    Per-hit reporting was measured at 481 lines for check W alone, which is a
    worklist nobody opens. The file is the unit of repair anyway."""
    errs: list[str] = []
    for p, why in (corpus if corpus is not None else rot_corpus()):
        text = p.read_text()
        hits = [(text.count("\n", 0, m.start()) + 1, m.group(0))
                for m in pattern.finditer(text) if not rot_excused(text, m.start())]
        if not hits:
            continue
        ln, tok = hits[0]
        errs.append(f"[{letter}] {p.relative_to(ROOT).as_posix()} carries "
                    f"{len(hits)} live {what} (first :{ln}, `{tok.strip()}`) -- "
                    f"the file is {why}. {fix}")
    return errs


_ROT_PY = re.compile(r"chirality/[A-Za-z_][\w-]*\.py|(?<![\w/])scaffold/"
                     r"|python3 -m chirality")


def check_w() -> list[str]:
    """W. No live reference to the cut Python oracle (added 2026-09-04).

    DR-1 in records/doc-rot.md, 310 files by grep and the largest of the five.
    `docs/decisions/decision-scope.md` decision 5 cuts external judgment,
    the Python oracle among it. `scaffold/` went with it in the 2026-08-31
    migration and no such directory exists.

    Three forms carry the class: a `chirality/<name>.py` path, a path under
    `scaffold/`, and the `python3 -m chirality` invocation. A live spec that
    says "Lands in: scaffold/lib/collections.chiral" sends an implementer at a
    path that has been gone for four days.

    Vacuous when scaffold/ is back, because the reference would resolve."""
    if (ROOT / "scaffold").exists():
        raise Vacuous("scaffold/ exists again, so a path under it resolves")
    return rot_scan("W", _ROT_PY, "reference(s) to the cut Python oracle",
                    "Repoint it at the live tree, or date the sentence.")


# The four module keys the 2026-08-31 migration moved. MAP.md holds the tree
# contract: the module key is the root-relative path, so `lib/ports.chiral` and
# `lib/ports/ports.chiral` are different keys and the first one names nothing.
_ROT_MOVED = {
    "lib/sys-tal.chiral": re.compile(r"lib/sys-tal\.chiral"),
    "lib/ports.chiral": re.compile(r"lib/ports\.chiral"),
    "lib/collections.chiral": re.compile(r"lib/collections\.chiral"),
    "typing/pretty": re.compile(r"(?<![\w/])typing/pretty\b"),
}


def check_x() -> list[str]:
    """X. No live citation of a pre-migration module key (added 2026-09-04).

    DR-2 in records/doc-rot.md, 131 files by grep. Each key is checked for
    existence first, so the check goes quiet on its own the day a file comes
    back rather than holding an assertion about the tree that only this
    docstring records. `typing/pretty` resolves as `lib/typing/pretty.chiral`;
    the live key is `lib/surface/pretty.chiral`, and `status-ledger.md:66`
    states it.

    Vacuous when all four resolve again."""
    live = {k: pat for k, pat in _ROT_MOVED.items()
            if not (ROOT / (k if k.endswith(".chiral") else f"lib/{k}.chiral")).exists()}
    if not live:
        raise Vacuous("all four pre-migration keys resolve again")
    joined = re.compile("|".join(p.pattern for p in live.values()))
    return rot_scan("X", joined, "pre-migration module key(s)",
                    "MAP.md: the module key is the root-relative path.")


def check_y() -> list[str]:
    """Y. `chirality verify` names a subcommand that exists (added 2026-09-04).

    DR-3 in records/doc-rot.md, 21 files by grep. The arms are read from
    bin/chirality's own dispatch rather than listed here, the way check O reads
    its patterns from RUNG1-CHECKLIST: a second copy in code drifts from the
    thing it enforces. `docs/definitions/working-discipline.md` states the
    structural rule this serves -- a subcommand dispatching to a floor this tree
    lacks is a gate that cannot fail.

    Vacuous when the dispatch grows a `verify` arm."""
    cli = ROOT / "bin" / "chirality"
    if not cli.exists():
        raise Vacuous("bin/chirality is absent, so no dispatch can be read")
    text = cli.read_text()
    if 'case "${1:-help}" in' not in text:
        raise Vacuous("bin/chirality has no toplevel dispatch to read arms from")
    tail = text.split('case "${1:-help}" in', 1)[1]
    arms = set(re.findall(r"^\s*([a-z][\w-]*)\)", tail, re.M))
    if "verify" in arms:
        raise Vacuous("bin/chirality dispatches `verify` now")
    return rot_scan("Y", re.compile(r"\bchirality verify\b"),
                    "use(s) of the subcommand `chirality verify`",
                    f"bin/chirality dispatches {', '.join(sorted(arms)[:6])}.")


_ROT_PLANNING = re.compile(
    r"\.gitignore:12"
    r"|\.planning/?[^\n]{0,60}?\b(untracked|not tracked|ignored|gitignored|"
    r"excluded|excludes)\b"
    r"|\b(untracked|ignored|excludes|excluded)\b[^\n]{0,60}?`?\.planning")


def check_z() -> list[str]:
    """Z. The planning tier is called tracked, because it is (added 2026-09-04).

    DR-4 in records/doc-rot.md, 18 files by grep and false in every instance.
    `git ls-files .planning` returns 145 and `.gitignore`'s own first line is a
    banner headed "the agent tier is tracked"; line 12 introduces `.claude/*`
    and says nothing about `.planning/`. Three skill files carry the claim as an
    instruction to a session, which makes it the one class that misdirects work
    rather than merely misdescribing the tree.

    The strictest of the five: no reading of the tree makes the claim true, so
    the only excuse is the shared one, a block that dates it or names it as
    history.

    Vacuous when git tracks nothing under .planning."""
    import subprocess
    try:
        out = subprocess.run(["git", "ls-files", "-z", ".planning"], cwd=ROOT,
                             capture_output=True, text=True, check=True).stdout
    except Exception as e:
        raise Vacuous(f"git ls-files failed ({e}), so tracking cannot be read")
    n = len([x for x in out.split("\0") if x])
    if n == 0:
        raise Vacuous("git tracks no file under .planning/, so the claim holds")
    return rot_scan("Z", _ROT_PLANNING, "instance(s) of the claim that .planning/ is untracked",
                    f"`git ls-files .planning` returns {n}.")


_ROT_ASSERTIONS = re.compile(r"\b(?:303|321) assertions\b")
_ROT_SIZE = re.compile(r"(?<![\w,])(\d{1,3}(?:,\d{3})+)\s*(?:B\b|bytes\b)")
_ROT_BIN = re.compile(r"\bchirality-bin\b(?!-)")


def check_ab() -> list[str]:
    """AB. LEDGER state vs the CATALOG's own prose assertion.

    Added 2026-09-04. Check N pairs the LEDGER against docs/examples/INDEX.md and
    never opens docs/elements/catalog.md, so the two documents that both assert a
    build state could disagree with nothing watching. They did: E185 sat `built`
    in the LEDGER and "Not built" in the CATALOG for a day after it landed
    (ccff8e8, promoted 1157028), and records/ledger-reconciliation.md is the pass
    that found it by hand.

    Deliberately narrow, for check N's stated reason: only flag pairs that cannot
    both be true. The CATALOG's state is prose, not a column, so this reads ONLY
    an unambiguous "not built" opening the description cell and fires ONLY against
    a LEDGER row reading `built`. A cell that hedges ("partially built", "not
    built as specified", "not built;") is left alone -- a check aimed at a guess
    passes by looking at nothing, which docs/decisions/decision-scope.md names.
    """
    errs: list[str] = []
    ledger = ROOT / "docs" / "elements" / "ledger.md"
    catalog = ROOT / "docs" / "elements" / "catalog.md"
    if not ledger.exists() or not catalog.exists():
        return errs
    lstate: dict[int, str] = {}
    for ln in ledger.read_text().splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) >= 3 and re.match(r"^\*{0,2}E\d+\*{0,2}$", cells[0]):
            lstate[int(re.sub(r"\D", "", cells[0]))] = \
                re.sub(r"[*`]", "", cells[2]).split()[0].lower()
    if not lstate:
        return errs
    for ln in catalog.read_text().splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 3 or not re.match(r"^\*{0,2}E\d+\*{0,2}$", cells[0]):
            continue
        num = int(re.sub(r"\D", "", cells[0]))
        desc = re.sub(r"[*`]", "", cells[2]).strip()
        # Only the unambiguous opening. "Not built." / "Not built," / "Not built "
        # count; "Not built as specified", "Partially built", "not built;" do not.
        if not re.match(r"^not built\s*[.,]?(\s|$)", desc, re.I):
            continue
        if re.match(r"^not built\s+(as|except|apart|in|for|beyond|outside)\b",
                    desc, re.I):
            continue
        if lstate.get(num) == "built":
            errs.append(f"[AB] E{num} ledger=built but catalog opens \"Not built\" "
                        f"-- both documents assert a build state and they disagree")
    return errs


def check_ac() -> list[str]:
    """AC. LEDGER `built` against a PRE-IMPLEMENTATION pipeline state.

    Added 2026-09-05. Check N already pairs the LEDGER against
    docs/examples/INDEX.md, but it only fires on `built` against `design` and on
    INDEX=`implemented` against a non-`built` ledger. The reverse leg was open:
    an element the LEDGER calls `built` could sit at `audited` in the pipeline
    index with nothing watching. E187 did. It landed and was promoted at
    8d4009d, its catalog, ledger and enforcement-arc rows flipped at 98a9450,
    and its INDEX row was skipped there because the author held the file. The
    row stayed `audited (pre-run 2026-09-05)` and was found by hand, which is
    the same way AB's class was found the day before.

    Why the pair cannot both be true. The Status section of
    docs/examples/INDEX.md defines its own vocabulary as one chain measuring one
    thing, how ready this element is to be BUILT: `drafted` -> `reviewed` ->
    `specced` -> `audited` -> `implemented`, with `audited` spelled out as
    "spec audit passed; implement-ready". An element the LEDGER calls `built`
    is not awaiting implementation. That is two documents contradicting each
    other about one fact rather than the pointer-versus-snapshot lag check N's
    docstring licenses, because the lag check N tolerates is a difference of
    DISTANCE and these two states are on opposite sides of the event.

    The pre-implementation set is those four chain rungs and nothing else, taken
    from that section rather than guessed. Excluded on purpose:
      * `implemented` -- the agreeing value, and check N already owns its
        converse leg.
      * `needs-rework` -- it marks the DRAFT invalidated by a later decision and
        says nothing about readiness, so a built element can carry it honestly.
      * `superseded` -- check N pairs it EXACTLY on both sides and owns it. It
        can never reach here anyway, since it is outside the set.
      * everything off-vocabulary the corpus actually carries (`part`, `impl`,
        `built`, `minted`, `implemented-core`). A hedge is a cell somebody wrote
        deliberately, and AB's rule holds: a check aimed at a guess passes by
        looking at nothing.

    A ledger row carrying the literal marker `UNRESOLVED` is honored the way
    check N honors it: reported on every run, not failing the gate.
    """
    errs: list[str] = []
    ledger = ROOT / "docs" / "elements" / "ledger.md"
    index = ROOT / "docs" / "examples" / "INDEX.md"
    if not ledger.exists() or not index.exists():
        return errs
    PRE = ("drafted", "reviewed", "specced", "audited")
    ltext = ledger.read_text()
    lstate: dict[int, str] = {}
    flagged: set[int] = set()
    for ln in ltext.splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) >= 3 and re.match(r"^\*{0,2}E\d+\*{0,2}$", cells[0]):
            num = int(re.sub(r"\D", "", cells[0]))
            lstate[num] = re.sub(r"[*`]", "", cells[2]).split()[0].lower()
            if "UNRESOLVED" in ln:
                flagged.add(num)
    # A disagreement ENUMERATED in the limit lens is recorded rather than
    # unnoticed, which is the escape AE and AG already give. E20, E26 and E101
    # were measured in records/ledger-reconciliation.md and sat as prose that
    # closed nothing.
    for about in _lens_about("limits.md") | _lens_about("problems.md"):
        am = re.fullmatch(r"E(\d+)", about.strip())
        if am:
            flagged.add(int(am.group(1)))
    pipe: dict[int, str] = {}
    for ln in index.read_text().splitlines():
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        # INDEX header: | Element | Title | Kind | Ref | Status | Artifact |
        if len(cells) >= 5 and re.match(r"^E\d+$", cells[0]):
            st = re.sub(r"[*`]", "", cells[4]).strip()
            if st:
                pipe[int(cells[0][1:])] = st.split()[0].lower()
    if not lstate or not pipe:
        return errs
    for n, ls in sorted(lstate.items()):
        ps = pipe.get(n)
        if ps is None or ls != "built" or ps not in PRE:
            continue
        if n in flagged:
            print(f"  [AC] E{n} KNOWN disagreement (ledger=built, INDEX={ps}) "
                  f"-- flagged in the row, not failing")
            continue
        errs.append(f"[AC] E{n} ledger=built but INDEX={ps} "
                    f"(the pipeline index says this element is still awaiting "
                    f"implementation)")
    return errs


def check_ad() -> list[str]:
    """The four lenses against records/lenses/README.md. decision-four-lenses
    split problems, gaps, limits and unspoken territory into files with a closed
    state set apiece and an author marker on every row. tools/lens/lens.py owns
    that schema; this check runs it, so a malformed lens row fails the same gate
    every other doc claim fails."""
    lens = ROOT / "tools" / "lens" / "lens.py"
    if not lens.is_file():
        raise Vacuous("tools/lens/lens.py is absent")
    import subprocess
    r = subprocess.run([sys.executable, str(lens), "check"],
                       capture_output=True, text=True, cwd=str(ROOT))
    return [ln for ln in r.stdout.splitlines() if ln.startswith("[LN]")]


# ── the system's own goals, as checks ─────────────────────────────────────────
# Each of AE..AJ enforces an invariant this tree STATES and nothing read. The
# jump in findings when they land is not new breakage: those claims were always
# wrong and sat where the checks did not reach. docs/elements/README.md records
# the same reading for the 2026-09-01 jump from 3 failing checks to 7.

_ARC_ROW = re.compile(r"^\|\s*`?([a-z0-9-]+/[A-Z]+\d+)`?\s*\|(.*)$", re.M)
_ROSTER_STATES = ("open", "designed", "minted", "specced", "building", "built",
                  "closed", "direct")


def _arc_files():
    d = ROOT / "docs" / "arcs"
    return [f for f in sorted(d.glob("*-arc.md")) if not f.name.startswith("_")]


def _goal_files():
    d = ROOT / "docs" / "goals"
    return [f for f in sorted(d.glob("*.md"))
            if not f.name.startswith("_") and f.name != "README.md"]


# 29 element rows are BOLD in their number cell (`| **E42** | **async** | ...`),
# 23 in the ledger and 6 in the catalog. A regex anchored on `| E42 |` misses
# every one and reports it as an unminted element. Measured 2026-09-05 after
# check AE's first run named E42 as missing from a ledger that holds it.
_EROW = re.compile(r"^\|\s*\*{0,2}E(\d+)\*{0,2}\s*\|", re.M)


def _reserved_slots() -> set[int]:
    """Numbers the catalog declares as reserved SLOTS rather than elements.
    E114-E119 are the six CRY slots: ledger rows with no catalog row, by
    design, so an asymmetry check has to know they are not elements."""
    out: set[int] = set()
    txt = (ROOT / "docs/elements/catalog.md").read_text()
    for m in re.finditer(r"reserved[^.\n]{0,40}?slots?\s*\(E(\d+)[-\u2013]E?(\d+)\)",
                         txt, re.I):
        out |= set(range(int(m.group(1)), int(m.group(2)) + 1))
    return out


def _minted():
    """(catalog set, ledger set) of E numbers, as ints, reserved slots removed."""
    slots = _reserved_slots()
    cat = {int(n) for n in _EROW.findall((ROOT / "docs/elements/catalog.md").read_text())}
    led = {int(n) for n in _EROW.findall((ROOT / "docs/elements/ledger.md").read_text())}
    return cat - slots, led - slots


def _ledger_state():
    st = {}
    for ln in (ROOT / "docs/elements/ledger.md").read_text().splitlines():
        m = re.match(r"\|\s*\*{0,2}E(\d+)\*{0,2}\s*\|\s*\*{0,2}([^|]*?)\*{0,2}\s*\|"
                     r"\s*\*{0,2}([a-z]+)\*{0,2}\s*\|", ln)
        if m and int(m.group(1)) not in st:
            st[int(m.group(1))] = m.group(3)
    return st


def _lens_about(lens_file):
    f = ROOT / "records" / "lenses" / lens_file
    if not f.is_file():
        return set()
    return {m.group(1).strip() for m in
            re.finditer(r"^- about:\s*(.+)$", f.read_text(), re.M)}


def check_ae() -> list[str]:
    """Element and arc, both directions.

    docs/goals/README.md: "An element belongs to exactly one arc." That was
    unsatisfiable until decision-four-lenses gave unspoken territory a home, so
    the invariant now reads: an unbuilt element is named by an arc, OR it is
    enumerated in the unspoken lens as territory with no ruling. Silence is the
    only thing this refuses."""
    errs = []
    cat, led = _minted()
    for n in sorted(cat - led):
        errs.append(f"[AE] E{n} is in docs/elements/catalog.md and not in "
                    f"docs/elements/ledger.md. A mint writes both rows")
    for n in sorted(led - cat):
        errs.append(f"[AE] E{n} is in docs/elements/ledger.md and not in "
                    f"docs/elements/catalog.md. A mint writes both rows")

    named = set()
    for f in _arc_files():
        named |= {int(x) for x in re.findall(r"\bE(\d+)\b", f.read_text())}
    spoken = {a for a in _lens_about("unspoken.md")}
    st = _ledger_state()
    for n in sorted(cat):
        if st.get(n) not in ("design", "flight"):
            continue                       # built and superseded rows are history
        if n in named:
            continue
        if f"E{n}" in spoken:
            continue
        errs.append(f"[AE] E{n} is unbuilt (ledger `{st.get(n)}`), no arc names it, "
                    f"and no row in records/lenses/unspoken.md is about it. "
                    f"Unscheduled work has to be visible somewhere")
    return errs


def check_af() -> list[str]:
    """Every goal states what done means, in numbered checkable conditions, and
    every condition names its arc or declares itself unopened.

    docs/goals/README.md requires a goal to "state what `done` means", and
    .claude/skills/goal-open enforces the numbered form. A condition nothing
    schedules and nothing marks unopened is a claim with no plan and no
    admission."""
    errs = []
    for f in _goal_files():
        t = f.read_text()
        m = re.search(r"^## What done means\s*$", t, re.M)
        if not m:
            errs.append(f"[AF] {f.name} has no `## What done means`. Nothing "
                        f"states what done is for this goal")
            continue
        rest = t[m.end():]
        n = re.search(r"^## ", rest, re.M)
        sec = rest[:n.start()] if n else rest
        conds = list(re.finditer(r"^(\d+)\.\s+(.+?)(?=^\d+\.\s|\Z)", sec, re.M | re.S))
        if not conds:
            errs.append(f"[AF] {f.name} `## What done means` carries no NUMBERED "
                        f"conditions. A condition with no number cannot be cited "
                        f"by an arc")
            continue
        for c in conds:
            body = c.group(2)
            if re.search(r"[Uu]nopened", body):
                continue
            if re.search(r"\[\[arcs/[a-z0-9-]+\]\]", body):
                continue
            errs.append(f"[AF] {f.name} done-condition {c.group(1)} names no arc "
                        f"and does not say unopened")
    return errs


def check_ag() -> list[str]:
    """An arc's roster against arcs/README.md's schema, and its coverage.

    Coverage is the forcing function that keeps an arc from being thin: every
    requirement served by a row, every row serving a requirement. It is only
    decidable on a roster carrying the `req` and `state` columns, so an arc
    predating that schema is reported once rather than per row."""
    errs = []
    cat, _ = _minted()
    for f in _arc_files():
        t = f.read_text()
        rows = _ARC_ROW.findall(t)
        reqs = set(re.findall(r"^(\d+)\.\s+\*\*", arc_req_section(t), re.M))
        arcname0 = f.stem[:-4] if f.stem.endswith("-arc") else f.stem
        if not rows:
            if "REQUIREMENT" not in t:
                continue
            # An arc can legitimately carry no roster: tuning-arc is blocked
            # whole by an author call, and its opening proposal measured that
            # any row written now prejudges the call. Zero rows is honest when
            # every requirement is ENUMERATED instead, which is the same escape
            # a covered requirement gets below.
            allg = _lens_about("gaps.md") | _lens_about("unspoken.md")
            reqs0 = set(re.findall(r"^(\d+)\.\s+\*\*", arc_req_section(t), re.M))
            missing = [r for r in sorted(reqs0, key=int)
                       if f"{arcname0}/req{r}" not in allg]
            if missing:
                errs.append(f"[AG] {f.name} states REQUIREMENTS and carries no "
                            f"roster table, and requirement(s) "
                            f"{', '.join(missing)} have no gap row either. Its "
                            f"work cannot be counted or cited")
            continue
        cols = len([c for c in rows[0][1].split("|") if c.strip()]) + 1
        if cols < 8:
            errs.append(f"[AG] {f.name} roster has {cols} columns and the schema "
                        f"in docs/arcs/README.md has 8 (row what group kind origin "
                        f"req state element). {len(rows)} row(s) cannot be "
                        f"coverage-checked")
            continue
        served = set()
        for rid, rest in rows:
            cells = [c.strip() for c in rest.strip().strip("|").split("|")]
            state, elem = cells[-2], cells[-1].strip("`")
            if state not in _ROSTER_STATES:
                errs.append(f"[AG] {f.name} row {rid} state '{state}' is outside "
                            f"({' '.join(_ROSTER_STATES)})")
            # A row may cover more than one element: bridge/C4 is E40 and E56,
            # the mirror of unit-lane N8 and N9 both minting as E196. Forcing one
            # number per row would make a roster lie about what it covers.
            # Four lanes mint into this pipeline: E is the core catalog, and
            # U, S and N are the user, scriba and native lanes pack.py's source
            # adapters read from their own documents. scriba-arc holds the S
            # namespace, so demanding an E number there rejects every row it has.
            # A trailing letter is legal: pack.py's id regex allows S20b.
            if elem != "unminted":
                ids = re.findall(r"\b([EUSN])(\d+)([a-z]?)", elem)
                if not ids:
                    errs.append(f"[AG] {f.name} row {rid} element '{elem}' is not "
                                f"`unminted` or a lane id (E/U/S/N)")
                for lane, num, _sfx in ids:
                    if lane == "E" and int(num) not in cat:
                        errs.append(f"[AG] {f.name} row {rid} claims E{num} and no "
                                    f"catalog row mints it")
            rq = {x for x in re.findall(r"\d+", cells[-3])}
            if not rq:
                errs.append(f"[AG] {f.name} row {rid} serves no numbered "
                            f"requirement. It is out of scope, or a requirement "
                            f"is missing")
            served |= rq
        # A requirement no row serves is closed one of two ways: a row takes it,
        # or the hole is ENUMERATED as a gap. That is the same escape AE gives
        # an unscheduled element through the unspoken lens, and it is what stops
        # the guide handing back a finding whose answer is an author call it
        # cannot take. The gap row carries the author marker.
        arcname = f.stem[:-4] if f.stem.endswith("-arc") else f.stem
        gaps = _lens_about("gaps.md") | _lens_about("unspoken.md")
        # A requirement can be DELEGATED: presentability requirement 6 is served
        # by binary-split/B5, and one arc taking another's requirement is a real
        # relation rather than a hole. A row serves a foreign requirement by
        # writing `<arc>/req<N>` in its own req cell.
        for other in _arc_files():
            for _, orest in _ARC_ROW.findall(other.read_text()):
                ocells = [c.strip() for c in orest.strip().strip("|").split("|")]
                if len(ocells) >= 7:
                    served |= set(re.findall(rf"{re.escape(arcname)}/req(\d+)",
                                             ocells[-3]))
        for r in sorted(reqs - served, key=int):
            if f"{arcname}/req{r}" in gaps:
                continue
            errs.append(f"[AG] {f.name} requirement {r} is served by no roster "
                        f"row and no gap row is about `{arcname}/req{r}`. It is "
                        f"a done-condition with no plan and no admission")
    return errs


def arc_req_section(t: str) -> str:
    m = re.search(r"^## REQUIREMENTS\s*$", t, re.M)
    if not m:
        return ""
    rest = t[m.end():]
    n = re.search(r"^## ", rest, re.M)
    return rest[:n.start()] if n else rest


def check_ah() -> list[str]:
    """A roster row's state against the artifact that state claims exists.

    decision-design-before-mint puts one artifact behind each stage. A row that
    says `designed` with no design is a state nothing backs."""
    errs = []
    parts = ROOT / "docs" / "arcs" / "parts"
    specs = ROOT / "docs" / "elements" / "specs"
    checked = 0
    for f in _arc_files():
        arc = f.stem[:-4] if f.stem.endswith("-arc") else f.stem
        for rid, rest in _ARC_ROW.findall(f.read_text()):
            cells = [c.strip() for c in rest.strip().strip("|").split("|")]
            if len(cells) < 7:
                continue
            checked += 1
            state, elem = cells[-2], cells[-1].strip("`")
            local = rid.split("/")[-1]
            # Work built BEFORE decision-design-before-mint (2026-09-05) went
            # through worked-example, and docs/arcs/parts/ did not exist. Its
            # artifact is the retired corpus entry, so demanding a design for it
            # is demanding a document the pipeline of the day never wrote.
            # Four lanes mint into this pipeline, not one: E, U, S and N, per
            # pack.py's source adapters. An exemption that only knew E called
            # native-protocol/N1 undesigned while docs/examples/N01-*.md sat on
            # disk.
            # Four lanes mint into this pipeline, not one: E, U, S and N, per
            # pack.py's source adapters. And a row can carry old-pipeline work
            # while still reading `unminted`, because the retired corpus is
            # keyed by the artifact tag rather than by a catalog row: the arc
            # native-protocol/N1 has docs/examples/N01-crypto-kernels.md and no
            # element. Both the element cell and the local id are checked.
            old_pipeline = False
            for tag in (elem, local):
                em = re.fullmatch(r"([EUSN])(\d+)", tag)
                if em and list((ROOT / "docs" / "examples").glob(
                        f"{em.group(1)}{int(em.group(2)):02d}-*.md")):
                    old_pipeline = True
                    break
            # A row carrying no element was never in the element pipeline.
            # working-discipline: everything that is not the compiler has no
            # ceremony. transport/T1 to T4 are gate phases, built and green,
            # and demanding a pre-mint design for them demands a document the
            # work never owed.
            # `direct` is terminal and carries no pipeline artifact by
            # definition: working-discipline runs the pipeline for a row iff
            # building it requires choosing between shapes the codebase does
            # not already settle, and a forced shape is its own blueprint.
            # E105, file write, is a syscall crossing built that way.
            if elem != "unminted" \
               and state in ("designed", "minted", "specced", "building", "built") \
               and not (parts / f"{arc}-{local}.md").is_file() \
               and not old_pipeline:
                errs.append(f"[AH] {f.name} row {rid} is `{state}` and "
                            f"docs/arcs/parts/{arc}-{local}.md does not exist")
            if state in ("specced", "building", "built") and elem.startswith("E") \
               and not list(specs.glob(f"{elem}-*-SPEC.md")):
                errs.append(f"[AH] {f.name} row {rid} is `{state}` and no "
                            f"{elem}-*-SPEC.md exists")
    if not checked:
        raise Vacuous("no arc carries a roster with the state column yet")
    return errs


def check_ai() -> list[str]:
    """A row whose evidence moved after it was last checked.

    records/lenses/README.md and records/README.md both state the rule: "A row
    whose `checked:` date predates the last change to the files it cites is
    unverified." Nothing read it until now. The `revisit` skill works one off."""
    import subprocess
    # One `git log` per (row, path) made this check take minutes. The dates are
    # per FILE, so they are looked up once and cached: a lint nobody can afford
    # to run is worse than no lint.
    cache: dict[str, str] = {}

    def last_change(path: str) -> str:
        if path not in cache:
            r = subprocess.run(["git", "-C", str(ROOT), "log", "-1",
                                "--format=%cs", "--", path],
                               capture_output=True, text=True)
            cache[path] = r.stdout.strip()
        return cache[path]

    errs = []
    roots = [ROOT / "records"]
    for d in roots:
        for f in sorted(d.rglob("*.md")):
            if f.name == "README.md":
                continue
            for blk in re.split(r"(?m)^(?=### )", f.read_text()):
                if not blk.startswith("### "):
                    continue
                rid = blk.split("\n", 1)[0][4:].split()[0]
                st = re.search(r"^- state:\s*(\S+)", blk, re.M)
                if st and st.group(1) in ("RETIRED", "FIXED", "covered", "closed"):
                    continue
                ck = re.search(r"^- checked:\s*(\d{4}-\d{2}-\d{2})", blk, re.M)
                ev = re.search(r"^- evidence:\s*(.+)$", blk, re.M)
                if not (ck and ev):
                    continue
                for path in re.findall(
                        r"([A-Za-z0-9_./-]+\.(?:chiral|prog|py|sh|md))", ev.group(1)):
                    if not (ROOT / path).exists():
                        continue
                    last = last_change(path)
                    if last and last > ck.group(1):
                        rel = f.relative_to(ROOT)
                        errs.append(f"[AI] {rel} {rid} checked {ck.group(1)} and "
                                    f"{path} changed {last}. The row is unverified")
                        break
    return errs


def check_aj() -> list[str]:
    """The deferral rule, mechanised.

    working-discipline: never defer to an `E#` that is not already minted. A
    citation of an unminted number is a phantom dependency. Zero-padded artifact
    names (E01-sexp-reader.md) and the endpoints of a reserved band (E184-E189)
    are not citations of an element and are excluded."""
    errs = []
    cat, led = _minted()
    # A reserved slot is DECLARED, so naming one is not a phantom dependency.
    # The CRY slots E114-E119 are ledger rows the catalog names in prose.
    minted = cat | led | _reserved_slots()
    # ONE pass. Reading every doc twice, once for band endpoints and once for
    # citations, doubled this check's share of the run for no gain.
    srcs = [f for f in sorted(list((ROOT / "docs").rglob("*.md"))
                              + list((ROOT / "records").rglob("*.md")))
            if not f.name.startswith("_")]
    texts = {f: f.read_text(errors="ignore") for f in srcs}
    band_ends = set()
    for text in texts.values():
        for m in re.finditer(r"E(\d+)\s*[-\u2013]\s*E?(\d+)", text):
            band_ends |= {int(m.group(1)), int(m.group(2))}
    for src in srcs:
        rel = src.relative_to(ROOT)
        text = texts[src]
        seen = set()
        for m in re.finditer(r"(?<![\w/-])E(\d{1,3})\b", text):
            raw = m.group(1)
            if raw.startswith("0"):
                continue                    # E01-… is an artifact filename, not a citation
            n = int(raw)
            if n in minted or n in band_ends or n in seen:
                continue
            seen.add(n)
            line = text.count("\n", 0, m.start()) + 1
            errs.append(f"[AJ] {rel}:{line} cites E{n} and no catalog or ledger "
                        f"row mints it. The deferral rule forbids naming an "
                        f"element that does not exist")
    return errs


def check_aa() -> list[str]:
    """AA. A superseded figure carries the date it measured (added 2026-09-04).

    DR-5 in records/doc-rot.md, 15 files by grep. Two limbs.

    The binary size is read from bin/chirality-bin on disk, so the check has no
    frozen number to rot: a comma-formatted byte figure on a line naming
    `chirality-bin` and disagreeing with the live size is undated history. The
    `(?!-)` matters -- `chirality-bin-c` is a different binary and its 1,077,624
    and 2,171,314 are correct where they stand.

    The suite figures 303 and 321 are literals, because the live assertion count
    comes only from running the suite and this tool runs nothing. Both are
    superseded and doc-rot.md names them.

    ⚑ This finds nothing in the live tiers today, and that is the measurement
    rather than a hole: every live-tier instance already carries its date, which
    is the disposition doc-rot.md gives the class. The residue sits in records/
    and the element registries, which the tier rule never scans. The demonstration
    that it fires is in the same record.

    Vacuous when the compiler binary is absent."""
    binp = ROOT / "bin" / "chirality-bin"
    if not binp.exists():
        raise Vacuous("bin/chirality-bin is absent, so no live size can be read")
    live = binp.stat().st_size
    errs: list[str] = []
    for p, why in rot_corpus():
        text = p.read_text()
        lines = text.splitlines()
        hits: list[tuple] = []
        for m in _ROT_ASSERTIONS.finditer(text):
            if not rot_excused(text, m.start()):
                hits.append((text.count("\n", 0, m.start()) + 1, m.group(0)))
        for m in _ROT_SIZE.finditer(text):
            ln = text.count("\n", 0, m.start()) + 1
            if not _ROT_BIN.search(lines[ln - 1]):
                continue
            if int(m.group(1).replace(",", "")) == live:
                continue
            if rot_excused(text, m.start()):
                continue
            hits.append((ln, m.group(0)))
        if not hits:
            continue
        ln, tok = sorted(hits)[0]
        errs.append(f"[AA] {p.relative_to(ROOT).as_posix()} carries "
                    f"{len(hits)} superseded figure(s) (first :{ln}, "
                    f"`{tok.strip()}`) -- the file is {why}. bin/chirality-bin "
                    f"is {live:,} B today; date the figure at what it measured.")
    return errs


CHECKS = (("A evidence paths", check_a),
                     ("B principle numbers", check_b),
                     ("C CONTENTS counts", check_c),
                     ("D banks tier", check_d),
                     ("E bank claims vs map", check_e),
                     ("F link graph", check_f),
                     ("G line citations", check_g),
                     ("H cheatsheet ops", check_h),
                     ("I frontier staleness", check_i),
                     ("J ledger vs catalog", check_j),
                     ("K cat-prefix consistency", check_k),
                     ("L ownership ratchet", check_l),
                     ("M duplicate-module ratchet", check_m),
                     ("N ledger vs pipeline state", check_n),
                     ("O rung-1 python accounting", check_o),
                     ("P suite compiler override", check_p),
                     ("Q map live tally", check_q),
                     ("R citation lands on its symbol", check_r),
                     ("S rank-2 anchor is committed", check_s),
                     ("T artifacts have registry rows", check_t),
                     ("U quotes match their source", check_u),
                     ("V goal-arc-element chain", check_v),
                     ("W cut-python references", check_w),
                     ("X pre-migration module keys", check_x),
                     ("Y chirality verify", check_y),
                     ("Z planning tier tracked", check_z),
                     ("AA superseded figures", check_aa),
                     ("AB ledger vs catalog build state", check_ab),
                     ("AC ledger built vs pre-impl pipeline state", check_ac),
                     ("AD the four lenses", check_ad),
                     ("AE element and arc, both directions", check_ae),
                     ("AF goal done-conditions", check_af),
                     ("AG arc roster schema and coverage", check_ag),
                     ("AH roster state vs its artifact", check_ah),
                     ("AI rows whose evidence moved", check_ai),
          ("AJ the deferral rule", check_aj))


# ── the guide ─────────────────────────────────────────────────────────────────
# A dump of 111 findings is a list nobody works. --next scans, groups the
# findings by the single file each one is fixed in, ranks the groups, and hands
# back ONE task with the protocol that governs it and the command that verifies
# it. Work that task, run --next again, repeat. That is the loop the author
# asked for: no bulk, single task, reselect.

# tier 1 blocks other checks from running at all
# tier 2 the spine, top down: goal, arc, roster, element
# tier 3 citation and evidence truth
# tier 4 counts and generated artifacts
GUIDE = {
    "AG": (1, "docs/arcs/README.md, `What an arc file carries` and `The roster`",
           "The arc carries the 8-column roster (row what group kind origin req "
           "state element) and the coverage check: every requirement served by a "
           "row, every row serving a requirement. Until an arc has the `req` and "
           "`state` columns, checks AG-coverage and AH cannot see it at all.",
           "AG,AH"),
    "AF": (2, "docs/goals/README.md and .claude/skills/goal-open",
           "`## What done means` carries NUMBERED conditions, each checkable, each "
           "naming its arc with [[arcs/<name>]] or saying it is unopened. An arc "
           "cites a numbered condition, so an unnumbered goal cannot be served.",
           "AF"),
    "AE": (2, "docs/goals/README.md and docs/elements/README.md",
           "A mint writes both the catalog row and the ledger row. An unbuilt "
           "element is named by an arc, or enumerated in records/lenses/unspoken.md.",
           "AE"),
    "AC": (2, "docs/definitions/status-ledger.md",
           "The ledger's build state and the pipeline state agree, or the "
           "disagreement is recorded as a row that says which side is wrong.",
           "AC"),
    "N":  (2, "docs/definitions/status-ledger.md",
           "Same as AC, and this one is already flagged in its row rather than "
           "failing. Closing it means moving one side or retiring the row.",
           "N"),
    "AI": (3, "records/lenses/README.md, `Re-verifying`",
           "A row whose `checked:` predates the last change to the files it cites "
           "is unverified. Re-read the evidence, then either refresh `checked:` "
           "with what you measured, or move the row's state. The `revisit` skill "
           "is the run: one artifact, one trigger, a closed verdict set.",
           "AI"),
    "AJ": (3, "docs/definitions/working-discipline.md, the deferral rule",
           "Every `E#` a doc names is already minted. Name a roster row instead.",
           "AJ"),
    "I":  (4, "tools/frontier/frontier.py",
           "FRONTIER.md is generated. A source moved, so re-condense it: "
           "`python3 tools/frontier/frontier.py condense`.",
           "I"),
    "C":  (4, "CONTENTS.md",
           "The counts CONTENTS states match the tree.", "C"),
}
_DEFAULT = (3, "the check's own docstring in tools/ledger-lint/ledger-lint.py",
            "See the finding text: it names both sides of the disagreement.", "")

_SUBJ = re.compile(r"([A-Za-z0-9_./-]+\.(?:md|py|sh|chiral|prog|tsv))")


def _finding_parts(e: str):
    """(check, subject file, text). The subject is the file the fix lands in,
    which is the first path the finding names."""
    m = re.match(r"\[([A-Z]{1,2})\]\s*(.*)", e.strip())
    if not m:
        return "?", "?", e
    body = m.group(2)
    sm = _SUBJ.search(body)
    return m.group(1), (sm.group(1) if sm else "?"), body


def guide_next(all_errs, vacuous, scanned_tier=None):
    groups: dict[tuple, list] = {}
    for e in all_errs:
        chk, subj, body = _finding_parts(e)
        groups.setdefault((chk, subj), []).append(body)
    if not groups:
        print("\nledger-lint --next: nothing to select. Every check is clean or "
              "named VACUOUS.")
        for name, why in vacuous:
            print(f"  VACUOUS {name}: {why}")
        return 0

    def rank(k):
        chk, subj = k
        tier = GUIDE.get(chk, _DEFAULT)[0]
        return (tier, -len(groups[k]), chk, subj)

    order = sorted(groups, key=rank)
    chk, subj = order[0]
    hits = groups[(chk, subj)]
    tier, authority, shape, verify = GUIDE.get(chk, _DEFAULT)

    print("\n" + "=" * 74)
    print(f"NEXT TASK  —  check {chk}  —  {subj}")
    print("=" * 74)
    print(f"\n{len(hits)} finding(s) in this file, from one check. Fix THIS FILE "
          f"only, then re-run --next.\n")
    for h in hits[:30]:
        print(f"  - {h}")
    if len(hits) > 30:
        print(f"  ... and {len(hits) - 30} more in the same file")
    print(f"\nWHY THIS ONE\n  tier {tier}"
          + ("  (it blocks other checks from running at all)" if tier == 1 else
             "  (spine order: goal, then arc, then roster, then element)" if tier == 2 else
             "  (citation and evidence truth)" if tier == 3 else
             "  (counts and generated artifacts)")
          + f"\n  {len(hits)} finding(s) close together in one file.")
    print(f"\nTHE PROTOCOL\n  {authority}")
    print(f"\nWHAT IN-PROTOCOL LOOKS LIKE")
    for line in _wrap(shape, 70):
        print(f"  {line}")
    print(f"\nVERIFY\n  python3 tools/ledger-lint/ledger-lint.py --only "
          f"{verify or chk}")
    scope = (f"in tier {scanned_tier}" if scanned_tier else "across every check")
    print(f"\nREMAINING {scope}\n  {len(all_errs)} finding(s) in {len(groups)} "
          f"file-and-check group(s).")
    if scanned_tier:
        print(f"  Lower tiers were not scanned: nothing below tier {scanned_tier} "
              f"can outrank this.")
    by_check: dict[str, int] = {}
    for (c, _), v in groups.items():
        by_check[c] = by_check.get(c, 0) + len(v)
    print("  " + ", ".join(f"{c} {n}" for c, n in sorted(by_check.items())))
    print()
    return 1


def _wrap(text, width):
    out, cur = [], ""
    for w in text.split():
        if len(cur) + len(w) + 1 > width:
            out.append(cur)
            cur = w
        else:
            cur = f"{cur} {w}".strip()
    if cur:
        out.append(cur)
    return out


def _run(checks, quiet=False):
    errs: list[str] = []
    vac: list[tuple] = []
    for name, fn in checks:
        try:
            e = fn()
        except Vacuous as v:
            vac.append((name, str(v)))
            continue
        errs += e
        if not quiet:
            print(f"  [{'FAIL' if e else 'ok'}] {name} ({len(e)} issue(s))")
    return errs, vac


def main() -> int:
    only = None
    nxt = "--next" in sys.argv
    for i, a in enumerate(sys.argv):
        if a == "--only" and i + 1 < len(sys.argv):
            only = {x.strip().upper() for x in sys.argv[i + 1].split(",")}
    rc = preflight()
    if rc:
        return rc

    # --next scans in TIER order and stops at the first tier that yields work.
    # A full pass is ~45s, and the loop the author asked for runs it after every
    # single fix. Scanning tier 1 alone answers "what is next" in a fraction of
    # that, and the tier below cannot outrank what tier 1 already found.
    order = CHECKS
    if nxt:
        for tier in (1, 2, 3, 4):
            sel = [c for c in CHECKS
                   if GUIDE.get(c[0].split()[0], _DEFAULT)[0] == tier]
            if not sel:
                continue
            errs, vac = _run(sel, quiet=True)
            if errs:
                return guide_next(errs, vac, tier)
        print("\nledger-lint --next: nothing to select. Every check that can "
              "name a next task is clean.")
        return 0

    all_errs: list[str] = []
    vacuous: list[tuple] = []
    for name, fn in order:
        code = name.split()[0]
        if only and code not in only:
            continue
        try:
            errs = fn()
        except Vacuous as v:
            vacuous.append((name, str(v)))
            if not nxt:
                print(f"  [VACUOUS] {name} -- subject gone, checked nothing")
            continue
        all_errs += errs
        status = "FAIL" if errs else "ok"
        if not nxt:
            print(f"  [{status}] {name} ({len(errs)} issue(s))")
    if nxt:
        return guide_next(all_errs, vacuous)
    if vacuous:
        print("\nchecked nothing, and named rather than counted as clean:\n")
        for name, why in vacuous:
            print(f"  {name}\n    {why}")
    if all_errs:
        print("\nledger-lint: violations found\n")
        for e in all_errs:
            print(f"  {e}")
        return 1
    print("\nledger-lint: clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
