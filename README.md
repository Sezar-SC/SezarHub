# SezarHub

SezarHub is a Lua project organized around a loader, a UI library, reusable modules, and optional game-specific modules. The current client downloads Lua files from the repository at runtime.

## Project layout

- `main.lua` starts the client, loads configuration and language/theme data, checks the key, creates tabs, and loads modules.
- `ui.lua` contains the UI library and shared notification/configuration helpers.
- `config.lua` contains public feature settings. Never put passwords, GitHub tokens, API secrets, or private keys here.
- `keys.lua` contains the current client-side key list. This file is public and downloaded by every client. It cannot keep keys secret or provide strong access control. Use a server-side verification service before treating keys as security credentials.
- `keyscreen.lua` displays the existing key-entry screen.
- `vip.lua` is a legacy client-side role list. It is not trusted for authorization. VIP stays disabled until a server-side verifier is implemented.
- `lang.lua` contains translations; `theme.lua` contains theme behavior.
- `modules/` contains reusable feature modules.
- `games/` contains the game-to-module mapping and game-specific modules.
- `version.txt` holds the displayed version and a one-line update note.
- `CHANGELOG.md` records user-visible changes.

## Security notes

The loader currently fetches code from the mutable `main` branch and executes downloaded Lua. A failed key/config/module load now stops startup or reports an error, but client-only checks cannot prevent a user from modifying the client. Do not publish secrets in this repository. If a real GitHub token or API key was ever committed, revoke it and replace it; deleting the file in a later commit does not remove it from Git history.

The key list and VIP roles are delivered to the client. Keep VIP disabled and do not use this key list as a security boundary until a server-side service performs the checks. Cryptographic update verification and automatic rollback require a trusted release/signature design and runtime support; they are not provided by the current loader.

## Updating the version

1. Update `version.txt` using `MAJOR.MINOR.PATCH` and add a short note on the next line.
2. Add the detailed change under the matching version in `CHANGELOG.md`.
3. Review the complete diff and ensure no secrets or local data are included.
4. Commit the change, create a GitHub release with the same `vMAJOR.MINOR.PATCH` tag, and attach the reviewed source archive.
5. Do not describe a release as integrity-verified or rollback-capable until signed artifact verification and a tested rollback path have been implemented.

## GitHub repository settings

Restrict write access to trusted maintainers, enable two-factor authentication for maintainers, protect the default branch where available, and enable secret scanning/push protection if available for the account. Keep a second backup outside the repository and periodically confirm that it can be restored.
