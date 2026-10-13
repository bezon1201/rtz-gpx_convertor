# IP-1A — RTZ and GPX Schema Qualification Record

**Current execution status: PARTIAL — R3 public-source review completed; required publisher/legal confirmations and runtime qualification remain outstanding.** This record is not an IP-1 PASS, version support claim, legal opinion, implementation authorization, or independent sign-off. RTZ 1.0 and 1.2 remain mandatory qualification targets; RTZ 1.1 remains conditional and non-blocking. No schema is included in the repository or approved for application bundling.

**Repository baseline:** `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`

**Execution branch:** `implementation/ip-1a-standards-schema-baseline`

**Prior schema research/validation date:** 2026-10-12. **R3 public-source review date:** 2026-10-13.
**Prior validation tool:** `xmllint` (libxml2), using `--nonet`; no application parser/runtime was exercised. R3 did not rerun those checks.

## IP-1A R3 status summary (2026-10-13)

| Topic | R3 status | Finding |
|---|---|---|
| Exact RTZ 1.2 provenance | **PARTIAL / REQUIRES EXTERNAL CONFIRMATION** | IEC confirms PAS 61174-1:2021 defines revised RTZ 1.2, and CIRM publishes the recorded 1.2 artifact. No authoritative checksum or byte-level mapping ties the exact CIRM bytes (`ba569510…81ceff`) to the IEC PAS. The `IEC PAS 6XXXX` placeholder remains unresolved. Do not infer exact provenance from name, namespace, date, or description. |
| RTZ 1.0/1.2 access, local use, repository copying and redistribution | **BLOCKED / NOT CLEARED** | Public CIRM downloads do not establish a license. IEC terms require written permission for reproduction/use of IEC publication material and restrict copying, modification, publication, distribution and derivative works from IEC Products absent written permission. No written CIRM/IEC grant for repository copies, app inclusion, user-local installation, offline validation, or unchanged redistribution was found. Access to a download is not permission for those acts. |
| GPX 1.1 raw XSD | **CONDITIONAL / NOT CLEARED** | Topografix calls the GPX overview-page text public domain and links the official XSD, but the wording does not clearly license the separate raw `.xsd` artifact. Keep its existing digest and test observations; obtain artifact-specific terms/confirmation before copying or bundling. |
| Offline schema validation | **BLOCKED / NO APPROVED RUNTIME** | Candidate A (pinned static libxml2 plus permitted schemas) is technically plausible but needs vulnerability/version qualification, security controls, schema rights, and package verification. Apple facilities and alternative validators have material constraints (see §5). No probe was necessary to distinguish these documented issues; no runtime candidate is qualified. |
| Publisher/legal confirmation | **REQUIRES EXTERNAL CONFIRMATION** | Ready-to-send CIRM, IEC and Topografix inquiries appear in §6. None was sent. Written rights-holder evidence and legal review are still required. |
| **IP-1A R3 verdict** | **PARTIAL** | R3 documents the remaining blockers and candidate limits; it closes no mandatory IP-1A legal/provenance/runtime dependency. Overall IP-1 remains **PARTIAL / NOT PASS**. |

## Historical IP-1A R2 status summary (superseded by R3)

