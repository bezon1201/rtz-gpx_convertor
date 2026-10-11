# IP-6 — Windy Route Planner Empirical Acceptance: Detailed Implementation Plan

**IP-6 PLAN:** APPROVED / READY FOR GATE 3 CROSS-CHECK (R1 conditions closed).

**IP-6 execution:** NOT AUTHORIZED.

**IP-6 consumer acceptance:** NOT TESTED.

**IP-7 planning:** NOT STARTED.

**Overall implementation:** NOT AUTHORIZED.

**Planning branch:** `docs/ip-6-windy-route-planner-acceptance`.
**Planning baseline:** IP-5 R1 `7d24aadcdc0e0b8bf0429e3f639696e9bafa68b7`.

This is a documentation-only plan for future, manually executed, synthetic-data consumer acceptance. No Windy import, browser automation, fixture, test, script, GPX, RTZ, probe, credential, or implementation artifact is created by this plan. Plan approval is not empirical consumer compatibility evidence or an execution PASS. Completing the future IP-6E report is a separate status from passing consumer acceptance (§§13, 15, 17).

## 1. Objective, scope and authority

IP-6 determines whether output produced by the approved converter contract is usable in the intended Windy Route Planner workflow. It evaluates actual consumer behavior after IP-4 serialization and IP-5 delivery; GPX 1.1 schema validity alone is insufficient.

IP-6 owns consumer workflow discovery, controlled synthetic cases, manual import observations, compatibility classification, and an evidence-based verdict. It does not own RTZ parsing, route transformations, GPX serialization, Windy internals, navigation decisions, or product policy. It must not change a GPX route into a track, add points, alter geometry, or weaken an upstream contract to make Windy accept a file. IP-6 evidence can inform Gate 3 decisions but cannot resolve IP-4's one-point or route-name policy.

The converter remains completely offline. Windy is an external online consumer; future Windy testing may require internet access and may transfer synthetic GPX data to Windy. No real route or vessel position may be uploaded. No user route is tested without separate explicit authorization and privacy review.

## 2. Evidence rules and status

Keep these evidence layers separate in every case:

1. **GPX specification compliance:** the file conforms to the qualified GPX 1.1 schema and core document contract.
2. **Converter serialization correctness:** the produced bytes encode the approved route name and exact ordered `rtept` sequence, with no track substitution or fabricated point.
3. **Windy file-import acceptance:** the identified Windy interface accepts or rejects that file.
4. **Windy route-object interpretation:** the imported result is observable as a Route Planner route, track, marker, upload layer, or another object.
5. **Waypoint order and coordinate fidelity:** observable values are compared point-by-point to the expected GPX sequence; a map image alone is not numerical evidence.
6. **Rendered geometry and visible behavior:** map line, point markers, labels, warnings and display-only interpolation are recorded separately from imported route data and semantics-changing automatic routing.
7. **Overall product acceptance:** the intended workflow meets every mandatory criterion under the aggregate rule in §13.

Use only evidence captured during authorized future IP-6 execution. Record unknowns as `UNRESOLVED`, `BLOCKED`, or `INCONCLUSIVE`; do not fill gaps using screenshots, assumptions, a different Windy product, public Uploader behavior, or reverse-engineered/private APIs. Evidence is date-, interface-, browser-, and platform-bounded; a later UI change can invalidate the workflow procedure.

## 3. Exact Windy target and current discovery status

### 3.1 Target product

The intended consumer is **Windy.com**, the browser-based weather map at `https://www.windy.com/`, using its **Distance & Planning / Route Planner** feature. This is not the Windy mobile application, Windy.app, or the generic GPX file Uploader/display layer. The public Windy article describes the Route Planner workflow and says GPX routes can be imported for display on the map; Windy Staff's Route Planner announcement lists GPX import entry points. These sources identify a credible target, but they do not prove current behavior for the converter's exact GPX contract.

### 3.2 Candidate import workflow

The strongest published Route Planner-specific workflow is:

1. Open the Route Planner / `Distance & Planning` interface on Windy.com in a desktop browser.
2. Choose **More options → Import GPX**.
3. Select the authorized synthetic GPX file.
4. Inspect the resulting object inside that Route Planner interface, without publishing or sharing it.

Windy Staff also documented two alternative entry paths: **Menu → Upload KML, GPX or geoJSON file → Upload GPX and open it in Route Planner**, and drag-and-drop onto the Route Planner. IP-6 must choose and qualify one primary entry path; if practical, record alternative entry paths as separate cases rather than pooling their results. A generic upload acceptance is not evidence that Route Planner imports a route object.

### 3.3 What is known and what remains unverified

