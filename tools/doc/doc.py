#!/usr/bin/env python3
"""doc — doc-keyed audit bundles + doc scaffolding, the doc-tier sibling
of pack (which is element-keyed).

The docs tier encodes its claims in machine-readable shapes: bank shard headers
carry **STATE (E#s)**, line evidence is cited as `file.py:NN` or `file` … `:NN`,
[[links]]/related: form a graph, and build-state authority is
records/conformance-map.md + examples/INDEX.md. This tool exploits that:
`audit` prints ONE bundle putting every claim next to its live authority — the
extended ledger-lint findings (pre-sorted worklist), the map/pipeline rows for
every E# the doc names, the ACTUAL code lines behind every citation, and the
head of every linked note. Correcting is then mechanical: read the claim, read
the authority beside it, fix toward the authority.

Usage:
    tools/doc/doc.py audit banks/port            # audit bundle for docs/banks/port.md
    tools/doc/doc.py audit memory-model          # any docs/ note by node name
    tools/doc/doc.py audit examples/_CHEATSHEET.md   # any repo .md by path
    tools/doc/doc.py new-bank taint E57 E58      # scaffold a bank, evidence pre-seeded
"""
import glob, os, re, subprocess, sys, datetime

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CONFMAP = os.path.join(ROOT, "records/conformance-map.md")
EXINDEX = os.path.join(ROOT, "docs/examples/INDEX.md")

CHARTER = """## 0. Doc-audit charter
Write surface: THIS doc only. Authority gradient — every fix runs toward what
sits above the doc: scaffold code + tests > CONFORMANCE-MAP + examples/INDEX
(build / pipeline state) > decision docs (design intent) > bank > thin note.
When two authorities ABOVE the doc disagree, FLAG it verbatim — never pick.
Checks, in order:
1. **Build-state truth** — every shard/residue/status claim vs §3; nothing
   rounded to done or to undone; gradients preserved.
2. **Line-evidence truth** — every §4 slice must still say what the doc claims
   beside it; drifted code means fixing the citation or the claim, not both.
3. **Settled-decision conformance** — the doc's characterization of any
   decision vs the linked note heads in §5 (grep the note if a head is silent).
4. **Graph integrity** — resolve every §2 lint finding for this doc.
5. **Refraction honesty** (banks: cross-cuts point at real shards; residue
   stays honest · thin notes: the one-idea claim still matches its bank).
Protocol: FIX in place · FLAG author-tier issues verbatim · finish by running
`python3 tools/ledger-lint/ledger-lint.py` — done = lint clean + FLAG list reported."""


def die(m):
    print(m, file=sys.stderr)
    sys.exit(1)


# The doc tier sorts by ROLE as of 2026-08-31 (MAP.md), so a note that used
# to sit at docs/<name>.md now sits under one of these. Order is deliberate:
# the literal path first, then the roles most notes live in. This is a repoint
# to KNOWN destinations, not a guess -- .planning/MIGRATION-MAP.tsv records
# where every one of them went.
DOC_ROLES = ("docs", "docs/definitions", "docs/decisions", "docs/modules",
             "docs/banks", "docs/implementation", "docs/benchmarks",
             "docs/examples", "docs/elements", "records",
             "docs/goals", "docs/arcs")

def resolve_doc(name):
    cands = [name, f"{name}.md", f"docs/{name}"]
    cands += [f"{d}/{name}.md" for d in DOC_ROLES]
    for c in cands:
        p = os.path.join(ROOT, c)
        if os.path.isfile(p):
            return os.path.relpath(p, ROOT)
    die(f"no doc found for {name!r} (tried the literal path and "
        + ", ".join(DOC_ROLES) + ")")


def find_src(tok):
    # The source tree is lib/ + prog/ here; the old scaffold/ bases are kept so a
    # citation written against the old tree still resolves by basename. A miss
    # returns None and the caller prints the citation unresolved, which is the
    # honest outcome: the audit charter's check 2 then decides whether the
    # citation or the claim is the thing that drifted.
    for base in ("", "lib", "prog", "scaffold", "scaffold/chirality", "scaffold/lib"):
        p = os.path.join(ROOT, base, tok)
        if os.path.isfile(p):
            return p
    return None


def enums_in(text):
    ns = set()
    for m in re.finditer(r"\bE(\d+)(?:[–-]E?(\d+))?\b", text):
        a, b = int(m.group(1)), int(m.group(2) or m.group(1))
        ns.update(range(a, min(b, a + 40) + 1))
    return sorted(ns)


