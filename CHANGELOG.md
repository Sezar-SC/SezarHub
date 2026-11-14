## v2.5.0 - 2026-11-14

### Added
- Pro profile: a Worker-verified key profile now unlocks a Pro look.
- Pro themes: Rainbow (default, animated), Golden, Diamond and Silver, kept in a separate `pro_themes.lua`.
- Pro intro: rainbow SEZARHUB animation with a "WELCOME, SIR" message above it, translated to English, Turkish and Russian.
- Pro menu: rainbow border, header strip, divider, logo plate and accents.
- Mobile support: responsive menu size, scrollable tabs, larger touch targets, floating "SH" open/close button.
- Fewer particles in intro animations on touch devices.

### Changed
- Free users only see Neon Purple, Dark and Clean White. Pro themes are never listed or selectable for Free.
- Pro accounts only use Pro themes. A saved Free theme is replaced by Rainbow silently.
- The key server check and fail-closed behavior are unchanged.

### Removed
- `theme_profiles.lua`: it exposed Pro themes to Free users.

### Notes
- If `pro_themes.lua` is missing, Pro falls back to the Free look and the hub keeps running.
- Pro separation is client-side and visual only.
