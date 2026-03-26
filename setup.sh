#!/bin/bash

set -e

cd "$(dirname "$0")"

case "${1:-up}" in
    up)
        echo "[*] Starting testbed..."
        docker network inspect testbed_public_net &>/dev/null || docker network create --driver bridge --subnet 172.20.10.0/24 testbed_public_net
        docker network inspect testbed_service_net &>/dev/null || docker network create --driver bridge --internal --subnet 172.20.20.0/24 testbed_service_net
        docker network inspect testbed_protected_net &>/dev/null || docker network create --driver bridge --internal --subnet 172.20.30.0/24 testbed_protected_net
        
        docker compose -f zones/protected/docker-compose.yml up -d --build
        docker compose -f zones/service/docker-compose.yml up -d --build
        docker compose -f zones/public/docker-compose.yml up -d --build
        
        echo "[+] Running on http://localhost:8888"
        ;;
    down)
        echo "[*] Stopping..."
        docker compose -f zones/public/docker-compose.yml down 2>/dev/null || true
        docker compose -f zones/service/docker-compose.yml down 2>/dev/null || true
        docker compose -f zones/protected/docker-compose.yml down 2>/dev/null || true
        echo "[+] Stopped"
        ;;
    status)
        docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(public|service|protected)" || echo "No containers"
        ;;
    *)
        echo "Usage: $0 {up|down|status}"
        exit 1
        ;;
esac
