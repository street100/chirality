#!/usr/bin/env python3
# Fixture: a fake Tool 1b `route` implementing the CLI seam contract, so capture's
# seam (external-tool-preferred) path is exercised without the real router.
# Contract: prints candidate lines  <score>\t<kind>:<id>\t<why>
import sys
q = sys.argv[2].lower() if len(sys.argv) > 2 and sys.argv[1] == "route" else ""
if "custody" in q:
    print("9.9\tbank:custody\tsecret custody warrants its own refraction bank")
elif "widget" in q or "zzqqxx" in q:
    pass  # no candidates -> genuinely new
else:
    print("3.0\tnode:trust-boundary\tfallback-ish generic home")
