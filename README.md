# Cybersecurity Testbed

A Docker-only routed-zone demonstrator with fixed tasks for showing network segmentation, firewall policy changes, and controlled cross-zone access.

Docker networks provide subnet wiring only. They are not the security boundary in this version. Dedicated firewall/router boundary containers are the only multi-homed components, and their `iptables` rules decide which directional flows are allowed.

## Topology

```text
kali-attacker 172.20.10.50
  |
public_net 172.20.10.0/24
  |
public-service-fw 172.20.10.254 / 172.20.20.254
  |
service_net 172.20.20.0/24
  |
service-protected-fw 172.20.20.253 / 172.20.30.254
  |
protected_net 172.20.30.0/24
```

## Quick Start

```bash
./setup.sh up
./scenario.sh baseline
./scenario.sh service-open
./scenario.sh data-open
./demo.sh all
./test.sh
./setup.sh down
```

## Demo Tasks

The Kali attacker container is the official attack origin. Use `./demo.sh` for the fixed demonstration flow:

```bash
./demo.sh task1
./demo.sh task2
./demo.sh task3
./demo.sh task4
```

## Scenarios

| Scenario | Effect |
|----------|--------|
| `baseline` | Cross-zone traffic denied by default |
| `service-open` | Public zone can reach the service API on port 5001 |
| `data-open` | Service API can reach protected Redis on port 6379 |
| `hardened` | Returns to default deny for cross-zone flows |
| `status` | Prints firewall `FORWARD` chains |

## Structure

```text
config/topology.yml              Static IP and subnet contract
boundaries/                      Firewall/router modules
attacker/                        Kali attacker module
zones/public/                    Public web and probe
zones/service/                   Service API and probe
zones/protected/                 Redis and probe
scenario.sh                      Live firewall profile switcher
demo.sh                          Fixed task runner
test.sh                          Routed firewall behavior tests
```

Normal services live in exactly one zone. Cross-zone routes point at boundary modules, and boundary `iptables` rules control access.
