# Networking Deep Dive

## Networks

| Network | Subnet | Purpose |
|---------|--------|---------|
| `testbed_public_net` | `172.20.10.0/24` | Public web, probe, and Kali attacker |
| `testbed_service_net` | `172.20.20.0/24` | Service API and service probe |
| `testbed_protected_net` | `172.20.30.0/24` | Redis and protected probe |

Docker networks are subnets for wiring. They are not treated as the primary security boundary.

## Routing Model

Only firewall/router boundary containers are multi-homed. Normal services live in one zone. Cross-zone routes point at boundary modules. `iptables` controls which directional flows are allowed.

```text
public-nginx routes 172.20.20.0/24 via 172.20.10.254
service-api routes 172.20.10.0/24 via 172.20.20.254
service-api routes 172.20.30.0/24 via 172.20.20.253
protected-redis routes 172.20.20.0/24 via 172.20.30.254
kali-attacker routes 172.20.20.0/24 via 172.20.10.254
```

Kali deliberately has no direct route to `172.20.30.0/24`. Its default route is removed at startup so Docker's bridge gateway cannot bypass the demonstrator boundary.

## Traffic Flow

### Host to Public

```text
Host localhost:8888 -> public-nginx 172.20.10.10:80
```

### Public to Service

```text
kali-attacker -> public-service-fw -> service-api:5001
```

Allowed only when `./scenario.sh service-open` or `./scenario.sh data-open` is active.

### Service to Protected

```text
service-api -> service-protected-fw -> protected-redis:6379
```

Allowed only when `./scenario.sh data-open` is active.

## DNS

Docker DNS names are convenience only inside the same Docker network. Cross-zone targeting should use the stable IPs from `config/topology.yml`.
