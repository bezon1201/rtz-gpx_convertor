# IP-3 — Route Modes and Geometry: Detailed Implementation Plan

**Plan status:** Approved Gate 2 plan. Effective Gate 3 status: PENDING FINAL INDEPENDENT ARCHITECT REVIEW; the remote PASS declaration at `d9f723ba91091c682c9676f41dc168da31a252f1` is historical and superseded for current authorization. Gate 4, IP-3 execution, and overall implementation: NOT AUTHORIZED.

**IP-3 execution:** NOT AUTHORIZED.

**Overall implementation:** NOT AUTHORIZED.

**Planning baseline:** Gate 1 `d57d0935c7885eb25eb14542e7996839644e96e2`; IP-1 `6ed649d3995f70fa2421e08cb027c07d19b4cad4`; corrected IP-2 `8011d3f0c4baf62cb15194ab9308f4e312269615`.

This plan defines the transformation boundary from IP-2’s immutable validated route model to the GPX handoff consumed by IP-4. It creates no GPX and does not alter the source RTZ or IP-2 RouteDocument. The approved Master Plan and upstream plans remain authoritative. Proposals marked provisional or unresolved require evidence/review before their implementation sub-stage is authorized.

## 1. Scope and boundaries

IP-3 plans three user-selected modes: Full Route, From Waypoint, and From Current Position. Current Position has two explicitly selected variants: Direct to Next WP and Join Selected Route Leg. It produces an immutable domain-level TransformationPreview/Candidate and, after valid confirmation for Current Position modes, a format-neutral TransformedRoute, diagnostics, advisory distances, and a metadata-loss/provenance summary for IP-4/IP-5/IP-7.

IP-3 does not parse XML, qualify schemas, serialize GPX, render a map, optimize or repair a route, select a waypoint/leg automatically, perform safety or hazard analysis, infer a geometry type, or claim ECDIS equivalence. It does not alter IP-2’s model contract: any required addition is a cross-stage issue for review. RTZP remains outside V1. No implementation, probes, fixtures, tests, scripts, dependencies, or product artifacts are authorized by this planning task.

## 2. Upstream contract and status

| Input | Required contract/evidence | Status at this planning baseline |
|---|---|---|
| Master Plan | Modes; offline scope; geometry and distance convention; non-navigation boundary | Approved. Distance convention is advisory only. |
| IP-1 | Qualified exact RTZ dialect/schema/field matrix; geometry literal semantics; synthetic fixtures; independently reviewed distance oracles and tolerances | Reconciled plans are pending final independent Gate 3 review; execution evidence is pending. Do not infer a dialect or literal is qualified. |
| IP-2 | Immutable ordered RouteDocument; point identities/coordinates/names; incoming leg ownership; qualified geometry or uninterpreted UnknownLiteral; safe diagnostics | Reconciled plans are pending final independent Gate 3 review; execution evidence is pending. |
| IP-4 | GPX 1.1 mapping and loss-report consumer contract | Approved plan; execution pending. G3-001/G3-004 policies fixed; schema and exact-name qualification pending. |
| IP-5 | Stable CLI mode/selection/confirmation inputs and diagnostic contract | Approved plan; execution pending. G3-003 continuity mechanism and G3-007 consent protocol qualification pending. |
| IP-6 | Windy import acceptance using synthetic routes | Indirect dependency through IP-4 output; no Windy behavior is assumed here. |
| IP-7 | Shortcut preview, explicit confirmation, manual position entry and errors | Approved plan; execution pending. G3-001/G3-002 UI contracts fixed; platform/transport qualification pending. |

Planning can establish a proposed interface, but no IP-3 implementation may begin until Gate 4 is explicitly authorized. Final independent Gate 3 review remains pending. IP-1/IP-2 plan approval is not evidence that schemas, models, or calculations have been implemented or tested.

## 3. Transformation invariants

1. Treat the source RouteDocument as immutable. Transformations create new value objects; source point order and coordinates remain unchanged.
2. Preserve source waypoint order. Never sort by ID, reverse direction, snap, interpolate, optimize, repair, or silently remove a source point.
3. A source leg’s geometry and leg metadata belong to its destination waypoint as that point’s incoming leg. The first point normally has no incoming leg.
4. Only IP-1-qualified geometry literals with explicitly reviewed semantics may drive calculations or a transformation. Missing geometry means unavailable. UnknownLiteral is uninterpreted source metadata only and never drives distance, selection, projection, or transformation. No guessed Loxodrome or Orthodrome fallback.
5. Distances and join candidates are explanatory calculations. They never choose, modify, rank, or authorize the intended route. A computed candidate is not accepted until the user explicitly confirms the complete preview.
6. A route transformation is not a navigation recommendation. No safety, hazard avoidance, traffic separation, or ECDIS-equivalence claim is made.
7. Private route names, coordinates, identifiers, and source digests stay out of default logs/diagnostics. Use the IP-2 privacy boundary; no full source digest by default.

## 4. Stable references and neutral output model

### 4.1 Source references

Use an in-memory SourceWaypointRef scoped to one validated RouteDocument: one-based source ordinal plus source identity when the qualified dialect supplies one. Display names are labels only, never identity. Duplicate names and nonsequential IDs are valid selection cases. If IDs are repeated or absent, ordinal within the immutable document disambiguates. A reference from another document/session is invalid. Do not expose or persist a source-file digest to manufacture identity.

