# Flutter portal architecture

This document describes the target architecture for EchoCorner portals: app foundation (Flutter at repo root in **this repo**), repository of modules, and Service Catalog (in [scd-echocorner](https://github.com/lobo1111/scd-echoCorner)) delivering only hosting and config.

## Principles

- **SC products only deliver hosting and config.** No per-module Service Catalog products; module lifecycle is code and config (which module IDs appear in `enabledModules`).
- **One app foundation** (this repo, Flutter at repo root): SPA routing, Cognito integration, menu built from enabled modules' metadata, config loading.
- **Repository of modules** (this repo or separate): Flutter packages that implement the foundation's module contract (routes + metadata for menu). Modules may or may not be enabled via `config.json`.

## Components

### 1. Service Catalog (scd-echocorner repo)

- **Portal hosting**: Three product entries (admins, ops, users) share one **foundation template** parameterized by `PortalVariant`. Each provisions S3 + CloudFront + Route53.
- **Config delivery**: A **config generator** in scd-echocorner (`tools/config/generate_portal_config.py`) reads deploy state and `portal_module_matrix.yaml` to produce `config.json` (apiBaseUrl, Cognito settings, `enabledModules`). The deploy step uploads `config.json` with the app to each portal's S3 bucket.

### 2. App foundation (this repo)

- **Flutter at repo root**: `lib/`, `web/`, `pubspec.yaml`, `main.dart`.
- **Responsibilities**: SPA routing (go_router), Cognito Hosted UI (redirect, callback, session, logout), theme and shell, **menu** (built from enabled modules' metadata only), API client, config loading (asset or `/config.json`).
- **Module contract**: Foundation defines the interface (routes + metadata: id, menuLabel, routePath, menuOrder, icon). Only modules whose ID is in config's `enabledModules` get routes and menu entries.

### 3. Repository of modules

- **Packages**: e.g. `ec_module_communities`, `ec_module_estates`, each implementing the foundation's contract (routes + metadata).
- **Enabled at runtime**: Config's `enabledModules` list controls which modules are visible; the foundation registers routes and menu items only for those IDs.

## Config flow

1. **Deploy state** (in scd-echocorner after `scd deploy apply`): Cognito and API product outputs (UserPoolId, UserPoolClientId, HostedUiDomain, ApiUrl, PortalUrl).
2. **Portal–module matrix**: In scd-echocorner: `tools/config/portal_module_matrix.yaml` lists which module IDs are enabled per portal (admins, ops, users).
3. **Config generator**: In scd-echocorner; produces `config.json` per portal; deploy uploads it with the app.
4. **App** (this repo): Loads `config.json` at startup and configures auth, API client, and enabled module set (routes + menu).

## References

- Hosting and config: [scd-echocorner](https://github.com/lobo1111/scd-echoCorner) (CAPABILITY for ec_web_spa_portal_hosting, tools/config).
