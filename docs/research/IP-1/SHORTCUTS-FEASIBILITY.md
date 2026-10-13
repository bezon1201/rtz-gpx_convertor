# IP-1D — Shortcuts and Finder transport feasibility

**Status: PARTIAL.** This is an empirical observation on one Mac, not a V1 transport selection, supported-macOS claim, or IP-1 PASS. IP-1D was authorized from baseline `85956a226980691eb74cbf9ac56c1258aa90c2c1` on branch `implementation/ip-1d-shortcuts-transport`. The probe and Shortcut were temporary and are not product artifacts.

## Scope and environment

- macOS 26.6.2, build 25G83; Apple Silicon `arm64`.
- Shortcuts version 7.0, build 4711. Finder Quick Actions and the Shortcuts command-line tool are present. Shell: `/bin/zsh`.
- In the Shortcuts Run Shell Script action, observed environment included `PATH` entries for standard system locations and `/opt/homebrew/bin`; `LANG` and `LC_ALL` were unset, and working directory was the user home (redacted). In the separate terminal, `LANG` and `LC_ALL` were `C.UTF-8`. Do not rely on locale or current directory; resolve bundled executable locations explicitly. Environment values and user paths are not retained in full here.
- Temporary inert helper was an arm64 Mach-O executable, mode 755. SHA-256: `5fcb871a1bdcecf81b21bf211ba3529626888ccfea097582a2e25e1b3816fe16`. It reported only argument counts/byte lengths/UTF-8 validity and hex edges, emitted a fixed JSON record, or emitted a fixed diagnostic and chosen exit code. A sleep mode enabled cancellation observation. It did not parse RTZ, access route files, write files, calculate geometry, or use the network.
- Temporary Finder inputs had synthetic names/content, including spaces, apostrophe, semicolon, `$()`, leading `--`, composed/decomposed Unicode, and multiple selection candidates. No operational data was used. Temporary probe executable/source and synthetic files were removed after testing. The temporary Shortcut remains in the Shortcuts library: its Delete confirmation stated removal would propagate to all iCloud devices, so that cross-device deletion was not confirmed. It is not a product Shortcut and is not part of this repository.

## Observations

1. **Shortcuts → stdin:** A Shortcuts Text action passed its text to Run Shell Script configured “to stdin.” The helper measured 51 UTF-8 bytes and reported valid UTF-8. The byte prefix/suffix preserved the synthetic apostrophe, semicolon, `$()`, composed `é`, decomposed `e` plus combining acute, and `Ω`. No shell evaluation was observed. The successful action exposed the helper’s JSON stdout as a result.
2. **Bounded larger stdin:** A 262,144-byte ASCII payload arrived with exactly 262,144 bytes, valid UTF-8, and expected edge bytes. The helper’s small JSON response appeared in the Shortcuts editor. This establishes only this payload size and local setup, not a maximum or arbitrary structured-response limit.
3. **Argument mode:** The same Text-to-Shell Script standalone run configured “as arguments” reported `argc=0`. Retrying did not change the result. Therefore this setup did not qualify Shortcuts argument transport. It is not evidence that all Shortcuts argument pathways are empty; treat argv transport as unqualified.
4. **Nonzero/error:** The helper emitted a fixed stdout JSON response, a fixed stderr diagnostic, and exited 7. Shortcuts displayed an error alert containing the stderr marker and returned to the editor with an error indicator. A separate numeric exit code was not exposed in the observed alert. Detailed stdout/error mapping and code-to-message policy remain unqualified.
5. **Cancellation:** Starting the 60-second sleep action changed the toolbar Run control to Stop. Pressing Stop ended the run and returned to the editor; no completion result was shown. Timing guarantees, child-process termination semantics, and whether cancellation leaves temporary output were not qualified; the helper wrote no output files.
6. **Finder Quick Action:** The temporary Shortcut was visible under Finder → Quick Actions and was invoked on one selected synthetic file whose displayed name contained spaces and shell metacharacters. Shortcuts' run count advanced, confirming invocation. The editor continued to show its prior result and did not expose the Quick Action's new input/result; consequently the actual received file representation, path bytes, input content, identity continuity, and whether a temporary copy was used are **unknown**. Finder file transport is not qualified.
7. **Terminal baseline:** Direct invocation with five discrete synthetic arguments (including spaces, quote/apostrophe, semicolon, literal `$()`, leading dash, and Unicode) reported five arguments with the expected UTF-8 bytes. Direct UTF-8 stdin and a deliberate exit-7 stdout/stderr case also behaved as expected. These results do not substitute for Shortcuts parity.
8. **CLI availability:** local `shortcuts help run` documents `--input-path` as repeatable and `--output-path`/`--output-type`; these options were not used to infer Finder Quick Action behavior or to make a runtime contract decision.

