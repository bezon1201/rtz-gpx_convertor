# RTZ-GPX-Converter — Master Plan

**Status:** Draft for architect review (Gate 1). This document sets project direction; it is not an implementation plan. No application code, conversion scripts, tests, GUI, Finder Quick Action, or packages are part of this stage.

## 1. Purpose and boundaries

Plan a small, reliable, fully offline macOS Apple Silicon utility that converts selected maritime RTZ routes into GPX 1.1 for personal weather assessment in Windy. It preserves source RTZ unchanged and makes the coordinate and metadata losses visible.

This utility is not an ECDIS, chart plotter, approved passage-planning tool, safety-checking system, route optimizer, weather service, or source of navigational advice. The Master remains responsible for route and weather judgment. GPX display in Windy must never be described as operational or navigational equivalence to the source ECDIS route.

## 2. Discovery and format research

### 2.1 Sample inspection

The repository had no sample files. Two RTZ routes supplied earlier in this conversation were inspected read-only; no route names, coordinates, vessel identifiers, source file, or derived GPX were added to Git.

Observed in those samples:

- Both declare RTZ `version="1.0"` and namespace `http://www.cirm.org/RTZ/1/0`.
- One contains 35 waypoints and one 51. Coordinates are `lat`/`lon` decimal-degree attributes under `position`; waypoint order is represented by XML order.
- Waypoint attributes observed include `id`, `revision`, optional `name`, and `radius`. A `leg` child is associated with each destination waypoint and uses `geometryType`; observed types include `Loxodrome` and `Orthodrome`.
- Observed leg metadata includes port/starboard XTD, speed bounds, and free-text leg notes. Both files include a `schedules` section with a `CalculatedSchedule`; the schedules and waypoint names differ between samples.
- No `defaultWaypoint` or extensions block was present in either sample.

These observations establish sample shapes only. They do not establish general vendor behavior or broad version support. No fixture is committed. Future public fixtures must be sanitized synthetic data; real voyage routes remain private.

### 2.2 Verified format facts and support posture

| Version / format | Verified evidence | Planning posture |
|---|---|---|
| RTZ 1.0 | CIRM publishes a 1.0 schema. IEC PAS 61174-1:2021 states 1.0 is retained from IEC 61174:2015. Sample namespace is `/RTZ/1/0`. | Candidate supported input; validate against a vendored, versioned 1.0 schema. |
| RTZ 1.1 | STM materials publish a 1.1 schema/proposal and use namespace `/RTZ/1/1`. IEC PAS describes 1.1 as an STM project iteration, notes it was used in STM, and says it lacked the optional `Extensions` in `Leg`. CIRM's published schema page lists 1.0 and 1.2 schema files, not a 1.1 schema. | Do not promise broad 1.1 support yet. Discovery must identify a vetted schema lineage, compare it to 1.0/1.2, and build fixtures for relevant dialects. Unsupported or ambiguous variants must fail clearly rather than be guessed. |
| RTZ 1.2 | IEC PAS 61174-1:2021 supplies revised schema 1.2 and keeps 1.0. CIRM publishes 1.2 schema and v1.2 test files. The PAS describes WGS84 coordinates and nautical-mile measurement conventions unless otherwise specified. | Candidate supported input; validate against the official 1.2 schema and test files after reviewing redistribution/licensing requirements. |
| GPX 1.1 | Topografix's GPX 1.1 schema requires `gpx` attributes `version="1.1"` and `creator`; `rte` is an ordered list of route points and `rtept` uses the waypoint type with required latitude/longitude. GPX has optional namespaces/extensions, but those do not guarantee consumer support. | Emit a minimal core GPX 1.1 route with ordered `rtept` elements. Avoid consumer-specific extensions until tested. |

Official CIRM material currently exposes 1.0 and 1.2 schema downloads and 1.2 test files. IEC's PAS says equipment should import 1.0 and 1.2; it does not make the STM 1.1 schema an equivalent third normative target. Therefore version support is to be evidence-based and stated precisely in the user guide.