| Question | Evidence-based planning status |
|---|---|
| Product name and target | Windy.com browser weather map, specifically Distance & Planning / Route Planner. Not Windy.app or a generic uploader. |
| Published GPX import entry point | Windy Staff documentation describes More options → Import GPX and other paths. Exact labels and availability must be rechecked manually at execution. |
| Platform | Windy community guidance has described Route Planner/import as a browser/desktop workflow and unavailable in mobile app flows. The actual supported desktop OS/browser matrix is not established; qualify it during IP-6A. |
| Expected object | Official Windy material describes using an imported GPX route in Route Planner. Whether V1 GPX `<rte>` consistently becomes an editable route object rather than track/layer/other remains unverified. |
| Waypoint inspection/order | Not guaranteed by the cited materials. Verify through Route Planner's own visible point list or another user-accessible supported view; do not infer from map appearance. |
| Persistence | Windy community guidance describes saving a route as a Favorite. Persistence, account requirements and re-opening behavior must be qualified; a transient import is not evidence of persistence. |
| Authentication | Public sources indicate that account login is used for saved Favorites, but whether authentication is required to import/inspect a route is unresolved. Record account state; never store credentials. |
| Network/offline | Windy is an external weather service. IP-6 should use an online test environment. Offline import behavior is not promised or required. Converter conversion itself remains offline. |
| Current interface/version | Unverified until the manual test records date, URL, interface labels and environment. |

If the current Windy.com browser interface or the Route Planner-specific GPX entry point cannot be located, IP-6A is BLOCKED. Do not substitute Windy.app, the generic Uploader, a third-party map, or another application.

### 3.4 Source quality and recheck

Official Windy.com editorial material and Windy Staff posts are discovery evidence for the intended target, not compatibility guarantees. Some specific UI instructions originate in older community posts. Recheck the live interface and current official help during authorized IP-6A; record which details remain corroborated and which changed. Do not claim import support from a page that only describes generic GPX display.

## 4. Consumer compatibility contract

The converter's approved GPX output contract is one GPX 1.1 document with the Topografix GPX 1.1 namespace, one `<rte>`, and ordered `<rtept>` children; preserve available original waypoint names and only the route-name behavior approved at Gate 3. Do not emit a `<trk>` in place of the route. Do not fabricate points, reorder points, or imply that unsupported RTZ navigation semantics have been preserved.

For every converter-produced acceptance case, test whether Windy:

- Accepts the `<rte>`-based file directly in the intended Route Planner workflow.
- Produces an identifiable Route Planner route object and not a generic upload layer or silently substituted track; object substitution is a mandatory semantic failure.
- Retains the same number and ordinal sequence of route points.
- Retains every coordinate at the strongest precision observable through supported UI or user-accessible export.
- Retains waypoint names and approved route name, including absent names and Unicode cases.
- Mutates imported route data by adding/removing/reordering/merging route points, changing coordinates/names, or substituting a track/overlay for the intended route object.
- Changes only visual line rendering/interpolation while the imported route-point sequence and stored route semantics remain unchanged.
- Performs automatic routing, snapping, relocation, or adds navigation vertices that change route semantics.
- Displays the expected line and markers, warnings, route-leg controls, or any automatic-routing behavior.
- Reports import errors in an identifiable, reproducible way.

Maintain separate **imported-data**, **automatic-routing**, and **rendered-map** observations. Visual line interpolation between unchanged imported points, including projection or antimeridian wrapping, is recorded as rendering behavior and is not by itself a route-data compatibility failure. If supported UI cannot distinguish rendering from inserted, moved, snapped, or otherwise changed route points, classify the affected criterion INCONCLUSIVE. If Windy does not expose exact coordinates, point order, or object semantics through supported user-visible functionality, record the corresponding criterion INCONCLUSIVE. Never infer numeric fidelity from screenshots or a plausible-looking map line.

## 5. Synthetic acceptance corpus specification

No corpus artifacts are created in this planning task. After separate execution authorization, the cases below will use only approved synthetic source models from IP-1B/IP-2/IP-3 and expected GPX semantics from IP-4. Every case receives a stable case ID, fixture ID, source-model ID, mode/selection, expected route name, expected ordered point identities, expected decimal coordinates, expected names, expected schema result, and traceable generation record. Fixture metadata records provenance without private routes or vessel coordinates.

### 5.1 Positive consumer cases

| Case group | Planned synthetic coverage | Expected semantic oracle |
|---|---|---|
| `IP6-MIN` | Minimal valid multi-point route; short and long legs | Exact ordered input point identities/coordinates/names represented by the expected GPX `rtept` sequence. |
| `IP6-MANY` | Representative many-waypoint route within approved IP-2/IP-4 limits | Stable ordinal order and complete count; detect truncation or consumer limits. Do not invent an acceptance size before IP-1B qualification. |
| `IP6-DUP` | Duplicate coordinates with distinct source identities; duplicate waypoint names | Distinct ordinal points remain distinct; names are compared by position, not uniqueness. |
| `IP6-EMPTY-NAME` | Missing waypoint names and absent route name | No invented filename-, vessel-, or metadata-derived names; compare observed blank/omitted treatment. |
| `IP6-UNICODE` | Unicode route and waypoint names; XML-special characters | Expected decoded text at each ordinal where Windy exposes labels. |
| `IP6-COORD` | Positive/negative latitudes and longitudes; near-equator and near-prime-meridian points | Exact ordinal-by-ordinal coordinate oracle using approved numeric representation policy. |
| `IP6-HIGHLAT` | High latitudes inside approved model bounds | Coordinate fidelity and rendering observation without extrapolating beyond tested bounds. |
| `IP6-DATELINE` | Antimeridian-adjacent coordinates and approved longitude boundaries | Values compared numerically, with map-wrap/rendering treated separately. Unsupported `+180` is excluded unless Gate 3 approves it. |
| `IP6-FULL` | Full Route mode | All selected source-order points, with no omitted or inserted point. |
| `IP6-WAYPOINT` | From Waypoint suffix from first, middle and final selected source waypoint where eligible | Selected waypoint is ordinal 1 and only the approved forward suffix follows. One-point suffix follows the unresolved IP-4 policy. |
| `IP6-CURRENT-DIRECT` | Current Position — Direct to Next WP | Manually entered position and explicitly confirmed next waypoint lead the exact approved sequence. |
| `IP6-CURRENT-JOIN` | Current Position — Join Selected Route Leg | Approved synthetic join point, selected leg endpoints, connector points and remaining route appear in the IP-3-approved order. Windy must not choose a join or nearest leg. |
| `IP6-ONE` | Schema-valid one-point reference GPX | Separately characterize accept/reject/object/marker/error. Does not select IP-4 policy. |

Include negative/edge corpus cases only as separately labeled controls (§12): malformed GPX, unsupported namespace/version, empty route, track-only input, multiple routes, extension stress and excessive points. They are not converter-produced fixtures and do not become positive conformance requirements.

### 5.2 Fixture separation and traceability

- **IP-4 fixtures:** test serializer/schema/semantic outputs against approved expected bytes/model; owned and validated by IP-4, not created by IP-6.
- **IP-6 consumer cases:** select a minimal reproducible subset of IP-4-approved outputs and exercise the external Windy workflow. Record exact artifact identity using a hash only for synthetic fixture artifacts, never a private source-route digest.
- **Negative controls:** independently authored only after execution authorization; label them `CONTROL`, keep them outside converter-output claims, and specify expected validity/import classification.
- Each expected point sequence is derived from an approved synthetic source model plus the relevant IP-3 mode/selection, then checked against IP-4 serialization output before Windy import. The oracle is an ordinal table of stable synthetic point IDs, decimal coordinate values, optional names and provenance category (source or approved connector). It must not use the map screenshot as its source of truth.

## 6. Empirical manual test procedure

Browser automation and Windy interaction are prohibited during planning. After explicit IP-6 execution authorization, use a human-operated session and only synthetic files:

1. Record date/time, exact Windy product, URL, interface/menu labels, interface version/build if exposed, browser/version, OS/version, display scale if screenshots are used, account state (signed in/out only), and network state. Never record credentials, email, account ID or personal profile details.
2. Identify case ID, fixture ID, artifact hash (synthetic artifact only), GPX validation evidence, expected semantic route-point table, and the exact IP-4/IP-3 result used to produce it.
3. Open the actual Windy.com browser Route Planner (`Distance & Planning`) and record the precise import entry point. Do not use the mobile app or generic uploader as a substitute.
4. Import using the selected documented Route Planner workflow. Record accepted/rejected, visible message, interruption, and resulting object type. Do not publish/share.
5. Inspect the route's point list/order through a supported Route Planner view. Record the count and each visible ordinal/name. If no inspectable ordered list exists, mark order INCONCLUSIVE and escalate the product limitation.
6. Compare coordinates only if the consumer exposes exact numeric values in supported UI or a documented user-facing export. Compare each ordinal to the approved independent expected-coordinate oracle. Do not inspect private APIs, internal browser state, network payloads, undocumented storage or reverse-engineered endpoints.
7. Compare names and route name separately from XML correctness. Record absent names, Unicode, duplicate names and display truncation/normalization.
8. Inspect rendered line/markers and route controls. Record apparent straight/geodesic/rhumb/automatic routing behavior as an observation only; do not infer an algorithm from appearance.
9. Record any point insertion/removal/reordering, coordinate changes, snapping, simplification, warnings, route-type change or automatic route modification as imported-data or route-semantics evidence. Record display interpolation separately; if its effect cannot be distinguished from route-data mutation, mark the criterion INCONCLUSIVE. Preserve the original synthetic file and capture consumer output only through supported means.
10. Capture screenshots or equivalent evidence only for synthetic data. Crop/redact account/profile/weather-location details and unrelated browser content. Store evidence in the approved non-sensitive evidence location; do not commit screenshots with personal/account information.
11. Assign exactly one case verdict (`PASS`, `FAIL`, `BLOCKED`, `INCONCLUSIVE`) with evidence references and a second reviewer. Do not repeat imports until behavior is reproducible or the reason for variation is recorded.
12. If account authentication is needed, obtain an authorized generic test account outside the repository. Never request, store, paste, or commit credentials. Do not bypass access controls, paywalls, rate limits, or privacy settings.

The Windy test environment may require internet for Windy itself, map tiles, weather data, authentication or save/favorite behavior. The acceptance report must distinguish that external connectivity from the converter's mandatory network-disabled conversion guarantee. No claim of offline Windy import is made.

## 7. Geometry interpretation and limits

Classify consumer behavior on three independent axes:

