# IP-2A R1 — Input and Security Feasibility Record

**Status: PARTIAL.** This is a documentation-first security/runtime feasibility record. It does not approve a parser, close IP1-B03/B04, authorize IP-2B–IP-2E, or qualify schema-backed dialect support.

**Authorization:** IP-2A R1 only. **Gate 3:** PASS / ARCHITECT ACCEPTED. **Overall IP-1:** PARTIAL / NOT PASS. No parser, model, validator, CLI, Shortcut, or release work is authorized.

**Reviewed baseline:** `4329b04193652b7fe555180ecd51e238b1271d4d`
**Branch:** `implementation/ip-2a-security-runtime-feasibility`
**Review date:** 2026-10-13
**Observed probe environment:** macOS 26.6.2 (25G83), Apple Silicon arm64; Apple Swift 6.3.3, target macOS 26.0.

## 1. Executive finding

No candidate is qualified for IP-2B implementation. Foundation `XMLParser` has useful event parsing, namespace, error, abort, and external-entity policy APIs, but the authorized one-host probe accepted a bare `DOCTYPE` with no declaration callback. It therefore cannot, by itself, enforce the approved policy to reject DTD declarations. Its documentation also states that its validation-error callback is not invoked and it does not perform validation. Foundation is unsuitable as the sole strict XML/security boundary unless a separate, robust DTD rejection layer is independently justified and qualified.

A pinned libxml2 build remains a technically plausible candidate, with documented XSD 1.0 support, streaming APIs, parser-context resource loaders and entity/network controls. It is not qualified: DTD behavior, resource-loader/catalog behavior, cancellation, resource limits and the exact fixed release/build require evidence; CVE-2026-6732 raises an explicit patch/version gate. It also cannot be used for product schema validation until the IP-1A rights and schema-runtime blockers are resolved. Candidate C (Xerces-C++) does not materially improve the security case; upstream reports no active maintainers and reduced DoS vulnerability support, so it is not recommended.

The documented design below narrows safe responsibilities and sets provisional resource ceilings. It does not establish a secure implementation. **IP1-B03: PARTIAL, OPEN. IP1-B04: PARTIAL for parser-side requirements only; the joint file-reference/continuity blocker remains open. IP-2A R1: PARTIAL.**

## 2. Evidence classes and scope

| Class | R1 record |
|---|---|
| **Verified documentation facts** | Apple documents Foundation `XMLParser` as an event-driven XML parser that includes DTD declarations; namespace reporting; `externalEntityResolvingPolicy` values including `.never`; a parser abort API; fatal parse-error callbacks with line/column; and a `validationErrorOccurred` delegate method that is not invoked because `XMLParser` performs no validation. libxml2 documents XSD APIs, streaming reader input callbacks, `XML_PARSE_NO_XXE`, `XML_PARSE_NOENT`, `XML_PARSE_NONET`, a context resource loader, and version-specific catalog/option behavior. |
| **Observed result** | The disposable Foundation probe described in §3 ran on the exact environment above. It used only tiny synthetic in-memory XML strings, including a bare DOCTYPE, declared element/internal entity cases, and malformed XML. It made no network calls and read no project route or schema. The bare DOCTYPE parsed successfully with zero declaration callbacks; aborting from element/entity-declaration callbacks returned failure; the internal entity sentinel was not observed after callback abort; malformed XML failed with a fatal error callback. |
| **Decision / proposed requirement** | Treat all source references and contents as untrusted. Reject every DTD. Deny all external entities and all unapproved resource loads. Separate well-formed XML parsing, exact version/namespace dispatch, XSD validation, semantic validation, and immutable model construction. Fail closed and return no partial model. |
| **Not qualified / assumptions** | No parser is selected. The probe is not evidence for other macOS or Swift builds, adversarial entity complexity, network denial, file access, streaming memory, asynchronous cancellation, input ceilings, XSD runtime, or production behavior. The probe does not close IP1-B03 or IP1-B04. |

The probe source existed only on standard input; no probe source or executable was retained in the repository. No dependency was installed. The earlier `xmllint` observations and XSD hashes are inherited IP-1A evidence only and were not repeated here.

## 3. Candidate comparison

| Requirement | A. Foundation `XMLParser` / Apple XML facilities | B. Pinned self-contained libxml2 | C. Xerces-C++ (comparison only) |
|---|---|---|---|
| DTD declarations | **Fails strict contract alone in observed case:** a bare DOCTYPE parsed successfully and triggered no listed declaration callback. Delegate callbacks can detect some declarations, but the probe only establishes callback-abort behavior for the tested forms. A second DTD recognizer would need independent encoding-safe, parser-equivalent qualification. | Provides DTD/entity option and SAX/context mechanisms, but whether the selected exact configuration rejects every DOCTYPE, including an otherwise empty one, is **not verified**. Future probe/negative matrix required. Never enable DTD loading/validation for RTZ. | XML/DTD behavior needs exact configuration tests; no reason to prefer it over B. |
| External entities / filesystem | `.never` and `shouldResolveExternalEntities = false` are documented controls. The R1 probe did not test a file URI. No claim about actual filesystem access on other versions. Require explicit deny behavior and local-file sentinel testing before selection. | `XML_PARSE_NO_XXE` is documented from 2.13.0. Do not use `XML_PARSE_NOENT` (enables entity substitution and external loading), `DTDLOAD`, `DTDATTR`, or `DTDVALID`. Require per-context closed resource loading; exact behavior remains unqualified. | Requires explicit resolver configuration and tests. |
| Network / external schema fetch | `.never` is the strict candidate policy; no network case was attempted. `XMLParser` itself is not an XSD validator and must not fetch schemas. | `XML_PARSE_NONET` blocks built-in HTTP/FTP clients in older versions; in libxml2 2.15, NVD/API docs state there are no built-in network clients and the flag is only passed to custom loaders. A custom loader, catalogs and fallback loaders must be tightly controlled. Disable system catalogs and fail closed; `NONET` alone is not a network policy. | Must prove resolver/catalog isolation; no measured evidence. |
| Namespaces | Documented namespace URI/name reporting. Use expanded names; test exact version/namespace pairs and malformed declarations. The probe did not assert the emitted expanded name. | Namespaces are supported; exact parser/reader and schema dispatch still require tests. | Namespaces supported; exact behavior untested. |
| Malformed XML | Apple documents fatal parse errors and line/column values. Probe observed mismatched tags fail with a fatal callback. No recovery behavior is authorized. | `XML_PARSE_RECOVER` explicitly relaxes well-formedness and must not be enabled. Exact diagnostics need tests. | Must disable recovery and test. |
| Size/depth/text/waypoint limits | Event callbacks allow application counters, but no public documentation found for enforceable hard depth, attribute, or token-size limits. A cap applied after a callback may be too late for the parser’s temporary allocation; the whole input-byte cap remains an outer bound. | Reader/event callbacks and parser limits/options are available; the exact enforcement point and memory/CPU behavior need versioned testing. Do not enable `XML_PARSE_HUGE` or `XML_PARSE_UNZIP`. Application counters still required. | Exact limits require independent evidence; maintenance posture makes reliance unattractive. |
| Cancellation | `abortParsing()` is documented; callback-triggered abort is synchronous. R1 confirmed abort at declaration callback, not asynchronous user cancellation or bounded cancellation latency. | `xmlStopParser` and callbacks exist; thread-safety and responsiveness during parse/schema validation are not qualified. Must test on the exact build or isolate into a safely terminable process with architecture review. | Cancellation behavior unqualified. |
| Streaming / memory | Event-based parser; `InputStream` initializer is documented. A counted stream around the already-authorized file object may avoid a whole-document tree, but descriptor-preserving adapter and exact memory behavior are unqualified. | `xmlReaderForIO` accepts I/O callbacks, enabling descriptor-backed streaming in principle. Memory behavior with validation/model creation and cancellation remains unqualified. | Streaming APIs exist, but no candidate-specific test. |
| XSD 1.0 validation | **Not supported by `XMLParser`.** Apple’s delegate documentation says it does not perform validation. `XMLDocument.validate()` is a separate API and is not qualified for closed local-only schema selection or this product’s security requirements. | XSD 1.0 APIs are documented. Exact schemas, XSD dependencies, legal use, resolver closure and runtime behavior remain blocked by IP1-B01/B02 and later testing. | XSD support is documented, but does not resolve schema rights or security concerns. |
| Error localization | `lineNumber`, `columnNumber`, and fatal parse errors are documented. The probe observed fatal-error reporting, but not a full diagnostic mapping. | Structured error callbacks/context exist; output must be capped and sanitized. Verify line/column, stable internal category and no route content leakage. | Requires qualification. |
| Offline determinism / versioning | OS-supplied behavior changes with macOS releases; no engine pin. Target matrix begins at the IP-1E candidate macOS Sequoia 15.8, but no OS is declared supported. | Statically pinned arm64 dependency is reproducible in principle. Select only after security review. NVD lists CVE-2026-6732 affected versions from 2.13.0 to before 2.15.3; at minimum evaluate 2.15.3 or a later reviewed fixed release, verify upstream fix/advisories, and maintain patch ownership. This does not prove the release is otherwise safe. | Apache license is manageable, but upstream states there are no active maintainers and DoS reports will no longer be treated as vulnerabilities; unaddressed hash-collision DoS is listed. Not recommended for untrusted RTZ input. |
| License/deployment | System Foundation code is not bundled as a separate dependency, but API behavior cannot be pinned. No XSD rights are implied. | Upstream libxml2 is MIT-licensed; required notices and dependency inventory would apply. This license does not grant XSD rights. A universal2/arm64 build, signing and deployment target need later packaging qualification. | Apache-2.0 notices required; build/deployment and maintenance risks remain. |
| **R1 assessment** | **Unsuitable as the sole parser/security policy** under the strict DTD-rejection requirement, based on bare-DOCTYPE observation. Could be reconsidered only with a separately justified, safe DTD gate and full OS-matrix evidence. | **Leading technical candidate, PARTIAL / NOT QUALIFIED.** Still needs security probe matrix, resource/cancellation evidence, fixed build and lawful schema runtime. | **Not recommended.** No evidence it materially improves security or maintenance over B. |

### Candidate facts and references

- Apple describes [`XMLParser`](https://developer.apple.com/documentation/foundation/xmlparser) as an event-driven parser that includes DTD declarations. [`shouldResolveExternalEntities`](https://developer.apple.com/documentation/foundation/xmlparser/shouldresolveexternalentities) defaults to false; [`externalEntityResolvingPolicy`](https://developer.apple.com/documentation/foundation/xmlparser/externalentityresolvingpolicy-swift.enum?changes=_6) includes `.never`. Apple documents [`abortParsing()`](https://developer.apple.com/documentation/foundation/xmlparser/abortparsing()) and the [`XMLParserDelegate`](https://developer.apple.com/documentation/foundation/xmlparserdelegate), including fatal parse errors and DTD callbacks. The same delegate reference says `XMLParser` currently does not perform validation.
- libxml2 documents [`XML_PARSE_NO_XXE`, entity options, catalog behavior and resource loaders](https://gnome.pages.gitlab.gnome.org/libxml2/html/parser_8h.html), and [I/O streaming readers](https://gnome.pages.gitlab.gnome.org/libxml2/html/xmlreader_8h.html). The [NVD CVE-2026-6732 record](https://nvd.nist.gov/vuln/detail/CVE-2026-6732) describes a DoS for a specially crafted schema-validated document containing an internal entity and lists affected upstream libxml2 versions from 2.13.0 through <2.15.3.
- Xerces-C++’s [security notice](https://xerces.apache.org/xerces-c/secadv.html) says it has no active maintainers, no longer accepts DoS reports as security vulnerabilities, and lists an unaddressed hash-collision DoS advisory.

## 4. Required security contract

These are requirements for future implementation, not claims that a candidate currently satisfies them.

1. **DTD:** reject every document containing a DOCTYPE, including an empty DOCTYPE and internal/external subsets. Do not validate against DTDs, load external DTDs, apply DTD defaults, or process XInclude. A candidate that cannot reliably detect/reject the declaration before entity use is unsuitable.
2. **Entities:** reject internal and external general/parameter entity declarations and references. No entity substitution or expansion. If any entity or DTD input reaches an unsupported parser state, fail the whole parse before producing a model.
3. **External resources:** no filesystem access through XML system identifiers; no HTTP/network; no catalogs, `schemaLocation` fetch, XInclude, decompression or implicit fallback parser. Any validator resource loader is context-local, closed, and deny-by-default; only an independently qualified local schema registry may be used after IP-1A rights/runtime closure.
4. **Malformed input:** invalid encoding, invalid XML characters, mismatched/truncated tags, multiple roots, trailing non-whitespace content and parser errors fail closed. No recovery, character replacement, or partial usable model.
5. **Dialect:** a minimal safe root inspection may only select an exact qualified `(root expanded name, literal version)` pair. Do not trim, normalize, guess, alias, or use a filename/schemaLocation. Unsupported or mismatched pairs fail before model construction.
6. **Limits:** enforce a byte cap during bounded reads and counters for elements, depth, attributes, text bytes, waypoints, extensions, diagnostics, and elapsed work. A callback counter is not a hard bound on memory already used to materialize a token. No unlimited/“huge” mode.
7. **Cancellation:** cancellation is never approval. Stop reads/parsing/validation promptly; return a cancellation result, no partial model and no output. Prove actual upper-bound latency on each qualified target. If a parser/validator cannot be interrupted safely, isolate it under a reviewed process boundary or reject that candidate.
8. **Privacy and errors:** no source bytes, coordinates, vessel identifiers, private absolute paths or source digest in default logs or diagnostics. Return bounded safe categories; parser crashes must not yield a success or partial model.

## 5. Parsing and validation phase boundary

The approved order remains:

`opaque FileReference → secure open → bounded byte source → strict XML well-formedness/structure → exact version/namespace dispatch → rights-cleared local XSD validation → semantic validation → immutable RouteDocument`

- **Secure open and bounded bytes:** IP-2 owns reading only after it receives a still-authorized reference. Check regular-file eligibility and size using the opened object; read from the same descriptor/authorized handle. No untrusted path reopen.
- **XML parsing:** establishes only well-formedness and structure/namespaces. It does not establish RTZ dialect validity or semantic correctness.
- **Exact dialect dispatch:** only exact version/namespace pairs qualified in IP-1A can proceed. Filename and instance schema hints are never authority.
- **XSD validation:** distinct phase using the exact legally cleared, local, pinned schema. Currently unavailable; missing rights/schema/runtime produces `RTZ_SCHEMA_UNAVAILABLE`, not acceptance of merely well-formed XML.
- **Semantic validation/model:** only a schema-validated structure can be checked against qualified RTZ semantics and built into an immutable model. Unknown/ambiguous semantics fail closed or remain uninterpreted where the approved model allows it. Fatal errors return no model.

No DTD or entity input can be accepted as a “well-formed-only” exception. IP-2A does not create a validator or alter G3 policy.

## 6. File acquisition, ownership and source continuity

| Responsibility | Owner | R1 requirement / evidence boundary |
|---|---|---|
| Picker/Finder/Shortcut selection and process handoff | IP-5/IP-7 | Preserve an opaque, short-lived user-authorized file reference/capability; do not flatten it into an allegedly trusted path. No shell interpolation or path-as-authority. Actual Shortcut/Finder carrier and cross-process access remain unqualified. |
| Alias/security-scoped URL/bookmark lifecycle | Joint IP-2A/IP-5/IP-7 | Obtain, transfer, resolve, start/stop and expire access only through explicitly qualified macOS APIs. Apple documents security-scoped bookmark and URL lifecycle, but this does not prove Finder Action/Shortcut-to-CLI transfer semantics for this product. Do not persist bookmark/access grants absent separately approved need. |
| Secure object open and parse | IP-2 | Validate the reference; securely open once; require eligible regular local bytes; inspect descriptor/object identity; enforce size while reading from that same open handle; close on success, failure and cancellation. Parse only bytes read through this boundary. Permission denial, stale scope, unsupported placeholder, non-regular object or uncertain identity fails with an actionable error. |
| Alias/symlink policy | Joint IP-2A/IP-5/IP-7 | Distinguish user-selected aliases/symlinks opened through authorized OS reference APIs from unsafe path-chain traversal/reopening. Do not unconditionally reject user-selected aliases. Any allowed resolution is explicit, bounded, identity-checked, resistant to replacement, and tested. R1 chooses no final policy. |
| Preview-to-export continuity | Joint IP-2/IP-5D/IP-7 | Reacquire a still-authorized source reference and repeat secure open, bounded parse, dispatch, validation and model construction. Compare file identity and material route semantics to the confirmed preview, with no path/token-only proof and no full-source digest by default. If equivalence is not proven, require a fresh preview and route confirmation; never export a stale route. This mechanism remains unqualified. |

Check object identity before/after the bounded read and record only minimal non-sensitive provenance needed during that operation. Same-inode mutation during read, file coordination, file replacement, bookmark staleness, provider-backed availability and cross-process security-scope lifetime require joint evidence. Metadata equality alone is not proof of identical bytes; a private full digest remains opt-in only after documented need, privacy review and explicit approval.

Apple documentation states that bookmark-created security-scoped URLs require appropriate app entitlements, that the receiving process must resolve/start access, and that access should be balanced with stop-accessing. See [App Sandbox file access](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox), [security-scoped URL access](https://developer.apple.com/documentation/foundation/url/startaccessingsecurityscopedresource%28%29), and [bookmark resolution](https://developer.apple.com/documentation/foundation/url/init%28resolvingbookmarkdata%3Aoptions%3Arelativeto%3Abookmarkdatastale%3A%29-3ic6f?changes=_1). Product transport behavior remains untested.

## 7. Threat model and later verification ownership

| Threat | Required prevention | Detection/failure behavior | Owner / later gate |
|---|---|---|---|
| XXE / external general or parameter entities | DTD rejection, external resolution deny-all, no implicit loader | Any declaration/reference fails before model; no external bytes admitted | IP-2B; resolver/offline cases |
| Entity expansion / recursive entity abuse | Reject all DTD/entity declarations; never substitute entities; fixed patched parser | Abort on first policy violation; bounded error; no partial model | IP-2B; synthetic small/recursive cases |
| Deeply nested XML / recursive structural abuse | Depth and node ceilings during streaming; no “huge” mode | Cap diagnostic, no model; ensure cap occurs before unacceptable stack/resource growth | IP-2A limits; IP-2B boundary tests |
| Oversized text/attributes or long names | Per-value plus aggregate byte counters and overall input ceiling | Reject over cap; never truncate or normalize silently | IP-2B / IP-2D |
| Huge waypoint/element count | Count before model allocation; cap elements and waypoint records | Reject at limit; no partial model | IP-2A limits; IP-2B/D |
| Malformed namespace/version pairing | Exact expanded-name/version allowlist, no fallback | Stable unsupported/mismatch error before schema/model | IP-2C |
| External schema/resource fetch or catalog substitution | Ignore `schemaLocation`; no catalogs/network; per-context deny-by-default loader | Missing local permitted schema fails `RTZ_SCHEMA_UNAVAILABLE` | IP-1A/IP-2C; offline resolver tests |
| Path confusion / symlink traversal / alias redirection | Opaque reference; no path-as-authority; secure open once; bounded, explicit resolution | Identity/permission uncertainty fails closed | IP-2A/IP-5/IP-7; file-reference tests |
| Selected-file replacement race / same-object mutation | Descriptor-based read, identity observations, coordination policy review, fresh reacquisition | Detect changed identity/content where possible; if unproven, invalidate preview | IP-2A/IP-5D/IP-7 |
| Preview/export TOCTOU | Reacquire/reparse/revalidate and compare semantic route state; no token/path-only proof | Refresh preview/route confirmation and dependent consent; do not publish | IP-5D/IP-7 |
| Parser crash, exception, or malformed input | Pin/version review; strict mode; no partial model; process containment review | Controlled failure/no output; sanitized diagnostic; crash does not become success | IP-2A/B/E and IP-5 |
| Cancellation leaves partial state | Check cancellation at read/callback/validation boundaries; abort and clean up | No model/output; report cancelled distinctly; latency measured | IP-2A/B/E and IP-5/IP-7 |
| Unicode, encoded names, spaces/metacharacters in paths | Keep path outside XML/protocol strings; exact URL decoding once; strict XML encoding; argument arrays, no shell | Reject invalid XML; preserve valid name/value exactly; safe actionable file error | IP-2B/IP-5/IP-7 |

## 8. Blocker disposition and readiness

### IP1-B03 — parser/XML runtime security controls

**Disposition: PARTIAL (not closed).** Official documentation provides concrete APIs and warnings, and the current Foundation probe establishes that `XMLParser` alone accepts a bare DOCTYPE despite strict entity settings. This rules out Foundation `XMLParser` alone for the current contract, but does not prove an alternative implementation. libxml2 remains a candidate and must use an exact fixed/reviewed build, deny external resource access, reject all DTDs, avoid dangerous options and pass the full security/resource/cancellation matrix. Candidate macOS runtime behavior and all enforceable limits remain unqualified.

**Closure evidence:** selected parser and pinned/runtime version; DTD/internal/external entity rejection; no filesystem/network/catalog/XInclude/schema fetch; malformed XML fail-closed; bounded bytes/depth/nodes/text/work/memory; cancellation latency; adversarial synthetic security matrix; exact OS/build; independent security review.

### IP1-B04 — Finder/file reference/source continuity

**Disposition: PARTIAL for parser-side requirements only; blocker remains OPEN.** IP-2 responsibilities and shared IP-2/IP-5/IP-7 contract are stated in §6. No file-reference carrier, alias/symlink policy, permission behavior, file identity mechanism, source replacement defense, or preview-to-export continuity proof was exercised or selected. IP-1D remains PARTIAL. Do not use a full source digest by default.

**Closure evidence:** jointly chosen OS/file-reference transport and tested process scope; user-selected alias/symlink and unsafe traversal cases; permission/stale-scope/provider cases; descriptor identity and same-object mutation/replacement races; bounded read from the same handle; fresh reacquisition/reparse semantic equivalence; no unsafe reopen; independent review.

### Readiness verdicts (assessment only; no authorization)

| Stage | Readiness | Reason |
|---|---|---|
| IP-2A security/runtime design | **PARTIAL** | R1 supplies a useful candidate comparison, probe result, provisional limits and owner boundaries. Acceptance is incomplete: no parser meets the required controls yet; B03/B04 remain open; lawful schema runtime and joint FileReference policy remain unresolved. |
| IP-2B parser/model implementation | **BLOCKED** | IP-2A must pass first; no parser selected; strict DTD rejection, resource/cancellation evidence, safe source-reference transport and reviewed security policy are not complete. |
| IP-2C schema-backed dialect validation | **BLOCKED** | IP-1A exact schema provenance/rights/offline runtime remain unresolved (B01/B02). No schema may be copied; well-formed-only input cannot be accepted. |
| IP-2D semantic/model validation | **BLOCKED** | Depends on IP-2A–IP-2C, schema-qualified structure, reviewed field semantics and IP-1B synthetic cases. Neither parser nor schema-validation boundary is ready. |

**IP-2A R1 verdict: PARTIAL. Overall IP-1: PARTIAL / NOT PASS.** Gate 3 remains PASS / ARCHITECT ACCEPTED. Gate 4 is stage-specific. IP-2B–IP-7, implementation and release remain NOT AUTHORIZED.

## 9. R1 scope record

Read the IP-2 approved plan, IP-1A qualification, IP-1G blocker inventory, IP-1B fixture manifest, Gate 3 reconciliation, Master Plan, IP-5/IP-7 plans, REPORT and PROGRESS. The disposable Foundation probe was explicitly allowed by IP-2A R1 and used synthetic in-memory strings only; it did not touch schemas, route fixtures or real RTZ files and made no network calls. No approved plan or G3-001–G3-011 decision was modified. No parser/model implementation, schema, fixture, dependency, CLI, Shortcut, app, package or runtime artifact was created. The pre-existing `AGENTS.md` worktree modification is preserved and excluded.
