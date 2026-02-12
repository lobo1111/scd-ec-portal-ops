# Config collection tools

Tools that generate the portal app’s `config.json` from **scd-echocorner** deploy state.

## Prerequisites

- **scd-echocorner** must have been deployed at least once so that `.deployer/.deploy-state.json` exists (e.g. run `scd deploy apply -e dev` in that repo).
- Run from the **flut-template** repo root (or pass `--scd-repo` to point at scd-echocorner).

## collect_config.dart

Reads deploy state and profiles from scd-echocorner and writes a single JSON config file for the Flutter app.

### Usage

```bash
# From flut-template root
dart run tools/collect_config.dart --env dev --variant ops
```

**Required:**

- `--env <name>` – Environment (e.g. `dev`, `prod`). Must exist in `.deployer/.deploy-state.json`.
- `--variant <name>` – Portal variant: `ops` | `admins` | `users`.

**Optional:**

- `--scd-repo <path>` – Path to the scd-echocorner repo (default: `../scd-echocorner`).
- `--out <path>` – Output file (default: `web/config.json`).
- `--all-variants` – Write one file per variant: `web/config.<variant>.<env>.json` (e.g. `web/config.ops.dev.json`). Do not pass `--variant` when using this.

### Sources

| Source | Used for |
|--------|----------|
| `$SCD_REPO/.deployer/.deploy-state.json` | `environments.<env>.products.<product_key>.outputs` (UserPoolId, UserPoolClientId, HostedUiDomain, PortalUrl, ApiUrl, GraphQLEndpoint) |
| `$SCD_REPO/.deployer/profiles.yaml` | `profiles.<env>.aws_region` for `region` |

### Product mapping (per variant)

| Variant | Cognito product | Hosting product | API product |
|---------|-----------------|----------------|-------------|
| ops | ec_security_cognito_operators_portal_auth | ec_web_spa_ops_portal_hosting | ec_api_ops_portal |
| admins | ec_security_cognito_admins_portal_auth | ec_web_spa_admins_portal_hosting | ec_api_admins_portal |
| users | ec_security_cognito_users_portal_auth | ec_web_spa_users_portal_hosting | ec_api_users_portal |

### Output shape

The generated JSON matches the app’s [AppConfig](lib/config/app_config.dart): `userPoolId`, `userPoolClientId`, `cognitoHostedUiDomain`, `region` (required); `portalUrl`, `apiBaseUrl`, `graphqlEndpoint` (optional, empty string if missing).

### Examples

```bash
# Dev ops portal config → web/config.json
dart run tools/collect_config.dart --env dev --variant ops

# Prod users portal config → web/config.users.prod.json
dart run tools/collect_config.dart --env prod --variant users --out web/config.users.prod.json

# All three variants for dev (writes config.ops.dev.json, config.admins.dev.json, config.users.dev.json)
dart run tools/collect_config.dart --env dev --all-variants --out web/
```

---

## run_local.sh

Runs the portal locally with Flutter web (Chrome). Optionally writes `web/config.json` from scd-echocorner so auth and API URLs match the chosen environment.

### Usage

```bash
./tools/run_local.sh [options]
```

**Options (or set env vars):**

- `--env <name>` – Environment (default: `dev`)
- `--variant <name>` – Portal variant: `ops` | `admins` | `users` (default: `ops`)
- `--scd-repo <path>` – Path to scd-echocorner (default: `../scd-echocorner`)
- `--no-config` – Skip collecting config; use existing `web/config.json`
- `--web-port <port>` – Port for web server (default: `3000`). Must match Cognito callback URL (e.g. `http://localhost:3000/callback`).

**Examples:**

```bash
./tools/run_local.sh --env dev --variant ops
VARIANT=users ./tools/run_local.sh
./tools/run_local.sh --no-config   # use current web/config.json only
```

Ensure the Cognito app client in scd-echocorner has `http://localhost:3000/callback` (and your port) in **CallbackUrls** for local sign-in.

---

## get_hosting_outputs.dart

Prints `BUCKET_NAME` and `DISTRIBUTION_ID` for the portal hosting product so deploy scripts can upload to S3 and invalidate CloudFront.

### Usage

```bash
eval $(dart run tools/get_hosting_outputs.dart --env dev --variant ops [--scd-repo <path>])
# Then: aws s3 sync build/web/ s3://$BUCKET_NAME/ --delete
#       aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

Used by [deploy_to_hosting.sh](#deploy_to_hostingsh); you normally don’t call it directly.

---

## deploy_to_hosting.sh

Builds the Flutter web app and deploys it to the S3 bucket and CloudFront distribution provisioned by scd-echocorner for the chosen portal variant.

### Usage

```bash
./tools/deploy_to_hosting.sh --env <env> --variant <variant> [options]
```

**Required:**

- `--env <name>` – Environment (e.g. `dev`, `prod`)
- `--variant <name>` – Portal variant: `ops` | `admins` | `users`

**Options:**

- `--scd-repo <path>` – Path to scd-echocorner (default: `../scd-echocorner`)
- `--dry-run` – Print what would be done; do not build, sync, or invalidate

**Steps performed:**

1. Run `collect_config` to write `web/config.json` for the target env/variant.
2. Run `flutter build web`.
3. Read `BUCKET_NAME` and `DISTRIBUTION_ID` from scd-echocorner deploy state for the hosting product.
4. `aws s3 sync build/web/ s3://$BUCKET_NAME/ --delete`
5. `aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"`

**Prerequisites:**

- Flutter SDK
- AWS CLI configured (credentials for the account where scd-echocorner resources live)
- scd-echocorner deploy state present (run `scd deploy apply` there first)

**Examples:**

```bash
./tools/deploy_to_hosting.sh --env dev --variant ops
./tools/deploy_to_hosting.sh --env prod --variant users --dry-run
```
