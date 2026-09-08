#!/usr/bin/env bash
# crypto-kernel.sh -- the driver behind docs/benchmarks/crypto-kernel-allocation.md.
#
# Measures what lib/crypto/chacha.chiral costs per byte and whether its Q4 and
# St products survive to runtime as arena cells. Reads nothing out of lib/ or
# prog/ and writes nothing into them: every subject is generated here and run
# with `chirality run` / `chirality compile`, which carry no build ceremony.
#
# usage: tools/bench/crypto-kernel.sh [alloc|time|xor|sites|all]  (default all)
#
# The instrument is `heap-allocated` (lib/ports/process.port:36), the arena's
# own bump cursor: heapptr - heapbase is total bytes ever allocated exactly,
# not an inference from residency.
set -u
ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"
CH="$ROOT/bin/chirality"
W="${TMPDIR:-/tmp}/chirality-crypto-bench"
mkdir -p "$W"
MODE="${1:-all}"

# The RFC 8439 §2.3.2 key and nonce. Held in one place because every subject
# below needs them and a top-level (def _ Bytes ...) is re-evaluated at every
# reference -- measured at 336 B for the key, 88 B for the nonce -- so every
# subject binds them ONCE and threads them as parameters.
cat > "$W/common.inc" <<'CHIRAL'
(def bk-key Bytes
  (bcat (pack-u32 50462976)  (bcat (pack-u32 117835012)
  (bcat (pack-u32 185207048) (bcat (pack-u32 252579084)
  (bcat (pack-u32 319951120) (bcat (pack-u32 387323156)
  (bcat (pack-u32 454695192) (pack-u32 522067228)))))))))
(def bk-nonce Bytes
  (bcat (pack-u32 150994944) (bcat (pack-u32 1241513984) (pack-u32 0))))
(def bk-say (=> Str I64 I64 Unit)
  (lam (lbl v sink)
    (put (str-cat lbl (str-cat " " (str-cat (i64->str v)
         (str-cat " sink=" (str-cat (i64->str sink) "\n")))))))) 
CHIRAL
hdr() { printf '(import "prelude/prelude")\n(import "crypto/chacha")\n(import "ports/stdio")\n(import "ports/process")\n'; cat "$W/common.inc"; }

# ── the ARX baseline ─────────────────────────────────────────────────────────
# qround's body verbatim (lib/crypto/chacha.chiral:50-56) with the SAME add32
# and rotl32, four lanes carried as PARAMETERS instead of returned in a Q4.
# Identical arithmetic, no product constructed. Its measured allocation is 0.
ARX='(def arx (-> I64 I64 I64 I64 I64 I64)
  (lam (a b c d n)
    (case (<i 0 n)
      (true (let ((a1 (add32 a b)) (d1 (rotl32 (bxor d a1) 16))
                  (c1 (add32 c d1)) (b1 (rotl32 (bxor b c1) 12))
                  (a2 (add32 a1 b1)) (d2 (rotl32 (bxor d1 a2) 8))
                  (c2 (add32 c1 d2)) (b2 (rotl32 (bxor b1 c2) 7)))
              (arx a2 b2 c2 d2 (- n 1))))
      (false (bxor a (bxor b (bxor c d)))))))'
STDES='((st a b c d e f g h j l m o p q r t)'

# ── subjects ─────────────────────────────────────────────────────────────────
# gen <file> <N> <body-def> <call>   -- N iterations, allocation delta printed.
gen() {
  { hdr; printf '%s\n\n' "$3"
    cat <<CHIRAL
(def compile-main (=> I64 I64)
  (lam (n)
    (let ((k bk-key))
      (let ((v bk-nonce))
        (let ((w (bget k 1)))
          (let ((a0 (heap-allocated unit)))
            (let ((r $4))
              (let ((a1 (heap-allocated unit)))
                (let ((_ (bk-say "$2" (- a1 a0) r)))
                  0)))))))))
CHIRAL
  } > "$1"
}

gen "$W/sA.prog" "sA-block-alloc" \
"(def lp (-> Bytes Bytes I64 I64 I64)
  (lam (k v i acc)
    (case (<i 0 i)
      (true (lp k v (- i 1) (bxor acc (bget (chacha-block k v i) 0))))
      (false acc))))" "(lp k v (* w \$N) w)"

gen "$W/sD.prog" "sD-rounds-alloc" \
"(def lp (-> Bytes Bytes I64 I64 I64)
  (lam (k v i acc)
    (case (<i 0 i)
      (true (case (rounds (block-init k v i) 10) $STDES (lp k v (- i 1) (bxor acc a)))))
      (false acc))))" "(lp k v (* w \$N) w)"

gen "$W/sI.prog" "sI-init-alloc" \
"(def lp (-> Bytes Bytes I64 I64 I64)
  (lam (k v i acc)
    (case (<i 0 i)
      (true (case (block-init k v i) $STDES (lp k v (- i 1) (bxor acc a)))))
      (false acc))))" "(lp k v (* w \$N) w)"

gen "$W/sR1.prog" "sR1-one-dround-alloc" \
"(def lp (-> Bytes Bytes I64 I64 I64)
  (lam (k v i acc)
    (case (<i 0 i)
      (true (case (rounds (block-init k v i) 1) $STDES (lp k v (- i 1) (bxor acc a)))))
      (false acc))))" "(lp k v (* w \$N) w)"

gen "$W/sF.prog" "sF-add-alloc" \
"(def lp (-> Bytes Bytes I64 I64 I64)
  (lam (k v i acc)
    (case (<i 0 i)
      (true (let ((s (block-init k v i)))
              (case (st-add s (rounds s 10)) $STDES (lp k v (- i 1) (bxor acc a))))))
      (false acc))))" "(lp k v (* w \$N) w)"

