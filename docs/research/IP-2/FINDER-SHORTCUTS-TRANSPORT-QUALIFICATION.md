# Finder / Shortcuts File-Authority Transport Qualification

## Historical IP-2A R6 update (2026-10-14)

**Verdict: PARTIAL.** The Shortcuts action catalog became populated after an existing action-bearing Shortcut was opened, but the internal cause of the initial empty pane is not established. A local R6 research Shortcut was exposed in Finder Quick Actions. With its shell action explicitly bound to Shortcut Input and configured to pass input as arguments, Finder delivered one or two POSIX path strings; the receiver opened the synthetic regular files and matched their unique contents. A generic `Input` binding first produced zero arguments. Finder therefore supplies a **PATH LOCATOR ONLY** in this tested setup. No independent security-scoped authority, sandbox grant, identity continuity, cancellation/permission behavior, or product transport was qualified.

The complete method, observations and limits are in [`SHORTCUTS-TRANSPORT-R6.md`](SHORTCUTS-TRANSPORT-R6.md). The retained research Shortcut's receiver was reduced after testing so it no longer reads files or writes logs. No research source, exception record, real route, fixture, executable, schema, dependency, product Shortcut, or runtime artifact was committed. The existing IP-1D Shortcut and empty R5 draft were preserved.

**Disposition:** action-library root cause **UNRESOLVED**; Shortcuts carrier **PARTIAL**; Finder Quick Action carrier **PARTIAL**; standalone receiver authority **BLOCKED**; `IP1-B04` **PARTIAL / OPEN**; `IP1-B03` **OPEN / PARTIAL / NOT QUALIFIED, unchanged**; IP-1 overall **PARTIAL / NOT PASS**. Gate 3 remains **PASS / ARCHITECT ACCEPTED**; Gate 4 remains stage-specific. IP-2B–IP-2E, production work and release remain **NOT AUTHORIZED**.

## Current IP-2A R7 update (2026-10-14)

**Verdict: PARTIAL.** R7 distinguished process authority from a path locator. A separately launched sandboxed receiver with only `com.apple.security.app-sandbox=true` received two readable synthetic file paths and was denied both with `EPERM`; no selected-file authority was conveyed. An ordinary unsandboxed comparison receiver read synthetic files when ordinary user permissions allowed and failed a mode-000 file with `EACCES`; those successful opens are not system grants. The deterministic replacement case showed that the same pathname resolved to a different device/inode object, and the receiver's descriptor did not match the original identity.

The Shortcuts shell action ran without input and exposed `/bin/zsh`, uid and process identifiers; `launchctl procinfo` was unavailable or denied to the non-root probe. File-argument invocation did not produce a reliable observable result, so Shortcuts file authority remains **UNKNOWN / NOT QUALIFIED**. R5 native-picker/inherited-helper evidence remains a separate, historically demonstrated process-tree configuration and was not repeated. Detailed method, constraints and sanitized results: [`INDEPENDENT-RECEIVER-AUTHORITY-R7.md`](INDEPENDENT-RECEIVER-AUTHORITY-R7.md).

**Current disposition:** Shortcuts carrier **PARTIAL / NOT QUALIFIED**; standalone sandboxed path authority **BLOCKED**; ordinary path read **ORDINARY PERMISSIONS ONLY**; R5 picker/inherited helper **PARTIAL**; `IP1-B04` **PARTIAL / OPEN**; `IP1-B03` **OPEN / PARTIAL / NOT QUALIFIED, unchanged**; IP-1 overall **PARTIAL / NOT PASS**. IP-2B–IP-2E, production work and release remain **NOT AUTHORIZED**.

## Historical IP-2A R5 qualification

**Authorization:** IP-2A R5 only, from reviewed baseline `7314b123723f6253544917b324529cfe767cd580`. The narrowly scoped exception is recorded in [`IP-2A-R5-SCOPE-EXCEPTION.md`](IP-2A-R5-SCOPE-EXCEPTION.md). **Verdict: PARTIAL.** Research evidence only; no production transport or API is selected.

## R5 status summary (historical snapshot)