RTZ 1.2 describes each route as waypoint positions plus leg parameters attached to the destination waypoint (except the first), schedules, and optional extension data. The schema covers more than coordinates: routeInfo/vessel attributes, default waypoint settings, waypoint revisions and turn radii, leg geometry and limits, schedules/ETAs, and manufacturer extensions can matter to the source system.

### 2.3 Windy evidence and open question

Windy's public Uploader page currently lists GPX among supported uploads and says it can display/share KML, GPX, or GeoJSON. This verifies that Windy accepts some GPX uploads; it does **not** prove that Windy's Route Planner imports the generated GPX as an editable route, preserves point order/names, or draws source leg geometry. Windy community material describes Route Planner GPX import, but it is not a product compatibility guarantee.

An empirical Windy acceptance test is required in Stage 6. It must use a synthetic route first, not the user's confidential voyage route; test Route Planner's import path separately from the public Uploader. Record app/web version or date, entry point, route-vs-track result, point count and order, labels, endpoint coordinates, displayed geometry, and any truncation or normalization. Do not publish or share a route during the test. Any test involving real route data requires separate explicit authorization and a privacy review.

## 3. User scenarios

1. **Full Route:** choose an RTZ file, inspect route identity, waypoint count, warnings, and metadata-loss summary, then save a GPX copy.
2. **From Waypoint:** explicitly select a waypoint in the source order and export that waypoint through the original destination. Show the resulting endpoints and remaining point count before saving.
3. **From Current Position:** manually enter the current latitude/longitude in unambiguous decimal degrees or a clearly labelled degree/minute format. Explicitly confirm the route leg and next waypoint. Show the resulting geometry and require a separate choice between:
   - **Direct to selected next waypoint:** current position followed by the explicitly confirmed next waypoint and remaining route.
   - **Join selected route leg:** current position, a displayed computed join point on the specifically selected leg, then that leg's destination and remaining route.

For Current Position, never infer the next waypoint from the nearest point or silently project a route join. If the user has not selected/confirmed the leg and downstream direction, block export. The plan view must make clear that the added segment is a user-selected convenience for weather assessment, not a navigational recommendation.

## 4. Requirements

### Functional requirements

- Inspect and report the RTZ version, namespace, route name when present, waypoint count, coordinate range, schedules/extensions presence, supported fields, and fields that will be dropped.
- Preserve waypoint order exactly. Preserve waypoint names where present; do not invent names for unnamed points.
- Offer Full Route, From Waypoint, and From Current Position as defined above.
- Keep the original RTZ unchanged. Write a new GPX using a save panel or an explicitly chosen output path; never silently overwrite an existing output.
- Validate coordinates, numeric attributes used, selected waypoint/leg, route order, minimum useful point count, XML/schema shape, and serialized GPX before reporting success.
- Present a loss summary for every recognized source property that is not carried into GPX. Unknown extension data must be counted/reported as dropped or unsupported, never silently interpreted.
- Give actionable errors and warnings without exposing raw route content in logs.

### Nonfunctional requirements

- Run conversion, parsing, validation, and distance estimation with networking disabled. No cloud conversion, telemetry, analytics, route upload, or network dependency at runtime.
- Deterministic results for identical input and choices. Preserve source precision unless a documented GPX serialization rule requires a change.
- Responsiveness for realistic route sizes; impose and document bounded input size, XML depth, waypoint count, and processing time limits.
- Accessibility and plain-language labels; units and coordinate formats must be explicit.
- Build and release for macOS on Apple Silicon. Minimum supported macOS release is unresolved until UX, Quick Action, and signing choices are validated.

## 5. Input and output contracts

### RTZ input

