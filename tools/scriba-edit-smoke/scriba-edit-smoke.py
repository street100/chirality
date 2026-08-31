#!/usr/bin/env python3
# scriba-edit-smoke — differential PTY smoke for the scriba EDITING core (S18 G3).
#
# Python is a HARNESS here: it drives a terminal. It compiles nothing (BUILD RULE).
# Usage:  python3 tools/scriba-edit-smoke/scriba-edit-smoke.py <scriba-elf> <frames-out>
#
# Run it against the pre-change binary, then the post-change binary, and diff the
# two frame files. An empty diff is the gate; a diff is a finding.
# PTY scaffolding (pty.fork / TIOCSWINSZ 40x120 / one-byte-at-a-time send /
# ANSI-stripping drain) is copied from tools/scriba-run-smoke/scriba-run-smoke.py:1-35.
#
# The session walks one path through each co-varying block §2.2 of the S18 SPEC
# identified: sc-enter (mode transitions), sc-repaint (puffer+scroll+rendering),
# the Pending operator path, and msg (the status line).

import pty, os, sys, time, select, re, struct, fcntl, termios, signal, hashlib

if len(sys.argv) < 3:
    print("usage: python3 tools/scriba-edit-smoke/scriba-edit-smoke.py <scriba-elf> <frames-out>",
          file=sys.stderr)
    print("  builds nothing: hand it a scriba ELF built with bin/chirality compile.", file=sys.stderr)
    sys.exit(2)
ELF = sys.argv[1]
OUT = sys.argv[2]
HOME = "/tmp/scriba-edit-smoke-home"

os.makedirs(HOME, exist_ok=True)
for f in os.listdir(HOME):
    os.unlink(os.path.join(HOME, f))

pid, fd = pty.fork()
if pid == 0:
    os.environ["TERM"] = "xterm-256color"
    os.environ["HOME"] = HOME
    os.execv("/bin/bash", ["bash", "-c", "cd %s && exec %s" % (HOME, ELF)])
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 120, 0, 0))


def drain(timeout=1.5):
    out = b""
    while True:
        r, _, _ = select.select([fd], [], [], timeout)
        if not r:
            break
        try:
            d = os.read(fd, 65536)
        except OSError:
            break
        if not d:
            break
        out += d
        timeout = 0.4
    return out


def send(s, per=0.12):
    for ch in s:
        try:
            os.write(fd, bytes([ch]))
        except OSError:
            return
        time.sleep(per)


def strip(b):
    t = re.sub(rb"\x1b\[[0-9;?]*[ -/]*[@-~]", b"", b)
    return t.replace(b"\x1b", b"").decode("utf-8", "replace")


frames = []


def step(label, keys, wait=0.5):
    if keys is not None:
        send(keys)
        time.sleep(wait)
    raw = drain()
    frames.append((label, strip(raw), hashlib.md5(raw).hexdigest()))


step("00-init", None)                          # startup frame
step("01-insert", b"i")                        # sc-enter: normal -> insert
step("02-typed", b"hello")                     # sc-repaint: puffer + scroll + rendering
step("03-escape", b"\x1b")                     # sc-enter: insert -> normal
step("04-dd", b"dd")                           # Pending operator path + kill-ring
step("05-p", b"p")                             # register paste
step("06-write", b":w\r", 0.8)                 # msg -- the status line (42/47)
step("07-saveas", b"smoke.txt\r", 0.8)         # the Save-as prompt this raises
step("08-quit", b":q\r", 1.0)                  # teardown, term-restore

time.sleep(0.8)
tail = drain(1.0)
if tail:
    frames.append(("09-tail", strip(tail), hashlib.md5(tail).hexdigest()))

# Reap. If it is still alive after the quit, that is itself a finding.
status = None
for _ in range(20):
    try:
        w, st = os.waitpid(pid, os.WNOHANG)
    except ChildProcessError:
        status = "reaped-elsewhere"
        break
    if w == pid:
        status = "exited rc=%d" % (st >> 8) if os.WIFEXITED(st) else "signalled %r" % st
        break
    time.sleep(0.2)
if status is None:
    status = "STILL RUNNING after :q -- killed"
    os.kill(pid, signal.SIGKILL)
    try:
        os.waitpid(pid, 0)
    except ChildProcessError:
        pass
try:
    os.close(fd)
except OSError:
    pass

saved = sorted(os.listdir(HOME))

with open(OUT, "w") as f:
    for label, text, h in frames:
        f.write("===== %s (raw md5 %s) =====\n" % (label, h))
        f.write(text)
        if not text.endswith("\n"):
            f.write("\n")
    f.write("===== files written =====\n%s\n" % (saved,))
    f.write("===== status =====\n%s\n" % status)

print("wrote", OUT, "frames:", len(frames), "|", status, "| files:", saved)
