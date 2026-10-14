# IP-2A R13 — Signed-Child Resource-Control Feasibility

**Authorization:** the one-time R13 research-only scope exception in [`IP-2A-R13-SCOPE-EXCEPTION.md`](IP-2A-R13-SCOPE-EXCEPTION.md).

**Baseline:** `28ed59ce0fee7e7c0555beaa5de2fa188fb5f6bf`

**Target actually tested:** macOS 26.6.2 (build 25G83), Darwin 25.6.0, arm64 Apple Silicon; Apple clang 21.0.0 (`clang-2100.1.1.101`); locally ad-hoc signed executable, no entitlements, no privileged APIs.
**Scope:** synthetic CPU and anonymous memory only. No parser, RTZ/GPX, schema, route, file, network, authority-transfer, or product IPC activity.

## 1. Result

| Classification | Result | Exact scope |
|---|---|---|
| CPU containment | **QUALIFIED — host-specific feasibility only** | `RLIMIT_CPU` was accepted and the child received `SIGXCPU` at its one-second soft CPU limit in both runs. This is evidence for that control/workload on this host, not a parser or supported-OS claim. |
| Memory containment | **PARTIAL** | `RLIMIT_AS` was accepted and stopped new anonymous mappings near the configured virtual-address-space ceiling. `RLIMIT_DATA` configuration returned `EINVAL`. No general resident-set or total physical-memory cap is qualified. |
| Watchdog termination | **QUALIFIED — host-specific feasibility only** | The two-second parent watchdog sent `SIGTERM` to a child that deliberately ignored it, escalated to `SIGKILL` after 250 ms, and reaped it. Request-to-reap was 254–255 ms. This is not a deadline guarantee under other load or OS versions. |
| Reap/orphan behavior | **QUALIFIED — tested children only** | All eight child invocations across two runs were reaped; the post-reap `kill(pid, 0)` check observed `ESRCH`. The child created no descendants. |

**Architecture-feasibility conclusion: `WORKER RESOURCE CONTAINMENT PARTIAL`.** Public, nonprivileged CPU-time and parent-watchdog controls worked in this synthetic host setup. Address-space growth was bounded for the tested mapping pattern, but a hard, general process-memory/RSS bound was not established. Do not select a production worker automatically from this result.

## 2. Controls attempted and observations

The project-authored harness in `tests/research/ip2a/r13/resource_probe.c` applies limits in the forked child before `exec`; the parent supervises only synthetic child status, watchdog, and reap. The same four cases ran twice. Each control setter result, prior and requested limits, exit status/signal, child CPU, wall timing and memory observations are in [`tests/research/ip2a/r13/results.json`](../../../tests/research/ip2a/r13/results.json). That manifest contains source/runner SHA-256 identities and no machine name, user name, paths, route data, or coordinates.

### CPU-time control

`setrlimit(RLIMIT_CPU)` returned success with soft 1 second / hard 2 seconds. The deterministic busy-loop child terminated by signal 24 (`SIGXCPU`) after 1.006–1.023 seconds wall time and approximately 1.003 seconds combined child user/system CPU. The parent watchdog did not fire in this case. This distinguishes the kernel-delivered CPU-limit signal from parent action; it does not establish behavior for parser work or real-time latency.

### Independent parent watchdog

For a second run of the same CPU workload, `RLIMIT_CPU` was set soft 30 / hard 31 seconds so it would not be the controlling event. The child ignored `SIGTERM`. At two seconds the parent sent `SIGTERM`, waited 250 ms, sent `SIGKILL`, then reaped the child. Both repetitions ended by signal 9 with watchdog active and no orphan observed; request-to-reap measured 254–255 ms. This establishes that the watchdog path worked in the tested process arrangement, not that those times are guaranteed.

### Address-space / RSS alias control

