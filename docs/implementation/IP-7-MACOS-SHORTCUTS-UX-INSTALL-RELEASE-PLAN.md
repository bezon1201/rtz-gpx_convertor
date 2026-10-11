# IP-7 — macOS Shortcuts UX, Installation, Distribution & Release

**Plan status:** Approved Gate 2 plan. Effective Gate 3 status: PENDING FINAL INDEPENDENT ARCHITECT REVIEW; the remote PASS declaration at `d9f723ba91091c682c9676f41dc168da31a252f1` is historical and superseded for current authorization. Gate 4, IP-7 execution, and overall implementation: NOT AUTHORIZED. This is a planning document; no product artifacts were created or run.

## 1. Objective, scope, and evidence rules

IP-7 defines V1's user-facing workflow and release experience. The primary UI is a reproducibly installable macOS Shortcut, with Finder Quick Action support and a local self-contained CLI. Both entry points must use the same IP-2–IP-5 conversion pipeline. There is no standalone GUI in V1.

IP-7 owns prompts, selection, presentation, explicit consent, export-only route-name editing, install/update/help experience, and release UX. IP-2 owns secure input acquisition and validated immutable route data; IP-3 owns route semantics and connector geometry; IP-4 owns GPX serialization and loss inventory; IP-5 owns CLI transport/orchestration enforcement and filesystem writing/publication; IP-6 owns empirical Windy consumer acceptance; IP-1 owns standards and platform/packaging discovery evidence.

No proposed Shortcuts action, API, permission behavior, process transport, file reference, security scope, macOS floor, package, signature, notarization, Gatekeeper path, or Windy workflow is considered qualified by this plan. Record each finding as **Verified fact**, **Observed result** (with exact environment/evidence), **Decision**, **Assumption/open question**, or **Not qualified**. Plans and proposed acceptance cases are not execution evidence.

## 2. Fixed product and upstream contracts

- Input is one uncompressed `.rtz` XML document. RTZP is out of scope for V1.
- RTZ 1.0 and 1.2 are mandatory targets subject to schema-backed qualification; 1.1 is conditional and non-blocking. Unsupported/mismatched versions and dialects fail clearly.
- Output is GPX 1.1: an ordered route (`<rte>` / ordered `<rtept>`), not a track by default.
- The four user choices are Full Route, From Waypoint, Current Position — Direct to Next WP, and Current Position — Join Selected Route Leg.
- Current Position always means manual latitude and longitude; no sensor, GPS, chart, network or inferred position source.
- Next waypoint and, for join mode, source route leg are explicit user choices and confirmation. No nearest waypoint/leg choice, automatic route decision, or visual-map inference is allowed.
- Both Current Position modes require explicit selection of the new connector geometry: Rhumb Line (Loxodrome) or Great Circle (Orthodrome); no default or fallback. In Join mode this is distinct from the original selected-leg geometry used to calculate the join point.
- Qualified geometry only. Both Current Position modes require explicit user selection of Rhumb Line (Loxodrome) or Great Circle (Orthodrome) for the new connector, with no default or automatic fallback. For Join, the connector geometry is distinct from the source selected-leg geometry used in join-point calculation. Unsupported/unqualified geometry blocks the affected operation.
- Advisory distance follows the approved WGS84 authalic sphere convention (`R=6,371,007.1809 m`; qualified Loxodrome as rhumb, Orthodrome as great-circle; `1 NM = 1,852 m`) and never selects or modifies a route. No ECDIS geometry equivalence is claimed.
- Conversion is fully offline. No telemetry, analytics, route upload, cloud conversion, external API, automatic Windy import, or hidden route persistence.
- RTZ remains unchanged. No vessel identity fallback for output naming; private route data, full coordinates, hashes, paths, raw XML and credentials are excluded from default logs/messages.
- No target-Mac Homebrew or Python requirement and no Terminal interaction for ordinary use. No standalone GUI framework in V1.

## 3. User journeys

### 3.1 Finder Quick Action

1. Select one `.rtz` file in Finder and invoke the installed converter Quick Action.
2. The Shortcut receives a file object/reference; it shows which item was selected without exposing private path details unnecessarily.
3. Pass the opaque reference to the approved local runtime handoff. Finder/Shortcuts provenance does not make the path or bytes trusted.
4. IP-2 securely opens, bounds and validates the file; the CLI returns only an approved bounded summary and safe diagnostics.
5. The user selects one of the four modes. For waypoint choices, labels include source order/context to distinguish duplicate or empty names; names are not identities.
6. For Current Position, request coordinates, explicit next waypoint, and either Direct or Join. Join additionally requires explicit route-leg selection and confirmation.
7. For either Current Position mode, require explicit connector geometry selection (Rhumb Line/Loxodrome or Great Circle/Orthodrome). For Join, show source-leg geometry separately from connector geometry.
8. Set the effective GPX route name: valid source name by default; offer an explicit export-only override or explicit omission when no valid source name is available. Validate and bound input; do not silently substitute/truncate.
9. Show transformed-route preview, including geometry, effective GPX route name or omission, warnings and metadata-loss summary; obtain **route confirmation** as defined in §6. A one-point result shows no navigable legs and requires explicit confirmation.
10. Select destination and filename separately; show target state and warnings; obtain separate **publication consent**, including exact-target overwrite authorization if applicable.
11. Before publication, IP-5 reacquires authorized source access, securely reopens/revalidates RTZ, recomputes with all confirmed parameters and verifies source identity/content and preview equivalence. If continuity cannot be proven, require fresh preview and route confirmation and do not publish. Then validate target state and publish under the approved writer contract.
12. Report success only on IP-5-confirmed publication; offer to reveal the output in Finder.

