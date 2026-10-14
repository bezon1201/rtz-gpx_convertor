# IP-1E R1 — Minimum Supported macOS Decision

**Decision status: OS FLOOR NOT QUALIFIED.** No macOS version is frozen or currently supported by product evidence.

**Qualification candidate only:** macOS Sequoia 15 (test the currently listed patch, 15.8.1, before qualification). This preserves IP-1E's earlier Sequoia 15 candidate for evaluation; it is not a support claim or a decision to ship with that deployment target.

**Baseline:** `7d45e67db6bc62bb0bf43b827ecd4cbf21eebdf2`

**Scope:** documentation-only. No probes, tests, implementation, packaging, signing, parser/worker changes, or IP-2B–IP-2E work were performed.

## 1. Existing requirements and evidence boundary

| Source | Existing requirement or statement | Status for this decision |
|---|---|---|
| Gate 3 / Master Plan | Apple Silicon macOS product; local/offline conversion; Shortcuts is V1 primary UI; Finder Quick Action reuses the Shortcut; launch through Shortcuts, Dock, and keyboard. | Approved product requirements; no minimum macOS version is fixed. |
| IP-1E `PACKAGING-DECISION.md` | Developer ID signed/notarized `.app` with bundled self-contained arm64 CLI, stapled DMG, user-imported `.shortcut`, user install at `~/Applications`; earlier Sequoia 15.8 candidate and three-line matrix. | Packaging direction and clean-user qualification plan are approved at documentation level. OS compatibility is expressly untested. The earlier 15.8 candidate is superseded by this R1's current patch reference; the major-version candidate remains Sequoia 15. |
| IP-2 §§3–4, 11 | Candidate macOS/runtime must be qualified for parser security, cancellation, limits and schema validation; IP-2A names candidate macOS as a dependency. | Requires actual API/runtime evidence. It does not name a minimum OS version or let the Tahoe research host establish one. |
| IP-5 / IP-7 | Support only OS versions and hardware actually qualified; test invocation, native picker, Finder/Shortcuts handoff, permissions, cancellation, packaging, installation, and offline flows on the claimed matrix. | Mandatory product integration requirements; no OS/platform workflow has passed as a product. |
| R10–R14 | Security/parser evidence is from macOS Tahoe 26.6.2 arm64; R13 child-control harness was ad-hoc signed, unsandboxed and synthetic. R14 needs later parser/schema workload qualification after OS floor and lawful schema/runtime are available. | Useful host-specific evidence only; it does not prove compatibility with macOS 15, nor make 26.6.2 a support floor. |

There is no exact inventory mapping every planned app/helper/Shortcut API and runtime dependency to its first supported macOS release. Nor is there a built, signed, notarized artifact, installable Shortcut, or end-to-end workflow tested on a candidate minimum. This prevents freezing the floor now.

## 2. Platform and maintenance comparison

Apple announced Shortcuts on Mac with macOS Monterey (12), including integration with Finder and other macOS entry points. This establishes that the high-level feature family exists from that generation; it does **not** qualify this project's imported Shortcut, native picker, Finder Quick Action payload, keyboard/Dock paths, cancellation, or helper invocation on Monterey or later. Apple documents enabling a Shortcut as a Quick Action and running it from Dock, Finder and a keyboard shortcut, but current user-guide instructions do not constitute a compatibility test for this product.

Apple's Developer ID notarization requirements are a distribution/security constraint, not an app deployment-target recommendation. Notarization requires Developer ID-signed executables and hardened runtime among its requirements; these facts do not establish which proposed app APIs or helper behaviors work at a chosen minimum.