The SDK defines `RLIMIT_RSS` as an alias of `RLIMIT_AS`; the harness attempted the public `RLIMIT_AS` limit at the pre-exec virtual size plus 128 MiB. `setrlimit` returned success. The child repeatedly `mmap`ed and touched 4 MiB anonymous chunks and requested up to 384 MiB. Both repetitions stopped with `mmap` returning `ENOMEM` after 130,023,424 bytes of successful growth, before emitting a completion status. `wait4` peak RSS was 131,366,912 bytes; sampled peak virtual size reached within 16 KiB of the configured address-space limit in one repetition and within 320 KiB in the other.

This demonstrates an enforceable limit on **new address-space mappings for this child/workload**. It does not establish a general RSS cap: existing mappings can be populated without increasing virtual size, other allocation strategies may behave differently, and no arbitrary parser/schema/model workload was run. The observed RSS is a measurement during this controlled input, not itself the enforced resource.

### Data-segment control

`setrlimit(RLIMIT_DATA)` was attempted with a 256 MiB soft/hard limit from prior unlimited limits. It returned `-1`, `errno=22` (`EINVAL`) in both repetitions. The child did not start; no `sbrk` growth was attempted. Thus this mechanism was **not configured or qualified** in this setup. The source uses the deprecated `sbrk` API only as a synthetic mechanism if the limit is accepted; it is not a product API recommendation.

## 3. Supervision, output and measurements

- Every started child produced only a startup line and, for memory, a final completion or allocation-failure line. No accepted-success response was emitted before completion; the memory-limit cases emitted only the synthetic allocation-failure status.
- The parent recorded `setrlimit` success/errno, prior and requested soft/hard values, wait status, terminating signal or exit code, watchdog/TERM/KILL actions, start-to-reap time, request-to-reap time when parent termination was requested, and `wait4` user/system CPU usage.
- Memory methods: Darwin `wait4`/`rusage.ru_maxrss` in bytes plus periodic `proc_pidinfo(PROC_PIDTASKINFO)` resident and virtual-size sampling. The rusage and sampled values are both reported; neither is represented as a universal hard physical-memory limit.
- Reap check: successful `wait4` reaping followed immediately by `kill(pid, 0)` returning `ESRCH`. No grandchildren were spawned.
- Signature: `codesign` ad-hoc signature verified locally; no entitlements were supplied. This is not Developer ID signing, hardened-runtime qualification, or notarization.
- Reproducibility: two full repetitions produced the same stable control outcomes; timing and sampled peaks varied slightly and are recorded separately. The runner also parsed and checked the results manifest, invariants, and sanitization.

## 4. Qualification boundaries and B03 impact

IP-1E has not frozen the minimum supported macOS version. These results are therefore **host-specific feasibility only**, not a supported-matrix qualification. They do not establish a product worker, parser or schema behavior, file authority, IPC, no-partial-publication lifecycle, packaging/signing compatibility, or a production cancellation contract. The parent watchdog’s wall-clock response under system load is not a hard real-time guarantee.

R13 narrows the B03 architecture question: a public CPU limit and an independent watchdog/reap path are feasible in this host-specific synthetic setup; a public address-space ceiling can stop new mappings in the tested setup; `RLIMIT_DATA` was unavailable with `EINVAL`; and hard general RSS/memory containment remains unresolved. A worker may still contain parser crashes and CPU work, but no production architecture is chosen. If another component requires a physical-memory cap or robust arbitrary-allocation containment, this evidence does not satisfy it.

Preserved statuses: **B03 = PARTIAL / NARROWED / OPEN; B04 minimum policy = PASS / ARCHITECT ACCEPTED; B04 overall = PARTIAL / OPEN; IP-2A = PARTIAL / INCOMPLETE; IP-2B = BLOCKED / NOT AUTHORIZED; overall IP-1 = PARTIAL / NOT PASS.** No approved requirement is waived. Independent Architect review is required before any follow-up or architecture selection.

## 5. Reproduction

Run `tests/research/ip2a/r13/run-probe.sh`. It compiles with Apple clang into a temporary directory, signs ad hoc, verifies the signature, performs two repetitions, writes `results.json`, checks stable outcomes and sanitization using only the Python standard library, and removes the temporary executable. No compiled binary is retained in the repository.
