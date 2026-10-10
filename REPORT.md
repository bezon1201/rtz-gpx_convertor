# Architect review handoff

## Stage and status

Gate 1 / Stage 0 remains **APPROVED / PASS**. Gate 2 is **IN PROGRESS — IP-1 detailed plan submitted for architectural review**. The IP-1 execution stage remains **NOT AUTHORIZED**; IP-2 through IP-7 have not been started. Approval of this plan alone does not authorize any probe, fixture creation, or implementation.

## Current architecture and approved direction

V1 remains an offline Apple Silicon macOS utility with a reproducibly installable Shortcuts workflow as primary UI and a self-contained local CLI, no standalone GUI, Homebrew or target-Mac Python. Preserve Full Route, From Waypoint and From Current Position; Current Position requires manual coordinates and explicit next-WP/route-leg confirmation plus Direct to Next WP / Join Selected Route Leg. GPX 1.1 is the output; losses are disclosed; no automatic navigational decisions and no ECDIS geometry equivalence.

Approved RTZ policy remains 1.0 and 1.2 mandatory subject to schema-backed qualification, 1.1 conditional and nonblocking, unsupported dialects rejected clearly. RTZP is OUT OF SCOPE for V1 and may be reconsidered after release; no RTZP stage. Distance is advisory only and never chooses or modifies the intended route.

## This planning change

- Added `docs/implementation/IP-1-STANDARDS-FIXTURES-INTEGRATION-PLAN.md`, detailed Gate 2 planning for Stage 1 only.
- The plan specifies schema provenance/license/hash and version/namespace qualification, a synthetic fixture catalog, independently reviewed geometry vectors, a GPX 1.1 contract, safe Shortcuts invocation options and a deferred inert probe, self-contained packaging evaluation, and a separate synthetic-only Windy Uploader/Route Planner protocol.
- Decomposes future IP-1 execution into IP-1A through IP-1G with artifacts, dependencies, work sequences, future verification cases, risks, rollback and PASS evidence. Maps handoffs to IP-2 through IP-7 and distinguishes planning acceptance from execution PASS.
- Does not change `AGENTS.md` or the approved Master Plan. No probe, fixture, test, schema, package, code or Shortcut was created. No tests were run.

## Open technical questions

- Rights to redistribute the CIRM schemas/dependencies for offline validation; exact pinned 1.2 namespace and schema lineage.
- Whether any specific RTZ 1.1 dialect is rights-cleared and sufficiently specified; 1.1 may remain unsupported.
- Permitted offline XSD validation approach without adding a target runtime dependency.
- Safe, lossless Shortcuts-to-CLI argument/result behavior across candidate macOS versions; any probe is separately authorization-gated.
- Minimum macOS release, Developer ID availability, stable user-level install path, container/signing/notarization and clean-user procedure.
- Numeric precision and deterministic GPX serialization choices; actual Windy Route Planner acceptance remains Stage 6.

## Verification and privacy

- Planning-only documentation review; no tests run.
- No implementation code, scripts, executable fixtures, test suite, CLI, Shortcut, Quick Action, schemas, or dependencies created/installed.
- No real RTZ/GPX route or derived coordinate data added. The full three-file diff and tracked-file inventory were reviewed; no route data, credentials, or personal paths were found.

## Repository state

- Branch: `docs/ip-1-standards-fixtures-integration`, created from approved baseline `d57d0935c7885eb25eb14542e7996839644e96e2` on `docs/master-plan`.
- Planning commit: this focused IP-1 plan/report/ledger change; exact SHA is in Git history and task handoff.
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- Push: the dedicated branch is pushed without force after privacy review; remote SHA matches local HEAD (exact SHA and branch URL in task handoff).

## Next requested decision

Please review the IP-1 plan. Then, in a separate authorized task, prepare detailed plans for IP-2 through IP-7, cross-check the full Gate 2 plan set, resolve findings, and obtain explicit implementation authorization before any execution. Do not start IP-1 execution from this plan approval alone.
