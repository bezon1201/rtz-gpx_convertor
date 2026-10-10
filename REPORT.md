# Architect review handoff

## Stage and status

Stage 0 — Master planning: **REVIEW**. This is a planning draft awaiting the user's review and approval. No implementation has started.

## Current architecture proposal

Native macOS application on Apple Silicon, with separate format detection/parsing, validation, route transformation, distance estimation, GPX serialization, user interface, and Finder integration boundaries. A pure Swift core and Foundation XML APIs are candidates; selection is provisional pending the detailed stage plans. All runtime processing is local and offline.

## What changed

- Added the supplied `AGENTS.md` to the root of the previously empty repository.
- Added the master plan, project README, ignore rules, this handoff, and the stage ledger.
- Read-only inspection of two RTZ routes supplied earlier in this conversation found RTZ 1.0 / namespace `http://www.cirm.org/RTZ/1/0`; both included waypoint positions, a `CalculatedSchedule`, and leg geometry metadata. The files and coordinates were not copied into the repository.
- Standards research found CIRM's published schema page lists RTZ 1.0 and 1.2 files; IEC PAS 61174-1:2021 introduces 1.2 while retaining 1.0; RTZ 1.1 is associated with an STM development schema and needs compatibility investigation before support is promised.
- GPX 1.1 models a route as an ordered list of route points. Windy's public uploader accepts GPX, but Route Planner import behavior still needs an empirical acceptance test.

## Decisions proposed for approval

- Target native macOS Apple Silicon; use offline, local-only processing with no telemetry.
- Treat RTZ 1.0 and 1.2 as schema-backed candidate inputs; treat 1.1 as provisional until its schema lineage and fixtures are verified.
- Export ordered GPX 1.1 `<rte>/<rtept>` points, preserve waypoint names where present, disclose losses, and never imply ECDIS equivalence.
- Implement Full Route, From Waypoint, and From Current Position only after explicit user choices. Current Position must use manually entered coordinates and an explicit route-leg/next-waypoint confirmation, with direct-to-waypoint versus join-selected-leg behavior shown to the user.
- Keep real routes and derived routes out of Git. Use sanitized synthetic fixtures for public tests.
- Defer packaging choice and Finder UX details until the relevant planned stages.

## Unresolved issues

- Approve or revise the master plan and its proposed stage boundaries.
- Confirm whether RTZP containers, multiple GPX routes, and a command-line interface belong in scope.
- Confirm the intended minimum macOS version and whether direct notarized distribution or another delivery path is preferred.
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
- Planning commit: `bacfd5b9263333e6454b882cbdb3b337a67fa73f` on `docs/master-plan`.
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git` is configured by the clone. Push status: **not pushed**; explicit push authorization is still required by the supplied governance instructions.

## Next requested decision

Review and approve or revise `docs/RTZ-GPX-PLAN.md`. After approval, authorize the separate task to produce detailed implementation plans for every stage. No implementation should begin before the complete plan set is cross-checked and explicit implementation authorization is given.