### 3.2 Standalone Shortcut

The user runs the same Shortcut from the Shortcuts app or a qualified Dock, Spotlight, or keyboard entry point. If there is no input file, request one through a native file picker. Then use the exact shared secure-validation → route-selection → preview → route-confirmation → destination-selection → publication-consent → continuity-verification → safe-publication flow above. An unavailable launch surface is a qualification failure for that surface, not a reason to fork conversion behavior.

### 3.3 Cancellation and recovery

Cancellation is available at file picking, mode/waypoint/leg selection, coordinate entry, preview, route confirmation, save panel, publication consent, output staging, and publication where the writer supports it. Cancellation at either approval boundary is never approval. Every UI cancellation maps to an explicit cancelled result distinct from failure. The interface must not say “cancelled” until IP-5 confirms the operation stopped. If publication already crossed its commit point, show the actual published state; never imply rollback or delete/restore output without IP-5 evidence. Staging cleanup and residual-file behavior are IP-5-owned and must be visible in acceptance evidence. A cancelled flow must never silently proceed with defaults.

## 4. Route-mode interaction contracts

### 4.1 Full Route

Clearly label “Full Route”; preview the complete source-order route and counts. No point is omitted, invented, reordered or densified. Distance is explanatory only.

### 4.2 From Waypoint

Show source-order choices with stable ordinal and bounded neighboring context (for example, “Waypoint 08 — name — from/to context”). A duplicate name must remain distinguishable; an absent name is represented as unnamed, not fabricated. Selection is by validated source reference, not text label. Confirm the selected start and resulting suffix preview before conversion.

### 4.3 Current Position — Direct to Next WP

Collect latitude and longitude separately with explicit decimal-degree and sign/hemisphere guidance; reject blank, non-finite, out-of-range, malformed, ambiguous or locale-reinterpreted values. Ask for the next waypoint by source order/context and require explicit selection of the new connector geometry (Rhumb Line / Loxodrome or Great Circle / Orthodrome). Show the current position as user-entered, the selected next waypoint, selected geometry and complete resulting order. Require explicit confirmation. Never obtain a location automatically or switch geometry on failure.

### 4.4 Current Position — Join Selected Route Leg

Collect coordinates as above, ask for an exact source leg, show source-order endpoints and leg identity/context, and require route-leg confirmation. Explicitly ask for the new connector geometry (Rhumb Line / Loxodrome or Great Circle / Orthodrome). Show that choice separately from the source-leg geometry used to calculate the join point. IP-3 computes only qualified join geometry and returns a preview with selected leg, join point, connector and remaining route. The UI presents these as computed geometry, not navigation advice; user confirms the complete result. Unsupported or ambiguous geometry fails closed with the actual diagnostic. The UI must not select a closest leg or use map placement to infer intent.

## 5. Proposed native interaction mapping (unqualified candidates)

The following are design candidates for IP-7A/7B, not claims that an action exists with this exact label on every supported macOS release or that it meets the data/security contract. IP-1D must establish exact action names and behavior on the eventual candidate OS matrix. Prefer built-in Shortcuts actions; use supported macOS APIs only after architecture review and qualification.

