---
element: E128
slug: apc-handshake
title: APC structured-side-channel **handshake**: the wire negotiation protocol that *sets* `term-structured?`'s bit — an APC query (`ESC _ ? … ST`) the emulator answers with an APC reply, so a dumb terminal stays silent and a timeout ⇒ `false` (aligned with E112's APC transport). Split out of E112 (the codec consumes the `Bool`; this negotiates it) 2026-08-12 by the E112 spec-revision. Its spec resolves the exact query/reply bytes + timeout
kind: BUILD-PROPER
reference_class: OURS/PAPER
ours_source: (none)
status: drafted
updated: 2026-08-12
---

# E128 — APC structured-side-channel **handshake**: the wire negotiation protocol that *sets* `term-structured?`'s bit — an APC query (`ESC _ ? … ST`) the emulator answers with an APC reply, so a dumb terminal stays silent and a timeout ⇒ `false` (aligned with E112's APC transport). Split out of E112 (the codec consumes the `Bool`; this negotiates it) 2026-08-12 by the E112 spec-revision. Its spec resolves the exact query/reply bytes + timeout

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E128, the wire **negotiation** that sets `term-structured?`'s bit —
  chirality emits an APC query, and if a chirality emulator answers (also over APC), the
  acquired `Terminal` cap carries `structured = true` (the (M) lossless tier);
  otherwise it times out to `false` (the (R) baseline tier).
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** E112 (the APC codec) *consumes* the `term-structured?`
  `Bool` but does not *produce* it — it is negotiated once at acquisition. E128 is
  that negotiation. It is a distinct unit of work: E112 is a pure codec; E128 is a
  crossing (write a query, read a reply under a deadline). Splitting it keeps the
  codec pure and the negotiation's timing/robustness decisions in one place.

## 2. Research

- **Reference class:** OURS/PAPER — `TERMINAL-PORT-DESIGN §2` (the degrade rule +
  the `term-structured?` signature) and `§8 item 4` (the open handshake slot);
  E112's resolved transport (APC `ESC _ … ST`, printable payload). Prior art: the
  established terminal capability-query pattern — DA1 (`ESC [ c`), XTVERSION,
  kitty-keyboard query (`ESC [ ? u`) — all "write a query, read a reply, fall back
  on timeout." kitty/notty ride **APC** for private payloads (E112 decision #1).
- **Key findings (load-bearing):**
  1. **APC gives degrade-for-free.** A terminal that doesn't understand `ESC _ … ST`
     *silently discards* it (ECMA-48 APC) — so a dumb terminal never replies, and a
     read timeout is the unambiguous "plain" signal. No garbage echoed to the user.
  2. **The reply needs a timeout, and the timeout IS the answer.** The whole
     protocol is a timed read: reply-within-window ⇒ structured; window elapses ⇒
     plain. `poll` with a ms deadline (E31 `poll-timeout`, the exact mechanism E42's
     supervisor already uses) is the primitive.
  3. **A query/reply marker byte disambiguates handshake from render frames.**
     After `ESC _`, a `?` (query) / `!` (reply) marker distinguishes the negotiation
     from a payload frame, whose first byte is a constructor tag (`t/s/S/h/T/r`,
     E112) — never `?`/`!`. Zero collision with the codec.
  4. **A nonce defeats stale-buffer false-positives.** A leftover byte sequence in
     the input buffer could look like a reply; echoing a per-acquisition nonce in
     the query and requiring it back makes the match sound.

## 3. Conventional (other-language) approach

How a terminal capability handshake is done outside chirality (here: a typical raw-tty
probe in Python):

```python
import termios, tty, select, os
def probe_structured(fd, timeout=0.05):
    old = termios.tcgetattr(fd); tty.setraw(fd)
    try:
        os.write(fd, b"\x1b_?chirality1\x1b\\")        # APC query
        r, _, _ = select.select([fd], [], [], timeout)   # timed read
        if not r:
            return False                            # timed out → plain
        data = os.read(fd, 64)
        return data.startswith(b"\x1b_!") and b"chirality1" in data
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
```

- **Assumptions it bakes in:** ambient fd authority (`os.write(fd, …)` — anyone with
  the int can write); the timeout-vs-error-vs-reply outcome collapsed into
  truthy/falsy returns (a `select` error, an EOF, and a real timeout are not
  distinguished); raw-mode as a side effect on a global fd; no linear guarantee that
  the terminal is threaded and not aliased.

## 4. The chirality idea

- **Chirality features in play:** the **effect membrane** (`=>` for the write + timed
  read, `->` for parsing the reply); **linear ports** (the `Terminal` cap threaded
  through the crossing, never aliased); **boundary sums** (the outcome parsed once
  into a closed sum, not a `Bool`-with-lost-error); **errors/timeout as values**;
  **no ambient authority** (the write goes through the cap's write authority, not a
  bare fd int).
- **The reframing:** negotiation returns a **`HandshakeR`** sum carrying the
  *threaded* `Terminal` on every arm — `hs-structured` / `hs-plain` / `hs-err`. The
  negotiated bit is stamped onto the returned cap, and E112's `term-structured?`
  merely reads it. Timeout is not an error: `poll-timeout` maps to `hs-plain` (a
  first-class, expected arm). The query carries a nonce derived from the `Clock`
  cap; the reply must echo it.
