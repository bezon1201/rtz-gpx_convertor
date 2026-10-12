# IP-1A — RTZ and GPX Schema Qualification Record

**Execution status: PARTIAL — R2 rights/provenance research recorded; external confirmations outstanding.** This record is not an IP-1 PASS, version support claim, legal opinion, implementation authorization, or independent sign-off. RTZ 1.0 and 1.2 remain mandatory qualification targets; RTZ 1.1 remains conditional and non-blocking. No schema is included in the repository or approved for application bundling.

**Repository baseline:** `b9c7d0a7dbee25244f2119fc57b296fbe4b30876`

**Execution branch:** `implementation/ip-1a-standards-schema-baseline`

**Research/validation date:** 2026-10-12
**Validation tool:** `xmllint` (libxml2), using `--nonet`; no application parser/runtime was exercised.

## IP-1A R2 status summary

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

## 4. IP-1A qualification verdict

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

## 5. Offline runtime validation strategy (R2)

The approved requirement is full schema-backed validation while the converter is offline. None of these candidates closes legal clearance or implementation qualification by itself.

| Candidate | Rights status | Runtime/distribution characteristics | Assessment |
|---|---|---|---|
| **A. Authorized XSD resources in the signed app; system-provided libxml2** | **BLOCKED** until written permission covers each schema and its application distribution/use | Smaller package and no separately shipped XML engine. libxml2 exposes XSD validation APIs; however, public API availability, XSD support, supported macOS range, and behavior across OS versions have not been verified for this project. System updates may change engine behavior. | Viable only if target macOS versions provide the needed API and this is verified later. Not qualified here. |
| **B. Authorized XSD resources plus pinned, statically linked libxml2 in the signed CLI** | XSD rights **BLOCKED**; libxml2’s upstream project states MIT license. Include its license/notice and dependency inventory. | Self-contained and engine-version-pinned; avoids Homebrew/Python and runtime network. Requires controlled source/build and architecture/deployment-target qualification, security patch ownership, and accurate third-party notices. Static linking does not resolve schema rights. Apple documents a nested command-line tool in a macOS app and distribution-signing/notarization workflows. | **Preferred technical candidate**, conditional on rights and later build, signing, offline, and supported-OS verification. No build was performed. |
| **C. User-supplied or separately acquired schema under a license allowing local use** | **CONDITIONAL** on an applicable license authorizing the user’s acquisition and this application’s validation use | Can avoid project redistribution only if the user lawfully obtains the schema separately and supplies/installs it locally. Offline use can follow setup. Adds difficult setup, source/hash verification, exact version/namespace pairing, and support burden; weakens self-contained first-run usability. A separate schema download shipped by the project remains redistribution. | Contingency only if owner accepts the setup cost and written license permits it. Not approved. |
| **D. Custom checks or partial schema reimplementation** | **UNRESOLVED**; derivative-rights analysis needed if based on protected schema/spec text | A partial checker can omit ordering, cardinality, datatype, wildcard, and namespace constraints, so it is not equivalent to full XSD validation. A clean-room equivalent implementation would require rights-cleared source material and extensive conformance evidence. | **Not an acceptable current substitute** for the approved schema-backed requirement. Reconsider only with rights-cleared source and explicit architectural approval. |
| **E. Fetch XSDs at runtime or use a remote validation service** | Does not resolve rights | Requires network and adds availability, privacy, and security dependencies. | **Out of scope** for the fully offline product. |

### Recommended candidate and security requirements

Conditionally pursue candidate B: after written rights for the exact schemas, pin approved RTZ 1.0, RTZ 1.2, and GPX 1.1 artifacts by version, namespace, and digest; include immutable permitted schemas as app resources; statically link a pinned supported libxml2 build into the bundled CLI; include required notices; and sign/notarize the nested CLI and app. This is a research recommendation, **not clearance, a selected implementation, or an implementation authorization**. If permission is denied, stop for product/architectural/legal review; do not silently substitute D or E.

Future validation must select only locally pinned schemas through a closed resolver; ignore input `xsi:schemaLocation`; reject or disable DTDs, external entities, XInclude, and unapproved schema/resource loads; avoid entity substitution; enforce input/parser resource bounds; and avoid logging route contents. The exact APIs, resource loader, supported library build, and hardened behavior require review and adversarial checks in an authorized implementation stage. Upstream libxml2 documentation says `XML_PARSE_NONET` no longer disables built-in network access in versions where the built-in clients have been removed; custom resource loaders remain a separate boundary. Therefore `--nonet` alone is not a sufficient production guarantee. R1’s `xmllint --nonet` results remain only schema evidence, not runtime offline qualification.

