# IP-3 — Route Modes and Geometry: Detailed Implementation Plan

**Plan status:** Submitted for architectural review (Gate 2).

**IP-3 execution:** NOT AUTHORIZED.

**Overall implementation:** NOT AUTHORIZED.
**Planning baseline:** Gate 1 `d57d0935c7885eb25eb14542e7996839644e96e2`; IP-1 `6ed649d3995f70fa2421e08cb027c07d19b4cad4`; corrected IP-2 `8011d3f0c4baf62cb15194ab9308f4e312269615`.

This plan defines the transformation boundary from IP-2’s immutable validated route model to the GPX handoff consumed by IP-4. It creates no GPX and does not alter the source RTZ or IP-2 RouteDocument. The approved Master Plan and upstream plans remain authoritative. Proposals marked provisional or unresolved require evidence/review before their implementation sub-stage is authorized.

## 1. Scope and boundaries

IP-3 plans three user-selected modes: Full Route, From Waypoint, and From Current Position. Current Position has two explicitly selected variants: Direct to Next WP and Join Selected Route Leg. It produces a format-neutral immutable TransformedRoute, diagnostics, advisory distances, and a metadata-loss/provenance summary for IP-4/IP-5/IP-7.

IP-3 does not parse XML, qualify schemas, serialize GPX, render a map, optimize or repair a route, select a waypoint/leg automatically, perform safety or hazard analysis, infer a geometry type, or claim ECDIS equivalence. It does not alter IP-2’s model contract: any required addition is a cross-stage issue for review. RTZP remains outside V1. No implementation, probes, fixtures, tests, scripts, dependencies, or product artifacts are authorized by this planning task.

## 2. Upstream contract and status

| Input | Required contract/evidence | Status at this planning baseline |
|---|---|---|
| Master Plan | Modes; offline scope; geometry and distance convention; non-navigation boundary | Approved. Distance convention is advisory only. |
| IP-1 | Qualified exact RTZ dialect/schema/field matrix; geometry literal semantics; synthetic fixtures; independently reviewed distance oracles and tolerances | Plan approved for Gate 3 cross-check; execution evidence is pending. Do not infer a dialect or literal is qualified. |
| IP-2 | Immutable ordered RouteDocument; point identities/coordinates/names; incoming leg ownership; qualified geometry or uninterpreted UnknownLiteral; safe diagnostics | Plan approved for Gate 3 cross-check; execution evidence is pending. |
| IP-4 | GPX 1.1 mapping and loss-report consumer contract | Future plan; not frozen. |
| IP-5 | Stable CLI mode/selection/confirmation inputs and diagnostic contract | Future plan; not frozen. |
| IP-6 | Windy import acceptance using synthetic routes | Indirect dependency through IP-4 output; no Windy behavior is assumed here. |
| IP-7 | Shortcut preview, explicit confirmation, manual position entry and errors | Future plan; not frozen. |

Planning can establish a proposed interface, but no IP-3 implementation may begin until the complete plan set passes Gate 3 and Gate 4 is explicitly authorized. IP-1/IP-2 plan approval is not evidence that schemas, models, or calculations have been implemented or tested.

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
- JoinCandidate: candidate coordinate, selected source leg, geometry type, bounded calculation status, along-leg parameter, advisory distances, and warnings; candidate state only.
- ConfirmationRecord: explicit confirmation of the displayed preview revision and chosen options; transient, privacy-minimal, not an audit log.
- TransformedPoint: coordinate, optional display name, provenance, and source reference if applicable.
- TransformedLeg: endpoints, geometry availability/type, source-leg relation, transformation relation, advisory-distance result, and metadata disposition.
- TransformedRoute: ordered points/legs, mode, confirmed choice where required, warnings, loss inventory, and advisory summary.
- PointProvenance: OriginalSourcePoint or UserSuppliedCurrentPosition or ComputedJoinPoint.
- GeometryAvailability: Qualified(type), Missing, UnknownLiteral(uninterpreted), or UnsupportedByQualification.
- TransformationWarning / Diagnostic: stable code, severity, bounded safe message; contextual coordinates and identifiers are not logged by default.

Do not carry raw XML, full paths, source payload, or unreviewed extension blobs into this model. Synthetic-point identity is a typed provenance marker in the transformed model, not a fabricated RTZ ID. Any GPX name policy is an IP-4 decision; the transform must retain original names and synthetic identity separately. A UI may label a point “Current position” or “Join point” without changing source metadata.