- Initial scope is one uncompressed `.rtz` XML document with a single `route` root. RTZP ZIP containers are out of scope pending a separate scope decision and archive-bomb threat review.
- Determine support by matching both the `version` attribute and namespace to a known dialect. A mismatch, unknown major/minor version, unrecognized namespace, unsupported schema variation, or multiple route roots is an explicit error.
- Preserve document order of `waypoint` children as route order. Treat each non-first waypoint's `leg` metadata as the incoming segment to that waypoint, as described by RTZ.
- Parse enough routeInfo, waypoint/defaultWaypoint, leg, schedules, and extension information to report recognized fields and losses. Do not claim to preserve all RTZ semantics.
- Initial support proposal: 1.0 and 1.2 after schema-backed validation; 1.1 only after discovery establishes exact supported variants and fixtures. Any other version fails with an “unsupported version” message.

### GPX 1.1 output

- Root `<gpx>` in `http://www.topografix.com/GPX/1/1`, required `version="1.1"` and truthful `creator` value.
- One `<rte>` with an output route name that the user can preview, edit, or remove; ordered `<rtept lat="…" lon="…">` children, and `<name>` only for source waypoint names that exist. Do not silently copy vessel metadata into GPX.
- No `<trk>` is emitted for a route conversion. Do not flatten or densify the route to make a map polyline look like ECDIS geometry.
- Coordinates remain decimal degrees in WGS84. Serialization precision, XML escaping, optional metadata, and schema validation are fixed in the detailed plan.
- Output defaults to a collision-safe filename derived from the source, but the user confirms location and replacement. Atomic write and failure cleanup prevent partial files.

## 6. Field mapping and loss policy

| RTZ data | Planned GPX treatment |
|---|---|
| Route name | GPX `<rte><name>` if present and safe; otherwise use a neutral UI fallback, without changing the source. |
| Ordered waypoint positions | GPX ordered `<rtept>` coordinates. This preserves vertices, not the ECDIS leg/turn construction. |
| Waypoint names | GPX routepoint `<name>` when present; unnamed points stay unnamed. |
| Waypoint IDs/revisions | Not represented in GPX core; report as dropped. |
| Turn radius (`radius`) | Not represented in GPX core; report values/count as dropped. |
| Leg geometry (`Loxodrome`, `Orthodrome`) | Not represented in core GPX semantics; use only for advisory source-distance calculation and report that Windy may draw differently. |
| Port/starboard XTD | Not represented in core GPX; report dropped. RTZ measurements are generally nautical miles unless specified. |
| Leg speed limits, course/heading, safety contour, UKC/depth and similar leg properties | Do not translate into misleading GPX values. List recognized categories as dropped. |
| Leg comments/notes | Do not copy by default; they may contain sensitive operational instructions. Report their presence and count. |
| Schedules, ETAs, speed schedules | Do not represent as route-point times unless a separately reviewed mapping is approved; report the schedule type and loss. |
| routeInfo vessel/author/status/validity/optimization attributes | Do not copy personal/vessel metadata by default. Report recognized categories and losses. |
| `defaultWaypoint`, route/waypoint/schedule/manufacturer extensions | Do not execute or interpret vendor-specific payloads. Report presence and unsupported status; optionally retain a redacted count in the conversion summary only. |

The conversion report should state “coordinates and ordered waypoint names copied; RTZ navigation semantics not preserved” in user-facing language. No claims of route safety, clearance, XTD, turn-radius compliance, or ETA validity are allowed.

## 7. Proposed architecture

Keep the core independent from the UI and macOS integration, with explicit, reviewable data boundaries:

