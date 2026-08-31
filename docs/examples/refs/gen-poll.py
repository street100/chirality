#!/usr/bin/env python3
"""Regenerate ref-poll.md: poll(2) ABI facts for E31, derived from LOCAL
sources (this machine IS the platform the hand-tal crossing must match).

Sources, per fact, in order of preference:
- syscall number: /usr/include/asm/unistd_64.h (#define __NR_poll N);
  fallback: the x86-64 syscall table value 7, annotated as fallback.
- struct pollfd layout: MEASURED via ctypes (c_int fd; c_short events;
  c_short revents) -- offsets and sizes derived, not asserted.
- event bits: the running CPython's `select` module constants.
- timeout / return contract: poll(2) semantics, stated (no local oracle).

Run: python3 gen-poll.py    (writes ref-poll.md beside itself)
"""
import ctypes
import os
import re
import select

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "ref-poll.md")


def syscall_number():
    path = "/usr/include/asm/unistd_64.h"
    try:
        text = open(path).read()
        m = re.search(r"#define\s+__NR_poll\s+(\d+)", text)
        if m:
            return int(m.group(1)), path
    except OSError:
        pass
    return 7, "fallback: x86-64 syscall table (unistd_64.h not readable here)"


class Pollfd(ctypes.Structure):
    _fields_ = [
        ("fd", ctypes.c_int),
        ("events", ctypes.c_short),
        ("revents", ctypes.c_short),
    ]


def main():
    nr, nr_src = syscall_number()
    rows = []
    for name, ctyp in Pollfd._fields_:
        f = getattr(Pollfd, name)
        rows.append((name, ctyp.__name__, f.offset, f.size))
    stride = ctypes.sizeof(Pollfd)

    bits = []
    for b in ("POLLIN", "POLLOUT", "POLLERR", "POLLHUP", "POLLNVAL", "POLLPRI"):
        v = getattr(select, b, None)
        if v is not None:
            bits.append((b, v))

    lines = []
    a = lines.append
    a("# ref: poll(2) — E31")
    a("")
    a("Regenerable: `python3 gen-poll.py`. x86-64 Linux. Each table names its")
    a("source; MEASURED means derived by running code on this machine.")
    a("")
    a("## Syscall")
    a("")
    a("| fact | value | source |")
    a("|---|---|---|")
    a(f"| `__NR_poll` | **{nr}** | {nr_src} |")
    a("| args (SysV syscall regs) | rdi = pollfd array ptr, rsi = nfds, rdx = timeout_ms | syscall convention, matches lib/sys-tal.chiral register bank |")
    a("| return (rax) | n structs with nonzero revents; 0 = timeout; negative = -errno | poll(2) contract |")
    a("")
    a("## struct pollfd (MEASURED via ctypes)")
    a("")
    a("| field | c type | offset | size |")
    a("|---|---|---|---|")
    for name, ctyp, off, size in rows:
        a(f"| {name} | {ctyp} | {off} | {size} |")
    a("")
    a(f"- **stride = {stride} bytes**; entry *i* begins at byte `{stride}*i`;")
    a("  an N-entry array cell is `bnew (* N {})`.".format(stride))
    a("- `fd` is a 32-bit write at +0; `events`/`revents` are 16-bit at +4/+6.")
    a("- **revents is KERNEL-WRITTEN**: caller zeroes it; after the crossing it")
    a("  is substrate-written evidence to be read back (`bget`) and verified.")
    a("")
    a("## Event bits (source: running CPython `select` module)")
    a("")
    a("| bit | value (hex) |")
    a("|---|---|")
    for name, v in bits:
        a(f"| {name} | 0x{v:x} |")
    a("")
    a("## Timeout semantics")
    a("")
    a("- Milliseconds, `I64` truncated to int; **-1 = block forever; 0 = poll and")
    a("  return immediately**; >0 = upper bound on blocking (poll(2) contract).")
    a("- EINTR returns -errno like any failure; the caller decides re-arm.")
    a("")

    with open(OUT, "w") as f:
        f.write("\n".join(lines))
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
