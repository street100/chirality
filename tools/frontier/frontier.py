#!/usr/bin/env python3
"""frontier — the growth/orientation sibling of pack (elements) and
doc (doc audits). Two deterministic subcommands, no LLM in any path:

    condense   EXTRACT a rot-proof "where things stand" digest to docs/definitions/FRONTIER.md
    route      given a topic/claim, rank its home(s) in the ecosystem (or say
               "genuinely new — mint an edge/element/bank")
    bundle     assemble a read-time orientation payload for a fresh chat — a
               GUARANTEED-fresh digest + the start-here entry points (+ optional
               topic focus), to stdout. Writes nothing.

`condense` is pure extraction + formatting over the design sources of truth
(open-edges, the decision docket, docs/decisions/*.md, docs/examples/INDEX.md, the
spec frontmatter, and `git log` of those files), so regenerating twice yields
byte-identical output. It embeds a hash of its sources; ledger-lint check I
flags the digest stale when a source changed but the digest was not regenerated
— the same forcing function as check D. The digest holds GRADIENTS (resolved in
direction / shaped / open), never flattening to done/not-done.

`route` matches a query against the node graph — docs/ + docs/banks/ node names,
titles, `related:`, edge titles, and catalog element titles — with an
idf-weighted overlap score. Below threshold it returns "genuinely new" rather
than forcing a bad home. No file is written by `route`.

Usage:
    tools/frontier/frontier.py condense
    tools/frontier/frontier.py route register custody
    tools/frontier/frontier.py route --file .planning/VISION-something.md
    tools/frontier/frontier.py bundle
    tools/frontier/frontier.py bundle effect row
"""
from __future__ import annotations
import glob
import hashlib
import math
import os
import re
import subprocess
import sys
from collections import Counter

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# ---------------------------------------------------------------------------
# Sources of truth (single definition — shared by condense AND ledger-lint's
# staleness check, which imports source_files()/sources_hash() from here so the
# two can never drift). Order is deterministic: fixed head, then sorted globs.
# ---------------------------------------------------------------------------
FIXED_SOURCES = [
    "docs/definitions/open-edges.md",
    ".planning/DECISION-DOCKET.md",
    "docs/examples/INDEX.md",
]


def source_files() -> list[str]:
    """The design sources condense extracts from, as sorted repo-relative
    POSIX paths. This exact set is what the staleness hash covers."""
    rels: list[str] = [p for p in FIXED_SOURCES if os.path.isfile(os.path.join(ROOT, p))]
    rels += sorted(os.path.relpath(p, ROOT).replace(os.sep, "/")
                   for p in glob.glob(os.path.join(ROOT, "docs", "decisions", "decision-*.md")))
    rels += sorted(os.path.relpath(p, ROOT).replace(os.sep, "/")
                   for p in glob.glob(os.path.join(ROOT, "docs", "elements", "specs", "*.md"))
                   if os.path.basename(p) != "_TEMPLATE.md")
    return rels


def sources_hash() -> str:
    """Content hash over the source set — path\\0content\\0 per file, in the
    deterministic source_files() order. Not the file mtimes (unreliable across
    a git checkout); the byte content, like check D's forcing function."""
    h = hashlib.sha256()
    for rel in source_files():
        h.update(rel.encode())
        h.update(b"\0")
        with open(os.path.join(ROOT, rel), "rb") as f:
            h.update(f.read())
        h.update(b"\0")
    return h.hexdigest()


HASH_MARKER = "FRONTIER-SOURCES-SHA256"


def embedded_hash(digest_text: str) -> str | None:
    m = re.search(rf"{HASH_MARKER}:\s*([0-9a-f]{{64}})", digest_text)
    return m.group(1) if m else None


# ---------------------------------------------------------------------------
# shared text helpers
# ---------------------------------------------------------------------------
def read(rel: str) -> str:
    with open(os.path.join(ROOT, rel), encoding="utf-8") as f:
        return f.read()


def strip_markup(s: str) -> str:
    """Neutralize wiki-links and code spans in extracted prose: `[[x]]`->`x`,
    `` `code` ``->`code`. Keeps the words but removes the markup so the
    generated digest introduces no dangling [[links]] (check F) and no
    `file.py:NN` citations (check G) that ledger-lint would then police."""
    s = re.sub(r"\[\[([^\]]+)\]\]", r"\1", s)
    s = s.replace("`", "")
    return re.sub(r"\s+", " ", s).strip()


