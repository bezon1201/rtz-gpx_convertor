# IP-1A R4 — External Provenance and Schema-Rights Confirmation

**Stage:** IP-1A R4. **Authorization:** external-confirmation preparation and outreach for IP1-B01/B02 only. **Current status:** two inquiries SENT; awaiting responses. No reply, confirmed receipt, or rights clearance is claimed.

**Baseline:** `2630843a60f573856183fbc92a0fcccdaf45b3e7` (`implementation/ip-1a-r4-external-confirmation`).

## 1. Scope and safeguards

R4 seeks written, artifact-specific provenance and rights evidence for mandatory RTZ 1.0/1.2 and GPX 1.1 qualification. It does not perform legal analysis, acquire or attach schema files, change schema hashes, qualify a runtime, or alter the product contract. No schema, sample archive, route, or private coordinate is sent. An informal response, silence, generic standards association, or public download does not close a blocker. Received restrictions must be preserved accurately and reviewed independently.

The intended product use described in the inquiries is a locally installed, fully offline macOS application with a bundled schema resource set and local validation. The app may be privately shared with a limited set of intended users; no public/commercial redistribution is being requested by these inquiries. The recipient is asked to identify if that limited private use requires additional permission or differs from individual use.

## 2. Artifact identity checked before outreach

Identities below are copied from the existing IP-1A qualification record; R4 did not download or replace any artifact.

| Artifact | Publisher identity | Version / namespace | SHA-256 |
|---|---|---|---|
| RTZ schema | CIRM document 62, `RTZ_ Schema_version 1_0.xsd` | 1.0 / `http://www.cirm.org/RTZ/1/0` | `c63f002fe9ffa55a45d770cc642b62de7f4a8ef30e87f92a5540e1e5ad332072` |
| RTZ schema | CIRM document 64, `RTZ_Schema_version_1_2.xsd`; document 65 text copy previously recorded byte-identical | 1.2 / `http://www.cirm.org/RTZ/1/2`; header placeholder `IEC PAS 6XXXX` | `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff` |
| GPX schema | Topografix official GPX 1.1 XSD, `https://www.topografix.com/GPX/1/1/gpx.xsd` | 1.1 / `http://www.topografix.com/GPX/1/1` | `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6` |

The RTZ 1.2 exact-file lineage remains unconfirmed. Hashes identify the artifacts previously checked in IP-1A; they do not establish licensing or authority.

## 3. Outgoing inquiry record — messages sent

### CIRM — provenance and RTZ schema rights

- **Recipient/channel:** `office@cirm.org`, as listed in the approved IP-1A inquiry draft.
- **Subject:** Exact RTZ XSD provenance and rights for a locally installed offline converter.
- **Status:** Sent 2026-10-14 09:59:43 UTC. Gmail message ID `1a139da7fde05dbd`.
- **Artifacts:** RTZ 1.0 hash `c63f002fe9ffa55a45d770cc642b62de7f4a8ef30e87f92a5540e1e5ad332072`; RTZ 1.2 hash `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff`.

**Exact outgoing text:**

> Hello CIRM,
>
> We are qualifying the RTZ schemas for a small, fully offline macOS application that validates RTZ routes locally and exports GPX. The intended package is a locally installed, signed/notarized application with unchanged local schema resources. We may privately share the app with a limited set of intended users; we are not requesting public or commercial redistribution rights in this inquiry. Please tell us if that private use requires a separate permission.
>
> CIRM’s RTZ XML Schemas page identifies document 62 as the RTZ 1.0 XSD (`RTZ_ Schema_version 1_0.xsd`), SHA-256 `c63f002fe9ffa55a45d770cc642b62de7f4a8ef30e87f92a5540e1e5ad332072`. It identifies document 64 as `RTZ_Schema_version_1_2.xsd`, version 1.2, dated 2020-10-22, SHA-256 `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff`. The 1.2 header says “Source: IEC PAS 6XXXX”; the previously checked document 65 text download was byte-identical to document 64.
>
> **Provenance:** Is the exact document 64 artifact identified above the RTZ 1.2 schema associated with IEC PAS 61174-1:2021? Can CIRM identify the applicable publication/edition and explain or correct the `6XXXX` placeholder? If that is not the authoritative artifact, please identify the authoritative filename, revision, and publisher record or checksum mapping. Does the RTZ 1.0 artifact correspond to IEC 61174 Ed.4.0:2015 as its header indicates?
>
> **Rights and permitted use:** Who holds rights in these exact XSD artifacts, and is CIRM authorized to grant permissions for them, including any permission required from IEC? May we retain and use unchanged copies for local offline validation, include those copies as resources in the signed/notarized macOS app and DMG, and provide the same app privately to a limited set of intended users? Please identify whether private distribution, backups, and app updates require additional permission or differ from individual use. Please state any required notices, attribution, license text, source link, fees, or restrictions on byte-for-byte inclusion or modification.
>
> We are not asking you to send schema files. We will not copy or bundle these schemas until we have written terms identifying the permitted scope. Please reply in writing and identify any conditions or questions that should be directed to IEC.
>
> Thank you.