| Interaction | Candidate mechanism | Data / authority | Required qualification and safe failure |
|---|---|---|---|
| Finder input | Shortcut configured as Finder Quick Action; accept one file item | File URL/reference, still untrusted | Exact Finder settings, multiple-selection behavior, stale item, alias and permission behavior; refuse ambiguous/multiple input or offer picker only by explicit choice. |
| Standalone selection | Shortcuts “Choose File” candidate / native file selection API if a reviewed wrapper is required | User-selected file reference | Cancel returns cancellation; extension is advisory; secure open and validation remain mandatory. |
| Mode selection | Shortcuts “Choose from Menu” or equivalent | Fixed enum token | Stable machine values independent of localized labels; selection cancel is not a default. |
| Waypoint/leg selection | “Choose from List” or equivalent over bounded, privacy-safe labels | Scoped stable ordinal/reference token | Qualify item-count/output limits, duplicate/unnamed labels, truncation and accessibility. Reject if returned choice cannot be bound to the validated preview. |
| Coordinates | “Ask for Input” text/number candidate, or reviewed native text-field API | Raw text plus explicit format/sign choice | Locale-independent parser contract; invalid input stays in UI with safe message; no automatic location. Numeric field behavior must not silently alter decimal syntax. |
| Preview | Bounded “Show Result” or notification/detail action candidate; otherwise escalation for supported native presentation | Safe route summary and warning codes only | Qualify length truncation, layout, VoiceOver and loss visibility. Never place raw XML, private paths or full route in logs. If a readable preview is impossible, stop for architecture review. |
| Route name / confirmation | Explicit bounded text choice plus “Ask for Confirmation”/menu candidate | Valid source name default, explicit export-only override, or explicit omission; exact effective value displayed | Name is independent of filename/source model; name binds the route preview. Name change requires new preview and route confirmation. Token is correlation only. Cancellation is not approval; IP-5D enforces binding. |
| Connector geometry | Explicit choice in both Current Position modes | Rhumb Line / Loxodrome or Great Circle / Orthodrome | No default/fallback; preview and route-confirmation binding include the choice. Join also shows distinct source-leg geometry. |
| Route confirmation | “Ask for Confirmation”/menu action candidate | Exact route-preview semantics and affirmative user response | Binds validated source identity/content state, mode/selections/manual position, connector geometry, effective GPX route name/omission, resulting ordered points/loss warnings; excludes destination. Cancellation is not approval; IP-5D enforces binding. |
| Destination | “Save File” / native save-panel candidate | User-selected destination reference | Qualify default directory, extensions, provider locations, cancellation, replacement prompt and exact target returned. IP-5 independently validates. |
| Publication consent / overwrite | Native save dialog replacement alert or separate explicit confirmation after save target selection | Exact destination, filename, target identity/existing-file state and intended output; exact replacement authorization if applicable | Separate from route confirmation. No generic “replace?” detached from target; recheck changed target/identity and output binding before publication. No silent overwrite. |
| Completion | “Show Notification”/result action candidate | Success state and safe basename or user-approved detail | Say success only after IP-5 confirms publication. Error details use stable code and recovery action; no private path/coords in default notification. |
| Finder reveal | “Reveal in Finder”/Open File candidate | Published output file reference | Must reveal the exact output without opening/editing it; missing/moved file is a recoverable post-success warning. |
| CLI invocation | IP-1D-selected static, non-interpolating handoff or IP-5-approved launcher | Structured arguments/input/output, separately authorized file reference | No assumption Shortcuts supports arbitrary stdin or carries security scope to a subprocess. No dynamic shell construction, AppleScript, temporary plaintext route document, or privileged daemon. |

For every selected mechanism record macOS/Shortcuts build, action/API name, input/output type, permission prompts, behavior for denial/cancel, accessibility properties, output limits, offline result and repeatable evidence. Set the minimum supported macOS version only from passing evidence; do not guess it in this plan.

## 6. Route preview, route confirmation, and source continuity

Preview should include only what is needed for informed review: effective GPX route name (valid source name by default, explicit export-only override, or explicit omission); mode; original/resulting point counts; selected start waypoint or manual position; selected next WP/leg; explicitly selected connector geometry and, for Join, distinct original selected-leg geometry; bounded ordered sequence or summary; join/connector description; warnings; advisory distance/method if already qualified; metadata categories/counts lost; and the clear statement “GPX preserves ordered coordinates and available waypoint names; RTZ navigation semantics are not preserved and this is not an ECDIS-equivalent route.” Never claim navigational safety approval. Respect IP-2 privacy limits; do not persist preview or default-log route details.

There are two independent approval boundaries:

1. **Route confirmation** approves the validated source route and qualified content state; chosen mode; selected waypoint or route leg; manually entered current position where applicable; explicitly selected connector geometry; resulting ordered waypoint sequence; effective GPX route name or explicit omission; and material navigation-metadata-loss warnings. It confirms transformation semantics only. IP-3 owns those semantics; IP-7 presents them and collects affirmative consent; IP-5D enforces source continuity, semantic equivalence and confirmation binding.
2. **Publication consent** is collected after destination selection. It approves the exact output destination and filename, target identity/existing-file state, destination-specific warnings, and exact-target overwrite authorization if applicable. IP-7 presents the target and collects consent; IP-5E owns secure staging, target validation, collision handling, publication and cleanup.

The intended order is **secure source validation → route selection → preview → route confirmation → destination selection → publication consent → source/preview continuity verification → safe publication → confirmed result**. This is a logical UX sequence; it does not assume a file reference or security scope survives between processes.

Selecting a destination after route confirmation does not invalidate that confirmation if the validated source identity/content state, route selections and transformation semantics are unchanged. Changing only destination or filename invalidates publication consent only; route confirmation may remain valid. Changing source identity/content, route mode, waypoint/leg selection, manual position, connector geometry, effective GPX route name, or resulting route semantics invalidates route confirmation and any publication consent bound to the old output. Publication consent is bound to both the exact target state and the exact intended output derived from the confirmed preview. Changing the output filename alone never changes the internal GPX route name.

Before publication, IP-5 must reacquire authorized source access, securely reopen and revalidate the RTZ, recompute the transformation from all confirmed parameters (including connector geometry and effective GPX route name), and compare material route semantics, point order, coordinates, geometry, warnings and metadata-loss disclosures with the confirmed preview. File path or opaque token alone is not proof. The privacy-preserving continuity proof remains technically unqualified; no full source digest is required by default. If source identity/content continuity or preview equivalence cannot be established, fail closed and require a fresh preview and route confirmation; do not publish. If the target changes or overwrite authorization is stale, fail closed and request renewed publication consent. Require renewed route confirmation only when its own source/semantic binding has become invalid. Cancellation at either boundary is never approval. Report success only when IP-5 confirms the actual filesystem outcome.

