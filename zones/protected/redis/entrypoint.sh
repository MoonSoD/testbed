#!/usr/bin/env bash
set -euo pipefail

if [ -n "${SERVICE_SUBNET:-}" ] && [ -n "${SERVICE_PROTECTED_FW_PROTECTED_IP:-}" ]; then
    ip route replace "$SERVICE_SUBNET" via "$SERVICE_PROTECTED_FW_PROTECTED_IP"
fi

exec "$@"
