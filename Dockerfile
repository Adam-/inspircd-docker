FROM alpine:3.4

MAINTAINER Adam adam@anope.org
MAINTAINER Sheogorath <sheogorath@shivering-isles.com>

ARG VERSION=insp20
ARG CONFIGUREARGS=
ARG ADDPACKAGES=
ARG DELPACKAGES=

COPY conf /conf
COPY entrypoint.sh /inspircd/entrypoint.sh

RUN apk add --no-cache gcc g++ make libgcc libstdc++ git  \
       pkgconfig perl perl-net-ssleay perl-io-socket-ssl  \
       perl-libwww wget gnutls gnutls-dev gnutls-utils $ADDPACKAGES && \
    adduser -u 10000 -h /inspircd/ -D -S inspircd && \
    mkdir -p /src /conf && \
    cd /src && \
    git clone https://github.com/inspircd/inspircd.git inspircd -b $VERSION && \
    cd /src/inspircd && \
    ./configure --disable-interactive --prefix=/inspircd/ --uid 10000 --enable-gnutls $CONFIGUREARGS && \
    make && \
    make install && \
    apk del gcc g++ make git pkgconfig perl perl-net-ssleay perl-io-socket-ssl \
       perl-libwww wget gnutls-dev $DELPACKAGES && \
    rm -rf /src && \
    rm -rf /inspircd/conf && ln -s /conf /inspircd/conf && \
    chown -R inspircd /inspircd/ && \
    chown -R inspircd /conf/

VOLUME ["/inspircd/conf"]



WORKDIR /inspircd/

USER inspircd

EXPOSE 6667 6697 7000 7001

HEALTHCHECK CMD  /usr/bin/nc 127.0.0.1 6667 < /dev/null || exit 1

ENTRYPOINT ["/inspircd/entrypoint.sh"]
