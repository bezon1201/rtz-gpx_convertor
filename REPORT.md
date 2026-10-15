# Architect review handoff

## Current handoff — Prototype R6.1 GPX longitude boundary

**Authorization:** narrow prototype R6/R6.1, based on `bf19c524697120aec345dccfbb811bf14bbf119f`. Current Position Direct mode uses explicit `--current-position LAT LON --next-waypoint-id ID --connector rhumb|great-circle`. R6.1 applies GPX’s max-exclusive `+180` longitude boundary to every output route point regardless of RTZ version; it does not wrap `+180`, and preserves `-180`. This also closes the RTZ 1.0 source-waypoint case. The mode prepends the validated, unnamed current-position vertex and then includes the selected source waypoint and remaining suffix. It cannot combine with `--from-waypoint-id`; no connector defaults or waypoint inference exist. Connector is reported as transformation information only; GPX carries route vertices and no leg geometry semantics or interpolated points. Full Route and From Waypoint remain available. Last-source-WP selection in this mode yields two points. No advisory distance, Join Selected Route Leg, GUI, Shortcut, XSD, worker/IPC or packaging was added.

**Verification:** `make test` and `git diff --check` passed. R6.1 regressions confirm Current Position `+180` fails without output for RTZ 1.0 and 1.2, Current Position `-180` succeeds, and an RTZ 1.0 source waypoint at `+180` fails without output. Existing R6 synthetic tests cover middle/final next waypoint, coordinate validation, unknown ID, required connector, partial arguments, conflicting modes, coincident position/source waypoint retention, and Full Route/From Waypoint behavior. A local smoke test used an authorized private RTZ 1.0 route with non-operational synthetic position `(0, 0)`, next waypoint ID `26`, and `rhumb`: original 50 points; GPX 26 points; suffix order verified. Real source identifiers and coordinates are excluded from Git; both real RTZ and derived GPX remain local. No Windy import was run. No schema conformance/product support claim is made. Product OS floor remains NOT QUALIFIED; B01/B02 pending; B03 OPEN / PARTIAL; B04 minimum policy accepted, overall OPEN / PARTIAL; IP-2A PARTIAL / INCOMPLETE; IP-2B–IP-2E remain NOT AUTHORIZED; overall IP-1 PARTIAL / NOT PASS. The unrelated `AGENTS.md` edit is preserved and excluded. Stop for Architect review.
### Historical handoff — Prototype R5 From Waypoint mode

Added explicit `--from-waypoint-id ID` suffix conversion. Synthetic checks covered first/middle/last IDs, unknown IDs, duplicate-ID rejection, and unchanged Full Route output. A private Athens RTZ smoke test verified an ordered 25-point suffix from a 50-point route; source and derived route data were kept outside Git.

### Historical handoff — IP-1E R2 provisional engineering OS baseline

IP-1E R2 accepted Sequoia 15 as a provisional engineering target only. Product OS floor remained NOT QUALIFIED. The prototype task does not alter those determinations.

### Historical handoff — IP-1E R1 minimum macOS support-floor decision

R1 concluded **OS FLOOR NOT QUALIFIED**, retaining Sequoia 15 as a qualification candidate. R2 accepts it solely as a provisional engineering baseline; product compatibility remains unqualified. See [`docs/research/IP-1/IP-1E-OS-SUPPORT-FLOOR-DECISION.md`](docs/research/IP-1/IP-1E-OS-SUPPORT-FLOOR-DECISION.md). Stop for independent Architect review.

### Historical handoff — IP-2A R14 resource-containment architecture review

**Authorization:** documentation-only review. R13 research execution is **PASS / ARCHITECT ACCEPTED**; its technical conclusion remains partial. R14 decision: **ISOLATED WORKER CANDIDATE — REQUIRES QUALIFICATION**; no production architecture selected. R13 materially supports CPU-time enforcement (`RLIMIT_CPU` → `SIGXCPU`), parent-supervised watchdog termination/reap, and limiting new mappings with `RLIMIT_AS` on one host. However, each child began with about 445.7 GB (~415 GiB) virtual address space; the experimental ceiling was baseline plus 128 MiB, so this is not an absolute process or RSS limit. `RLIMIT_DATA` returned `EINVAL`; observed ~125 MiB resident usage was measurement only. R13 was two repetitions on macOS 26.6.2 arm64 using an ad-hoc-signed, unsandboxed research harness, without parser/schema workload or supported-OS-floor qualification. R14 distinguishes approved guarantees from proposed numeric targets and recommends one integrated parser/schema workload qualification only after the OS floor and lawful schema/runtime are established. Full decision: [`docs/research/IP-2/IP-2A-R14-CONTAINMENT-ARCHITECTURE-REVIEW.md`](docs/research/IP-2/IP-2A-R14-CONTAINMENT-ARCHITECTURE-REVIEW.md).

Preserved: B01/B02 pending; B03 **OPEN / PARTIAL**; B04 minimum policy **PASS / ARCHITECT ACCEPTED**, overall **OPEN / PARTIAL**; IP-2A **PARTIAL / INCOMPLETE**; IP-2B–IP-2E **NOT AUTHORIZED**; overall IP-1 **PARTIAL / NOT PASS**. No new probes, tests, parser, worker, IPC, schemas, dependencies, or runtime artifacts were created. The unrelated `AGENTS.md` modification is preserved and excluded. Branch: `implementation/ip-2a-r14-containment-review`, based on `40a40ee26296dc720eaa13318c971fee912e384e`. Stop for independent Architect review.

### Historical handoff — IP-2A R13 signed-child resource-control feasibility

**Authorization:** IP-2A R13's narrow research-only feasibility probe. Result: **WORKER RESOURCE CONTAINMENT PARTIAL**; no production architecture selected. On macOS 26.6.2 (25G83), arm64, Apple clang 21.0.0, an ad-hoc signed child with no entitlements received `SIGXCPU` under accepted `RLIMIT_CPU` (1s soft/2s hard). A second CPU-loop child ignored `SIGTERM`; the 2s parent watchdog escalated to `SIGKILL` and reaped it 254–255ms after termination request. `RLIMIT_AS` was accepted and prevented new anonymous mappings near the configured virtual-address cap, but this does not establish a general RSS/physical-memory cap. `RLIMIT_DATA` returned `EINVAL` and was not enforced. Two runs matched on stable outcomes. Full methods/results: [`docs/research/IP-2/IP-2A-R13-WORKER-RESOURCE-FEASIBILITY.md`](docs/research/IP-2/IP-2A-R13-WORKER-RESOURCE-FEASIBILITY.md) and sanitized [`tests/research/ip2a/r13/results.json`](tests/research/ip2a/r13/results.json).

Preserved: B01 **PENDING EXTERNAL CONFIRMATION**; B02 **PENDING / NOT CLEARED**; B03 **PARTIAL / NARROWED / OPEN**; B04 minimum policy **PASS / ARCHITECT ACCEPTED**, B04 overall **PARTIAL / OPEN**; IP-2A **PARTIAL / INCOMPLETE**; IP-2B **BLOCKED / NOT AUTHORIZED**; overall IP-1 **PARTIAL / NOT PASS**. The minimum supported macOS version is not frozen; evidence is host-specific and does not qualify parser/schema behavior, production cancellation, or a worker architecture. No product code or IPC was created. Research code/artifacts are limited to the R13 exception under `tests/research/ip2a/r13/`; binaries were temporary and removed. The unrelated `AGENTS.md` modification is preserved and excluded. Branch: `implementation/ip-2a-r13-worker-resource-feasibility`, based on `28ed59ce0fee7e7c0555beaa5de2fa188fb5f6bf`. Stop for independent Architect review.

### Historical handoff — IP-2A R12 parser resource-containment decision

**Authorization:** R12 documentation/architecture decision only, using existing R2/R3/R10 evidence. Decision: **INSUFFICIENT EVIDENCE — FURTHER QUALIFICATION REQUIRED**; no parser architecture selected. B03 remains **PARTIAL / NARROWED / OPEN**. The byte cap is limited to the tested read boundary; callback counters are not hard parser-allocation caps; RSS/timing are observational; cancellation is cooperative; R3 child termination/reap is one research-only observation, not a production guarantee or memory cap. Neither in-process residual risk nor a worker architecture has been accepted. The decision and a single unexecuted future resource-control feasibility probe are in [`docs/research/IP-2/IP-2A-R12-RESOURCE-CONTAINMENT-DECISION.md`](docs/research/IP-2/IP-2A-R12-RESOURCE-CONTAINMENT-DECISION.md).

Preserved: B01 **PENDING EXTERNAL CONFIRMATION**; B02 **PENDING / NOT CLEARED**; B04 minimum policy **PASS / ARCHITECT ACCEPTED**, B04 overall **PARTIAL / OPEN**; IP-2A **PARTIAL / INCOMPLETE**; IP-2B **BLOCKED / NOT AUTHORIZED**; overall IP-1 **PARTIAL / NOT PASS**. No probe, test, implementation, schema, dependency, or runtime work occurred. The unrelated `AGENTS.md` modification is preserved and excluded. Branch: `implementation/ip-2a-r12-resource-containment-decision`, from `a3492a6239098da7437295242ab673eee962beb6`. Stop for independent Architect review.

### Historical handoff — IP-2A R11 B04 file-reference policy

**Authorization:** IP-2A R11 documentation and joint policy work only, using existing R4–R8 evidence. **B04 = READY FOR FINAL POLICY REVIEW; blocker remains PARTIAL / OPEN.** R11 freezes the minimum conceptual contract: a path is a locator, not authority; successful unsandboxed open is ordinary permission, not a system capability; authority, object identity and content continuity are distinct; acquire/reacquire qualified authority; open once, check the descriptor, bounded-read that descriptor, avoid unsafe reopen, balance any security scope, and fail closed. Aliases/symlinks are not categorically rejected, but only explicit bounded resolution under qualified authority followed by secure target open is conditionally permitted.

