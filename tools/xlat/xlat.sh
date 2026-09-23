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
#   xlat new OBJECT                  scaffold the nine-section artifact
#   xlat unpinned                    external sources this tree names, and their pins
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
#
# EVERY citation on a line is inspected. The `grep -oE … | head -1` this command
# carried until 2026-09-23 read one citation per line: `records/findings.md`
# holds 2,442 citation-shaped spans and the tool reported 159, so 6.5% of the
# corpus carried the whole "citations verified" claim.
#
# The span grammar admits a backslash-escaped double quote. `\"` inside a span
# is read as one quote character and the span resolves against the pin's literal
# bytes, which is what a writer quoting a JSON or a C string line means. 41 of
# the citations in `records/findings.md` carry one and every one of them was
# invisible to the old grammar, which stopped the span at the backslash. An
# unterminated or empty span is MALFORMED. Every one is counted and named.
#
# Resolution is one awk pass. Each cited pin is read once with every span for
# that pin live in memory, so the work is pin-bytes plus spans rather than a
# grep pair per citation.
cmd_check() {
  local art="${1:-}"; [ -n "$art" ] || die "usage: xlat check ARTIFACT"
  [ -f "$art" ] || die "no such file: $art"
  local sep=$'\001'
  local tmp; tmp="$(mktemp -d "${TMPDIR:-/tmp}/xlat-check.XXXXXX")" || die "cannot make a temp dir"
  trap 'rm -rf "$tmp"' RETURN

  # ── extract: one record per citation, in file order ────────────────────────
  # record is  idx SEP kind SEP id SEP line SEP span
  # kind is `plain`, `esc` (the span held a \" ), or `MALFORMED`.
  awk -v SEP="$sep" '
    {
      s = $0; pos = 1
      while (pos <= length(s)) {
        rest = substr(s, pos)
        if (match(rest, /[A-Z][A-Z0-9-]+:[0-9]+ "/) == 0) break
        start = pos + RSTART - 1
        hdr   = substr(s, start, RLENGTH)
        c     = index(hdr, ":")
        id    = substr(hdr, 1, c - 1)
        ln    = substr(hdr, c + 1, length(hdr) - c - 2)
        i = start + RLENGTH
        span = ""; closed = 0; esc = 0
        while (i <= length(s)) {
          ch = substr(s, i, 1)
          if (ch == "\\" && substr(s, i + 1, 1) == "\"") { span = span "\""; esc = 1; i += 2; continue }
          if (ch == "\"") { closed = 1; i++; break }
          span = span ch; i++
        }
        n++
        if (closed == 0)   print n SEP "MALFORMED" SEP id SEP ln SEP "span has no closing quote on this line"
        else if (span == "") print n SEP "MALFORMED" SEP id SEP ln SEP "span is empty"
        else               print n SEP (esc ? "esc" : "plain") SEP id SEP ln SEP span
        pos = i
      }
    }' "$art" > "$tmp/cites"

  # ── which cited sources have a pin ─────────────────────────────────────────
  local id pins=()
  : > "$tmp/pinned"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    if [ -f "$(_text "$id")" ]; then
      printf '%s\n' "$id" >> "$tmp/pinned"
      pins+=("$(_text "$id")")
    fi
  done < <(cut -d"$sep" -f3 "$tmp/cites" | sort -u)

  # ── resolve: every pin read once, every span for it checked on every line ──
  awk -v SEP="$sep" -v PINLIST="$tmp/pinned" -v CITES="$tmp/cites" '
    BEGIN { FS = SEP }
    FILENAME == PINLIST { ispinned[$0] = 1; next }
    FILENAME == CITES {
      n++; idx[n] = $1; kind[n] = $2; cid[n] = $3; cln[n] = $4; span[n] = $5
      if ($2 != "MALFORMED") byid[$3] = byid[$3] " " n
      next
    }
    FNR == 1 { pid = FILENAME; sub(/.*\//, "", pid); sub(/\.txt$/, "", pid); ncur = split(byid[pid], cur, " ") }
    ncur > 0 {
      for (k = 1; k <= ncur; k++) {
        j = cur[k]
        if (index($0, span[j])) { cnt[j]++; if (first[j] == 0) first[j] = FNR }
      }
    }
    END {
      for (j = 1; j <= n; j++) {
        if (kind[j] == "MALFORMED")
          printf "%s%s%s%s%s%s  MALFORMED %s:%s %s\n", idx[j], SEP, "malformed", SEP, kind[j], SEP, cid[j], cln[j], span[j]
        else if (!(cid[j] in ispinned))
          printf "%s%s%s%s%s%s  UNPINNED  %s is cited and not pinned\n", idx[j], SEP, "unpinned", SEP, kind[j], SEP, cid[j]
        else if (cnt[j] == 0)
          printf "%s%s%s%s%s%s  NOT FOUND %s:%s \"%s\"\n", idx[j], SEP, "notfound", SEP, kind[j], SEP, cid[j], cln[j], span[j]
        else if (cnt[j] > 1)
          # A span occurring more than once resolves to whichever came first, which
          # is a citation that points somewhere by accident. Quote a unique span.
          printf "%s%s%s%s%s%s  AMBIGUOUS %s:%s appears %d times -- \"%s\"\n", idx[j], SEP, "ambiguous", SEP, kind[j], SEP, cid[j], cln[j], cnt[j], span[j]
        else if (first[j] != cln[j] + 0)
          printf "%s%s%s%s%s%s  MOVED     %s:%s is at :%d now -- \"%s\"\n", idx[j], SEP, "moved", SEP, kind[j], SEP, cid[j], cln[j], first[j], span[j]
        else
          printf "%s%s%s%s%s%s\n", idx[j], SEP, "ok", SEP, kind[j], SEP
      }
    }' "$tmp/pinned" "$tmp/cites" ${pins[@]+"${pins[@]}"} > "$tmp/res"

  local total=0 ok=0 bad=0 drift=0 mal=0 esc=0 i v k disp
  while IFS="$sep" read -r i v k disp; do
    total=$((total+1))
    [ "$k" = esc ] && esc=$((esc+1))
    case "$v" in
      ok)        ok=$((ok+1)) ;;
      moved)     drift=$((drift+1)) ;;
      malformed) mal=$((mal+1)); bad=$((bad+1)) ;;
      *)         bad=$((bad+1)) ;;
    esac
    [ -n "$disp" ] && printf '%s\n' "$disp"
  done < <(sort -t"$sep" -k1,1n "$tmp/res")

  echo
  echo "=== stages ==="
  local s miss=0
  for s in source object conventional carriers refusals "invariant core" laws push limits; do
    if grep -qiE "^#+.*$s" "$art"; then echo "  ok       $s"
    else echo "  ABSENT   $s"; miss=$((miss+1)); fi
  done
  echo
  echo "xlat: $total citation(s): $ok resolved, $drift moved, $bad unresolved. $miss stage(s) absent"
  [ "$mal" = 0 ] || echo "  $mal of the unresolved are MALFORMED: the grammar is ID:LINE \"span\" and the span above did not parse. Each is named, and none is skipped."
  [ "$esc" = 0 ] || echo "  $esc span(s) carry a backslash-escaped double quote, read as one quote character and resolved against the pin's literal bytes."
  [ "$total" = 0 ] && echo "  NO CITATIONS. A translation with no pinned quote rests on a reading nobody can check."
  { [ "$bad" = 0 ] && [ "$miss" = 0 ] && [ "$total" != 0 ]; } && return 0
  return 1
}


