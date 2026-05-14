FROM kalilinux/kali-rolling

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nmap \
    curl \
    netcat-traditional \
    iproute2 \
    iputils-ping \
    dnsutils \
 && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