A SelectedLegRef identifies the original forward leg by its source-document scope and the adjacent source ordinals of its origin and destination. Since incoming metadata belongs to the destination, it also points to the destination’s incoming leg record. No selection is inferred from proximity. “Forward” always means increasing source ordinal.

### 4.2 Proposed immutable types

These are conceptual interfaces, not frozen implementation language/API declarations:

- ConversionMode: FullRoute, FromWaypoint, CurrentPositionDirect, CurrentPositionJoin.
- WaypointSelection: SourceWaypointRef.
- CurrentPosition: validated latitude/longitude in decimal degrees with explicit user-input provenance.
- SelectedLeg: SelectedLegRef and confirmed forward direction.
- ConnectionGeometry: explicitly selected, IP-1-qualified Orthodrome or Loxodrome.
- TransformationPreview / TransformationCandidate: immutable exact input selection/options, proposed ordered point/leg sequence, provenance, geometry status, warnings, advisory results, and a transient preview revision bound to those exact inputs; candidate state only.
- ConfirmedTransformationCommand: explicit request to accept a current preview, carrying the exact preview revision and choices; IP-3 validates it against current inputs before producing a finalized route.
- JoinCandidate: candidate coordinate, selected source leg, geometry type, bounded calculation status, endpoint classification/identity, along-leg parameter, advisory distances, and warnings; candidate state only.
- TransformedPoint: coordinate, optional display name, provenance, and source reference if applicable.
- TransformedLeg: endpoints, geometry availability/type, source-leg relation, transformation relation, advisory-distance result, and metadata disposition.
- TransformedRoute: finalized ordered points/legs, mode, validated confirmed choice where required, warnings, loss inventory, and advisory summary.
- PointProvenance: OriginalSourcePoint or UserSuppliedCurrentPosition or ComputedJoinPoint.
- GeometryAvailability: Qualified(type), Missing, UnknownLiteral(uninterpreted), or UnsupportedByQualification.
- EffectiveGPXRouteName: valid source route name by default, explicit export-only user override, or explicit omission. This value is preview/export metadata separate from the immutable source RouteDocument/name and never changes points, coordinates, order, names, or leg geometry. Bind it to the confirmed command; IP-4 serializes it and IP-5 transports it.
- TransformationWarning / Diagnostic: stable code, severity, bounded safe message; contextual coordinates and identifiers are not logged by default.

Do not carry raw XML, full paths, source payload, or unreviewed extension blobs into this model. Synthetic-point identity is a typed provenance marker in the transformed model, not a fabricated RTZ ID. Any GPX name policy is an IP-4 decision; the transform must retain original names and synthetic identity separately. A UI may label a point “Current position” or “Join point” without changing source metadata.

### 4.3 Leg lineage

A transformed leg must state one of: unchanged source leg; retained subsegment of a source leg; new user-selected connection; or unavailable/unsupported geometry. It also records metadata disposition: retained as source provenance, superseded, portioned/semantics uncertain, or not applicable. Do not clone turn radius, XTD, speed, schedule, wheel-over, or other source instructions onto a newly created connection. Split-leg metadata applicability is unresolved until IP-1’s field matrix and IP-4’s loss contract are reviewed; preserve it only as provenance for reporting, never imply it describes a newly introduced connection.

## 5. Mode contracts

### 5.1 Full Route

Return every source waypoint in exact source order with original coordinates and available names. Preserve each qualified incoming-leg reference for downstream advisory/loss handling. No synthetic points or new legs. An unavailable/unknown geometry makes that leg’s geometry-specific distance unavailable, but does not by itself change the route. A validated one-point source route produces a valid one-point neutral transformation and an INSUFFICIENT_OUTPUT_POINTS warning; G3-004 permits GPX export only with the visible no-navigable-leg warning and explicit confirmation. Do not invent another point or discard the transformation. IP-6 consumer compatibility is separate. Route length is separate advisory information and never changes the point sequence.

### 5.2 From Waypoint

Require explicit selection by SourceWaypointRef. Include the selected point and every subsequent source point in order; exclude preceding points; never reverse. Selecting the first point yields the same point sequence as Full Route. Selecting the final point yields a valid one-point neutral transformation with an INSUFFICIENT_OUTPUT_POINTS advisory; do not fabricate a connector or silently discard the result. G3-004 approves one-point GPX export with a prominent no-navigable-leg warning and explicit user confirmation; IP-6 tests Windy compatibility separately. A one-point source route follows the same neutral-model behavior. The selected first point has no included incoming leg from its preceding source point; record that preceding incoming segment as excluded/discarded in the loss summary when one exists. Subsequent original incoming legs retain their source relationship.

### 5.3 Current Position — shared selection

**G3-002 approved contract:** Both Direct to Next WP and Join Selected Route Leg require an explicit new connector geometry choice: Great Circle / Orthodrome or Rhumb Line / Loxodrome. No default, inference, or automatic fallback is allowed. Show the choice in preview and bind it to route confirmation. In Join mode, this new connector geometry is distinct from the source selected-leg geometry used to compute the join point. If the selected connector cannot be calculated within its qualified domain, return a diagnostic and do not switch methods. Source RTZ geometry and data remain unchanged.

