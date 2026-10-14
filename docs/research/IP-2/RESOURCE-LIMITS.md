# IP-2A R2 Baseline and R3 Addendum — Resource Limit Qualification Record

**Current handoff:** IP-2A remains **PARTIAL / INCOMPLETE** after R10; no candidate ceiling is approved and IP1-B03 remains **OPEN / PARTIAL / NOT QUALIFIED**. The R2/R3 measurements below are historical research evidence, not implementation limits. R10's per-control classification is in [`IP-2A-R10-B03-SECURITY-QUALIFICATION.md`](IP-2A-R10-B03-SECURITY-QUALIFICATION.md). See [`IP-2A-CLOSEOUT-AND-HANDOFF.md`](IP-2A-CLOSEOUT-AND-HANDOFF.md) for the consolidated R8 closeout snapshot and ownership history.

## Historical R3 runtime-safety evidence addendum (2026-10-14)

The R3 harness reran the R2 parser-boundary matrix against the same pinned static libxml2 2.15.4 candidate, then added cooperative asynchronous cancellation, cleanup cancellation, repeated synthetic parsing and disposable CPU-worker termination. These results remain **PROVISIONAL / PARTIALLY CHARACTERIZED**. No candidate ceiling is approved for product use.

| Dimension | R3 observation | Classification / limit |
|---|---|---|
| DTD/entity/resource denial | Reproduced denial of synthetic DTD/entity and local/HTTP schema include attempts; no accepted external content, fallback, or network request. | Single build/host and synthetic matrix only; does not close IP1-B03 or qualify RTZ/GPX schemas. |
| Cancellation during reads | Separate thread set an atomic request; parser-thread callback observed it during a deliberately slowed descriptor read, returned failure, closed exactly once and did not read again after observation. | Cooperative only at callbacks. Recorded bytes/time are run-specific and no fixed cancellation deadline is established. |
| Cancellation during cleanup | Cancellation synchronized to close callback produced failure/no acceptance and exactly one close. | Synthetic callback timing only; not application lifecycle evidence. |
| CPU-bound cancellation | Disposable child repeatedly parsed 8,402,951 synthetic bytes; parent SIGTERM/reap succeeded. Recorded run: 35.630 ms CPU, 9,764,864 bytes Darwin peak RSS, 264 μs kill-to-reap. | Process isolation is an experiment, not product architecture. One host/run; no service-level latency claim. |
| Repeated nodes workload | 20 sequential parses of 1,000,003 bytes / 250,000 elements: accepted in 121,186 μs, 2,867,200 bytes peak RSS; 250,001 elements rejected in 121,050 μs with same peak. | Generated input and process/runtime memory included; not parser-only or conversion-attributable. |
| Repeated deep-nesting input | 20 parses of a 70,000-byte depth-10,000 input: rejected at callback in 95 μs aggregate; 2,162,688 bytes peak RSS. | Whole-harness peak; parser internal stack/allocation behavior not bounded by app callback. |
| Repeated large-attribute input | 10 parses with a 1,048,576-byte attribute: rejected at callback in 15,682 μs aggregate; 4,096,000 bytes peak RSS. | Attribute is materialized before callback. Whole-process RSS only; not a hard cap. |
| Repeated aggregate-text workload | 20 sequential parses of 8,402,951 bytes / 8 MiB text: 47,060 μs aggregate; 10,289,152 bytes peak RSS for whole harness process. | Same limitations; no product memory or performance conclusion. |
| Hard limits vs callback limits | Byte callback delivered at most the limit plus one byte to detect excess. Element/depth/attribute/text checks fired at application SAX callbacks; attribute tokens and parser events had already been processed/materialized. | Byte input cap is observable at the read boundary. Other counters do not cap internal parser allocations; none is a hard process bound. |

Full result objects and sanitized categories are in `tests/research/ip2a/results.jsonl`. The harness uses no real routes, schemas or network requests. The R3 artifacts are covered by the one-time exception in `IP-2A-R3-SCOPE-EXCEPTION.md`.

**R3 disposition:** retain the prior candidate values strictly as experimental boundaries. No hard memory ceiling, CPU ceiling, cancellation deadline, or supported-macOS qualification is established. IP1-B03 remains **OPEN / PARTIAL / NOT QUALIFIED**; IP1-B04 remained open and unchanged at that handoff.

**Historical R2 status: PROVISIONAL / PARTIALLY CHARACTERIZED.** No ceiling below is approved for product use or established as a hard process bound. Evidence is from disposable synthetic libxml2 2.15.4 probes on one macOS 26.6.2 arm64 host. See `INPUT-AND-SECURITY-DECISIONS.md` §R2.4. IP-2B must not treat a callback observation as approval of a limit.

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

## Current R10 classification note (2026-10-14)

R10 reviewed the existing record without rerunning its harness. The input byte ceiling is a hard pre-parser bound only on bytes delivered through the bounded descriptor callback (limit+1 for excess detection); it is not a parser-memory or CPU bound. Depth, element, attribute, and text checks are callback/application limits; waypoint, extension and diagnostic ceilings are unqualified. Whole-harness RSS and synthetic elapsed times remain observational. The 250 ms cancellation value remains a candidate proposal, not an approved hard deadline. Read/cleanup cancellation is cooperative; the worker kill/reap result is only a one-host disposable experiment. See the R10 qualification matrix for precise evidence and future bounded actions. No values are approved for product constants by this note.
