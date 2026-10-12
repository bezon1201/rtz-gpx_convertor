# Synthetic RTZ fixture corpus

All XML files in this directory are original, project-authored synthetic data. They do not copy or anonymize publisher, vendor, vessel, or user routes. Coordinate decimals are arbitrary schema-test values, not route recommendations or operational observations. No real vessel identity, voyage identifier, date, or user path is present.

`manifest.json` is the canonical index. IDs are stable and independent of filenames. Each entry separates expected XSD behavior from later semantic/application behavior, records field coverage and route order, and includes the exact fixture SHA-256. Outcomes describe the currently inspected temporary XSD artifacts only; they do not qualify RTZ support or grant redistribution rights. The artifact identities are recorded here so results are reproducible:

| Schema | Exact temporary artifact identity | Rights status |
|---|---|---|
| RTZ 1.0 | CIRM-published schema; SHA-256 `c63f002fe9ffa55a45d770cc642b62de7f4a8ef30e87f92a5540e1e5ad332072` | Not cleared for redistribution/bundling |
| RTZ 1.2 | CIRM-published schema; SHA-256 `ba5695107e2b559ea0594eb80f7407b7e4f1c10da8cf09b447b4b920f681ceff` | Not cleared for redistribution/bundling; exact IEC artifact lineage remains unconfirmed |

These schemas were not added to Git. Where validation was permissible, the local temporary XSD was invoked with `xmllint --nonet --noout --schema <temporary-xsd> <fixture>`. `--nonet` prevents network retrieval by that invocation; it is not evidence of an application runtime or platform-wide isolation. For `malformed-not-well-formed.xml`, the parser reports a syntax failure before schema validation. For `unsafe-doctype-entity.xml`, no entity-expanding/schema-validation command was run; later parser-security behavior remains an acceptance requirement, not a result from this corpus run.

Expected semantic categories are test intentions for future authorized parser work, not observed application behavior. No parser, geometry routine, or application test suite exists as a result of IP-1B. Geometry-oriented files only preserve authored input point order; no distances or navigation conclusions are recorded. `oversized-input-fixture.spec.md` is a recipe only; no oversized file is stored.

## Validation record

The matrix contains **35 XML fixtures**: 19 XSD-valid, 13 matching-schema-invalid, one malformed, one unsupported version with no schema selected, and one security-sensitive DOCTYPE/entity fixture intentionally not passed to the schema validator. Expected-invalid cases are checked against the matching temporary XSD. Version/namespace mismatches are rejected as dialect mismatches by contract; their direct declared-version XSD results are recorded separately. The malformed case is checked for XML syntax only.

The manifest records the exact command for each check, including the temporary schema path, and the actual validation outcome. The mismatch cases' direct XSD results do not replace the requirement to reject mismatched pairs before schema selection. No assertion is made about a future parser's runtime behavior.
