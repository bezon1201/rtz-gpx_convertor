# IP-2A R11 — Joint File-Reference and Secure-Open Policy

**Authorization:** IP-2A R11 documentation and joint policy work for IP1-B04, using existing R4–R8 evidence only. No new runtime probe, app/parser/CLI implementation, product Shortcut, packaging or IP-2B execution is authorized.

**Baseline:** `7109738caf0bad2e8dfed86f4787a4abd090c1ca` (`implementation/ip-2a-r11-file-reference-policy`).

**Disposition:** **B04 = READY FOR FINAL POLICY REVIEW; blocker remains PARTIAL / OPEN.** This record freezes the minimum security policy required by IP-2A. It does not claim the policy has received final independent acceptance, prove product integration, select a specific Finder/Shortcuts transport, or close B04.

## 1. Requirements and evidence basis

The minimum IP-2A policy is an explicit IP-2 plan §11 acceptance item: a jointly reviewed IP-2A/IP-5/IP-7 file-reference policy. IP-2 plan §§3, 9, 11 and 12 require an opaque untrusted reference, secure open, bounded descriptor reads without unsafe reopening, identity/source-continuity handling, fail-closed behavior, and delivery of a reviewed reference policy to later parser work. R9 distinguishes this minimum policy from full Finder/Shortcuts process transport, provider coverage, UX and production preview/export integration, which belong to downstream IP-5/IP-7 qualification jointly with IP-2A.

R4–R8 evidence is one-host and synthetic. It includes: descriptor behavior under rename/move, path replacement, symlink retarget and deletion; same-object in-place mutation; regular-file/type and permission observations; plain bookmark rename/staleness/deletion behavior; a native-picker/inherited-helper case in R5; Finder Quick Action path-locator behavior in R6; and an independently launched sandboxed receiver denied path-only access plus replacement identity change in R7. R8 consolidated this evidence without upgrading partial observations. None proves the complete production capability lifecycle or source-to-preview/export semantics.

## 2. Frozen minimum reference model

`AuthorizedFileReference` is a **conceptual contract label only**, not a proposed production Swift type.

- A path string, file URL string, filename, extension, bookmark bytes, sender identity, or file metadata is a locator or untrusted input; it is not, by itself, proof of authority, identity, or content continuity.
- The receiver must obtain/reacquire permission through a qualified user-selected macOS reference mechanism. Native file selection/reference mechanisms are the leading authority source, but the exact Finder/Shortcuts/helper transport is not selected or qualified.
- A successful unsandboxed `open()` proves only that ordinary process/user permissions allowed that open. It is not a system-granted capability and does not make the sender's path trusted.
- **Authorization, opened-object identity, and content continuity are separate properties.** Authority permits access; descriptor metadata identifies the opened object within evidence limits; validated material semantics establish whether output-affecting source state still matches a prior preview. None substitutes for the others.
- Finder, Shortcuts, CLI, or native picker origin never bypasses secure-open, bounded-read, format, schema, or semantic validation.
- No full RTZ digest is computed or persisted by default. Minimal ephemeral state needed for an active operation is not logged or persisted beyond that operation without separate approval.

## 3. Minimum secure-open sequence

| Step | Frozen policy | R4–R8 support and limit |
|---|---|---|
| 1. Obtain or reacquire authority | Use a qualified native user-selection/reference mechanism; reject path text alone where receiver access is not independently authorized. Reacquire for a later export rather than relying on prior authorization or a token. | R5 observed selected native-picker URLs and successful reads in one sandboxed parent/helper configuration. R6 Finder supplied path locators; R7 independent sandboxed path receiver got `EPERM`. Actual product authority transfer remains unqualified. |
| 2. Resolve the reference | Resolve only under the authorized reference mechanism. Any alias/link resolution is explicit and bounded. Do not recursively traverse arbitrary path chains. | R4 documented API candidates but tested no Finder alias; ordinary path symlink behavior is not equivalent to authorized selected-link resolution. |
| 3. Open the target once | Open one resolved target under the acquired authority. No untrusted path reopen during the read. | R4 observed descriptor reads remain bound to the opened object through rename, path replacement, retarget and deletion. R7 showed that opening the same path after replacement can reach a different object. |
| 4. Verify the opened object | Inspect the opened descriptor; require an acceptable regular file and permitted access. Treat identifiers as local evidence/hints, not universal identity or content proof. | R4 observed regular-file/type and permission outcomes on one host. R5 observed bounded reads and a mode-000 `EACCES` case. Other OS/filesystem/provider semantics remain unqualified. |
| 5. Read within bounds | Read only through that descriptor/authorized handle; enforce the selected byte ceiling during reads. Do not trust path metadata as authority or use a later reopen. | R2/R3 exercised limit+1 detection through synthetic descriptor I/O; R4/R5 demonstrated descriptor-backed reads in limited setups. No production parser integration is claimed. |
| 6. Close and fail safely | Close exactly once on success, error, cancellation and timeout. If authority, object eligibility, identity or continuity is ambiguous, fail closed with a safe actionable result and no partial route/output. | Research callbacks observed exactly-once close and no partial parser success in their cases. Product lifecycle/error behavior remains future IP-2/IP-5/IP-7 evidence. |

Opening the file is not a content freeze: R4 observed same-object in-place mutation. Device/inode, resource identifiers, generation identifiers, path, size and timestamps may provide local evidence or change hints, but none alone proves unchanged route content.

## 4. Alias, symlink and reference-state policy

The policy permits bounded explicit resolution of a user-selected alias or symlink only after the actual OS authority mechanism is qualified. It does not prescribe unconditional rejection of every selected alias/symlink, and it does not allow implicit path traversal. Each resolved target must then be securely opened once and checked through that descriptor. If authority, target, bounded resolution, identity, or replacement resistance cannot be established, reject/fail closed and ask the user to reselect through a supported interaction.

| Category | Current policy | Existing evidence and limit |
|---|---|---|
| Ordinary regular file | **ACCEPT with defined requirements** | Must originate from or be reached through qualified authority; secure-open once, verify descriptor is regular/readable, bounded-read same descriptor, validate. R4/R5 support only one-host synthetic cases, not a product support claim. |
| Finder alias | **CONDITIONALLY SUPPORTED; current behavior UNQUALIFIED** | Alias resolution must be explicit, bounded, authorized and followed by one target open. No Finder alias was tested; Foundation API availability is not authority evidence. |
| Symlink | **CONDITIONALLY SUPPORTED; current behavior UNQUALIFIED** | Distinguish unsafe path-chain traversal from a user-selected system reference. If allowed, resolve explicitly/boundedly under authority, open once, and resist retarget/replacement. R4 only showed ordinary `O_NOFOLLOW` and descriptor behavior; it did not qualify selected-link UX or scope. |
| Stale bookmark/reference | **REJECT until reacquired** | R4 plain bookmark followed a rename while marked stale; deletion failed resolution. Staleness or successful resolution does not prove authority/content continuity. Require a fresh qualified user selection/reference flow. |
| Deleted target | **REJECT** | R4 observed bookmark resolution fail after deletion while an already-open descriptor still referred to its old object. A new operation must obtain a currently accessible target; never silently substitute same-path contents. |
| Provider-backed reference | **UNQUALIFIED; conditional future support only** | No File Provider/hydration/offline-placeholder behavior qualified. Support requires separately tested authority, availability, permissions, identity/replacement, cancellation and provider behavior. Converter must not initiate cloud hydration/network conversion; unavailable content fails clearly. |

These dispositions define failure behavior and qualification conditions. They do not claim the product currently supports aliases, symlinks, bookmarks, or providers.

## 5. Security-scope and bookmark lifecycle

For any future mechanism that uses a security-scoped URL/bookmark:

- Start scoped access only when required and for the shortest operation that needs it. Every successful start must be balanced by stop on success, failure, cancellation and timeout.
- Treat security-scoped URLs and bookmark data as sensitive capability material. Never place them in logs, diagnostics, reports, Shortcut messages intended for display, or persistent storage by default.
- A stale, expired, denied, unresolved or deleted reference requires user-controlled reacquisition. Do not silently fall back to its path.
- Successful bookmark resolution is only resource location/access evidence under the qualified API. It does not prove the resolved file is the same content or semantics shown in an earlier preview.
- No exact bookmark flavor, serialization format, or cross-process transfer is selected by this policy. R5's default-option bookmark observation is limited to its inherited-sandbox helper case and does not qualify an independently launched CLI or Shortcut.

## 6. Replacement, identity and continuity

The following consequences are frozen from R4/R7 evidence:

1. Same path does not mean same object. A replacement at that path can be opened as a different object.
2. An already-open descriptor continues to refer to the opened object through tested rename/path replacement, but an in-place write can change its content.
3. Device/inode, Foundation resource/file identifiers, generation identifiers, size and timestamps are evidence or change hints only, with filesystem/OS limitations. They are not content proofs.
4. Never reacquire for export by blindly reopening a matching pathname. Obtain fresh authority, resolve under the qualified mechanism, open once, validate the descriptor, and reread/revalidate.
5. No full-file source digest is required or used by default. Any exception requires documented technical need, privacy review and explicit approval; schema artifact hashes remain a separate qualification mechanism.

## 7. Preview/export semantic continuity contract

At preview, the system must obtain authorized access, securely open and bounded-read the source, validate it, and construct a deterministic **output-affecting semantic projection** from the validated source plus confirmed transformation parameters. The projection must cover every input that can affect the confirmed output, including ordered route points and names, effective GPX route name or omission, relevant leg/geometry values, mode/selections, explicitly chosen connector geometry and applicable algorithm/configuration revision. It is ephemeral confirmation state, not a source digest and not a navigation decision.

Before export/publication, the system must reacquire authority, securely open again, bounded-reread, revalidate, reconstruct the projection from the fresh validated model and compare it with the projection bound to the confirmed preview.

- If the fresh projection is equivalent and all current authorization/target requirements still hold, continue using that fresh model and retain the existing confirmation only as permitted by the approved confirmation contract.
- If authority is unavailable, the reference is stale/deleted, source semantics differ, or comparison is inconclusive, do not export. Invalidate prior route confirmation and any publication consent bound to the previous output; show a refreshed preview and require affirmative route confirmation and renewed publication consent.
- A path, timestamp, file identifier, bookmark resolution, prior process token or same filename alone cannot establish equivalence. No default full RTZ digest is introduced.

The contract is frozen at the policy level. The exact projection fields/encoding/equality algorithm, authorization transport, confirmation token lifecycle and no-partial-publication behavior require cross-stage implementation design and empirical acceptance. R4–R8 did not test a parsed RTZ preview/export continuity path.

## 8. Ownership boundary

| Owner | Frozen now / required contract | Empirical work still downstream |
|---|---|---|
| IP-2A | Authority is distinct from locator; secure open once; regular-file check; bounded reads from same descriptor; no unsafe reopen; fail closed; identity and fresh-reacquisition requirements; no default digest; minimum semantic-continuity requirement. This minimum joint policy is an IP-2A PASS item. | Candidate parser/OS evidence, exact descriptor/API behavior, and any remaining minimum policy qualification identified at review. |
| IP-5 | Consume the opaque reference contract; never treat path text as authority. | Actual app/helper/CLI transport, capability handoff, serialization, helper discovery, cancellation/error propagation, packaged invocation and output publication integration. |
| IP-7 | User must control selection/reselection and receive clear failure/confirmation prompts. | Native picker/Finder UX, permission prompts/errors, alias/symlink interaction, stale-reference recovery, confirmation lifecycle and provider/offline UX. |
| Joint IP-2A/IP-5/IP-7 | Policy obligations above apply to all entry points. | Capability handoff, supported macOS/provider matrix, selected replacement behavior, and preview/export semantic continuity must be jointly qualified. |

R11 authorizes no empirical downstream work or implementation. Assigning those tests to IP-5/IP-7 does not remove the minimum jointly reviewed policy from IP-2A acceptance.