Require separately entered WGS84 latitude and longitude in decimal degrees, finite and within latitude [-90, 90] and longitude [-180, 180], plus an explicit next waypoint and either Direct to Next WP or Join Selected Route Leg. Any other coordinate notation must be rejected unless a separately declared, unambiguous parser is approved; never infer hemisphere or units. Selection must identify source-order waypoint/leg explicitly, and the user must confirm the forward direction. Never use nearest point/leg logic to select an operation. The domain layer calculates an immutable TransformationPreview/Candidate showing the supplied position, selected waypoint or leg endpoints, mode, resulting ordered point sequence, chosen new-connection geometry, candidate join point if any, geometry/loss implications, advisory distances, and warnings. A separate affirmative confirmation is required before constructing an accepted TransformedRoute. The domain defines and validates the confirmed-command contract but owns no buttons, dialogs, Shortcut screens, or CLI presentation. IP-5 defines transport and binds confirmation to the exact preview/options so stale or mismatched confirmation cannot authorize another transform. IP-7 displays the preview and obtains explicit confirmation/cancellation, then passes the selected command through the approved IP-5 contract; it does not compute or silently alter geometry. Revisions/tokens are proposed transient contract concepts, not automatically persistent identifiers or cryptographic security mechanisms. Cancellation or rejection produces no accepted transformation.

#### Direct to Next WP

Create a synthetic start point at the exact validated user-entered coordinate. Add an explicitly selected new connection from it to the selected next source waypoint; append that waypoint and every subsequent source waypoint in source order. The user must explicitly select a qualified connection geometry (Great Circle / Orthodrome or Rhumb Line / Loxodrome); there is no default or fallback. Show the choice in preview and bind it to confirmation. Never inherit the replaced source incoming leg’s geometry silently. The source incoming leg at the chosen next waypoint is superseded for this output because its original origin is omitted; retain it only as provenance/loss information. Later source legs remain associated with their original destinations. If the current position equals the selected waypoint, preserve both provenance-distinct points and issue a zero-length connection warning; do not silently deduplicate. A last-waypoint selection remains a valid neutral transformation (synthetic start plus source waypoint), with a zero-length warning if coincident and an insufficient-output advisory; IP-4/IP-6 decide separately whether export/consumer acceptance is appropriate.

#### Join Selected Route Leg

Require explicit selection of one adjacent original forward leg and explicit selection of qualified join-connection geometry (Great Circle / Orthodrome or Rhumb Line / Loxodrome) from current position to the proposed join point. This connector choice is separate from the original selected leg geometry used to compute the join point. There is no default or automatic fallback. A candidate is computed only on the selected finite leg. For an interior candidate and supported geometry, create current-position point, then a synthetic join point, then the original destination and subsequent source points; apply the endpoint-specific source-reference reuse sequence below when the candidate is classified at an endpoint. Do not include the original leg origin or any preceding point. Endpoint classification compares the candidate with the original selected-leg endpoints under an independently qualified numerical/identity contract; its tolerance remains provisional until that qualification. If it coincides with the origin endpoint, reuse that original source waypoint reference and exact source coordinate, and produce current-position point → original origin waypoint → original destination waypoint and remainder. The connector terminates at the original-origin coordinate; the original source leg from origin to destination remains unchanged, with its original incoming-leg provenance. If it coincides with the destination endpoint, reuse that original destination reference and exact source coordinate, and produce current-position point → original destination waypoint and remainder; the selected source leg is superseded/omitted and only its provenance/loss record remains, with no zero-length remainder leg. The preview must disclose endpoint classification and any nonzero candidate-to-endpoint residual accepted by the numerical contract; if that residual is outside the eventual approved contract, refuse rather than snap. Do not create a synthetic join point and then remove it by coordinate deduplication. Do not merge distinct source waypoint identities even when coordinates match. The synthetic current-position point remains distinct when coordinate-equal to any source waypoint. Preserve source ordering and show the endpoint identity/case in the preview. The newly introduced current-position-to-join connection is a new leg. For an interior join, the join-to-destination remainder is a shortened source-leg subsegment, preserving source order and qualified geometry only when the subsegment semantics are validated; mark the omitted source-origin-to-join portion and metadata applicability in the loss inventory. At the origin endpoint, the complete original source leg remains unchanged after the new connector; at the destination endpoint, the original selected leg is superseded/omitted. Do not copy original whole-leg radius/XTD/instructions onto the new connector or claim that those constraints remain valid after splitting. Never coordinate-deduplicate distinct source point identities.

If robust finite-leg projection cannot be qualified for a source leg type or edge case, refuse that join request with JOIN_GEOMETRY_UNAVAILABLE and leave the other modes available. Do not substitute direct-to-WP or another leg. A refusal/defer policy for a geometry subtype is not a route choice; any broader mode/scope change requires architectural review.

## 6. Advisory geodesy contract

The Master Plan convention is retained unchanged: WGS84 latitude/longitude are interpreted on the approved authalic sphere, radius R = 6,371,007.1809 m; 1 NM = exactly 1,852 m; Loxodrome means spherical rhumb and Orthodrome means spherical great-circle. Stage 1 must independently review vector values and tolerances before execution. IP-1 example values are sanity checks only until recomputed and approved as test oracles. No claim of ECDIS geometry equivalence.

