FROM nginx:alpine

# Install required tools for testing
RUN apk add --no-cache \
    curl \
    nmap \
    netcat-openbsd \
    iputils \
    bash \
    jq

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY html /usr/share/nginx/html

# Create health check script
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Create network test script (for simulating compromise)
COPY network_test.sh /usr/local/bin/network_test.sh
RUN chmod +x /usr/local/bin/network_test.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

CMD ["nginx", "-g", "daemon off;"]
