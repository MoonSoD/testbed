# Cybersecurity Testbed Architecture

## Overview

This testbed simulates a multi-zone network architecture for cybersecurity testing, implementing defense-in-depth principles with network segmentation.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Host Machine                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Networks                         │   │
│  │                                                      │   │
│  │   ┌──────────────┐    ┌──────────────┐             │   │
│  │   │  public_net  │    │ service_net  │             │   │
│  │   │ 172.20.10/24 │    │ 172.20.20/24 │             │   │
│  │   └──────┬───────┘    └──────┬───────┘             │   │
│  │          │                   │                      │   │
│  │   ┌──────▼───────┐    ┌──────▼───────┐             │   │
│  │   │              │    │              │             │   │
│  │   │ Public Zone  │◄──►│ Service Zone │             │   │
│  │   │   (nginx)    │    │  (Node.js)   │             │   │
│  │   │   Port 80    │    │   Port 5001  │             │   │
│  │   └──────┬───────┘    └──────┬───────┘             │   │
│  │          │                   │                      │   │
│  │          │            ┌──────▼───────┐              │   │
│  │          │            │ protected_net│              │   │
│  │          │            │ 172.20.30/24 │              │   │
│  │          │            └──────┬───────┘              │   │
│  │          │                   │                      │   │
│  │          │            ┌──────▼───────┐              │   │
│  │          │            │              │              │   │
│  │          │            │Protected Zone│              │   │
│  │          │            │   (Redis)    │              │   │
│  │          │            │   Port 6379  │              │   │
│  │          │            └──────────────┘              │   │
│  │          │                                          │   │
│  └──────────┼──────────────────────────────────────────┘   │
│             │                                               │
└─────────────┼───────────────────────────────────────────────┘
              │
              │ Port 8888
              ▼
    ┌─────────────────────┐
    │   Kali Linux VM     │
    │  (Attack Testing)   │
    └─────────────────────┘
```

## Security Zones

### 1. Public Zone (DMZ)
- **Purpose**: Externally accessible services
- **Technology**: Nginx web server
- **Network**: `public_net` (172.20.10.0/24)
- **Exposed Port**: 80 (mapped to host 8888)
- **Security Profile**: High exposure, minimal trust

**Services:**
- **nginx**: Reverse proxy, routes `/api/` to service zone
- **probe**: Health check API (port 3000)

### 2. Service Zone (Application Layer)
- **Purpose**: Internal API services
- **Technology**: Node.js with TypeScript (Express.js)
- **Network**: `service_net` (172.20.20.0/24)
- **Port**: 5001
- **Security Profile**: Medium trust, internal access only

**Services:**
- **api**: Main API server with Redis connectivity
- **probe**: Health check API (port 3000)

**API Endpoints:**
- `GET /health` - Health check
- `GET /status` - Zone status
- `GET /data` - Retrieve data from Protected Zone

### 3. Protected Zone (Data Layer)
- **Purpose**: Sensitive data storage
- **Technology**: Redis 7
- **Network**: `protected_net` (172.20.30.0/24)
- **Port**: 6379
- **Security Profile**: High trust, restricted access

**Services:**
- **redis**: Data store with persistence
- **probe**: Health check API (port 3000)

## Network Segmentation

### Communication Matrix

| Source → Destination | Status | Notes |
|---------------------|--------|-------|
| External → Public Zone | ✅ ALLOWED | Port 8888 only |
| External → Service Zone | ❌ DENIED | Network isolation |
| External → Protected Zone | ❌ DENIED | Network isolation |
| Public Zone → Service Zone | ✅ ALLOWED | Port 5001 only |
| Public Zone → Protected Zone | ❌ DENIED | No network route |
| Service Zone → Protected Zone | ✅ ALLOWED | Port 6379 only |

### How Isolation Works

**By Network Membership:**
```
protected-redis has ONLY ONE interface:
  eth0: 172.20.30.3 (protected_net)

It has NO interface on:
  - public_net (172.20.10.x)
  - service_net (172.20.20.x)

Therefore: Traffic from those networks cannot reach it
```

**Multi-Homed Bridge Containers:**
```
public-nginx:
  - eth0: 172.20.10.3 (public_net)
  - eth1: 172.20.20.4 (service_net)
  
service-api:
  - eth0: 172.20.20.3 (service_net)
  - eth1: 172.20.30.4 (protected_net)
```

These containers route traffic between zones.

## Deployment

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+

### Start Testbed
```bash
./setup.sh up
```

### Run Tests
```bash
./test.sh
```

### Stop Testbed
```bash
./setup.sh down
```

## Access Points

| Endpoint | URL | Description |
|----------|-----|-------------|
| Public Web | http://localhost:8888 | Nginx web interface |
| Public Probe | http://localhost:8888/api/probe/health | Zone identification |
| Service API | http://localhost:8888/api/status | API via nginx proxy |

## Extensibility

Each zone is a separate Docker Compose project:
- Add services by editing `zones/<zone>/docker-compose.yml`
- Networks are shared via external references
- New zones can be added with new subnets (e.g., 172.20.40.0/24)