- Input/output coordinates remain decimal degrees at the precision supplied by the validated model/user input. Calculations convert to radians; never round or normalize stored coordinates.
- Calculation-only longitude differences use the shortest signed delta across the antimeridian, with an explicit reviewed tie policy for an exact 180-degree difference. If the source direction/dialect does not resolve the rhumb tie, that leg’s rhumb distance is unavailable rather than guessed.
- Great-circle distance uses the shortest spherical central angle and is direction-independent. Near-antipodal distance may be reportable while a unique directed arc/projection is not.
- Rhumb calculations use constant-bearing spherical semantics. Exact-pole endpoints are singular/unavailable unless a qualified convention establishes otherwise. Near-pole and near-zero cases need stable formulas and separately reviewed tolerances; do not silently clamp.
- Coincident endpoints produce a zero distance and warning where relevant. Very short distances must avoid catastrophic cancellation. Long ocean and antimeridian paths use stable angle/delta calculations. Numerical failure yields an unavailable diagnostic, never a fabricated value.
- Only qualified geometry computes a geometry-specific per-leg distance. Missing/UnknownLiteral/unsupported geometry yields unavailable. Synthetic connectors use only their explicitly selected qualified geometry. Retained subsegments are measured only when subsegment semantics qualify.
- Report each leg separately. A total is available only when every included leg has a valid distance; otherwise report total unavailable (no unlabeled partial sum). Sum at full working precision using a compensated or equivalently accurate summation method. Convert metres to nautical miles with the fixed divisor; rounding occurs only for display. Display precision and warning thresholds are Stage 1 decisions, not transformation inputs.
- Distance calculations are read-only diagnostics. They cannot select a mode, waypoint, leg, join point, geometry, or alter any coordinate/leg.

## 7. Join-leg mathematics: proposal and qualification gate

A join candidate is a mathematical proposal on the explicitly selected finite leg, not an accepted transformation. Candidate generation, validity checks, display, user confirmation, and immutable route construction are separate phases. No endpoint clamping is allowed as a fallback for an out-of-segment projection: the user gets a clear refusal or an explicitly computed endpoint candidate only where it is mathematically the valid finite-leg minimum and distinctly displayed.

### Orthodrome candidate

Proposed spherical method for a qualified nondegenerate minor great-circle segment with unit endpoint vectors a,b and current-position unit vector p:

1. Form the great-circle normal from a×b. If endpoints coincide within reviewed numerical tolerance or are antipodal/near-antipodal such that a unique directed minor arc cannot be qualified, refuse as DEGENERATE_SELECTED_LEG.
2. Project p onto the great-circle plane using p − (p·n)n, normalize the candidate and its antipode, then retain only candidates lying on the finite forward minor arc from a to b. Along-track position is checked against the selected arc angle with reviewed tolerance.
3. If projection is undefined (projected norm too small), no unique in-plane foot exists; refuse. If no projected candidate is on the finite segment, do not clamp to an endpoint; refuse with JOIN_PROJECTION_OUTSIDE_SEGMENT. If more than one distinct valid global candidate remains within tolerance, refuse as AMBIGUOUS_JOIN_CANDIDATE.
4. Show candidate, forward direction, along-leg placement, and current-to-join/join-to-destination advisory distances. Require explicit confirmation. Geometry of the source remainder stays Orthodrome only if validated as a subarc; the current-to-join leg is the separately selected connector geometry.

This is a proposed contract, not yet an independently verified implementation recipe. IP-3E must compare against independently reviewed spherical-vector or GeographicLib sphere-configured references, establish degeneracy and tolerance bounds, and obtain architectural review before accepting it.

### Loxodrome candidate

**G3-006 product mathematical principle approved; algorithm qualification remains required.** For a qualified Loxodrome source leg, define the join point by minimizing spherical geodesic distance from the manually entered current position to points on the finite selected rhumb segment, including both endpoints, using the approved spherical Earth model. Flat Mercator Euclidean distance is not the optimization metric. This does not qualify a parameterization, minimizer, tolerance, tie rule or supported domain. IP-3E must independently qualify global-minimum/root completeness, endpoints, multiple/equal minima, antimeridian crossings, high latitudes, polar limits, degenerate legs and numerical conditioning before implementation. Unsupported or unqualified cases fail closed; never switch legs or geometry automatically.

The approved metric is not an implementation PASS: IP-3E must derive and qualify a bounded reproducible global minimizer for the finite segment. Exact poles, unresolved 180-degree longitude ties, ill-conditioned roots, multiple unresolved minima, degenerate legs, or inability to establish global root completeness result in JOIN_GEOMETRY_UNAVAILABLE / AMBIGUOUS_JOIN_CANDIDATE. Do not substitute Mercator-plane projection, another metric, another leg, or a different connector geometry. Failure to qualify blocks the affected Join case.

### Endpoint, direction, and distance behavior

The selected leg is always source-forward from its lower ordinal to higher ordinal. A candidate must lie on that finite segment, not its infinite supporting line. No reverse-direction candidate is accepted. Endpoint candidates are classified against source endpoint identities using a numerical tolerance that remains provisional until independent qualification. Reuse the matching original source waypoint reference when the candidate is classified as coincident with that endpoint; never create/remove a synthetic join point by coordinate deduplication, and never merge distinct source waypoint identities merely because their coordinates match. The user-supplied current-position point remains distinct even if coordinate-equal to a source waypoint. Distances to join and from join to destination are advisory, use the applicable qualified geometry, and are unavailable if geometry is not qualified. Geometric closeness never validates navigation safety.

## 8. Confirmation, diagnostics, and privacy

### Preview/confirmation

Every Current Position preview must show the user-selected new connector geometry using both labels (Great Circle / Orthodrome or Rhumb Line / Loxodrome), and, for Join, distinguish it from the source selected-leg geometry. It must also show:

- Selected mode and connector geometry.
- User-supplied latitude/longitude (visible only in the active UI flow).
- Explicit next waypoint or selected leg endpoint names/ordinals and forward direction.
- Candidate join location/position on the selected leg, when applicable, and its endpoint/interior status.
- Resulting ordered waypoint list with original/synthetic provenance.
- New, retained, shortened, superseded, or excluded legs and relevant metadata loss.
- Advisory distances with method/units, including “unavailable” reasons.
- A statement that the join is geometric only and is not a safe-navigation recommendation.

The domain produces the immutable preview/candidate and validates an explicit confirmed command against current exact inputs and preview revision/options; any changed selection/input, connector geometry, or effective GPX route name invalidates the command. The optional export-only route name is preview metadata separate from RouteDocument and source names. A name change never modifies source data, waypoint names, coordinates, order or geometry. IP-5 owns transport and binding against stale/mismatched confirmation. IP-7 displays the preview and obtains confirmation or cancellation, then sends the command through the IP-5 contract; UI controls are outside IP-3. Cancel/reject produces no accepted TransformedRoute. Revisions/tokens are conceptual transient bindings, not assumed persistent IDs or cryptographic security. Keep only minimal in-memory state; do not persist a voyage audit log, coordinates, or full route-derived hashes unless separately reviewed and approved.

### Stable diagnostic proposal

Blocking errors: INVALID_WAYPOINT_SELECTION, AMBIGUOUS_WAYPOINT_REFERENCE, INVALID_CURRENT_POSITION, MISSING_SELECTED_LEG, INVALID_FORWARD_DIRECTION, UNSUPPORTED_OR_UNQUALIFIED_GEOMETRY, JOIN_GEOMETRY_UNAVAILABLE, JOIN_PROJECTION_OUTSIDE_SEGMENT, DEGENERATE_SELECTED_LEG, AMBIGUOUS_JOIN_CANDIDATE, CONFIRMATION_REQUIRED, or PREVIEW_STALE. Advisory warnings include INSUFFICIENT_OUTPUT_POINTS (valid one-point result; IP-4 exports under G3-004 after explicit warning confirmation), ZERO_LENGTH_CONNECTION, SOURCE_LEG_SUPERSEDED, SOURCE_LEG_PORTIONED, METADATA_NOT_CARRIED, DISTANCE_UNAVAILABLE, ANTIPODAL_DIRECTION_AMBIGUITY, and PRECISION_LIMIT. A confirmed command with no matching current preview is a blocking confirmation error. Final names/codes must be reconciled with IP-2/IP-5/IP-7 before freeze.

Diagnostics are deterministic, bounded, and privacy-safe. Default logs and CLI/Shortcut error text contain stable code and safe explanation, not coordinates, source XML, full paths, route/waypoint labels, or hashes. The interactive preview may show the user’s own values because the user needs them to confirm. Do not echo malformed input verbatim.

## 9. IP-4 handoff and loss inventory

The neutral handoff contains ordered transformed points, names/provenance, explicit transformed leg lineage/geometry availability, mode and confirmed choices, advisory distance results, warnings, and a bounded metadata-loss inventory. IP-4 owns GPX 1.1 serialization and exact GPX extension/name mapping. The effective GPX route name is a separately confirmed export value: valid source route name by default, explicit user override, or explicit omission; it never mutates the source route name or RouteDocument and is not derived from the output filename. IP-3 must not serialize GPX or assume core GPX preserves RTZ leg geometry, turn radius, XTD, speed, schedule, wheel-over, or navigation instructions.

Loss inventory distinguishes: excluded source points; excluded incoming legs; replaced/superseded incoming leg; omitted portion of a split source leg; source metadata retained only for explanation; unknown/unsupported metadata; and newly created connector lacking source RTZ navigation constraints. Identify each affected item through scoped source references, not raw XML. Explain that route-point order survives in the neutral model, while downstream Windy rendering/interpretation requires IP-6 empirical verification.

## 10. Error and edge-case policy

| Condition | Planned behavior |
|---|---|
| Name duplicate/nonsequential or absent ID | Selection remains ordinal + document-scoped identity; show disambiguating ordinal/context. Never choose by name alone. |
| Stale/foreign waypoint or leg reference | Blocking error; require re-selection against current validated document. |
| Invalid/nonfinite/out-of-range coordinate | Blocking error before transformation; no clamping, wraparound, or default. |
| Last waypoint in From Waypoint | Produce a valid one-point neutral transformation; G3-004 allows GPX export with no-navigable-leg warning and explicit confirmation. IP-6 compatibility is tested separately. |
| Current position identical to next WP | Preserve synthetic/source provenance; warn zero-length; explicit confirmation required. |
| Unknown or missing geometry | Preserve as unavailable metadata; no calculation/projection/default. |
| Geometry literal not qualified or prohibited by schema | Fail closed at parser boundary; no transform. |
| Source geometry cannot be safely split | Refuse join; do not replace with another mode or geometry. |
| Current point projection outside finite leg | Controlled refusal; no endpoint clamp. |
| Multiple equal/near-equal minima or ill-conditioned result | Controlled ambiguity refusal; present no automatically selected candidate. |
| User rejects preview/cancels | No accepted transformed route; no output handoff. |
| Any option/input changes after preview | Invalidate confirmation and recalculate preview. |
| One-point neutral transformation | Valid transformation with INSUFFICIENT_OUTPUT_POINTS advisory; G3-004 approves export with warning and explicit confirmation. IP-6 separately qualifies Windy compatibility. |
| Two provenance-distinct points at identical coordinates | Preserve both in order with ZERO_LENGTH_CONNECTION; never silently deduplicate. |
| Numerical calculation unavailable | Keep transformation only if calculation is advisory and not required for selected operation; clearly mark distance unavailable. Join calculation failure blocks that join mode. |

