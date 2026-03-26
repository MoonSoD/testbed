# Public Zone

Entry point to the testbed. Exposes services to external access.

## Services

| Service | Port | Description |
|---------|------|-------------|
| nginx | 80 (host:8080) | Web server and API gateway |
| probe | 3000 | Health check API for testing connectivity |

## Networks

- **public_net** - External access
- **service_net** - Connects to service zone

## Access

```bash
# From host
curl http://localhost:8888
curl http://localhost:8888/api/probe/health
```

## Files

- `docker-compose.yml` - Service definitions
- `nginx/` - Reverse proxy configuration
- `probe/` - TypeScript probe API
