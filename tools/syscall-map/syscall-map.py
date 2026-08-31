#!/usr/bin/env python3
"""Pull the canonical x86-64 syscall table and map it against chirality's
self-hosted floor. Deterministic: parses the kernel header (nr -> name),
classifies each syscall into a family, and joins against the built tal
crossings (lib/sys-tal.chiral) + the typed face (lib/ports.chiral) + the
host referents (impl_ports.py). The output is the coverage ledger --
which syscalls chirality crosses natively, which are faced-but-host-bound, and
which are UNMODELED (see below).

Honest framing (do not overstate coverage): the built crossings are the
syscalls a chirality program *performs*, hand-written so far. They are NOT a
closed governance surface. Today `ti-sys` carries an arbitrary numeric
immediate -- the floor can emit ANY syscall number; the only gate is the
`nb-sys-*` naming discipline, not the model (RUNG-2-MAP WATCH-4). So an
UNMODELED syscall is an UNGOVERNED path on rung 1, exactly the seccomp-hole
P1 names -- not a call chirality has decided it "never needs." Closing the
surface (a default-deny gate keyed to the typed crossing set) is unbuilt
P1 work, and how much of the surface to model is an author decision, NOT
resolved by this script.

Usage:
  syscall-map.py                 # the coverage summary + per-family counts
  syscall-map.py --md            # the full markdown table (docs artifact)
  syscall-map.py --family net    # one family's rows
  syscall-map.py --needed        # only rung-1-relevant syscalls, by status

No network, no guessing: the numbers come from the header on this machine.
"""

import os
import re
import sys

# tools/<name>/<name>.py -> the tree root is THREE levels up, not two.
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HEADER_CANDIDATES = [
    "/usr/include/x86_64-linux-gnu/asm/unistd_64.h",
    "/usr/include/asm/unistd_64.h",
]

# Family classification: prefix/exact rules, first match wins. The point is
# to pre-separate the 360-odd calls into the handful of families the rung-1
# floor actually touches vs the long tail it never will.
FAMILIES = [
    ("fileio",  r"^(read|write|open|openat|close|lseek|pread|pwrite|readv|writev|"
                r"dup|dup2|dup3|pipe|pipe2|fcntl|flock|fsync|fdatasync|truncate|"
                r"ftruncate|sendfile|splice|tee|vmsplice|copy_file_range|"
                r"preadv|pwritev|preadv2|pwritev2)"),
    ("fs",      r"^(stat|fstat|lstat|newfstatat|statx|access|faccessat|"
                r"getdents|getdents64|getcwd|chdir|fchdir|rename|mkdir|rmdir|"
                r"creat|link|unlink|symlink|readlink|chmod|chown|umask|"
                r"mknod|mount|umount|statfs|fstatfs|sync|utimensat|.*at$|"
                r"inotify.*|fanotify.*|name_to_handle_at|open_by_handle_at)"),
    ("memory",  r"^(mmap|munmap|mprotect|brk|mremap|msync|mincore|madvise|"
                r"mlock|munlock|mlockall|munlockall|memfd_create|memfd_secret|"
                r"pkey_.*|mbind|set_mempolicy|get_mempolicy|migrate_pages|"
                r"move_pages|process_vm_readv|process_vm_writev|userfaultfd|"
                r"remap_file_pages|map_shadow_stack)"),
    ("process", r"^(fork|vfork|clone|clone3|execve|execveat|exit|exit_group|"
                r"wait4|waitid|kill|tkill|tgkill|getpid|getppid|gettid|"
                r"getuid|geteuid|getgid|getegid|setuid|setgid|setpgid|getpgid|"
                r"getpgrp|setsid|getsid|setreuid|setregid|setresuid|setresgid|"
                r"getresuid|getresgid|setfsuid|setfsgid|getgroups|setgroups|"
                r"capget|capset|personality|prctl|arch_prctl|set_tid_address|"
                r"unshare|setns|pidfd.*|process_madvise|nice|getpriority|"
                r"setpriority|sched.*|rseq)"),
    ("net",     r"^(socket|socketpair|connect|accept|accept4|bind|listen|"
                r"getsockname|getpeername|send|recv|sendto|recvfrom|sendmsg|"
                r"recvmsg|sendmmsg|recvmmsg|shutdown|setsockopt|getsockopt)"),
    ("poll",    r"^(poll|ppoll|select|pselect6|epoll_create|epoll_create1|"
                r"epoll_ctl|epoll_wait|epoll_pwait|epoll_pwait2|eventfd|"
                r"eventfd2|signalfd|signalfd4|timerfd.*|io_uring.*)"),
    ("time",    r"^(clock_gettime|clock_settime|clock_getres|clock_nanosleep|"
                r"gettimeofday|settimeofday|nanosleep|time|times|adjtimex|"
                r"clock_adjtime|getitimer|setitimer|timer_.*|alarm)"),
    ("signal",  r"^(rt_sig.*|sigaltstack|pause|restart_syscall)"),
    ("ipc",     r"^(shmget|shmat|shmdt|shmctl|semget|semop|semctl|semtimedop|"
                r"msgget|msgsnd|msgrcv|msgctl|mq_.*|futex.*)"),
    ("security",r"^(seccomp|landlock.*|bpf|ptrace|keyctl|add_key|request_key|"
                r"getrandom)"),
    ("system",  r"^(uname|sysinfo|syslog|reboot|sethostname|setdomainname|"
                r"getrlimit|setrlimit|prlimit64|getrusage|acct|"
                r"quotactl|kexec.*|init_module|finit_module|delete_module|"
                r"iopl|ioperm|swapon|swapoff|_sysctl|nfsservctl|vhangup|"
                r"perf_event_open|ioprio_get|ioprio_set|io_setup|io_destroy|"
                r"io_submit|io_cancel|io_getevents|io_pgetevents|"
                r"lookup_dcookie|kcmp|membarrier|modify_ldt)"),
]


