#!/usr/bin/env bash
# chirality-resolve.sh -- the filesystem SOURCE PROVIDER (sourceable, no Python).
#
# Resolves module references to source bytes. This is chirality's ONE place that
# knows about files-in-a-directory and about which EXTENSIONS name an importable
# kind; the compiler itself is pure (Str -> ELF) and never sees either. Swap this
# file for a different provider (a node store, a content-addressed store, an
# in-image environment) and nothing else changes.
#
#   chirality_blob ROOTSPEC MODULE...
#     writes MODULE and its transitive (import "...") dependencies, in dependency
#     order, concatenated to stdout. Post-order DFS with a shared visited set.
#     ROOTSPEC is a colon-separated search path, e.g. "lib:prog".
#
#   chirality_blob_file ROOTSPEC FILE
#     the same, for a source file at an ARBITRARY path. `chirality_blob`'s roots
#     are root-relative module keys, so they cannot name a file outside the tree;
#     this is the entry point `chirality check` / `chirality compile` need.
#
#   chirality_imports FILE
#     the module keys FILE imports, one per line.
#
# ── The module KEY is the ROOT-RELATIVE PATH ────────────────────────────────
#
# `(import "lowering/x64/mach")`, not `(import "mach")`. The directory IS the
# identity, not decoration: `lowering/mach/mach`, `lowering/x64/mach`,
# `lowering/c/mach` and `lowering/listing/mach` are four keys, and the old
# basename-collision class ("two DIFFERENT modules under one key") is therefore
# UNREACHABLE rather than merely named. Resolution is deterministic per key, so
# a key seen again IS the same module: deduped -- and that dedup is what
# terminates the DFS on cycles and diamonds, so it must stay.
#
# There is NO importer-directory probing leg. The key is the path, so a sibling
# is named by its path like anything else; a second leg would be a second way to
# spell one module, and two spellings is how the collision class came back.
#
# ── The three IMPORTABLE extensions ────────────────────────────────────────
#
# Probed, in this order:
#
#   .chiral    module -- importable computation
#   .port      port registry -- mints capability types
#   .manifest  data a module reads
#
# NOT probed, by definition rather than by rule:
#
#   .prog      an entry cannot be imported. Two entries in one blob is
#              `duplicate label`, so an `(import "prog/compiler")` must be a
#              not-found and not a silent success that breaks at link time.
#   .profile   a profile names a module set the BUILD consumes; nothing imports
#              one.
#
# 44% of the tree never enters the resolution space at all, and that is the
# point: the bad state is unrepresentable, not detected.
#
# What a path CAN still do is exist under two IMPORTABLE extensions in one root
# (`x.chiral` beside `x.port`): one key, two identities. That stays a NAMED
# ERROR -- `module extension collision` -- never a silent pick. The native
# provider (lib/module/resolve.chiral) raises the same refusal as
# `re-ext-collision`; the two providers are pinned against each other.

# The importable extensions, in probe order. Keep in step with
# lib/module/resolve.chiral's try-exts.
CHIRALITY_EXTS=(.chiral .port .manifest)

# chirality_imports FILE -- the module keys FILE imports, one per line.
#
# Comment lines are stripped first. The AUTHORITATIVE provider
# (lib/module/resolve.chiral) parses real s-expressions via `read-all-str`, so a
# doc comment that merely mentions an import form is not a dependency to it; a
# bare grep made it one here. resolve.chiral itself is the proof -- its own
# header comment names an import form.
chirality_imports() {
  { sed -E 's/^[[:space:]]*;.*$//' "$1" 2>/dev/null \
      | grep -oE '\(import "[^"]+"\)' \
      | sed -E 's/.*"([^"]+)".*/\1/'; } || true
}

# _chirality_probe ROOT KEY -- echo the resolved path, or nothing.
#   0 = hit (path on stdout)   1 = miss   2 = extension collision (msg on stderr)
_chirality_probe() {
  local root="$1" key="$2" e hits=()
  for e in "${CHIRALITY_EXTS[@]}"; do
    [ -f "$root/$key$e" ] && hits+=("$root/$key$e")
  done
  case "${#hits[@]}" in
    0) return 1 ;;
    1) printf '%s\n' "${hits[0]}"; return 0 ;;
    *)
      {
        echo "chirality-resolve: module extension collision on '$key'"
        echo "  ${hits[0]} and ${hits[1]} both resolve it"
        echo "  One key, two identities -- rename one."
      } >&2
      return 2 ;;
  esac
}

