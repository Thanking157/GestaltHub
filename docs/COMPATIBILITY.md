# GestaltHub v0.1 Compatibility Engine

## Result model

The engine returns status (supported, conditional, unsupported, unknown, or blocked), human-readable reasons, matched rule identifiers, confidence, required actions, evaluation time, and database version.

Unknown is a first-class result. Missing data never implies support.

## Inputs

- Immutable DeviceContext from the detector
- FeatureDefinition snapshot
- Optional proposed value
- App policy version
- Backend capability report

DeviceContext includes product/model identifiers when available, OS version, build, architecture/family, region only when explicitly available, and restricted/read-only environment state. Sensitive identifiers are minimized and remain local by default.

## Rule order

1. Invalid or incomplete input -> blocked.
2. Platform or OS exclusion -> unsupported.
3. Explicit device/build exclusion -> unsupported.
4. Known supported predicate and valid value -> supported.
5. Conditional prerequisites or expert confirmation -> conditional.
6. No reliable rule -> unknown.

The most restrictive applicable rule wins, while all relevant reasons are returned.

## Explainability

Compatibility is advisory. Supported does not promise that a write backend exists or that the platform will accept a value. The planner re-checks compatibility immediately before execution.

## Test matrix

Cover supported iPhone and iPad fixtures, OS bounds, unknown builds, invalid types and ranges, device exclusions, read-only backends, missing provenance, conflicting rules, and deterministic repeated evaluation.
