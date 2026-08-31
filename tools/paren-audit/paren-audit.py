#!/usr/bin/env python3
"""Paren audit for chirality source files.

Scans for (def and (declare boundaries at top level, counts parentheses
per function body, reports deltas. Finds exactly where a miscount lives:
one command, instant answer.

Usage:
    python3 tools/paren-audit/paren-audit.py FILE.chiral

Exit code 0 if all functions balanced, 1 if any imbalance found.
"""

import re
import sys


def audit(filepath):
    """Scan file and return per-function paren deltas.

    Returns list of (kind, name, start_line, end_line, opens, closes, delta).
    """
    with open(filepath, "r", encoding="utf-8") as fh:
        lines = fh.readlines()

    in_str = False
    esc = False
    depth = 0
    min_depth = 0
    functions = []
    # current = [kind, name, start_line, opens, closes]
    current = None

    for line_no, raw_line in enumerate(lines, start=1):
        line = raw_line.rstrip("\n\r")
        in_comment = False

        for i, ch in enumerate(line):
            if in_comment:
                continue
            if in_str:
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == '"':
                    in_str = False
                continue
            if ch == ";":
                in_comment = True
                continue
            if ch == '"':
                in_str = True
                continue

            if ch == "(":
                depth += 1
                if current is not None:
                    current[3] += 1
                if depth == 1:
                    rest = line[i + 1 :].lstrip()
                    m = re.match(r"(def|declare)\b", rest)
                    if m:
                        if current:
                            functions.append(_finalize(current, line_no))
                        name_part = rest[m.end() :].lstrip()
                        name_match = re.match(r"[^\s();\"]+", name_part)
                        name = name_match.group(0) if name_match else "?"
                        current = [m.group(1), name, line_no, 0, 0]
                        # the opening ( that just fired: count it
                        current[3] = 1

            elif ch == ")":
                depth -= 1
                if depth < min_depth:
                    min_depth = depth
                if current is not None:
                    current[4] += 1
                if depth == 0 and current is not None:
                    functions.append(_finalize(current, line_no))
                    current = None

    if current is not None:
        functions.append(_finalize(current, len(lines)))

    if depth != 0 or min_depth < 0:
        functions.append(("top-level", "(file)", 1, len(lines),
                          0, 0, depth))

    return functions


def _finalize(current, end_line):
    """Close out a function entry and return a result tuple."""
    kind, name, start_line, opens, closes = current
    delta = opens - closes
    return (kind, name, start_line, end_line, opens, closes, delta)


def main(argv):
    if len(argv) < 2:
        print("usage: paren-audit.py FILE (.chiral / .prog / .port / .profile / .manifest)", file=sys.stderr)
        return 1

    filepath = argv[1]
    try:
        results = audit(filepath)
    except FileNotFoundError:
        print(f"paren-audit: {filepath}: no such file", file=sys.stderr)
        return 1
    except IOError as e:
        print(f"paren-audit: {filepath}: {e}", file=sys.stderr)
        return 1

    if not results:
        print(f"{filepath}: no (def ...) or (declare ...) forms found")
        return 0

    problems = 0
    has_func_imbalance = False
    for kind, name, start_line, end_line, opens, closes, delta in results:
        if kind == "top-level":
            continue  # handled after
        if delta != 0:
            has_func_imbalance = True
            problems += 1
            direction = "EXTRA" if delta < 0 else "MISSING"
            print(
                f"{name} ({kind}, line {start_line}-{end_line}): "
                f"opens={opens} closes={closes} delta={delta:+d} "
                f"\u2190 {direction} {abs(delta)}"
            )

    # file-level imbalance: only report when no function covers it
    if not has_func_imbalance:
        for kind, name, start_line, end_line, opens, closes, delta in results:
            if kind == "top-level" and delta != 0:
                problems += 1
                direction = "EXTRA" if delta < 0 else "MISSING"
                print(
                    f"(file-level): depth ended at {delta:+d} "
                    f"\u2190 {direction} {abs(delta)}"
                )

    if problems:
        print(f"\n{problems} function(s) with paren imbalance", file=sys.stderr)
        return 1

    print(f"{filepath}: {len(results)} functions, all balanced")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
