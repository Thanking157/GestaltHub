# GestaltHub v0.1 Roadmap

## Milestone 1 — foundation

Technical specification and safety boundary; SwiftUI app shell; Domain models and protocols; read-only detection; in-memory Feature Repository and Compatibility Engine; basic History and Backup interfaces.

## Milestone 2 — usable read-only product

Bundled database schema and seed records; feature browser; compatibility explanations; plan review with explicit confirmation; diagnostic export; unit/UI fixtures.

## Milestone 3 — backend boundary

Backend capability discovery; no-op/read-only default backend; Backup/Restore coordinator with integrity checks; a separately reviewed and explicitly enabled backend only if the target environment and authorization model are documented.

Each milestone is a small, reviewable commit. Completing Milestones 1 or 2 does not imply write-capable behavior.
