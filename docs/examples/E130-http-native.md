---
element: E130
slug: http-native
title: Native HTTP/1.1 client (transport swap): rewrite `http.chiral` over the native socket caps, retiring the Python `http-request` urllib shim (`@impl("http-request")`, impl_ports.py:343). `http-request : (=> Str Str Bytes HttpR)` (method, url, body) becomes a chirality `def`: parse the URL into host/port/path (`http://host:port/path`, dotted-quad host), `sock-connect-in` (E129) to the host, format an HTTP/1.1 request (request line `METHOD path HTTP/1.1` + `Host:` + `Content-Type: application/json` + `Content-Length:` + CRLF CRLF + body) into Bytes, `sock-send` it, `sock-recv`-loop the response, parse the status line + headers, read the body by `Content-Length`. `HttpR`/`http-status`/`http-body` unchanged (typed face is frozen — E51 "transport swap is not a reshape"); `backend.chiral` needs no change (its seam is already `base : Str`). **Scope: non-streaming request/response**; the streaming `chat-open`/`chat-read`/`chat-close` (SSE, Transfer-Encoding: chunked) is the follow-on E131. Zero CPython in the model path (the whole point of §4.6)
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: reviewed
updated: 2026-08-13
---

# E130 — Native HTTP/1.1 client (transport swap)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E130. The non-streaming half of `scaffold/lib/http.chiral` becomes
  a real chirality HTTP/1.1 client. The `http-request` extern (a CPython urllib shim
  behind `@impl("http-request")`) is retired and reimplemented as a chirality `def`
  over the native socket caps from E125/E129.
- **Kind:** BUILD-PROPER. There is no chirality HTTP framing or response parser in
  the tree today; the socket floor is native but nothing speaks HTTP on top of it.
- **Why chirality needs its own:** the model path (`backend.chiral` `be-chat` and the
  health/models/embed/search endpoints) currently calls into CPython for every
  request. That is a crutch in the middle of the TCB boundary: urllib carries
  ambient authority (DNS, proxies, redirects, decompression) that the type system
  cannot see. Replacing it with a chirality `def` shrinks the TCB and makes the
  effect row of an HTTP call a typed, finite fact.

The typed face is FROZEN. `HttpR`, the `http-request` signature, and the
`http-status`/`http-body` projections do not change. This is a transport swap,
not a reshape (E51). `backend.chiral` and everything above it stay untouched. The
streaming SSE half (`chat-open`/`chat-read`/`chat-close`, `Transfer-Encoding:
chunked`) is OUT of scope here; it is the deferred follow-on E131.

## 2. Research

- **Reference class:** OURS/SPEC. OURS: the frozen urllib oracle at
  `impl_ports.py:343`, the `HttpR`/`http-request` face in `http.chiral`, the
  call sites in `backend.chiral:83,126`, and the native socket floor
  (`ports.chiral:95-98`, `inet.chiral:109-114`, the recv-loop pattern in
  `lincoll.chiral:86-89`). SPEC: HTTP/1.1 message framing, RFC 7230.
