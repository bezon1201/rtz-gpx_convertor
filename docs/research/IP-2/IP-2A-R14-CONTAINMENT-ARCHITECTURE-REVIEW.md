# IP-2A R14 — Resource-Containment Architecture Review

**Authorization:** documentation-only architecture review, based on the approved IP-2 plan §§3–4 and 11 and existing R10, R12 and R13 evidence. No probe, test, build, implementation, schema, dependency, or runtime artifact was authorized or created.

**Baseline:** `40a40ee26296dc720eaa13318c971fee912e384e`

**R13 disposition:** PASS / ARCHITECT ACCEPTED as a research substage. Its technical conclusion remains **WORKER RESOURCE CONTAINMENT PARTIAL**.

**OS prerequisite update (IP-1E R2):** Sequoia 15 is **ACCEPTED AS PROVISIONAL ENGINEERING BASELINE** for future authorized research only. Product OS floor remains NOT QUALIFIED. This updates target identification, not R14's empirical status. Target environment/build is **NOT VERIFIED**; exact lawful schema/runtime is **NOT AVAILABLE / NOT CLEARED** (B01/B02 pending); integrated parser/schema workload authorization is **NOT GRANTED**; actual workload qualification is **NOT RUN**. R10–R14 Tahoe 26.6.2 observations do not establish Sequoia behavior. The proposed R14 follow-up remains unexecuted until its prerequisites are available and separate authorization is issued.

## 1. Requirements audit

The approved plan requires bounded input/work evidence and a rationale for limits and their enforcement points; measurement of cancellation on qualified targets; fatal failure with no partial model/output; safe cleanup; and a reviewed security/dependency decision before IP-2B. It says to document resources that cannot be bounded and not promise a hard bound. It does not approve a numeric CPU, wall-clock, virtual-memory, resident-memory, or cancellation limit. The candidate 5-second parse/schema budget, 128 MiB per-conversion memory value, and 250 ms cancellation value remain proposals only.

| Dimension | What the approved plan requires | What it does not establish or prescribe | R13 contribution |
|---|---|---|---|
| CPU-time limit | Bounded-work evidence, justified limits and enforcement points; expose unbounded work as a residual. | No mandatory `RLIMIT_CPU` value or requirement that this particular API be used. | `RLIMIT_CPU` was accepted and delivered `SIGXCPU` at the 1-second soft limit for the synthetic loop, twice, on one host. No parser CPU bound follows. |
| Wall-clock lifetime | Cancellation checks and measured responsiveness on qualified targets; promptly stop/fail as ultimately reviewed. | No 2-second watchdog, 250 ms grace period, or other numerical product deadline is approved. | A parent watchdog independently stopped a child ignoring `SIGTERM` and reaped it. The measured 254–255 ms termination-request-to-reap interval is an observation, not an SLO. |
| Virtual-address-space limit | Measure and classify the enforcement point; do not equate a proposed cap with a verified guarantee. | No mandatory `RLIMIT_AS` policy or 128 MiB address-space headroom. | The accepted `RLIMIT_AS` ceiling stopped new anonymous mappings in the tested allocation pattern. This concerns virtual mappings, not resident memory. |
| Resident-memory limit | Measure peak memory and document any resource that cannot be bounded; never promise an unsupported cap. | No approved 128 MiB RSS/per-conversion requirement and no explicit requirement to claim a hard RSS cap. | No hard resident-memory limit was demonstrated. `ru_maxrss` and samples are observations only. |
| Cancellation responsiveness | Check during reads/callbacks, measure on qualified targets, and fail without a partial result. | No fixed latency target is approved. | Parent termination was demonstrated only for this child on this host. Parser, schema, model and application cancellation remain unqualified. |
| Crash containment | A reviewed security decision must state residual risks and failure behavior. A separate process can reduce some process-local crash impact. | The plan does not independently mandate worker isolation. | No parser crash was induced. Process separation is a defensible containment property to qualify, not a product guarantee yet. |
| No partial model/output | On fatal failure, return no usable partial model; output/publication follows the approved confirmation boundaries. | R13 does not define a worker protocol or an accepted-result protocol. | Synthetic child emitted no accepted success before completion; no parser/model/output pipeline was exercised. |
| Cleanup and reaping | Safe cleanup and close-once behavior are required in the chosen pipeline. | No product child lifecycle has been qualified. | All eight research child invocations were reaped, and the immediate no-orphan check observed `ESRCH`; no descendants or production cleanup paths were tested. |

