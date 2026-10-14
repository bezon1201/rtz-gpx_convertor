# IP-2A R3 Research Harness Scope Exception

**Status:** Explicitly authorized for IP-2A R3 only.

## Conflict with approved plan

Approved `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` §11 defines IP-2A as decision-record work and excludes code, schemas, fixtures and tests. Its acceptance nevertheless requires reproducible security evidence. The R3 authorization identifies this conflict and grants a narrow exception to preserve a minimal research harness and synthetic cases so an independent reviewer can reproduce the libxml2 evidence.

## Authorized exception

For IP-2A R3 only, the following may be committed under `tests/research/ip2a/`: minimal C/C++ libxml2 security-harness source, project-authored synthetic XML inputs or deterministic generators, local compile/run reproduction scripts, and a research-only README and result manifest. These artifacts are not production parser code, model code, application tests or product interfaces.

The R3 harness may characterize the pinned libxml2 2.15.4 candidate and synthetic inputs only. It must record source release identity/checksum, build configuration, parser options, loader/DOCTYPE policy, input identity, expected/observed result, exit status, sanitized diagnostics, host/compiler, and evidence that the tested executable links the intended candidate library. A system-library fallback is a qualification failure.

## Prohibitions and expiry

- No production parser, route model, application source, production test target or product architecture change.
- No RTZ/GPX schemas, real or user-provided routes, vessel data, vendored dependencies, downloaded source archives or compiled binaries in Git.
- No network activity during harness tests. The pinned source may be downloaded separately for local build only, after which the qualification harness runs offline.
- Do not invoke parser-context operations concurrently from another thread unless upstream documentation establishes that the specific operation is safe. A disposable isolated-worker experiment is research only and cannot become production architecture by implication.
- This exception expires upon completion and review of IP-2A R3. It does not generally amend IP-2A or the approved plan.
- IP-2B, IP-2C, IP-2D, IP-2E, IP-3–IP-7, production implementation and release remain **NOT AUTHORIZED**.

The approved IP-2 plan is intentionally unchanged. The next stage requires separate explicit authorization and review of the R3 results.
