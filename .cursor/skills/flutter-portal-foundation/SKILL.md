---
name: flutter-portal-foundation
description: App layout (config, auth, router, feature registry, data layer), Cognito Hosted UI, offline/sync contract, GraphQL/WS helpers. Use when changing app structure or adding features. Stays generic.
---

# Flutter portal foundation skill

## App layout

- **Config**: `lib/config/` — `AppConfig` model and loader; runtime `config.json` (web: `/config.json`; mobile: assets or URL). Config must load before Amplify.
- **Auth**: `lib/auth/` — Amplify configured from config; Hosted UI redirect; `AuthService`, `AuthGuard`; callback route completes OAuth.
- **Core**: `lib/core/` — `setupProvider` (config + Amplify init), `createAppRouter` (go_router with callback and auth redirect guard).
- **Features**: `lib/features/` — registry (`_registry.dart`, `FeatureDescriptor`); each feature has its own folder (screens, widgets); routes registered from the registry.
- **Data**: `lib/data/local/` (sync metadata store), `lib/data/sync/` (sync service contract), `lib/data/remote/` (GraphQL client, WebSocket helper).

## Auth flow

Cognito Hosted UI (managed login). Redirect to Cognito → user signs in → redirect back to `/callback` → Amplify completes code exchange → app redirects to home. No custom login form in the app.

## Offline and live data

- **Offline**: Sync metadata store and sync service contract; optional Drift DB (see `lib/data/local/README.md`).
- **Live**: Optional GraphQL client and WebSocket helper in `lib/data/remote/` for features that need real-time data.

## When adding a feature

1. Create `lib/features/<name>/` (screens, widgets, and a `*_feature.dart` descriptor).
2. Register the feature in `lib/features/_registry.dart` (add its `FeatureDescriptor` to `featureDescriptors`).
3. Add a **feature subagent** at `.cursor/agents/feature-<name>.md`:
   - **Name/description**: e.g. "Feature specialist for &lt;name&gt; (screens, routes, data)."
   - **Scope**: This feature only — `lib/features/<name>/` and any feature-specific tables/repos in `lib/data/` used only by this feature.
   - **Source of truth**: Paths under `lib/features/<name>/`; dependency on core router/registry.
   - **Guardrails**: Feature-owned routes and state; no cross-feature coupling unless explicit.
   Use `.cursor/agents/portal-app.md` as the template; trim to feature scope only.

## When to use

Changing app structure, adding a feature (code + registry + subagent), adjusting auth or config flow, or extending the data layer. Keep guidance generic; no portal-type names.
