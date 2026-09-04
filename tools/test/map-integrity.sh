#!/usr/bin/env bash
# Every new_path in the migration map must exist. The map is the record of where
# the 147 originals went, and a row pointing at a path that moved since is a
# record that lies. It drifted twice on 2026-08-31 alone (the ports/ relocation,
# then the root sort), both times silently, which is why this is a script.
#
# not-a-phase: it reads .planning/MIGRATION-MAP.tsv and a person runs it after a move.
# (records/tooling-classification.md TC-09 disputes the reason given below.)
# Not a suite phase: the map lives under .planning/, which is not tracked, so a
# fresh checkout has no map to check. Run it after any move.
set -uo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
MAP="$ROOT/.planning/MIGRATION-MAP.tsv"
[ -f "$MAP" ] || { echo "map-integrity: no map at .planning/MIGRATION-MAP.tsv"; exit 2; }
bad=0; rows=0
# Tab is IFS whitespace, so `IFS=$'\t' read` folds a run of tabs into one
# delimiter and an empty new_path shifts ext left into $new. With ext=prog the
# existence test then read $ROOT/prog and the row passed. Translating to \001
# gives read a non-whitespace delimiter, which does not fold, so an empty field
# stays empty. Reproduced 2026-09-01 with a row whose new_path is empty and
# whose ext is prog: the old loop bound new=prog and the row passed, exit 0.
while IFS=$'\001' read -r old new ext why; do
  [ "$old" = old_path ] && continue
  [ -n "$old$new$ext$why" ] || continue
  rows=$((rows+1))
  case "$new" in *"{"*) continue ;; esac      # a split row names several files
  # A row with no destination records nothing about where the file went. A
  # retired original says so with the brace form, which the branch above skips.
  [ -n "$new" ] || { echo "  NODEST $old"; bad=$((bad+1)); continue; }
  [ -e "$ROOT/$new" ] || { echo "  STALE  $old -> $new"; bad=$((bad+1)); }
done < <(tr '\t' '\001' < "$MAP")
echo "map-integrity: $rows rows, $bad stale"
[ "$bad" -eq 0 ] || exit 1
