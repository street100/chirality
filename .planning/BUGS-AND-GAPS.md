# Bugs & gaps found in passing (not yet ticketed into elements)

## ✔ FIXED 2026-08-16 (commit `b402aff`, E100 sub-task 0) — `lower-defs` discards accumulated `le-skip` records → closure-lowering failures have NO blame chain (found during E100 re-diagnosis, 2026-08-16)

`compile-back.chiral:241` — `lower-defs`' `nil` case keeps only filter/prune/erase skips,
not the `le-skip` records accumulated during lowering. So when `compile-fn` on `$apply`
hits "case on unknown data" (`lower.chiral:349`) and emits an `le-skip`, that record is
**dropped silently** — no blame/skip-chain output. This is why the E100 `$apply` failure
surfaced only as a bare `no emitted label for entry compile-main` with no trace, and cost
significant diagnosis time. **Cheap, SAFE fix:** append `skips` in the `nil` case so the
accumulated `le-skip`s propagate to the blame chain — future closure-lowering failures
become self-reporting. (Still a compiler-source change → needs a self-host fixpoint, but
low-risk: it only adds diagnostic output, doesn't change lowering.) Not yet ticketed;
worth doing before/alongside the real E100 fix so that fix is debuggable.

## ✔ FIXED 2026-08-16 (E147) — nested defunctionalization: an HO *function* captured into a partial-app closure, applied inside the arm, fell through to "higher-order application" (surfaced during E100)

E.g. `(alist-get Str Str str-eqf)` partially applied, where `str-eqf` (a function) is
captured and then applied inside the `$apply` arm. **PRE-EXISTING and orthogonal to E100**
— verified to fail IDENTICALLY on the pre-E100 compiler and even on a monomorphic case
with zero type args, so it is NOT type-erasure (E100 fixed type-var captures; this is a
*function* capture that needs a second defunctionalization level in the arm).

**Root cause (E147, traced — a BOUNDED gap):** `arm-body` (`closconv.chiral:1025`) ran the
remapped `$apply` arm body through `rw` with an **empty de-Bruijn context** (`nil`). Inside
the arm a captured fn becomes a capture var (`cap0`); when `rw-app-disp` rewrote its
application `(eq hk k)`/`(f x)`, `ty-of sig nil (c-var i)` returned `none` → the Var-head app
was not recognized as a saturated higher-order call → left bare → `lower.chiral:280`
`er-skip "higher-order application"` → the family + entry pruned to a bare "no emitted
label". The `$apply` second-level dispatch already lived in `rw-app-disp` (it routes Var-head
saturated apps through `$apply` when `ka-find` matches) — it only lacked the capture types.

**Fix:** `arm-body` now passes `(arm-rw-ctx fields)` = the site's KEPT field types reversed
(`rev-onto-some (kept-tys fields) nil`), so `ctx[m-1-kj]` = kept field kj (matching
`g-subst`/`cap-subst`), giving `rw` the capture arrow types to dispatch on; apply-arg / clo
slots (≥m) resolve to `none` via out-of-range `ctx-get`. Uniform over `cs-g`/`cs-lam`.
Runtime gate `scaffold/tests/samples/e147_nested_ho.chiral` (3 cases, exit 0). Self-host
fixpoint holds cleanly (gen2==gen3, 1020280 B). Home: `closconv.chiral` `arm-body` /
`arm-rw-ctx` / `kept-tys`.

## REMINDER — set up web extraction backend