Before export, reacquire, securely reread and revalidate, then compare a deterministic output-affecting semantic projection. Missing authority, changed semantics or inconclusive comparison invalidates route confirmation and dependent publication consent and requires refreshed preview/affirmative confirmation. No full source digest by default. Actual Finder/Shortcuts/helper transport, alias/provider UX, supported OS/provider coverage, replacement lifecycle and semantic continuity remain unqualified downstream work. No probes or implementation occurred.

Preserved: R10 **PASS / ARCHITECT ACCEPTED** as a documentation/evidence-classification substage; B01 **PENDING EXTERNAL CONFIRMATION**; B02 **PENDING / NOT CLEARED**; B03 **PARTIAL / NARROWED / OPEN**; B04 **PARTIAL / OPEN**; IP-2A **PARTIAL / INCOMPLETE**; IP-2B **BLOCKED / NOT AUTHORIZED**; overall IP-1 **PARTIAL / NOT PASS**. The full policy and B04 matrix are in [`docs/research/IP-2/IP-2A-R11-FILE-REFERENCE-POLICY.md`](docs/research/IP-2/IP-2A-R11-FILE-REFERENCE-POLICY.md). Branch: `implementation/ip-2a-r11-file-reference-policy`, based on `7109738caf0bad2e8dfed86f4787a4abd090c1ca`. Stop for independent Architect review.

### Historical handoff — IP-2A R10 B03 security-control review

**Authorization:** IP-2A R10 documentation and review of existing R2/R3 evidence only. **B03 = PARTIAL / NARROWED; OPEN / NOT QUALIFIED.** The descriptor byte cap is a hard bound only at the read boundary; XML event counters are callback/application limits; harness RSS and timings are observational; parser cancellation is cooperative; and worker termination is a research-only experiment. No hard parser/process memory or CPU bound, fixed cancellation deadline, schema-validation workload, supported macOS matrix or production integration is qualified. No parser or process-isolation architecture is selected.

Preserved status: IP-1A R4 outreach **PASS / ARCHITECT ACCEPTED** (IP-1A overall remains PARTIAL); B01 **PENDING EXTERNAL CONFIRMATION**; B02 **PENDING / NOT CLEARED**; B04 **PARTIAL / OPEN**; IP-2A **PARTIAL / INCOMPLETE**; IP-2B **BLOCKED / NOT AUTHORIZED**; overall IP-1 **PARTIAL / NOT PASS**. No new probe, test, build, schema, fixture, dependency or implementation was created or run. The matrix and future closure evidence are in [`docs/research/IP-2/IP-2A-R10-B03-SECURITY-QUALIFICATION.md`](docs/research/IP-2/IP-2A-R10-B03-SECURITY-QUALIFICATION.md). Branch: `implementation/ip-2a-r10-b03-qualification-plan`, based on `2561888f717b1ae8fdfd2611495d21111c987d8c`. Independent Architect review is next.

### Historical handoff — IP-1A R4 external confirmation

**Authorization: IP-1A R4 external-confirmation preparation and outreach for B01/B02 only.** The CIRM inquiry was sent 2026-10-14 09:59:43 UTC and the Topografix publisher-linked inquiry at 09:59:58 UTC. Gmail shows both as sent; no replies or bounces were found at the status check, and receipt is not confirmed. B01 remains PENDING EXTERNAL CONFIRMATION; B02 remains PENDING / NOT CLEARED; IP-1A remains PARTIAL. IP-2A R9 was accepted PASS / ARCHITECT ACCEPTED as a documentation/critical-path stage, while IP-2A overall remains PARTIAL / INCOMPLETE. IP-2B remains BLOCKED / NOT AUTHORIZED; overall IP-1 remains PARTIAL / NOT PASS. No schemas were downloaded or attached, and no implementation/runtime work occurred. The unrelated local `AGENTS.md` modification remains untouched and excluded.

R4 exact text, artifact identities/hashes, timestamps and mail message IDs are recorded in [`docs/research/IP-1/IP-1A-R4-EXTERNAL-CONFIRMATION.md`](docs/research/IP-1/IP-1A-R4-EXTERNAL-CONFIRMATION.md). The branch is `implementation/ip-1a-r4-external-confirmation`, based on reviewed commit `2630843a60f573856183fbc92a0fcccdaf45b3e7`. IEC remains a conditional follow-up if CIRM cannot establish provenance or rights authority.

### Historical handoff — IP-2A R9 acceptance recovery

**Authorization: IP-2A R9 documentation and planning only. IP-2A R8 documentation closeout: PASS / ARCHITECT ACCEPTED; IP-2A overall remains PARTIAL / INCOMPLETE.** `IP1-B03` and `IP1-B04` remain OPEN / PARTIAL; `IP1-B01/B02` remain unresolved; **IP-2B = BLOCKED / NOT AUTHORIZED**; overall IP-1 remains **PARTIAL / NOT PASS**. R9 authorized/performed no implementation, probe, schema acquisition, fixture, dependency, test, or platform work. The proposed next action had not yet been executed at the R9 handoff. The unrelated modified `AGENTS.md` remains untouched and excluded.

R9 adds [`docs/research/IP-2/IP-2A-ACCEPTANCE-RECOVERY-PLAN.md`](docs/research/IP-2/IP-2A-ACCEPTANCE-RECOVERY-PLAN.md), mapping IP-2 plan §11 acceptance criteria to existing evidence and gaps, distinguishing IP-2A requirements from IP-5/IP-7 integration ownership, and setting a bounded critical path. At the R9 handoff its recommended IP-1A external-confirmation action had not yet been authorized or sent; R4 later authorized and performed the outreach recorded above. See the recovery matrix and explicit stop criteria before authorizing any follow-up.

The R8 closeout below is retained as a historical snapshot; R9 changes no approved plan or R1–R8 evidence.

### Historical handoff — IP-2A R8 closeout

**Authorization: IP-2A R8 documentation and closeout only. IP-2A status: PARTIAL / INCOMPLETE; no PASS is claimed.** R8 consolidates R1–R7 findings, records the candidate input/authority boundary, retains IP1-B03 and IP1-B04 as open, and assigns remaining work to IP-2, IP-5, IP-7 and their joint qualification. **IP-2B = BLOCKED.** Overall IP-1 remains **PARTIAL / NOT PASS**. No implementation, runtime probe or later stage is authorized. The R8 closeout document itself is prepared for Architect review.

The complete status matrix, residual sub-blockers, B03 evidence and qualification gaps, and current authority recommendation are in [`docs/research/IP-2/IP-2A-CLOSEOUT-AND-HANDOFF.md`](docs/research/IP-2/IP-2A-CLOSEOUT-AND-HANDOFF.md). The R8 work is documentation-only; R1–R7 evidence remains host/configuration-specific and no partial evidence is upgraded to PASS.

**Git baseline:** branch `implementation/ip-2a-r8-closeout-handoff`, parent `e91cec69fdffc5d4484289207db8c740efa310b9`. Unrelated modified `AGENTS.md` remains untouched and excluded.

### Historical handoff — IP-2A R7 independent receiver authority

**Authorization: IP-2A R7 research and decision work only. Verdict: PARTIAL.** On macOS 26.6.2 (25G83), arm64, a separately launched app-sandbox receiver with no selected-file or inherit entitlement was denied two readable synthetic path arguments with `EPERM`. An unsandboxed comparison receiver read two synthetic files under ordinary filesystem permissions and received `EACCES` for a mode-000 file; this is not a system-granted authority result. Deterministic replacement at the same pathname changed the device/inode identity, and the descriptor no longer matched the original object.

The Shortcuts shell process was observed only in a no-input run; file-argument delivery and authority remain inconclusive. `launchctl procinfo` was unavailable or denied to the non-root probe. Accepted R5 picker/inherited-helper observations remain configuration-specific and historical. Full method and limits: [`docs/research/IP-2/INDEPENDENT-RECEIVER-AUTHORITY-R7.md`](docs/research/IP-2/INDEPENDENT-RECEIVER-AUTHORITY-R7.md); sanitized results: [`tests/research/ip2a/r7/results.json`](tests/research/ip2a/r7/results.json).

**Disposition:** Finder/Shortcuts carrier **PARTIAL / NOT QUALIFIED**; independent sandboxed path authority **BLOCKED**; ordinary path reads **ORDINARY PERMISSIONS ONLY**; `IP1-B04` **PARTIAL / OPEN**; `IP1-B03` **OPEN / PARTIAL / NOT QUALIFIED, unchanged**; IP-1 overall **PARTIAL / NOT PASS**. IP-2B–IP-2E, production parser/CLI/app/Shortcut and release remain **NOT AUTHORIZED**. No Gate 3 decision or approved architecture changed.

**Git baseline:** branch `implementation/ip-2a-r7-receiver-authority`, reviewed baseline and parent `ef4da7cf51818e079a9eb17c7b2c387d07d163e1`. The unrelated modified `AGENTS.md` remains excluded.

### Historical handoff — IP-2A R6 Finder / Shortcuts transport

**Authorization: IP-2A R6 only. Verdict: PARTIAL.** The Shortcuts action catalog became populated after an existing action-bearing Shortcut was opened, but the internal cause of the initial empty pane is not established. A local R6 research Shortcut was exposed in Finder Quick Actions. With its shell action explicitly bound to Shortcut Input and configured to pass input as arguments, Finder delivered one or two POSIX path strings; the receiver opened the synthetic regular files and matched their unique contents. A generic `Input` binding first produced zero arguments. Finder therefore supplies a **PATH LOCATOR ONLY** in this tested setup. No independent security-scoped authority, sandbox grant, identity continuity, cancellation/permission behavior, or product transport was qualified.

