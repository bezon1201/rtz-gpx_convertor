# IP-2A R7 — Independent Receiver Authority

**Authorization:** IP-2A R7 research and decision work only, from baseline `ef4da7cf51818e079a9eb17c7b2c387d07d163e1`. The scope exception is recorded in [`IP-2A-R7-SCOPE-EXCEPTION.md`](IP-2A-R7-SCOPE-EXCEPTION.md). **Verdict: PARTIAL.** No production transport or product architecture is selected.

## Question and decision boundary

R7 asks whether a process launched independently from Finder/Shortcuts can treat a supplied path as sufficient authority to read a selected file, and compares that boundary with the R5 native-picker/inherited-helper experiment. A path is only a locator. A successful ordinary `open()` is not evidence of a system grant. This is one-host research with synthetic local files and does not establish production behavior.

## Configurations and observations

| Configuration | Empirical result | Authority classification | Limits |
|---|---|---|---|
| **A — Shortcuts → Run Shell Script** | A no-input run in the Shortcuts editor showed a `/bin/zsh` process, uid 501, and its process identifiers. `launchctl procinfo` was unavailable or denied to this non-root probe. A file-argument run could not be observed conclusively: `shortcuts run --input-path` hung and was cancelled; the Finder Quick Action invocation did not yield a reliable result in the editor. A separately named R7 research Shortcut was configured as a Finder Quick Action, without changing existing IP-1D/R5/R6 Shortcuts. | **UNKNOWN.** No successful Shortcut file read or sandbox grant was demonstrated. | Shortcut input was configured as arguments, but configuration is not evidence of transfer. This does not qualify Shortcuts sandbox state, security scope, file cardinality, or cancellation behavior. |
| **B — independently launched, sandboxed receiver** | A minimal arm64 receiver was built with Swift 6.3.3, placed in an app bundle, ad-hoc signed, and verified with `codesign --verify --deep --strict`. Entitlements were `com.apple.security.app-sandbox=true`, with no user-selected-read-only or inherit entitlement. Its process reported `appSandbox=1`. Both readable path arguments failed `open()` with `EPERM`. | **No path-derived authority.** This is direct evidence that these path strings did not grant the sandboxed receiver access in this configuration. | One macOS host; ad-hoc signing; no Finder/Shortcuts launch of this receiver and no user-selected-file capability was conveyed. Not a Developer ID/notarized test. |
| **Ordinary filesystem comparison** | A separately launched, unsandboxed, ad-hoc-signed receiver read two synthetic files with spaces/Unicode (30 and 28 bytes); descriptor identity matched the path object at open. A mode-000 file failed with `EACCES`. | **Ordinary filesystem/user permissions only.** Read success is not a system-granted selected-file entitlement. | Comparison only; not a candidate authority mechanism. |
| **C — native picker → inherited-sandbox helper** | R7 relies on the accepted R5 evidence; it was not repeated. R5 observed a sandboxed native picker returning selected URLs and a nested helper with inherited sandbox access reading selected files in that exact parent-child setup. | **Demonstrated inherited sandbox access in R5's specific process tree.** | Does not establish an independently launched Shortcut receiver's authority or a finalized product transport. See [`FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md`](FINDER-SHORTCUTS-TRANSPORT-QUALIFICATION.md). |

The first direct sandbox execution probe crashed because its executable lacked bundle identifier metadata. The harness was corrected to run from an app bundle with `Info.plist`; the final run above completed and verified its signature. This correction does not change the authority result.

## Synthetic matrix

The reproducible command is `./tests/research/ip2a/r7/run-matrix.sh` from the repository root. It compiles temporary receivers, applies the explicit signing/entitlement configurations, creates project-authored temporary text inputs, runs the cases below, and removes its scratch directory on exit. Set `KEEP_SCRATCH=1` only for a coordinated manual carrier check and remove that synthetic scratch directory afterward. No binary or fixture data is committed. Sanitized outcomes are in [`../../../tests/research/ip2a/r7/results.json`](../../../tests/research/ip2a/r7/results.json).

| Case | Observed outcome |
|---|---|
| Readable regular file | Sandboxed independent receiver: `EPERM`; ordinary receiver: bounded read succeeded. |
| Permission denied | mode-000 synthetic file: ordinary receiver got `EACCES`. |
| Spaces/Unicode and multiple files | Two distinct synthetic files were received as distinct arguments by the matrix receiver and read as 30/28 bytes; no Finder authority inference follows. |
| Deleted before receiver open | `ENOENT`. |
| Deterministic replacement before open | Original object was moved aside and a replacement created at the original path. Device/inode identity changed; receiver opened the replacement and its descriptor did not match the original identity. |
| Symlink retarget before open | `O_NOFOLLOW` rejected the link with `ELOOP`. This is harness behavior, not a final product symlink policy. |
| Non-regular file | FIFO opened nonblocking, then rejected after `fstat` classification. |
| Cancellation before open | Gated receiver was terminated before gate release; exit 143; open was not reached. This does not qualify in-read or CPU-bound cancellation. |
| Cleanup after failure | Runner's exit trap removes its temporary tree; the committed run completed with the default cleanup path. |