1. **File intake:** user-selected URL and bounded byte read; identify `.rtz`; preserve source.
2. **Version/schema detection:** identify root and namespace without attempting fallback guesses; select a bundled, versioned offline schema only for confirmed support.
3. **Safe parser:** namespace-aware XML parser; no external entity resolution or network fetch; bounded input/depth/node count; parse a neutral RTZ domain model while preserving order and retaining recognized-field inventory.
4. **Validation:** schema validation plus semantic checks (coordinates, required elements, duplicate IDs, element ordering, missing positions, finite numeric values, supported geometry values, schedule references, and warnings for suspicious jumps/duplicates).
5. **Route transformation:** pure functions for the three modes. Require explicit selections for Current Position. Return a proposed output route and a review summary, not side effects.
6. **Distance/geodesy:** documented advisory segment calculations by source `geometryType`; never use estimates to select a route or infer navigation intent.
7. **GPX serializer/validator:** emit deterministic GPX 1.1 XML using a library; escape content; validate against a pinned GPX schema bundled for offline use; reopen/parse the serialized output and compare route points to the transformed model.
8. **Loss report and UI:** show before/after counts, endpoints, distance convention, warnings, and dropped fields before the save action.
9. **macOS integration:** SwiftUI/AppKit shell and Finder Quick Action extension are candidates; no Finder extension should bypass the same explicit review and safe-write flow.

Technology proposal: native Swift and Foundation `XMLParser`/XML APIs to minimize runtime dependencies. Confirm parser security behavior and schema-validation strategy in detailed plans. A third-party XML dependency is acceptable only if provenance, offline use, licensing, security, and bundling are reviewed. Runtime network entitlement should not be needed.

## 8. Validation, errors, and safe writes

Hard errors: unreadable file; malformed XML; unsafe or prohibited DTD/entity; unsupported/mismatched version and namespace; schema failure for a supported dialect; no route or no usable waypoints; missing/invalid/out-of-range/nonfinite coordinate; invalid selected waypoint or leg; ambiguous or unconfirmed Current Position choice; invalid GPX serialization; output write failure.

Warnings requiring user review: duplicate consecutive coordinates; repeated IDs; unnamed route or waypoint; non-monotonic IDs; large jumps/discontinuities; unsupported metadata/extensions; highly unusual radii/XTD; distance divergence between geometry interpretation and straight-line comparison; high latitudes; antimeridian crossing; a route that reduces to fewer than two points.

No XML external entity expansion, schema retrieval over the network, arbitrary URL access, script execution, route uploads, or silent overwrites. If RTZP support is later approved, enforce compressed and uncompressed limits, a single expected RTZ member, path traversal defenses, compression-ratio limits, and no extraction to arbitrary paths.

## 9. Geometry and distance conventions

- Compute distance only as an explanatory estimate and show the selected method and units.
- Proposed convention: use the WGS84 authalic sphere (radius 6,371,007.1809 m) and calculate each source leg according to its declared `geometryType` (rhumb for `Loxodrome`, great-circle/orthodrome for `Orthodrome`); convert metres to nautical miles using exactly 1 NM = 1,852 m. This is an application-level estimate, not a claim to reproduce ECDIS geometry. Stage 1 must approve this convention and independently reviewed test vectors before implementation.
- Normalize longitude deltas across the antimeridian. Explicitly test high latitudes and document that RTZ guidance warns that high-latitude and long-leg geometry can differ between systems.
- For Current Position, show the exact coordinate, selected next waypoint/leg, proposed join location, and added segment(s). A join point is a geometric construction only; it does not account for chart hazards, traffic separation schemes, safety contours, vessel handling, weather, or ECDIS settings.
- GPX's ordered route-point list does not encode the RTZ choice of orthodrome/loxodrome, turn arcs, wheel-over positions, or cross-track limits. Windy may render segments differently. Never use map appearance or route total distance as proof of navigational equivalence.
- Compare source-derived and exported-coordinate estimates as a regression signal only. Differences need a documented threshold before warning; do not auto-correct or move any waypoint.

## 10. macOS, offline, privacy, and packaging

### macOS constraints

