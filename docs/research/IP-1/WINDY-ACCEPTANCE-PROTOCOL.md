# IP-1F — Windy Acceptance Protocol

**Status: IP-1F PASS (protocol design only).** This document defines reproducible future acceptance procedures and evidence rules. It records no Windy compatibility result. No file was uploaded or imported; consumer outcomes remain **NOT TESTED**. IP-1G, IP-2–IP-7 execution, production conversion and release remain **NOT AUTHORIZED**.

**Baseline:** `debf177a979027323890bed31369303645d2bcbd`
**Research checked:** 2026-10-13
**Scope:** synthetic GPX 1.1 only; no real route, voyage, vessel identity, operational coordinates or private account data.

## 1. Purpose and fixed product contract

The target is the browser version of Windy.com and its Route Planner / Distance & Planning feature. This protocol keeps the ordinary GPX uploader distinct from the Route Planner. Acceptance by an uploader, or display of a line on a map, does not show that Windy created an editable Route Planner route.

The approved converter output is a GPX 1.1 route (`<rte>` with ordered `<rtept>`), not a substitute track. Preserve point count, order, coordinates and names under the approved contract. G3-001 route naming remains: valid source name by default, explicit export-only override, or explicit omission. G3-004 remains `ALLOW_WITH_WARNING`: one-point export is permitted after warning and affirmative route confirmation. Windy refusal of one point is recorded as a consumer limitation and cannot change that export policy. No result establishes ECDIS geometry equivalence.

## 2. Evidence status and current workflow discovery

Windy's current editorial article describes importing a GPX route into Windy and displaying it on the map, but does not specify a current Route Planner import menu path or how to inspect imported object semantics. A Windy Staff community post describes `More options → Import GPX`, drag-and-drop, and upload-then-open paths; it is historical discovery evidence, not current workflow confirmation. Therefore:

- **Uploader entry point:** exact current label and behavior **TO VERIFY DURING IP-6**.
- **Route Planner entry point:** exact current label/path **TO VERIFY DURING IP-6**. Do not assume the old community steps still exist.
- **Editable object, order/coordinate observability, account needs and persistence:** **TO VERIFY DURING IP-6**.
- Do not interact with Windy in IP-1F. IP-6A must manually identify the current desktop browser interface and choose one primary Route Planner path before testing. If it cannot, mark IP-6A BLOCKED. Do not invent steps or substitute Windy.app/mobile, a generic uploader, another product, private APIs or browser automation.

