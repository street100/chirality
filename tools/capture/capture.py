#!/usr/bin/env python3
"""capture — turn a marked exploration note into scaffolded canonical
artifacts, the growth-tier sibling of doc (which audits) and pack
(which drives the element pipeline).

The problem it ends: crystallising an exploration (a `VISION-*` note) into canon
— a `decision-*.md`, an edge insertion, a bank, a catalog row, an edit into an
existing node — is hand-authoring every time, and settled design scatters into
the wrong home. capture does the deterministic half: for each section/claim it
ROUTES the claim to its home(s) and SCAFFOLDS the target, pre-seeded with the
source claim (verbatim) + the authority it must be checked against (the authority
gradient: code > CONFORMANCE-MAP/INDEX > decision > bank > note). It scaffolds; a
human/LLM fills — exactly as `doc new-bank` scaffolds and `worked-example`
fills.

Hard rules (mirroring the toolchain philosophy):
  * NO LLM anywhere — deterministic parse + a routing seam + template scaffolds.
  * NEEDS-AUTHOR is SURFACED VERBATIM, never resolved. Author-calls in the note
    are reported as-is and never routed to a resolving scaffold.
  * Gradients held — a claim's own state marker (REAL / NEW / DESIGNED / ABSENT
    / SPLIT / unbuilt) is carried into the scaffold, never flattened to done.
  * Every emitted scaffold keeps `ledger-lint` clean.

Write surface: staging dir `.planning/capture/<note-slug>/` (one placeable
skeleton per routed home + REPORT.md + AUTHOR-CALLS.md). The ONE exception is a
claim routed to a NEW bank: capture invokes `tools/doc/doc.py new-bank` (its
native in-place write to docs/banks/) and appends the banks/INDEX row so lint
stays green — the spec's explicit "reuse the new-bank scaffolder". Everything
else stages, because in-place edits touch authority-tier files (MAP counts, edge
numbering, catalog ids) a human must reconcile against the gradient; capture
pre-seeds the exact edit + the authority pointer but never silently mutates canon.

Usage:
    tools/capture/capture.py .planning/VISION-deployment-custody-2026-07-24.md
    tools/capture/capture.py <note.md> --report-only    # Stage 1: parse+route+report, no writes
    tools/capture/capture.py <note.md> --out <dir>       # override staging dir

    ------------------------------------------------------------------ SEAM ----
    Routing is Tool 1b `route`, built in parallel as `tools/frontier/frontier.py`.
    capture invokes `python3 tools/frontier/frontier.py route "<query>"` as a
    subprocess (the CLI seam) and parses candidate lines of the contract form
        <score>\\t<kind>:<id>\\t<why>
    with kind in {node, decision, bank, edge, catalog, new}. If that tool is
    absent / errors / returns nothing parseable, capture falls back to a small
    internal token-overlap matcher (see route_fallback) so it builds standalone.
    ----------------------------------------------------------------------------
"""
import glob, os, re, subprocess, sys, math, datetime

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FRONTIER = os.path.join(ROOT, "tools/frontier/frontier.py")   # SEAM: built in parallel
OPEN_EDGES = os.path.join(ROOT, "docs/open-edges.md")
CATALOG = os.path.join(ROOT, "docs/elements/catalog.md")
BANKS_INDEX = os.path.join(ROOT, "docs/banks/INDEX.md")
CONFMAP = "records/conformance-map.md"
DOCKET = ".planning/DECISION-DOCKET.md"

KINDS = ("node", "decision", "bank", "edge", "catalog", "new")


def die(m):
    print(m, file=sys.stderr)
    sys.exit(1)


# ---------------------------------------------------------------- tokenizing --
STOP = set("""a an the this that these those and or but of to in on at by for with
from into as is are was were be been being it its his her their our your my we you
they he she them us not no nor so if then than too very can will would should could
what which who whom where when why how all any both each few more most other some
such only own same over under again further about against between through during
before after above below up down out off only just also now here there one two
three four five per via vs chirality need needs lacks lack real new absent designed
split does doing done thing things form shape state note only already still open
""".split())


def toks(text):
    return {t for t in re.split(r"[^A-Za-z0-9]+", text.lower())
            if len(t) >= 3 and t not in STOP}


# --------------------------------------------------------------- note parsing -
STATE_MARKERS = ("ENFORCED", "DESIGNED", "ABSENT", "REAL", "SPLIT", "NEW",
                 "unbuilt", "planning-only", "docs-only", "not built")


