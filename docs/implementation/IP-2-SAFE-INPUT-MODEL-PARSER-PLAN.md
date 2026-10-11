# IP-2 — Safe Input Model and Parser: Detailed Implementation Plan

**Status:** Approved Gate 2 plan; Gate 3: PASS / ARCHITECT ACCEPTED at reviewed reconciliation commit f98f43618ad69c347fc8a071d741b9719714b934. Gate 4: NOT AUTHORIZED. Stage execution: NOT AUTHORIZED. Overall implementation: NOT AUTHORIZED.

**IP-2 execution:** NOT AUTHORIZED. **Overall implementation:** NOT AUTHORIZED.
**Baseline:** Gate 1 d57d0935c7885eb25eb14542e7996839644e96e2; approved IP-1 plan 6ed649d3995f70fa2421e08cb027c07d19b4cad4.

Future-work plan only. No parser, model, fixture, test, schema, dependency, CLI or Shortcut is created. Numeric limits below are evaluation proposals, not approved product limits.

## 1. Objective and scope

Define an offline ingestion boundary for one uncompressed RTZ XML file. It dispatches only an exact qualified version/namespace pair, validates against its exact local schema under IP-1’s licensing/runtime decision, applies separate semantic checks, and returns an immutable source-ordered route model with bounded diagnostics and metadata/loss summaries.

Included: safe local file read, strict XML parsing, version dispatch, schema-validation boundary, semantic validation, immutable model, diagnostics, and synthetic tests mapped to IP-1.

Excluded: GPX, route modes/transforms, geometry/distance, route repair, CLI, Shortcuts/Finder UI, packaging, Windy, real routes, and RTZP/ZIP extraction.

## 2. Upstream contracts and blockers

The approved Master Plan is primary. IP-1 is the upstream contract, but its execution has not qualified schemas, cleared a runtime, or created fixtures. Conditional inputs must not be treated as frozen.

| Contract | Owner/evidence | State | Closure and implementation impact |
|---|---|---|---|
| RTZ 1.0/1.2 exact namespace/schema pairs | IP-1A provenance/hash, structural review, positive/negative evidence, independent sign-off | Mandatory targets; qualification pending | Freeze only from IP-1A evidence; blocks dialect acceptance until qualified. |
| RTZ 1.1 | IP-1A named lineage/schema/fixtures | Conditional, nonblocking | May remain unsupported; reject unless qualified. |
| Schema rights and offline runtime | IP-1A/IP-5 legal clearance or reviewed lawful offline schema-backed alternative | Unresolved | Blocks implementation/release; validation cannot be weakened or omitted. |
| Synthetic fixtures | IP-1B catalog, expected outcomes, hashes and privacy review | Planned, absent | Map test cases only after catalog approval. |
| XML API/runtime | IP-2A candidate-OS evidence; IP-1E package constraints | Foundation XMLParser candidate only | Security and resource behavior must be demonstrated. |
| Field semantics | IP-1A field matrix/spec evidence; Master Plan incoming-leg rule | Partly specified | Unresolved semantics block model freeze. |
| CLI and UI handoff | Future IP-5/IP-7 plans | Not frozen | Parser/model remain independent; no consumer implementation here. |

Schema qualification, licensing/runtime, fixture outcomes, coordinate boundary qualification, and source-reference continuity are explicit blockers. The approved Gate 3 decisions are recorded in this plan’s reconciliation section; do not silently select an implementation mechanism.

## 3. File ingestion and threat controls

Production accepts one selected local file reference only; no URL, archive, multi-file input, or arbitrary inline XML. Treat all input as untrusted.

### Pipeline

