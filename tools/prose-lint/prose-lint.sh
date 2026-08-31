#!/usr/bin/env bash
# prose-lint -- the doc tier's PROSE sorter. Finds the tics that make a document
# read as machine-written, ranks the corpus worst-first, and holds a baseline so
# a cleanup pass can be iterated and cannot silently backslide.
#
# No Python, no LLM, no network. Deterministic: the same tree gives the same
# report, so the number going down is the only evidence that anything improved.
#
# usage:
#   prose-lint                  ranked worklist over the default scope
#   prose-lint PATH...          per-line findings for a file or directory
#   prose-lint --summary        totals per check over the scope
#   prose-lint --baseline       record today's counts to the baseline file
#   prose-lint --regress        fail if any file is worse than the baseline
#   prose-lint --checks         what each check matches, and why it is here
#
# exit: 0 clean (or no regressions) - 1 findings (or regressions) - 2 cannot run
set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"
BASELINE="$ROOT/.planning/PROSE-BASELINE.tsv"

# ── the checks ───────────────────────────────────────────────────────────────
# Tier 1 is structural: a shape, not a word. It is what actually saturates this
# corpus (18k em-dashes, 2.8k comma-antitheses) and what a reader notices.
#
# Tier 2 is vocabulary, and is deliberately SHORT. The obvious slop list was
# measured against this tree first and nearly all of it scored zero (delve 0,
# tapestry 0, seamless 0, Furthermore 0). Words that did score -- robust,
# leverage, vital -- are technical here: `robust-shares` is a T3 rung, and
# "highest-leverage row" is a noun. Flagging them would make the linter noise,
# and a linter you learn to ignore is worse than no linter.
_checks_doc() {
  cat <<'EOF'
  em-dash          every —. The single loudest tic; 18,415 of them at baseline.
  antithesis       ", not x" / ", never x" / ", rather than x". Called out by
                   the author twice as a template nobody speaks in.
  copula-negation  "is not just x" / "are not merely x". The same move, wearing
                   a verb.
  not-but          "not x but y".
  parallel-no      "no x, no y" / "never x, never y". Negation used for rhythm.
  slop-word        delve tapestry seamless showcase "testament to" plethora
                   myriad pivotal. Zero legitimate uses measured in this tree.
  throat-clearing  "worth noting" / "important to note" / "in essence" /
                   "at its core" / "in other words". Says a sentence is coming
                   instead of saying it.
  connective       Furthermore / Moreover / "Additionally,".
EOF
}

# ── scope ────────────────────────────────────────────────────────────────────
_scope() {
  if [ "$#" -gt 0 ]; then
    for p in "$@"; do
      [ -d "$p" ] && find "$p" -type f -name '*.md' || { [ -f "$p" ] && echo "$p"; }
    done
  else
    find "$ROOT/docs" "$ROOT/.planning" -type f -name '*.md' 2>/dev/null
    find "$ROOT" -maxdepth 1 -type f -name '*.md' 2>/dev/null
  fi
}

# ── the one pass: file <tab> check <tab> hits <tab> lines ────────────────────
# Code is not prose. Fenced blocks are skipped whole and inline `spans` are
# blanked before counting, so an identifier, a shell snippet or a check name
# quoted in a doc is not a finding. Both the counter and the per-line reporter
# read through this same filter, so a worklist number and its lines agree.
_scan() {
  [ "$#" -eq 0 ] && return 0
  awk '
    FNR == 1 { fence = 0 }
    /^[ \t]*```/ { fence = !fence; lines[FILENAME]++; next }
    fence { lines[FILENAME]++; next }
    {
      $0 = $0
      gsub(/`[^`]*`/, "", $0)
      c["em-dash"]         = gsub(/—/, "&")
      c["antithesis"]      = gsub(/, (not|never|rather than) [a-z]/, "&")
      c["copula-negation"] = gsub(/(is|are|was|were|isn.t|aren.t) not (just |merely |simply )?[a-z]/, "&")
      c["not-but"]         = gsub(/not [a-z]+ but /, "&")
      c["parallel-no"]     = gsub(/[Nn]o [a-z]+, no [a-z]+|[Nn]ever [a-z]+, never /, "&")
      c["slop-word"]       = gsub(/[Dd]elve|[Tt]apestry|[Ss]eamless|[Ss]howcase|testament to|[Pp]lethora|[Mm]yriad|[Pp]ivotal/, "&")
      c["throat-clearing"] = gsub(/worth noting|important to note|[Ii]n essence|[Aa]t its core|[Ii]n other words/, "&")
      c["connective"]      = gsub(/Furthermore|Moreover|Additionally,/, "&")
      for (k in c) tot[FILENAME SUBSEP k] += c[k]
      lines[FILENAME]++
    }
    END {
      for (k in tot) {
        split(k, a, SUBSEP)
        if (tot[k] > 0) printf "%s\t%s\t%d\t%d\n", a[1], a[2], tot[k], lines[a[1]]
      }
    }' "$@"
}

_rel() { sed "s|^$ROOT/||"; }

