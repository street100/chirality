---
node: decision-user-layer-extensibility
layer: decision
status: DECIDED (2026-08-22)
decided: 2026-08-22
related: [live-environment, decision-reflective-floor, banks/module, axis-altitude, insp-emacs, open-edges]
---

# Decision — the user layer extends in chirality, live; the kernel is the floor

**Resolves D-S1 *and* D-S2** (`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` §3). Gates
`S11` (init-file load) and shapes every registry `S18`–`S21` builds.

> **Merged 2026-08-22.** These were minted as two decisions — "the extensibility
> model" and "the hook shape". That was a false split: **a hook IS extensibility**,
> just a different feature reaching the same effect. Deciding them apart invited two
> mechanisms where one belongs. One decision, stated once, with the observation half
> as a consequence (§"Hooks are not a second mechanism").

## The question as posed

Is scriba's user layer **data** (ops, keymaps, modes, setups loaded from disk into
the registries that already exist) or **code** (chirality compiled at runtime and linked
into the resident binary, = `E132`)?

It was posed as a fork because two settled things looked opposed:

- `docs/live-environment.md` — *"The environment is the program. You extend it in its
  own language, live … No edit-compile-run seam."*
- `E45` / `reflect-floor.chiral` — `freeze : (1 b SigB) -> Frozen`, no writeback, so
  post-staging reconfiguration is **unexpressible by construction**.

## The decision

**Not a fork. The target is code — extend in chirality, live — and `E45` never forbade
it.** The two claims are about different objects:

- `E45` freezes **the judgment**: the capability kernel that grants ports. That is
  what "cannot be reconfigured from inside" means, and it is the whole security
  argument. `live-environment.md` says the same thing in its own words: *"Emacs draws
  it at the empty set (nothing off limits, hence liveness and no security); chirality
  draws it above a capability kernel that self-modification cannot reach and therefore
  cannot forge authority through."*
- The **user layer** — commands, keymaps, modes, renderers, setups, skills — sits
  entirely **above** that line. Redefining a command cannot forge a port. Nothing in
  `E45` is in tension with recompiling it live.

So the answer to "data or code" is **code, with a floor** — and the floor is drawn
where it was always drawn, not newly imposed on the user layer.

**The precondition is already met.** `live-environment.md` states it exactly:
*"Extension-language equals implementation-language is only true once chirality is
self-hosted. Until then the implementation language is the Python host."* The rung-1
fixpoint landed **2026-08-05** (`B1 == B1(B1)`, zero CPython in the compile path). The
condition the thesis names is satisfied; what remains is mechanism, not permission.

## What this means for the build

1. **`S11` is not redefined as a data-only init loader.** It stays what it is — load
   `~/.config/scriba/init.chiral` — and it is **blocked on `E132`** (runtime dynamic
   loading: a resident binary loads a freshly-compiled artifact). Do not build a
   throwaway data-config format to fill the gap; that would be scaffolding for a seam
   that already has a cataloged answer.
2. **The registries are the seam, and they must be built as such.** `ScribaOp`
   (name, fn, doc) already is one, and it works. `S21` gives `:` commands the same
   shape; `S18` puts them in one state value; `S19`/`S20` make buffers and their
   local state first-class. **Every one of those is on the path to the residential
   target, not a detour around it** — `E132` lands *into* these registries.
3. **Data-loading is legitimate where the thing genuinely is data.** Saved manas
   setups (`:save`/`:load`, JSON on disk, shipped) are values, not code, and stay
   values. The test is whether the thing has behaviour: a keymap is data, a command
   body is code.
4. **The floor gets stated, not assumed.** When `S11` lands, the init file must not
   be able to reach the capability kernel — and that is `E45`'s job structurally, not
   a check `S11` writes. If building `S11` reveals a path from init code to kernel
   reconfiguration, that is an `E45` defect and stops the work.

## What was rejected

- **"User layer is data, permanently."** Rejected: it contradicts invariant 1 of
  `live-environment.md` and would make scriba an application *on* chirality rather than
  an environment *of* it — the exact seam the thesis exists to remove.
- **"Build a data-config init now, migrate later."** Rejected as scaffolding against
  a cataloged element (`E132`). If the wait is unacceptable, the answer is to
  prioritise `E132`, not to build a format that must then be retired.

## Hooks are not a second mechanism

Once the user layer extends in chirality, "hooks" and "advice" stop being features to
design and become consequences to read off:

- **Advice dissolves entirely.** Emacs needs it because a command is not a
  first-class replaceable value — you can only wrap it. Here a command IS a registry
  entry, so "advise `save-buffer`" is *re-register `save-buffer`*. Building an advice
  mechanism would be a second, weaker way to do what the registry already does.
- **What a hook adds over re-registration is exactly one thing: plurality.** If two
  independent parties both re-register `save-buffer`, the second clobbers the first.
  A hook lets N parties observe one moment without any of them owning the command. So
  the hook is not a mechanism — it is a **handler list**, plus a name for the moment.
- **The convention already exists in shipped code — generalize it, do not invent one.**
  `backend.chiral:130` takes an `on-delta` (*"the incremental hook — print to a UI,
  append to a buffer"*, S17) and `turn.chiral:788` takes an `on-step` for the F1
  progress hook, explicitly *"exactly as `call-expert-stream` takes an `on-delta`"*.
  Both are caller-supplied `(=> Str Unit)` callbacks that default to a no-op. So `S25`
  adds exactly two things to an established shape: **plurality** and **named moments**.
  *(Corrected 2026-08-22: an earlier draft of this said there were zero hooks in the
  tree. False — and it nearly justified building a mechanism where a generalization
  was owed.)* There is also kernel precedent for hooks being staging-only:
  `reflect-floor.chiral` installs `VHook`s into `SigB` and drops them at `freeze`.
- **The name of the moment is a which-of-N, so it is a closed sum.**
  `(data ScribaEvent () (ev-after-save …) …)` in the `S18` record, not Emacs's
  string-keyed `add-hook 'symbol` — that is the shape `docs/pattern-boundary-sums.md`
  rejects.

`S25` is therefore not a rival extension model; it is the **observation half of this
one** — an event sum, a handler list, and a `run-handlers` call at each named moment.
No dynamic dispatch machinery, and `E132` extends handlers for free because they are
ordinary chirality registered the ordinary way. `S29`'s completions land on the same event
sum, so there is one vocabulary rather than two.

## Residue

- `E132` (runtime dynamic loading) is `design`, unbuilt — the real gate. It cites the
  `E20` mmap floor + `E51` symbol resolve.
- The exact A/B line *inside* the kernel module — which parts are immutable from
  inside a running chirality — is `E45`/edge 5: direction resolved, **line not drawn, no
  code** (`docs/banks/module.md` §5 item 4). `S11` does not need the line drawn to
  proceed, but the environment is its forcing function, as `live-environment.md` says.
- The exact event set (which moments get names) is an `S25` implementation detail, deliberately not fixed here — name a moment when something needs to observe it, not in advance.
