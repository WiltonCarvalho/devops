#!/bin/sh
set -e
rm -rf /var/run/docker.pid
DOCKER_OPTS="${DOCKER_OPTS:---host tcp://0.0.0.0:2376 --insecure-registry=registry.example.com}"
DOCKER_HOST="${DOCKER_HOST:-tcp://0.0.0.0:2376}"

dockerd $DOCKER_OPTS \
	--host=unix:///var/run/docker.sock \
	--iptables=true \
	--ipv6=false \
	--storage-driver=overlay2 &>/var/log/docker.log &


tries=0
d_timeout=60
until docker info >/dev/null 2>&1
do
	if [ "$tries" -gt "$d_timeout" ]; then
                cat /var/log/docker.log
		echo 'Timed out trying to connect to internal docker host.' >&2
		exit 1
	fi
        tries=$(( $tries + 1 ))
	sleep 1
done

eval "$@"