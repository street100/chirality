# CAPTURE REPORT — .planning/VISION-deployment-custody-2026-07-24.md
_Generated 2026-07-24 by bin/chirality-capture.py. Routing source: **frontier**._

13 routable claim(s) → 6 home(s) · 3 author-call(s) surfaced · 4 already-captured/resolved item(s).

## Routed — scaffolds emitted
| # | home | kind | claims | scaffold file |
|---|------|------|--------|---------------|
| 1 | bank banks/capability (NEW — via new-bank) | bank | 1 | `01-bank-banks_capability.md` |
| 2 | bank banks/evidence-and-split (NEW — via new-bank) | bank | 1 | `02-bank-banks_evidence_and_split.md` |
| 3 | bank banks/memory (NEW — via new-bank) | bank | 2 | `03-bank-banks_memory.md` |
| 4 | existing docs node docs/open-edges.md | node | 6 | `04-node-open_edges.md` |
| 5 | existing docs node docs/target-tomodachi.md | node | 2 | `05-node-target_tomodachi.md` |
| 6 | existing docs node docs/trust-boundary.md | node | 1 | `06-node-trust_boundary.md` |

## In-place bank scaffolds (new-bank reuse)
- [bank banks/capability] new-bank FAILED: Traceback (most recent call last):
  File "/workspace/chirality/tools/doc/doc.py", line 313, in <module>
    main()
  File "/workspace/chirality/tools/doc/doc.py", line 307, in main
    new_bank(arg, [int(e.lstrip("Ee")) for e in sys.argv[3:]])
  File "/workspace/chirality/tools/doc/doc.py", line 289, in new_bank
    open(dest, "w").write(BANK_TEMPLATE.format(
    ^^^^^^^^^^^^^^^
FileNotFoundError: [Errno 2] No such file or directory: '/workspace/chirality/docs/banks/banks/capability.md'
- [bank banks/evidence-and-split] new-bank FAILED: Traceback (most recent call last):
  File "/workspace/chirality/tools/doc/doc.py", line 313, in <module>
    main()
  File "/workspace/chirality/tools/doc/doc.py", line 307, in main
    new_bank(arg, [int(e.lstrip("Ee")) for e in sys.argv[3:]])
  File "/workspace/chirality/tools/doc/doc.py", line 289, in new_bank
    open(dest, "w").write(BANK_TEMPLATE.format(
    ^^^^^^^^^^^^^^^
FileNotFoundError: [Errno 2] No such file or directory: '/workspace/chirality/docs/banks/banks/evidence-and-split.md'
- [bank banks/memory] new-bank FAILED: Traceback (most recent call last):
  File "/workspace/chirality/tools/doc/doc.py", line 313, in <module>
    main()
  File "/workspace/chirality/tools/doc/doc.py", line 307, in main
    new_bank(arg, [int(e.lstrip("Ee")) for e in sys.argv[3:]])
  File "/workspace/chirality/tools/doc/doc.py", line 289, in new_bank
    open(dest, "w").write(BANK_TEMPLATE.format(
    ^^^^^^^^^^^^^^^
FileNotFoundError: [Errno 2] No such file or directory: '/workspace/chirality/docs/banks/banks/memory.md'

## NEEDS-AUTHOR — surfaced VERBATIM, never resolved
_These are author-tier calls from the note. capture does NOT route or resolve them; a human decides._

- Canon-level + home for this vision (planning-tier vs a `docs/` note / a `decision-*.md`; and whether "personal host" enters `live-environment`).
- Whether to mint the **typed ABI-layout abstraction** (edge 6's open call).
- The tool priority for the next handoff: **doc-expansion tooling** (grow/ condense the ecosystem so it self-orients) > the frontier-orientation bundler (has use for opening chats, secondary).

## Already captured / resolved this session (verify-only, not re-scaffolded)
- **Edge 6** shaped (`open-edges.md`) — the tal-vocabulary line drawn: floor is thin, structs are library composition, not floor primitives; E30 disposition.
- **Edge 5** sharpened (`open-edges.md`) — dynamism reframe: freeze binds the judgment not the population; fine-grained certified succession; the cutover-window (not a hot-swap); the two new obligations.
- **`axis-altitude.md`** — new "The floor is thin" section (the substrate- minimality invariant + the "altitude error" name).
- ~~C8 propagation (rung model → `trust-boundary`)~~ — **DONE 2026-07-24** (the "two rungs" section, with the honest rung-1 secret-custody statement).

## Notes
- SEAM: routing delegates to `bin/chirality-frontier.py route` (Tool 1b); this run used the **frontier** path. See the SEAM banner in bin/chirality-capture.py.
- capture SCAFFOLDS; a human/LLM fills each Draft, checking it against the seeded authority (gradient: code > CONFORMANCE-MAP/INDEX > decision > bank > note).
- All non-bank scaffolds are STAGED here (not merged into canon): in-place edits touch authority-tier files (MAP counts, edge numbering, catalog ids) a human must reconcile. New banks are the one exception (created in place via new-bank + INDEX row).
