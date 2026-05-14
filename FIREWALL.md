# Firewall and Routed Boundaries

## Current Setup

This testbed uses Docker networks as subnet wiring and uses dedicated firewall/router modules as the security boundary.

Only firewall/router boundary containers are multi-homed. Normal services live in one zone. Cross-zone routes point at boundary modules. `iptables` controls which directional flows are allowed.

## Boundary Defaults

Each firewall/router starts with:

```bash
iptables -F
iptables -P FORWARD DROP
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

This means new cross-zone traffic is denied unless a scenario explicitly permits it.

## Scenario Rules

`service-open` allows public-to-service API traffic:

```bash
iptables -A FORWARD -s 172.20.10.0/24 -d 172.20.20.10 -p tcp --dport 5001 -j ACCEPT
```

`data-open` also allows service API-to-protected Redis traffic:

```bash
iptables -A FORWARD -s 172.20.20.10 -d 172.20.30.10 -p tcp --dport 6379 -j ACCEPT
```

Use `./scenario.sh status` to inspect the active `FORWARD` chains.

## macOS and Docker Desktop

The firewall commands run inside Linux containers managed by Docker Desktop or OrbStack. The host macOS firewall is not modified.

## Why Not Docker Isolation Alone?

The demonstrator models explicit routers and firewall policy. Docker networks provide convenient subnets, but the intended lesson is that routed boundaries and rules control cross-zone access.
