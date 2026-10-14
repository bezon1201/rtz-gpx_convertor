# IP-2A R13 — Research Scope Exception

**Authorization:** project-owner instruction in “Gate 4 — IP-2A R13 Signed-Child Resource-Control Feasibility,” based on reviewed commit `28ed59ce0fee7e7c0555beaa5de2fa188fb5f6bf`.

The approved IP-2 plan §11 normally limits IP-2A to decision records and excludes committed code, fixtures, and tests. R13 is an explicit, one-time exception to that boundary so the owner and independent Architect can reproduce a narrowly scoped assessment of whether public, nonprivileged macOS process controls provide CPU/lifetime and memory containment for a disposable child.

This exception permits only minimal research source, a local runner, a research README, and sanitized results manifest under `tests/research/ip2a/r13/`. Inputs may exercise deterministic synthetic CPU-bound and anonymous-memory-growth behavior only. No binaries may be committed.

The exception expressly prohibits:

- production parser, route model, worker, IPC, app, CLI, or Shortcut implementation;
- RTZ/GPX parsing, schema validation, route data, or file-authority transfer;
- third-party dependencies, vendored source, or committed compiled artifacts;
- claims of parser qualification, supported macOS matrix, production cancellation behavior, or B03 closure from this probe.

The exception expires when IP-2A R13 is complete. IP-2B and all later execution remain **NOT AUTHORIZED** unless separately authorized. A favorable result does not select production worker architecture.
