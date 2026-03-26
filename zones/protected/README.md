# Protected Zone

Data layer. Contains sensitive data storage. Most restricted access.

## Services

| Service | Port | Description |
|---------|------|-------------|
| redis | 6379 | Data store |
| probe | 3000 | Health check API |

## Networks

- **protected_net** - Only accessible from service zone

## Access

No direct external access. Reachable only via service zone API.
