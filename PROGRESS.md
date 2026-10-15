# Progress ledger

## Current gate activity — minimal converter prototype

**Authorization:** minimal prototype only, from `03e3f5f13267a51772ceb6aef4430bb0375aff82`. One Swift CLI handles synthetic RTZ 1.0/1.2 in Full Route mode and writes deterministic GPX 1.1. It rejects malformed, unsupported, invalid-coordinate and DTD/entity input and does not publish output on failure. XSD validation is absent; no conformance/support claim is made. No UI, Shortcut, worker, IPC, schema, dependency, or packaging was added. `make test` passed focused tests; no Windy import was run. Example: `examples/rtz-1.2-synthetic-example.gpx`. The Sequoia 15 engineering baseline remains research-only; product OS floor NOT QUALIFIED. B01/B02 pending; B03 OPEN / PARTIAL; B04 minimum policy PASS / ARCHITECT ACCEPTED, overall OPEN / PARTIAL; IP-2A PARTIAL / INCOMPLETE; IP-2B–IP-2E remain NOT AUTHORIZED; this prototype is a separate, narrow authorization; overall IP-1 PARTIAL / NOT PASS. `AGENTS.md` is preserved and excluded. Branch: `implementation/minimal-converter-prototype`, from `03e3f5f13267a51772ceb6aef4430bb0375aff82`. Stop for Architect review before expanding scope.

### Historical gate activity — IP-1E R2 provisional engineering OS baseline

R2 accepted Sequoia 15 as a provisional engineering target only. Product OS floor remained NOT QUALIFIED. See [`docs/research/IP-1/IP-1E-R2-ENGINEERING-OS-BASELINE.md`](docs/research/IP-1/IP-1E-R2-ENGINEERING-OS-BASELINE.md).

### Historical gate activity — IP-1E R1 minimum macOS support-floor decision

R1 concluded **OS FLOOR NOT QUALIFIED**, retaining Sequoia 15 as a qualification candidate. R2 now accepts it solely as a provisional engineering baseline; product compatibility remains unqualified. See [`docs/research/IP-1/IP-1E-OS-SUPPORT-FLOOR-DECISION.md`](docs/research/IP-1/IP-1E-OS-SUPPORT-FLOOR-DECISION.md).

### Historical gate activity — IP-2A R14 resource-containment architecture review

**Authorization:** documentation-only architecture review. R13 research execution = PASS / ARCHITECT ACCEPTED; its technical conclusion remains partial. R14 decision: **ISOLATED WORKER CANDIDATE — REQUIRES QUALIFICATION**, not a production architecture selection. R13 supports host-specific CPU-time enforcement, parent watchdog termination/reap, and limiting tested new virtual mappings. Its `RLIMIT_AS` cap started from a ~415 GiB virtual-address baseline; it is not a general RSS cap. `RLIMIT_DATA` returned `EINVAL`; observed resident memory is not an enforced limit. One integrated parser/schema workload qualification is proposed only after supported-OS floor and lawful exact schema/runtime are available; it is not authorized here. B01/B02 pending; B03 OPEN / PARTIAL; B04 minimum policy PASS / ARCHITECT ACCEPTED and overall OPEN / PARTIAL; IP-2A PARTIAL / INCOMPLETE; IP-2B–IP-2E NOT AUTHORIZED; overall IP-1 PARTIAL / NOT PASS. No probes, tests, or runtime work occurred. `AGENTS.md` is preserved and excluded. Branch: `implementation/ip-2a-r14-containment-review`, from `40a40ee26296dc720eaa13318c971fee912e384e`. Stop for independent Architect review.

### Historical gate activity — IP-2A R13 signed-child resource-control feasibility

**Authorization:** IP-2A R13 one-time research-only feasibility probe. Result: **WORKER RESOURCE CONTAINMENT PARTIAL**; no production architecture selected. On macOS 26.6.2 (25G83) arm64, `RLIMIT_CPU` caused `SIGXCPU`; the parent watchdog killed and reaped a child ignoring `SIGTERM`; `RLIMIT_AS` blocked new anonymous mappings near its configured address-space cap; `RLIMIT_DATA` returned `EINVAL`. All eight children across two runs were reaped with no orphan observed, and stable outcomes matched. This does not establish general RSS containment, parser/schema behavior, supported-OS coverage, or production cancellation. R13 artifacts and exact observations: `docs/research/IP-2/IP-2A-R13-WORKER-RESOURCE-FEASIBILITY.md`, `tests/research/ip2a/r13/results.json`. B01 PENDING EXTERNAL CONFIRMATION; B02 PENDING / NOT CLEARED; B03 PARTIAL / NARROWED / OPEN; B04 minimum policy PASS / ARCHITECT ACCEPTED and overall PARTIAL / OPEN; IP-2A PARTIAL / INCOMPLETE; IP-2B BLOCKED / NOT AUTHORIZED; overall IP-1 PARTIAL / NOT PASS. No production code, parser, IPC, schema, or fixture was created. Temporary binary removed. `AGENTS.md` remains untouched and excluded. Branch: `implementation/ip-2a-r13-worker-resource-feasibility`, from `28ed59ce0fee7e7c0555beaa5de2fa188fb5f6bf`. Stop for independent Architect review.

### Historical gate activity — IP-2A R12 parser resource-containment decision

**Authorization:** IP-2A R12 documentation/architecture decision only, based on existing R2/R3/R10 evidence. Decision: **INSUFFICIENT EVIDENCE — FURTHER QUALIFICATION REQUIRED**; no parser architecture selected. **B03 = PARTIAL / NARROWED / OPEN**; no hard parser/process CPU or memory bound, supported-OS matrix, or cancellation deadline is established. R3 child kill/reap remains a one-host research observation only. One minimal future signed-child resource-control feasibility probe is specified but not run or authorized. R11 remains PASS / ARCHITECT ACCEPTED for minimum B04 policy; B04 overall remains PARTIAL / OPEN. B01 PENDING EXTERNAL CONFIRMATION; B02 PENDING / NOT CLEARED; IP-2A PARTIAL / INCOMPLETE; IP-2B BLOCKED / NOT AUTHORIZED; overall IP-1 PARTIAL / NOT PASS. No probe, test, implementation, schema, dependency, or runtime work occurred. `AGENTS.md` remains untouched and excluded. Branch: `implementation/ip-2a-r12-resource-containment-decision`, from `a3492a6239098da7437295242ab673eee962beb6`. Stop for independent Architect review.

### Historical gate activity — IP-2A R11 B04 file-reference policy

**Authorization:** IP-2A R11 documentation and joint policy work only, using existing R4–R8 evidence. **B04 = READY FOR FINAL POLICY REVIEW; blocker remains PARTIAL / OPEN.** The minimum policy is frozen for review: path strings are locators; unsandboxed open is not system-granted authority; authority, opened-object identity and content continuity are distinct; reacquire qualified authority, open once, check the descriptor, bounded-read the same descriptor, avoid unsafe reopen, balance scope, and fail closed. Alias/symlink use is conditional on explicit bounded resolution under qualified authority and secure target open. Export requires reacquisition, reread/revalidation and semantic-projection comparison; mismatch or inconclusive comparison invalidates route confirmation and dependent publication consent. No full source digest by default.

