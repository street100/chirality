---
element: E131
slug: sse-stream
title: Native SSE streaming (retire the `chat-*` shim): lower `chat-open`/`chat-read`/`chat-close` to native over the socket floor, retiring the Python SSE shim (`@impl("chat-open"/"chat-read"/"chat-close")`, impl_ports.py:357/399/440). `chat-open` sends the request (`stream:true`, `Accept: text/event-stream`) and keeps the live connection in the stream handle; `chat-read` recvs into a buffer, splits `data:` frames, extracts the content delta via `json.chiral` (OpenAI `choices[0].delta.content` AND Ollama `message.content` passthrough), and emits `chunk`/`chunk-done` (`[DONE]`)/`chunk-err` (transport, HTTP status, JSON, mid-stream error frame, or EOF-before-DONE truncation); `chat-close` releases the connection. The `ChatStream`/`ChatChunk` typed face is frozen; the handle must stay live across recvs (one recv does not drain a stream). Zero CPython in the streaming model path
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: reviewed
updated: 2026-08-14
---

# E131 — Native SSE streaming (retire the `chat-*` shim): lower `chat-open`/`chat-read`/`chat-close` to native over the socket floor, retiring the Python SSE shim (`@impl("chat-open"/"chat-read"/"chat-close")`, impl_ports.py:357/399/440). `chat-open` sends the request (`stream:true`, `Accept: text/event-stream`) and keeps the live connection in the stream handle; `chat-read` recvs into a buffer, splits `data:` frames, extracts the content delta via `json.chiral` (OpenAI `choices[0].delta.content` AND Ollama `message.content` passthrough), and emits `chunk`/`chunk-done` (`[DONE]`)/`chunk-err` (transport, HTTP status, JSON, mid-stream error frame, or EOF-before-DONE truncation); `chat-close` releases the connection. The `ChatStream`/`ChatChunk` typed face is frozen; the handle must stay live across recvs (one recv does not drain a stream). Zero CPython in the streaming model path

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E131, native SSE streaming. Retire the three `chat-*` CPython
  shims (impl_ports.py:357/399/440) and re-implement them as chirality defs over the
  already-native socket floor (E125 `sock-send`/`sock-recv`, E129
  `sock-connect-in`, E130 `http-request`).
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the streaming model path is the last CPython
  holdout in HTTP. E130 made the non-streaming path native; the chat shim still
  rides `urllib` + Python `json` (readline loop, exception control flow, a
  hidden buffered reader). Zero CPython in the streaming path shrinks the TCB and
  makes the stream handle a first-class linear cap instead of a Python object.

## 2. Research

- **Reference class:** OURS/SPEC. OURS = `http.chiral` (`HttpR`, `http-request`,
  `ChatStream`, `ChatChunk`, `parse-url`), `backend.chiral` (`be-chat-stream`),
  `json.chiral` (`json-parse`, `Json`), `inet.chiral` (`sock-connect-in`),
  `ports.chiral` (`sock-send`/`sock-recv`/`sock-close`). SPEC = Server-Sent
  Events (`text/event-stream`) and HTTP/1.1 chunked transfer (RFC 7230 §3.3).