## 2. Independent R13 evidence review

The committed source, runner, and `results.json` were inspected. They identify the source and runner hashes, run two repetitions, record setter errors, wait status/signals, CPU time, timing, `ru_maxrss`, `proc_pidinfo` samples, child output, reap and orphan checks. The runner compiles a temporary executable, ad-hoc signs it, checks that signature, executes the repetitions and removes the binary. Recorded environment: macOS 26.6.2 (25G83), Darwin 25.6.0, arm64, Apple clang 21.0.0, ad-hoc signature, no entitlements.

The evidence supports these limited statements:

- **CPU-time:** `setrlimit(RLIMIT_CPU)` succeeded with 1/2-second soft/hard limits, and the synthetic child ended with `SIGXCPU` after about one second of CPU time. This is kernel enforcement for that test, not a parser-work bound.
- **Wall-clock:** with CPU limits set beyond the test interval, the parent watchdog fired at its configured 2 seconds, sent `SIGTERM`, escalated to `SIGKILL` after its configured 250 ms grace, and reaped the ignoring child. This is independent supervision in the test arrangement, not a guaranteed response deadline.
- **Virtual address space:** `setrlimit(RLIMIT_AS)` succeeded. The attempted limit was the measured pre-exec virtual-size baseline plus 128 MiB. Anonymous mappings stopped with `ENOMEM` after 130,023,424 bytes of successful growth. This establishes only the tested new-mapping boundary.
- **Cleanup:** all eight started children across two repetitions were reaped and immediately returned `ESRCH` to `kill(pid, 0)`. This does not test descendant trees, races in a product supervisor, or application recovery.

The memory result needs particular care. Each child started with about **445,742,694,400 bytes (approximately 415 GiB) of virtual address space** already mapped. The configured ceiling was that large baseline plus 134,217,728 bytes, not a small absolute process-size ceiling. The experiment therefore tested incremental mapping headroom on this exact process/host layout. Baseline variability, pre-existing reservations, and allocation patterns that populate already-reserved mappings can change the usefulness of the same relative setting. The observed resident peak of 131,366,912 bytes is not an enforced RSS cap. `RLIMIT_DATA` returned `EINVAL`; it supplied no alternate memory control.

Limitations: one host, two repetitions, ad-hoc signing, no sandbox or product package, no frozen supported macOS floor, no parser/schema/model workload, no schema rights/runtime qualification, and no hard RSS control. This is a feasibility signal only.

## 3. Architecture comparison

| Option | Empirically supported mechanisms | Assumptions and unresolved residuals | Integration dependencies / R11 impact |
|---|---|---|---|
| **A — in-process parser with reviewed residual risks** | Existing R2/R3 evidence supports bounded bytes at the read callback and tested parser callback checks. R13 adds no in-process resource enforcement. | CPU work between callbacks is not independently stopped; process memory/RSS is not hard-capped; parser failure shares the app process. This option is acceptable only if the owners and independent security reviewer find the measured controls and explicitly documented residual risk sufficient under the approved requirements. | Simpler direct access to the securely opened descriptor under R11. Still requires exact schemas/runtime, cancellation and no-partial-model/output integration, supported-OS evidence, and a reviewed risk disposition. |
| **B — isolated worker with CPU limit, watchdog and address-space ceiling** | R13 supports `RLIMIT_CPU` for synthetic CPU work, parent watchdog termination/reap, and `RLIMIT_AS` limiting new mappings under one allocation pattern. Process separation also provides a boundary for many child-local failures, though parser crash isolation was not exercised. | No hard RSS/physical-memory cap; large baseline VM makes address-space budgeting relative and layout-sensitive; process controls and timing are one-host observations. A worker cannot be described as fully resource-bounded or production-qualified. Child descendants, forced termination races, and no-partial-result behavior in a real protocol remain untested. | Requires bounded, validated IPC and lifecycle; nested signing/package/resource discovery; exact runtime/schema resources; and a secure authorized file-reference handoff. Under R11 a path string cannot confer authority: the worker must consume an already authorized descriptor/capability or use another qualified authority-preserving mechanism, with bounded reads and no unsafe reopen. No handoff is selected. |
| **C — defer selection pending exact missing evidence** | All current evidence remains available without inferring unsupported controls. | Leaves no candidate for the next qualification sequence and does not answer whether worker-level CPU/crash isolation is worth its added complexity. | Avoids premature integration choice but delays IP-2A's reviewed security/dependency decision and blocks IP-2B. |

