#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PROMPT_FILE="${1:-$SCRIPT_DIR/prompt.txt}"
TARGET_EMAIL="${2:-${TARGET_EMAIL:-}}"

if [ -f "$REPO_ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$REPO_ROOT/.env"
  set +a
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-talking_shaha}"
DB_USERNAME="${DB_USERNAME:-}"
DB_PASSWORD="${DB_PASSWORD:-}"

if [ -z "$TARGET_EMAIL" ]; then
  echo "Usage: $0 [prompt_file] <user_email>" >&2
  echo "Example: $0 \"$SCRIPT_DIR/prompt.txt\" user@example.com" >&2
  exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

if [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
  echo "DB_USERNAME and DB_PASSWORD must be set in environment or .env" >&2
  exit 1
fi

PROMPT_CONTENT=$(cat "$PROMPT_FILE")
export PGPASSWORD="$DB_PASSWORD"

UPDATED_ROWS=$(
  psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USERNAME" \
    -d "$DB_NAME" \
    -t -A \
    -v ON_ERROR_STOP=1 \
    -v target_email="$TARGET_EMAIL" \
    -v prompt="$PROMPT_CONTENT" <<'SQL'
WITH updated AS (
  UPDATE app_users
     SET ai_system_prompt = :'prompt'
   WHERE email = :'target_email'
  RETURNING id
)
SELECT COUNT(*) FROM updated;
SQL
)

if [ "$UPDATED_ROWS" = "0" ]; then
  echo "No user found with email: $TARGET_EMAIL" >&2
  exit 1
fi

echo "Prompt updated for $TARGET_EMAIL"
