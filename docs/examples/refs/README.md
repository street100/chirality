# ABI reference bank

Concise, **regenerable** ABI facts for the SPEC-class self-implementation
elements (ELF, syscalls). A ref exists so translating an element to hand-tal is
a *lookup*, not research: exact syscall numbers, struct field/offset/size
tables, register conventions, and constant values — each annotated with the
local source it came from.

## Discipline

- **Local sources only** (raw egress is blocked, and the local platform's real
  values are what the crossings must match): Python stdlib constants
  (`socket`, `select`, `time`, `os`, `errno`), `/usr/include` headers
  (`elf.h`, `bits/*.h`, `asm/unistd_64.h`), and `readelf`/`ausyscall` when
  present (graceful fallback when not).
- **Every ref is emitted by a `gen-<slug>.py` script** committed beside it, so a
  number can never be a hallucination — re-run the script to re-derive it, and
  the output names its source per row. Numbers are `x86-64 Linux` unless a row
  says otherwise.
- A ref is an implementation aid, not a design doc; the worked example
  `E<NN>-<slug>.md` cites it for concrete values and owns the chirality idiom.

## Contents

| Ref | Element | Covers |
|-----|---------|--------|
| [ref-elf.md](ref-elf.md) (`gen-elf.py`) | E34 | ELF64 Ehdr/Phdr field·offset·size tables, minimal static-exec constants + layout math, psABI entry state |
| [ref-fdpass.md](ref-fdpass.md) (`gen-fdpass.py`) | E30 | sendmsg/recvmsg numbers, msghdr/cmsghdr offset tables, CMSG alignment math (self-asserting vs `socket.CMSG_LEN`/`CMSG_SPACE`) |
| [ref-poll.md](ref-poll.md) (`gen-poll.py`) | E31 | poll number, pollfd layout (ctypes-measured, 8-byte stride), event bits, timeout semantics |
| [ref-clock.md](ref-clock.md) (`gen-clock.py`) | E32 | clock_gettime/nanosleep/exit_group numbers, CLOCK_MONOTONIC, timespec layout, ms↔timespec math |
