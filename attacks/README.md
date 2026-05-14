# Demonstration Tasks from Kali

The official attack origin is the `kali-attacker` container on `public_net` at `172.20.10.50`.

Use the fixed demo runner instead of ad-hoc exploit chains:

```bash
./demo.sh task1
./demo.sh task2
./demo.sh task3
./demo.sh task4
./demo.sh all
```

## Manual Examples

```bash
docker exec kali-attacker nmap -Pn -p 80,5001 172.20.10.10 172.20.20.10
docker exec kali-attacker curl -s --connect-timeout 2 http://172.20.20.10:5001/health
docker exec kali-attacker sh -lc 'echo PING | nc -w1 172.20.30.10 6379 || true'
```

Expected behavior changes with `./scenario.sh baseline`, `./scenario.sh service-open`, `./scenario.sh data-open`, and `./scenario.sh hardened`.

This implementation is service-level and benign. It demonstrates routing and firewall policy changes without adding exploit chains.