**A. Imported route-data mutation.** Added, removed, reordered or merged route points; changed coordinates or names; or silent substitution of the required route object with a track/generic overlay are mandatory compatibility failures unless an explicit upstream architecture decision changes the contract.

**B. Visual rendering or interpolation.** A line drawn between unchanged points, display-only interpolation, map projection or antimeridian wrapping is not automatically a compatibility failure. Record it separately from route-data fidelity. Do not infer Windy's mathematics from appearance or claim that visual interpolation preserves RTZ leg geometry or ECDIS semantics.

**C. Automatic routing that changes semantics.** Network-based routing, silent snapping/relocation, inserted navigation vertices, or replacement of the approved sequence requires explicit classification and architectural review. If supported evidence cannot distinguish it from display-only rendering/interpolation, mark the affected criterion INCONCLUSIVE; do not assume PASS or FAIL.

Use four distinct geometry layers:

1. Original RTZ legs, turns, XTD, speed/safety constraints and other source navigation metadata.
2. IP-3's qualified mode transformation and any explicitly approved connector/join geometry.
3. GPX's ordered route-point sequence (`rtept`) and serializer-defined coordinate representation.
4. Windy's own imported object, line rendering, interpolation, automatic routing or display behavior.

GPX route vertices do not encode all RTZ leg/turn semantics. Windy may draw straight visual segments, interpolate geodesically or rhumb-wise, snap, auto-route, simplify, or display a polyline without exposing its internal interpretation. Test observable differences with synthetic short/long, high-latitude, antimeridian and sparse/dense route cases where the interface permits. Record whether a difference is imported-data mutation, semantics-changing automatic routing, or display-only rendering. If supported evidence cannot distinguish those classes, use INCONCLUSIVE. A visual appearance is evidence only of appearance; it cannot establish the rendering algorithm or numerical coordinate preservation.

Record any indication of automatic routing and route-leg mode. If the interface does not disclose interpolation/automatic-routing rules, say so. Never claim ECDIS geometry equivalence, route safety, navigational validity, or preservation of operational constraints.

## 8. Independent route-mode acceptance

Each mode is a separate required acceptance group; success in one mode does not qualify another.

| Mode | Expected consumer check |
|---|---|
| Full Route | Imported route count/order corresponds to every approved source-order point; no extra or missing point; compare names and numeric coordinates wherever observable. |
| From Waypoint | Explicitly selected source waypoint is first; only approved forward suffix follows; no preceding point or inferred selection is introduced. |
| Current Position — Direct to Next WP | Manually entered synthetic current position appears first; explicitly confirmed next waypoint follows; exact remaining route order is preserved. |
| Current Position — Join Selected Route Leg | IP-3-selected leg and finalized connector points are represented in approved order; Windy does not select a nearest leg, compute a replacement join, or silently route between points. |

IP-6 tests consumer interpretation of the finalized GPX only. Any question about route transformation, selected leg, join point, coordinate math or point provenance is returned to IP-3/IP-4, not recomputed or adjudicated by IP-6. A rendered connector that looks different is not automatically a mutation; verify whether imported points or route semantics changed.

## 9. One-point GPX decision support

IP-4 R1 leaves product policy unresolved: `ALLOW_WITH_WARNING` or `REFUSE_EXPORT`. IP-6 may evaluate a schema-valid synthetic one-point GPX reference artifact after execution authorization, even if the eventual converter policy refuses to produce one.

Record separately whether Windy accepts it; creates a Route Planner route, a marker, another object, or nothing; drops the point; or gives an identifiable error. A single marker does not prove a useful route. This evidence is advisory to Gate 3 only. IP-6 must not choose the policy, change IP-4 eligibility, or make other route-mode PASS contingent on one-point behavior unless Gate 3 explicitly says so.

## 10. Route names and metadata

Use authorized synthetic cases for source route name present/absent, Unicode route name, duplicate waypoint names, absent waypoint names, long valid names, and XML-special characters. Include an export-only route-name override only if Gate 3 approves that capability before fixture generation.

Separate:

- Whether GPX bytes correctly contain or omit the approved name (IP-4 evidence).
- Whether Windy imports and retains the semantic string.
- Whether Windy's UI truncates, normalizes, hides, or otherwise limits display.

Do not add name editing to V1 through an IP-6 workaround. Do not derive names from a filename, vessel identifier, or unrelated metadata. GPX extensions and RTZ metadata are not presumed to survive or be supported by Windy; record only observed behavior and do not turn it into a preservation promise.

## 11. Numeric precision and coordinate fidelity

For each positive consumer case, preserve an independent expected coordinate table produced from the approved synthetic semantic model and exact IP-4 output. Compare by ordinal and point identity; never compare only endpoints or route length.

- Use decimal equality only where the approved IP-2/IP-4 model/serializer contract requires mathematical decimal equality.
- Use a binary floating-point round-trip tolerance only if IP-2/IP-4 explicitly qualified and approved it. Carry the documented source-decimal-to-model error analysis into evidence.
- Do not invent an IP-6 tolerance. A consumer's rounding rule requires its own evidence and approval; report raw exposed values and differences before applying any allowed threshold.
- Test antimeridian-adjacent values and longitude limits supported by the approved upstream contract. `+180` remains excluded unless separately approved.
- Screenshots, map cursor positions and line placement are not numeric coordinate evidence.
- If Windy does not expose exact point coordinates or an exportable/user-accessible route object suitable for comparison, mark consumer coordinate fidelity `INCONCLUSIVE`, even if the drawn route appears correct.

