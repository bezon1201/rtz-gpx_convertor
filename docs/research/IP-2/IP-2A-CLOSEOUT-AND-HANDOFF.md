# IP-2A Closeout, Boundary Freeze, and Cross-Stage Handoff

**Current authorization:** IP-2A R8 documentation and closeout only. **IP-2A status: PARTIAL / INCOMPLETE.** The R8 closeout document is prepared for review, but approved IP-2A acceptance criteria remain unmet. This does not close IP1-B03 or IP1-B04, and does not authorize IP-2B–IP-2E or later work.

**Reviewed baseline:** `e91cec69fdffc5d4484289207db8c740efa310b9`. R1–R7 remain evidence snapshots under their separate authorizations. No new runtime probe was run for R8.

## 1. Consolidated R1–R7 status

The classifications below are limited to the described host and configuration. “Observed” is not equivalent to a product decision or cross-version qualification.

| Area | R1–R7 evidence/status | Remaining qualification |
|---|---|---|
| Parser runtime candidate | **Candidate only:** static libxml2 2.15.4 was reproducibly built and tested under R2/R3 configuration; Foundation `XMLParser` alone is not suitable for strict DTD rejection based on the R1 bare-DOCTYPE observation. No product parser is selected. | Product dependency/version, lawful offline schema validator composition, supported deployment target, updates and integration require approval and qualification. |
| Parser security | **PARTIAL / OPEN (B03):** the recorded synthetic R2/R3 cases rejected tested DOCTYPE/entity, local/HTTP resource and malformed-input cases with a deny-all per-context loader and immediate internal-subset stop. | Broader adversarial/security review, exact production configuration, schema-validator workload, target-OS behavior and integration remain unqualified. |
| Resource limits | **PARTIAL / OPEN:** byte callback observed limit+1; depth, element, attribute and text counters acted at application callbacks. Candidate ceilings remain experimental. | No hard parser/process memory or CPU bound; no approved production limits; model/schema end-to-end resource use unmeasured. |
| Cancellation | **PARTIAL / OPEN:** cooperative cancellation was observed in synthetic read/cleanup callbacks; a disposable worker could be terminated/reaped during a CPU-bound experiment. | No end-to-end deadline or supported-OS guarantee; no product cancellation contract; parser-context calls from an unrelated thread are not established safe. |
| File authority | **PARTIAL / OPEN (B04):** R5 observed selected-file access through a native picker in one sandboxed app; R7's independently launched sandboxed receiver without a selected-file entitlement received `EPERM` for path-only inputs. | No complete, approved authority acquisition and transfer lifecycle across product process boundaries. |
| Descriptor identity | **Observed locally:** R4/R5 used descriptor-backed `fstat` and bounded reads; R7 compared the opened descriptor against the original identity. | Descriptor identity describes the opened object on that filesystem; it does not authorize access or prove unchanged content. No supported-volume/provider matrix. |
| Path replacement | **Observed locally:** R4/R7 showed that reopening a path after replacement can select a different object; R7's deterministic replacement changed identity and the receiver opened the replacement. | Product policy for replacement/reacquisition and fail-closed user flow remains joint IP-2/IP-5/IP-7 work. |
| Native picker | **PARTIAL:** R5 observed a real native picker returning selected synthetic file URLs, bounded reads, and a mode-000 `EACCES` outcome. | No clean-user packaged product or supported macOS matrix; scope lifecycle, aliases and provider behavior remain open. |
| Inherited helper | **PARTIAL, configuration-specific:** R5 observed a nested helper reading selected files under an inherited sandbox in that picker-launched parent/child arrangement. | It does not qualify an independently launched CLI/receiver, Shortcut path input, bookmark scope flavor, or production packaging. |
| Finder/Shortcuts transport | **PARTIAL:** R6 observed Finder passing POSIX path locators for selected synthetic files with explicit Shortcut Input / “as arguments”. R7's no-input shell identity was observed; its file-argument invocation was inconclusive. | No authority transfer, stable product protocol, permission/cancellation behavior, or supported-version qualification. JSON stdin is not frozen. |
| Standalone receiver authority | **BLOCKED for path-only sandboxed access:** R7 receiver had `com.apple.security.app-sandbox=true` and no selected-file or inherit entitlement; both readable paths failed with `EPERM`. Unsandboxed reads were ordinary filesystem permissions only. | No independently authorized direct path-based CLI mechanism has been qualified. This does not permanently reject future direct CLI mechanisms. |
| Preview/export continuity | **UNQUALIFIED / SECURITY BLOCKER:** no R1–R7 experiment proved reauthorization plus semantic equivalence from preview to final export. | Must reacquire access, reopen securely, revalidate and compare the output-affecting semantic projection; mismatch or uncertainty invalidates route confirmation and associated publication consent. No default full source digest. |
| Supported OS coverage | **NOT QUALIFIED:** empirical evidence is from macOS 26.6.2 build 25G83, arm64, with the toolchain documented in each research record. | Candidate minimum and supported-version matrix require IP-1E/IP-5/IP-7 qualification. No OS support claim follows from one host. |
| Schema rights/runtime | **BLOCKED:** IP1-B01 requires external RTZ 1.2 provenance confirmation; IP1-B02 has no written redistribution/offline-use clearance for RTZ 1.0/1.2 schemas and GPX schema status remains conditional/not cleared. | Obtain rights and provenance evidence for exact artifacts, establish a lawful closed offline schema set and validator runtime, then independently qualify it. No schema was bundled by R1–R7. |

Detailed source records: [`INPUT-AND-SECURITY-DECISIONS.md`](INPUT-AND-SECURITY-DECISIONS.md), [`RESOURCE-LIMITS.md`](RESOURCE-LIMITS.md), [`FILE-REFERENCE-AND-CONTINUITY.md`](FILE-REFERENCE-AND-CONTINUITY.md), [`FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md`](FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md), [`INDEPENDENT-RECEIVER-AUTHORITY-R7.md`](INDEPENDENT-RECEIVER-AUTHORITY-R7.md), and the IP-1 blocker register [`../IP-1/DECISIONS-AND-DEPENDENCIES.md`](../IP-1/DECISIONS-AND-DEPENDENCIES.md).

## 2. Frozen candidate input boundary

The upstream responsibility boundary is:

`AuthorizedFileReference` → secure authorization lifecycle → secure open → descriptor-backed bounded byte source → strict XML security layer → exact dialect/schema phase → semantic model

This is a conceptual boundary only; it defines no production Swift API.

- A path string is a locator, not authority. A filename, extension, sender, URL text, or successful unsandboxed `open()` carries no authorization claim.
- Treat the reference and file contents as untrusted until permitted access is established and the file is securely opened and validated.
- Read from the opened descriptor, after `fstat` and regular-file/size checks; do not perform an unsafe path reopen during that read.
- Same path does not establish the same object. Descriptor identity is local evidence about the object opened, not proof of authorization or immutable contents.
- Same object does not establish unchanged contents; in-place modification can alter bytes without changing descriptor identity.
- Semantic preview/export continuity is separate from reference authority and object identity. It requires a fresh authorized read and validation plus comparison of all output-affecting semantics.

## 3. Current authority decision for review

**Leading candidate:** a native app obtains authority through a qualified native selection/reference mechanism. A bundled helper may operate only within an authority model explicitly qualified for that configuration, such as the R5 inherited-sandbox parent/child arrangement or another separately proven capability handoff.

Shortcuts and Finder may serve as launcher, Quick Action, file-selection convenience, or workflow entry point. Their path transport is **not** the security authority boundary. No independently authorized direct path-based CLI mechanism has been qualified. Direct CLI mechanisms are not permanently rejected; any future mechanism requires its own evidence and architectural review.

This is the R8 boundary recommendation, not a production architecture selection or implementation authorization.

## 4. Cross-stage ownership of unresolved work

| Owner | Unresolved responsibility |
|---|---|
| **IP-2 / B03** | Bounded source; strict XML security; resource limits; cancellation boundary; production parser integration. IP-2A research evidence remains partial and is not a parser implementation. See approved IP-2 plan §11 and R8 status below. |
| **IP-5** | Later app/helper/CLI invocation contract; local transport serialization; safe helper discovery; cancellation/error propagation across process boundaries; installed-package behavior. This follows IP-5 §§3–4, 6, 8 and 10. |
| **IP-7** | Later native-picker and Finder Quick Action UX; permission failures; user behavior for aliases/symlinks; reacquisition; confirmation lifecycle; end-to-end preview/export interaction. This follows IP-7 §§3, 6–7 and 13. |
| **Joint IP-2/IP-5/IP-7** | Authorized reference/capability handoff; replacement race policy; semantic preview/export continuity; supported macOS and provider matrix. The approved IP-5 §4 and IP-7 §§7, 15 retain joint qualification. |

This assigns ownership only. No later execution is authorized by R8.

## 5. IP1-B04 residual closure conditions

**Parent status: IP1-B04 PARTIAL / OPEN.** The following labels decompose closure conditions under the existing blocker; they are not new governance blocker IDs.

| Residual | Closure evidence still required |
|---|---|
| **B04-A — Authority acquisition** | Demonstrate the selected native authorization/reference mechanism in the actual signed/sandboxed target; verify scope start/stop and permission behavior on supported configurations. |
| **B04-B — Transport/process handoff** | Demonstrate the real Finder/Shortcuts/app/helper process boundary, received data type, authority behavior, safe serialization and bounded diagnostics. Path-only transport must not be treated as authority. |
| **B04-C — Alias/symlink policy** | Jointly qualify aliases, selected symlinks, security-scoped URLs/bookmarks and any permitted resolution. Do not infer a blanket rejection or acceptance policy from the R7 `O_NOFOLLOW` harness case. |
| **B04-D — Replacement/reacquisition** | Exercise deletion/replacement and reacquire permission at export. Detect unproven continuity and fail closed; path equality or a token is insufficient. |
| **B04-E — Semantic preview/export continuity** | Freeze and test a deterministic projection of every output-affecting input. On mismatch or inconclusive comparison, refresh preview and affirmative route confirmation; invalidate publication consent bound to the old output. |
| **B04-F — OS/provider coverage** | Run the above on the supported macOS matrix, with local and relevant provider-backed/offline states, and document unavailability/permission outcomes. |

## 6. IP1-B03 parser-security status

**IP1-B03 remains OPEN / PARTIAL / NOT QUALIFIED.** R2/R3 used the exact libxml2 2.15.4 upstream archive (SHA-256 `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`), verified runtime `xmlParserVersion == 21504`, built a static candidate, and checked that the harness did not silently link the host libxml2. The recorded configuration used `XML_PARSE_NONET | XML_PARSE_NO_XXE | XML_PARSE_NO_SYS_CATALOG | XML_PARSE_BIG_LINES`, a per-context deny-all resource loader, descriptor-style callbacks, and an immediate `internalSubset` stop. On one macOS 26.6.2 arm64 host, the synthetic matrices reproduced expected DTD/entity/resource denial and malformed-input outcomes.

These are reproducible candidate observations, not a security qualification. Candidate byte/depth/node/text/attribute values are not approved limits. The byte callback detects at most limit+1 bytes at its boundary; application counters execute after the parser may have allocated tokens/events, so they are not hard memory limits. RSS measurements include the harness and generated input and do not establish per-conversion memory. Cooperative cancellation was observed at read/cleanup callbacks; worker termination/reaping was an isolated experiment. No asynchronous cancellation deadline, robust CPU/memory bound, broader adversarial review, supported-OS matrix, production parser integration or independent final acceptance exists. The parser candidate is not selected.

## 7. IP-2B readiness

**IP-2B = BLOCKED.** The approved IP-2 plan §11 lists IP-2A PASS and approved synthetic cases as direct dependencies. The current blockers are:

1. IP-2A has not met its approved PASS criteria, including reviewed parser/security dependencies, evidence-backed limits and jointly reviewed file-reference policy.
2. **B03** remains open: strict parser security, hard-bound limitations, cancellation, supported-OS behavior and production integration are not qualified.
3. **B04** remains open: the secure reference/transport policy and shared evidence are unresolved; see residuals B04-A–B04-F above.
4. The approved IP-2B synthetic case set and its acceptance evidence must be established before execution; R8 creates no cases and does not convert existing IP-1B corpus entries into IP-2B approval.
5. IP-2B has not received stage-specific execution authorization.

The separate IP1-B01/B02 schema provenance, rights and offline-runtime blockers are direct dependencies of IP-2C and remain project progression blockers; IP1-B05 dialect/field semantics also remain unresolved for later model/schema work. They are not presented here as new direct IP-2B §11 dependencies.

IP1-B03/B04 closure is necessary but not sufficient to authorize or pass IP-2B; all approved dependencies and authorization must be satisfied first.

## 8. IP-2A closeout disposition

**IP-2A: PARTIAL / INCOMPLETE.** R8 consolidates R1–R7, records the candidate input and authority boundary for review, and assigns residual questions to their owners. The approved IP-2A acceptance criteria are not met: the lawful exact schema/runtime, approved enforceable limits, final jointly reviewed file-reference policy and supported-OS evidence remain unresolved. The R8 closeout document is ready for independent review, but IP-2A itself is not complete and dependent implementation is not ready.

R8 closes the current R1–R7 exploratory sequence. Further IP-2A investigation or execution requires a separate explicit, scoped authorization after Architect review; this handoff grants none.

**Overall IP-1 remains PARTIAL / NOT PASS.** Gate 3 status is unchanged. IP-2B–IP-2E, later stages and production implementation remain **NOT AUTHORIZED**. Stop for independent Architect review.
