# IP-2A R5 file-authority probe

Research-only macOS Swift probe authorized by `docs/research/IP-2/IP-2A-R5-SCOPE-EXCEPTION.md`. It builds a temporary ad-hoc-signed sandboxed `.app` and inherited-sandbox helper, creates small synthetic text files in a temporary directory, opens a real `NSOpenPanel`, then removes the temporary bundle and inputs when the process exits. No route, schema, production target, package, or persistent bookmark is used.

## Reproduce

On an Apple Silicon Mac with the Apple Swift toolchain and macOS SDK installed, run from repository root:

```sh
tests/research/ip2a/r5/run-sandbox-picker.sh
```

Select both readable synthetic files in the native picker to repeat the positive cases. To repeat the mode-000 case, run again and select only `R5 permission denied.txt`. Canceling the picker reports `CANCELLED`. The script is interactive; do not automate or claim a case that was not actually selected. Temporary paths and descriptor identifiers printed by the runner are runtime-only and must not be copied into the repository.

The sender is compiled with `swiftc -O -target arm64-apple-macosx26.0` and linked with AppKit and Security. The receiver is compiled with the same optimization/target and linked with Security. `codesign` applies ad-hoc signatures and the checked-in entitlements, then runs `codesign --verify --deep --strict`. The app has `com.apple.security.app-sandbox=true` and `com.apple.security.files.user-selected.read-only=true`; the receiver has `com.apple.security.app-sandbox=true` and `com.apple.security.inherit=true`. This is a temporary research configuration, not Developer ID signing or notarization.

Each test open uses `O_RDONLY | O_CLOEXEC | O_NOFOLLOW`, verifies the opened descriptor is a regular file, enforces a 4,096-byte size bound, reads at most 4,097 bytes, compares a synthetic expected payload, and closes the descriptor. The receiver is a child process launched with `Process.arguments` as an argument array. It tests a path locator and Foundation bookmark data created with default options from the selected URL; the probe does not independently classify the bookmark's scope flavor. Receiver output records sandbox entitlement, process IDs, descriptor identity equality and payload equality as booleans, never the actual identity value.

## Scope and limits

This probe qualifies only the observed local macOS setup and selected files. It does not exercise Finder Quick Actions, an executed Shortcut, File Provider/cloud files, aliases, selected symlinks, replacement/deletion races between selection and open, another macOS release, product CLI discovery, product confirmation/preview/export, or a persistent bookmark feature. A successful path handoff in this inherited-sandbox process tree does not make path text a capability for an independently launched CLI. See the qualification report for status and interpretation.

The result manifest is `results.json`. It contains only synthetic payload digests and sanitized observations; it omits the temporary folder path, user name, actual device/inode values, and capability/bookmark bytes.
