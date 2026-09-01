---
element: E131
slug: sse-stream
title: Native SSE streaming (retire the `chat-*` shim): lower `chat-open`/`chat-read`/`chat-close` to native over the socket floor, retiring the Python SSE shim (`@impl("chat-open"/"chat-read"/"chat-close")`, impl_ports.py:357/399/440). `chat-open` sends the request (`stream:true`, `Accept: text/event-stream`) and keeps the live connection in the stream handle; `chat-read` recvs into a buffer, splits `data:` frames, extracts the content delta via `json.chiral` (OpenAI `choices[0].delta.content` AND Ollama `message.content` passthrough), and emits `chunk`/`chunk-done` (`[DONE]`)/`chunk-err` (transport, HTTP status, JSON, mid-stream error frame, or EOF-before-DONE truncation); `chat-close` releases the connection. The `ChatStream`/`ChatChunk` typed face is frozen; the handle must stay live across recvs (one recv does not drain a stream). Zero CPython in the streaming model path
kind: BUILD-PROPER
example: examples/E131-sse-stream.md
status: implemented
updated: 2026-08-14
---

# E131 SPEC: Native SSE streaming (retire the `chat-*` shim)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> reviewed worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the three `chat-*` externs in `http.chiral` (lines
  349-358) are retired from CPython `@impl` shims to native chirality `def`s over
  the E125/E129/E130 socket floor. `ChatStream` stops being a bare `porttype`
  and becomes a single-ctor `data` carrying `(1 sock SockOpt)` + a `Bytes`
  reservoir + a `StreamMode` parse state. `chat-open`/`chat-read`/`chat-close`
  keep their frozen signatures textually identical and their `ChatChunk` shape
  byte-identical; only `extern` becomes `def`. The three `@impl("chat-*")`
  bodies in `impl_ports.py:357/399/440` are deleted. Zero CPython remains in the
  streaming model path.
- **Non-goals:** no new TAL crossings (nothing added to `sys-tal.chiral`,
  `crossing-wraps.chiral`, `target-linux.chiral`, `native.py`, `tal.py`); no
  changes to `backend.chiral` `be-chat-stream` (it drives the frozen face
  unchanged); no read-timeout hardening (that is a separate hardening element,
  deferred from `recv-all`); no retry/backoff logic; no HTTP/2 or
  `transfer-encoding: chunked` decoder beyond what the reservoir already gives
  us (SSE over HTTP/1.1 as the shim does).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E131 postdates the map snapshot; treat as
  BUILD. The row names only OURS shards, no CONFORMS/EXTEND rows, so nothing to
  reconcile. The frozen face is the authority this change must not break.
- **Live code (compose with, do NOT respec):**
  - `ports.chiral`: `(porttype Sock)`; `(data SendR () (send-r (1 s Sock)) (send-err (msg Str)))`;
    `(data RecvR () (recv-r (bs Bytes) (1 sock Sock)) (recv-closed (1 sock Sock)) (recv-err (msg Str)))`;
    `(extern sock-send (=> (1 s Sock) Bytes SendR))`;
    `(extern sock-recv (=> (1 s Sock) (refine I64 (> 0)) RecvR))`;
    `(extern sock-close (=> (1 s Sock) Unit))`.
  - `inet.chiral`: `(declare sock-connect-in (=> Str I64 ConnR))` returning
    `(conn-r (1 s Sock))` / `(conn-err (msg Str))` (E129).
  - `http.chiral` (E130): `(data UrlR () (url-ok (host Str) (port I64) (path Str)) (url-err (msg Str)))`;
    `(def format-request (-> Str Str I64 Str Bytes Bytes))`; `CRLF`/`SP` byte
    consts; `recv-all`'s `(sock-recv s 4096)` recv-loop shape (the read-all
    recursion to mirror); `(def parse-url (-> Str UrlR))`.
  - `json.chiral`: `(data Json () (j-null) (j-bool (b Bool)) (j-num (lexeme Str)) (j-str (s Str)) (j-arr (items (List Json))) (j-obj (fields (List (Pair Str Json)))))`;
    `(def json-parse (-> Bytes (Maybe Json)))`; `(def obj-get (-> Json Str (Maybe Json)))`;
    `(def alist-find (-> (List (Pair Str Json)) Str (Maybe Json)))`; `(def as-str (-> Json (Maybe Str)))`.
  - `backend.chiral:114`: `(def be-chat-stream (=> Backend Str (List Msg) (=> Str Unit) ChatR) ...)`
    calls `chat-open`/`chat-read`/`chat-close` exactly as the frozen face defines
    them; it must compile unchanged.
  - `impl_ports.py:357/399/440`: the three `@impl("chat-open"/"chat-read"/"chat-close")`
    bodies to delete (the shim under retirement).