| Topic | Status | Finding |
|---|---|---|
| CIRM publication of RTZ 1.2 artifact | **VERIFIED** | CIRM lists the RTZ 1.2 XSD as document 64, named `RTZ_Schema_version_1_2.xsd`, version 1.2, date 2020-10-22. Its companion text download (document 65) is byte-identical to the XSD download at SHA-256 `ba569510…681ceff`. This verifies the file’s association with CIRM’s published RTZ 1.2 entry. |
| Link from that exact file to IEC PAS 61174-1:2021 content | **CONDITIONAL / REQUIRES EXTERNAL CONFIRMATION** | IEC confirms PAS 61174-1:2021 provides a revised RTZ 1.2 schema; CIRM lists its RTZ 1.2 artifact in that standards context. The artifact’s `IEC PAS 6XXXX` placeholder remains unresolved, and no authoritative artifact checksum or byte-level IEC-to-CIRM mapping was found. The relationship is credible but not proven at exact-file/normative-text level. |
| CIRM RTZ 1.0/1.2 schema redistribution rights | **BLOCKED / REQUIRES EXTERNAL CONFIRMATION** | No applicable license or redistribution grant was found on the public schema page or in the artifact metadata. IEC publication terms require written permission for reproduction/use of IEC publication material. No schema bundling is authorized by this research. |
| GPX 1.1 schema rights | **CONDITIONAL / REQUIRES EXTERNAL CONFIRMATION** | Topografix says all text on its GPX overview page is public domain and links the official XSD, but the statement does not expressly identify the raw XSD artifact or required notices. Seek written confirmation before bundling. |
| Offline validator | **CONDITIONAL RECOMMENDATION; NOT IMPLEMENTATION-READY** | Preferred technical candidate is a locally pinned, statically linked libxml2 validator plus the exact permitted XSDs as signed app resources. This satisfies offline and self-contained goals in principle, but schema rights, supported macOS/API qualification, build/signing verification, and runtime security checks remain open. |
| IP-1A overall | **PARTIAL** | R2 narrows provenance and licensing findings and proposes a technical path. It does not close external rights, runtime strategy qualification, full IP-1A evidence, or independent review. |

## 1. Findings by evidence class

### Verified publisher/source facts