### Topografix — GPX 1.1 XSD rights

- **Recipient/channel:** `support@expertgps.com`. Topografix's [GPX overview](https://www.topografix.com/gpx.asp) links its maintainer Dan Foster to the [ExpertGPS support page](https://www.expertgps.com/support.asp), which publishes this email address. This is the publisher-linked contact route used for the private schema-rights inquiry.
- **Subject:** Does the GPX public-domain statement cover the GPX 1.1 XSD artifact?
- **Status:** Sent 2026-10-14 09:59:58 UTC. Gmail message ID `1a139dabaa25c3a0`.
- **Artifact:** `https://www.topografix.com/GPX/1/1/gpx.xsd`, SHA-256 `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6`.

**Exact outgoing text:**

> Hello Dan,
>
> We are qualifying the official GPX 1.1 XSD for a small, fully offline macOS RTZ-to-GPX converter. The exact artifact previously checked is `https://www.topografix.com/GPX/1/1/gpx.xsd`, SHA-256 `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6`.
>
> The GPX overview says that all text on that webpage is public domain and links the XSD. Does that public-domain statement also apply to the downloadable XSD file and its embedded comments/documentation? May we keep an unchanged local copy for offline validation, include it as a resource in a locally installed signed/notarized macOS app/DMG, and privately share that app with a limited set of intended users? We are not requesting public or commercial redistribution rights in this inquiry; please tell us whether the described private use requires separate permission or has different terms.
>
> Please identify any attribution, copyright/license notice, source link, or other condition required or requested for those uses. If the XSD has a different status from the overview-page text, please identify the applicable license or rights holder. We are not asking you to send a schema file and will not bundle it until the permitted scope is clear in writing.
>
> Thank you.

### IEC — conditional follow-up draft

The existing IEC draft in `RTZ-SCHEMA-QUALIFICATION.md` §6 is retained as a conditional follow-up if CIRM cannot establish exact lineage or identify the rights holder/authority to license the RTZ schemas. No IEC inquiry is included in the initial outbound batch. If triggered, use the official IEC copyright/contact channel, ask IEC to identify the exact artifact and rights authority, and record the exact submitted form text or message and submission confirmation before claiming it was sent.

## 4. Send and reply ledger

| Organization | Contact channel | Sent time (UTC) | Exact message | Delivery outcome | Reply |
|---|---|---|---|---|---|
| CIRM | `office@cirm.org` | 2026-10-14 09:59:43 UTC; Gmail ID `1a139da7fde05dbd` | §3, CIRM exact outgoing text | Gmail Sent label confirmed; no bounce observed at check. Receipt not confirmed. | No reply found at check. |
| Topografix | `support@expertgps.com` (publisher-linked contact) | 2026-10-14 09:59:58 UTC; Gmail ID `1a139dabaa25c3a0` | §3, Topografix exact outgoing text | Gmail Sent label confirmed; no bounce observed at check. Receipt not confirmed. | No reply found at check. |
| IEC | Official copyright/contact route, conditional | Not triggered | Existing conditional draft in `RTZ-SCHEMA-QUALIFICATION.md` §6 | No inquiry sent | None |

For any sent message, append the actual UTC send time and the mail system's delivery result. For replies, record sender identity, organization, date/time, exact relevant wording or terms, referenced artifact, restrictions/conditions, and the blocker addressed. Preserve restrictive wording; label project analysis separately from the incoming text. Do not store unrelated personal data.

## 5. Decision rules and current disposition

- **B01 closes only** on authoritative exact-file provenance for RTZ 1.2, or an authoritative replacement mapping sufficient to freeze the registry. A generic statement that the PAS defines version 1.2 is not enough.
- **B02 closes only** when written rights cover every required local/offline use and app inclusion/private distribution, the rights holder's authority is established, conditions/notices are recorded, and independent legal/project review accepts the terms.
- Silence, ambiguous terms, public download, or an informal statement without authority leave the applicable blocker open. A refusal or scope restriction must be recorded verbatim and escalated; do not change schema strategy or validation requirements silently.
- While awaiting replies: **B01 = PENDING EXTERNAL CONFIRMATION; B02 = PENDING / NOT CLEARED; IP-1A = PARTIAL; IP-2A = PARTIAL / INCOMPLETE; IP-2B = BLOCKED / NOT AUTHORIZED; overall IP-1 = PARTIAL / NOT PASS.**

R4 performs no schema acquisition/bundling, code, runtime, fixture, parser, B03/B04 work, or IP-2B work. Receipt of a reply alone does not constitute legal clearance or Architect acceptance.
