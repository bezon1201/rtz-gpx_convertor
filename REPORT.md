# Architect review handoff

## IP-5 planning handoff

- **IP-5 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.** (Architectural review: approved with minor conditions; R1 corrections applied.)
- **IP-5 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Branch: `docs/ip-5-cli-runtime-packaging`, reviewed baseline `af619b326a3a60a8a32912b3eda94774223c960f`.

Updated `docs/implementation/IP-5-CLI-RUNTIME-PACKAGING-PLAN.md` to close four R1 conditions while preserving IP-5A–IP-5F. IP-5A through IP-5F remain future execution sub-stages; none is executed or individually passed.

R1 corrections: (1) `inspect` uses the approved file-reference mechanism and the exact IP-2 secure acquisition, bounded read, dialect/schema/semantic validation path; summaries derive only from immutable validated `RouteDocument`. No separate parser, path reader, filename inference or schema bypass; output bounds and over-limit strategy are explicit planning requirements. (2) Preview/confirmation requires fresh authorized reference acquisition, fresh IP-2 validation, and verified source-object identity plus source-content continuity; capability lifetime, semantic preview equivalence and user consent remain distinct. The continuity mechanism is unresolved pending joint IP-2/IP-5/IP-7 qualification; no stateless feasibility or default private digest is claimed. (3) Output permissions are evidence-gated: `0600` is only a candidate; IP-5E must qualify macOS defaults, umask, ACLs, extended attributes and provider semantics separately for creation/replacement, without unsafe inheritance or silent loss. No final mode is selected. (4) IP-5D does not PASS if secure continuity cannot be demonstrated. Rollback may restore verified work; dropping Current Position from V1 requires separate explicit product-governance approval and cannot be an IP-5 unilateral downgrade.

The existing conditional JSON stdio proposal, file-reference security boundary, local self-contained packaging direction, offline requirements, writer ownership and explicit user consent remain. No protocol, package, filesystem API, Shortcuts behavior, minimum OS, permission policy or source-continuity mechanism is claimed as qualified. IP-4 one-point and route-name decisions remain Gate 3 items.

Remaining Gate 3 decisions and blockers: cross-check inspect limits and pagination/error strategy with IP-2; jointly qualify source identity/content continuity and reference/capability lifetime with IP-2/IP-7; resolve IP-4 one-point/name policies; reconcile IP-1D transport and IP-1E packaging. Execution/platform blockers include IP-1A schema rights/offline validator, IP-2A alias/security-scope policy, IP-3 confirmed-command/geometry evidence, IP-6 Windy results, IP-7 UI/install binding, actual filesystem permissions/ACL/atomicity, signing/notarization, cancellation, Gatekeeper and clean-user verification.

No application code, scripts, tests, probes, fixtures, schemas, dependencies, binaries, GPX, packages or Shortcuts were created; no tests or platform probes were run. No private routes, credentials or generated artifacts were added.

## IP-5 repository state

- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- R1 correction commit and remote-head verification: recorded in the final task handoff after publication.
- Next: Gate 3 cross-check when the full detailed-plan set is ready; do not execute IP-5 or begin IP-6 planning without separate authorization.

## IP-4 R1 correction handoff

- **IP-4 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.** (Architectural review: approved with minor conditions; R1 corrections applied.)
- **IP-4 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Branch: `docs/ip-4-gpx-serialization-loss-report`, reviewed baseline `df9ebbb31ddd3679d0c6c3adb828ab35a64f6303`.

Updated `docs/implementation/IP-4-GPX-SERIALIZATION-LOSS-REPORT-PLAN.md` and preserved the IP-4A–IP-4F decomposition.

The plan now records four corrections: (1) one-point export is an unresolved Gate 3 decision between ALLOW_WITH_WARNING and REFUSE_EXPORT; the valid IP-3 neutral transformation remains valid either way, and IP-6 provides compatibility evidence without deciding product policy. (2) IP-3 owns the source route name/provenance, IP-4 serializes approved naming input, IP-5 transports it, and IP-7 owns any confirmation UI; a confirmed export-only display-name override remains an explicit Gate 3 choice, with no automatic vessel/route/filename fallback. (3) IP-4 returns immutable validated bytes and the loss report; IP-5 owns filesystem writing/staging/identity/collision/publishing/cleanup/save result; IP-7 owns destination selection, overwrite consent and save feedback. Safe-save invariants remain intact. (4) coordinate preservation is representation-aware: exact decimals require mathematical equality; binary floating point may use qualified shortest round trip to the same finite value, with source-decimal error analysis and independently verified tolerance required before freeze. No RTZ lexical preservation is claimed. Longitude +180 remains fail-closed unless approved otherwise.

