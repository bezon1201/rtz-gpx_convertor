# IP-5 — Stable Local Swift CLI and Self-contained Runtime: Detailed Implementation Plan

**Plan status:** Approved Gate 2 plan. Effective Gate 3 status: PASS / ARCHITECT ACCEPTED at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 authorization is stage-specific and never blanket authorization. IP-5 execution and overall implementation remain NOT AUTHORIZED.
**IP-5 execution:** NOT AUTHORIZED.
**Overall implementation:** NOT AUTHORIZED.
**Planning branch:** `docs/ip-5-cli-runtime-packaging`.
**Planning baseline:** Gate 1 `d57d0935c7885eb25eb14542e7996839644e96e2`; IP-1 `6ed649d3995f70fa2421e08cb027c07d19b4cad4`; IP-2 `8011d3f0c4baf62cb15194ab9308f4e312269615`; IP-3 R1 `8e35edff864de87278aa7c61c7376e49845c3d74`; IP-4 R1 `34f067112187a4c755f5c4cc94d5b6f36cfae1ae`.

This is a Gate 2 plan for an internal Swift command-line engine, primarily invoked by macOS Shortcuts. It creates no application or support code, script, test, probe, fixture, schema, dependency, binary, GPX, package or Shortcut. Product execution remains unauthorized.

## 1. Purpose, scope and authority

IP-5 defines a stable local protocol and owns process/runtime integration and the actual filesystem writer. It connects the user-confirmed Shortcut flow to the IP-2 parser, IP-3 route-mode domain, and IP-4 GPX serializer/validator. It does not decide navigation intent or create another user interface.

V1 constraints:

- Apple Silicon macOS; minimum supported macOS remains provisional until IP-1D/IP-1E evidence and later authorized platform tests.
- Native Swift executable. No target-Mac Python, Homebrew, Node.js, separately installed interpreter/runtime, Terminal workflow, daemon, background server, privileged helper, administrative conversion privilege or network service.
- Offline conversion, no telemetry/cloud processing, and no source RTZ modification.
- Shortcuts is the primary interaction surface. IP-7 owns UI, file picker, mode/waypoint selection, preview display, explicit consent, destination selection, overwrite consent, user feedback, and Finder reveal.
- IP-5 does not own route geometry. IP-3 computes candidates, validates confirmed commands and finalizes neutral transformations. Distance remains advisory only.
- IP-4 owns GPX construction, schema/semantic validation and export eligibility; it returns immutable validated bytes and a loss report. IP-5 alone owns writing those bytes to disk and reporting the final save outcome.

Status constraints inherited from approved plans:

- The earlier remote Gate 3 acceptance declaration is historical; effective Gate 3 is PASS / ARCHITECT ACCEPTED at the approved baseline. None of IP-1–IP-4 has execution PASS evidence.
- G3-001 approves an export-only GPX route-name override or explicit omission; G3-004 approves one-point GPX export with warning and explicit confirmation. IP-5 transports and enforces these decisions but does not change source route data.
- No mandatory RTZ dialect is advertised as supported until IP-1 qualification evidence exists. RTZP remains out of scope.
- Never treat a Finder, Shortcuts or CLI file reference as trusted. Paths and content remain untrusted until IP-2 securely opens and validates them.

## 2. Architecture and module boundaries

Proposed layers; exact Swift package/target layout is provisional pending IP-1 packaging and IP-2 runtime qualification:

1. **Protocol decoder/encoder:** strict, versioned JSON envelopes; bounded input size; no filesystem or route semantics.
2. **Request validator and dispatcher:** action/mode/version/capability validation; maps stable protocol fields to typed application requests.
3. **Reference broker:** adapts the approved short-lived input/output file capability to IP-2/IP-5 reference interfaces. It never promotes an untrusted path string into trusted authority.
4. **Conversion orchestrator:** deterministic state machine coordinating IP-2 → IP-3 → IP-4; no duplicated parser, transformation, geometry, GPX or eligibility logic.
5. **IP-5 writer:** exclusive filesystem implementation for validated artifacts and optional loss sidecars, subject to the safe-publication rules in §8.
6. **Diagnostic mapper:** preserves upstream codes, severity and safe provenance; maps stable public protocol codes without copying raw XML or private payloads.
7. **Runtime manifest/resources:** version/capability metadata and only legally approved runtime resources. No resource or schema rights are assumed.

Keep core conversion domain libraries independent of Shortcuts and shell details. No GUI framework, persistence database, updater service, listener socket, IPC server or privileged process is planned. A process handles a finite request and exits.

## 3. Stable invocation and response protocol

### 3.1 Transport decision proposal

Use **one versioned JSON request on stdin and exactly one JSON response on stdout** as the proposed primary machine protocol. Use only fixed, non-sensitive argv elements to select the protocol entry point; route names, coordinates, reference payloads, selections, destination capabilities and overwrite consent never appear as shell-interpolated command text or sensitive argv values.

This is a proposal, not a frozen transport. IP-1D must qualify actual Shortcuts input preservation, process launch, stdin delivery, stdout/stderr capture, exit status, cancellation and file-reference access. Until those results exist, the plan leaves the reference carrier conditional. If JSON stdin/stdout or reference handoff is unreliable, stop and compare an explicitly launched Foundation.Process bridge or another tested transport. Do not silently switch to path interpolation or claim an untested Shortcuts action works.

| Transport | Benefits | Risks / decision |
|---|---|---|
| Discrete CLI arguments | Simple for fixed action names, protocol version, and capability flags; Foundation.Process passes an argv array without shell expansion. | User values in argv can appear in process inspection/logging and require strict boundaries. Use for fixed non-sensitive selectors only; never coordinates, names, paths, file URLs, consent tokens or route data. |
| JSON over stdin/stdout | Keeps request data out of argv; bounded and structured; one response can carry preview/result/error. | Must verify Shortcuts can preserve file objects/capabilities and capture streams and status without flattening, truncating or timeout. Proposed primary protocol, subject to IP-1D. |
| File-backed request/response envelope | Can accommodate transport limitations or larger previews. | More private data at rest, temporary-file races, cleanup and permission complexity. Not the default. Consider only with measured Shortcuts limits, private owner-only storage, atomic envelope creation, bounded lifetime and reviewed cleanup. |

### 3.2 Envelope and versioning

Proposed response/request envelope fields (exact schema is to be frozen only after IP-1D and cross-stage review):

- `protocol_version`: integer major version; version `1` is the initial proposal.
- `request_id`: random per-invocation correlation ID unrelated to input, route, source path or content digest.
- `action`: `capabilities`, `inspect`, `preview`, `confirm_export`, or `cancel`. In the proposed separate-invocation protocol, `cancel` abandons a pending UI flow and returns a no-op cancelled response; it cannot terminate a different active process. Active-process cancellation uses the qualified launcher’s signal/pipe-close behavior, which IP-1D must verify. Separate-invocation/stateless feasibility remains unqualified.
- `input_reference`: opaque reference object supplied by the approved bridge; no raw path is an authority.
- `mode`: `full_route`, `from_waypoint`, `current_direct`, or `current_join` where applicable.
- `selection`: explicit source-order waypoint/leg reference; current-position entered latitude/longitude; explicit next waypoint; explicit qualified connector geometry; and any approved export naming choice.
- `effective_gpx_route_name`: valid source name, explicit validated override, or explicit omission; independent from output filename.
- `route_confirmation`: explicit affirmative approval bound to source state, mode/selections/manual coordinates, connector geometry, resulting ordered route, effective GPX route name, warnings and metadata-loss disclosures.
- `preview_binding`: transient correlation/revision data for equivalence checks, never proof of source identity, content continuity or user approval by itself.
- `destination_reference`: separately authorized output capability, not a string pathname.
- `publication_consent`: separate affirmative approval bound to the exact confirmed GPX output and destination/filename/target identity/state; `overwrite_authorization` is exact-target permission within this separate boundary. Absence means no publication/replacement.

Response fields: `protocol_version`, `request_id`, `outcome`, `phase`, `capabilities` where requested, safe `diagnostics`, `preview` where requested, IP-4 `validation` and `loss_report`, and separate `save_result` when writing was attempted. User-facing preview/result data may contain coordinates/names required to display the selected transformation; these values must not be copied to logs or generic diagnostics. A successful save may return a display-only output reference/name for IP-7 to show or reveal; never include full paths in default diagnostics or logs.

G3-007 requires route confirmation and publication consent to remain distinct protocol concepts. A changed effective route name, geometry, source state, selection, coordinate, resulting route or material warning invalidates route confirmation and dependent publication consent. Destination/filename-only changes renew publication consent only; changed target identity/state renews publication consent. A stale/replayed token or button event cannot authorize either boundary. One-point export is allowed only with the IP-7 warning and affirmative confirmation represented in the confirmed request.

#### `inspect` action contract

`inspect` is a summary operation over the same securely acquired and validated input as conversion, not a lightweight content peek. It must receive an approved file reference, use IP-2 secure open and bounded read, exact dialect dispatch, schema validation and semantic model construction, and derive all route/waypoint summaries solely from the resulting immutable validated `RouteDocument`. It must not introduce another XML parser or path-based reader, infer route names/waypoint names/counts/identifiers from a filename, or bypass mandatory schema qualification. Finder, Shortcuts and CLI origins confer no trust.

Inspect output is bounded: cap returned waypoint entries, each name/label length, total response bytes, and diagnostics under evidence-based IP-2/protocol limits. The contract must specify either a structured `SUMMARY_LIMIT_EXCEEDED` error that does not represent an incomplete list as complete, or explicit stable pagination over the validated model; choose and qualify the strategy before freezing protocol v1. User-facing route details exist only in the transient response and never in default logs. The response may identify only route fields present in the validated model; it must not manufacture identifiers or names.

Use a strict, documented JSON encoding and field schema. Reject malformed JSON, duplicate/unknown required fields, invalid enum values, unsupported features and unsupported major protocol versions with a structured response when the stream permits. Additive evolution requires explicit compatibility rules and capability negotiation. A client must not infer that a capability exists from a version number alone. Unsupported protocol versions fail explicitly; no best-effort reinterpretation.

Capability reporting returns CLI version, protocol versions, build architecture, qualified RTZ dialects only, available actions, and required runtime-resource status. Policy targets are not reported as supported dialects without IP-1 execution evidence. Capabilities contain no host identity, source data, source digest or route details.

### 3.3 Stream, exit and determinism contract

- stdin: one bounded request envelope, one request per process. EOF terminates request input. No prompts or interactive terminal reads.
- stdout: exactly one machine-readable JSON response, no banner, progress text, debug logging, traceback or unstructured success output. UTF-8 and stable response schema.
- stderr: at most bounded, privacy-safe human diagnostics suitable for IP-7 capture. No raw RTZ/XML/GPX, route coordinates/names, vessel identity, source/output paths, sensitive identifiers or source-derived hashes. Detailed safe diagnostics live in the JSON response.
- Exit status: stable mapping proposal: `0` completed operation (success or a valid preview/capability response); `2` malformed/invalid request; `3` unsupported protocol/capability; `4` input reference/access/parse/schema failure; `5` mode/selection/geometry/confirmation failure; `6` GPX eligibility/serialization/validation failure; `7` output collision/permission/provider/write failure; `8` cancelled/interrupted with final state described in JSON; `70` unexpected internal failure. Exact mapping is provisional until IP-2/IP-3/IP-4 diagnostics are reconciled.
- A nonzero exit is never suppressed because a JSON response exists. A zero exit never substitutes for `outcome` and `save_result` fields. If stdout cannot be written, emit only a short safe stderr diagnostic and nonzero status.
- Identical request, model, qualified resources and approved settings produce the same semantic preview, diagnostics order, GPX bytes meaning and loss report. Request IDs may differ. Byte equality is only required if approved IP-1/IP-4 decisions demand it.
- Enforce byte/depth/item/time limits from IP-2 and protocol-specific caps chosen by evidence. Do not invent unreviewed route limits. Oversize requests fail before expensive parsing. Bound diagnostics and preview serialization.

`inspect` uses the same input-acquisition and IP-2 validation phases as every conversion action (§5). Response-size limits must not cause a separate parser, partial-validation shortcut, or filename-derived fallback.

## 4. Input-reference and file-access security boundary

### 4.1 Reference contract

All file references are opaque and untrusted until IP-2 securely acquires and validates the selected object. Their provenance from Finder, Shortcuts or direct CLI invocation does not bypass parser checks. A filename extension is a hint, not evidence. IP-5 does not duplicate IP-2 parsing or read a second path after IP-2 establishes descriptor identity.

The protocol must ultimately carry a **short-lived, process-usable access capability** whose open semantics and identity can be verified. Candidate carriers for IP-1D/IP-2A/IP-5/IP-7 qualification:

1. An already-open descriptor explicitly inherited by a trusted launcher, with ownership/descriptor-number contract and no path reopen.
2. A file URL/security-scoped bookmark or equivalent OS file-reference object passed through an API proven to preserve access into the receiving process; recipient resolves/starts access, securely opens once, and stops access after bounded processing.
3. A user-selected path only as an untrusted locator when policy permits opening it under the receiving process’s own access; it is not proof of selection, a security scope or content identity.

No assumption that security scope, bookmark authority or Finder selection crosses a process boundary automatically. Do not use a URL path as a trusted capability. If the chosen transport loses access or cannot retain selected-file identity, fail closed with actionable `INPUT_REFERENCE_UNAVAILABLE` / `INPUT_IDENTITY_UNVERIFIED`; request a supported local selection again. Do not persist source bookmarks or access grants beyond the conversion absent explicit need and privacy review.

### 4.2 Joint macOS policy

IP-2A, IP-5 and IP-7 must jointly specify and verify:

- Finder Quick Action file objects, native Shortcut picker results and no-input picker fallback.
- POSIX path vs file URL handling; file URL decoding exactly once; no shell interpolation; no treating a string as authority.
- Security-scoped URL/bookmark creation, process transfer, start/stop lifetime and cancellation cleanup.
- Alias and symlink treatment. Distinguish unsafe path-based traversal/reopening from legitimate user-selected aliases/security-scoped resources. No unconditional symlink rejection without feasibility evidence; permitted resolution must be explicit, bounded, identity-checked and resistant to replacement.
- File Provider/cloud-backed objects and local availability. Conversion itself makes no network request; if access triggers remote hydration or local content is not available offline, fail with a safe actionable error and require the user to make a local copy.
- Permissions, ACLs, regular-file checks, size limits, resource values, descriptor identity before/during/after bounded read, replacement races and file coordination behavior.
- Whether a Shortcut action can create/pass a reusable per-invocation file capability to the CLI. If not, evaluate an explicit, minimally scoped bridge; do not loosen security to make the UX appear to work.

The CLI/bridge passes IP-2 an opaque `FileReference`; IP-2 owns secure open, bounded reads, content/XML/schema/semantic validation and immutable model construction. IP-5 consumes only the validated `RouteDocument` handle/result and provenance required by IP-3/IP-4. Paths, input bytes and source-derived hashes remain out of default diagnostics and logs. No full RTZ digest is calculated by default.

## 5. Deterministic orchestration across IP-2/IP-3/IP-4

One request follows explicit phases with independent results:

1. Decode and validate the protocol envelope, version, action, required capabilities and bounded field sizes.
2. Acquire the supplied input capability securely; verify it names an eligible regular file and obtain the selected object identity. Preserve access only for the required operation lifetime.
3. Invoke IP-2 once for secure bounded parse, exact version/namespace/schema dispatch and semantic validation. Return fatal errors without a partial model. Unknown dialect/schema or invalid content fails; never infer from filename.
4. Retain the immutable source route model and source-order waypoint/leg references only for this process/request. No source route database or durable session is introduced.
5. Apply user-provided mode and selections. Full Route uses source order. From Waypoint requires a selected source-order waypoint. Current Position requires manual coordinate strings, explicit next waypoint, and explicit Direct to Next WP or Join Selected Route Leg choice; a join requires an explicitly selected leg and explicitly qualified connector geometry.
6. For a preview action, call IP-3 candidate/preview API and return its immutable ordered point sequence, geometry availability, warnings, endpoint/leg display information, provenance-safe references, and advisory distances separately. Never allow an advisory distance to choose or alter route construction.
7. For confirmation, obtain IP-3’s exact confirmed-command validation. A fresh process must reacquire the input using a newly authorized reference or separately qualified reusable capability, then perform a fresh IP-2 secure open and validation. Establish the same qualified source identity and content state under the approved IP-2/IP-5 identity contract, and reconstruct preview from the same selections and model/algorithm revision. Reject changed source content, selections or stale previews; return a new preview request rather than selecting replacements.
8. Only a finalized IP-3 `TransformedRoute` can be passed to IP-4. IP-5 cannot upgrade a preview/candidate into a final transform or suppress an IP-3 error.
9. Invoke IP-4 eligibility, GPX serialization, offline schema validation, semantic/representation-specific round-trip validation, and loss reporting. Respect the Gate 3 one-point policy and naming contract; IP-5 makes neither product decision.
10. Receive immutable validated GPX bytes and loss report. Reject absent/invalid validation status. No filesystem operation begins on failed serialization, eligibility or validation.
11. Write only through the IP-5 safe writer (§8), separately tracking GPX and optional sidecar results.
12. Return one structured response to IP-7. Distinguish transformation, schema, eligibility, serialization and save statuses. User-facing success requires actual GPX save success.

No layer may silently change the selected waypoint/leg, infer geometry, normalize coordinates, repair a route, suppress blocking validation, fabricate a point, change route name without the approved Gate 3 confirmation policy, or conflate preview with consent. Source RTZ remains unchanged in all outcomes.

## 6. Current-position preview and confirmation lifecycle

### 6.1 Transport model comparison

| Model | Advantages | Risks / disposition |
|---|---|---|
| Single-process interaction: CLI remains alive while Shortcuts displays preview and returns consent | Keeps the same parsed model and file access in memory; avoids reacquiring a reference; no persistent session store. | Shortcuts may not support a human interaction while a child process remains blocked; risks timeout, orphan process, unclear cancellation and scope lifetime. No daemon is intended. IP-1D must prove actual behavior. |
| Separate-process requests: preview returns, Shortcut presents it, then invokes again with explicit user response | Fits sequential Shortcut actions; process is short-lived; crashes/cancel do not leave a resident session. | Reference/capability must be reacquired or separately qualified; file or model may change; must rerun IP-2/IP-3 and reject stale state. Candidate only; feasibility and privacy/security qualification are unresolved. |

Do not build a background server, listener, persistent session database or implicit conversion queue to mask these tradeoffs. Do not promise a stateless solution before evidence establishes feasibility. If separate invocation cannot securely re-establish source identity and content-state continuity plus explicit consent, stop for architecture review; evaluate a supported alternative transport rather than weaken the gate.

### 6.2 Proposed separate-invocation state protocol (feasibility unresolved)

1. `preview` request includes exact entered current position, selected next waypoint, selected leg where applicable, chosen mode, qualified connector geometry, route-name choice permitted by Gate 3, and opaque source reference.
2. The CLI returns a bounded `preview` payload: a random correlation ID/revision, mode, entered position, explicit selections and their display labels, ordered proposed points, connector endpoints/geometry, included/excluded leg semantics, warnings, geometry availability, advisory distances clearly labelled non-authorizing, and source/model revision metadata that contains no source hash.
3. IP-7 presents the proposed geometry/order and obtains a distinct user confirmation or cancellation. Cancel sends no export request and produces no file. IP-7 must not edit or silently substitute a waypoint, leg, coordinate or geometry.
4. `confirm_export` is a new request containing the same explicit inputs/selections and correlation data, plus an authorized output capability and any separately approved overwrite consent. IP-7 must construct/send it only after a separate affirmative user action. A JSON `confirmed` flag, preview ID or request token is not proof of UI consent; the CLI cannot authenticate that a caller is Shortcuts, so this protocol makes no cryptographic or caller-authentication claim.
5. The confirmation invocation reacquires input using a newly authorized reference or separately qualified reusable capability. It performs a fresh IP-2 secure open and validation, verifies source-object identity and source-content state separately under the approved IP-2/IP-5 identity contract, regenerates the IP-3 preview, and validates the confirmed command against it. It compares explicit choices, coordinates, qualified geometry, model/algorithm revision and preview semantics. Path/name equality, timestamp alone, or file identity alone does not prove unchanged content. Any mismatch returns `STALE_PREVIEW` or `PREVIEW_BINDING_MISMATCH`; no output is created.
6. A preview ID, revision, selection digest or user-editable token is **not** proof of consent or a cryptographic security mechanism. Do not calculate a full source-route digest by default. Source-object identity, source-content state, reference/capability lifetime, preview semantic equivalence, and explicit UI confirmation are distinct properties; none substitutes for another. The continuity mechanism remains **UNRESOLVED** pending joint IP-2/IP-5/IP-7 qualification. If continuity cannot be established under the approved privacy/security policy, fail closed and require a fresh preview and confirmation. IP-2A may propose a private full-route digest only for a documented technical need, privacy review and explicit approval.
7. IP-3 remains authority for domain confirmation validity. IP-5 owns transport and stale/mismatch binding. IP-7 owns the user-visible preview and consent action. IP-5 does not invent a private confirmation bypass or treat `confirmed=true` alone as domain validation; UI ordering and confirmation are interaction requirements, not a security boundary against a caller that can invoke the CLI directly.

The protocol may return a refreshed preview after a stale result, but never auto-confirms it. Each confirmation binds only to the currently displayed explicit choices. Preview content is returned for user display, not copied to logs. Keep request/response and any transient file-reference material in memory/pipes where possible.

## 7. Safe GPX filesystem writer — IP-5 responsibility

### 7.1 Inputs and result states

The writer accepts only IP-4 immutable validated bytes plus its validation result, a separately authorized destination capability, optional exact-target overwrite authorization from IP-7, and optional user-selected loss-report artifact. It does not accept raw GPX text from Shortcuts, an unconfirmed transformation, arbitrary target paths as trusted authority, or a request to overwrite without consent.

Maintain distinct states:

- transformation finalized;
- GPX serialization succeeded;
- IP-4 schema and semantic validation passed;
- IP-4 export eligibility passed under the approved one-point policy;
- staged bytes match the immutable artifact and pass required final-byte verification;
- GPX save succeeded / failed / cancelled after publication;
- optional loss-report save succeeded / failed / not requested.

The user-facing operation is complete only when `save_result.gpx == saved`. If the GPX is saved but the optional sidecar fails, return GPX success and sidecar failure independently. Never claim failure-with-no-output if publication already happened; report the actual published state.

### 7.2 Destination and publication requirements

- IP-7 supplies a user-selected output destination reference; the source RTZ directory is only a suggested initial location where permission and security scope allow. No silent alternate location.
- Treat parent directory, target, aliases, symlinks, URL/path strings and overwrite responses as untrusted. Coordinate destination alias/scope/file identity policy with IP-2A/IP-7. Do not categorically reject a legitimate user-selected alias without feasibility evidence; do not follow unsafe path chains or reopen untrusted paths.
- Validate parent-directory access and identity through the approved macOS file-reference APIs. Reject directories/devices/FIFOs/sockets as a GPX target. Verify output is not the same file/object as the selected source RTZ, including aliases/hard links where detection is qualified.
- Existing regular file: IP-7 must obtain explicit consent tied to that exact selected target. Recheck target identity immediately before replacement. If it changed, cancel replacement and request fresh consent. Never overwrite a different target merely because the path string matches.
- New file: fail on collision by default and use an OS-supported atomic no-replace publication primitive. Do not check-then-write with a race window.
- Stage to an unpredictable exclusive temporary file in the same directory/volume when supported; never use the final `.gpx` path until complete. Apply only a permissions/metadata policy justified by the approved user-selected destination and security policy. Mode `0600` is one candidate, not frozen or implicitly preferred: IP-5E must evaluate macOS default permissions, umask, ACLs, extended attributes and destination-provider semantics, avoid exposing private route data, and avoid restrictions that block legitimate local applications. Do not blindly inherit unsafe permissions from an existing target or staging directory. Write all bytes, flush as required, close, verify length and exact content against IP-4 bytes, then atomically publish. No final mode is selected in this plan.
- Treat new-file creation and replacement of an existing file as separate cases. New files use the qualified creation policy and atomic no-replace. Replacement requires exact-target consent from IP-7 and a reviewed replacement operation; do not silently discard security-relevant ACLs or metadata or blindly inherit unsafe target permissions. If security-relevant metadata cannot be handled safely, fail closed pending a user-selected supported destination or policy review.
- File Provider/cloud-backed or cross-volume behavior must be observed. Conversion cannot trigger network access or cloud upload. Require a locally available destination and a measured atomicity guarantee; otherwise return `DESTINATION_PROVIDER_UNSUPPORTED` / `DESTINATION_NOT_LOCAL` with a safe explanation.
- On any error/cancel before publication, remove only the temporary object created by this request and leave every preexisting target/source intact. Never report a partial file as GPX success.
- Optional sidecar is a second independent artifact and transaction. It requires its own selected destination/consent if applicable, safe write, and result. Never silently save it beside GPX.

No specific POSIX syscall, Foundation API, directory-fd technique, atomic replacement function, permission mode or file-coordination primitive is frozen here. IP-5E must compare supported macOS APIs, obtain real macOS filesystem evidence for permissions/ACLs/metadata and demonstrate race behavior; code review and tests must verify equivalent guarantees on the qualified OS/filesystems.

### 7.3 Concurrency and source/output protection

Each invocation has an isolated request ID, immutable request state, unique temporary names and no process-global mutable conversion state. Concurrent conversions are permitted only when resource caps hold; concurrent writes to the same target serialize through atomic no-replace or exact-target replacement checks, never shared mutable files. Two requests cannot reuse another request’s overwrite consent or temporary file.

Before publishing, compare source and destination object identity using the approved open handles/resource identifiers; reject same-object writes. IP-2 owns input descriptor identity; IP-5 owns destination identity and collision checks. Never use full source digests as default identity/privacy mechanism.

## 8. Cancellation, lifecycle and recovery

| Moment | Required result |
|---|---|
| User cancels before file selection or mode entry | IP-7 returns without starting conversion; no request/output. |
| User cancels after preview | No confirm/export request; no output. Release transient references and scopes. |
| User cancels during parse/preview/validation | Cooperative cancellation where supported; return `CANCELLED`, no finalized result/output, release scope. Cancellation responsiveness is bounded and tested. |
| User cancels during temporary staging | Stop writing at safe boundary, remove only this request’s temp file; no final GPX reported. |
| User cancels before atomic publication | Abort publication, clean owned temporary artifact, leave existing target unchanged. |
| Cancellation races with atomic publication | Determine actual final state. If complete GPX was published, report it as saved with a cancellation-after-publication status; do not claim no output. |
| Process termination/crash before publication | OS closes descriptors. Any incomplete file is a non-`.gpx` temp and never success. Recovery may remove only a temp whose ownership/identity is established; otherwise leave it untouched and report or document cleanup. |
| Shortcut timeout/interruption | IP-1D establishes how the child is stopped and whether it receives a signal/EOF. IP-5 must not assume termination semantics. Writer cleanup remains best effort, atomic publication decides final state. |
| Repeated or concurrent requests | Independent IDs, bounded per-process and aggregate work, no reused confirmation or destination consent; duplicate export yields collision unless user explicitly selects/replaces the exact target. |

No persistent conversion queue or service. Design cancellation checkpoints before expensive phases, before staging, during bounded writes, and immediately before publication. A signal or closed pipe is a cancellation request, not authority to erase published user data. Stale-preview confirmation always restarts at secure input acquisition. Temporary files use a private recognizable non-GPX naming convention and exclusive creation; automatic orphan cleanup must verify ownership and exact file identity before deletion. If identity is uncertain, never delete. The cleanup design and stale-temp policy require IP-5E evidence.

## 9. Diagnostics, privacy and offline guarantee

### 9.1 Stable public diagnostic families

Preserve upstream IP-2/IP-3/IP-4 codes when stable; otherwise map to versioned protocol codes. Proposed families:

- Protocol: `REQUEST_INVALID`, `PROTOCOL_VERSION_UNSUPPORTED`, `CAPABILITY_UNAVAILABLE`, `REQUEST_TOO_LARGE`.
- Input: `INPUT_REFERENCE_UNAVAILABLE`, `INPUT_ACCESS_DENIED`, `INPUT_IDENTITY_UNVERIFIED`, `INPUT_CHANGED`, `INPUT_NOT_REGULAR_FILE`, `INPUT_TOO_LARGE`, `RTZ_XML_INVALID`, `RTZ_DIALECT_UNSUPPORTED`, `RTZ_SCHEMA_UNAVAILABLE`, `RTZ_SCHEMA_INVALID`.
- Selection/domain: `WAYPOINT_SELECTION_REQUIRED`, `WAYPOINT_SELECTION_AMBIGUOUS`, `LEG_SELECTION_REQUIRED`, `GEOMETRY_UNSUPPORTED`, `JOIN_CANDIDATE_UNAVAILABLE`, `PREVIEW_STALE`, `PREVIEW_BINDING_MISMATCH`, `CONFIRMATION_REQUIRED`, `TRANSFORMATION_REJECTED`.
- GPX/eligibility: `GPX_EXPORT_NOT_ELIGIBLE`, `ONE_POINT_WARNING_ACK_REQUIRED` (provisional code for the G3-004 explicit warning confirmation), `GPX_SERIALIZATION_FAILED`, `GPX_SCHEMA_VALIDATION_FAILED`, `GPX_SEMANTIC_VALIDATION_FAILED`, `GPX_COORDINATE_UNREPRESENTABLE`.
- Output/lifecycle: `DESTINATION_REFERENCE_UNAVAILABLE`, `DESTINATION_PERMISSION_DENIED`, `DESTINATION_PROVIDER_UNSUPPORTED`, `DESTINATION_NOT_LOCAL`, `OUTPUT_ALREADY_EXISTS`, `OVERWRITE_CONSENT_REQUIRED`, `OUTPUT_IDENTITY_CHANGED`, `OUTPUT_VALIDATION_FAILED`, `OUTPUT_WRITE_FAILED`, `OUTPUT_PUBLISHED_BEFORE_CANCEL`, `SIDECAR_SAVE_FAILED`, `CANCELLED`, `INTERNAL_ERROR`.

Codes and severities are proposals until reconciled with upstream catalogs. Each diagnostic contains code, severity, bounded user-safe message, phase and optional non-sensitive category/count. Preserve source-stage provenance code in a separate field only if it is itself privacy-safe. No raw parser error, XML line excerpt or filesystem exception string is passed through by default.

### 9.2 Privacy boundary

- Default stderr, logs, crash context and telemetry contain no route coordinates/names, vessel identity, full source/output paths, RTZ/GPX content, sensitive source IDs, source digest or input bookmark data.
- No full source RTZ digest by default, consistent with IP-2 R1. Ephemeral request IDs are random and not derived from source content. Schema-resource hashes remain qualification metadata and are not private route digests.
- The JSON response necessarily returns user-selected preview geometry/names and may return a save display reference to IP-7; these are transient, direct-to-user data, not logs or telemetry. Do not persist them after the request unless separately approved.
- Optional diagnostic export is off by default; any later proposal requires separate privacy review, explicit consent, data minimization, local-only storage and path/content redaction. No telemetry or network reporting.
- Any raw system error must be mapped to a bounded code/message. Do not echo invalid JSON fields, untrusted filenames, paths, coordinates or identifiers into stderr.

### 9.3 Offline behavior

No network client, updater, telemetry, remote schema fetch, runtime package download, DNS lookup, service endpoint or cloud conversion. Schema/resources, if lawfully bundled, are local and hash-verified against release manifest. If mandatory schema rights/runtime validation remain unresolved, block packaging/implementation rather than fetch at runtime or weaken validation. Offline qualification tests must run with network unavailable and verify no attempted connections. The converter must not independently initiate File Provider/cloud downloads; process only authorized, available content and fail clearly without indefinite waiting when unavailable. macOS/provider activity outside converter control is documented separately and does not weaken the mandatory fully-local offline guarantee.

## 10. Shortcuts integration boundary (IP-7-owned UX)

The Shortcut is the primary UI; IP-5 exposes only stable machine requests/results. IP-7 builds and owns the user interaction:

| User step | Shortcut/IP-7 | IP-5 executable |
|---|---|---|
| Finder selected RTZ | Receives file object as Quick Action input; verifies exactly one supported item or shows clear choice/error. | Accepts only the qualified opaque reference; IP-2 securely opens/validates. |
| No input (Shortcuts app, Dock, keyboard) | Presents native file picker action, mode list and cancellation. | Returns capability/mode information; does not display UI. |
| Full Route / From Waypoint | Displays route summary and ordered waypoint names/ordinals; captures explicit start waypoint. | Inspects validated model and executes selected transformation. |
| Current Position | Requests manual latitude/longitude, explicit next WP, selected route leg and Direct/Join method where applicable. | Validates and transports explicit fields; IP-3 owns domain rules. |
| Preview/confirm | Displays proposed ordered points, selected endpoints/geometry, warnings; obtains explicit Confirm/Cancel. | Returns preview; on confirm revalidates/reconstructs binding; no output on stale/unconfirmed command. |
| Save | Presents native destination selection, overwrite consent, cancellation and actionable errors. | Writes through IP-5 writer and returns distinct GPX/sidecar save results. |
| Success | Shows result and offers Reveal in Finder only after successful save. | Returns a safe display reference; no Terminal output is required. |
| Launch/install | Supports Shortcuts app, Dock, keyboard, Finder Quick Action; installation steps are documented/tested at IP-7. | Installs at a stable documented location; no developer checkout or PATH lookup. |

Current Apple Shortcuts documentation states that a Finder Quick Action can receive selected content, while a Dock-launched Shortcut does not use content from other apps as its input; Shortcuts can also be assigned a keyboard shortcut. Therefore Dock/keyboard launch must include a file-picker fallback; Finder Quick Action must separately qualify file-object transfer. These are documented platform capabilities, not proof that the chosen CLI transport preserves a security-scoped file reference or child process results.

Do not create a Shortcut or rely on a “Run Shell Script”, direct executable action, process launcher, input coercion, security-scope inheritance, or stdout/exit/cancel behavior before IP-1D’s evidence. Shortcuts must pass user values as structured input, never through interpolated shell code. If the candidate Shortcuts action cannot preserve the capability/response contract, stop for review and consider a narrowly scoped signed app-bundle bridge only after architecture approval.

## 11. Self-contained build, packaging and installation

### 11.1 Approved architecture direction and candidate models

| Model | Advantages | Risks / qualification |
|---|---|---|
| Standalone signed CLI binary | Small; direct invocation; no visible application UI. | Resource placement, stable path/update, quarantine/Gatekeeper, executable-bit preservation, schema/resource lookup and code-signing/notarization must be qualified. A bare binary does not bypass macOS security. |
| Signed `.app` bundle containing CLI and approved resources | Stable bundle layout for executable/resources/version/manifest; signs as a coherent deliverable; can be invoked by fixed internal executable path without a GUI. | Must verify direct nested CLI execution, bundle signing/notarization, Gatekeeper/quarantine, Launch Services behavior, file access and Shortcuts invocation. Do not assume the wrapper solves sandbox/security-scope transport. |
| Installer/flat package | Can place files and register components; deterministic install/update. | May require admin or installer privileges, adds privileged deployment complexity and uninstall risk. No need identified for V1; not recommended absent a demonstrated requirement. |

**G3-010 approved V1 architecture direction:** signed/notarized `.app` bundle containing the arm64 CLI executable and only approved local resources, distributed in a signed/notarized drag-install disk image (DMG) with the exported Shortcut and concise installation/uninstall/update instructions. This is not a qualified package or a feasibility claim. Place the bundle in a user-level stable location (provisionally `~/Applications/RTZ-GPX-Converter.app`) so ordinary use requires no administrator privileges. The installed CLI location is a documented fixed path inside that bundle; Shortcuts must not depend on a developer checkout, shell PATH, Homebrew, Python or Node.js. IP-1E/IP-7 must qualify path handling, package copy, Shortcut import, Gatekeeper and updates. If direct invocation of the bundled CLI is not supported safely, stop and return for architectural review; do not silently change the approved package direction.

The package is self-contained in the product sense: it includes the project executable and legally redistributable required resources. It may use macOS system frameworks/runtime components available on the qualified OS; it does not install a language runtime or developer toolchain on the target Mac. Exact linkage/resource policy depends on IP-1 qualification. No schema is included unless rights clear; no runtime schema download.

### 11.2 Build and release requirements

- **Build-time only:** pinned supported Xcode/Swift toolchain, macOS SDK, source revision, dependency lock/provenance, reproducible build settings, signing identity and notarization credentials when available. Build machine may require developer tools; target Mac does not.
- **Target:** arm64 Apple Silicon executable. Consider universal binary only if it has user value and is independently qualified; do not imply Intel support. Minimum macOS remains provisional until Shortcuts action set, Foundation APIs, signing/runtime, parser/schema libraries and file-reference behavior are tested on candidate oldest/current releases.
- **Dependencies:** prefer standard Swift/macOS libraries. Any third-party dependency requires explicit version pinning, license/security review, SBOM/source provenance, included runtime artifact and offline packaging proof. No package manager required on the target Mac.
- **Resources:** package only schemas/runtime resources cleared by IP-1A. Record exact resource name/version/hash/rights in a non-private release manifest; verify bundled bytes against it at build/release and runtime where appropriate. No private route data or source digest.
- **Signing/security:** code-sign the executable and all nested code with the appropriate Developer ID identity for direct distribution; use hardened runtime and secure timestamps as required by Apple’s current notarization requirements. Notarize supported deliverables and staple tickets where supported. Validate signatures after packaging and test Gatekeeper/quarantine on a clean user account. Never instruct users to bypass Gatekeeper or strip quarantine.
- If a suitable signing identity/account or schema rights are unavailable, mark a release blocker and request an explicit architecture/release decision; do not label unsigned/ad-hoc distribution as equivalent.
- **Install:** verify downloaded package, copy `.app` to the documented user-level location, import the distributed Shortcut locally, enable Finder Quick Action, configure Dock and keyboard paths, perform an offline sample conversion using synthetic data, and record permissions granted. No privileged script or auto-launch service.
- **Stable binding/update:** Shortcut invokes the fixed installed path, not PATH. Updating replaces the bundle at that same location while preserving user data; if the app moved or binding is invalid, fail clearly and provide the documented reinstall/rebind steps. Update cannot silently replace user routes. No auto-updater/service.
- **Release artifacts:** versioned DMG, `.app`, Shortcut export, install/update/rollback/uninstall instructions, manifest/checksums, supported OS/architecture matrix, signing/notarization evidence and SBOM where dependencies require it. No GPX/RTZ fixtures in release except approved synthetic non-private test resources where justified.
- **Rollback/uninstall:** retain prior signed release for manual rollback; remove only product app/Shortcut artifacts; never remove user routes, unrelated Shortcuts or user files. Test clean install, upgrade, rollback, uninstall and reinstall.

Apple’s notarization documentation describes code signing, Developer ID, hardened runtime and notarization tickets for distributed Mac software, including apps, disk images and installer packages. This supports the release design constraints; it does not qualify this project’s executable, bundle, Shortcut or target macOS compatibility. The minimum OS and packaging model remain provisional pending actual tests.

## 12. Synthetic verification matrix (future authorized execution only)

No tests, fixtures, probes or build products are created in this planning task. Later authorized IP-5 execution uses IP-1 synthetic fixtures and test cases only; never real voyage routes or vessel coordinates.

- Protocol v1 request/response schema, capabilities negotiation, `inspect` via the exact secure IP-2 acquisition/open/parse/schema/semantic pipeline, no independent path reader or filename inference, bounded names/waypoint entries/diagnostics/response, explicit over-limit error or pagination behavior, unsupported version, unknown action/field, malformed/duplicate-key JSON, truncation, oversized input, request ID uniqueness, deterministic error ordering, exactly-one-JSON stdout, stderr privacy, exit status mapping and no mixed output.
- Every route mode: Full Route, From Waypoint (first/middle/last/ambiguous), Current Direct and Current Join; absent selection/unsupported geometry rejected; no auto-selection or geometry fallback.
- Preview/confirm/cancel: explicit fields, sequence display, authorized reacquisition, source-object identity distinct from source-content state and reference lifetime, semantic preview equivalence, stale input/model/content/selections, modified options, path/timestamp/token insufficiency, replay, mismatched request ID, cancellation before/after each phase, no finalization without IP-3 validation, no source digest by default, fail-closed when continuity cannot be proven.
- Safe input: missing, malformed, oversized, unreadable, nonregular and replaced source; filename spoof/extension mismatch; selected alias and symlink policy; path traversal; Unicode/spaces; file URL encoding; security scope expired/denied; resource access race; content mutation; cloud-only File Provider item; no network; identity mismatch.
- Writer: IP-4 artifact required; serialization/validation/eligibility status combinations; exact staged bytes; source/output same object; existing regular file/directory/device/symlink; no-replace race; exact-target overwrite consent; target replaced after consent; read-only/permission failure; alias/hardlink behavior; macOS default mode/umask/ACL/extended-attribute/destination-provider semantics for new-file creation versus replacement; no unsafe inheritance or silent loss of security-relevant metadata; Unicode path; cross-volume; File Provider; provider atomicity unsupported; partial write; flush failure; cancellation before/during/immediately before/after publication; temp cleanup/orphan recovery; optional sidecar succeeds/fails independently.
- Concurrency: separate inputs, same destination, same source and output, duplicated request IDs, simultaneous overwrite consent attempts, aggregate resource caps, process termination, no cross-request state/permission/preview reuse.
- Offline/privacy: network disabled, no attempted connection/DNS/schema retrieval/telemetry; logs and errors contain no paths/coordinates/names/XML/GPX/full digest/bookmark; preview JSON delivered only to Shortcut; no source mutation.
- Distribution: arm64 runtime; resource hash verification; signature verification for every nested executable; notarization/ticket/Gatekeeper/quarantine; clean user without developer tools/Homebrew/Python/Node; no admin; app path stability; Shortcut import and launch path; Finder Quick Action; Dock/keyboard picker fallback; cancellation and process result; update/rollback/uninstall.

Separate mock/unit tests from actual platform qualification. Mocks cannot establish Finder/Shortcuts file-reference transfer, security scopes, Gatekeeper, atomic filesystem behavior or offline execution. Record macOS version/build, Apple Silicon model class, Shortcuts version, package/build revision, identity/signing/notary state, filesystem/provider, test case ID and redacted result. Do not capture private paths or route data.

## 13. Future IP-5 execution sub-stages

These are future work packages only, not implementation instructions or authorization. Proposed source paths assume Swift pending IP-1/IP-2 language/runtime review.

### IP-5A — Runtime architecture and packaging qualification

- **Objective:** settle CLI target/runtime model, arm64/minimum-OS candidates, app-bundle vs standalone-vs-installer, stable install path, resources and signing/notarization plan.
- **Scope:** architecture and reproducible build/package qualification; no product feature work beyond authorized verification harness.
- **Exclusions:** no schema acquisition/redistribution without IP-1A rights; no Shortcut artifact unless separately authorized through IP-7; no user data.
- **Proposed files:** `docs/research/IP-5/PACKAGING-QUALIFICATION.md`, build/release workflow docs and manifest template; build config only after execution authorization.
- **Dependencies:** IP-1A/E schema/legal and candidate OS strategy; approved Gate 3 plan set; explicit Gate 4/IP-5A authorization; signing identity availability.
- **Sequence:** compare targets/packages → inventory OS/dependency/resource needs → determine rights/signing → authorized build/package → clean-user Gatekeeper/offline install/update/rollback checks → recommend final layout.
- **Synthetic tests/evidence:** target architecture, packaged resources/hash, signature/notary, clean account without developer tools, no-admin install, stable path, OS matrix.
- **Acceptance:** self-contained local runtime; no target interpreter/developer tools/network/admin; lawful resources; verified arm64/path/signing on stated OS matrix; unresolved compatibility remains named and blocks support claims.
- **Risks:** missing identity/schema rights, OS incompatibility, moved bundle, executable loading from bundle.
- **Rollback:** remove only test package/account artifacts; preserve user data and previous signed release.
- **PASS:** reproducible package evidence, independent Gatekeeper and clean-user verification, rights and minimum supported OS explicitly reviewed.

### IP-5B — Versioned CLI request/response protocol

- **Objective:** freeze and implement protocol versioning, JSON schemas, capability negotiation, exit codes and safe diagnostics.
- **Scope:** finite CLI requests/responses and typed mapping; no parser implementation, geometry, GPX serializer, UI or writer internals.
- **Exclusions:** no private data in argv/logs; no protocol claiming unqualified capabilities; no persistent listener.
- **Proposed files:** `Sources/RTZCLI/Protocol/Request.swift`, `Response.swift`, `DiagnosticEnvelope.swift`, protocol docs and synthetic tests.
- **Dependencies:** IP-1D transport feasibility; IP-2/IP-3/IP-4 stable type/code review; IP-5A executable/path decision; Gate 4 authorization.
- **Sequence:** schema/version policy → parse limits → capabilities/action map and secure `inspect` contract → exit/error contract → stdout/stderr separation → compatibility review.
- **Synthetic tests/evidence:** malformed/unsupported requests, strict parser, version mismatch, one response, clean streams, deterministic mapping, no sensitive argv/logs.
- **Acceptance:** documented stable contract, backward-compatibility rules, supported capability reporting and failure behavior; `inspect` uses the validated IP-2 model with bounded output and qualified over-limit behavior; actual Shortcuts round-trip passes IP-1D evidence.
- **Risks:** Shortcut coercion, schema drift, accidental debug output or protocol break.
- **Rollback:** retain last compatible protocol implementation; reject unsupported majors explicitly.
- **PASS:** independent protocol review and actual supported-transport verification; no unqualified field or behavior.

### IP-5C — Secure file-reference transport and orchestration

- **Objective:** bridge untrusted Shortcuts/Finder input/output capabilities into IP-2/IP-3/IP-4 without path trust or unsafe reopen.
- **Scope:** process boundary, reference lifetime, deterministic orchestration, phase/error mapping.
- **Exclusions:** no parser/domain/serializer duplication; no blanket alias rejection without evidence; no source digest default.
- **Proposed files:** `Sources/RTZCLI/InputReferenceAdapter.swift`, `ConversionOrchestrator.swift`, `OutputReferenceAdapter.swift`, interface and privacy tests.
- **Dependencies:** IP-2A joint security-scope/alias/identity/limit policy; IP-1D transport; IP-3/IP-4 approved interfaces; IP-5A/B; Gate 4 authorization.
- **Sequence:** select one demonstrated carrier → bind one invocation → open/parse/validate via IP-2 → for `inspect`, summarize only the validated immutable model → otherwise keep model request-local, map mode/selection → call IP-3 → call IP-4 only on finalized result → return bounded structured result.
- **Synthetic tests/evidence:** Finder/Shortcut/CLI source capability, revoked/expired scope, identity replacement, content mutation, unsupported provider, size limits, all mode dispatches, no path reopen/source mutation, privacy.
- **Acceptance:** only validated model enters domain or `inspect`; no independent XML/path reader, filename inference, path/content trust bypass or schema bypass; bounded inspect output has explicit over-limit behavior; no partial model; deterministic errors; access revoked/closed after operation; no capability persistence unless separately qualified.
- **Risks:** process loses scope, alias race, File Provider hydration, interface drift.
- **Rollback:** reject unproven carrier and disable affected workflow; do not weaken IP-2 requirements.
- **PASS:** joint IP-2A/IP-5/IP-7 signed-off behavior and platform evidence for each supported launch path.

### IP-5D — Preview/confirmation transport and binding

- **Objective:** transport IP-3 previews and bind a distinct affirmative Shortcut action to a freshly validated confirmed command.
- **Scope:** preview/confirm request and result lifecycle across candidate invocation models; separate-invocation/stateless operation is not promised until qualified. No geometry algorithms/UI implementation.
- **Exclusions:** no trusted token-only decision, full source digest, persistent DB, daemon, implicit confirmation or selection changes.
- **Proposed files:** `Sources/RTZCLI/PreviewBinding.swift`, `ConfirmationRequest.swift`, response-model tests/docs.
- **Dependencies:** IP-3 confirmed-command contract; IP-7 route/publication approvals; IP-5B protocol, IP-5C reference/identity; IP-4 G3-001 naming and G3-004 one-point contracts; Gate 4 authorization.
- **Sequence:** inspect/recompute preview → return display payload → collect user consent in Shortcut → new invocation obtains newly authorized input reference or separately qualified reusable capability → fresh IP-2 open/validation and IP-3 recomputation → verify source-object identity and source-content state separately, plus selections and preview semantic equivalence → IP-3 validates confirmed command → only then IP-4/export.
- **Synthetic tests/evidence:** stale/replayed/mismatched preview, changed bytes with stable file identity, changed object with same path/name/timestamp, changed selections/model/algorithm revision, all current-position variants, explicit route leg/next-WP, cancellation, user-editable token tampering, capability/reference lifetime, continuity failure and fail-closed response.
- **Acceptance:** no export from preview alone; changed source content/options require re-preview; continuity established under the jointly approved IP-2/IP-5 identity contract; no navigation choice inferred; token/revision treated as correlation only; user consent is distinct and explicit. If continuity cannot be demonstrated, IP-5D does not PASS and Current Position remains not implemented/accepted/release-ready.
- **Risks:** source identity/content continuity without default digest; capability lifetime and reacquisition; Shortcuts cannot render/retain preview; cancellation race.
- **Rollback:** may revert incomplete IP-5D implementation changes to a previously verified state. Disabling Current Position and releasing only Full Route/From Waypoint is a separate product-scope decision requiring explicit project-governance approval; IP-5 cannot downgrade approved V1 requirements.
- **PASS:** secure preview/confirmation binding is demonstrated under the approved identity/content-continuity contract, with IP-3 domain and IP-7 UX review plus real Shortcuts end-to-end evidence. If this is infeasible, IP-5D does not PASS; stop and escalate for architectural review of a supported alternative transport. Partial functionality or scope reduction is not equivalent to PASS.

### IP-5E — Safe filesystem writer and output lifecycle

- **Objective:** write only IP-4 immutable validated bytes with exact-target consent, collision/race safety, atomic publication where supported and accurate final states.
- **Scope:** IP-5 writer, optional sidecar write, temporary staging, cleanup and result protocol.
- **Exclusions:** no file picker/overwrite UI (IP-7), no GPX serialization/schema policy (IP-4), no source RTZ writes, no silent fallback.
- **Proposed files:** `Sources/RTZCLI/Output/ValidatedArtifactWriter.swift`, `DestinationIdentity.swift`, `PublicationResult.swift`, synthetic filesystem tests and platform evidence docs.
- **Dependencies:** IP-4 immutable artifact/status; IP-7 destination/overwrite authorization; IP-2A reference and identity policy; IP-5A/B/C; supported filesystem matrix; Gate 4 authorization.
- **Sequence:** resolve authorized destination → secure parent/target identity → compare source/output → exclusive same-volume temp → complete-byte check → atomic no-replace or confirmed replacement → cleanup/report actual state.
- **Synthetic/platform tests:** collision/replacement race, source-output identity, permission/ACL, alias/symlink, read-only, cross-volume, File Provider, failed write/flush, cancellation at every boundary, process kill/orphan cleanup, sidecar partial success.
- **Acceptance:** no silent overwrite/partial success or unsafe fallback; no preexisting user file removed; output identity/consent rechecked; new-file and replacement permission/metadata behavior is separately evidenced on real macOS filesystems; final mode/ACL policy does not broaden exposure or impose unjustified restrictions; supported destinations have demonstrated semantics; unsupported ones fail closed; sidecar status separate.
- **Risks:** atomic APIs differ, provider semantics, ACL change, termination at publish boundary.
- **Rollback:** preserve old output; remove only verified operation-owned temporary files; disable unsupported destinations.
- **PASS:** reviewed race/atomicity/cleanup and permission/ACL/metadata evidence on every supported macOS/filesystem class; no output claim without actual publish result. Planning does not select a final permission mode.

### IP-5F — Shortcuts integration qualification and release handoff

- **Objective:** verify the selected package/CLI protocol through actual IP-7 Shortcut entry points and hand off stable installation/release contract.
- **Scope:** launch/input/output protocol and release readiness; IP-7 remains UI owner.
- **Exclusions:** no Shortcut authoring in this plan; no Windy test, no real RTZ, no product marketing or unsupported OS promise.
- **Proposed files:** `docs/research/IP-5/SHORTCUTS-INTEGRATION-ACCEPTANCE.md`, install/version/update contract and release checklist.
- **Dependencies:** IP-1D/E; IP-5A–E PASS, including an explicit IP-5D PASS; IP-7 Shortcut design; IP-6 separate; Gate 4 authorization. IP-5D failure blocks this release gate unless project governance separately approves a V1 scope change.
- **Sequence:** clean install → import Shortcut → Finder Quick Action/file path → Dock/keyboard picker fallback → exercise all modes/preview/confirm/save/cancel/error → offline/Gatekeeper/update/rollback → privacy review → hand off to IP-7.
- **Synthetic tests/evidence:** complete §12 on candidate minimum/current OS; spaces/Unicode; stdout/stderr/status/cancel; file scopes; save destination; reveal; no Terminal; no admin; no network.
- **Acceptance:** reproducible documented installation/binding; actual Shortcuts handles all approved V1 interactions, including Current Position only after IP-5D PASS; no CLI Terminal exposure; executable path remains valid under supported update; errors and consent are clear. Scope reduction is not implied by a partial integration result.
- **Risks:** OS/Shortcut action drift, permission prompts, input flattening, bundle relocation, user cancellation behavior.
- **Rollback:** remove only test installation/Shortcut; restore prior signed version and documented binding.
- **PASS:** independent end-to-end evidence on supported OS matrix, IP-5D PASS, and explicit IP-7 acceptance; no assumed platform behavior. If IP-5D fails, IP-5F cannot pass or release V1 under a reduced mode set without separate explicit project-governance approval.

## 14. Cross-stage dependency and decision matrix

| Contract | Owner / IP-5 need | Status | Closure evidence / dependency |
|---|---|---|---|
| Platform and minimum macOS | IP-1D/E researches; IP-5/IP-7 implement within verified matrix | **UNRESOLVED** | Candidate/current OS testing, Shortcuts behavior, runtime/API compatibility; no unsupported OS claims. |
| Shortcuts process/input/stream transport | IP-1D qualifies; IP-5 protocol; IP-7 UX | **PROVISIONAL** | Reproducible Finder/Dock/keyboard, stdio/exit/cancel/file-object evidence; any probe separately authorized. |
| Swift runtime/package/path | IP-5A packaging; IP-7 installation | **PROVISIONAL** | Signed app bundle vs binary evidence; stable path; clean-user no-admin/no-tools installation. |
| RTZ schema rights/resources/offline validation | IP-1A rights and validator; IP-5 bundles only cleared resources | **UNRESOLVED** | Exact schema/resource hashes, rights and offline fail-closed strategy. |
| Input file-reference carrier | IP-2A secure open; IP-5 bridge; IP-7 selected file | **UNRESOLVED** | Security scope/bookmark/descriptor transfer; aliases, permissions, identity, replacement, File Provider and lifetime jointly verified. |
| `inspect` summary boundary | IP-2 validates; IP-5B/C transports; IP-7 presents | **REQUIRED; STRATEGY OPEN** | Same IP-2 secure/schema-qualified parse; bounded summary output; select error vs stable pagination before protocol freeze. |
| IP-2 model/error/limits | IP-2 owns parse/model; IP-5 dispatches/maps only | **APPROVED AS PLAN; EXECUTION PENDING** | Exact interfaces/limits/dialects, immutable model and diagnostics from authorized IP-2 evidence. |
| IP-3 route selections/preview/confirmation | IP-3 domain; IP-5 transport/binding; IP-7 consent | **APPROVED AS PLAN; CONTRACT PROVISIONAL** | Explicit waypoint/leg, connector geometry, stale confirmation and no automatic decisions; numerical geometry decisions remain upstream. |
| Cross-invocation source continuity | IP-2 identity contract; IP-5D binding; IP-7 capability/UI | **UNRESOLVED; IP-5D BLOCKING** | Newly authorized reference or qualified reusable capability; object identity and content state separately proven; no default private digest; fail closed if unavailable. |
| IP-4 validated artifact/eligibility/loss | IP-4 creates immutable validated bytes; IP-5 writes | **APPROVED AS PLAN; EXECUTION PENDING** | G3-001 export name and G3-004 one-point ALLOW_WITH_WARNING are approved; exact schema/name qualification and loss behavior remain pending. |
| Writer/destination/overwrite | IP-5 writer; IP-7 destination/consent | **OWNER BOUNDARY APPROVED; IMPLEMENTATION UNQUALIFIED** | Same-object protection, atomic/no-replace/replace, provider matrix, evidence-based permissions/ACL/metadata for creation and replacement, cancellation and cleanup. |
| IP-5D / IP-5F release gate | IP-5D continuity; IP-5F integration/release | **MANDATORY; NOT QUALIFIED** | IP-5D must PASS; if it fails, IP-5F cannot pass by omitting Current Position absent separate governance approval for scope change. |
| IP-6 Windy acceptance | IP-6 only | **UNRESOLVED** | Synthetic empirical Route Planner results. These inform compatibility, not IP-4 product policy. |
| IP-7 UI/install | IP-7 user interaction, Shortcut artifact and installation docs | **UNRESOLVED** | Actual file picker/Quick Action/Dock/keyboard/preview/confirmation/save/reveal end-to-end test. |
| Privacy/offline | All stages; IP-5 process protocol/runtime | **APPROVED REQUIREMENT; EXECUTION UNVERIFIED** | No logs/data persistence/network, private reference lifetime, offline run and privacy review. |

No upstream execution PASS is claimed. IP-5 must not freeze a transport, file-reference encoding, minimum OS, package path, schema resource set, numeric tolerance or atomic filesystem implementation before its named owner’s evidence and required architectural review. Apply the approved one-point/name contracts without inventing qualification results.

## 15. Risks and unresolved decisions

1. **Shortcuts transfer semantics:** documented UI launches do not prove file capability, stdio, cancellation or exit status. IP-1D is a hard dependency.
2. **Cross-process scope:** security-scoped URLs/bookmarks and file identity may not survive a second invocation as required. Fail closed if access cannot be transferred and verified.
3. **Inspect exposure and bounds:** inspect output comes only from the schema-validated IP-2 model, is bounded, and is transient; no filename inference, independent parser, or route details in default logs.
4. **Protocol exposure:** stdout preview necessarily contains user-facing route data; keep ephemeral and distinct from logs. No sensitive values in argv or stderr.
5. **Preview binding:** no token proves consent. Fresh IP-2/IP-3 recomputation and distinct Shortcut confirmation are required; identity/content continuity remains unresolved; no full source digest by default.
6. **IP-5D failure:** inability to establish secure source continuity is a mandatory-capability failure; IP-5D and dependent IP-5F do not PASS. Partial Current Position support or unilateral scope reduction cannot satisfy the approved V1 gate.
7. **IP-4 policy:** G3-001 route naming and G3-004 one-point export are resolved; IP-5 transports/enforces them and cannot alter their product semantics.
8. **Writer atomicity and permissions:** filesystem/provider replacement primitives, modes, ACLs, extended attributes and security scopes differ. Supported behavior requires IP-5E evidence; unsupported semantics fail safely.
9. **Schema redistribution/runtime:** IP-1 legal/technical decisions may block self-contained offline validation; no download-at-runtime workaround.
10. **Packaging/security:** code signing, notarization, Gatekeeper, app-bundle invocation and a stable install path are not qualified. No bypass instructions.
11. **Minimum macOS:** stays provisional until real Shortcuts and packaging matrix passes.
12. **Cancellation after publication:** must accurately report saved state even when Shortcut cancellation races with commit.
13. **Resource exhaustion/concurrency:** parser and preview are bounded by IP-2; IP-5 also bounds JSON, response size, process concurrency and temporary bytes without inventing upstream route limits.
14. **Privacy:** capabilities/bookmarks, paths, source names and coordinates must not leak to process listing, logs, crash reports, telemetry or persisted sessions.

## 16. IP-5 planning acceptance and future execution PASS

### Planning acceptance

- Swift CLI module boundaries, protocol proposal and exit/stream rules defined.
- JSON stdio is recommended conditionally; CLI args and file-backed envelopes compared; IP-1D feasibility remains explicit.
- File references are untrusted capabilities; no path trust, unsafe reopen, or assumed cross-process security scope.
- Deterministic IP-2/IP-3/IP-4 orchestration and explicit modes are mapped.
- `inspect` has an explicit secure-IP-2-only contract, bounded response and unresolved over-limit strategy.
- Preview/confirmation lifecycle compares both process models, fresh recomputation, source identity versus content continuity, reference lifetime, semantic equivalence and token limitations; separate-process/stateless feasibility remains unqualified.
- IP-5 filesystem writer ownership is explicit; no-replace, exact overwrite consent, atomicity, cleanup, offline and source-protection invariants are specified. Permission/ACL/metadata policy is evidence-gated and no final mode is selected.
- Shortcuts responsibilities and limitations are evidence-bounded; no Shortcut is created.
- Self-contained packaging options are compared with a V1 direction and explicit signing/notarization/OS/path qualification gates.
- Diagnostics, cancellation, concurrency, recovery, privacy, offline guarantees and synthetic verification are covered.
- IP-5A–IP-5F stages each contain objective, scope/exclusions, files, dependencies, sequence, future tests, acceptance/evidence, risks, rollback and PASS conditions.
- Cross-stage matrix marks approved/provisional/unresolved items; approved G3-001 naming and G3-004 one-point product policies remain fixed, while schema, serialization, numeric representation, and evidence qualifications remain unresolved.

### Future IP-5 execution PASS

Only after Gate 3 acceptance, resolution of stage-specific blockers, and explicit Gate 4/IP-5 authorization: stable protocol is tested through the qualified Shortcut transport; input is securely referenced/opened and IP-2 validates it; `inspect` shares that same secure/schema-qualified boundary; explicit IP-3 preview/confirmation cannot be bypassed or become stale and IP-5D passes the jointly approved source identity/content-continuity contract; IP-4 returns a valid immutable artifact; IP-5 writer passes identity/collision/atomicity/permissions/ACL/metadata/cancellation/concurrency and sidecar tests on every claimed filesystem; offline/no-telemetry/privacy checks pass; signed/notarized package installs on the declared Apple Silicon macOS matrix without developer tools/admin; all approved V1 modes and Shortcuts entry points work; update/rollback/uninstall preserve user data; and independent review accepts evidence. If IP-5D does not PASS, overall IP-5/IP-5F cannot pass through partial mode support; any V1 scope change requires separate explicit governance approval. No execution PASS or platform support claim is implied by this plan.

## 17. Primary platform references

Research checked 2026-10-11. Platform documentation can change; recheck at IP-1/IP-5 execution and record retrieval/build OS versions.

- Apple Support, [Run a shortcut while working on your Mac](https://support.apple.com/en-gb/guide/shortcuts-mac/apd163eb9f95/mac) — Quick Actions, Finder input, Dock and keyboard behavior. In particular, Dock launch does not use other-app content as input, so a file-picker fallback is needed.
- Apple Support, [Run a shortcut from the Shortcuts app on Mac](https://support.apple.com/en-gb/guide/shortcuts-mac/apd5ba077760/mac) — sequential execution, action input dialogs and cancellation controls.
- Apple Developer Documentation, [Foundation Process arguments](https://developer.apple.com/documentation/foundation/process/arguments) — discrete argument array is passed without shell expansion; this supports using argv only for fixed non-sensitive selectors, not user payload.
- Apple Developer Documentation, [Foundation Process standardOutput](https://developer.apple.com/documentation/foundation/process/standardoutput) — process stream capture options; does not prove Shortcuts interoperability.
- Apple Developer Documentation, [Accessing files from the macOS App Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox) — user-selected files, security-scoped URLs/bookmarks and cross-process bookmark behavior. This does not prove Shortcut-to-CLI capability transfer for this product.
- Apple Developer Documentation, [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) — Developer ID signing, hardened runtime and notarization requirements for applicable direct distribution; does not qualify this project’s artifacts.
- Approved project sources: Master Plan; IP-1 §7, §8, IP-1D/IP-1E; IP-2 R1 §§3, 9–11, 14; IP-3 R1 §§4–5, 8–10, 13–15; IP-4 R1 §§6–9, 12–15.

## Approval request

The reconciled architecture retains conditional JSON stdio, secure `inspect`, unqualified file-reference carrier and cross-process scope, unresolved IP-5D source identity/content continuity, evidence-gated writer permissions, approved signed app-bundle/DMG direction, and IP-5A–IP-5F decomposition. The approved name/one-point/geometry/consent policies are inputs, not IP-5 choices. Gate 3 is PASS / ARCHITECT ACCEPTED at the approved baseline; do not begin IP-5 execution without separate explicit Gate 4 authorization naming IP-5.