def find_state(text):
    """The honest gradient marker on a claim, if any — carried through, never
    flattened. First marker wins (they are listed strong->weak)."""
    for m in STATE_MARKERS:
        if re.search(rf"\b{re.escape(m)}\b", text):
            return m
    return ""


def split_sections(text):
    """Level-2 (`## `) sections: [(title, body), ...]. Intro before the first
    `##` is dropped (context, not a claim)."""
    out, title, buf = [], None, []
    for ln in text.splitlines():
        m = re.match(r"^##\s+(.*)$", ln)
        if m:
            if title is not None:
                out.append((title, "\n".join(buf).strip()))
            title, buf = m.group(1).strip(), []
        elif title is not None:
            buf.append(ln)
    if title is not None:
        out.append((title, "\n".join(buf).strip()))
    return out


def table_rows(body):
    """Data rows of any markdown table in the body, as lists of cell strings.
    Header + `|---|` separator rows dropped."""
    rows = []
    for ln in body.splitlines():
        s = ln.strip()
        if not s.startswith("|"):
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if all(re.fullmatch(r":?-{2,}:?", c or "-") for c in cells):
            continue  # separator
        if any(re.search(r"[A-Za-z0-9]", c) for c in cells):
            rows.append(cells)
    return rows


def is_author_section(title):
    t = title.lower()
    return "author call" in t or "do not silently resolve" in t \
        or "do not silently" in t or "author-call" in t


def is_captured_section(title):
    t = title.lower()
    return "captured elsewhere" in t or "settled part" in t


def is_meta_section(title):
    """Pure orientation prose — not a routable design claim."""
    return "why this note exists" in title.lower()


def bullets(body):
    """Top-level `- ` / `* ` bullet lines, kept verbatim minus the bullet marker
    (multi-line bullets joined)."""
    out, cur = [], None
    for ln in body.splitlines():
        if re.match(r"^\s*[-*]\s+", ln):
            if cur is not None:
                out.append(cur.strip())
            cur = re.sub(r"^\s*[-*]\s+", "", ln)
        elif cur is not None and ln.strip() and not ln.startswith("#"):
            cur += " " + ln.strip()
        elif cur is not None:
            out.append(cur.strip())
            cur = None
    if cur is not None:
        out.append(cur.strip())
    return out


class Claim:
    def __init__(self, subject, text, origin, state=""):
        self.subject = subject          # short routing subject
        self.text = text                # full verbatim claim
        self.origin = origin            # section title it came from
        self.state = state or find_state(text)
        self.route = None               # (kind, id, score, why)

    def query(self):
        return f"{self.subject} {self.text}"


def parse_note(text):
    """-> (routable_claims, author_calls, captured_notes). Header prose is not a
    claim; the two special sections are diverted (author-calls surfaced verbatim,
    captured-elsewhere reported verify-only)."""
    routable, author, captured = [], [], []
    for title, body in split_sections(text):
        if is_author_section(title):
            for b in bullets(body):
                # a struck-through, marked-DONE bullet is a resolved call, not live
                if b.startswith("~~") or re.search(r"\bDONE\b", b):
                    captured.append(("author-call (already resolved)", b))
                else:
                    author.append((title, b))
            continue
        if is_captured_section(title):
            for b in bullets(body):
                captured.append((title, b))
            continue
        if is_meta_section(title):
            continue
        rows = table_rows(body)
        if rows:
            # each data row is its own claim (they carry per-piece state markers)
            for cells in rows:
                subj = cells[0].strip("* ")
                if subj.lower() in ("piece", "centralised instinct"):
                    continue  # header row that slipped the separator test
                routable.append(Claim(subj, " · ".join(cells), title))
        else:
            # the section as a whole is one claim
            first = next((l for l in body.splitlines() if l.strip()), title)
            routable.append(Claim(title, f"{title} — {first.strip()}", title))
    return routable, author, captured


# ------------------------------------------------------------- routing (SEAM) -
# capture calls Tool 1b over the CLI seam; route_fallback is the small internal
# matcher for standalone build/test. Both return a ranked list of
# (score, kind, id, why); [] means genuinely-new.

