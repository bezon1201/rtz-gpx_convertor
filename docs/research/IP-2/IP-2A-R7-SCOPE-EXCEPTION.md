# IP-2A R7 Research Scope Exception

**Authorization:** Project-owner authorization for IP-2A R7, based on reviewed baseline `ef4da7cf51818e079a9eb17c7b2c387d07d163e1`.

## Conflict with the approved IP-2 plan

The approved IP-2 plan §11 normally limits IP-2A to decision records and excludes committed code, fixtures, and tests. R7 requires independent, repeatable evidence about process identity, sandbox entitlements, file-reference authority, and descriptor behavior across Finder/Shortcuts receiver boundaries. Existing R5/R6 evidence does not establish an independently launched receiver's authority or the requested synthetic replacement and failure cases.

## Narrow exception

For IP-2A R7 only, authorization is granted to create minimal disposable research receiver source, project-authored synthetic security inputs, deterministic local reproduction/orchestration scripts, and sanitized result manifests under `tests/research/ip2a/r7/`. The research may build temporary executables outside the repository and run them against synthetic files created in temporary directories. It may configure a separately named, temporary R7 research Shortcut without changing the existing IP-1D, R5, or R6 Shortcuts.

The harness is limited to comparing (A) Shortcuts → Run Shell Script, (B) Shortcuts → independently launched research receiver with explicitly observed signing/entitlements, and (C) the already accepted R5 sandboxed native-picker/inherited-helper baseline. It must distinguish path location from permission and from a proven system-granted or inherited authority. It must not bypass sandbox restrictions when access is unavailable.

## Prohibitions and expiry

- No production parser, route model, CLI, application, product Shortcut, or production test target.
- No RTZ/GPX schemas, real routes, vessel identifiers or coordinates, user-provided operational files, third-party source, vendored dependency, or committed compiled binary.
- Do not alter or delete the existing IP-1D, R5, or R6 Shortcuts; do not change iCloud synchronization settings.
- Keep temporary files, logs, binaries, signatures, and capability/bookmark data outside Git; expose only sanitized synthetic results.
- This exception expires upon completion of IP-2A R7 and grants no authority for IP-2B–IP-2E or any later stage, all of which remain **NOT AUTHORIZED**.