The stateless cross-invocation continuity mechanism remains unresolved. The UI must support fresh authorized file-reference acquisition where required, secure reopen/revalidation, source-object identity and content-state continuity, preview semantic equivalence, and fail-closed behavior if scope expires or continuity is unproven. The token is correlation only, not proof. A full source digest is not calculated by default: IP-2A may propose it only with documented technical need, privacy review and explicit approval. Schema artifact hashes are unrelated. Do not invent a security-scope solution or design a UI bypass.

## 7. Shortcuts transport and authority qualification

IP-5's JSON stdin/stdout proposal remains provisional. Shortcuts may expose typed items, shell-action inputs/outputs, or other OS-mediated handoff, but it is not established that an arbitrary process can receive stdin, preserve file-reference authority, return bounded structured output, propagate cancellation, or display errors correctly. Finder access does not automatically confer subprocess access.

IP-7B must compare only architecture-reviewed candidates, with IP-1D/IP-5: (A) a fixed Shortcuts action invocation with strictly separated, typed input; (B) a fixed launcher using Foundation `Process` and an explicit argument array/defined pipes; or another candidate only after explicit architectural review. No user-derived value is inserted into shell source or a command string. Do not use AppleScript, route plaintext temporary files, or persistent privileged services as an unreviewed fallback. Exercise spaces, Unicode normalization variants, quote/apostrophe, shell metacharacters, leading dash, large but bounded lists, structured success and nonzero errors using harmless synthetic values only. Test actual file authority across the process boundary, no-network behavior and cancellation. Record exact OS/action configuration, sanitized data shape, stdout/stderr/exit handling and output-size ceilings; no route content or user paths in evidence.

If no candidate can meet secure file access, privacy, UX, cancellation and stable automation contracts, mark IP-7B BLOCKED and return an architecture decision request. Do not silently switch transport or degrade Current Position/preview/consent requirements. Any required probe needs its own explicit Gate 4 execution authorization; planning this probe does not authorize running it.

## 8. Save, overwrite, and filesystem feedback

IP-7 owns destination selection and publication consent; IP-5 owns target validation, staging, writing, publication, cleanup and actual state. Keep the output `.gpx` filename independent of the internal GPX route name: changing one does not silently change the other. A safe filename proposal may be generated separately under the privacy policy; never use vessel identity or treat a filename as the GPX route name. Validate filename and route name under their separate contracts. After route confirmation, the user selects the full destination and filename, reviews relevant destination/target state, then gives publication consent. Any replacement requires explicit authorization for that exact target.

Publication consent is bound to the exact selected target state and intended output, and is rechecked immediately before publication. A destination/filename change invalidates publication consent, but does not by itself invalidate route confirmation. If target identity, existing-file state, permissions or relevant provider state changes, fail closed and request renewed publication consent; renew route confirmation only if its own binding is no longer valid. A source/route-semantic change invalidates route confirmation and consent for the output derived from it. Protect against source and destination resolving to the same underlying object. Report read-only/unavailable locations, permission denial, insufficient space, provider failure, GPX validation failure and cleanup status with retry/reselect/stop advice. File Provider behavior is conditional; distinguish converter-controlled network activity from macOS/provider activity, and do not claim provider-wide offline behavior. Do not promise identical atomicity, metadata, ACL or permission behavior across filesystems/providers. IP-5E chooses output-permission policy; IP-7 does not preselect `0600` or inheritance. Cancellation during staging/publication follows actual IP-5 state; no phantom rollback.

## 9. Diagnostics, privacy, and error recovery

Every UI-visible error maps to a stable machine diagnostic code owned by the relevant upstream stage, with a plain-language message, safe technical detail, recovery action, and retry/reselect/stop classification. Include unsupported RTZ version/dialect; malformed or schema-invalid input; invalid coordinates; duplicate/ambiguous waypoint labels; unsupported geometry; stale or inaccessible reference; expired permission; source continuity/route-confirmation invalidation; stale-target/publication-consent invalidation; invalid manual position; cancelled flow; unavailable destination; collision/unsafe overwrite; permission/disk/provider error; GPX validation/write failure; version mismatch; and success with metadata loss. Distinguish user cancellation from error and distinguish route-confirmation renewal from destination-consent renewal.

Default notifications, logs and Shortcut variables must not disclose source XML, full route coordinates, vessel identifiers, credentials, private absolute paths, or source-file hashes. Use stable diagnostic identifiers and bounded field-free details. Any exceptional support bundle/logging design requires separate privacy approval and must be opt-in, sanitized, local and bounded. No route history, hidden storage, automatic backup or telemetry.

## 10. Package, first run, updates, and removal