`web_extract` is broken (ddgs is search-only, can't extract page content). Fix:
- **Quick:** enable `web-firecrawl` plugin (needs FIRECRAWL_API_KEY, free tier)
- **Self-hosted:** deploy SearXNG Docker instance, enable `web-searxng` plugin
- Either path gets `web_extract` working. Currently research quality is degraded
  because every URL extraction fails.

Also: chirality-native HTTP crawler status — E65 (HTTP + SSE) is built but rides
CPython sockets as transport. E29 (native sockets as TAL crossings) and E51
(sys-face linkage) are the gates for a fully self-hosted crawler. TLS is an
unaddressed gap (not in the catalog).

## ✔ BUILD-STATE — reblob VERIFIED NOT NEEDED (2026-08-11)

**Resolved.** The worry below (that E103/E105/T1–T3 compiler-blob source edits
left `scaffold/build/B1`'s bytes out of sync with the tree) was checked directly
and does not hold: `chirality_blob scaffold/lib sys-linkage compile-front compile-back
compile-emit compile-all > blob` then `B1 < blob > chirality-bin.new` produces a
**byte-identical** copy of the committed B1 (827768 B), and `chirality-bin.new < blob`
reproduces itself again (fixpoint OK). So the committed B1 **is** a valid
self-hosting fixpoint of the current tree — `tree == binary` holds, no reblob or
promote required. The crossing/prim additions genuinely do not alter the
compiler's self-image (the compiler never calls them). Keep this check
(`B1 < blob | cmp - B1`) as the pre-commit gate whenever compiler-blob sources
change; only reblob+promote if it ever differs.

<details><summary>original 2026-08-10 note (superseded)</summary>

The committed `scaffold/build/B1` = E104's `chirality-bin.new2`. Since then the tree
gained compiler-blob source changes NOT yet in B1: E103's `bytes-tal.chiral` +
E105's `write-fd`. Before any commit: reblob + refixpoint + promote. `selfhost.py
ROOTS` (line 28) records the root list; use `chirality_blob`, never `selfhost.py`.
</details>

---


Concrete, actionable findings surfaced during other work. Each names its
discovery context so it isn't mistaken for the element that found it.

## BUG — `bput-u32-le` truncation → `bslice(start>end)` fault — ROOT-CAUSED & FIXED (E103 impl, 2026-08-10)

`bslice` is `[i, j)` — the 3rd arg is an **exclusive END index**, not a length
(`nb-bslice-t` computes `j - i`, and it **faults instead of clamping** on
`i > j`). The pre-existing `bput-u32-le` passed `(blen - (off+4))` as that END, so
its suffix slice was **truncated** and, for a 4-byte cell at offset 0, degenerated
to `bslice(4, 0)` (start>end) → **fault** — this was the "E104 bslice
end-boundary segfault." Latent because `term.chiral` was the sole caller and only
read back the word it wrote (and the truncated cell was still ≥36 bytes, so E99's
kernel TCSETS still got enough).

- **FIXED** (FLAG B, E103): suffix END → `(blen cell)`, verified against the
  `[i,j)` semantics; `bput-u8` uses the same correct form. E103's 4-write chain
  needs all 60 bytes, so this fix was required for `termios-set-raw`; the pure
  sample (exit 42, all fields + length correct) confirms it.
- **Residual (optional hardening, not blocking):** `nb-bslice-t` itself still
  faults on `i > j` rather than treating it as empty. FLAG B removed the caller
  that generated such calls; whether `bslice` should clamp/empty on `i>=j` is a
  separate robustness call. Regression test worth adding.

## GAP — no surface write-to-arbitrary-fd crossing (found during E104, 2026-08-10)

`put` writes to **stdout only** (`(extern put (=> Str Unit))` → `wrap-put`,
ports.chiral:82). The TAL `nb-sys-write-t` exists in `sys-lib` but is **not
exposed** as a surface `write(fd, bytes)`. So no chirality program can write to an
arbitrary fd (a file, a socket, a pty master).

- **Blocks:** **E103 Step 4** (the pty behavioral test writes a byte to the pty
  master fd) and **E104's full byte round-trip** (both currently prove pty
  *acquisition* — exit 42 — but not master↔slave data flow).
- **Fix:** a small, E104-shaped, **fixpoint-forcing** element — expose
  `(extern write-fd (=> I64 Bytes I64))` (fd, bytes → bytes-written | -errno) over
  the existing `nb-sys-write-t`, with the crossing-table rows (crossing-wraps,
  ports, target-linux SysReg → nr 1, oracle mirror). Unblocks both round-trips.
- **Status:** the natural next small element after E103's fidelity fix lands
  (candidate E105); until then E103 ships Steps 1–3/5 and Step 4 waits.