The complete method, observations and limits are in [`docs/research/IP-2/SHORTCUTS-TRANSPORT-R6.md`](docs/research/IP-2/SHORTCUTS-TRANSPORT-R6.md). The retained research Shortcut's receiver was reduced after testing so it no longer reads files or writes logs. No research source-code file or scope-exception record, real route, fixture, executable, schema, dependency, product Shortcut, or runtime artifact was committed. The existing IP-1D Shortcut and empty R5 draft were preserved.

**Disposition:** action-library root cause **UNRESOLVED**; Shortcuts carrier **PARTIAL**; Finder Quick Action carrier **PARTIAL**; standalone receiver authority **BLOCKED**; `IP1-B04` **PARTIAL / OPEN**; `IP1-B03` **OPEN / PARTIAL / NOT QUALIFIED, unchanged**; IP-1 overall **PARTIAL / NOT PASS**. Gate 3 remains **PASS / ARCHITECT ACCEPTED**; Gate 4 remains stage-specific. IP-2B–IP-2E, production work and release remain **NOT AUTHORIZED**.

**Git baseline:** branch `implementation/ip-2a-r6-shortcuts-transport`, reviewed baseline and parent `d7ca083a4069641599d281d23ebcfc66155ab395`.

### Historical handoff — IP-2A R5 Finder / Shortcuts file-authority transport

- **Authorization:** IP-2A R5 only, including the expiring research-only sender/receiver exception. Gate 3 remains **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; Gate 4 is stage-specific, never blanket authorization. IP-2B–IP-2E, production CLI/app/Shortcut, later stages and release remain **NOT AUTHORIZED**. Overall IP-1 remains **PARTIAL / NOT PASS**.
- **Verdict: IP-2A R5 PARTIAL.** A temporary ad-hoc-signed sandboxed Swift app used a real `NSOpenPanel`; two synthetic filenames with spaces and composed/decomposed Unicode were selected and read through bounded `O_NOFOLLOW` descriptors. A mode-000 selected file returned a URL and `startAccessingSecurityScopedResource() == true`, but descriptor open failed with `EACCES`. A sandboxed inherited helper read the same selected object and expected bytes through both a path locator and Foundation bookmark data created with default options. A same-process delayed reopen after balanced scope stop also succeeded on the local synthetic files. Full evidence/limits: `docs/research/IP-2/FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md` and sanitized `tests/research/ip2a/r5/results.json`.
- **Carrier status:** Finder Quick Action **BLOCKED** (not invoked in R5; prior IP-1D input remained unobservable). Shortcuts **BLOCKED** because the Shortcuts action library showed no actions for searches including Run Shell Script, shell and Text. A uniquely named empty R5 Shortcut draft exists but was not run/configured as Quick Action. Existing IP-1D iCloud Shortcut was not modified or invoked. Native picker **PARTIAL**; cross-process transfer **PARTIAL** only for this inherited sandbox child setup; export-time reacquisition **PARTIAL**, with no preview/export semantic test.
- **Disposition:** IP1-B04 remains **PARTIAL / OPEN**; the one-host picker/helper evidence does not qualify actual Finder/Shortcuts transport, standalone CLI authority, alias/symlink or provider behavior, replacement/deletion races, or semantic preview/export continuity. IP1-B03 remains **OPEN / PARTIAL / NOT QUALIFIED**, unchanged; IP1-B01/B02 remain unresolved. IP-2B remains **BLOCKED**. No G3 decision or approved architecture changed.
- **Research files:** `docs/research/IP-2/IP-2A-R5-SCOPE-EXCEPTION.md`, `docs/research/IP-2/FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md`, `tests/research/ip2a/r5/` (Swift probe, entitlements, temporary runner, README and sanitized result manifest), updates to `docs/research/IP-2/FILE-REFERENCE-AND-CONTINUITY.md`, `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md`, this report and `PROGRESS.md`. Existing unrelated `AGENTS.md` modification remains untouched and excluded. No production code, private input, schema, dependency, committed binary or product Shortcut was created.
- **Git:** branch `implementation/ip-2a-r5-finder-shortcuts-transport`; R5 research commit `b0f066af96534f2834d024c0586b6959bf3f8058`, parent `7314b123723f6253544917b324529cfe767cd580`. The branch was pushed normally; the reporting follow-up commit and final remote-head verification are recorded in the task handoff.
- **Shortcuts safety:** the R5 empty Shortcut draft is retained; no deletion was attempted. The existing IP-1D iCloud Shortcut remains untouched. No bookmark bytes, temporary paths or actual descriptor identity values were persisted.
- **Next:** independent Architect review of IP-2A R5 PARTIAL. Stop before IP-2B or any later stage.

### Historical handoff — IP-2A R4 FileReference / source continuity

- **Authorization:** IP-2A R4 only. Gate 3 is **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; Gate 4 is stage-specific, never blanket authorization. IP-2B–IP-2E, IP-3–IP-7 execution, production implementation and release remain **NOT AUTHORIZED**. Overall IP-1 remains **PARTIAL / NOT PASS**.
- **Verdict: IP-2A R4 PARTIAL.** Added the requested file-reference research record, updated security decision/dependency/report/progress records, and performed a reproducible probe using synthetic temporary files only. Full contract, evidence qualifications, mechanisms and unresolved work are in `docs/research/IP-2/FILE-REFERENCE-AND-CONTINUITY.md`.
- **Observed host/evidence:** macOS 26.6.2 (25G83), Darwin arm64; Apple Swift 6.3.3, Apple clang 21.0.0, SDK 26.5. Descriptor-backed reads stayed attached to the opened object across rename/move, path replacement, symlink retargeting and source deletion. A same-inode write changed bytes visible through the descriptor. A plain bookmark tracked a rename while reporting stale, and resolving after deletion failed. Permission and nonregular-file checks behaved as expected. Results are limited to this unsandboxed host and local temporary filesystem.
- **Not established:** actual Finder/Shortcuts input/capability transport; sandboxed security-scope behavior; Finder aliases; File Provider; OS/filesystem matrix; and production preview/export semantic comparison. The API calls returning `true` in this unsandboxed probe do not prove sandbox authority or handoff. `--input-path` is a locator, not a capability.
- **Disposition:** IP1-B04 remains **PARTIAL / OPEN**, materially narrowed but not closed. IP1-B03 remains **OPEN / PARTIAL / NOT QUALIFIED**; IP1-B01/B02 remain unresolved. No full source digest was used. G3 decisions unchanged.
- **Files:** added `docs/research/IP-2/FILE-REFERENCE-AND-CONTINUITY.md`, `docs/research/IP-2/IP-2A-R4-SCOPE-EXCEPTION.md`, and research-only `tests/research/ip2a/r4/` source/runner/README/result manifest; updated `docs/research/IP-2/INPUT-AND-SECURITY-DECISIONS.md`, `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md`, this report and `PROGRESS.md`. No product parser/model/CLI/app/Shortcut, schema, dependency, route, or binary was created. Existing `AGENTS.md` modification remains untouched and uncommitted.
- **Git:** branch `implementation/ip-2a-r4-file-reference-continuity`; R4 evidence commit `8315e677edbb5781f96aa838b8097e9928b11bea`, parent `8b73f44fe82f3b47187c5ba49ad5ee315f4ea433`. A follow-up handoff-record commit captures this SHA; final remote HEAD is reported after push verification.
- **Next:** independent Architect review of IP-2A R4 PARTIAL. Stop before IP-2B or any later stage.

### Historical handoff — IP-2A R3 runtime safety

- **Authorization:** IP-2A R3 only, including the narrowly documented, expiring research-harness exception. Gate 3 is **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; Gate 4 is stage-specific, never blanket authorization. IP-2B–IP-2E, IP-3–IP-7 execution, production implementation and release remain **NOT AUTHORIZED**. Overall IP-1 remains **PARTIAL / NOT PASS**.
- **Verdict: IP-2A R3 PARTIAL.** Built and exercised a research-only harness against official libxml2 2.15.4 source archive (SHA-256 `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`), runtime version guard `21504`, static candidate link, and no dynamic libxml2 dependency. Host: macOS 26.6.2 (25G83), arm64, Apple clang 21.0.0. The run recorded `SUMMARY failures=0`; exact generated-input identities and outcomes are in `tests/research/ip2a/results.jsonl`.
- **Findings:** synthetic DTD/entity/resource-denial and R2 boundary cases reproduced. Separate-thread atomic cancellation was observed by parser-thread read/cleanup callbacks; no parser context was operated on from the cancelling thread, no partial success was returned, and close ran once. A disposable CPU-bound worker was terminated and reaped. Twenty-iteration synthetic measurements and peak RSS include generated input and the whole harness process; they do not prove parser memory ceilings or performance guarantees. Callback limits are not internal allocation limits.
- **Disposition:** IP1-B03 remains **OPEN / PARTIAL / NOT QUALIFIED** pending hard-bound evidence, supported-macOS matrix, production integration and independent review. IP1-B04 remains **OPEN / PARTIAL**; Finder/Shortcuts file references, aliases, security scope, permissions, identity and continuity were not tested. IP1-B01/B02 remain unresolved. No schema was used or bundled. Overall IP-1 stays **PARTIAL / NOT PASS**.
- **Files:** recorded the scope exception, research harness, deterministic synthetic cases/generators, local build/run instructions, result manifest/log, and updates to the security decision, resource-limit, dependency, report and progress records. No production source, product test target, third-party source, binary, schema or route was created or committed. Pre-existing `AGENTS.md` modification remains untouched and uncommitted.
- **Next:** independent Architect review of IP-2A R3. Stop before IP-2B or any later stage.

### Historical handoff — IP-2A R2 libxml2 security qualification

