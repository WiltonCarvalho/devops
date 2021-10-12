FROM ubuntu:20.04

ENV SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends squid \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /
RUN chmod +x /run.sh

RUN cat /etc/squid/squid.conf  | grep -vE '^#|^$' | tee /etc/squid/squid.conf && \
    sed -i '1i http_access allow all' /etc/squid/squid.conf && \
    if ! grep ^cache_dir /etc/squid/squid.conf >/dev/null 2>&1; then \
        echo "cache_dir ufs /var/spool/squid 7000 16 256" >> /etc/squid/squid.conf; \
    fi && \
    if ! grep ^access_log /etc/squid/squid.conf >/dev/null 2>&1; then \
        echo "logfile_rotate 0" >> /etc/squid/squid.conf; \
        echo "access_log stdio:/proc/self/fd/1 combined" >> /etc/squid/squid.conf; \
        echo "cache_store_log none" >> /etc/squid/squid.conf; \
        echo "cache_log none" >> /etc/squid/squid.conf; \
    fi

EXPOSE 3128/tcp
CMD exec /run.sh