1. Receive one opaque local-file reference. Its path and contents remain untrusted until securely opened and validated. Origin from Finder, Shortcuts, or CLI does not bypass checks. Reject directories, devices, FIFOs and sockets; extension is a hint only.
2. Distinguish unsafe path-based symlink traversal from legitimately user-selected files. Do not categorically reject a selected alias/symlink before IP-2A/IP-5/IP-7 establish macOS reference behavior. Open through the selected reference/security-scoped API where applicable, inspect the resulting descriptor, and read from that same descriptor without unsafe path reopening. Compare file identity and relevant metadata across the read. A path swap must not redirect the opened descriptor. Any permitted resolution must be explicit, bounded, and resistant to replacement; if safety cannot be established, fail closed.
3. Enforce the byte limit from file metadata and during reads; read at most limit plus one byte. Avoid duplicate whole-file buffers. Path normalization is not a security boundary.
4. Parse strict encoding/XML characters, without lossy decoding, repair, or recovery mode.
5. Enable namespace processing; prohibit DTD/entity resolution; never process XInclude; ignore input schema hints; disable network/catalog access. Abort on any external-resolution request.
6. Detect exact root expanded name and literal version; dispatch only to a qualified pair.
7. Validate using that pair’s exact local schema and closed dependency set.
8. Perform separate semantic validation. Build a model only if no fatal errors exist.
9. Return immutable model plus warnings, or errors with no partial route.

For G3-003, the final export invocation must reacquire authorized file-reference access, securely reopen the RTZ and rerun this exact validation pipeline before recomputation. A path or confirmation token alone cannot establish identity or content continuity. IP-2A/IP-5D/IP-7 jointly qualify a privacy-preserving comparison of filesystem identity and material route-content state; no full RTZ digest is calculated by default. If continuity cannot be established, fail closed and require a fresh preview and route confirmation. This requirement does not select or claim a proven macOS mechanism.

### Threat controls

| Threat | Control and future evidence |
|---|---|
| XXE, DTD, external/general/parameter entities | DTD forbidden, no resolver, substitution disabled, abort on declaration/resolution; synthetic tests prove no file disclosure/network. |
| Entity expansion | Reject DTD before expansion; input/parser caps and bounded adversarial tests. |
| XInclude | Never invoke it; reject or summarize only if qualified schema permits. Never read referenced resources. |
| External schema resolution | Ignore input schemaLocation; exact local allowlist, deny-all external resolver and closed imports. |
| Deep/large XML, node/text/attribute floods | Enforce streaming event counters during parse and abort at caps. |
| Malformed XML/invalid Unicode | Strict parser, no replacement/recovery; safe error mapping. |
| Oversize input/unbounded memory | Bounded descriptor reads; streaming preferred; measure time/peak memory. Tree parsing only with evidence of headroom. |
| Unsafe path-based symlink traversal or replacement race | Treat path/content as untrusted; distinguish unsafe traversal from Finder/Shortcuts-selected aliases/security-scoped URLs. IP-2A/IP-5/IP-7 jointly decide alias, scope, permission and identity behavior. Any permitted resolution is explicit/bounded and reads one descriptor without reopening a path. Test selected alias, unsafe traversal, replacement, nonregular and unreadable files. |
| ZIP/RTZP | Detect common ZIP signature; unsupported-container error; never decompress or extract. |
| Network | No URL entry, resolver, catalog, XInclude or schema fetch; verify offline and resolver denial. |
| Confidential logging | No full path, coordinates, waypoint names, raw XML, vessel metadata or username in default logs/messages; test with synthetic sentinels. |

### Resource-limit proposals

Evaluation starting points only: source 16 MiB; depth 64; element count 250,000; waypoint count 20,000; attributes per element 64; single text/attribute 4 KiB; total text 8 MiB; parse budget 5 seconds on lowest candidate Mac; diagnostic cap 100. **None is approved.**

IP-2A must measure sanitized ordinary and upper-bound IP-1B inputs plus adversarial cases. Record sizes/counts, elapsed time, peak memory, OS/build/CPU, parser version/options, and enforcement point. Justify each cap with realistic-route headroom and acceptable resource use; test cap−1, cap, cap+1. If a resource (especially process RSS) cannot be bounded, document that limitation; do not promise a hard bound. Measure cancellation latency and check during reads/callbacks. No proposal becomes a code constant without review.

## 4. XML parsing and schema validation architecture