def route_via_seam(query):
    """Invoke `tools/frontier/frontier.py route <query>`; parse the contract lines.
    Returns None if the tool is absent or produced nothing parseable (=> fall
    back), else a ranked candidate list."""
    if not os.path.exists(FRONTIER):
        return None
    try:
        r = subprocess.run([sys.executable, FRONTIER, "route", query, "--porcelain"],
                           capture_output=True, text=True, timeout=30, cwd=ROOT)
    except Exception:
        return None
    cands = []
    for ln in r.stdout.splitlines():
        m = re.match(r"\s*([0-9.]+)\t([a-z]+):(\S+)\t(.*)$", ln)
        if m and m.group(2) in KINDS:
            kind, nid = m.group(2), m.group(3)
            # defend the docs/banks/<nid>.md convention: a bank id may arrive
            # namespaced ("banks/port") from the router; the kind already carries
            # the namespace, so strip it or every downstream existence check
            # (home_desc/placement/authority_for/new_bank_inplace) looks for
            # docs/banks/banks/<nid>.md and false-reports an existing bank as NEW.
            if kind == "bank" and nid.startswith("banks/"):
                nid = nid[len("banks/"):]
            cands.append((float(m.group(1)), kind, nid, m.group(4).strip()))
    if not cands and r.returncode != 0:
        return None
    return cands or None


# ---- internal fallback index (deterministic token overlap over the graph) ----
_INDEX = None


def _build_index():
    """A minimal routable index: docs nodes, decisions, banks, open edges,
    catalog elements. Enough to route standalone; the real router (Tool 1b)
    supersedes it over the CLI seam."""
    entries = []   # (kind, id, token_set, descriptor, exists)

    for p in sorted(glob.glob(os.path.join(ROOT, "docs/*.md"))):
        name = os.path.basename(p)[:-3]
        if name in ("index",):
            continue
        head = ""
        for ln in open(p).read().splitlines():
            if ln.startswith("# "):
                head = ln[2:]
                break
        kind = "decision" if name.startswith("decision-") else "node"
        nid = name[len("decision-"):] if kind == "decision" else name
        desc = head or name.replace("-", " ")
        entries.append((kind, nid, toks(name.replace("-", " ") + " " + head),
                        desc, True))

    if os.path.exists(BANKS_INDEX):
        for ln in open(BANKS_INDEX).read().splitlines():
            m = re.match(r"\|\s*\[\[banks/([^\]]+)\]\]\s*\|\s*([^|]*)\|\s*([^|]*)\|",
                         ln)
            if m:
                nm, concept, monolith = m.group(1), m.group(2), m.group(3)
                entries.append(("bank", nm,
                                toks(nm + " " + concept + " " + monolith),
                                concept.strip(), True))

    if os.path.exists(OPEN_EDGES):
        for m in re.finditer(r"^(\d+)\.\s+(.*(?:\n(?![\d]+\.\s|##|\s*$).*)*)",
                             open(OPEN_EDGES).read(), re.M):
            num, blurb = m.group(1), " ".join(m.group(2).split())
            entries.append(("edge", num, toks(blurb),
                            blurb[:90], True))

    if os.path.exists(CATALOG):
        for m in re.finditer(r"^\|\s*E(\d+)\s*\|\s*([^|]+)\|",
                             open(CATALOG).read(), re.M):
            entries.append(("catalog", f"E{m.group(1)}", toks(m.group(2)),
                            m.group(2).strip()[:90], True))

    # deterministic idf over the corpus
    N = len(entries)
    df = {}
    for _, _, ts, _, _ in entries:
        for t in ts:
            df[t] = df.get(t, 0) + 1
    idf = {t: math.log(1 + N / c) for t, c in df.items()}
    return entries, idf


MIN_SCORE = 1.5   # below this the best home is too weak -> "genuinely new"


def route_fallback(query):
    global _INDEX
    if _INDEX is None:
        _INDEX = _build_index()
    entries, idf = _INDEX
    q = toks(query)
    scored = []
    for kind, nid, ts, desc, _ in entries:
        inter = q & ts
        if not inter:
            continue
        # sum of idf over the overlap, normalized by sqrt(target size) so a long
        # blurb (an edge) does not out-score a tight, on-topic node by sheer bulk
        score = sum(idf.get(t, 0) for t in inter) / math.sqrt(len(ts))
        # a direct id/name hit is a strong signal
        if toks(nid.replace("-", " ")) & q:
            score += 1.0
        scored.append((round(score, 3), kind, nid, desc))
    scored.sort(key=lambda x: (-x[0], x[1], x[2]))
    top = [c for c in scored if c[0] >= MIN_SCORE][:3]
    return top   # [] => genuinely new