- **True delta (deliverable minus baseline):**
  - `http.chiral`: `+ (import "json")`; replace `(porttype ChatStream)` with three
    `data` carriers; replace three `extern chat-*` with three `def chat-*` (same
    signatures) plus the pure framing helpers and the process spine.

## 3. Decisions

Every open question from the example §6, dispositioned. The four author-tier
forks are RESOLVED by the author (2026-08-14): preserve the frozen face, mirror
the shim; the mechanical and structurally-forced calls are RESOLVED with citation.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | No-socket arms: connect failure and mid-stream `recv-err` leave no live `Sock`, but the frozen face always returns a closeable handle. `SockOpt` linear-option carrier vs relaxing `chat-open` to a result sum | RESOLVED | Author (2026-08-14): `SockOpt` (`so-live`/`so-dead`). Preserves the frozen `chat-open` return type; the result-sum alternative breaks it and ripples into `backend.chiral` `be-chat-stream`. |
| 2 | Status deferral: non-2xx surfaces on first `chat-read` via `m-failed`, not at open (the shim raised at open; frozen `chat-open` returns only a handle) | RESOLVED | Author (2026-08-14): defer to first `chat-read` via `m-failed`. Matches the shim exactly: `chat-open` catches the HTTPError and returns a handle, the error surfaces as `chunk-err` on the first read. |
| 3 | `(import "json")` into `http.chiral`: the module keeps JSON out today; the delta walk needs `json-parse`. Import vs factoring `j-content`/`j-has-error` into `json.chiral` | RESOLVED | Author (2026-08-14): import `json`, keep the SSE delta walk in `http.chiral` (the OpenAI/Ollama field shape is transport-specific, not general JSON). `json.chiral` imports prelude only, no cycle. |
| 4 | delta-skip blocking: role-only / finish_reason / keepalive frames make `chat-read` loop for the next event within one call; a keepalive burst could block | RESOLVED | Author (2026-08-14): within-call loop, mirrors the shim's readline loop. The keepalive-burst block is theoretical (the shim blocks identically) and is covered by the read-timeout residue in §6, not a face change. |
| 5 | `ChatStream` must gain a constructor (cannot stay a bare `porttype`) | RESOLVED | Structural, not a choice: a `porttype` has no constructor, so no chirality `def` can produce one; the deliverable retires the extern that host-side constructed it. Cited: `chirality-implementation` "Porttype crossing pitfall" + `chirality-conventions` linear-field rule. The data carrier is the only form that keeps the frozen `(1 s ChatStream)` field annotations working. |
| 6 | recv chunk size | RESOLVED | `4096`, mirroring `recv-all`'s `(sock-recv s 4096)`. Cited: `http.chiral:296`. |
| 7 | transport/parse failure status sentinel | RESOLVED | `-1` for non-HTTP failures (recv-err corpse, JSON parse fail, mid-stream error frame, EOF-before-DONE), mirroring `http-request`'s `(http-r -1 ...)` transport mapping. Cited: `http.chiral:320-322,336-337`. Real HTTP status carries through `m-failed`. |
| 8 | EOF-before-`[DONE]` is truncation error | RESOLVED | `recv-closed` before a `[DONE]` frame maps to `chunk-err` (truncation). Cited: example §6 conformance target. |
| 9 | over-read body bytes on the header recv are kept in the reservoir | RESOLVED | `read-head` returns `(head-ok status rest s)` where `rest` is everything past `\r\n\r\n`; first SSE events may ride in with the header recv and one recv does not drain a stream. Cited: example §5 `HeadR` + finding 2. |
| 10 | `ok2xx` boundary | RESOLVED | status in `200..299`. Cited: example §5 "Deliberately omitted" note. Classification is independent of fork 2 (it decides where the status is classified, not where it surfaces). |
| 11 | spine conformance test substrate | RESOLVED | Hermetic minimum uses E126 `(extern socketpair (=> Unit SockPairR))` with `(sp-ok (1 a Sock) (1 b Sock))`; the stronger variant uses `sock-listen`/`sock-accept` for a full `chat-open` end-to-end. Test-harness detail, not an author-tier design fork. |

Forks 1-4 are RESOLVED by the author (2026-08-14) in favor of the example's
picks (`SockOpt`, deferred `m-failed`, the json import, within-call skip loop).
§4 executes as written; §5/§6 are the conformance gate.

## 4. Change plan (ordered, commit-sized)

Every step lands a compile-clean chunk, sized under a 50-call implement budget.
Steps 1-3 are verified with `python3 -m chirality check lib/http.chiral` (line-numbered
oracle) as they land; the B1 blob build is the final authority at Step 5. The
example §5 snippet is the authoritative body source; live-source corrections
already folded in: `RecvR` uses `(bs Bytes)` (not `chunk`), `sock-recv`'s size
arg is `(refine I64 (> 0))`, and `sock-close` returns `Unit`.

### Step 1: data carriers + frozen-face retype
- **Target:** `scaffold/lib/http.chiral`: the streaming section, lines 349-358.
- **Change:** add `(import "json")` beside the existing imports; replace
  `(porttype ChatStream)` with the three carriers; convert the three
  `extern chat-*` to `(declare ...)` forward declares with byte-identical
  signatures (the `def` bodies land in Step 3). `ChatChunk` is untouched.

```chirality
(import "json")   ; json-parse, Json (j-obj/j-str), obj-get, alist-find

; a socket that may already be gone: connect failed, or the peer reset the
; stream mid-flight. the frozen face always hands a closeable handle back, so
; the handle needs a "nothing left to close" arm. a bare (Maybe Sock) is the
; trap (its field is w, rejects the linear Sock), so this is a linear option.
(data SockOpt ()
  (so-live (1 s Sock))
  (so-dead))

; parse state across the header/body boundary of the response.
(data StreamMode ()
  (m-body)                 ; SSE body streaming, healthy
  (m-failed (status I64))) ; terminal: open-time or transport failure, status kept

(data ChatStream ()
  (cs (1 sock SockOpt) (buf Bytes) (mode StreamMode)))

; the frozen face, unchanged signatures, extern -> declare (def bodies in Step 3):
(declare chat-open  (=> Str Str Bytes ChatStream))     ; method url body -> stream
(declare chat-read  (=> (1 s ChatStream) ChatChunk))
(declare chat-close (=> (1 s ChatStream) Unit))
```

- **Size:** S (one file, ~7 forms). Verified with `python3 -m chirality check`.

### Step 2: pure SSE framing helpers
- **Target:** `scaffold/lib/http.chiral`: append to the streaming section.
- **Change:** the pure `->` layer. Bodies are the mechanical `bget`/`bslice`/
  `blen` byte loops the example deliberately omits; signatures are the contract.
  `j-content`/`j-has-error` are one `alist-get`/`obj-get` walk over the
  `j-obj` fields list. `split-line`/`scan-event`/`is-done`/`strip-data` are
  structural recursion over `Bytes` (opaque, index-threaded, no `case` on
  `Bytes`).

