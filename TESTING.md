# Testing Network Segmentation

## Quick Test Commands

### From Your Machine (External)

```bash
# Should work - public zone
curl http://localhost:8888/api/probe/health

# Should fail - no direct access to service
curl --connect-timeout 2 http://localhost:5001/health

# Should fail - no direct access to protected
curl --connect-timeout 2 http://localhost:6379
```

### From Inside Containers

```bash
# Public → Service (should work)
docker exec public-nginx-1 curl -s http://service-api:5001/health

# Public → Protected (should fail - no route)
docker exec public-nginx-1 curl -s --connect-timeout 2 http://protected-probe:3000/health

# Service → Protected (should work)
docker exec service-api curl -s http://protected-probe:3000/health

# Service → Redis (should work)
docker exec service-api sh -c 'echo "PING" | nc protected-redis 6379'
```

## Port Scanning with nmap

### From Your Machine

```bash
# Quick scan
nmap -p 8888,5001,6379,3000 localhost

# Expected: Only 8888 open
```

### From Public Zone (Compromised)

```bash
# Install nmap
docker exec public-nginx-1 apk add --no-cache nmap

# Scan service network
docker exec public-nginx-1 nmap -p 5001,3000 service-api

# Try protected network (should find nothing)
docker exec public-nginx-1 nmap -sn 172.20.30.0/24
```

## DNS Resolution

```bash
# From Public Zone
docker exec public-nginx-1 getent hosts public-probe    # ✅ Works
docker exec public-nginx-1 getent hosts service-api     # ✅ Works
docker exec public-nginx-1 getent hosts protected-redis # ❌ Fails
```

## Network Interfaces

```bash
# Check interfaces per container
docker exec public-nginx-1 ip addr    # 2 IPs (public + service)
docker exec service-api ip addr       # 2 IPs (service + protected)
docker exec protected-redis ip addr   # 1 IP (protected only)
```

## Why It Works

Segmentation is enforced by **network membership**:

- `protected-redis` only on `172.20.30.0/24`
- `public-nginx` on `172.20.10.0/24` and `172.20.20.0/24`
- Since `public-nginx` has no interface on `protected_net`, it cannot reach `protected-redis`
