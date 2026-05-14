#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

require_yq() {
    if ! command -v yq >/dev/null 2>&1; then
        echo "[!] yq is required. Install it first: https://github.com/mikefarah/yq"
        exit 1
    fi
}

render_config() {
    require_yq
    local topology="config/topology.yml"
    local env_file=".env.generated"

    echo "[*] Rendering $env_file from $topology..."
    cat > "$env_file" <<EOF
PUBLIC_NET_NAME=$(yq -r '.zones.public.network_name' "$topology")
SERVICE_NET_NAME=$(yq -r '.zones.service.network_name' "$topology")
PROTECTED_NET_NAME=$(yq -r '.zones.protected.network_name' "$topology")
PUBLIC_SUBNET=$(yq -r '.zones.public.subnet' "$topology")
SERVICE_SUBNET=$(yq -r '.zones.service.subnet' "$topology")
PROTECTED_SUBNET=$(yq -r '.zones.protected.subnet' "$topology")
PUBLIC_WEB_IP=$(yq -r '.zones.public.services.web.ip' "$topology")
PUBLIC_WEB_PORT=$(yq -r '.zones.public.services.web.port' "$topology")
PUBLIC_WEB_HOST_PORT=$(yq -r '.zones.public.services.web.host_port' "$topology")
PUBLIC_PROBE_IP=$(yq -r '.zones.public.services.probe.ip' "$topology")
PUBLIC_PROBE_PORT=$(yq -r '.zones.public.services.probe.port' "$topology")
KALI_ATTACKER_IP=$(yq -r '.zones.public.services.attacker.ip' "$topology")
SERVICE_API_IP=$(yq -r '.zones.service.services.api.ip' "$topology")
SERVICE_API_PORT=$(yq -r '.zones.service.services.api.port' "$topology")
SERVICE_PROBE_IP=$(yq -r '.zones.service.services.probe.ip' "$topology")
SERVICE_PROBE_PORT=$(yq -r '.zones.service.services.probe.port' "$topology")
PROTECTED_REDIS_IP=$(yq -r '.zones.protected.services.redis.ip' "$topology")
PROTECTED_REDIS_PORT=$(yq -r '.zones.protected.services.redis.port' "$topology")
PROTECTED_PROBE_IP=$(yq -r '.zones.protected.services.probe.ip' "$topology")
PROTECTED_PROBE_PORT=$(yq -r '.zones.protected.services.probe.port' "$topology")
PUBLIC_SERVICE_FW_PUBLIC_IP=$(yq -r '.boundaries.public_service.public_ip' "$topology")
PUBLIC_SERVICE_FW_SERVICE_IP=$(yq -r '.boundaries.public_service.service_ip' "$topology")
PUBLIC_SERVICE_ALLOWED_PORT=$(yq -r '.boundaries.public_service.allowed_ports.service_api' "$topology")
SERVICE_PROTECTED_FW_SERVICE_IP=$(yq -r '.boundaries.service_protected.service_ip' "$topology")
SERVICE_PROTECTED_FW_PROTECTED_IP=$(yq -r '.boundaries.service_protected.protected_ip' "$topology")
SERVICE_PROTECTED_ALLOWED_PORT=$(yq -r '.boundaries.service_protected.allowed_ports.redis' "$topology")
EOF
    echo "[+] Rendered $env_file"
}

load_generated_env() {
    if [ ! -f .env.generated ]; then
        render_config
    fi

    set -a
    source .env.generated
    set +a
}

compose() {
    docker compose --env-file .env.generated "$@"
}

case "${1:-up}" in
    up)
        render_config
        load_generated_env

        echo "[*] Starting testbed..."
        docker network inspect "$PUBLIC_NET_NAME" >/dev/null 2>&1 || docker network create --driver bridge --subnet "$PUBLIC_SUBNET" "$PUBLIC_NET_NAME"
        docker network inspect "$SERVICE_NET_NAME" >/dev/null 2>&1 || docker network create --driver bridge --subnet "$SERVICE_SUBNET" "$SERVICE_NET_NAME"
        docker network inspect "$PROTECTED_NET_NAME" >/dev/null 2>&1 || docker network create --driver bridge --subnet "$PROTECTED_SUBNET" "$PROTECTED_NET_NAME"

        compose -f boundaries/public-service/docker-compose.yml up -d --build
        compose -f boundaries/service-protected/docker-compose.yml up -d --build
        compose -f zones/protected/docker-compose.yml up -d --build
        compose -f zones/service/docker-compose.yml up -d --build
        compose -f zones/public/docker-compose.yml up -d --build
        compose -f attacker/docker-compose.yml up -d --build
        
        echo "[+] Running on http://localhost:8888"
        ;;
    down)
        load_generated_env
        echo "[*] Stopping..."
        compose -f attacker/docker-compose.yml down 2>/dev/null || true
        compose -f zones/public/docker-compose.yml down 2>/dev/null || true
        compose -f zones/service/docker-compose.yml down 2>/dev/null || true
        compose -f zones/protected/docker-compose.yml down 2>/dev/null || true
        compose -f boundaries/service-protected/docker-compose.yml down 2>/dev/null || true
        compose -f boundaries/public-service/docker-compose.yml down 2>/dev/null || true
        echo "[+] Stopped"
        ;;
    status)
        docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(public|service|protected|kali)" || echo "No containers"
        ;;
    render-config)
        render_config
        ;;
    *)
        echo "Usage: $0 {up|down|status|render-config}"
        exit 1
        ;;
esac
