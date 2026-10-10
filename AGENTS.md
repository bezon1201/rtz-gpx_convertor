# AGENTS.md — RTZ-GPX Converter

## Mission
Build a small, reliable, fully offline macOS tool to convert maritime RTZ routes into GPX 1.1 routes for personal weather assessment in Windy. It is NOT an ECDIS replacement or an approved navigational route-planning system.

## Project governance
- The repository is the source of truth. Work in small, reviewable commits.
- `docs/RTZ-GPX-PLAN.md` is the master plan. Detailed stage plans belong in `docs/implementation/`.
- `PROGRESS.md` is the chronological stage ledger: current stage, state (PLANNED / IN_PROGRESS / BLOCKED / REVIEW / PASS), evidence, tests, next action, and commit hashes.
- `REPORT.md` is the concise, cumulative handoff for an external architect/reviewer (ChatGPT): current architecture, what changed, decisions, unresolved issues, risks, test evidence, exact commit/branch, and next requested decision. Update it with every meaningful stage or review.
- Commit `REPORT.md` and `PROGRESS.md` with each stage completion. Do not mark PASS without evidence.
- Never silently overwrite or rewrite the user's decisions. Record changes and rationale.
- GitHub repository proposal: `RTZ-GPX-Converter` (private by default). Ask the user before creating the remote repository or pushing. Do not claim it exists until verified.

## Mandatory planning gates
**Gate 1 — Master plan only.** Create `docs/RTZ-GPX-PLAN.md` with goals, use cases, constraints, data formats, proposed architecture, risks, test strategy, staged roadmap, acceptance criteria, and unresolved questions. No product code.
**Gate 2 — Detailed stage plans.** After the user approves the master plan, create one implementation plan per approved stage with file-level changes, interfaces, dependencies, test cases, rollback, and exit criteria. No product code.
**Gate 3 — Cross-check.** Review the entire plan set for consistency, omissions, format fidelity, UX, error handling, security, offline behavior, and scope. Produce a review report and resolve blockers. No product code.
**Gate 4 — Implementation.** Start only after explicit user approval following cross-check. One stage at a time, with tests and documentation updated.

## Functional scope
- Import RTZ (investigate versions 1.0, 1.1, 1.2; verify actual schemas and sample files before promising support).
- Export GPX 1.1 with ordered `<rte>/<rtept>`; investigate whether Windy preserves the route as intended.
- Full Route; From Waypoint; From Current Position.
- For Current Position, accept latitude/longitude in clear maritime formats; show the proposed route join and next waypoint for user confirmation. Never silently select the nearest waypoint as the next one.
- Consider both direct-to-next-WP and join-selected-route-segment behaviors, with user-visible geometry and explicit choice.
- Validate input XML safely, coordinate ranges, waypoint ordering, duplicates, route discontinuities, and export output. Avoid external entity expansion.
- Compare calculated great-circle/rhumb-line distances only with explicitly documented conventions; flag meaningful discrepancies and never claim navigational equivalence to ECDIS.
- RTZ turn radii, XTD, leg types, safety and other metadata may not map into GPX; inventory and report losses explicitly. Preserve original RTZ unchanged.
- Entire conversion must function offline; no upload of routes or vessel positions. No telemetry by default.
- macOS Apple Silicon target; prioritize minimal dependencies. Plan a Finder Quick Action and optional simple GUI, but choose packaging only after research.

## Engineering rules
- Separate parsing, validation, route transformations, GPX serialization, UI, and OS integration.
- Use deterministic, repeatable fixture-based tests. Include malformed RTZ, missing coordinates, multiple route structures, antimeridian, high latitudes, and ambiguous nearest-leg cases.
- Use sanitized synthetic fixtures in the public-facing test suite. Treat real voyage routes as confidential; never commit them or their derived coordinates without explicit permission.
- Do not modify ship systems or ECDIS files. Do not require admin access on the ship PC.
- No network dependency at runtime. Do not add cloud conversion services.
- Avoid unsupported assumptions about RTZ schemas, NAVTOR exports, or Windy import behavior. Mark unknowns for verification.
- Do not introduce unrelated functionality or optimize routing/weather; the Master remains responsible for route and weather judgment.

## Reporting format after each stage
1. Stage and status.
2. Files changed.
3. Tests run and exact results.
4. Decisions / deviations from plan.
5. Risks and blockers.
6. Branch and commit hash, remote push status.
7. Next proposed step and approval needed.

## Git workflow
- Prefer a private GitHub repo. Never commit credentials, real vessel positions/routes, personal information, or large generated artifacts by default.
- Work on descriptive feature branches; keep commits atomic. Confirm git status before and after commits.
- Do not force-push or rewrite shared history without explicit authorization.
- Before any stage is declared complete, update and commit `REPORT.md` and `PROGRESS.md` together with the relevant stage deliverables.