def _row_enums(row):
    cells = [c.strip() for c in row.strip().strip("|").split("|")]
    return set(enums_in(cells[6])) if len(cells) >= 7 else set()


def map_rows_for(nums):
    """CONFORMANCE-MAP rows for these elements: keyed by the E# cell (ranges
    expanded) OR naming the element anywhere in the row — authority is often
    filed under a sibling number with the element only in the notes."""
    want = set(nums)
    rxs = [re.compile(rf"\bE0*{n}\b") for n in nums]
    return [ln for ln in open(CONFMAP).read().splitlines()
            if ln.startswith("|")
            and (_row_enums(ln) & want or any(rx.search(ln) for rx in rxs))]


def index_rows_for(nums):
    want = {f"E{n}" for n in nums}
    return [ln for ln in open(EXINDEX).read().splitlines()
            if ln.startswith("|")
            and ln.split("|")[1].strip() in want]


def evidence_slices(text):
    """For every line-numbered code citation (attached `file.py:NN` or the
    banks' detached `file` … `:NN–MM` convention), print the live lines."""
    out, ctx, cache = [], None, {}

    def lines_of(p):
        if p not in cache:
            cache[p] = open(p).read().splitlines()
        return cache[p]

    for ln in text.splitlines():
        for span in re.findall(r"`([^`]+)`", ln):
            span = span.strip()
            pm = re.match(r"([A-Za-z0-9_/.-]+\.(?:py|chirality))"
                          r"(?::(\d+)(?:[–-](\d+))?)?$", span)
            lo = hi = None
            if pm:
                p = find_src(pm.group(1))
                if p is None:
                    continue
                ctx = p
                if pm.group(2):
                    lo, hi = int(pm.group(2)), int(pm.group(3) or pm.group(2))
            else:
                lm = re.match(r":(\d+)(?:[–-](\d+))?$", span)
                if lm and ctx is not None:
                    p = ctx
                    lo, hi = int(lm.group(1)), int(lm.group(2) or lm.group(1))
            if lo is None:
                continue
            src = lines_of(p)
            a, b = max(1, lo - 2), min(len(src), min(hi, lo + 12) + 2)
            body = "\n".join(f"{i:>5}  {src[i-1]}" for i in range(a, b + 1))
            rel = os.path.relpath(p, ROOT)
            out.append(f"#### cited `{span}` → {rel}:{a}-{b} (live)\n```\n{body}\n```")
    return out


def _split_blocks(text):
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


def link_heads(text, self_rel):
    """Every [[link]] (code spans excluded) -> resolved path + its head blocks."""
    scan = re.sub(r"`[^`\n]*`", lambda m: " " * len(m.group(0)), text)
    out, seen = [], set()
    for name in re.findall(r"\[\[([A-Za-z0-9/_.-]+)\]\]", scan):
        if name in seen:
            continue
        seen.add(name)
        m = re.match(r"E(\d+)(?:-|$)", name)
        cands = [os.path.join(ROOT, "docs", "examples", os.path.basename(g)) for g in
                 glob.glob(os.path.join(ROOT, "docs/examples", f"E{int(m.group(1)):02d}-*.md"))] \
            if m else [os.path.join(ROOT, d, f"{name}.md")
                       for d in DOC_ROLES + (".planning", "")]
        p = next((c for c in cands if os.path.isfile(c)), None)
        rel = os.path.relpath(p, ROOT) if p else None
        if p is None or rel == self_rel:
            continue
        head = "\n\n".join(_split_blocks(open(p).read())[:2])
        out.append(f"#### [[{name}]] → {rel}\n{head}")
    return out


