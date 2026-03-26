# Cybersecurity Testbed

A simple 3-zone network for testing segmentation.

## Architecture

```
┌─────────────────┐
│   Public Zone   │ ◄── You access via http://localhost:8888
│   (nginx)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Service Zone   │ ◄── API layer (port 5001)
│  (Node.js)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Protected Zone  │ ◄── Data layer (Redis)
│   (Redis)       │
└─────────────────┘
```

## Quick Start

```bash
# Start all zones
./setup.sh up

# Test connectivity
./test.sh

# Stop
./setup.sh down
```

## Access

| URL | Description |
|-----|-------------|
| http://localhost:8888 | Web interface |
| http://localhost:8888/api/status | API via proxy |

## Structure

```
├── docker-compose.yml      # Shared networks
├── setup.sh                # Start/stop script
├── test.sh                 # Simple tests
├── zones/
│   ├── public/            # Nginx + probe
│   ├── service/           # API + probe
│   └── protected/         # Redis + probe
└── attacks/               # Kali Linux guide
```

Each zone is isolated by Docker networks:
- `public_net` (172.20.10.0/24)
- `service_net` (172.20.20.0/24)  
- `protected_net` (172.20.30.0/24)

Containers can only talk if on the same network.