gen "$W/sB.prog" "sB-arx-alloc" "$ARX" "(arx w 7 11 13 (* w \$A))"

# ── run-10 / honest-spread timing ────────────────────────────────────────────
bench() { # bench <elf> <label>
  local t; TIMEFORMAT='%R %U %S'; local R=() U=() S=()
  for _ in 1 2; do (ulimit -s unlimited; "$1") >/dev/null 2>&1; done
  for _ in $(seq 1 10); do
    t=$( { time (ulimit -s unlimited; "$1" >/dev/null 2>&1); } 2>&1 )
    R+=("${t%% *}"); U+=("$(echo "$t"|awk '{print $2}')"); S+=("$(echo "$t"|awk '{print $3}')")
  done
  st() { printf '%s\n' "$@" | sort -g | awk '{a[NR]=$1} END{printf "%.3f/%.3f/%.3f", a[1], a[int((NR+1)/2)], a[NR]}'; }
  printf '%-22s real %s  user %s  sys %s\n' "$2" "$(st "${R[@]}")" "$(st "${U[@]}")" "$(st "${S[@]}")"
}

build() { N="$2" A=$((${2}*80)) envsubst '$N $A' < "$1" > "$W/x.prog" 2>/dev/null \
  || sed -e "s/\$N/$2/g" -e "s/\$A/$((${2}*80))/g" "$1" > "$W/x.prog"
  "$CH" compile "$W/x.prog" -o "$3" >/dev/null; }

echo "== host =="
printf 'date %s  head %s  vcpu %s  loadavg %s\n' "$(date -Iseconds)" "$(git -C "$ROOT" rev-parse --short HEAD)" "$(nproc)" "$(cut -d' ' -f1-3 /proc/loadavg)"
printf 'cpu %s  MHz %s  MemTotal %s\n' "$(grep -m1 'model name' /proc/cpuinfo|cut -d: -f2-)" "$(grep -m1 'cpu MHz' /proc/cpuinfo|cut -d: -f2-)" "$(grep -m1 MemTotal /proc/meminfo|awk '{print $2}')"
printf 'compiler sha256 %s\n' "$(sha256sum "$ROOT/bin/chirality-bin"|cut -c1-24)"

if [ "$MODE" = alloc ] || [ "$MODE" = all ]; then
  echo; echo "== allocation, bytes per iteration over 1000 iterations =="
  for s in sI sR1 sD sF sA sB; do
    build "$W/$s.prog" 1000 "$W/e-$s"
    out=$( (ulimit -s unlimited; "$W/e-$s") )
    lbl=$(echo "$out"|awk '{print $1}'); tot=$(echo "$out"|awk '{print $2}')
    printf '  %-22s %10d total  %8d per iteration\n' "$lbl" "$tot" $((tot/1000))
  done
fi

if [ "$MODE" = sites ] || [ "$MODE" = all ]; then
  echo; echo "== inline bump-allocation sites in the emitted ELF =="
  echo "   x-galo emits 'lea rcx,[rax+sz]' twice per site (mach.chiral:513,519);"
  echo "   sz = 8*(1+fields), so Q4 -> 40 and St -> 136."
  build "$W/sA.prog" 1000 "$W/e-sA"
  python3 - "$W/e-sA" <<'PY'
import sys
d=open(sys.argv[1],'rb').read()
for sz,n in ((40,'Q4  4 fields'),(136,'St 16 fields')):
    p=bytes([0x48,0x8d,0x88])+sz.to_bytes(4,'little')
    c=d.count(p)
    print(f'   lea rcx,[rax+{sz:>3}]  x{c}  = {c//2} allocation site(s)   {n}')
PY
fi

if [ "$MODE" = time ] || [ "$MODE" = all ]; then
  N=100000
  echo; echo "== timing, N=$N blocks (6,400,000 B of keystream) vs 80N ARX quarter-rounds =="
  for s in sB sD sA; do build "$W/$s.prog" "$N" "$W/e-$s"; done
  for pass in 1 2 3; do
    echo "  pass $pass"
    bench "$W/e-sB" "    sB ARX 8,000,000qr"
    bench "$W/e-sD" "    sD init+10dr x$N"
    bench "$W/e-sA" "    sA block     x$N"
  done
fi

if [ "$MODE" = xor ] || [ "$MODE" = all ]; then
  echo; echo "== chacha-xor, the stream path, one call per run =="
  for K in 14 15 16 17; do
    { hdr; cat <<CHIRAL
(def x-dbl (-> Bytes I64 Bytes)
  (lam (m k) (case (<i 0 k) (true (x-dbl (bcat m m) (- k 1))) (false m))))
(def compile-main (=> I64 I64)
  (lam (n)
    (let ((msg (x-dbl bk-key $((K-5)))))
      (let ((a0 (heap-allocated unit)))
        (let ((ct (chacha-xor bk-key bk-nonce 1 msg)))
          (let ((a1 (heap-allocated unit)))
            (let ((_ (bk-say (str-cat "msglen=" (i64->str (blen msg))) (- a1 a0) (bget ct 0))))
              0)))))))
CHIRAL
    } > "$W/sX.prog"
    "$CH" compile "$W/sX.prog" -o "$W/e-sX" >/dev/null
    printf '  %s\n' "$( (ulimit -s unlimited; "$W/e-sX") )"
    bench "$W/e-sX" "    xor 2^$K B"
  done
fi
