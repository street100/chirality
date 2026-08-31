# paren-audit — migration notes

Carried from `bin/paren-audit.py` (154 L). **It works unchanged** — it is a pure
text tool over one file handed to it on the command line, with no tree structure in
it at all. Two usage strings updated from `FILE.metis` to the chirality extensions.

```
$ python3 tools/paren-audit/paren-audit.py lib/typing/qtt.chiral
lib/typing/qtt.chiral: 8 functions, all balanced
```

Nothing is blocked.
