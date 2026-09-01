# Two lanes — how the diagnostics work and the file-type work split

**Written 2026-08-31** so two sessions can run at once without colliding. Read
this before starting either lane. The chain both lanes serve is at the top of
`HANDOFF-DIAGNOSTICS-ARC.md`; this file is only the *division*.

---

## The split

| | **Lane A — diagnostics & errors** | **Lane B — file types** |
|---|---|---|
| owns | `E181` pretty · `E182` arity evidence · `E176` `str-sub` · `E179` face registry · `E180` face redraw · adoption of `dg-doc` | `E146` value→source · `E163` `.manifest` · `E183` `.protocol` |
| lands in | `lib/typing/`, `lib/protocol/render*.chiral` | `lib/manifest/` (new), `lib/protocol/` codecs, `prog/` emitters |
| gate phases | **18, 19, 20** | **21, 22, 23** |
| element numbers | **E184–E189** | **E190–E195** |

Phases 1–7 and 13–17 are taken. 8–12 are names still owed to unported old-tree
phases — **do not reuse them**; a number that once meant something else is worse
than a fresh one.

---

## ⚑ The shared seam: `Doc` and `pretty`

Both lanes print. That is the whole collision risk, and it has exactly two parts.

**`lib/prelude/doc.chiral` is FROZEN.** E158 built it, Phase 14 gates it, and
**neither lane may change it** without telling the other. It is a closed sum: a
new constructor is a compile error in every exhaustive `case`, which is the design
working — but it is also an instant cross-lane break. If a lane believes `Doc`
needs an arm, that is a conversation, not a commit.

**`E181` (`typing/pretty.chiral`) belongs to Lane A, and Lane B consumes it.**
The reason is not seniority, it is that Lane A has the forcing consumer already in
the tree: `diag.chiral:125`'s `r-mismatch` carries **two `Term`s** and there is no
reachable `Term` renderer, which is why E158 had to ship `dg-term-tag` as a flat
one-level accessor instead. Lane B's `E146` also needs it — to print chirality
source — but *later in its own sequence*.

**So Lane B starts on the half that does not need it:** the declared form, the
schema, the round-trip gate's shape, and `.protocol`'s codec derivation. It
integrates `pretty` when E181 lands. **Lane B must not write its own term
printer** — that is the duplicate-owner defect this repo has now fixed four times
(`str-cmp`, `list-sort`, `list-dedup-adj`, `Ord`).

---

## File ownership — explicit, so nobody has to guess

**Lane A may write:** `lib/typing/pretty.chiral` · `lib/typing/diag.chiral` ·
`lib/protocol/render.chiral` · `lib/protocol/render-doc.chiral` ·
`lib/prelude/string.chiral` (E176) · `tools/test/{face,render-doc}.sh` and new
Lane-A gates.

**Lane B may write:** `lib/manifest/**` (new) · `lib/protocol/{json,http,wire,apc,vt-parser}.chiral`
· `prog/` emitters · new Lane-B gates.

**Neither may write, without saying so first:** `lib/prelude/doc.chiral` (frozen)
· `bin/chirality-bin` (promote only per the build rule) · another lane's gate
script — every gate sha256-pins its neighbours, so touching one reddens the other
lane's phase.

---

## ⚑ Element numbers: the guard we did not have

`.planning/` is **untracked** by master's own decision, so the element catalog —
the file that makes a number unique — is exactly what git cannot help two sessions
agree on. **This already cost us one collision:** two sessions independently minted
`E173`, and it surfaced only because a merge happened to put both INDEX rows side
by side. Nothing detected it.

**The guard, until something better exists:** each lane mints only inside its own
band above (**A: E184–E189, B: E190–E195**), and a new element's row lands in
`docs/examples/INDEX.md` — which **is** tracked — in the same change that mints it.
The INDEX row is the collision detector; the catalog row is the detail.

---

## Working rules (both lanes)

- **Separate worktree per lane**, off `/workspace/chirality`, living under
  `/workspace`. **Never `/tmp`** — this sandbox is fragile. Never work in
  `/workspace/chirality` itself.
- **Full pipeline per element**: example → audit → SPEC → audit → implement. It has
  earned it — it caught a wrong element premise, a 10× scope error, and nine gate
  rows that could not fail.
- **BUILD RULE:** the committed compiler compiles everything, Python compiles
  nothing. Build-new → test → promote; nothing replaces itself in place.
- **Every gate row needs a named mutant that is actually RUN.** Nine toothless
  rows were found in one session — greps matching their own source, mutants paired
  with rows they cannot move, and once currying turning an arity check into a legal
  partial application. Reading a gate never tells you whether it can fail.
- **Probe before reasoning on anything renderer-shaped.** Source-reading produced a
  confidently wrong premise for E175 that a byte-exact probe refuted in one run.
- **Merge early.** Master moved 25 commits during one arc; the planning tier was
  untracked mid-flight. A long-lived branch pays for itself in conflicts.

---

## What "done" means for each lane

**Lane A:** diagnostics render through `Doc` end to end — a real consumer in
`prog/`, not just the arc's own modules — and the error-quality rows (E182, E176,
E179) are closed. Today `dg-doc` and `doc->rendering` are imported *only* by
`lib/`, which is the fifth "built but unadopted" instance in this repo.

**Lane B:** `.manifest` and `.protocol` exist as declared kinds with derived
codecs and round-trip gates — `parse(source(v)) ≡ v` against source, and against
**bytes** respectively. `LAYOUT.md` gains `.protocol`.

**Both, together:** they are the prerequisites for the real destination —
**replacing the nine Python tools (4,140 lines) with chirality programs and
deleting `tools/`.** Neither lane does that; both exist so it can be done. Not
"no Python in the compile path" — that is already true. **Zero Python in the repo.**
