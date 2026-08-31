# scriba polish backlog + the self-growth-test option (2026-08-16)

Logged, NOT scheduled. The mechanical editing queue and the persistence arc (P1–P4)
are shipped; these are the residue. Kept distinct from the two spec-tier FEATURES
still open (3C per-Expert fields, 3D actuate ORDER — see `SCRIBA-STATE.md` gap 3).

## The polish lineup (residue — non-blocking, each small)

| # | Item | What / why | Cost signal |
|---|------|-----------|-------------|
| PL1 | **`:compose` fires the edited/loaded doc** | Today `:compose` picks from static `all-pipelines` + binds a config; edit→run runs the *edited* pipeline but with a FIXED `smoke-local-config`. Polish = let compose bind a *chosen* config to the CURRENT author doc → config-choice on your edited setup. | pure scriba, small |
| PL2 | **Absolute / config-dir setups path** | `setups-dir` is cwd-relative `"setups"` (resolves from repo root only, as `bin/scriba` runs). A `$XDG_CONFIG_HOME/manas/setups` path needs `getenv` + `mkdir` crossings (~5-file each). | crosses into "chirality needs" (2 syscalls) |
| PL3 | **Long render rows truncate** | EXPERTS row (and any long row) is cut at terminal width — no wrap/scroll; a long pool isn't fully visible (value-level correctness is fine, proven by unit tests). | pure scriba, small |
| PL4 | **Browser is Tab-completion, not a list** | `:manas` picker shows label + typed prefix; candidates reached via Tab. A scrollable inline candidate list is more discoverable. | pure scriba, small–med |
| PL5 | **`m`/`g` first-applicable targeting** | `m` rebinds the config's FIRST binding; `g` toggles the FIRST rule's members. add/remove already take explicit names (`G/X/B/R`); only in-place `m`/`g` are first-applicable. Name-targeting = 2 extra minipuffer prompts. | pure scriba, small |
| PL6 | **VimMode flat type-split** | `VimMode` is one flat sum (vm-normal 72×); dispatch is already two-level but the type isn't. ~130-site mechanical split. Pure internal cleanliness, low external value. | pure churn, ~130 sites |

## The self-growth-test option — a DISTINCT path, tangent to actually growing itself

"Grow itself" = use the manas cockpit (now able to author → save → run pipelines that
orchestrate AI agents against the mesh) to produce scriba/chirality's OWN next changes —
self-hosting the *development loop*, not just the compiler.

Two distinct options — do not conflate:

- **A) Actually grow itself.** Adopt the cockpit as the real dev pipeline going
  forward: a manas pipeline drives feature work (author the pipeline, run it, take the
  diff). The main line. High stakes — you're betting real feature delivery on the loop.

- **B) TEST that it CAN grow itself.** A scoped validation, NOT feature delivery: pick
  ONE polish item above, build it THROUGH the cockpit (author a pipeline for
  "implement PL#", `:save` it, `:run`/`:compose` against the mesh, capture the produced
  diff), then check the result the normal way (B1 build + PTY). The deliverable is the
  ANSWER "did the loop produce a correct change?", not the change itself. Tangent to A,
  distinct, lower-stakes — a proof-of-loop.

**Why the polish items are the right test-bed for B:** small, well-scoped, low-risk,
independently verifiable (compile + PTY). Ideal to prove the loop without a big feature
riding on an unproven pipeline. If B succeeds on a PL#, A becomes credible; if it
fails, we learn where the cockpit falls short of self-growth cheaply. Suggested first
target: **PL5** (name-targeting) or **PL3** (row wrap) — both self-contained, no
crossings, obvious pass/fail.

## Status
Backlog only. Nothing here is scheduled or in progress. Next move (A vs B vs a
specific PL#, or the spec-tier 3C/3D features) is a user call.