| Candidate floor | Advantages | Costs / risks | Disposition |
|---|---|---|---|
| macOS Sonoma 14 | Would broaden coverage to older Apple Silicon installs; Apple listed Sonoma 14.8.9 in its 6 Aug 2026 security-release record. | Older major adds another platform line and API/runtime qualification. Apple’s release listing does not promise a future support window; IP-1E did not select 14, and no Shortcut/package workflow has been tested here. | Do not adopt without explicit user need and a separate matrix expansion. |
| macOS Sequoia 15 | Preserves the existing IP-1E candidate while avoiding additional older-major scope. Apple listed Sequoia 15.8.1 on 28 Sep 2026; Apple’s compatibility list includes M1 Apple Silicon models. | No product artifact or required workflow has been tested on 15. The listed update is evidence of a recent release, not a published lifetime guarantee. | **Recommended qualification candidate, not frozen floor.** |
| macOS Tahoe 26 | R10–R14 provide a host record at 26.6.2; Tahoe is a current recent major and current patch 26.7.1 was listed 28 Sep 2026. | The research host's patch/configuration is not package qualification. Making 26 the floor would exclude Sequoia users without a demonstrated API necessity. | Test as a compatibility line, not as the minimum. |
| macOS Golden Gate 27 | Current major; Apple lists 27.0.1 and Apple Silicon support as of this review. | Latest-major-only scope unnecessarily excludes older supported Apple Silicon devices/OS installations and provides no product evidence. | Test as the current-major compatibility line, not as the minimum. |

As of 15 October 2026, Apple's security-release page lists macOS 15.8.1, 26.7.1, and 27.0.1 as releases dated 28 September 2026, and Sonoma 14.8.9 dated 6 August 2026. This supports comparing 15/26/27 as actively updated candidates at this snapshot. Apple does not publish a guaranteed future maintenance duration in that list, so do not infer an end-of-support date or long-term maintenance commitment from recency alone. Recheck Apple's security releases immediately before any product support claim.

## 3. Decision and missing evidence

**OS FLOOR NOT QUALIFIED.** The evidence supports retaining **macOS Sequoia 15** as the most defensible next qualification candidate, but not freezing it as V1's minimum supported version. The evidence is documentary, and user-visible Shortcuts/Finder features and signing/notarization rules do not prove compatibility of the actual self-contained app, CLI, Shortcut workflow, or security-sensitive APIs.

Exact blockers to qualification:

1. An API/runtime inventory naming each planned Foundation, process-launch, file-reference/security-scope, signing, Shortcut action, and helper-discovery dependency, its documented availability, and its fallback policy. Unsupported APIs may not be silently replaced by weaker behavior.
2. A package-level clean-user run on the proposed oldest supported Apple Silicon class and the candidate OS version, including imported Shortcut, native picker, Finder Quick Action, Dock and keyboard entry points, cancellation, local offline operation, permissions, helper lookup and removal.
3. Independent review of that result and an owner decision that the proposed 15-major floor balances device coverage and maintenance costs. Security-release listings inform this decision but do not substitute for Apple's lifecycle commitment or project owner acceptance.
4. Separate parser/worker/file-authority evidence on the selected floor. The IP-2A R10–R14 and IP-1D findings remain stage-specific; passing the packaging/UI matrix cannot qualify parser controls, resource containment, or Finder file authority.

Until those items pass review, external documentation and capability reports must not say macOS 15, 26, or 27 is supported. The current host's macOS 26.6.2 remains an R10–R14 research environment only.

## 4. Bounded supported-target qualification matrix

If the owner approves Sequoia 15 as the qualification floor, use this initial, bounded three-row Apple Silicon matrix. These are test targets, not currently supported targets. Apple product version is specified; record the exact installed build, hardware identifier/chip, app/package/Shortcut hashes, Shortcuts version, test date, and outcome at execution. Apple security patches may change before execution; update each row to the then-current security patch within that same major version and record the change rather than claiming an untested patch.

