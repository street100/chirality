#!/usr/bin/env bash
# Every new_path in the migration map must exist. The map is the record of where
# the 147 originals went, and a row pointing at a path that moved since is a
# record that lies. It drifted twice on 2026-08-31 alone (the ports/ relocation,
# then the root sort), both times silently, which is why this is a script.
#
# Not a suite phase: the map lives under .planning/, which is not tracked, so a
# fresh checkout has no map to check. Run it after any move.
set -uo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
MAP="$ROOT/.planning/MIGRATION-MAP.tsv"
[ -f "$MAP" ] || { echo "map-integrity: no map at .planning/MIGRATION-MAP.tsv"; exit 2; }
bad=0; rows=0
while IFS=$'\t' read -r old new ext why; do
  [ "$old" = old_path ] && continue
  [ -z "$new" ] && continue
  rows=$((rows+1))
  case "$new" in *"{"*) continue ;; esac      # a split row names several files
  [ -e "$ROOT/$new" ] || { echo "  STALE  $old -> $new"; bad=$((bad+1)); }
done < "$MAP"
echo "map-integrity: $rows rows, $bad stale"
[ "$bad" -eq 0 ] || exit 1
