---
name: portal-config
description: How portal config is produced and consumed; collect_config, config shape, env/variant. Use when generating config, wiring env/variant into scripts, or explaining config shape.
---

# Portal config skill

## Producing config

- **Tool**: `tools/collect_config.dart` reads deploy state (and optionally profiles) from an external repo (e.g. scd-echocorner).
- **Output**: `config.json` for a given **env** and **variant**.
- **Args**: `--env <name>`, `--variant <name>`, optional `--scd-repo <path>`, `--out <path>`, `--all-variants`.
- The template does not list allowed variant values; the clone may set a portal identity that becomes the default variant.

## Consuming config

- **Web**: App loads config at runtime from `/config.json` (same origin).
- **Mobile**: From `assets/config.json` or a config URL.
- **Shape**: See `lib/config/app_config.dart` — `userPoolId`, `userPoolClientId`, `cognitoHostedUiDomain`, `region` (required); optional `portalUrl`, `apiBaseUrl`, `graphqlEndpoint`, `wsUrl`.

## When to use

- Generating or updating config for a given env/variant.
- Wiring `--env` / `--variant` into run or deploy scripts.
- Explaining or changing the config JSON shape or load path.