- **Key findings:**
  - **Message shape (RFC 7230 §3).** A message is `start-line`, then zero or more
    `header-field CRLF`, then a bare `CRLF`, then an optional body. The empty line
    terminates the header section; that is the one delimiter the framing code must
    hunt for.
  - **Start lines (RFC 7230 §3.1.1, §3.1.2).** Request line is
    `METHOD SP request-target SP HTTP-version CRLF`; status line is
    `HTTP-version SP status-code SP reason-phrase CRLF` where status-code is three
    digits. The parser reads the status code as decimal from a fixed-width field,
    not by splitting on whitespace.
  - **Header grammar and case (RFC 7230 §3.2).** `field-name ":" OWS field-value
    OWS`; field names are case-insensitive. `Content-Length` and `content-length`
    are the same field, so the header scan must fold case or compare ignorantly of
    case, not do a byte-equal.
  - **Body delimiting (RFC 7230 §3.3.2).** With no `Transfer-Encoding`, the body
    length is the decimal value of `Content-Length`. The body is NOT delimited by
    EOF on a persistent connection; a reader that trusts EOF will stall or overread.
  - **Close vs keep-alive (RFC 7230 §6.1, §6.3).** HTTP/1.1 defaults to persistent.
    A request carrying `Connection: close` tells the server to close after the
    response, which collapses the read loop to "read until the peer FINs" and
    sidesteps keep-alive framing entirely. That is the cheap move here: send
    `Connection: close`, read to close, then slice the body by `Content-Length`.
  - **The oracle and the floor.** The frozen shim returns `(http-r status body)`
    for `(method, url, body)`; the call sites pass `method`, a `Str` URL, and a
    `Bytes` body (`backend.chiral:83` POST, `:126` GET with `(str->bytes "")`).
    Below it, `sock-send : (=> (1 s Sock) Bytes SendR)` and
    `sock-recv : (=> (1 s Sock) (refine I64 (> 0)) RecvR)` thread the `Sock`
    linearly through `SendR`/`RecvR` sums (`ports.chiral:95-98`), and
    `sock-connect-in : (=> Str I64 ConnR)` takes a dotted-quad host and a port
    (`inet.chiral:109`). `RecvR` is three-way: `recv-r` (bytes back, `Sock` back),
    `recv-closed` (peer FIN, `Sock` back), `recv-err` (message, `Sock` consumed)
    (`lincoll.chiral:86-89`, sys-tal tag comment). That is the exact floor the
    framing layer sits on.

## 3. Conventional (other-language) approach

How `http-request` works today, and how any Python/Ruby/Go one-off would do it:

```python
import urllib.request

def http_request(method, url, body):
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        return resp.status, resp.read()   # (status, body) -> HttpR
```

- **Assumptions it bakes in:**
  - **Ambient authority.** `urlopen` resolves DNS, honors proxy env vars, follows
    redirects, decompresses gzip, and negotiates keep-alive, all invisibly. None of
    that is in the signature; the caller grants all of it by calling the function.
  - **Errors are exceptions.** `URLError`/`HTTPError` unwind the stack. The
    failure mode is not a value the caller is forced to inspect; it is control flow.
  - **EOF == body end.** `resp.read()` reads to end-of-response, with the
    `http.client` layer handling `Content-Length` and de-chunking transparently.
    The raw framing decisions are hidden in a stdlib.
  - **Untyped split.** `status` and `body` come back as bare `(int, bytes)`; nothing
    in the type distinguishes a transport failure from an HTTP 500 from a success.
  - **No proof obligation.** Nothing forces the request bytes to be well-formed or
    the body length to match `Content-Length`; a mismatch is a runtime surprise.

## 4. The chirality idea

- **Chirality features in play:** QTT linear `Sock` threading; the effect membrane
  (`->` pure vs `=>` effectful, inferred crossing rows); ports and capabilities;
  boundary sums (parse once, pass a closed sum, no `Str` tags); totality;
  categories A (typed surface) / B (raw socket floor) / C (the bridge here is
  `http.chiral` over `ports`/`inet`).
- **The reframing.** The transport swap is a purity split. Everything that
  touches bytes without touching the network is pure `->`: `parse-url`,
  `format-request`, `parse-response`, the header scan, the `Content-Length`
  extraction. Only four names cross the membrane, and all four already exist as
  typed crossings: `sock-connect-in`, `sock-send`, `sock-recv`, `sock-close`. The
  `http-request` def's effect row is exactly that set, by construction, with no
  ambient authority. The URL and the response are each parsed ONCE at their
  boundary into a closed sum (`UrlR`, `ParseR`), so downstream code cases totally
  and stays pure; no re-checking a `Str` tag. The `Sock` is a linear capability:
  every `case` arm either passes it on or closes it, so a socket left dangling
  after the response is untypeable.