- **Key findings:**
  1. **SSE framing** (text/event-stream): events are separated by a blank line;
     an event's payload is its `data:` lines joined with `\n`; `:` comment lines
     are keepalives. `[DONE]` is an application sentinel, not part of SSE.
  2. **Chunked transfer** (RFC 7230 §3.3): recv boundaries are arbitrary. One
     recv can return a partial frame, several frames, or a mid-line cut. The
     read buffer must be a persistent reservoir, not a per-call scratch.
  3. **The frozen face** (http.chiral:349-358): `ChatStream` is a bare
     `porttype` with no native carrier, and `ChatChunk` is the 3-ctor sum. A
     bare porttype cannot be bridged from a crossing return (the "no emitted
     label" pitfall), so the handle needs a data carrier.
  4. **The floor is already native** (E125/E129/E130): `sock-recv` returns the
     3-way `RecvR` (`recv-r`/`recv-closed`/`recv-err`) where `recv-err` is a
     corpse that drops the socket; `json-parse` is `(-> Bytes (Maybe Json))`
     with `j-obj`/`j-arr`/`j-str` constructors.

## 3. Conventional (other-language) approach

The Python shim (impl_ports.py:357-444). `chat-open` does `urllib.urlopen` with
the two headers; `chat-read` runs a `readline()` loop; `chat-close` closes the
response.

```python
def _chat_open(method, url, body):
    req = urllib.request.Request(url, data=body, method=method,
                                 headers={"stream": "true",
                                          "Accept": "text/event-stream"})
    return urllib.request.urlopen(req)          # raises on connect / non-2xx

def _chat_read(resp):
    data = b""
    while True:
        line = resp.readline()
        if line == b"": break                   # EOF
        line = line.rstrip(b"\r\n")
        if line == b"": break                   # end of event
        if line.startswith(b":"): continue      # keepalive
        if line.startswith(b"data:"): data += line[5:].lstrip(b" ")
    if data == b"[DONE]": return chunk_done
    j = json.loads(data)                        # raises on bad JSON
    if isinstance(j, dict) and "error" in j: return chunk_err
    delta = (j.get("choices", [{}])[0].get("delta", {}).get("content")
             or j.get("message", {}).get("content"))
    return chunk(delta)
```

- **Assumptions it bakes in:** untyped effects (DNS, socket, HTTP all fire
  invisibly inside `urlopen`); exceptions as control flow (connect, status, and
  JSON errors all raise); a hidden buffered reader and hidden socket living in
  the `resp` object; ambient allocation; partiality (readline blocks forever).
  None of it is a type. chirality refuses all of it.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (`(1 s Sock)` caps threaded by
  construction); the effect membrane (`chat-*` and the recv loop are `=>`
  process, the frame scanner and delta walk are pure `->`); ports as
  capabilities (no ambient authority, the socket is a value you hold); boundary
  sums (every classification is a closed sum at the boundary, not a `Str` tag);
  totality (pure scanners are structural; the recv loop mirrors `read-all`);
  category C bridge (chirality source over the untyped socket crossing).
- **The reframing:** the stream handle stops being a Python object and becomes a
  single-ctor `data` carrying three things: the live `Sock` cap, a `Bytes`
  reservoir (the unconsumed tail of the last recv), and a parse-state mode. The
  bare `porttype` had no carrier; the data type gives it one. The frozen extern
  signatures mention `ChatStream` only by name, so they stay textually
  identical.
- **What chirality makes impossible here:** dropping the socket (linear, must thread
  or close); reading without the handle (the cap is the parameter); reusing a
  drained handle (consumed exactly once, moved back each read); forgetting a
  partial frame (it lives in the reservoir, not in a hidden reader); an
  unhandled error path (every failure is an arm of `RecvR`/`FrameKind`/`DeltaR`
  the caller must case on).

## 5. Chirality example (fleshed)

```chirality
; ---------------------------------------------------------------- streaming
; E131: retire the chat-* Python shim (impl_ports.py:357/399/440). The typed
; face is FROZEN (chat-open/chat-read/chat-close signatures, ChatChunk shape);
; what changes is ChatStream gains a native carrier and the externs become defs
; over the E125/E129/E130 socket floor. No new crossings; no TAL work.

(import "json")   ; json-parse, Json (j-obj/j-arr/j-str) for the delta walk

; ---- the handle: a native carrier for the former bare porttype.
; A bare porttype cannot be bridged from a crossing return (the "no emitted
; label" pitfall), so retype it as a single-ctor data carrying the live Sock
; cap + the unconsumed-byte reservoir + parse state. The frozen signatures
; reference `ChatStream` by name, so they are untouched.

; A socket that may already be gone: connect failed, or the peer reset the
; stream mid-flight. The frozen ChatChunk face always hands a handle back
; (chunk-err "still must close"), so the handle needs a way to say "nothing
; left to close". A bare (Maybe Sock) is the trap (its field is `w`, rejects
; the linear Sock), so this is a linear option.
(data SockOpt ()
  (so-live (1 s Sock))
  (so-dead))

; Parse state across the header/body boundary of the response.
(data StreamMode ()
  (m-body)                 ; SSE body streaming, healthy
  (m-failed (status I64))) ; terminal: open-time or transport failure, status kept

(data ChatStream ()
  (cs (1 sock SockOpt) (buf Bytes) (mode StreamMode)))

; The frozen face, unchanged:
(data ChatChunk ()
  (chunk      (delta Str)   (1 s ChatStream))
  (chunk-done               (1 s ChatStream))
  (chunk-err  (status I64)  (1 s ChatStream)))

; ------------------------------------------------------------ pure SSE framing
; Everything that touches bytes without touching the socket is a pure `->`.

; One line off the front of the buffer: bytes before the first \n, plus the
; rest. No \n -> (line-none): the recv returned mid-line, need more bytes.
(data LineSplit ()
  (line-ok  (line Bytes) (rest Bytes))
  (line-none))
(declare split-line (-> Bytes LineSplit))

; Strip a leading "data:" (with one optional space). None for event:/id:/
; retry:/blank/comment lines.
(declare strip-data (-> Bytes (Maybe Bytes)))

; Scan the reservoir for ONE complete SSE event. An event ends at a blank line;
; its payload is its "data:" lines joined by \n (SSE multi-line concatenation).
; Comment/keepalive (":") lines are skipped inside the scan. (fs-need) = the
; event is still incomplete (partial frame / mid-frame recv).
(data FrameScan ()
  (fs-event (payload Bytes) (rest Bytes))
  (fs-need))
(declare scan-event (-> Bytes FrameScan))

; Payload classification: [DONE] vs a content delta vs skip vs error.
(data FrameKind ()
  (fk-done)
  (fk-data (delta Str))
  (fk-skip)                 ; keepalive / role-only / finish_reason frame
  (fk-err  (status I64)))   ; JSON parse fail / mid-stream error frame

(declare is-done (-> Bytes Bool))   ; payload == "[DONE]"

; Delta extraction result: the four ways a parsed frame classifies.
(data DeltaR ()
  (delta-ok   (delta Str))
  (delta-skip)               ; parsed, no content field this frame
  (delta-error)              ; parsed, top-level "error" field present
  (delta-bad))               ; json-parse returned none

; top-level "error" field present -> error frame
(declare j-has-error (-> Json Bool))
; content delta: choices[0].delta.content (OpenAI) OR message.content (Ollama)
(declare j-content (-> Json (Maybe Str)))

; json-delta: parse the payload; the two providers differ only in where the
; content string sits, so this is one closed case over Json.
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

; ------------------------------------------------------------ process spine

; One pull of the stream: scan the reservoir for a complete event; if none,
; recv more and retry (the read-all pattern: recursion over the recv result
; stream, not a structural argument). Returns the verdict + the socket (now
; maybe dead) + the leftover reservoir.
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

(def chat-read (=> (1 s ChatStream) ChatChunk)
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

(def chat-close (=> (1 s ChatStream) Unit)
  (lam (st)
    (case st
      ((cs sock buf mode)
        (case sock
          ((so-live s) (sock-close s))
          ((so-dead) unit))))))

; Read the response head (status line + headers) until the \r\n\r\n separator,
; handing back any over-read body bytes as `rest` -- the first SSE events may
; ride in with the header recv, and the reservoir must keep them (one recv does
; not drain a stream).
(data HeadR ()
  (head-ok (status I64) (rest Bytes) (1 s Sock))
  (head-err (msg Str)))   ; transport died mid-head: no sock

(declare read-head (=> (1 s Sock) Bytes HeadR))
(declare format-sse-request (-> Str Str I64 Str Bytes Bytes))
(declare ok2xx (-> I64 Bool))

; open-stream mirrors http-request-on's shape, but stops after the head: the
; body is streamed, not drained. Non-2xx is recorded in the mode and surfaces
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

(def chat-open (=> Str Str Bytes ChatStream)
  (lam (method url body)
    (case (parse-url url)
      ((url-ok host port path)
        (case (sock-connect-in host port)
          ((conn-r s) (open-stream s method host port path body))
          ((conn-err m) (cs so-dead (str->bytes "") (m-failed -1)))))
      ((url-err m) (cs so-dead (str->bytes "") (m-failed -1))))))
```

- **Knobs to modify:** the recv chunk size (`4096`, mirroring `read-all`); the
  `SockOpt` carrier if the author instead relaxes the frozen face to a result
  sum on `chat-open`; `j-content` when a third provider shape arrives (one more
  arm in the field walk); the buffer reservoir is the single place to change
  frame-splitting policy.
- **Deliberately omitted:** the mechanical byte loops (`split-line`,
  `scan-event`, `strip-data`, `is-done` via `bget`/`bslice`/`blen`); the field
  walk inside `j-content`/`j-has-error` (an `alist-get` over the `j-obj` fields
  list); `read-head`'s recv loop (identical shape to `read-all`, terminating at
  `\r\n\r\n`); `format-sse-request` (E130's `format-request` plus the two SSE
  headers `stream:true` and `Accept: text/event-stream`); `ok2xx` (status in
  200..299).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/http.chiral` (the streaming section, replacing
  `(porttype ChatStream)` and the three `(extern chat-*)` at lines 349-358).
  Adds one import: `(import "json")` (json.chiral imports prelude
  only, no cycle). No `sys-tal.chiral`, `crossing-wraps.chiral`, `native.py`, or
  `tal.py` changes: `chat-*` compose the existing native socket crossings. The
  three `@impl("chat-open"/"chat-read"/"chat-close")` bodies in `impl_ports.py`
  are deleted, not migrated.
- **Conformance target:** reproduce the shim exactly. `[DONE]` payload maps to
  `chunk-done`; OpenAI `choices[0].delta.content` and Ollama `message.content`
  both yield the same delta string; a mid-stream `{"error":...}` frame and a
  JSON parse failure map to `chunk-err`; EOF before `[DONE]` is `chunk-err`
  (truncation); `backend.chiral` `be-chat-stream` drives the loop unchanged.
- **Open questions (RESOLVED 2026-08-14 by author; kept here as the design
  record, the SPEC dispositions each RESOLVED):**
  1. **No-socket arms** (was NEEDS-AUTHOR). RESOLVED: `SockOpt` linear-option
     carrier (`so-live`/`so-dead`), preserving the frozen face.
  2. **Status deferral** (was NEEDS-AUTHOR). RESOLVED: defer to the first
     `chat-read` via `m-failed`.
  3. **`(import "json")` into http.chiral** (was NEEDS-AUTHOR). RESOLVED: import
     `json`, keep the delta walk in http.chiral.
  4. **Delta-skip blocking** (was NEEDS-AUTHOR). RESOLVED: within-call loop,
     mirrors the shim's readline loop.
- **Related:** [[E131-sse-stream]] · [[E130]] `http-request` (native def over
  sockets) · [[E129]] `sock-connect-in` · [[E125]] `sock-send`/`sock-recv` ·
  [[E107]] `sock-close`.
