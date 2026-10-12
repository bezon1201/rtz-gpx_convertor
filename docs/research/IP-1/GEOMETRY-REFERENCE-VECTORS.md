# IP-1C — Geometry Reference Vectors

**Status: PARTIAL.** The advisory distance reference baseline is reproducible for the qualified synthetic cases below. The approved general finite-rhumb closest-point objective (G3-006) is not globally qualified: the included exact cases have proofs, but no general global-minimizer method or completeness bound is established. This document is not navigation guidance, an implementation, or an ECDIS-equivalence claim. No application dependency is proposed.

## Approved convention and oracle provenance

- Model: sphere with the project-approved WGS84 authalic radius `R = 6,371,007.1809 m`; angular inputs and reported bearings are degrees, latitude/longitude order; all distances are surface distances.
- Orthodrome: shortest spherical great-circle distance. Rhumb: constant-bearing spherical loxodrome, shortest signed longitude difference when unique; an exact 180° longitude tie and pole-singular cases are classified unavailable rather than guessed. For non-tie cases the selected signed difference lies in `(-180°, 180°)`.
- Conversion: `1 NM = 1,852 m`, and `NM = metres / 1852`. Distance output is advisory only. It cannot select, infer, move, densify, or otherwise modify a route.
- **Reference implementation:** GeographicLib Python, version **2.1**, author Charles Karney; MIT/X11 license; official project source and docs: [GeographicLib Python 2.1](https://geographiclib.sourceforge.io/html/python/), [API](https://geographiclib.sourceforge.io/html/python/code.html), [geodesic algorithm references](https://geographiclib.sourceforge.io/geod.html). The inverse geodesic oracle was instantiated as `Geodesic(6371007.1809, 0)` so flattening is exactly zero. This is a sphere, not GeographicLib's WGS84 ellipsoid default; the inverse routine uses Karney's geodesic algorithms. Reproduction setup: `python3 -m venv /tmp/ip1c-venv && /tmp/ip1c-venv/bin/pip install geographiclib==2.1`; invoke `Geodesic(6371007.1809, 0).Inverse(lat1, lon1, lat2, lon2)` and read `s12`, `azi1`, `azi2`. The Python package itself contains the geodesic routines; it does not provide the rhumb calculation used here.
- **Rhumb mathematical reference:** C. F. F. Karney, “The area of rhumb polygons,” *Studia Geophysica et Geodaetica* 68 (2024), [publisher article](https://link.springer.com/article/10.1007/s11200-024-0709-z); the GeographicLib [`RhumbSolve` reference](https://geographiclib.sourceforge.io/html/RhumbSolve.1.html) describes inverse/direct rhumb calculations and explicitly allows `f=0` for a sphere. Its implementation was not executed in this task. For the sphere, the inverse formula cross-checked here is `Δψ = asinh(tan φ₂) − asinh(tan φ₁)`, `q = Δφ/Δψ` (limit `cos φ₁` when `Δψ=0`), `s = R·hypot(Δφ, q·Δλ)`, and initial bearing `atan2(Δλ, Δψ)` normalized to `[0°,360°)`. A second derivation integrates the spherical line element along linear `(ψ, λ)` rhumb coordinates; the formula/integral are independent derivations, not two independent software libraries.
- Oracle outputs below were recalculated in Python 3.13.14. Independent great-circle cross-check used unit 3-vectors and `atan2(|u×v|, u·v)`; maximum observed distance difference across the checked cases was `1.11e-9 m`, and maximum unique-bearing difference was `2.81e-9°`. Near-antipodal distance agreed to displayed precision. The naive haversine form is not accepted for near-antipodal checks because cancellation produced a 0.157 m disagreement there. Rhumb formula was cross-checked by composite Simpson integration of the spherical line element at 2048 intervals; maximum difference over all seven numeric rhumb cases was `1.40e-9 m`. No `RhumbSolve` executable was available, so independent reviewer reproduction against that tool remains pending.

## Distance and bearing vectors

All coordinates are synthetic. Bearing is initial true bearing clockwise from north. `—` means intentionally not asserted because bearing is undefined or ill-conditioned. Distances are shown to 9 decimal metres and 12 decimal nautical miles; displayed rounding is not a claim of physical accuracy.

| ID | Method | Start (lat, lon) | End (lat, lon) | Distance (m) | Distance (NM) | Initial bearing | Expected behavior |
|---|---|---:|---:|---:|---:|---:|---|
| GC-EQ-1 | Orthodrome | (0, 0) | (0, 1) | 111195.051974907 | 60.040524824464 | 90° | One degree on equator |
| RH-EQ-1 | Loxodrome | (0, 0) | (0, 1) | 111195.051974907 | 60.040524824464 | 90° | Equals equatorial great-circle arc |
| RH-MER-1 | Loxodrome | (0, 0) | (1, 0) | 111195.051974907 | 60.040524824464 | 0° | Meridional rhumb |
| GC-AM-2 | Orthodrome | (0, 179) | (0, -179) | 222390.103949814 | 120.081049648928 | 90° | Short 2° crossing, not 358° |
| RH-AM-2 | Loxodrome | (0, 179) | (0, -179) | 222390.103949814 | 120.081049648928 | 90° | Short signed longitude delta |
| RH-LAT60-10 | Loxodrome | (60, 0) | (60, 10) | 555975.259874535 | 300.202624122319 | 90° | Constant-latitude rhumb |
| GC-LAT60-10 | Orthodrome | (60, 0) | (60, 10) | 555445.759026771 | 299.916716537133 | 85.667126047928° | Shorter than same-endpoint rhumb |
| GC-MID-1 | Orthodrome | (34, -118) | (36, -122) | 426792.513462172 | 230.449521307868 | 302.535357100016° | Ordinary mid-latitude case |
| RH-MID-1 | Loxodrome | (34, -118) | (36, -122) | 426821.043976419 | 230.464926553142 | 301.401923276025° | Differs from orthodrome |
| GC-NS-1 | Orthodrome | (-20, 12) | (20, 12) | 4447802.078996279 | 2401.620992978553 | 0° | North/south |
| RH-NS-1 | Loxodrome | (-20, 12) | (20, 12) | 4447802.078996279 | 2401.620992978553 | 0° | Meridian coincides with great circle |
| GC-NEAR-1 | Orthodrome | (10, 20) | (10.000001, 20.000001) | 0.156063604 | 0.000084267605 | 44.561451380753° | Distinct, nearly coincident points |
| ZERO-1 | Both | (10, 20) | (10, 20) | 0 | 0 | — | Coincident endpoints; finite zero; bearing unavailable |
| RH-HIGH-1 | Loxodrome | (80, -40) | (82, 40) | 1403586.925068237 | 757.876309432094 | 80.883400725010° | High latitude |
| GC-HIGH-1 | Orthodrome | (80, -40) | (82, 40) | 1294764.335071138 | 699.116811593487 | 42.771403981835° | Materially differs from rhumb |
| RH-NEAR-POLE | Loxodrome | (89, 0) | (89, 90) | 174655.911679286 | 94.306647774992 | 90° | Finite near-pole parallel |
| NEAR-ANTI | Orthodrome | (0, 0) | (0.000001, 179.999999) | 20015109.198229708 | 10807.294383493363 | — | Stable shortest distance; direction ill-conditioned |
| POLE-1 | Loxodrome | (90, 0) | (89, 90) | — | — | — | Exact pole endpoint: longitude singularity, unavailable, no fallback |
| HALF-TURN-TIE | Rhumb | (10, 0) | (20, 180) | — | — | — | Equal shortest signed-longitude choices: unavailable, no guessed direction |

The 1° equatorial value is `R·π/180`; it is a sanity value, while GeographicLib and the vector calculation provide the recorded cross-check. NM values use only division by exactly 1852. Great-circle bearings are not accepted for exact coincident/antipodal ambiguity.

## Finite-rhumb closest-point vectors (G3-006)

The approved objective remains: for a selected finite rhumb source leg, find the point minimizing spherical great-circle distance from the manually entered current position, endpoints included. The source-leg geometry used for this search is separate from the explicitly selected geometry of the new connector. No leg is automatically selected. The following analytically tractable examples have global proofs; they do **not** qualify a general minimizer.

| ID | Rhumb leg endpoints | Query point | Expected closest result | Global-minimum basis |
|---|---|---|---|---|
| CP-ON-1 | (0, -10) → (0, 10) | (0, 3) | fraction `0.65`, point (0, 3), distance `0 m` | Zero is the global lower bound for a metric; the query lies on the finite segment. |
| CP-NEAR-START | (0, -10) → (0, 10) | (0, -9.999) | fraction `0.00005`, query itself, `0 m` | Same zero lower-bound proof; tests near start endpoint. |
| CP-NEAR-END | (0, -10) → (0, 10) | (0, 9.999) | fraction `0.99995`, query itself, `0 m` | Same zero lower-bound proof; tests near end endpoint. |
| CP-AFTER | (0, -10) → (0, 10) | (0, 20) | endpoint (0, 10), `1111950.519749070 m` | Along the equator, angular distance is monotone over this interval; the nearest admissible longitude is the end boundary. |
| CP-BEFORE-MERIDIAN | (-10, 0) → (10, 0) | (-20, 0) | endpoint (-10, 0), `1111950.519749070 m` | Along this meridian, angular distance is monotone over the interval; nearest admissible latitude is the start boundary. |

**G3-006 remains PARTIAL / unqualified for general cases.** A finite grid, local optimizer, or Mercator-plane perpendicular projection cannot establish a global minimum. No global search/root-completeness proof, tie policy, or general numerical error bound has been produced. IP-3 must keep unsupported cases unavailable/fail-closed until separately qualified. The approved spherical-geodesic objective is unchanged.

## Provisional test tolerances

These are reference-comparison proposals for later review, not final production tolerances and not physical navigation accuracy claims.

| Quantity | Proposed comparison tolerance | Evidence / domain |
|---|---:|---|
| Well-conditioned distance | `1e-5 m` | Cross-method spherical distance residual was at most `1.11e-9 m`; rounded table values add at most `0.5e-9 m`. `10 µm` is a finite numeric-comparison envelope with margin above observed binary64 and print-rounding residuals. Reviewer must confirm runtime/platform behavior. |
| Well-conditioned initial bearing | `1e-7°` | Proposed only for vectors with unique, well-conditioned direction; it is about 35 times the observed maximum independent unit-vector bearing residual (`2.81e-9°`). Near-antipodal and coincident bearings are explicitly not asserted. Reviewer/runtime confirmation remains required. |
| Exact synthetic on-segment fraction | exact decimal expectation (`0.65`, `0.00005`, `0.99995`) | Defined by equatorial linear-longitude parameterization; these are classification vectors, not a general rhumb closest-point tolerance. |
| Coordinate preservation | exact numeric value / source order | Transformation diagnostics must not mutate coordinates or order. GPX decimal round-trip tolerance is owned by IP-4 and is not set here. |

## Reproduction and remaining evidence

Use Python 3.7+ and GeographicLib 2.1 as above. Independent spherical cross-check for a pair of unit vectors `u,v` is `R * atan2(norm(cross(u,v)), dot(u,v))`; this is stable at both short and near-antipodal separations. For a rhumb pair, independently evaluate the stated inverse formula and integrate `R·sqrt((dφ/dt)^2 + cos²(φ(t))·(dλ/dt)^2)` over `t∈[0,1]` with `ψ(t)=ψ₁+tΔψ`, `λ(t)=λ₁+tΔλ`, `φ(t)=atan(sinh ψ(t))`, `dφ/dt=Δψ/cosh(ψ(t))`, and `dλ/dt=Δλ`; composite Simpson integration with 2048 subintervals gave the residual above. Report quadrature convergence and compare before accepting rhumb outputs. Reproduction must preserve latitude/longitude order and set the sphere radius explicitly.

Before IP-1C can be PASS, an independent reviewer must reproduce every rhumb output, approve the tolerance derivation, and either qualify a globally complete general G3-006 minimizer or explicitly retain that geometry as unsupported. No vectors or source route data are operational.