**Candidate parser:** Foundation XMLParser, event-based and namespace-aware. Apple documents namespace reporting, delegate parse/error events, line/column, abort, and external-entity policy. Candidate settings: set shouldProcessNamespaces true; prefixes off unless field evidence requires them; shouldResolveExternalEntities false and the SDK's deny-resolution policy where available; install rejecting declaration/resolution handlers; abort on DTD/entity; recovery off. Verify exact API behavior on each candidate OS. These settings do not by themselves prove security or enforceable resource caps.

XMLDocument is not the default: Apple describes an in-memory logical tree, notes initializers read external XML sources, and documents validate() without establishing a secure XSD workflow. Do not infer secure XSD behavior from that method; tree use requires measured memory headroom.

Parsing, schema validation, and semantic validation are separate layers. Verify Foundation local XSD support and resolver controls. If insufficient, evaluate a self-contained pinned validator with a per-context deny-all external loader, no network/catalog, entity substitution, DTD loading/validation, XInclude, decompression, recovery, or relaxed huge mode. libxml2 is only a candidate: docs note XML_PARSE_NO_XXE exists since 2.13.0, XML_PARSE_NOENT enables entity substitution/external loading, and NONET behavior varies by version. A single flag is not security evidence.

Any schema/runtime must pass IP-1 technical qualification and separate legal clearance. No schema is downloaded or vendored here. If a lawful offline schema-backed fail-closed strategy is unavailable, return RTZ_SCHEMA_UNAVAILABLE; never accept well-formed-only XML as qualified.

Trust flow: FileReference → BoundedInput → XMLStructure → ExactDialect → SchemaValidatedStructure → SemanticValidation → immutable RouteDocument and Diagnostics. If schema failure prevents safe field interpretation, stop semantic checks. A minimal root/version sniff is permitted only for local schema selection/error category, not model construction.

## 5. Exact version/dialect handling

Dispatch key is exact root expanded name plus literal unmodified version; root local name exactly route; namespace URI exact and case-sensitive. No trimming, aliases, normalization, guessing, prefix matching, vendor fallback, or input-selected schema. The 1.2 URI comes only from IP-1A and is intentionally not assumed here.

| Observation | Result |
|---|---|
| Missing/unknown/unqualified version, including unqualified 1.1 | Fatal RTZ_UNSUPPORTED_VERSION; no inference/fallback. |
| Recognized version with wrong/unknown namespace | Fatal RTZ_NAMESPACE_MISMATCH or unsupported dialect. |
| Qualified pair with missing/unlicensed schema | Fatal RTZ_SCHEMA_UNAVAILABLE. |
| Well-formed but XSD-invalid | Fatal RTZ_SCHEMA_INVALID; no model. |
| Schema-valid but semantic-invalid | Fatal RTZ_SEMANTIC_INVALID. |
| Unknown vendor dialect/extension | Fail closed unless qualified schema permits bounded extension content; summary only. |
| Conflicting schemaLocation | Ignore as authority; use local registry or fail unavailable. |
| ZIP/RTZP | Unsupported container; no extraction. |
| Multiple roots/trailing content | Malformed/invalid document. |

1.0 and 1.2 are mandatory targets subject to qualification; 1.1 is conditional and nonblocking. No pair is claimed implemented or verified before evidence and tests.

## 6. Immutable model

Proposed domain concepts, not frozen Swift signatures:

- RouteDocument: RouteIdentity, SourceProvenance, QualifiedDialect, ordered waypoints, route metadata, unsupported-content summaries, warnings.
- RouteIdentity: optional route name and ID.
- QualifiedDialect: literal version, namespace URI, schema digest.
- SourceProvenance: minimal processing provenance such as byte count; no source filename or source-file digest by default. File identity used to secure an active read is ephemeral processing state, not persisted route provenance.
- Waypoint: ID, optional name, WGS84Position, optional IncomingLeg, metadata.
- WGS84Position: finite latitude/longitude degrees.
- IncomingLeg: GeometryKind and metadata.
- GeometryKind: QualifiedKnown or UnknownLiteral.
- RecognizedMetadata: qualified field and typed value.
- UnsupportedItemSummary: optional namespace, local name, count, reason.