G3-010 approves the architecture direction: a signed and notarized macOS `.app` container with bundled arm64 Swift CLI, distributed by DMG. This is not a qualified package or feasibility claim. IP-1E/IP-5A–F evidence must settle bundle layout, Shortcut executable discovery, embedded CLI invocation, code-signing identity, hardened runtime where required, notarization/stapling, Gatekeeper/quarantine behavior, install without admin where supported, Shortcut install/registration, Finder Quick Action registration, Dock/Spotlight behavior, minimum OS, and removal. No developer-specific absolute path. No automatic updater. No Terminal/Homebrew/Python for ordinary use.

First-run documentation should guide: install app; install/activate provided Shortcut; enable Quick Action if needed; grant only necessary permissions; perform a future authorized synthetic smoke journey; locate generated output; and import GPX into the exact Windy.com Route Planner workflow only after IP-6A verifies current instructions. Do not promise setup can be automated. Name which steps require user action and why. No real route is needed for onboarding acceptance.

Track separate application, CLI protocol and Shortcut workflow versions. Publish an explicit compatibility matrix; reject incompatible combinations with a safe message. Updates are offline-installable and user-initiated. Document replacement/install steps, version detection and recovery. Rollback uses a previously qualified package and compatible Shortcut/protocol; no automatic migration or deletion of private route files. Removal describes app, Shortcut and optional Finder registration separately and confirms what user-created files remain. No update service, network check or telemetry.

## 11. Accessibility and localization

Acceptance requires keyboard-only completion; logical focus order; meaningful VoiceOver labels/announcements for mode, waypoint/leg choices, preview warnings, errors and completion; usable text at supported system sizes; readable contrast; warnings not expressed by color alone; and duplicate/unnamed waypoint disambiguation understandable without visual map cues. Coordinate labels state decimal-degree convention, sign/hemisphere and range. Parsing is locale-independent, with explicit decimal separator behavior and no silent comma/dot reinterpretation. Machine protocol and diagnostic codes are locale-neutral. English is V1 baseline; future localization must not alter machine values, coordinate meaning, source ordering or confirmation semantics.

## 12. Offline, supported environment, and nonfunctional requirements

**Mandatory local offline support:** for approved, fully local and available source files and local destinations, every route mode and both Finder Quick Action and standalone Shortcut workflows pass with network access disabled. Input validation, transformation, route preview/confirmation, GPX serialization and safe publication remain local. Converter-controlled runtime makes no cloud API, network schema request, analytics, telemetry, upload, or external-service request. No automatic GPS acquisition, Windy upload, background synchronization, hidden route persistence or network-based schema resolution. User-initiated GPX import into Windy is a separate external action and never automatic. This guarantee is tested separately from provider behavior.

**Conditional File Provider support:** sources or destinations in cloud-backed/File Provider locations are supported only for specifically qualified provider states and OS versions. Qualification covers authorized content availability; security-scoped access and reference lifetime; alias/symlink resolution; provider permissions; save/replacement/publication guarantees; metadata, ACLs and extended attributes; cancellation/synchronization/error reporting; and network-dependent provider behavior. The converter must not independently initiate a cloud download, cloud API call or network conversion, or wait indefinitely for an unavailable placeholder. Fail clearly and promptly when authorized content is unavailable or cannot be safely accessed/published; offer only user-controlled retry or a local-file/destination alternative. Do not generalize one provider's results to all providers. Distinguish converter-controlled activity from macOS/provider activity outside converter control. An unavailable placeholder does not invalidate mandatory local offline PASS. Any provider support claim requires separate evidence.

Support only macOS versions and Apple Silicon hardware actually qualified. Candidate oldest/current OS matrix is selected during IP-7A/7B in coordination with IP-1/IP-5; do not claim a minimum version here. Include first launch, standard user permissions, installation and clean-user testing. Performance, list bounds, preview length and cancellation responsiveness derive from IP-2/IP-5 limits and measured realistic synthetic data. No claim of universal Finder/File Provider behavior.

## 13. Future synthetic UX acceptance matrix (design only)

No test or fixture is created or run in this planning task. Future cases use only reviewed synthetic RTZ/model/GPX data and exact IP-2–IP-6 expected results. Each record captures case ID, OS/Shortcuts/build, prerequisites, input ID, user actions, expected UI, expected CLI/IP-5 result, filesystem state, privacy controls, evidence artifact, and PASS/FAIL/BLOCKED rule.

