# Gate 3 Cross-Stage Reconciliation R1

**Historical status at R1 publication:** Reconciliation complete / pending independent architecture review; Gate 3 PASS not declared. Gate 4 and all implementation were NOT AUTHORIZED. The independent review disposition is appended below.

## Baseline provenance

Reconciliation branch `docs/gate-3-reconciliation` was created from the clean IP-7 head `482c8b585635138174dbf64d309cc3f308e3dcd9`. The approved revisions were checked against their recorded commits and remote refs. The Master Plan’s approved commit is on separate history, so its exact plan blob was compared with the approved tree; it matched. Each approved IP plan blob also matched its approved revision before edits:

| Baseline | Approved commit | Approved plan blob |
|---|---|---|
| Master Plan | `d57d0935c7885eb25eb14542e7996839644e96e2` | `33fda5e82ad12115988bfadf0c6665177fdbaedc` |
| IP-1 | `6ed649d3995f70fa2421e08cb027c07d19b4cad4` | `11c31157a11674173d881ca866b13bff36141577` |
| IP-2 | `8011d3f0c4baf62cb15194ab9308f4e312269615` | `e2a94197f408e8dac72ac8460b26a397c56d3f41` |
| IP-3 | `8e35edff864de87278aa7c61c7376e49845c3d74` | `86e703fc69e24b8299ecee481a5ac53e73d75897` |
| IP-4 | `34f067112187a4c755f5c4cc94d5b6f36cfae1ae` | `5ed76d92701a23650add188e12c89b4dec1ef929` |
| IP-5 | `7d24aadcdc0e0b8bf0429e3f639696e9bafa68b7` | `4f3bbd59e47c5db3b01db97702346cfd4a3cf240` |
| IP-6 | `8688880058c489d14d2ec26c1d624106506d26e5` | `fbe7621aaecf0ace6d0fe5f3f5eb03af50cf0a66` |
| IP-7 | `482c8b585635138174dbf64d309cc3f308e3dcd9` | `2861221c7aa64406bc7e47a6dded1fdcf3e32897` |

The original cross-stage audit was supplied in the preceding architecture-review conversation; no standalone audit file was present in the repository. No pre-existing working-tree edits were present.

## Decision ledger

| Decision | Reconciled contract and owners | Residual qualification / blocking condition |
|---|---|---|
| G3-001 Export-only route-name override — **PRODUCT DECISION RESOLVED** | IP-3 derives the effective export name without source mutation; IP-4 serializes the exact confirmed value or explicit omission in `<rte><name>`; IP-5 transports/binds it; IP-7 edits and previews it. Source name is default only when valid. Filename remains independent. No silent repair or vessel/file fallback. | IP-4 must qualify XML characters, length bound and normalization; invalid/missing source name requires valid override or explicit omission. Any effective-name change invalidates route confirmation and dependent publication consent. |
| G3-002 Current Position connector geometry — **PRODUCT DECISION RESOLVED** | Both Direct to Next WP and Join Selected Route Leg require an explicit Rhumb Line/Loxodrome or Great Circle/Orthodrome choice. IP-3 transforms; IP-5 binds; IP-7 presents. No default/fallback. Join connector geometry is distinct from source-leg geometry. | IP-3 must qualify numerical algorithms/limits. Join’s closest-point objective is separately covered by G3-006. Uncomputable geometry fails closed. |
| G3-003 Source continuity — **SECURITY PRINCIPLE APPROVED; MECHANISM UNQUALIFIED** | IP-2 reacquires authorized access, securely reopens, validates and compares material route semantics; IP-5D orchestrates continuity and preview equivalence; IP-7 requests fresh preview/confirmation on mismatch. Path/token alone is insufficient; full source digest is not default. | Qualify privacy-preserving filesystem identity and material-content comparison. If equivalence cannot be proven, stop export and require refreshed preview and route confirmation. |
| G3-004 One-point GPX — **PRODUCT DECISION RESOLVED: ALLOW_WITH_WARNING** | IP-3 may return one point; IP-4 emits one `<rte>` with one `<rtept>`; IP-5 transports warning acknowledgement; IP-7 shows no-navigable-leg warning and obtains explicit confirmation; IP-6 tests separately. | GPX schema/serializer qualification remains. Windy refusal is a disclosed one-point consumer limitation and does not revoke export policy. |
| G3-005 +180° longitude — **PRODUCT DECISION RESOLVED; SCHEMA QUALIFICATION REQUIRED** | IP-1/IP-2 qualify accepted source dialect and numeric value; IP-3 preserves numeric semantics; IP-4 validates GPX representation. Never wrap +180° to −180° or claim lexical decimal preservation. | Exact approved XSD and semantic representation must accept it; otherwise fail closed without output. Antimeridian geometry also needs qualification. |
| G3-006 Rhumb closest-point metric — **MATHEMATICAL OBJECTIVE APPROVED; ALGORITHM UNQUALIFIED** | For Join on a rhumb source leg, minimize spherical geodesic distance from Current Position to the finite rhumb segment, including endpoints, using the approved spherical Earth model. Never switch legs automatically. IP-3 owns. | Qualify parameterization, minimizer, tolerances, ties, antimeridian, polar and degenerate cases; unsupported/unqualified cases fail closed. |
| G3-007 Route confirmation vs publication consent — **ARCHITECTURAL CONTRACT APPROVED; PROTOCOL QUALIFICATION REQUIRED** | IP-3 defines semantic output; IP-5 binds and enforces separate approvals; IP-7 obtains them. Route confirmation binds source, mode/selections, coordinates, geometry, effective name, ordered output, warnings and loss disclosures. Publication consent binds exact GPX, destination/name, target state and replacement authorization. | Any semantic change invalidates route confirmation and dependent consent. Destination/filename-only changes renew publication consent only; target-state changes renew publication consent. Qualify replay resistance and transport. |
| G3-008 Windy acceptance — **RELEASE POLICY APPROVED; EMPIRICAL ACCEPTANCE NOT EXECUTED** | IP-6 must obtain PASS for every mandatory multi-point case across all four modes in the exact Route Planner workflow, including route object, order and coordinate fidelity; IP-7 gates release on that PASS. | FAIL/BLOCKED/INCONCLUSIVE/NOT TESTED prevents consumer PASS. One-point is separate. No real routes; no compatibility claim before evidence. |
| G3-009 Offline and File Provider — **PRODUCT DECISION RESOLVED; PLATFORM QUALIFICATION REQUIRED** | IP-5/IP-7 guarantee fully local inputs and destinations offline across all modes and entry paths. Converter initiates no cloud download or network conversion. Provider/OS activity is distinguished. | Qualify authorized availability, placeholders, permissions, cancellation and provider-backed output. Unavailable items fail clearly without indefinite wait; provider qualification does not weaken local offline acceptance. |
| G3-010 Distribution — **PRODUCT ARCHITECTURE APPROVED; PACKAGING QUALIFICATION REQUIRED** | IP-1/IP-5/IP-7 target signed/notarized arm64 `.app` in `.dmg`, drag-to-Applications, bundled local CLI and standalone/Finder Shortcut; document update/migration, uninstall and rollback. No Terminal/Python/Homebrew/Xcode in normal use. | Qualify bundle, Shortcut registration and persistence, Gatekeeper, signing/notarization, permissions, macOS floor and clean-user install/update/removal. If unsafe/infeasible, stop for review; do not silently change architecture. |
| G3-011 Governance — **GOVERNANCE DECISION RESOLVED** | Independent review must find consistent decisions, no cross-stage contradictions, owned evidence/acceptance/blocking conditions for every qualification, and HIGH findings closed or explicitly gated. | Gate 3 PASS requires independent reviewer verdict. It never authorizes Gate 4; separate explicit product-owner authorization is required. |

