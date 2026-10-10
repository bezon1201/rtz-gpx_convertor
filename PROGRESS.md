# Progress ledger

## Current gate activity

**IP-3 PLAN: SUBMITTED FOR ARCHITECTURAL REVIEW (Gate 2)**

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-2 execution **NOT AUTHORIZED**.
- IP-3 execution: **NOT AUTHORIZED**; overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-3-route-modes-geometry`, based on corrected IP-2 baseline `8011d3f0c4baf62cb15194ab9308f4e312269615`.
- IP-3 defines all three modes and explicit Current Position variants, immutable source-order output/provenance, confirmation, losses, diagnostics, advisory-only distance, and IP-4 handoff. Join math remains qualification-gated; unreliable rhumb global minimization blocks IP-3E pending architectural decision.
- Open dependencies: IP-1 schema/geometry qualification and independent distance oracles; IP-2 execution/model evidence and identifier semantics; minimum-point/duplicate-coordinate policy; split-leg metadata semantics; IP-4/IP-5/IP-7 contracts. No upstream execution PASS is assumed.
- No application code, tests, fixtures, probes, schemas, dependencies, CLI, GPX or Shortcuts created; no tests run.
- Next: architectural review of IP-3 plan, then Gate 3 cross-check after all detailed plans are separately authorized and available. Do not execute IP-3 or begin IP-4.
- Commit and remote verification: to be recorded after the focused planning commit.

### Preserved IP-2 status and evidence

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution **NOT AUTHORIZED**.
- IP-2 execution: **NOT AUTHORIZED**; no execution PASS is claimed.
- Overall implementation: **NOT AUTHORIZED**.
- IP-2 plan uses approved IP-1 planning commit `6ed649d3995f70fa2421e08cb027c07d19b4cad4` as baseline.
- Resource limits/API behavior are proposals pending authorized evidence and architectural review. Schema qualification, legal offline validator strategy and fixture catalog remain upstream dependencies.
- FileReference path/content remain untrusted until securely opened and validated. Alias/security-scoped URL/permission/identity policy requires joint IP-2A/IP-5/IP-7 closure. Unknown geometry is uninterpreted only. RTZ digests are opt-in after approval; none by default.
- No tests run. No code, model, parser, fixture, probe, schema, dependency, CLI, Shortcut or package created.
- IP-2 branch/commit: `docs/ip-2-safe-input-model-parser` at `8011d3f0c4baf62cb15194ab9308f4e312269615`; remote branch was its approved baseline for IP-3 planning.

## Stage ledger

| Stage | State | Evidence / exit condition | Commit |
|---|---|---|---|
| 0. Discovery and master plan | PASS | Gate 1 approved; conditions closed. | `d57d093` |
| 1. Standards, fixtures, integration/packaging discovery (IP-1) | PLANNED | Plan ready for Gate 3 cross-check; execution unauthorized. | — |
| 2. Safe input model and parser (IP-2) | PLAN APPROVED | R1 conditions closed; ready for Gate 3 cross-check. Execution unauthorized. | — |
| 3. Route modes and geometry (IP-3) | PLAN SUBMITTED FOR REVIEW | Detailed transformation plan created; join algorithms remain qualification-gated; execution unauthorized. | pending |
| 4. GPX serialization and loss report (IP-4) | PLANNED | Detailed plan not created in this task. | — |
| 5. Stable local CLI and self-contained runtime (IP-5) | PLANNED | Detailed plan not created in this task. | — |
| 6. Windy Route Planner acceptance (IP-6) | PLANNED | Detailed plan not created in this task. | — |
| 7. V1 Shortcuts release (IP-7) | PLANNED | Detailed plan not created in this task. | — |

Plan review is not execution PASS. RTZP remains OUT OF SCOPE for V1.