def first_sentence(s: str) -> str:
    s = strip_markup(s)
    m = re.search(r"(.+?[.:])(?:\s|$)", s)
    return m.group(1).strip() if m else s


def first_heading(text: str) -> str:
    for ln in text.splitlines():
        if ln.startswith("# "):
            return ln[2:].strip()
    return ""


def frontmatter_field(text: str, field: str) -> str | None:
    m = re.search(rf"^{field}:\s*(.+?)\s*$", text, re.M)
    return m.group(1) if m else None


# ---------------------------------------------------------------------------
# EXTRACTORS — each returns structured facts, no summarization
# ---------------------------------------------------------------------------
def parse_edges() -> list[dict]:
    """open-edges.md numbered edges 1..20. An edge block is the numbered line
    plus its indented/blank continuation lines (edge markers sit at column 0;
    section headers and interstitial prose also sit at column 0)."""
    lines = read("docs/definitions/open-edges.md").split("\n")
    edges: list[dict] = []
    seen: set[int] = set()
    i = 0
    while i < len(lines):
        m = re.match(r"^(\d{1,2})\.\s+(.*)$", lines[i])
        if m and 1 <= int(m.group(1)) <= 20 and int(m.group(1)) not in seen:
            num = int(m.group(1))
            seen.add(num)
            body = [m.group(2)]
            j = i + 1
            while j < len(lines) and (lines[j] == "" or lines[j][:1] in (" ", "\t")):
                body.append(lines[j])
                j += 1
            block = "\n".join(body)
            edges.append({"num": num,
                          "title": first_sentence(m.group(2)),
                          "status": edge_status(block),
                          "block": block})
            i = j
        else:
            i += 1
    edges.sort(key=lambda e: e["num"])
    return edges


def edge_status(block: str) -> str:
    """Classify an edge into a GRADIENT bucket from its own language — never a
    binary. resolved-in-direction (a direction drawn, residue named) / shaped
    (partially answered) / open (stub or fully unresolved)."""
    b = block.lower()
    resolved = ("resolved in direction", "resolved-in-direction", "**resolved**",
                "settled in direction")
    if any(k in b for k in resolved) or re.search(r"\bresolved\s+20\d\d", b):
        return "resolved-in-direction"
    shaped = ("**shaped", "shape settled", "largely answered", "**narrowed",
              "narrowed in direction", "**sharpened", "softened on the wire",
              "**stress-tested", "**two additions", "**two obligations",
              "answer shape")
    if any(k in b for k in shaped):
        return "shaped"
    return "open"


def parse_decisions() -> list[dict]:
    out = []
    for rel in sorted(os.path.relpath(p, ROOT).replace(os.sep, "/")
                      for p in glob.glob(os.path.join(ROOT, "docs", "decisions", "decision-*.md"))):
        text = read(rel)
        out.append({"node": frontmatter_field(text, "node") or os.path.basename(rel)[:-3],
                    "title": first_heading(text),
                    "updated": frontmatter_field(text, "updated") or "0000-00-00",
                    "status": frontmatter_field(text, "status") or "?"})
    out.sort(key=lambda d: (d["updated"], d["node"]), reverse=True)
    return out


def parse_docket() -> list[dict]:
    """DECISION-DOCKET.md D# headers: `## D1 — <title> · … · **STATUS date**`."""
    out = []
    for m in re.finditer(r"^##\s+(D\d+)\s+—\s+(.*)$", read(".planning/DECISION-DOCKET.md"), re.M):
        header = m.group(2)
        title = strip_markup(header.split("·")[0])
        st = re.findall(r"\*\*([A-Z][A-Z0-9\- ]*?)(?:\s+\d{4}-\d\d-\d\d)?\*\*", header)
        out.append({"id": m.group(1), "title": title,
                    "status": st[-1].strip() if st else "?"})
    out.sort(key=lambda d: int(d["id"][1:]))
    return out


def parse_specs() -> list[dict]:
    out = []
    for rel in sorted(os.path.relpath(p, ROOT).replace(os.sep, "/")
                      for p in glob.glob(os.path.join(ROOT, "docs", "elements", "specs", "*.md"))
                      if os.path.basename(p) != "_TEMPLATE.md"):
        text = read(rel)
        out.append({"element": frontmatter_field(text, "element") or "?",
                    "title": strip_markup(frontmatter_field(text, "title") or ""),
                    "status": frontmatter_field(text, "status") or "?",
                    "blocker": spec_blocker(text)})
    out.sort(key=lambda s: (int(re.sub(r"\D", "", s["element"]) or 0)))
    return out


