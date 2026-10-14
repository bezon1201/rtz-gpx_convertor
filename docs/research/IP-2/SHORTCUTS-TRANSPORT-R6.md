# IP-2A R6 — Shortcuts Transport Diagnostic and Qualification

**Authorization:** IP-2A R6 only; IP-2B and later remain unauthorized. From reviewed baseline `d7ca083a4069641599d281d23ebcfc66155ab395`, on branch `implementation/ip-2a-r6-shortcuts-transport`. **Verdict: PARTIAL.** This is host-specific research evidence; it does not select product transport or authorize IP-2B or implementation.

## Status summary

| Question | Status | Evidence / limitation |
|---|---|---|
| Shortcuts action-library root cause | **UNRESOLVED** | R5 showed an initially empty action pane. In R6, opening an existing action-bearing Shortcut populated the pane; subsequent new/R5 editor states showed 100 actions and Text/Run Shell Script searches returned results. This identifies a UI-state transition, not the internal cause; no permission/configuration cause was established. |
| Shortcuts file carrier | **PARTIAL** | With `Run Shell Script` explicitly bound to `Shortcut Input` and “Pass Input” set to “as arguments”, a Finder invocation delivered one or two POSIX path strings as separate shell arguments. The earlier generic `Input` binding delivered zero arguments in the same probe. The payload itself was not sent as bytes; the receiver opened the locator. |
| Finder Quick Action carrier | **PARTIAL** | The R6 Shortcut appeared under Finder → Quick Actions and ran for one and two selected synthetic files. Exact received type was a list of path strings; the two-file argument order matched Finder’s displayed sorted order in this view. This is one local host/action configuration only. |
| Receiver opens intended regular file | **PARTIAL** | The receiver classified both path arguments as regular files and read the expected, distinct synthetic marker bytes. It did not compare sender and receiver file IDs or establish continuity for a later read. |
| Standalone receiver authority | **BLOCKED** | The shell receiver had no independently verified security-scoped URL/bookmark or other demonstrated permission grant. A successful open through a path does not distinguish an OS-granted capability from incidental process/user access. Do not infer sandbox authority. |
| Cancellation, permission denial, alias/symlink, replacement, provider behavior | **NOT TESTED** | R6 did not attempt these paths. |
| `IP1-B04` | **PARTIAL / OPEN** | The carrier is now observed, but authorization, independent receiver authority, aliases, identity/replacement, reacquisition, and preview-to-export semantic continuity remain unqualified across IP-2A/IP-5/IP-7. |
| `IP1-B03` | **OPEN / PARTIAL / NOT QUALIFIED; unchanged** | R6 supplies no parser-security evidence. |
| `IP-2A R6` / overall IP-1 | **PARTIAL** / **PARTIAL / NOT PASS** | No blocker is closed; no later stage is authorized. |

## Environment and catalog diagnosis

Observed host: macOS 26.6.2, build 25G83, Apple Silicon arm64. Shortcuts was version 7.0, build 4711. The existing empty R5 research draft was preserved. The existing IP-1D iCloud Shortcut was neither edited nor invoked. The pre-existing action-bearing Shortcut opened to warm the catalog was inspected only; it was not run, changed or discussed by private content.

At first, an empty new editor showed the “Add actions from the right” state and its action list was blank. After the action-bearing `Ship Logout` Shortcut was opened and closed without running or editing it, the Shortcuts editor showed populated categories and a list of 100 actions. Searching “Text” and “Run Shell Script” then returned actions. R6 therefore reproduced a transition from an apparently uninitialized/empty pane to a populated action catalog. No Shortcuts reset, library deletion, iCloud setting change, or permission change was made. The user-facing observations do not establish why the initial editor was empty; catalog root cause remains **UNRESOLVED**.

## Probe configuration and method

A uniquely named research Shortcut, **IP-2A R6 Finder Input Carrier Probe 20261014**, was created after the action catalog became usable. Its Details enabled **Use as Quick Action** and **Finder**; Finder exposed it in the selected-file context menu. The Shortcut accepted the displayed “Apps and 18 more” input categories. Its only action was the built-in **Run Shell Script**, with shell `zsh`, input explicitly set to **Shortcut Input**, and **Pass Input: as arguments**. “Run as Administrator” was off.

The temporary receiver recorded argument count, UTF-8 argument bytes, regular-file classification and up to 4 KiB of each file’s contents in a temporary log. It received only project-created synthetic text files, never an RTZ/GPX or user file. The temporary test directory and log are not in Git. After evidence collection, the retained R6 Shortcut action was reduced to reporting only argument count; it no longer opens files or writes a log. The R6 Shortcut remains a research artifact in the Shortcuts library, is not a product Shortcut, and was not exported as a file or committed. No iCloud synchronization setting was changed; its sync behavior follows the existing account configuration. No research source file was committed, so no R6 source-code scope-exception record was required.

