# ref: poll(2) — E31

Regenerable: `python3 gen-poll.py`. x86-64 Linux. Each table names its
source; MEASURED means derived by running code on this machine.

## Syscall

| fact | value | source |
|---|---|---|
| `__NR_poll` | **7** | fallback: x86-64 syscall table (unistd_64.h not readable here) |
| args (SysV syscall regs) | rdi = pollfd array ptr, rsi = nfds, rdx = timeout_ms | syscall convention, matches lib/sys-tal.chiral register bank |
| return (rax) | n structs with nonzero revents; 0 = timeout; negative = -errno | poll(2) contract |

## struct pollfd (MEASURED via ctypes)

| field | c type | offset | size |
|---|---|---|---|
| fd | c_int | 0 | 4 |
| events | c_short | 4 | 2 |
| revents | c_short | 6 | 2 |

- **stride = 8 bytes**; entry *i* begins at byte `8*i`;
  an N-entry array cell is `bnew (* N 8)`.
- `fd` is a 32-bit write at +0; `events`/`revents` are 16-bit at +4/+6.
- **revents is KERNEL-WRITTEN**: caller zeroes it; after the crossing it
  is substrate-written evidence to be read back (`bget`) and verified.

## Event bits (source: running CPython `select` module)

| bit | value (hex) |
|---|---|
| POLLIN | 0x1 |
| POLLOUT | 0x4 |
| POLLERR | 0x8 |
| POLLHUP | 0x10 |
| POLLNVAL | 0x20 |
| POLLPRI | 0x2 |

## Timeout semantics

- Milliseconds, `I64` truncated to int; **-1 = block forever; 0 = poll and
  return immediately**; >0 = upper bound on blocking (poll(2) contract).
- EINTR returns -errno like any failure; the caller decides re-arm.