### 4.3 Leg lineage

A transformed leg must state one of: unchanged source leg; retained subsegment of a source leg; new user-selected connection; or unavailable/unsupported geometry. It also records metadata disposition: retained as source provenance, superseded, portioned/semantics uncertain, or not applicable. Do not clone turn radius, XTD, speed, schedule, wheel-over, or other source instructions onto a newly created connection. Split-leg metadata applicability is unresolved until IP-1’s field matrix and IP-4’s loss contract are reviewed; preserve it only as provenance for reporting, never imply it describes a newly introduced connection.

## 5. Mode contracts

### 5.1 Full Route

Return every source waypoint in exact source order with original coordinates and available names. Preserve each qualified incoming-leg reference for downstream advisory/loss handling. No synthetic points or new legs. An unavailable/unknown geometry makes that leg’s geometry-specific distance unavailable, but does not by itself change the route. If the route has fewer than two usable points, refuse GPX handoff with INSUFFICIENT_OUTPUT_POINTS; do not invent points. Route length is separate advisory information and never changes the point sequence.

### 5.2 From Waypoint

Require explicit selection by SourceWaypointRef. Include the selected point and every subsequent source point in order; exclude preceding points; never reverse. Selecting the first point yields the same point sequence as Full Route. Selecting the final point yields one point and therefore a controlled INSUFFICIENT_OUTPUT_POINTS refusal under the V1 two-point minimum; do not emit a one-point route or fabricate a connector. If the source route itself has fewer than two points, the same refusal applies. The selected first point has no included incoming leg from its preceding source point; record that preceding incoming segment as excluded/discarded in the loss summary when one exists. Subsequent original incoming legs retain their source relationship.

### 5.3 Current Position — shared selection

Require separately entered WGS84 latitude and longitude in decimal degrees, finite and within latitude [-90, 90] and longitude [-180, 180], plus an explicit next waypoint and either Direct to Next WP or Join Selected Route Leg. Any other coordinate notation must be rejected unless a separately declared, unambiguous parser is approved; never infer hemisphere or units. Selection must identify source-order waypoint/leg explicitly, and the user must confirm the forward direction. Never use nearest point/leg logic to select an operation. The preview must show the supplied position, selected waypoint or leg endpoints, mode, resulting ordered point sequence, chosen new-connection geometry, candidate join point if any, geometry/loss implications, advisory distances, and warnings. A separate affirmative confirmation of that preview is required before constructing an accepted TransformedRoute. Cancellation or rejection produces no accepted transformation.

#### Direct to Next WP

Create a synthetic start point at the exact validated user-entered coordinate. Add an explicitly selected new connection from it to the selected next source waypoint; append that waypoint and every subsequent source waypoint in source order. The user must explicitly select a qualified connection geometry (Orthodrome or Loxodrome); never inherit the replaced source incoming leg’s geometry silently. The source incoming leg at the chosen next waypoint is superseded for this output because its original origin is omitted; retain it only as provenance/loss information. Later source legs remain associated with their original destinations. If the current position equals the selected waypoint, preserve both provenance-distinct points and issue a zero-length connection warning; do not silently deduplicate. A last-waypoint selection is valid only if the output has at least two points (synthetic start plus waypoint) and passes other validations.

#### Join Selected Route Leg

Require explicit selection of one adjacent original forward leg and explicit selection of qualified join-connection geometry from current position to the proposed join point. A candidate is computed only on the selected finite leg. For supported geometry, create current-position point, then join point, then the original destination and subsequent source points. Do not include the original leg origin or any preceding point. If the candidate is an endpoint, construct a deduplicated sequence by provenance-aware endpoint reuse: at origin, current position → original origin → original destination and remainder; at destination, current position → original destination and remainder. Show the endpoint case explicitly in the preview. The newly introduced current-position-to-join connection is a new leg. The join-to-destination remainder is a shortened source-leg subsegment, preserving source order and qualified geometry only when the subsegment semantics are validated. Mark the original leg’s omitted portion and metadata applicability in the loss inventory. Do not copy original whole-leg radius/XTD/instructions onto the new connector or claim that those constraints remain valid after splitting.

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

