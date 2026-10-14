#!/bin/sh
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RESULT=${1:-"$HERE/results.json"}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/rtz-ip2a-r13.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

CLANG=$(command -v clang)
"$CLANG" -std=c11 -O2 -Wall -Wextra -Werror -Wno-deprecated-declarations \
  "$HERE/resource_probe.c" -o "$TMP/resource_probe"
codesign --force --sign - --timestamp=none "$TMP/resource_probe" >/dev/null
codesign --verify --strict "$TMP/resource_probe"
codesign -dv --verbose=2 "$TMP/resource_probe" 2>"$TMP/codesign.txt"
grep -q 'Signature=adhoc' "$TMP/codesign.txt"
if grep -q 'Authority=' "$TMP/codesign.txt"; then
  echo "Unexpected certificate-backed signer; expected local ad-hoc signature" >&2
  exit 1
fi
codesign -d --entitlements :- "$TMP/resource_probe" >"$TMP/entitlements.plist" 2>/dev/null
if [ -s "$TMP/entitlements.plist" ]; then
  echo "Unexpected embedded entitlements" >&2
  exit 1
fi

"$TMP/resource_probe" >"$TMP/run1.json"
"$TMP/resource_probe" >"$TMP/run2.json"
SOURCE_SHA=$(shasum -a 256 "$HERE/resource_probe.c" | awk '{print $1}')
RUNNER_SHA=$(shasum -a 256 "$HERE/run-probe.sh" | awk '{print $1}')

mkdir -p "$(dirname -- "$RESULT")"
{
  printf '{"format":"ip2a-r13-results-v1","source_sha256":"%s","runner_sha256":"%s","repetitions":[' "$SOURCE_SHA" "$RUNNER_SHA"
  cat "$TMP/run1.json"
  printf ','
  cat "$TMP/run2.json"
  printf ']}\n'
} >"$RESULT"

python3 - "$RESULT" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
d = json.loads(p.read_text())
assert d["format"] == "ip2a-r13-results-v1"
assert len(d["source_sha256"]) == 64 and len(d["runner_sha256"]) == 64
assert len(d["repetitions"]) == 2
serialized = p.read_text()
for forbidden in ("/Users/", "/Volumes/", "/private/", "latitude", "longitude", "waypoint", "vessel"):
    assert forbidden not in serialized, f"unexpected sensitive marker: {forbidden}"
for run in d["repetitions"]:
    assert run["experiment"] == "IP-2A-R13"
    assert run["architecture"] == "arm64"
    assert len(run["runs"]) == 4
    assert [x["mode"] for x in run["runs"]] == ["cpu", "cpu-watchdog", "mem-as", "mem-data"]
    for child in run["runs"]:
        assert child["control"]["setrlimit_accepted"] in (True, False)
        assert child["reaped"] and child["no_orphan_observed"]
        assert not child["child_output_truncated"]
        if child["control"]["setrlimit_accepted"]:
            assert "CHILD_STARTED" in child["child_output"]
        else:
            assert child["child_output"] == "" and child["exit_code"] == 91
        assert "SYNTHETIC_SUCCESS" not in child["child_output"]
        assert "SYNTHETIC_WORK_COMPLETE" not in child["child_output"] or child["exit_code"] == 0
        assert "RTZ" not in child["child_output"] and "GPX" not in child["child_output"]
stable = lambda run: [(x["mode"], x["control"]["resource_id"],
                       x["control"]["setrlimit_errno"], x["control"]["soft_limit"],
                       x["control"]["hard_limit"], x["control"]["setrlimit_accepted"],
                       x["signal"], x["exit_code"], x["watchdog_fired"],
                       x["reaped"], x["no_orphan_observed"],
                       "SYNTHETIC_ALLOCATION_FAILED" in x["child_output"],
                       "SYNTHETIC_WORK_COMPLETE" in x["child_output"])
                      for x in run["runs"]]
assert stable(d["repetitions"][0]) == stable(d["repetitions"][1]), "control outcome varied across repetitions"
print("R13 reproducibility/sanitization checks passed")
PY

printf 'Results written: %s\n' "$RESULT"
