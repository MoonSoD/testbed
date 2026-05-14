#!/usr/bin/env bash
set -euo pipefail

if [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]; then
    echo "[!] net.ipv4.ip_forward is not enabled"
    exit 1
fi

iptables -F
iptables -P FORWARD DROP
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "[+] Firewall router ready: $(hostname)"
exec sleep infinity
