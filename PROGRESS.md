# Progress ledger

## Current stage

**Stage 0 — Master plan**

- State: **REVIEW**
- Evidence: Supplied `AGENTS.md` installed at repository root; master plan and project records drafted; official CIRM, IEC, Topografix, Windy, and Apple documentation reviewed; two user-supplied RTZ examples inspected read-only.
- Tests: None run; no implementation exists.
- Next action: User reviews and approves or revises the master plan.
- Commit: Recorded in the stage completion commit; see `git log`.

## Stage ledger

| Stage | State | Evidence / exit condition | Commit |
|---|---|---|---|
| 0. Discovery and master plan | REVIEW | This plan and project scaffolding are ready for architect review; approval is pending. | See `git log` |
| 1. Standards and fixture baseline | PLANNED | Version/schema matrix, sanitized synthetic fixtures, and format decisions accepted. | — |
| 2. Core model and safe parsing | PLANNED | Input version detection, parsing, and validation satisfy the approved contracts. | — |
| 3. Route modes and geometry | PLANNED | All three modes produce explicit, reviewable geometry and documented estimates. | — |
| 4. GPX serialization and loss report | PLANNED | GPX 1.1 output validates and loss disclosure is clear. | — |
| 5. macOS UX and Finder integration | PLANNED | The approved interaction works with selected-file access and safe output handling. | — |
| 6. Windy and end-to-end acceptance | PLANNED | Synthetic GPX acceptance is recorded in Windy; known limitations are documented. | — |
| 7. Packaging and release | PLANNED | Apple Silicon release artifact, offline behavior, signing/distribution, and documentation are accepted. | — |

This ledger is chronological. A stage is not marked PASS without recorded evidence. Detailed per-stage plans belong in `docs/implementation/` and are gated on approval of the master plan.
