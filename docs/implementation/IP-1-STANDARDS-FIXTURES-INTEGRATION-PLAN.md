# IP-1 — Standards, Fixtures, and Integration/Packaging Discovery

**Plan status:** Draft for architectural review (Gate 2). **Implementation:** NOT AUTHORIZED. This plan-authoring task created no probes, fixtures, tests, software, schemas, packages or Shortcuts. **Baseline:** `docs/master-plan` at `d57d0935c7885eb25eb14542e7996839644e96e2`. The approved Master Plan is authoritative; this document plans Stage 1 only and does not alter it or start IP-2 through IP-7.

## 1. Objective and boundaries

IP-1 must turn the approved Stage 1 outline into evidence-backed decisions and downstream contracts: qualify RTZ versions; establish schema provenance and rights; design synthetic cases; review independent distance vectors; freeze the proposed GPX 1.1 contract; assess Shortcuts/CLI feasibility and self-contained packaging; and prepare a synthetic-only Windy acceptance protocol. The plan is detailed enough to guide a separate authorized executor without delegating major architectural choices to them.

**In scope:** documentary standards/platform research; exact version/namespace/schema qualification ledger; static synthetic fixture design; reviewed geometry vectors; GPX shape, precision, determinism and loss policy; a no-route-data probe design; packaging recommendation; Windy test protocol; dependencies and objective exit evidence.

**Out of scope:** product code, parser/converter/CLI/GUI, schemas, packages, dependency installation, Shortcuts/Quick Actions, executable fixture generators, tests, or Windy upload during this task. Static synthetic XML fixture data may be authored only during separately authorized IP-1 execution; executable parser/serializer tests are downstream work. No real route, derived coordinate, vessel position/identity, operational note, or user-specific path. RTZP remains OUT OF SCOPE for V1, may be reconsidered after V1, and has no implementation stage.

Plan approval is not IP-1 execution PASS and does not authorize probes or implementation. The complete Gate 2 plan set must first pass Gate 3 cross-check, then the user must explicitly authorize Gate 4 execution.

## 2. Fixed decisions and evidence rules

1. RTZ 1.0 and 1.2 are mandatory V1 targets subject to schema-backed qualification; 1.1 is conditional and not a release blocker.
2. Accept only exact version plus root namespace pairs. Unknown versions, mismatches and unsupported dialects fail clearly; no fallback guessing.
3. Single uncompressed `.rtz` XML input; RTZP out of scope.
4. Distance is advisory only and must never select, infer, move, densify or otherwise modify the intended route. No ECDIS geometry equivalence.
5. Preserve approved convention: WGS84 authalic sphere radius 6,371,007.1809 m; Loxodrome as rhumb and Orthodrome as great-circle; 1 NM = exactly 1,852 m.
6. GPX 1.1 output: one ordered `<rte>`, ordered `<rtept>`, existing waypoint names, user-confirmed route name, no `<trk>` by default, no misleading navigation metadata.
7. Offline runtime, macOS Shortcuts primary UI, self-contained local CLI, no standalone GUI, Homebrew or target-Mac Python requirement.
8. Current Position needs manual lat/lon, explicit next-WP and route-leg confirmation, and Direct to Next WP / Join Selected Route Leg choice. No automatic navigational decisions.

Label each result **Verified fact** (primary source/reproducible result), **Observed result** (authorized bounded probe and environment), **Decision** (rationale/downstream effects), **Assumption/open question** (owner and closure stage), or **Not qualified** (reject until evidence closes gap). A schema’s existence alone never means a version is implemented, verified or supported.

## 3. RTZ version/schema qualification

### 3.1 Provenance, pinning and rights

