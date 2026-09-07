#!/usr/bin/env bash
# xlat -- the translation tier's gather and check tool. Pins the external
# sources a translation rests on, extracts their normative obligations, indexes
# the carriers this tree can actually lower, and verifies that every quote in a
# translation artifact resolves into a pinned source.
#
# No Python, no LLM, no network. Deterministic: the same tree and the same pins
# give the same report. Nothing here summarizes a source. A summary standing in
# for a definition is the failure this tool exists to make impossible, so the
# pin holds bytes and the reading happens in the run.
#
# usage:
#   xlat sources                     what is pinned, with origin and hash
#   xlat pin ID URL ORIGIN FILE      pin FILE as source ID
#   xlat verify                      re-hash every pin against its meta
#   xlat obligations ID              RFC 2119 obligations in a pinned source
#   xlat carriers                    carrier forms live in lib/, and the gaps
#   xlat gather OBJECT               an object's gather manifest and its state
#   xlat bundle OBJECT               everything a translate run reads
#   xlat check ARTIFACT              resolve every pinned-source citation
#
# citation form, matching the tree's file:line idiom:
#   ID:LINE "the quoted span"
#
# exit: 0 clean - 1 findings - 2 cannot run
set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"
SRC="$ROOT/.planning/sources"
ORIGINS="raw transcribed partial"

die() { echo "xlat: $*" >&2; exit 2; }
[ -d "$SRC" ] || die "no $SRC. mkdir it and pin something"

