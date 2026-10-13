# IP-4 — GPX Serialization and Loss Report: Detailed Implementation Plan

**Plan status:** Approved Gate 2 plan. Effective Gate 3 status: PASS / ARCHITECT ACCEPTED at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 authorization is stage-specific and never blanket authorization. IP-4 execution and overall implementation remain NOT AUTHORIZED.
**IP-4 execution:** NOT AUTHORIZED.
**Overall implementation:** NOT AUTHORIZED.
**Planning baseline:** Gate 1 `d57d0935c7885eb25eb14542e7996839644e96e2`; IP-1 `6ed649d3995f70fa2421e08cb027c07d19b4cad4`; IP-2 `8011d3f0c4baf62cb15194ab9308f4e312269615`; IP-3 R1 `8e35edff864de87278aa7c61c7376e49845c3d74`.

This plan defines the contract from IP-3’s finalized immutable TransformedRoute to one locally saved GPX 1.1 route artifact and a separate loss report. It separates document construction, independent schema/semantic validation, export eligibility, loss reporting, safe local file handling, and Windy acceptance. This is planning only; no application code, GPX, fixtures, tests, probes, schemas, dependencies, or Shortcuts are created here.

## 1. Scope and boundaries

IP-4 consumes only a finalized IP-3 TransformedRoute. For Current Position modes, previews/candidates or unconfirmed transformations are invalid input. IP-4 constructs one GPX 1.1 document containing exactly one rte and ordered route points, serializing only the route name supplied under the approved cross-stage naming contract and approved point display names. It generates a structured loss inventory and human-readable summary from qualified upstream provenance. It validates the document using a vetted offline GPX 1.1 schema and semantic checks, then returns immutable validated output bytes to IP-5’s filesystem writer.

IP-4 does not parse RTZ, compute or modify route geometry, decide navigation intent, select a joining point, serialize RTZ metadata as misleading GPX fields, implement the CLI/Shortcut/save panel, write files, or test Windy itself. IP-4 owns serialization, schema/semantic validation, export eligibility, immutable validated bytes, loss reporting, and output requirements/status. IP-5 owns the actual filesystem writer, temporary staging, file identity/collision checks, no-replace or confirmed-replace publishing, atomicity/provider behavior, cleanup/final save result, and runtime/file-reference transport. IP-7 owns native destination selection, explicit overwrite consent, user-facing save/cancel/error feedback, and Reveal in Finder. IP-6 owns Windy Route Planner empirical acceptance. IP-4 makes no claim of ECDIS equivalence.

## 2. Upstream contracts and status

| Upstream/downstream | Required contract | State at this planning baseline |
|---|---|---|
| Master Plan | GPX 1.1, one ordered rte, exact selected route order, source unchanged, collision-safe save, no silent overwrite, offline schema validation, loss reporting | Approved. |
| IP-1 | GPX XSD provenance/hash/license and offline validation strategy; coordinate formatting and semantic determinism decisions; qualified source field matrix; sanitized fixture plan | Gate 3 review passed; execution evidence and exact artifact/license decisions remain open. Do not bundle or download an XSD based on this plan. |
| IP-2 | Validated immutable model precision, optional field presence, qualified meanings, bounded unsupported-content summaries | Plan approved; execution evidence pending. No raw XML/payload crosses into IP-4. |
| IP-3 R1 | Finalized TransformedRoute; point and leg provenance; effective GPX route-name metadata separate from source model; synthetic labels/provenance; one-point neutral result with warning; explicit connector geometry | Plan approved; execution evidence pending. G3-006 selects the rhumb closest-point objective; numerical qualification remains unverified and is not represented as execution PASS. |
| IP-5 | Stable CLI result/error interface, save transport, file permissions/reference binding, output path handling | Approved plan; protocol and platform qualification pending. |
| IP-6 | Synthetic GPX import through Windy Route Planner; visual/order/count and one-point compatibility evidence | Future empirical stage; no Windy behavior assumed and no product policy delegated to IP-6. |
| IP-7 | Native save panel, explicit overwrite, warnings, Shortcut display, Reveal in Finder | Approved plan; UI/platform qualification pending. |

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
- A route point has required decimal `lat` and `lon` attributes. Preserve model values according to §4.1; serialize no geometry-derived or distance-derived coordinate.
- Route child order follows the GPX schema sequence. The only route child emitted by default is optional `name`, followed by `rtept` elements. Each rtept has only required coordinate attributes and optional name. Do not substitute `trk/trkseg/trkpt` for route semantics.
- A finalized route with zero points is invalid. A valid one-point transformation is eligible for GPX export as exactly one `rtept`, with a prominent no-navigable-leg warning and explicit user confirmation. Do not fabricate another point or change source data. Windy acceptance of this case is separate under IP-6. Two same-coordinate points remain two ordered points with distinct provenance and a zero-length warning.
- The GPX route preserves vertices/order, not RTZ leg geometry, turn arcs, wheel-over points, XTD, or ECDIS construction. No densification, smoothing, interpolation, sorting, snapping, deduplication, or “repair.”

### 3.3 Route and waypoint names