- **Authorization:** IP-2A R2 only at that handoff. Gate 3 is **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; Gate 4 is stage-specific, never blanket authorization. R3 later superseded this snapshot; R8 is the current handoff.
- **Verdict: IP-2A R2 PARTIAL.** The temporary candidate was libxml2 2.15.4 (upstream archive SHA-256 `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`), built static for this host. Candidate flags were `XML_PARSE_NONET | XML_PARSE_NO_XXE | XML_PARSE_NO_SYS_CATALOG | XML_PARSE_BIG_LINES`; per-context deny-all resource loader; SAX `internalSubset` calls `xmlStopParser`; descriptor-style `xmlCtxtReadIO` with 4 KiB reads and bounded byte/cancel callbacks. Forbidden expansion, DTD loading/defaulting/validation, recovery, huge mode, XInclude, decompression, catalogs and implicit/default loaders were disabled or absent. `NONET` was not treated as the security boundary.
- **Observed security results:** synthetic bare DOCTYPE, internal DTD declarations/entities, external file/HTTP entities and DTDs, parameter entities and nested expansion attempts all failed before element/text callbacks; loader calls were zero. Malformed tags, multiple roots, trailing data, invalid declared encoding and invalid UTF-8 failed closed. A tiny generic synthetic XSD include test confirmed the context schema loader rejected both local and HTTP include requests without fallback; no network client/request was used. No RTZ/GPX schema was used.
- **Streaming/cancellation:** descriptor callback accepted candidate 16 MiB−1 and 16 MiB, rejected 16 MiB+1 after limit+1 bytes, and closed exactly once. Synchronous cancellation at 64 KiB stopped parsing, returned no document and caused no later reads; ~50 μs on the tiny run is not a latency guarantee. Asynchronous/pathological cancellation is unqualified.
- **Resource limits:** app callbacks accepted depth 64, 250,000 elements, 4 KiB individual text/attribute and 8 MiB aggregate text at limits and rejected +1. Attribute text is already materialized before callback; these are not parser memory hard limits. Full harness RSS (~43.8 MiB, including generated input buffers) is not per-conversion memory evidence. Remaining candidate ceilings and exact observations are in `docs/research/IP-2/RESOURCE-LIMITS.md`.
- **Security review:** 2.15.4 is after the upstream fixes for CVE-2026-6732 (fixed before 2.15.3) and includes the 2026-86137–86144 fixes listed in its release notes. CVE-2026-74860 is Python-binding-specific; bindings were disabled. CVE-2026-11979 concerns the disabled `xmlcatalog --shell` and is disputed upstream. This is a point-in-time advisory review, not certification or product dependency selection.
- **Disposition:** IP1-B03 **PARTIAL / OPEN / NOT QUALIFIED** pending OS matrix, async/pathological cancellation and memory bound evidence, product integration and independent security review. IP1-B04 remains **PARTIAL / OPEN, unchanged**; aliases, security scope, file identity/continuity and Finder/Shortcuts transport were not tested. IP1-B01/B02 remain open. Readiness: IP-2A PARTIAL; IP-2B BLOCKED; IP-2C BLOCKED; IP-2D BLOCKED.
- **Files:** exactly the two IP-2 research records, IP-1 blocker/dependency register, this report and `PROGRESS.md`. Pre-existing unrelated `AGENTS.md` change is preserved and excluded. No source/route/schema/fixture/dependency or probe artifact was added to Git. Temporary probe/build files were disposable and are being removed.
- **Git:** branch `implementation/ip-2a-r2-libxml2-security-qualification`, based on `0625fc8980c0072a297a37fde6603538cf52cc06`. Commit and remote verification will be recorded in the final handoff.
- **Next:** independent Architect review of IP-2A R2 PARTIAL. Stop before IP-2B or any later stage.

### Historical handoff — IP-2A R1 security and runtime feasibility

- **Authorization:** IP-2A R1 only. IP-2B–IP-2E, IP-3–IP-7 execution, production implementation and release remain **NOT AUTHORIZED**. Gate 4 is stage-specific, never blanket authorization.
- **Governance:** Gate 3 is **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. **Overall IP-1 remains PARTIAL / NOT PASS.** IP-1A R3 remains PARTIAL; IP-1B PASS; IP-1C/IP-1D PARTIAL; IP-1E PASS (documentation-level); IP-1F PASS (protocol only); IP-1G and governance reconciliation PASS / ARCHITECT ACCEPTED.
- **IP-2A R1 verdict: PARTIAL.** Foundation XMLParser is unsuitable as the sole strict boundary based on the observed bare-DOCTYPE acceptance. Pinned libxml2 is a leading candidate only, not selected or qualified; Xerces-C++ is not recommended. No parser candidate closes IP1-B03.
- **Blockers:** IP1-B03 remains **PARTIAL / OPEN, NOT QUALIFIED**; IP1-B04 remains **PARTIAL / OPEN** because the cross-stage file-reference, alias/security-scope and preview/export continuity policy is not qualified. IP1-B01/B02 rights/provenance/runtime blockers remain open. No blocker is closed by R1.
- **Artifacts:** added `docs/research/IP-2/INPUT-AND-SECURITY-DECISIONS.md` and `docs/research/IP-2/RESOURCE-LIMITS.md`; updated `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md`, this report and `PROGRESS.md`. Resource ceilings are proposals only. No schemas, fixtures, dependencies, code, parser, CLI, Shortcut, app or runtime artifact was created.
- **Probe boundary:** one disposable, in-memory Foundation probe used synthetic XML strings on macOS 26.6.2 / arm64 with Swift 6.3.3. It was explicitly authorized by the task; no route, schema, network, or filesystem XML input was used. Its results are host-specific observations, not cross-version or production security evidence. No application tests were run.
- **Git:** branch `implementation/ip-2a-security-runtime-feasibility`, based on reviewed baseline `4329b04193652b7fe555180ecd51e238b1271d4d`. Pre-existing `AGENTS.md` modification is preserved and excluded.
- **Next:** independent Architect review of IP-2A R1. Do not begin IP-2B or any later stage without separate authorization.

### Historical handoff — IP-1A R3 rights, provenance and offline validation (superseded)

## IP-1A R3 handoff at that time

- **Authorization:** this task authorized IP-1A R3 only. IP-1B–IP-1G retain their already accepted verdicts; IP-2–IP-7 execution, production implementation, schema vendoring, Windy testing, packaging/signing and release are **NOT AUTHORIZED**. Gate 4 remains stage-specific, never blanket authorization.
- **Governance:** Gate 3 is **PASS / ARCHITECT ACCEPTED** at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. IP-1G and Governance Status Reconciliation are PASS / ARCHITECT ACCEPTED. **Overall IP-1 remains PARTIAL / NOT PASS.**
- **IP-1A R3 verdict: PARTIAL.** Exact RTZ 1.2 byte-level provenance still requires CIRM/IEC confirmation. RTZ 1.0/1.2 copying, bundling, local installation, offline runtime use and redistribution remain NOT CLEARED. GPX 1.1 raw-XSD rights remain CONDITIONAL / NOT CLEARED. No validator/runtime is approved; Candidate A (fixed, pinned static libxml2 plus permitted local schemas) is only the leading conditional technical direction and must address CVE-2026-6732, patch ownership, resolver restrictions, offline behavior and target-macOS verification.
- **Readiness only:** IP-2A is PARTIAL (a bounded documentary investigation could be separately authorized); IP-2B, IP-2C and IP-4 schema-backed acceptance are BLOCKED by unresolved security, provenance, rights and runtime qualifications. This report does not authorize those stages.
- **Blockers:** IP1-B01 REQUIRES EXTERNAL CONFIRMATION; IP1-B02 BLOCKED / NOT CLEARED; IP1-B03 OPEN / NOT QUALIFIED. No unrelated blocker is closed. Inquiry drafts are ready but **no email or external message was sent**.
- **Scope:** updated `docs/research/IP-1/RTZ-SCHEMA-QUALIFICATION.md`, `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md`, this report and `PROGRESS.md`. Prior hashes and empirical schema-validation observations were preserved; no tests or probes were repeated. No schema, fixture, dependency, implementation or runtime artifact was created. The pre-existing `AGENTS.md` modification remains untouched and uncommitted.
- **Baseline:** reviewed commit `ddd17bf1306e5140ffcd86e61e9a12a6e9008673`; branch `implementation/ip-1a-r3-rights-provenance-runtime`. Commit SHA, parent and remote HEAD will be provided in the final handoff.
- **Next:** independent Architect review of IP-1A R3. Stop before any IP-2–IP-7 or product implementation activity.

## Historical handoff — IP-1G integration and closeout before acceptance (superseded)