- **What chirality makes impossible here:** writing the query to a terminal you don't
  hold (no ambient fd); dropping or reusing the `Terminal` mid-negotiation (linear);
  a caller silently mistaking a read error for "plain" (the error is its own arm, in
  the type).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "ports")   ; Terminal cap, its write authority, poll (E31), Clock (E32)

; ── The outcome: parse the reply ONCE into a closed sum, carry the cap as a value.
;    Boundary-sum directive: never a Bool-with-a-dropped-error / sentinel int.
(data HandshakeR ()
  (hs-structured (1 t Terminal))          ; a chirality emulator answered → (M) tier
  (hs-plain      (1 t Terminal))          ; timeout / silent / malformed → (R) tier
  (hs-err (msg Str) (1 t Terminal)))      ; poll/read/write crossing failed

; ── APC envelopes. Constants DECIMAL (reader is decimal-only):
;    ESC=27  _=95  backslash=92  ?=63  !=33.  '?' marks a query, '!' a reply —
;    neither collides with a render frame's tag byte (t/s/S/h/T/r, E112).
(declare apc-query (-> Str Bytes))        ; nonce -> ESC _ ? "chirality1:" nonce ESC \
(declare reply-ok? (-> Bytes Str Bool))   ; well-formed ESC _ ! … ST echoing nonce?

; ── The negotiation crossing.  dl = deadline ms (erased-usage: the size-param
;    idiom — pure `->` over dl, returning the `=>` process fn, exactly the
;    `pool-read (-> (0 n I64) (=> …))` shape).  negotiate-body is the mechanical
;    poll/read/write spine, elided (declared as a helper, same type).
(declare negotiate      (-> (0 dl I64) (=> (1 t Terminal) (1 c Clock) HandshakeR)))
(declare negotiate-body (-> (0 dl I64) (=> (1 t Terminal) (1 c Clock) HandshakeR)))
(def negotiate
  (lam (dl t c)                              ; binds the erased dl + the two caps
    ; 1. mint a per-acquisition nonce from the Clock (defeats stale-buffer match)
    ;    (case (time-mono c) ((time-ok ms c1) …thread c1…))
    ; 2. term-write t (apc-query nonce)              → threads Terminal   (=>)
    ; 3. poll the terminal's read fd with `dl` ms     → PollR (E31 poll-timeout)
    ;      poll-timeout        → (hs-plain t')          ; dumb terminal stayed silent
    ;      poll-ready → read → (case (reply-ok? bytes nonce)
    ;                             (true  (hs-structured t'))   ; emulator answered
    ;                             (false (hs-plain t')))       ; unknown responder → degrade
    ;      poll-err errno      → (hs-err (errno->msg errno) t')
    ; INVARIANT: the linear Terminal (and Clock) return on EVERY arm — no dropped cap.
    (the HandshakeR (negotiate-body dl t c))))

; ── E112 side (already specced): term-structured? just READS the stamped bit;
;    negotiate is what SET it.  term-draw then picks the tier.  E128 owns only
;    the negotiation; the codec + tier-select are E112.
```

- **Knobs to modify:** the deadline `dl`; the query/reply marker bytes and the
  version tag string (`"chirality1"`); whether the nonce is required (robust) or the
  presence of a well-formed reply suffices (simpler); a retry count.
- **Deliberately omitted:** the mechanical poll/read/write byte loop (rides E31
  `poll-timeout` + E98 read + E105 `write-fd`, all built); the capability payload
  *beyond* a version tag — v1 is a one-bit presence probe ("are you a chirality
  emulator"), a feature-bitset reply is a follow-on; raw-mode setup (E103, already
  the acquisition precondition).

## 6. Use / modify notes

- **Lands in:** `TUI/apc.chiral` (beside E112's codec — `apc-query`/`reply-ok?`) +
  the `Terminal` port impl (`negotiate` called at acquisition, stamping the bit the
  cap carries). Pure helpers `->`; `negotiate` `=>`.
- **Conformance target:** against a chirality emulator, `negotiate` returns
  `hs-structured` and the acquired cap makes `term-structured?` = `true`; against a
  dumb terminal (no APC responder), it returns `hs-plain` within `dl` ms and
  `term-structured?` = `false` — and the dumb terminal shows **nothing** on screen
  (the query was silently discarded). A malformed/nonce-mismatched reply degrades to
  `hs-plain`, never `hs-structured`.
- **Open questions (spec resolves):** exact `dl` (too short misses a slow emulator;
  too long stalls startup — 50 ms is the prior-art default); exact query/reply byte
  grammar (`ESC _ ? chirality1:<nonce> ST` / `ESC _ ! chirality1:<nonce> ST` recommended);
  nonce required vs optional; the reply capability schema (version-only vs feature
  bits); retry-on-partial-read behavior.
- **Related:** [[E128-apc-handshake]] · [[E112-apc-sidechannel]] (the codec that
  consumes the bit) · `TERMINAL-PORT-DESIGN.md` (§2 degrade rule, §8 item 4) ·
  E31 `poll-timeout` (the timed-read mechanism) · E32 `Clock` (the nonce source) ·
  E98/E105 (read/write crossings) · [[pattern-boundary-sums]] (outcome-as-sum).