The receiver opens once with `O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK`, checks descriptor metadata using `fstat`, accepts only regular files up to 4,096 bytes, reads at most 4,097 bytes, and closes descriptors. These are harness safeguards only. No real route, RTZ/GPX file, schema, user file, or private coordinate was used.

## Option comparison

| Option | Evidence and assessment | R7 disposition |
|---|---|---|
| **A — Direct Shortcuts → CLI** | Simple launch path and Finder integration are plausible. R6 demonstrated path-locator delivery for a configured Finder Quick Action, but R7 did not prove that Run Shell Script receives usable file authority. Paths alone cannot cross a sandbox boundary. Installer discovery, authority, permissions, cancellation, and supported-OS behavior remain unqualified. | **PARTIAL / NOT QUALIFIED.** Do not treat a CLI path argument as authorization. |
| **B — Native app/picker → bundled helper** | R5 experimentally demonstrated native picker access and a helper inheriting the selected app's sandbox in one parent-child configuration. The native app can retain the selected URL/scope and perform descriptor-backed reads. R7's independently launched sandboxed receiver was denied. Packaging, scope lifecycle, helper signing, replacement handling and OS coverage still require qualification. | **Strongest candidate for further qualification; not selected or implemented.** Keep the helper within the qualified picker-launched parent process tree unless future evidence supports another mechanism. |
| **C — Hybrid Shortcut launches native app** | Could preserve Shortcut/Dock/keyboard launch options while routing selection through a native picker. It may reuse B's authority boundary. No complete Shortcut-to-app file and authority handoff was empirically demonstrated. | **Technically plausible, unqualified.** Requires IP-5/IP-7 end-to-end evidence. |

**Recommendation for architectural review:** carry B, optionally launched through C, as the leading candidate for future qualification. This is not an architecture selection and does not authorize implementation. Do not rely on independently launched path-based CLI access as a grant.

## Security and continuity interpretation

- `FileReference`, URLs, path strings, names and arguments remain untrusted until the receiving component obtains permitted access, securely opens the source, verifies the opened descriptor and validates bounded content.
- R7 resolves one narrow question: a sandboxed independent receiver without selected-file entitlement did not gain access merely from path arguments; ordinary unsandboxed reads reflected ordinary permissions. It does not qualify aliases, security-scoped URLs/bookmarks transported from Shortcuts, provider placeholders, ACLs, or persistent capability behavior.
- The deterministic replacement demonstrates that reopening the same path can select another object. Descriptor identity at each open is required, but it does not itself establish route-content continuity or immutable content.
- R5's inherited helper access is specific to its picker-parent/child relationship. It is not transferable evidence for a standalone CLI.
- Cancellation was tested only before the receiver opened the file. In-read, parser CPU-bound, process crash and cleanup deadlines remain open.
- The `O_NOFOLLOW` test rejects a symlink in this harness only. Final alias and symlink behavior remains jointly owned by IP-2A, IP-5 and IP-7.

## Cross-stage disposition

`IP1-B04` remains **PARTIAL / OPEN**. R7 narrows standalone path authority and proves deterministic replacement can change the opened object, but it does not close reference transport, aliases/security scope, permission lifecycle, export-time reacquisition, or semantic preview/export continuity. IP-2A/IP-5/IP-7 must jointly qualify those behaviors on supported macOS configurations.

`IP1-B03` remains **OPEN / PARTIAL / NOT QUALIFIED**, unchanged. IP-1A provenance and rights blockers remain unresolved; overall IP-1 remains **PARTIAL / NOT PASS**. IP-2B–IP-2E, production parser/CLI/app/Shortcut and release remain **NOT AUTHORIZED**. IP-2B readiness remains **BLOCKED** by existing upstream blockers, including B03 and B04. No Gate 3 decision changed.

## Reproduction and result provenance

Run `./tests/research/ip2a/r7/run-matrix.sh` on a compatible Apple Silicon macOS host. The recorded run used macOS 26.6.2 build 25G83, arm64, Swift 6.3.3, Apple clang 21.0.0, uid 501. The sandbox receiver app identifier was `org.example.rtzgpx.ip2a-r7-independent-receiver`; it was ad-hoc signed, bundle verification succeeded, and its only entitlement was `com.apple.security.app-sandbox=true`. The ordinary comparison receiver was separately ad-hoc signed without sandbox entitlement. `launchctl procinfo` required root on this host, so no sandbox conclusion is drawn from that command for the Shortcut shell process.

The result manifest contains only sanitized case outcomes, no scratch paths, object identifiers, source digests, bookmark/capability bytes, or payload contents. The evidence is host-specific, synthetic, and not a security certification.