R10 PASS / ARCHITECT ACCEPTED as a documentation/evidence-classification substage; B01 PENDING EXTERNAL CONFIRMATION; B02 PENDING / NOT CLEARED; B03 PARTIAL / NARROWED / OPEN; B04 PARTIAL / OPEN; IP-2A PARTIAL / INCOMPLETE; IP-2B BLOCKED / NOT AUTHORIZED; overall IP-1 PARTIAL / NOT PASS. Actual transport, alias/provider behavior, supported OS/provider matrix and semantic continuity remain unqualified. No probe, test, implementation or runtime work occurred. Branch: `implementation/ip-2a-r11-file-reference-policy`, from `7109738caf0bad2e8dfed86f4787a4abd090c1ca`. `AGENTS.md` remains untouched and excluded. Stop for independent Architect review.

### Historical gate activity — IP-2A R10 B03 security-control review

**Authorization:** IP-2A R10 documentation and review of existing R2/R3 evidence only. **B03 = PARTIAL / NARROWED; OPEN / NOT QUALIFIED.** Existing controls are classified in `docs/research/IP-2/IP-2A-R10-B03-SECURITY-QUALIFICATION.md`: the byte cap is a read-boundary limit; event counters are application callback limits; timing/RSS are observations; cancellation is cooperative; process termination remains a research experiment. No hard parser/process memory or CPU bound, fixed cancellation deadline, schema-validation workload, supported macOS matrix, or production integration is qualified. No parser/worker architecture is selected.

Preserved: IP-1A R4 outreach PASS / ARCHITECT ACCEPTED (IP-1A overall remains PARTIAL); B01 PENDING EXTERNAL CONFIRMATION; B02 PENDING / NOT CLEARED; B04 PARTIAL / OPEN; IP-2A PARTIAL / INCOMPLETE; IP-2B BLOCKED / NOT AUTHORIZED; overall IP-1 PARTIAL / NOT PASS. No probe, test, build, schema, fixture, dependency or implementation was created or run. Branch: `implementation/ip-2a-r10-b03-qualification-plan`, from `2561888f717b1ae8fdfd2611495d21111c987d8c`. The unrelated `AGENTS.md` worktree modification remains untouched and excluded. Stop for independent Architect review.

### Historical gate activity — IP-1A R4 external-confirmation preparation

**Authorization: IP-1A R4 preparation and outreach for IP1-B01/B02 only.** The CIRM inquiry was sent 2026-10-14 09:59:43 UTC and the Topografix publisher-linked inquiry at 09:59:58 UTC; Gmail confirms Sent status. No replies or bounces were found at the status check, and receipt is not confirmed. B01 remains PENDING EXTERNAL CONFIRMATION; B02 remains PENDING / NOT CLEARED; IP-1A remains PARTIAL. IP-2A R9 documentation/critical-path stage was accepted PASS / ARCHITECT ACCEPTED, but IP-2A overall remains PARTIAL / INCOMPLETE; IP-2B remains BLOCKED / NOT AUTHORIZED; overall IP-1 remains PARTIAL / NOT PASS. No schema files were downloaded or attached and no runtime or implementation work occurred. The unrelated local `AGENTS.md` modification remains untouched and excluded.

Exact outgoing text, hashes, UTC timestamps and mail IDs: `docs/research/IP-1/IP-1A-R4-EXTERNAL-CONFIRMATION.md`. Current branch: `implementation/ip-1a-r4-external-confirmation`, based on `2630843a60f573856183fbc92a0fcccdaf45b3e7`. IEC is conditional follow-up only if CIRM cannot establish lineage or rights authority.

### Historical gate activity — IP-2A R9 acceptance recovery

**Authorization: IP-2A R9 documentation and planning only. IP-2A R8 documentation closeout: PASS / ARCHITECT ACCEPTED; IP-2A overall remains PARTIAL / INCOMPLETE; no overall IP-2A PASS is claimed.** The §11 acceptance matrix and critical-path plan are in `docs/research/IP-2/IP-2A-ACCEPTANCE-RECOVERY-PLAN.md`. `IP1-B03` and `IP1-B04` remain OPEN / PARTIAL; `IP1-B01/B02` remain unresolved; **IP-2B = BLOCKED / NOT AUTHORIZED**; overall IP-1 remains **PARTIAL / NOT PASS**. No implementation, probe, schema, fixture, dependency, test, or platform work occurred in R9. The proposed IP-1A external-confirmation action had not been executed at the R9 handoff. The unrelated local `AGENTS.md` modification remains untouched and excluded.

R9 confirms that §11 requires an exact registry source, legal offline runtime, cap rationale/enforcement, reproducible security evidence, and joint IP-2A/IP-5/IP-7 file-reference policy. Actual product transport/UX and full preview/export integration remain assigned to later IP-5/IP-7 work, while the minimum joint policy remains an IP-2A PASS criterion. R8 evidence remains historical and unchanged.

### Historical gate activity — IP-2A R8 closeout

**Authorization: IP-2A R8 documentation and closeout only. IP-2A status: PARTIAL / INCOMPLETE; no PASS is claimed.** R8 consolidated R1–R7, recorded the candidate input/authority boundary for review, and assigned remaining qualifications to their owners. `IP1-B03` and `IP1-B04` remain open. **IP-2B = BLOCKED**; overall IP-1 remains **PARTIAL / NOT PASS**. No runtime probe or implementation was authorized or performed in R8. The closeout document is prepared for independent review.

Details: `docs/research/IP-2/IP-2A-CLOSEOUT-AND-HANDOFF.md`. The unrelated local `AGENTS.md` modification remains untouched and excluded.

### Historical gate activity — IP-2A R7 independent receiver authority

**Authorization: IP-2A R7 research and decision work only. Verdict: PARTIAL.** On macOS 26.6.2 (25G83), arm64, an independently launched sandboxed receiver without selected-file or inherit entitlement received `EPERM` for both readable synthetic paths. An ordinary unsandboxed comparison read synthetic files only where ordinary permissions allowed; mode-000 returned `EACCES`. A deterministic replacement at the same pathname changed object identity, and the opened descriptor did not match the original identity.

The Shortcuts shell process was observed only without file input; a file-argument result was not conclusive. `launchctl procinfo` was unavailable or denied to the non-root probe. R5 native-picker/inherited-helper evidence remains a separate, historical configuration. Details: `docs/research/IP-2/INDEPENDENT-RECEIVER-AUTHORITY-R7.md`; sanitized outcomes: `tests/research/ip2a/r7/results.json`.