| Case IDs | Scenario | Required result |
|---|---|---|
| 7UX-01–04 | Finder Quick Action; standalone picker; Shortcuts app launch; each claimed Dock/Spotlight/keyboard entry point | Same pipeline; selected file is explicit; unavailable surface blocks its claim; cancellation has no output. Mandatory local-file/local-destination cases run offline. |
| 7UX-05–08 | Full Route; From Waypoint; Current Position Direct; Current Position Join | Exact approved point order/selections, preview and explicit confirmation; no inferred choice. |
| 7UX-09–12 | Duplicate/unnamed names; Unicode route/file names; maximum bounded waypoint list; long preview | Stable disambiguation, intact file naming, bounded accessible UI, no silent truncation of material choices. |
| 7UX-13–17 | Unsupported dialect; malformed/schema-invalid input; unsupported geometry; invalid coordinate; ambiguous route choice | Actionable diagnostic, no unsafe fallback and no output publication. |
| 7UX-18–22 | Source replaced after preview; stale/expired security scope; aliases/symlinks; permission denial; re-selection | Joint IP-2/IP-5/IP-7 policy enforced; identity/content continuity proved or fail closed; no unsafe reopen. |
| 7UX-23–27 | Cancel at route confirmation and publication consent separately; cancel during staging; publication race; Shortcut terminated; CLI nonzero exit | Approval at one boundary never implies approval at the other; correct cancelled/failed/published state; no claim of rollback without evidence; cleanup matches IP-5. |
| 7UX-28–33 | Destination/filename changes after route confirmation; target changes after publication consent; source=destination identity; read-only/disk full; File Provider failure | Destination-only change renews publication consent but preserves still-valid route confirmation; source/semantic change renews route confirmation and dependent consent; no silent replacement; safe writer state. |
| 7UX-34–37 | GPX validation/write failure; success plus loss report; Finder reveal; Windy instructions | No false success; warnings visible; reveal exact output; import guidance matches verified IP-6A evidence. |
| 7UX-38–42 | Offline run; version mismatch; Gatekeeper first launch; Shortcut missing/disabled; fresh-user install/removal | Offline workflow works; incompatibility fails safely; reproducible user-managed recovery/removal. |
| 7UX-43–45 | VoiceOver; keyboard-only; text scaling/high contrast and coordinate locale variants | Complete accessible flow and locale-independent numeric semantics; no color-only decision or changed coordinates. |
| 7UX-46–47 | Offline update; rollback/version compatibility | Reproducible upgrade and qualified rollback; no route-data migration/network access. |
| 7UX-48–50 | Effective route-name default/override/explicit omission; invalid value; filename-only change | Exact name shown in preview and serialized; invalid input rejected without substitution/truncation; name change renews route confirmation and dependent publication consent; filename-only change renews publication consent only and leaves `<rte><name>` unchanged. |
| 7UX-51–53 | Explicit connector geometry for both Current Position modes; changed geometry; unqualified calculation | Both choices presented without default; preview/confirmation binds selected geometry; changed choice refreshes preview and route confirmation/consent; calculation failure is diagnostic with no fallback; Join shows source-leg geometry separately. |
| 7UX-54–55 | One-point route from valid source/mode | Preview warns no navigable legs; affirmative confirmation required; exact one-point GPX emitted; no fabricated point; Windy compatibility recorded separately. |

Maintain separate verdict groups. **Mandatory Offline PASS** requires fully local available input and fully local destination, network disabled, all required entry points and route modes, no converter-controlled network activity, and correct safe publication. **Conditional File Provider qualification** separately covers provider-specific local/hydrated files, unavailable placeholders, cloud-dependent destinations, permissions, cancellation and publication. Unsupported/unavailable provider states are documented limitations with safe diagnostics, not failures of the mandatory local-offline guarantee. Do not weaken mandatory offline acceptance for local files.

PASS requires both correct user-visible behavior and expected IP-5 filesystem/security state; screenshots alone are insufficient. Privacy scan and network-disabled evidence are mandatory for Mandatory Offline PASS. Provider cases have their own conditional verdict and do not substitute for or weaken local-offline acceptance. Unsupported or unobservable behavior is BLOCKED/INCONCLUSIVE, never assumed PASS.

## 14. IP-7A–IP-7F future execution decomposition

Each sub-stage below is a plan-level outline, not a detailed execution checklist. Detailed stage and file-level implementation/test plans are separate approval-gated work before any Gate 4 authorization. No sub-stage is started or passed.

### IP-7A — UX Contract and Interaction Mapping

- **Objective:** freeze user journeys, modes, prompts, preview, consent, diagnostics, accessibility and candidate native action/API map.
- **Scope/files:** future UX contract and evidence records; exact files to be chosen in detailed planning.
- **Dependencies:** approved master/IP-1–IP-6 contracts; resolve UI ownership and upstream diagnostic shapes without changing semantics.
- **Sequence:** reconcile journeys → map every interaction/data type/permission/OS version → review privacy/accessibility → return uncertainties.
- **Future verification:** design review and synthetic flow traceability; no platform PASS from documentation alone.
- **Acceptance/evidence:** all entry points and four modes covered, every interaction mapped with qualification method, errors/cancellation/privacy/accessibility complete, no unapproved scope change.
- **Risks/stop/rollback:** Shortcuts UI limits may prevent readable preview or explicit choice; stop and request separate architecture decision rather than create GUI.
- **PASS:** reviewed UX contract and no unresolved ownership ambiguity.

### IP-7B — Shortcuts and Finder Integration Qualification