def audit(target):
    rel = resolve_doc(target)
    text = open(os.path.join(ROOT, rel)).read()

    out = [f"# DOC-AUDIT BUNDLE — {rel}",
           "Read THIS ONLY; grep only to chase a specific claim the bundle "
           "leaves unsettled. Read-only bundle — nothing was written.",
           CHARTER,
           f"## 1. DOC UNDER AUDIT — {rel}\n\n{text.strip()}"]

    r = subprocess.run([sys.executable, os.path.join(ROOT, "tools/ledger-lint/ledger-lint.py")],
                       capture_output=True, text=True)
    base = os.path.basename(rel)
    mine = [ln.strip() for ln in r.stdout.splitlines()
            if base in ln and ln.strip().startswith("[")]
    out.append("## 2. Lint findings for this doc (pre-sorted worklist)\n"
               + ("\n".join(mine) if mine else "(lint-clean for this doc)"))

    nums = enums_in(text)
    rows = map_rows_for(nums)
    irows = index_rows_for(nums)
    out.append(f"## 3. Authority — the {len(nums)} E#s this doc names\n"
               "### CONFORMANCE-MAP verdicts (E-ranges expanded)\n"
               + ("\n".join(rows) or "(no rows)")
               + "\n\n### Pipeline state (examples/INDEX.md)\n"
               + ("\n".join(irows) or "(no rows)"))

    ev = evidence_slices(text)
    out.append(f"## 4. Live code behind every line citation ({len(ev)})\n"
               + ("\n\n".join(ev) or "(no line-numbered citations)"))

    lh = link_heads(text, rel)
    out.append(f"## 5. Linked-note heads ({len(lh)})\n"
               + ("\n\n".join(lh) or "(no links)"))

    print("\n\n".join(out))


BANK_TEMPLATE = """---
node: banks/{name}
layer: bank
tier: depth
related: [{related}]
status: draft
updated: {today}
---

# Bank: {name}

> **What a bank is.** The depth tier under the thin relational notes in
> `docs/`. A bank holds the full *refraction* of ONE concept: what it is, the
> shards it decomposes into with their principled homes and honest build-state,
> the cross-cuts where one shard *is* a shard of another concept, and the
> native monoliths it gets mistaken for.
>
> **Why this bank exists.** <the monolith this refracts + the recurring
> misfire>. Build-state is AUTHORITATIVE from
> `records/conformance-map.md` and [[status-ledger]]; where a facet is
> genuinely unbuilt it is named as such, never rounded to done.

---

## 1. The concept in chirality

**The one-sentence truth.** <…>

**What {name} IS.** <…> · **What it IS NOT.** <…>

---

## 2. The refraction — the shards, their homes, their build-state

### Shard 1 — <name> · **<CONFORMS|EXTEND|REFACTOR|BUILD|DECISION> (E#)**
- **What.** <…>
- **Home.** <…>
- **Build-state.** <…, grounded in the seeded map rows below>

<!-- seed evidence (delete when refracted into shards):
{seed}
-->

---

## 3. Cross-cuts — where a shard of "{name}" IS a shard of another concept

**C1 · <title> (Shard ? ↔ [[banks/?]]).** <…>

---

## 4. Native → chirality translation (the misfire → the correction)

- **"You need a <monolith>."** → Correction: <…>

---

## 5. What's genuinely new / unbuilt — the honest residue

1. **<gap> — <CLASS>, E#, <gate>.** <gradient preserved>

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[<note>]] — <why>
"""


def new_bank(name, enums):
    dest = os.path.join(ROOT, "docs/banks", f"{name}.md")
    if os.path.exists(dest):
        die(f"docs/banks/{name}.md already exists")
    seed = "\n".join(map_rows_for(enums)) if enums else "(none passed — " \
        "rerun with E#s or paste rows from CONFORMANCE-MAP)"
    open(dest, "w").write(BANK_TEMPLATE.format(
        name=name, today=datetime.date.today().isoformat(), seed=seed,
        related="glossary, status-ledger, open-edges"))
    print(f"[new-bank] wrote docs/banks/{name}.md "
          f"({len(map_rows_for(enums)) if enums else 0} map rows seeded into §2)")
    print(f"[new-bank] NOW add to docs/banks/INDEX.md:\n"
          f"| [[banks/{name}]] | <concept> | <the monolith it refracts> |")
    print("[new-bank] ledger-lint check D FAILS until the INDEX row exists — "
          "that is the forcing function, not a bug.")


def main():
    if len(sys.argv) < 3:
        die("usage: tools/doc/doc.py audit <doc> | new-bank <name> [E# …]")
    cmd, arg = sys.argv[1], sys.argv[2]
    if cmd == "audit":
        audit(arg)
    elif cmd == "new-bank":
        new_bank(arg, [int(e.lstrip("Ee")) for e in sys.argv[3:]])
    else:
        die(f"unknown command '{cmd}' (audit | new-bank)")


if __name__ == "__main__":
    main()
