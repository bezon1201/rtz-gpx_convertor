# IP-4 — GPX Serialization and Loss Report: Detailed Implementation Plan

**Plan status:** Submitted for architectural review (Gate 2).
**IP-4 execution:** NOT AUTHORIZED.
**Overall implementation:** NOT AUTHORIZED.
**Planning baseline:** Gate 1 `d57d0935c7885eb25eb14542e7996839644e96e2`; IP-1 `6ed649d3995f70fa2421e08cb027c07d19b4cad4`; IP-2 `8011d3f0c4baf62cb15194ab9308f4e312269615`; IP-3 R1 `8e35edff864de87278aa7c61c7376e49845c3d74`.

This plan defines the contract from IP-3’s finalized immutable TransformedRoute to one locally saved GPX 1.1 route artifact and a separate loss report. It separates document construction, independent schema/semantic validation, export eligibility, loss reporting, safe local file handling, and Windy acceptance. This is planning only; no application code, GPX, fixtures, tests, probes, schemas, dependencies, or Shortcuts are created here.

## 1. Scope and boundaries

IP-4 consumes only a finalized IP-3 TransformedRoute. For Current Position modes, previews/candidates or unconfirmed transformations are invalid input. IP-4 constructs one GPX 1.1 document containing exactly one rte, ordered route points, the confirmed route name if any, and approved point display names. It generates a structured loss inventory and human-readable summary from qualified upstream provenance. It validates the document using a vetted offline GPX 1.1 schema and semantic checks, then hands bytes to the safe local output boundary.

IP-4 does not parse RTZ, compute or modify route geometry, decide navigation intent, select a joining point, serialize RTZ metadata as misleading GPX fields, implement the CLI/Shortcut/save panel, or test Windy itself. IP-5 owns CLI/runtime transport and output-file invocation; IP-7 owns native save UI and user warnings/overwrite confirmation; IP-6 owns Windy Route Planner empirical acceptance. IP-4 makes no claim of ECDIS equivalence.

## 2. Upstream contracts and status

| Upstream/downstream | Required contract | State at this planning baseline |
|---|---|---|
| Master Plan | GPX 1.1, one ordered rte, exact selected route order, source unchanged, collision-safe save, no silent overwrite, offline schema validation, loss reporting | Approved. |
| IP-1 | GPX XSD provenance/hash/license and offline validation strategy; coordinate formatting and semantic determinism decisions; qualified source field matrix; sanitized fixture plan | Plan approved for Gate 3 cross-check; execution evidence and exact artifact/license decisions remain pending. Do not bundle or download an XSD based on this plan. |
| IP-2 | Validated immutable model precision, optional field presence, qualified meanings, bounded unsupported-content summaries | Plan approved; execution evidence pending. No raw XML/payload crosses into IP-4. |
| IP-3 R1 | Finalized TransformedRoute; point and leg provenance; synthetic labels/provenance; one-point neutral result with warning; no implicit geometry decisions | Plan approved / ready for Gate 3; execution evidence pending. Rhumb closest-point metric remains unresolved upstream and cannot be represented as settled geometry. |
| IP-5 | Stable CLI result/error interface, save transport, file permissions/reference binding, output path handling | Future plan; not frozen. |
| IP-6 | Synthetic GPX import through Windy Route Planner; visual/order/count and one-point acceptance | Future empirical stage; no Windy behavior assumed. |
| IP-7 | Native save panel, explicit overwrite, warnings, Shortcut display, Reveal in Finder | Future plan; not frozen. |

No upstream implementation PASS is claimed. Exact GPX schema artifacts must be established by IP-1 (issuer, version, digest, transitive imports, licensing, and permissible offline use). If rights or a legal offline runtime strategy remain unresolved, schema distribution/validation implementation is blocked; IP-4 must not omit or weaken schema-backed validation by assumption.

## 3. GPX 1.1 document contract

### 3.1 Document envelope

Proposed serialized shape:

- XML 1.0 declaration, UTF-8 encoding, no byte-order mark; line endings and indentation may be selected consistently by the approved serializer.
- Root element in the default namespace `http://www.topografix.com/GPX/1/1`.
- Required root attribute `version="1.1"` and truthful `creator`. Proposed stable creator value: `RTZ-GPX-Converter`; release/version suffix policy must be finalized in IP-4A, and no machine/user identity may be included.
- Exactly one `rte` in the document, representing the selected finalized TransformedRoute. No `wpt`, `trk`, or extra `rte` is emitted.
- Optional `xsi:schemaLocation` is omitted by default: it is a hint, not a validation mechanism, and IP-4 validates against its pinned local schema without dereferencing any URL. If IP-6 finds a consumer requirement, consider adding a conventional hint only after review; it must never trigger network access at runtime.
- Do not emit metadata, author, time, links, extensions, route number/type, elevation, fix, speed, ETA, safety values, or comments unless a separately justified, schema-qualified and consumer-reviewed mapping is approved. V1 defaults to the minimum core elements.

The Topografix GPX 1.1 schema documents the GPX namespace, required version/creator attributes, ordered document child sequence, and rte as an ordered list of route points. It declares rtept with minOccurs=0 and maxOccurs=unbounded; therefore XSD validity alone does not establish that an application should export an empty or one-point route. The schema defines latitude as decimal degrees in [-90,90] and longitude in [-180,180). IP-4 imposes the stronger application contract of at least one transformed point; an empty route is invalid for this converter even if the XSD permits it.