Gate 3 decisions: one-point policy and whether to permit a confirmed export-only route-name override, including reconciliation with Master Plan wording. Remaining evidence/execution blockers include IP-1 schema identity/license/offline validation; IP-2 numeric representation and error evidence; IP-3 model/confirmation evidence; +180 handling; IP-5/IP-7 file-reference and save contracts plus filesystem/provider verification; and IP-6 Windy empirical evidence. Gate 3 cross-check remains ahead; no unresolved decision or evidence is represented as approved or tested.

No application code, tests, fixtures, schemas, GPX, CLI, Shortcuts, dependencies or implementation artifacts were created. No tests were run; no private routes, credentials or generated artifacts were added.

## IP-4 repository state

- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- R1 correction commit and remote verification: recorded in the final task handoff after publication.
- Next: Gate 3 cross-check when the complete detailed-plan set is available. Do not execute IP-4 or begin IP-5 planning.

## IP-3 planning handoff

- **IP-3 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.**
- **IP-3 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Planning branch is based on corrected IP-2 commit `8011d3f0c4baf62cb15194ab9308f4e312269615`; no upstream execution PASS is implied.

Created `docs/implementation/IP-3-ROUTE-MODES-GEOMETRY-PLAN.md` and applied all four R1 architectural corrections in §§4.2, 5.1–5.3, 7–8, 10–14, and 15. The plan specifies Full Route, From Waypoint, Current Position / Direct to Next WP, and Current Position / Join Selected Route Leg; immutable source-order transforms; scoped ordinal waypoint/leg references; incoming-leg ownership; synthetic-point and source-leg provenance; domain preview/confirmation contracts separated from IP-5 transport and IP-7 UI; privacy-safe diagnostics; metadata losses; advisory-only distance; and IP-4/IP-5/IP-7 handoffs.

R1 corrections: (1) one-point neutral transformations are valid with an INSUFFICIENT_OUTPUT_POINTS advisory; no point is fabricated or result discarded; GPX exportability is left to IP-4 and empirical Windy compatibility to IP-6, without pre-approving one-point GPX. (2) Join endpoints reuse the corresponding original source waypoint reference only when classified coincident under a still-provisional numerical/identity tolerance; coordinate deduplication never removes a synthetic join, distinct source identities are never merged, and the current-position point retains distinct provenance. (3) The Loxodrome closest-point metric is an **UNRESOLVED ARCHITECTURAL DECISION**. Authalic-sphere great-circle separation remains only a candidate; metric review/approval must precede any minimizer qualification, and global root completeness remains a hard gate. (4) IP-3 domain creates previews/candidates and validates confirmed commands; IP-5 owns transport/binding; IP-7 presents the preview and collects consent. Revisions/tokens are transient contract proposals, not presumed durable identifiers or cryptographic protections.

Remaining execution blockers include IP-1 qualified schema/geometry literals and independent distance oracles/tolerances; IP-2 implemented model and ID semantics; great-circle degeneracy and join-endpoint tolerance qualification; architectural selection of the Loxodrome closest-point metric followed by global-minimum/root-completeness evidence; field-by-field split-leg metadata applicability; IP-4 one-point export policy and IP-6 empirical Windy acceptance; and final IP-4/IP-5/IP-7 interface contracts. IP-1 and IP-2 are plan-approved but their execution evidence is pending. Gate 3 remains pending the complete detailed-plan set and cross-check.

No implementation code, tests, fixtures, probes, schemas, dependencies, CLI, GPX, or Shortcuts were created or run. No real routes, derived vessel coordinates, credentials, or full source-route digest were added.

## IP-3 repository state

- Branch: `docs/ip-3-route-modes-geometry`
- Base: `8011d3f0c4baf62cb15194ab9308f4e312269615`
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- IP-3 plan commit: `9a5db3525b986a3e13e3239274dcc6ae6957d6e5`.
- R1 correction commit and final remote-head verification are recorded in this task handoff.
- Next action: architectural review of IP-3 plan. Do not execute IP-3 or begin IP-4.

## Status

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution remains **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK** after R1 corrections.
- IP-2 execution and overall implementation: **NOT AUTHORIZED**. No implementation PASS is claimed.

## IP-2 planning deliverable

Created `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` from approved IP-1 planning revision `6ed649d3995f70fa2421e08cb027c07d19b4cad4`. It defines secure single-file ingestion, strict exact-pair dispatch, separate XML/schema/semantic phases, immutable route model, diagnostics, synthetic test matrix, API boundaries, future IP-2A–IP-2E decomposition, acceptance criteria and handoffs.

Key recommendations: Foundation XMLParser is a candidate only; security/resource behavior needs authorized verification. Schema validation is an independent layer and requires a legally cleared offline strategy. No exact 1.2 namespace is guessed. Proposed numeric resource limits remain unapproved until workload/adversarial evidence and review. Fail closed for unqualified dialects, unavailable schemas, unsafe XML and fatal semantic errors. No partial model on fatal input.

The model preserves XML waypoint order independently of waypoint IDs, treats destination waypoint leg metadata as incoming, distinguishes optional absence from defaults, and never repairs coordinates or guesses geometry. RTZP remains out of scope. IP-3/IP-4/IP-5/IP-6/IP-7 handoffs are described without implementing their work.

## IP-2 R1 corrections recorded

1. **FileReference trust — plan §§3, 9, 11.** It is an opaque, local, untrusted reference until securely opened and validated. Finder/Shortcuts/CLI origin is no bypass; descriptor identity, bounded reads and no unsafe path reopening remain.
2. **Aliases and symlinks — §§3, 10, 11, 14.** Unsafe path traversal is distinguished from a user-selected alias/file reference. No blanket symlink rejection is prescribed. IP-2A/IP-5/IP-7 jointly settle aliases, security-scoped URLs, permissions and identity; any allowed resolution must be explicit, bounded and resistant to replacement.
3. **Unknown geometry — §§6, 10, 12.** UnknownLiteral is uninterpreted source metadata only and never drives navigation, distance, selection or transformation. IP-3 may use explicitly qualified types only; schema-prohibited literals fail closed. No Loxodrome/Orthodrome fallback. Incoming-leg ownership and source order remain intact.
4. **Source digest privacy — §§6, 8, 14.** No RTZ digest is calculated or persisted by default and no source hash is exposed in diagnostics, logs, CLI output or Shortcut messages. IP-2A may propose one only for documented need, privacy review and explicit approval. Required schema artifact hashes remain separate.

## Approved upstream direction

V1 remains an offline macOS Apple Silicon tool with a macOS Shortcut as primary UI and a self-contained local CLI, no standalone GUI, and no target-Mac Homebrew/Python requirement. It supports the three approved route modes with explicit user selections, emits GPX 1.1, preserves the input RTZ, and makes metadata losses visible. No automatic navigation decisions or ECDIS-equivalence claim. RTZ 1.0/1.2 are mandatory targets subject to qualification; 1.1 is conditional; RTZP is out of scope. Distance remains advisory only. IP-1 review conditions remain recorded in its approved plan.

## Open dependencies and risks

- IP-1A must qualify exact 1.0/1.2 schema pairs, hashes and fields and resolve legal/runtime validation strategy; these block parser implementation.
- IP-1B must supply reviewed synthetic fixture IDs and outcomes.
- IP-2A must verify parser behavior, resource enforcement, limits, cancellation and joint file-reference/alias policy with IP-5/IP-7 on candidate macOS versions.
- ID uniqueness, minimum useful waypoint count, geometry literals, optional metadata rules, precision representation and extension-summary policy require evidence/review.
- IP-5/IP-7 must resolve file-reference/alias behavior and cross-check diagnostic identifiers before those contracts freeze.

No contradiction with the Master Plan or IP-1 was identified. Dependencies that remain conditional are explicitly marked; no schema version, licensing, runtime, or security behavior is represented as implemented or tested.

## Changed files and verification

- `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md`
- `REPORT.md`
- `PROGRESS.md`

Documentation-only changes. No application code, parser, model, fixture, test, schema, dependency, CLI, Shortcut, package, or test run. No real RTZ/GPX routes, derived coordinates, or credentials are included.

## Repository state

- Branch: `docs/ip-2-safe-input-model-parser`
- Base: approved IP-1 planning commit `6ed649d3995f70fa2421e08cb027c07d19b4cad4`
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- Commit SHA and remote verification are recorded in the task handoff after the focused planning commit.

## Review request and next process

Please review the IP-2 architecture, proposed limits, security behavior, semantic classifications, model semantics, and upstream blockers. After IP-2 review and separate authorization for the remaining detailed plans, cross-check the full plan set at Gate 3, resolve findings, then obtain explicit Gate 4 authorization before any implementation. Stop after this planning commit.