Synthetic cases included filenames with spaces, composed `é`, decomposed `e` + combining acute, and unique UTF-8 text payloads. Tests invoked Finder’s Quick Actions menu with one selected file and with two selected Unicode/space-bearing files. R5’s other native picker and sandbox-helper experiments were not repeated.

## Empirical observations

| Case | Received shell input | Receiver observation |
|---|---|---|
| Finder invocation while action input remained generic `Input` | `argc=0` | No file argument reached the receiver. |
| One selected file after explicitly binding `Shortcut Input` | One argument | Argument was a POSIX path string, not a file URL or payload bytes. It contained spaces and a Unicode name. Receiver classified it as a regular file and read the exact synthetic payload. |
| Two selected files after the same binding | Two separate arguments | Finder’s visible list order was preserved for this selection. Each argument named a regular file and each read returned its corresponding unique expected synthetic bytes. Quoting/argument boundaries preserved spaces. |
| Composed/decomposed accent path spellings | Both arguments’ path accent bytes were `65cc81` (decomposed) in the receiver | The Finder UI/URL representations and receiver path string did not preserve the original normalization spelling uniformly. File contents retained their exact bytes. Do not rely on filename normalization as a stable identity. |

The `Run Shell Script` action did not transmit file contents: it received locators, and its process opened the named synthetic files. Matching unique payloads supports that the intended synthetic test files were opened in these runs. It is not a sender/receiver descriptor identity comparison, race test, or proof about any real source. The `argc=0` result with generic `Input` and successful arguments after selecting `Shortcut Input` show that action-variable binding is material to this particular workflow.

## Evidence categories and authority boundary

**Empirical on this host:** the action catalog’s observed transition; Finder menu visibility; one-/two-file cardinality; argument representation and order for the tested view; whitespace and exact synthetic payload reads; UTF-8 path normalization behavior; and the zero-argument generic-binding case.

**Apple-documented setup behavior:** Apple’s Shortcuts guide describes enabling “Use as Quick Action”, enabling Finder, and invoking a Shortcut from Finder; it also notes that Finder may require the shortcut’s accepted input to include Files or Folders. See [Run a shortcut while working on your Mac](https://support.apple.com/en-au/guide/shortcuts-mac/apd163eb9f95/mac). Apple’s action-connection guide describes typed action inputs/outputs, but does not promise that a path string is a security capability; see [Action connections in Shortcuts on Mac](https://support.apple.com/guide/shortcuts-mac/action-connections-apda850ab0e1/mac).

**Not established:** sandbox status of the Run Shell Script execution process; security-scope transfer; the authority represented by a Finder-selected object after the receiver process boundary; aliases or symlinks; path replacement/deletion; permission-denied/cancellation behavior; File Provider/cloud placeholders; maximum selection size; ordering guarantees across views/versions; other macOS/Shortcuts releases; or preview-to-export semantic continuity. This test does not justify a standalone CLI path contract. Treat every received path and its contents as untrusted until the eventual product boundary independently obtains permitted access, securely opens and validates a bounded regular file, and compares the confirmed source/output semantics as required.

## Decision and remaining closure evidence

The current result is **PATH LOCATOR ONLY**. Transport and authority are separate: the tested shortcut conveyed path strings and successful synthetic reads, but no independent permission mechanism was demonstrated. A filename, extension, selected-file menu entry, action invocation, path equality, or successful unsandboxed read is not proof of authority or stable object identity.

| Owner | Remaining question | Closure evidence |
|---|---|---|
| IP-2A | How will the actual receiver acquire and verify authorized access? | Test the signed/sandboxed target configuration, a qualified native reference or explicitly authorized mechanism, descriptor-backed regular-file open, bounded read, file identity and permission denial on the supported OS matrix. |
| IP-5 | What stable local transport carries the selected object across process boundaries? | Reproduce the real candidate process invocation, including spaces/Unicode, lists, errors/cancellation and permission failures. Do not treat this shell probe as a frozen CLI protocol. |
| IP-7 | What is the installed Shortcut/Finder UX and cancellation contract? | Clean-user end-to-end testing of picker and Finder journeys, accepted input kinds, no-input/cancel/errors, accessibility and final output flow. |
| Joint IP-2A/IP-5/IP-7 | Can source continuity and user authority be reacquired for export? | Qualify aliases/symlinks/security-scoped URLs/bookmarks and permission lifecycle; securely reopen and compare output-affecting semantic projection; changed or inconclusive source requires fresh preview/confirmation and invalidates dependent publication consent. |

R6 did not close `IP1-B04`; `IP1-B03` is unchanged. IP-1A schema provenance/rights remain unresolved. Overall IP-1 is **PARTIAL / NOT PASS**. IP-2A R6 is **PARTIAL**. IP-2B–IP-2E, IP-3–IP-7 execution, production parser/model/CLI/app/Shortcut and release remain **NOT AUTHORIZED**. Gate 3 decisions and approved architecture are unchanged. Independent Architect review is next.