**Disposition:** Shortcuts carrier **PARTIAL / NOT QUALIFIED**; independent sandboxed path authority **BLOCKED**; ordinary reads **ORDINARY PERMISSIONS ONLY**; `IP1-B04` **PARTIAL / OPEN**; `IP1-B03` **OPEN / PARTIAL / NOT QUALIFIED, unchanged**; IP-1 overall **PARTIAL / NOT PASS**. IP-2B–IP-2E and production implementation remain **NOT AUTHORIZED**.

**Git baseline:** branch `implementation/ip-2a-r7-receiver-authority`, reviewed baseline and parent `ef4da7cf51818e079a9eb17c7b2c387d07d163e1`. Unrelated modified `AGENTS.md` remains untouched and excluded.

### Historical gate activity — IP-2A R6 Finder / Shortcuts transport

**Authorization: IP-2A R6 only. Verdict: PARTIAL.** The Shortcuts action catalog became populated after an existing action-bearing Shortcut was opened, but the internal cause of the initial empty pane is not established. A local R6 research Shortcut was exposed in Finder Quick Actions. With its shell action explicitly bound to Shortcut Input and configured to pass input as arguments, Finder delivered one or two POSIX path strings; the receiver opened the synthetic regular files and matched their unique contents. A generic `Input` binding first produced zero arguments. Finder therefore supplies a **PATH LOCATOR ONLY** in this tested setup. No independent security-scoped authority, sandbox grant, identity continuity, cancellation/permission behavior, or product transport was qualified.

The complete method, observations and limits are in [`docs/research/IP-2/SHORTCUTS-TRANSPORT-R6.md`](docs/research/IP-2/SHORTCUTS-TRANSPORT-R6.md). The retained research Shortcut's receiver was reduced after testing so it no longer reads files or writes logs. No research source-code file or scope-exception record, real route, fixture, executable, schema, dependency, product Shortcut, or runtime artifact was committed. The existing IP-1D Shortcut and empty R5 draft were preserved.

**Disposition:** action-library root cause **UNRESOLVED**; Shortcuts carrier **PARTIAL**; Finder Quick Action carrier **PARTIAL**; standalone receiver authority **BLOCKED**; `IP1-B04` **PARTIAL / OPEN**; `IP1-B03` **OPEN / PARTIAL / NOT QUALIFIED, unchanged**; IP-1 overall **PARTIAL / NOT PASS**. Gate 3 remains **PASS / ARCHITECT ACCEPTED**; Gate 4 remains stage-specific. IP-2B–IP-2E, production work and release remain **NOT AUTHORIZED**.

**Git baseline:** branch `implementation/ip-2a-r6-shortcuts-transport`, reviewed baseline and parent `d7ca083a4069641599d281d23ebcfc66155ab395`.

### Historical gate activity — IP-2A R5 Finder / Shortcuts file-authority transport

**Gate 3: PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 is stage-specific, never blanket authorization. Current authorization: **IP-2A R5 only**, including its expiring research-only sender/receiver exception. IP-2B–IP-2E, production CLI/app/Shortcut, later stages and release remain **NOT AUTHORIZED**. Overall IP-1: **PARTIAL / NOT PASS**.

- **IP-2A R5: PARTIAL.** A real sandboxed native picker selected two synthetic space/Unicode filenames and the app read their expected bytes through bounded descriptors. A mode-000 selected file failed descriptor open with `EACCES` even though scope start returned true. An inherited-sandbox helper read the same objects and bytes via a path locator and default-option Foundation bookmark data. A same-process delayed reopen after scope stop succeeded for the local files. Details and limitations: `docs/research/IP-2/FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md`; result manifest and reproducible source: `tests/research/ip2a/r5/`.
- **Carrier/readiness:** Finder Quick Action **BLOCKED / NOT TESTED**. Shortcuts **BLOCKED** because the action library UI returned no actions for relevant searches; a uniquely named empty R5 draft exists and was not run. The existing IP-1D iCloud Shortcut was not modified or invoked. Native picker and inherited-child transfer are **PARTIAL** for this single host/setup; neither proves standalone CLI authority. Export-time semantic continuity is **PARTIAL**, not qualified.
- **IP1-B04 remains PARTIAL / OPEN.** Actual Finder/Shortcut transport, standalone receiver authority, alias/symlink/provider behavior, replacement/deletion races, supported OS matrix and preview/export semantic comparison remain unqualified. **IP1-B03 remains OPEN / PARTIAL / NOT QUALIFIED**; IP1-B01/B02 remain unresolved. No digest, private route or real coordinates were used.
- `IP-2A R5` exception and research artifacts are limited to the approved Swift sender/receiver, temporary sandboxed build, synthetic inputs/results and README under `tests/research/ip2a/r5/`. No production code, schemas, dependencies, committed binaries, product Shortcut, app package or release artifact was created. The unrelated `AGENTS.md` modification remains untouched and uncommitted.
- **Git:** branch `implementation/ip-2a-r5-finder-shortcuts-transport`; R5 research commit `b0f066af96534f2834d024c0586b6959bf3f8058` (parent `7314b123723f6253544917b324529cfe767cd580`); reporting follow-up is the current handoff commit.
- **Next:** independent Architect review of IP-2A R5 PARTIAL. Stop before IP-2B or any later stage.

### Historical gate activity — IP-2A R4 FileReference / source continuity

At the R4 handoff, Gate 3 was **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 was stage-specific, never blanket authorization. **Historical R4 authorization:** IP-2A R4 only, including the narrow expiring research-only exception in `docs/research/IP-2/IP-2A-R4-SCOPE-EXCEPTION.md`. IP-2B–IP-2E, IP-3–IP-7 execution, production implementation and release remained **NOT AUTHORIZED**. Overall IP-1: **PARTIAL / NOT PASS**.

- **IP-2A R4: PARTIAL.** Synthetic one-host macOS 26.6.2 arm64 probes showed descriptor reads remain bound to the opened object through rename/move, path replacement, symlink retarget and deletion; in-place mutation is visible through that descriptor. Local permission/type checks passed. A bookmark followed rename while marked stale and failed after deletion. Full facts and limitations: `docs/research/IP-2/FILE-REFERENCE-AND-CONTINUITY.md`; reproducibility artifacts: `tests/research/ip2a/r4/`.
- **IP1-B04 remains OPEN / PARTIAL.** Finder/Shortcuts carrier and sandbox scope handoff, alias policy, File Provider behavior and production semantic preview/export comparison remain unqualified. **IP1-B03 remains OPEN / PARTIAL / NOT QUALIFIED**; IP1-B01/B02 remain unresolved. No digest or real route data was used.
- Added the R4 scope exception, research-only Swift probe, local runner, README and sanitized result manifest; updated the IP-2 security record, IP-1 blocker register, REPORT and this ledger. No production parser/model/CLI/app/Shortcut, schema, dependency or compiled artifact was added. The pre-existing `AGENTS.md` modification remains untouched and excluded.
- Branch `implementation/ip-2a-r4-file-reference-continuity`; R4 evidence commit `8315e677edbb5781f96aa838b8097e9928b11bea`, parent `8b73f44fe82f3b47187c5ba49ad5ee315f4ea433`. A follow-up handoff-record commit captures this SHA; final remote HEAD is reported after push verification.
- **Next:** independent Architect review of IP-2A R4. Stop before IP-2B or later work.