## 9. B04 closure matrix

| B04 residual | Policy frozen? | Empirical evidence sufficient? | Owner of remaining evidence | Blocks IP-2A PASS? |
|---|---|---|---|---|
| B04-A — authority acquisition | **Yes, minimum rule:** qualified user-selected authority; path alone is insufficient; reacquire before export. Mechanism remains unselected. | **No.** R5 is one picker/inherited-helper configuration; R6/R7 show locator and denied standalone path behavior. | IP-2A/IP-5/IP-7 jointly; actual selection/capability lifecycle in IP-5/IP-7 integration. | **Minimum policy: yes, as an IP-2A acceptance item until independently accepted.** Full production UX evidence is downstream. |
| B04-B — transport/process handoff | **Yes, boundary:** transport must preserve/reacquire authority; locator must not be promoted to capability. | **No.** No complete actual product Shortcut/Finder-to-installed-helper authority transfer. | IP-5 (transport/helper) with IP-2A/IP-7. | **No** for the full product transport workflow; **yes** if the minimum authority policy/interface cannot be reviewed/frozen. |
| B04-C — alias/symlink policy | **Yes, minimum:** no blanket rejection; only explicit, bounded, authorized resolution then one secure target open; otherwise fail closed. | **No.** Finder aliases and user-selected symlink authority/retarget resistance are untested. | IP-2A/IP-5/IP-7 jointly; IP-7 owns interaction, IP-5 handoff, IP-2 secure open. | **Minimum conditional policy: yes, as a required IP-2A policy item until review.** Specific product support claims are downstream. |
| B04-D — replacement/reacquisition | **Yes, minimum:** same path is insufficient; fresh authority and fresh secure read; metadata IDs are not content proof. | **Partial only.** R4/R7 characterize selected local races, not the full app/helper/export lifecycle. | IP-2A policy and IP-5D/IP-7 integration jointly. | **Minimum policy: yes, required by IP-2A.** Full lifecycle test is downstream, but IP-2A must not claim B04 closed without the approved closure evidence. |
| B04-E — semantic preview/export continuity | **Yes, minimum:** deterministic output-affecting projection; fresh revalidation/comparison; mismatch/inconclusive means invalidate route confirmation and dependent publication consent. | **No.** No RTZ model/preview/export semantic comparison tested. | IP-2A/IP-5D/IP-7 jointly; IP-3/IP-4 supply transformation/output-affecting semantics. | **Yes**, the minimum joint policy is expressly required for IP-2A PASS. Full production behavior also blocks downstream acceptance. |
| B04-F — OS/provider coverage | **Yes, boundary:** no support claim without target evidence; unavailable provider content fails safely; no converter-initiated cloud/network conversion. | **No.** One-host local synthetic evidence only; no File Provider matrix. | IP-1E/IP-5/IP-7 with IP-2A for secure-open behavior. | **No** for full provider matrix if it is downstream; **yes** for any IP-2A candidate-OS evidence explicitly required by its plan and for any claimed provider support. |

### IP-2A PASS interpretation

The policy text is now frozen for final review, and full Finder/Shortcuts/helper/provider/UX integration remains properly assigned downstream. However, the approved IP-2 plan §11 requires this minimum policy to be jointly reviewed before IP-2A PASS. R11 has not received independent final acceptance; therefore B04 remains **PARTIAL / OPEN**, IP-2A remains **PARTIAL / INCOMPLETE**, and IP-2B remains **BLOCKED / NOT AUTHORIZED**. R11 does not shift mandatory policy acceptance downstream or treat incomplete empirical integration as policy closure.

## 10. Scope and handoff

R11 uses existing R4–R8 evidence only. No Finder, Shortcuts, native picker, sandbox, or other probe was rerun. No harness, test, schema, fixture, dependency, code, CLI, app, Shortcut, package or runtime artifact was created or modified. `git diff --check`, documentation link checks, blocker-status reconciliation and historical-reference review are required before commit. Stop for independent Architect review; no downstream integration is authorized.