Use immutable value types/collections; construction restricted to validated builder. No parser, serializer, CLI or UI types escape. Waypoint order is XML order and independent of IDs; never sort by ID. Required/unique ID rules come from qualified dialect; never invent IDs. Preserve absent names distinctly. Coordinates are a pair; a missing component is fatal; never clamp, wrap, round or infer datum. A leg belongs to its destination waypoint as incoming leg under the Master Plan; the first normally has none, with schema evidence controlling exceptions. Never shift or synthesize. Optional absence is not zero/default geometry/assumed unit. GeometryKind.UnknownLiteral is preserved only as uninterpreted source metadata; it must never drive navigation, distance, selection, or transformation. IP-3 may use only explicitly qualified geometry types. If the qualified dialect/schema prohibits the literal, parsing fails closed; never fall back to Loxodrome or Orthodrome. Recognized metadata is limited to IP-1’s field matrix; unknown extensions become bounded summaries, not opaque XML. Provenance excludes full paths/payload. Decimal representation must preserve precision; exact wrapper remains open.

Source-file digest calculation is opt-in, not default provenance. By default, do not calculate or persist a full RTZ digest and never expose a source hash in diagnostics, logs, CLI output, or Shortcut messages. IP-2A may propose digest use only for a documented technical need, privacy review, and explicit approval. Mandatory schema-artifact hashes used for qualification are separate and unaffected. Under G3-005 preserve numeric +180° if the qualified RTZ dialect accepts it; never wrap it. GPX representation remains an IP-4 qualification and must fail closed if exact valid serialization cannot be established.

## 7. Semantic validation

Rules must derive from qualified schema/spec or Master Plan; undocumented behavior remains open and blocks freeze.

| Condition | Proposed result |
|---|---|
| Latitude outside −90..+90 or longitude outside −180..+180 | Fatal semantic invalid, or schema invalid when XSD catches it; no clamp/wrap. |
| Missing component, malformed or nonfinite coordinate | Fatal; schema and semantic layer distinguished. |
| Duplicate waypoint ID | Fatal only if qualified rule requires uniqueness; otherwise unresolved. |
| Consecutive duplicate positions | Warning, preserve both; equality semantics need review. |
| One valid point | Valid parsed model; no parser-level minimum-useful-route failure. G3-004 permits GPX export with warning and explicit confirmation; IP-4 owns serialization eligibility, IP-7 owns user confirmation, and IP-6 tests Windy compatibility separately. |
| Missing/invalid geometry | Fatal if required; otherwise warning/explicit absent or unknown; no default. |
| Invalid optional radius/XTD/speed/schedule | Schema fatal for XSD violation; semantic fatal only with reviewed rule; otherwise warning and invalid/loss state. Never silently drop recognized bad metadata. |
| Unexpected waypoint/leg relation | Fatal per qualified content model; never reorder/synthesize. |
| Unknown extension under wildcard | Bounded loss warning; otherwise fail closed, no opaque payload. |
| Route discontinuity | No parser geometry decision; only report spec-defined structural inconsistency. |
| XSD-invalid / schema-valid semantic-invalid | Distinct fatal codes; no partial model. |

Warnings never alter positions, order, names, metadata, leg ownership or route intent.

## 8. Diagnostics

Proposed IDs until reconciled with IP-5: INPUT_NOT_FOUND, INPUT_UNREADABLE, INPUT_INVALID_TYPE, INPUT_TOO_LARGE, INPUT_CHANGED_DURING_READ, XML_MALFORMED, XML_UNSAFE, XML_INVALID_ENCODING, RTZ_UNSUPPORTED_VERSION, RTZ_NAMESPACE_MISMATCH, RTZ_SCHEMA_UNAVAILABLE, RTZ_SCHEMA_INVALID, RTZ_SEMANTIC_INVALID, RTZ_UNSUPPORTED_DIALECT, RTZ_RESOURCE_LIMIT, CANCELLED, INTERNAL_ERROR.

Each has stable code, severity, safe message, optional qualified field path, optional 1-based waypoint ordinal, reliable line/column if available, and optional safe recovery hint. Do not expose coordinates, names, raw XML, full paths, username, schema path, or source-file hashes.

Order by phase (input, XML, dispatch, schema, semantic), reliable source position, then code/field; otherwise preserve encounter order. Deduplicate identical code/field/position. Fatal errors stop later phases and suppress cascades. Proposed cap 100 (first 99 plus DIAGNOSTIC_LIMIT_REACHED) requires validation before freeze. Cancellation returns no model. IP-5 owns CLI result/exit mapping; identifiers remain proposals.

## 9. Internal interfaces and handoffs

Proposed language-neutral boundaries:

- InputLoader.read(FileReference, Limits, Cancellation) → Result<BoundedInput, Diagnostics>
- DialectDetector.detect(XMLRootSummary, Registry) → Result<QualifiedDialect, Diagnostics>
- XMLReader.parse(BoundedInput, SecurityPolicy, Limits, Cancellation) → Result<ParsedStructure, Diagnostics>
- SchemaValidator.validate(ParsedStructure, QualifiedDialect, LocalSchemaRegistry) → Result<SchemaValidatedStructure, Diagnostics>
- RTZSemanticValidator.validate(SchemaValidatedStructure, Rules) → Result<SemanticallyValidatedStructure, Diagnostics>
- RouteModelBuilder.build(SemanticallyValidatedStructure, ProvenancePolicy) → Result<RouteDocument, Diagnostics>
- RTZParser.parse(FileReference, Configuration, Cancellation) → ParseResult<RouteDocument>

Success is immutable model plus warnings; failure contains errors only. FileReference is an opaque local-file reference, not a trust assertion: its path and contents remain untrusted until securely opened and validated. It is not a URL. One parse owns context; cancellation is cooperative/thread-safe; no global resolver/catalog. Tests may inject synthetic bounded bytes; production remains file-only. Identical bytes/config yield identical semantic model and diagnostic ordering. No GPX/navigation API.

IP-3 consumes ordered WGS84 points/IDs/names/incoming legs, but adds transformations separately. IP-4 consumes validated data and metadata/loss inventory, and owns GPX. IP-5 owns CLI arguments/stdout/stderr/exit; IP-2 supplies parse results and safe diagnostics. IP-7 owns prompts/presentation and consumes safe summary/errors.

IP-6 does not consume parser internals: its synthetic Windy acceptance input comes from the IP-4 GPX contract/output, with the IP-1F protocol. IP-2 must not provide real route data to IP-6.

## 10. Future synthetic test matrix

Planning only; map to IP-1B fixture IDs later. No fixtures/tests created or run.

| Case | Expected category | Invariant/evidence |
|---|---|---|
| Valid qualified 1.0/1.2 | Success | Exact pair/schema digest; model matches manifest. |
| Unqualified 1.1, unknown/missing version | Unsupported | No fallback or model. |
| Wrong/vendor namespace, hostile schemaLocation | Mismatch/unsupported | Exact dispatch; no fetch. |
| Well-formed XSD-invalid/schema-valid semantic-invalid | Distinct schema/semantic failure | No partial model or repair. |
| DTD, XXE, parameter entity, expansion attack | Unsafe/resource limit | No local disclosure/network; bounded resources. |
| XInclude/hostile schema imports | Unsafe/unsupported | No inclusion/external request. |
| File/depth/node/text/attribute/waypoint caps at −1/exact/+1 | Success/resource failure per approved cap | Enforcement evidence. |
| Missing/nonnumeric/nonfinite/out-of-range coordinate | Schema/semantic invalid | No defaults/clamp/wrap. |
| Duplicate ID/equal consecutive positions | Frozen fatal/warning policy | Preserve both/order. |
| Empty/one-point route, missing/unknown/mixed geometry | Contract-specific | No invented point/type; correct incoming leg. UnknownLiteral is uninterpreted metadata only; if the qualified dialect prohibits it, fail closed. |
| Invalid/absent optional metadata | Schema/semantic/warning | Absence != zero; loss explicit. |
| Unknown extension | Bounded summary or fail closed | No payload retention. |
| Unicode/XML escaping | Success when valid | Safe values; no sentinel log echo. |
| Antimeridian/high latitude | Success | Coordinates unchanged; no geodesy. |
| Malformed bytes/XML/extra root | Malformed | No recovery/partial result. |
| Missing/unreadable, unsafe path traversal, user-selected alias, nonregular/swapped file | Input error or reviewed selected-reference outcome | IP-2A/IP-5/IP-7 settle API/permissions; bounded resolution, descriptor identity, and no unsafe reopening. |
| ZIP/RTZP | Unsupported | No decompression. |
| Offline run/sentinel resolver | Success or fail closed | Zero external requests. |
| Repeated parse/cancel/diagnostic flood | Deterministic/cancel/resource | Stable output, bounded latency/cap, no model on fatal. |

## 11. Future implementation sub-stages

Paths are proposals against the current documentation-only tree; none exists.

### IP-2A — Upstream contracts and feasibility
- **Objective:** close dependencies; evidence candidate parser, limits, security and semantics.
- **Scope/exclusions:** decision records only; no code/schema/fixtures/tests.
- **Files:** docs/research/IP-2/INPUT-AND-SECURITY-DECISIONS.md; docs/research/IP-2/RESOURCE-LIMITS.md; REPORT.md; PROGRESS.md.
- **Dependencies:** IP-1A/B, lawful offline schema runtime, field matrix, candidate macOS; coordinate file-reference behavior with IP-5 and IP-7.
- **Interface:** deliver frozen SecurityPolicy, Limits, QualifiedDialectRegistry source, joint alias/security-scope/permission/identity policy, and source-digest decision to IP-2B onward.
- **Sequence:** review evidence; separately authorized bounded probe if needed; measure approved synthetic inputs; derive caps/rules.
- **Future cases:** API/security/encoding/resource probe only with specific authorization; test Finder/Shortcuts/CLI-selected files, aliases, security-scoped URLs, permissions, file replacement and identity.
- **Acceptance:** exact registry source, legal runtime, cap rationale/enforcement, reproducible security evidence, and jointly reviewed IP-2A/IP-5/IP-7 file-reference policy.
- **Risks:** undocumented alias or security-scope behavior; define exact probe/owner/blocker, allow only explicit bounded resolution, fail closed if identity cannot be maintained.
- **Rollback:** revert decisions and block dependents.
- **PASS evidence:** reviewed dependency matrix, licensing, measurements and execution authorization.

### IP-2B — Bounded input and strict XML reader
- **Objective:** safe descriptor read and namespace-aware parsing.
- **Scope/exclusions:** file boundary/XML/counters/cancellation; no schema/model.
- **Files:** Sources/RTZCore/Input/FileReference.swift; Sources/RTZCore/Input/BoundedInput.swift; Sources/RTZCore/Input/XMLSecurityPolicy.swift; Sources/RTZCore/Input/XMLStructureReader.swift; Tests/RTZCoreTests/InputSecurityTests.swift.
- **Dependencies:** IP-2A PASS and approved synthetic cases.
- **Interface:** provide BoundedInput and namespace-aware ParsedStructure plus input/XML diagnostics to IP-2C.
- **Sequence:** descriptor reader, streaming adapter, counters, safe errors, adversarial tests.
- **Future cases:** path traversal, selected alias/symlink, security-scoped access, permission denial, file replacement/identity, nonregular, XXE, XInclude, malformed encoding, floods, offline, cancellation.
- **Acceptance:** no resolution/network; bounded work; controlled errors; source unchanged.
- **Risks:** OS differences/buffering; verify candidate OS, no unsafe fallback.
- **Rollback:** revert reader/tests and reopen selection.
- **PASS evidence:** test report, time/memory, OS/runtime, security review.

### IP-2C — Exact dialect and schema adapter
- **Objective:** dispatch exact qualified pair and validate locally.
- **Scope/exclusions:** registry/adapter; no acquisition absent clearance or semantic repair.
- **Files:** Sources/RTZCore/Validation/QualifiedDialect.swift; Sources/RTZCore/Validation/LocalSchemaRegistry.swift; Sources/RTZCore/Validation/SchemaValidator.swift; Sources/RTZCore/Validation/DialectDetector.swift; Tests/RTZCoreTests/SchemaDispatchTests.swift.
- **Dependencies:** IP-2A/B; IP-1A pair/hash/rights/runtime; IP-1B. Unresolved mandatory schema/license blocks.
- **Interface:** provide exact QualifiedDialect and SchemaValidatedStructure, keeping schema diagnostics distinct, to IP-2D.
- **Sequence:** reviewed allowlist, sealed resolver, validate, separate schema errors, reject unknown pairs.
- **Future cases:** 1.0/1.2, optional 1.1, crossed pair, missing schema, hostile import, invalid schema, offline.
- **Acceptance:** exact pairs, no external load, unavailable schema fails closed.
- **Risks:** Foundation XSD/rights insufficient; reviewed lawful alternative or block.
- **Rollback:** remove adapter, mark dialect unavailable; never accept merely well-formed XML as qualified.
- **PASS evidence:** hashes/licensing, offline positives/negatives, resolver denial, review.

### IP-2D — Semantic validation and immutable model
- **Objective:** map validated source order into typed values and metadata summaries.
- **Scope/exclusions:** model/validation; no transformations/geodesy/GPX.
- **Files:** Sources/RTZCore/Model/RouteDocument.swift; Sources/RTZCore/Model/Waypoint.swift; Sources/RTZCore/Model/WGS84Position.swift; Sources/RTZCore/Model/RTZMetadata.swift; Sources/RTZCore/Validation/RTZSemanticValidator.swift; Sources/RTZCore/Validation/RouteModelBuilder.swift; Tests/RTZCoreTests/RouteModelTests.swift; Tests/RTZCoreTests/SemanticValidationTests.swift.
- **Dependencies:** IP-2A–2C, IP-1A semantics/IP-1B, precision/duplicate/minimum-count rules.
- **Interface:** provide immutable RouteDocument and warnings to IP-2E and the documented downstream consumers.
- **Sequence:** immutable types; map order/incoming legs; validate fields; preserve optionals/unknowns; bounded summaries.
- **Future cases:** semantic matrix, ID-vs-order, mixed geometry, optionals, repeated parse.
- **Acceptance:** no invented/default values; exact order/coordinates; correct leg; no model on fatal error.
- **Risks:** ambiguous spec/precision; stop for evidence.
- **Rollback:** revert model/validator and reopen contract.
- **PASS evidence:** fixture trace, invariants, tests and semantic review.

### IP-2E — Diagnostics, parser facade and closeout
- **Objective:** compose internal API and downstream handoff.
- **Scope/exclusions:** facade/diagnostics only; no CLI/UI/GPX/package/IP-3–IP-7 plans.
- **Files:** Sources/RTZCore/RTZParser.swift; Sources/RTZCore/Diagnostics/Diagnostic.swift; docs/research/IP-2/PARSER-API-AND-DECISIONS.md; REPORT.md; PROGRESS.md.
- **Dependencies:** IP-2A–2D; later IP-5/IP-7 cross-check.
- **Interface:** expose ParseResult<RouteDocument> with stable candidate diagnostics; IP-5/IP-7 own external presentation/protocol.
- **Sequence:** compose phases; lock ordering/cap/redaction; cancellation/thread rules; trace handoffs/privacy.
- **Future cases:** order/cap/cancel/concurrency and sanitized consumer boundary.
- **Acceptance:** controlled errors, deterministic result, no partial model, documented handoff.
- **Risks:** downstream mismatch; IDs provisional until cross-check.
- **Rollback:** revert facade and block dependents.
- **PASS evidence:** test/privacy/trace evidence and independent architecture acceptance.

## 12. Invariants

