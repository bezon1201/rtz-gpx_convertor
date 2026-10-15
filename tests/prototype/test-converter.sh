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
  shift 2
  if "$BIN" "$FIX/$fixture" "$output" "$@" >"$TMP/stdout" 2>"$TMP/stderr"; then fail "accepted $fixture"; fi
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

"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/from-first.gpx" --from-waypoint-id 10 >"$TMP/stdout"
cmp "$TMP/v12.gpx" "$TMP/from-first.gpx" >/dev/null || fail 'selecting the first waypoint changed Full Route output'
"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/from-middle.gpx" --from-waypoint-id 20 >"$TMP/stdout"
[[ "$(grep -c '<rtept ' "$TMP/from-middle.gpx")" -eq 2 ]] || fail 'middle waypoint selection did not produce a two-point suffix'
grep -Fq '<name>SYN-B</name>' "$TMP/from-middle.gpx" || fail 'middle waypoint missing from suffix'
grep -Fq '<name>SYN-C</name>' "$TMP/from-middle.gpx" || fail 'destination waypoint missing from suffix'
! grep -Fq '<name>SYN-A</name>' "$TMP/from-middle.gpx" || fail 'preceding waypoint remained in suffix'
[[ "$(grep -n '<name>SYN-B</name>' "$TMP/from-middle.gpx" | cut -d: -f1)" -lt "$(grep -n '<name>SYN-C</name>' "$TMP/from-middle.gpx" | cut -d: -f1)" ]] || fail 'middle suffix order changed'
grep -Fq '<rtept lat="12.5" lon="23.75">' "$TMP/from-middle.gpx" || fail 'selected middle waypoint coordinates changed'
"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/from-middle-override.gpx" --from-waypoint-id 20 --route-name 'Suffix & Route' >"$TMP/stdout"
grep -Fq '<name>Suffix &amp; Route</name>' "$TMP/from-middle-override.gpx" || fail 'route-name override changed in From Waypoint mode'
[[ "$(grep -c '<rtept ' "$TMP/from-middle-override.gpx")" -eq 2 ]] || fail 'route-name override changed the selected suffix'
"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/from-last.gpx" --from-waypoint-id 30 >"$TMP/stdout"
[[ "$(grep -c '<rtept ' "$TMP/from-last.gpx")" -eq 1 ]] || fail 'last waypoint selection did not produce one route point'
grep -Fq '<name>SYN-C</name>' "$TMP/from-last.gpx" || fail 'last selected waypoint missing'
grep -Fq '<rtept lat="12.75" lon="24">' "$TMP/from-last.gpx" || fail 'last selected waypoint coordinates changed'
reject_without_output valid-rtz-1.2-fields.xml "$TMP/unknown-id.gpx" --from-waypoint-id 999

"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/current-middle.gpx" --current-position 1.5 -2.5 --next-waypoint-id 20 --connector rhumb >"$TMP/stdout"
[[ "$(grep -c '<rtept ' "$TMP/current-middle.gpx")" -eq 3 ]] || fail 'Current Position middle selection produced the wrong point count'
grep -Fq '<rtept lat="1.5" lon="-2.5">' "$TMP/current-middle.gpx" || fail 'current position was not first'
grep -Fq '<rtept lat="12.5" lon="23.75">' "$TMP/current-middle.gpx" || fail 'selected next waypoint was not second'
! grep -Fq '<name>SYN-A</name>' "$TMP/current-middle.gpx" || fail 'preceding waypoint remained in Current Position output'
[[ "$(grep -n '<name>SYN-B</name>' "$TMP/current-middle.gpx" | cut -d: -f1)" -lt "$(grep -n '<name>SYN-C</name>' "$TMP/current-middle.gpx" | cut -d: -f1)" ]] || fail 'Current Position source suffix order changed'
grep -Fq '<name>SYN-Fields-12</name>' "$TMP/current-middle.gpx" || fail 'Current Position source route name changed'
grep -Fq 'rhumb (Rhumb Line / Loxodrome)' "$TMP/stdout" || fail 'selected connector was not reported'
grep -Fq 'connector geometry semantics are not encoded' "$TMP/stdout" || fail 'GPX geometry limitation was not reported'

"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/current-last.gpx" --current-position 1 2 --next-waypoint-id 30 --connector great-circle >"$TMP/stdout"
[[ "$(grep -c '<rtept ' "$TMP/current-last.gpx")" -eq 2 ]] || fail 'final next waypoint should produce exactly two points'
grep -Fq '<rtept lat="1" lon="2">' "$TMP/current-last.gpx" || fail 'current position missing from final-waypoint result'
grep -Fq '<rtept lat="12.75" lon="24">' "$TMP/current-last.gpx" || fail 'final source waypoint missing'
grep -Fq 'great-circle (Great Circle / Orthodrome)' "$TMP/stdout" || fail 'great-circle connector was not reported'

"$BIN" "$FIX/valid-rtz-1.2-fields.xml" "$TMP/current-equal.gpx" --current-position 12.5 23.75 --next-waypoint-id 20 --connector rhumb >"$TMP/stdout"
[[ "$(grep -c '<rtept lat="12.5" lon="23.75">' "$TMP/current-equal.gpx")" -eq 2 ]] || fail 'equal current/next coordinates were deduplicated'
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-latitude.gpx" --current-position 91 2 --next-waypoint-id 20 --connector rhumb
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-longitude.gpx" --current-position 1 181 --next-waypoint-id 20 --connector rhumb
reject_without_output valid-rtz-1.0-fields.xml "$TMP/current-plus-180-v10.gpx" --current-position 1 180 --next-waypoint-id 10 --connector rhumb
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-plus-180-v12.gpx" --current-position 1 180 --next-waypoint-id 10 --connector rhumb
"$BIN" "$FIX/valid-rtz-1.0-fields.xml" "$TMP/current-minus-180.gpx" --current-position 1 -180 --next-waypoint-id 10 --connector rhumb >"$TMP/stdout"
grep -Fq '<rtept lat="1" lon="-180">' "$TMP/current-minus-180.gpx" || fail 'negative 180 longitude should remain valid'
sed 's/lon="23.5"/lon="180"/' "$FIX/valid-rtz-1.0-fields.xml" >"$TMP/source-plus-180-v10.xml"
reject_file_without_output "$TMP/source-plus-180-v10.xml" "$TMP/source-plus-180-v10.gpx"
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-unknown-id.gpx" --current-position 1 2 --next-waypoint-id 999 --connector rhumb
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-missing-connector.gpx" --current-position 1 2 --next-waypoint-id 20
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-invalid-connector.gpx" --current-position 1 2 --next-waypoint-id 20 --connector automatic
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-partial.gpx" --current-position 1 2 --connector rhumb
reject_without_output valid-rtz-1.2-fields.xml "$TMP/current-from-waypoint-conflict.gpx" --current-position 1 2 --next-waypoint-id 20 --connector rhumb --from-waypoint-id 10

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
