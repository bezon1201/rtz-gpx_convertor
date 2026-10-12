# IP-1C — GPX 1.1 Output Contract

**Status: PARTIAL.** The product and core GPX shape contracts are frozen below for downstream planning. Offline schema validation was demonstrated locally against the exact temporary XSD identified here, but GPX XSD redistribution rights remain conditional and runtime schema strategy is not qualified. This document is not a serializer implementation or Windy compatibility claim.

## Normative output shape

- Output is GPX **1.1**, namespace `http://www.topografix.com/GPX/1/1`, XML root `<gpx version="1.1" creator="…">`. `version` is fixed to `1.1`; `creator` is required and must truthfully identify the producing software. IP-4 chooses the final stable creator string/version rule.
- One transformed source route produces exactly one `<rte>` whose `<rtept>` children preserve transformed route order. Do not emit a duplicate top-level `<wpt>` list or `<trk>` by default. GPX describes an ordered list of route waypoints; it does not encode RTZ leg semantics equivalently.
- A product output contains **at least one** `<rtept>`. G3-004 allows a one-point route: show a clear warning that it defines no route leg and require affirmative route confirmation. The Topografix schema itself allows zero or more `rtept`; the product contract is deliberately stricter. Windy acceptance for one point is not assumed.
- Emit a route point's `<name>` only when the source waypoint name is non-empty and valid for XML serialization. Do not invent names, move IDs/revisions into GPX fields, or include source metadata as a substitute.
- Ordered route-point coordinates retain the transformed numeric values; no geometry-based densification, interpolation or waypoint reordering is implied by GPX serialization.

## Route name — G3-001

1. A present, valid source RTZ route name is the default effective GPX route name.
2. The user may enter an explicit export-only override or explicitly omit the GPX route name.
3. Preview shows the exact effective value (or explicit omission); affirmative route confirmation binds that value. A name edit invalidates the prior preview/route confirmation and any publication consent bound to the previous output; refresh preview and reconfirm.
4. Serialize the exact confirmed effective value into `<rte><name>` with a standards-compliant XML serializer. Never modify the source RTZ or source route model.
5. If the source name is absent or invalid, require an explicit valid override or explicit omission. Reject invalid input safely; never silently substitute, truncate, normalize, derive from vessel identity, or derive from source/output filename/path. The GPX internal route name remains independent of the output `.gpx` filename.

Exact name length, XML scalar validity, normalization policy and any UI input bounds are implementation qualifications for IP-4/IP-5/IP-7. No name may be concatenated into XML markup.

## Coordinates and numeric lexical form

