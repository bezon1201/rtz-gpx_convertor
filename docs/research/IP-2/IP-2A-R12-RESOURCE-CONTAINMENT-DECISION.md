# IP-2A R12 — Parser Resource-Containment Architecture Decision

**Authorization:** IP-2A R12 documentation and architecture decision only. This record uses existing R2/R3/R10 parser evidence and published platform documentation for conceptual feasibility only. No probe, test, build, implementation, schema, dependency, or runtime artifact is authorized or created.

**Baseline:** `a3492a6239098da7437295242ab673eee962beb6`

**Decision:** **INSUFFICIENT EVIDENCE — FURTHER QUALIFICATION REQUIRED.**

**B03:** **PARTIAL / NARROWED / OPEN.** No parser architecture is selected.

**IP-2A:** **PARTIAL / INCOMPLETE.** **IP-2B:** **BLOCKED / NOT AUTHORIZED.**

**R13 follow-up:** the narrowly authorized host-specific child-control probe later qualified the tested CPU-limit and watchdog/reap cases, and partially qualified address-space growth control. It did not qualify a general memory cap or select a production architecture. See [`IP-2A-R13-WORKER-RESOURCE-FEASIBILITY.md`](IP-2A-R13-WORKER-RESOURCE-FEASIBILITY.md); B03 remains open.

## 1. Decision basis and approved requirements

The approved [IP-2 plan](../../implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md) §§3–4 and 11 requires bounded input and work evidence, resource-limit rationale and enforcement points, measured cancellation on qualified targets, fail-closed behavior with no partial model/output, safe cleanup, and a reviewed security/dependency decision before IP-2B. It does **not** approve the candidate 250 ms cancellation figure, 5-second parse/schema budget, or 128 MiB per-conversion memory value as product requirements. No deadline is introduced here.

R2/R3 evidence is narrowly scoped to one static libxml2 2.15.4 candidate on macOS 26.6.2 arm64. R10 accurately classifies the input-byte cap as a read-boundary bound, parser-event counters as callback/application limits, whole-harness RSS and elapsed time as observations, and cancellation as cooperative. The child-process result proves only that one disposable child in that research setup could be signalled and reaped. None of these facts selects libxml2 or establishes production behavior.

## 2. In-process parsing assessment

| Requirement/risk | Existing evidence and assessment | Classification |
|---|---|---|
| Input bytes | The descriptor-style callback supplied no more than limit+1 bytes for excess detection in the tested harness. It does not cap allocations or work for the bytes already supplied. Candidate value is unapproved. | Adequately bounded only at the tested read boundary; integration and approved value remain open. |
| Depth, element, attribute, and text counters | Tested counters reject at application callbacks after the parser has handled the event/token. They do not bound parser-internal allocation before the callback. Waypoint, extension, and diagnostic caps remain unqualified. | Requires more evidence; not hard resource limits. |
| CPU/pathological input | Synthetic timings are one-host observations. Cooperative callbacks do not impose a hard CPU or wall-clock bound if work does not reach a checkpoint. | Requires more evidence. |
| Memory | R2/R3 RSS is whole-harness/process observation, not per-conversion attribution. Parser, schema validation, model construction, and copies may accumulate memory before application checks run. | Requires more evidence; no hard memory cap established. |
| Cancellation | A separate thread requested cancellation; the parser-owning thread observed it at slowed read/cleanup callbacks, returned failure, and closed once. This does not establish response during CPU-bound or otherwise non-cooperative work. | Cooperative behavior observed; responsiveness/latency on approved targets requires more evidence. |
| No partial result and cleanup | Selected harness cases failed without partial success and closed once. There is no integrated parser/schema/model/output lifecycle. | Requires end-to-end evidence. |
| Crash/fatal-library failure | In-process fatal failure can take down the hosting process; no recovery or crash-isolation evidence exists. | Residual risk is unreviewed and not accepted. |
| macOS support | Evidence is one macOS 26.6.2 arm64 host. The product OS floor and supported matrix are not qualified. | Requires more evidence. |

**Conclusion:** The current record does not justify **IN-PROCESS ACCEPTABLE WITH REVIEWED RESIDUAL RISK**. No owner or independent reviewer has accepted the unbounded CPU/memory and crash-blast-radius residuals, and approved IP-2 requirements still call for evidence and review.

## 3. Isolated-worker assessment

| Requirement/risk | Existing evidence and conceptual assessment | Classification |
|---|---|---|
| Lifetime/cancellation | R3 terminated and reaped one disposable CPU-bound child. A supervising parent could conceptually impose a wall-clock watchdog and terminate a stuck child, but production timing, race handling, and cleanup are untested. | Promising containment mechanism; requires qualification. |
| Memory | macOS public documentation describes `RLIMIT_CPU`; its archived `setrlimit(2)` page also lists `RLIMIT_RSS`, but that alone does not establish reliable current macOS resident-memory enforcement for an ordinary signed user-launched child. XNU documents process memory-limit handling in its managed memorystatus/daemon context; this is not evidence that this product can configure an equivalent hard limit. Memory-pressure notifications are signals, not a demonstrated enforceable cap. | Hard worker memory cap is unestablished. Do not assume `RLIMIT_RSS` or internal memorystatus controls are usable product guarantees. |
| Crash containment | A separate process can contain many process-local failures, but signal, termination, crash-report, and parent recovery behavior are not qualified. Kernel/system impact is not contained by the process boundary. | Requires qualification. |
| No partial result / cleanup | A worker can withhold results until a complete validated response, but protocol, temporary data handling, termination races, and orphan prevention do not exist. | Requires design and end-to-end evidence. |
| IPC attack surface | Any request/response protocol must bound bytes, lengths, diagnostics, handles, and lifetime; malformed or compromised-worker responses must fail closed. | New security surface and substantial complexity; unqualified. |
| File authority | Under accepted R11, a pathname is only a locator. A worker must receive or reacquire already-authorized access through a qualified mechanism, open/check once, and bounded-read the verified descriptor; it must not promote a path string to authority or perform unsafe path reopening. No descriptor/capability transfer is selected. | R11 policy preserved; transfer feasibility and authority lifecycle remain unqualified. |
| Signing, packaging, schemas | A nested worker would add signed executable discovery, nested-code signing/notarization, version matching, local schema/resource availability, and update/removal obligations. No packaged worker or offline schema composition exists. | Requires later packaging and lawful-schema qualification. |
| Supported macOS | R3 is one host only; public platform documentation is not a substitute for testing the selected public API and packaged process on every claimed OS. | Requires more evidence. |

The worker option offers a plausible way to contain CPU-bound work through parent-controlled termination and improve process-crash separation. Current evidence does not show a hard, configurable memory ceiling for an ordinary product worker, nor prove the file-authority, packaging, IPC, no-partial-result, or supported-OS contract. R3 does not qualify a production worker.

### Platform-documentation boundary

Apple's archived `setrlimit(2)` reference describes per-process CPU limits and lists RSS/data/stack resource limits; its existence is not evidence that a particular limit gives the required current macOS containment semantics. The open-source XNU memorystatus documentation describes process memory-limit handling, including launchd-managed daemon configuration, and memory-limit notifications. Those internal/system-managed mechanisms do not establish an ordinary app's authority to configure a dependable hard worker cap. These references inform feasibility questions only; no API or limit is approved by R12.

- [Apple `setrlimit(2)` reference](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setrlimit.2.html)
- [Apple XNU memorystatus design](https://github.com/apple-oss-distributions/xnu/blob/main/doc/vm/memorystatus.md)
- [Apple XNU memorystatus notifications](https://github.com/apple-oss-distributions/xnu/blob/main/doc/vm/memorystatus_notify.md)

## 4. Architecture comparison

| Dimension | In-process | Isolated worker | Evidence status |
|---|---|---|---|
| CPU containment | Callback checks are cooperative; parser can consume work between callbacks. | Parent watchdog can terminate/reap a child in principle; no product guarantee. | Neither qualified as an end-to-end bound. |
| Memory containment | Callback counters/RSS do not cap process memory. | A distinct address space helps contain crash effects, but a dependable configurable macOS hard memory cap is unestablished. | Unresolved for both. |
| Cancellation responsiveness | Cooperative only; no deadline or CPU-bound interruption proof. | Parent can signal/kill, but race, latency, and cleanup guarantees are unqualified. | R3 supports only one research child termination/reap. |
| Parser crash containment | Failure can affect the host app process. | Most child-local crashes can be isolated; parent/OS behavior remains. | Worker advantage is conceptual, not product-tested. |
| Descriptor/file authority | Same process can consume the already-open descriptor under R11. | Must securely transfer a descriptor/capability or reacquire authority; path text is insufficient. | R11 policy accepted; worker handoff not tested or designed. |
| Implementation complexity | Lower process/IPC complexity; residual risks remain. | Adds process lifecycle, bounded IPC, crash/reap handling, code signing and resources. | Worker substantially more complex; neither architecture approved. |
| Packaging/signing | One executable/runtime boundary. | Nested executable discovery, signing/notarization and synchronized updates. | No package evidence; IP-1E remains separate. |
| Diagnostics | Direct in-memory error channel; still needs redaction/bounds. | IPC response must be bounded and validated; abnormal exit mapping needed. | Neither integrated. |
| Testability | Deterministic callbacks are testable, but hard process bounds are difficult to infer. | Parent/child failure and termination are testable, subject to OS-specific evidence. | Research evidence only; no production tests. |
| Supported macOS risk | Parser behavior and limits may vary by OS/runtime. | Process controls, signing, authority transfer, and memory behavior may also vary. | Only macOS 26.6.2 arm64 is represented empirically. |
| Attack surface | Parser shares app process and authority. | Adds IPC and a privileged-input boundary; can reduce crash blast radius if authority is minimized. | No threat review of a concrete worker protocol. |

## 5. Decision and exactly one future qualification action

The evidence cannot support either accepting in-process residual risk or requiring a worker as a completed architecture decision. In particular, the approved requirements demand bounded-work evidence and reviewed residual disposition, while no hard memory bound or supported-target cancellation behavior exists. Therefore the decision is **INSUFFICIENT EVIDENCE — FURTHER QUALIFICATION REQUIRED**. This is not a preference vote and does not select libxml2.

**One minimal future probe (not authorized or performed in R12):** on the candidate minimum supported Apple Silicon macOS version after IP-1E freezes that target, run one disposable signed-child feasibility experiment using only synthetic CPU-bound and memory-growth inputs. The parent must apply the proposed public resource controls, request cancellation/termination at the defined boundary, reap the child, and record OS/build, control return/outcome, CPU time, process-memory measurement method, exit/signal, elapsed stop-to-reap, and whether any partial response or orphan remains. The experiment answers only whether a public, nonprivileged child-process configuration provides enforceable CPU/lifetime and memory containment on that target. It must not test RTZ parsing, use route data, transfer file authority, establish a product IPC contract, or become production architecture. **Do not execute it without a separate explicit authorization and reviewed protocol.** A failed or unavailable memory cap leaves that dimension unresolved; it does not silently waive the approved requirement.

This single probe is selected because available evidence already separates callback limits from hard bounds and already demonstrates one kill/reap case; a focused public-control feasibility result can determine whether worker isolation can satisfy the unresolved process-boundary assumption. It does not replace later parser/schema/model integration, B01/B02 clearance, cancellation/no-partial-output acceptance, or supported-OS matrix work.

## 6. B03 disposition and interaction with B04

Architectural questions clarified by R12:

- In-process and isolated-worker options have distinct residual risks; neither is selected.
- Existing byte-boundary, callback, observation, and cooperative-cancellation classifications remain as stated in R10.
- R3 kill/reap is not worker qualification and says nothing about a memory cap.

Still empirically open for B03:

- hard or otherwise reviewed containment for parser CPU and memory, with the approved limits rationale;
- cancellation behavior and measured latency on the eventual supported target matrix, without introducing a 250 ms product requirement;
- no partial model/output and safe cleanup across parser, schema validation, model construction, cancellation, crash, and publication boundaries;
- exact lawful schema/runtime workload and complete no-fallback security configuration after B01/B02 clear;
- independent security review and any separately authorized production integration.

R11 is unchanged. If a later decision selects a worker, its input must remain an authorized file capability/reference under R11; a path string cannot confer authority. The worker must read the same securely opened descriptor or use another expressly qualified authorized handoff, with bounded reads and no unsafe reopen. R12 selects no IPC or file-transfer mechanism and does not reopen B04.

## 7. Status and handoff

- B01 = **PENDING EXTERNAL CONFIRMATION**.
- B02 = **PENDING / NOT CLEARED**.
- B03 = **PARTIAL / NARROWED / OPEN**; this R12 decision is **INSUFFICIENT EVIDENCE — FURTHER QUALIFICATION REQUIRED**.
- B04 minimum policy = **PASS / ARCHITECT ACCEPTED**; B04 overall = **PARTIAL / OPEN**.
- IP-2A = **PARTIAL / INCOMPLETE**; IP-2B = **BLOCKED / NOT AUTHORIZED**.
- Overall IP-1 = **PARTIAL / NOT PASS**.

R12 creates no parser/worker code, IPC, tests, probes, schemas, dependencies, or runtime artifacts. It changes no approved plan, resource-limit value, B04 policy, or Gate 3 decision. Stop for independent Architect review; do not begin IP-2B or another stage.
