# IP-2A R2 — Resource Limit Qualification Record

**Status: PROVISIONAL / PARTIALLY CHARACTERIZED.** No ceiling below is approved for product use or established as a hard process bound. Evidence is from disposable synthetic libxml2 2.15.4 probes on one macOS 26.6.2 arm64 host. See `INPUT-AND-SECURITY-DECISIONS.md` §R2.4. IP-2B must not treat a callback observation as approval of a limit.

## Candidate ceilings and observed probe boundaries

| Resource | Candidate ceiling | R2 observation | Enforcement caveat / status |
|---|---:|---|---|
| Uncompressed input bytes | 16 MiB | Descriptor-backed callback accepted limit−1 and limit; rejected limit+1 after delivering exactly limit+1 bytes. Close callback exactly once. | App read-callback cap only; does not bound parser allocations or total memory. **Characterized, not approved.** |
| XML nesting depth | 64 | App SAX counter accepted 64; rejected 65. | Parser may consume stack/token resources before callback; **not a library hard limit.** |
| XML elements | 250,000 | App SAX counter accepted exactly 250,000; rejected 250,001. | Does not characterize production model allocations or downstream schema validation. |
| Route waypoints | 20,000 | Not measured in an RTZ model (no model was built). | Candidate only; measure before model allocation in authorized IP-2B. |
| Attributes per element | 64 | Count policy retained from R1; not separately boundary-tested in R2. | Element start callback occurs after parser processed attributes; parser-internal work precedes this check. |
| Individual text or attribute value | 4 KiB UTF-8 bytes | Single text and attribute accepted 4095/4096; rejected 4097 by app callback. | Attribute is already materialized before callback; not a token-allocation bound. |
| Aggregate XML text | 8 MiB UTF-8 bytes | Accepted 8 MiB−1 and 8 MiB; rejected 8 MiB+1. | App SAX counter only; repeat with schema/model pipeline later. |
| Extension content | 1 MiB aggregate; individual values remain 4 KiB | Not measured. | Candidate only; preserve no uninterpreted payload absent approved model need. |
| Parse plus schema-validation work | 5 seconds on lowest supported candidate Mac | No schema validation or supported-OS floor exercised. Tiny synthetic timings are not representative. | **Unqualified.** Must include lawful schema runtime, cold/warm runs and adversarial cancellation. |
| Process peak memory attributable to one conversion | 128 MiB | Full multi-case harness peak was 45,875,560 bytes (~43.8 MiB), including generated input buffers; 16 MiB cases reported ~44,768 KiB harness RSS. | Not per-input parser RSS; measurement cannot establish conversion bound. **Unqualified.** |
| Diagnostics | 100 | Not measured. | Candidate only; cap and sanitize without route data. |
| Cancellation response | 250 ms target | Read callback cancelled at 64 KiB; parser stopped, no document, close once, no later reads; tiny case observed ~50 μs. | No latency guarantee; asynchronous cancellation and CPU-bound input not qualified. **Unqualified.** |

No ZIP/RTZP decompression is permitted. The byte ceiling applies while reading the already-open descriptor, allowing at most limit+1 bytes to detect excess. The callback tests did not use path metadata as authority. Parser callback caps do not prove hard memory/CPU ceilings when the parser materializes a token before invoking application code.

## Evidence conditions

- Candidate libxml2: 2.15.4; build/configuration and exact host are recorded in `INPUT-AND-SECURITY-DECISIONS.md` §§R2.1–R2.2.
- Synthetic only; no RTZ/GPX schemas, operational routes or product model were used.
- Input byte cap was exercised through descriptor-style I/O callbacks in 4 KiB reads, with cap−1/cap/cap+1 outcomes. Cancellation demonstrated a synchronous read-callback stop and deterministic close, not asynchronous responsiveness.
- Depth, element, text and attribute results were application counters/callback actions, not intrinsic libxml2 ceilings. No claim is made about memory before callback, schema validation, model construction, or end-to-end conversion.
- Aggregate harness RSS includes generated buffers and multiple cases; it must not be restated as parser memory per document.

## Existing synthetic-corpus characterization

The IP-1B manifest contains 35 synthetic fixture entries. The largest checked-in fixture is 2,377 bytes; its largest explicit waypoint-count case contains three waypoints. A depth stress fixture contains 128 synthetic extension elements. These are corpus facts only; they do not establish operational route distributions, supported maxima, parser resource consumption, or suitability of any candidate ceiling.

## Required future evidence

Before any ceiling becomes a product requirement or constant, separately authorized IP-2B qualification must use synthetic inputs and record exact parser/validator versions, OS/build and hardware; enforcement point; elapsed time; process memory methodology; cancellation latency; and cap−1/cap/cap+1 outcomes. Include schema-valid and malformed cases, nested markup, huge attributes/text, element/waypoint/extension counts, entity/DTD attacks and repeated runs. Demonstrate no partial model/output on rejection or cancellation. A callback counter alone is insufficient evidence for memory safety. Test any proposed hard bounds across the supported macOS matrix and end-to-end parse/schema/model pipeline.

No product tests were created or run in IP-2A R2. Disposable security probes are summarized in the companion record; no probe source or binary is retained in the repository.