- Target Apple Silicon (arm64). Determine minimum macOS release after prototyping the chosen Finder Action and packaging path.
- Use user-selected open/save panels and least-privilege file access. App Sandbox document selection grants access to selected URLs; Finder Action extension requires explicit extension input/output handling. Keep route processing in the app's core and avoid persistent access unless a user-facing need is approved.
- No administrator/root requirement; no modifications to ECDIS/ship systems or files.
- Direct distribution outside the Mac App Store normally involves Developer ID signing and notarization; notarization/distribution uploads the app package to Apple, never route content. The App Store imposes sandbox requirements. Evaluate both rather than promising a delivery path before checking capabilities and account requirements.
- Candidate packages: signed/notarized `.app` distributed in a `.dmg` or `.zip`; Mac App Store; or Homebrew Cask only if maintenance/distribution tradeoffs make sense. These are installation-time choices; conversion remains offline.
- Finder Quick Action candidates: native Action Extension or a clearly packaged Automator workflow. Apple documents Action Extensions as a way to expose app functions in Finder Quick Actions. Compare the security-scoped file handoff, UI limitations, install friction, and minimum macOS support before selecting.

### Threat and privacy model

Assets: vessel positions, planned voyages, vessel identity/MMSI/IMO, schedules/ETAs, operational notes, and output routes. Treat source and derived route files as confidential by default.

Threats include malicious XML (entity expansion, deep nesting, oversized values), malformed coordinates, path/name injection, output collisions, log leakage, unauthorized network transmission, accidentally committed voyage fixtures, and hostile compressed containers if RTZP is later allowed.

Controls: offline runtime and no network APIs; secure XML parser settings; strict resource bounds; no arbitrary XPath/user expressions or dynamic code; escaped XML output; deterministic filename sanitization; save-panel confirmation, no silent replacement, atomic write; minimal diagnostics with no route payload; no persistence of Current Position by default; no analytics; `.gitignore` protection plus mandatory diff/status review before commit; synthetic fixtures only in public tests. The user explicitly controls any Windy upload/import and must use synthetic data for initial acceptance.

## 11. UX options and decision points

Candidate primary UI: a small native window with source-file selection, version/route summary, mode selector, waypoint/leg selection, coordinate fields where applicable, a simplified schematic preview, loss/warning panel, and Save GPX action. Candidate Finder Quick Action: invoke the same flow for one selected `.rtz`; it should show a compact confirmation dialog and output choice rather than silently writing.

To decide after discovery: GUI-only vs GUI plus Finder extension; whether Finder Action opens the main app; whether output beside source is default; whether the user can edit route/waypoint names; whether GPX `<desc>` or `<extensions>` may carry any safe metadata. Default proposal is no metadata beyond route/point names and all conversion warnings visible before save.

## 12. Verification strategy (planned, not run)

- Synthetic fixture corpus for valid 1.0/1.2; candidate 1.1 dialects only after lineage review; missing/invalid fields; schedules; defaults; extensions; namespace/version mismatch; malformed/hostile XML; duplicate IDs/points; antimeridian; high latitude; single-point/empty route; mixed leg types; and the two Current Position behaviors.
- Schema validation with vendored schemas; tests must not fetch XSDs or depend on network.
- Deterministic conversion checks compare point count, exact order, names, and coordinates before/after serialization; source-file hash remains unchanged.
- Geodesy tests use independently reviewed vectors for both leg types and edge cases, with units explicit and no expectation of ECDIS reproduction.
- Manual macOS checks for open/save permissions, filename collisions, cancellation, VoiceOver/keyboard flow, Finder extension enablement, and offline operation.
- Empirical Windy Stage 6 check as specified in 2.3; retain only evidence screenshots/notes without private route data.
- Never place a real route, position, or derived coordinate sequence in public fixtures, screenshots, logs, or release artifacts.

## 13. Ordered roadmap (stage outlines only)

These are manageable stage boundaries, not detailed implementation plans. Each stage's file-level changes, interfaces, exact tests, rollback, and exit checklist are deferred until Gate 2.

### Stage 0 — Discovery and master plan

- **Objective:** agree on scope, format posture, threat model, UX direction, and roadmap.
- **Deliverables:** this master plan and repository planning records.
- **Dependencies:** supplied AGENTS.md and repository access.
- **Acceptance:** user approves/revises plan; all unresolved high-impact questions are recorded; no code exists.
- **Risks:** undocumented vendor dialects; standards ambiguity.
- **Verification:** architect review of evidence, scope, privacy, and roadmap.

