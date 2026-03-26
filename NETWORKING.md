# Networking Deep Dive

## The 3 Networks

| Network | Subnet | Purpose |
|---------|--------|---------|
| testbed_public_net | 172.20.10.0/24 | External access |
| testbed_service_net | 172.20.20.0/24 | Internal only |
| testbed_protected_net | 172.20.30.0/24 | Internal only |

## Why These Subnets?

- **172.20.x.x**: Private IP range (RFC 1918), avoids collision with common 192.168.x.x
- **/24 mask**: Standard subnet, 254 usable IPs
- **10, 20, 30**: Easy to remember: 10=public, 20=service, 30=protected

## Multi-Homed Containers

Some containers connect to multiple networks:

```
public-nginx:
  - eth0: 172.20.10.3 (public_net)
  - eth1: 172.20.20.4 (service_net)
  
service-api:
  - eth0: 172.20.20.3 (service_net)
  - eth1: 172.20.30.4 (protected_net)
```

These act as **bridges** between zones.

## How Isolation Works

```
protected-redis:
  - eth0: 172.20.30.3 (protected_net ONLY)
  
  No interfaces on:
    - 172.20.10.x (public_net)
    - 172.20.20.x (service_net)
    
  Result: Kernel drops packets from those networks
```

## DNS Resolution

Docker provides DNS at 127.0.0.11. Containers resolve names to IPs:

```bash
# From public-nginx
nslookup service-api → 172.20.20.3
nslookup protected-redis → NXDOMAIN (not on same network)
```

## Traffic Flow

### External → Public
```
Your Mac → Docker port 8888 → nginx container
```

### Public → Service
```
nginx (172.20.20.4) → service-api (172.20.20.3)
Same network, direct communication
```

### Service → Protected
```
service-api (172.20.30.4) → redis (172.20.30.3)
Same network, direct communication
```

### Public → Protected (BLOCKED)
```
nginx tries → 172.20.30.3
No route: "Network unreachable"
```