## Qualification matrix

| Case | Expected | Actual | Status |
|---|---|---|---|
| Simple local Shortcuts invocation | Starts without Terminal | Shell action ran and returned JSON | Observed on this Mac |
| Structured stdin / UTF-8 | Exact payload bytes, one machine-readable response | 51-byte synthetic UTF-8 text arrived exactly; JSON stdout appeared | Partial pass for tested payload |
| Unicode normalization and shell metacharacters in stdin | Preserve bytes; do not evaluate content | Composed/decomposed Unicode and `' ; $()` survived in byte evidence | Pass for tested stdin payload |
| Large payload | Bounded request accepted or safely rejected | 262,144 bytes arrived intact; no higher limit tested | Partial |
| Shortcuts argv | Discrete values survive intact | `argc=0` for Text action in “as arguments” mode | Not qualified; candidate failed this setup |
| Terminal argv | Each value remains one argument | Five test values arrived as five arguments | Pass for direct terminal only |
| Special-character Finder filename / file reference | One unambiguous local reference, no shell evaluation | Quick Action invoked, but transport output was inaccessible | Not qualified |
| Multiple selected Finder files | Count/order/representation defined | Not tested | Not qualified |
| Nonzero exit and stderr | Actionable safe error; status mapping known | Alert displayed fixed stderr marker; separate numeric status not visible | Partial |
| Empty/malformed request | Deterministic bounded diagnostic and status | Empty invocation yielded zero argv in an earlier no-input run; malformed JSON not tested | Partial / not qualified |
| Cancellation | Stops work safely and leaves no publication | Stop ended sleep probe; no files were produced | Partial; child-process guarantees unqualified |
| Picker, save, overwrite, Reveal, permissions | Native behavior and safe failures | Not tested | Not qualified; IP-7-owned UX checks |
| Offline behavior | Ordinary local transport works with networking disabled | Probe performed locally and contained no network calls; networking was not disabled | No OS-offline claim |
| Environment parity | No hidden cwd/locale/PATH dependency | Shortcuts environment differs from terminal; variables noted above | Risk confirmed; packaging unresolved |

## Candidate interpretation and security boundaries

- **JSON on stdin remains a candidate**, because one text input arrived byte-exactly, including Unicode and shell metacharacters, and a 256 KiB payload was accepted. It is not selected as a final interface: Finder file-reference transport, malformed/empty/bounded behavior, error mapping, and cross-version repetition remain open. Keep stdout reserved for a single structured response and stderr for diagnostics as an IP-5 contract proposal; this probe does not qualify a production error schema.
- **Shortcuts argv is not qualified** by the observed empty argument list. The direct-terminal argv result cannot be generalized to Shortcuts.
- Never construct shell source from a filename or user input. Fixed script text and descriptor/reference-safe APIs remain required. The filename selected in Finder was not shown to be safely transported, so no shell-safety or source-continuity claim follows from that invocation.
- No security-scoped URL, bookmark, alias, provider-backed file, descriptor identity, file replacement race, permission denial, or byte read from a Finder-selected item was tested. IP-2/IP-5/IP-7 must continue to determine acquisition, identity, lifetime and authorization jointly.
- No network was used by the probe, but Wi-Fi/networking was not disabled. This does not prove system-wide or provider-wide offline behavior.

## Closure work and ownership

Before IP-1D can pass, repeat a defined matrix on each candidate minimum/supported macOS version and make the Finder input/result observable without exposing route data. Qualify one and multiple selected local files, exact representation, path quoting, no-input/cancel behavior, stdout/stderr/exit mapping, malformed and over-limit JSON, output bounds, child cancellation, and local offline invocation with network disabled where safe and authorized. Capture evidence with synthetic data and redact account/user paths.

IP-5 owns the stable CLI protocol and explicit process/result mapping. IP-2/IP-5/IP-7 jointly own secure file acquisition and continuity; no IP-1D observation settles that policy. IP-7 owns picker, save, overwrite, Reveal, install and end-to-end Shortcut UX. Minimum OS, security-scoped access, packaging, signing/notarization and File Provider behavior remain unqualified or assigned to IP-1E/IP-7. Do not advance to IP-1E or later without separate authorization.
