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

# ── The two caches, and why they are sound ──────────────────────────────────
#
# Both memoize a PURE function of a static tree: a file's import list is a
# function of its bytes, and a key's resolution is a function of which files
# exist. Neither caches the DFS state -- `seen` and `order` stay per-call, so
# every blob still gets its own visited set and its own dependency order. That
# separation is the whole safety argument: caching the walk would make two
# blobs share a dedup set and silently drop modules from the second.
#
# Scope is one shell process. `bin/chirality` sources this file per invocation,
# so `chirality check` gets a cold cache every time; what the cache is for is
# the callers that resolve MANY roots in ONE shell, which is run-tests.sh's
# Phase 7 (38 roots over one heavily-overlapping closure) and any driver that
# loops. A tree mutated mid-process would be stale, so tools/test/mutant.sh
# resolves each mutated tree in its own subshell; set CHIRALITY_NO_CACHE=1 to
# disable both if a caller ever needs to re-read a tree it just wrote.
#
# ⚑ MEASURED, 2026-08-31, before any of this: resolving prog/compiler.prog cost
# 1657ms against 744ms to COMPILE the 732 KB blob it produces, and a root with
# no imports at all cost 88ms against 14ms. The provider was the dominant cost
# of every gate in the tree, and none of it was compilation.
declare -A _CHIR_IMP=()    # file path        -> its import keys, newline-joined
declare -A _CHIR_PROBE=()  # "root|key"       -> "rc:path"
declare -A _CHIR_SRC=()    # file path        -> its bytes

# chirality_imports FILE -- the module keys FILE imports, one per line.
#
# Comment lines are stripped first. The AUTHORITATIVE provider
# (lib/module/resolve.chiral) parses real s-expressions via `read-all-str`, so a
# doc comment that merely mentions an import form is not a dependency to it; a
# bare grep made it one here. resolve.chiral itself is the proof -- its own
# header comment names an import form.
#
# ⚑ THE PIPELINE STAYS, AND THAT IS A MEASUREMENT RATHER THAN A PREFERENCE.
# It was first rewritten as pure bash to kill the three forks per module. That
# is SLOWER, measured 2026-08-31: resolving prog/compiler.prog went 660ms ->
# 1294ms and a 39-root sweep went 17.3s -> 24.7s, because `sed` and `grep` are C
# reading a file once while bash parameter expansion walks every line of every
# file in the interpreter. Three forks of a fast program beat zero forks of a
# slow one at this size. What is left is the CACHE, which is where the win
# actually was.
chirality_imports() {
  local f="$1"
  if [ -z "${CHIRALITY_NO_CACHE:-}" ] && [ -n "${_CHIR_IMP[$f]+x}" ]; then
    [ -n "${_CHIR_IMP[$f]}" ] && printf '%s\n' "${_CHIR_IMP[$f]}"
    return 0
  fi
  local out
  out="$( { sed -E 's/^[[:space:]]*;.*$//' "$f" 2>/dev/null \
              | grep -oE '\(import "[^"]+"\)' \
              | sed -E 's/.*"([^"]+)".*/\1/'; } || true )"
  [ -z "${CHIRALITY_NO_CACHE:-}" ] && _CHIR_IMP[$f]="$out"
  [ -n "$out" ] && printf '%s\n' "$out"
  return 0
}

# _chirality_deps FILE -- sets the array _CHIR_DEPS. The walker's form.
#
# `for dep in $(chirality_imports "$f")` forks a subshell on EVERY module of
# EVERY blob, cache hit or not, which is the fork the cache could not remove.
# Module keys are root-relative paths and contain no whitespace, so unquoted
# expansion splits them exactly as the command substitution did, without a
# process. ⚑ _CHIR_DEPS is global and `_chirality_walk` RECURSES, so the walker
# must copy it into a local before descending.
_chirality_deps() {
  local f="$1"
  if [ -z "${CHIRALITY_NO_CACHE:-}" ] && [ -n "${_CHIR_IMP[$f]+x}" ]; then
    # shellcheck disable=SC2206
    _CHIR_DEPS=( ${_CHIR_IMP[$f]} ); return 0
  fi
  local out
  out="$( { sed -E 's/^[[:space:]]*;.*$//' "$f" 2>/dev/null \
              | grep -oE '\(import "[^"]+"\)' \
              | sed -E 's/.*"([^"]+)".*/\1/'; } || true )"
  [ -z "${CHIRALITY_NO_CACHE:-}" ] && _CHIR_IMP[$f]="$out"
  # shellcheck disable=SC2206
  _CHIR_DEPS=( $out )
  return 0
}