Proposed objective: on the qualified spherical rhumb curve r(t), t∈[0,1], find the point or points minimizing authalic-sphere great-circle distance from current position p; equivalently maximize p·r(t). Endpoints are candidates. Interior candidates satisfy p·r′(t)=0. Evaluate all stationary candidates and endpoints, compare using a reviewed numerical tolerance, and accept a join only when a unique global minimum is established. The curve parameterization and shortest signed longitude delta must follow IP-1-qualified rhumb semantics. Exact poles, unresolved 180-degree longitude ties, ill-conditioned roots, unresolved multiple minima, or an inability to bound global root search produce JOIN_GEOMETRY_UNAVAILABLE / AMBIGUOUS_JOIN_CANDIDATE. Never use a local optimizer that silently returns one of multiple possible minima, or a Mercator-plane perpendicular projection as a substitute without architectural approval.

This global-minimum/root-isolation requirement is a hard IP-3E qualification gate. Stage research must independently establish a bounded, reproducible candidate method and compare it against reviewed references over equatorial, antimeridian, high-latitude, endpoint, near-pole, and multi-candidate cases. If it cannot be established, IP-3E remains BLOCKED pending an explicit architectural decision; do not silently downgrade approved product scope, mislabel another calculation, or route around the selected-leg requirement.

### Endpoint, direction, and distance behavior

The selected leg is always source-forward from its lower ordinal to higher ordinal. A candidate must lie on that finite segment, not its infinite supporting line. No reverse-direction candidate is accepted. Endpoint candidates are explicitly identified and sequences are built without duplicate coordinate-only points while retaining the original endpoint provenance. Distances to join and from join to destination are advisory, use the applicable qualified geometry, and are unavailable if geometry is not qualified. Geometric closeness never validates navigation safety.

## 8. Confirmation, diagnostics, and privacy

### Preview/confirmation

The Current Position preview must show:

- Selected mode and connector geometry.
- User-supplied latitude/longitude (visible only in the active UI flow).
- Explicit next waypoint or selected leg endpoint names/ordinals and forward direction.
- Candidate join location/position on the selected leg, when applicable, and its endpoint/interior status.
- Resulting ordered waypoint list with original/synthetic provenance.
- New, retained, shortened, superseded, or excluded legs and relevant metadata loss.
- Advisory distances with method/units, including “unavailable” reasons.
- A statement that the join is geometric only and is not a safe-navigation recommendation.

Require a distinct Confirm action bound to the exact preview revision/options; any changed selection/input invalidates prior confirmation. Cancel/reject produces no accepted TransformedRoute. Confirmation records only the minimum in-memory state needed; do not persist a voyage audit log or coordinates unless separately approved.

### Stable diagnostic proposal

Blocking errors: INVALID_WAYPOINT_SELECTION, AMBIGUOUS_WAYPOINT_REFERENCE, INVALID_CURRENT_POSITION, MISSING_SELECTED_LEG, INVALID_FORWARD_DIRECTION, UNSUPPORTED_OR_UNQUALIFIED_GEOMETRY, JOIN_GEOMETRY_UNAVAILABLE, JOIN_PROJECTION_OUTSIDE_SEGMENT, DEGENERATE_SELECTED_LEG, AMBIGUOUS_JOIN_CANDIDATE, INSUFFICIENT_OUTPUT_POINTS, CONFIRMATION_REQUIRED, or PREVIEW_STALE. Advisory warnings include ZERO_LENGTH_CONNECTION, SOURCE_LEG_SUPERSEDED, SOURCE_LEG_PORTIONED, METADATA_NOT_CARRIED, DISTANCE_UNAVAILABLE, ANTIPODAL_DIRECTION_AMBIGUITY, and PRECISION_LIMIT. Final names/codes must be reconciled with IP-2/IP-5/IP-7 before freeze.

Diagnostics are deterministic, bounded, and privacy-safe. Default logs and CLI/Shortcut error text contain stable code and safe explanation, not coordinates, source XML, full paths, route/waypoint labels, or hashes. The interactive preview may show the user’s own values because the user needs them to confirm. Do not echo malformed input verbatim.

## 9. IP-4 handoff and loss inventory

The neutral handoff contains ordered transformed points, names/provenance, explicit transformed leg lineage/geometry availability, mode and confirmed choices, advisory distance results, warnings, and a bounded metadata-loss inventory. IP-4 owns GPX 1.1 serialization and the exact GPX extension/name mapping. IP-3 must not serialize GPX or assume core GPX preserves RTZ leg geometry, turn radius, XTD, speed, schedule, wheel-over, or navigation instructions.

