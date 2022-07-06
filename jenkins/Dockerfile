FROM jenkins/jenkins:2.303.2-jdk11
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Sao_Paulo
USER root
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-keyring.gpg] https://download.docker.com/linux/debian $(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f 2) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends tzdata ca-certificates gnupg2 unzip curl wget less lynx jq docker-ce-cli python3 git openssh-client && \
    curl -fsSL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "/tmp/awscliv2.zip" && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws && \
    rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin /var/lib/apt/lists/* || true
RUN echo '\
Host * \n\
    ConnectTimeout=10 \n\
    ConnectionAttempts=10 \n\
    StrictHostKeyChecking=no \n\
    UserKnownHostsFile=/dev/null \n\
' > /etc/ssh/ssh_config.d/custom.conf
USER jenkins
RUN echo && docker-compose -version && echo && aws --version && echo && docker version || true
RUN jenkins-plugin-cli --plugins blueocean:1.25.0 docker-workflow:1.26 ssh-agent ssh-credentials credentials \
    matrix-auth ansicolor slack build-user-vars-plugin workflow-aggregator authorize-project git email-ext docker-plugin
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Dfile.encoding=UTF-8"
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo