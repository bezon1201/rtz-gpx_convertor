# IP-1E R2 — Provisional Engineering OS Baseline

**Decision: `SEQUOIA 15 ACCEPTED AS PROVISIONAL ENGINEERING BASELINE`.** This selects macOS 15 as the target for authorized pre-implementation research and future qualification planning. It does **not** establish that the app works on macOS 15, set the product minimum supported OS, qualify a release matrix, or authorize probes, builds, implementation, or packaging.

**Reviewed baseline:** `e459b0157cc7f6cb551434dfa23bb98c45cf92c8` (IP-1E R1, PASS / ARCHITECT ACCEPTED as a documentation stage).

**Scope:** documentation-only API compatibility assessment. No new probes, builds, tests, implementation, parser, worker, IPC, schemas, packaging, or IP-2B–IP-2E execution occurred.

## 1. Decision question and evidence boundary

R1 kept the product OS floor unqualified because API inventory and product workflow evidence were incomplete. R2 resolves the narrower circularity: future pre-implementation research needs an explicit OS target even though product support cannot be established until a package and its user flows exist.

The approved plans require Apple Silicon macOS, local/offline operation, Shortcuts as the primary interface, Finder Quick Action support, user-selected files, secure descriptor-backed reads, self-contained helper execution, parser resource/cancellation assessment, and signed/notarized distribution. This review found no mandatory API with documented minimum availability later than macOS 15. Where Apple’s current references do not state an API’s first-available OS release, this review records that limit rather than inventing one. Exact chosen APIs, Shortcuts action semantics, and cross-process authority behavior remain implementation/evidence questions.

Contract sources reviewed: [Master Plan §§4, 10–11](../../RTZ-GPX-PLAN.md); [IP-1E packaging decision §§1–5](PACKAGING-DECISION.md); [IP-2 §§3–4, 11](../../implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md); [IP-5 §§4, 8–11](../../implementation/IP-5-CLI-RUNTIME-PACKAGING-PLAN.md); and [IP-7 §§3–5, 7, 10, 12, 16](../../implementation/IP-7-MACOS-SHORTCUTS-UX-INSTALL-RELEASE-PLAN.md). These documents establish required capability families and planned qualification; they do not select specific APIs or supply product test evidence.

### API-family inventory

| Required family | Documented availability / source | Known constraints and remaining qualification |
|---|---|---|
| Native file selection | AppKit `NSOpenPanel` is Apple’s macOS Open panel. Apple documents separate-process panel behavior beginning at macOS 10.15; the current class reference does not state a first-available release. [NSOpenPanel](https://developer.apple.com/documentation/appkit/nsopenpanel) | Panel selection does not by itself prove RTZ file authority survives Shortcut-to-helper handoff. Alias resolution, cancellation, permissions, and selected-file identity remain unqualified. Exact picker mechanism must match approved Shortcut UX. |
| Security-scoped URLs/bookmarks | Apple documents security-scoped bookmarks as available beginning macOS 10.7.3, including balanced `startAccessingSecurityScopedResource` / `stopAccessingSecurityScopedResource` use. [Bookmark options](https://developer.apple.com/documentation/corefoundation/bookmark-data-creation-options), [URL access](https://developer.apple.com/documentation/foundation/url/startaccessingsecurityscopedresource%28%29) | This establishes API history, not that the product is sandboxed or that a scope transfers to a child. Exact scope, alias, provider, stale-reference, permission, and process-transfer behavior remains jointly unqualified under IP-2A/IP-5/IP-7. |
| Descriptor-backed bounded reads | Apple’s macOS/BSD system-call documentation covers `getrlimit` / `setrlimit`; the POSIX `open`/`read`/`fstat` family is part of the longstanding macOS system interface. [Apple `setrlimit(2)` reference](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setrlimit.2.html) | No single Cocoa abstraction is selected. API availability does not prove race resistance, identity semantics, alias policy, bounded-read correctness, or authority continuity. Those require the approved file-reference contract and later empirical tests. |
| Process launch and supervision | Foundation `Process` documents subprocess launch, termination status, and termination handling; Apple notes that child processes inherit a sandbox. [Process](https://developer.apple.com/documentation/foundation/process) | The reference does not state a first-available macOS release for the reviewed API surface. `Process` availability is not a guarantee of watchdog deadlines, descendant cleanup, hard kill, resource limits, or secure descriptor transfer. R13/R14 evidence remains host-specific. |
| Resource limits and child termination | Apple’s `setrlimit(2)` reference documents CPU limits and per-process resource limits; Foundation `Process` exposes subprocess termination operations. [Apple `setrlimit(2)` reference](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setrlimit.2.html), [Process](https://developer.apple.com/documentation/foundation/process) | The reference is not evidence that every limit is enforced on macOS 15 or provides RSS containment. R13’s `RLIMIT_AS` result was a one-host incremental-mapping observation. CPU/watchdog, cleanup, memory, cancellation, and parser workload still require separate qualification. |
| Bundle-relative helper discovery | Foundation `Bundle` can locate bundle content; Apple documents `url(forAuxiliaryExecutable:)`; helper tools may reside in `Contents/Helpers` or `Contents/MacOS`. [Bundle](https://developer.apple.com/documentation/foundation/bundle/), [auxiliary executable URL](https://developer.apple.com/documentation/foundation/bundle/url%28forauxiliaryexecutable%3A%29), [bundle placement](https://developer.apple.com/documentation/bundleresources/placing-content-in-a-bundle) | Apple’s references do not give a first-available release for every lookup method. Actual helper placement, launch from Shortcuts, move/relaunch behavior, signatures, and notarization must be tested with the final package. No absolute developer path is accepted. |
| Shortcuts and Finder Quick Action | Apple introduced Shortcuts on Mac with Monterey (macOS 12) and described Finder integration. [Monterey announcement](https://www.apple.com/newsroom/2021/06/macos-monterey-introduces-powerful-features-to-get-more-done/). Current Apple Support documents using a Shortcut as a Finder Quick Action. [Run a Shortcut on Mac](https://support.apple.com/en-au/guide/shortcuts-mac/apd163eb9f95/mac) | Feature-family availability does not guarantee this imported Shortcut, its file-picker action, keyboard/Dock launch, input type, permissions, cancellation, helper invocation, or behavior on a given patch. No exact Shortcuts action/API contract is selected or tested. |
| Signing, Hardened Runtime and notarization | Apple says notarization requires Developer ID-signed executables and Hardened Runtime; its guidance covers macOS 10.14.5/10.15-era requirements and a 10.9+ SDK. [Notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution), [Hardened Runtime](https://developer.apple.com/documentation/security/hardened-runtime), [notarization issues](https://developer.apple.com/documentation/security/resolving-common-notarization-issues) | These prerequisites predate Sequoia 15, but no product artifact/account/signature was tested. Nested-code signing, hardened-runtime exceptions, stapling, Gatekeeper, and offline first launch remain packaging qualification work. |
| Fully offline behavior | No OS API minimum: offline conversion is an approved product architecture property, not a platform feature-version requirement. | Runtime dependency closure, local lawful schemas, no network lookups, and user-visible offline success/error behavior are untested. B01/B02 remain open. |

## 2. Engineering baseline decision

**`SEQUOIA 15 ACCEPTED AS PROVISIONAL ENGINEERING BASELINE`.** The API-family review found no documented mandatory feature requiring a macOS version newer than 15. The required Shortcuts feature family exists from Monterey; security-scoped bookmark APIs predate Sequoia; and Apple’s notarization rules predate Sequoia. The remaining references either do not state a first-available OS or describe longstanding platform families without a later-version requirement. This is sufficient to identify Sequoia 15 for future authorized research; it is not proof that every chosen API combination, built artifact, Shortcuts flow, parser, worker, or file-authority mechanism works there.

Future authorized work should use a then-current Sequoia 15 patch on Apple Silicon as the **engineering qualification target**, recording exact product version, build, chip, tools, and artifact identity. This decision does not claim a Sequoia test environment has been made available or tested. A later documented API requirement, unavailable target environment, or failed compatibility result must return the baseline for review; no weaker fallback may be inferred.

## 3. Three separate OS decisions

| Gate | Decision | Evidence required | Status after R2 |
|---|---|---|---|
| Engineering baseline | Select an OS target for pre-implementation research and future qualification. | API-family compatibility review; exact target environment recorded when available. | **Sequoia 15 accepted provisionally. Target environment availability is not verified.** |
| Product support floor | Declare the oldest OS on which the completed product is supported. | Built app and actual user workflow at the proposed floor, plus independent review and owner decision. | **OS FLOOR NOT QUALIFIED.** |
| Release compatibility matrix | State each OS/build/hardware combination supported for a release. | Clean-user signed/notarized package and Shortcut/Finder end-to-end qualification on every claimed row. | **NOT QUALIFIED; no supported rows.** |

No gate automatically satisfies another. The R1 matrix remains a product/package qualification proposal, not an engineering-baseline approval and not a support claim.

## 4. R14 prerequisite disposition

R14’s proposed integrated parser/schema/resource workload action remains unexecuted and unauthorized. Its OS prerequisite is tracked as separate states:

| Prerequisite | R2 disposition |
|---|---|
| OS target identified | **YES — Sequoia 15, provisional engineering baseline only.** |
| Target environment available and exact build recorded | **NOT VERIFIED.** R10–R14 used Tahoe 26.6.2; those results do not transfer to Sequoia. |
| Exact lawful schema/runtime available | **NO — unresolved.** B01 provenance and B02 rights/offline runtime remain pending. |
| Integrated parser/schema workload authorized | **NO — not authorized by this decision.** Requires separate narrow authorization after prerequisites/design are reviewed. |
| Actual workload qualified on target | **NO — not run.** |

An engineering target removes only the ambiguity about which OS future pre-implementation evidence should target. It does not close legal, environment, authorization, or workload prerequisites; it does not alter R14’s candidate architecture or resource-containment limitations.

## 5. Governance and handoff

- IP-1E R1 remains **PASS / ARCHITECT ACCEPTED** as a documentation decision; R2 records a provisional engineering target, not product compatibility.
- **Product OS floor remains NOT QUALIFIED.** No Sequoia support claim is made.
- B01/B02 remain pending; B03 remains OPEN / PARTIAL; B04 overall remains OPEN / PARTIAL (minimum policy remains accepted).
- IP-2A remains **PARTIAL / INCOMPLETE**; IP-2B–IP-2E remain **NOT AUTHORIZED**; overall IP-1 remains **PARTIAL / NOT PASS**.
- No probes, builds, tests, application/parser/worker/IPC code, schemas, dependencies, or packaging work occurred.
- Stop for independent Architect review. Any empirical platform or parser/worker qualification requires separate authorization.

## 6. References

All links above point to Apple primary documentation. They were reviewed for this compatibility assessment on 15 October 2026. A documentation statement about API availability is not empirical evidence for the product’s chosen implementation.
