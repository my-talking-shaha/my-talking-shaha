#!/usr/bin/env bash
set -Eeuo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker/docker-compose.blue-green.yml}"
DEPLOY_STATE_DIR="${DEPLOY_STATE_DIR:-.deploy}"
ACTIVE_SLOT_FILE="$DEPLOY_STATE_DIR/active-slot"
NGINX_STATE_DIR="$DEPLOY_STATE_DIR/nginx"
ACTIVE_UPSTREAMS_FILE="$NGINX_STATE_DIR/active-upstreams.conf"

log() {
  printf '[blue-green] %s\n' "$*"
}

is_slot() {
  [ "${1:-}" = "blue" ] || [ "${1:-}" = "green" ]
}

opposite_slot() {
  case "$1" in
    blue) printf 'green' ;;
    green) printf 'blue' ;;
    *) printf 'blue' ;;
  esac
}

detect_compose() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_COMMAND=(docker compose)
  elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_COMMAND=(docker-compose)
  else
    log "Docker Compose is not installed"
    exit 1
  fi
}

compose() {
  "${COMPOSE_COMMAND[@]}" -f "$COMPOSE_FILE" "$@"
}

require_env() {
  local name
  for name in "$@"; do
    if [ -z "${!name:-}" ]; then
      log "$name environment variable is required"
      exit 1
    fi
  done
}

container_running() {
  local name="$1"
  [ "$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null || true)" = "true" ]
}

read_active_slot() {
  if [ ! -f "$ACTIVE_SLOT_FILE" ]; then
    return 1
  fi

  tr -d '[:space:]' < "$ACTIVE_SLOT_FILE"
}

write_active_upstreams() {
  local slot="$1"

  mkdir -p "$NGINX_STATE_DIR"
  cat > "$ACTIVE_UPSTREAMS_FILE.tmp" <<EOF
upstream frontend_active {
    server frontend-$slot:80;
}

upstream backend_active {
    server backend-$slot:8080;
}
EOF
  mv "$ACTIVE_UPSTREAMS_FILE.tmp" "$ACTIVE_UPSTREAMS_FILE"
}

write_active_slot() {
  local slot="$1"

  mkdir -p "$DEPLOY_STATE_DIR"
  printf '%s\n' "$slot" > "$ACTIVE_SLOT_FILE.tmp"
  mv "$ACTIVE_SLOT_FILE.tmp" "$ACTIVE_SLOT_FILE"
}

dump_diagnostics() {
  set +e
  log "diagnostics=dump_start"
  df -h >&2 || true
  free -h >&2 || true
  docker system df >&2 || true
  docker ps -a >&2 || true
  compose ps postgres backend-blue frontend-blue backend-green frontend-green router >&2 || true
  compose logs --no-color --tail=200 postgres backend-blue frontend-blue backend-green frontend-green router >&2 || true
  log "diagnostics=dump_end"
  set -e
}

on_error() {
  local status=$?
  log "unhandled_error_exit_code=$status"
  dump_diagnostics
  exit "$status"
}

trap on_error ERR

wait_backend_slot() {
  local slot="$1"
  local attempt

  for attempt in {1..30}; do
    if compose exec -T "backend-$slot" curl -fsS http://localhost:8080/actuator/health >/dev/null; then
      log "backend_health=pass slot=$slot"
      return 0
    fi

    log "backend_health=waiting slot=$slot attempt=$attempt/30"
    sleep 5
  done

  log "backend_health=fail slot=$slot"
  return 1
}

curl_from_slot() {
  local slot="$1"
  shift

  compose exec -T "backend-$slot" curl "$@"
}