def read_header():
    for path in HEADER_CANDIDATES:
        if os.path.exists(path):
            table = {}
            with open(path) as f:
                for line in f:
                    m = re.match(r"#define __NR_(\S+)\s+(\d+)", line)
                    if m:
                        table[m.group(1)] = int(m.group(2))
            return table, path
    sys.exit("no unistd_64.h found; this needs a Linux x86-64 host")


def classify(name):
    for fam, pat in FAMILIES:
        if re.match(pat, name):
            return fam
    return "other"


def _read(path):
    with open(os.path.join(ROOT, path)) as f:
        return f.read()


def chirality_layers():
    """The three built layers, by syscall nr where derivable.
    Returns (crossings_by_nr, faced_syscall_names, referent_names)."""
    tal = _read("lib/lowering/tal/sys.chiral")
    # each crossing: (def nb-sys-NAME ... (ti-sys dst NR (...)))
    crossings = {}  # nr -> nb-sys name
    for m in re.finditer(r'\(def (nb-sys-\S+) TFn', tal):
        name = m.group(1)
        # the nr is the ti-sys immediate in that def's body
        body = tal[m.end():m.end() + 800]
        nrm = re.search(r'\(ti-sys \d+ (\d+)', body)
        if nrm:
            crossings[int(nrm.group(1))] = name
    # ⚑ THE REFERENT LAYER IS GONE. In the old tree this read
    # scaffold/chirality/impl_ports.py -- the Python oracle's @impl registry. The
    # Python oracle is CUT by author decision, so there is no referent set to
    # read and the column is EMPTY rather than guessed. It is not that every
    # crossing lost its referent; it is that this tool can no longer see one.
    # Restoring the column means naming a new referent source, not a new path.
    referents = set()
    return crossings, referents