def route(query):
    """The seam: prefer Tool 1b, fall back to the internal matcher. Returns
    (ranked_candidates, source_tag)."""
    cands = route_via_seam(query)
    if cands is not None:
        return cands, "frontier"
    return route_fallback(query), "fallback"


# ------------------------------------------------------- authority per home ---
def authority_for(kind, nid):
    """The gradient authority a filled claim must be checked against, keyed by
    home kind (code > CONFORMANCE-MAP/INDEX > decision > bank > note)."""
    if kind == "node":
        return [f"docs/{nid}.md (the node under edit)",
                f"{CONFMAP} — any E# the node names",
                "code + tests in scaffold/ behind any build-state claim"]
    if kind == "decision":
        p = f"docs/decision-{nid}.md"
        exists = os.path.exists(os.path.join(ROOT, p))
        return [(f"{p} (existing settled decision)" if exists
                 else f"{p} (NEW — must be minted; also bump CONTENTS.md decision count)"),
                f"{DOCKET} — the docket item this decision resolves",
                f"{CONFMAP} — gated E#s"]
    if kind == "bank":
        return [f"docs/banks/{nid}.md",
                f"{CONFMAP} — build-state authority for every shard",
                "docs/banks/INDEX.md — the bank must be listed (lint check D)"]
    if kind == "edge":
        return [f"docs/open-edges.md — edge {nid} (its status banner)",
                f"{DOCKET} — the docket item, if this edge has one",
                f"{CONFMAP} — E#s the edge gates"]
    if kind == "catalog":
        return [f"{CATALOG} — the element row/section",
                f"{CONFMAP} — its conformance verdict"]
    return ["no home above threshold — see the mint proposal"]


def home_desc(kind, nid):
    if kind == "node":
        return f"existing docs node docs/{nid}.md"
    if kind == "decision":
        e = os.path.exists(os.path.join(ROOT, f"docs/decision-{nid}.md"))
        return f"decision-{nid}.md ({'existing' if e else 'NEW skeleton'})"
    if kind == "bank":
        e = os.path.exists(os.path.join(ROOT, f"docs/banks/{nid}.md"))
        return f"bank {nid} ({'existing' if e else 'NEW — via new-bank'})"
    if kind == "edge":
        return f"open-edges.md edge {nid}"
    if kind == "catalog":
        return f"catalog element {nid}"
    return "genuinely new — mint an edge / element / bank"


def placement(kind, nid):
    if kind == "node":
        return f"edit-stub: fold the draft into docs/{nid}.md."
    if kind == "decision":
        if os.path.exists(os.path.join(ROOT, f"docs/decision-{nid}.md")):
            return f"edit-stub: fold into the existing docs/decision-{nid}.md."
        return ("new decision: place at docs/decision-{}.md AND bump CONTENTS.md's "
                "'(nine notes)' count (authority-tier — do NOT let capture do it "
                "silently).".format(nid))
    if kind == "bank":
        if os.path.exists(os.path.join(ROOT, f"docs/banks/{nid}.md")):
            return f"edit-stub: refract into the existing docs/banks/{nid}.md shards."
        return "new bank: created in place by `doc new-bank`; fill the shards."
    if kind == "edge":
        return (f"edge insertion: extend edge {nid} in docs/open-edges.md, or add "
                "a new numbered edge if the claim opens a genuinely new boundary "
                "(edge numbers are cited everywhere — a human assigns them).")
    if kind == "catalog":
        return f"catalog row: refine element {nid}'s row in the catalog."
    return ("mint: no home ranked above threshold — decide edge vs element vs "
            "bank, then re-route.")


# ------------------------------------------------------------- scaffolding ----
STUB = """# CAPTURE STUB — {home}

<!-- Generated by tools/capture/capture.py from {note}. Scaffold only; a human/LLM
fills the Draft. Route + authority pre-seeded; the source claims are verbatim and
their gradient markers are preserved — do NOT flatten them. -->

## Routed home
- **{home}** · route source: {src} · score {score}
- Placement: {placement}

## Authority to check the draft against (fill toward this; gradient: code > CONFORMANCE-MAP/INDEX > decision > bank > note)
{authority}

## Source claim(s) from the exploration note (verbatim)
{claims}

## Draft — fill this (the canonical prose a human/LLM writes)

TODO — write the canonical statement here, checked against every authority above.
"""


