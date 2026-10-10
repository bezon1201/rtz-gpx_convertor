# Architect review handoff

## Stage and status

Stage 0 — Master planning: **REVIEW**. The user has approved the V1 product direction (macOS Shortcuts primary UI plus local CLI); the updated master plan is awaiting architectural review. No implementation has started.

## Current architecture proposal

Offline Apple Silicon CLI with separate format detection/parsing, validation, route transformation, distance estimation, GPX serialization, and reporting boundaries. A native Swift CLI using Foundation XML APIs is the current candidate; the macOS Shortcuts artifact is the V1 primary interface and invokes that CLI without Terminal interaction. There is no standalone GUI framework in V1. The exact Shortcuts invocation mechanism, argument/result contract, package form, and installation path remain to be established in the gated plans.

## What changed

- Added the supplied `AGENTS.md` to the root of the previously empty repository.
- Added the master plan, project README, ignore rules, this handoff, and the stage ledger.
- Read-only inspection of two RTZ routes supplied earlier in this conversation found RTZ 1.0 / namespace `http://www.cirm.org/RTZ/1/0`; both included waypoint positions, a `CalculatedSchedule`, and leg geometry metadata. The files and coordinates were not copied into the repository.
- Standards research found CIRM's published schema page lists RTZ 1.0 and 1.2 files; IEC PAS 61174-1:2021 introduces 1.2 while retaining 1.0; RTZ 1.1 is associated with an STM development schema and needs compatibility investigation before support is promised.
- GPX 1.1 models a route as an ordered list of route points. Windy's public uploader accepts GPX, but Route Planner import behavior still needs an empirical acceptance test.
- User-approved V1 interaction: launch from Shortcuts, Dock, keyboard shortcut, or Finder Quick Action; use native file selection when no Finder input is passed; offer all three modes with explicit confirmations; save through native UI; show success/errors; offer Reveal in Finder; remain offline.
- Apple documentation confirms Dock, keyboard, Finder Quick Action, and local `.shortcut` file import paths. Safe argument passing from a Shortcut into a self-contained CLI and an offline clean-user installation still require implementation-stage verification.

## Approved product direction and carried-forward proposals

- V1's primary UI is a reproducibly installable macOS Shortcut on Apple Silicon, backed by a local automation-grade CLI; use offline, local-only processing with no telemetry.
- Treat RTZ 1.0 and 1.2 as schema-backed candidate inputs; treat 1.1 as provisional until its schema lineage and fixtures are verified.
- Export ordered GPX 1.1 `<rte>/<rtept>` points, preserve waypoint names where present, disclose losses, and never imply ECDIS equivalence.
- Implement Full Route, From Waypoint, and From Current Position only after explicit user choices. Current Position must use manually entered coordinates and an explicit route-leg/next-waypoint confirmation, with direct-to-waypoint versus join-selected-leg behavior shown to the user.
- Keep real routes and derived routes out of Git. Use sanitized synthetic fixtures for public tests.
- No standalone GUI framework; Finder Quick Action reuses the same Shortcut.
- Do not require Homebrew or target-machine Python unless the user explicitly approves a deviation. Evaluate a self-contained CLI plus reproducibly installable Shortcut.

## Unresolved issues

- Approve or revise the master plan and its proposed stage boundaries.
- Confirm whether RTZP containers and multiple GPX routes belong in scope.
- Confirm the intended minimum macOS version and self-contained release path.
- Verify safe CLI invocation/argument passing, output/error handoff, Finder file input, source-directory save permissions, and offline Shortcut installation across supported macOS versions.
- Select the exact CLI packaging and Shortcut installation/update/removal procedure after feasibility research.
- Decide how much source metadata should be copied into GPX versus reported as dropped.
- Define acceptance thresholds for distance discrepancies and duplicate/discontinuous waypoint warnings.
- Complete the Windy Route Planner empirical import test with synthetic or explicitly approved anonymized data.
- Obtain a vetted 1.1 schema source and compare schema variants, including 1.1 leg extensions.

## Verification

- Planning evidence only: standards and vendor documentation reviewed and two conversation-supplied RTZ files inspected read-only.
- No application tests were run; no code or test suite exists yet.
- No live Windy import was performed.
- No real RTZ or GPX route was committed.

## Repository state

- Branch: `docs/master-plan`
- Planning commit: to be recorded after this planning-only commit is created on `docs/master-plan`.
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git` is configured by the clone. Push status: **not pushed**; explicit push authorization is still required by the supplied governance instructions.

## Next requested decision

Review the updated `docs/RTZ-GPX-PLAN.md` architecturally. Once the complete master plan is approved, authorize the separate task to produce detailed implementation plans for every stage. No implementation should begin before the complete plan set is cross-checked and explicit implementation authorization is given.