- Approved G3-001 contract: use the valid source RTZ route name as the default when present; IP-7 may collect an explicit export-only override or explicit omission, IP-5 transports and binds it, and IP-4 serializes the exact effective confirmed value as `rte/name`. This value is separate from source route identity/model and from the output `.gpx` filename. Never infer a vessel name, source filename or private path. If the source name is missing or invalid, require either a valid override or explicit omission. Validate without silent substitution, truncation, or normalization. Exact XML character policy, length bound and normalization details remain technical qualification items. A route-name change after route confirmation invalidates that confirmation and dependent publication consent.
- For original points, emit `rtept/name` only when the finalized point carries an existing nonempty source waypoint name. Preserve its Unicode scalar sequence and value; do not normalize, trim, case-fold, or alter for uniqueness. Missing source names remain absent. Duplicate names remain duplicate; the user must disambiguate them by displayed order/reference, not by changing GPX names.
- Synthetic points are not source waypoints and have no RTZ identity. Proposed stable display labels are `Current Position (synthetic)` and `Join Point (synthetic)`. Emit these labels in GPX only when the preview/confirmation contract explicitly accepts synthetic labels; otherwise omit name and retain typed provenance in the separate report. A label is explanatory text, never an ID, and may collide with an original display name without merging points.
- If a join endpoint reuses an original waypoint reference under IP-3’s approved endpoint identity/tolerance contract, use that original point’s name if present. Do not emit a synthetic Join Point name for a reused endpoint.
- Never put IP-3 internal object references, source IDs/revisions, source ordinals, digests, or private route/vessel identifiers into GPX names/extensions. No extensions are planned for V1.

## 4. Coordinate integrity, XML safety, and determinism

### 4.1 Numeric representation

- IP-4 consumes the exact numeric values on finalized TransformedRoute points. Preserve the numerical value represented by the model, not the original RTZ attribute’s lexical spelling. No claim of byte-for-byte or lexical equality to RTZ is made; IP-2 may preserve decimal value while lexical form remains unavailable.
- GPX serialization must use deterministic, locale-independent decimal formatting. Do not intentionally round, snap, smooth, normalize, or alter coordinates, and do not use locale-dependent formatting. Formatting and parser rules must preserve the coordinate value according to IP-2’s approved numeric representation; no precision guarantee may exceed what the upstream model demonstrates.
- **Exact-decimal representation:** if IP-2 represents a coordinate as an exact decimal, independently parse the GPX coordinate and require mathematical decimal equality.
- **Binary floating-point representation:** binary floating point alone is not a blocker. Select a qualified shortest-round-trip decimal representation that reparses to the same finite binary value under approved parsing rules. Before freezing, document error relative to the original RTZ decimal input and intended output, and establish an approved precision/tolerance policy. Do not equate binary semantic preservation with lexical or mathematical equality to the original RTZ decimal spelling.
- Verify both representations with independent synthetic vectors and a second parser/implementation. Compare every coordinate by ordinal to the approved model value under its representation-specific contract; separately quantify source-RTZ-decimal-to-model error where the model is binary. Synthetic coordinates receive the same representation-aware verification.
- Preserve source model coordinates and confirmed synthetic coordinates according to the approved numeric representation. G3-005 approves preserving numeric +180° when the qualified RTZ input and approved GPX 1.1 schema can represent the value without changing its semantics. Do not normalize or wrap it to -180°. If the exact schema artifact rejects +180°, or semantic/schema validity cannot be established, fail closed with GPX_COORDINATE_UNREPRESENTABLE and no output. Numeric-value preservation does not promise source decimal-spelling preservation. Antimeridian geometry behavior remains subject to IP-1/IP-3 qualification.
- Reject nonfinite/out-of-range coordinates and values that cannot be represented or round-tripped under the approved model/serializer contract. Latitude bounds are inclusive [-90,90]; GPX longitude bounds are [-180,180). Validate before serialization and after independent reparsing.

### 4.2 XML and text

- Use a standards-compliant XML writer. Never concatenate XML markup with route names or point names.
- Encode XML 1.0 UTF-8; escape markup-significant characters in attributes/elements, preserve valid Unicode without normalization, and reject XML 1.0 forbidden characters/surrogates rather than replacing or dropping them silently.
- XML declaration, namespace, element order, creator, decimal formatting and omission rules are fixed by the serializer contract. Repeated semantically identical requests must produce identical GPX meaning: same names, point order, coordinate decimal values, and element presence. Byte-for-byte identity is not required unless IP-1’s serializer decision supplies a concrete requirement; do not add custom canonicalization solely to make bytes identical.
- Invalid route/name/coordinate data yields a bounded diagnostic that does not echo unsafe raw input. A bad optional name is not silently omitted; it blocks export or requires correction through the approved IP-7/IP-5 naming interaction before a new confirmed request.

## 5. Structured metadata-loss inventory

Generate one deterministic LossInventory from the finalized TransformedRoute and IP-2’s qualified field-presence/semantic summaries. Never infer that a field existed from a dialect alone; report a field-specific loss only when IP-2/IP-3 provenance establishes that the recognized field was present or an applicable leg/point was excluded. Distinguish absent, present-and-preserved, transformed, excluded, not representable in core GPX, unknown/unqualified, and not applicable.

Each item contains a stable code, category, severity, disposition, bounded count, and optional scoped point/leg provenance references (source ordinal and typed relation). References remain in-memory by default and must not expose source IDs, names, paths, coordinates, hashes, or payload in default logs. Do not embed raw XML or arbitrary extension text.