# The face externs whose REFERENT ultimately reaches a given syscall family,
# hand-declared where the mapping is a composition (a socket call is one
# syscall; pool-create is three). This is the bridge between "face extern"
# and "kernel syscall" that no regex can derive -- kept short and explicit.
FACE_TO_SYSCALL = {
    "put": ["write"], "print": ["write"], "trace": ["write"],
    "fd-close": ["close"], "pool-close": ["munmap", "close"],
    "pool-create": ["memfd_create", "ftruncate", "mmap"],
    "pool-write": [], "time-mono": ["clock_gettime"],
    "sleep-ms": ["nanosleep"], "exit": ["exit_group"],
    "env-get": [], "env-view": [],
    "sock-connect": ["socket", "connect"], "sock-listen": ["socket", "bind", "listen"],
    "sock-accept": ["accept"], "lsock-close": ["close"],
    "sock-send": ["sendto"], "sock-recv": ["recvfrom"], "sock-close": ["close"],
    "sock-send-fd": ["sendmsg"], "poll2": ["poll"],
    "spawn": ["clone", "execve"], "halt": [],
}


def build_rows():
    table, header = read_header()
    crossings, referents = chirality_layers()
    faced_syscalls = {}  # syscall name -> [face externs that reach it]
    for face, calls in FACE_TO_SYSCALL.items():
        for c in calls:
            faced_syscalls.setdefault(c, []).append(face)
    rows = []
    for name, nr in sorted(table.items(), key=lambda kv: kv[1]):
        fam = classify(name)
        built = nr in crossings
        faced = faced_syscalls.get(name, [])
        if built:
            status = "BUILT"
        elif faced:
            status = "FACED"       # a face extern reaches it, host-bound today
        else:
            status = "-"           # UNMODELED: no typed name, no gate (open path)
        rows.append({
            "nr": nr, "name": name, "family": fam, "status": status,
            "crossing": crossings.get(nr, ""), "faces": faced,
        })
    return rows, header


def main(argv):
    rows, header = build_rows()
    mode = argv[1] if len(argv) > 1 else ""
    fam_filter = argv[2] if len(argv) > 2 else None

    if mode == "--md":
        print(f"<!-- generated by tools/syscall-map/syscall-map.py from {header} -->")
        print("| nr | syscall | family | status | crossing | face externs |")
        print("|----|---------|--------|--------|----------|--------------|")
        for r in rows:
            if r["status"] == "-" and r["family"] in ("other", "signal", "ipc",
                                                       "security", "system", "fs"):
                continue  # unmodeled tail elided from the table for length; it
                          # is NOT "never needed" -- see the UNMODELED count in
                          # the summary and the honest-framing note above
            print(f"| {r['nr']} | {r['name']} | {r['family']} | {r['status']} | "
                  f"{r['crossing']} | {' '.join(r['faces'])} |")
        return 0

    if mode == "--family":
        for r in rows:
            if r["family"] == fam_filter:
                print(f"{r['nr']:>4}  {r['name']:<22} {r['status']:<6} "
                      f"{r['crossing']}  {' '.join(r['faces'])}")
        return 0

    if mode == "--needed":
        for st in ("BUILT", "FACED"):
            hits = [r for r in rows if r["status"] == st]
            print(f"\n== {st} ({len(hits)}) ==")
            for r in hits:
                print(f"{r['nr']:>4}  {r['name']:<22} {r['family']:<8} "
                      f"{r['crossing']}  {' '.join(r['faces'])}")
        return 0

    # default: the coverage summary
    total = len(rows)
    built = [r for r in rows if r["status"] == "BUILT"]
    faced = [r for r in rows if r["status"] == "FACED"]
    unmodeled = total - len(built) - len(faced)
    print(f"x86-64 syscalls: {total}   (source: {header})")
    print(f"  BUILT   (native tal crossing):      {len(built):>3}")
    print(f"  FACED   (host-bound, E51 target):   {len(faced):>3}")
    print(f"  UNMODELED (no typed name, no gate): {unmodeled:>3}  "
          f"<- ungoverned on rung 1 until the surface is closed (P1)")
    print("\nby family (built / faced / total):")
    fams = {}
    for r in rows:
        f = fams.setdefault(r["family"], [0, 0, 0])
        f[2] += 1
        if r["status"] == "BUILT":
            f[0] += 1
        elif r["status"] == "FACED":
            f[1] += 1
    for fam, (b, fc, t) in sorted(fams.items(), key=lambda kv: -kv[1][2]):
        bar = "#" * b + "+" * fc
        print(f"  {fam:<9} {b:>2} / {fc:>2} / {t:>3}  {bar}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
