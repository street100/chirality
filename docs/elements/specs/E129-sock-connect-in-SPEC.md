---
element: E129
slug: sock-connect-in
title: Native `sock-connect-in` (AF_INET TCP connect): the mesh/Tailscale client crossing that lets `http.chiral` reach a local model endpoint with zero TLS — lower `sock-connect-in : (=> Str I64 ConnR)` (dotted-quad host, port) to native: a fused TAL body doing `socket(AF_INET=2, SOCK_STREAM=1, 0)` (nr 41, reuse `nb-sys-socket`) then `connect(fd, sockaddr_in, 16)` (nr 42, reuse `nb-sys-connect`), packing a 16-byte `sockaddr_in` (family u16 = 2, port u16 network-order, 4-byte addr) as a pure chirality surface function `pack-sa-in` (`parse-quad` → pack, no I/O — the big-endian port is the one ABI trap). Decode the return → `conn-err` (close fd, E107) / `conn-r Sock`, assemble `ConnR` via `ti-cona` (the `nb-sock-connect-t` precedent). WireGuard/Tailscale is the transport crypto, so no TLS in the chirality path. crossing-wraps row + `nb-sock-connect-in-t` in `sys-lib`. **Scope: client connect only**; host is a dotted-quad IP (DNS resolution, AF_INET6, and server bind/listen/accept deferred)
kind: BUILD-PROPER
example: examples/E129-sock-connect-in.md
status: audited
updated: 2026-08-13
---

# E129 SPEC — Native `sock-connect-in` (AF_INET TCP connect)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the socket floor stops being AF_UNIX-only. A new pure
  surface file `scaffold/lib/inet.chiral` holds `parse-quad`, `pack-sa-in`, and
  the `sock-connect-in` wrapper; `ports.chiral` gains the raw crossing extern
  `nb-sock-connect-in (=> Bytes ConnR)`; `sys-tal.chiral` gains the fused
  `nb-sock-connect-in-t` TAL body (registered in `sys-lib`) that does
  `socket(2,1,0)` then `connect(fd, sa, 16)` on a pre-packed sockaddr_in;
  `crossing-wraps.chiral` routes the extern. A chirality program can then call
  `(sock-connect-in "100.64.0.5" 11434)` and get `(conn-r s)` with a live
  AF_INET Sock, or `(conn-err msg)` with the fd already closed, reaching a
  local model endpoint over the mesh with zero TLS.