### 3.2 Route and point sequence

- Emit exactly one `rte` and emit its `rtept` children in exact TransformedRoute order. Point count must match the finalized neutral model.
- A route point has required decimal `lat` and `lon` attributes. Preserve model numeric values exactly; serialize no geometry-derived or distance-derived coordinate.
- Route child order follows the GPX schema sequence. The only route child emitted by default is optional `name`, followed by `rtept` elements. Each rtept has only required coordinate attributes and optional name. Do not substitute `trk/trkseg/trkpt` for route semantics.
- A finalized route with zero points is invalid. One point is schema-valid and eligible for controlled export under the provisional policy in §6, subject to warning and empirical Windy acceptance. Two same-coordinate points remain two ordered points with distinct provenance and a zero-length warning.
- The GPX route preserves vertices/order, not RTZ leg geometry, turn arcs, wheel-over points, XTD, or ECDIS construction. No densification, smoothing, interpolation, sorting, snapping, deduplication, or “repair.”

### 3.3 Route and waypoint names

- `rte/name` contains only the route name confirmed for this export. If the source route has a name, offer it for confirmation; user may edit/remove it. If absent, propose a neutral label only for explicit user confirmation; otherwise omit `rte/name`. Do not copy vessel names/IDs, source filenames, or private path components automatically.
- For original points, emit `rtept/name` only when the finalized point carries an existing nonempty source waypoint name. Preserve its Unicode scalar sequence and value; do not normalize, trim, case-fold, or alter for uniqueness. Missing source names remain absent. Duplicate names remain duplicate; the user must disambiguate them by displayed order/reference, not by changing GPX names.
- Synthetic points are not source waypoints and have no RTZ identity. Proposed stable display labels are `Current Position (synthetic)` and `Join Point (synthetic)`. Emit these labels in GPX only when the preview/confirmation contract explicitly accepts synthetic labels; otherwise omit name and retain typed provenance in the separate report. A label is explanatory text, never an ID, and may collide with an original display name without merging points.
- If a join endpoint reuses an original waypoint reference under IP-3’s approved endpoint identity/tolerance contract, use that original point’s name if present. Do not emit a synthetic Join Point name for a reused endpoint.
- Never put IP-3 internal object references, source IDs/revisions, source ordinals, digests, or private route/vessel identifiers into GPX names/extensions. No extensions are planned for V1.

## 4. Coordinate integrity, XML safety, and determinism

### 4.1 Numeric representation

- IP-4 consumes the exact numeric values on finalized TransformedRoute points. Preserve the numerical value represented by the model, not the original RTZ attribute’s lexical spelling. No claim of byte-for-byte or lexical equality to RTZ is made; IP-2 may preserve decimal value while lexical form remains unavailable.
- Required serialization should use decimal-preserving numeric values and a locale-independent, deterministic plain-decimal representation accepted by the GPX XSD. Do not use a fixed number of decimal places, scientific notation, locale comma, or rounding. Remove redundant trailing zeros and decimal point; use `0` for numeric negative zero. These canonical lexical choices do not change the mathematical decimal value.
- If IP-2 supplies only binary floating-point values and IP-4 cannot round-trip the represented source value under the contract below, implementation must stop for cross-stage review rather than claim exact preservation or silently approximate.
- Round-trip tolerance: **zero decimal-degree difference** between each finalized model coordinate and the coordinate parsed from the serialized GPX using exact decimal arithmetic. This is a semantic-value requirement, not a lexical-string comparison. Verify independently by reparsing with a second schema-capable XML/decimal implementation and comparing every point by ordinal. Also verify source-backed coordinates against their exact IP-2 model values and synthetic coordinates against their confirmed IP-3 values.
- Preserve source coordinate values as supplied by the model. Do not normalize longitude, even when wrapping would be geographically equivalent. GPX 1.1 excludes longitude +180 (its maximum is exclusive), while a source/synthetic value may be +180 under upstream bounds. Proposed behavior is blocking GPX_COORDINATE_UNREPRESENTABLE with no output; conversion to -180 would violate the no-normalization rule. Any alternate mapping requires architectural approval and a cross-stage decision.
- Reject nonfinite/out-of-range coordinates and decimal values that cannot be represented in the approved model/serializer without loss. Latitude bounds are inclusive [-90,90]; GPX longitude bounds are [-180,180). Validate both before serialization and after reparsing.

### 4.2 XML and text

- Use a standards-compliant XML writer. Never concatenate XML markup with route names or point names.
- Encode XML 1.0 UTF-8; escape markup-significant characters in attributes/elements, preserve valid Unicode without normalization, and reject XML 1.0 forbidden characters/surrogates rather than replacing or dropping them silently.
- XML declaration, namespace, element order, creator, decimal formatting and omission rules are fixed by the serializer contract. Repeated semantically identical requests must produce identical GPX meaning: same names, point order, coordinate decimal values, and element presence. Byte-for-byte identity is not required unless IP-1’s serializer decision supplies a concrete requirement; do not add custom canonicalization solely to make bytes identical.
- Invalid route/name/coordinate data yields a bounded diagnostic that does not echo unsafe raw input. A bad optional name is not silently omitted; it blocks export or requires an explicit user edit/removal before a new confirmed request.

## 5. Structured metadata-loss inventory