Neutral transformation validity, GPX export policy and Windy compatibility are distinct. G3-004 approves one-point GPX export with warning and explicit confirmation; IP-4 implements that policy and IP-6 empirically reports the one-point consumer outcome separately. Two identical-coordinate, provenance-distinct points remain ordered and receive a zero-length warning.

## 11. Synthetic verification and independent oracles (future execution only)

No test or fixture is created in this task. Authorized implementation should use IP-1 sanitized synthetic cases and IP-2 immutable model invariants. Include cases for all modes and variants; first/middle/last selection including a valid one-point neutral transformation plus warning; duplicate names and nonsequential IDs; qualified/missing/unknown geometry; source order and unchanged coordinates; endpoint/interior joins with origin/destination source-reference reuse; candidate tolerance boundaries; distinct source waypoints with equal coordinates (not merged); current-position/source-waypoint coincidence (distinct provenance); equator, antimeridian and high latitudes; coincident, near-antipodal and antipodal endpoints; exact/near poles; outside-segment projection; multiple minima; candidate metric comparisons for rhumb joining before approval; confirmation rejection/stale/mismatched command; unavailable distances; deterministic repeat runs; and proof that advisory results never alter route output.

Oracle provenance: IP-1’s listed example values are preliminary sanity checks, not expected test outputs. During IP-1 execution independently recompute each accepted distance vector from the Master Plan formula and convention; document method, precision, independent reference/tool/configuration, units, reproducible derivation, conditioning, and separately reviewed tolerance. Only after the join metric is explicitly approved may IP-3E qualify join calculations against a separate reviewed reference implementation/configuration (for example GeographicLib configured to a sphere where its model applies), hand-derived simple vectors, and adversarial edge cases. GeographicLib documentation notes spherical antipodal non-uniqueness and rhumb pole singularity; these support cautious refusal cases but do not validate the proposed finite-arc/global-minimum algorithm or settle the closest-point metric. Stage 1/IP-3E must qualify method and tolerances. Never copy illustrative IP-1 tolerances without recomputation/review.

Future tests must verify byte/value immutability of the source model before/after transform, preserved source ordering, exact untouched source coordinates, explicit synthetic provenance, no implicit selection, and deterministic diagnostics. Tests are evidence only after authorized execution and review.

## 12. Future IP-3 implementation sub-stages

Suggested decomposition retained as IP-3A–IP-3F. Every sub-stage below is a future plan outline; detailed file-by-file plans, probes, tests, and execution are gated on separate authorization. Proposed files are conceptual and must reconcile with the repository language/layout after IP-1/IP-2 execution. No stage may be marked PASS without recorded evidence and review.

### IP-3A — Transformation contracts and selection semantics

- **Objective:** Freeze neutral immutable transformation types, stable references, leg lineage, mode semantics, diagnostic/privacy contract.
- **Scope:** Contract and cross-stage issue review only; no GPX/UI/parser.
- **Proposed files:** route-transform model/API module; contract documentation; focused model tests.
- **Dependencies:** IP-1 qualified field matrix; IP-2 executed model/API evidence; Gate 3/Gate 4 authorization.
- **Sequence:** reconcile exact upstream types → resolve open identity, neutral-result/exportability boundary, and metadata questions → define immutable types → map IP-4/IP-5/IP-7 consumers → review privacy and compatibility.
- **Evidence/acceptance:** signed-off contract maps every source/synthetic point and unchanged/new/shortened leg; no raw XML; no mutation; stable references disambiguate duplicate labels; no conflict with IP-2.
- **Risks:** upstream model shape changes; accidental privacy exposure; overfrozen provisional details.
- **Rollback/PASS:** revert only IP-3A-owned changes if contract review fails; PASS only after contract and cross-stage review approvals.

### IP-3B — Full Route and From Waypoint

- **Objective:** Deterministic source-order subset transforms.
- **Scope:** Full and suffix routes; no current-position math, GPX, or UI.
- **Proposed files:** transformation service module and synthetic unit tests.
- **Dependencies:** IP-3A PASS; IP-2 source model.
- **Sequence:** validate scoped reference → construct ordered point/leg lineage → calculate no distances in this substage unless IP-3C is present → attach INSUFFICIENT_OUTPUT_POINTS advisory to one-point results without invalidating the neutral transform → produce loss summary.
- **Evidence/acceptance:** first/middle/final behavior as approved; no reordering/mutation; final-waypoint suffix remains a valid one-point neutral transform with advisory; deterministic warnings.
- **Risks:** ID/order confusion; downstream GPX/Windy handling of one-point routes remains unqualified.
- **Rollback/PASS:** revert substage-owned transform code/tests; PASS on reviewed synthetic matrix and immutability evidence.

### IP-3C — Advisory geodesic engine

- **Objective:** Implement qualified spherical Orthodrome/Loxodrome per-leg estimates and totals.
- **Scope:** Advisory diagnostics only; no selection/transformation based on values.
- **Proposed files:** geodesy module, synthetic oracle tests, calculation-method note.
- **Dependencies:** IP-1 independent oracle/tolerance PASS; IP-3A semantics; qualified IP-2 geometry.
- **Sequence:** implement stable angle/rhumb formula → compare each oracle → cover singularities/conditioning → add accurate summation and formatting boundary → prove output transform independence.
- **Evidence/acceptance:** reviewed per-leg and total vectors/tolerances pass; unavailable cases explicit; constants correct; calculations cannot mutate route.
- **Risks:** pole and antipodal conditioning; misleading display precision.
- **Rollback/PASS:** disable/revert geodesy module without changing route modes; PASS only after independent oracle review.

