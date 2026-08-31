---
element: E130
slug: http-native
title: Native HTTP/1.1 client (transport swap): rewrite `http.chiral` over the native socket caps, retiring the Python `http-request` urllib shim (`@impl("http-request")`, impl_ports.py:343). `http-request : (=> Str Str Bytes HttpR)` (method, url, body) becomes a chirality `def`: parse the URL into host/port/path (`http://host:port/path`, dotted-quad host), `sock-connect-in` (E129) to the host, format an HTTP/1.1 request (request line `METHOD path HTTP/1.1` + `Host:` + `Content-Type: application/json` + `Content-Length:` + CRLF CRLF + body) into Bytes, `sock-send` it, `sock-recv`-loop the response, parse the status line + headers, read the body by `Content-Length`. `HttpR`/`http-status`/`http-body` unchanged (typed face is frozen — E51 "transport swap is not a reshape"); `backend.chiral` needs no change (its seam is already `base : Str`). **Scope: non-streaming request/response**; the streaming `chat-open`/`chat-read`/`chat-close` (SSE, Transfer-Encoding: chunked) is the follow-on E131. Zero CPython in the model path (the whole point of §4.6)
kind: BUILD-PROPER
example: examples/E130-http-native.md
status: audited
updated: 2026-08-13
---

# E130 SPEC: Native HTTP/1.1 client (transport swap)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/http.chiral` ships a chirality-native
  non-streaming HTTP/1.1 client. `http-request` stops being a CPython urllib
  extern and becomes a `def` over the four native socket caps
  (`sock-connect-in`, `sock-send`, `sock-recv`, `sock-close`). The typed face
  is unchanged, so `backend.chiral` and everything above it keep working with
  zero edits, and the `@impl("http-request")` shim in `impl_ports.py` becomes
  dead code.
- **Non-goals:** the streaming SSE half (`chat-open`/`chat-read`/`chat-close`,
  `Transfer-Encoding: chunked`) stays a Python-riding extern; TLS (`https`),
  DNS resolution, redirect-following, and gzip decompression are not built; no
  compiler change, no fixpoint, no new crossings, no new TAL surface.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E130 postdates the map snapshot, so this
  element is treated as BUILD. Live source is the authority, not the map.
