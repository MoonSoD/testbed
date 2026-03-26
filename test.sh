#!/bin/bash

echo "Testing..."

# External access
curl -s -o /dev/null http://localhost:8888 && echo "✓ Public web reachable" || echo "✗ Public web failed"

# Cross-zone from public
docker exec public-nginx-1 curl -s --connect-timeout 2 http://service-api:5001/health >/dev/null && echo "✓ Public → Service works" || echo "✗ Public → Service failed"

# Public cannot reach protected
docker exec public-nginx-1 curl -s --connect-timeout 2 http://protected-redis:6379 >/dev/null 2>&1 && echo "✗ Public → Protected (should be blocked)" || echo "✓ Public → Protected blocked (correct)"

# Service can reach protected
docker exec service-api sh -c 'echo PING | nc -w1 protected-redis 6379' | grep -q PONG && echo "✓ Service → Protected works" || echo "✗ Service → Protected failed"

echo "Done"
