# Firewall vs Docker Networks

## Current Setup

We use **Docker networks** for isolation, not iptables:

- Containers on different networks cannot communicate
- No route between subnets
- Kernel drops packets automatically

## Do You Need Firewall Rules?

**No**, for this testbed. Docker networks provide sufficient isolation.

**Yes**, if you want:
- Port-level filtering (only allow port 5001, block others)
- Misconfiguration protection
- Audit logs
- Defense in depth

## How It Works

### Without Firewall
```
Same network = can communicate on any port
```

### With Firewall (iptables)
```
iptables -A FORWARD -p tcp --dport 5001 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -j DROP
```

## On macOS

iptables runs inside Docker's Linux VM, not on macOS. It cannot break your Mac.

To use iptables, run the testbed on a Linux VM:
```bash
# Using multipass
multipass launch --name testbed-vm
multipass shell testbed-vm
# Install Docker, clone repo, then:
sudo ./firewall/setup.sh setup
```

## Recommendation

Use Docker networks only for this learning testbed. Add iptables for production environments.