def spec_blocker(text: str) -> str:
    """A blocked spec names its blocker in the leading blockquote after the
    `status: blocked` marker — extract that sentence verbatim (markup stripped)."""
    m = re.search(r"status:\s*blocked\*\*\s*—\s*(.+?)(?:\.\s|\.\n|\n>\s*\n)", text, re.S)
    if m:
        return first_sentence(m.group(1))
    return ""


def parse_index_pipeline() -> list[tuple[str, int]]:
    """docs/examples/INDEX.md status column, counted. Status cells may carry a
    parenthetical ('drafted (reworked …)') — the bucket is the first word."""
    counts: Counter[str] = Counter()
    for ln in read("docs/examples/INDEX.md").splitlines():
        if not ln.startswith("|"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 6 or cells[0] in ("Element", "-------", "") or cells[0].startswith("-"):
            continue
        if not re.match(r"E\d+", cells[0]):
            continue
        bucket = cells[4].split()[0] if cells[4] else "?"
        counts[bucket] += 1
    order = ["drafted", "reviewed", "specced", "audited", "implemented", "needs-rework"]
    known = [(k, counts[k]) for k in order if counts.get(k)]
    extra = sorted((k, v) for k, v in counts.items() if k not in order)
    return known + extra


def git_recent(n: int = 8) -> list[tuple[str, str, str]]:
    """git log over the source files: (short-hash, date, subject). Deterministic
    given HEAD; the sources it walks exclude the digest itself, so committing a
    regenerated digest never perturbs this section."""
    cmd = ["git", "-C", ROOT, "log", "--no-merges", f"-n{n}",
           "--date=short", "--format=%h%x09%ad%x09%s", "--"] + source_files()
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, check=True).stdout
    except Exception:
        return []
    rows = []
    for ln in out.splitlines():
        parts = ln.split("\t", 2)
        if len(parts) == 3:
            rows.append((parts[0], parts[1], strip_markup(parts[2])))
    return rows


# ---------------------------------------------------------------------------
# condense — assemble docs/definitions/FRONTIER.md
# ---------------------------------------------------------------------------
DIGEST_PATH = "docs/definitions/FRONTIER.md"

STATUS_GLOSS = {"resolved-in-direction": "resolved in direction (residue named)",
                "shaped": "shaped (partially answered)",
                "open": "open / stub"}


