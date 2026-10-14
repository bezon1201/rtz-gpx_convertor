# IP-2A R2 Baseline and R3 Addendum — libxml2 Security Qualification

## Current IP-2A R10 B03 classification (2026-10-14)

R10 is a documentation-only review of the existing R2/R3 candidate evidence. The complete control matrix, requirements baseline and closure plan are in [`IP-2A-R10-B03-SECURITY-QUALIFICATION.md`](IP-2A-R10-B03-SECURITY-QUALIFICATION.md). **B03 = PARTIAL / NARROWED; OPEN / NOT QUALIFIED.** No candidate or production architecture is selected.

The descriptor read callback's limit+1 behavior is a hard bound only on bytes supplied through that boundary. Depth, element, attribute and text counters are callback/application limits after parser work; waypoint, extension and diagnostic ceilings remain unqualified. Harness timing and RSS are observational, not per-conversion or hard bounds. Cancellation checks are cooperative; the R3 child termination/reaping result is only a disposable process-isolation experiment. No hard CPU/memory limit, fixed cancellation deadline, schema-validation workload, supported macOS matrix or production integration has been established. The 250 ms candidate value is not approved as a deadline.

Preserved: B01 **PENDING EXTERNAL CONFIRMATION**; B02 **PENDING / NOT CLEARED**; B04 **PARTIAL / OPEN**; IP-2A **PARTIAL / INCOMPLETE**; IP-2B **BLOCKED / NOT AUTHORIZED**; overall IP-1 **PARTIAL / NOT PASS**. R10 ran no probe or test and changed no harness.

## Historical IP-2A R4 FileReference / source continuity addendum (2026-10-14)

**Verdict: PARTIAL.** Authorized R4 evidence and the candidate cross-stage contract are in [`FILE-REFERENCE-AND-CONTINUITY.md`](FILE-REFERENCE-AND-CONTINUITY.md). A narrowly bounded, expiring research-only exception is recorded in [`IP-2A-R4-SCOPE-EXCEPTION.md`](IP-2A-R4-SCOPE-EXCEPTION.md); it does not amend approved IP-2 §11 generally. The Swift/Foundation probe and synthetic local cases are in `tests/research/ip2a/r4/`; no product parser, model, CLI, app, Shortcut, route fixture, schema, or dependency was added.

- **Reproduced on one unsandboxed macOS 26.6.2 arm64 host:** descriptor-backed reads stayed bound to their opened object across rename/move, path replacement, symlink retargeting and source deletion; in-place content modification was visible through the same descriptor; mode-000 access was denied to uid 501; directory/FIFO types were identified; a plain bookmark followed rename while reporting stale, and failed resolution after deletion. Resource/file identifiers remained equal across the tested rename; their presence is not a content proof.
- **Not qualified:** Finder/Shortcuts file-reference transport, sandboxed picker/CLI capability transfer, persistent security-scope lifecycle, Finder alias, File Provider/offline placeholder, ACL, cross-volume/provider behavior, semantic RTZ comparison, and product preview-to-export handling. `shortcuts help run --input-path` documents path text only. The security-scope API calls returning true in this unsandboxed process do not prove sandbox authorization or transport.
- **Candidate contract:** authorize and resolve via a qualified native reference; explicitly and boundedly resolve selected alias/link only if joint IP-2A/IP-5/IP-7 tests prove it safe; open one regular file once; bounded-read only that descriptor; validate; on export reacquire permission and repeat the read/validation; compare a deterministic output-affecting semantic projection. If access or equivalence is absent/inconclusive, invalidate route confirmation and bound publication consent and require fresh preview/confirmation. Never infer unchanged content from path, bookmark, inode/resource IDs, size or timestamps; no source digest by default.
- **IP1-B04 remains PARTIAL / OPEN.** Evidence narrows but does not close concrete transport, sandbox scope, alias policy, export-time reacquisition and semantic-equivalence requirements. **IP1-B03 remains PARTIAL / OPEN / NOT QUALIFIED; IP1-B01/B02 remain unresolved.** Overall IP-1 remains **PARTIAL / NOT PASS**. IP-2B–IP-2E and later stages remain **NOT AUTHORIZED**.

R3 and R4 are historical evidence snapshots. The consolidated current handoff is [`IP-2A-CLOSEOUT-AND-HANDOFF.md`](IP-2A-CLOSEOUT-AND-HANDOFF.md); it preserves open security, rights, limits, authority and continuity requirements.

## Historical IP-2A R3 runtime-safety addendum (2026-10-14)

**Verdict: PARTIAL.** This R3 work is separately authorized by `docs/research/IP-2/IP-2A-R3-SCOPE-EXCEPTION.md`; it does not amend approved IP-2 §11 beyond this one expiring exception. No product parser/dependency is selected. Gate 3 remains **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; Gate 4 is stage-specific. **IP-2A R3 only** was authorized. IP-2B–IP-2E, IP-3–IP-7 execution, production implementation and release remain **NOT AUTHORIZED**. Overall IP-1 remains **PARTIAL / NOT PASS**.

### Reproducible harness and provenance

- The research-only C harness, deterministic generators, build/run script, README, manifest and sanitized result log are under `tests/research/ip2a/`. The authorization record was added before the harness. No production `Sources/RTZCore/` file, application target, product test target, real route, vessel coordinate, schema, dependency source or compiled binary was added to Git.
- The harness verifies `xmlParserVersion == 21504` at runtime. The official GNOME `libxml2-2.15.4.tar.xz` archive SHA-256 was verified as `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`. Configure options and exact invocation are in the build script/README. The build used macOS 26.6.2 (25G83), arm64, Apple clang 21.0.0 (clang-2100.1.1.101); a static `libxml2.a` was linked and `otool -L` found no dynamic libxml2 dependency. The host system library was 2.9.13 and was not used. Temporary upstream source, build tree and executable remained under `/tmp/rtz-ip2a-r3/`.
- Parse options: `XML_PARSE_NONET | XML_PARSE_NO_XXE | XML_PARSE_NO_SYS_CATALOG | XML_PARSE_BIG_LINES` (`0x2c00800`). Each parser context installed a deny-all resource loader; the SAX `internalSubset` callback immediately stopped parsing. Input used descriptor-style callbacks in 4 KiB requests with a 16 MiB plus one byte detection boundary. No DTD loading/entity substitution/recovery/huge mode/XInclude/catalog/default loader was enabled. The harness suppresses libxml2 generic error text and emits bounded category labels, avoiding URLs, paths and XML content in results.

### Reproduced observations

- **R2 behavior reproduced:** bare/internal DOCTYPE, general/parameter entities, external `file://` and inert HTTP DTD/entity declarations, malformed/multi-root/trailing/invalid-encoding XML all failed closed. The parser delivered the DOCTYPE callback and stopped before element/text callbacks; loader count was zero for these DTD inputs. Schema-context tests using tiny project-authored generic XSD text attempted one local and one HTTP include each; the configured resolver denied both, with no network client/request. Schema-location hints and XInclude markup remained inert when ordinary XML parsing was used. All recorded per-case expectations matched; `self-test` reported `failures=0`.
- **Boundary classification:** 16 MiB−1 and exactly 16 MiB descriptor streams were accepted; 16 MiB+1 was rejected after the callback observed limit+1. Depth 64/65, 250,000/250,001 elements, 64/65 attributes, 4,096/4,097-byte text and attribute values, and 8 MiB/8 MiB+1 aggregate text matched the harness expectations. These are harness callback outcomes. Attribute-count/value and element/depth checks occur after libxml2 has parsed/materialized some token/event data; they are not hard parser allocation or process-resource caps. No RTZ model or schema validation was involved.
- **Cooperative asynchronous cancellation:** a separate pthread only set an atomic flag. During a deliberately slowed descriptor read, parser-thread callback code observed the flag, returned failure, delivered no partial success, closed exactly once, and made no subsequent read callback after observing cancellation. A second run synchronized cancellation with the close/cleanup callback and likewise returned failure and closed once. One observed run read 40,000 bytes before cancellation; elapsed times vary across runs and do not establish a deadline. No parser-context operation was called from the cancellation thread.
- **CPU-bound worker experiment:** the child repeatedly parsed an 8,402,951-byte synthetic text input. The parent terminated it with SIGTERM and reaped it; the recorded run used 35.630 ms child CPU, 9,764,864 bytes Darwin `ru_maxrss`, and 264 μs from kill request to reap. This demonstrates only that this local disposable child could be terminated/reaped promptly on this host. It is neither an end-to-end cancellation guarantee nor a production architecture decision.
- **Repeated workloads:** twenty sequential parses of 1,000,003 bytes with 250,000 elements accepted in 121,186 μs total and reported 2,867,200 bytes peak RSS; the +1 element input rejected in 121,050 μs and reported the same process peak RSS. Twenty 70,000-byte depth-10,000 inputs each rejected at the depth callback in 95 μs total (2,162,688-byte peak RSS). Ten 1,048,585-byte attributes each rejected at the attribute callback in 15,682 μs total (4,096,000-byte peak RSS). Twenty 8,402,951-byte aggregate-text inputs took 47,060 μs total (10,289,152-byte peak RSS). All RSS values are for the whole harness process, including generated input and runtime; they are not parser-attributable memory or conversion bounds. Timings are single-host samples, not performance targets.
- Exact synthetic input hashes, expected/observed outcomes, exit statuses, callback counters, timings and sanitized errors are in `tests/research/ip2a/results.jsonl`; the manifest describes identity and expected policy. No file contents or private paths are logged.

### Interpretation, decisions and unqualified requirements

- **Verified empirical observations:** only the tested release/build, synthetic cases and host above. The static link check and runtime version guard make silent system-libxml2 fallback fail the harness qualification.
- **Proposed, not selected:** keep parsing on one owning thread; cancellation may set an atomic request which parser-thread read callbacks observe. For a strict CPU-time limit, a disposable worker process provides a stronger interruption boundary than attempting cross-thread parser-context calls. This is evidence for a future comparison only; no production worker/process architecture is approved here.
- **Not established:** absolute CPU/memory ceilings, parser hard limits, schema-validation behavior/performance, adversarial algorithmic complexity, 250 ms cancellation objective, repeated long-duration stability, supported macOS matrix, Finder/Shortcuts references or permissions, production integration, or portability. No claim of complete libxml2 security qualification is made.
- Upstream API documentation does not establish that calling parser-context operations such as `xmlStopParser` from an unrelated thread is safe. R3 therefore never does so. `xmlCleanupParser` remains process-exit-only and was not called during worker threads.

### Historical R3 disposition

- **IP1-B03: OPEN / PARTIAL / NOT QUALIFIED.** R3 reproducibly strengthens one-host candidate evidence but does not close the required supported-OS, robust hard-bound, integration or independent-review criteria.
- **IP1-B04: OPEN / PARTIAL, unchanged.** No Finder/Shortcuts file reference, alias/symlink, security scope, permission, file replacement/identity, or preview/export continuity behavior was exercised.
- **IP1-B01/B02 remain open:** RTZ 1.2 provenance and schema rights/offline runtime remain unresolved. No RTZ/GPX schema was used or bundled.
- **IP-2A R3: PARTIAL. IP-2B–IP-2E: NOT AUTHORIZED.** Overall IP-1 remains **PARTIAL / NOT PASS**. Independent Architect review is next; stop before any later stage.

The R2 record follows as historical evidence; R2 was superseded as the latest handoff by R3 and subsequent R4–R8 records.

**Verdict: PARTIAL.** This authorized disposable qualification supports libxml2 2.15.4 as a technically credible parser candidate under the exact configuration below; it does **not** select a product dependency, close IP1-B03/B04, qualify RTZ/XSD behavior, or authorize IP-2B–IP-2E. No RTZ/GPX schemas were used.

**Authorization:** IP-2A R2 only. Gate 3 remains **PASS / ARCHITECT ACCEPTED**; Gate 4 is stage-specific. Overall IP-1 remains **PARTIAL / NOT PASS**. IP-2B–IP-2E, IP-3–IP-7 execution and production implementation remain **NOT AUTHORIZED**.

**Branch:** `implementation/ip-2a-r2-libxml2-security-qualification`; baseline/parent `0625fc8980c0072a297a37fde6603538cf52cc06`. **Environment:** macOS 26.6.2 (25G83), arm64, Apple clang 21.0.0 / Xcode 26.6. All empirical claims below are limited to the disposable build and synthetic cases on this single host.

## R2.1 Candidate release and build

- **Exact candidate:** libxml2 2.15.4, upstream release dated 2026-09-01. Upstream archive SHA-256: `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`. The archive checksum was independently recomputed after download. Sources: [GNOME 2.15 release index](https://download.gnome.org/sources/libxml2/2.15/), [2.15.4 release notes](https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.news), [published SHA-256](https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.sha256sum).
- **License:** upstream libxml2 MIT license; this does not grant rights to any RTZ or GPX schema. See [upstream API documentation](https://gnome.pages.gitlab.gnome.org/libxml2/html/).
- **Temporary build:** static, host-native test build; no library source or binary was added to Git or installed as a product dependency. Configure options: `--disable-shared --enable-static --without-catalog --without-http --without-python --without-zlib --without-valid --without-xinclude --with-schemas --with-reader --with-push --with-iconv`. The feature report showed Reader, Push, Schemas and Iconv; Catalog, HTTP, Zlib, DTD validation, XInclude and Python bindings were absent. The standalone `xmlcatalog` tool was absent. The system libxml2 2.9.13 was not used.
- The build demonstrates a candidate configuration only. It is not a final product dependency choice, signed/notarized build, supported-OS claim, ABI/deployment qualification, or general security certification.

## R2.2 Exact parse configuration and boundaries

The synthetic SAX push-parser probe used `XML_PARSE_NONET | XML_PARSE_NO_XXE | XML_PARSE_NO_SYS_CATALOG | XML_PARSE_BIG_LINES`. `XML_PARSE_BIG_LINES` was for useful diagnostics, not permissive parsing. Each parser context used `xmlCtxtSetResourceLoader` with a deny-all callback. Input came from `xmlCtxtReadIO` callbacks, in 4 KiB chunks; the callback enforced the byte cap and cancellation. A SAX `internalSubset` callback immediately called `xmlStopParser`; the application also counted SAX element, depth, text and attribute values and stopped on its candidate caps. No route model/tree was returned by the probe.

Not enabled: `XML_PARSE_NOENT`, `XML_PARSE_DTDLOAD`, `XML_PARSE_DTDATTR`, `XML_PARSE_DTDVALID`, `XML_PARSE_RECOVER`, `XML_PARSE_HUGE`, `XML_PARSE_XINCLUDE`, `XML_PARSE_UNZIP`, `XML_PARSE_CATALOG_PI`, or any default resource loader. `XML_PARSE_NONET` was defense-in-depth only: in 2.15 it is not a standalone network boundary because custom loaders receive the policy and built-in HTTP/FTP clients are absent. The context loader must deny all requests. No global catalog or implicit fallback was permitted. API reference: [libxml2 parser API](https://gnome.pages.gitlab.gnome.org/libxml2/html/parser_8h.html).

**DOCTYPE timing evidence:** locally inspected pinned upstream source shows the SAX `internalSubset` callback at [`parser.c` v2.15.4, around line 8016](https://gitlab.gnome.org/GNOME/libxml2/-/blob/v2.15.4/parser.c#L8016), before `xmlParseInternalSubset()`; that routine checks `PARSER_STOPPED` before processing the subset. In this build, each DOCTYPE case was rejected before element/text SAX events and with zero resource-loader calls. This supports early abort for the tested callback/configuration, not a proof against every parser bug or every input encoding.

## R2.3 Observed synthetic security and XML matrix

All cases were project-authored synthetic strings. No network request was made; external local-file tests used a temporary sentinel outside the repository. Expected policy was fail-closed for any DOCTYPE/resource request/malformed XML and acceptance only for well-formed ordinary XML at this parser layer.

| Case | Observed result | Loader / callback evidence |
|---|---|---|
| Plain well-formed XML | Accepted | No loader calls |
| Bare DOCTYPE; internal element declaration; internal general entity; internal parameter entity | Rejected | `doctype=1`; stopped before element/text callbacks; loader 0 |
| External general entity (`file://`, `http://`); external DTD (local/network); external parameter entity (local/network); nested expansion attempt | Rejected | `doctype=1`; loader attempts 0; no external bytes observed |
| Mismatched/malformed tags, two roots, trailing non-whitespace, `UTF-99`, invalid UTF-8 | Rejected | No recovery; no successful result |
| Well-formed wrong namespace/version-like document | Accepted at XML layer | Expected: dialect dispatch/schema/semantic validation are separate and not qualified here |
| `xsi:noNamespaceSchemaLocation` hint | Accepted at XML layer | Loader 0; no implicit fetch |
| XInclude marker | Parsed as inert elements | Loader 0; XInclude was not built/enabled/invoked |
| Synthetic XSD include to an existing local sentinel and synthetic HTTP URI, via schema-context loader | Both rejected | Per-schema-context deny loader called once per request; no fallback; accepted 0; no network client/request |

The generic XSD loader check establishes only the deny-loader path for the tiny synthetic schema test. It is not RTZ/GPX schema or IP-2C qualification and does not resolve schema redistribution or runtime rights.

## R2.4 Streaming, cancellation and candidate limits

- **Streaming API:** `xmlCtxtReadIO` with descriptor-style read/close callbacks consumed the same open descriptor in bounded 4 KiB requests; it did not first copy the whole file into a second input buffer. The test close callback ran exactly once. No reads occurred after cancellation/stop was observed.
- **Input-byte ceiling:** with a candidate 16 MiB callback cap, descriptor-backed synthetic inputs of 16 MiB−1 and exactly 16 MiB were accepted. 16 MiB+1 was rejected after delivering exactly 16 MiB+1 to the parser callback (`cap_exceeded=1`); close callback ran once. This shows the callback can observe at most limit+1 bytes, not that parser internal allocation or total process memory is capped at 16 MiB.
- **Cancellation:** the read callback called `xmlStopParser` upon a synthetic cancellation signal at 64 KiB. Result was failure/no document; close callback exactly once; no later read callback. The tiny case took about 50 μs on this run; this is an observation, not a 250 ms bound. Asynchronous cross-thread cancellation and CPU-bound adversarial interruption remain unqualified.
- **Depth:** application SAX counter accepted depth 64 and rejected 65. This is an application callback result, not an intrinsic libxml depth guarantee.
- **Attribute value:** callback accepted 4095 and 4096 UTF-8 bytes; rejected 4097. The attribute value has already been materialized by the parser before the SAX start callback, so this is not an allocation hard limit.
- **Text:** application counter accepted a single text value of 4095/4096 bytes and rejected 4097; aggregate text of 8 MiB−1 and exactly 8 MiB was accepted, 8 MiB+1 rejected.
- **Element count:** 250,000 synthetic elements accepted; 250,001 rejected by application callback.
- **Measurement limits:** `/usr/bin/time -l` reported 45,875,560 bytes (~43.8 MiB) for the full multi-case harness, including generated input buffers; this is not per-input parser RSS and is not a product memory bound. The 16 MiB cases reported about 44,768 KiB RSS for the harness. Small-case timings and one host do not establish performance targets or supported-system behavior. Candidate waypoint, extension, diagnostics, work-time, per-conversion memory and 250 ms cancellation ceilings remain unqualified; see `RESOURCE-LIMITS.md`.

The boundary findings update provisional evidence only; none of the candidate ceilings is approved for product use. Callback checks can occur after parser token allocation. Production validation/model memory, schema work and process-wide containment have not been measured.

## R2.5 Security advisory review

| Advisory | Assessment for 2.15.4 candidate | Qualification note |
|---|---|---|
| CVE-2026-6732 | Upstream release notes indicate fixed before 2.15.3; 2.15.4 is beyond that fixed release. | NVD describes a schema-validation DoS involving an internal entity. This does not certify other paths/builds. [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-6732). |
| CVE-2026-86137 through CVE-2026-86144 | 2.15.4 upstream release notes identify the security fixes; the chosen release includes them. | Verify against release notes and advisories again before any product dependency selection. [Upstream 2.15.4 news](https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.news), [Debian tracker](https://security-tracker.debian.org/tracker/source-package/libxml2). |
| CVE-2026-74860 | Python binding-specific; Python bindings were disabled and absent in the temporary build. | Does not imply the C library is generally safe. [Ubuntu advisory](https://ubuntu.com/security/CVE-2026-74860). |
| CVE-2026-11979 | Debian tracks an `xmlcatalog --shell` issue as unimportant; upstream disputes that it is a vulnerability. | Catalog support and `xmlcatalog` were disabled/absent in the test build. This is not a general parser exposure assessment. [Debian record](https://security-tracker.debian.org/tracker/CVE-2026-11979). |

This review is limited to cited published records available at the task date and the tested build features. Advisory databases can change; dependency selection requires a fresh review, patch owner and update policy. No general security certification is claimed.

## Historical R2.6 disposition and readiness

- **IP1-B03: PARTIAL / OPEN / NOT QUALIFIED.** The exact candidate’s tested deny-DOCTYPE and deny-loader behavior is credible for the synthetic cases on one host. Still missing: supported macOS matrix, async/pathological cancellation bound, reliable per-input memory bound, production integration, schema-validator workload, broader security review and independent acceptance.
- **IP1-B04: PARTIAL / OPEN, unchanged.** IP-2A R2 did not exercise Finder/Shortcuts references, aliases, security scope, permissions, identity races or preview/export continuity. Joint IP-2A/IP-5/IP-7 closure remains necessary.
- **IP-2A R2: PARTIAL.** Qualification evidence is not a product parser or a dependency selection.

| Assessment | Readiness | Reason |
|---|---|---|
| IP-2A | **PARTIAL** | Candidate config and bounded synthetic controls characterized; B03/B04 and legal schema/runtime dependencies remain open. |
| IP-2B | **BLOCKED** | IP-2A not PASS; B04 and other mandatory dependencies remain unresolved. |
| IP-2C | **BLOCKED** | IP1-B01/B02 schema provenance, rights and offline runtime remain unresolved; no schema was used. |
| IP-2D | **BLOCKED** | Depends on qualified parsing/schema and reviewed semantics/model contract. |

No later stage is authorized. Overall IP-1 remains **PARTIAL / NOT PASS**.

### R2 sources

- GNOME official [2.15 release index](https://download.gnome.org/sources/libxml2/2.15/), [2.15.4 notes](https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.news), [archive checksum](https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.sha256sum), [parser API](https://gnome.pages.gitlab.gnome.org/libxml2/html/parser_8h.html).
- [NVD CVE-2026-6732](https://nvd.nist.gov/vuln/detail/CVE-2026-6732); [Debian libxml2 tracker](https://security-tracker.debian.org/tracker/source-package/libxml2); [Debian CVE-2026-11979](https://security-tracker.debian.org/tracker/CVE-2026-11979); [Ubuntu CVE-2026-74860](https://ubuntu.com/security/CVE-2026-74860).

---

# Historical IP-2A R1 — Input and Security Feasibility Record

**Historical status at R1:** PARTIAL. Superseded by the R2 disposition above; this R1 record is retained as evidence of prior work.

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
