#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

source .env.generated

pass() { echo "✓ $1"; }
fail() { echo "✗ $1"; exit 1; }

curl -s -o /dev/null "http://localhost:${PUBLIC_WEB_HOST_PORT}" && pass "Public web reachable from host" || fail "Public web failed from host"

./scenario.sh baseline >/dev/null
docker exec kali-attacker curl -s --connect-timeout 2 "http://${SERVICE_API_IP}:${SERVICE_API_PORT}/health" >/dev/null \
  && fail "Baseline should block public -> service" \
  || pass "Baseline blocks public -> service"

./scenario.sh service-open >/dev/null
docker exec kali-attacker curl -s --connect-timeout 2 "http://${SERVICE_API_IP}:${SERVICE_API_PORT}/health" >/dev/null \
  && pass "service-open allows public -> service API" \
  || fail "service-open did not allow public -> service API"

docker exec service-api sh -c "echo PING | nc -w1 ${PROTECTED_REDIS_IP} ${PROTECTED_REDIS_PORT}" | grep -q PONG \
  && fail "service-open should not allow service -> protected Redis" \
  || pass "service-open blocks service -> protected Redis"

./scenario.sh data-open >/dev/null
docker exec service-api sh -c "echo PING | nc -w1 ${PROTECTED_REDIS_IP} ${PROTECTED_REDIS_PORT}" | grep -q PONG \
  && pass "data-open allows service -> protected Redis" \
  || fail "data-open did not allow service -> protected Redis"

docker exec kali-attacker curl -s --connect-timeout 2 "http://${SERVICE_API_IP}:${SERVICE_API_PORT}/data" | grep -q '"source":"protected"' \
  && pass "data-open allows attacker to retrieve protected data through service API" \
  || fail "data-open did not allow protected data through service API"

docker exec kali-attacker sh -c "echo PING | nc -w1 ${PROTECTED_REDIS_IP} ${PROTECTED_REDIS_PORT}" >/dev/null 2>&1 \
  && fail "Kali should not directly reach protected Redis" \
  || pass "Kali cannot directly reach protected Redis"

./scenario.sh hardened >/dev/null
docker exec kali-attacker curl -s --connect-timeout 2 "http://${SERVICE_API_IP}:${SERVICE_API_PORT}/health" >/dev/null \
  && fail "hardened should block public -> service" \
  || pass "hardened blocks public -> service"

echo "Done"
