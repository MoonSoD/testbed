# Hardware Replacement Guide

This testbed can be mapped to physical or VM components by preserving the IP contract in `config/topology.yml`.

## Replacing a Zone Module

To replace a containerized service with hardware, attach the device to the matching subnet, assign the service IP, and add routes for remote zones through the boundary modules.

Example for replacing the service API host:

```bash
sudo ip addr add 172.20.20.10/24 dev eth0
sudo ip route add 172.20.10.0/24 via 172.20.20.254
sudo ip route add 172.20.30.0/24 via 172.20.20.253
```

## Replacing a Boundary Module

A boundary replacement needs one interface in each adjacent zone, IPv4 forwarding, and a default-deny forwarding policy.

```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -P FORWARD DROP
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -s 172.20.10.0/24 -d 172.20.20.10 -p tcp --dport 5001 -j ACCEPT
```

## Raspberry Pi Service Zone Example

Configure a Raspberry Pi as the service API device:

```bash
sudo ip addr flush dev eth0
sudo ip addr add 172.20.20.10/24 dev eth0
sudo ip route add 172.20.10.0/24 via 172.20.20.254
sudo ip route add 172.20.30.0/24 via 172.20.20.253
node /opt/testbed/service-api/dist/index.js
```

The public-service firewall must allow TCP/5001, and the service-protected firewall must allow TCP/6379 only for data-open style demos.

## Raspberry Pi Public-Service Firewall Example

Use two interfaces, one on public and one on service:

```bash
sudo ip addr add 172.20.10.254/24 dev eth0
sudo ip addr add 172.20.20.254/24 dev eth1
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -F
sudo iptables -P FORWARD DROP
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -s 172.20.10.0/24 -d 172.20.20.10 -p tcp --dport 5001 -j ACCEPT
```

## QNX Notes

Use the same addressing and routing contract. Replace Linux-specific `iptables` commands with the QNX packet filter available in your target image. Keep the policy equivalent: default deny, allow established return traffic where supported, and allow only the task-specific service ports.

## Kali VM Replacement Notes

A Kali VM can replace the `kali-attacker` container when it is connected to the public subnet:

```bash
sudo ip addr add 172.20.10.50/24 dev eth0
sudo ip route add 172.20.20.0/24 via 172.20.10.254
sudo ip route del default
```

Do not add a route to `172.20.30.0/24`; the protected zone should only be reached indirectly through the service path allowed by the firewall scenario.
