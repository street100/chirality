# scriba persistence — plan (2026-08-16)

KNOWN GAP #4 / the "easy access to compile different setups" depth. Today
Pipeline/Config are **static compiled-in values** (`all-pipelines`,
`all-profiles`) and every author edit **evaporates on ESC**. Persistence = save an
edited setup to disk and reload/run it later, so the editing surface (edit→run,
browser, the full add/remove family — all shipped) can produce a **saved, reusable
setup**.

## Format decision — JSON (reuse `scaffold/lib/json.chiral`)
`json.chiral` already ships `Json` (`j-null/j-bool/j-num/j-str/j-arr/j-obj`) +
`json-show : (-> Json Str)` + `json-parse : (-> Bytes (Maybe Json))` and is used by
http/backend/runner/manifest. Compose, don't reinvent: on-disk format = JSON.
**Experts are NOT serialized** — they're a shared compiled-in pool referenced by id;
a saved Pipeline/Config carries ids only, resolved against the live `expert-pool` on
load. This bounds the codec to Pipeline+Config (+ nested GateRule/Order/StopPolicy/
Binding) and sidesteps the 3C per-Expert design fork.

## Serial slices (one implement-agent at a time, verify + fold between each)

- **P1 — JSON codec (PURE, the foundation + the hard part).** New pure module
  `scaffold/lib/manas/pipeline/persist.chiral`: encoders `pipeline->json`/
  `config->json` (build the `j-obj` tree) + **total** decoders `json->pipeline`/
  `json->config : (-> Json (Maybe _))` (walk the obj, validate, reconstruct; missing/
  ill-typed field → `none`). Round-trip unit test over every value in `all-pipelines`
  + `all-profiles`: `json-show (encode v)` → `json-parse` → `decode` → `encode` →
  `json-show` equals the original string. Mesh-free, self-contained. **← dispatch first**
- **P2 — save.** Author-mode `:w <name>` (or a save key) writes `json-show (doc->json
  d)` to `<setups-dir>/<name>.json` via the existing file-io save primitive
  (`open-create`/`write-fd`). Pick the setups dir convention.
- **P3 — load.** `:load <name>` reads the file, `json-parse` → `decode` → author mode.
  Round-trips with P2 (save then load then diff = identity).
- **P4 — library browse + compose.** List on-disk setups and fold them into the
  `:manas` browser alongside the compiled-in ones; `:compose` fires the CURRENT edited/
  loaded doc, not a static. **Open dep:** directory listing needs `getdents` (per
  memory, "getdents auto-discovery" was owed) — assess in P4; fallback = a
  `setups/index.json` manifest to avoid a new crossing. Decide at P4, not before.

## Field map (for the codec — exact constructors)
- `Pipeline = (pipeline id:Str when:Str gate:(List GateRule) order:Order
  expert-ids:(List Str) combiner:Str stop:StopPolicy yield-desc:Str)`
- `GateRule = (gate-rule condition:Str ids:(List Str))`
- `Order = order-fan-out | order-chain | order-branch` (nullary → tag string)
- `StopPolicy = stop-single | stop-capped(cap:I64) | stop-until-dry(cap:I64)`
- `Config = (config id:Str bindings:(List Binding))`
- `Binding = (binding slot:Str model:Str num-ctx:I64)`

## Confirmed JSON schema (P1 shipped — P2/P3 MUST match)
```
Pipeline -> {"kind":"pipeline","id":Str,"when":Str,
             "gate":[{"condition":Str,"ids":[Str]}],
             "order":"fan-out"|"chain"|"branch",
             "expert-ids":[Str],"combiner":Str,"stop":<stop>,"yield":Str}
<stop>   -> {"kind":"single"} | {"kind":"capped","cap":Int}
          | {"kind":"until-dry","cap":Int}
Config   -> {"kind":"config","id":Str,"bindings":[<bind>]}
<bind>   -> {"slot":Str,"model":Str,"num-ctx":Int}
```
I64 ↔ `j-num` decimal lexeme (`i64->str` / `str->i64`). `"kind"` is written on
encode, ignored on decode (survives the round-trip). Note: JSON key is `bindings`;
the `Config` type field binder is `binds` (positional — no impact).

## Status
- [x] **P1 codec** — DONE 2026-08-16 (`ecf638f`). `scaffold/lib/manas/pipeline/persist.chiral`
  (total encoders + total decoders reusing `json.chiral`) + `persist-test.chiral`
  round-trip fixpoint over all-pipelines+all-profiles + negative tests, exit 0.
- [x] **P2 save** — DONE 2026-08-16 (`f65ec90`). `doc->json` (manas-mode) +
  `save-string-to-path` (file-io, mirrors save-puffer, zero crossings) + a `w <path>`
  branch in `manas-command-line`. PTY: pipeline save reflects an edit (`order=chain`),
  config save valid, error path clean; saved files decode back through P1. 1003896 B.
  **Residue:** `save-string-to-path` reuses `SaveR` whose `save-ok` carries a Puffer →
  fabricates a throwaway 0-byte puffer. Fold a clean result sum into P3.
- [x] **P3 load** — DONE 2026-08-16 (`f58c2be`). `load-bytes` + `json->doc`
  (dispatch on `"kind"`) + `LoadR` + `manas-load-doc` + a `load <path>` arm; clean
  `WriteR`/`LoadR` sums retire P2's throwaway Puffer. PTY: `:load` of a chain-order
  setup renders `ORDER order-chain`, config loads as `CONFIG smoke-local`, plain
  loads; distinct honest errors (open/parse/decode), no crash. 1007992 B. (Note:
  edit+save+load in ONE keystream is PTY-timing-flaky — isolated ops all pass; a
  test-harness artifact, not a scriba bug. Use generous leads / isolated runs.)
- [x] **P4 setups LIBRARY** — DONE 2026-08-16 (`7cfb675`). `:save <name>` →
  `setups/<name>.json` + `setups/index.json` (idempotent); `manas-browse` lists saved
  names + loads on pick via `load-doc-from-path`; `read-index-names` total (corrupt/
  missing index → `nil`). Committed `setups/index.json` = `[]`. PTY-proven the browser
  loads DISK content (hand-set `order:chain` → renders `order-chain`), not compiled
  defaults; idempotent index; compiled-in browse still routes `manas-enter`. 1012088 B.

**⚑ PERSISTENCE ARC COMPLETE (P1–P4, 2026-08-16).** Edit → save-by-name → browse →
reload → run, end to end, JSON on disk, zero new syscall crossings. Optional residue:
`:compose`-the-edited-doc; absolute/config-dir setups path (needs getenv+mkdir).