### Historical gate activity — IP-2A R3 runtime safety

**Gate 3: PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 is stage-specific, never blanket authorization. **Authorization at the R3 handoff:** IP-2A R3 only, including the narrow expiring exception in `docs/research/IP-2/IP-2A-R3-SCOPE-EXCEPTION.md`. IP-2B–IP-2E, IP-3–IP-7 execution, production implementation and release remained **NOT AUTHORIZED**. Overall IP-1: **PARTIAL / NOT PASS**.

- **IP-2A R3: PARTIAL.** A reproducible research harness rebuilt official libxml2 2.15.4 source (archive SHA-256 `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`) as a static arm64 candidate and verified runtime version `21504` with no dynamic libxml2 dependency. Host: macOS 26.6.2 (25G83), arm64, Apple clang 21.0.0. `self-test` completed with `failures=0`; inputs, expected/observed results and hashes are recorded under `tests/research/ip2a/`.
- R2 synthetic DTD/entity/resource denial and callback boundary cases reproduced. Cooperative asynchronous cancellation was observed during descriptor read and cleanup; no partial result was returned, close ran once, and no parser-context API was called from the cancelling thread. A disposable CPU-bound child was terminated/reaped. Twenty-repeat CPU/RSS measurements include harness/runtime and generated inputs; callback boundaries are not hard allocation limits.
- **IP1-B03 remains OPEN / PARTIAL / NOT QUALIFIED.** Supported macOS coverage, robust hard resource bounds, cancellation deadline, product integration and independent review remain open. **IP1-B04 remains OPEN / PARTIAL, unchanged**; Finder/Shortcuts references, aliases, security scopes, permissions, identity and continuity were not exercised. IP1-B01/B02 remain unresolved; no RTZ/GPX schema was used.
- Readiness: IP-2A **PARTIAL**; IP-2B–IP-2E **NOT AUTHORIZED**. IP-1 overall remains **PARTIAL / NOT PASS**. No downstream work is authorized.
- Added only the recorded scope exception, research harness sources/scripts/docs/results and the five requested documentation updates. No production implementation, production test target, RTZ/GPX schema, third-party source, binary, private route or vessel data was created or committed. The pre-existing `AGENTS.md` change is untouched and excluded.
- Branch `implementation/ip-2a-r3-runtime-safety`, baseline/parent `636ce15f70e874f88f0a4317f3862a8efcb0936d`; commit/remote details will be reported after verification.
- **Next:** independent Architect review of IP-2A R3. Stop before IP-2B or any later work.

### Historical gate activity — IP-2A R2 libxml2 security qualification

The R2 handoff below records its results and authorization at that time; R3 was current at the R2 handoff. R5 and R7 were later snapshots, and R8 is the current closeout status at the top of this ledger.

### Historical gate activity — IP-2A R1 security and runtime feasibility

**Historical authorization at the R1 handoff:** IP-2A R1 only. Gate 3 was **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; Gate 4 is stage-specific, never blanket authorization. Authorization at the R1 handoff was for R1 only.

- IP-2A R1: **PARTIAL**. Foundation XMLParser alone does not meet the strict DTD policy in the observed case; libxml2 remains a candidate, not selected or qualified; Xerces-C++ is not recommended.
- IP1-B03: **PARTIAL / OPEN, NOT QUALIFIED**. IP1-B04: **PARTIAL / OPEN**; joint FileReference, alias/security-scope and source-continuity requirements remain unqualified. IP1-B01/B02 remain open. Overall IP-1: **PARTIAL / NOT PASS**.
- Provisional resource ceilings and future evidence requirements are in `docs/research/IP-2/RESOURCE-LIMITS.md`; none is approved or measured as a hard bound.
- Disposable probe: synthetic in-memory XML only, on macOS 26.6.2 arm64 / Swift 6.3.3. The bare DOCTYPE was accepted with no DTD callback; this host-specific observation does not qualify other OS versions or production behavior. No app tests or persistent probe artifacts were created.
- Added `docs/research/IP-2/INPUT-AND-SECURITY-DECISIONS.md` and `docs/research/IP-2/RESOURCE-LIMITS.md`; updated the blocker register, this ledger and REPORT.md. No schemas, fixtures, dependencies or implementation artifacts were created. Pre-existing `AGENTS.md` change remains untouched and uncommitted.
- Branch `implementation/ip-2a-security-runtime-feasibility`, based on reviewed baseline `4329b04193652b7fe555180ecd51e238b1271d4d`.
- **Next:** independent Architect review. Stop before IP-2B or later work.

### Historical handoff — IP-1A R3 rights, provenance and offline validation (superseded)

**Gate 3: PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 is stage-specific and never blanket authorization. The current task authorizes **IP-1A R3 only**. IP-2–IP-7 execution and implementation remain **NOT AUTHORIZED**.

- IP-1A R3: **PARTIAL**. IP-1B PASS; IP-1C PARTIAL; IP-1D PARTIAL; IP-1E PASS (documentation-level); IP-1F PASS (protocol-design only); IP-1G PASS / ARCHITECT ACCEPTED. **Overall IP-1: PARTIAL / NOT PASS.**
- RTZ 1.2 exact artifact provenance: **REQUIRES EXTERNAL CONFIRMATION** (`IEC PAS 6XXXX` unresolved; no authoritative exact-byte mapping). RTZ schema copying, bundling, local installation and redistribution: **BLOCKED / NOT CLEARED**. GPX raw-XSD rights: **CONDITIONAL / NOT CLEARED**. No lawful offline schema validator is approved.
- IP1-B01 remains REQUIRES EXTERNAL CONFIRMATION; IP1-B02 remains BLOCKED / NOT CLEARED; IP1-B03 remains OPEN / NOT QUALIFIED. No unrelated blocker is closed.
- Readiness only: IP-2A **PARTIAL** (documentation investigation could be separately authorized); IP-2B **BLOCKED**; IP-2C **BLOCKED**; IP-4 schema-backed validation **BLOCKED**. No downstream stage is authorized here.
- Candidate A (pinned static libxml2 plus licensed local XSDs) is the leading conditional technical direction, not selected or qualified. Account for CVE-2026-6732, security patch ownership, exact resource resolution and target-macOS behavior. No probe or dependency installation was performed.
- Inquiry drafts remain unsent. Existing schema hashes and R1/R2 validation observations are preserved; no tests were rerun. No code, fixtures, schema, dependencies, Shortcut, package or runtime artifact created.
- Branch: `implementation/ip-1a-r3-rights-provenance-runtime`; reviewed baseline `ddd17bf1306e5140ffcd86e61e9a12a6e9008673`; commit SHA, parent and remote HEAD are provided in the final handoff. Pre-existing `AGENTS.md` change remains untouched and uncommitted.
- **Next:** independent Architect review of IP-1A R3; stop before IP-2–IP-7 or implementation.