1. Never alter coordinates or reorder source waypoints.
2. Never make navigational decisions or calculate route/distance/leg geometry.
3. Never guess unknown geometry.
4. Keep schema and semantic validation distinct.
5. Unsupported/unqualified dialects fail closed.
6. No network, external entities, XInclude or remote schema.
7. No real routes/derived positions in Git absent authorization.
8. No GPX, CLI, Shortcut UI or packaging.
9. Every mandatory failure has a controlled privacy-safe diagnostic.
10. Fatal errors return no partial usable model.
11. Optional absence never becomes a misleading default.
12. Source RTZ remains read-only.

## 13. Acceptance criteria

**Planning acceptance:** complete architecture/threat boundary/parser and schema evaluation/model/semantics/diagnostics/API/matrix/sub-stages/dependencies; unknowns explicit; Master Plan and IP-1 unchanged; no implementation artifacts.

**Future execution PASS (not claimed):** qualified 1.0/1.2 exact pairs use legally cleared offline schema validation; 1.1 may remain unsupported; security/file/resource/cancellation tests pass on approved OS/runtime; schema and semantic errors are distinct; synthetic model invariants and deterministic diagnostics pass; fatal inputs yield no model; offline/privacy evidence and independent review recorded.

## 14. Open questions and owners

1. Foundation XMLParser DTD/entity refusal, depth/text bounds, cancellation: IP-2A; authorized probe if docs insufficient.
2. Foundation local XSD/resolver controls or lawful self-contained validator: IP-1A/IP-5/IP-2A; blocks IP-2C.
3. Exact qualified 1.0/1.2 pairs, hashes, dependencies and rights: IP-1A; 1.2 URI not assumed.
4. Evidence-backed byte/node/depth/text/waypoint/time limits: IP-2A; proposals unapproved.
5. ID uniqueness and minimum useful point count: IP-1A/IP-2A.
6. Geometry literals, incoming-leg semantics and optional metadata rules: IP-1A/IP-2A.
7. Decimal representation/source precision: IP-1A/IP-2A/IP-4.
8. Extension summaries and optional source-digest privacy decision: IP-1A/IP-2A; no source digest by default, while schema artifact hashes remain required.
9. Joint IP-2A/IP-5/IP-7 decision on Finder/Shortcuts/CLI references, aliases, security-scoped URLs, permissions, identity and safe bounded resolution without unsafe reopening.
10. Stable diagnostics compatible with CLI/Shortcut: IP-2/IP-5/IP-7; never expose source hashes.

## 15. Governance and next process

Only this plan, REPORT.md and PROGRESS.md may change. Do not edit AGENTS.md, Master Plan, or IP-1. Do not create IP-3–IP-7 plans or execute IP-2.

Gate 3 reconciliation is accepted at f98f43618ad69c347fc8a071d741b9719714b934. Address any future IP-2 review findings through the owning review process; obtain explicit Gate 4 authorization naming the stage and any probe/schema/dependency acquisition; then execute one stage at a time. Plan approval authorizes no code, tests or probes.

## 16. References and evidence

Apple documents XMLParser as event-driven with namespace reporting, parse errors/positions, abort and external-entity policy: [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser), [XMLParserDelegate](https://developer.apple.com/documentation/foundation/xmlparserdelegate). Apple describes XMLDocument as a logical tree, notes initializers read external XML sources, and documents validate() without establishing a secure XSD workflow: [XMLDocument](https://developer.apple.com/documentation/foundation/xmldocument). These docs do not prove target-OS security behavior.

libxml2 documents security-sensitive flags, including XML_PARSE_NO_XXE availability by version, entity substitution/loading, and version-dependent NONET: [parser options](https://gnome.pages.gitlab.gnome.org/libxml2/html/parser_8h.html). This does not select libxml2 as runtime.

Policy: [approved Master Plan](../RTZ-GPX-PLAN.md), [approved IP-1 plan](IP-1-STANDARDS-FIXTURES-INTEGRATION-PLAN.md). No parser behavior, schema/runtime, limit or OS compatibility is claimed tested or implemented.
