FROM alpine:3.20

RUN apk add --no-cache dnsmasq tzdata iptables && \
    mkdir -p /var/log/dnsmasq /etc/dnsmasq.d

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/entrypoint.sh"]
