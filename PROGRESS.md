# Progress ledger

## Current gate activity

**IP-4 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK (R1 conditions closed)**

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; execution **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; execution **NOT AUTHORIZED**.
- IP-3 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; execution **NOT AUTHORIZED**.
- IP-4 execution and overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-4-gpx-serialization-loss-report`, R1 base `df9ebbb31ddd3679d0c6c3adb828ab35a64f6303`.
- R1 corrections: one-point policy is unresolved between ALLOW_WITH_WARNING and REFUSE_EXPORT pending Gate 3; route-name override is an unresolved product choice; IP-4 returns immutable validated bytes while IP-5 owns filesystem writing and IP-7 owns destination/consent/feedback; coordinate checks are representation-aware with binary source-decimal error/tolerance evidence required.
- Remaining questions/evidence: Gate 3 one-point and naming decisions; IP-1 schema/license/offline validator; IP-2 numeric representation and precision/error analysis; GPX +180 boundary; IP-5/IP-7 file-reference and writer behavior; IP-6 Windy acceptance. No unresolved decision is claimed as approved or tested.
- No application code, tests, fixtures, schemas, dependencies, GPX, CLI, Shortcuts or generated artifacts created; no tests run.
- Next: Gate 3 cross-check after the complete detailed-plan set is available; IP-4 execution and IP-5 planning are not authorized.
- R1 correction commit and remote status are reported in the final task handoff.

**IP-3 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK**

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-2 execution **NOT AUTHORIZED**.
- IP-3 execution: **NOT AUTHORIZED**; overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-3-route-modes-geometry`, based on corrected IP-2 baseline `8011d3f0c4baf62cb15194ab9308f4e312269615`.
- IP-3 R1 conditions closed: one-point neutral transforms are valid with an advisory; GPX exportability remains with IP-4 and Windy consumer acceptance with IP-6. Endpoint coincidence reuses the source point reference only under provisional tolerance; distinct source identities and synthetic current-position provenance are never merged. The Loxodrome closest-point metric is unresolved; candidate metric approval must precede any minimizer qualification, with global root completeness still required. Confirmation responsibilities are divided between IP-3 domain, IP-5 transport, and IP-7 UI.
- Open dependencies: IP-1 schema/geometry qualification and independent distance oracles; IP-2 execution/model evidence and identifier semantics; join-endpoint tolerance and great-circle degeneracy qualification; approved Loxodrome metric and global-minimum evidence; split-leg metadata semantics; IP-4/IP-5/IP-7 interfaces; IP-4/IP-6 one-point GPX policy/acceptance. No upstream execution PASS is assumed.
- No application code, tests, fixtures, probes, schemas, dependencies, CLI, GPX or Shortcuts created; no tests run.
- Next: Gate 3 cross-check after the complete detailed-plan set is available. IP-3 execution and overall implementation remain unauthorized.
- IP-3 plan commit `9a5db3525b986a3e13e3239274dcc6ae6957d6e5` was pushed without force; R1 corrections are the current documentation update. The final R1 commit and remote-head verification are reported in the task handoff.

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
| 3. Route modes and geometry (IP-3) | PLAN APPROVED | R1 corrections closed; ready for Gate 3 cross-check; execution unauthorized. | R1 commit in task handoff |
| 4. GPX serialization and loss report (IP-4) | PLAN APPROVED | R1 conditions closed; ready for Gate 3 cross-check; execution unauthorized. | R1 correction commit in task handoff |
| 5. Stable local CLI and self-contained runtime (IP-5) | PLANNED | Detailed plan not created in this task. | — |
| 6. Windy Route Planner acceptance (IP-6) | PLANNED | Detailed plan not created in this task. | — |
| 7. V1 Shortcuts release (IP-7) | PLANNED | Detailed plan not created in this task. | — |

Plan review is not execution PASS. RTZP remains OUT OF SCOPE for V1.
