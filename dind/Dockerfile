FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Sao_Paulo
USER root
RUN sed -i "s/archive.ubuntu.com/br.archive.ubuntu.com/g" /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qq -y install --only-upgrade $( apt-get --just-print upgrade | awk 'tolower($4) ~ /.*security.*/ || tolower($5) ~ /.*security.*/ {print $2}' | sort | uniq ) && \
    apt-get -qq -y install --no-install-recommends tzdata openssl ca-certificates curl iptables iproute2 docker.io && \
    rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true

# https://github.com/aws/aws-codebuild-docker-images/blob/master/ubuntu/standard/5.0/Dockerfile
ARG DOCKER_BUCKET="download.docker.com"
ARG DOCKER_CHANNEL="stable"
ARG DIND_COMMIT="3b5fac462d21ca164b3778647420016315289034"
ARG DOCKER_COMPOSE_VERSION="1.29.2"
ARG SRC_DIR="/usr/src"

ARG DOCKER_SHA256="ddb13aff1fcdcceb710bf71a210169b9c1abfd7420eeaf42cf7975f8fae2fcc8"
ARG DOCKER_VERSION="19.03.13"

# Install Docker
RUN set -ex \
    # && curl -fsSL "https://${DOCKER_BUCKET}/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    # && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    # && tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    # && rm docker.tgz \
    && docker -v \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    && curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    #&& curl -fsSL "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -o /usr/local/bin/dind \
    #&& chmod +x /usr/local/bin/dind \
    # Ensure docker-compose works
    && docker-compose version

COPY dockerd.sh /
RUN chmod +x /dockerd.sh
VOLUME /var/lib/docker
ENTRYPOINT [ "/dockerd.sh" ]
CMD [ "tail -f /dev/null" ]
ENV DOCKER_OPTS "--insecure-registry=registry.example.com"