- **At that handoff, IP-1G status was REVIEW.** `docs/research/IP-1/DECISIONS-AND-DEPENDENCIES.md` integrated IP-1A–IP-1F evidence, traced Gate 3 and product requirements to owners/gates/status, classified blockers, checked cross-plan consistency, and assessed bounded IP-2 readiness. Independent acceptance was then pending.
- **Overall IP-1 recommendation: PARTIAL / NOT PASS.** IP-1A PARTIAL; IP-1B PASS (static synthetic corpus only); IP-1C PARTIAL; IP-1D PARTIAL; IP-1E PASS (documentation only); IP-1F PASS (protocol only); IP-1G REVIEW. No parser, geometry, serializer, CLI or consumer compatibility implementation is established.
- **Open blocker register: 15 items** across immediate security/provenance/governance, downstream technical acceptance and release qualification. Critical unresolved items include RTZ/GPX schema rights and lawful offline schema validation, source-file reference/continuity, and stale status statements in approved plans. G3-006 general rhumb minimization, Shortcuts/Finder transport, package verification and empirical Windy acceptance also remain open.
- **IP-2 readiness:** no parser implementation is ready. A narrowly bounded, documentation-only IP-2A investigation could be considered only under separate explicit authorization and would remain PARTIAL/BLOCKED. The recommended next gate is independent Architect review, then a focused IP-1A rights/provenance/runtime resolution. No IP-2 scope is authorized here.
- **At that handoff, material status inconsistencies** remained in approved plan headers and the IP-6 IP-7-planning statement. This reconciliation resolves IP1-B15; those statements are retained here only as a historical snapshot.
- **Authorization:** this task authorized IP-1G only. IP-2–IP-7 execution, implementation, schema redistribution, Windy uploads, packaging, signing and release remain **NOT AUTHORIZED**. No IP-1 PASS is claimed.
- **Git:** branch `implementation/ip-1g-integration-closeout`, from reviewed baseline `b964b51584c79fde7af06100809ccca1f54333df`. Pre-existing unrelated `AGENTS.md` modification remains untouched and excluded. Commit and remote verification are recorded after completion.
- **Next at that handoff:** independent Architect review of IP-1G; stop before IP-1A R3 or IP-2 absent separate authorization. The owner has since recorded IP-1G PASS; this historical handoff does not supersede the current governance status above.

## Historical handoff — IP-1F Windy acceptance protocol

- **IP-1F verdict: PASS (protocol design only).** Added `docs/research/IP-1/WINDY-ACCEPTANCE-PROTOCOL.md`, with separate ordinary Uploader and Route Planner procedures, ten synthetic acceptance profiles plus mandatory coverage across all four route modes and both explicit Current Position connector geometries, observation/verdict rules, a reusable record, and privacy/publication boundaries. No GPX was produced or uploaded; Windy compatibility remains NOT TESTED.
- The current exact Route Planner import entry point is **TO VERIFY DURING IP-6**. The current Windy editorial confirms general GPX import/display but does not establish a current Route Planner menu path or object inspection; the Staff post with paths is historical and must be rechecked manually.
- Mandatory future Route Planner cases cover a two-point baseline, multiple ordered points, names, source-name default, explicit override and omission, antimeridian, Unicode/XML escaping, and decimal precision, across all four route modes and both explicit Current Position connector geometries. One-point is a required separate informative observation, non-release-gating, and cannot overturn G3-004 `ALLOW_WITH_WARNING`. Uploader PASS cannot substitute for Route Planner PASS.
- **Historical authorization at IP-1F completion:** Gate 4 was authorized for IP-1F only by that task. At that handoff, IP-1G and IP-2–IP-7 execution, production conversion, Windy empirical testing, implementation and release were **NOT AUTHORIZED**. The current IP-1G authorization is recorded above. No Windy interaction, production GPX, code, fixtures, tests or runtime artifacts were created.
- **Git:** branch `implementation/ip-1f-windy-acceptance-protocol`, from reviewed baseline `debf177a979027323890bed31369303645d2bcbd`. The pre-existing unrelated `AGENTS.md` change remains untouched and excluded. Commit and remote verification are recorded after completion.
- **Next:** independent Architect review before IP-1G.

## Historical handoff — IP-1E packaging decision

- **IP-1E verdict: PASS (documentation-level only).** The approved signed/notarized arm64 `.app` + self-contained local CLI + stapled `.dmg` + exported `.shortcut` direction is retained. Recommended consumer install location is `~/Applications`; `/Applications` remains optional only where write permissions are preconfigured. Candidate OS floor is macOS Sequoia 15.8; Tahoe 26.7.1 and Golden Gate 27 (initial release) are matrix candidates, not declared supported.
- The clean-user procedure covers standard-user install, Gatekeeper/offline launch, importing/enabling the Shortcut and Finder Quick Action, Dock/keyboard launch, offline synthetic run, update/rollback, and removal while preserving source/output files. No app, DMG, shortcut package, signing, notarization, or installation was produced or run.
- Apple references and signing/cost prerequisites are documented in `docs/research/IP-1/PACKAGING-DECISION.md`. Developer ID membership/account access is unverified; Apple's current listed membership price and qualified fee-waiver path are recorded. No account or purchase was used.
- **Open blockers:** IP-1D Finder transport and CLI discovery; IP-2/IP-5/IP-7 file-reference/security-scope/source-continuity; cancellation/error mapping; all OS/package/Gatekeeper tests; legal clearance and offline schema validator from IP-1A; future IP-7 UI acceptance. The 15.8 floor is only a candidate. IP-1A remains PARTIAL; IP-1B PASS; IP-1C and IP-1D PARTIAL; no IP-1 PASS is implied.
- **Historical authorization at IP-1E completion:** Gate 4 was authorized for IP-1E only. At that handoff, IP-1F onward, IP-2–IP-7 execution, product implementation and release were **NOT AUTHORIZED**. The current IP-1F authorization is recorded above. The temporary IP-1D Shortcut remains in the Shortcuts library because deletion would propagate across iCloud devices; its status is recorded in the IP-1D report.
- **Git:** branch `implementation/ip-1e-packaging-decision`, from reviewed baseline/parent `767e1a1791202969122db8a98f7459a98201cab8`. The unrelated `AGENTS.md` change remains untouched and excluded. Commit and remote verification are recorded after completion.
- **Next:** independent Architect review of this documentation-level IP-1E PASS. Do not start IP-1F or implementation without a separate authorization.

## Historical handoff — IP-1D Shortcuts/Finder transport qualification

- **IP-1D verdict: PARTIAL.** On macOS 26.6.2 (25G83, arm64; Shortcuts 7.0 build 4711), an inert local helper observed exact UTF-8 stdin forwarding for a 51-byte Unicode/metacharacter payload and a 262,144-byte payload. Shortcuts displayed JSON stdout, surfaced a deliberate stderr marker on exit 7, and its Stop control interrupted a 60-second inert action.
- **Unqualified:** Shortcuts “as arguments” produced `argc=0` for the Text-action setup; Finder Quick Action launched but its actual input representation/result was not observable. Multiple files, malformed/oversized requests, output bounds, child-process cancellation guarantees, picker/save/Reveal/permissions, network-disabled operation, other macOS versions, and security-scoped access were not qualified. No minimum OS or final transport is selected.
- **Recommendation:** retain JSON stdin as a candidate only; do not settle the stable IP-5 protocol or Finder file-reference contract from this one-machine probe. IP-5 owns protocol/error mapping; IP-2/IP-5/IP-7 jointly own secure file acquisition and continuity; IP-7 owns end-to-end UI qualification. IP-1D remains PARTIAL pending matrix completion.
- **Files:** `docs/research/IP-1/SHORTCUTS-FEASIBILITY.md`, `REPORT.md`, `PROGRESS.md`. The inert arm64 probe and synthetic temporary files were removed after testing. The temporary Shortcut remains in the Shortcuts library because its Delete confirmation stated removal would propagate to all iCloud devices; no such deletion was confirmed. It is not a product Shortcut or repository artifact. No real route or coordinates were used.
- **Git:** branch `implementation/ip-1d-shortcuts-transport`, baseline/parent `85956a226980691eb74cbf9ac56c1258aa90c2c1`; commit and remote verification are recorded in this handoff after completion. The pre-existing `AGENTS.md` user change remains untouched and excluded.
- **Historical authorization at IP-1D completion:** Gate 4 was authorized for IP-1D only. At that handoff, IP-1E onward, IP-2–IP-7 execution, production parser/converter/CLI, product Shortcut, app, packaging and release were **NOT AUTHORIZED**. The present IP-1E authorization is recorded above. IP-1A remains PARTIAL; IP-1B PASS; IP-1C PARTIAL. No IP-1 PASS is implied.
- **Next:** independent Architect review of this PARTIAL IP-1D evidence. Do not begin IP-1E or later work without separate authorization.

## Historical handoff — IP-1C geometry references and GPX contract

