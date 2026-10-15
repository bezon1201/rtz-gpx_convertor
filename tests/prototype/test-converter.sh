#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BIN="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
FIX="$ROOT/tests/fixtures/rtz/synthetic"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
reject_without_output() {
  local fixture="$1" output="$2"
  if "$BIN" "$FIX/$fixture" "$output" >"$TMP/stdout" 2>"$TMP/stderr"; then fail "accepted $fixture"; fi
  [[ ! -e "$output" ]] || fail "partial output exists for $fixture"
}
reject_file_without_output() {
  local input="$1" output="$2"
  if "$BIN" "$input" "$output" >"$TMP/stdout" 2>"$TMP/stderr"; then fail "accepted $input"; fi
  [[ ! -e "$output" ]] || fail "partial output exists for $input"
}

"$BIN" "$FIX/valid-rtz-1.0-fields.xml" "$TMP/v10.gpx" >"$TMP/stdout"
grep -Fq '<name>SYN-Fields-10</name>' "$TMP/v10.gpx" || fail 'RTZ 1.0 route name was not retained'
grep -Fq '<rtept lat="12.25" lon="23.5">' "$TMP/v10.gpx" || fail 'first RTZ 1.0 coordinate missing'
grep -Fq '<rtept lat="12.5" lon="23.75">' "$TMP/v10.gpx" || fail 'second RTZ 1.0 coordinate missing'
grep -Fq '<name>SYN-A</name>' "$TMP/v10.gpx" || fail 'waypoint name missing'

"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/v12.gpx" >"$TMP/stdout"
grep -Fq '<name>SYN-Fields-12</name>' "$TMP/v12.gpx" || fail 'RTZ 1.2 route name was not retained'
[[ "$(grep -c '<rtept ' "$TMP/v12.gpx")" -eq 3 ]] || fail 'expected three ordered route points'
grep '<rtept ' "$TMP/v12.gpx" | sed -n '1p' | grep -Fq 'lat="12.25" lon="23.5"' || fail 'first waypoint order/coordinate incorrect'
grep '<rtept ' "$TMP/v12.gpx" | sed -n '2p' | grep -Fq 'lat="12.5" lon="23.75"' || fail 'second waypoint order/coordinate incorrect'
grep '<rtept ' "$TMP/v12.gpx" | sed -n '3p' | grep -Fq 'lat="12.75" lon="24"' || fail 'third waypoint order/coordinate incorrect'

"$BIN" "$FIX/unicode-route-waypoint-text.xml" "$TMP/unicode.gpx" >"$TMP/stdout"
grep -Fq '<name>SYN-海図-Δ</name>' "$TMP/unicode.gpx" || fail 'Unicode route name was not preserved'
grep -Fq '<name>SYN-北</name>' "$TMP/unicode.gpx" || fail 'Unicode waypoint name was not preserved'

"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/override.gpx" --route-name 'Pilot & <Route>' >"$TMP/stdout"
grep -Fq '<name>Pilot &amp; &lt;Route&gt;</name>' "$TMP/override.gpx" || fail 'route-name override was not XML-escaped'
cmp <(grep '<rtept ' "$TMP/v12.gpx") <(grep '<rtept ' "$TMP/override.gpx") >/dev/null || fail 'route-name override changed waypoint output'
"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/omitted.gpx" --omit-route-name >"$TMP/stdout"
! grep -q '    <name>.*SYN-Fields-12' "$TMP/omitted.gpx" || fail 'explicit omission retained source route name'
reject_without_output missing-route-name.xml "$TMP/missing-name.gpx"
"$BIN" "$FIX/missing-route-name.xml" "$TMP/missing-name-omitted.gpx" --omit-route-name >"$TMP/stdout"

"$BIN" "$FIX/valid-rtz-1.0-fields.xml" "$TMP/deterministic-a.gpx" >"$TMP/stdout"
"$BIN" "$FIX/valid-rtz-1.0-fields.xml" "$TMP/deterministic-b.gpx" >"$TMP/stdout"
cmp "$TMP/deterministic-a.gpx" "$TMP/deterministic-b.gpx" >/dev/null || fail 'GPX output was not deterministic'

cp "$FIX/valid-rtz-1.0-minimal.xml" "$TMP/input with spaces.rtz"
"$BIN" "$TMP/input with spaces.rtz" "$TMP/output with spaces.gpx" >"$TMP/stdout"
grep -Fq '<name>SYN-MIN-10</name>' "$TMP/output with spaces.gpx" || fail 'path with spaces was not handled'
printf 'keep-existing-file\n' >"$TMP/existing.gpx"
if "$BIN" "$FIX/valid-rtz-1.0-minimal.xml" "$TMP/existing.gpx" >"$TMP/stdout" 2>"$TMP/stderr"; then fail 'overwrote an existing output'; fi
grep -Fq 'keep-existing-file' "$TMP/existing.gpx" || fail 'existing output was changed'

reject_without_output malformed-not-well-formed.xml "$TMP/malformed.gpx"
reject_without_output unsupported-version-9.9.xml "$TMP/unsupported.gpx"
reject_without_output wrong-namespace-rtz-1.0.xml "$TMP/wrong-namespace.gpx"
reject_without_output mismatch-version-1.0-namespace-1.2.xml "$TMP/mismatch.gpx"
reject_without_output unsafe-doctype-entity.xml "$TMP/doctype.gpx"
reject_without_output out-of-range-latitude.xml "$TMP/latitude.gpx"
reject_without_output longitude-180-rejected.xml "$TMP/positive-180.gpx"
reject_without_output missing-coordinate.xml "$TMP/missing-coordinate.gpx"
reject_without_output missing-waypoint-id.xml "$TMP/missing-id.gpx"
reject_without_output duplicate-waypoint-id.xml "$TMP/duplicate-id.gpx"
reject_without_output missing-routeInfo.xml "$TMP/missing-route-info.gpx"
reject_without_output missing-waypoints.xml "$TMP/missing-waypoints.gpx"
reject_file_without_output "$ROOT/tests/prototype/fixtures/doctype-without-entities.xml" "$TMP/doctype-no-entities.gpx"
reject_file_without_output "$ROOT/tests/prototype/fixtures/nested-waypoint-extension.xml" "$TMP/nested-waypoint.gpx"
reject_file_without_output "$ROOT/tests/prototype/fixtures/misplaced-position-extension.xml" "$TMP/misplaced-position.gpx"
reject_file_without_output "$ROOT/tests/prototype/fixtures/foreign-waypoint-rtz-position.xml" "$TMP/foreign-waypoint.gpx"

echo 'PASS: RTZ 1.0/1.2, order/coordinates/names, Unicode, route-name choices, paths with spaces, existing-output protection, malformed/unsupported/ambiguous/DOCTYPE rejection, misplaced and foreign-namespace waypoint/position rejection, deterministic output, and no partial output.'