- **What chirality makes impossible here:**
  - **Use-after-close / leak.** `Sock` is quantity-1; you cannot drop it, reuse it
    after `sock-close`, or forget to close it without the checker rejecting.
  - **Hidden authority.** urllib's DNS/proxy/redirect/decompress side effects
    cannot hide behind a bare function call; the only crossings are the four
    socket caps named above.
  - **Exceptions as control flow.** A bad URL, a refused connect, a truncated
    response are all returned values (`url-err`, `conn-err`, `recv-err`, `parse-err`)
    the caller must case on.
  - **Partiality.** `parse-url` and `parse-response` are total: malformed input
    yields an `*-err` constructor, never a hang or a throw.

## 5. Chirality example (fleshed)

```chirality
; http.chiral — E130 transport swap. Non-streaming HTTP/1.1 client over the native
; socket caps. Typed face is FROZEN: HttpR / http-request / http-status / http-body
; do not change. The extern becomes a def; the effect row is the four socket caps.

(import "prelude")
(import "ports")     ; Sock, ConnR, SendR, RecvR, sock-send/-recv/-close
(import "inet")      ; sock-connect-in (=> Str I64 ConnR), E129

; ---- frozen face (unchanged) ----
(data HttpR () (http-r (status I64) (body Bytes)))

(def http-status (-> HttpR I64)   (lam (r) (case r ((http-r s b) s))))
(def http-body   (-> HttpR Bytes) (lam (r) (case r ((http-r s b) b))))

; ---- pure framing layer: -> throughout, empty effect row ----

; URL boundary: parse once into a closed sum, pass the value downstream.
(data UrlR () (url-ok (host Str) (port I64) (path Str)) (url-err (msg Str)))

(declare parse-url (-> Str UrlR))
(def parse-url
  (lam (url)
    ; strip the "http://" prefix, split host:port on ':', split path on the first
    ; '/' (default "/"). All byte-walking is pure; elided. Dotted-quad host only,
    ; port parsed as decimal I64. Malformed -> (url-err msg).
    (url-ok "127.0.0.1" 11434 "/v1/chat/completions")))   ; … replaced by the walk

(declare i64->dec (-> I64 Str))   ; decimal digits, no sign (Content-Length, Host port)

; Request framing: request line + Host + Content-Type + Content-Length + Connection
; + CRLF CRLF, then the raw body bytes appended. CRLF is 0x0d 0x0a.
(declare format-request (-> Str Str I64 Str Bytes Bytes))
(def format-request
  (lam (method host port path body)
    (bcat
      (str->bytes
        (str-cat method
          (str-cat " "
            (str-cat path
              (str-cat " HTTP/1.1\r\nHost: "
                (str-cat host
                  (str-cat ":"
                    (str-cat (i64->dec port)
                      (str-cat "\r\nContent-Type: application/json\r\nContent-Length: "
                        (str-cat (i64->dec (blen body))
                          "\r\nConnection: close\r\n\r\n"))))))))))
      body)))

; Response boundary: status line + headers + body, parsed once. Header names are
; matched case-insensitively (Content-Length vs content-length, RFC 7230 §3.2).
(data ParseR () (parse-ok (status I64) (body Bytes)) (parse-err (msg Str)))

(declare parse-response (-> Bytes ParseR))
(def parse-response
  (lam (buf)
    ; find the CRLF CRLF header terminator, read status-code (3 digits) from the
    ; status line, scan headers for Content-Length (case-insensitive), slice that
    ; many bytes after the terminator as the body. Pure ->; elided.
    (parse-ok 200 (str->bytes "ok"))))                     ; … replaced by the walk

; ---- effectful spine: the only crossings are the four socket caps ----

; recv-all: read chunks until the peer FINs (we sent Connection: close), threading
; the linear Sock through every arm. recv-err consumed the cap, so it carries none.
(data ReadAllR () (read-all-done (1 s Sock) (buf Bytes)) (read-all-err (msg Str)))

(declare recv-all (=> (1 s Sock) Bytes ReadAllR))
(def recv-all
  (lam (s acc)
    (case (sock-recv s 4096)
      ((recv-r chunk s)  (recv-all s (bcat acc chunk)))
      ((recv-closed s)   (read-all-done s acc))
      ((recv-err m)      (read-all-err m)))))

(declare http-request (=> Str Str Bytes HttpR))
(def http-request
  (lam (method url body)
    (case (parse-url url)
      ((url-ok host port path)
       (case (sock-connect-in host port)
         ((conn-r s)
          (let ((req (format-request method host port path body)))
            (case (sock-send s req)
              ((send-r s)
               (case (recv-all s (str->bytes ""))
                 ((read-all-done s buf)
                  (case (parse-response buf)
                    ((parse-ok status resp-body)
                     (case (sock-close s) (unit (http-r status resp-body))))
                    ((parse-err m)
                     (case (sock-close s) (unit (http-r 0 (str->bytes m)))))))
                 ((read-all-err m) (http-r 0 (str->bytes m)))))
              ((send-err m) (http-r 0 (str->bytes m))))))
         ((conn-err m) (http-r 0 (str->bytes m)))))
      ((url-err m) (http-r 0 (str->bytes m))))))
```

