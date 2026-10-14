# IP-1E — Packaging and deployment decision

**IP-1E verdict: PASS (documentation-level only).** The approved packaging direction, recommended bundle/install path, candidate OS floor, reproducible qualification matrix, clean-user procedure, and remaining blockers are recorded below. This is not a built, signed, notarized, installed, or released package. No OS version is declared supported. IP-1F onward and production implementation remain **NOT AUTHORIZED**.

**Current OS decision (IP-1E R1, 2026-10-15): OS FLOOR NOT QUALIFIED.** Sequoia 15 remains the qualification candidate, with macOS 15.8.1 as the current candidate test image, not an approved or supported minimum. R1's assessment and exact matrix are in [`IP-1E-OS-SUPPORT-FLOOR-DECISION.md`](IP-1E-OS-SUPPORT-FLOOR-DECISION.md). This supersedes the earlier 15.8 patch reference but does not change the documentation-level IP-1E packaging verdict.

**Baseline:** `767e1a1791202969122db8a98f7459a98201cab8`; branch `implementation/ip-1e-packaging-decision`. Research checked 2026-10-13. IP-1D evidence is carried forward without treating its observations as packaging qualification.

## 1. Decision within the approved architecture

Retain G3-010: a Developer ID signed/notarized Apple Silicon `.app` containing a self-contained local Swift CLI, distributed in a signed/notarized and stapled `.dmg`, accompanied by an exported `.shortcut` and user-level install/remove instructions. The Shortcut remains the primary UI. Finder Quick Action reuses that Shortcut. No standalone GUI, `.pkg` installer, updater, daemon, Homebrew, user-installed Python, Xcode, Terminal workflow, or runtime service is introduced.

**Recommended installation location: `~/Applications/RTZ-GPX Converter.app`.** This is the default because it is user-owned and does not ordinarily require administrator access. `/Applications` is not the V1 default: write access can require an administrator or a preconfigured policy, so it cannot guarantee installation by a standard user. An organization may optionally preinstall to `/Applications` under its own policy, but that is not the consumer acceptance path. These are filesystem/permission design conclusions to verify on clean accounts, not a special Apple entitlement or tested result.

The app bundle must travel as one unit. Candidate layout:

```text
RTZ-GPX Converter.app/
  Contents/
    Info.plist
    MacOS/RTZ-GPX Converter       # bundle's principal executable
    Helpers/rtz-gpx-cli           # bundled, self-contained arm64 CLI
```

