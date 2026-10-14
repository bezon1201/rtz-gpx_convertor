# IP-2A R4 FileReference Probe

Research-only Swift/Foundation/POSIX probe for the explicitly authorized IP-2A R4 scope exception. It creates a new temporary directory, uses tiny synthetic text files, and removes the directory on exit. It does not read route files, invoke Shortcuts, contact a network, or create a production interface.

## Reproduce

From the repository root, run:

```sh
tests/research/ip2a/r4/run-probe.sh
```

The script uses the installed `swiftc`, compiles an executable into a temporary directory, runs it, prints JSON observations, and removes the executable and temporary data on exit. No dependencies are installed and no binary is retained. Each case's `PASS` means the probe ran and observed the behavior described in its `detail`; it is not an IP-2A qualification verdict.

Observed on one host:

- macOS 26.6.2 (25G83), Darwin arm64
- Apple Swift 6.3.3 / swift-driver 1.148.6
- Apple clang 21.0.0
- macOS SDK 26.5; target `arm64-apple-macosx26.0`
- User ID 501

Exact sanitized run output: [`results.json`](results.json), SHA-256 `50c8077cadd25694ce3d2e081f8b515b94cf8006b27f61a7e49042dd6723d7c7`.

## What the probe establishes

- An open descriptor retained the opened object across rename/move, replacement of the former path, symlink retargeting, and source-path deletion. Reopening the path or link selected the replacement object.
- On this local APFS temporary volume, device/inode and Foundation resource/file identifiers remained equal across rename; generation metadata was available. In-place truncation/write changed bytes visible through the already-open descriptor while device/inode stayed the same.
- `O_NOFOLLOW` refused a symlink path. `fstat`/`lstat` classified a directory and FIFO without opening the FIFO.
- A mode-000 file was denied to this user. This does not cover ACLs, sandbox, privacy controls, or other volumes.
- A plain bookmark followed a rename, reported stale, and resolved to the moved file; resolution after deletion failed. A security-scoped bookmark API call and `startAccessingSecurityScopedResource()` both returned successfully in this **unsandboxed process**, which does not test an app sandbox grant or inter-process capability transfer.
- Reacquiring after a synthetic content mutation yielded different bytes from the preview snapshot, so a caller can detect a mismatch. This probe does not parse RTZ or define the semantic equivalence projection.

## Not tested / limits

No sandboxed app, open-panel selection, Dock drop, Finder Quick Action file object, Shortcuts file input, CLI handoff, Finder alias, security-scoped grant transfer, cancellation, NSFileCoordinator, File Provider/cloud placeholder, ACL, network volume, alternate OS/filesystem, concurrent writer, or output publication was exercised. The command help `shortcuts help run` advertises `--input-path`, which is a path input and is not evidence that a security capability is transported. IP-1D's prior Finder input remained unobservable; its “as arguments” setup yielded zero arguments, and JSON stdin remains only a candidate.

This harness does not prove inode/resource identifiers are persistent across reboot, copy, provider, or volume boundaries; they are same-object hints on this host, not content proofs. No full source digest was calculated or persisted. No production parser, model, CLI, app, Shortcut, dependency, schema, route, or product test target was created.
