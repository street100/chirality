# scriba-edit-smoke — migration notes

Carried from `bin/scriba-edit-smoke.py` (126 L). Differential PTY smoke for the
scriba editing core (S18 G3). It takes a **scriba ELF** as `argv[1]` and a frames
file as `argv[2]`; it builds nothing itself, so it has no old-tree paths in it.

Changed: an argv guard, so a bare invocation prints usage instead of an
`IndexError` traceback. Nothing else.

Blocked for the same reason as `scriba-run-smoke`: there is no scriba ELF to hand
it. `prog/scriba/scriba-main.prog` imports `manas/core/*`, `manas/chatter/*`,
`manas/pipeline/*`, `manas/profile/*`; only four manas modules were migrated. Once
the manas subtree lands:

```
bin/chirality compile prog/scriba/scriba-main.prog -o /tmp/scriba
python3 tools/scriba-edit-smoke/scriba-edit-smoke.py /tmp/scriba /tmp/frames.txt
```
