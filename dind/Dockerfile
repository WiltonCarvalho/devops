FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Sao_Paulo
USER root
RUN sed -i "s/archive.ubuntu.com/br.archive.ubuntu.com/g" /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qq -y install --only-upgrade $( apt-get --just-print upgrade | awk 'tolower($4) ~ /.*security.*/ || tolower($5) ~ /.*security.*/ {print $2}' | sort | uniq ) && \
    apt-get -qq -y install --no-install-recommends tzdata openssl gnupg2 ca-certificates curl wget less lynx jq procps psmisc unzip iptables iproute2 openssh-client && \
    rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true

RUN echo '\
Host * \n\
    ConnectTimeout=10 \n\
    ConnectionAttempts=10 \n\
    StrictHostKeyChecking=no \n\
    UserKnownHostsFile=/dev/null \n\
' > /etc/ssh/ssh_config.d/custom.conf

# https://github.com/aws/aws-codebuild-docker-images/blob/master/ubuntu/standard/5.0/Dockerfile
ARG DOCKER_BUCKET="download.docker.com"
ARG DOCKER_CHANNEL="stable"
#ARG DIND_COMMIT="3b5fac462d21ca164b3778647420016315289034"
ARG DOCKER_COMPOSE_v1_VERSION="1.29.2"
ARG DOCKER_COMPOSE_v2_VERSION="v2.0.1"
ARG SRC_DIR="/usr/src"

ARG DOCKER_SHA256="caf74e54b58c0b38bb4d96c8f87665f29b684371c9a325562a3904b8c389995e"
ARG DOCKER_VERSION="20.10.9"

# Install Docker
RUN set -ex \
    #&& curl -fsSL "https://${DOCKER_BUCKET}/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    #&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    #&& tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    #&& rm docker.tgz \
    && apt-get -qq update \
    && apt-get -qq -y install --no-install-recommends docker.io \
    && rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true \
    && docker -v \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap -s /bin/bash -d /home/dockremap -m dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    # docker compose v2.xx.x
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_v2_VERSION}/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
    # docker-compose v1.xx.x
    && curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_v1_VERSION}/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    #&& curl -fsSL "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -o /usr/local/bin/dind \
    #&& chmod +x /usr/local/bin/dind \
    # Ensure docker-compose v1 works
    && docker-compose version \
    # Ensure docker compose v2 works
    && docker compose version

# Install AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
RUN set -ex \
    && curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /opt \
    && /opt/aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm /tmp/awscliv2.zip \
    && rm -rf /opt/aws \
    && aws --version

# Install OpenJDK
RUN set -ex \
    && apt-get -qq update \
    && apt-get -qq -y install --no-install-recommends openjdk-11-jdk-headless \
    && rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true \
    && java -version

# Install Trivy
RUN set -ex \
    curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor > /usr/share/keyrings/trivy-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/trivy-keyring.gpg] https://aquasecurity.github.io/trivy-repo/deb $(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f 2) main" | tee /etc/apt/sources.list.d/trivy.list && \
    apt-get -qq update && \
    apt-get -qq -y install trivy && \
    rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true

# Install Terraform
ARG TF_VERSION="1.0.8"
RUN set -ex \
    && curl -fsSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
    && unzip -q /tmp/terraform.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/terraform \
    && rm /tmp/terraform.zip \
    && terraform --version

VOLUME /var/lib/docker

COPY dockerd.sh /
RUN chmod +x /dockerd.sh

ENTRYPOINT [ "/dockerd.sh" ]
CMD [ "tail -n50 -f /etc/docker/certs.d/client/*.pem" ]

ENV DOCKER_HOST tcp://127.0.0.1:2376
ENV DOCKER_OPTS --insecure-registry=registry.example.com
ENV DOCKER_CERT_PATH /etc/docker/certs.d/client
ENV DOCKER_TLS_VERIFY 1