def build_digest() -> str:
    edges = parse_edges()
    decisions = parse_decisions()
    docket = parse_docket()
    specs = parse_specs()
    pipeline = parse_index_pipeline()
    recent = git_recent()

    latest = max((r[1] for r in recent), default="") or \
        max((d["updated"] for d in decisions), default="0000-00-00")

    L: list[str] = []
    L.append("---")
    L.append("node: frontier")
    L.append("layer: generated")
    L.append("tier: orientation")
    L.append(f"updated: {latest}")
    L.append("---")
    L.append("")
    L.append("# Design frontier — where things stand")
    L.append("")
    L.append("> GENERATED by `tools/frontier/frontier.py condense` — do not hand-edit. It")
    L.append("> EXTRACTS (never summarizes) from open-edges, the decision docket,")
    L.append("> docs/decisions/*.md, docs/examples/INDEX.md, the spec frontmatter, and the")
    L.append("> git log of those files. Regenerating twice is byte-identical;")
    L.append("> ledger-lint check I flags it stale when a source moved. Statuses are")
    L.append("> GRADIENTS (resolved in direction / shaped / open), not done/not-done.")
    L.append("")
    L.append(f"<!-- {HASH_MARKER}: {sources_hash()} -->")
    L.append(f"<!-- sources: {len(source_files())} files -->")
    L.append("")

    # --- Decided recently ---
    L.append("## Decided recently")
    L.append("")
    L.append("### Settled decision notes (docs/decision-*.md, newest first)")
    L.append("")
    for d in decisions:
        L.append(f"- {d['updated']} · {d['node']} [{d['status']}] — {d['title']}")
    L.append("")
    L.append("### Docket items resolved (.planning/DECISION-DOCKET.md)")
    L.append("")
    for d in docket:
        if d["status"].startswith("RESOLVED"):
            L.append(f"- {d['id']} [{d['status']}] — {d['title']}")
    L.append("")
    L.append("### Edges resolved in direction (docs/open-edges.md)")
    L.append("")
    for e in edges:
        if e["status"] == "resolved-in-direction":
            L.append(f"- Edge {e['num']} — {e['title']}")
    L.append("")

    # --- Open ---
    L.append("## Open")
    L.append("")
    L.append("### Edges still open (gradient preserved)")
    L.append("")
    for e in edges:
        if e["status"] != "resolved-in-direction":
            L.append(f"- Edge {e['num']} [{STATUS_GLOSS[e['status']]}] — {e['title']}")
    L.append("")
    L.append("### Live author-calls (docket, not yet resolved)")
    L.append("")
    author = [d for d in docket if not d["status"].startswith("RESOLVED")]
    if author:
        for d in author:
            L.append(f"- {d['id']} [{d['status']}] — {d['title']}")
    else:
        L.append("- (none open)")
    L.append("")

    # --- In-flight ---
    L.append("## In-flight")
    L.append("")
    L.append("### Pipeline (examples/INDEX.md, by status)")
    L.append("")
    for status, count in pipeline:
        L.append(f"- {status}: {count}")
    L.append("")
    L.append("### Blocked specs (docs/elements/specs/, named with blocker)")
    L.append("")
    blocked = [s for s in specs if s["status"] == "blocked"]
    if blocked:
        for s in blocked:
            reason = s["blocker"] or "(blocker not stated in spec)"
            L.append(f"- {s['element']} — {s['title']} · BLOCKED: {reason}")
    else:
        L.append("- (none blocked)")
    L.append("")

    # --- Recently changed / killed ---
    L.append("## Recently changed / killed")
    L.append("")
    L.append("### Last commits touching the frontier sources")
    L.append("")
    if recent:
        for h, dt, subj in recent:
            L.append(f"- {dt} {h} — {subj}")
    else:
        L.append("- (git log unavailable)")
    L.append("")
    return "\n".join(L)


def condense() -> None:
    text = build_digest()
    dest = os.path.join(ROOT, DIGEST_PATH)
    with open(dest, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"[condense] wrote {DIGEST_PATH} ({text.count(chr(10)) + 1} lines, "
          f"{len(source_files())} sources)")
    print(f"[condense] sources-hash {sources_hash()[:16]}… — ledger-lint check I "
          f"flags the digest stale if a source changes without a re-condense.")


# ---------------------------------------------------------------------------
# route — where does this belong?
# ---------------------------------------------------------------------------
STOPWORDS = {
    "the", "a", "an", "and", "or", "of", "to", "in", "is", "it", "its", "as",
    "at", "on", "by", "for", "with", "that", "this", "these", "those", "be",
    "are", "was", "not", "no", "but", "so", "if", "then", "than", "into",
    "from", "over", "under", "how", "what", "which", "when", "where", "who",
    "one", "two", "can", "may", "do", "does", "done", "each", "per", "all",
    "any", "own", "you", "your", "we", "our", "they", "their", "up", "out",
    "off", "new", "now", "still", "yet", "also", "only", "same", "such",
}


def tokenize(s: str) -> list[str]:
    toks = []
    for raw in re.findall(r"[A-Za-z0-9]+", s.lower()):
        if raw in STOPWORDS or len(raw) < 2:
            continue
        # light plural fold: rows->row, but keep -ss (class, address)
        if len(raw) > 3 and raw.endswith("s") and not raw.endswith("ss"):
            raw = raw[:-1]
        toks.append(raw)
    return toks


# location weights — where in a home a query token landed
W_NAME, W_TITLE, W_RELATED, W_BODY = 4.0, 3.0, 2.5, 1.0
THRESHOLD = 2.5          # a home below this is not a real home
SPECIFICITY_FLOOR = 1.2  # at least one matched token must be this discriminating


