#!/bin/bash
set -e

if [ -z "$(ls -A /etc/ldap/slapd.d/)" ] || [ -z "$(ls -A /var/lib/ldap/)" ]; then
    slapadd -F /etc/ldap/slapd.d -b cn=config -l /root/config.ldif
    slapadd -F /etc/ldap/slapd.d -b $BASE_DN -l /root/base.ldif
    chown -R openldap:openldap /var/lib/ldap/ /etc/ldap/slapd.d/
    slapd -h "ldap:/// ldapi:///" -u openldap -g openldap -4
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/tls.ldif
    LDAPTLS_REQCERT=never ldapsearch -x -LLL -H ldap://127.0.0.1 -ZZ -b $BASE_DN
    #LDAPTLS_REQCERT=never ldapsearch -x -LLL -H ldap://127.0.0.1 -ZZ -b $BASE_DN -D $ADMIN_DN -W
    #LDAPTLS_REQCERT=never ldapadd -x -H ldap://127.0.0.1 -ZZ -D $ADMIN_DN -W
    pkill -TERM slapd
else
    echo "Not Empty"
fi
echo
echo "Start LDAP Daemon..."
echo
exec "$@"