def slugify_note(path):
    b = os.path.basename(path)[:-3] if path.endswith(".md") else os.path.basename(path)
    return re.sub(r"^VISION-", "", b)


def new_bank_inplace(nid, enums):
    """Reuse doc new-bank (in place) + append the banks/INDEX row so lint
    stays green. Returns a status line for the report."""
    dest = os.path.join(ROOT, "docs/banks", f"{nid}.md")
    if os.path.exists(dest):
        return f"[bank {nid}] already exists — left as-is; fold the claim into its shards"
    cmd = [sys.executable, os.path.join(ROOT, "tools/doc/doc.py"),
           "new-bank", nid] + [f"E{n}" for n in enums]
    r = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        return f"[bank {nid}] new-bank FAILED: {r.stderr.strip() or r.stdout.strip()}"
    # append the INDEX row (lint check D forcing-function) so lint stays clean
    with open(BANKS_INDEX, "a") as f:
        f.write(f"| [[banks/{nid}]] | <concept — fill> | <monolith it refracts — fill> |\n")
    return f"[bank {nid}] created via new-bank (in place) + banks/INDEX row appended"


def scaffold(routed_groups, note_path, outdir, banklog):
    os.makedirs(outdir, exist_ok=True)
    files = []
    for i, (key, group) in enumerate(sorted(routed_groups.items()), 1):
        kind, nid = key
        best = group[0].route  # (kind, id, score, why) — same home for the group
        claims = "\n".join(
            f'- "{c.text}"' + (f"  _[state: {c.state}]_" if c.state else "")
            + f"  _(from: {c.origin})_" for c in group)
        auth = "\n".join(f"- {a}" for a in authority_for(kind, nid))
        body = STUB.format(
            home=home_desc(kind, nid), note=os.path.basename(note_path),
            src="frontier/fallback",
            score=best[2] if best else "n/a",
            placement=placement(kind, nid), authority=auth, claims=claims)
        fn = f"{i:02d}-{kind}-{re.sub(r'[^A-Za-z0-9]+', '_', nid)}.md"
        open(os.path.join(outdir, fn), "w").write(body)
        files.append((fn, kind, nid, len(group)))
        # the ONE in-place exception: a NEW bank -> reuse new-bank
        if kind == "bank" and not os.path.exists(
                os.path.join(ROOT, f"docs/banks/{nid}.md")):
            enums = sorted({int(m.group(1)) for c in group
                            for m in re.finditer(r"\bE(\d+)\b", c.text)})
            banklog.append(new_bank_inplace(nid, enums))
    return files


# ---------------------------------------------------------------- reporting ---
def build_report(note_path, routable, author, captured, groups, files,
                 route_src, banklog, mint):
    L = []
    L.append(f"# CAPTURE REPORT — {os.path.relpath(note_path, ROOT)}")
    L.append(f"_Generated {datetime.date.today().isoformat()} by tools/capture/capture.py. "
             f"Routing source: **{route_src}**._")
    L.append(f"\n{len(routable)} routable claim(s) → {len(groups)} home(s) · "
             f"{len(author)} author-call(s) surfaced · {len(captured)} "
             f"already-captured/resolved item(s).")

    L.append("\n## Routed — scaffolds emitted")
    L.append("| # | home | kind | claims | scaffold file |")
    L.append("|---|------|------|--------|---------------|")
    for i, (fn, kind, nid, n) in enumerate(files, 1):
        L.append(f"| {i} | {home_desc(kind, nid)} | {kind} | {n} | `{fn}` |")

    if mint:
        L.append("\n## Genuinely new — no home above threshold (mint proposal)")
        for c in mint:
            L.append(f"- **{c.subject}** — {c.text}"
                     + (f"  _[state: {c.state}]_" if c.state else ""))
        L.append("_These routed to no existing home. Decide edge vs element vs "
                 "bank before scaffolding; a mint-proposal stub was staged._")

    if banklog:
        L.append("\n## In-place bank scaffolds (new-bank reuse)")
        for b in banklog:
            L.append(f"- {b}")

    L.append("\n## NEEDS-AUTHOR — surfaced VERBATIM, never resolved")
    L.append("_These are author-tier calls from the note. capture does NOT route "
             "or resolve them; a human decides._\n")
    if author:
        for title, b in author:
            L.append(f"- {b}")
    else:
        L.append("_(none marked in this note)_")

    if captured:
        L.append("\n## Already captured / resolved this session (verify-only, not re-scaffolded)")
        for title, b in captured:
            L.append(f"- {b}")

    L.append("\n## Notes")
    L.append("- SEAM: routing delegates to `tools/frontier/frontier.py route` (Tool "
             "1b); this run used the **" + route_src + "** path. See the SEAM "
             "banner in tools/capture/capture.py.")
    L.append("- capture SCAFFOLDS; a human/LLM fills each Draft, checking it "
             "against the seeded authority (gradient: code > CONFORMANCE-MAP/"
             "INDEX > decision > bank > note).")
    L.append("- All non-bank scaffolds are STAGED here (not merged into canon): "
             "in-place edits touch authority-tier files (MAP counts, edge "
             "numbering, catalog ids) a human must reconcile. New banks are the "
             "one exception (created in place via new-bank + INDEX row).")
    return "\n".join(L)