| Category | Planned disposition |
|---|---|
| Ordered transformed waypoint positions and existing names | Preserved semantically in `rtept` order/name where supplied; value round-trip follows the approved exact-decimal or binary-floating-point representation contract, without claiming source lexical equality. |
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
- Optionally save a separate machine-readable JSON sidecar (proposed suffix `.loss-report.json`) only after explicit user selection/confirmation. Use a separately selected location or same-folder default only if permitted; never silently save beside the route. The sidecar contains codes, categories, counts, and scoped point/leg ordinals; IP-7 selects/consents to this optional output and IP-5 writes it. By default exclude coordinates, private route/waypoint names, source IDs, paths, source digest, and raw extension data. An expanded contextual sidecar policy requires separate privacy review and user opt-in.
- A GPX save and optional sidecar save are separate artifacts, not one atomic transaction. If GPX succeeds and a requested sidecar fails, report GPX success and sidecar failure distinctly; never misreport either status.
- Default logs, error text, telemetry, and crash details must not include coordinates, route/vessel identity, names, source/output paths, full hashes, or XML payload. No network or upload.

## 6. One-point export policy — architectural decision record

**Decision status: RESOLVED — G3-004 approves ALLOW_WITH_WARNING.** The product policy below is fixed; IP-6 supplies separate empirical consumer-compatibility evidence and cannot revoke converter export capability.

### Invariants common to both options

1. **Transformation validity:** IP-3 may return a finalized one-point neutral transformation with `INSUFFICIENT_OUTPUT_POINTS` advisory. Preserve it as a valid neutral result. Do not fabricate a waypoint or classify the transformation itself as invalid.
2. **GPX schema:** GPX 1.1 XSD permits zero or more `rtept`; a one-point route can satisfy schema cardinality if all other constraints pass. XSD conformance establishes neither product eligibility nor consumer acceptance. An empty route remains ineligible at the application layer.
3. **Windy:** compatibility is unverified until IP-6 tests a synthetic one-point GPX through the actual Route Planner import path. Record import outcome and object type. Do not infer product policy from schema or consumer behavior.

### Approved policy — ALLOW_WITH_WARNING

- Permit schema-valid one-point GPX export after an explicit warning and user acknowledgement.
- State clearly that one position does not represent a useful passage route; never label it a complete route or imply navigational utility.
- **Advantages:** preserves a user-selected single-position result for benign review workflows and aligns export eligibility with the schema’s cardinality.
- **Limitations / Master Plan implication:** G3-004 has resolved this policy as ALLOW_WITH_WARNING. Warning/acknowledgement handling is required in IP-7 and transport through IP-5.
- **Consumer risk:** Windy may reject it, reinterpret it, or display a marker rather than a route; IP-6 must measure this, but its result does not decide policy by itself.

### Rejected alternative — REFUSE_EXPORT (not V1 policy; historical rationale only)

- Preserve the one-point IP-3 neutral transformation and its advisory, but refuse GPX export with `GPX_EXPORT_NOT_ELIGIBLE` / `INSUFFICIENT_OUTPUT_POINTS` and a clear explanation. Generate no file.
- Do not fabricate a second waypoint, discard the neutral transformation, or call it invalid.
- **Advantages:** aligns export with a useful-passage minimum and avoids presenting a single position as a route; no special one-point acknowledgement flow is needed.
- **Limitations / Master Plan implication:** the application’s export eligibility is stricter than GPX XSD cardinality and must be documented as a product rule. Users cannot export a schema-valid one-point route.
- **Consumer risk:** avoids relying on Windy’s single-point route behavior, but does not establish any other Windy compatibility; IP-6 may still test it as a bounded compatibility probe if authorized.

IP-4A implements the approved policy; APIs and diagnostics must not retain a selectable refusal branch as the default. IP-6 tests the one-point consumer case separately. If Windy rejects it, retain GPX export and disclose the consumer limitation.

## 7. Export eligibility and validation pipeline

Keep independent states and result types for:

- **Construction:** GPXDocument value has one rte and points/names derived only from final TransformedRoute and naming inputs authorized by the approved cross-stage contract.
- **Schema validation:** serialized XML is well formed, validates offline against the exact approved GPX 1.1 XSD, and passes application semantics.
- **ExportEligibility:** Eligible, EligibleWithWarning, or Ineligible with stable diagnostic codes. One point is EligibleWithWarning, requiring explicit user confirmation; it is separate from schema validity and Windy compatibility.
- **Artifact/save:** IP-4 returns immutable validated bytes; only IP-5’s writer can produce a final save result for the selected destination. Serialization/validation success is not file-save success.
- **Consumer compatibility:** separate IP-6 empirical result; never inferred from successful serialization/validation.

Required checks:

1. Input is a finalized TransformedRoute, not preview/candidate; mode-specific current-position confirmation is valid per IP-3/IP-5/IP-7 contract.
2. Route is nonempty; point and leg lineage coherent; exactly one route will be represented. Apply the Gate 3-approved one-point policy; duplicate-coordinate consecutive points remain distinct and are never deduplicated.
3. All coordinates are finite and in GPX ranges. Round-trip checks follow the approved exact-decimal or binary-floating-point representation contract in §4.1. +180 longitude is not silently wrapped.
4. Name text is valid XML 1.0; output creator and name policy pass; only justified GPX core elements exist.
5. XML is well formed and GPX XSD-valid using an offline local validator and approved schema artifact. Validator must not access network or trust instance schemaLocation.
6. Independent reparse verifies root namespace/version/creator; exactly one rte, no wpt/trk; exact rtept count/order; representation-correct coordinate equality; route and permitted point names; no unexpected child fields/extensions.
7. LossInventory is complete against known qualified/present source properties and IP-3 mode provenance; no speculative claims.
8. Deterministic semantic repeat-conversion check over synthetic inputs yields identical semantic fields, not necessarily identical bytes.

Schema conformance and app semantic checks must have separate diagnostics. Preserve schema issuer/revision/hash/license/runtime strategy evidence in IP-1 research records, not route logs. Do not fetch, download, or bundle an XSD as part of planning. Network remains disabled for implementation/runtime validation.

## 8. Safe local output-file boundary

### 8.1 Responsibility split

- **IP-4:** GPX serialization, schema and semantic validation, export eligibility, immutable validated output bytes, loss report, output requirements and validation status. It does not implement a filesystem writer.
- **IP-5:** actual filesystem writer; temporary-file staging; file identity and collision checks; no-replace or confirmed-replace publishing; atomicity and filesystem/provider behavior; cleanup and final save result; runtime and file-reference transport.
- **IP-7:** native save destination selection; explicit overwrite consent; user-facing save/cancel/error feedback; warnings/report presentation; optional sidecar selection; Reveal in Finder.

### 8.2 IP-5 writer requirements and IP-4 handoff

IP-4 returns immutable bytes only after serialization, schema validation, semantic validation, and eligibility checks pass. Save errors and filesystem outcomes are returned solely by IP-5. It supplies the loss report and validation status; it may specify required output properties but does not stage or publish files.

IP-5 owns the filesystem protocol: receive the authorized destination reference from IP-7; resolve it through approved macOS file-reference/security-scoped APIs; treat path/name as untrusted; settle aliases, permissions and identity jointly with IP-2A/IP-7; stage to an exclusive temporary file; validate the exact staged bytes; perform collision and identity rechecks; publish with no-replace or explicit confirmed-replace semantics; clean up its own temporary artifact; and return the final save result. IP-7 owns choosing the destination, obtaining explicit overwrite consent, and presenting save/cancel/error outcomes.

Safe-save invariants remain mandatory: never silently overwrite; recheck destination identity immediately before publishing; never claim success for partial/invalid bytes; do not remove a preexisting user file; fail safely if atomicity or identity guarantees cannot be met; no unsafe symlink traversal or path reopening; no silent alternate destination; no cloud upload. Preserve Unicode filenames where permitted, handle spaces/cancellation/permissions, and reveal only after successful save. Proposed mode 0600 remains a policy candidate for IP-5 platform review, not an IP-4 writer implementation requirement.

IP-5/IP-7 verification must cover collision/overwrite, target replacement race, permissions, unavailable destinations, cancellation, cleanup, same-volume behavior, File Provider/cloud-backed folders, security-scoped URL lifetime and aliases. Cross-volume/provider guarantees must be measured; unsupported semantics fail safely. GPX-save and optional sidecar-save outcomes remain separate and accurately reported.

## 9. API and diagnostics contract

Conceptual typed interfaces; exact language signatures wait for IP-5/runtime decisions:

- `GPXExportRequest`: finalized TransformedRoute reference, effective route-name value or explicit omission supplied under G3-001, synthetic-name options, approved one-point eligibility/acknowledgement state, optional loss-sidecar request, and no filesystem path or writer handle. Must not accept an unconfirmed preview as final. IP-5 transports the name and validated bytes; IP-7 owns editing and confirmation. The output filename is not the GPX route name.
- `GPXDocument`: neutral validated structure: one route, ordered points, coordinate decimal values, optional names, truthful creator, GPX version/namespace.
- `GPXSerializer`: GPXDocument → deterministic semantic UTF-8 bytes/result; no IO/path/UI.
- `ExportEligibility`: eligible/ineligible/warnings and required acknowledgements; one-point result follows approved G3-004 ALLOW_WITH_WARNING; separate from schema and filesystem state.
- `GPXValidationResult`: well-formed, schema result, application semantic result, round-trip comparison, bounded diagnostics.
- `LossInventory` / `LossReport`: typed machine categories and human summary from qualified source and transformation provenance.
- `ValidatedGPXArtifact`: immutable validated GPX bytes, byte count, format and validation status; no path or filesystem mutation. IP-5 returns a distinct `SaveResult` and optional user-selected sidecar result after writing; no source path/route coordinates/hash in default logs.
- `ExportDiagnostic`: stable code, severity, bounded safe message, optional safe category/count/provenance ordinal; no raw XML/private names/coordinates/path.

Suggested diagnostics, to reconcile with IP-2/IP-3/IP-5 before freeze. One-point eligibility uses the approved warning/confirmation policy:

