#!/usr/bin/env bash
# Run the portal locally (Flutter web). Optionally pulls config from scd-echocorner deploy state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Prefer project-local Flutter (FVM) so the script works without global PATH
if [[ -d "$PROJECT_ROOT/.fvm/flutter_sdk/bin" ]]; then
  export PATH="$PROJECT_ROOT/.fvm/flutter_sdk/bin:$PATH"
fi

ENV="${ENV:-dev}"
VARIANT="${VARIANT:-ops}"
SCD_REPO="${SCD_REPO:-$PROJECT_ROOT/../scd-echocorner}"
WEB_PORT="${WEB_PORT:-3000}"

usage() {
  cat <<EOF
Usage: $0 [options]

Runs the Flutter portal locally (Chrome). If --config is used, writes web/config.json
from scd-echocorner deploy state first so auth and API URLs match the chosen environment.

Options (or set env vars):
  --env <name>       Environment (default: dev)
  --variant <name>   Portal variant: ops | admins | users (default: ops)
  --scd-repo <path> Path to scd-echocorner (default: ../scd-echocorner)
  --no-config        Skip collecting config; use existing web/config.json
  --web-port <port>  Port for web server (default: 3000). Must match Cognito callback URL.
  -h, --help         Show this help

Cognito callback for local dev is typically http://localhost:3000/callback.
Ensure the app client in scd-echocorner has that URL in CallbackUrls.

Example:
  $0 --env dev --variant ops
  VARIANT=users $0
EOF
}

NO_CONFIG=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV="$2"; shift 2 ;;
    --variant) VARIANT="$2"; shift 2 ;;
    --scd-repo) SCD_REPO="$2"; shift 2 ;;
    --no-config) NO_CONFIG=true; shift ;;
    --web-port) WEB_PORT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# Resolve dart and flutter (project .fvm already on PATH if present)
DART_CMD=
FLUTTER_CMD=
if command -v dart &>/dev/null; then
  DART_CMD="dart run"
fi
if command -v flutter &>/dev/null; then
  FLUTTER_CMD="flutter"
  if [[ -z "$DART_CMD" ]]; then
    FLUTTER_BIN="$(dirname "$(command -v flutter)")"
    DART_CMD="$FLUTTER_BIN/dart run"
  fi
fi
if [[ -z "$DART_CMD" || -z "$FLUTTER_CMD" ]]; then
  echo "Error: Flutter/Dart not found. Install Flutter SDK, or run 'fvm install' in this project." >&2
  exit 1
fi

if [[ "$NO_CONFIG" != true ]]; then
  echo "Collecting config for env=$ENV variant=$VARIANT from $SCD_REPO ..."
  $DART_CMD tools/collect_config.dart --env "$ENV" --variant "$VARIANT" --scd-repo "$SCD_REPO" --out web/config.json
fi

echo "Starting Flutter web app on port $WEB_PORT ..."
exec $FLUTTER_CMD run -d chrome --web-port="$WEB_PORT"