Loss inventory distinguishes: excluded source points; excluded incoming legs; replaced/superseded incoming leg; omitted portion of a split source leg; source metadata retained only for explanation; unknown/unsupported metadata; and newly created connector lacking source RTZ navigation constraints. Identify each affected item through scoped source references, not raw XML. Explain that route-point order survives in the neutral model, while downstream Windy rendering/interpretation requires IP-6 empirical verification.

## 10. Error and edge-case policy

| Condition | Planned behavior |
|---|---|
| Name duplicate/nonsequential or absent ID | Selection remains ordinal + document-scoped identity; show disambiguating ordinal/context. Never choose by name alone. |
| Stale/foreign waypoint or leg reference | Blocking error; require re-selection against current validated document. |
| Invalid/nonfinite/out-of-range coordinate | Blocking error before transformation; no clamping, wraparound, or default. |
| Last waypoint in From Waypoint | Refuse due to one output point; no synthetic connector. |
| Current position identical to next WP | Preserve synthetic/source provenance; warn zero-length; explicit confirmation required. |
| Unknown or missing geometry | Preserve as unavailable metadata; no calculation/projection/default. |
| Geometry literal not qualified or prohibited by schema | Fail closed at parser boundary; no transform. |
| Source geometry cannot be safely split | Refuse join; do not replace with another mode or geometry. |
| Current point projection outside finite leg | Controlled refusal; no endpoint clamp. |
| Multiple equal/near-equal minima or ill-conditioned result | Controlled ambiguity refusal; present no automatically selected candidate. |
| User rejects preview/cancels | No accepted transformed route; no output handoff. |
| Any option/input changes after preview | Invalidate confirmation and recalculate preview. |
| Fewer than two output points | Blocking INSUFFICIENT_OUTPUT_POINTS; never fabricate a point. Two provenance-distinct points at identical coordinates remain two points and produce a zero-length warning; never silently deduplicate. |
| Numerical calculation unavailable | Keep transformation only if calculation is advisory and not required for selected operation; clearly mark distance unavailable. Join calculation failure blocks that join mode. |

Potential policy tension: the Master Plan says routes reducing to fewer than two points warrant warning; IP-3 proposes that fewer than two output points block GPX handoff, including inherently one-point From Waypoint. This stricter error-versus-warning policy requires architectural review. Two identical-coordinate points still count as two points; they remain in order with a zero-length warning. A zero-length leg is not silently removed.

## 11. Synthetic verification and independent oracles (future execution only)

No test or fixture is created in this task. Authorized implementation should use IP-1 sanitized synthetic cases and IP-2 immutable model invariants. Include cases for all modes and variants; first/middle/last selection; duplicate names and nonsequential IDs; qualified/missing/unknown geometry; source order and unchanged coordinates; endpoint/interior joins; duplicate/current-equals-waypoint; equator, antimeridian and high latitudes; coincident, near-antipodal and antipodal endpoints; exact/near poles; outside-segment projection; multiple minima; confirmation rejection/stale preview; unavailable distances; deterministic repeat runs; and proof that advisory results never alter route output.

Oracle provenance: IP-1’s listed example values are preliminary sanity checks, not expected test outputs. During IP-1 execution independently recompute each accepted distance vector from the Master Plan formula and convention; document method, precision, independent reference/tool/configuration, units, reproducible derivation, conditioning, and separately reviewed tolerance. For join calculations use a separate reviewed reference implementation/configuration (for example GeographicLib configured to a sphere where its model applies), hand-derived simple vectors, and adversarial edge cases. GeographicLib documentation notes spherical antipodal non-uniqueness and rhumb pole singularity; these support cautious refusal cases but do not alone validate this proposed finite-arc/global-minimum algorithm. Stage 1/IP-3E must qualify method and tolerances. Never copy illustrative IP-1 tolerances without recomputation/review.

Future tests must verify byte/value immutability of the source model before/after transform, preserved source ordering, exact untouched source coordinates, explicit synthetic provenance, no implicit selection, and deterministic diagnostics. Tests are evidence only after authorized execution and review.

## 12. Future IP-3 implementation sub-stages

Suggested decomposition retained as IP-3A–IP-3F. Every sub-stage below is a future plan outline; detailed file-by-file plans, probes, tests, and execution are gated on separate authorization. Proposed files are conceptual and must reconcile with the repository language/layout after IP-1/IP-2 execution. No stage may be marked PASS without recorded evidence and review.

### IP-3A — Transformation contracts and selection semantics