## Cross-stage reconciliation and residual findings

The Master Plan and IP-1–IP-7 now express the decisions above with ownership aligned to the input → transformation → serialization → transport/consent → UI → consumer/release flow. The seven-stage implementation roadmap and IP-2A–IP-2E decomposition remain unchanged. The signed app/DMG direction is fixed as architecture, while feasibility evidence remains pending. No ECDIS geometry equivalence is claimed; distance remains advisory and cannot choose or alter a route.

The continuity principle is resolved, but its technical proof is not. Other technical qualifications remain explicitly blocking at their owning stages: RTZ/GPX schema acquisition, licensing and offline validation; exact supported RTZ dialects and field semantics; +180° representability; source-file alias/security-scoped URL and File Provider handling; Shortcuts-to-CLI authority and transport; confirmation replay/preview binding; output permissions, atomicity, target races and provider behavior; geometry numerical bounds; actual Windy mandatory consumer results; signing/notarization, Gatekeeper and supported macOS floor; privacy-safe diagnostics and evidence.

Optional loss-report sidecar format/save/privacy remains a technical/product-scope item in IP-4/IP-5/IP-7. It must be explicitly dispositioned before any sidecar implementation; it does not block the core GPX contract if deferred. No new product behavior is inferred here.

## Verification and change inventory

The reconciliation edits only `docs/RTZ-GPX-PLAN.md`, IP-1 through IP-7 plans, `REPORT.md`, `PROGRESS.md`, and this report. The pre-commit scope check found only these documentation paths; all seven plan files remain present; a consistency search found no live unresolved wording for the decided route-name, one-point, or package policies; `git diff --check` is clean. Tracked-path inspection found no RTZ/RTZP/GPX route files or certificate/key container files. No application code or implementation artifacts were added. No tests, builds, scripts, fixtures, schemas, probes, Windy imports, or platform experiments were run.

**Historical final governance state at R1 publication:** Gate 3 reconciliation complete and awaiting independent architecture review; Gate 3 PASS not declared; Gate 4 and implementation NOT AUTHORIZED.


## Independent Architecture Review Closure

Architect independently reviewed and accepted the R1 reconciliation at commit f98f43618ad69c347fc8a071d741b9719714b934. The review found G3-001 through G3-011 cross-stage consistent; the seven-stage roadmap intact; product/architecture decisions distinct from unresolved technical qualification; every remaining technical qualification assigned an owning stage and stop condition; no open HIGH cross-stage contradiction; and export-only route naming consistent across transformation, serialization, transport and UX.

The accepted findings preserve all technical qualification boundaries and blockers in the original decision ledger. Source identity/content continuity; Shortcuts-to-CLI authority and safe transport; security-scoped/file-reference/File Provider behavior; atomic publication and target races; geometry algorithms/bounds/tolerances; RTZ/GPX schemas, licensing and offline validation; +180° representation; mandatory empirical Windy acceptance; signing/notarization/Gatekeeper/macOS support; and privacy-safe diagnostics/evidence remain unqualified. The optional loss-report sidecar remains subject to explicit product-scope disposition before any sidecar implementation. No pending qualification is promoted to PASS.

**Historical remote governance event:** Gate 3: PASS / ARCHITECT ACCEPTED was recorded at `d9f723ba91091c682c9676f41dc168da31a252f1`. **Effective current governance:** Gate 3 PENDING FINAL INDEPENDENT ARCHITECT REVIEW; the historical declaration is superseded for current authorization. Gate 4, stage execution, and overall implementation remain NOT AUTHORIZED.
