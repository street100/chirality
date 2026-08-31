import pty, os, time, select, re, struct, fcntl, termios

pid, fd = pty.fork()
if pid == 0:
    os.environ["TERM"] = "xterm-256color"
    # THE LAUNCHER IT DRIVES DOES NOT EXIST YET. In the old tree this ran
    # `exec ./bin/scriba` -- a build-and-run
    # wrapper that was NOT in this slice's migration list; and scriba itself does
    # not compile here, because it imports the manas subtree (manas/core/*,
    # manas/chatter/*, manas/pipeline/*, manas/profile/*), a separate slice.
    # SCRIBA_CMD is the seam: point it at a launcher when there is one.
    cmd = os.environ.get("SCRIBA_CMD")
    if not cmd:
        os.write(2, b"scriba-run-smoke: set SCRIBA_CMD to the scriba launcher "
                    b"(there is none in the tree yet -- see MIGRATION-NOTES.md)\n")
        os._exit(2)
    os.execv("/bin/bash", ["bash", "-c", cmd])
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 120, 0, 0))

def drain(timeout=2.0):
    out = b""
    while True:
        r, _, _ = select.select([fd], [], [], timeout)
        if not r: break
        try: d = os.read(fd, 65536)
        except OSError: break
        if not d: break
        out += d
        timeout = 0.5
    return out

def send(s, per=0.18):
    for ch in s:
        os.write(fd, bytes([ch])); time.sleep(per)

time.sleep(6)
init = drain(4)
send(b":run"); time.sleep(0.4)      # type the command one key at a time
send(b"\r"); time.sleep(0.5)        # commit
run = drain(40)                     # 6 experts + combiner on qwen2.5:0.5b, streamed (drain as it flows)
os.write(fd, b"\x1b"); time.sleep(0.4)
os.write(fd, b"\x18\x03"); time.sleep(1)

full = init + run
text = re.sub(rb"\x1b\[[0-9;?]*[ -/]*[@-~]", b"", full).replace(b"\x1b", b"").decode("utf-8", "replace")
open("/tmp/scriba_run_smoke.out", "w").write(text)
print("=== bytes:", len(full), " compile-failed:", "compile failed" in text)
for m in ["Run", "GATE", "claim-vs-source", "curate-merge", "OK", "BAD", "COMBINER", "YIELD"]:
    print(f"  run {m!r:16}:", m in text)
print("=== tail (ANSI-stripped) ===")
print(text[-1400:])