- **IP-1C verdict: PARTIAL.** Synthetic advisory-distance vectors, source/formula descriptions, proposed numeric tolerances, finite-rhumb closest-point exact cases and GPX 1.1 output contract are documented. IP-1C is not an IP-1 PASS, implementation claim, navigational accuracy claim or ECDIS-equivalence claim.
- **Authorization:** Gate 4 is authorized for IP-1C only by the current owner task. IP-1D onward, IP-2–IP-7 execution, production geometry, parser/converter/serializer/CLI/application/Shortcut, packaging and release remain **NOT AUTHORIZED**. Gate 3 is owner-confirmed PASS / ARCHITECT ACCEPTED at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`.
- **Branch/baseline:** `implementation/ip-1c-geometry-gpx-contract`, created from reviewed IP-1B commit `aa97b3e445d2edb85ad6795952b06ca28019dbfb`. The unrelated pre-existing `AGENTS.md` user edit is preserved and excluded from this commit.
- **Geometry oracle:** GeographicLib Python 2.1, MIT/X11, configured explicitly as `Geodesic(6371007.1809, 0)` for the approved sphere; checked against an independent unit-vector central-angle calculation. Seventeen numeric distance/bearing entries plus two unavailable-domain classifications cover equatorial, meridional, mid-latitude, antimeridian, high-latitude, near/coincident and near-antipodal cases and GC/rhumb differences. Five additional finite-rhumb closest-point cases have exact global proofs. Repeated generation of the 17 numeric outputs produced identical SHA-256 `2cdad3e6bcd6d2ca76eb1feb32ca320ae8e3334efaa4460be69c6557200f0919`. Rhumb outputs use the spherical loxodrome equations described in Karney (2024), with an independent Simpson line-element integration cross-check (2048 intervals; maximum discrepancy `1.40e-9 m`). `RhumbSolve` was not executed; reviewer reproduction remains outstanding.
- **G3-006:** The approved finite-rhumb closest-point objective remains unchanged. Exact cases with global proofs are included, but a general globally complete minimizer, tie policy and numerical error bound are not established. General rhumb joins remain unqualified and must fail closed; this is the principal reason for PARTIAL.
- **GPX evidence:** Exact temporary Topografix XSD SHA-256 `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6`; `xmllint` / libxml2 2.9.13 with `--nonet` accepted a synthetic one-point route and rejected `lon="180"` at `maxExclusive`. The XSD was not committed; GPX XSD redistribution rights remain conditional. Byte-level determinism is explicitly not required; semantic determinism is mandatory. A one-point product route is allowed with warning and affirmative confirmation per G3-004.
- **Other open blockers:** IP-1A remains PARTIAL; RTZ 1.0/1.2 redistribution is not cleared, RTZ 1.2 exact IEC artifact lineage requires external confirmation, GPX XSD rights are conditional, and self-contained offline schema validation is unqualified. GPX name bounds/Unicode normalization/negative zero remain IP-4 technical decisions. No Windy behavior is claimed.
- **Verification:** Seventeen numerical reference rows were generated twice with identical output; independent great-circle cross-check maximum observed residual was `1.11e-9 m`, and Simpson rhumb-integral checks (2048 intervals) differed by at most `1.40e-9 m`. `xmllint --nonet --noout --schema /tmp/rtz-ip1a-schemas/gpx-1.1.xsd /tmp/ip1c-gpx-onepoint.gpx` passed; the same command for `/tmp/ip1c-gpx-plus180.gpx` failed as expected. `git diff --check` passed; review confirmed documentation-only scope. No production tests/builds or app execution occurred.
- **Files:** `docs/research/IP-1/GEOMETRY-REFERENCE-VECTORS.md`, `docs/research/IP-1/GPX-1.1-CONTRACT.md`, `REPORT.md`, `PROGRESS.md`. No fixture, schema, dependency or runtime artifact is included.
- **Next:** independent Architect review of IP-1C PARTIAL evidence. Do not begin IP-1D or later work without separate authorization.

## Historical handoff — IP-1B synthetic fixture corpus

- **IP-1B: PASS — static corpus and qualification matrix complete.** This verdict is limited to the IP-1B fixture-corpus deliverables; it is not an IP-1 PASS or RTZ support/implementation claim.
- **Authorization boundary:** only IP-1B was authorized by this task. IP-1C and later substages, IP-2–IP-7 execution, parser/application implementation and release remain **NOT AUTHORIZED**. Gate 3 remains owner-confirmed PASS / ARCHITECT ACCEPTED at `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`; the IP-1B branch is based on reviewed commit `8e94ae0875ef914fec0f5ddc40ca3d3fe6f920bc`.
- **Branch/baseline:** `implementation/ip-1b-synthetic-fixture-corpus`, based directly on reviewed commit `8e94ae0875ef914fec0f5ddc40ca3d3fe6f920bc`. The pre-existing `AGENTS.md` edit is preserved and excluded from this stage commit.
- Added 35 original synthetic RTZ XML fixtures, a stable-ID `manifest.json`, corpus README and a temporary-generation recipe for oversized input. Coverage includes RTZ 1.0/1.2 minimal and field cases; required/range-invalid structures; version/namespace errors; metadata, Unicode, duplicate IDs, missing names, schedules/extensions; coordinate boundaries and geometry-oriented input cases. RTZ 1.1 is not enabled.
- **Schema evidence:** using local temporary CIRM XSD copies with `xmllint`/libxml2 2.9.13 and `--nonet`, 19 fixtures validated and 13 expected-invalid fixtures failed schema validation. One malformed document failed XML parsing; unsupported 9.9 had no schema selected. The DTD/entity fixture was intentionally not sent to XSD validation. No parser/application tests were run.
- Fixture SHA-256 values, exact schema hashes, expected versus actual XSD outcomes, anticipated processing categories, route order, purpose and provenance are in `tests/fixtures/rtz/synthetic/manifest.json`. The temporary schemas are not committed. RTZ 1.0/1.2 redistribution remains **NOT CLEARED**; RTZ 1.2 exact IEC file lineage remains **REQUIRES EXTERNAL CONFIRMATION**. IP-1A remains **PARTIAL**.
- No CIRM/IEC/STM/vendor/sample RTZ, operational route, private coordinate, vessel identifier, or source data was committed. The fixture coordinates are project-authored synthetic decimals and are not navigational guidance. No 1.1 fixtures, parser, geometry implementation, serializer, CLI, Shortcut, dependency or package was created.
- Checks: schema validation and fixture-hash/manifest consistency; privacy/scope review; `git diff --check`. The final commit and remote verification are provided in the task handoff.
- **Next:** independent Architect review of IP-1B. Do not start IP-1C or later work without separate authorization.

## Historical handoff — IP-1A schema qualification execution

- **R2 update:** CIRM’s publication of the exact RTZ 1.2 bytes is verified (document 64; document 65 is byte-identical). The association with IEC PAS 61174-1:2021 is supported generally by CIRM/IEC descriptions, but exact-file identity remains unconfirmed because the XSD says `IEC PAS 6XXXX`.
- **Rights status:** RTZ 1.0/1.2 redistribution is **BLOCKED / NOT CLEARED** pending written CIRM/IEC terms. GPX 1.1 is **CONDITIONAL**: Topografix calls the overview page text public domain, but has not expressly confirmed the raw XSD. No schema was bundled and no inquiry was sent. Ready-to-send drafts are in the qualification record.
- **Offline strategy:** preferred technical candidate is permitted, pinned XSD resources plus statically linked, pinned libxml2 inside the signed CLI. This remains conditional on rights, legal review, notices, target-macOS/API and security qualification; no build was done. A system libxml2 option and separately licensed user-supplied schemas are documented alternatives. Partial custom checks and runtime network fetch are not acceptable substitutes.
- **Authorization:** Gate 3 PASS / ARCHITECT ACCEPTED at approved baseline `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`. Gate 4 is authorized for IP-1A only. IP-1B onward, IP-2–IP-7, application implementation and release remain **NOT AUTHORIZED**.
- **IP-1A verdict: PARTIAL.** R1’s validation evidence is unchanged and not repeated in R2. No runtime, parser, serializer, dependency installation, or package was built or exercised.
- Full evidence, sources, strategy comparison, external questions, and closure criteria: [RTZ-SCHEMA-QUALIFICATION.md](docs/research/IP-1/RTZ-SCHEMA-QUALIFICATION.md). External rights, final provenance confirmation, legal/runtime review, full IP-1A matrix, and independent sign-off remain open.
- RTZ 1.1 remains conditional and non-blocking; the inspected STM materials do not establish a canonical, rights-cleared lineage. No RTZ schema was committed or cleared for bundling. No persistent fixtures were created because their approved plan ownership is IP-1B.
- **Unrelated local change:** pre-existing user edit in `AGENTS.md` remains untouched and uncommitted. Only the qualification record, this report, and `PROGRESS.md` are authorized for the R2 commit.
- Branch: `implementation/ip-1a-standards-schema-baseline`, based on `2a779f3b1e309ff652911c3dc7c78017ea0ebb1c`. Commit and remote-head verification will be reported in the task handoff.
- **Next:** independent Architect review of this PARTIAL IP-1A evidence. Do not begin IP-1B or any later work without separate authorization.

## Historical handoff — Gate 3 recovery merge (status superseded by owner acceptance and current reconciliation)

Historical record; superseded by the IP-1A execution status above.


- **Effective status: Gate 3 PENDING FINAL INDEPENDENT ARCHITECT REVIEW.** The remote `Gate 3 PASS / ARCHITECT ACCEPTED` declaration at `d9f723ba91091c682c9676f41dc168da31a252f1` is preserved as a historical event and is superseded for current authorization purposes. Gate 4, stage execution, and implementation are **NOT AUTHORIZED**.
- R2 corrections remain: the Master Plan route-name field mapping follows G3-001; IP-4/IP-5 reflect the approved G3-004 one-point policy.
- Branch: `docs/gate-3-reconciliation`; approved IP-7 parent: `482c8b585635138174dbf64d309cc3f308e3dcd9`. The approved Master/IP-1–IP-7 baseline provenance and G3-001–G3-011 decision ledger are recorded in [GATE-3-RECONCILIATION-R1.md](docs/implementation/GATE-3-RECONCILIATION-R1.md).
- The reviewed reconciliation records the accepted export-only route naming, explicit Current Position geometry, source continuity, one-point warning/export, +180° fail-closed qualification, rhumb closest-point objective, separate route/publication consent, mandatory Windy multi-point PASS, fully local offline behavior, signed app/DMG architecture, and Gate 3/Gate 4 governance.
- Preserved all stage decompositions and documented remaining technical qualification owners and stop conditions. No feasibility, consumer acceptance, implementation PASS, or effective Gate 3 PASS is claimed.
- This closure updates status/governance wording only in the Master Plan, IP-1–IP-7 plans, this report, `PROGRESS.md`, and the reconciliation report. No implementation, test, fixture, schema, dependency, CLI, Shortcut, build, Windy-import or platform-probe artifact is created or run.
- This local recovery merge reconciles both documentation histories without publishing them. It does not declare Gate 3 PASS or authorize Gate 4.

## Historical handoffs

## IP-7 detailed plan handoff

- **IP-7 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK (R1 corrections applied).**
- **IP-7 EXECUTION: NOT AUTHORIZED. GATE 3 CROSS-CHECK: NOT AUTHORIZED. OVERALL IMPLEMENTATION: NOT AUTHORIZED.** Gate 1 and IP-1–IP-6 approvals/statuses are preserved; no platform qualification or release readiness is claimed.
- Branch: `docs/ip-7-macos-shortcuts-ux-install-release`, R1 baseline `e593201e833bc1cba04523c036acc037dda9b2c8`.
- Added `docs/implementation/IP-7-MACOS-SHORTCUTS-UX-INSTALL-RELEASE-PLAN.md` defining the Shortcut-first UX; Finder and standalone journeys; four route modes; native interaction candidates; preview/confirmation continuity; safe save/overwrite; transport and permissions qualification; privacy/offline, accessibility, package/install/update/removal; synthetic acceptance matrix; IP-7A–IP-7F; dependencies, Gate 3 decisions and release gate.
- R1 Correction 1 separates **route confirmation** (source/content state, mode/selections, manual position, qualified geometry, resulting ordered points and metadata-loss warnings) from **publication consent** (exact destination/name, target state, destination warnings and exact overwrite authorization). A destination-only change renews publication consent but preserves still-valid route confirmation. Source or transformation change invalidates route confirmation and consent bound to the old output. Target-state changes invalidate publication consent. IP-5 must revalidate source/preview continuity and target before safe publication; failures require the relevant renewed approval. IP-5D's cross-invocation continuity mechanism remains unresolved.
- R1 Correction 2 makes **Mandatory Offline PASS** apply to fully local available inputs and local destinations across all modes and Finder/standalone flows with networking disabled. File Provider/cloud-backed behavior is conditional and separately qualified for hydration, authority, provider permissions, save/replacement, publication guarantees, metadata, cancellation and network-dependent behavior. Converter-controlled network activity is distinguished from OS/provider activity; unavailable cloud-only items are safe conditional limitations, not failures of the local offline guarantee.
- IP-7A–IP-7F decomposition is preserved. No Shortcuts/CLI transport, API, security-scope solution, macOS floor, package, signing/Gatekeeper path, provider behavior or Windy compatibility is claimed qualified.
- The signed/notarized `.app` container with bundled arm64 Swift CLI distributed as DMG remains a candidate only. No Shortcuts action/API, process transport, security-scope solution, macOS floor, package, signing/Gatekeeper path, provider behavior or Windy instruction is claimed qualified. IP-5D source identity/content continuity and IP-1D/IP-1E dependencies remain blockers.
- IP-4 one-point and route-name decisions, IP-3 Loxodrome metric, joint alias/security-scope policy, IP-5E output permissions/provider behavior, transport/package selection, and IP-6 consumer status remain unresolved for Gate 3 or their owning stage.
- No application code, tests, fixtures, scripts, schemas, binaries, packages, Shortcuts or platform probes were created or run. No real route, derived coordinates, credentials or source digest were added.
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`. Planning commit and remote-head verification are reported in the final task handoff.
- **Next:** Gate 3 cross-check when separately authorized. IP-7 execution remains unauthorized. Review the R1 approval boundaries, offline/provider split, and preserved Gate 3 decisions before cross-check.