**IP-4 blocking diagnostics:** INVALID_TRANSFORMED_ROUTE, UNCONFIRMED_TRANSFORMATION, INVALID_GPX_COORDINATE, GPX_COORDINATE_UNREPRESENTABLE, INVALID_XML_CHARACTER, GPX_SCHEMA_UNAVAILABLE, GPX_SCHEMA_VALIDATION_FAILED, GPX_EXPORT_NOT_ELIGIBLE. Under G3-004, a one-point route is eligible only with an explicit warning acknowledgement; if acknowledgement is absent, return a clear blocking diagnostic. Filesystem diagnostics (OUTPUT_ALREADY_EXISTS, OVERWRITE_CONFIRMATION_REQUIRED, OUTPUT_WRITE_FAILED, DESTINATION_PERMISSION_DENIED, DESTINATION_UNAVAILABLE, CANCELLED) and staged-byte writer validation are owned by IP-5; IP-7 presents consent/cancellation/errors. Reconcile shared interface identifiers before freeze.

**Advisory/loss:** INSUFFICIENT_OUTPUT_POINTS, METADATA_NOT_REPRESENTABLE, SOURCE_WAYPOINT_EXCLUDED, SOURCE_LEG_EXCLUDED, SOURCE_LEG_SUPERSEDED, SOURCE_LEG_PORTIONED, UNKNOWN_METADATA_UNQUALIFIED, GEOMETRY_UNAVAILABLE, DISTANCE_UNAVAILABLE, SYNTHETIC_CONNECTION_UNCONSTRAINED, ZERO_LENGTH_CONNECTION, WINDY_COMPATIBILITY_UNVERIFIED.

These identifiers are proposals only. Reconcile diagnostic identity/severity and CLI mapping with IP-2/IP-3/IP-5. Default output includes stable code and safe explanation, not coordinates, route names/IDs, source/output path, XML, full digest, or raw extension content. Interactive UI may show user-selected details needed for informed confirmation.

## 10. Synthetic verification plan (future execution only)

No synthetic file, GPX, test, or fixture is created in this planning task. After authorization, consume the reviewed synthetic fixture catalog from IP-1/IP-2/IP-3. Required cases:

- Full Route, From Waypoint first/middle/last, both Current Position variants; exact output point order/provenance.
- Empty transformed route rejection; one-point neutral transform preserved; G3-004 ALLOW_WITH_WARNING requires affirmative warning acknowledgement and output; absent acknowledgement returns a clear diagnostic and no file; two identical-coordinate points retained with warning; IP-6 consumer behavior recorded independently.
- Every GPX coordinate bound, including +180 longitude refusal without normalization; negative zero; very small/high-precision decimals; malformed/nonfinite values; exact-decimal equality or binary shortest-round-trip equality as appropriate; source-decimal-to-model error measured under approved synthetic tolerance; no locale-dependent formatting.
- Unicode composed/decomposed strings preserved without normalization; XML metacharacters escaped; forbidden XML 1.0 controls rejected; duplicate/missing source names; repeated synthetic labels and collisions without identity merging.
- Valid source route name default; explicit valid export-only override; explicit omission when source name is missing/invalid; Unicode and filename/XML-special text; invalid characters and length-bound rejection; exact confirmed `<rte><name>`; output filename changes do not change route name; name never becomes a path, changes RTZ/IP-3 source identity, or becomes creator identity. Keep waypoint names unchanged, including duplicates.
- Serializer output has correct root namespace/version/creator, one rte, no wpt/trk/extra rte, schema sequence, ordered rtept, required attributes and only approved optional names.
- Offline XSD valid/invalid pairs; schema unavailable/license unresolved; validator network access disabled; wrong namespace/version, wrong element order, missing creator/coordinate, out-of-range coordinate and forbidden element.
- Loss inventory for present versus absent fields, every IP-3 exclusion/superseded/shortened leg, unknown extension summaries, unsupported geometry/distance, synthetic connector, schedules, speed, XTD/radius/instructions. Assert no invented losses.
- Reparse output independently; compare exact decimal values for decimal models or identical finite binary values for binary models, plus count/order/names/creator. Quantify source-decimal-to-binary-model error with approved synthetic tolerances; repeated request yields semantic equality.
- IP-5-owned save-path integration evidence from §8, including overwrite/race/permission/cancellation/temp cleanup/provider limitations; IP-4 only verifies immutable artifact handoff and accurate separation of serialization/validation from the IP-5 save result and optional sidecar outcome.
- Privacy assertions: no coordinate/path/private route name/source ID/hash/raw payload in default diagnostics/log fixtures. Windy Route Planner import is a separate IP-6 manual acceptance record, not a unit test substitute.

Oracle provenance: XSD validation uses the exact IP-1 approved GPX schema hash and legally permitted offline validator. Coordinate round-trip oracle uses a second parser and representation-specific comparison; synthetic source-decimal-to-binary error vectors and tolerance must be independently reviewed before contract freeze. No real route or vessel coordinates in fixtures or screenshots.

## 11. IP-6 Windy acceptance handoff

IP-4 should deliver to IP-6 a matrix of synthetic GPX documents generated only after IP-4 execution authorization. Include:

- Full Route, From Waypoint, Current Direct, Current Join with expected point sequence.
- One-point GPX may be tested by IP-6 as synthetic empirical evidence; it does not choose product policy. Empty route is rejected at application layer and is not a consumer test artifact.
- Original waypoint names including duplicate/absent and synthetic labels included/omitted; effective route name default/override/omission; filename independence; source model unchanged.
- Unicode and XML-special characters.
- Antimeridian and high-latitude coordinates.
- Two distinct route points with equal coordinates.
- Geometry-metadata loss and synthetic connector limitations.