- **Non-goals:** DNS/getaddrinfo (host is a dotted-quad IP only); AF_INET6
  (family 10, 28-byte packer); server bind/listen/accept; the `http.chiral`
  A3 step-2 rewrite that consumes this crossing; errno-to-Str numeric render
  (see §3 #2). No new syscall numbers: 41/42/3 already registered in
  `target-linux.chiral`.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the map carries no E129 row (it postdates the
  snapshot). The catalog row says "Not built" and names the OURS shards to
  compose. Treat as BUILD over the existing socket floor.
- **Live code (composed, not re-specced):**
  - `sys-tal.chiral`: `nb-sys-socket-t` (nr 41, :842), `nb-sys-connect-t`
    (nr 42, :850), `nb-sys-close-t` (nr 3, :200), and the precedent
    `nb-sock-connect-t` (:887) whose two-level `ti-tcase`/`ti-cona` sum
    assembly and close-on-error shape this body mirrors. `nb-sa-un-pack-t`
    (:869) is AF_UNIX-only and NOT reused.
  - `ports.chiral`: `Sock` porttype (:12); `ConnR` = `(conn-r (1 s Sock)) |
    (conn-err (msg Str))` (:43-45); `sock-connect` extern (:82).
  - `crossing-wraps.chiral`: the extern→crossing routing table; the adjacent
    row `sock-connect` → `nb-sock-connect` sits at :39.
  - prelude Bytes API: `pack-u16` (little-endian), `bslice`, `bcat`,
    `brepeat`, `str->bytes`, `blen`, `bget`.
- **True delta:** a pure `->` sockaddr_in packer with a big-endian port split,
  a dotted-quad parser, the `sock-connect-in` wrapper, one new extern, one
  crossing-wraps row, and one fused TAL body taking pre-packed Bytes. Nothing
  else on the socket floor changes.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 0 | sockaddr_in packing is pure chirality surface `pack-sa-in`, NOT a TAL byte-builder; the only TAL body is the thin `nb-sock-connect-in-t` taking pre-packed Bytes | RESOLVED | Author's explicit resolution of the prior audit FLAG (chirality-conventions, "Resolved-FLAG residue", 2026-08-12). Do not re-open. |
| 1 | Where `parse-quad`/`pack-sa-in`/`sock-connect-in` live | RESOLVED | Pure `->` surface (`Quad`, `QuadR`, `parse-quad`, `pack-sa-in`) plus the effectful `sock-connect-in` wrapper land in a NEW `scaffold/lib/inet.chiral` (imports prelude + ports). The raw extern `nb-sock-connect-in` lands in `ports.chiral` with the other socket externs. Rationale: pure `->` surface must stay off the membrane (never `sys-tal.chiral`), and `ports.chiral` is extern/porttype-only (verified: zero `def`s in its outline), so the pure defs get their own home. Refines example §6 "Lands in", which bundled everything into ports.chiral. |
| 2 | `conn-err` carries a formatted `Str` vs grows an errno field `(conn-err (errno I64))` | RESOLVED | Keep `conn-err (msg Str)`, empty Str on error, mirroring E127. Author's call (2026-08-13): the errno field is ergonomics, not load-bearing — growing it changes the SHARED `ConnR` type (ports.chiral:43) and ripples to E127's built `nb-sock-connect-t`. The errno-field upgrade is a deferred follow-on. |
| 3 | `sock-connect-in` shares the `ConnR` decode with `sock-connect` (E127) vs its own errno mapping (ECONNREFUSED vs ENOENT) | RESOLVED | Share the decode: E129 reuses `ConnR` as-is, same `conn-r`=0 / `conn-err`=1 tags, same `ti-cona` assembly as `nb-sock-connect-t` (ports.chiral:43-49 "numeric render deferred"; examples/E127-sock-connect.md). The ECONNREFUSED-vs-ENOENT distinction is exactly what the §3 #2 errno field would carry; the errno field is deferred (§3 #2 RESOLVED), so both E127 and E129 report a bare empty-Str `conn-err`. |
| 4 | Exact surface shape: `sock-connect-in : (=> Str I64 ConnR)` vs raw `(=> Bytes ConnR)` crossing + pure wrapper | RESOLVED | Raw crossing + pure wrapper. The ONLY crossing is `nb-sock-connect-in : (=> Bytes ConnR)` (takes the pre-packed 16-byte sockaddr_in; socket+connect+decode). The public `sock-connect-in : (=> Str I64 ConnR)` is a pure-surface `def` composing `parse-quad` → `pack-sa-in` → `nb-sock-connect-in`. crossing-wraps row: `(pair "nb-sock-connect-in" "nb-sock-connect-in")` (extern name == ti-fn name). sys-lib entry: `nb-sock-connect-in-t` (TIFn, `ti-fn "nb-sock-connect-in"`). Cite example §5 wrapper spine + the thin-TAL-body resolution (#0). |

No NEEDS-AUTHOR remains: #2 is RESOLVED (empty Str, errno deferred). The change plan proceeds; the errno-field upgrade is a flagged follow-on.

## 4. Change plan (ordered, commit-sized)

### Step 1 — pure AF_INET surface (new file)
- **Target:** `scaffold/lib/inet.chiral` (new) — `Quad`, `QuadR`, `parse-quad`,
  `byte`, `pack-sa-in`, `sock-connect-in`
- **Change:** `(import "prelude")` + `(import "ports")`. Add `(data Quad ()
  (quad (a I64) (b I64) (c I64) (d I64)))` and `(data QuadR () (quad-ok (q
  Quad)) (quad-err (msg Str)))`. `parse-quad : (-> Str QuadR)` splits
  `(str->bytes s)` on '.' (46), four octets each 0-255; empty / non-numeric /
  out-of-range / wrong count → `(quad-err "...")`. `byte` and `pack-sa-in` are
  copied verbatim from example §5: family `(pack-u16 2)` (host order), port
  split high-byte-first `(byte (/ port 256)) (byte (% port 256))` (network
  order, the ABI trap), addr four octets, eight zero bytes. `(declare
  sock-connect-in (=> Str I64 ConnR))` + `(def sock-connect-in (lam (host port)
  (case (parse-quad host) ((quad-err msg) (conn-err msg)) ((quad-ok q)
  (nb-sock-connect-in (pack-sa-in q port))))))`. No externs, no TAL, all pure.
- **Size:** M (~60 lines, new file)

### Step 2 — raw crossing extern
- **Target:** `scaffold/lib/ports.chiral` — insert after the `sock-connect`
  extern (:82)
- **Change:** `(extern nb-sock-connect-in (=> Bytes ConnR))`. Bare types, no
  named params (the B1 `load: unknown name` trap). Comment: takes the packed
  16-byte sockaddr_in, returns the connected Sock cap or conn-err.
- **Size:** S

### Step 3 — crossing-wraps row
- **Target:** `scaffold/lib/crossing-wraps.chiral` — insert after the
  `sock-connect` row (:39)
- **Change:** `(cons (pair "nb-sock-connect-in" "nb-sock-connect-in") ...)`
  and +1 close paren on the `nil)))...` tail. Extern name == ti-fn name.
- **Size:** S

### Step 4 — fused TAL body + sys-lib entry
- **Target:** `scaffold/lib/sys-tal.chiral` — new `nb-sock-connect-in-t` TIFn
  (after `nb-sock-connect-t`, :921) + `sys-lib` entry (after
  `nb-sock-connect-t`, :1074)
- **Change:** `(def nb-sock-connect-in-t TIFn (ti-fn "nb-sock-connect-in" 1 N
  ...))`. Mirror `nb-sock-connect-t` exactly, three diffs: (1) reg0 is the
  already-packed sockaddr_in, so drop the `ti-call "nb-sa-un-pack"` and
  `ti-call "nb-sa-un-len"` steps; (2) socket args are `(2, 1, 0)` (AF_INET,
  SOCK_STREAM, 0) not `(1, 1, 0)`; (3) `ti-bptr` reg0 directly and pass
  addrlen constant 16 (not computed). Shape: `ti-call "nb-sys-socket"` → fd;
  fd<0 → `(conn-err "")` empty Str; else `ti-bptr` sa, `ti-call
  "nb-sys-connect" (fd sa 16)`; connect<0 → `ti-call "nb-sys-close"` fd then
  `(conn-err "")`; else `ti-cona` tag0 `(conn-r fd)` (fd word IS a Sock,
  E123). Add `(cons nb-sock-connect-in-t ...)` to `sys-lib`; +1 close paren on
  the chain tail. Use `ti-call` delegation only, no raw `ti-sys`, no new E76
  row. Verify with `bin/paren-audit.py` and the sexp reader; never hand-count.
- **Size:** L (deep TAL; one TIFn, mirror of a verified body)

### Step 5 — tests + golden fixtures
- **Target:** `scaffold/tests/` — new tests; `test_eff_lower_chirality.py`,
  `test_sig_derive_chirality.py`, `test_effectful_lowering.py`,
  `test_process_externs.py` — extend the bound-crossing fixture sets
- **Change:** add the §5 named tests; extend the golden crossing-set fixtures
  with `nb-sock-connect-in` per the crossing checklist.
- **Size:** M

## 5. Conformance gate

- **Golden behavior:**
  - `(sock-connect-in "100.64.0.5" 11434)` returns `(conn-r s)` with a live
    connection; oracle is CPython `socket.socket(AF_INET,
    SOCK_STREAM).connect(("100.64.0.5", 11434))` reachability.
  - A refused port returns `(conn-err msg)` with the fd already closed: no fd
    leak, no uncaught exception, `(conn-err "")` empty Str (per §3 #2 RESOLVED).
  - `pack-sa-in` byte layout: offset 0..1 = `[02 00]` (family 2 host order);
    offset 2..3 = `[hi lo]` big-endian port (e.g. port 80 → `[00 50]`);
    offset 4..7 = the four octets; offset 8..15 = zero. The little-endian port
    is the one failure this must not produce (E109 `bput-u16-le` trap).
- **Tests to add:**
  - `test_sock_connect_in_pack` (confirming): pack-sa-in byte layout, big-endian
    port, zero pad.
  - `test_sock_connect_in_parse` (confirming): parse-quad happy path and each
    error arm (empty field, non-numeric, out-of-range, wrong count).
  - `test_sock_connect_in_conn` (confirming): connect to a loopback listener →
    `(conn-r s)`.
  - `test_sock_connect_in_refused` (adversarial): connect to a closed port →
    `(conn-err ...)`, fd closed, no leak.
- **Green line:** 709 test functions → ≥ 713 (4 new); `chirality test-native` green;
  ledger-lint clean; fixpoint holds after `chirality/build.sh` (B1 == B2).
- **Done when:** B1 compiles `inet.chiral` + the new TAL body, `chirality test-native`
  passes with the four new tests green, and a sample program returns `(conn-r
  s)` against a live `100.64.0.5` endpoint and `(conn-err ...)` on a refused
  port.

## 6. Residue & links

- **Deliberately unbuilt:** DNS/getaddrinfo (dotted-quad only); AF_INET6
  (family 10, 28-byte packer); server bind/listen/accept; the `http.chiral` A3
  step-2 rewrite that consumes `sock-connect-in`; errno-to-Str numeric render
  (deferred, tied to §3 #2 RESOLVED).
- **Follow-on:** the `http.chiral` plain-HTTP-over-mesh path reaching a local
  model endpoint with zero TLS (this crossing is its client half).
- **Related:** [[E127-sock-connect]] (AF_UNIX precedent), [[E125-sock-use]]
  (send/recv), [[E126-socketpair]], [[E123-native-porttype-carrier]] (Sock
  lowers to one word), [[E124-adopt-fd]]; E107 (sock-close on the conn-err
  path), E109 (the bput-u16-le little-endian trap, no example file).