- **Objective:** empirically establish supported entry points, file handoff, authority, transport, bounded outputs, errors, cancellation and permissions.
- **Scope/files:** future authorized inert-probe evidence, OS/action matrix and selected interface record; never real routes.
- **Dependencies:** IP-1D transport and IP-1E package discovery; IP-2A alias/reference policy; IP-5 CLI/reference contract; separate authorization for probes.
- **Sequence:** select candidate OS/users → compare architecture-reviewed transports → run harmless synthetic/inert cases → prove authority, errors and offline operation → review result.
- **Future verification:** repeatable observations with exact OS/action configuration, no sensitive values, and privacy-safe evidence.
- **Acceptance/evidence:** all claimed launch paths pass; Finder/picker files remain secure references; spaces/Unicode/discrete data survive; no shell interpolation; no Terminal; permissions and cancellation fail safely; transport chosen from reproducible evidence.
- **Risks/stop/rollback:** input flattening, scope loss, OS variance, action limits; BLOCKED if unresolved and escalate, no silent alternate transport.
- **PASS:** IP-1D/IP-5/IP-7 jointly approve a tested transport and matrix.

### IP-7C — Preview, Confirmation and Save UX

- **Objective:** qualify route preview/readability and route confirmation separately from publication consent, destination/overwrite, cancellation and Finder reveal.
- **Scope/files:** future interaction specifications and authorized synthetic evidence.
- **Dependencies:** IP-3 domain preview, IP-4 naming/loss policy, IP-5D continuity and IP-5E writer policy, IP-5F orchestration; IP-7B transport.
- **Sequence:** bind route confirmation to immutable preview semantics → verify a destination-only change preserves still-valid route confirmation but requires new publication consent → test source/semantic invalidation → qualify exact-target consent and write-state feedback/reveal.
- **Future verification:** synthetic route cases, target replacement/race cases, accessibility and cancellation evidence.
- **Acceptance/evidence:** complete route summary; two distinct affirmative approvals; continuity/equivalence proven; save/overwrite consent binds the exact output target and intended output; source change invalidates route confirmation; target change invalidates publication consent; actual publication state reported; no unsafe success.
- **Risks/stop/rollback:** stateless preview/content continuity, provider/atomicity variance, long lists; no PASS if IP-5D continuity unresolved.
- **PASS:** IP-5 confirms transport/enforcement and IP-7 review accepts evidence.

### IP-7D — Installation, Signing and Notarization

- **Objective:** qualify package candidate, app/CLI/Shortcut discovery, installation, Gatekeeper, permissions and removal.
- **Scope/files:** future build/release evidence and user-facing installation artifacts only after authorization.
- **Dependencies:** IP-1E and IP-5 packaging decision, supported OS matrix, selected IP-7B transport.
- **Sequence:** settle bundle layout → sign/notarize/staple candidate → install on clean qualified systems → assess Gatekeeper/permissions/Shortcut registration → document uninstall.
- **Future verification:** clean-user/offline install and launch evidence, exact build/signature identities and no developer-specific path.
- **Acceptance/evidence:** self-contained arm64 package; no Homebrew/Python/Terminal in ordinary use; verified launch and Finder integration; understandable admin/quarantine handling; removal boundaries documented.
- **Risks/stop/rollback:** certificate/team availability, notarization changes, OS floor and registration; stop on unqualified package or elevated permission need.
- **PASS:** approved distribution candidate reproducibly installs offline on every claimed environment.

### IP-7E — Release Workflow and User Documentation

- **Objective:** qualify offline install/update/rollback/version documentation, onboarding, troubleshooting and help.
- **Scope/files:** future user guide, compatibility table, release notes and support procedures.
- **Dependencies:** IP-7A–D decisions, IP-5 CLI protocol/version, IP-6A verified Windy instructions.
- **Sequence:** draft from observed product behavior → review privacy/accessibility → exercise install/update/rollback/removal instructions → correct ambiguities.
- **Future verification:** independent fresh-user walkthrough, offline and incompatible-version cases.
- **Acceptance/evidence:** accurate install, Shortcut activation, Quick Action, permission, save/reveal, update/rollback/remove and recovery instructions; no unverified Windy claim; no hidden route retention or network check.
- **Risks/stop/rollback:** documentation diverges from signed package or live Windy UI; requalify affected instructions.
- **PASS:** fresh-user evidence and architecture review close every instruction.

### IP-7F — End-to-End UX Acceptance

- **Objective:** run full synthetic journeys and provide a release recommendation against all mandatory criteria.
- **Scope/files:** future acceptance matrix results, privacy/accessibility report, release disposition.
- **Dependencies:** IP-7A–E PASS; mandatory local-offline IP-1–IP-5 implementation criteria PASS; IP-6 approved disposition; separate provider qualification only for any provider support claim; explicit implementation/testing authorization.
- **Sequence:** freeze candidate/version matrix → run all applicable cases offline → reconcile filesystem/CLI/UI evidence → privacy/accessibility review → classify each criterion → request release decision.
- **Future verification:** reproducible records linked to synthetic inputs and exact package/OS; tests are not executed during planning.
- **Acceptance/evidence:** all required local journeys and modes pass offline with correct route confirmation, publication consent and IP-5 filesystem state; error/cancel/save/privacy/accessibility/install/update criteria pass; provider claims separately evidenced; unsupported cases explicit; no scope reduction.
- **Risks/stop/rollback:** any upstream blocker, non-deterministic permission behavior, unsupported OS or unobservable consumer criterion blocks release recommendation.
- **PASS:** all mandatory release conditions in §16 pass and independent review approves the evidence; otherwise BLOCKED/FAIL/INCONCLUSIVE as appropriate.

