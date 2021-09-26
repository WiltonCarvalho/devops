FROM ubuntu:20.04
RUN sed -i "s/archive.ubuntu.com/br.archive.ubuntu.com/g" /etc/apt/sources.list \
&&  apt-get update \
&&  DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends dnsmasq iproute2 dnsutils iputils-ping \
&&  rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY --chown=root:root run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
CMD ["dnsmasq", "-C", "/etc/dnsmasq.conf"]
STOPSIGNAL SIGTERM
USER dnsmasq
EXPOSE 5353/UDP
HEALTHCHECK --interval=10s --timeout=30s --start-period=10s --retries=2 CMD dig +short @127.0.0.1 -p 5353 localhost || exit 1
