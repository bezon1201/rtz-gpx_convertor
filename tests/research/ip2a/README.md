# IP-2A libxml2 2.15.4 research harness

Research-only synthetic security characterization. This is not production code, a product test target, or an RTZ parser. It reads no RTZ/GPX routes and uses no RTZ/GPX schemas. Tests perform no network access; HTTP strings are inert inputs passed to a deny-all loader. Do not run it with real route data.

## Reproduce locally (macOS, Xcode Command Line Tools)

1. Obtain the official source archive separately from [GNOME](https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.tar.xz). Its required SHA-256 is `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821`. Do not use `brew` or the system libxml2.
2. Run the local-only build and tests, passing the downloaded archive and a disposable build directory:

   ```sh
   tests/research/ip2a/build-and-run.sh /path/to/libxml2-2.15.4.tar.xz /tmp/ip2a-r3-build
   ```

   The script verifies the archive hash, builds a static arm64 candidate with the recorded options, compiles the harness against that archive's `libxml2.a`, verifies the executable-reported libxml2 version, and runs the cases. It performs no downloads. `otool -L` output is checked for a dynamic/system libxml2 dependency; a mismatch fails.

3. For repeated local checks after the build, invoke `/tmp/ip2a-r3-build/bin/ip2a-harness self-test` directly. It has no runtime dependency other than the statically linked candidate and Apple system libraries. The separately authorized cancellation and repeated-workload experiments are:

   ```sh
   /tmp/ip2a-r3-build/bin/ip2a-harness cancel-read
   /tmp/ip2a-r3-build/bin/ip2a-harness cancel-cleanup
   /tmp/ip2a-r3-build/bin/ip2a-harness cpu-worker
   /tmp/ip2a-r3-build/bin/ip2a-harness measure nodes 20 249999
   /tmp/ip2a-r3-build/bin/ip2a-harness measure nodes 20 250000
   /tmp/ip2a-r3-build/bin/ip2a-harness measure deep 20 10000
   /tmp/ip2a-r3-build/bin/ip2a-harness measure attr 10 1048576
   /tmp/ip2a-r3-build/bin/ip2a-harness measure segtext 20 8388608
   ```

   `measure` prints whole-process peak RSS, including generated input; it does not measure parser-attributable memory. Timings and cancellation latency are observations from the current host, not guarantees.

The build directory contains third-party source/build outputs and must remain outside Git. This harness assumes macOS APIs (`CommonCrypto`, `getrusage`, `fork`/`waitpid`) and is not claimed portable. Results are host-specific; see `manifest.json`, `results.jsonl`, and the parent research record. XML contents, user paths and route data are never written to results. All input is source-authored synthetic material. The R3 scope exception expires at R3 completion; this is not a reusable product test target.

## Cases

`manifest.json` enumerates deterministic generated cases, expected parser-layer results and how each source identity is computed. The harness emits one JSON object per case with observed outcome, exit status, parser version, input SHA-256, loader count, callbacks, elapsed time and sanitized error category. It does not emit XML contents or private paths.

R3 cancellation experiments use cooperative cancellation observed at the descriptor read boundary and a disposable child process for CPU-bound termination. They never call parser-context functions concurrently from another thread. Process isolation is a research comparison only, not an approved product architecture.
