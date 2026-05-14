#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .env.generated ]; then
    echo "[!] .env.generated missing. Run ./setup.sh render-config first."
    exit 1
fi

set -a
source .env.generated
set +a

require_container() {
    local name="$1"
    if ! docker ps --format '{{.Names}}' | grep -qx "$name"; then
        echo "[!] Container not running: $name"
        exit 1
    fi
}

reset_fw() {
    local container="$1"
    docker exec "$container" iptables -F
    docker exec "$container" conntrack -F >/dev/null 2>&1 || true
    docker exec "$container" iptables -P FORWARD DROP
    docker exec "$container" iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
}

reset_all() {
    require_container public-service-fw
    require_container service-protected-fw
    reset_fw public-service-fw
    reset_fw service-protected-fw
}

baseline() {
    reset_all
    echo "[+] Applied baseline: cross-zone traffic denied"
}

service_open() {
    reset_all
    docker exec public-service-fw iptables -A FORWARD -s "$PUBLIC_SUBNET" -d "$SERVICE_API_IP" -p tcp --dport "$PUBLIC_SERVICE_ALLOWED_PORT" -j ACCEPT
    echo "[+] Applied service-open: public -> service API allowed"
}

data_open() {
    service_open
    docker exec service-protected-fw iptables -A FORWARD -s "$SERVICE_API_IP" -d "$PROTECTED_REDIS_IP" -p tcp --dport "$SERVICE_PROTECTED_ALLOWED_PORT" -j ACCEPT
    echo "[+] Applied data-open: service API -> protected Redis allowed"
}

hardened() {
    baseline
    echo "[+] Applied hardened: only public entry remains"
}

status() {
    require_container public-service-fw
    require_container service-protected-fw
    echo "== public-service-fw =="
    docker exec public-service-fw iptables -S FORWARD
    echo "== service-protected-fw =="
    docker exec service-protected-fw iptables -S FORWARD
}

case "${1:-}" in
    baseline) baseline ;;
    service-open) service_open ;;
    data-open) data_open ;;
    hardened) hardened ;;
    status) status ;;
    *) echo "Usage: $0 {baseline|service-open|data-open|hardened|status}"; exit 1 ;;
esac