- Coordinate numeric meaning must survive conversion and reparse; reject non-finite values and values outside GPX 1.1 numeric facets. No silent rounding or coordinate correction.
- GPX 1.1 `longitudeType` is `xsd:decimal` with `-180.0 <= value < 180.0`; `latitudeType` is decimal with `-90.0 <= value <= 90.0` ([Topografix schema documentation](https://www.topografix.com/gpx/1/1/)). The exact locally validated XSD also rejects longitude `+180` (`maxExclusive`). The approved source RTZ 1.0/1.2 artifacts likewise use a max-exclusive `+180` boundary. If a qualified input dialect or transformed model nevertheless contains numeric `+180`, fail closed before output; never wrap it to `-180`.
- `xsd:decimal` does not represent exponent notation. IP-4 must serialize finite decimals in locale-independent decimal notation without changing numeric value; do not impose fixed decimal rounding. Negative-zero spelling/semantic policy remains an IP-4 decision, with numeric equality required.
- Source coordinate order and numeric meaning are semantic requirements. GPX schema validity alone does not establish consumer fidelity; Windy is qualified in the authorized Stage 6 empirical acceptance.

## XML serialization, determinism, and validation

- Use a standards-compliant XML serializer with escaping. Do not hand-build XML or normalize invalid characters silently. If the serializer cannot represent a selected name, return an actionable error and request override or explicit omission.
- **Semantic determinism is mandatory:** identical confirmed choices produce identical route-point order, coordinate values, names, GPX structure and loss categories.
- **Byte-level determinism is not required for V1.** No concrete consumer, signature, cache, or audit requirement has been identified that requires byte-identical XML. XML attribute order, declaration and insignificant formatting may vary while the parsed GPX remains semantically identical. Do not add custom canonicalization solely to force equal bytes. Stable UTF-8 output and predictable indentation are implementation preferences, not byte-identity guarantees.
- Reparse and validate the locally generated output with an exact, locally pinned GPX 1.1 schema; compare route point count/order/numeric values and effective route name. Do not fetch `schemaLocation` at runtime. Validation must be offline. The later application may bundle/reference an XSD only after written rights clearance and an approved offline packaging strategy.

**Schema validation evidence (research only):** local artifact `/tmp/rtz-ip1a-schemas/gpx-1.1.xsd`, SHA-256 `9e4d1988b862edbe556305b130f8f6f1b29864fefd0dc02d5dab04ccdd1f34d6`; validator `xmllint` / libxml2 2.9.13, command form `xmllint --nonet --noout --schema /tmp/rtz-ip1a-schemas/gpx-1.1.xsd FILE`. A synthetic one-point `<rte>` with a single `<rtept lat="0" lon="0"/>` **validated**. The same synthetic document with `lon="180"` **failed** the `maxExclusive` facet. Temporary XSD and test documents were not committed. `--nonet` applies to this invocation only; it is not a system-wide isolation claim.

**Rights:** Topografix states that all text on its [GPX overview page](https://www.topografix.com/gpx.asp) is public domain; that statement does not expressly grant rights for the raw XSD artifact. GPX schema redistribution/bundling remains **CONDITIONAL / REQUIRES EXTERNAL CONFIRMATION**, as documented by IP-1A. Local validation does not imply a redistribution license.

## Mapping and disclosed losses

| Source/transform data | GPX 1.1 treatment |
|---|---|
| Ordered transformed positions | Ordered `<rtept lat="…" lon="…"/>` |
| Existing non-empty waypoint names | Corresponding `<rtept><name>…</name></rtept>` |
| Route name | G3-001 effective-name rule above; zero or one `<rte><name>` |
| One-point route | One `<rtept>`, explicit no-leg warning, affirmative route confirmation |
| RTZ IDs/revisions, turn radius, leg geometry, XTD, course/speed/safety, schedules/ETA, vessel/route details, notes and opaque extensions | Omit; disclose by safe category/count, never raw opaque payload |
| RTZ route drawing/turn construction/ECDIS semantics | Not preserved by an ordered GPX route; no equivalence claim |

User-facing summary must convey: “Coordinates and ordered waypoint names copied; RTZ navigation semantics are not preserved.” Loss categories may not expose raw XML, route content, vessel identity, source paths or private source-file hashes.

## Future acceptance cases / open dependencies

IP-4/IP-5/IP-7 should add synthetic checks for: multi-point ordering; one-point allowed plus warning/confirmation gate; no top-level duplicate `<wpt>` and no default `<trk>`; source-name default; explicit override; explicit omission; invalid/missing source-name recovery; exact XML escaping and invalid scalar rejection; route-name and filename independence; name-edit confirmation invalidation; `+180` rejection without wrapping; `-180` preservation; decimal output/reparse including small fractional values and negative zero; semantic repeatability; schema validation with network unavailable; unchanged source model; loss-summary boundaries. These are planned acceptance cases, not tests run here.

Remaining blockers: GPX XSD license/redistribution confirmation; approved self-contained offline validation mechanism; exact name bounds/Unicode normalization and negative-zero implementation choices; +180 fail-closed behavior in qualified end-to-end dialects; and empirical Windy behavior for the eventual signed app/output. IP-1C has not run app or Windy tests.
