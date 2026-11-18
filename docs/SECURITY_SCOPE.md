# GestaltHub v0.1 Security Scope

GestaltHub may inspect platform/device metadata and may eventually coordinate an authorized, user-approved write backend. The safe v0.1 boundary is:

## Allowed

- Read-only detection and local analysis
- High-level backend capability and failure modeling
- Backups, restore planning, integrity verification, and local history
- User-visible warnings, expert confirmation, and audit records
- Defensive tests using fixtures and fake backends

## Not provided

- Exploit code or exploit chains
- Sandbox escape, privilege escalation, entitlement/signing bypass
- Instructions for defeating platform security or evading detection
- Silent, remote, or irreversible modification
- Copied implementation or UI from third-party GPL/AGPL repositories

Any future backend must document authority, supported environments, limitations, rollback, and failure handling before enablement. The default remains read-only.
