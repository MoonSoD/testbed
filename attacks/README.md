# Attack Testing from Kali Linux

## Port Scan

```bash
# From Kali, scan the testbed host
nmap -p 8888,5001,6379 <testbed-ip>

# Expected: Only 8888 open
```

## Web Enumeration

```bash
curl http://<testbed-ip>:8888
curl http://<testbed-ip>:8888/api/status
```

## Key Points

- Port 8888 is the only entry point
- Internal zones (5001, 6379) not reachable from outside
- Network segmentation enforced by Docker
