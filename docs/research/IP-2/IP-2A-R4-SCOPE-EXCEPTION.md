# IP-2A R4 Research Probe Scope Exception

**Status:** Explicitly authorized for IP-2A R4 only.

## Conflict and purpose

The approved `docs/implementation/IP-2-SAFE-INPUT-MODEL-PARSER-PLAN.md` §11 limits IP-2A to decision records and excludes committed code, fixtures, and tests. The R4 authorization specifically permits a minimal reproducible research probe because independent review of macOS file-reference lifecycle, descriptor identity, path replacement, and preview/export continuity requires empirical evidence that documentation alone cannot establish.

## Narrow exception

For IP-2A R4 only, this exception authorizes minimal research-only probe source and reproduction instructions/results under `tests/research/ip2a/r4/`, using synthetic temporary files and synthetic byte payloads. It permits only local compilation and execution of that probe. The artifacts must remain outside production targets and must not implement the production parser boundary.

## Explicit exclusions

This exception does not authorize:

- production parser, route model, input loader, CLI, application, or product Shortcut code;
- RTZ/GPX schemas, real routes, operational coordinates, or user-provided route data;
- vendored or downloaded dependencies, compiled binaries, or production test targets;
- persistent bookmark storage or any modification/deletion of the existing iCloud Shortcut;
- IP-2B–IP-2E, IP-3–IP-7, or any later execution.

The exception expires upon completion of IP-2A R4. It does not amend the approved IP-2 plan generally. IP-2B–IP-2E remain **NOT AUTHORIZED**.