verify_slot_before_switch() {
  local slot="$1"
  local api_status

  log "pre_switch_verification=start target_slot=$slot"

  if ! wait_backend_slot "$slot"; then
    return 1
  fi

  for attempt in {1..30}; do
    if curl_from_slot "$slot" -fsS "http://frontend-$slot/health" >/dev/null; then
      log "frontend_health=pass slot=$slot"
      break
    fi

    if [ "$attempt" = "30" ]; then
      log "frontend_health=fail slot=$slot"
      return 1
    fi

    log "frontend_health=waiting slot=$slot attempt=$attempt/30"
    sleep 5
  done

  if ! curl_from_slot "$slot" -fsS "http://frontend-$slot/v3/api-docs" >/dev/null; then
    log "openapi=fail slot=$slot"
    return 1
  fi
  log "openapi=pass slot=$slot"

  if ! curl_from_slot "$slot" -fsS "http://frontend-$slot/swagger-ui.html" | grep -q "SwaggerUIBundle"; then
    log "swagger_ui=fail slot=$slot page=html"
    return 1
  fi

  if ! curl_from_slot "$slot" -fsS "http://frontend-$slot/webjars/swagger-ui/5.32.2/swagger-ui.css" | grep -q "swagger-ui"; then
    log "swagger_ui=fail slot=$slot page=css"
    return 1
  fi
  log "swagger_ui=pass slot=$slot"

  api_status="$(curl_from_slot "$slot" -sS -o /tmp/deploy-api-check-body -w '%{http_code}' "http://frontend-$slot/api/v1/users/me")"
  api_status="${api_status//$'\r'/}"
  case "$api_status" in
    401|403)
      log "api_route=pass slot=$slot expected_status=$api_status"
      ;;
    *)
      log "api_route=fail slot=$slot status=$api_status"
      return 1
      ;;
  esac

  log "pre_switch_verification=pass target_slot=$slot"
}

wait_public_health() {
  local attempt

  for attempt in {1..30}; do
    if curl -fsS http://localhost/health >/dev/null; then
      return 0
    fi

    log "router_health=waiting attempt=$attempt/30"
    sleep 2
  done

  return 1
}

activate_router_slot() {
  local slot="$1"
  local recreate="${2:-false}"

  write_active_upstreams "$slot"

  if container_running talking-shaha-router && [ "$recreate" != "true" ] &&
    docker exec talking-shaha-router test -f /etc/nginx/blue-green/active-upstreams.conf; then
    if ! docker exec talking-shaha-router nginx -t; then
      return 1
    fi

    if ! docker exec talking-shaha-router nginx -s reload; then
      return 1
    fi
  else
    if ! compose up -d --force-recreate router; then
      return 1
    fi
  fi

  if ! wait_public_health; then
    return 1
  fi
}

verify_public_after_switch() {
  local slot="$1"
  local api_status

  log "post_switch_verification=start active_slot=$slot"

  if ! wait_backend_slot "$slot"; then
    return 1
  fi

  if ! curl -fsS http://localhost/health >/dev/null; then
    log "frontend_health=fail public=true active_slot=$slot"
    return 1
  fi
  log "frontend_health=pass public=true active_slot=$slot"

  if ! curl -fsS http://localhost/v3/api-docs >/dev/null; then
    log "openapi=fail public=true active_slot=$slot"
    return 1
  fi
  log "openapi=pass public=true active_slot=$slot"

  if ! curl -fsS http://localhost/swagger-ui.html | grep -q "SwaggerUIBundle"; then
    log "swagger_ui=fail public=true active_slot=$slot page=html"
    return 1
  fi

  if ! curl -fsS http://localhost/webjars/swagger-ui/5.32.2/swagger-ui.css | grep -q "swagger-ui"; then
    log "swagger_ui=fail public=true active_slot=$slot page=css"
    return 1
  fi
  log "swagger_ui=pass public=true active_slot=$slot"

  api_status="$(curl -sS -o /tmp/deploy-public-api-check-body -w '%{http_code}' http://localhost/api/v1/users/me)"
  api_status="${api_status//$'\r'/}"
  case "$api_status" in
    401|403)
      log "api_route=pass public=true active_slot=$slot expected_status=$api_status"
      ;;
    *)
      log "api_route=fail public=true active_slot=$slot status=$api_status"
      return 1
      ;;
  esac

  log "post_switch_verification=pass active_slot=$slot"
}