## 12. Negative controls and compatibility failure classification

Negative controls are independent inputs used to characterize consumer handling; they are not output requirements. Planned controls include:

- Invalid GPX namespace; unsupported GPX version; malformed XML; missing mandatory attributes; empty route.
- One-point route (also covered in §9); track-only GPX; multiple `<rte>` elements; duplicate coordinates; unexpected extensions.
- Excessive point count chosen only after interface limits are measured; interrupted import; UI/interface change; ambiguous or unsupported resulting object.

Classification rules:

- A negative control rejected by Windy is expected negative-control behavior unless it contradicts an explicit converter requirement; it is not automatically a converter defect.
- A converter-produced, IP-4-validated required case rejected by the exact intended workflow is a Windy consumer compatibility **FAIL** for that case, not a GPX serializer defect. Route the evidence to IP-4/IP-5/Gate 3 for disposition without silently changing the output contract.
- If a user interface changes or a required action is unavailable, mark the case BLOCKED until IP-6A requalifies the workflow. Do not rewrite historical evidence as current.
- If import succeeds but object type, point sequence, or numeric coordinates cannot be observed, use INCONCLUSIVE for the relevant criterion; upload success is never an overall PASS.
- If Windy changes order, drops/adds/merges route points, changes coordinates beyond an already-approved tolerance, or substitutes a track/overlay for the required route object, classify the affected mandatory criterion FAIL and escalate.
- Display-only line rendering, interpolation, projection, or wrapping with unchanged imported route data is recorded separately and is not automatically a failure.
- If apparent snapping, inserted points or route recalculation may be visual-only and supported evidence cannot distinguish that from semantic mutation, classify the affected criterion INCONCLUSIVE and escalate; do not silently accept it as harmless rendering.

## 13. Evidence matrix and aggregate acceptance

Maintain one row per case and one evidence link per criterion. Track two independent status axes: **IP-6E report state** (`NOT STARTED`, `IN PROGRESS`, `REPORT COMPLETE`) and **IP-6 consumer verdict** (`NOT TESTED`, `PASS`, `FAIL`, `BLOCKED`, `INCONCLUSIVE`). Completing the analysis/report may record any aggregate consumer verdict; report completion never implies compatibility PASS. Required fields:

| Field | Content |
|---|---|
| Case / fixture / source-model ID | Stable identifiers; synthetic provenance only. |
| Expected semantic result | Mode, selected IDs/ordinals, exact expected ordered point IDs, coordinates, names and route label. |
| GPX conformance | IP-4 schema-validation result and serializer semantic comparison reference. |
| Consumer environment | Exact Windy product/interface URL/version/date, browser/OS versions, network and generic account state. |
| Import | Entry point, accepted/rejected, message, time, interruption. |
| Imported object | Route/track/marker/layer/other/unknown and evidence. |
| Count and order | Expected vs observed count and ordinal sequence; `UNOBSERVABLE` explicitly allowed. |
| Coordinate fidelity | Method, exposed values, per-ordinal differences, approved comparison rule or `UNOBSERVABLE`. |
| Names and geometry | Expected/observed labels; rendered behavior; modifications, interpolation or auto-routing observations. |
| Behavior classification | Imported route-data mutation / display-only rendering / semantics-changing automatic routing / unable to distinguish; evidence and affected criterion. |
| Evidence/privacy | Screenshot or supported equivalent path; synthetic-only confirmation and redaction status. |
| Limitations / verdict / reviewer | Constraints, one of four verdicts, reviewer/date. |

Each required criterion uses exactly one state:

- **PASS:** directly observed with adequate, reproducible evidence against its approved oracle.
- **FAIL:** observed behavior contradicts a mandatory criterion or loses/changes approved output semantics.
- **BLOCKED:** test cannot be safely or procedurally run, such as missing access/workflow or unresolved prerequisites.
- **INCONCLUSIVE:** execution occurred but the relevant property cannot be observed or evidence is insufficient.

### Aggregate rule

The IP-6 consumer verdict is **PASS** only when every mandatory Full Route, From Waypoint, Current Position — Direct, and Current Position — Join case passes in the qualified target workflow; imports yield the required route interpretation; all required point counts and order are verified; exact coordinates are verified by supported evidence under the already-approved numeric policy; required names behave as specified; no unapproved imported route-data mutation is observed; and no semantics-changing automatic routing is observed. Required cases with FAIL, BLOCKED or INCONCLUSIVE prevent consumer PASS. A GPX upload or plausible-looking map line alone cannot pass any hidden-data criterion.

Display-only rendering differences do not fail the consumer verdict when supported evidence establishes that imported route data and route semantics remain unchanged. If a visual effect cannot be distinguished from route-data mutation or automatic routing using supported evidence, the affected mandatory criterion is INCONCLUSIVE and aggregate consumer acceptance cannot PASS. No mandatory criterion may be downgraded to reach PASS.

