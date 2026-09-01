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
def doc_tier(pattern: str = "*.md"):
    """Every markdown doc under docs/, at any depth, sorted and deduped."""
    return sorted(set((ROOT / "docs").rglob(pattern)))

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
        claimed = WORDS.get(m.group(1).lower())
        if claimed != n_decisions:
            errs.append(f"[C] CONTENTS claims {m.group(1)} decision notes; "
                        f"tree has {n_decisions}")

    edges = (ROOT / "docs" / "definitions" / "open-edges.md").read_text()
    seq_block = edges.split("Sequencing questions", 1)
    if len(seq_block) == 2:
        n_seq = len(re.findall(r"^\s*\d+\.\s", seq_block[1], re.M)) or \
                len(re.findall(r"^-\s", seq_block[1], re.M))
        m = re.search(r"(\w+)\s+sequencing questions", mapmd)
        if m and WORDS.get(m.group(1).lower()) != n_seq:
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
    cmap = ROOT / ".planning" / "audit" / "CONFORMANCE-MAP.md"
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
    catalog = (ROOT / ".planning" / "SELF-IMPLEMENT-CATALOG.md").read_text() \
        if (ROOT / ".planning" / "SELF-IMPLEMENT-CATALOG.md").exists() else ""
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
        return ((ROOT / ".planning" / f"{name}.md").exists()
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


def _find_src(tok: str):
    for base in (ROOT, SCAFFOLD, SCAFFOLD / "chirality", SCAFFOLD / "lib"):
        p = base / tok
        if p.is_file():
            return p
    return None


def check_g() -> list[str]:
    """Line-numbered code citations in docs still fit the file. Handles the
    banks' detached convention: `ports.chiral` … (`:19`) — a bare `:NN` span
    resolves against the last file span seen. Unresolvable files are skipped
    (naming an unbuilt file in residue is legitimate)."""
    errs: list[str] = []
    nlines: dict = {}

    def count(p) -> int:
        if p not in nlines:
            nlines[p] = len(p.read_text().splitlines())
        return nlines[p]

    for f in doc_tier():
        ctx = None
        for i, ln in enumerate(f.read_text().splitlines(), 1):
            for span in re.findall(r"`([^`]+)`", ln):
                span = span.strip()
                pm = re.match(r"([A-Za-z0-9_/.-]+\.(?:py|chirality))"
                              r"(?::(\d+)(?:[–-](\d+))?)?$", span)
                if pm:
                    p = _find_src(pm.group(1))
                    if p is None:
                        continue
                    ctx = p
                    if pm.group(2) and int(pm.group(3) or pm.group(2)) > count(p):
                        errs.append(f"[G] {f.parent.name}/{f.name}:{i} cites "
                                    f"`{span}` but file has {count(p)} lines")
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
    cite = re.compile(r"([A-Za-z0-9_/.-]+\.(?:py|chirality))(?::(\d+))?$")
    bare = re.compile(r":(\d+)$")

    for f in doc_tier():
        ctx = None
        for i, ln in enumerate(f.read_text().splitlines(), 1):
            spans = [(m.start(), m.end(), m.group(1).strip())
                     for m in re.finditer(r"`([^`]+)`", ln)]
            for k, (pos, _end, s) in enumerate(spans):
                cm, bm = cite.match(s), bare.match(s)
                if cm:
                    p = _find_src(cm.group(1))
                    if p is None:
                        continue
                    ctx = p
                    if not cm.group(2):
                        continue
                    want = int(cm.group(2))
                elif bm and ctx is not None:
                    p, want = ctx, int(bm.group(1))
                else:
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
    """J. Ledger ⇄ catalog consistency. .planning/LEDGER.md is the category map
    over the E# set; a catalog element that is not tagged there rots out of the
    map (the exact failure this lint fights, one level up). Every catalog E# must
    appear in the ledger; every non-reserved ledger E# must exist in the catalog;
    every `## CODE · …` category header must use a legend code. Skipped if the
    ledger is absent (optional tier, like D/E/I)."""
    errs: list[str] = []
    ledger = ROOT / ".planning" / "LEDGER.md"
    catalog = ROOT / ".planning" / "SELF-IMPLEMENT-CATALOG.md"
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
    ledger = ROOT / ".planning" / "LEDGER.md"
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
    cmap = ROOT / ".planning" / "audit" / "CONFORMANCE-MAP.md"
    if not cmap.exists():
        return ["[Q] .planning/audit/CONFORMANCE-MAP.md missing — the live tally has no subject"]
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
    ledger = ROOT / ".planning" / "LEDGER.md"
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
    and .planning/specs/E<NN>-*-SPEC.md sat on disk, and the whole lint stayed
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
    catalog = ROOT / ".planning" / "SELF-IMPLEMENT-CATALOG.md"
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
        raise Vacuous("no docs/examples/E*.md or .planning/specs/E*-SPEC.md on "
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
                        f".planning/SELF-IMPLEMENT-CATALOG.md -- an element the "
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
    (".planning/audit/CONFORMANCE-MAP.md",    "checks E/Q -- the build-state authority"),
    (".planning/SELF-IMPLEMENT-CATALOG.md",   "checks J/K -- element rows"),
    (".planning/LEDGER.md",                   "check J -- ledger rows"),
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


def main() -> int:
    rc = preflight()
    if rc:
        return rc
    all_errs: list[str] = []
    vacuous: list[tuple] = []
    for name, fn in (("A evidence paths", check_a),
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
                     ("T artifacts have registry rows", check_t)):
        try:
            errs = fn()
        except Vacuous as v:
            vacuous.append((name, str(v)))
            print(f"  [VACUOUS] {name} -- subject gone, checked nothing")
            continue
        all_errs += errs
        status = "FAIL" if errs else "ok"
        print(f"  [{status}] {name} ({len(errs)} issue(s))")
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