For each, provide expected XSD result, application eligibility, exact coordinate/order/name expectations and known GPX limitations. IP-6 records date/app/web version, actual Route Planner import path, imported object type (route vs track/other), point count/order, names/endpoints, displayed geometry and any truncation/normalization. Do not conflate public Uploader support with Route Planner acceptance. Use only synthetic data and do not publish/share. If schema-valid output conflicts with Windy behavior, document evidence and request architectural review before vendor-specific workaround or scope change.

## 12. Future IP-4 implementation sub-stages

These are future authorized stages, not execution instructions for this task. Proposed paths assume the Swift-oriented direction in IP-2 and must be reconciled after IP-1/IP-2 execution; no files are created now.

### IP-4A — GPX 1.1 schema and serialization contract

- **Objective:** Freeze XSD provenance/license/offline validator strategy, root/route/point/name/number rules, representation-aware precision contract, namespace/schema hint, eligibility states and Gate 3-approved one-point policy.
- **Scope:** Contract/evidence integration; no product code, schema download, or GPX artifact.
- **Proposed files:** `docs/research/IP-4/GPX-QUALIFICATION.md`, `docs/research/IP-4/GPX-SERIALIZATION-DECISIONS.md`.
- **Dependencies:** IP-1 GPX schema/legal decisions; IP-2 numeric representation and source-error evidence; IP-3 R1 finalized route and approved G3-001/G3-004 name and one-point contracts; Gate 4 authorization.
- **Sequence:** inspect only approved schema artifact → decide license/offline validation → reconcile IP-1 serializer notes → qualify +180 coordinate representation and semantic determinism under G3-005 → implement G3-001 name and G3-004 one-point policy → close representation-specific precision/error/tolerance and hint decisions → review.
- **Synthetic tests/evidence:** later planned cases for schema facts, exact-decimal and binary shortest-round-trip behavior/error analysis, both name alternatives, the approved one-point warning/acknowledgement path and missing-acknowledgement refusal path; independently reviewed schema/hash/license record.
- **Acceptance:** documented GPX contract; no unsupported fields; approved G3-001 naming and G3-004 one-point contracts honored; representation-aware precision/error contract supported by IP-2 evidence; IP-6 obligations explicit.
- **Risks:** schema redistribution, longitude +180 conflict, model lexical precision unavailable, numeric representation unable to support stated semantic preservation.
- **Rollback/PASS:** revert only IP-4A-owned decision files; PASS after architect and IP-1 review, no schema bundled unless rights cleared.

### IP-4B — Deterministic route/point serializer

- **Objective:** Build UTF-8 GPX 1.1 document from finalized TransformedRoute and naming input approved by the cross-stage contract.
- **Scope:** Pure document construction/serialization, no file IO, CLI, UI, RTZ parsing, or GPX extension.
- **Proposed files:** `Sources/RTZCore/GPX/GPXDocument.swift`, `GPXSerializer.swift`, `Sources/RTZCore/Diagnostics/GPXDiagnostic.swift`; synthetic tests in `Tests/RTZCoreTests/GPXSerializerTests.swift`.
- **Dependencies:** IP-4A PASS; IP-3 finalized transform API; IP-2 numeric representation and precision/error evidence.
- **Sequence:** validate final route and approved names → map one rte and ordered points → serialize locale-independent decimals/XML text → independent reparse → compare representation-specific semantic values.
- **Synthetic tests:** §10 schema shape, Unicode/escaping, names, coordinate edge cases, deterministic semantics and non-mutation.
- **Acceptance:** one GPX route, exact order/count and representation-correct value round-trip, approved name policy, no tracks/metadata leakage, well-formed output; +180/nonfinite/invalid XML fail explicitly.
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

- **Objective:** Separate transformed-route validity, app eligibility, XSD conformance, representation-aware round-trip semantics and Windy compatibility.
- **Scope:** Validation/eligibility; no file saving or Windy import.
- **Proposed files:** `Sources/RTZCore/GPX/GPXExportEligibility.swift`, `GPXValidator.swift`; synthetic tests in `GPXValidationTests.swift`.
- **Dependencies:** IP-1 approved GPX XSD/license/runtime; IP-4A/B/C; IP-2 numeric representation evidence; IP-3 confirmation status.
- **Sequence:** require finalized route → validate coordinates/names/count → construct document → offline XSD validation → independent reparse/exact compare → return separate statuses/warnings.
- **Synthetic tests:** all invalid/valid schema pairs; the approved one-point warning/acknowledgement path and missing-acknowledgement refusal path; +180 refusal; exact-decimal and binary shortest-round-trip/error analysis; no network.
- **Acceptance:** schema and app semantics distinct; no unconfirmed preview accepted; Gate 3 one-point policy implemented as approved; representation-specific precision/tolerance verified; validator offline and traceable.
- **Risks:** schema license or validator not shippable; downstream behavior not implied.
- **Rollback/PASS:** fail closed if validator unavailable; PASS only with hash-bound XSD/oracle evidence and no network.

