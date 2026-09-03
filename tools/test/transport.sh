#!/usr/bin/env bash
# transport.sh -- Phase 20: a model call that leaves this tree and comes back.
#
# Five roots under prog/samples/ carry the transport path end to end: a
# non-streaming HTTP round trip, a streaming SSE chat, the pure framing golden
# under that stream, a socketpair-fed chat-read loop with no network, and a
# request against a closed port. Each compiles with bin/chirality-bin, runs, and
# is judged against the exit code its own header specifies.
#
# WHAT THIS CLOSES. Phase 7 of run-tests.sh sweeps every root in the tree
# compile-only and executes none, so the largest body of built code in the
# repository was gated on whether it parses and lowers. Phase 2's test-runner
# walks a bundled six-sample manifest in prog/test-runner.prog and carries
# nothing from the model path. Before this phase the transport roots had run
# once, by hand, on 2026-09-02.
#
# HERMETIC vs ENDPOINT-BOUND. Three of the five pass on any box with no network:
# the framing golden, the socketpair loop, and the closed-port refusal. Two need
# 100.64.0.5:11434 and are DEFERRED when it does not answer. That deferral is an
# author ruling quoted at prog/samples/e130_http_get.prog:8-9: golden-check
# deferral if the endpoint is unreachable, report honestly, do not gate on it.
# A DEFER counts as neither a pass nor a failure and leaves the phase green on
# the three hermetic assertions.
#
# WHY THE EXIT CODES ARE ADEQUATE. Two assertions expect 42 and two expect 0, so
# a stub echoing one fixed status satisfies at most half the set. The fifth
# assertion reads BYTES: stream-ollama.prog prints the model's answer token by
# token before exiting 0, and an exit code with empty stdout is a path that
# never reached the model. The text itself is not asserted. Two runs of the same
# binary against the same model qwen2.5:0.5b printed "Hello. How may I assist
# you today?" and "Hello, how are you?" on 2026-09-02, and that divergence is
# what says the call is live.
#
# NO MUTANT HARNESS, BY DESIGN. Several phases carry one. This phase's negative
# control is e130_http_request_refused.prog: the adversarial arm of the same
# http-request the positive case exercises, against a closed port, asserting the
# conn-err arm's status -1 rather than a success code.
#
# STANDALONE. run-tests.sh does not fit on a 3.85 GB box with no swap and has
# OOM-killed sessions here, so this script is written to run on its own:
#
#     bash tools/test/transport.sh
#
# ENDPOINT OVERRIDE. CHIRALITY_TRANSPORT_HOST and CHIRALITY_TRANSPORT_PORT move
# the REACHABILITY PROBE only. The two endpoint-bound roots hardcode
# 100.64.0.5:11434 in their own source, so an override pointed at a closed port
# exercises the DEFER branch and says nothing about what those roots would do
# against a different server.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

# Same resolution order as run-tests.sh and linear-mint.sh: one exported
# variable must put a chosen compiler under the whole suite.
CC="${CHIRALITY_COMPILE:-}"
if [ -z "$CC" ]; then
  for c in "$REPO/bin/chirality-bin"; do
    [ -x "$c" ] && { CC="$c"; break; }
  done
fi
[ -n "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }

RESOLVER="$REPO/bin/chirality-resolve.sh"
[ -f "$RESOLVER" ] || { echo "  FAIL  $RESOLVER missing -- a broken checkout is not a configuration"; exit 2; }
# shellcheck disable=SC1090
. "$RESOLVER"
ROOTSPEC="lib:prog"

EP_HOST="${CHIRALITY_TRANSPORT_HOST:-100.64.0.5}"
EP_PORT="${CHIRALITY_TRANSPORT_PORT:-11434}"
PROBE_TIMEOUT=5
RUN_TIMEOUT=30
LIVE_TIMEOUT=90

pass=0; fail=0; defer=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
ulimit -s unlimited

echo "compiler: $CC ($(wc -c <"$CC") bytes)"
echo "endpoint probe: $EP_HOST:$EP_PORT"

# ---- build <root> <artifact> -------------------------------------------------
# Phase 7's own invocation: chirality_blob_file over the root, piped into the
# compiler under an unlimited stack. The artifact is checked NON-EMPTY before
# anything runs it. An empty artifact is a compile that produced nothing, and
# its exit status is a verdict on nothing; docs/definitions/working-discipline.md
# carries that rule for the fixpoint cmp and it reads the same way here.
build() {
  local root="$1" art="$2" n="${3:-x}"
  ( cd "$REPO" && chirality_blob_file "$ROOTSPEC" "$root" ) >"$T/$n.blob" 2>"$T/$n.blob.err" || return 1
  ( ulimit -s unlimited; "$CC" <"$T/$n.blob" >"$art" 2>"$T/$n.cc.err" ) || return 2
  [ -s "$art" ] || return 3
  chmod +x "$art"
  return 0
}

build_fail_msg() {
  local rc="$1" n="$2"
  case "$rc" in
    1) echo "blob step failed: $(tr '\n' ' ' <"$T/$n.blob.err" | head -c 200)" ;;
    2) echo "compile failed: $(tr '\n' ' ' <"$T/$n.cc.err" | head -c 200)" ;;
    3) echo "artifact EMPTY -- a compile that produced nothing" ;;
    *) echo "build failed rc=$rc" ;;
  esac
}

# ---- assert_exit <desc> <root> <want> <timeout> ------------------------------
# Compile the root, run it under a timeout, compare the exit code against the
# one the root's own header specifies. A timeout surfaces as exit 124 and so
# fails loudly rather than stalling the suite.
assert_exit() {
  local desc="$1" root="$2" want="$3" tmo="$4"
  local n="a$((pass+fail+defer))" art rc got
  art="$T/$n.elf"
  build "$REPO/$root" "$art" "$n"; rc=$?
  if [ "$rc" != "0" ]; then
    echo "  FAIL  $desc -- $(build_fail_msg "$rc" "$n")"; fail=$((fail+1)); return
  fi
  timeout "$tmo" "$art" >"$T/$n.out" 2>"$T/$n.err"; got=$?
  if [ "$got" = "124" ]; then
    echo "  FAIL  $desc -- HUNG, killed after ${tmo}s (want exit $want)"; fail=$((fail+1)); return
  fi
  if [ "$got" != "$want" ]; then
    echo "  FAIL  $desc -- exit $got, want $want: $(tr '\n' ' ' <"$T/$n.err" | head -c 200)"
    fail=$((fail+1)); return
  fi
  echo "  ok    $desc (exit $got, $(wc -c <"$art") bytes)"; pass=$((pass+1))
}

# ---- assert_exit_with_output <desc> <root> <want> <timeout> ------------------
# The same, plus stdout must be non-empty. This is the row that an exit code
# alone cannot carry: the model's answer arrives on stdout, and a run that
# exits 0 having printed nothing never reached the model. What came back is
# echoed so a reader sees the live answer in the log. The TEXT is not asserted.
assert_exit_with_output() {
  local desc="$1" root="$2" want="$3" tmo="$4"
  local n="a$((pass+fail+defer))" art rc got
  art="$T/$n.elf"
  build "$REPO/$root" "$art" "$n"; rc=$?
  if [ "$rc" != "0" ]; then
    echo "  FAIL  $desc -- $(build_fail_msg "$rc" "$n")"; fail=$((fail+1)); return
  fi
  timeout "$tmo" "$art" >"$T/$n.out" 2>"$T/$n.err"; got=$?
  if [ "$got" = "124" ]; then
    echo "  FAIL  $desc -- HUNG, killed after ${tmo}s (want exit $want)"; fail=$((fail+1)); return
  fi
  if [ "$got" != "$want" ]; then
    echo "  FAIL  $desc -- exit $got, want $want: $(tr '\n' ' ' <"$T/$n.err" | head -c 200)"
    fail=$((fail+1)); return
  fi
  if [ ! -s "$T/$n.out" ]; then
    echo "  FAIL  $desc -- exit $got with EMPTY stdout; the model path was never reached"
    fail=$((fail+1)); return
  fi
  echo "  ok    $desc (exit $got, $(wc -c <"$T/$n.out") bytes on stdout)"
  echo "        model said: $(tr '\n' ' ' <"$T/$n.out" | head -c 200)"
  pass=$((pass+1))
}

echo
echo "=== Phase 20 A: hermetic, hard-gated -- these must pass with no network ==="

assert_exit "SSE framing golden over hardcoded Bytes, no socket" \
  prog/samples/e131_sse_framing.prog 0 "$RUN_TIMEOUT"

assert_exit "http-request against 127.0.0.1:1, conn-err arm yields status -1" \
  prog/samples/e130_http_request_refused.prog 42 "$RUN_TIMEOUT"

assert_exit "socketpair-fed chat-read loop, then chat-close on done and dead handles" \
  prog/samples/e131_sse_socketpair.prog 0 "$RUN_TIMEOUT"

echo
echo "=== Phase 20 B: endpoint-bound -- deferred when $EP_HOST:$EP_PORT is silent ==="

reachable=0
if timeout "$PROBE_TIMEOUT" bash -c "exec 3<>/dev/tcp/$EP_HOST/$EP_PORT" 2>/dev/null; then
  reachable=1
fi

if [ "$reachable" = 1 ]; then
  echo "  probe: $EP_HOST:$EP_PORT accepted a TCP connection"
  assert_exit "http-request GET /v1/models, status 200 with a non-empty body" \
    prog/samples/e130_http_get.prog 42 "$LIVE_TIMEOUT"
  assert_exit_with_output "chat-open POST /v1/chat/completions, chat-read loop to clean [DONE]" \
    prog/samples/stream-ollama.prog 0 "$LIVE_TIMEOUT"
else
  echo "  ############################################################"
  echo "  #  DEFER  DEFER  DEFER  --  NOT A PASS                     #"
  echo "  ############################################################"
  echo "  DEFER  $EP_HOST:$EP_PORT did not accept a TCP connection within ${PROBE_TIMEOUT}s."
  echo "  DEFER  prog/samples/e130_http_get.prog      -- want exit 42, NOT RUN"
  echo "  DEFER  prog/samples/stream-ollama.prog      -- want exit 0,  NOT RUN"
  echo "  DEFER  Ruling: prog/samples/e130_http_get.prog:8-9 -- report honestly,"
  echo "  DEFER  do not gate on it. Neither root counts as passed or failed."
  echo "  DEFER  chat-open has no subject on this box. chat-read and chat-close"
  echo "  DEFER  keep theirs from the socketpair root above."
  echo "  ############################################################"
  defer=$((defer+2))
fi

echo
echo "transport: $pass passed, $fail failed, $defer deferred"
[ "$fail" -eq 0 ]
