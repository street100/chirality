# scriba-run-smoke — migration notes

Carried from `bin/scriba-run-smoke.py` (40 L). It drives a PTY (40x120, keys one at
a time) at a running scriba and greps the drained frames.

**The thing it drives does not exist here.** The old script hardcoded
`exec ./bin/scriba` — `bin/scriba` is a
build-and-run wrapper that was NOT in this slice's migration list. And scriba would
not launch anyway: `prog/scriba/scriba-main.prog` does not compile, because it
imports `prapanca/core/*`, `prapanca/chatter/*`, `prapanca/pipeline/*` and `prapanca/profile/*`,
and only `prog/prapanca/{backend,coordinator,fsm,manas}` were migrated. The prapanca
subtree is a separate slice.

Changed: the hardcoded launcher became `SCRIBA_CMD`, and with it unset the child
says so on stderr and exits 2 instead of exec'ing into the old tree. Nothing else.

Unblocking it needs, in order: the prapanca subtree migrated → `scriba-main.prog`
compiles → a launcher (the old `bin/scriba`) ported or `SCRIBA_CMD` pointed at
`bin/chirality run prog/scriba/scriba-main.prog`.
