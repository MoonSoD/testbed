# Cybersecurity Testbed Architecture

## Overview

This testbed demonstrates routed segmentation across public, service, and protected zones. Docker bridge networks represent subnets, while firewall/router boundary containers enforce cross-zone access with `iptables`.

Only firewall/router boundary containers are multi-homed. Normal services live in one zone. Cross-zone routes point at boundary modules. `iptables` controls which directional flows are allowed.

## Logical Topology

```text
kali-attacker 172.20.10.50
  |
public_net 172.20.10.0/24
  | public-service-fw: 172.20.10.254 / 172.20.20.254
service_net 172.20.20.0/24
  | service-protected-fw: 172.20.20.253 / 172.20.30.254
protected_net 172.20.30.0/24
```

## Zones

| Zone | Subnet | Services |
|------|--------|----------|
| Public | `172.20.10.0/24` | Nginx `172.20.10.10`, probe `172.20.10.11`, Kali `172.20.10.50` |
| Service | `172.20.20.0/24` | API `172.20.20.10`, probe `172.20.20.11` |
| Protected | `172.20.30.0/24` | Redis `172.20.30.10`, probe `172.20.30.11` |

## Boundaries

| Boundary | Interfaces | Role |
|----------|------------|------|
| `public-service-fw` | `172.20.10.254`, `172.20.20.254` | Routes and filters public-to-service traffic |
| `service-protected-fw` | `172.20.20.253`, `172.20.30.254` | Routes and filters service-to-protected traffic |

Each boundary enables IPv4 forwarding and starts with default-deny `FORWARD` policy plus established/related return traffic.

## Access Model

| Scenario | Allowed Flow |
|----------|--------------|
| `baseline` | Host to public web only |
| `service-open` | Public subnet to service API TCP/5001 |
| `data-open` | Public subnet to service API TCP/5001, service API to Redis TCP/6379 |
| `hardened` | Cross-zone traffic denied again |

## Deployment

```bash
./setup.sh up
./scenario.sh status
./test.sh
./demo.sh all
```

The static IP contract lives in `config/topology.yml`; run `./setup.sh render-config` to generate `.env.generated` for Compose.