def build_homes() -> list[dict]:
    """Every routable home: docs/ + banks/ nodes, open-edges edges, catalog
    elements. Each carries per-location token sets so a name/title hit outranks
    a body mention."""
    homes: list[dict] = []

    for base, kind in ((os.path.join(ROOT, "docs"), "doc"),
                       (os.path.join(ROOT, "docs", "banks"), "bank")):
        for p in sorted(glob.glob(os.path.join(base, "*.md"))):
            if os.path.basename(p) in ("FRONTIER.md", "INDEX.md"):
                continue
            text = open(p, encoding="utf-8").read()
            node = frontmatter_field(text, "node") or os.path.basename(p)[:-3]
            title = first_heading(text)
            related = frontmatter_field(text, "related") or ""
            homes.append({
                "kind": kind, "id": node,
                "label": title or node,
                "name": set(tokenize(node.replace("/", " ").replace("-", " "))),
                "title": set(tokenize(title)),
                "related": set(tokenize(related.replace("[", " ").replace("]", " ")
                                        .replace(",", " ").replace("-", " "))),
                "body": Counter(tokenize(text)),
            })

    for e in parse_edges():
        homes.append({
            "kind": "edge", "id": f"edge-{e['num']}",
            "label": e["title"],
            "name": set(),
            "title": set(tokenize(e["title"])),
            "related": set(),
            "body": Counter(tokenize(e["block"])),
        })

    catalog = os.path.join(ROOT, "docs", "elements", "catalog.md")
    if os.path.isfile(catalog):
        for m in re.finditer(r"^\|\s*E(\d+)\s*\|\s*([^|]+?)\s*\|",
                             open(catalog, encoding="utf-8").read(), re.M):
            title = strip_markup(m.group(2))
            homes.append({
                "kind": "element", "id": f"E{m.group(1)}",
                "label": title,
                "name": set(),
                "title": set(tokenize(title)),
                "related": set(),
                "body": Counter(),
            })
    return homes


def compute_idf(homes: list[dict]) -> dict[str, float]:
    df: Counter[str] = Counter()
    for h in homes:
        toks = set(h["name"]) | set(h["title"]) | set(h["related"]) | set(h["body"])
        for t in toks:
            df[t] += 1
    n = len(homes)
    return {t: math.log(1 + n / c) for t, c in df.items()}


def score_home(home: dict, qtokens: list[str], idf: dict[str, float]) -> tuple[float, list[str], float]:
    total = 0.0
    why: list[str] = []
    best_idf = 0.0
    for t in dict.fromkeys(qtokens):  # distinct, order-preserving
        w = idf.get(t)
        if w is None:
            continue
        if t in home["name"]:
            loc, weight = "name", W_NAME
        elif t in home["title"]:
            loc, weight = "title", W_TITLE
        elif t in home["related"]:
            loc, weight = "related", W_RELATED
        elif t in home["body"]:
            loc, weight = "body", W_BODY
        else:
            continue
        contrib = weight * w
        # small bonus for repeated body mentions (capped), keeps ordering stable
        if loc == "body":
            contrib += min(home["body"][t] - 1, 4) * 0.1 * w
        total += contrib
        best_idf = max(best_idf, w)
        why.append(f"{t}@{loc}")
    return total, why, best_idf


