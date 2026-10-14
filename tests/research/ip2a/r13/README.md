# IP-2A R13 — Signed-child resource-control feasibility

This disposable research probe tests public, nonprivileged process controls with synthetic workloads. It does not parse routes or XML, open files, use schemas, access the network, or transfer file authority. The source is project-authored and has no third-party dependencies. The runner compiles into a temporary directory, applies a local ad-hoc signature with no entitlements, runs four child cases spanning CPU and memory modes twice, validates the sanitized JSON result, and deletes the temporary executable.

## Reproduce

From any directory on a macOS Apple Silicon host with Apple clang, `codesign`, `shasum`, and the system Python 3 standard library available:

```sh
tests/research/ip2a/r13/run-probe.sh
```

An optional first argument selects another result JSON path. The default updates this directory's `results.json`. The runner verifies an ad-hoc signature, rejects an unexpected certificate-backed signer, embeds SHA-256 identities for the source and runner, and performs two identical runs. It fails if stable control outcomes differ, a child is not reaped, an orphan is observed, output is truncated, or an output invariant is violated. Timing and memory measurements can vary and are intentionally excluded from the stable-outcome comparison.

## Child cases and controls

- `cpu`: the parent applies `RLIMIT_CPU` soft 1 second / hard 2 seconds before `exec`; the child executes a deterministic busy loop. This isolates the kernel CPU-limit outcome from the parent watchdog.
- `cpu-watchdog`: the same CPU loop ignores `SIGTERM`; `RLIMIT_CPU` is set to soft 30 / hard 31 seconds and the parent watchdog expires at 2 seconds, requests `SIGTERM`, waits 250 ms, then escalates to `SIGKILL`. This checks parent-enforced lifetime independently of child cooperation.
- `mem-as`: the parent attempts `RLIMIT_AS` (the current SDK aliases `RLIMIT_RSS` to `RLIMIT_AS`) at the child pre-exec virtual size plus 128 MiB. The synthetic child `mmap`s/touches 4 MiB chunks, up to 384 MiB, and reports completion only after all requested bytes are touched.
- `mem-data`: the parent attempts `RLIMIT_DATA` at 256 MiB. The synthetic child extends the anonymous heap with the deprecated `sbrk` API, touching 4 MiB chunks, up to 192 MiB. The runner suppresses only the deprecation warning for this intentional research use. This exercises the resource named by the Darwin manual; it is not a product API recommendation, and a passing setter alone is not enforcement.

Each child emits a startup record and, only after successful completion or a failed allocation, one final synthetic status line. It never emits a success response before completion. The parent records every `setrlimit` result, wait status/signal, explicit watchdog action, `wait4` CPU usage and `ru_maxrss` (bytes per the local Darwin `getrusage(2)` manual), and peak resident/virtual sizes sampled with `proc_pidinfo(PROC_PIDTASKINFO)`. No hostname, username, route content, filename, or coordinate is collected.

## Evidence limits

The experiment is specific to the recorded macOS build, arm64 architecture, compiler, ad-hoc signature, no-entitlement process, and controls shown in `results.json`. `RLIMIT_AS` constrains virtual address-space growth if enforced; that is not by itself a process RSS cap or total-system memory guarantee. `RLIMIT_DATA` applies only to the behavior the OS/allocator actually subjects to that limit. Parent watchdog termination is distinct from a child resource-control signal. Two consistent runs are reproducibility evidence for this setup only.

The IP-1E minimum supported macOS version has not been frozen, so this is **host-specific feasibility**, not a supported-OS qualification. The result does not qualify a parser, schema workload, production cancellation contract, worker architecture, IPC, packaging, file authority, or B03 closure.
