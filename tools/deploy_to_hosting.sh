#!/usr/bin/env bash
# Build the Flutter web app and deploy to S3/CloudFront using scd-echocorner portal hosting.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

ENV=""
VARIANT=""
SCD_REPO="${SCD_REPO:-$PROJECT_ROOT/../scd-echocorner}"
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $0 --env <env> --variant <variant> [options]

Builds the portal (flutter build web), writes config from scd-echocorner deploy state,
then uploads build/web/ to the S3 bucket and invalidates the CloudFront distribution
for the chosen portal variant.

Required:
  --env <name>       Environment (e.g. dev, prod)
  --variant <name>   Portal variant: ops | admins | users

Options:
  --scd-repo <path>  Path to scd-echocorner repo (default: ../scd-echocorner)
  --dry-run          Print commands only; do not build, sync, or invalidate
  -h, --help         Show this help

Prerequisites:
  - Flutter SDK (flutter build web)
  - AWS CLI configured (aws s3 sync, aws cloudfront create-invalidation)
  - scd-echocorner deploy state at \$SCD_REPO/.deployer/.deploy-state.json
    (run "scd deploy apply" there first)

Example:
  $0 --env dev --variant ops
  $0 --env prod --variant users --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV="$2"; shift 2 ;;
    --variant) VARIANT="$2"; shift 2 ;;
    --scd-repo) SCD_REPO="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$ENV" ]] || [[ -z "$VARIANT" ]]; then
  echo "Error: --env and --variant are required." >&2
  usage >&2
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] Would collect config: dart run tools/collect_config.dart --env $ENV --variant $VARIANT --scd-repo $SCD_REPO --out web/config.json"
  echo "[dry-run] Would run: flutter build web"
  echo "[dry-run] Would read BUCKET_NAME and DISTRIBUTION_ID from $SCD_REPO/.deployer/.deploy-state.json"
  echo "[dry-run] Would run: aws s3 sync build/web/ s3://\$BUCKET_NAME/ --delete"
  echo "[dry-run] Would run: aws cloudfront create-invalidation --distribution-id \$DISTRIBUTION_ID --paths '/*'"
  exit 0
fi

echo "Step 1/4: Collecting config for env=$ENV variant=$VARIANT ..."
dart run tools/collect_config.dart --env "$ENV" --variant "$VARIANT" --scd-repo "$SCD_REPO" --out web/config.json

echo "Step 2/4: Building Flutter web app ..."
flutter build web

echo "Step 3/4: Reading hosting outputs from scd-echocorner ..."
eval "$(dart run tools/get_hosting_outputs.dart --env "$ENV" --variant "$VARIANT" --scd-repo "$SCD_REPO")"
if [[ -z "${BUCKET_NAME:-}" ]]; then
  echo "Error: BUCKET_NAME not set. Check deploy state for $VARIANT hosting product." >&2
  exit 1
fi

echo "Step 4/4: Uploading to s3://$BUCKET_NAME/ and invalidating CloudFront ..."
aws s3 sync build/web/ "s3://$BUCKET_NAME/" --delete

if [[ -n "${DISTRIBUTION_ID:-}" ]]; then
  aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"
  echo "Deployed. CloudFront invalidation created for distribution $DISTRIBUTION_ID"
else
  echo "Deployed to S3. DISTRIBUTION_ID was empty; skipping CloudFront invalidation."
fi
