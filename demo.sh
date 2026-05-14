#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
source .env.generated

run_attacker() {
    docker exec kali-attacker sh -lc "$*"
}

task1() {
    echo "== Task 1: Recon Public Zone =="
    ./scenario.sh baseline
    echo "Expected: public web reachable; service API blocked."
    run_attacker "nmap -Pn -p ${PUBLIC_WEB_PORT},${SERVICE_API_PORT} ${PUBLIC_WEB_IP} ${SERVICE_API_IP} || true"
    run_attacker "curl -s --connect-timeout 2 http://${SERVICE_API_IP}:${SERVICE_API_PORT}/health || true"
}

task2() {
    echo "== Task 2: Open Service Boundary =="
    ./scenario.sh service-open
    echo "Expected: service API reachable from attacker."
    run_attacker "nmap -Pn -p ${SERVICE_API_PORT} ${SERVICE_API_IP} || true"
    run_attacker "curl -s http://${SERVICE_API_IP}:${SERVICE_API_PORT}/health"
}

task3() {
    echo "== Task 3: Reach Protected Data Through Service =="
    ./scenario.sh data-open
    echo "Expected: protected Redis is accessed indirectly through service API."
    run_attacker "curl -s http://${SERVICE_API_IP}:${SERVICE_API_PORT}/data"
    run_attacker "echo PING | nc -w1 ${PROTECTED_REDIS_IP} ${PROTECTED_REDIS_PORT} || true"
}

task4() {
    echo "== Task 4: Harden And Verify =="
    ./scenario.sh hardened
    echo "Expected: service API is blocked again."
    run_attacker "curl -s --connect-timeout 2 http://${SERVICE_API_IP}:${SERVICE_API_PORT}/health || true"
    ./scenario.sh status
}

case "${1:-}" in
    task1) task1 ;;
    task2) task2 ;;
    task3) task3 ;;
    task4) task4 ;;
    all) task1; task2; task3; task4 ;;
    *) echo "Usage: $0 {task1|task2|task3|task4|all}"; exit 1 ;;
esac