chirality_blob() {
  local rootspec="$1"; shift
  local -a roots
  IFS=':' read -r -a roots <<< "$rootspec"
  local order=""
  local -A seen=()
  _chirality_walk() {
    local key="$1" parent="$2"
    [ -n "${seen[$key]+x}" ] && return 0     # re-import -- deduped
    local root f="" rc
    for root in "${roots[@]}"; do
      f="$(_chirality_probe "$root" "$key")"; rc=$?
      [ $rc -eq 2 ] && return 1              # collision: already named on stderr
      [ $rc -eq 0 ] && break
      f=""
    done
    if [ -z "$f" ]; then
      {
        echo "chirality-resolve: no module '$key'"
        echo "  searched: ${roots[*]}"
        echo "  extensions probed: ${CHIRALITY_EXTS[*]}  (.prog and .profile are NOT import targets)"
        [ -n "$parent" ] && echo "  imported from $parent"
      } >&2
      return 1
    fi
    seen[$key]="$f"
    local dep
    for dep in $(chirality_imports "$f"); do
      _chirality_walk "$dep" "$f" || return 1
    done
    order="$order $key"
  }
  local r
  for r in "$@"; do _chirality_walk "$r" "" || return 1; done
  # E161 -- the DECLARED module extent. A blob is a flat concatenation, so the
  # module boundary the provider knows is destroyed here unless it is written
  # down. It is written down: one `(end-module "<key>")` after each module's
  # source, naming the module's KEY -- now the root-relative path, which is also
  # what a file's own `(module <path> ...)` coordinate must spell. The compiler
  # closes the module's coordinate there instead of guessing from an `import`.
  # Keep this byte-for-byte identical to lib/module/resolve.chiral's concat-mods
  # -- the two providers are pinned against each other.
  local k
  for k in $order; do
    cat "${seen[$k]}"
    printf '\n(end-module "%s")\n' "$k"
  done
}

# chirality_blob_file ROOTSPEC FILE -- resolve FILE's transitive imports against
# the search path, then append FILE itself.
#
# FILE may live anywhere. It is the ROOT and nothing imports it, so it goes last
# and needs no place in the visited set -- with one exception: if FILE *is* a
# module of one of the roots, a dep may import it back, and then it must be
# resolved as an ordinary root so the dedup covers it. That case is detected by
# PATH, not by name.
chirality_blob_file() {
  local rootspec="$1" file="$2"
  local -a roots
  IFS=':' read -r -a roots <<< "$rootspec"
  local canon_file; canon_file="$(readlink -f "$file" 2>/dev/null)"
  local root canon_root rel e key
  for root in "${roots[@]}"; do
    canon_root="$(readlink -f "$root" 2>/dev/null)"
    [ -n "$canon_root" ] && [ -n "$canon_file" ] || continue
    case "$canon_file" in
      "$canon_root"/*)
        rel="${canon_file#$canon_root/}"
        for e in "${CHIRALITY_EXTS[@]}"; do
          case "$rel" in
            *"$e")
              key="${rel%$e}"
              chirality_blob "$rootspec" "$key"
              return $?
              ;;
          esac
        done
        ;;
    esac
  done
  # Not a module of any root (a .prog entry, a fixture in a mktemp dir): resolve
  # what it imports and append it.
  local deps; deps="$(chirality_imports "$file")"
  if [ -n "$deps" ]; then
    chirality_blob "$rootspec" $deps || return 1
  fi
  # E161: the ROOT gets NO `(end-module ...)` marker. It is a file at an
  # arbitrary path, not a module of any root -- it has no resolver key, and
  # naming its extent after its filename would make the coordinate/extent name
  # check compare a declared coordinate against a mktemp name. Its one trailing
  # extent runs to EOF and is closed there by load-source.
  cat "$file" || return 1
  printf '\n'
}