- **Knobs to modify:**
  - `parse-url`'s scheme check: this targets `http://host:port/path` with a
    dotted-quad host; adding `https` means a different connect crossing (TLS),
    which is out of scope.
  - `Content-Length` extraction: swap the single header scan for a small
    assoc list if more headers (Content-Type echo, chunked detection) ever matter.
  - The buffer size `4096` in `recv-all`: any positive `I64`; it is the `sock-recv`
    chunk size, not a correctness parameter.
  - `ConnR` constructor names: confirmed at `ports.chiral:43-45` —
    `(data ConnR () (conn-r (1 s Sock)) (conn-err (msg Str)))`. The snippet's
    `conn-r`/`conn-err` arms match; no change needed before copying.
  - CRLF: the `\r\n` in the string literals must be the real bytes 0x0d 0x0a. If
    `Str` literals do not escape `\r`, build the separator as a `Bytes` constant
    and assemble the whole request with `bcat` instead of `str-cat`.
- **Deliberately omitted:**
  - The byte-walking bodies of `parse-url` and `parse-response` (index scans and
    digit folds) are elided as `; …`; they are mechanical and pure.
  - The streaming half (`chat-open`/`chat-read`/`chat-close`, SSE, chunked
    transfer) is deferred to E131 and not spec'd here.
  - `json.chiral` is not touched: `http-request` still returns a raw `Bytes` body
    and `backend.chiral` still parses it. No change above the `http.chiral` seam.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/http.chiral` (the `http-request` extern and its
  `@impl` shim come out; the `def` above and its helpers go in). `ports.chiral`,
  `inet.chiral`, `backend.chiral` are untouched. The `@impl("http-request")` entry
  at `impl_ports.py:343` is retired as dead code once nothing calls it.
- **Conformance target:** reproduce the frozen oracle byte-for-byte on the
  non-streaming endpoints. `http-request "POST" url body` must return
  `(http-r status body)` identical to the urllib shim for the same
  `(method, url, body)`; `http-status`/`http-body` must project it unchanged;
  `backend.chiral` `be-chat`/health/models/embed/search must keep working with zero
  edits above the seam.
- **Open questions:**
  - What does the oracle return on a transport error (refused connect, timeout)?
    `HttpR` has no error constructor, so the shim must already map failure to some
    status; the chirality def must match that mapping (the snippet guesses status 0).
  - Non-termination: a hostile peer that never FINs (and ignores `Connection:
    close`) makes `recv-all` diverge. A read-timeout or a max-body bound would make
    it total by measure; decide whether that belongs here or in a later hardening
    element.
  - Case-insensitive header match needs a fold helper; confirm `Str` literals
    support `\r` before relying on `\r\n` escapes.
- **Related:** [[E130-http-native]] · [[E129]] (native AF_INET connect floor) ·
  [[E125]] (sock send/recv) · [[E107]] (sock-close) · [[E131]] (streaming SSE,
  deferred follow-on).