## 4. Candidate decision

**Decision: `ISOLATED WORKER CANDIDATE — REQUIRES QUALIFICATION`.**

R13 materially changes R12: it demonstrates host-specific, public mechanisms for CPU-time enforcement, independent wall-clock supervision/reaping, and a limited virtual-address mapping ceiling. Those mechanisms make a worker candidate concrete enough to qualify. This is not a finding that the worker meets all requirements, does not accept its residual memory risk, and does not approve a production architecture.

The unresolved memory question remains explicit. The approved plan does not make a hard RSS number a product requirement; it requires measurement, rationale, and honest disclosure when a resource cannot be bounded. A worker candidate can therefore proceed to a focused qualification only if the owners do not silently treat the address-space result as RSS containment and the independent security review determines whether the documented residual is acceptable. If that review requires hard resident-memory enforcement, Option B is not qualified by R13 and the candidate decision must be revisited. Option A is not silently accepted as a fallback.

R11 is unchanged: authority belongs to the selected, securely opened file reference, not a pathname. Candidate worker isolation creates a handoff requirement but does not alter the R11 contract or establish any transfer mechanism.

## 5. One minimal next evidence action — proposed, not authorized

**Propose one bounded, research-only parser-workload containment qualification on the provisional engineering target, after a Sequoia target environment/build is available and the exact schema/runtime is lawfully cleared.** Use the candidate parser and representative approved synthetic upper-bound valid and adversarial inputs in a disposable, ordinarily signed child; run on the recorded Sequoia target with the proposed CPU/watchdog/`RLIMIT_AS` controls. Record startup virtual-size baseline and its run-to-run variability, whether relevant parser allocations are new mappings or populate existing reservations, peak resident-memory measurements, control-triggered outcomes, cancellation-to-reap, and whether any result can be accepted before full success. Do not assign a numeric product memory/deadline requirement; compare only to separately approved limits and classify any unbounded RSS honestly. This engineering-target experiment would not establish the product support floor or release matrix.

This is one integrated evidence action aimed at the decisive gap between synthetic mapping growth and the actual parser/schema workload. It should determine whether the worker candidate provides useful, enforceable containment on the qualified target or whether its memory control is too weak to justify the added IPC, signing, and file-authority boundary. It must not be executed under R14; it requires a separate scope authorization after its prerequisites are available. Do not repeat standalone CPU/watchdog cases unless needed as controls in that integrated run.

## 6. Status and handoff

- **B01/B02:** pending external confirmation / rights not cleared.
- **B03:** OPEN / PARTIAL; R13 narrows but does not close it.
- **B04:** minimum file-reference policy remains PASS / ARCHITECT ACCEPTED; overall B04 remains OPEN / PARTIAL.
- **IP-2A:** PARTIAL / INCOMPLETE.
- **IP-2B–IP-2E:** NOT AUTHORIZED.
- **Overall IP-1:** PARTIAL / NOT PASS.
- **Production architecture:** not selected; worker is a qualification candidate only.

R14 changes no approved plan, numeric target, R11 policy, parser, worker, IPC, schema, dependency, or runtime artifact. Stop for independent Architect review; do not execute the proposed qualification or begin IP-2B–IP-2E.
