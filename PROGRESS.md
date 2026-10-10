# Progress ledger

## Current gate activity

**Gate 2 — Detailed plans: IN PROGRESS (IP-1 plan in REVIEW)**

- Gate 1 / Stage 0: **APPROVED / PASS**; architectural conditions closed.
- Gate 2: IP-1 detailed plan prepared for architectural review. Plans IP-2 through IP-7 are not yet present.
- IP-1 execution: **NOT AUTHORIZED**. Implementation overall: **NOT AUTHORIZED** pending complete plan-set cross-check and later explicit approval.
- Evidence: plan is based on approved Gate 1 commit `d57d0935c7885eb25eb14542e7996839644e96e2`; includes objectives, artifacts, contracts, future cases, risks, rollback, acceptance evidence and downstream dependencies.
- Tests: none run. No product code, fixture, probe, schema, package, Shortcut or executable artifact created.
- Next action: architectural review of IP-1 plan; do not execute it or begin IP-2–IP-7 until separately authorized.
- Branch: `docs/ip-1-standards-fixtures-integration`.
- Commit and remote verification: see current planning commit in Git history and task handoff; branch pushed without force and remote HEAD verified equal to local HEAD.

## Stage ledger

| Stage | State | Evidence / exit condition | Commit |
|---|---|---|---|
| 0. Discovery and master plan | PASS | Gate 1 approved; review conditions closed; Gate 2 ready. | `d57d093` |
| 1. Standards, fixtures, and integration/packaging discovery | PLANNED | Future IP-1 execution requires separate authorization and all PASS evidence in the IP-1 plan. | — |
| 2. Core model and safe parsing | PLANNED | Version detection, parsing and validation satisfy approved contracts. | — |
| 3. Route modes and geometry | PLANNED | Three explicit modes; distance advisory only, no automatic route change or ECDIS equivalence claim. | — |
| 4. GPX serialization and loss report | PLANNED | Valid GPX 1.1 and clear loss disclosure. | — |
| 5. Stable local CLI and self-contained runtime | PLANNED | Stable automation contract; no target Homebrew/Python. | — |
| 6. Windy Route Planner acceptance | PLANNED | Synthetic-only acceptance, Uploader and Planner outcomes distinguished. | — |
| 7. V1 Shortcuts experience, installation, and release | PLANNED | Working primary Shortcut, all approved launch paths/modes, reproducible install and end-to-end verification. | — |

Detailed plans belong under `docs/implementation/`. Plan review is not execution PASS. RTZP containers remain OUT OF SCOPE for V1 and have no roadmap stage.