Generate one deterministic LossInventory from the finalized TransformedRoute and IP-2’s qualified field-presence/semantic summaries. Never infer that a field existed from a dialect alone; report a field-specific loss only when IP-2/IP-3 provenance establishes that the recognized field was present or an applicable leg/point was excluded. Distinguish absent, present-and-preserved, transformed, excluded, not representable in core GPX, unknown/unqualified, and not applicable.

Each item contains a stable code, category, severity, disposition, bounded count, and optional scoped point/leg provenance references (source ordinal and typed relation). References remain in-memory by default and must not expose source IDs, names, paths, coordinates, hashes, or payload in default logs. Do not embed raw XML or arbitrary extension text.

| Category | Planned disposition |
|---|---|
| Ordered transformed waypoint positions and existing names | Preserved semantically in `rtept` order/name where supplied; source lexical precision may differ while numeric value must round-trip exactly. |
| Source waypoints omitted by From Waypoint/Current Position | Excluded from this output; report count and scoped ordinals if provenance says they existed. |
| Incoming legs omitted/superseded/shortened by IP-3 | Report the exact IP-3 lineage state: excluded, superseded, or portioned. A shortened join leg names the retained remainder and omitted portion; no entire-source-leg semantics are implied for the connector. |
| Orthodrome/Loxodrome source leg geometry | Not represented by GPX 1.1 core route semantics. Report qualified type only if present and qualified; state that Windy may render vertices differently. Unknown/missing geometry is unavailable/unqualified, not a claimed lost known type. |
| Turn radius, wheel-over, radius-related maneuver | Not representable in core GPX; report only qualified/present fields. Do not infer wheel-over points or convert a radius into points. |
| XTD / port-starboard cross-track limits | Not representable in core GPX; report present qualified limits by category/count, not as GPX coordinates or safety claims. |
| Planned speed, course/heading, safety contour, UKC/depth, other leg instructions | Not represented by the V1 mapping. Report only qualified fields known present; never copy to a connector or a shortened leg without an approved semantic mapping. |
| ETA/ETD, calculated schedules, timing/speed schedule | Omitted by default and reported by qualified field/category/count; do not invent route point times or claim the source schedule is preserved. |
| Route/wpt IDs, revisions, source names | IDs/revisions are not placed in GPX core; names are emitted as §3.3; private identity is not copied elsewhere. Report qualified present IDs/revisions as not representable only if policy defines them as dropped. |
| Extensions | If IP-2 exposes a bounded summary, report unknown/unqualified category and count only. Do not claim contents lost unless presence is evidenced; never copy payload. |
| Synthetic connector legs | New, with no original RTZ leg constraints; report as transformed/new connection. Do not apply source XTD/radius/speed/schedule to it. |
| Advisory distances | Report available/incomplete/unavailable status and safe reason/category; distance is not GPX geometry and never edits route points. |
| One-point route | Record INSUFFICIENT_OUTPUT_POINTS advisory; this does not mean GPX schema-invalid. Consumer acceptance remains IP-6 evidence. |

### 5.1 Human-readable loss summary

Use the same inventory to produce a short plain-language report with sections: **Preserved**, **Changed by selected route mode**, **Not represented in GPX**, and **Unknown or unavailable**. Explain that GPX retains ordered vertices and supported names/route label, not RTZ navigation semantics or ECDIS geometry; added connectors are not RTZ-constrained; distances are advisory only; and Windy interpretation is not guaranteed until IP-6 acceptance. Suppress empty categories. Use counts and ordinal references only when useful and authorized; no raw XML or coordinates by default.

### 5.2 Report transport and privacy

- Return the structured report and human summary in memory to the IP-5 CLI result and IP-7 Shortcut flow.
- No GPX extensions for loss data by default. This avoids nonstandard consumer dependence and leaking internal provenance.
- Optionally save a separate machine-readable JSON sidecar (proposed suffix `.loss-report.json`) only after explicit user selection/confirmation. Use a separately selected location or same-folder default only if permitted; never silently save beside the route. The sidecar contains codes, categories, counts, and scoped point/leg ordinals; by default exclude coordinates, private route/waypoint names, source IDs, paths, source digest, and raw extension data. An expanded contextual sidecar policy requires separate privacy review and user opt-in.
- A GPX save and optional sidecar save are separate artifacts, not one atomic transaction. If GPX succeeds and a requested sidecar fails, report GPX success and sidecar failure distinctly; never misreport either status.
- Default logs, error text, telemetry, and crash details must not include coordinates, route/vessel identity, names, source/output paths, full hashes, or XML payload. No network or upload.

## 6. One-point export policy

Distinguish these states:

1. **Transformation validity:** IP-3 may return a finalized one-point neutral transformation with `INSUFFICIENT_OUTPUT_POINTS` advisory. IP-4 must preserve that result and must not fabricate a second point or silently discard it.
2. **GPX schema validity:** GPX 1.1 XSD permits zero or more `rtept`; a single `rtept` can therefore satisfy schema cardinality when all other constraints pass. XSD conformance is not application usefulness or consumer acceptance.
3. **Export eligibility:** Proposed conservative policy is `ELIGIBLE_WITH_WARNING` for a finalized one-point transformation: permit generation of a schema-valid one-point GPX after showing a clear warning that it contains one position and does not describe a useful passage route. Require an explicit user acknowledgement before saving. Do not present it as a complete route, discard it, or add a point. This may broaden the Master Plan’s “minimum useful point count” export check beyond a warning; it is a proposal only and requires explicit architectural approval before IP-4A freezes it or implementation begins. If review chooses refusal, record the Master Plan consistency decision and keep the neutral IP-3 result intact.
4. **Windy compatibility:** unverified until IP-6 tests a synthetic one-point GPX through the actual Route Planner import path. Include point count/order and resulting object type in the acceptance record. Do not claim Windy accepts it from schema validity or public uploader support alone. If Windy rejects or transforms it unexpectedly, record the result and return to architectural review; do not silently block or rewrite only this case.