### Technical comparison evidence

- Upstream libxml2 documents [schema parse/validation APIs](https://gnome.pages.gitlab.gnome.org/libxml2/html/xmlschemas_8h.html), its [MIT license](https://gnome.pages.gitlab.gnome.org/libxml2/), and [parser controls/resource loaders](https://gnome.pages.gitlab.gnome.org/libxml2/html/parser_8h.html). Those facts establish technical plausibility but not availability of a particular macOS system library/API or runtime behavior for this application.
- Apple documents [embedding a command-line tool in a macOS app](https://developer.apple.com/documentation/xcode/embedding-a-helper-tool-in-a-sandboxed-app) and [distribution-signing/notarizing Mac code](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac/). This supports packaging feasibility in principle; no project build or notarization was attempted.
- GPX 1.1 and both RTZ XSDs inspected in R1 have no imports/includes, simplifying a local closed schema set. RTZ 1.1 STM extension package has an unresolved relative import and remains conditional/non-blocking.

## 6. Ready-to-send publisher inquiries (not sent)

No external messages were sent. These drafts require separate user authorization before sending.

### CIRM — provenance and RTZ rights

**To:** office@cirm.org

**Subject:** RTZ schema 1.2 provenance and redistribution permission for offline macOS application

> CIRM’s RTZ XML Schemas page lists document 64 as `RTZ_Schema_version_1_2.xsd` (version 1.2, dated 2020-10-22). Its SHA-256 is `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff`; its header says `Source: IEC PAS 6XXXX`. CIRM’s document 65 text-format download is byte-identical. IEC’s PAS 61174-1:2021 page says the PAS provides the revised RTZ 1.2 schema. Please confirm:
>
> 1. Is this exact CIRM-published file the RTZ 1.2 schema corresponding to IEC PAS 61174-1:2021? Can CIRM identify the correct source reference and explain/correct the `6XXXX` placeholder? Is there an authoritative checksum, release record, or IEC-to-CIRM artifact mapping?
> 2. Who holds copyright/licensing authority for the RTZ 1.0 and 1.2 XSDs, and can CIRM grant the permissions below, including any necessary IEC permission?
> 3. May the unmodified XSDs be included as local resources in a free or commercial, signed/notarized macOS application/DMG distributed worldwide, and used only for offline local validation? May they be copied in app backups? Please specify attribution, notice, link, source availability, fees, territory, duration, user-count, and update conditions.
> 4. Does permission cover use by a statically linked validator or other compiled/embedded form? Are modifications or normalized copies prohibited? Is byte-for-byte inclusion allowed?
> 5. What rights and notices apply to the RTZ 1.2 sample archive for internal validation without redistribution?
>
> We will not bundle schemas or samples until written terms identify the permitted scope.

### IEC — if CIRM cannot establish lineage or licensing authority

**Contact:** permissions route on the [IEC copyright page](https://webstore.iec.ch/copyright).

**Subject:** Provenance and permission for CIRM-published RTZ 1.0/1.2 XSDs

> CIRM publishes RTZ 1.0 and RTZ 1.2 XSDs. Its 1.2 file (SHA-256 `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff`) has the header `IEC PAS 6XXXX`. IEC’s PAS 61174-1:2021 page says the PAS provides the revised RTZ 1.2 schema and retains RTZ 1.0 unchanged. Does IEC identify this exact file as schema text in or derived from the PAS or IEC 61174:2015? Does CIRM’s publication grant the rights needed to redistribute it, or is separate IEC permission required?
>
> If IEC permission is required, can IEC license inclusion of the exact RTZ 1.0 and 1.2 XSD files as immutable local resources in a free/commercial signed/notarized macOS application distributed worldwide, for offline validation only? Please specify fees, attribution/notice, source-link, modification, sublicensing, territory, duration, update, and user-count terms. We can provide the files and hashes on request.

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

No source-vessel route, user-provided route, private coordinate, credential, or route digest was used. No R1 validation tests were repeated for R2; R2 added publisher-rights research and a strategy comparison. No publisher inquiry was sent. No schema, test fixture, script, dependency, parser, application code, Shortcuts artifact, or package was added to Git. Static project fixtures are assigned to IP-1B and were not created. IP-1B onward, IP-2–IP-7, and release remain unauthorized.
