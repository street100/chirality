---
element: E<NN>
slug: <slug>
title: <human title>
design: arcs/parts/<arc>-<id>.md
status: draft
updated: <YYYY-MM-DD>
---

# E<NN> SPEC: <human title>

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/<arc>-<id>.md` made the design decisions and an audit gated
> them before this element minted. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** <the one-sentence observable delta, carried from the
  design's §5 call>.
- **Chosen shape:** <the design's call, cited. Do not re-argue it>.
- **Non-goals:** <what this run does not build. Residue lives in §5>.

## 2. What the code forces

The design chose a shape against structural outlines. This is where the live
files push back.

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `file:line` | <assumption> | <what is actually there> | agrees / constrains / **refuses** |

- **Constraints carried into §3:** <an ordering, an extra helper, a name already
  taken>.
- **Refusals:** <a target that will not admit the chosen shape. Do NOT re-decide
  it here: that is a `revisit` on the design with this run as the trigger. Name
  the design artifact and set `status: blocked`.>

## 3. Change plan (ordered, commit-sized)

### Step 1: <name>
- **Target:** `<file>`, at <symbols>
- **Change:** <precise description>
- **Size:** ~<S / M / L>

> A step touching `lib/` or `prog/` is compiler source and owes the build rule in
> [[working-discipline]]: build-new, test, promote, generations from the same
> blob until two consecutive agree, a non-empty check before every `cmp`, a stop
> at `C4`. A comment-only edit counts.

## 4. Conformance gate

- **Baseline:** <what the gate reads today>.
- **Expected:** <what it reads after>.
- **Named phase:** <the phase in `tools/test/run-tests.sh`>.
- **Mutant:** <the mutant that is actually run, and what it breaks. A gate with
  no run mutant passes by looking at nothing>.
- **Done when:** <one sentence an executor can verify>.

## 5. Residue and links

- **Deliberately unbuilt:** <each item with the home that owns it>.
- **Follow-on:** <roster rows, or already-minted elements>.
- **Related:** [[links]].