- **Live code this composes with (already built, not respec'd):**
  - `ports.chiral:12-98` — `Sock`, `ConnR` (`conn-r`/`conn-err`), `SendR`
    (`send-r`/`send-err`), `RecvR` (`recv-r`/`recv-closed`/`recv-err`), and the
    `sock-send`/`sock-recv`/`sock-close` externs.
  - `inet.chiral:33-114` — `sock-connect-in : (=> Str I64 ConnR)` plus the pure
    `parse-quad`/`pack-sa-in`/`byte` helpers (E129).
  - `http.chiral:17-27` — the frozen `HttpR`/`http-status`/`http-body` face and
    the `(extern http-request (=> Str Str Bytes HttpR))` being retired.
  - `json.chiral` — `json-parse`/`json-show` (kept, untouched; `backend.chiral`
    parses the returned body).
  - `backend.chiral` — `be-chat`/`be-health`/`be-models`/`be-embed`/`be-search`;
    its seam is `base : Str`, so the swap lands entirely below it.
- **True delta:** delete the extern and its shim; add three pure `->` parsers
  (`parse-url`, `format-request`, `parse-response`) and two effectful `=>`
  functions (`recv-all`, `http-request`) whose effect row is exactly the four
  socket caps. No new crossings, no compiler rebuild.

## 3. Decisions

Already resolved (from the task docket; not re-opened):

- Typed face frozen (E51): `HttpR`, the `http-request` signature, and
  `http-status`/`http-body` are unchanged. `backend.chiral` and everything above
  it stay untouched. This is a transport swap, not a reshape.
- Scope is non-streaming request/response only. `chat-open`/`chat-read`/
  `chat-close` (SSE, chunked) is DEFERRED to E131. The `chat-*` externs and
  the `ChatStream` porttype stay as-is, still Python-riding.
- `Connection: close` is sent, so the response read collapses to "read until
  peer FIN" (RFC 7230 §6.3), sidestepping keep-alive framing.

The three open questions from the example §6, dispositioned:

| # | Question | Disposition | Rationale |
|---|----------|-------------|-----------|
| 1 | Transport-error mapping | RESOLVED | Source: `@impl("http-request")` at `impl_ports.py:343-377`. The shim returns `("con","http-r",[resp.status, resp.read()])` on success, `[e.code, e.read()]` on `HTTPError`, and `("con","http-r",[-1, str(e).encode("utf-8","replace")])` on transport failure (`OSError`/`HTTPException`). So the native `def` maps every failure arm to `(http-r -1 (str->bytes msg))`: `url-err`, `conn-err`, `send-err`, `recv-err`, `parse-err` all return status **-1** (the example's `0` was wrong). `ok2xx` (`backend.chiral:29`) is false for -1, so the failure flows to the circuit breaker exactly like a 5xx. A server 4xx/5xx arrives as the actual status code in the status line and passes through positive, matching the oracle's `HTTPError` arm. Body on failure is the crossing's message as UTF-8 bytes (shape-equal to `str(e)`; the exact string differs, which is fine, the -1 status is the conformance-critical fact). |
| 2 | `recv-all` non-termination | RESOLVED (bound now) + DEFERRED (timeout) | Add a `MAX-BODY` ceiling now (64 MiB constant, name it and make it tunable) inside `recv-all`: on `recv-r`, if `(blen acc) + (blen chunk)` exceeds the ceiling, `sock-close` the live cap and return `read-all-err`. Pure, no new crossings, turns a hostile-peer divergence into a value. The read-timeout half is DEFERRED to a hardening element: a true deadline needs a `poll2`/`nb-poll` loop with a timer, which changes timing semantics and must be verified against the oracle's 300s `urlopen` ceiling. |
| 3 | Case-insensitive header match + CRLF | RESOLVED | (a) Match: define a pure `lc` fold (65..90 -> +32); `parse-response` compares header-name bytes case-folded against the lowercase literal `content-length`. (b) CRLF: chirality `Str` literals do NOT escape `\r`. The escape set is `\n \t \" \\` and any other `\X` decodes to the literal byte X (`sexp.chiral:178-186`, mirrored by `sexp.py`), so `"\r"` yields the byte `r`, not 13. The request is therefore assembled as `Bytes` via `bcat`, with `CRLF = (bcat (byte 13) (byte 10))` (`byte` is inet's, already in scope). `format-request` uses `bcat` of `str->bytes` pieces + `CRLF` constants, never `str-cat` with `\r\n`. |

Extra, decidable from source, folded into the plan: the example's `i64->dec`
helper is dropped. prelude already provides `i64->str` (extern, used in ~20
places; renders non-negative I64 as unsigned decimal digits), which is exactly
what `Content-Length` and the `Host` port need.

NEEDS-AUTHOR: none. All three open questions are decidable from live source or
the settled design; nothing here requires an author call.

## 4. Change plan (ordered, commit-sized)

All steps edit `scaffold/lib/http.chiral` only. Steps 1-3 are additive pure
surface and leave the extern alive; step 4 is the single swap that retires it.
Each step stays paren-balanced and B1-clean on its own.

### Step 1 — imports + pure URL boundary
- **Target:** `scaffold/lib/http.chiral` — header imports, `UrlR`, `parse-url`.
- **Change:** add `(import "ports")` and `(import "inet")` beside the existing
  `(import "prelude")`. Add `(data UrlR () (url-ok (host Str) (port I64)
  (path Str)) (url-err (msg Str)))`. Add `(declare parse-url (-> Str UrlR))`
  + `(def parse-url (lam (url) ...))`. Body (byte-walk):
  - `(let ((b (str->bytes url)) (n (blen b))) ...)`.
  - Scheme check: the first 7 bytes must be `http://` (104 116 116 112 58 47
    47), else `(url-err "bad scheme")`.
  - Find path start: scan from index 7 for the first `/` (47). If none, path is
    `"/"` and path-start is `n`; else path is `(bytes->str (bslice b
    path-start n))`.
  - `hostport = (bslice b 7 path-start)`. Find `:` (58) in it; none ->
    `(url-err "missing port")`. `host = bytes->str (bslice hostport 0 colon)`,
    `portstr = bslice hostport (+ colon 1) (blen hostport)`.
  - Validate host by reusing `parse-quad` (inet, in scope): `quad-err` ->
    `(url-err msg)`; `quad-ok` -> continue. `sock-connect-in` re-parses the
    quad internally, which is fine; the boundary check gives a clean `url-err`.
  - Parse `portstr` as decimal digits with a bounded fold, mirroring inet's
    `pq-go` (`inet.chiral:57-97`): `acc = acc*10 + (b-48)` for each byte in
    48..57; empty, non-digit, or acc > 65535 -> `(url-err "bad port")`.
  - Return `(url-ok host port path)`.
- **Size:** M.

### Step 2 — request framing
- **Target:** `scaffold/lib/http.chiral` — `CRLF`, `SP`, `format-request`.
- **Change:** define `CRLF = (bcat (byte 13) (byte 10))` and `SP = (byte 32)`,
  reusing inet's `byte` (do NOT redefine it). Add `(declare format-request (->
  Str Str I64 Str Bytes Bytes))` + `(def format-request (lam (method host port
  path body) ...))`. Body: a `bcat` chain of `str->bytes` pieces + `CRLF`/`SP`
  constants, with `i64->str` for the port and `Content-Length` (no `i64->dec`,
  no `\r\n` escapes):
  `method SP path " HTTP/1.1" CRLF "Host: " host ":" (i64->str port) CRLF
  "Content-Type: application/json" CRLF "Content-Length: " (i64->str (blen
  body)) CRLF "Connection: close" CRLF CRLF`, then append the raw `body` with a
  final `bcat`.
- **Size:** S.

### Step 3 — response parsing
- **Target:** `scaffold/lib/http.chiral` — `lc`, `ParseR`, `parse-response`.
- **Change:** define `lc (-> I64 I64)` = `c+32` when 65..90, else `c`. Add
  `(data ParseR () (parse-ok (status I64) (body Bytes)) (parse-err (msg
  Str)))`. Add `(declare parse-response (-> Bytes ParseR))` + `(def
  parse-response (lam (buf) ...))`. Body (byte-walk):
  - Hunt for the header terminator `CRLF CRLF` (13 10 13 10). Absent ->
    `(parse-err "truncated headers")`.
  - Status line = bytes before the first CRLF of the header block. Find the
    first SP (32); fold the next 3 bytes as decimal digits (48..57) -> status;
    any non-digit -> `(parse-err "bad status line")`.
  - Header region = between the status-line CRLF and the terminator. Walk it
    line by line (each line ends at CRLF); at each line start, find `:` (58);
    case-fold-compare the name bytes `[line-start, colon)` against the
    lowercase literal `content-length`. On match, skip OWS after `:`, fold the
    decimal digits until CRLF -> content-length.
  - Body: if `Content-Length` was found, `(bslice buf (+ term 4) (+ term 4
    clen))` (clamp to the available tail); else the whole tail after the
    terminator (we sent `Connection: close`, body-to-EOF). Return `(parse-ok
    status body)`.
- **Size:** M.

### Step 4 — effectful spine + extern swap
- **Target:** `scaffold/lib/http.chiral` — retire `(extern http-request ...)`
  (line 22), add `ReadAllR`, `MAX-BODY`, `recv-all`, `http-request`.
- **Change:** delete the extern. Add `(data ReadAllR () (read-all-done (1 s
  Sock) (buf Bytes)) (read-all-err (msg Str)))` and `(def MAX-BODY I64
  67108864)`. Add `(declare recv-all (=> (1 s Sock) Bytes ReadAllR))` +
  `(def recv-all (lam (s acc) ...))`: case `(sock-recv s 4096)` — `recv-r
  chunk s'` -> let `acc' = (bcat acc chunk)`, if `(<i (blen acc') MAX-BODY)`
  recurse else `(case (sock-close s') (unit (read-all-err "response too
  large")))`; `recv-closed s'` -> `(read-all-done s' acc)`; `recv-err m` ->
  `(read-all-err m)` (no cap to thread; the crossing consumed it). Add
  `(declare http-request (=> Str Str Bytes HttpR))` + `(def http-request (lam
  (method url body) ...))` = the example §5 spine verbatim, EXCEPT every error
  arm returns `(http-r -1 (str->bytes msg))` instead of `0`; close `s` in both
  the `parse-ok` and `parse-err` arms before returning. The extern-to-def swap
  is a single atomic edit (a `def` and an `extern` of the same name cannot
  coexist).
- **Size:** M.

## 5. Conformance gate

- **Golden behavior:** for the five non-streaming endpoints, `http-request
  "METHOD" url body` returns `(http-r status body)` with status/body identical
  to the frozen urllib oracle for the same `(method, url, body)`;
  `http-status`/`http-body` project it unchanged; `backend.chiral`
  `be-chat`/health/models/embed/search keep working with zero edits. Transport
  failure (refused connect) returns status **-1** (matching
  `impl_ports.py:377`); a server 4xx/5xx returns the server's status code.
- **Tests to add** (native, B1-compiled, exit-code convention per
  `samples/e129_sock_connect_in_refused.chiral`):
  - `e130_parse_url.chiral` — pure: good dotted-quad URL -> `url-ok`; bad
    scheme / missing port / non-numeric port / bad quad -> `url-err`.
  - `e130_parse_response.chiral` — pure on canned response bytes:
    `Content-Length` present, `content-length` lowercase present, no
    `Content-Length` (body-to-EOF), truncated (no CRLF CRLF).
  - `e130_format_request.chiral` — pure: CRLF bytes are 0x0d 0x0a,
    `Content-Length` equals `(blen body)`, `Connection: close` present.
  - `e130_http_request_refused.chiral` — `http-request "GET"
    "http://127.0.0.1:1/" (str->bytes "")` -> status -1 (conn-err -> -1);
    hermetic (no peer).
  - Host differential (host-only, ccbox has no loopback): bind a local
    `http.server` on 127.0.0.1, run the native `http-request`, assert
    status/body match `urllib.request` for the same request, byte-for-byte on
    the body. NOTE: `test_http.py`'s current mock injection at
    `runtime.IMPLS["http-request"]` (`test_chirality_path_get_and_post`,
    `test_http_error_status_is_a_normal_result`) BREAKS once `http-request` is
    a `def` with no extern seam; those two tests must re-point to mock the
    socket crossing seam (`nb-sock-connect-in`) or the local-server path.
    `test_transport_failure_is_data_not_an_alarm`'s assertion (status -1 on
    refused connect) must still hold against the native path.
- **Green line:** B1 compiles the `http.chiral` blob (via the resolver, like any
  non-compiler program); the four `e130_*` samples run and return their
  documented exit codes; the host differential test agrees with urllib. Python
  floor (709 test fns) stays advisory and non-gating. No fixpoint, no compiler
  rebuild (pure chirality surface).
- **Done when:** B1 compiles the `http.chiral` blob, the four `e130_*` samples
  exit with their documented codes, and the host differential test matches
  urllib byte-for-byte on health/models/chat(non-stream)/embed/search.

## 6. Residue & links

- **Deliberately unbuilt:** streaming SSE (`E131`); read-timeout / poll-based
  deadline (hardening, home not yet assigned); TLS (`https`) needs a TLS
  connect crossing, not spec'd here; DNS resolution (dotted-quad only, per
  E129); redirect-following and gzip decompression (urllib did these
  ambiently; the native client does not — the model endpoints never redirect
  or compress, so this is a documented divergence, not a gap); request-side
  `Content-Length: 0` on GET (benign, response differential unaffected); the
  now-dead `@impl("http-request")` shim at `impl_ports.py:343-377` is retired
  but not deleted in this element (removal is cleanup, not this element).
- **Follow-on:** E131 (streaming SSE transport swap) is next.
- **Related:** [[E130-http-native]] [[E129]] [[E125]] [[E107]] [[E131]].