### IP-4E — Validated artifact handoff and IP-5/IP-7 integration

- **Objective:** Deliver immutable validated GPX bytes, loss report and output requirements to IP-5/IP-7 through approved interfaces.
- **Scope:** Define/test the artifact handoff contract and integration; no filesystem writer, temporary-file logic, path resolution, collision handling or publish code belongs to IP-4. Native save UI remains IP-7; writer/CLI transport remains IP-5.
- **Proposed files:** `Sources/RTZCore/GPX/ValidatedGPXArtifact.swift`, integration contract documentation/tests; filesystem writer files, if required, are owned by the separately planned IP-5.
- **Dependencies:** IP-4B/D PASS; IP-5 writer/file-reference/runtime contract; IP-7 destination/security-scope/overwrite-consent UX; platform security review.
- **Sequence:** provide immutable bytes plus validation status → IP-5 receives the approved destination capability from IP-7 → IP-5 performs identity/collision checks, stages, validates exact bytes, publishes and cleans up → return a distinct save result → IP-7 presents result or reveals saved output.
- **Synthetic tests/evidence:** artifact immutability, invalid-artifact refusal, interface/error mapping; filesystem collision/race/permission/provider/cancellation/cleanup verification is owned by IP-5 and coordinated with IP-7.
- **Acceptance:** IP-4 never mutates filesystem; no silent overwrite, fallback or partial success; save result distinct from serialization/validation; safe-save invariants are tested by IP-5/IP-7.
- **Risks:** handoff mismatch, unsupported destination semantics, unclear writer ownership.
- **Rollback/PASS:** isolate/revert handoff contract only; PASS after IP-5/IP-7 interface and evidence review; no platform-specific writer is introduced in IP-4.

### IP-4F — Synthetic acceptance and IP-6 handoff

- **Objective:** Assemble end-to-end synthetic evidence for GPX, loss reporting and Windy test readiness.
- **Scope:** Contract acceptance and sample handoff; actual Windy behavior belongs to IP-6.
- **Proposed files:** IP-4 synthetic test suite and `docs/research/IP-4/GPX-ACCEPTANCE-MATRIX.md`; no private route.
- **Dependencies:** IP-4A–E; IP-1 synthetic fixtures; IP-2/IP-3 execution evidence; IP-6 protocol.
- **Sequence:** run authorized IP-4 XSD/round-trip/privacy/artifact-handoff matrix → independently review evidence → coordinate IP-5-owned filesystem integration evidence without taking writer ownership → prepare minimal synthetic GPX cases → hand expected outcomes to IP-6.
- **Synthetic tests:** complete §10 matrix; Windy one-point and all mode cases documented as not yet accepted until IP-6.
- **Acceptance:** all IP-4-owned contracts and artifact handoff verified; no confidential data; IP-5 save evidence remains attributed to IP-5; IP-6 can independently reproduce expected GPX semantics.
- **Risks:** mistaking schema validity for consumer acceptance; fixture drift.
- **Rollback/PASS:** quarantine failing sample; PASS only after review signs the evidence and IP-6 receives synthetic matrix (IP-6 itself may remain pending).

## 13. Cross-stage dependency and decision matrix

| Contract | IP-4 need | State | Owner/evidence to freeze |
|---|---|---|---|
| GPX 1.1 XSD identity, digest, license and offline validator | Schema and release validation | IP-1 plan approved; artifact/runtime evidence unresolved | IP-1 qualification and legal review |
| GPX route mapping: one rte, ordered rtept, names only | Serialization | Core route semantics and export-only name override approved | IP-3 supplies effective name/omission; IP-5 transports/binds it; IP-7 edits and confirms; IP-4 serializes exact value |
| IP-2 coordinate representation | Semantic GPX round trip | Exact decimal vs binary floating-point behavior must be evidenced; no unsupported precision promise | IP-2 model evidence, source-decimal error analysis, synthetic independent-parser vectors and approved tolerance |
| Longitude +180 handling | Coordinate output | Product rule resolved: preserve numeric value only if exact schema-valid representation is qualified; never wrap | IP-1/IP-2 coordinate evidence and exact GPX XSD validation; otherwise fail closed |
| One-point neutral route | Keep IP-3 result intact | G3-004 resolves export as ALLOW_WITH_WARNING + explicit confirmation; Windy remains separate | IP-4 implements one `<rte>` with one `<rtept>`; IP-6 reports one-point behavior/limitation |
| Current-position confirmation | No candidate serialization | IP-3 domain/IP-5 transport/IP-7 UI contract proposed; not executed | Cross-stage command binding and stale-preview tests |
| Loss inventory source presence | Avoid invented losses | Depends on qualified IP-1 matrix and IP-2 bounded model | IP-1/IP-2 execution review |
| Route name ownership | Serialize only approved name input | G3-001 resolves valid source default, export-only override or explicit omission; no fallback | IP-3 supplies effective value, IP-5 transports/binds, IP-7 previews/confirms, IP-4 serializes |
| Validated artifact vs filesystem writer | IP-4 returns immutable bytes; IP-5 writes | IP-5 exclusively owns staging, identity/collision, publishing, cleanup and save result; IP-7 owns destination and overwrite consent | IP-5 plan plus IP-2A/IP-7 reference, alias, permission and identity agreement |
| Overwrite/atomicity/permissions | No partial or silent replace | IP-5 writer responsibility; behavior unverified | IP-5/IP-7 and filesystem-specific verification |
| Loss report sidecar | Optional, privacy-minimal | Proposed, not frozen | IP-5/IP-7 format/save/privacy review |
| Windy Route Planner behavior | Consumer acceptance | Unverified | IP-6 synthetic empirical record; never inferred from XSD |

All IP-1/IP-2/IP-3 implementation evidence is pending. Their approved plans are upstream planning contracts only. If any IP-3 decision or IP-2 model cannot satisfy a GPX rule without altering source coordinates, raise a cross-stage issue; do not normalize, repair, or change approved plans silently.

## 14. Risks and unresolved decisions

1. **Schema provenance/licensing/runtime:** no XSD artifact or bundle until IP-1 documents exact digest, imports, rights and offline validator strategy.
2. **+180 longitude:** preserve numeric value only when the qualified GPX XSD and semantic round-trip accept it; otherwise fail closed. Never normalize to -180. Schema qualification remains pending.
3. **Coordinate representation:** preserve semantic values according to the approved exact-decimal or binary contract; quantify source-decimal-to-model error for binary values and approve synthetic tolerance before freeze. No RTZ lexical preservation claim.
4. **One-point route:** G3-004 approves ALLOW_WITH_WARNING and explicit confirmation. Windy one-point behavior remains separately unqualified and may be documented as a limitation.
5. **Route-name ownership:** G3-001 approves source-name default, explicit export-only override, or explicit omission; no vessel/filename fallback. IP-3 owns effective preview semantics, IP-5 transport/binding, IP-7 interaction and IP-4 serialization.
6. **Loss semantics:** field presence and split-leg applicability depend on IP-1/IP-2/IP-3 qualified evidence; unknown fields cannot be counted as specific known losses.
7. **Offline schema:** if legal/runtime requirement cannot be met, block rather than fetch at runtime or weaken validation.
8. **Filesystem writer:** IP-5 owns writer implementation and must measure same-volume, File Provider/cloud-folder, permissions, replacement and atomicity behavior; IP-4 supplies immutable validated bytes only.
9. **Privacy of optional report:** sidecars can expose route-derived provenance; keep them opt-in, minimal and local, with separate policy.
10. **Windy mismatch:** valid GPX schema does not guarantee Route Planner import; no vendor workaround without architectural review.

## 15. IP-4 acceptance and execution gate

### Planning acceptance

- Complete GPX 1.1 core mapping, XML/encoding/namespace/root/name/point-order contract.
- Representation-aware semantic coordinate preservation, deterministic formatting, independent round-trip verification, source-decimal error analysis and explicit +180 limitation.
- G3-004 resolves the one-point export policy as ALLOW_WITH_WARNING with explicit confirmation; IP-4A must implement that policy after Gate 4 authorization. Windy compatibility remains separate IP-6 evidence.
- Structured deterministic loss report distinguishes present, absent, excluded, transformed, unsupported, and unrepresentable data.
- Human summary, optional sidecar, privacy boundary, and no-extension default defined.
- IP-4 immutable-byte/validation handoff is separated from IP-5 filesystem writer and IP-7 destination/consent/feedback responsibilities; safe-save invariants remain specified.
- Offline schema validation plan, independent round-trip test matrix and IP-6 synthetic handoff defined.
- IP-4A–IP-4F dependencies/acceptance/risks/rollback recorded without implementation plans being executed.
- G3-001–G3-011 product/architecture decisions are recorded in the Gate 3 reconciliation report. Numeric representation/tolerance, schema qualification, Windy evidence, source continuity and filesystem behavior remain unresolved technical qualification dependencies.

### Future IP-4 execution PASS

Only after Gate 3 acceptance, closure of prerequisite technical blockers, and explicit Gate 4 authorization: finalized route maps to one valid GPX 1.1 rte; output validates against approved offline schema; point order and representation-specific coordinate values round-trip under independently verified rules; loss categories match qualified source presence and IP-3 provenance; selected one-point and name policies are implemented as approved; IP-4 returns immutable validated bytes; IP-5’s separately verified writer saves complete output without silent overwrite/partial success and IP-7 reports accurately; no source RTZ change or network dependency occurs; independent review accepts evidence. Windy compatibility remains IP-6 evidence and does not independently choose product policy.

## 16. Sources and research boundary

- Approved project sources: Master Plan; IP-1 §§5–6; IP-2 §§6–9; IP-3 R1 §§4–5, 8–10, 13–15 at the baselines in the header.
- Topografix, [GPX 1.1 Schema Documentation](https://www.topografix.com/gpx/1/1/) — root attributes, namespace, element sequence/cardinality, rte/rtept structure, decimal coordinate ranges.
- Topografix, [Developing GPX applications](https://www.topografix.com/gpx_for_developers.asp) — schemaLocation is a hint whose locations may change; use XML parsers/writers and do not rely on fetching a fixed schema URL.
- Topografix, [GPX format overview](https://www.topografix.com/gpx.asp) — GPX’s interchange purpose and official schema access point.

These primary references establish schema facts only. They do not establish Windy Route Planner behavior, IP-1 XSD redistribution rights, a runtime validator, or acceptance of any real route. Those require their designated evidence and review.