- CIRM’s [RTZ XML Schemas page](https://cirm.org/rtz-xml-schemas/) publishes RTZ 1.0 and 1.2 XSD downloads and a 1.2 test archive. CIRM describes the schemas in the context of IEC 61174 / IEC PAS 61174-1:2021. The downloaded XSDs declare namespaces and fixed version values listed in §2.
- CIRM’s page metadata identifies document 64 as `RTZ_Schema_version_1_2.xsd`, version `1.2`, dated 2020-10-22. Its document 65 text-format download has exactly the same SHA-256 as document 64’s XSD download. This is strong evidence that the checked bytes are CIRM’s published RTZ 1.2 artifact, but does not authenticate the artifact against a checksum or annex supplied by IEC.
- The [IEC PAS 61174-1:2021 record](https://webstore.iec.ch/en/publication/67774) states that the PAS “provides a revised version 1.2 of the RTZ schema” and retains original version 1.0 unchanged. The CIRM artifact’s source comment still says `IEC PAS 6XXXX`. Therefore the **general association** between CIRM’s RTZ 1.2 entry and IEC PAS 61174-1:2021 is supported by both publishers’ descriptions; the **exact-file provenance/identity** is not independently verified and requires CIRM confirmation (and, if CIRM cannot establish its chain, IEC confirmation).
- The [STM schema page](https://www.seatrafficmanagement.info/developers-forum/schemas/) presents RTZ 1.1 as STM validation-project material/proposal and supplies an RTZ 1.1 XSD plus a separate STM extension schema. The RTZ 1.1 file declares namespace `http://www.cirm.org/RTZ/1/1`. The STM extension schema imports that namespace using a relative `rtz.xsd` location; the paired dependency was not provided under that name by the cited page. These materials do not establish a canonical, rights-cleared 1.1 lineage.
- [Topografix GPX 1.1 documentation](https://www.topografix.com/gpx/1/1/) publishes the GPX 1.1 schema. Its namespace is `http://www.topografix.com/GPX/1/1`, the root version is fixed to `1.1`, and the `creator` attribute is required. The [GPX overview](https://www.topografix.com/gpx.asp) describes the page text as public domain; a separate explicit license statement for the XSD artifact was not located during this review.
- IEC’s [copyright terms](https://webstore.iec.ch/copyright) say IEC publications are protected and reproduction or utilization requires written permission. IEC’s [Products & Services Portal terms](https://webstore.iec.ch/en/iec-psp-tc) additionally prohibit copying, modifying, publishing, making available, or creating derivative works from IEC Products absent written permission. This is directly relevant if the exact RTZ XSD content is IEC material; CIRM’s authority to license that content has not been established.

### Qualification decisions and limits

- Exact version/namespace pairs must be treated as inseparable. The checked schemas declare RTZ 1.0 + `http://www.cirm.org/RTZ/1/0` and RTZ 1.2 + `http://www.cirm.org/RTZ/1/2`. This is observed schema metadata, not an implementation allowlist or support claim.
- The checked RTZ schemas require `routeInfo` and `waypoints`; each waypoint has a required position and required non-negative `id`, and the route contains at least two waypoints. `routeInfo` has a required route name. Waypoint order is represented by XML sequence. The schemas carry route/waypoint/leg attributes including names, revision, turn radius, XTD, geometry type, safety/depth, speed and note/report fields. RTZ 1.2 also declares the `Extension`/`NonEmptyString` types and permits extensions on `Leg`; extension semantics are not thereby qualified for transformation.
- Both checked RTZ schemas enumerate only `Loxodrome` and `Orthodrome` for `geometryType`; both use decimal WGS84 coordinates, latitude inclusive from -90 to +90, and longitude inclusive at -180 but exclusive at +180. Thus an RTZ numeric longitude of +180 is rejected by these exact XSDs. This is a schema observation relevant to the already approved fail-closed boundary; it does not revise G3-005 or establish parser behavior.
- The schemas differ beyond the namespace/version and header. Structural inspection found changes in `RouteInfo`, `Route`, `Leg`, `Waypoint`, `RadiusType`, `Calculated`, `Manual`, schedule-related types and extension types; RTZ 1.2 adds `Extension` and `NonEmptyString`, adds `Leg` extensions, changes the schedule element spelling to `scheduleElement`, and constrains radius to 0 through 5 inclusive (1.0 permits 0 through less than 10). The 1.0 waypoint `revision` attribute is optional; 1.2 requires it. Detailed field-by-field semantic mapping remains open for IP-1B/IP-2 and must be checked against normative text before implementation.
- CIRM’s 1.2 test archive includes cases named “Error” that are XSD-valid (duplicate waypoint IDs and route-name/filename mismatch). These observed results show that XSD validity is not semantic conformance; future validation must distinguish schema checks from semantic/application checks.
- **No rights clearance is granted here.** CIRM RTZ XSD redistribution/bundling terms were not found; RTZ 1.0 and 1.2 are **NOT CLEARED FOR BUNDLING**. IEC text/schema use requires written rights confirmation unless CIRM confirms it holds and can grant the needed redistribution rights. GPX 1.1’s public-domain wording covers “all text on this Web page”; the raw XSD is linked as the official schema but is a separate artifact, so its scope and any notice requirements need confirmation. No schema or test archive may be distributed based solely on the fact it is publicly downloadable.

### Rights by act (R3)

| Act | RTZ 1.0/1.2 XSDs | GPX 1.1 XSD |
|---|---|---|
| Access/download from publisher | **VERIFIED as publicly accessible publisher downloads** in prior evidence; this establishes access to those endpoints only. | **VERIFIED as publicly linked/downloadable** from Topografix; this establishes access only. |
| Local examination or use | **REQUIRES EXTERNAL CONFIRMATION.** No applicable terms were found establishing whether downloaded XSDs may be used for local validation or retained as local copies. IEC publication terms may apply if the artifacts contain IEC publication material; the exact rights holder and scope need confirmation. | **CONDITIONAL.** Public-domain wording covers page text but does not clearly cover the raw XSD. Obtain artifact-level confirmation before retaining/using it as an app resource. |
| Copy into this repository, application bundle, or local product installation; redistribute unchanged | **BLOCKED / NOT CLEARED.** No written permission or applicable license found for any of these acts, free/private or commercial distribution, or app updates/backups. | **CONDITIONAL / NOT CLEARED.** No raw-XSD license/notice establishing these permissions was located. |
| Modify, normalize, or create derivative schema copies | **NOT CLEARED.** IEC terms restrict modification of IEC Products absent written permission; CIRM authority over exact files is unconfirmed. | **NOT ESTABLISHED.** No artifact-level terms found. |

These are evidence dispositions, not legal conclusions. No written permission was obtained, and no schema copy is authorized by this research.

## 2. Artifact provenance and identity

All downloads were made on 2026-10-12 from the listed publisher pages/download endpoints. SHA-256 is over the exact downloaded file, except where stated for decompressed STM files. Artifacts remain in temporary storage and are not committed.

| Artifact | Publisher/source | Declared identity | Bytes | SHA-256 | Imports/includes | Rights/runtime disposition |
|---|---|---|---:|---|---|---|
| RTZ 1.0 XSD | [CIRM download](https://cirm.org/api/documents/download/62), listed as “RTZ_ Schema_version 1_0.xsd” | Revision 1.0; `http://www.cirm.org/RTZ/1/0`; version fixed `1.0`; header cites IEC 61174 Ed.4.0:2015 | 30,551 | `c63f002fe9ffa55a45d770cc642b62de7f4a8ef30e87f92a5540e1e5ad332072` | None observed | CIRM publication association verified; exact rights/IEC lineage not cleared |
| RTZ 1.2 XSD | [CIRM download](https://cirm.org/api/documents/download/64), listed as “RTZ_Schema_version_1_2.xsd”; document 65 is byte-identical text copy | Revision 1.2; `http://www.cirm.org/RTZ/1/2`; version fixed `1.2`; header says `IEC PAS 6XXXX` | 32,793 | `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff` | None observed | CIRM publication association verified; exact IEC lineage and all redistribution rights remain unresolved |
| CIRM RTZ test archive | [CIRM download](https://cirm.org/api/documents/download/66) | `RTZ_v1.2_test_files.zip` | 30,406 | `848d427fbffd0e60bbb2fac29b9f33fcc46226e0f409157f0220233c0dc24bf5` | Contains RTZ test files; `.rtzp` entries were excluded from validation | Public download, no separate reuse license located; not committed |
| RTZ 1.1 STM proposal XSD | [STM schema page](https://www.seatrafficmanagement.info/developers-forum/schemas/) linked artifact; SHA over decompressed XML | Revision 1.1; `http://www.cirm.org/RTZ/1/1`; header says IEC 61174 | 30,244 decompressed | `d9b382f6208c805a4c4f8718b2e93e2a6ab87158dc6accda9f2682286a791ba2` | No schema import observed in this RTZ XSD | Proposal lineage; rights/normative standing unverified; conditional only |
| STM extensions XSD | [STM schema page](https://www.seatrafficmanagement.info/developers-forum/schemas/) linked artifact; SHA over decompressed XML | Revision 1.0.0; `http://stmvalidation.eu/STM/1/0/0` | 9,327 decompressed | `b38b9449d93b7ee24308e86e49675b49418e8342b143b36e02e9a91b5c527e88` | Imports RTZ 1.1 namespace with relative `schemaLocation="rtz.xsd"` | Dependency pairing and rights unresolved; not a qualified 1.1 package |
| GPX 1.1 XSD | [Topografix direct XSD](https://www.topografix.com/GPX/1/1/gpx.xsd) | GPX 1.1; `http://www.topografix.com/GPX/1/1`; root version fixed `1.1` | 26,665 | `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6` | None observed | Likely covered by public-domain page statement, but raw XSD scope/notice needs confirmation |

The IEC publication record identifies PAS 61174-1:2021 as published 2021-03-03. The STM source artifacts were served with gzip transfer encoding; the table hashes the decompressed XML bytes. Transfer-encoded byte hashes were not retained as qualification identities.

## 3. Offline validation evidence

### Approach

Used `xmllint` from the local libxml2 installation with `--nonet --noout --schema`. XSD syntax compilation also used `xmllint --nonet --noout <schema>`. Temporary files, downloaded schemas, and official samples were confined to `/tmp/rtz-ip1a-schemas`; none are repository fixtures. No application code, parser, unit-test suite, or runtime dependency was used. `--nonet` prevents network schema resolution during these checks; this is not a platform-wide network-isolation test.

### Schema syntax

| Schema | Result |
|---|---|
| RTZ 1.0 XSD | PASS: parsed/compiled locally |
| RTZ 1.2 XSD | PASS: parsed/compiled locally |
| STM RTZ 1.1 proposal XSD (decompressed) | PASS: parsed/compiled locally |
| GPX 1.1 XSD | PASS: parsed/compiled locally |

### Official CIRM RTZ sample archive

Validated 16 `.rtz` files against the matching checked schema selected from the sample root `version`; the archive is CIRM’s published 1.2 test archive and includes one RTZ 1.0 example. No `.rtzp` was extracted or tested.

**9 XSD-valid:** `BasicRoute.rtz`, `BasicRouteWithOptionalAttributes.rtz`, `DefaultWaypoint.rtz`, `DuplicateWaypointIdError.rtz`, `ManufacturerExtensions.rtz`, `RTZ1.0MandatoryElementsAndAttributes.rtz`, `RTZ1.2AllOptionalElementsAndAttributes.rtz`, `RevisionAttribute.rtz`, `RouteNameDoesNotMatchFilenameError.rtz`.

**7 XSD-invalid:** `EsotericRouteInfoError.rtz`, `EsotericScheduleError.rtz`, `GeometryTypeError.rtz`, `MissingWaypointIdError.rtz`, `NegativeRevisionError.rtz`, `NonsenseGeometryTypeError.rtz`, `ScheduleError.rtz`.

The two XSD-valid files whose names imply semantic errors confirm a layer boundary: duplicate-ID detection and route-name/filename policy are not established by these XSD checks. No claim is made that these 16 examples exhaust the standards or vendor dialects.

### Additional synthetic boundary checks

- RTZ 1.0 CIRM sample against RTZ 1.0 XSD: PASS.
- RTZ 1.2 CIRM `BasicRoute.rtz` against RTZ 1.2 XSD: PASS.
- A temporary copy with longitude changed to `180`: expected rejection confirmed by `maxExclusive` facet. No source archive file was changed.
- A temporary, synthetic two-point GPX 1.1 route with `creator`, `rte/name`, and ordered `rtept`: PASS.
- The same GPX with root version changed to `1.0`: expected rejection confirmed by the fixed `1.1` constraint.
- The same GPX with latitude changed to `91`: expected rejection confirmed by the `maxInclusive` facet.

Representative exact commands:

```text
xmllint --nonet --noout /tmp/rtz-ip1a-schemas/rtz-1.0.xsd
xmllint --nonet --noout --schema /tmp/rtz-ip1a-schemas/rtz-1.0.xsd /tmp/rtz-ip1a-schemas/tests/RTZ_v1.2_test_files/RTZ1.0MandatoryElementsAndAttributes.rtz
xmllint --nonet --noout --schema /tmp/rtz-ip1a-schemas/rtz-1.2.xsd /tmp/rtz-ip1a-schemas/tests/RTZ_v1.2_test_files/BasicRoute.rtz
xmllint --nonet --noout --schema /tmp/rtz-ip1a-schemas/gpx-1.1.xsd /tmp/rtz-ip1a-schemas/gpx-positive.gpx
```

Negative cases were run with the same schema-validation form; each returned nonzero with the facet diagnostic described above. No test command invokes project application code.

## 4. Historical R2 qualification verdict (superseded by R3)

**IP-1A: PARTIAL.** There is reproducible positive and negative XSD evidence for the downloaded artifacts. This is not the approved plan’s full PASS evidence:

1. **RTZ 1.0:** CIRM publication association, schema syntax and one official positive sample are verified. Exact normative lineage/rights, full required positive/negative synthetic matrix, normative field semantics, independent review, and legal/runtime clearance remain open. **Not qualified for V1 support or bundling.**
2. **RTZ 1.2:** CIRM publication association, schema syntax and matching CIRM sample evidence are verified. Its general association with IEC PAS 61174-1:2021 is supported by both publisher descriptions, but exact-file identity against the IEC schema is not confirmed; the XSD header’s `IEC PAS 6XXXX` placeholder remains unresolved. Normative field comparison, complete synthetic matrix, independent review, and legal/runtime clearance remain open. **Not qualified for V1 support or bundling.**
3. **RTZ 1.1:** a proposal and extension artifact are identifiable, but lineage, dependency completeness, normative standing and rights are unresolved. It remains conditional and is not a release blocker; do not enable it by fallback.
4. **GPX 1.1:** the official schema parses and representative positive/negative documents validate locally. Topografix’s public-domain statement applies explicitly to page text; whether it covers the linked XSD and what notice to carry remain unconfirmed. No GPX serializer is implemented or verified.
5. **Runtime:** no schema artifact is committed, bundled, modified, installed, or selected for a target-Mac runtime. Candidate B in §5 is the preferred technical direction, conditional on external rights, legal and later platform qualification.

### Open qualification questions and owners

| Question | Owner / closure point |
|---|---|
| Confirm the exact CIRM 1.2 artifact provenance and resolve its `IEC PAS 6XXXX` header | Requires CIRM; escalate to IEC if CIRM cannot establish lineage; before pinning a V1 allowlist |
| Confirm CIRM XSD and test archive license/redistribution terms, and IEC permission requirements | Requires written CIRM/IEC terms plus legal review; before any bundling |
| Confirm GPX XSD legal status and notices for application distribution | Requires written Topografix confirmation or artifact-specific license; before bundling |
| Establish a legally cleared offline schema-backed runtime validation strategy without weakening validation | Candidate B; IP-1A/IP-5 architectural review and later target-macOS verification; before runtime implementation |
| Complete schema-backed synthetic fixture catalog, semantic-vs-XSD checks, and full field/loss mapping | IP-1B/IP-2, under separate authorization |
| Independent review/sign-off of artifact hashes, field matrix, legal status, and validation evidence | Independent Architect; before declaring the applicable qualification PASS |
| Validate exact version/namespace dispatch and fail-closed parser behavior | IP-2; not tested here |

## 5. Offline runtime validation strategy (R3)

The approved requirement remains full schema-backed validation while the converter is offline. No candidate is approved or qualified. This is a technical comparison, not a legal opinion; permissions for each exact XSD remain separate from validator licensing.

| Candidate | Technical feasibility and XSD 1.0 support | Security, offline behavior and versioning | License/distribution and assessment |
|---|---|---|---|
| **A. Pinned, statically linked libxml2 plus permitted, pinned XSD resources** | libxml2 exposes XML Schema parse/validation APIs and supports XSD 1.0; a pinned arm64 build can be embedded in the self-contained CLI. | Supports a closed local resolver and deterministic engine version in principle. Must ignore document-provided `xsi:schemaLocation`, reject DTD/entity input, deny all unapproved resource loads, bound work/memory, and be patched and regression-qualified. NIST records CVE-2026-6732 affecting libxml2 2.13.0 through <2.15.3: a crafted schema-validated document with an internal entity can cause a DoS. Pin only a reviewed fixed release (NVD currently identifies 2.15.3 as the first non-affected upstream version), then track security advisories and test the exact build. Rejecting DTDs/entities is additional defense, not a replacement for a fixed library. | libxml2 is MIT-licensed; include applicable notices. That license does not grant RTZ/GPX schema rights. Self-contained/offline and likely the best fit **if** rights clear and exact build security, macOS deployment, signing and validation evidence pass. Not implementation-ready or selected. |
| **B. Apple/system XML facilities** | `XMLDocument.validate()` provides an XSD validation API, but project-safe deterministic use of only pinned local schemas and exact required XSD 1.0 behavior across the proposed macOS matrix is unverified. Apple documents schema validation through the document; the current document may supply `xsi:schemaLocation`. `XMLParser` alone does not provide schema validation. | The instance-supplied schema location or external-resource handling must not cause network/path access; no empirical qualification exists for denial controls, version consistency, resource bounds, or behavior across OS releases. System updates can change the engine, weakening reproducibility. | Avoids bundling a third-party validator, but does not resolve schema rights. Candidate only if documented Apple API behavior and an authorized target-macOS qualification prove the closed local-resource design. Not qualified. |
| **C. Another self-contained validator (e.g. Xerces-C++)** | Xerces-C++ advertises XML Schema support and Apache License 2.0; technically embeddable, subject to XSD 1.0 feature and arm64 deployment verification. | Its upstream security page says it has no active maintainers, will no longer accept DoS reports as security vulnerabilities, and lists an unaddressed hash-collision DoS advisory. That maintenance posture is unsuitable for processing untrusted route documents without a compelling, independently supportable mitigation. Any alternative must also prove closed resolver/no-network behavior, resource limits, pinned version and patch ownership. | Apache-2.0 notices are manageable, but validator code licensing does not clear schema rights. **Not recommended** for V1 on current security/maintenance evidence. A different validator requires an explicit supported-security and XSD-conformance case; no dependency was installed. |
| **D. User-supplied, separately obtained and licensed XSD resources** | Could validate offline if users obtain the exact authorized schema set and the application enforces its version/namespace/digest pairing and closed local resolver. | Adds first-run setup, schema authenticity/update/support burden, and risks mismatched or unsafe external resources. It is not self-contained on first launch; the application must never fetch schemas. | Could avoid project redistribution only if user acquisition and local use are expressly licensed and legally reviewed. It does not meet the approved self-contained product direction by default. Any V1 change requires owner/architect approval; not approved. |

**Conclusion:** Candidate A is the leading technical direction, conditional and unselected. It is not cleared for use until (1) exact schema rights and provenance are established, (2) an appropriate fixed libxml2 version/build receives security review and adversarial offline/resolver qualification, and (3) target-macOS, signing/notarization and output validation are verified. If A is infeasible or rights are denied, stop for an explicit architecture/product decision; do not silently weaken schema-backed validation or switch to a partial custom checker. Candidate D remains a potential product-direction change, not a workaround approved by this task.

Security requirements for any future validator remain: select only locally pinned schemas by exact version/namespace; ignore instance-provided schema locations; reject/disable DTDs, external entities, XInclude and unapproved resource resolution; no network schema fetch or remote service; avoid entity substitution; enforce bounded reads, parse work and memory; do not log route contents; pin and monitor validator releases. `--nonet` alone is not a production guarantee. Prior `xmllint --nonet` results remain schema observations and do not qualify a packaged runtime.

### Runtime and rights evidence

- IEC says PAS 61174-1:2021 provides revised RTZ 1.2 while retaining RTZ 1.0 unchanged ([IEC publication record](https://webstore.iec.ch/en/publication/67774)). IEC copyright says publication use requires written permission, and current Webstore terms prohibit copying, modifying, publishing or making IEC Products available without written permission ([copyright](https://webstore.iec.ch/copyright), [terms](https://webstore.iec.ch/terms-conditions)). This does not establish that CIRM may grant rights over the exact XSDs; obtain written authority/permission.
- Topografix’s GPX overview says “All text on this Web page is in the public domain” and links the official GPX schema ([overview](https://www.topografix.com/gpx.asp)). That wording does not expressly identify the raw XSD download. Keep GPX XSD rights conditional pending artifact-specific confirmation.
- libxml2 upstream documents its [MIT license and security posture](https://github.com/GNOME/libxml2); the NVD describes [CVE-2026-6732](https://nvd.nist.gov/vuln/detail/CVE-2026-6732), affecting upstream versions 2.13.0 through <2.15.3. Pinning a version alone is insufficient: security updates and the exact build must be reviewed. NVD version data is a screening input, not a substitute for upstream advisory/build verification.
- Apple documents [`XMLDocument.validate()`](https://developer.apple.com/documentation/foundation/xmldocument/validate%28%29) and [`XMLParserDelegate`](https://developer.apple.com/documentation/foundation/xmlparserdelegate); these APIs do not by themselves establish this product’s required local-only schema dispatch, complete XSD behavior, or safe untrusted-input runtime.
- Xerces-C++ documents its [security and maintenance limitations](https://xerces.apache.org/xerces-c/secadv.html), including lack of active maintainers and DoS support limits. It is not recommended here.

No temporary technical probe was necessary to distinguish these candidates from the available primary documentation. No probe, dependency installation, build, or runtime test was performed in R3.

## 6. Ready-to-send publisher inquiries (not sent)

No external messages were sent. These drafts require separate user authorization before sending.

### CIRM — provenance and RTZ rights

**To:** office@cirm.org

**Subject:** Exact RTZ XSD provenance and rights for repository copies and an offline application

> CIRM’s RTZ XML Schemas page lists document 64 as `RTZ_Schema_version_1_2.xsd` (version 1.2, dated 2020-10-22). Its SHA-256 is `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff`; its header says `Source: IEC PAS 6XXXX`. CIRM’s document 65 text-format download is byte-identical. IEC’s PAS 61174-1:2021 page says the PAS provides the revised RTZ 1.2 schema. Please confirm:
>
> 1. Is this exact CIRM-published file the RTZ 1.2 schema corresponding to IEC PAS 61174-1:2021? Can CIRM identify the correct source reference and explain/correct the `6XXXX` placeholder? Is there an authoritative checksum, release record, or IEC-to-CIRM artifact mapping?
> 2. Who holds copyright/licensing authority for the RTZ 1.0 and 1.2 XSDs, and can CIRM grant the permissions below, including any necessary IEC permission?
> 3. May the exact RTZ 1.0 and 1.2 XSDs be copied into a public or private software repository, and then redistributed unchanged as local resources installed with a free or privately distributed offline application? Does the answer differ for non-commercial versus commercial use?
> 4. Is local offline validation against the bundled, unchanged XSD copies permitted? Does permission cover a signed/notarized macOS application/DMG, app backups and updates? What attribution, license text, notices, links, fees, territory, duration, user-count, source-availability or other conditions apply?
> 5. Are modifications, normalized copies, or embedding/packaging with a statically linked validator restricted? Is byte-for-byte inclusion permitted?
> 6. What rights and notices apply to the RTZ 1.2 sample archive for internal validation without redistribution?
>
> We will not bundle schemas or samples until written terms identify the permitted scope.

### IEC — if CIRM cannot establish lineage or licensing authority

**Contact:** permissions route on the [IEC copyright page](https://webstore.iec.ch/copyright).

**Subject:** Provenance and permission for CIRM-published RTZ 1.0/1.2 XSDs

> CIRM publishes RTZ 1.0 and RTZ 1.2 XSDs. Its 1.2 file (SHA-256 `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff`) has the header `IEC PAS 6XXXX`. IEC’s PAS 61174-1:2021 page says the PAS provides the revised RTZ 1.2 schema and retains RTZ 1.0 unchanged. Does IEC identify this exact file as schema text in or derived from the PAS or IEC 61174:2015? Does CIRM’s publication grant the rights needed to redistribute it, or is separate IEC permission required?
>
> If IEC permission is required, can IEC license inclusion of the exact RTZ 1.0 and 1.2 XSD files as immutable local resources in a free/commercial signed/notarized macOS application distributed worldwide, for offline validation only? Please specify fees, attribution/notice, source-link, modification, sublicensing, territory, duration, update, and user-count terms. We can provide the files and hashes on request.

> Please also state whether the exact XSD files may be copied into a public or private source repository before release, retained locally for validation, installed with the application, redistributed unchanged in free/private or commercial products, and copied in updates/backups. Identify whether CIRM is authorized to grant those permissions and whether IEC permission is required.

### Topografix — GPX 1.1 XSD rights

**Contact:** the maintainer/contact route linked from the [Topografix GPX overview](https://www.topografix.com/gpx.asp) or its GPX Developers channel.

**Subject:** Does the GPX public-domain statement cover the GPX 1.1 XSD artifact?

> The GPX overview states “All text on this Web page is in the public domain” and links the official GPX 1.1 schema at `https://www.topografix.com/gpx/1/1/gpx.xsd`. Does this statement expressly cover the downloadable XSD file and its embedded documentation/comments? May we include the unmodified XSD in a free/commercial signed/notarized macOS application/DMG distributed worldwide and use it for offline validation? Is attribution, a license/copyright notice, or a source link required or requested? If the XSD has a different status from the page text, please identify its license and scope.

### Evidence required to close

- Written response from the rights holder or authorized licensor identifying the exact artifact/version and granting or denying app distribution and local validation rights.
- Explicit scope for free/commercial use, worldwide distribution, offline use, immutable/compiled inclusion, app updates, source notices, attribution, term, and fees; or precise restrictions enabling a compliant alternative.
- CIRM confirmation of the 1.2 file’s relationship to PAS 61174-1:2021 and resolution of `IEC PAS 6XXXX`, ideally with corrected artifact or publisher-confirmed digest.
- Topografix confirmation or artifact-specific license covering the raw GPX XSD.
- Legal review of written terms and independent Architect acceptance of any resulting offline runtime strategy.

## 7. Scope and privacy record

No source-vessel route, user-provided route, private coordinate, credential, or route digest was used. R3 did not repeat accepted R1/R2 schema-validation evidence. R3 reviewed public publisher, standards, platform, validator-license, and security sources; no publisher inquiry was sent. No probe, schema, test fixture, script, dependency, parser, application code, Shortcuts artifact, or package was created or added to Git. Static project fixtures are assigned to IP-1B and were not created here. This task authorizes IP-1A R3 only; IP-2–IP-7 execution and release remain unauthorized.