# ── new ──────────────────────────────────────────────────────────────────────
# Scaffolds the nine sections `check` looks for. Writing the artifact by hand
# risks a heading `check` cannot see, which would read as an absent stage.
cmd_new() {
  local obj="${1:-}"; [ -n "$obj" ] || die "usage: xlat new OBJECT"
  local out="$ROOT/docs/translations/$obj.md"
  [ -e "$out" ] && die "$out exists. Edit it, or use revisit against a trigger"
  [ -f "$SRC/$obj.gather" ] || die "no manifest at .planning/sources/$obj.gather. The gather comes first"
  mkdir -p "$ROOT/docs/translations"
  cat > "$out" <<EOF
---
node: translation-$obj
layer: reference
related: [translations/README, definitions/working-discipline, index]
status: draft
updated: $(date -u +%Y-%m-%d)
---

# Translation: $obj

> One published object rendered into this tree's forms. The mathematics is
> external and stays external. Every quote below carries a pinned citation in
> the form \`ID:LINE "span"\`, resolvable by \`tools/xlat/xlat.sh check\`.

## 1. Source

<!-- the gather manifest, and every UNRUN slot named as a hole -->

## 2. Object

<!-- the mathematics in its own terms: signature, laws, security notions,
     preconditions. Quoted from pins, never from memory. -->

## 3. Conventional

<!-- the reference shape, and one bug class per baked-in assumption.
     Generate this column from the binding obligations, not from a reading. -->

## 4. Carriers

<!-- each precondition mapped to a chirality form, with a lib/ precedent.
     tools/xlat/xlat.sh carriers seeds this and names the lowering gaps. -->

## 5. Refusals

<!-- what stops being constructible, derived from section 4 -->

## 6. Invariant core

<!-- what stays byte-identical, which is what keeps the published vectors
     valid. An empty section here means this is a redesign. -->

## 7. Laws and pins

<!-- the properties to test, and which vectors pin which arbitrary constants -->

## 8. Push

<!-- where the type system reaches past what the standard can enforce.
     Generated: properties the object lacks, crossed with carriers available. -->

## 9. Limits

<!-- the binding obligations no carrier reaches, named one by one -->
EOF
  echo "xlat: scaffolded docs/translations/$obj.md"
  echo "  next: xlat bundle $obj"
  return 0
}


# ── unpinned ─────────────────────────────────────────────────────────────────
# Every external source the tree's own prose names, beside whether it is pinned.
# The worklist half. The gate half is ledger-lint check AM, which fails only on
# an attributed quotation: a source named on a line that also quotes it.
#
# ugrep's --exclude-dir is a no-op here even with a glob, so the pinned bodies
# are filtered out by path instead. Scanning them would count every RFC they
# cite as one this tree names.
_SRCPAT='RFC ?[0-9]{3,5}|FIPS ?[0-9]{3}|SP ?800-[0-9]{1,3}|draft-[a-z0-9-]{6,}'

_scan() {
  grep -rnE -- "$_SRCPAT" \
    "$ROOT/docs" "$ROOT/records" "$ROOT/.planning" "$ROOT/CLAUDE.md" "$ROOT/MAP.md" \
    2>/dev/null | grep -v '/\.planning/sources/'
}

_is_pinned() {
  local id="$1" m
  for m in "$SRC"/*.meta; do
    [ -e "$m" ] || continue
    [ "$(basename "$m" .meta)" = "$id" ] && return 0
    grep -qiF -- "$id" "$m" 2>/dev/null && return 0
  done
  return 1
}

cmd_unpinned() {
  local scan named n=0 miss=0 id pin q
  scan="$(_scan)"
  named="$(printf '%s\n' "$scan" | grep -oE -- "$_SRCPAT" | tr -d ' ' | sort -u)"
  [ -n "$named" ] || { echo "xlat: the tree's prose names no external source"; return 0; }
  echo "=== external sources this tree names ==="
  printf '  %-34s %-8s %s\n' SOURCE PINNED QUOTED
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    n=$((n+1))
    if _is_pinned "$id"; then pin=yes; else pin=no; fi
    if printf '%s\n' "$scan" | grep -F -- "$id" | grep -qE '"[^"]{20,}"'; then q=YES; else q=no; fi
    printf '  %-34s %-8s %s\n' "$id" "$pin" "$q"
    { [ "$pin" = no ] && [ "$q" = YES ]; } && miss=$((miss+1))
  done <<EOF
$named
EOF
  echo
  echo "xlat: $n source(s) named, $miss quoted without a pin"
  [ "$miss" = 0 ] && return 0
  echo "  A source quoted without a pin is a claim about a document nobody here has read."
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
  new)         shift; cmd_new "$@" ;;
  unpinned)    shift; cmd_unpinned "$@" ;;
  ""|-h|--help) sed -n '2,27p' "$(readlink -f "${BASH_SOURCE[0]}")" | sed 's/^# \{0,1\}//' ;;
  *)           die "unknown subcommand: $1" ;;
esac