For each XSD, test set and specification record issuer, exact title/revision, canonical URL, UTC retrieval date, normative/informative/proposal/sample status, filename, byte size, SHA-256, declared version, targetNamespace, imports/includes and test-suite revision. Track each dependency and its hash. Candidate references are [CIRM RTZ XML Schemas](https://cirm.org/rtz-xml-schemas), [IEC PAS 61174-1:2021](https://webstore.iec.ch/en/publication/67774), and [STM schema materials](https://www.seatrafficmanagement.info/developers-forum/schemas/). The approved Master Plan reports CIRM 1.0/1.2 schema publication and IEC’s revised 1.2 retaining 1.0; historical STM 1.1 is only a research lead, not an assumed normative equivalent. IP-1 must inspect the actual artifact and licensed normative text as necessary.

A public download does not prove redistribution rights. Record license/terms and link or written permission. If terms are ambiguous, mark **not cleared for bundling**; do not vendor or claim offline validation is ready pending resolution. Do not rewrite an official schema and label it official. Record exact digests in `docs/research/IP-1/RTZ-SCHEMA-QUALIFICATION.md`; a changed digest requires re-review. Schema retrieval is development-time only. Runtime schema dependencies must be closed, local, licensed and incapable of network resolution.

### 3.2 Exact allowlist and structural comparison

Allowlist is keyed by `(version attribute, root expanded name)`. Verify 1.0 `version="1.0"` + expected `http://www.cirm.org/RTZ/1/0` against the pinned schema. Read 1.2 namespace from the actual pinned XSD; do not infer it. For 1.1, evaluate each specific STM/vendor lineage and namespace; otherwise reject. Do not normalize `1`, `1.0.0`, namespace aliases or vendor URIs without an explicit schema-backed rule.

Create a reviewed field matrix, with schema component path, exact observed difference, prose source, handling, fixture ID and uncertainty, for: route root and routeInfo/vessel metadata; waypoint sequence, IDs/revisions/names/radii/position/defaults; leg placement and geometryType/radius/XTD/speed/course/safety/notes/Leg Extensions; schedules/ETA/references; extension containers/namespaces/wildcards. Classify each field as recognized, intentionally loss-reported, opaque extension, or unsupported dialect. Compare types, cardinalities, order, enumerations and wildcard processing across pinned schema hashes. Never fill differences from memory: if none, say “no difference observed in pinned artifacts [hashes].” Schema diff does not establish semantics; distinguish normative sources from proposals.

| Version | Approved policy | Qualification rule |
|---|---|---|
| RTZ 1.0 | Mandatory V1 target | Exact schema/hash/namespace; all §3.3 evidence required. |
| RTZ 1.2 | Mandatory V1 target | Exact schema/hash/namespace; all §3.3 evidence required. |
| RTZ 1.1 | Conditional, non-blocking | Qualify only a specifically named lineage with rights-cleared schema and fixtures; otherwise reject. |

### 3.3 Evidence and parser contract

Qualification requires: traceable schema and dependency hashes; offline redistribution disposition; exact version/namespace pairing; reviewed structural/field/loss comparison; synthetic positive and negative fixtures; offline validation with external access disabled; separation of schema checks from semantic/safety checks; independent reviewer sign-off. If a mandatory target does not satisfy all, it remains unqualified and cannot be claimed supported. 1.1 may remain unqualified without blocking V1.

Downstream parser must inspect root expanded name/version before schema selection; disable DTD, external entities, XInclude, external schema fetch and URI resolution; ignore input `xsi:schemaLocation`; use closed local schema catalog; fail closed on missing schema. IP-2 sets bounded byte/depth/node/text/waypoint limits. Distinguish malformed XML, unsupported/mismatched dialect, schema-invalid, semantically invalid, and recognized-but-dropped data. No namespace stripping, permissive fallback or best-effort coordinate extraction.

## 4. Synthetic fixture strategy

Invent all data from scratch using neutral labels such as `SYN-A`, `SYN-B`; no route-derived or anonymized real coordinates, vessel IDs, operational text, real voyage dates, personal paths or names. Record synthetic provenance and per-file SHA-256. Proposed static corpus (design only; no files created):

- `tests/fixtures/rtz/synthetic/README.md`
- `valid-rtz-1.0-minimal.xml`, `valid-rtz-1.0-fields.xml`
- `valid-rtz-1.2-minimal.xml`, `valid-rtz-1.2-fields.xml`, `valid-rtz-1.2-schedule-extension.xml`
- `mismatch-version-1.0-namespace-1.2.xml`, `mismatch-version-1.2-namespace-1.0.xml`, `unsupported-version-9.9.xml`
- `missing-coordinate.xml`, `out-of-range-latitude.xml`, `out-of-range-longitude.xml`
- `missing-waypoint-id.xml`, `duplicate-waypoint-id.xml`, `unnamed-waypoint.xml`
- `mixed-leg-geometries.xml`, `radius-and-xtd.xml`, `schedule-and-extension.xml`
- `antimeridian-crossing.xml`, `high-latitude.xml`, `duplicate-consecutive-points.xml`, `discontinuity-warning.xml`
- `malformed-not-well-formed.xml`, `unsafe-doctype-entity.xml`, `excessive-depth.xml`
- `oversized-input-fixture.spec.md` (temporary generation recipe only; no huge file in Git)

Manifest each ID with source dialect, purpose, expected schema result, expected semantic/warning category, route order if applicable, field coverage and hash. Expected outcomes: positives pass matching schema; crossed and unknown dialects reject before schema selection; missing/range-invalid coordinates fail at declared schema or semantic layer; IDs follow actual schema and documented duplicate policy; unnamed point remains unnamed; mixed legs retain type for advisory calculation; radius/XTD/schedules/extensions are counted as losses; antimeridian/high-latitude vectors are stable without moving points; duplicate/discontinuity warns without repair; malformed XML fails without leaking content; entity sentinel is never resolved; depth/size trips a documented bound. Never weaken schema to force a negative fixture through. If XSD catches a case first, state that phase. Oversize case is generated in a later temporary test after IP-2 selects limits.

Static fixture creation is later work, not this plan. No executable generator/test is planned. Review every XML diff and secret/route scan before commit. Arbitrary user RTZ/RTZP/GPX remains excluded; synthetic data is explicitly reviewed and allowlisted.

## 5. Advisory geometry vectors

Keep approved convention unchanged: WGS84 authalic sphere `R=6,371,007.1809 m`; shortest spherical orthodrome; spherical rhumb with shortest signed longitude delta for the segment and explicit pole behavior; `NM=metres/1852`; use destination waypoint’s incoming `geometryType`; unknown/missing type means unavailable diagnostic, never inferred. GeographicLib defaults to ellipsoid; configure sphere for direct comparison or label ellipsoid comparison separately. No ECDIS equivalence.

`docs/research/IP-1/GEOMETRY-REFERENCE-VECTORS.md` records endpoints, method, formulas, full-precision metres/NM, two derivations, reviewer and tolerance. Minimum vectors:

| ID | Endpoints/method | Planning expectation |
|---|---|---|
| GC-EQ-1 | (0,0) to (0,1), orthodrome | R·π/180 ≈111,195.05 m / 60.0405 NM. |
| RH-EQ-1 | Same, loxodrome | Same as GC-EQ-1 within reference rounding. |
| RH-MER-1 | (0,0) to (1,0), rhumb | Same one-degree spherical arc. |
| GC-AM-2 | (0,179) to (0,-179), orthodrome | Short 2° ≈222,390.16 m /120.0809 NM, not 358°. |
| RH-LAT60-10 | (60,0) to (60,10), rhumb | R·cos(60°)·10π/180 ≈555,975.4 m /300.202 NM. |
| GC-LAT60-10 | Same endpoints, orthodrome | Independently derived spherical value, shorter than rhumb. |
| ZERO-1 | Same valid endpoints | Exactly zero; no NaN or route mutation. |
| NEAR-1 | Very short distinct endpoints | Small finite positive value checked against high-precision reference. |
| POLE-1 | Near-pole endpoints and exact boundary | Finite near-pole case; explicit reviewed unavailable/error at singularity. |
| GC-ANTI-1 | Near antipodes | Stable shortest distance; directional ambiguity documented. |
| NM-1 | 1,852 metres | Exactly one NM. |

Listed values are reasonableness checks, not final oracle. Two independent calculations and reviewer reproduction establish full values. For well-conditioned future comparisons use `max(0.01 m, 1e-10 × reference_m)`; reviewer recomputation within `max(0.1 m, 1e-8 × reference_m)`. Pole/near-antipode cases get separately reviewed behavior/tolerance. Any relaxed tolerance needs evidence and approval before IP-3. Assert route coordinates unchanged before/after diagnostic calculation. Warning thresholds are separate; distance never changes route.

## 6. GPX 1.1 contract proposal

One source route produces exactly one `<rte>` in GPX 1.1 namespace `http://www.topografix.com/GPX/1/1`, root `version="1.1"`, truthful required `creator` (proposed stable name `RTZ-GPX-Converter`, exact value/version rule in IP-4). Ordered `rtept` coordinates match transformed route order. No duplicate `<wpt>` list and no `<trk>` by default. GPX ordered route vertices do not preserve RTZ geometry, turns, XTD, wheel-over or ECDIS drawing.

`rte/name` is user-confirmed; when source name is absent offer a neutral proposal and require confirmation. Include `rtept/name` only for non-empty source waypoint names. Never create names or copy IDs/revisions into unrelated metadata. Omit author, time, extensions, schedules, vessel/safety/leg fields unless separately approved mapping exists.

Preserve numeric coordinate value; prefer decimal-preserving parse and shortest round-trippable locale-independent decimal. No fixed rounding without error bound; no exponent until schema/consumer review; reject nonfinite/out-of-range; decide negative zero and Unicode normalization in IP-4. Use standards-compliant XML serializer, never concatenate names; invalid XML characters fail field-locally. Define UTF-8, declaration, newline, indentation, child order, fixed creator, no timestamp/random IDs. If byte-level attribute ordering is library-dependent, define deterministic GPX infoset and document byte behavior. Pin GPX schema/hash/license and validate offline; never fetch schemaLocation.

Reparse output and compare count/order/numeric coordinates/route name/names. Report dropped IDs/revisions, radius, leg geometry, XTD, speed/course/safety, notes, schedules/ETAs, vessel/route info and opaque extensions by category/count, never payload. State: “Coordinates and ordered waypoint names copied; RTZ navigation semantics are not preserved.” Primary reference: [Topografix GPX 1.1 schema](https://www.topografix.com/gpx/1/1/).

## 7. Shortcuts-to-CLI feasibility

Apple documents Shortcuts Quick Actions, Dock, keyboard, Finder input and local `.shortcut` import. Apple’s WWDC Shortcuts materials discuss migrated Automator shell-script actions. These sources do not prove the V1 data transport, output/error handling, cancellation or minimum-OS behavior. Sources: [Run a shortcut while working on Mac](https://support.apple.com/en-gb/guide/shortcuts-mac/apd163eb9f95/mac), [Import shortcuts](https://support.apple.com/guide/shortcuts-mac/apd02bffbaac/mac), [Shortcuts User Guide](https://support.apple.com/guide/shortcuts-mac/welcome/mac), [WWDC Shortcuts for macOS](https://developer.apple.com/videos/play/wwdc2021/10232/). [Foundation Process](https://developer.apple.com/documentation/foundation/process) accepts a discrete argument array but may add package/sandbox complexity.

| Approach | Benefits | Risks | Position |
|---|---|---|---|
| A. Shortcuts Run Shell Script with fixed script and typed input as argv/stdin | Minimal, same Shortcut, no Terminal | Must prove file objects aren’t flattened/split and errors/output/cancellation work | Preferred probe candidate only. Static script; never interpolate user paths. Prefer discrete argv, otherwise validated unambiguous stdin protocol. |
| B. Fixed native launcher using Foundation Process explicit argv | Native argv and stdout/stderr/exit capture | New executable, signature/path/access complexity | Fallback only after architecture review if A fails. |
| C. Concatenated shell commands or interpolated path | Superficially easy | Injection, quoting/path splitting, weak errors | Rejected. |
| D. Direct executable Shortcut action | Potentially simple | No built-in action proven by cited official evidence | Research only, do not assume. |

**Deferred probe (not run now):** only if documentation is insufficient and separately authorized. Temporary inert helper reports argument count, byte lengths and UTF-8 hex for harmless values; no RTZ parser, file contents, network, writes or input evaluation. Try spaces, Unicode composed/decomposed, quotes, apostrophe, semicolon, `$()`, leading dash and two files; no dynamic value in script source. Test picker and Finder, Shortcuts/Dock/keyboard, structured success and deliberate nonzero error, stdout/stderr, cancel-before-call, save and Reveal. Disable networking. Record OS build, Shortcuts version, action config and redacted data shape, no account or user paths. Pass only if values arrive intact as discrete values/one documented record, no shell evaluation/Terminal, actionable errors, Finder input unchanged, cancel creates nothing, save/reveal works offline and behavior repeats on oldest/current candidate OS. Otherwise reject A, assess B or record blocker. This probe requires explicit authorization and creates no product artifact.

Feasibility matrix per OS covers: native single-.rtz picker and cancel; Finder selected input/no repick; reject multiple/non-RTZ; all launch paths; spaces/Unicode/metacharacters; mode prompts and manual confirmations using inert data; native destination/collision/permission behavior; useful errors; Finder reveal; offline local Shortcut import. Minimum OS remains open until actual candidate OSes pass.

## 8. Packaging and deployment

Compare: (1) arm64 Swift CLI inside signed app bundle used only as container plus `.shortcut` (stable internal path; risks bundle movement, Gatekeeper, file access, perceived GUI); (2) signed standalone user-level CLI in Application Support (no GUI, but path/quarantine/update risks); (3) installer package (stable path but complexity/admin/system scope). No Homebrew/Python/runtime network/Terminal. Swift toolchain build-time only; universal binary not required unless reason found.

Investigate signed/notarized DMG as preferred candidate over ZIP for clearer installation and ticket stapling; verify actual nested executable and offline Gatekeeper behavior. Apple documents direct distribution, Developer ID, notarization, ticket and that a ZIP itself is not signed: [Packaging Mac software](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution), [Notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution). If signing identity/account is unavailable, report a release blocker or approved alternative; never ask users to bypass Gatekeeper. App Store is not default; research sandbox file access, external CLI and local Shortcut import before considering it.

Candidate install: versioned DMG with CLI app bundle (no GUI), exported `.shortcut`, install/remove instructions. Decide `~/Applications` vs `/Applications` only after testing permissions and path stability. Import Shortcut locally, enable Finder Quick Action, add Dock icon, configure keyboard shortcut. Update replaces bundle atomically and reimports Shortcut only as needed; rollback retains prior version; uninstall removes only app artifacts, never user routes. No auto-updater/service. Clean-user test has no Homebrew/Python/dev tools/prior configuration/admin; install, run offline, Gatekeeper, update, rollback, uninstall. OS matrix records build, picker/input, Quick Action, Dock/keyboard, shell, permissions, save, CLI, Gatekeeper, local import and offline. Select oldest OS only if every required flow passes and can be tested.

Artifact `docs/research/IP-1/PACKAGING-DECISION.md` compares admin need, path, signing, install/offline, update/remove, Shortcut access, clean-user evidence, OS floor, account/cost and risks. No package/tool installed during planning.

## 9. Windy Stage 6 protocol (design only)

No upload in IP-1. Stage 6 uses a small synthetic GPX: neutral route name, 4–6 ordered points, distinct labels, separated endpoints, no extensions; optional edge-case file only if useful. Test separately:

1. **Uploader:** record upload/display behavior; do not assume editable Planner object.
2. **Route Planner:** record its actual GPX import entry and whether result is route, track or other; stop before publish/share.

Record UTC date, platform/browser/app version, generic test-account context only, entry path, synthetic file hash/schema validity, route-vs-track, count/order/names/endpoints/geometry, truncation/normalization/reordering, paraphrased error. Verify order from imported list/object, not visual impression. No personal screenshots. Acceptance is date/version bounded, not ECDIS equivalence. Artifact `docs/research/IP-1/WINDY-ACCEPTANCE-PROTOCOL.md`; empirical result is Stage 6 only.

## 10. IP-1 execution sub-stages

All work below is future work after Gate 3 and explicit Gate 4 authorization. Each sub-stage returns evidence; planning approval is not PASS.

### IP-1A — Schema provenance and qualification

- **Objective:** pin schemas/rights, compare structures, decide exact pair matrix/status.
- **Artifacts:** `docs/research/IP-1/RTZ-SCHEMA-QUALIFICATION.md`, source manifest; no schema vendoring before rights.
- **Dependencies/interface:** authorized work and official/licensed sources; IP-2 consumes pair allowlist, schema IDs, fields, rights, reject cases.
- **Sequence:** obtain sources read-only; hash/rights/dependency review; component diff; normative semantic research; qualification evidence; independent review.
- **Future cases:** right pair selects right schema; cross/unknown rejects; positive/negative offline validation; no network.
- **Risks/mitigations:** inaccessible text, 1.1 ambiguity, changed hash, unclear rights; keep unqualified, do not block 1.0/1.2 on optional 1.1.
- **Rollback:** revert only records/schema additions, mark dialect unqualified; Master Plan untouched.
- **PASS evidence:** hash/rights ledger, reviewed diff, exact pairs, offline evidence and reviewer sign-off.

### IP-1B — Synthetic fixture catalog/static corpus

- **Objective:** author §4 catalog and synthetic XML only; no generator or test suite.
- **Artifacts:** `tests/fixtures/rtz/synthetic/README.md` and listed XMLs; optional `docs/research/IP-1/FIXTURE-CATALOG.md`.
- **Dependencies/interface:** IP-1A schema; downstream tests use stable IDs, outcomes and route order.
- **Sequence:** model synthetic route; create positives; add field and negative cases; validate according to schemas; provenance review, hashes and privacy scan.
- **Future cases:** positives validate, negatives fail correct phase, entity sentinel untouched, oversize temporary, no private data.
- **Risks/mitigations:** impossible fixture/large file/derived data; schema-linked authoring, temp oversize, independent privacy review.
- **Rollback:** remove implicated fixture and catalog row; explain, do not weaken schema.
- **PASS evidence:** complete reviewed catalog, schema outcomes, hashes and privacy sign-off.

### IP-1C — Geometry vectors and GPX contract

- **Objective:** independent vector oracle/tolerances and frozen GPX contract.
- **Artifacts:** `docs/research/IP-1/GEOMETRY-REFERENCE-VECTORS.md`, `docs/research/IP-1/GPX-1.1-CONTRACT.md`.
- **Dependencies/interface:** approved convention and GPX source; IP-3 consumes methods/units/vectors, IP-4 consumes shape/naming/precision/escaping/loss.
- **Sequence:** two independent derivations; poles/antipodes; no-mutation invariant; schema mapping; precision/escaping/determinism and metadata review.
- **Future cases:** reviewer reproduces within tolerance, route unchanged, schema accepts shape, round-trip contract explicit.
- **Risks/mitigations:** sphere/ellipsoid mix, false precision, consumer normalization; label model and defer Windy to Stage 6.
- **Rollback:** revert unapproved contract; do not change Master Plan convention.
- **PASS evidence:** signed vectors and reviewed downstream GPX contract.

### IP-1D — Shortcut feasibility

- **Objective:** documentation review and, only if necessary, separately authorized inert probe.
- **Artifacts:** `docs/research/IP-1/SHORTCUTS-FEASIBILITY.md`; redacted evidence; no product Shortcut/helper.
- **Dependencies/interface:** Gate 3 and probe-specific Gate 4 authorization; IP-5 gets transport/error, IP-7 gets launch/input/output/OS.
- **Sequence:** source mapping, action input review, compare options, request/run bounded probe if needed, record result/recommendation.
- **Future cases:** full §7 matrix on candidate OSes; path intact, no evaluation, errors/cancellation/save/offline correct.
- **Risks/mitigations:** action changes, permissions, flattened input; test oldest/current, static script, discrete argv/stdin, fail closed.
- **Rollback:** remove temp helper/files and restore shortcut settings; retain only redacted result.
- **PASS evidence:** official mapping plus repeatable results as needed, accepted invocation/fallback and no interpolation proof.

### IP-1E — Packaging decision

- **Objective:** recommend self-contained path, container, OS floor, signing, update/remove.
- **Artifacts:** `docs/research/IP-1/PACKAGING-DECISION.md`; no binary/package.
- **Dependencies/interface:** IP-1D and Apple docs; IP-5 gets path/runtime policy, IP-7 install procedure.
- **Sequence:** compare candidates; assess Swift CLI/bundle/path without building; ZIP/DMG/security/account review; clean-user requirements.
- **Future cases:** clean user/no tools/admin installs and runs offline, Gatekeeper passes, update/rollback/uninstall preserves user data.
- **Risks/mitigations:** absent signing, path movement, permissions; record blocker, no security bypass, reversible user-level path.
- **Rollback:** revise recommendation; no system artifact exists.
- **PASS evidence:** comparison, preferred path and assumptions, OS floor or named blocker and clean-user procedure.

### IP-1F — Windy protocol

- **Objective:** separate synthetic Uploader/Planner acceptance procedures; no IP-1 upload.
- **Artifacts:** `docs/research/IP-1/WINDY-ACCEPTANCE-PROTOCOL.md`.
- **Dependencies/interface:** GPX contract; IP-6 gets steps, measurements, privacy controls.
- **Sequence:** test-file profile, entry paths, route/track checks, evidence template/no-share rule.
- **Future cases:** protocol can determine order/count/names/endpoints/geometry/truncation safely.
- **Risks/mitigations:** UI changes/accidental publication; verify current UI and stop before sharing.
- **Rollback:** remove only synthetic test object if safe; no real data.
- **PASS evidence:** reviewed date-bounded protocol and separate outcomes.

### IP-1G — Integration and closeout

- **Objective:** reconcile A–F, trace requirements and blockers, request IP-1 execution review.
- **Artifacts:** `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md`; update REPORT/PROGRESS only for actual execution.
- **Dependencies/interface:** A–F artifacts; frozen handoff for IP-2–IP-7.
- **Sequence:** cross-check schema/fixtures, geometry/GPX, invocation/package, Windy; trace criteria; assign blocker owners; privacy scan; update actual evidence.
- **Future cases:** every mandatory criterion maps to evidence; open items have owner/closure and cannot invalidate mandatory scope.
- **Risks/mitigations:** hidden contradiction/license/OS issue; do not waive mandatory blockers; optional 1.1 may remain unqualified.
- **Rollback:** revert rejected IP-1 artifacts and return to REVIEW.
- **PASS evidence:** independent architect accepts execution evidence; reports record actual state/hash. Plan approval alone never marks implementation PASS.

## 11. Downstream dependencies

| Plan | Required IP-1 handoff | Freeze before dependent implementation closes |
|---|---|---|
| IP-2 Parser | Version pairs/schema/rights, field matrix, schema-vs-semantic rules, fixture IDs, security/errors | Exact root/version contract, local schema policy, known fields; unqualified dialects reject. |
| IP-3 Modes/geometry | Convention, vectors/tolerances, geometryType, warning cases and no-mutation invariant | Radius/method/units, unknown type, pole/date-line, tolerance; no ECDIS claim. |
| IP-4 GPX | One-route schema, names, precision/escaping/determinism, offline validation/loss | Root/creator/order/no track, schema rights, numeric preservation and metadata. |
| IP-5 CLI/runtime | Version matrix, package/path, transport/error evidence, Unicode cases, offline rule | Exact input/output transport, structured result/exit behavior and stable path; CLI syntax remains IP-5’s decision within these constraints. |
| IP-6 Windy | Synthetic protocol, separate Uploader/Planner and privacy template | File profile and observations; no real data/ECDIS claim. Actual result remains Stage 6. |
| IP-7 Shortcut/release | Invocation/fallback, OS floor, launch/picker/Finder/save/cancel/permissions, install/sign/remove | Safe tested transport, stable path, local shortcut import, package/signing or blocker. |

IP-2–IP-7 plans require separate authorization for the complete set. Any conditional contract needs an owner and closure before dependent implementation.

## 12. Acceptance criteria

**Planning acceptance for this document:** scopes, workflow, files, sub-stages, interfaces, future verification, rollback, risks, dependencies and exit criteria are specified; approved decisions preserved; no AGENTS/Master Plan edit; no code, executable fixtures/tests, schema/package/Shortcut; facts separated from assumptions.

**Future IP-1 execution PASS requires:** (1) hash-pinned 1.0/1.2 schema and dependencies with rights for offline use; (2) reviewed structural/field comparison and exact pairs/errors; (3) positive/negative synthetic examples per mandatory version, hashes and privacy approval; explicit optional 1.1 decision; (4) independent vectors for GC/rhumb/NM/date-line/high-latitude/degenerate cases, tolerances and no-mutation verified; (5) frozen GPX contract and offline schema policy; (6) safe Shortcuts feasibility with authorized probe if needed and no interpolation; (7) self-contained package recommendation, tested OS floor or blocker, local Shortcut/install/update/remove and clean-user/offline criteria; (8) separate synthetic Windy protocol, no IP-1 upload; (9) every mandatory item evidence-mapped, no hidden blocker; (10) privacy scan finds no private routes, derived coordinates, identity, credentials or user paths; (11) reports state actual execution status. Any failed mandatory criterion means REVIEW/BLOCKED, not PASS. Optional 1.1 may remain not qualified.

## 13. Open questions and owners

1. CIRM schema/dependency redistribution rights — IP-1A; before bundling.
2. Exact 1.2 namespace/version pairing — IP-1A; before allowlist freeze.
3. Specific rights-cleared 1.1 lineage and Leg Extensions — IP-1A; optional, may reject.
4. Permitted local XSD validator without target runtime — IP-1A/IP-5; no installation absent authorization.
5. Constraints beyond XSD — IP-1A/IP-2.
6. Numeric preservation vs deterministic GPX lexical output — IP-1C/IP-4.
7. Lossless Shortcut file transport/error/cancel on candidate OS — IP-1D; any probe needs specific authorization.
8. Developer ID availability/app-bundle container suitability — IP-1E; otherwise release blocker/options.
9. Minimum macOS passing all flows — IP-1D/IP-1E; before IP-7 plan closes.
10. Current Route Planner GPX import and preserved fields — Stage 6 only, following IP-1F protocol.

## 14. Privacy, change control and rollback

This task changes only this plan plus REPORT/PROGRESS. Leave `AGENTS.md` and approved Master Plan unchanged. Future evidence uses public standards metadata and synthetic data. Do not commit private routes, derived positions, credentials, private screenshots or local paths. Cite sources and distinguish facts from assumptions; changed source hash triggers requalification. Revert only rejected sub-stage files and return status to REVIEW; no force-push. Any finding requiring changes to approved scope/version/geometry/UI/privacy decisions stops dependent work for explicit approval.

## 15. Execution sequence after authorization

1. Complete Gate 3 cross-check of all IP-1–IP-7 plans and resolve findings.
2. Obtain explicit Gate 4 authorization, naming any probe/schema/tool acquisition.
3. IP-1A qualification; stop on unresolved mandatory rights/schema.
4. IP-1B static synthetic cases after schemas settle.
5. IP-1C vector and GPX contracts; reconcile IP-3/IP-4.
6. IP-1D documentary work; request separate probe approval if needed.
7. IP-1E packaging using D findings.
8. IP-1F protocol only; empirical Windy remains Stage 6.
9. IP-1G privacy/completeness review and architectural acceptance request.

## 16. References

- [CIRM RTZ XML Schemas](https://cirm.org/rtz-xml-schemas) — primary schema/test discovery; verify exact payloads/rights.
- [IEC PAS 61174-1:2021](https://webstore.iec.ch/en/publication/67774) — official overview of revised 1.2 retaining 1.0; licensed normative text may be needed.
- [STM schemas](https://www.seatrafficmanagement.info/developers-forum/schemas/) and [STM 1.1 proposal](https://stm-stmvalidation.s3.eu-west-1.amazonaws.com/uploads/20190322122013/ECDIS-Annex-S-version-1.1-STM-Extended_29032017_Final_Proposal.pdf) — historical lineage only.
- [Topografix GPX 1.1](https://www.topografix.com/gpx/1/1/).
- [GeographicLib](https://geographiclib.sourceforge.io/index.html), [Geodesics](https://geographiclib.sourceforge.io/html/C++/geodesic.html), [RhumbSolve](https://geographiclib.sourceforge.io/html/RhumbSolve.1.html) — independent references; configure sphere for this convention.
- [Apple Shortcuts launch/input](https://support.apple.com/en-gb/guide/shortcuts-mac/apd163eb9f95/mac), [local shortcut import](https://support.apple.com/guide/shortcuts-mac/apd02bffbaac/mac), [Shortcuts User Guide](https://support.apple.com/guide/shortcuts-mac/welcome/mac), [WWDC Shortcuts for macOS](https://developer.apple.com/videos/play/wwdc2021/10232/).
- [Foundation Process](https://developer.apple.com/documentation/foundation/process) — argv and subprocess fallback with sandbox caveats.
- [Apple packaging](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution), [notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution), [sandbox file access](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox).

## Approval request

Review scope, schema qualification, fixture design, numerical acceptance, safe invocation, packaging criteria, decomposition and downstream contracts. Then complete/cross-check all detailed plans, resolve findings, obtain explicit implementation authorization and execute one stage at a time. **Do not begin IP-1 execution or implementation based only on approval of this plan.**
