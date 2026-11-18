# GestaltHub v0.1 Feature Database

## Purpose

The Feature Database is a versioned, provenance-aware catalog of feature keys and known behavior. It is a data contract, not copied project data. Entries are authored from original observations, public documentation, and attributed research notes.

## Feature definition

Each entry contains:

- id: stable GestaltHub identifier
- key: platform-facing key or abstract key family
- displayName and summary
- valueType: boolean, integer, string, array, dictionary, or opaque
- allowed values or validation constraints when known
- platform scope and observed OS/build range
- device constraints
- compatibility policy: supported, unsupported, conditional, or unknown
- risk level: informational, low, medium, high, or critical
- write policy: read-only, planned-only, backend-dependent, or unavailable
- provenance: source type, reference, date, and confidence
- notes and expert-mode requirement

Confidence is observed, documented, inferred, or unknown. The UI shows provenance and confidence next to every result. Low-confidence data is never presented as a guarantee.

## Storage and versioning

v0.1 uses a bundled seed dataset plus a local schema version. The format must support additive migrations, disabling an entry without deleting history, future hash-verified imports, and preserving source/confidence.

Suggested paths: Resources/FeatureDatabase/seed.json and Resources/FeatureDatabase/schema.json.

The seed contains only GestaltHub-authored records and references. It does not contain copied source code or third-party UI.

## Queries

Support lookup by stable id and key, filtering by platform/device/OS, full-text search, and provenance retrieval. Queries return a snapshot so history can reproduce an evaluation.

## Example

    {
      "id": "example.feature",
      "key": "ExampleKey",
      "displayName": "Example feature",
      "summary": "Illustrative record only.",
      "valueType": "boolean",
      "platformScope": ["iOS", "iPadOS"],
      "compatibilityPolicy": "unknown",
      "riskLevel": "informational",
      "writePolicy": "readOnly",
      "provenance": {
        "sourceType": "originalObservation",
        "reference": "replace-with-a-real-reference",
        "confidence": "unknown"
      }
    }

This is intentionally non-operational and is not a claim about a real platform feature.
