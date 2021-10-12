#!/bin/sh
set -e

if [ ! -d /etc/docker/certs.d ]; then
	mkdir -p /etc/docker/certs.d
	cd /etc/docker/certs.d
	openssl genrsa -out ca-key.pem 2048
	openssl req -x509 -new -nodes -key ca-key.pem -days 36500 \
	-out ca.pem -sha256 -subj '/O=Docker/CN=docker ca'
	openssl genrsa -out server-key.pem 2048
	openssl req -new -key server-key.pem -out server.csr -subj '/O=Docker/CN=localhost'
	echo "extendedKeyUsage = clientAuth, serverAuth, 1.3.6.1.5.5.8.2.2" > /tmp/san.txt
	echo "subjectAltName=IP:$(ip route get 1.1.1.1 | grep -oP 'src \K\S+'),IP:127.0.0.1,DNS:localhost,DNS:*.example.com" >> /tmp/san.txt
	openssl x509 -req -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -days 36500 \
	-out server-cert.pem -sha256 -extfile /tmp/san.txt
	mkdir client
	cp ca.pem client
	openssl genrsa -out client/key.pem 2048
	openssl req -subj '/CN=client' -new -key client/key.pem -out client/client.csr
	echo extendedKeyUsage = clientAuth > /tmp/client.cnf
	openssl x509 -req -days 36500 -sha256 -in client/client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
	-out client/cert.pem -extfile /tmp/client.cnf
	chmod +r client/key.pem
	echo 'mkdir $HOME/.docker' > client/readme.txt
	echo 'sudo cp /etc/docker/certs.d/client/*.pem $HOME/.docker' >> client/readme.txt
	echo 'sudo chown $USER: .docker/*.pem' >> client/readme.txt
	echo 'export DOCKER_HOST=tcp://localhost:2376 DOCKER_TLS_VERIFY=1' >> client/readme.txt
fi

rm -rf /var/run/docker.pid
dockerd $DOCKER_OPTS \
	--host=unix:///var/run/docker.sock \
	--host=tcp://0.0.0.0:2376 \
	--iptables=true \
	--ipv6=false \
	--tls=true \
	--tlscacert=/etc/docker/certs.d/ca.pem \
	--tlscert=/etc/docker/certs.d/server-cert.pem \
	--tlskey=/etc/docker/certs.d/server-key.pem \
	--tlsverify=true \
	--storage-driver=overlay2 &>/var/log/docker.log &

tries=0
d_timeout=60
until docker info >/dev/null 2>&1; do
	if [ "$tries" -gt "$d_timeout" ]; then
        cat /var/log/docker.log;
		echo 'Timed out trying to connect to internal docker host.' >&2;
		exit 1;
	fi
    tries=$(( $tries + 1 ));
	sleep 1;
done

sleep 5

eval "$@"