If the one-point advisory acknowledgement is absent, return `GPX_EXPORT_NOT_ELIGIBLE` / `INSUFFICIENT_OUTPUT_POINTS` with an actionable explanation and no file. Acceptance evidence required to freeze policy: exact pinned GPX XSD/hash/license; independent schema validation and round-trip comparison for one point; IP-6 dated empirical Windy Route Planner result using synthetic data; and architect review of any discrepancy. An empty TransformedRoute is always invalid at the application layer.

## 7. Export eligibility and validation pipeline

Keep independent states and result types for:

- **Construction:** GPXDocument value has one rte and points/names derived only from final TransformedRoute and confirmed export options.
- **Schema validation:** serialized XML is well formed, validates offline against the exact approved GPX 1.1 XSD, and passes application semantics.
- **ExportEligibility:** Eligible, EligibleWithWarning (including one-point with explicit acknowledgement), or Ineligible with stable diagnostic codes. It is not the same as schema validity or Windy compatibility.
- **File save:** OutputArtifact exists at the selected destination and was fully written/validated. Serialization success alone is not file-save success.
- **Consumer compatibility:** separate IP-6 empirical result; never inferred from successful serialization/validation.

Required checks:

1. Input is a finalized TransformedRoute, not preview/candidate; mode-specific current-position confirmation is valid per IP-3/IP-5/IP-7 contract.
2. Route is nonempty; point and leg lineage coherent; exactly one route will be represented. Warn on one point or duplicate-coordinate consecutive points; never deduplicate.
3. All coordinate values are finite and in GPX ranges, and decimal serialization preserves each model value with zero decimal-degree round-trip difference. +180 longitude is not silently wrapped.
4. Name text is valid XML 1.0; output creator and name policy pass; only justified GPX core elements exist.
5. XML is well formed and GPX XSD-valid using an offline local validator and approved schema artifact. Validator must not access network or trust instance schemaLocation.
6. Independent reparse verifies root namespace/version/creator; exactly one rte, no wpt/trk; exact rtept count/order; exact decimal coordinates; route and permitted point names; no unexpected child fields/extensions.
7. LossInventory is complete against known qualified/present source properties and IP-3 mode provenance; no speculative claims.
8. Deterministic semantic repeat-conversion check over synthetic inputs yields identical semantic fields, not necessarily identical bytes.

Schema conformance and app semantic checks must have separate diagnostics. Preserve schema issuer/revision/hash/license/runtime strategy evidence in IP-1 research records, not route logs. Do not fetch, download, or bundle an XSD as part of planning. Network remains disabled for implementation/runtime validation.

## 8. Safe local output-file boundary

### 8.1 Responsibility split

- **IP-7:** native save panel and selected destination; explicit overwrite confirmation; warning/report presentation; optional sidecar prompt; Reveal in Finder.
- **IP-5:** secure local CLI/runtime transport, selected-file/security-scope handoff, cancellation/error mapping, and stable result payload. Do not interpolate path strings into shell source.
- **IP-4:** serialize/validate bytes, provide a bounded artifact handoff, request safe create/replace, distinguish serialization/validation from save result, and report precise diagnostics. No path chooser or UI.

### 8.2 Proposed write protocol

1. Start only after user confirms export and IP-7 supplies an authorized destination reference. Default the save panel to the source RTZ directory only when macOS permissions/security scope permit; otherwise require a user-selected location. No silent alternate directory.
2. Resolve the destination through the approved macOS file-reference/security-scoped API; treat path/name as untrusted. IP-2A/IP-5/IP-7 must jointly settle aliases, security scopes, permissions and file identity. Do not categorically reject a legitimate user-selected alias, but never perform unsafe path traversal/reopening.
3. Sanitize only the suggested filename component; do not use it as a path. Preserve Unicode filename semantics where filesystem permits; reject separators, traversal components, NUL/control characters, invalid extensions, and overlong names with an actionable prompt. Suggested base name may derive from the selected source filename stem; do not log it or place source path in GPX metadata.
4. If destination exists, return OUTPUT_ALREADY_EXISTS and require IP-7 to display explicit overwrite confirmation. Recheck target identity immediately before replace; a changed target requires renewed consent. Never overwrite silently.
5. Write to an exclusive, unpredictable temporary file in the same directory/volume when supported; apply restrictive user-only permissions for new route artifacts (proposed mode 0600, subject to macOS API/security review). Flush/close, then validate the exact staged bytes before commit. Do not expose temp paths to logs.
6. For new files, atomically publish with a same-volume rename/no-replace operation where the filesystem guarantees it. For confirmed replacement, use an OS replacement API that preserves reviewed permission/ACL expectations. Do not claim atomicity across volumes, network shares, File Providers/cloud-backed folders, or unsupported filesystems. If atomic publication cannot be guaranteed, fail safely or request another local destination; never silently fall back or leave a partial GPX as success.
7. On cancellation/error, remove only the temporary artifact created by this operation; do not remove a preexisting user file. Report serialization, validation, destination, and save results separately. Successful validation plus failed write is not export success.
8. Open/reveal action is IP-7 and occurs only after save success. No cloud upload/share action. Runtime stays offline.

