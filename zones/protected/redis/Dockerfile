FROM redis:7-alpine

RUN apk add --no-cache iproute2 bash

COPY entrypoint.sh /route-entrypoint.sh
RUN chmod +x /route-entrypoint.sh

ENTRYPOINT ["/route-entrypoint.sh"]
CMD ["redis-server", "--appendonly", "yes"]
