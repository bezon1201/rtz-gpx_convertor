# Progress ledger

## Current stage

**Stage 0 — Master plan: PASS**

- Gate 1: **APPROVED / PASS**. Architectural review conditions are closed in the master plan.
- Gate 2: **READY FOR DETAILED PLANNING**.
- Implementation: **NOT AUTHORIZED**.
- Evidence: approved product direction and seven-stage roadmap retained; version policy, RTZP V1 boundary, advisory-only distance safeguards, and review status synchronized across planning records.
- Tests: none run; no implementation exists.
- Next action: await the separate task authorization for detailed plans for Stages 1–7, then cross-check the complete plan set. Do not implement before explicit later authorization.
- Commit: Gate 1 finalization documentation commit on `docs/master-plan`; exact SHA is available in Git history and the task handoff.
- Remote: pushed without force; remote branch was verified to match local HEAD.

## Stage ledger

| Stage | State | Evidence / exit condition | Commit |
|---|---|---|---|
| 0. Discovery and master plan | PASS | Architectural approval conditions closed; Gate 1 approved; Gate 2 ready. | Gate 1 finalization commit |
| 1. Standards, fixtures, and integration/packaging discovery | PLANNED | Qualify mandatory RTZ 1.0/1.2 targets, conditional 1.1 dialects, geometry vectors, sanitized fixtures, Shortcuts feasibility, and self-contained packaging. | — |
| 2. Core model and safe parsing | PLANNED | Input version detection, parsing, and validation satisfy the approved contracts. | — |
| 3. Route modes and geometry | PLANNED | All three modes produce explicit, reviewable geometry; distance stays advisory and no ECDIS equivalence is claimed. | — |
| 4. GPX serialization and loss report | PLANNED | GPX 1.1 output validates and loss disclosure is clear. | — |
| 5. Stable local CLI and self-contained runtime | PLANNED | CLI contract is stable/documented; target Mac needs no Homebrew or Python. | — |
| 6. Windy Route Planner acceptance | PLANNED | Synthetic GPX acceptance is recorded in Route Planner; known limitations are documented. | — |
| 7. V1 Shortcuts experience, installation, and release (final implementation stage) | PLANNED | Working primary Shortcut supports Shortcuts/Dock/keyboard/Finder Quick Action, native file selection, all modes, safe file flows, offline use, reproducible installation, and end-to-end verification. | — |

This ledger is chronological. A stage is not marked PASS without recorded evidence. Detailed per-stage plans belong in `docs/implementation/` and are gated on the approved master plan and separate authorization. RTZP containers are OUT OF SCOPE for V1; they may be reconsidered after V1 release and have no roadmap stage.