### Stage 1 — Standards and fixture baseline

- **Objective:** settle version support, schema provenance, GPX contract, distance vectors, and sanitized fixture inventory.
- **Deliverables:** approved version matrix; offline schema strategy; synthetic fixture plan; Windy test protocol.
- **Dependencies:** Stage 0 approval; access to permitted standards and schemas.
- **Acceptance:** every promised input version has a traceable schema/dialect and positive/negative fixtures; 1.1 status is explicit; no private route fixture is needed.
- **Risks:** 1.1 dialect ambiguity and schema redistribution constraints.
- **Verification:** schema diff review, fixture inventory review, standards citations and independently checked geodesic vectors.

### Stage 2 — Safe input model and parser

- **Objective:** read supported RTZ dialects into a bounded, neutral route model and report validation failures safely.
- **Deliverables:** version-aware parser/validator behavior, user-facing error model, recognized-field/loss inventory.
- **Dependencies:** Stage 1 approved schema and model contracts.
- **Acceptance:** supported dialects parse deterministically; invalid or hostile input fails closed with actionable errors; source remains unchanged.
- **Risks:** vendor extensions, XML parser security, schema optionality.
- **Verification:** planned fixture-based automated checks and security review.

### Stage 3 — Route modes and geometry

- **Objective:** provide the three explicitly selected route transformations and advisory distances.
- **Deliverables:** Full Route, From Waypoint, direct-to-selected-next-WP, and join-selected-leg behavior; visible loss/warning summary.
- **Dependencies:** Stage 2 route model and Stage 1 geometry convention.
- **Acceptance:** choices and outputs are deterministic; no implicit nearest-next-WP or auto-join decision; proposed geometry is shown before export.
- **Risks:** ambiguous direction/leg choices; projection differences and misleading distance precision.
- **Verification:** route transformation fixtures, reviewed geometry vectors, UX walkthrough.

### Stage 4 — GPX serialization and round-trip checks

- **Objective:** produce deterministic GPX 1.1 route files that conform to the approved core mapping.
- **Deliverables:** GPX serializer, offline schema validation, collision-safe save behavior, clear dropped-field report.
- **Dependencies:** Stage 2 model and Stage 3 output model.
- **Acceptance:** all outputs validate; point order/coordinates/names match the selected transformed route; writes are atomic and never silently overwrite.
- **Risks:** consumer-specific import expectations; precision/escaping errors.
- **Verification:** schema checks, parse-after-write comparisons, deterministic fixture results.

### Stage 5 — macOS UX and Finder integration

- **Objective:** make conversion understandable and safe on Apple Silicon macOS.
- **Deliverables:** approved UI shell and, if selected, Finder Quick Action integration.
- **Dependencies:** Stage 0 UX decision; core conversion pipeline.
- **Acceptance:** selected input/output flows work with least privilege; user can cancel; Current Position confirmations cannot be bypassed; offline use is clear.
- **Risks:** extension sandbox/permissions, minimum macOS compatibility, installation friction.
- **Verification:** manual accessibility, file-access, cancellation, and offline walkthroughs on supported macOS versions.

### Stage 6 — Windy and end-to-end acceptance

- **Objective:** determine whether the produced GPX behaves as intended in Windy Route Planner.
- **Deliverables:** dated import acceptance record, known limitations, user guidance.
- **Dependencies:** GPX serializer and macOS export flow; synthetic test route.
- **Acceptance:** correct import path confirmed; route-vs-track, point order/count, endpoints, names, and displayed geometry recorded; discrepancies documented; no real route publicly shared.
- **Risks:** Windy UI changes, import may simplify or reinterpret route geometry.
- **Verification:** controlled manual test with synthetic data and repeat after material Windy changes when release validation requires it.

### Stage 7 — Packaging, release, and maintenance

