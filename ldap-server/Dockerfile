FROM ubuntu:20.04
WORKDIR /tmp
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    slapd ldap-utils schema2ldif debconf-utils openssl ca-certificates && \
    mkdir /etc/ldap/ssl && \
    openssl genrsa -out /etc/ldap/ssl/example.key && \
    openssl req -new -key /etc/ldap/ssl/example.key -out /etc/ldap/ssl/example.csr -subj '/O=Example/CN=*.example.com' -addext "subjectAltName=IP:127.0.0.1,DNS:example.com,DNS:*.example.com" && \
    echo "subjectAltName=IP:127.0.0.1,DNS:example.com,DNS:*.example.com" > /tmp/san.txt && \
    openssl x509 -req -days 36500 -in /etc/ldap/ssl/example.csr -signkey /etc/ldap/ssl/example.key -out /etc/ldap/ssl/example.pem -extfile /tmp/san.txt && \
    mkdir /usr/share/ca-certificates/example.com/ && \
    cp /etc/ldap/ssl/example.pem /usr/share/ca-certificates/example.com/ && \
    echo "example.com/example.pem" >> /etc/ca-certificates.conf && \
    update-ca-certificates -f && \
    chown -R openldap:openldap /etc/ldap/ssl && \
    apt download samba && \
    dpkg -x samba_*.deb /tmp/samba && \
    cp /tmp/samba/usr/share/doc/samba/examples/LDAP/samba.ldif /etc/ldap/schema/ && \
    cp /tmp/samba/usr/share/doc/samba/examples/LDAP/samba.schema /etc/ldap/schema/ && \
    rm -rf /tmp/samba*

ENV LDAP_DOMAIN=${LDAP_DOMAIN:-"example.com"}
ENV LDAP_ORG=${LDAP_ORG:-"Example Org"}
ENV BASE_DN=${BASE_DN:-"dc=example,dc=com"}
ENV ADMIN_DN=${ADMIN_DN:-"cn=admin,dc=example,dc=com"}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}
ARG LDAP_DOMAIN=${LDAP_DOMAIN:-"example.com"}
ARG LDAP_ORG=${LDAP_ORG:-"Example Org"}
ARG BASE_DN=${BASE_DN:-"dc=example,dc=com"}
ARG ADMIN_DN=${ADMIN_DN:-"cn=admin,dc=example,dc=com"}
ARG ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}

RUN rm -rf /var/lib/ldap/ /etc/ldap/slapd.d/ && \
echo "slapd slapd/domain string $LDAP_DOMAIN" | debconf-set-selections && \
echo "slapd shared/organization string $LDAP_ORG" | debconf-set-selections && \
echo "slapd slapd/internal/adminpw password $ADMIN_PASSWORD" | debconf-set-selections && \
echo "slapd slapd/internal/generated_adminpw password $ADMIN_PASSWORD" | debconf-set-selections && \
echo "slapd slapd/password1 password $ADMIN_PASSWORD" | debconf-set-selections && \
echo "slapd slapd/password2 password $ADMIN_PASSWORD" | debconf-set-selections && \
echo "slapd slapd/purge_database boolean true" | debconf-set-selections && \
echo "slapd slapd/no_configuration boolean false" | debconf-set-selections && \
echo "slapd slapd/move_old_database boolean true" | debconf-set-selections && \
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure slapd && \
echo "dn: cn=config" > /root/tls.ldif && \
echo "add: olcTLSCACertificateFile" >> /root/tls.ldif && \
echo "olcTLSCACertificateFile: /etc/ldap/ssl/example.pem" >> /root/tls.ldif && \
echo '-' >> /root/tls.ldif && \
echo "add: olcTLSCertificateFile" >> /root/tls.ldif && \
echo  "olcTLSCertificateFile: /etc/ldap/ssl/example.pem" >> /root/tls.ldif && \
echo '-' >> /root/tls.ldif && \
echo "add: olcTLSCertificateKeyFile" >> /root/tls.ldif && \
echo "olcTLSCertificateKeyFile: /etc/ldap/ssl/example.key" >> /root/tls.ldif && \
slapadd -F /etc/ldap/slapd.d -b cn=config -l /etc/ldap/schema/samba.ldif && \
slapcat -b cn=config > /root/config.ldif && \
slapcat -b $BASE_DN > /root/base.ldif && \
rm -rf /var/lib/ldap/* /etc/ldap/slapd.d/*

COPY --chown=root:root run.sh /
RUN chmod 700 /run.sh

ENTRYPOINT [ "/run.sh" ]
CMD ["/usr/sbin/slapd", "-h", "ldap:/// ldapi:///", "-u", "openldap", "-g", "openldap", "-4", "-d", "256"]
STOPSIGNAL SIGINT
EXPOSE 389