| Boundary | Status | R5 disposition |
|---|---|---|
| Finder Quick Action carrier | **BLOCKED** | No R5 Quick Action was configured or invoked. Prior IP-1D Finder invocation did not expose its input representation and remains only historical evidence. |
| Shortcuts carrier | **BLOCKED** | The Shortcuts app exposed no actions in the action library UI for searches including “Run Shell Script”, “shell”, and “Text”; no transport could be constructed or tested. A unique, empty R5 draft exists; it was not run or configured as a Quick Action. |
| Native picker authority | **PARTIAL** | On one macOS 26.6.2 arm64 host, a sandboxed app's real `NSOpenPanel` returned two Unicode/space-bearing file URLs; bounded descriptor reads matched both synthetic payloads. A mode-000 selected file returned a URL but failed open with `EACCES`. |
| Cross-process scope transfer | **PARTIAL** | A sandboxed child helper with inherited sandbox entitlement read the same selected objects and payloads using both a path argument and Foundation bookmark data created with default options. This was a specific parent-child inherited-sandbox setup; bookmark scope flavor was not independently identified, and it does not qualify an independently launched CLI or Shortcut. |
| Export-time reacquisition | **PARTIAL** | A same-process URL reopen two seconds after the explicit scope start/stop interval returned the same object and bytes on these local temporary files. No RTZ preview, semantic comparison, export, process restart, Finder/Shortcut transport or output consent was tested. |
| `IP1-B04` | **PARTIAL / OPEN** | The native picker/helper evidence narrows some cases but does not satisfy its cross-stage carrier, aliases, identity/replacement and preview/export closure criteria. |
| `IP-2A R5` | **PARTIAL** | Native picker evidence is useful; the Finder and Shortcuts objectives remain blocked or untested. |
| `IP-2B` readiness | **BLOCKED** | R5 does not close `IP1-B04`; `IP1-B03` remains open/not qualified and IP-1A provenance/rights blockers remain. No later stage is authorized. |

## Environment and reproducibility

The host was macOS 26.6.2 build 25G83, arm64, Apple Swift 6.3.3 (swift-driver 1.148.6), Apple clang 21.0.0, SDK 26.5, target `arm64-apple-macosx26.0`. The temporary app and helper were compiled with `swiftc -O`; the app linked AppKit and Security and the receiver linked Security. Both were ad-hoc signed. `codesign --verify --deep --strict` reported the app valid on disk and satisfying its designated requirement.

The app entitlements were `com.apple.security.app-sandbox=true` and `com.apple.security.files.user-selected.read-only=true`. The nested receiver had `com.apple.security.app-sandbox=true` and `com.apple.security.inherit=true`. The receiver also reported the sandbox entitlement from its own process. This was an ad-hoc signed local experiment, not a Developer ID or notarized artifact.

Run `tests/research/ip2a/r5/run-sandbox-picker.sh` from the repository root on a compatible Apple Silicon Mac. It creates synthetic files, builds/signs a temporary app/helper, opens a real native picker, and removes the temporary directory on exit. The observed inputs and sanitized outcomes are in [`tests/research/ip2a/r5/results.json`](../../../tests/research/ip2a/r5/results.json); reproduction steps and the probe boundary are in its README. Payload SHA-256 values in that manifest identify only project-authored synthetic text. Temporary paths, actual device/inode values, and bookmark/capability bytes are intentionally omitted.

The synthetic cases were: `R5 selection one é.txt` (25 bytes), `R5 selection second é.txt` (28 bytes; decomposed `e` plus combining acute), and `R5 permission denied.txt` (29 bytes, mode `000`). Their exact payload digests are in the result manifest. No RTZ/GPX, route, vessel coordinate, schema, user file or production data was used.

## Observed cases

### Native file picker and sender

The operator navigated the native `NSOpenPanel` to the temporary synthetic folder and selected the two readable files together. The app received two file URLs. Each file opened using `O_RDONLY | O_CLOEXEC | O_NOFOLLOW`, passed `fstat` regular-file and 4,096-byte checks, and matched its exact expected synthetic bytes. `startAccessingSecurityScopedResource()` returned `true` for each selected URL. The app compared descriptor identities internally and emitted only equality results; it did not persist the identity values.

A separate run selected only the mode-000 synthetic file. The picker returned its URL and `startAccessingSecurityScopedResource()` returned `true`, but the descriptor open failed with `EACCES`. The app emitted the denied result and did not launch a helper for that file. Thus a URL and a successful scope-start return are not treated as proof that the requested read succeeded. No general permission-dialog behavior or ACL behavior is established.

### Receiving helper

For each readable selection, the app launched a nested helper through `Process` using an argument array. The path-carrier case sent the selected URL's path plus expected identity and payload. The receiver process reported sandbox entitlement, read through its own descriptor, and observed both same-object identity and payload equality. This demonstrates that path text can locate/read a file in **this** inherited sandbox child process tree after the parent selected it. It does not make a path a capability, and does not show that Finder, Shortcuts, a standalone helper, or a product CLI will deliver or inherit equivalent authority.

The app also passed Foundation bookmark data created with default options from each selected URL to the same helper over stdin. The helper resolved the bookmark, started security-scoped access, and observed the same object and bytes. The experiment did not independently classify the bookmark's scope flavor, test staleness or persistence, transfer it to an independently launched process, or establish that any Shortcut can produce this representation. Bookmark data must remain ephemeral and private; no bookmark bytes were logged or stored.

After the per-file explicit scope start/stop interval ended, the sender waited two seconds and reopened each selected URL in the same process. Both reopens returned the same descriptor identity and expected bytes. This is a narrow local temporary-file observation. It is not a preview-to-export semantic-continuity proof: the source route was not parsed, transformed, or compared, and the read did not cross an app restart or Finder/Shortcuts boundary.

### Finder and Shortcuts

No R5 Finder Quick Action was configured or invoked, so no R5 Finder carrier type, cardinality, encoding, authority, permission, replacement, deletion, or error result is claimed. The prior IP-1D observation that Finder invoked a Quick Action but its actual input was unobservable remains unchanged.

A new Shortcut named **IP-2A R5 Research Finder Input Probe 20261014** was created as an empty research draft. It was not run, shared, configured as a Finder Quick Action, or used to replace the existing IP-1D iCloud Shortcut. In the Shortcuts app, the action library displayed no available actions for searches including “Run Shell Script”, “shell”, and “Text”. Consequently, R5 could not construct any of the requested stdin, argument, file-input, or helper-invocation cases. The existing IP-1D Shortcut was neither modified nor invoked. The empty draft is retained; no deletion was attempted.

R5 does not repeat or upgrade IP-1D's prior results: stdin forwarding of synthetic text worked for that inert setup, “as arguments” produced zero arguments in that setup, and the Finder input remained unobservable. JSON stdin is still not a frozen interface.

## Security interpretation and limits

- Treat any path/URL/string, bookmark bytes, file name, sender identity, extension, or metadata as untrusted until the receiving component obtains permitted access, opens the file securely, verifies regular-file and size limits, and validates content.
- The sender and receiver opened the selected object with `O_NOFOLLOW`, `fstat`, a regular-file check, and a 4,096-byte ceiling; they read at most 4,097 bytes and closed descriptors. Synthetic payloads were 25–29 bytes. The bound and descriptor procedure are properties of this harness only, not product parser qualification.
- `startAccessingSecurityScopedResource()` returning `true` did not make the mode-000 file readable. Access must be tested by the operation, and every successful start must remain balanced on success and failure paths.
- The child helper's path success depended on the exact selected parent and inherited sandbox configuration. No permission or identity conclusion transfers to a separately launched CLI. A path remains a locator and is never sufficient authority by itself.
- Path replacement between selection and helper open, source deletion, aliases, selected symlinks, File Provider/cloud placeholders, cancellation, Shortcut/Finder input, multiple Shortcut files, process crash, supported-OS matrix and user-facing diagnostics were not tested. The probe has code to report native picker cancellation, but no cancellation was performed in the recorded run.
- Do not reopen a path merely because it matches a prior path. For each actual read, obtain qualified authority, open once, verify the descriptor object, perform a bounded read and close. R5 does not select the final alias/symlink policy.
- R5 used no full RTZ digest. Synthetic payload digests in the result manifest are fixture identifiers only; they are not source-route provenance or continuity tokens.

## Cross-stage disposition

IP-2A owns descriptor-backed bounded reads and validation; IP-5 owns serialization, process invocation and transport/error behavior; IP-7 owns native picker/Finder UX and end-to-end confirmation/reacquisition. These stages must jointly qualify actual Finder/Shortcut inputs, independent receiver authority, aliases and security-scoped URLs/bookmarks, permissions, path replacement/deletion, cancellation, supported OS behavior, and preview-to-export semantic comparison before freezing a product contract. Any bookmark/capability must not be logged or persist by default.

`IP1-B04` stays **PARTIAL / OPEN**. `IP1-B03` remains **OPEN / PARTIAL / NOT QUALIFIED** and is unchanged. `IP1-B01/B02` remain unresolved. Overall IP-1 remains **PARTIAL / NOT PASS**. IP-2B–IP-2E, production CLI/app/Shortcut and release remain **NOT AUTHORIZED**. No Gate 3 decision or product architecture is changed.