If Windy cannot expose exact coordinates or point order using supported means, the report must say consumer fidelity is unverified and the aggregate remains INCONCLUSIVE/BLOCKED. It may present separate sub-results (for example import acceptance PASS, coordinate fidelity INCONCLUSIVE), but cannot collapse them into overall PASS. Optional display metadata, unsupported Windy features, and one-point behavior are reported separately and do not silently alter product policy. A qualified result applies only to the recorded Windy interface and environment; future interface changes require requalification.

## 14. Failure handling and product consequences

Escalate to the architect/Gate 3 review if:

- Windy rejects the required `<rte>` contract but accepts `<trk>`.
- Windy reorders, drops, inserts, merges, snaps, or changes required route points/coordinates.
- Windy performs automatic routing that changes route semantics, snaps/relocates points, inserts navigation vertices, or replaces the approved sequence.
- Apparent visual interpolation/rendering cannot be distinguished from a semantics-changing route modification using supported evidence.
- The object is a track/overlay rather than the intended Route Planner route.
- The target workflow cannot expose enough evidence to verify a mandatory criterion.
- The only workable import is outside the approved Windy.com Route Planner workflow, requires prohibited behavior, or differs from the specified product.

Do not silently switch output to `<trk>`, densify, interpolate, modify route geometry, add Windy-specific extensions, or relax point/coordinate criteria. Such a change requires separate architecture/product approval and coordinated IP-3/IP-4/IP-5 review. A display-only rendering difference alone does not establish that the approved GPX contract is unconsumable. If imported route data is mutated or semantics-changing automatic routing occurs, classify a product-compatibility failure; if mutation versus rendering cannot be distinguished, classify it INCONCLUSIVE. IP-6 cannot authorize release by weakening the target or by reclassifying an unknown property as correct.

## 15. Future IP-6 execution sub-stages

All sub-stages below are future execution work, require separate Gate 4/IP-6 authorization, and create no artifacts in this planning task.

### IP-6A — Target Workflow Qualification

- **Objective:** establish the exact current Windy.com browser product, Route Planner interface, import entry point, object interpretation observables, account needs, persistence and test environment.
- **Scope/exclusions:** inspect official documentation and perform authorized manual UI discovery only after execution authorization; no browser automation, private APIs, other Windy product substitution or real routes.
- **Proposed files:** `docs/research/IP-6/WINDY-WORKFLOW-QUALIFICATION.md`, evidence index.
- **Dependencies:** IP-1 Windy discovery; approved synthetic-only/privacy boundary; current access to Windy.com.
- **Sequence:** recheck official sources → record live URL/interface/version → select primary documented Route Planner import path → identify route/list/coordinate/persistence observables → document browser/OS/account/network conditions → architect review.
- **Tests/evidence:** dated manual workflow recording; safe synthetic session; evidence for route vs generic uploader distinction; list all unobservable properties.
- **Acceptance:** exact target and entry path are reproducible and distinct from Windy.app/mobile/generic Uploader; observables and limitations documented; no unsupported compatibility claim.
- **Risks:** UI drift, account gates, regional/product variation, external-service unavailability.
- **Rollback/stop:** stop if target import entry is absent or requires bypass; return to architectural review rather than substituting an app.
- **PASS:** independent reviewer can reproduce the qualified target steps from the record without private API or ambiguous product selection.

### IP-6B — Synthetic Consumer Corpus

- **Objective:** bind a small approved synthetic corpus to deterministic expected GPX route-point sequences.
- **Scope/exclusions:** fixture specification and generation only after authorization; no real source routes, credentials, current vessel positions, or fixture creation during planning.
- **Proposed files:** `Tests/Fixtures/IP6/README.md`, synthetic GPX fixtures, `docs/research/IP-6/EXPECTED-ROUTE-SEMANTICS.md` (exact names subject to IP-4 repository conventions).
- **Dependencies:** IP-1B synthetic source catalog; IP-2 model/coordinate decisions; IP-3 mode/geometries; IP-4 schema/serializer and one-point/name decisions; privacy review.
- **Sequence:** choose cases → derive source-model point identities → apply approved mode selections → compare IP-4 output with independent expected order/coordinates/names → separate negative controls → review fixture provenance.
- **Tests/evidence:** schema validation, deterministic expected semantic tables, duplicate identity/name and boundary case checks, no private-coordinate scan.
- **Acceptance:** every fixture is synthetic, traceable and approved; positive converter outputs are distinct from negative controls; one-point reference is labeled independent where necessary; expected oracle is not derived from screenshots.
- **Risks:** accidental resemblance to real voyages, undefined tolerances, upstream policy changes.
- **Rollback/stop:** remove unapproved fixture candidates before commit; stop if synthetic provenance or numeric oracle cannot be established.
- **PASS:** approved corpus catalog and independent semantic oracle review; no untracked or unreviewed real route material.

### IP-6C — Manual Import Acceptance

