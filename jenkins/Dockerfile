FROM jenkins/jenkins:2.303.1-jdk11
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Sao_Paulo
USER root
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-keyring.gpg] https://download.docker.com/linux/debian $(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f 2) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends tzdata ca-certificates gnupg2 unzip curl wget less lynx jq docker-ce-cli python3 git openssh-client && \
    # apt-get -qq -y install --no-install-recommends python3-pip python3-setuptools python3-wheel \
    # python3-websocket python3-docopt python3-jsonschema python3-texttable python3-cached-property python3-dotenv python3-yaml \
    # python3-docker python3-dockerpty python3-requests python3-distro python3-six python3-attr python3-paramiko python3-certifi \
    # python3-urllib3 python3-chardet python3-idna python3-nacl python3-bcrypt python3-cryptography python3-cffi python3-pycparser && \
    # pip3 install docker-compose && \
    curl -fsSL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "/tmp/awscliv2.zip" && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws && \
    rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true
USER jenkins
RUN echo && docker-compose -version && echo && aws --version && echo && docker version || true
RUN jenkins-plugin-cli --plugins blueocean:1.25.0 docker-workflow:1.26 ssh-agent ssh-credentials credentials \
    matrix-auth ansicolor slack build-user-vars-plugin workflow-aggregator authorize-project git email-ext docker-plugin
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Dfile.encoding=UTF-8"
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo