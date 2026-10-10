# Architect review handoff

## IP-3 planning handoff

- **IP-3 PLAN: SUBMITTED FOR ARCHITECTURAL REVIEW (Gate 2).**
- **IP-3 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Planning branch is based on corrected IP-2 commit `8011d3f0c4baf62cb15194ab9308f4e312269615`; no upstream execution PASS is implied.

Created `docs/implementation/IP-3-ROUTE-MODES-GEOMETRY-PLAN.md`. It specifies Full Route, From Waypoint, Current Position / Direct to Next WP, and Current Position / Join Selected Route Leg; immutable source-order transforms; scoped ordinal waypoint/leg references; incoming-leg ownership; synthetic-point and source-leg provenance; preview-bound explicit confirmation; privacy-safe diagnostics; metadata losses; advisory-only distance; and IP-4/IP-5/IP-7 handoffs. The proposed great-circle finite-arc projection and rhumb finite-leg global-minimum approach are qualification-gated, not claimed verified. If reliable rhumb root enumeration cannot be established, IP-3E remains blocked for architectural decision; no fallback or silent scope downgrade is permitted.

Remaining decisions/evidence include IP-1 qualified schema/geometry literals and independent distance oracles/tolerances; IP-2 implemented model and ID semantics; exact output minimum/duplicate-coordinate policy; great-circle degeneracy thresholds; rhumb global-minimum reliability; field-by-field split-leg metadata applicability; and IP-4/IP-5/IP-7 interface contracts. IP-1 and IP-2 are plan-approved but their execution evidence is pending. Gate 3 remains pending the complete detailed-plan set and cross-check.

No implementation code, tests, fixtures, probes, schemas, dependencies, CLI, GPX, or Shortcuts were created or run. No real routes, derived vessel coordinates, credentials, or full source-route digest were added.

## IP-3 repository state

- Branch: `docs/ip-3-route-modes-geometry`
- Base: `8011d3f0c4baf62cb15194ab9308f4e312269615`
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- Commit and remote-head verification: to be recorded after the focused planning commit.
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