- **Objective:** execute repeatable imports through the qualified Route Planner entry path and determine file acceptance and object interpretation.
- **Scope/exclusions:** manual desktop-browser interaction with synthetic GPX only; no browser automation, no real routes, no publishing/sharing, no private APIs.
- **Proposed files:** `docs/research/IP-6/MANUAL-IMPORT-RESULTS.md`, redacted synthetic evidence references.
- **Dependencies:** IP-6A PASS; IP-6B approved corpus; IP-4 serializer execution evidence for artifacts; IP-5 delivery flow where relevant; explicit IP-6 execution authorization.
- **Sequence:** capture environment → open intended interface → import one fixture at a time → classify accepted/rejected/object type → inspect point list/feedback → record date-bounded result.
- **Tests/evidence:** all mandatory route modes and selected controls through same workflow; repeat a subset to assess reproducibility; exact visible messages and privacy-safe screenshots.
- **Acceptance:** each case has evidence and one verdict; Route Planner path is not conflated with generic upload; any product variation is recorded, not averaged away.
- **Risks:** service changes, authentication requirements, rate limits, non-deterministic imports.
- **Rollback/stop:** stop on access restriction, unexpected real-data exposure, publish/share prompt, or unsafe external-service request; do not bypass.
- **PASS:** all planned manual imports are recorded with reproducible, privacy-reviewed results; this sub-stage PASS does not imply overall IP-6 PASS.

### IP-6D — Geometry and Metadata Assessment

- **Objective:** compare observable imported count, order, coordinates, labels and rendering with the expected semantics and record non-observable behavior honestly.
- **Scope/exclusions:** consumer observation only; IP-3 retains geometry algorithms and IP-4 retains serialization. No reverse engineering or screenshot-based numeric inference.
- **Proposed files:** `docs/research/IP-6/GEOMETRY-METADATA-ASSESSMENT.md`, evidence updates.
- **Dependencies:** IP-6A qualified observables; IP-6B expected semantic tables; IP-6C import results; IP-2/IP-4 approved numeric policy.
- **Sequence:** compare ordinal lists → compare supported exact coordinate exposure → compare names → inspect line/markers → classify interpolation/automatic-routing observations and unknowns → reviewer checks every claim against evidence.
- **Tests/evidence:** Full Route, suffix and both Current Position modes; duplicate coordinates/names; high-latitude and dateline rendering cases; one-point separate support case.
- **Acceptance:** imported data, semantics-changing automatic routing and display-only rendering are classified separately; observable route-data properties are compared to their oracle; indistinguishable behavior is INCONCLUSIVE; every unsupported inference is labeled unknown; no ECDIS-equivalence statement or unapproved tolerance.
- **Risks:** limited UI exposes only rendered geometry; display rounding; feature subscription differences.
- **Rollback/stop:** if data cannot be observed safely, classify INCONCLUSIVE and stop that criterion; do not use undocumented access.
- **PASS:** the IP-6D assessment is complete when available observations and limitations are classified and reviewed; display-only rendering is not mislabeled as data mutation, and indistinguishable behavior remains INCONCLUSIVE. IP-6D sub-stage completion does not itself pass the consumer verdict; unobservable mandatory numerical fidelity remains a consumer blocker.

### IP-6E — Product Compatibility Verdict

- **Objective:** consolidate the matrix, assign core and optional verdicts, identify product blockers and return evidence for Gate 3 decisions.
- **Scope/exclusions:** report and recommendation only; no change to converter behavior, IP-4 policy, Windy target, or V1 scope.
- **Proposed files:** `docs/research/IP-6/CONSUMER-ACCEPTANCE-REPORT.md`, final evidence matrix, `REPORT.md`, `PROGRESS.md`.
- **Dependencies:** IP-6A–IP-6D evidence; IP-1–IP-5 status reconciliation; Gate 3 architect review.
- **Sequence:** audit required case coverage → apply §13 aggregate rule → separate import/object/order/coordinate/rendering results → classify failures → list exact blocker/decision owner → independent review.
- **Tests/evidence:** trace each verdict to raw privacy-safe observations and approved expected semantic oracle; verify no required `BLOCKED`/`INCONCLUSIVE` is hidden by aggregate wording.
- **Acceptance:** report is reviewed, all required evidence is classified, and limitations/failures/blockers are explicit. It may record aggregate consumer verdict PASS, FAIL, BLOCKED or INCONCLUSIVE; `IP-6E REPORT COMPLETE` is a report-completion state only and never implies consumer acceptance PASS.
- **Risks:** overclaim from partial acceptance, version drift, uncertain coordinate visibility.
- **Rollback/stop:** withdraw any report with unsupported PASS claims and return affected cases to review; no product-scope shortcut.
- **IP-6E REPORT COMPLETE (sub-stage exit):** report review and evidence classification are complete for any aggregate consumer verdict (PASS, FAIL, BLOCKED or INCONCLUSIVE). Report completion must not be labeled `IP-6 PASS` unless the independent consumer verdict is PASS under §13. A completed report with a non-PASS verdict is useful evidence but does not authorize release.

## 16. Cross-stage dependencies