def route(query: str, porcelain: bool = False) -> None:
    qtokens = tokenize(query)
    homes = build_homes()
    idf = compute_idf(homes)

    scored = []
    for h in homes:
        s, why, best_idf = score_home(h, qtokens, idf)
        if s > 0:
            scored.append((s, h, why, best_idf))
    # deterministic: score desc, then kind order, then id
    kind_order = {"doc": 0, "bank": 1, "edge": 2, "element": 3}
    scored.sort(key=lambda r: (-round(r[0], 6), kind_order.get(r[1]["kind"], 9), r[1]["id"]))
    strong = [r for r in scored if r[0] >= THRESHOLD and r[3] >= SPECIFICITY_FLOOR]

    if porcelain:
        # machine contract for capture: <score>\t<kind>:<id>\t<why>.
        # kinds mapped to capture's vocab {node,decision,bank,edge,catalog,new};
        # an explicit 'new' line lets the caller tell genuinely-new from a dead
        # seam (empty output would trip its fallback).
        _K = {"doc": "node", "element": "catalog", "bank": "bank", "edge": "edge"}
        if not qtokens or not strong:
            print("0.00\tnew:-\tno home clears the routing threshold")
            return
        for s, h, why, _ in strong[:8]:
            kind, hid = _K.get(h["kind"], h["kind"]), h["id"]
            if kind == "node" and hid.startswith("decision-"):
                kind, hid = "decision", hid[len("decision-"):]
            elif kind == "bank" and hid.startswith("banks/"):
                # the `kind` field already carries the namespace; emit the bare
                # slug (parallel to the decision case) so a consumer's
                # docs/banks/<id>.md check is not fed a doubled prefix.
                hid = hid[len("banks/"):]
            print(f"{s:.2f}\t{kind}:{hid}\t{', '.join(why)}")
        return

    print(f"# route — query: {query!r}")
    if not qtokens:
        print("\nEmpty query after stopword removal — nothing to route.")
        return
    print(f"query tokens: {', '.join(dict.fromkeys(qtokens))}")

    if not strong:
        print("\nVERDICT: genuinely new — no home clears the routing threshold.")
        print("Mint one: an open-edge (design question), a catalog element (E#, a")
        print("thing to build), or a bank (a refracted concept). See CLAUDE.md 'Banks'.")
        if scored[:3]:
            print("\n(nearest weak matches, all below threshold:)")
            for s, h, why, _ in scored[:3]:
                print(f"  - [{h['kind']}] {h['id']} (score {s:.2f}) — {', '.join(why)}")
        return

    print(f"\nVERDICT: {len(strong)} home(s) above threshold "
          f"(>= {THRESHOLD}). Ranked:\n")
    for rank, (s, h, why, _) in enumerate(strong[:8], 1):
        print(f"{rank}. [{h['kind']}] {h['id']} — {h['label']}")
        print(f"     score {s:.2f} · matched {', '.join(why)}")


# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# bundle — the read-time orientation payload (Tool 3). Assembles a GUARANTEED-
# fresh digest + the start-here entry points (+ optional topic focus) to stdout
# for a fresh chat. Ephemeral: writes nothing, so it is not lint-policed.
# ---------------------------------------------------------------------------
ORIENT_DOCS = ["README.md", "docs/index.md", "PRINCIPLES.md",
               "docs/glossary.md", "CLAUDE.md"]


def _fresh_digest() -> tuple[str, bool]:
    """The digest text, guaranteed current. Returns (text, on_disk_was_fresh);
    rebuilds in-memory if the file is stale/missing so a fresh chat never reads
    a stale frontier."""
    path = os.path.join(ROOT, DIGEST_PATH)
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as f:
            disk = f.read()
        if embedded_hash(disk) == sources_hash():
            return disk, True
    return build_digest(), False


def bundle(topic: str | None = None) -> None:
    text, fresh = _fresh_digest()
    if not fresh:
        print("<!-- NOTE: docs/definitions/FRONTIER.md was stale or missing; the digest "
              "below was rebuilt in-memory. Run `frontier condense` to "
              "update the file. -->\n")
    print(text.rstrip())
    print("\n## Start here — orientation entry points\n")
    for rel in ORIENT_DOCS:
        p = os.path.join(ROOT, rel)
        if not os.path.isfile(p):
            continue
        with open(p, encoding="utf-8") as f:
            head = first_heading(f.read())
        print(f"- `{rel}`" + (f" — {head}" if head else ""))
    print("\nDepth tier: docs/banks/ (read a concept's bank before naming a "
          "gap). Element pipeline: pack. Doc audits: doc.")
    if topic:
        print(f"\n## Topic focus — {topic!r}\n")
        route(topic)


# ---------------------------------------------------------------------------
def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    cmd = sys.argv[1]
    if cmd == "condense":
        condense()
        return 0
    if cmd == "route":
        rest = sys.argv[2:]
        porcelain = "--porcelain" in rest
        rest = [a for a in rest if a != "--porcelain"]
        if rest and rest[0] == "--file":
            if len(rest) < 2:
                print("route --file needs a path", file=sys.stderr)
                return 2
            path = rest[1] if os.path.isabs(rest[1]) else os.path.join(ROOT, rest[1])
            with open(path, encoding="utf-8") as f:
                route(f.read(), porcelain=porcelain)
        elif rest:
            route(" ".join(rest), porcelain=porcelain)
        else:
            print("route needs a query or --file <path>", file=sys.stderr)
            return 2
        return 0
    if cmd == "bundle":
        rest = sys.argv[2:]
        bundle(" ".join(rest) if rest else None)
        return 0
    print(f"unknown command {cmd!r} (condense | route | bundle)", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
