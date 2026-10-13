# IP-2A R1 — Provisional Resource Limits

**Status: PROPOSAL ONLY.** None of these ceilings is approved for product use or established as a hard bound. IP-2A R1 may document and assess candidate limits; IP-2B must implement and measure them only after IP-2A passes and separate authorization is granted.

## Candidate ceilings for qualification

| Resource | Candidate ceiling | Enforcement/evidence requirement | Current status |
|---|---:|---|---|
| Uncompressed input bytes | 16 MiB | Enforce on the already-authorized descriptor while reading, allowing at most limit + 1 byte to detect excess; do not trust pre-open path metadata. | Proposed; unmeasured |
| XML nesting depth | 64 | Count events and abort at the boundary; determine whether parser stack/token allocation can exceed acceptable resources before callback. | Proposed; parser-dependent |
| XML elements | 250,000 | Count before model allocation; include extension elements. | Proposed; unmeasured |
| Route waypoints | 20,000 | Count before allocating waypoint/model records. | Proposed; unmeasured |
| Attributes per element | 64 | Count at element start; parser-side attribute materialization risk must be measured. | Proposed; parser-dependent |
| Individual text or attribute value | 4 KiB UTF-8 bytes | Measure encoded byte length; reject, never silently truncate or normalize. | Proposed; parser-dependent |
| Aggregate XML text | 8 MiB UTF-8 bytes | Count across document, including extension content. | Proposed; unmeasured |
| Extension content | 1 MiB aggregate; individual text/attribute remains 4 KiB | Count extensions within overall element/text limits; preserve no uninterpreted payload unless an approved model explicitly requires it. This is a new candidate, not an approved cap. | Proposed; unmeasured |
| Parse plus schema-validation work | 5 seconds on the lowest supported candidate Mac | Must include a rights-cleared schema runtime; measure cold and warm runs, adversarial cases, and cancellation. No supported OS has yet been established. | Proposed; unmeasured |
| Process peak memory attributable to one conversion | 128 MiB | Measure process RSS across accepted/rejected adversarial inputs and repeat runs. If not enforceable, document it as an observed budget rather than promise a hard bound. | Proposed; unmeasured |
| Diagnostics | 100 | Cap emitted diagnostics; suppress further details after a stable “additional errors omitted” indicator. | Proposed; unmeasured |
| Cancellation response | 250 ms target from cancellation signal to safe abort | Measure on every qualified parser/validator build and candidate OS; no result may be emitted after cancellation. | Proposed; unmeasured |

No ZIP/RTZP decompression is permitted. The overall byte ceiling applies during the same descriptor-backed read used for parsing. Counters do not prove a hard memory ceiling if a parser materializes a token before invoking callbacks.

## Existing synthetic-corpus characterization

The IP-1B manifest contains 35 synthetic fixture entries. The largest checked-in fixture is 2,377 bytes; the largest explicit waypoint-count case contains three waypoints. The depth stress fixture contains 128 nested synthetic extension elements. These are corpus facts only. They do not establish operational route distributions, parser resource consumption, valid maximum values, or suitability of the candidate ceilings. The 128-level case exceeds the candidate depth cap and is expected to be rejected if the cap is later approved.

## Required future evidence

Before any candidate ceiling becomes a product requirement or constant, an authorized IP-2B qualification must use synthetic inputs and record exact parser/validator versions, OS/build, hardware, enforcement point, elapsed time, peak memory, cancellation latency, and outcomes at cap−1, cap, and cap+1. It must include schema-valid cases, malformed documents, nested markup, huge attributes/text, high element/waypoint counts, extensions, entity/DTD attacks, and repeated operations. Tests must demonstrate no partial model or output on rejection/cancellation. A callback counter alone is insufficient evidence for memory safety.

No tests were created or run as part of IP-2A R1. The only empirical observation is the narrowly scoped Foundation in-memory probe described in `INPUT-AND-SECURITY-DECISIONS.md`.