### Historical handoff — IP-1G before independent acceptance (superseded)

**GATE 3: PASS / ARCHITECT ACCEPTED** at owner-confirmed commit `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. **Gate 4 is authorized for IP-1G only by the current owner task.** IP-2–IP-7 execution, production implementation, Windy uploads, schema redistribution, packaging/signing and release remain **NOT AUTHORIZED**.

- **IP-1G: REVIEW — integration and closeout package prepared; independent Architect acceptance pending.** See `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md` for the evidence inventory, full traceability matrix, 15-item blocker register, contradictions and readiness recommendation.
- **Overall IP-1: PARTIAL / NOT PASS.** IP-1A PARTIAL; IP-1B PASS (static fixtures only); IP-1C PARTIAL; IP-1D PARTIAL; IP-1E PASS (documentation only); IP-1F PASS (protocol only). IP-1G cannot be marked PASS until independent Architect acceptance.
- Do not start IP-2B/IP-2C parser implementation. A limited IP-2A documentation-only investigation is only a candidate for a separate explicit authorization and could not pass while schema rights/runtime, dialect, and joint file-reference requirements remain open. Recommended next gate: independent review, then focused IP-1A rights/provenance/runtime resolution.
- At that historical IP-1G handoff, material status inconsistencies were recorded in the Master Plan, approved plan headers and IP-6. Governance reconciliation R1 resolves IP1-B15; this historical entry records the earlier state only.
- No code, tests, probes, fixtures, schemas, dependencies, Windy imports, runtime files, Shortcuts, packages, signing or installation were performed/created. Existing `AGENTS.md` modification remains untouched and uncommitted.
- Branch `implementation/ip-1g-integration-closeout`, baseline `b964b51584c79fde7af06100809ccca1f54333df`; commit/remote SHA will be reported in handoff.
- **Next:** independent Architect review. No IP-2–IP-7 execution or implementation is authorized.

### Historical handoff — IP-1F only

**GATE 3: PASS / ARCHITECT ACCEPTED** at owner-confirmed commit `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. **Gate 4 is authorized for IP-1F only by the current owner task.** IP-1G, IP-2–IP-7 execution, production conversion, Windy empirical testing, implementation and release remain **NOT AUTHORIZED**.

- **IP-1F: PASS (protocol design only).** Added a separate synthetic-only ordinary Uploader and Route Planner protocol, ten acceptance profiles plus all four route modes and both explicit Current Position connector geometries, strict outcome and aggregate rules, order/coordinate evidence requirements, publication/privacy boundaries and a reusable test record. No Windy import/upload or compatibility test was performed; consumer status remains NOT TESTED.
- Current Route Planner import entry point: **TO VERIFY DURING IP-6**. Historical Windy Staff workflow steps are not treated as current instructions; the current editorial confirms general GPX import/display only.
- Mandatory multi-point Route Planner cases: two-point, multiple ordered points, route/waypoint names, source route-name default, explicit override, explicit omission, antimeridian, Unicode/XML escaping and decimal precision, across all four modes and both explicit Current Position connector geometries. One-point is a required separate informative observation and does not gate or change G3-004 export policy. Generic Uploader PASS cannot replace Route Planner PASS.
- **No Windy interaction, GPX generation, fixtures, application code, tests, CLI, Shortcut, package, schema, dependency or runtime artifact was created or executed.** IP-1G and implementation remain unauthorized.
- Branch `implementation/ip-1f-windy-acceptance-protocol`, baseline `debf177a979027323890bed31369303645d2bcbd`. Pre-existing `AGENTS.md` modification remains untouched and uncommitted. Commit/remote SHA will be reported in handoff.
- **Next:** independent Architect review before IP-1G.

### Historical handoff — IP-1E only

**GATE 3: PASS / ARCHITECT ACCEPTED** at owner-confirmed commit `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. **Gate 4 is authorized for IP-1E only by the current owner task.** IP-1F onward, IP-2–IP-7 execution, production implementation, packaging/release execution and release remain **NOT AUTHORIZED**.

- **IP-1E: PASS (documentation-level).** Recommends the approved arm64 `.app` + self-contained local CLI + signed/notarized/stapled `.dmg` + exported `.shortcut`; defaults install to `~/Applications` for standard-user permissions. Bundle layout, signing, hardened runtime, nested signing, notarization, ticket stapling, Gatekeeper/offline test, Shortcut/Finder enablement, update/rollback/removal, Developer ID account/pricing requirements and clean-user procedure are documented.
- Candidate floor: macOS Sequoia 15.8. Concrete unqualified matrix: Sequoia 15.8, Tahoe 26.7.1 and Golden Gate 27 (initial release) on Apple Silicon; no OS version is declared supported. Previous IP-1D observation on Tahoe 26.6.2 is transport-only and is not packaging evidence.
- **Outstanding blockers:** IP-1D Finder file representation/CLI discovery; joint IP-2/IP-5/IP-7 security-scoped reference, identity and continuity policy; cancellation/error mapping; real clean-user signing/notarization/Gatekeeper/offline matrix; IP-1A schema rights/offline validator; IP-7 UI acceptance. See `docs/research/IP-1/PACKAGING-DECISION.md`.
- No app, DMG, Shortcut artifact, executable, signing, notarization, install, OS/network configuration or implementation was created/run. The existing temporary IP-1D Shortcut remains in the Shortcuts library because deletion was explicitly shown to sync across all iCloud devices; no delete action was confirmed.
- Branch `implementation/ip-1e-packaging-decision`, parent baseline `767e1a1791202969122db8a98f7459a98201cab8`. Unrelated pre-existing `AGENTS.md` remains untouched and uncommitted. Commit/remote SHA will be recorded in the final handoff.
- **Next:** independent Architect review of IP-1E documentation-level PASS. IP-1F and implementation remain unauthorized.

### Historical handoff — IP-1D only

**GATE 3: PASS / ARCHITECT ACCEPTED** at owner-confirmed commit `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. **Gate 4 is authorized for IP-1D only by the current owner task.** IP-1E onward, IP-2–IP-7 execution, production parser/converter/CLI, product Shortcut, application implementation, packaging and release remain **NOT AUTHORIZED**.