- **Objective:** Freeze neutral immutable transformation types, stable references, leg lineage, mode semantics, diagnostic/privacy contract.
- **Scope:** Contract and cross-stage issue review only; no GPX/UI/parser.
- **Proposed files:** route-transform model/API module; contract documentation; focused model tests.
- **Dependencies:** IP-1 qualified field matrix; IP-2 executed model/API evidence; Gate 3/Gate 4 authorization.
- **Sequence:** reconcile exact upstream types → resolve open identity/minimum-point/metadata questions → define immutable types → map IP-4/IP-5/IP-7 consumers → review privacy and compatibility.
- **Evidence/acceptance:** signed-off contract maps every source/synthetic point and unchanged/new/shortened leg; no raw XML; no mutation; stable references disambiguate duplicate labels; no conflict with IP-2.
- **Risks:** upstream model shape changes; accidental privacy exposure; overfrozen provisional details.
- **Rollback/PASS:** revert only IP-3A-owned changes if contract review fails; PASS only after contract and cross-stage review approvals.

### IP-3B — Full Route and From Waypoint

- **Objective:** Deterministic source-order subset transforms.
- **Scope:** Full and suffix routes; no current-position math, GPX, or UI.
- **Proposed files:** transformation service module and synthetic unit tests.
- **Dependencies:** IP-3A PASS; IP-2 source model.
- **Sequence:** validate scoped reference → construct ordered point/leg lineage → calculate no distances in this substage unless IP-3C is present → enforce minimum-point policy → produce loss summary.
- **Evidence/acceptance:** first/middle/final behavior as approved; no reordering/mutation; one-point suffix controlled according to final policy; deterministic warnings.
- **Risks:** ID/order confusion; ambiguous one-point/duplicate-coordinate policy.
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
- **Sequence:** validate input and explicit next waypoint → require explicit qualified connector geometry → build preview payload → require confirmed preview revision → construct ordered transform and loss inventory.
- **Evidence/acceptance:** no auto-selected next WP; direct leg does not inherit replaced geometry; exact coordinate/provenance; rejected/stale confirmation yields no accepted result.
- **Risks:** coordinate-format ambiguity; accidental UI confirmation bypass.
- **Rollback/PASS:** feature-gate/revert Current Direct independently; PASS on explicit-selection, validation, confirmation and privacy tests.

### IP-3E — Join Selected Route Leg

- **Objective:** Qualify and implement confirmed projection onto explicitly selected finite leg.
- **Scope:** Candidate algorithms and accepted join transform only for geometry types that pass qualification.
- **Proposed files:** join geometry module, reviewed method note, synthetic/adversarial tests.
- **Dependencies:** IP-1 geometry qualification/oracles; IP-3A/B/C/D contracts; explicit architectural approval of algorithm/tolerances.
- **Sequence:** independently research and derive candidates → review global/finite-segment behavior and failure bounds → compare independent references → obtain approval → implement candidate-only API → verify edge matrix → integrate explicit confirmation → construct split-leg provenance.
- **Evidence/acceptance:** unique finite-leg candidate or explicit refusal; no fallback/clamp/alternate selection; both geometry types individually qualified or explicitly unavailable; split semantics and connector metadata-loss clear.
- **Risks:** loxodrome global minimization/root completeness; near antipodal GC ambiguity; overconfident tolerance.
- **Rollback/PASS:** disable/refuse join by geometry type without affecting other modes; PASS only with mathematical review and adversarial oracle evidence. If research cannot bound reliability, remain BLOCKED and request architectural decision.

### IP-3F — Confirmation, diagnostics, and IP-4 handoff

- **Objective:** Freeze end-to-end transform result, privacy-safe diagnostics, preview revision binding, loss/provenance contract.
- **Scope:** Neutral handoff only; IP-4 serialization and IP-7 UI remain separate.
- **Proposed files:** handoff/diagnostics module, contract tests, documentation.
- **Dependencies:** IP-3A–E applicable PASS; IP-4/IP-5/IP-7 interface review.
- **Sequence:** reconcile types and codes → bind confirmation to immutable preview inputs → assemble loss/advisory summaries → verify sanitized diagnostics → review consumer contract.
- **Evidence/acceptance:** IP-4 can explain all point/leg origins and losses; IP-5/IP-7 can invoke and display stable errors; no coordinates/path/hash in defaults; no raw XML; no GPX serialization.
- **Risks:** diagnostic drift; presenting candidate as safe/accepted; consumer mismatch.
- **Rollback/PASS:** revert handoff-only layer; PASS after all downstream interface reviews and synthetic contract tests.

