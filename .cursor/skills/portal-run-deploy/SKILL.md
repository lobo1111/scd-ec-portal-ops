---
name: portal-run-deploy
description: Run portal locally and deploy to hosting (S3 + CloudFront). Use when running locally, building, deploying, or debugging deploy-state paths.
---

# Portal run and deploy skill

## Run locally

- **Script**: `tools/run_local.sh`
- **Options**: `--env`, `--variant`, `--scd-repo`, `--no-config`, `--web-port` (default 3000 for Cognito callback).
- **Behavior**: Unless `--no-config`, runs `tools/collect_config.dart` for the given env/variant to write `web/config.json`, then runs `flutter run -d chrome --web-port=...`.
- When the clone has a portal identity (e.g. `.portal`), variant can default from it; otherwise pass `--variant` explicitly.

## Deploy to hosting

- **Script**: `tools/deploy_to_hosting.sh`
- **Required**: `--env`, `--variant`
- **Options**: `--scd-repo`, `--dry-run`
- **Steps**:
  1. Run `tools/collect_config.dart` for env/variant → `web/config.json`
  2. `flutter build web`
  3. Read bucket and distribution from deploy state via `tools/get_hosting_outputs.dart` (same env/variant)
  4. `aws s3 sync build/web/ s3://<bucket>/ --delete`
  5. `aws cloudfront create-invalidation --distribution-id <id> --paths "/*"`
- When the clone has a portal identity, variant can default from it for both config and hosting outputs.

## Prerequisites

- Flutter SDK for run and build.
- AWS CLI configured for deploy (S3, CloudFront).
- Deploy state available at the configured scd-repo path (e.g. `.deployer/.deploy-state.json`).