- **IP-1D: PARTIAL.** On macOS 26.6.2 build 25G83 / arm64 with Shortcuts 7.0 build 4711, synthetic stdin arrived byte-exactly at 51 bytes (Unicode/metacharacters) and 262,144 bytes; success JSON appeared in Shortcuts. Deliberate exit 7 produced an alert containing the fixed stderr marker; a separate numeric exit status was not exposed. Stop interrupted the inert 60-second action.
- Shortcuts “as arguments” yielded `argc=0` in the tested Text-action setup. Finder Quick Action invocation was confirmed, but its input representation and result were not observable. Multiple-file transport, malformed/oversized input, response bounds, child-process cancellation guarantees, picker/save/Reveal/permissions, offline with networking disabled, other macOS versions and security-scoped access remain unqualified. No transport selection, minimum-OS support, or system-wide offline claim is made.
- Full matrix/evidence and closure owners: `docs/research/IP-1/SHORTCUTS-FEASIBILITY.md`. JSON stdin remains a candidate only; IP-5 owns protocol/error mapping, IP-2/IP-5/IP-7 jointly own file acquisition/continuity, and IP-7 owns UI acceptance.
- No production code, product Shortcut, RTZ/GPX fixture, schema, dependency, package, or runtime artifact was committed. The inert probe, temporary Shortcut and synthetic temporary files are excluded from Git.
- Branch `implementation/ip-1d-shortcuts-transport`, parent baseline `85956a226980691eb74cbf9ac56c1258aa90c2c1`. Unrelated pre-existing `AGENTS.md` change is preserved and excluded. Commit and remote verification will be reported in the task handoff.
- **Next:** independent Architect review of IP-1D PARTIAL. IP-1E and all later work remain unauthorized.

### Historical handoff — IP-1C only

- **IP-1C: PARTIAL.** Added geometry reference vectors and the GPX 1.1 contract. GeographicLib Python 2.1 was configured to the approved authalic sphere and cross-checked against an independent unit-vector calculation. Seventeen numeric outputs and two unavailable-domain classifications were generated twice with identical output SHA-256 `2cdad3e6bcd6d2ca76eb1feb32ca320ae8e3334efaa4460be69c6557200f0919`. Spherical rhumb formula outputs were cross-checked against Simpson line-element integration (2048 intervals; max difference `1.40e-9 m`); execution of the official `RhumbSolve` oracle and independent reviewer reproduction remain outstanding.
- The vector set covers ordinary, north/south, east/west, antimeridian, high latitude, near/coincident endpoints, near-antipodal behavior, degenerate/tie classifications, GC/rhumb divergence, and finite-rhumb closest-point exact cases with global proofs. The general G3-006 minimizer is still unqualified; no global root-completeness method or general numerical error bound is claimed. Affected general joins remain fail-closed.
- GPX 1.1 local schema check: Topografix XSD SHA-256 `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6`; `xmllint`/libxml2 2.9.13 accepted synthetic one-point output and rejected `+180` longitude. The XSD and temporary documents are not committed. GPX XSD rights remain conditional; no redistribution clearance or runtime validator qualification is claimed.
- Byte-level determinism is not required; semantic determinism is mandatory. One-point output remains allowed with warning and affirmative route confirmation. No GPX serializer, production geometry, fixtures, schemas, dependencies, runtime code or Windy test was created/run.
- **IP-1A remains PARTIAL; IP-1B remains PASS.** RTZ XSD rights, exact RTZ 1.2 IEC artifact lineage, GPX XSD rights and offline runtime validation strategy remain unresolved. No IP-1 PASS is implied.
- Branch: `implementation/ip-1c-geometry-gpx-contract`, based on IP-1B commit `aa97b3e445d2edb85ad6795952b06ca28019dbfb`. The unrelated `AGENTS.md` user edit is preserved and excluded from this stage commit.
- Next: independent Architect review of IP-1C PARTIAL evidence. IP-1D and later work remain unauthorized.

### Historical IP-1B activity

- **IP-1B: PASS — static synthetic fixture corpus and qualification matrix complete.** This is not an IP-1 PASS, RTZ support claim, or parser result.
- 35 project-authored fixtures are indexed by stable ID in `tests/fixtures/rtz/synthetic/manifest.json`. Results: 19 XSD-valid, 13 XSD-invalid, one malformed XML, one unsupported version with no schema selected, and one security-sensitive DOCTYPE/entity case deliberately not XSD-validated. Validation used temporary schemas and `xmllint --nonet`; no application parser/tests were run.
- Corpus README, coverage matrix, fixture hashes, exact schema hashes, actual results, negative-case intent and synthetic provenance are recorded under `tests/fixtures/rtz/synthetic/`.
- **IP-1A remains PARTIAL.** RTZ 1.0/1.2 redistribution remains **NOT CLEARED**; exact RTZ 1.2 IEC artifact linkage remains externally unconfirmed; GPX XSD scope remains conditional; offline runtime validation/legal strategy and independent sign-off remain open. RTZ 1.1 remains conditional/non-blocking.
- No third-party XSD or sample was committed. No source route, vessel identity, private coordinates, parser, geometry implementation, GPX serializer, CLI, Shortcut, dependency, or package was added.
- Branch: `implementation/ip-1b-synthetic-fixture-corpus`; parent: reviewed baseline `8e94ae0875ef914fec0f5ddc40ca3d3fe6f920bc`. The pre-existing `AGENTS.md` modification remains untouched and uncommitted. Final commit and remote HEAD are recorded in the handoff.
- Next: independent Architect review of IP-1B. IP-1C and all later work remain unauthorized.

## Historical gate activity — Gate 3 final independent review pending (superseded by owner acceptance)

Historical reconciliation status, superseded by the current owner authorization and IP-1B handoff above.

**EFFECTIVE GATE 3 STATUS: PENDING FINAL INDEPENDENT ARCHITECT REVIEW.** The remote PASS declaration at `d9f723ba91091c682c9676f41dc168da31a252f1` is retained as historical, superseded for current authorization.

- R2 applied: corrected the stale Master Plan route-name mapping and IP-4/IP-5 one-point decision statements. Both divergent documentation histories are preserved in the local recovery merge.
- Gate 1: **APPROVED / PASS**. IP-1–IP-7 plans remain approved; reconciliation edits do not authorize their execution.
- Gate 4: **NOT AUTHORIZED**. Stage execution: **NOT AUTHORIZED**. Overall implementation: **NOT AUTHORIZED**. IP-6 consumer acceptance: **NOT TESTED**.
- Branch: `docs/gate-3-reconciliation`, based on approved IP-7 HEAD `482c8b585635138174dbf64d309cc3f308e3dcd9`.
- The accepted R1 reconciliation records approved decisions G3-001–G3-011. Full decision ledger, verified baseline, ownership, residual technical qualifications and stop conditions: `docs/implementation/GATE-3-RECONCILIATION-R1.md`.
- Stage decompositions and the seven-stage roadmap are unchanged. Route confirmation and publication consent remain distinct. No package, source identity mechanism, numerical geometry behavior, Windy compatibility or platform behavior is claimed qualified.
- This closure changes only status/governance wording in the Master Plan, IP-1–IP-7 plans, `REPORT.md`, this ledger and the reconciliation report. No implementation, tests, fixtures, schemas, dependencies, runtime probes or Shortcuts were created or run.
- No push is authorized by this task. Current merge is local and awaits independent Architect review.

## Historical gate activity — prior stage handoffs (before Gate 3 review closure)

### IP-7 (before Gate 3 R1 reconciliation)

**IP-7 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK (R1 corrections applied)**