## IP-6 R1 correction handoff

- **IP-6 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.** (Two architectural corrections applied.)
- **IP-6 CONSUMER ACCEPTANCE: NOT TESTED.**
- **IP-6E REPORT: NOT STARTED.**
- **IP-6 EXECUTION: NOT AUTHORIZED.**
- **IP-7 PLANNING: NOT STARTED at that historical handoff.** The approved IP-7 plan was created later; current status is stated above.
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Branch: `docs/ip-6-windy-route-planner-acceptance`, reviewed baseline `eca79b4dbba9019d3651c74a603d46bd52960e0a`.

Updated `docs/implementation/IP-6-WINDY-ROUTE-PLANNER-ACCEPTANCE-PLAN.md` to close both R1 conditions. **Report completion is independent from consumer acceptance:** a future `IP-6E REPORT COMPLETE` may document aggregate PASS, FAIL, BLOCKED or INCONCLUSIVE; it does not itself mean `IP-6 CONSUMER ACCEPTANCE PASS`. The current IP-6E empirical report is not started, and consumer acceptance remains NOT TESTED.

R1 also separates **imported route-data mutation** (mandatory failure for changes to required point/object semantics), **display-only rendering/interpolation** (not automatically a failure when route data is unchanged), and **semantics-changing automatic routing** (requires explicit classification/review). If supported evidence cannot distinguish rendering from route mutation or automatic routing, the affected criterion is INCONCLUSIVE. Numerical coordinate/order unknowns remain blocking for consumer PASS; upload success and plausible screenshots are insufficient.

At that historical IP-6 handoff, remaining blockers included live Windy workflow/version confirmation, exact Route Planner object interpretation and supported point/coordinate inspection, authentication/persistence requirements, interface/platform matrix, and approved synthetic corpus plus upstream implementation evidence. IP-4 one-point and route-name policies were then recorded as unresolved; the approved IP-7 plan did not yet exist. Current status is stated at the top of this report.

No code, scripts, tests, browser automation, probes, GPX/RTZ fixtures, schemas, binaries, Shortcuts, dependencies or packages were created. No route was uploaded to Windy; no tests or empirical checks were run. No credentials or real route data were added.

## IP-6 repository state

- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- Commit and remote verification: recorded in the final task handoff after publication.
- Next: architectural review of the IP-6 plan; do not execute IP-6 or begin IP-7 planning without separate authorization.

## IP-5 planning handoff

- **IP-5 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.** (Architectural review: approved with minor conditions; R1 corrections applied.)
- **IP-5 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Branch: `docs/ip-5-cli-runtime-packaging`, reviewed baseline `af619b326a3a60a8a32912b3eda94774223c960f`.

Updated `docs/implementation/IP-5-CLI-RUNTIME-PACKAGING-PLAN.md` to close four R1 conditions while preserving IP-5A–IP-5F. IP-5A through IP-5F remain future execution sub-stages; none is executed or individually passed.

R1 corrections: (1) `inspect` uses the approved file-reference mechanism and the exact IP-2 secure acquisition, bounded read, dialect/schema/semantic validation path; summaries derive only from immutable validated `RouteDocument`. No separate parser, path reader, filename inference or schema bypass; output bounds and over-limit strategy are explicit planning requirements. (2) Preview/confirmation requires fresh authorized reference acquisition, fresh IP-2 validation, and verified source-object identity plus source-content continuity; capability lifetime, semantic preview equivalence and user consent remain distinct. The continuity mechanism is unresolved pending joint IP-2/IP-5/IP-7 qualification; no stateless feasibility or default private digest is claimed. (3) Output permissions are evidence-gated: `0600` is only a candidate; IP-5E must qualify macOS defaults, umask, ACLs, extended attributes and provider semantics separately for creation/replacement, without unsafe inheritance or silent loss. No final mode is selected. (4) IP-5D does not PASS if secure continuity cannot be demonstrated. Rollback may restore verified work; dropping Current Position from V1 requires separate explicit product-governance approval and cannot be an IP-5 unilateral downgrade.

The existing conditional JSON stdio proposal, file-reference security boundary, local self-contained packaging direction, offline requirements, writer ownership and explicit user consent remain. No protocol, package, filesystem API, Shortcuts behavior, minimum OS, permission policy or source-continuity mechanism is claimed as qualified. IP-4 one-point and route-name decisions remain Gate 3 items.

Remaining Gate 3 decisions and blockers: cross-check inspect limits and pagination/error strategy with IP-2; jointly qualify source identity/content continuity and reference/capability lifetime with IP-2/IP-7; resolve IP-4 one-point/name policies; reconcile IP-1D transport and IP-1E packaging. Execution/platform blockers include IP-1A schema rights/offline validator, IP-2A alias/security-scope policy, IP-3 confirmed-command/geometry evidence, IP-6 Windy results, IP-7 UI/install binding, actual filesystem permissions/ACL/atomicity, signing/notarization, cancellation, Gatekeeper and clean-user verification.

No application code, scripts, tests, probes, fixtures, schemas, dependencies, binaries, GPX, packages or Shortcuts were created; no tests or platform probes were run. No private routes, credentials or generated artifacts were added.

## IP-5 repository state

- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- R1 correction commit and remote-head verification: recorded in the final task handoff after publication.
- Next: Gate 3 cross-check when the full detailed-plan set is ready; do not execute IP-5 or begin IP-6 planning without separate authorization.

## IP-4 R1 correction handoff

- **IP-4 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.** (Architectural review: approved with minor conditions; R1 corrections applied.)
- **IP-4 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Branch: `docs/ip-4-gpx-serialization-loss-report`, reviewed baseline `df9ebbb31ddd3679d0c6c3adb828ab35a64f6303`.

Updated `docs/implementation/IP-4-GPX-SERIALIZATION-LOSS-REPORT-PLAN.md` and preserved the IP-4A–IP-4F decomposition.

The plan now records four corrections: (1) one-point export is an unresolved Gate 3 decision between ALLOW_WITH_WARNING and REFUSE_EXPORT; the valid IP-3 neutral transformation remains valid either way, and IP-6 provides compatibility evidence without deciding product policy. (2) IP-3 owns the source route name/provenance, IP-4 serializes approved naming input, IP-5 transports it, and IP-7 owns any confirmation UI; a confirmed export-only display-name override remains an explicit Gate 3 choice, with no automatic vessel/route/filename fallback. (3) IP-4 returns immutable validated bytes and the loss report; IP-5 owns filesystem writing/staging/identity/collision/publishing/cleanup/save result; IP-7 owns destination selection, overwrite consent and save feedback. Safe-save invariants remain intact. (4) coordinate preservation is representation-aware: exact decimals require mathematical equality; binary floating point may use qualified shortest round trip to the same finite value, with source-decimal error analysis and independently verified tolerance required before freeze. No RTZ lexical preservation is claimed. Longitude +180 remains fail-closed unless approved otherwise.