The helper location follows Apple's documented macOS helper-tool location. A bundled executable can be located through Foundation bundle APIs rather than an absolute developer path. **However, an exported Shortcut runs outside the app bundle:** IP-1D did not qualify Finder's file reference or a stable way for the Shortcut to find and invoke the packaged CLI. Therefore the layout is recommended, while Shortcut-to-helper discovery, executable invocation and input transport remain release blockers owned by IP-5/IP-7. A fixed install path may be evaluated, but must fail clearly if the app is moved or absent and must not interpolate a user-controlled path into shell source. Do not treat JSON stdin as a finalized contract. [Apple bundle placement](https://developer.apple.com/documentation/bundleresources/placing-content-in-a-bundle), [Foundation auxiliary-executable lookup](https://developer.apple.com/documentation/foundation/bundle/url%28forauxiliaryexecutable%3A%29).

| Candidate | Assessment | Decision |
|---|---|---|
| CLI inside `.app` at `Contents/Helpers`, app as container | Keeps CLI with signed app; standard helper location; allows bundle-relative discovery by app code | Preferred; actual launch from Shortcut still unqualified |
| CLI in `Contents/MacOS` as app's principal executable | Conventional executable location, but conflates bundle launch and CLI invocation; direct Finder/Dock launch behavior is untested | Do not prefer without a concrete launch contract |
| CLI sidecar beside app or in a separate directory | App move/update can separate or stale the CLI; discovery can select the wrong copy | Reject for V1 |
| CLI in `Contents/Resources` | Apple classifies this area for resources, not executable code; signature/distribution handling is unsuitable | Reject |
| ZIP instead of DMG | Can carry an app, but ZIP itself cannot be stapled; would complicate the approved offline Gatekeeper flow | Keep as comparison only; retain approved DMG |
| `.pkg`, App Store, standalone binary, or installer framework | Changes the approved distribution/install direction and/or permissions/user workflow | Out of scope; return for architectural review if DMG/app proves infeasible |

The DMG should present the app and a short installation guide. User copies the app into `~/Applications`, imports the supplied `.shortcut`, and enables Finder under Shortcuts/Finder extension settings. Apple documents importing `.shortcut` files by opening or dragging them into Shortcuts, setting a Shortcut as a Quick Action, enabling it in Finder settings, and adding a Shortcut to the Dock. It does not establish automatic or silent registration; V1 instructions must include those user steps. [Import a Shortcut](https://support.apple.com/guide/shortcuts-mac/apd02bffbaac/mac), [Run a Shortcut on Mac](https://support.apple.com/guide/shortcuts-mac/apd163eb9f95/mac).

## 2. Signing, hardened runtime, notarization, and offline launch

### Verified Apple requirements

- Direct distribution outside the Mac App Store uses Developer ID signing for Gatekeeper assessment. Apple issues Developer ID certificates to Apple Developer Program or Enterprise Program members. The Developer ID Application certificate signs the app and executable code; Developer ID Installer is for `.pkg`, which is not selected. Apple's account documentation says certificate creation requires the Account Holder, with cloud-managed certificate access available to appropriately authorized team admins. [Developer ID certificates](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/), [Developer ID overview](https://developer.apple.com/developer-id/).
- Apple's current Developer Program page lists **US$99 per membership year** (local-currency price may differ). Some qualifying nonprofits, accredited educational institutions, and government entities may apply for a waiver; eligibility is not assumed. No project developer account, certificate, or budget has been verified, and no enrollment or purchase was made. [Membership pricing](https://developer.apple.com/programs/whats-included/), [Fee waivers](https://developer.apple.com/help/account/membership/fee-waivers/).
- For notarized direct-distribution software, Apple requires valid signatures for distributed executables, Developer ID identity, Hardened Runtime, secure timestamps, and no `com.apple.security.get-task-allow=true`. Apple describes App Sandbox as optional for direct distribution (it is required for Mac App Store distribution); this plan does not choose a sandbox entitlement model until Shortcuts/Finder reference access is qualified. Sign nested code inside out and sign the enclosing app last; do not rely on `codesign --deep` as the signing strategy. Grant only entitlements justified by verified requirements; Hardened Runtime exceptions are not a substitute for resolving file-access design. [Notarization requirements](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution), [Distribution signing order](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac/), [Hardened Runtime](https://developer.apple.com/documentation/security/hardened-runtime).
- Apple notarization is an online submission/review service, not App Review. The service returns a ticket. Apple accepts DMGs and says stapling the ticket to the distribution enables Gatekeeper to find it without a network connection. For nested distribution, Apple's packaging guide says sign the nested items and notarize the outermost container. The final release workflow must verify the app signature, nested CLI signature, signed DMG, notarization log, stapled ticket, and Gatekeeper behavior after extraction. [Notarization workflow and stapling](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow), [Packaging for distribution](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution).

### Recommended release signing sequence (not executed)

1. Build the app and CLI on the release machine/CI with the selected macOS SDK and deployment target; the target Mac receives no toolchain requirement.
2. Sign each executable, including the CLI, with Developer ID Application identity and secure timestamp; enable Hardened Runtime and only the minimum required entitlements. Validate every signature and architecture.
3. Sign the outer `.app` after its nested code. Do not mutate the bundle after signing.
4. Create and sign the final DMG. Submit the outer distribution to Apple's notary service; inspect the full notary log, staple the returned ticket to the DMG, and verify the staple.
5. On a clean Mac with networking disabled after the package is obtained, mount the stapled DMG, copy the app to `~/Applications`, import the local Shortcut, and test Gatekeeper first launch and a synthetic local conversion. If Gatekeeper or launch requires a network check despite a valid staple, stop; do not tell users to bypass Gatekeeper. Determine whether the app also needs its own stapled ticket or a changed submission flow through documented qualification and review.

The online build/release submission is separate from V1's offline runtime. No runtime network endpoint, update checker, schema fetch, or service is permitted. Signing credentials remain in the release account/keychain or controlled CI secret store; never in Git, the Shortcut, the app's resources, or logs. Membership cost, renewals, certificate expiry/revocation, account-holder availability, secure key custody, and release-service connectivity are explicit external prerequisites.

## 3. Candidate macOS minimum and qualification matrix

**Current status: OS FLOOR NOT QUALIFIED.** Sequoia 15 remains the preferred qualification candidate, but the app/Shortcut/API inventory and full clean-user matrix have not been executed. As of 2026-10-15, Apple's security-release list names Sequoia 15.8.1, Tahoe 26.7.1, and Golden Gate 27.0.1 (all dated 2026-09-28); Sonoma 14.8.9 is dated 2026-08-06. These dates inform candidate comparison but do not establish product compatibility or Apple's future maintenance commitment. R1's [OS-floor decision](IP-1E-OS-SUPPORT-FLOOR-DECISION.md) records the evidence, limitations, and qualification gates. The IP-1D observations on Tahoe 26.6.2 were a temporary Shortcut transport probe only, not package or OS-compatibility evidence. [Apple security releases](https://support.apple.com/en-us/100100), [Sequoia 15.8.1](https://support.apple.com/en-us/149229), [Tahoe 26.7.1](https://support.apple.com/en-us/149228), [Golden Gate 27 updates](https://support.apple.com/en-us/127257).

| Candidate OS/build to test | Role | Evidence today | Release condition |
|---|---|---|---|
| macOS Sequoia 15.8.1, Apple Silicon | Proposed minimum qualification target | Not tested for this package | Full clean-user procedure passes on M1 oldest-class representative; test latest 15.x security patch at release |
| macOS Tahoe 26.7.1, Apple Silicon | Previous-major compatibility target | IP-1D/R10–R14 used Tahoe 26.6.2 only for limited research; not package qualification | Full package and Shortcut procedure passes on the matrix hardware |
| macOS Golden Gate 27.0.1, Apple Silicon | Current-major compatibility target | Not tested | Full clean-user procedure passes on the matrix hardware |

Use the exact current product version/build in execution records; the versions above are as-of-2026-10-15 test targets and update to the latest security patch in the same major before qualification/release. Any added macOS release or Apple Silicon hardware family requires qualification. Maintain a support table with exact product version/build, chip family, Shortcut version, package SHA-256, test date and outcome. A version is not supported until this evidence is reviewed. No Intel claim is planned. The exact matrix is defined in `IP-1E-OS-SUPPORT-FLOOR-DECISION.md` §4; no row has passed.

## 4. Clean-user install, update, rollback, removal acceptance

Use a newly created standard local account with no administrator privileges, no previous app or Shortcut, no user-installed Python/Homebrew/Xcode, and no existing app configuration. Use only synthetic RTZ-like input; never use a real voyage file. Stage a downloaded/quarantined final package while online if needed, then disable networking before first launch to test the stapled-ticket path and offline runtime. Record the exact macOS build and preserve evidence without account names or personal paths.

1. Verify the delivered DMG signature, notarization status/log reference and stapled ticket using release-side verification records. Mount the DMG in Finder; install by copying the app into `~/Applications`. Confirm no admin prompt and no command-line interaction.
2. Import the provided `.shortcut` from the DMG by a documented Finder/Shortcuts action. Enable the Shortcut for Finder/Quick Actions using the user's macOS settings; show the expected user-controlled permissions. Add the Shortcut to the Dock and configure its keyboard shortcut as described. Confirm all launch paths, with Finder input passing the selected file without a second picker. The last condition remains blocked by IP-1D until its file-reference and identity behavior are observable and qualified.
3. With networking disabled, launch from Shortcuts, Dock and keyboard; invoke the Finder Quick Action on one synthetic local file. Confirm that the installed CLI is found after installation and after an app relaunch; there is no Terminal, Homebrew, Python, Xcode, service, or external request. Confirm stdout/stderr/result handling, cancellation, permissions, output save/open-in-Finder behavior, and actionable failure cases. Do not infer this from the IP-1D stdin probe.
4. Install a newer signed test build over the prior build using the documented user-level process. Confirm protocol/Shortcut version compatibility, local operation and preservation of all source/output files. Keep the previous qualified DMG/app for manual rollback; restore it and repeat a synthetic local smoke flow. No automatic updater or migration runs.
5. Uninstall only by user actions: disable the Finder Quick Action if needed, remove the imported Shortcut, then move the app bundle to Trash. Verify source RTZ, generated GPX, and unrelated user files remain untouched. No cleanup tool may search for or delete route files. Record whether user-created data or preferences remain; deletion of such files is never implicit.
6. Repeat the full procedure for each matrix row and document installation, update, rollback, shortcut reimport, Finder registration and removal steps from the clean account. Any admin prompt, Gatekeeper bypass request, offline network dependency, broken moved-app path, missing-file access, or route mutation is a failure/blocker.

## 5. Carried blockers and ownership

| Blocker | State / owner | Closure evidence |
|---|---|---|
| Finder input shape, path Unicode/metacharacters, one/multiple selection | IP-1D PARTIAL; IP-5/IP-7 | Observable, repeatable end-to-end transport on each candidate OS; preserve discrete inputs; no shell interpolation |
| File identity, aliases/security-scoped URLs, permissions, reference lifetime, source continuity | Unresolved; jointly IP-2/IP-5/IP-7 | Documented secure acquisition API and descriptor/file-identity/continuity checks, with replacement-race and permission tests |
| Cancellation and error mapping, including child-process termination | IP-1D partial; IP-5/IP-7 | Stable protocol behavior, interruption cleanup, actionable user-visible results; no partial publication |
| Shortcut-to-bundled-CLI discovery after install/move/update | Unresolved; IP-5/IP-7 | Reproducible install path or supported discovery, move/rename failure handling, no developer-specific absolute path |
| Developer ID team, certificate and signing credential custody | Not checked; project owner/release operator | Confirm Account Holder/team access, certificate issuance, renewal and secure signing pipeline; cost decision |
| App/DMG signature, notarization, staple, Gatekeeper offline launch | Not tested; IP-1E documentation now defines test; release owner | Actual artifact verification and clean-user offline launch across matrix |
| Minimum macOS and product support claims | Candidate 15.8; not qualified; IP-1E/IP-7 | Full matrix with exact builds and reviewed pass record; no unsupported inference from docs |
| RTZ/GPX schema rights and legal offline validator | IP-1A remains PARTIAL | Written rights/provenance and reviewed offline schema-validation strategy before any package includes schemas/runtime |
| User-visible permission, save/output and Shortcut installation UX | Not tested; IP-7 | IP-7 acceptance across launch paths; no admin requirement; no source/output route mutation |

No dependency install, package build, signing, notarization, account access, network configuration change, or installation was performed in IP-1E.

## 6. IP-1E acceptance and status

| Approved IP-1E criterion | Result |
|---|---|
| Recommend self-contained app/CLI, install path and bundle layout within G3-010 | PASS — recommendation and alternatives recorded; runtime discovery remains a named downstream blocker |
| Document signing, Hardened Runtime, nested signatures, notarization/stapling and Gatekeeper offline requirements | PASS — verified against current Apple primary documentation; no artifact tested |
| Candidate OS floor and qualification matrix | PASS — documented candidate Sequoia 15 and concrete rows; **OS FLOOR NOT QUALIFIED**, no version supported |
| Define clean-user install/update/rollback/removal acceptance without admin or development tools | PASS — steps and data-preservation checks recorded |
| Carry IP-1D transport/reference/security/cancellation blockers | PASS — retained with owners and closure evidence |
| Account/cost/external prerequisites and release blockers | PASS — recorded; account status not verified and no purchase or signing occurred |

**IP-1E verdict: PASS — documentation-level packaging decision. OS FLOOR: NOT QUALIFIED.** This does not pass IP-1A, IP-1D, IP-1, Gate 4 as a whole, packaging, notarization, OS compatibility, or release. IP-1F and all implementation remain **NOT AUTHORIZED**. See R1 for the minimum-OS qualification recommendation and missing evidence.

## 7. Primary references

- Apple, [Developer ID certificates](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/) and [signing apps for Gatekeeper](https://developer.apple.com/developer-id/).
- Apple, [Apple Developer Program membership and current price](https://developer.apple.com/programs/whats-included/), [fee waiver rules](https://developer.apple.com/help/account/membership/fee-waivers/), and [team roles](https://developer.apple.com/help/account/access/roles).
- Apple, [notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution), [customizing notarization and stapling](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow), [distribution code signing](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac/), [Hardened Runtime](https://developer.apple.com/documentation/security/hardened-runtime), and [packaging for distribution](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution).
- Apple, [placing content in a bundle](https://developer.apple.com/documentation/bundleresources/placing-content-in-a-bundle) and [Foundation bundle executable lookup](https://developer.apple.com/documentation/foundation/bundle/url%28forauxiliaryexecutable%3A%29).
- Apple Support, [importing Shortcuts](https://support.apple.com/guide/shortcuts-mac/apd02bffbaac/mac), [running Shortcuts and Quick Actions](https://support.apple.com/guide/shortcuts-mac/apd163eb9f95/mac), and [Apple security releases](https://support.apple.com/en-us/100100).