## 13. Cross-stage dependency and freeze matrix

| Contract | Needed by IP-3 | State | Freeze evidence/owner |
|---|---|---|---|
| RTZ version/schema/geometry literal qualification | Distance and join use | Unresolved execution evidence | IP-1A schema/field matrix and qualification review |
| Independent advisory-distance vectors/tolerances | IP-3C | Unresolved | IP-1B recalculation/reviewer record |
| Immutable source order, identities, incoming-leg model | IP-3A/B | Planned, not executed | IP-2 execution and model invariants |
| Duplicate/missing ID handling and stable reference | IP-3A/B | Provisional | IP-2 qualified dialect rules plus architectural review |
| Spherical finite Orthodrome projection | IP-3E | Proposed, unqualified | Independent derivation/oracle + review |
| Spherical rhumb global minimum and root completeness | IP-3E | Unresolved hard gate | Research, bounded method, adversarial oracle + explicit approval |
| Two-point and duplicate-coordinate output policy | IP-3B/D/E | Unresolved | Architectural decision before implementation |
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
- Proposed join math is explicit, finite-leg constrained, and gated on independent qualification; unresolved rhumb global-minimum proof blocks that substage rather than allowing a guessed fallback.
- Immutable neutral output, provenance, incoming-leg ownership, split/discard semantics, losses, diagnostics and confirmation boundaries are defined.
- Advisory distance conventions match the Master Plan and await Stage 1’s independent vectors.
- Synthetic test matrix, oracle provenance/tolerance requirements, cross-stage dependencies, risks, and acceptance criteria are recorded.
- No conflict with Master Plan or approved IP-1/IP-2; unresolved contracts remain visible.

### Future execution PASS

Only after Gate 3 and explicit Gate 4 authorization: all approved modes implemented; authorized synthetic tests pass; independent distance and join oracles are verified; preview confirmation is enforced; source route is immutable; diagnostics are privacy-safe; IP-4 handoff is validated; no unapproved navigation choices are made; and independent review accepts evidence. An unqualified join geometry remains unavailable/blocked and cannot be marked supported. No execution PASS is claimed in this plan.

## 15. Risks and open architectural decisions

1. **Rhumb projection reliability:** can a bounded deterministic global minimizer enumerate all stationary points and establish a unique finite-leg minimum across qualified domain? If not, IP-3E blocks for review; no local-optimizer guess.
2. **Finite great-circle projection conditioning:** exact/near antipodal and nearly coincident endpoints do not define a robust unique directed minor arc. IP-3E must set independently reviewed thresholds or refuse a conservative domain.
3. **Waypoint identity:** confirm qualified dialect ID uniqueness/presence; ordinal is always needed as source-order disambiguator. No source digest is introduced.
4. **Minimum output:** confirm whether fewer than two points is a blocking error or warning under the Master Plan. Proposed behavior blocks GPX handoff; two identical coordinates count as two provenance-distinct points and are retained with a zero-length warning.
5. **Split metadata:** determine field-by-field whether incoming radius/XTD/speed/schedule and other attributes remain meaningful on a retained subsegment; until then report uncertain/not carried and do not clone onto connector.
6. **Tolerance/display:** Stage 1 independently approves numeric tolerances, display precision, and warnings. They must not influence route selection.
7. **Confirmation API:** IP-5/IP-7 must bind confirmation to the exact preview revision without persisting route coordinates or exposing secrets in process arguments/logs.

## 16. Sources and research boundary

- Approved project sources: `docs/RTZ-GPX-PLAN.md`, `docs/implementation/IP-1-STANDARDS-FIXTURES-INTEGRATION-PLAN.md`, and `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` at the baselines listed above.
- GeographicLib, *Geodesics on a sphere*: https://geographiclib.sourceforge.io/html/python/geodesics.html — documents spherical geodesic behavior, including antipodal non-uniqueness; reference for research, not a qualified IP-3 oracle.
- GeographicLib, *RhumbSolve*: https://geographiclib.sourceforge.io/html/RhumbSolve.1.html — describes constant-bearing rhumbs and pole singularity behavior; reference for research, not proof of the proposed global finite-leg minimizer.

The external references guide research only. Exact application semantics, model configuration, tolerances, supported domains, and test oracle provenance must be established and reviewed during authorized IP-1/IP-3 execution.