- Gate 1: **APPROVED / PASS**.
- IP-1 through IP-6 plan statuses and IP-6 consumer status are unchanged; see entries below. IP-6 consumer acceptance remains **NOT TESTED** and IP-6E report **NOT STARTED**.
- IP-7 execution: **NOT AUTHORIZED**. Gate 3 cross-check: **NOT AUTHORIZED**. Overall implementation: **NOT AUTHORIZED**. Gate 1 and IP-1–IP-6 statuses are preserved.
- Branch: `docs/ip-7-macos-shortcuts-ux-install-release`, R1 baseline `e593201e833bc1cba04523c036acc037dda9b2c8`.
- Plan path: `docs/implementation/IP-7-MACOS-SHORTCUTS-UX-INSTALL-RELEASE-PLAN.md`.
- R1 separates route confirmation from publication consent. Destination-only changes invalidate publication consent but preserve still-valid route confirmation; source/semantic changes invalidate route confirmation and publication consent bound to its output; target-state changes invalidate publication consent. IP-5 revalidates source/preview continuity and target before publication. IP-5D continuity remains unresolved.
- Mandatory offline acceptance now covers fully local, available inputs and local destinations across all four modes and both entry paths. File Provider/cloud-backed states are conditional, provider-specific qualification; safe unavailable-state handling does not weaken the local offline guarantee or claim OS/provider-wide network inactivity.
- The plan specifies Finder and standalone Shortcut journeys, native-interaction candidates requiring platform qualification, safe destination/overwrite behavior, transport/authority evaluation, diagnostics, privacy/accessibility, candidate `.app`/DMG distribution, onboarding/update/removal, synthetic acceptance matrix, IP-7A–IP-7F, dependencies and release gate.
- Remaining cross-stage blockers are preserved: IP-4 one-point/name policy; IP-3 closest-point metric; IP-2/IP-5/IP-7 aliases and file-reference authority; IP-5D source continuity; IP-5E output permissions/provider/atomicity; IP-1D transport; IP-1E packaging/OS matrix; IP-6 consumer verdict.
- No implementation, fixtures, tests, schemas, dependencies, CLI, Shortcuts, package or platform probes created or run. Planning commit and remote verification are in the final task handoff.
- Next: Gate 3 cross-check only after separate authorization. IP-7 execution remains unauthorized.

## Prior gate activity — IP-6

**IP-6 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK** (R1 corrections closed)

- Gate 1: **APPROVED / PASS**.
- IP-1 through IP-5 plans: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; no upstream implementation PASS is claimed.
- IP-6 consumer acceptance: **NOT TESTED**; IP-6E report: **NOT STARTED**; IP-6 execution: **NOT AUTHORIZED**; IP-7 planning: **NOT STARTED**; overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-6-windy-route-planner-acceptance`, reviewed baseline `eca79b4dbba9019d3651c74a603d46bd52960e0a`.
- Target: Windy.com desktop browser, Distance & Planning / Route Planner. Official discovery material documents GPX import and a candidate `More options → Import GPX` path; current UI, route-object type, editability, point/coordinate observability, auth/persistence and browser/OS matrix remain to be manually qualified in IP-6A.
- **Status separation:** future `IP-6E REPORT COMPLETE` means the reviewed evidence analysis is complete for any consumer verdict. It does not mean consumer acceptance passed. Only the independent aggregate consumer verdict may be **IP-6 CONSUMER ACCEPTANCE PASS**.
- Plan distinguishes format validity, serialization, import, object interpretation, order/coordinate fidelity, rendering and overall acceptance. R1 separately classifies imported route-data mutation, display-only rendering/interpolation, and semantics-changing automatic routing. Ambiguous cases are INCONCLUSIVE; only unchanged route data plus non-semantic rendering is not automatically a failure. It defines synthetic-only traceable cases, separate coverage for all four route modes, one-point evidence that does not decide IP-4 policy, negative controls, and a strict aggregate PASS rule. No successful upload alone can pass IP-6.
- Future sub-stages IP-6A–IP-6E: workflow qualification; synthetic corpus; manual import; geometry/metadata assessment; compatibility verdict. No execution artifacts created.
- No application code, scripts, tests, browser automation, import probes, GPX/RTZ fixtures, schemas, dependencies, binaries, packages or Shortcuts created; no Windy interaction or empirical testing occurred; no route uploaded.
- Open questions: current target workflow and environment; account requirements and persistence; imported object type/editability; supported way to inspect order and exact coordinates; upstream synthetic/output evidence; IP-4 one-point and route-name decisions. IP-7 planning remains unauthorized.
- Next: architectural review of IP-6 plan; do not execute IP-6 or begin IP-7 planning without separate authorization.
- Commit and remote verification are reported in the final task handoff.

**IP-5 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK** (R1 conditions closed)

- Gate 1: **APPROVED / PASS**.
- IP-1 through IP-4 plans: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; upstream execution remains **NOT AUTHORIZED**.
- IP-5 execution and overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-5-cli-runtime-packaging`, reviewed baseline `af619b326a3a60a8a32912b3eda94774223c960f`.
- Four R1 corrections: secure `inspect` shares IP-2 acquisition/open/bounded parse/schema/semantic validation and emits bounded transient summaries only from immutable validated `RouteDocument`; preview/confirmation distinguishes source-object identity, content continuity, reference lifetime, semantic preview equivalence and UI consent, with the continuity mechanism unresolved pending IP-2/IP-5/IP-7 qualification; output permissions are evidence-gated (`0600` is only a candidate, with no final mode selected); IP-5D cannot PASS or be rescued by unilateral removal of Current Position from V1.
- Existing conditional JSON stdio and self-contained arm64 `.app`/DMG proposals remain unqualified; IP-5A–IP-5F structure is preserved and none is executed or individually passed.
- IP-5 writer ownership: immutable validated bytes from IP-4; IP-5 writes and reports save state; IP-7 owns destination, overwrite consent and feedback. New-file and replacement policies must separately qualify atomicity, permissions, ACLs, extended attributes and destination-provider semantics.
- Remaining Gate 3 decisions/blockers: inspect over-limit error vs pagination; joint source-continuity and reference/capability lifetime policy; IP-4 one-point/name decisions; IP-1D transport and IP-1E packaging reconciliation. Execution evidence remains needed for schema rights/offline validation, IP-2A alias/scope policy, IP-3 confirmation, IP-6, IP-7, filesystem/provider semantics, signing/notarization and supported macOS matrix.
- No application code, scripts, tests, probes, fixtures, schemas, dependencies, binaries, GPX, packages or Shortcuts created; no tests/probes run.
- Next: Gate 3 cross-check when complete; do not execute IP-5 or begin IP-6 planning without separate authorization.
- Commit and remote verification are reported in the final task handoff.