```chirality
; one line off the front of the buffer: bytes before the first \n, plus the
; rest. no \n -> (line-none): the recv returned mid-line, need more bytes.
(data LineSplit ()
  (line-ok  (line Bytes) (rest Bytes))
  (line-none))
(declare split-line (-> Bytes LineSplit))

; strip a leading "data:" (with one optional space). none for event:/id:/
; retry:/blank/comment lines.
(declare strip-data (-> Bytes (Maybe Bytes)))

; scan the reservoir for ONE complete SSE event. an event ends at a blank line;
; its payload is its "data:" lines joined by \n. comment/keepalive (":") lines
; are skipped inside the scan. (fs-need) = the event is still incomplete.
(data FrameScan ()
  (fs-event (payload Bytes) (rest Bytes))
  (fs-need))
(declare scan-event (-> Bytes FrameScan))

; payload classification: [DONE] vs a content delta vs skip vs error.
(data FrameKind ()
  (fk-done)
  (fk-data (delta Str))
  (fk-skip)                 ; keepalive / role-only / finish_reason frame
  (fk-err  (status I64)))   ; JSON parse fail / mid-stream error frame

(declare is-done (-> Bytes Bool))   ; payload == "[DONE]"

; delta extraction result: the four ways a parsed frame classifies.
(data DeltaR ()
  (delta-ok   (delta Str))
  (delta-skip)               ; parsed, no content field this frame
  (delta-error)              ; parsed, top-level "error" field present
  (delta-bad))               ; json-parse returned none

(declare j-has-error (-> Json Bool))     ; top-level "error" field present
(declare j-content (-> Json (Maybe Str))) ; choices[0].delta.content OR message.content

(def json-delta (-> Bytes DeltaR)
  (lam (payload)
    (case (json-parse payload)
      (none (delta-bad))
      ((some j)
        (case (j-has-error j)
          (true (delta-error))
          (false (case (j-content j)
            ((some d) (delta-ok d))
            (none (delta-skip)))))))))

(def classify-payload (-> Bytes FrameKind)
  (lam (payload)
    (case (is-done payload)
      (true (fk-done))
      (false (case (json-delta payload)
        ((delta-ok d)  (fk-data d))
        ((delta-skip)  (fk-skip))
        ((delta-error) (fk-err -1))     ; mid-stream {"error":...}
        ((delta-bad)   (fk-err -1))))))) ; JSON parse fail
```

- **Size:** M (one file, ~4 data types + ~10 pure defs). Verified with
  `python3 -m chirality check`.

### Step 3: process spine defs
- **Target:** `scaffold/lib/http.chiral`: the streaming section; drop the
  Step-1 `(declare chat-open/chat-read/chat-close)` inline types and replace
  them with `(def ...)` bodies (declare+def rule: a `def` after a prior
  `declare` carries NO inline type). `read-event`/`read-head`/`open-stream`/
  `format-sse-request`/`ok2xx` are new and carry inline types.
- **Change:** the `=>` spine, mirroring `recv-all`'s recursion-over-recv-result
  shape. `read-event` is the recv/reservoir/scan loop; `chat-read` is the
  frozen-face boundary that unwraps the `SockOpt` and re-wraps the `ChatStream`;
  `chat-close` discharges the cap; `read-head` reads to `\r\n\r\n` and keeps the
  over-read tail; `open-stream` is `http-request-on`'s shape but stops after the
  head. `mode` and `buf` are `w` fields (safe to reuse after `case`); the `sock`
  field is the only `(1 ...)` field and must be rebuilt with its constructor in
  every nullary-call path.