Required cross-stage verification: spaces/Unicode, collision/overwrite confirmation, target replacement race, permission denial, destination unavailable, cancellation before/write/replace, temporary cleanup, local same-volume atomicity, File Provider/cloud folder behavior, security-scoped URL lifetime, alias resolution, and no output on failed validation. Exact destination path and permissions remain IP-5/IP-7 contracts; IP-4 must not substitute ad hoc shell/path rules.

## 9. API and diagnostics contract

Conceptual typed interfaces; exact language signatures wait for IP-5/runtime decisions:

- `GPXExportRequest`: finalized TransformedRoute reference, confirmed optional route name, synthetic-name options, one-point acknowledgement, optional loss-sidecar request, output destination capability from IP-5/IP-7. Must not accept a preview as final.
- `GPXDocument`: neutral validated structure: one route, ordered points, coordinate decimal values, optional names, truthful creator, GPX version/namespace.
- `GPXSerializer`: GPXDocument → deterministic semantic UTF-8 bytes/result; no IO/path/UI.
- `ExportEligibility`: eligible/ineligible/warnings and required acknowledgements; separate from schema and filesystem state.
- `GPXValidationResult`: well-formed, schema result, application semantic result, round-trip comparison, bounded diagnostics.
- `LossInventory` / `LossReport`: typed machine categories and human summary from qualified source and transformation provenance.
- `OutputArtifact`: successful validated save reference, byte count, format, and optional user-selected sidecar result; no source path/route coordinates/hash in default logs.
- `ExportDiagnostic`: stable code, severity, bounded safe message, optional safe category/count/provenance ordinal; no raw XML/private names/coordinates/path.

Suggested diagnostics, to reconcile with IP-2/IP-3/IP-5 before freeze:

**Blocking:** INVALID_TRANSFORMED_ROUTE, UNCONFIRMED_TRANSFORMATION, INVALID_GPX_COORDINATE, GPX_COORDINATE_UNREPRESENTABLE, INVALID_XML_CHARACTER, GPX_SCHEMA_UNAVAILABLE, GPX_SCHEMA_VALIDATION_FAILED, GPX_EXPORT_NOT_ELIGIBLE, ONE_POINT_ACKNOWLEDGEMENT_REQUIRED, OUTPUT_ALREADY_EXISTS, OVERWRITE_CONFIRMATION_REQUIRED, OUTPUT_WRITE_FAILED, OUTPUT_VALIDATION_FAILED, DESTINATION_PERMISSION_DENIED, DESTINATION_UNAVAILABLE, CANCELLED.

**Advisory/loss:** INSUFFICIENT_OUTPUT_POINTS, METADATA_NOT_REPRESENTABLE, SOURCE_WAYPOINT_EXCLUDED, SOURCE_LEG_EXCLUDED, SOURCE_LEG_SUPERSEDED, SOURCE_LEG_PORTIONED, UNKNOWN_METADATA_UNQUALIFIED, GEOMETRY_UNAVAILABLE, DISTANCE_UNAVAILABLE, SYNTHETIC_CONNECTION_UNCONSTRAINED, ZERO_LENGTH_CONNECTION, WINDY_COMPATIBILITY_UNVERIFIED.

These identifiers are proposals only. Reconcile diagnostic identity/severity and CLI mapping with IP-2/IP-3/IP-5. Default output includes stable code and safe explanation, not coordinates, route names/IDs, source/output path, XML, full digest, or raw extension content. Interactive UI may show user-selected details needed for informed confirmation.

## 10. Synthetic verification plan (future execution only)

No synthetic file, GPX, test, or fixture is created in this planning task. After authorization, consume the reviewed synthetic fixture catalog from IP-1/IP-2/IP-3. Required cases:

- Full Route, From Waypoint first/middle/last, both Current Position variants; exact output point order/provenance.
- Empty transformed route rejection; valid one-point neutral route export with acknowledgement; one-point no acknowledgement; two identical-coordinate points retained with warning; IP-6 one-point import separately observed.
- Every GPX coordinate bound, including +180 longitude refusal without normalization; negative zero; very small/high-precision decimals; malformed/nonfinite values; exact decimal round-trip and no exponent output.
- Unicode composed/decomposed strings preserved without normalization; XML metacharacters escaped; forbidden XML 1.0 controls rejected; duplicate/missing source names; repeated synthetic labels and collisions without identity merging.
- Route names present, absent, edited, removed, Unicode, and malicious filename-like text; route name never becomes path or creator identity.
- Serializer output has correct root namespace/version/creator, one rte, no wpt/trk/extra rte, schema sequence, ordered rtept, required attributes and only approved optional names.
- Offline XSD valid/invalid pairs; schema unavailable/license unresolved; validator network access disabled; wrong namespace/version, wrong element order, missing creator/coordinate, out-of-range coordinate and forbidden element.
- Loss inventory for present versus absent fields, every IP-3 exclusion/superseded/shortened leg, unknown extension summaries, unsupported geometry/distance, synthetic connector, schedules, speed, XTD/radius/instructions. Assert no invented losses.
- Reparse output using an independent parser; compare exact decimal values/count/order/names/creator; repeated request yields semantic equality.
- Save-path cases from §8, including overwrite/race/permission/cancellation/temp cleanup/provider limitations; distinguish GPX success from sidecar failure.
- Privacy assertions: no coordinate/path/private route name/source ID/hash/raw payload in default diagnostics/log fixtures. Windy Route Planner import is a separate IP-6 manual acceptance record, not a unit test substitute.

