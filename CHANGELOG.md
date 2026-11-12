# Changelog

## [2.3.0] - 2026-11-12

### Security
- Stop startup when configuration or key verification is unavailable.
- Stop startup if the key screen fails or does not return a valid key.
- Keep VIP access disabled until a server-side verifier exists.

### Documentation
- Document the project layout, client-side security limits, versioning, and GitHub repository hygiene.

### Known limitations
- Runtime source is still fetched from the mutable `main` branch.
- There is no signed update manifest, automatic rollback, or server-side key/VIP service yet.