- **Objective:** provide a trustworthy Apple Silicon installable release and support documentation.
- **Deliverables:** selected signed distribution artifact, installation/removal guidance, version support matrix, privacy and limitations notice, release evidence.
- **Dependencies:** Stages 1–6 accepted; distribution method decision and signing access.
- **Acceptance:** install and remove without admin access; verify code signature/notarization or App Store delivery; conversion works offline from a clean user environment; release contains no real routes.
- **Risks:** signing/notarization requirements, Gatekeeper behavior, dependency provenance.
- **Verification:** clean-machine install, offline conversion acceptance, artifact inspection, release checklist and privacy scan.

## 14. Approval gates and next process

1. **Approve the master plan** (this Gate 1 document).
2. **Generate detailed implementation plans for every approved stage**, one per stage under `docs/implementation/`, with file-level changes, interfaces, dependencies, test cases, rollback, and exit criteria.
3. **Cross-check the complete plan set** for format fidelity, stage dependencies, UX, errors, security/privacy, offline behavior, packaging, and scope. Record findings and resolve blockers before implementation.
4. **Obtain explicit authorization to implement.** Then implement one stage at a time, updating `REPORT.md` and `PROGRESS.md` with each stage completion and its evidence.

No implementation begins before the complete plans are reviewed and explicit authorization is given.

## 15. Unresolved decisions for review

1. Approve the 1.0/1.2 candidate support posture and conditional 1.1 support, or choose a narrower initial scope.
2. Include RTZP container support in a later stage, or keep `.rtz` only.
3. GUI only, or GUI plus Finder Action in the first release.
4. Preferred minimum macOS release and release path: notarized direct download, App Store, or another channel.
5. Whether to include command-line/batch conversion (default proposal: out of scope initially).
6. Approve the proposed WGS84-derived advisory distance convention after Stage 1 vector review.
7. Approve default GPX field mapping: user-confirmed route name and existing waypoint names only; report notes, IDs, radii, XTD, schedules, vessel data, and extensions as lost.
8. Confirm Windy acceptance testing can use synthetic test routes in the user's Windy account, without publishing/sharing.

## Sources reviewed

- [CIRM — RTZ XML Schemas](https://cirm.org/rtz-xml-schemas) — published RTZ 1.0 and 1.2 schemas and RTZ 1.2 test files; route plan description.
- [IEC — IEC PAS 61174-1:2021](https://webstore.iec.ch/en/publication/67774) — current PAS overview, scope, and 1.2/1.0 relationship. More detailed provisions referenced during discovery are in the published PAS; review the relevant licensed text before finalizing detailed conformance claims.
- [IEC 61174-1:2021 preview](https://elstandard.se/documents/preview/2607001) — accessible text preview for version differences, route structure, and geometry caveats.
- [STM — RTZ schemas and test materials](https://www.seatrafficmanagement.info/developers-forum/schemas/) and [STM 1.1 schema proposal](https://stm-stmvalidation.s3.eu-west-1.amazonaws.com/uploads/20190322122013/ECDIS-Annex-S-version-1.1-STM-Extended_29032017_Final_Proposal.pdf) — historical 1.1 branch and its context.
- [Topografix — GPX 1.1 schema documentation](https://www.topografix.com/GPX/1/1/) and [GPX developer guidance](https://www.topografix.com/gpx_for_developers.asp) — GPX 1.1 route semantics, required root attributes, namespace, and XML guidance.
- [Windy — public file uploader](https://www.windy.com/uploader) — currently lists GPX upload/display/share; separate from Route Planner acceptance.
- [Windy Community — Route Planner launch discussion](https://community.windy.com/topic/9013/windy-launches-route-planner?page=10) — historical community report of GPX import, not a current compatibility guarantee.
- [Apple — Finder Action Extensions](https://developer.apple.com/documentation/appkit/add-functionality-to-finder-with-action-extensions), [App Sandbox file access](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox), and [macOS notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) — integration, least-privilege file access, and distribution considerations.