**IP-4 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK (R1 conditions closed)**

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; execution **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; execution **NOT AUTHORIZED**.
- IP-3 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; execution **NOT AUTHORIZED**.
- IP-4 execution and overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-4-gpx-serialization-loss-report`, R1 base `df9ebbb31ddd3679d0c6c3adb828ab35a64f6303`.
- R1 corrections: one-point policy is unresolved between ALLOW_WITH_WARNING and REFUSE_EXPORT pending Gate 3; route-name override is an unresolved product choice; IP-4 returns immutable validated bytes while IP-5 owns filesystem writing and IP-7 owns destination/consent/feedback; coordinate checks are representation-aware with binary source-decimal error/tolerance evidence required.
- Remaining questions/evidence: Gate 3 one-point and naming decisions; IP-1 schema/license/offline validator; IP-2 numeric representation and precision/error analysis; GPX +180 boundary; IP-5/IP-7 file-reference and writer behavior; IP-6 Windy acceptance. No unresolved decision is claimed as approved or tested.
- No application code, tests, fixtures, schemas, dependencies, GPX, CLI, Shortcuts or generated artifacts created; no tests run.
- Next: Gate 3 cross-check after the complete detailed-plan set is available; IP-4 execution and IP-5 planning are not authorized.
- R1 correction commit and remote status are reported in the final task handoff.

**IP-3 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK**

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-2 execution **NOT AUTHORIZED**.
- IP-3 execution: **NOT AUTHORIZED**; overall implementation: **NOT AUTHORIZED**.
- Branch: `docs/ip-3-route-modes-geometry`, based on corrected IP-2 baseline `8011d3f0c4baf62cb15194ab9308f4e312269615`.
- IP-3 R1 conditions closed: one-point neutral transforms are valid with an advisory; GPX exportability remains with IP-4 and Windy consumer acceptance with IP-6. Endpoint coincidence reuses the source point reference only under provisional tolerance; distinct source identities and synthetic current-position provenance are never merged. The Loxodrome closest-point metric is unresolved; candidate metric approval must precede any minimizer qualification, with global root completeness still required. Confirmation responsibilities are divided between IP-3 domain, IP-5 transport, and IP-7 UI.
- Open dependencies: IP-1 schema/geometry qualification and independent distance oracles; IP-2 execution/model evidence and identifier semantics; join-endpoint tolerance and great-circle degeneracy qualification; approved Loxodrome metric and global-minimum evidence; split-leg metadata semantics; IP-4/IP-5/IP-7 interfaces; IP-4/IP-6 one-point GPX policy/acceptance. No upstream execution PASS is assumed.
- No application code, tests, fixtures, probes, schemas, dependencies, CLI, GPX or Shortcuts created; no tests run.
- Next: Gate 3 cross-check after the complete detailed-plan set is available. IP-3 execution and overall implementation remain unauthorized.
- IP-3 plan commit `9a5db3525b986a3e13e3239274dcc6ae6957d6e5` was pushed without force; R1 corrections are the current documentation update. The final R1 commit and remote-head verification are reported in the task handoff.

### Historical IP-2 plan status and evidence snapshot

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution **NOT AUTHORIZED**.
- IP-2 execution: **NOT AUTHORIZED**; no execution PASS is claimed.
- Overall implementation: **NOT AUTHORIZED**.
- IP-2 plan uses approved IP-1 planning commit `6ed649d3995f70fa2421e08cb027c07d19b4cad4` as baseline.
- Resource limits/API behavior are proposals pending authorized evidence and architectural review. Schema qualification, legal offline validator strategy and fixture catalog remain upstream dependencies.
- FileReference path/content remain untrusted until securely opened and validated. Alias/security-scoped URL/permission/identity policy requires joint IP-2A/IP-5/IP-7 closure. Unknown geometry is uninterpreted only. RTZ digests are opt-in after approval; none by default.
- No tests run. No code, model, parser, fixture, probe, schema, dependency, CLI, Shortcut or package created.
- IP-2 branch/commit: `docs/ip-2-safe-input-model-parser` at `8011d3f0c4baf62cb15194ab9308f4e312269615`; remote branch was its approved baseline for IP-3 planning.

## Stage ledger

| Stage | State | Evidence / exit condition | Commit |
|---|---|---|---|
| 0. Discovery and master plan | PASS | Gate 1 approved; conditions closed. | `d57d093` |
| 1. Standards, fixtures, integration/packaging discovery (IP-1) | IP-1A R4 outreach pending; IP-1A remains PARTIAL; IP-1B PASS; IP-1C PARTIAL; IP-1D PARTIAL; IP-1E PASS (documentation only); IP-1F PASS (protocol design only); IP-1G PASS / ARCHITECT ACCEPTED | B01 external provenance confirmation pending; B02 rights not cleared; B03/B04 remain open. Overall IP-1 remains PARTIAL / NOT PASS. IP-2B–IP-7 execution NOT AUTHORIZED. | IP-1A R4 outreach commit series |
| 2. Safe input model and parser (IP-2) | PLAN APPROVED; IP-2A R8/R10/R11 substages PASS / ARCHITECT ACCEPTED; R13 worker resource feasibility PARTIAL; R14 isolated worker candidate requires qualification; IP-2A overall PARTIAL / INCOMPLETE; B03 PARTIAL / NARROWED / OPEN; B04 minimum policy PASS, overall PARTIAL / OPEN | B01 external response pending; B02 rights not cleared; B03 general RSS containment, parser/schema behavior, supported-OS and production cancellation evidence remain open. Sequoia 15 is a provisional engineering target under IP-1E R2; product OS FLOOR NOT QUALIFIED. B04 downstream transport/provider/continuity evidence incomplete. IP-2B–IP-2E NOT AUTHORIZED. | R8 closeout; R9 recovery plan; R10 security classification; R11 reference policy; R12 containment decision; R13 signed-child feasibility; R14 architecture review; IP-1E OS-floor R1/R2 |
| 3. Route modes and geometry (IP-3) | PLAN APPROVED | Historical remote Gate 3 PASS declaration (superseded for current authorization); stage execution NOT AUTHORIZED. | R1 commit in task handoff |
| 4. GPX serialization and loss report (IP-4) | PLAN APPROVED | Historical remote Gate 3 PASS declaration (superseded for current authorization); stage execution NOT AUTHORIZED. | R1 correction commit in task handoff |
| 5. Stable local CLI and self-contained runtime (IP-5) | PLAN APPROVED | Historical remote Gate 3 PASS declaration (superseded for current authorization); stage execution NOT AUTHORIZED. | R1 commit in task handoff |
| 6. Windy Route Planner acceptance (IP-6) | PLAN APPROVED | Historical remote Gate 3 PASS declaration (superseded for current authorization); consumer acceptance NOT TESTED; IP-6E report not started; stage execution NOT AUTHORIZED. | R1 task handoff |
| 7. V1 Shortcuts release (IP-7) | PLAN APPROVED | Historical remote Gate 3 PASS declaration (superseded for current authorization); IP-7 execution NOT AUTHORIZED. | R1 commit in task handoff |

Plan review is not execution PASS. RTZP remains OUT OF SCOPE for V1.