## 15. Cross-stage dependency and ownership matrix

| Stage | Owned contract / required handoff | Status and unresolved dependency |
|---|---|---|
| IP-1 | RTZ/GPX standards, schema/legal qualification, independent distance vectors, Shortcuts transport and packaging discovery | Plan approved; execution evidence pending. IP-1D transport and IP-1E package/OS matrix must coordinate with IP-5/IP-7. |
| IP-2 | Secure source acquisition, aliases/security-scoped references, validation, immutable route model and safe diagnostics | Plan approved; execution pending. IP-2A must jointly resolve alias/symlink/reference authority and local/offline versus provider availability states with IP-5/IP-7. |
| IP-3 | Four route modes, qualified transformation geometry, preview semantics | Plan approved; execution pending. G3-002 connector choice and G3-006 rhumb metric objective are approved; numerical algorithm qualification remains required. |
| IP-4 | GPX 1.1 route, naming, one-point policy, serialization and loss report | Plan approved; execution pending. G3-001 export-only naming and G3-004 one-point ALLOW_WITH_WARNING are approved; schema/name qualification remains pending. |
| IP-5 | Stable CLI, protocol, source continuity/route-confirmation enforcement, safe filesystem writer/publication | Plan approved; execution pending. IP-5D stateless continuity mechanism and IP-5E permissions/provider/atomicity remain unqualified; IP-7 distinguishes route and publication approvals and separates local offline guarantees from conditional provider support. |
| IP-6 | Windy Route Planner empirical consumer verdict | Plan approved; consumer acceptance NOT TESTED and IP-6E report NOT STARTED. IP-7 documentation may use only IP-6A-verified instructions. |
| IP-7 | User interaction, Shortcuts/Finder, install/update/docs, accessibility and release UX | Final independent Gate 3 review pending; IP-7 execution remains NOT AUTHORIZED. |

Interface owners: IP-1D/IP-5/IP-7 transport; IP-1E/IP-5/IP-7 packaging; IP-2/IP-5/IP-7 source-reference continuity; IP-3/IP-5/IP-7 route-preview semantics and route confirmation; IP-4/IP-5/IP-7 naming/save; IP-5/IP-7 publication consent, output permissions/replacement; IP-6/IP-7 Windy instructions. Mandatory local offline behavior remains separate from conditional provider qualifications. These are dependencies, not decisions made by IP-7.

## 16. Release gate and qualification dependencies

V1 release requires: all mandatory IP-1–IP-5 implementation criteria PASS; **IP-6 consumer acceptance PASS** under its mandatory multi-point case matrix in the exact Route Planner workflow; IP-7A–IP-7F criteria PASS; all four modes; distinct bound route confirmation and publication consent; safe published GPX 1.1; Mandatory Offline PASS for fully local inputs/destinations and all required local workflows; qualified Apple Silicon/macOS matrix; signed/notarized/Gatekeeper-accepted selected package; no Terminal/Homebrew/Python in ordinary use; accessibility/privacy/security acceptance; reproducible install/update/rollback/removal guidance; and all Gate 3 decisions dispositioned. One-point GPX compatibility is separately tested and disclosed if Windy refuses it; that limitation does not revoke G3-004 export capability or excuse a non-PASS mandatory multi-point case. File Provider claims require separate provider-specific qualification. Gate 3 PASS requires independent review under G3-011 and never authorizes Gate 4; Gate 4 requires separate explicit product-owner authorization.

Approved Gate 3 policy decisions G3-001 through G3-011 are recorded in the reconciliation report and owned plans. Remaining technical qualifications include IP-5D continuity proof; Shortcuts-to-CLI authority/transport; security-scope/File Provider behavior; IP-5E atomic publication, target races and permissions; IP-3 geometry and numerical bounds; schema rights/offline validation and +180° representability; actual Windy consumer evidence; and package/signing/macOS qualification. These remain owned and blocking at their specified stage gates; no feasibility or implementation PASS is implied.

## 17. Planning acceptance, governance, and next process

Gate 2 IP-7 planning is reviewable when this document defines complete Finder/standalone journeys; four mode contracts; native interaction candidates and qualification evidence; privacy-bounded preview and separate route/publication approvals; Shortcuts transport/authority evaluation; safe save/overwrite/cancel behavior; diagnostics; mandatory local-offline and conditional File Provider policies; package/onboarding/update/removal strategy; accessibility requirements; synthetic acceptance matrix; IP-7A–IP-7F outline; cross-stage ownership; release gate; and unresolved decisions. This plan satisfies no implementation, platform test, or release criterion by itself.

**Next process:** obtain final independent Architect review of the reconciled Gate 3 documentation. Gate 4, IP-7 execution, tests and platform probes remain NOT AUTHORIZED. Any future stage requires separate explicit Gate 4 authorization naming the stage and any probes; execute one authorized stage at a time.