```chirality
; one pull of the stream: scan the reservoir for a complete event; if none,
; recv more and retry (the read-all pattern: recursion over the recv result
; stream, not a structural argument).
(data EventOut ()
  (ev-chunk (delta Str)  (1 sock SockOpt) (buf Bytes))
  (ev-done               (1 sock SockOpt) (buf Bytes))
  (ev-err   (status I64) (1 sock SockOpt) (buf Bytes)))

(def read-event (=> (1 s Sock) Bytes EventOut)
  (lam (s buf)
    (case (scan-event buf)
      ((fs-event payload rest)
        (case (classify-payload payload)
          ((fk-done)    (ev-done (so-live s) rest))
          ((fk-data d)  (ev-chunk d (so-live s) rest))
          ((fk-skip)    (read-event s rest))
          ((fk-err stt) (ev-err stt (so-live s) rest))))
      ((fs-need)
        (case (sock-recv s 4096)
          ((recv-r bs s2)   (read-event s2 (bcat buf bs)))
          ((recv-closed s2) (ev-err -1 (so-live s2) buf)) ; EOF before [DONE]
          ((recv-err m)     (ev-err -1 so-dead buf)))))))  ; corpse: no sock

(def chat-read
  (lam (st)
    (case st
      ((cs sock buf mode)
        (case mode
          ((m-failed stt) (chunk-err stt (cs sock buf mode)))
          ((m-body)
            (case sock
              ((so-live s)
                (case (read-event s buf)
                  ((ev-chunk d sock2 buf2) (chunk d (cs sock2 buf2 mode)))
                  ((ev-done sock2 buf2)     (chunk-done (cs sock2 buf2 mode)))
                  ((ev-err stt sock2 buf2)  (chunk-err stt (cs sock2 buf2 mode)))))
              ((so-dead) (chunk-err -1 (cs so-dead buf mode))))))))))

(def chat-close
  (lam (st)
    (case st
      ((cs sock buf mode)
        (case sock
          ((so-live s) (sock-close s))
          ((so-dead) unit))))))

; read the response head (status line + headers) until the \r\n\r\n separator,
; handing back any over-read body bytes as `rest` -- the first SSE events may
; ride in with the header recv, and the reservoir must keep them.
(data HeadR ()
  (head-ok (status I64) (rest Bytes) (1 s Sock))
  (head-err (msg Str)))   ; transport died mid-head: no sock

(declare read-head (=> (1 s Sock) Bytes HeadR))
(declare format-sse-request (-> Str Str I64 Str Bytes Bytes)) ; format-request + stream:true + Accept: text/event-stream
(declare ok2xx (-> I64 Bool))

; open-stream mirrors http-request-on's shape, but stops after the head: the
; body is streamed, not drained. non-2xx is recorded in the mode and surfaces
; on the first chat-read as chunk-err (frozen chat-open returns only a handle).
(def open-stream (=> (1 s Sock) Str Str I64 Str Bytes ChatStream)
  (lam (s method host port path body)
    (case (sock-send s (format-sse-request method host port path body))
      ((send-r s2)
        (case (read-head s2 (str->bytes ""))
          ((head-ok status rest s3)
            (case (ok2xx status)
              (true  (cs (so-live s3) rest (m-body)))
              (false (cs (so-live s3) rest (m-failed status)))))
          ((head-err m) (cs so-dead (str->bytes "") (m-failed -1)))))
      ((send-err m) (cs so-dead (str->bytes "") (m-failed -1))))))

(def chat-open
  (lam (method url body)
    (case (parse-url url)
      ((url-ok host port path)
        (case (sock-connect-in host port)
          ((conn-r s) (open-stream s method host port path body))
          ((conn-err m) (cs so-dead (str->bytes "") (m-failed -1)))))
      ((url-err m) (cs so-dead (str->bytes "") (m-failed -1))))))
```

- **Size:** L (one file, ~4 data types + ~8 effectful defs; the effectful
  recursion is the B1-sensitive half).

### Step 4: retire the CPython shim
- **Target:** `scaffold/chirality/impl_ports.py`: delete the three `@impl("chat-open"/"chat-read"/"chat-close")`
  bodies at 357/399/440. No migration; the defs in http.chiral replace them.
- **Change:** remove the urllib readline loop + Python `json` extraction. Grep
  `scaffold/tests/` for `chat-open`/`chat-read`/`chat-close` references and
  update any baseline that asserted the shim's existence (expected: `test_http.py`,
  `test_backend_stream.py`: the advisory Python floor, non-gating).
- **Size:** S. No golden-list change (no crossing added; `crossing_sigs` and
  `sys-bindings` are untouched).

### Step 5: native build + conformance gates
- **Target:** `chirality/` sync + `scaffold/samples/` gate binaries.
- **Change:** copy `http.chiral` to `chirality/scaffold/lib/`, `./build.sh`,
  copy `bin/chirality-bin.new` back as `scaffold/build/B1`; add the two native gate
  programs from §5 under `scaffold/samples/`; run `chirality test`.
- **Size:** M (build + two sample programs + gate run).

## 5. Conformance gate