Gate 3 decisions: one-point policy and whether to permit a confirmed export-only route-name override, including reconciliation with Master Plan wording. Remaining evidence/execution blockers include IP-1 schema identity/license/offline validation; IP-2 numeric representation and error evidence; IP-3 model/confirmation evidence; +180 handling; IP-5/IP-7 file-reference and save contracts plus filesystem/provider verification; and IP-6 Windy empirical evidence. Gate 3 cross-check remains ahead; no unresolved decision or evidence is represented as approved or tested.

No application code, tests, fixtures, schemas, GPX, CLI, Shortcuts, dependencies or implementation artifacts were created. No tests were run; no private routes, credentials or generated artifacts were added.

## IP-4 repository state

- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- R1 correction commit and remote verification: recorded in the final task handoff after publication.
- Next: Gate 3 cross-check when the complete detailed-plan set is available. Do not execute IP-4 or begin IP-5 planning.

## IP-3 planning handoff

- **IP-3 PLAN: APPROVED / READY FOR GATE 3 CROSS-CHECK.**
- **IP-3 EXECUTION: NOT AUTHORIZED.**
- **OVERALL IMPLEMENTATION: NOT AUTHORIZED.**
- Planning branch is based on corrected IP-2 commit `8011d3f0c4baf62cb15194ab9308f4e312269615`; no upstream execution PASS is implied.

Created `docs/implementation/IP-3-ROUTE-MODES-GEOMETRY-PLAN.md` and applied all four R1 architectural corrections in §§4.2, 5.1–5.3, 7–8, 10–14, and 15. The plan specifies Full Route, From Waypoint, Current Position / Direct to Next WP, and Current Position / Join Selected Route Leg; immutable source-order transforms; scoped ordinal waypoint/leg references; incoming-leg ownership; synthetic-point and source-leg provenance; domain preview/confirmation contracts separated from IP-5 transport and IP-7 UI; privacy-safe diagnostics; metadata losses; advisory-only distance; and IP-4/IP-5/IP-7 handoffs.

R1 corrections: (1) one-point neutral transformations are valid with an INSUFFICIENT_OUTPUT_POINTS advisory; no point is fabricated or result discarded; GPX exportability is left to IP-4 and empirical Windy compatibility to IP-6, without pre-approving one-point GPX. (2) Join endpoints reuse the corresponding original source waypoint reference only when classified coincident under a still-provisional numerical/identity tolerance; coordinate deduplication never removes a synthetic join, distinct source identities are never merged, and the current-position point retains distinct provenance. (3) The Loxodrome closest-point metric is an **UNRESOLVED ARCHITECTURAL DECISION**. Authalic-sphere great-circle separation remains only a candidate; metric review/approval must precede any minimizer qualification, and global root completeness remains a hard gate. (4) IP-3 domain creates previews/candidates and validates confirmed commands; IP-5 owns transport/binding; IP-7 presents the preview and collects consent. Revisions/tokens are transient contract proposals, not presumed durable identifiers or cryptographic protections.

At that historical IP-3 handoff, execution blockers included IP-1 qualified schema/geometry literals and independent distance oracles/tolerances; IP-2 implemented model and ID semantics; great-circle degeneracy and join-endpoint tolerance qualification; architectural selection of the Loxodrome closest-point metric followed by global-minimum/root-completeness evidence; field-by-field split-leg metadata applicability; IP-4 one-point export policy and IP-6 empirical Windy acceptance; and final IP-4/IP-5/IP-7 interface contracts. Those technical qualifications remain open where owned; the Gate 3 pending statement records only the status at that historical handoff.

No implementation code, tests, fixtures, probes, schemas, dependencies, CLI, GPX, or Shortcuts were created or run. No real routes, derived vessel coordinates, credentials, or full source-route digest were added.

## IP-3 repository state

- Branch: `docs/ip-3-route-modes-geometry`
- Base: `8011d3f0c4baf62cb15194ab9308f4e312269615`
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- IP-3 plan commit: `9a5db3525b986a3e13e3239274dcc6ae6957d6e5`.
- R1 correction commit and final remote-head verification are recorded in this task handoff.
- Next action: architectural review of IP-3 plan. Do not execute IP-3 or begin IP-4.

## Status

- Gate 1: **APPROVED / PASS**.
- IP-1 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK**; IP-1 execution remains **NOT AUTHORIZED**.
- IP-2 plan: **APPROVED / READY FOR GATE 3 CROSS-CHECK** after R1 corrections.
- IP-2 execution and overall implementation: **NOT AUTHORIZED**. No implementation PASS is claimed.

## IP-2 planning deliverable

Created `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` from approved IP-1 planning revision `6ed649d3995f70fa2421e08cb027c07d19b4cad4`. It defines secure single-file ingestion, strict exact-pair dispatch, separate XML/schema/semantic phases, immutable route model, diagnostics, synthetic test matrix, API boundaries, future IP-2A–IP-2E decomposition, acceptance criteria and handoffs.

Key recommendations: Foundation XMLParser is a candidate only; security/resource behavior needs authorized verification. Schema validation is an independent layer and requires a legally cleared offline strategy. No exact 1.2 namespace is guessed. Proposed numeric resource limits remain unapproved until workload/adversarial evidence and review. Fail closed for unqualified dialects, unavailable schemas, unsafe XML and fatal semantic errors. No partial model on fatal input.

The model preserves XML waypoint order independently of waypoint IDs, treats destination waypoint leg metadata as incoming, distinguishes optional absence from defaults, and never repairs coordinates or guesses geometry. RTZP remains out of scope. IP-3/IP-4/IP-5/IP-6/IP-7 handoffs are described without implementing their work.

## IP-2 R1 corrections recorded

1. **FileReference trust — plan §§3, 9, 11.** It is an opaque, local, untrusted reference until securely opened and validated. Finder/Shortcuts/CLI origin is no bypass; descriptor identity, bounded reads and no unsafe path reopening remain.
2. **Aliases and symlinks — §§3, 10, 11, 14.** Unsafe path traversal is distinguished from a user-selected alias/file reference. No blanket symlink rejection is prescribed. IP-2A/IP-5/IP-7 jointly settle aliases, security-scoped URLs, permissions and identity; any allowed resolution must be explicit, bounded and resistant to replacement.
3. **Unknown geometry — §§6, 10, 12.** UnknownLiteral is uninterpreted source metadata only and never drives navigation, distance, selection or transformation. IP-3 may use explicitly qualified types only; schema-prohibited literals fail closed. No Loxodrome/Orthodrome fallback. Incoming-leg ownership and source order remain intact.
4. **Source digest privacy — §§6, 8, 14.** No RTZ digest is calculated or persisted by default and no source hash is exposed in diagnostics, logs, CLI output or Shortcut messages. IP-2A may propose one only for documented need, privacy review and explicit approval. Required schema artifact hashes remain separate.

## Approved upstream direction

V1 remains an offline macOS Apple Silicon tool with a macOS Shortcut as primary UI and a self-contained local CLI, no standalone GUI, and no target-Mac Homebrew/Python requirement. It supports the three approved route modes with explicit user selections, emits GPX 1.1, preserves the input RTZ, and makes metadata losses visible. No automatic navigation decisions or ECDIS-equivalence claim. RTZ 1.0/1.2 are mandatory targets subject to qualification; 1.1 is conditional; RTZP is out of scope. Distance remains advisory only. IP-1 review conditions remain recorded in its approved plan.

## Open dependencies and risks

- IP-1A must qualify exact 1.0/1.2 schema pairs, hashes and fields and resolve legal/runtime validation strategy; these block parser implementation.
- IP-1B must supply reviewed synthetic fixture IDs and outcomes.
- IP-2A must verify parser behavior, resource enforcement, limits, cancellation and joint file-reference/alias policy with IP-5/IP-7 on candidate macOS versions.
- ID uniqueness, minimum useful waypoint count, geometry literals, optional metadata rules, precision representation and extension-summary policy require evidence/review.
- IP-5/IP-7 must resolve file-reference/alias behavior and cross-check diagnostic identifiers before those contracts freeze.

No contradiction with the Master Plan or IP-1 was identified. Dependencies that remain conditional are explicitly marked; no schema version, licensing, runtime, or security behavior is represented as implemented or tested.

## Changed files and verification

- `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md`
- `REPORT.md`
- `PROGRESS.md`

Documentation-only changes. No application code, parser, model, fixture, test, schema, dependency, CLI, Shortcut, package, or test run. No real RTZ/GPX routes, derived coordinates, or credentials are included.

## Repository state

- Branch: `docs/ip-2-safe-input-model-parser`
- Base: approved IP-1 planning commit `6ed649d3995f70fa2421e08cb027c07d19b4cad4`
- Remote: `https://github.com/bezon1201/rtz-gpx_convertor.git`
- Commit SHA and remote verification are recorded in the task handoff after the focused planning commit.

## Review request and next process

Please review the IP-2 architecture, proposed limits, security behavior, semantic classifications, model semantics, and upstream blockers. After IP-2 review and separate authorization for the remaining detailed plans, cross-check the full plan set at Gate 3, resolve findings, then obtain explicit Gate 4 authorization before any implementation. Stop after this planning commit.


## Historical remote Gate 3 Architecture Review Closure — superseded for current authorization

Historical remote disposition: **GATE 3 — PASS / ARCHITECT ACCEPTED**. Reviewed reconciliation commit: f98f43618ad69c347fc8a071d741b9719714b934; its parent is 482c8b585635138174dbf64d309cc3f308e3dcd9. Findings and residual qualification boundaries are recorded in docs/implementation/GATE-3-RECONCILIATION-R1.md. No pending technical qualification is converted to PASS.

**Gate 4 authorization is stage-specific and never blanket authorization.** This governance reconciliation authorizes no implementation stage. IP-2–IP-7 execution and overall implementation remain **NOT AUTHORIZED**. Gate 4 requires separate explicit product-owner authorization naming each stage and any associated probes. Historical handoffs above retain their statuses as recorded at the time.
