# RTZ-GPX-Converter

A proposed offline macOS Apple Silicon utility for converting maritime RTZ route plans into GPX 1.1 routes for personal weather assessment in Windy. V1's approved direction is a macOS Shortcut invoking a self-contained local CLI. It is not an ECDIS replacement or an approved navigation system.

## Project status

**Development prototype only.** This branch includes a small offline command-line converter for project-authored synthetic RTZ 1.0 and 1.2 input, limited to Full Route mode. It writes deterministic GPX 1.1, preserves waypoint order, validates coordinates, rejects malformed/unsupported/unsafe XML, and does not publish partial output.

The prototype is **not schema validated** and does not claim RTZ 1.0/1.2 conformance or product support. It handles only the fields needed for this demonstration; other RTZ metadata is ignored. It has no GUI, Shortcuts/Finder integration, worker, IPC, packaging, or support for the other route modes. The input ceiling and route-name bound are prototype safeguards, not approved product limits. Use synthetic fixtures only. B01/B02 schema provenance and rights, IP-2A security/file-reference qualifications, and production acceptance gates remain open.

Build and convert a synthetic fixture with the installed macOS Swift compiler:

```sh
make build
./build/rtz-gpx-converter tests/fixtures/rtz/synthetic/valid-rtz-1.2-fields.xml /tmp/example.gpx
```

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
