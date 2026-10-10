# Progress ledger

## Current stage

**Stage 0 — Master plan**

- State: **REVIEW**
- Evidence: Supplied `AGENTS.md` installed at repository root; user-approved V1 direction recorded (Shortcuts primary UI plus local CLI); master plan and project records updated; official CIRM, IEC, Topografix, Windy, and Apple Shortcuts documentation reviewed; two user-supplied RTZ examples inspected read-only.
- Tests: None run; no implementation exists.
- Next action: Architectural review of the updated master plan; then Gate 2 detailed plans only after approval.
- Commit: `d3d98f7bad2944eb0805e21fd54f3d1310f2f626` (`docs/master-plan`).

## Stage ledger

| Stage | State | Evidence / exit condition | Commit |
|---|---|---|---|
| 0. Discovery and master plan | REVIEW | User-approved V1 interface direction is recorded; the updated plan is ready for architectural review. | `d3d98f7` |
| 1. Standards, fixtures, and integration/packaging discovery | PLANNED | Version/schema matrix, sanitized synthetic fixtures, Shortcuts feasibility, and self-contained packaging direction accepted. | — |
| 2. Core model and safe parsing | PLANNED | Input version detection, parsing, and validation satisfy the approved contracts. | — |
| 3. Route modes and geometry | PLANNED | All three modes produce explicit, reviewable geometry and documented estimates. | — |
| 4. GPX serialization and loss report | PLANNED | GPX 1.1 output validates and loss disclosure is clear. | — |
| 5. Stable local CLI and self-contained runtime | PLANNED | CLI contract is stable/documented; Shortcut can invoke it without Terminal, Homebrew, or Python. | — |
| 6. Windy Route Planner acceptance | PLANNED | Synthetic GPX acceptance is recorded in Route Planner; known limitations are documented. | — |
| 7. V1 Shortcuts experience, installation, and release (final implementation stage) | PLANNED | Working Shortcut supports Shortcuts/Dock/keyboard/Finder Quick Action, all modes, safe file flows, offline use, and a tested reproducible install. | — |

This ledger is chronological. A stage is not marked PASS without recorded evidence. Detailed per-stage plans belong in `docs/implementation/` and are gated on approval of the master plan.
