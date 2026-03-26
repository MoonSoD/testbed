# Service Zone

Application layer. Processes business logic and connects to data layer.

## Services

| Service | Port | Description |
|---------|------|-------------|
| api | 5001 | Main API server (Node.js/TypeScript) |
| probe | 3000 | Health check API |

## Networks

- **service_net** - Receives requests from public zone
- **protected_net** - Connects to protected zone

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| GET /health | Health check |
| GET /status | Service status |
| GET /data | Fetch data from protected zone (Redis) |

## Access

Accessed via nginx proxy: `http://localhost:8080/api/`