Oracle provenance: XSD validation uses the exact IP-1 approved GPX schema hash and legally permitted offline validator. Coordinate round-trip oracle compares exact decimal values in a second parser and independently reviewed arithmetic. No real route or vessel coordinates in fixtures or screenshots.

## 11. IP-6 Windy acceptance handoff

IP-4 should deliver to IP-6 a matrix of synthetic GPX documents generated only after IP-4 execution authorization. Include:

- Full Route, From Waypoint, Current Direct, Current Join with expected point sequence.
- One-point GPX; empty route must be rejected at application layer and is not a consumer test artifact.
- Original names including duplicate/absent, synthetic labels included/omitted, route-name present/removed.
- Unicode and XML-special characters.
- Antimeridian and high-latitude coordinates.
- Two distinct route points with equal coordinates.
- Geometry-metadata loss and synthetic connector limitations.

For each, provide expected XSD result, application eligibility, exact coordinate/order/name expectations and known GPX limitations. IP-6 records date/app/web version, actual Route Planner import path, imported object type (route vs track/other), point count/order, names/endpoints, displayed geometry and any truncation/normalization. Do not conflate public Uploader support with Route Planner acceptance. Use only synthetic data and do not publish/share. If schema-valid output conflicts with Windy behavior, document evidence and request architectural review before vendor-specific workaround or scope change.

## 12. Future IP-4 implementation sub-stages

These are future authorized stages, not execution instructions for this task. Proposed paths assume the Swift-oriented direction in IP-2 and must be reconciled after IP-1/IP-2 execution; no files are created now.

### IP-4A — GPX 1.1 schema and serialization contract

- **Objective:** Freeze XSD provenance/license/offline validator strategy, root/route/point/name/number rules, precision, namespace/schema hint, eligibility states and one-point policy.
- **Scope:** Contract/evidence integration; no product code, schema download, or GPX artifact.
- **Proposed files:** `docs/research/IP-4/GPX-QUALIFICATION.md`, `docs/research/IP-4/GPX-SERIALIZATION-DECISIONS.md`.
- **Dependencies:** IP-1 GPX schema/legal decisions; IP-2 decimal model; IP-3 R1 finalized route and one-point contract; Gate 3/Gate 4 authorization.
- **Sequence:** inspect only approved schema artifact → decide license/offline validation → reconcile IP-1 serializer notes → resolve +180 coordinate and byte-vs-semantic determinism → obtain architectural decision on the one-point policy against Master Plan “minimum useful point count” → close name/hint decisions → review.
- **Synthetic tests/evidence:** later planned cases for schema facts, exact decimal rules, names, one-point; independently reviewed schema/hash/license record.
- **Acceptance:** documented exact GPX contract; no unsupported fields; one-point policy consistent with Master Plan; IP-6 test obligations explicit.
- **Risks:** schema redistribution, longitude +180 conflict, model lexical precision unavailable.
- **Rollback/PASS:** revert only IP-4A-owned decision files; PASS after architect and IP-1 review, no schema bundled unless rights cleared.

### IP-4B — Deterministic route/point serializer

- **Objective:** Build UTF-8 GPX 1.1 document from finalized TransformedRoute and confirmed naming options.
- **Scope:** Pure document construction/serialization, no file IO, CLI, UI, RTZ parsing, or GPX extension.
- **Proposed files:** `Sources/RTZCore/GPX/GPXDocument.swift`, `GPXSerializer.swift`, `Sources/RTZCore/Diagnostics/GPXDiagnostic.swift`; synthetic tests in `Tests/RTZCoreTests/GPXSerializerTests.swift`.
- **Dependencies:** IP-4A PASS; IP-3 finalized transform API; IP-2 exact numeric values.
- **Sequence:** validate final route and names → map one rte and ordered points → serialize locale-independent decimals/XML text → independent reparse → compare exact semantic values.
- **Synthetic tests:** §10 schema shape, Unicode/escaping, names, coordinate edge cases, deterministic semantics and non-mutation.
- **Acceptance:** one GPX route, exact order/count/value/name policy, no tracks/metadata leakage, well-formed output; +180/nonfinite/invalid XML fail explicitly.
- **Risks:** floating-point precision loss, invalid characters, accidental metadata/extra elements.
- **Rollback/PASS:** serializer is isolated behind a pure API; revert serializer only; PASS after independent comparison and XSD validation evidence.

### IP-4C — Structured metadata-loss inventory and report

- **Objective:** Convert qualified source presence and IP-3 lineage into deterministic machine and human reports.
- **Scope:** Loss classification/reporting; no XML serializer, filesystem sidecar persistence or extension payload.
- **Proposed files:** `Sources/RTZCore/GPX/LossInventory.swift`, `LossReport.swift`; synthetic tests in `LossReportTests.swift`.
- **Dependencies:** IP-1 field matrix; IP-2 bounded presence summaries; IP-3 final source leg/point provenance.
- **Sequence:** define stable categories → map present/absent/unknown to dispositions → incorporate excluded/superseded/portion legs → render same inventory to machine and human summaries → privacy review.
- **Synthetic tests:** present vs absent radius/XTD/schedule, unknown extension count only, excluded/superseded/shortened leg, synthetic connection, unavailable distance; assert no speculative loss.
- **Acceptance:** deterministic complete categorized report; no raw XML/IDs/names/coordinates/path/hash in defaults; reports GPX limitations accurately.
- **Risks:** treating schema possibility as actual field presence; incorrect split metadata claims.
- **Rollback/PASS:** replace mapping table without altering serializer; PASS after IP-1/IP-2/IP-3 lineage review.