| Test target | Role | Hardware | Required qualification |
|---|---|---|---|
| macOS Sequoia 15.8.1 (or then-current 15.x security patch) | Candidate minimum; must pass first | M1 Apple Silicon device supported by Sequoia; use MacBook Air (M1, 2020) as the oldest-class representative | Full clean-user install at `~/Applications`; Developer ID/Gatekeeper/offline first launch; import and run Shortcut from Shortcuts, Dock, and keyboard; Finder Quick Action; picker and cancellation; local-file permissions and safe errors; helper discovery after move/relaunch; fully offline local conversion flow; update/rollback/removal preservation. |
| macOS Tahoe 26.7.1 (or then-current 26.x security patch) | Previous supported major compatibility line | Same M1 representative where Apple supports the OS | Same full package and user-flow acceptance; separately label R13's 26.6.2 probe as historical host-only evidence, not this row's result. |
| macOS Golden Gate 27.0.1 (or then-current 27.x security patch) | Current major compatibility line | Same M1 representative; Apple lists Apple Silicon Mac compatibility | Same full package and user-flow acceptance; review changes to Shortcuts, permissions, Gatekeeper and APIs against the minimum line. |

Pass all three rows before claiming the candidate support matrix. Re-run the full matrix on each row using the same release artifact, except where a newly built artifact is required to match a deliberately raised deployment target; record that artifact separately. Before release, repeat on each row's latest available security patch and test any newly added major as a new row. A support claim is limited to rows actually reviewed as PASS; no earlier patch, Sonoma 14, Intel Mac, or unlisted Apple Silicon configuration is implied.

This three-point design controls test cost while covering the proposed oldest line, the preceding major, and the current major. It does not imply that every Apple Silicon model has been tested; one oldest-class and one representative production-device run may be expanded if hardware-specific differences appear.

## 5. Separation from parser, worker and file-authority qualification

The OS-floor result is only a platform/package planning decision. It cannot close B03 or B04. If a floor is later qualified:

- IP-2A/R14's integrated parser/schema/resource qualification must run separately on the selected minimum OS and lawfully cleared schema/runtime. R13's 26.6.2 host result is not substituted.
- FileReference authority, security scope, alias/provider behavior, replacement/identity continuity and source reacquisition remain under IP-2A/IP-5/IP-7's joint and stage-owned acceptance criteria.
- IP-5/IP-7 must still verify invocation, native picker, Finder Quick Action, Shortcut installation, cancellation, clean-user lifecycle and offline behavior on the supported matrix.

## 6. Governance and handoff

- IP-1E packaging-direction documentation remains **PASS (documentation-level)**; this R1 decision does not turn it into OS compatibility PASS.
- **OS FLOOR: NOT QUALIFIED; no macOS version is currently declared supported.** Sequoia 15.8.1 is a qualification candidate only.
- B01/B02/B03/B04 are unchanged. IP-2A remains **PARTIAL / INCOMPLETE**; IP-2B–IP-2E remain **NOT AUTHORIZED**.
- No probe, test, build, package, signing, notarization or implementation was performed.
- Stop for independent Architect review. Any platform or parser/worker qualification requires its own explicit scope and authorization.

## 7. Sources reviewed

- Apple, [security releases](https://support.apple.com/en-us/100100) (accessed 15 October 2026): Sequoia 15.8.1, Tahoe 26.7.1 and Golden Gate 27.0.1 listed for 28 September 2026; Sonoma 14.8.9 listed for 6 August 2026.
- Apple, [Sequoia compatibility list](https://support.apple.com/en-us/120282): includes MacBook Air (M1, 2020), MacBook Pro (M1, 2020), and Mac mini (M1, 2020).
- Apple, [Tahoe compatibility list](https://support.apple.com/en-us/122867) and [Golden Gate compatibility](https://support.apple.com/en-us/127455): current model compatibility is an OS-install fact, not product qualification.
- Apple, [macOS Monterey announcement](https://www.apple.com/newsroom/2021/06/macos-monterey-introduces-powerful-features-to-get-more-done/): Shortcuts came to Mac with Monterey and was integrated with Finder; this does not verify this product's Shortcut workflow.
- Apple Support, [run a Shortcut on Mac](https://support.apple.com/en-au/guide/shortcuts-mac/apd163eb9f95/mac): documents current Quick Action, Dock, Finder and keyboard setup steps, not the compatibility of this product on the test matrix.
- Apple Developer, [notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution): Developer ID/hardened-runtime distribution requirements; no product minimum OS compatibility conclusion is inferred.