# ── per-file totals, ranked by DENSITY ───────────────────────────────────────
# Density, not raw count: a 40-line note with 30 em-dashes is a worse read than
# a 900-line spec with 60, and it is also the one you can actually finish.
_worklist() {
  _scan $(_scope "$@") | awk -F'\t' '
    { hits[$1] += $3; lines[$1] = $4 }
    END { for (f in hits) printf "%.2f\t%d\t%d\t%s\n", hits[f]*100/lines[f], hits[f], lines[f], f }
  ' | sort -rn
}

cmd_worklist() {
  local out; out="$(_worklist "$@")"
  [ -z "$out" ] && { echo "prose-lint: clean over the scope"; return 0; }
  printf '%8s  %6s  %6s  %s\n' "PER100" "HITS" "LINES" "FILE"
  echo "$out" | head -40 | while IFS=$'\t' read -r d h l f; do
    printf '%8s  %6s  %6s  %s\n' "$d" "$h" "$l" "$(echo "$f" | _rel)"
  done
  local nf nh
  nf="$(echo "$out" | wc -l)"; nh="$(echo "$out" | awk -F'\t' '{s+=$2} END{print s}')"
  echo
  echo "$nh hits across $nf files. Worst 40 shown; density is hits per 100 lines."
  echo "Per-line detail: prose-lint <file>.   Freeze today: prose-lint --baseline"
  return 1
}

cmd_summary() {
  local out; out="$(_scan $(_scope "$@"))"
  [ -z "$out" ] && { echo "prose-lint: clean over the scope"; return 0; }
  printf '%-18s %8s  %s\n' "CHECK" "HITS" "FILES"
  echo "$out" | awk -F'\t' '{h[$2]+=$3; f[$2]++} END {for (k in h) printf "%-18s %8d  %d\n", k, h[k], f[k]}' \
    | sort -k2 -rn
  return 1
}

# ── per-line findings ────────────────────────────────────────────────────────
cmd_lines() {
  local rc=0
  for f in $(_scope "$@"); do
    local hits
    hits="$(awk '
      FNR == 1 { fence = 0 }
      /^[ \t]*```/ { fence = !fence; next }
      fence { next }
      {
        s = $0
        gsub(/`[^`]*`/, "", s)
        while (match(s, /—|, (not|never|rather than) [a-z]|(is|are|was|were) not (just |merely |simply )?[a-z]|not [a-z]+ but |[Dd]elve|[Tt]apestry|[Ss]eamless|[Ss]howcase|testament to|worth noting|important to note|[Ii]n essence|[Aa]t its core|Furthermore|Moreover/)) {
          printf "%6d  %s\n", FNR, substr(s, RSTART, RLENGTH)
          s = substr(s, RSTART + RLENGTH)
        }
      }' "$f" 2>/dev/null)"
    [ -z "$hits" ] && continue
    rc=1
    echo "=== $(echo "$f" | _rel)  ($(echo "$hits" | wc -l) hits) ==="
    echo "$hits" | head -60
  done
  [ "$rc" -eq 0 ] && echo "prose-lint: clean"
  return $rc
}

cmd_baseline() {
  mkdir -p "$(dirname "$BASELINE")"
  { echo -e "density\thits\tlines\tfile"
    _worklist | while IFS=$'\t' read -r d h l f; do
      printf '%s\t%s\t%s\t%s\n' "$d" "$h" "$l" "$(echo "$f" | _rel)"
    done
  } > "$BASELINE"
  echo "prose-lint: baseline written to $(echo "$BASELINE" | _rel) ($(($(wc -l < "$BASELINE") - 1)) files)"
}

cmd_regress() {
  [ -f "$BASELINE" ] || { echo "prose-lint: no baseline at $(echo "$BASELINE" | _rel)" >&2
                          echo "  run: prose-lint --baseline" >&2; return 2; }
  local now; now="$(mktemp)"
  _worklist | while IFS=$'\t' read -r d h l f; do
    printf '%s\t%s\n' "$(echo "$f" | _rel)" "$h"
  done > "$now"
  local bad=0
  while IFS=$'\t' read -r d h l f; do
    [ "$d" = "density" ] && continue
    local cur; cur="$(awk -F'\t' -v k="$f" '$1==k {print $2}' "$now")"
    cur="${cur:-0}"
    if [ "$cur" -gt "$h" ]; then
      printf '  WORSE  %-58s %s -> %s\n' "$f" "$h" "$cur"; bad=$((bad+1))
    fi
  done < "$BASELINE"
  # a file with no baseline row is new; hold it to zero
  while IFS=$'\t' read -r f h; do
    grep -qP "\t\Q$f\E$" "$BASELINE" || { printf '  NEW    %-58s 0 -> %s\n' "$f" "$h"; bad=$((bad+1)); }
  done < "$now"
  rm -f "$now"
  [ "$bad" -eq 0 ] && { echo "prose-lint: no regressions against the baseline"; return 0; }
  echo; echo "$bad file(s) worse than the baseline."
  return 1
}

case "${1:---worklist}" in
  --worklist) shift; cmd_worklist "$@";;
  --summary)  shift; cmd_summary "$@";;
  --baseline) shift; cmd_baseline;;
  --regress)  shift; cmd_regress;;
  --checks)   _checks_doc;;
  --help|-h)  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//';;
  -*)         echo "prose-lint: unknown flag $1" >&2; exit 2;;
  *)          cmd_lines "$@";;
esac