### IP-4D — Export eligibility and independent GPX validation

- **Objective:** Separate transformed-route validity, app eligibility, XSD conformance, round-trip semantics and Windy compatibility.
- **Scope:** Validation/eligibility; no file saving or Windy import.
- **Proposed files:** `Sources/RTZCore/GPX/GPXExportEligibility.swift`, `GPXValidator.swift`; synthetic tests in `GPXValidationTests.swift`.
- **Dependencies:** IP-1 approved GPX XSD/license/runtime; IP-4A/B/C; IP-3 confirmation status.
- **Sequence:** require finalized route → validate coordinates/names/count → construct document → offline XSD validation → independent reparse/exact compare → return separate statuses/warnings.
- **Synthetic tests:** all invalid/valid schema pairs; one-point and acknowledgement state; +180 refusal; exact decimal; no network.
- **Acceptance:** schema and app semantics distinct; no unconfirmed preview accepted; one-point policy clear; validator offline and traceable.
- **Risks:** schema license or validator not shippable; downstream behavior not implied.
- **Rollback/PASS:** fail closed if validator unavailable; PASS only with hash-bound XSD/oracle evidence and no network.

### IP-4E — Safe local artifact handoff and IP-5/IP-7 integration

- **Objective:** Deliver validated GPX bytes and separately report save outcomes through approved local interfaces.
- **Scope:** Artifact handoff contract and implementation integration; native panel stays IP-7, CLI/path transport IP-5.
- **Proposed files:** `Sources/RTZCore/GPX/OutputArtifact.swift`, `Sources/RTZCore/GPX/ValidatedArtifactWriter.swift`; integration contract documentation/tests.
- **Dependencies:** IP-4B/D PASS; IP-5 local file-reference/runtime contract; IP-7 destination/security-scope/overwrite UX; platform security review.
- **Sequence:** receive security-scoped destination → collision and target-identity check → stage same-volume temp → validate exact bytes → safe no-replace/confirmed-replace publish → cleanup/report.
- **Synthetic tests:** collisions, race, permissions, cancellation, provider/volume behavior, output modes, failed validation and cleanup.
- **Acceptance:** no silent overwrite/fallback/partial success; file-save result distinct from serialization; restrictive permissions policy verified; no source modification/network.
- **Risks:** atomicity varies by provider/volume; alias/security-scoped lifetime; ACL changes on replace.
- **Rollback/PASS:** refuse unsupported atomic destination rather than unsafe fallback; PASS after target macOS/filesystem evidence and IP-5/IP-7 review.

### IP-4F — Synthetic acceptance and IP-6 handoff

- **Objective:** Assemble end-to-end synthetic evidence for GPX, loss reporting and Windy test readiness.
- **Scope:** Contract acceptance and sample handoff; actual Windy behavior belongs to IP-6.
- **Proposed files:** IP-4 synthetic test suite and `docs/research/IP-4/GPX-ACCEPTANCE-MATRIX.md`; no private route.
- **Dependencies:** IP-4A–E; IP-1 synthetic fixtures; IP-2/IP-3 execution evidence; IP-6 protocol.
- **Sequence:** run authorized XSD/round-trip/privacy/file matrix → independent reviewer checks evidence → prepare minimal synthetic GPX cases → hand expected outcomes to IP-6.
- **Synthetic tests:** complete §10 matrix; Windy one-point and all mode cases documented as not yet accepted until IP-6.
- **Acceptance:** all IP-4 contracts verified; no confidential data; IP-6 can independently reproduce expected semantics.
- **Risks:** mistaking schema validity for consumer acceptance; fixture drift.
- **Rollback/PASS:** quarantine failing sample; PASS only after review signs the evidence and IP-6 receives synthetic matrix (IP-6 itself may remain pending).

## 13. Cross-stage dependency and decision matrix

| Contract | IP-4 need | State | Owner/evidence to freeze |
|---|---|---|---|
| GPX 1.1 XSD identity, digest, license and offline validator | Schema and release validation | IP-1 plan approved; artifact/runtime evidence unresolved | IP-1 qualification and legal review |
| GPX route mapping: one rte, ordered rtept, names only | Serialization | Approved by Master/IP-1 plan; exact serializer policy provisional | IP-4A contract and IP-6 evidence |
| Decimal-preserving IP-2 coordinate model | Exact GPX round trip | Required by IP-2 plan; execution/API evidence pending | IP-2 decimal type and serializer adapter review |
| Longitude +180 handling | Coordinate output | Unresolved cross-stage conflict if source permits +180 | IP-1/IP-2 range evidence + IP-4A decision; no silent wrap |
| One-point neutral route | Keep IP-3 result intact | IP-3 R1 approved; export-after-warning is a provisional IP-4 proposal requiring explicit architectural approval against Master Plan wording; Windy unresolved | IP-4 schema test + IP-6 one-point import + Gate 2 architect decision |
| Current-position confirmation | No candidate serialization | IP-3 domain/IP-5 transport/IP-7 UI contract proposed; not executed | Cross-stage command binding and stale-preview tests |
| Loss inventory source presence | Avoid invented losses | Depends on qualified IP-1 matrix and IP-2 bounded model | IP-1/IP-2 execution review |
| Synthetic labels and route name | Naming privacy | Provisional | IP-4A/IP-6/Shortcut preview review |
| Save panel/file reference/security scope | Native local artifact | IP-5/IP-7 future; alias/permissions/identity open jointly with IP-2A | IP-5/IP-7 macOS evidence and IP-2A policy |
| Overwrite/atomicity/permissions | No partial or silent replace | Provisional | IP-5/IP-7 and filesystem-specific verification |
| Loss report sidecar | Optional, privacy-minimal | Proposed, not frozen | IP-5/IP-7 format/save/privacy review |
| Windy Route Planner behavior | Consumer acceptance | Unverified | IP-6 synthetic empirical record; never inferred from XSD |