# _chirality_emit PATH -- write a module's bytes to stdout without forking.
#
# The concat loop ran `cat` once per module per blob: ~150 modules x 39 roots is
# ~5,900 processes to copy files already in the page cache. `read -r -d ''` is a
# shell builtin and reads the whole file, trailing newline included; the bytes
# are then held so a second blob over the same module costs one printf. ⚑ It
# stops at a NUL byte, which no source file in this tree contains -- and the
# guard is not that claim, it is that every blob is byte-compared against the
# pre-change resolver, which a truncation would break loudly.
_chirality_emit() {
  local p="$1" s
  if [ -z "${CHIRALITY_NO_CACHE:-}" ] && [ -n "${_CHIR_SRC[$p]+x}" ]; then
    printf '%s' "${_CHIR_SRC[$p]}"; return 0
  fi
  IFS= read -r -d '' s < "$p" || true
  [ -z "${CHIRALITY_NO_CACHE:-}" ] && _CHIR_SRC[$p]="$s"
  printf '%s' "$s"
  return 0
}

# _chirality_probe_into ROOT KEY -- resolve without forking a subshell.
#   Sets _CHIR_PROBE_PATH. 0 = hit  1 = miss  2 = extension collision (on stderr)
#
# The old form echoed its answer and every caller wrapped it in `$(...)`, which
# is a fork per root per module. A resolve of the compiler walks ~150 modules
# over 2 roots, so that alone was ~300 processes doing six `[ -f ]` tests each.
# A collision is deliberately NOT cached: it prints, and it aborts the walk.
_chirality_probe_into() {
  local root="$1" key="$2" ck="$root|$key" v
  if [ -z "${CHIRALITY_NO_CACHE:-}" ] && [ -n "${_CHIR_PROBE[$ck]+x}" ]; then
    v="${_CHIR_PROBE[$ck]}"; _CHIR_PROBE_PATH="${v#*:}"; return "${v%%:*}"
  fi
  local e hits=()
  for e in "${CHIRALITY_EXTS[@]}"; do
    [ -f "$root/$key$e" ] && hits+=("$root/$key$e")
  done
  case "${#hits[@]}" in
    0) _CHIR_PROBE_PATH=""
       [ -z "${CHIRALITY_NO_CACHE:-}" ] && _CHIR_PROBE[$ck]="1:"
       return 1 ;;
    1) _CHIR_PROBE_PATH="${hits[0]}"
       [ -z "${CHIRALITY_NO_CACHE:-}" ] && _CHIR_PROBE[$ck]="0:${hits[0]}"
       return 0 ;;
    *)
      {
        echo "chirality-resolve: module extension collision on '$key'"
        echo "  ${hits[0]} and ${hits[1]} both resolve it"
        echo "  One key, two identities -- rename one."
      } >&2
      _CHIR_PROBE_PATH=""
      return 2 ;;
  esac
}

# _chirality_probe ROOT KEY -- the echoing form, kept so an external caller that
# learned the old shape still works. Nothing in the tree uses it.
_chirality_probe() {
  _chirality_probe_into "$1" "$2"; local rc=$?
  [ $rc -eq 0 ] && printf '%s\n' "$_CHIR_PROBE_PATH"
  return $rc
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
      _chirality_probe_into "$root" "$key"; rc=$?
      [ $rc -eq 2 ] && return 1              # collision: already named on stderr
      [ $rc -eq 0 ] && { f="$_CHIR_PROBE_PATH"; break; }
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
    # ⚑ copy before descending: _CHIR_DEPS is global and this recurses.
    _chirality_deps "$f"
    local -a deps=("${_CHIR_DEPS[@]}")
    local dep
    for dep in "${deps[@]}"; do
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
    _chirality_emit "${seen[$k]}"
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