| Stage | IP-6 dependency | Status | Evidence/owner boundary |
|---|---|---|---|
| IP-1 | GPX/RTZ standards; schema evidence; Windy discovery and test protocol | **APPROVED AS PLAN; EXECUTION EVIDENCE PENDING** | IP-1 identifies synthetic-only Route Planner testing; IP-6A requalifies current workflow; IP-6 cannot report IP-1 execution PASS. |
| IP-2 | Synthetic source model and coordinate representation | **APPROVED AS PLAN; EXECUTION EVIDENCE PENDING** | Supplies approved synthetic model/identity and numeric representation; IP-6 does not define parser tolerances. |
| IP-3 | Full Route, From Waypoint, both Current Position transforms and qualified geometry | **APPROVED AS PLAN; EXECUTION EVIDENCE PENDING** | Supplies final point order, provenance and connector geometry; IP-6 observes consumption only and never selects a leg/join. |
| IP-4 | GPX 1.1 route serialization, names, one-point policy and immutable validated artifact | **APPROVED AS PLAN; EXECUTION EVIDENCE PENDING** | GPX schema/serializer conformance is a separate gate; one-point and route-name override remain Gate 3 unresolved. |
| IP-5 | Local runtime orchestration and safe output writing | **APPROVED AS PLAN; EXECUTION EVIDENCE PENDING** | IP-5 execution and IP-5D/IP-5F qualification are pending; IP-6 may consume an approved IP-4 artifact without claiming CLI/write acceptance. |
| IP-6 | Windy consumer workflow acceptance | **PLAN APPROVED / READY FOR GATE 3; CONSUMER ACCEPTANCE NOT TESTED** | Owns external consumer evidence and independent aggregate verdict under this plan; execution not authorized. |
| IP-7 | Shortcut export/import instructions, user feedback and release workflow | **UNRESOLVED / FUTURE PLAN** | IP-6 provides validated consumer instructions/limitations; IP-6 cannot begin IP-7 planning or authorize UI claims. |

Cross-stage rule: IP-6 consumes independently approved upstream outputs and records their status as known at test time. It cannot claim that IP-1 through IP-5 implementation tests passed merely because Windy displayed a file. Product compatibility cannot override GPX schema correctness, IP-3 transformation policy, IP-4 one-point/name decisions, IP-5 security controls, or Gate 3 governance.

## 17. Planning acceptance and future execution PASS

Gate 2 planning acceptance requires: exact Windy.com Route Planner target and documented uncertainty; a layered consumer contract; synthetic case catalog and provenance method; repeatable manual procedure; independent route-mode matrix; geometry/metadata and coordinate-fidelity evidence strategy; one-point decision support; negative-control classification; evidence schema and strict aggregate verdict; separate report-completion and consumer-verdict statuses; IP-6A–IP-6E sub-stage plans; cross-stage dependency/status matrix; and no unsupported compatibility claim.

The current status model is **IP-6 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK; IP-6 CONSUMER ACCEPTANCE: NOT TESTED; IP-6 EXECUTION: NOT AUTHORIZED**. In future execution, **IP-6E REPORT COMPLETE** means the reviewed analysis is complete regardless of the consumer verdict. **IP-6 CONSUMER ACCEPTANCE PASS** is a separate verdict requiring actual, date-bounded evidence from the intended Windy.com Route Planner workflow with approved synthetic data and every mandatory criterion passed under §13. GPX schema PASS, file upload success, visual plausibility, or optional metadata display is never a substitute for route-object, order and coordinate-fidelity evidence. Any mandatory unobservable property leaves consumer acceptance INCONCLUSIVE or BLOCKED. Do not label a completed report `IP-6 PASS` when consumer acceptance has not passed.

## 18. Primary Windy references

Research checked 2026-10-11. Recheck during authorized IP-6A because web product workflows can change.

- Windy.com editorial, [How to Plan Outdoor Routes and Why GPX Files Are Your Best Friend](https://www.windy.com/articles/40059) — describes the Distance & Planning route-planning feature and GPX import for route display; it does not guarantee `<rte>` semantics or coordinate fidelity.
- Windy Staff, [Windy launches Route Planner](https://community.windy.com/topic/9013/windy-launches-route-planner/178) — staff post lists GPX import via upload then open in Route Planner, drag-and-drop, or Route Planner More options → Import GPX. Community instructions are historical and require live requalification.
- Windy Community moderator guidance, [How to use a route planner](https://community.windy.com/topic/9596/how-to-use-a-route-planner/140?page=4) — describes importing GPX into Distance & Planning as creating a route with Route Planner features and refers to Favorites; this is supporting discovery only, not a current compatibility guarantee.
- Windy Community discussion, [Importing GPX files](https://community.windy.com/topic/27511/importing-gpx-files/3) — distinguishes browser Route Planner import from mobile app limitations and mentions login for saved routes; this is historical supporting evidence, not proof of current authentication requirements.

## Approval request

Please review the exact Windy.com Route Planner target, its evidence limits, synthetic corpus, manual protocol, aggregate acceptance rule and IP-6A–IP-6E execution decomposition. Confirm any needed changes before Gate 3 cross-check. Do not execute IP-6 or begin IP-7 planning without separate explicit authorization.
