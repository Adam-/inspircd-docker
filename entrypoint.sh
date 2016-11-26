#!/bin/sh

if [ ! -f /inpircd/conf/cert.pem ] && [ ! -f /inpircd/conf/key.pem ]; then
    cat > /tmp/cert.template <<EOF
cn              = "${INSP_TLS_CN:-irc.example.com}"
email           = "${INSP_TLS_MAIL:-nomail@example.com}"
unit            = "${INSP_TLS_UNIT:-Server Admins}"
organization    = "${INSP_TLS_ORG:-Example IRC Network}"
locality        = "${INSP_TLS_LOC:-Example City}"
state           = "${INSP_TLS_STATE:-Example State}"
country         = "${INSP_TLS_COUNTRY:-XZ}"
expiration_days = ${INSP_TLS_DURATION:-365}
tls_www_client
tls_www_server
signing_key
encryption_key
cert_signing_key
crl_signing_key
code_signing_key
ocsp_signing_key
time_stamping_key
EOF
    /usr/bin/certtool --generate-privkey --bits 4096 --sec-param normal --outfile /inspircd/conf/key.pem
    /usr/bin/certtool --generate-self-signed --load-privkey /inspircd/conf/key.pem --outfile /inspircd/conf/cert.pem --template /tmp/cert.template
    rm /tmp/cert.template
fi


/inspircd/bin/inspircd --nofork $@
