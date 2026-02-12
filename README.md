# flut-template

Generic Flutter portal foundation with **Cognito managed login**, extensible feature structure, **offline-first** sync contract, and optional **GraphQL/WebSockets**.

## Targets

- **Web** (including WebAssembly when supported by your Flutter version)
- **Mobile** (Android, iOS)

## Quick start

1. **Run locally** (config + Flutter web on port 3000):
   ```bash
   ./tools/run_local.sh --env dev --variant ops
   ```
   This pulls config from scd-echocorner and runs `flutter run -d chrome --web-port=3000`. Use `--no-config` to skip config and use existing `web/config.json`.
   If the script reports "Flutter/Dart not found", either add Flutter to your PATH or use [FVM](https://fvm.app): run `fvm install` in this repo (creates `.fvm/flutter_sdk`); the script will use it automatically.

2. **Build and deploy** to hosting from scd-echocorner (S3 + CloudFront):
   ```bash
   ./tools/deploy_to_hosting.sh --env dev --variant ops
   ```
   Builds the app, uploads `build/web/` to the bucket, and invalidates CloudFront. Use `--dry-run` to preview.

3. **Manual run** (if you prefer):
   ```bash
   dart run tools/collect_config.dart --env dev --variant ops
   flutter pub get
   flutter run -d chrome
   ```

4. **Mobile platforms**: If `android/` or `ios/` are missing, run:
   ```bash
   flutter create --platforms=android,ios .
   ```

## Structure

- **lib/config** – Runtime config (Cognito, API URLs) from `config.json`.
- **lib/auth** – Amplify Auth (Hosted UI redirect), auth service, guard.
- **lib/core** – Router (go_router), setup provider, app shell.
- **lib/features** – Feature registry and feature modules (home, callback). Add new features under `lib/features/<name>/` and register in `_registry.dart`.
- **lib/data/local** – Sync metadata store; see [lib/data/local/README.md](lib/data/local/README.md) for adding a Drift database.
- **lib/data/sync** – Sync service contract and default implementation.
- **lib/data/remote** – GraphQL client and WebSocket helper for features that need live data.

## Specializing this clone for one portal

When this repo is cloned and dedicated to a single portal, set a **portal identity** (e.g. `echo myportal > .portal`). Use that value as `--variant` when running `run_local.sh` or `deploy_to_hosting.sh`, or have scripts read it to default variant. The file `.portal` is gitignored.

## Design mocks

[design/](design/) contains HTML/CSS mocks. Use them as reference for layout and branding.
