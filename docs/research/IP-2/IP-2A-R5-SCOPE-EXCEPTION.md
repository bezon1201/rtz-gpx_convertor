# IP-2A R5 Research Probe Scope Exception

**Status:** Explicitly authorized for IP-2A R5 only.

## Conflict and purpose

Approved `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` §11 limits IP-2A to decision records and excludes committed code, fixtures, and tests. The R5 authorization expressly permits a minimal research-only native Swift sender/receiver probe and, where technically necessary, a temporary sandboxed target. This exception is necessary to observe actual Finder/Shortcuts/native-picker process inputs and determine whether file access authority reaches a receiving process; documentation and the earlier unsandboxed R4 probe cannot establish those facts.

## Narrow exception

For IP-2A R5 only, minimal research source, local reproduction scripts, synthetic files/results and a research README may be committed only under `tests/research/ip2a/r5/`. A disposable local sandboxed native app/helper may be built and signed ad hoc outside Git solely to qualify the authorized synthetic file flow. All test data must be synthetic and temporary. The existing iCloud-synced IP-1D Shortcut must not be edited, replaced, renamed, or deleted. Any newly created temporary Shortcut must have a unique R5 research name and must not collide with an existing item.

## Exclusions and stop conditions

This exception does not authorize:

- production parser/model/CLI/app/Shortcut targets, product interfaces, or product architecture changes;
- real RTZ/GPX files, operational coordinates, schemas, third-party sources, vendored dependencies, or committed binaries;
- persistent security-scoped bookmarks or product capability storage;
- modifying/deleting the existing iCloud-synced Shortcut, or deleting any temporary Shortcut where deletion would propagate to iCloud devices without a separate explicit authorization;
- IP-2B–IP-2E or any later stage.

Do not claim sandbox qualification from an unsandboxed process. If the required signing, entitlement, interactive input, or UI behavior cannot be obtained and observed, mark the relevant case **BLOCKED** or **NOT TESTED**; do not simulate user action or substitute weaker evidence. The exception expires upon completion of IP-2A R5 and does not generally amend IP-2 §11.