# --------------------------------------------------------------------- main ---
def main():
    args = [a for a in sys.argv[1:]]
    report_only = "--report-only" in args
    args = [a for a in args if a != "--report-only"]
    outdir = None
    if "--out" in args:
        i = args.index("--out")
        outdir = args[i + 1]
        del args[i:i + 2]
    if not args:
        die("usage: tools/capture/capture.py <VISION-note.md> [--report-only] [--out <dir>]")
    note_path = args[0] if os.path.isabs(args[0]) else os.path.join(ROOT, args[0])
    if not os.path.isfile(note_path):
        die(f"note not found: {note_path}")

    text = open(note_path).read()
    routable, author, captured = parse_note(text)

    # route every routable claim (via the seam), grouping claims by home
    route_src = None
    groups = {}     # (kind, id) -> [Claim, ...]
    mint = []
    for c in routable:
        cands, src = route(c.query())
        if route_src != "frontier":
            route_src = src
        if not cands:
            c.route = None
            mint.append(c)
            continue
        score, kind, nid, why = cands[0]
        if kind == "new" or nid in ("", "-"):
            c.route = None
            mint.append(c)
            continue
        c.route = (kind, nid, score, why)
        groups.setdefault((kind, nid), []).append(c)
    route_src = route_src or "fallback"

    if report_only:
        rep = build_report(note_path, routable, author, captured, groups,
                           [("(not written — --report-only)", k[0], k[1], len(g))
                            for k, g in sorted(groups.items())],
                           route_src, [], mint)
        print(rep)
        return

    outdir = outdir or os.path.join(ROOT, ".planning/capture", slugify_note(note_path))
    if not os.path.isabs(outdir):
        outdir = os.path.join(ROOT, outdir)
    banklog = []
    files = scaffold(groups, note_path, outdir, banklog)

    # a mint proposal stub for genuinely-new claims (staged, not resolved)
    if mint:
        os.makedirs(outdir, exist_ok=True)
        mlines = ["# CAPTURE STUB — genuinely new (no home above threshold)",
                  f"\n<!-- from {os.path.basename(note_path)}; decide edge vs "
                  "element vs bank, then re-route. -->\n",
                  "## Claims that found no home\n"]
        for c in mint:
            mlines.append(f'- "{c.text}"'
                          + (f"  _[state: {c.state}]_" if c.state else "")
                          + f"  _(from: {c.origin})_")
        open(os.path.join(outdir, "00-mint-proposal.md"), "w").write(
            "\n".join(mlines) + "\n")

    rep = build_report(note_path, routable, author, captured, groups, files,
                       route_src, banklog, mint)
    open(os.path.join(outdir, "REPORT.md"), "w").write(rep + "\n")
    if author:
        open(os.path.join(outdir, "AUTHOR-CALLS.md"), "w").write(
            "# NEEDS-AUTHOR — surfaced verbatim, never resolved\n\n"
            f"From {os.path.relpath(note_path, ROOT)}:\n\n"
            + "\n".join(f"- {b}" for _, b in author) + "\n")
    print(rep)
    print(f"\n[capture] staged {len(files)} scaffold(s) + REPORT.md in "
          f"{os.path.relpath(outdir, ROOT)}/", file=sys.stderr)


if __name__ == "__main__":
    main()