### IP-3D — Current Position / Direct to Next WP

- **Objective:** Add explicit synthetic current start and user-selected direct connection.
- **Scope:** Current Position entry model/transform, no route-leg projection.
- **Proposed files:** current-position transformation module and synthetic tests.
- **Dependencies:** IP-3A/B PASS; IP-3C for advisory values; IP-5/IP-7 contracts reviewed.
- **Sequence:** validate input and explicit next waypoint → require explicit qualified connector geometry → domain builds immutable candidate → IP-5 transports exact selection/confirmation binding → IP-7 displays and collects confirmation → domain validates the command and constructs ordered transform/loss inventory.
- **Evidence/acceptance:** no auto-selected next WP; direct leg does not inherit replaced geometry; exact coordinate/provenance; rejected/stale confirmation yields no accepted result.
- **Risks:** coordinate-format ambiguity; accidental UI confirmation bypass.
- **Rollback/PASS:** feature-gate/revert Current Direct independently; PASS on explicit-selection, validation, confirmation and privacy tests.

### IP-3E — Join Selected Route Leg

- **Objective:** Qualify and implement confirmed projection onto explicitly selected finite leg.
- **Scope:** Candidate algorithms and accepted join transform only for geometry types that pass qualification.
- **Proposed files:** join geometry module, reviewed method note, synthetic/adversarial tests.
- **Dependencies:** IP-1 geometry qualification/oracles; IP-3A/B/C/D contracts; explicit architectural approval of the closest-point metric before minimizer qualification, then approval of algorithm/tolerances.
- **Sequence:** enumerate and compare candidate Loxodrome “closest point” metrics and implications → obtain explicit architectural metric approval → only then research/derive the selected metric’s global finite-segment algorithm → review bounds and compare independent references → approve tolerances → implement candidate-only API → verify edge matrix → integrate confirmation → construct split-leg provenance.
- **Evidence/acceptance:** unique finite-leg candidate or explicit refusal; no fallback/clamp/alternate selection; both geometry types individually qualified or explicitly unavailable; split semantics and connector metadata-loss clear.
- **Risks:** loxodrome global minimization/root completeness; near antipodal GC ambiguity; overconfident tolerance.
- **Rollback/PASS:** disable/refuse join by geometry type without affecting other modes; PASS only with mathematical review and adversarial oracle evidence. If research cannot bound reliability, remain BLOCKED and request architectural decision.

### IP-3F — Confirmation, diagnostics, and IP-4 handoff

- **Objective:** Freeze the domain candidate/confirmed-command contract, finalized transform result, privacy-safe diagnostics, and loss/provenance handoff.
- **Scope:** Domain validation and neutral handoff only; IP-5 owns CLI transport/binding; IP-7 owns preview presentation and collecting confirmation; IP-4 serialization remains separate.
- **Proposed files:** transformation handoff/diagnostics module, contract tests, documentation; no UI controls in this substage.
- **Dependencies:** IP-3A–E applicable PASS; IP-4/IP-5/IP-7 interface review.
- **Sequence:** reconcile types and codes → domain produces immutable preview/candidate → IP-5 binds exact input/options/revision in transport → IP-7 displays and returns confirm/cancel → domain rejects stale/mismatched confirmation or finalizes → assemble loss/advisory summaries → verify privacy and consumer contracts.
- **Evidence/acceptance:** IP-4 can explain all point/leg origins and losses; IP-5 transport cannot authorize altered choices; IP-7 cannot compute/alter geometry; domain enforces revision/input match; no coordinates/path/hash in defaults; no raw XML; no GPX serialization.
- **Risks:** diagnostic drift; presenting candidate as safe/accepted; UI/transport/domain boundary confusion; treating a revision token as persistent or cryptographic security.
- **Rollback/PASS:** revert handoff-only layer; PASS after downstream interface reviews and synthetic stale/mismatched/cancel/confirm tests.

## 13. Cross-stage dependency and freeze matrix