rollback_to_previous() {
  local previous_slot="$1"
  local target_slot="$2"

  if ! is_slot "$previous_slot"; then
    log "rollback_status=unavailable previous_slot=none"
    return 1
  fi

  log "rollback_status=starting previous_slot=$previous_slot target_slot=$target_slot"

  if activate_router_slot "$previous_slot"; then
    write_active_slot "$previous_slot"
    if verify_public_after_switch "$previous_slot"; then
      compose stop "frontend-$target_slot" "backend-$target_slot" >/dev/null || true
      log "rollback_status=succeeded active_slot=$previous_slot stopped_slot=$target_slot"
      return 0
    fi
  fi

  log "rollback_status=failed previous_slot=$previous_slot"
  return 1
}

stop_legacy_stack_for_initial_switch() {
  if container_running talking-shaha-frontend || container_running talking-shaha-backend; then
    log "legacy_stack=detected action=stop_before_initial_router_start"
    docker stop talking-shaha-frontend talking-shaha-backend >/dev/null 2>&1 || true
  fi
}

main() {
  require_env JWT_SECRET DB_USERNAME DB_PASSWORD BACKEND_IMAGE FRONTEND_IMAGE DEPLOY_STATE_DIR
  detect_compose

  local active_slot
  local target_slot
  local first_deploy=false

  active_slot="$(read_active_slot || true)"
  if ! is_slot "$active_slot"; then
    active_slot="none"
    target_slot="blue"
    first_deploy=true
  else
    target_slot="$(opposite_slot "$active_slot")"
  fi

  log "active_slot=$active_slot target_slot=$target_slot backend_image=$BACKEND_IMAGE frontend_image=$FRONTEND_IMAGE"

  if is_slot "$active_slot"; then
    write_active_upstreams "$active_slot"
    activate_router_slot "$active_slot" || {
      log "router_active_slot_check=failed active_slot=$active_slot"
      exit 1
    }
  fi

  compose up -d postgres

  if ! compose pull "backend-$target_slot" "frontend-$target_slot"; then
    log "image_pull=failed target_slot=$target_slot"
    exit 1
  fi
  log "image_pull=pass target_slot=$target_slot"

  if ! compose up -d --no-build --force-recreate "backend-$target_slot" "frontend-$target_slot"; then
    log "switch_result=not_attempted target_slot=$target_slot reason=target_start_failed"
    log "rollback_status=not_needed active_slot=$active_slot"
    dump_diagnostics
    exit 1
  fi

  if ! verify_slot_before_switch "$target_slot"; then
    log "switch_result=not_attempted target_slot=$target_slot reason=pre_switch_verification_failed"
    log "rollback_status=not_needed active_slot=$active_slot"
    compose stop "frontend-$target_slot" "backend-$target_slot" >/dev/null || true
    dump_diagnostics
    exit 1
  fi

  if [ "$first_deploy" = "true" ]; then
    stop_legacy_stack_for_initial_switch
  fi

  if ! activate_router_slot "$target_slot" "$first_deploy"; then
    log "switch_result=failed target_slot=$target_slot reason=router_activation_failed"
    rollback_to_previous "$active_slot" "$target_slot" || true
    dump_diagnostics
    exit 1
  fi

  write_active_slot "$target_slot"
  log "switch_result=switched previous_slot=$active_slot active_slot=$target_slot"

  if ! verify_public_after_switch "$target_slot"; then
    log "switch_result=failed_post_switch previous_slot=$active_slot target_slot=$target_slot"
    rollback_to_previous "$active_slot" "$target_slot" || {
      dump_diagnostics
      exit 1
    }
    dump_diagnostics
    exit 1
  fi

  log "rollback_status=not_needed active_slot=$target_slot"
  compose ps postgres backend-blue frontend-blue backend-green frontend-green router
  docker image prune -f
}

main "$@"
