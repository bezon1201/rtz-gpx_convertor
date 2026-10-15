# RTZ-GPX-Converter

A proposed offline macOS Apple Silicon utility for converting maritime RTZ route plans into GPX 1.1 routes for personal weather assessment in Windy. V1's approved direction is a macOS Shortcut invoking a self-contained local CLI. It is not an ECDIS replacement or an approved navigation system.

## Project status

**Development prototype only.** This branch includes a small offline command-line converter for RTZ 1.0 and 1.2 input, supporting Full Route and From Waypoint by explicit source waypoint ID. It writes deterministic GPX 1.1, preserves waypoint order, validates coordinates, rejects malformed/unsupported/unsafe XML, and does not publish partial output.

The prototype is **not schema validated** and does not claim RTZ 1.0/1.2 conformance or product support. It handles only the fields needed for this demonstration; other RTZ metadata is ignored. It has no GUI, Shortcuts/Finder integration, worker, IPC, packaging, or support for the other route modes. The input ceiling and route-name bound are prototype safeguards, not approved product limits. Automated repository tests use synthetic fixtures only; any authorized local real-route smoke test must keep its source and derived GPX outside Git. Its DOCTYPE guard conservatively rejects the literal `<!DOCTYPE` anywhere in UTF-8 input, so harmless occurrences in comments or text are rejected; non-UTF-8 input is rejected before parsing. This narrow check is not a complete XML security qualification. B01/B02 schema provenance and rights, IP-2A security/file-reference qualifications, and production acceptance gates remain open.

Inspect a route without creating a GPX or modifying a file:

```sh
./build/rtz-gpx-converter --inspect-json input.rtz
```

Inspection writes one UTF-8 JSON document to stdout and diagnostics to stderr. Its version-1 object contains the RTZ version, source route name (or `null`), waypoint count, and ordered waypoints with one-based ordinal, source ID/name (name may be `null`), and normalized latitude/longitude strings. It includes no file path or source metadata beyond those fields. A synthetic example is:

```json
{"schema":1,"rtz_version":"1.0","route_name":"SYN-Fields-10","waypoint_count":3,"waypoints":[{"ordinal":1,"id":"10","name":"SYN-A","lat":"12.25","lon":"23.5"},{"ordinal":2,"id":"20","name":"SYN-B","lat":"12.5","lon":"23.75"},{"ordinal":3,"id":"30","name":"SYN-C","lat":"12.75","lon":"24"}]}
```

Build and convert a synthetic fixture with the installed macOS Swift compiler:

```sh
make build
./build/rtz-gpx-converter tests/fixtures/rtz/synthetic/valid-rtz-1.2-fields.xml /tmp/example.gpx
```

Export a suffix beginning at a waypoint (the selected waypoint is included):

```sh
./build/rtz-gpx-converter input.rtz output.gpx --from-waypoint-id 20
```

Selecting the last waypoint writes a one-point GPX route. This CLI prototype does not provide user-facing confirmation; confirmation belongs to the later Shortcut/UI layer.

Prepend an explicitly entered position and continue from an explicitly selected next waypoint:

```sh
./build/rtz-gpx-converter input.rtz output.gpx --current-position 0 0 --next-waypoint-id 20 --connector rhumb
```

Current Position requires decimal-degree coordinates, a next waypoint ID, and exactly `rhumb` or `great-circle`. Longitude `+180` is rejected for both current positions and source waypoints regardless of RTZ version; `-180` is accepted. Current Position cannot be combined with From Waypoint. The CLI reports the connector choice, but GPX contains route vertices only and does not encode connector geometry or generate intermediate points. Coincident current-position and source-waypoint vertices are both retained.

The source RTZ route name is used by default. To apply the approved export-only naming choice, pass either `--route-name 'Name'` or `--omit-route-name`; the output filename never changes the internal GPX route name. The destination directory must already exist and the destination file must not exist.

Run the focused synthetic checks with:

```sh
make test
```

The committed [synthetic output example](examples/rtz-1.2-synthetic-example.gpx) is generated from `valid-rtz-1.2-fields.xml`; it is test data, not a navigational route. No Windy acceptance is claimed.

The approved architecture and current stage status are summarized in [the master plan](docs/RTZ-GPX-PLAN.md), [REPORT.md](REPORT.md), and [PROGRESS.md](PROGRESS.md).

## Safety and privacy

Route files and vessel positions can be sensitive. Real routes and their derived GPX files must remain outside Git unless the user explicitly authorizes their inclusion. The planned converter must work offline, preserve source RTZ files, and make no automatic navigational decisions.

## Governance

Follow [AGENTS.md](AGENTS.md). Gate 3 is accepted. This branch implements only the explicitly authorized minimal prototype; IP-2B–IP-2E and all other implementation remain unauthorized pending Architect review.
