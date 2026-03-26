# Docker Compose `internal` Property

## What It Does

```yaml
networks:
  public_net:
    internal: false   # ← Can reach the internet
    
  service_net:
    internal: true    # ← No internet access
    
  protected_net:
    internal: true    # ← No internet access
```

The `internal` property controls whether containers on that network can reach **external networks** (the internet).

## Visual Explanation

### internal: false (Public Net)

```
┌─────────────────────────────────────────┐
│           public_net                    │
│        (internal: false)                │
│                                         │
│   ┌─────────┐                           │
│   │  nginx  │◄──────► Internet          │
│   │         │         (can reach         │
│   └─────────┘          google.com, etc)  │
│                                         │
└─────────────────────────────────────────┘
```

**Result**: Containers CAN reach the internet (through Docker's NAT)

### internal: true (Service/Protected Net)

```
┌─────────────────────────────────────────┐
│           service_net                   │
│        (internal: true)                 │
│                                         │
│   ┌─────────┐                           │
│   │   api   │❌──────► Internet         │
│   │         │         (blocked!)        │
│   └────┬────┘                           │
│        │                                │
│        │ Only internal comms            │
│        ▼                                │
│   ┌─────────┐                           │
│   │  redis  │                           │
│   └─────────┘                           │
│                                         │
└─────────────────────────────────────────┘
```

**Result**: Containers CANNOT reach the internet, only other containers on the same network

## Why We Use It

| Network | internal | Why |
|---------|----------|-----|
| **public_net** | `false` | Nginx might need to fetch external resources (apt updates, etc) |
| **service_net** | `true` | API layer shouldn't directly access internet - security |
| **protected_net** | `true` | Data layer should NEVER access internet - maximum security |

## What Changes with `internal: true`

### Without internal: true (or internal: false)

```bash
# From service-api container
curl https://google.com   # ✅ Works - reaches internet
```

### With internal: true

```bash
# From service-api container
curl https://google.com   # ❌ Fails - network unreachable

# But internal works
curl http://protected-redis:6379  # ✅ Works - same network
```

## Technical Details

When `internal: true`:
- Docker does NOT create a NAT route to the host's external interface
- No default gateway is configured for the network
- Traffic can only flow to other containers on the same network

When `internal: false` (default):
- Docker creates iptables NAT rules
- Containers get a route to the internet via the host
- Can reach external IPs

## Test It

```bash
# Start testbed
./setup.sh up

# From public zone (should work)
docker exec public-nginx-1 wget -qO- https://google.com 2>/dev/null | head -1

# From service zone (should fail)
docker exec service-api wget -qO- https://google.com 2>/dev/null || echo "Failed (correct!)"
```

## Summary

`internal: true` = **Air-gapped network**

- Containers can talk to each other
- Containers CANNOT reach the internet
- Adds extra security layer
