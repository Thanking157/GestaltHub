# GestaltHub v0.1 Architecture

## Goal

GestaltHub is an iOS/iPadOS app for inspecting device capabilities, evaluating feature compatibility, planning reversible changes, and presenting an auditable history of user-approved operations.

The v0.1 design separates analysis and planning from any mechanism that may write platform state. The app must remain useful in read-only mode.

## Scope

In scope: device/OS/build detection; a versioned, provenance-aware Feature Database; an explainable Compatibility Engine; a Modification Planner; Backup/Restore; local History; an Expert Editor; and an abstract Write Backend.

Out of scope: exploit chains, sandbox escape, privilege or signing bypass, silent or remote modification, and copied code/UI/database content from other projects.

## Layers

| Layer | Responsibility |
| --- | --- |
| App | SwiftUI navigation and confirmation flows |
| Features | Inspector, Browser, Planner, Backups, History, Expert Editor |
| Domain | Feature records, compatibility results, plans, backups, history events |
| Services | Detection, database access, evaluation, planning, backup orchestration |
| Backends | Read backend and replaceable Write Backend implementations |
| Persistence | Local files/database, schema versions, migrations |

Dependencies point inward toward Domain protocols. UI code never calls a write backend directly.

## Core flow

1. Detection creates an immutable DeviceContext.
2. The Feature Database resolves a FeatureDefinition snapshot.
3. The Compatibility Engine evaluates it against DeviceContext.
4. The Modification Planner creates a reviewable plan with preconditions, risk, backup requirements, and a proposed backend operation.
5. The user reviews and explicitly confirms.
6. Backup Coordinator creates and verifies a restorable snapshot.
7. Write Backend reports capabilities and either performs the approved operation or returns an explicit unsupported/read-only result.
8. History records the request, result, backend identity, and restore reference.

## Protocols

DeviceDetecting, FeatureRepository, CompatibilityEvaluating, ModificationPlanning, BackupManaging, HistoryRecording, and WriteBackend. Use async APIs where I/O can block and return typed, actionable errors.

## Safety invariants

- Read-only analysis is always available.
- No mutation occurs without a confirmed plan.
- A plan identifies target, old value when known, proposed value, prerequisites, risk, and rollback path.
- Unknown compatibility is never treated as supported.
- Backups are integrity-checked before a write.
- Every write attempt, including failure, is recorded.
- The default backend is read-only.

## Testing

Use deterministic Domain tests with fixture DeviceContexts and FeatureDefinitions. Inject fake backends into services. UI tests cover plan review, confirmation, unsupported-device messaging, backup failure, and restore confirmation. Any future write-capable backend requires an explicit feature flag and integration tests.