| Contract | Needed by IP-3 | State | Freeze evidence/owner |
|---|---|---|---|
| RTZ version/schema/geometry literal qualification | Distance and join use | Unresolved execution evidence | IP-1A schema/field matrix and qualification review |
| Independent advisory-distance vectors/tolerances | IP-3C | Unresolved | IP-1B recalculation/reviewer record |
| Immutable source order, identities, incoming-leg model | IP-3A/B | Planned, not executed | IP-2 execution and model invariants |
| Duplicate/missing ID handling and stable reference | IP-3A/B | Provisional | IP-2 qualified dialect rules plus architectural review |
| Spherical finite Orthodrome projection | IP-3E | Proposed, unqualified | Independent derivation/oracle + review |
| Spherical rhumb global minimum and root completeness | IP-3E | Unresolved hard gate | Research, bounded method, adversarial oracle + explicit approval |
| One-point neutral transformation vs GPX exportability | IP-3B, IP-4, IP-6, IP-7 | G3-004 policy resolved: allow with warning and explicit confirmation; consumer compatibility remains unqualified | IP-4 serialization, IP-7 confirmation, separate IP-6 one-point observation |
| Join endpoint identity/tolerance | IP-3E | Source-reference reuse contract proposed; tolerance provisional | Independent numerical qualification; never merge distinct source IDs |
| Confirmation domain/transport/UI isolation | IP-3D/F, IP-5, IP-7 | Proposed boundary, not frozen | Cross-stage contract review and stale/mismatch verification |
| Loxodrome closest-point metric | IP-3E | G3-006 mathematical objective approved; algorithm unqualified | Minimize spherical geodesic distance over finite selected rhumb segment; qualify parameterization, global minimum, tolerances and fail-closed domain |
| Split-leg radius/XTD/instruction disposition | IP-3E/F, IP-4 | Unresolved by field | IP-1 field matrix and IP-4 loss mapping review |
| Neutral TransformedRoute → GPX 1.1 mapping | IP-4 | Future/provisional | IP-4 plan and cross-stage review |
| CLI mode/selection/confirmation diagnostics | IP-5 | Future/provisional | IP-5 plan/interface review |
| Preview and explicit confirmation | IP-7 | Future/provisional | IP-7 plan and end-to-end review |
| Windy rendering/import interpretation | IP-6 indirect | Unverified | IP-6 empirical synthetic acceptance |

No row is represented as implemented, tested, or upstream PASS. IP-3 can consume only qualified upstream contracts. Changes required in IP-1/IP-2 must be raised as cross-stage findings, not silently made here.

## 14. IP-3 acceptance and execution gate

### Planning acceptance

- All three modes and both Current Position variants are specified.
- No implicit navigational choice or silent geometry fallback exists.
- Join math is finite-leg constrained; G3-006 selects the spherical geodesic distance objective for a rhumb segment. Numerical minimizer qualification, independent oracles, tolerances and supported cases remain required; no implementation PASS is implied.
- Immutable neutral output, provenance, endpoint identity rules, incoming-leg ownership, split/discard semantics, losses, diagnostics and separated domain/transport/UI confirmation boundaries are defined.
- One-point neutral transformations remain valid with an advisory warning; exportability and Windy compatibility remain IP-4/IP-6 decisions.
- Advisory distance conventions match the Master Plan and await Stage 1’s independent vectors.
- Synthetic test matrix, oracle provenance/tolerance requirements, cross-stage dependencies, risks, and acceptance criteria are recorded.
- No conflict with Master Plan or approved IP-1/IP-2; unresolved contracts remain visible.

### Future execution PASS

Only after Gate 3 acceptance and explicit Gate 4 authorization: all approved modes implemented; authorized synthetic tests pass; independent distance and join oracles are verified; preview confirmation is enforced; source route is immutable; diagnostics are privacy-safe; IP-4 handoff is validated; no unapproved navigation choices are made; and independent review accepts evidence. An unqualified join geometry remains unavailable/blocked and cannot be marked supported. No execution PASS is claimed in this plan.

## 15. Risks and open architectural decisions

1. **Rhumb closest-point metric:** G3-006 chooses the product mathematical objective (minimum spherical geodesic distance to the finite selected rhumb segment). The parameterization, bounded global minimizer, edge-domain and tolerances remain unqualified and block implementation of affected join cases until evidenced.
2. **Rhumb projection reliability:** after a metric is approved, can a bounded deterministic global minimizer enumerate all stationary points and establish a unique finite-leg minimum across the qualified domain? If not, IP-3E blocks for review; no local-optimizer guess.
3. **Finite great-circle projection conditioning:** exact/near antipodal and nearly coincident endpoints do not define a robust unique directed minor arc. IP-3E must set independently reviewed thresholds or refuse a conservative domain.
4. **Waypoint identity:** confirm qualified dialect ID uniqueness/presence; ordinal is always needed as source-order disambiguator. No source digest is introduced.
5. **Neutral result/exportability:** G3-004 permits one-point export with warning and explicit confirmation; IP-6 consumer behavior remains separately qualified.
6. **Join endpoint tolerance:** qualify numerical coincidence independently; never merge different source waypoint references based on coordinate equality.
7. **Split metadata:** determine field-by-field whether incoming radius/XTD/speed/schedule and other attributes remain meaningful on a retained subsegment; until then report uncertain/not carried and do not clone onto connector.
8. **Tolerance/display:** Stage 1 independently approves numeric tolerances, display precision, and warnings. They must not influence route selection.
9. **Confirmation boundary:** IP-3 domain candidate and confirmed-command validation, IP-5 exact transport binding, and IP-7 presentation/consent must be cross-reviewed; tokens are not presumed durable or cryptographic. No coordinates/hashes in default logs or persistent state.

## 16. Sources and research boundary

- Approved project sources: `docs/RTZ-GPX-PLAN.md`, `docs/implementation/IP-1-STANDARDS-FIXTURES-INTEGRATION-PLAN.md`, and `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` at the baselines listed above.
- GeographicLib, *Geodesics on a sphere*: https://geographiclib.sourceforge.io/html/python/geodesics.html — documents spherical geodesic behavior, including antipodal non-uniqueness; reference for research, not a qualified IP-3 oracle.
- GeographicLib, *RhumbSolve*: https://geographiclib.sourceforge.io/html/RhumbSolve.1.html — describes constant-bearing rhumbs and pole singularity behavior; reference for research, not proof of the proposed global finite-leg minimizer.

The external references guide research only. Exact application semantics, model configuration, tolerances, supported domains, and test oracle provenance must be established and reviewed during authorized IP-1/IP-3 execution.