Sources: Windy editorial, [How to Plan Outdoor Routes and Why GPX Files Are Your Best Friend](https://www.windy.com/articles/40059) (general GPX import/display statement); Windy Staff, [Windy launches Route Planner](https://community.windy.com/topic/9013/windy-launches-route-planner/179) (historical paths; recheck during IP-6). The editorial source does not establish an uploader-versus-Route-Planner distinction or compatibility with this product's GPX semantics.

## 3. Two separate future workflows

These are protocols for the separately authorized IP-6 executor. The steps intentionally require the tester to record the actual visible controls rather than assume current labels.

### A. Ordinary GPX Uploader

1. In the Windy.com desktop browser, locate the ordinary GPX upload/import function. Record the exact visible entry point and URL. If it cannot be distinguished from Route Planner import, stop and mark the workflow BLOCKED pending clarification.
2. Using only an authorized synthetic GPX, record whether the uploader accepts it, rejects it, or returns a message. Paraphrase messages; do not capture account or personal details.
3. Record any resulting map layer/object only as the uploader's result (for example, overlay/track/other if the UI identifies it), plus visible point/line behavior and error state. Do not call it an editable Route Planner route without separate Route Planner evidence.
4. Do not use uploader success as evidence for Route Planner object type, editability, point ordering, numeric coordinate fidelity or mandatory IP-6 acceptance.

### B. Windy Route Planner

1. In a desktop browser, open the current Windy.com Route Planner / Distance & Planning interface using the live UI. Record the date, URL, exact labels and actions. The import entry point is **TO VERIFY DURING IP-6**; do not follow historical labels unless they are present and observed.
2. Before selecting a file, confirm it is the intended synthetic GPX and record its synthetic artifact ID/hash and validation evidence. Import it through the observed Route Planner-specific entry point only.
3. Record accepted/rejected, visible response and resulting object classification: editable Route Planner route, track, upload layer, marker, other, or unknown. Verify editability only through ordinary user-facing Route Planner controls; do not publish, share, save as Favorite or invoke an account-persistence action.
4. Verify waypoint count and order from the Route Planner's supported visible ordered list or another documented/user-facing representation. Use ordinal position and synthetic expected point IDs/names; do not infer order from marker placement or line appearance. If no ordered view or supported export exists, record order **INCONCLUSIVE**.
5. Compare coordinates only if exact numeric values are exposed in a supported user-facing view/export. Compare every ordinal to the independent expected-point table. If exact values are unavailable, coordinate fidelity is **INCONCLUSIVE**, even when the line looks plausible. No private API, internal browser state, network payload, undocumented storage or reverse engineering.
6. Record route/waypoint names, count, first/last points, any normalization/truncation, and whether imported semantics changed. Keep map rendering/interpolation separate from imported data. Do not infer a geodesic/rhumb algorithm from appearance.
7. Stop before any share, publish, public-link, Favorite/persistence or other publication action. Close/remove only the synthetic test object if the UI offers a clearly local, reversible action; otherwise leave it untouched and record that fact.

## 4. Synthetic acceptance case matrix

Every input must be original synthetic data and schema-valid GPX 1.1 for positive cases. The expected point oracle is prepared independently from the corresponding approved synthetic source model and transformation; validate the GPX before upload using the qualified method available at IP-6 time. Record validator/schema identity and rights status. Do not create product GPX or fixtures in IP-1F.

| Test ID | Synthetic profile | Required observation | Release role |
|---|---|---|---|
| `W-2PT` | Exactly two route points | Route object, count 2, ordinal order, endpoints and exact coordinates if observable | Mandatory multi-point baseline |
| `W-ORDER` | Several distinct ordered route points | Count and every ordinal; detect truncation, merge, insertion or reorder | Mandatory |
| `W-NAMES` | Route and waypoint names, including distinct waypoint names | Effective route name and per-ordinal names; distinguish hidden UI labels from dropped data | Mandatory |
| `W-NAME-SOURCE` | Valid source RTZ route name used as default | Imported `<rte><name>` value is observed as Windy exposes it | Mandatory name-contract coverage |
| `W-NAME-OVERRIDE` | Explicit confirmed export-only name override | Exact confirmed effective GPX route name is observed; output filename is not used as oracle | Mandatory; G3-008 requires a confirmed override case |
| `W-NAME-OMIT` | Explicit route-name omission | Determine whether route is accepted and how absent route name is represented; no fallback is presumed | Mandatory product-contract coverage |
| `W-DATELINE` | Synthetic points on either side of the antimeridian using only GPX-valid qualified coordinates | Numeric coordinates/order separately from map wrapping/rendering; no inference from the line | Mandatory geometry/fidelity case |
| `W-UNICODE-XML` | Unicode route/waypoint names and XML-special characters | Decoded text where exposed; report normalization, truncation or rejection | Mandatory |
| `W-PRECISION` | Coordinates with meaningful decimal precision, positive and negative values | Exact numeric comparison where supported; otherwise INCONCLUSIVE | Mandatory |
| `W-ONE` | One-point GPX route | Required separate observation of accept/reject, object/marker/other and error; never add a fabricated point | Informative and non-release-gating; not a mandatory multi-point PASS condition |

Mandatory cases are evaluated in the Route Planner workflow. The ordinary Uploader may be observed as a separate diagnostic for applicable files, but cannot satisfy any mandatory Route Planner row. The one-point result is always reported separately and does not gate G3-004 export capability. A failed mandatory test cannot be averaged against other passes.

### Required mode coverage

The required multi-point acceptance set must include outputs from **all four approved route modes**; a profile passing in one mode does not stand in for another:

| Mode case | Required synthetic output and observation |
|---|---|
| `W-MODE-FULL` | Full Route: complete approved source point sequence and names. |
| `W-MODE-WAYPOINT` | From Waypoint: a multi-point suffix starting at the explicitly selected first or middle source waypoint. Test final-waypoint one-point output separately as `W-ONE`. |
| `W-MODE-DIRECT` | From Current Position — Direct to Next WP: manual synthetic position, explicitly confirmed next waypoint, and approved connector. |
| `W-MODE-JOIN` | From Current Position — Join Selected Route Leg: manually selected leg, approved join point and connector; verify the new connector does not replace or alter the source leg semantics. |

For each Current Position mode, instantiate both explicitly selected connector geometries, **Rhumb Line** and **Great Circle**, using approved synthetic cases where the geometry is valid. Record the selected method and resulting expected point sequence. Do not infer or accept an automatic method switch. G3-002 selection and the selected route-leg's own geometry remain distinct. Any required multi-point mode/geometry combination without evidence prevents aggregate consumer PASS.

Cross these mode instances with the mandatory contract dimensions as applicable: route/waypoint names, source-name default, override and omission, Unicode/XML escaping, antimeridian and decimal precision. Keep the case ID unique for each concrete mode/profile combination and trace it to the synthetic expected-point oracle. This mode/profile matrix is a coverage requirement, not permission to invent a navigation choice or use operational route data.

## 5. Required observation record and order/geometry rules

For each workflow and test ID, record:

- Synthetic test/fixture ID and GPX SHA-256 (synthetic artifact only); GPX 1.1 validation result, validator and schema/artifact identity.
- Expected behavior and expected ordinal point table; UTC test date/time.
- Windy product, exact URL and observed entry path; browser/application and OS version/build if available; generic account state only (signed in/out), and platform/network context. Never record identity, email or credentials.
- Import success/failure, exact user-visible object classification, editability evidence, point count, ordered list evidence, route/waypoint names, first/last coordinates, and per-point numeric preservation where exposed.
- Geometry/rendering appearance separately from stored/imported point data; truncation, reordering, normalization, snapping, insertion/removal, dropped fields, warnings and paraphrased errors.
- Whether the resulting object is usable as an editable Route Planner route. Upload/display alone is insufficient.
- Evidence references, outcome, deviation classification, reproduction steps and any retest requirement.

Order must be checked by ordinal entries in a supported point list or supported user-facing export, not screenshot/map appearance. Coordinate fidelity requires exposed exact values or a documented user-facing export and comparison against the independent oracle. If those views are unavailable, mark the corresponding criterion INCONCLUSIVE; do not convert missing evidence into PASS.

Classify observations independently:

1. **Imported-data mutation:** missing/extra/merged/reordered points, changed coordinates/names or object substitution. This is a mandatory failure for a required case when established.
2. **Semantics-changing routing:** snapping, relocation or automatic route vertices/route decisions. Record separately; if it changes intended route semantics, mandatory failure.
3. **Display-only rendering:** projection, line interpolation or antimeridian wrapping. Not automatically a failure if imported point data is demonstrably unchanged. If the UI cannot distinguish rendering from route mutation, mark INCONCLUSIVE.

No observation asserts equivalence to RTZ leg geometry, rhumb/Great Circle behavior, or ECDIS display.

## 6. Verdicts and aggregation

Assign exactly one case outcome: **PASS**, **FAIL**, **BLOCKED**, **INCONCLUSIVE**, or **NOT TESTED**. PASS requires all applicable required observations and supporting evidence. Use BLOCKED when the workflow/test cannot be safely executed or a prerequisite is missing; INCONCLUSIVE when the workflow ran but an important property cannot be observed; NOT TESTED when no attempt occurred. Distinguish case verdict from workflow-level status.

Uploader PASS never substitutes for Route Planner PASS. A Route Planner mandatory multi-point case must PASS before relevant IP-6 consumer acceptance can PASS. Any mandatory case with FAIL, BLOCKED, INCONCLUSIVE or NOT TESTED prevents aggregate consumer PASS. Results apply only to the exact recorded Windy interface, date, platform, browser and observed version. A changed interface requires workflow requalification. One-point is a separate compatibility observation and cannot overturn G3-004.

## 7. Publication, privacy and evidence handling

Keep these events separate, each with its own affirmative user action where applicable:

1. **Local GPX generation** — no Windy transfer.
2. **Route-content confirmation** — confirms the user's intended transformed route/output.
3. **Consent to upload to Windy** — distinct, explicit consent immediately before any future external transfer; route confirmation is not upload consent.
4. **Windy import** — actual transfer/import in the authorized empirical test.
5. **Sharing/publication** — separate operation and consent. IP-6 testing stops before it.

Use synthetic data only. Do not store account identifiers, email, profile details, personal screenshots, real route contents, source file paths, access tokens, credentials, or private route digests. Screenshots, if essential, must contain synthetic data only and be cropped/redacted to remove unrelated account/weather/location content; prefer a written observation record. Hashes are allowed only for synthetic GPX test artifacts. Keep evidence in the approved non-sensitive location and do not commit sensitive captures.

## 8. Reusable test record

```text
Test ID / workflow (Uploader or Route Planner):
Test status: NOT TESTED | IN PROGRESS | COMPLETE
Synthetic fixture ID / GPX SHA-256:
GPX 1.1 validation status / validator / schema identity:
Test UTC date and time:
Windy product / exact URL / observed entry point:
Browser and version / OS and version / platform:
Account state (signed in/out only) / network state:
Expected behavior:
Expected ordinal point table reference:
Observed behavior:
Import result and user-visible object classification:
Editable Route Planner route? Evidence:
Waypoint count and verified order:
Route name / waypoint names:
First and last coordinates / coordinate comparison evidence:
Geometry/rendering observations (separate from route data):
Truncation, reorder, normalization, mutation or dropped data:
Paraphrased error/warning:
Publication/share action reached? (must be No):
Supporting evidence reference (synthetic/privacy-safe only):
Deviation class: none | imported-data mutation | routing semantics | display-only | unknown
Outcome: PASS | FAIL | BLOCKED | INCONCLUSIVE | NOT TESTED
Reproduction steps:
Retest required and trigger:
Second reviewer / review date:
Limitations and tested-version scope:
```

## 9. IP-1F protocol-design acceptance and blockers

| Criterion | Result |
|---|---|
| Separate ordinary Uploader and Route Planner procedures; no false equivalence | PASS — procedures and independent evidence rules defined; current UI entry labels remain to verify |
| All requested synthetic profiles, including separate one-point case | PASS — case IDs and mandatory/informative roles recorded |
| Objective observations and order/coordinate verification | PASS — supported visible list/export required; missing evidence cannot pass |
| Explicit verdicts, strict mandatory aggregate, bounded claims | PASS — PASS/FAIL/BLOCKED/INCONCLUSIVE/NOT TESTED rules defined |
| Route confirmation, upload consent, import and publication boundaries | PASS — separated; future test stops before sharing/publication |
| Privacy-safe reusable evidence template | PASS — synthetic-only, no personal/account/private route details |
| Current Route Planner entry point verified without interaction | **OPEN** — exact current UI not established by reliable current instructions; explicitly `TO VERIFY DURING IP-6` |

**IP-1F verdict: PASS (protocol design only).** The open live-UI discovery is a named IP-6A prerequisite, not a claim that the current workflow or any GPX file is accepted. No Windy upload/import or compatibility test was performed. IP-1G onward, IP-2–IP-7 execution, production implementation and release remain **NOT AUTHORIZED**. IP-1 as a whole is not declared PASS.

## 10. Dependencies and references

- Approved IP-1 plan §9 / IP-1F defines this protocol artifact and prohibits IP-1 upload.
- Approved IP-6 plan §§3–6, 8–13, 15–17 owns live workflow discovery, synthetic evidence, interpretation and future aggregate verdict.
- `docs/research/IP-1/GPX-1.1-CONTRACT.md` defines output semantics and states that consumer behavior remains untested.
- `docs/implementation/GATE-3-RECONCILIATION-R1.md` decision ledger: G3-004 one-point `ALLOW_WITH_WARNING`; G3-008 requires mandatory multi-point Route Planner PASS and keeps one-point separate.
- [Windy editorial GPX article](https://www.windy.com/articles/40059) — current general import/display context, not exact Route Planner procedure.
- [Windy Staff Route Planner announcement](https://community.windy.com/topic/9013/windy-launches-route-planner/179) — historical entry-point descriptions; re-verify manually during IP-6A.