- **Golden behavior:** reproduce the shim exactly, per the example §6 target.
  `[DONE]` payload → `chunk-done`; OpenAI `choices[0].delta.content` and Ollama
  `message.content` both yield the same delta string; a mid-stream
  `{"error":...}` frame and a JSON parse failure → `chunk-err`; EOF before
  `[DONE]` → `chunk-err` (truncation); non-2xx status → `chunk-err` on the first
  `chat-read` (not at open). `backend.chiral` `be-chat-stream` drives the loop
  unchanged.

- **Tests to add (three gates, all native):**
  1. **Frozen-face type-check (B1 authority):** `http.chiral` + `backend.chiral`
     build through B1 with the three `chat-*` signatures byte-identical to the
     retired externs and `ChatChunk`'s three ctors unchanged. Proven by the
     Step-5 `./build.sh` fixpoint/`built:` output plus a minimal
     `compile-main` blob that imports `http` and calls `chat-close (chat-open
     "POST" url body)`.
  2. **Pure framing golden (hermetic, deterministic, no socket):** a native
     `compile-main` under `scaffold/samples/` that drives `scan-event` →
     `classify-payload` over hardcoded `Bytes` and asserts the seven cases:
     `"data: hello\n\n"` → `fk-data "hello"`; `"data: a\ndata: b\n\n"` →
     `fk-data "a\nb"` (multi-line join); `": keepalive\n\n"` → `fk-skip`;
     `"data: {\"choices\":[{\"delta\":{\"role\":\"assistant\"}}]}\n\n"` → `fk-skip`
     (role-only); `"data: [DONE]\n\n"` → `fk-done`;
     `"data: {\"error\":{\"message\":\"boom\"}}\n\n"` → `fk-err`; `"data: not-json\n\n"`
     → `fk-err`. Exit `0` iff all hold, `1` on any mismatch.
  3. **Spine integration (hermetic socketpair-fed chat-read loop):** a native
     `compile-main` using E126 `(socketpair unit)` → `(sp-ok a b)`; write a
     canned SSE response into `a` via `sock-send` then `sock-close a`; wrap `b`
     as `(cs (so-live b) (str->bytes "") (m-body))`; loop `chat-read` collecting
     deltas; assert the sequence `chunk "hello"` → `chunk "world"` →
     `chunk-done` and that `chat-close` on the done handle is legal (and on a
     `(cs so-dead ...)` handle too). Exit `0` iff the sequence holds, `2` on
     mismatch. This exercises `read-event`'s recv/reservoir/scan loop over a
     real socket crossing with no network. Stronger variant (if the implement
     budget allows): `sock-listen` on 127.0.0.1 + `sock-accept` in a forked
     child feeding the canned response, parent `chat-open`s to it and reads to
     `chunk-done`: exercises the full connect → send → read-head → stream path.

- **Green line:** 709 test functions (77 files) → the two native gate samples
  land in the native test-runner walk; `chirality test` native+rocq PASS (python
  advisory may drift red on the deleted-shim baselines, non-gating). Ledger-lint
  clean.

- **Done when:** the B1 build passes with the frozen face intact, both native
  gate binaries exit `0` on their canned streams, and no `@impl("chat-*")`
  reference remains in `impl_ports.py`.

## 6. Residue & links

- **Deliberately unbuilt:** read-timeout hardening on `read-event`/`recv-all`
  (a hostile peer that never FINs and never sends a blank line would make the
  within-call skip loop diverge: same hardening element as `recv-all`, not
  E131's job); HTTP/2 and `transfer-encoding: chunked` decoding (the shim was
  HTTP/1.1 only); retry/backoff; a third provider's delta field shape (one more
  arm in `j-content`).
- **Follow-on:** the retired shim closes the last CPython holdout in the
  streaming model path; `be-chat-stream` becomes fully native end to end.
- **Related:** [[E131-sse-stream]] · [[E130]] `http-request` (native def over
  sockets) · [[E129]] `sock-connect-in` · [[E126]] `socketpair` · [[E125]]
  `sock-send`/`sock-recv` · [[E107]] `sock-close`.