All IP-1/IP-2/IP-3 implementation evidence is pending. Their approved plans are upstream planning contracts only. If any IP-3 decision or IP-2 model cannot satisfy a GPX rule without altering source coordinates, raise a cross-stage issue; do not normalize, repair, or change approved plans silently.

## 14. Risks and unresolved decisions

1. **Schema provenance/licensing/runtime:** no XSD artifact or bundle until IP-1 documents exact digest, imports, rights and offline validator strategy.
2. **+180 longitude:** GPX excludes +180 while upstream route coordinates may allow it. Proposed fail-closed export; any normalization requires explicit architectural approval.
3. **Coordinate representation:** exact decimal round-trip depends on IP-2’s concrete numeric type; no lexical preservation claim. Binary-only model that cannot meet zero decimal-difference criterion blocks implementation.
4. **One-point route:** XSD allows it; proposed V1 export with explicit insufficient-points warning/acknowledgement, but Windy behavior is unverified. IP-6 must test and report before compatibility claim.
5. **Creator/route naming/synthetic labels:** exact creator versioning and inclusion of synthetic generic labels require IP-4A/IP-6/IP-7 review; never encode source IDs or private route metadata.
6. **Loss semantics:** field presence and split-leg applicability depend on IP-1/IP-2/IP-3 qualified evidence; unknown fields cannot be counted as specific known losses.
7. **Offline schema:** if legal/runtime requirement cannot be met, block rather than fetch at runtime or weaken validation.
8. **Atomic write:** same-volume local rename does not imply provider-wide atomicity. File Provider/cloud folders, permissions and replacement behavior require empirical platform evidence.
9. **Privacy of optional report:** sidecars can expose route-derived provenance; keep them opt-in, minimal and local, with separate policy.
10. **Windy mismatch:** valid GPX schema does not guarantee Route Planner import; no vendor workaround without architectural review.

## 15. IP-4 acceptance and execution gate

### Planning acceptance

- Complete GPX 1.1 core mapping, XML/encoding/namespace/root/name/point-order contract.
- Exact coordinate value, XML text and numeric round-trip rules; explicit +180 limitation and no source lexical-equality claim.
- One-point policy separates neutral transformation, XSD, export eligibility, and Windy; warning/ack proposed without pre-approving consumer behavior.
- Structured deterministic loss report distinguishes present, absent, excluded, transformed, unsupported, and unrepresentable data.
- Human summary, optional sidecar, privacy boundary, and no-extension default defined.
- Safe output responsibilities/atomicity limits/cross-stage file reference contracts specified.
- Offline schema validation plan, independent round-trip test matrix and IP-6 synthetic handoff defined.
- IP-4A–IP-4F dependencies/acceptance/risks/rollback recorded without implementation plans being executed.
- Apparent conflicts with approved Master Plan or IP-1/IP-2/IP-3 are surfaced with explicit decision owners; specifically, one-point export remains a proposal requiring architectural approval against the Master Plan’s “minimum useful point count” check.

### Future IP-4 execution PASS

Only after Gate 3 and explicit Gate 4 authorization: finalized route maps to one valid GPX 1.1 rte; all output validates against approved offline schema; exact point order/numeric values/names round-trip; loss categories match qualified source presence and IP-3 provenance; one-point and edge eligibility are explicit; saved output is complete, privacy-safe, collision-safe, and accurately reported; no source RTZ change or network dependency occurs; independent review accepts the evidence. Windy acceptance itself remains an IP-6 decision and is not an IP-4 PASS unless its separate criteria are met.

## 16. Sources and research boundary

- Approved project sources: Master Plan; IP-1 §§5–6; IP-2 §§6–9; IP-3 R1 §§4–5, 8–10, 13–15 at the baselines in the header.
- Topografix, [GPX 1.1 Schema Documentation](https://www.topografix.com/gpx/1/1/) — root attributes, namespace, element sequence/cardinality, rte/rtept structure, decimal coordinate ranges.
- Topografix, [Developing GPX applications](https://www.topografix.com/gpx_for_developers.asp) — schemaLocation is a hint whose locations may change; use XML parsers/writers and do not rely on fetching a fixed schema URL.
- Topografix, [GPX format overview](https://www.topografix.com/gpx.asp) — GPX’s interchange purpose and official schema access point.

These primary references establish schema facts only. They do not establish Windy Route Planner behavior, IP-1 XSD redistribution rights, a runtime validator, or acceptance of any real route. Those require their designated evidence and review.