# ── carrier forms, and what each one is evidence of ──────────────────────────
# Each row is: label <TAB> grep pattern <TAB> what it carries.
_carrier_rows() {
  cat <<'EOF'
linear binder|\(1 [a-z][a-zA-Z0-9-]* |a value consumed by use. one-time keys, nonces, capabilities
erased index|\(0 [a-z][a-zA-Z0-9-]* |a compile-time parameter that costs nothing at runtime
indexed data|\(data [A-Za-z][A-Za-z0-9]* \(\(|a type carrying a parameter list, generic or value-indexed
refinement|\(refine |a bound stated in the type
category A module|\(cat A\)|an empty effect row by derivation. no clock, no RNG
closed sum|\(data [A-Za-z][A-Za-z0-9]* \(\) |a finite named alternative set, case coverage checked
EOF
}

# ── lowering gaps a proposed carrier must not walk into ──────────────────────
# Measured, with the citation that established each one. Extend as they close.
_gap_rows() {
  cat <<'EOF'
indexed function-bearing record|does NOT lower|lib/lowering/upper/specialize-singleton.chiral:99-118 matches a projector as exactly one t-lam. An index makes every accessor a two-lambda chain, nothing is rewritten, and the lowerer skips it. Indexed data WITHOUT function fields is fine: lib/memory/mem-region.chiral:31. Function-bearing WITHOUT an index is fine: lib/memory/alloc.chiral:18
EOF
}

_meta() { echo "$SRC/$1.meta"; }
_text() { echo "$SRC/$1.txt"; }
_metaval() { sed -n "s/^$2: //p" "$(_meta "$1")" 2>/dev/null | head -1; }

# ── sources ──────────────────────────────────────────────────────────────────
cmd_sources() {
  local n=0 weak=0
  printf '%-14s %-12s %-12s %8s  %s\n' ID ORIGIN PINNED LINES URL
  for m in "$SRC"/*.meta; do
    [ -e "$m" ] || continue
    local id; id="$(basename "$m" .meta)"
    printf '%-14s %-12s %-12s %8s  %s\n' \
      "$id" "$(_metaval "$id" origin)" "$(_metaval "$id" pinned)" \
      "$(_metaval "$id" lines)" "$(_metaval "$id" url)"
    n=$((n+1))
    [ "$(_metaval "$id" origin)" = raw ] || weak=$((weak+1))
  done
  [ "$n" = 0 ] && { echo "xlat: nothing pinned"; return 1; }
  echo
  echo "xlat: $n pinned, $weak not raw"
  # A non-raw pin is weaker evidence and says so rather than passing as raw.
  [ "$weak" = 0 ] || echo "  a transcribed or partial pin carries the transcriber's reading. Quotes against it are checked against what was transcribed, which is not the source."
  return 0
}

# ── pin ──────────────────────────────────────────────────────────────────────
cmd_pin() {
  local id="${1:-}" url="${2:-}" origin="${3:-}" file="${4:-}"
  [ -n "$id" ] && [ -n "$url" ] && [ -n "$origin" ] && [ -n "$file" ] \
    || die "usage: xlat pin ID URL ORIGIN FILE   (origin: $ORIGINS)"
  case " $ORIGINS " in *" $origin "*) ;; *) die "origin must be one of: $ORIGINS" ;; esac
  [ -f "$file" ] || die "no such file: $file"
  [ -s "$file" ] || die "$file is empty. an empty pin would make every quote fail for the wrong reason"
  cp "$file" "$(_text "$id")"
  {
    echo "id: $id"
    echo "url: $url"
    echo "origin: $origin"
    echo "pinned: $(date -u +%Y-%m-%d)"
    echo "sha256: $(sha256sum "$(_text "$id")" | cut -d' ' -f1)"
    echo "lines: $(grep -c '' "$(_text "$id")")"
    echo "bytes: $(wc -c < "$(_text "$id")" | tr -d ' ')"
  } > "$(_meta "$id")"
  echo "xlat: pinned $id, origin $origin, $(grep -c '' "$(_text "$id")") lines"
  [ "$origin" = raw ] || echo "  NOT RAW. Quotes resolve against the transcription, and the transcription is a claim."
  return 0
}

# ── verify ───────────────────────────────────────────────────────────────────
cmd_verify() {
  local bad=0 n=0
  for m in "$SRC"/*.meta; do
    [ -e "$m" ] || continue
    local id; id="$(basename "$m" .meta)"; n=$((n+1))
    if [ ! -f "$(_text "$id")" ]; then echo "  MISSING  $id has a meta and no text"; bad=$((bad+1)); continue; fi
    local now want; now="$(sha256sum "$(_text "$id")" | cut -d' ' -f1)"; want="$(_metaval "$id" sha256)"
    if [ "$now" != "$want" ]; then
      echo "  DRIFTED  $id"; echo "           meta $want"; echo "           file $now"; bad=$((bad+1))
    fi
  done
  [ "$n" = 0 ] && { echo "xlat: nothing pinned"; return 1; }
  [ "$bad" = 0 ] && { echo "xlat: $n pin(s) verified"; return 0; }
  echo "xlat: $bad of $n pin(s) failed"; return 1
}

# ── obligations ──────────────────────────────────────────────────────────────
# RFC 2119 keywords. The strong set binds an implementation; the weak set is
# reported separately so a run does not treat a MAY as a duty.
cmd_obligations() {
  local id="${1:-}"; [ -n "$id" ] || die "usage: xlat obligations ID"
  local f; f="$(_text "$id")"; [ -f "$f" ] || die "$id is not pinned"
  local strong='MUST NOT|MUST|SHALL NOT|SHALL|REQUIRED'
  local weak='SHOULD NOT|SHOULD|RECOMMENDED|MAY|OPTIONAL'
  echo "=== $id: binding obligations ==="
  grep -nE "\b($strong)\b" "$f" | sed 's/^/  /'
  local sc; sc="$(grep -cE "\b($strong)\b" "$f")"
  echo
  echo "=== $id: weaker keywords, reported and not binding ==="
  grep -nE "\b($weak)\b" "$f" | sed 's/^/  /'
  local wc; wc="$(grep -cE "\b($weak)\b" "$f")"
  echo
  echo "xlat: $sc binding line(s), $wc weaker line(s) in $id"
  echo "  every binding line owes a disposition: carried, unreachable, or deferred."
  [ "$(_metaval "$id" origin)" = raw ] || echo "  ORIGIN $(_metaval "$id" origin): this scan reads a transcription, so a MUST absent from it may still be in the source."
  return 0
}

# ── carriers ─────────────────────────────────────────────────────────────────
cmd_carriers() {
  echo "=== carrier forms, live in lib/ ==="
  _carrier_rows | while IFS='|' read -r label pat what; do
    [ -n "$label" ] || continue
    # a comment line is prose about the form rather than a use of it
    found="$(grep -rnE -- "$pat" "$ROOT/lib" 2>/dev/null \
             | grep -vE '^[^:]+:[0-9]+: *;' | sed "s|$ROOT/||")"
    hits="$(printf '%s' "$found" | grep -c '' )"
    [ -n "$found" ] || hits=0
    echo
    echo "  $label  --  $what"
    if [ "$hits" = 0 ]; then
      echo "    NO PRECEDENT in lib/. Proposing this carrier proposes a new form."
    else
      echo "    $hits use(s), comments excluded. first three:"
      printf '%s\n' "$found" | head -3 | sed 's/^/      /'
    fi
  done
  echo
  echo "=== lowering gaps: a proposed carrier must not walk into one ==="
  _gap_rows | while IFS='|' read -r name state why; do
    [ -n "$name" ] || continue
    echo
    echo "  $name -- $state"
    printf '    %s\n' "$why" | fold -s -w 76 | sed '2,$s/^/    /'
  done
  return 0
}

# ── gather ───────────────────────────────────────────────────────────────────
# An object's manifest. Rows are: slot <TAB> source-id <TAB> state <TAB> note.
# state is `run` or `UNRUN`. An UNRUN row is the point: an ungathered source
# must be visible rather than reading as an absence.
cmd_gather() {
  local obj="${1:-}"; [ -n "$obj" ] || die "usage: xlat gather OBJECT"
  local g="$SRC/$obj.gather"
  [ -f "$g" ] || die "no manifest at .planning/sources/$obj.gather"
  local unrun=0 missing=0 n=0
  echo "=== $obj: gather manifest ==="
  printf '  %-16s %-14s %-8s %s\n' SLOT SOURCE STATE NOTE
  while IFS=$'\t' read -r slot sid state note; do
    case "$slot" in ''|'#'*) continue ;; esac
    printf '  %-16s %-14s %-8s %s\n' "$slot" "$sid" "$state" "${note:-}"
    n=$((n+1))
    [ "$state" = UNRUN ] && unrun=$((unrun+1))
    if [ "$state" = run ] && [ ! -f "$(_text "$sid")" ]; then
      echo "      NOT PINNED: state says run and $sid has no pin"
      missing=$((missing+1))
    fi
  done < "$g"
  echo
  echo "xlat: $n slot(s), $unrun UNRUN, $missing claimed-run-but-unpinned"
  [ "$missing" = 0 ] || return 1
  [ "$unrun" = 0 ] || echo "  an UNRUN slot is a known hole. The artifact must name it, and an audit fails if it does not."
  return 0
}

# ── bundle ───────────────────────────────────────────────────────────────────
cmd_bundle() {
  local obj="${1:-}"; [ -n "$obj" ] || die "usage: xlat bundle OBJECT"
  echo "################ xlat bundle: $obj"
  echo "################ generated $(date -u +%Y-%m-%dT%H:%M:%SZ), deterministic inputs only"
  echo
  cmd_gather "$obj" || true
  echo
  local g="$SRC/$obj.gather"
  while IFS=$'\t' read -r slot sid state note; do
    case "$slot" in ''|'#'*) continue ;; esac
    [ "$state" = run ] || continue
    [ -f "$(_text "$sid")" ] || continue
    echo
    cmd_obligations "$sid"
  done < "$g"
  echo
  cmd_carriers
  return 0
}

# ── check ────────────────────────────────────────────────────────────────────
# Every `ID:LINE "span"` citation in an artifact must resolve into pin ID. This
# is what ledger-lint check U does for tracked files and cannot do for external
# material.
cmd_check() {
  local art="${1:-}"; [ -n "$art" ] || die "usage: xlat check ARTIFACT"
  [ -f "$art" ] || die "no such file: $art"
  local total=0 ok=0 bad=0 drift=0
  while IFS= read -r line; do
    local cite id ln span at
    cite="$(printf '%s' "$line" | grep -oE '[A-Z][A-Z0-9-]+:[0-9]+ "[^"]+"' | head -1)"
    [ -n "$cite" ] || continue
    total=$((total+1))
    id="$(printf '%s' "$cite" | cut -d: -f1)"
    ln="$(printf '%s' "$cite" | cut -d: -f2 | cut -d' ' -f1)"
    span="$(printf '%s' "$cite" | sed 's/^[^"]*"//; s/"$//')"
    if [ ! -f "$(_text "$id")" ]; then
      echo "  UNPINNED  $id is cited and not pinned"; bad=$((bad+1)); continue
    fi
    at="$(grep -nF -- "$span" "$(_text "$id")" 2>/dev/null | head -1 | cut -d: -f1)"
    if [ -z "$at" ]; then
      echo "  NOT FOUND $id:$ln \"$span\""; bad=$((bad+1))
    elif [ "$at" != "$ln" ]; then
      echo "  MOVED     $id:$ln is at :$at now -- \"$span\""; drift=$((drift+1))
    else
      ok=$((ok+1))
    fi
  done < "$art"
  echo
  echo "=== stages ==="
  local s miss=0
  for s in source object conventional carriers refusals "invariant core" laws push limits; do
    if grep -qiE "^#+.*$s" "$art"; then echo "  ok       $s"
    else echo "  ABSENT   $s"; miss=$((miss+1)); fi
  done
  echo
  echo "xlat: $total citation(s): $ok resolved, $drift moved, $bad unresolved. $miss stage(s) absent"
  [ "$total" = 0 ] && echo "  NO CITATIONS. A translation with no pinned quote rests on a reading nobody can check."
  { [ "$bad" = 0 ] && [ "$miss" = 0 ] && [ "$total" != 0 ]; } && return 0
  return 1
}

case "${1:-}" in
  sources)     shift; cmd_sources "$@" ;;
  pin)         shift; cmd_pin "$@" ;;
  verify)      shift; cmd_verify "$@" ;;
  obligations) shift; cmd_obligations "$@" ;;
  carriers)    shift; cmd_carriers "$@" ;;
  gather)      shift; cmd_gather "$@" ;;
  bundle)      shift; cmd_bundle "$@" ;;
  check)       shift; cmd_check "$@" ;;
  ""|-h|--help) sed -n '2,25p' "$(readlink -f "${BASH_SOURCE[0]}")" | sed 's/^# \{0,1\}//' ;;
  *)           die "unknown subcommand: $1" ;;
esac
