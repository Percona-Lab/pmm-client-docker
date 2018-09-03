FROM centos:latest

ENV MONIT_VERSION=5.25.2

# Compile and install monit
RUN yum -y install make gcc curl zlib-devel openssl-devel \
    && cd /tmp \
    && curl -sS https://mmonit.com/monit/dist/monit-${MONIT_VERSION}.tar.gz | gunzip -c - | tar -xf - \
    && cd monit-${MONIT_VERSION} \
    && ./configure --without-pam \
    && make \
    && make install

RUN yum -y install curl bash \
    && cd /tmp \
    && curl -sS https://s3.us-east-2.amazonaws.com/pmm-build-cache/pmm-client/pmm-client-PR-80-8a282a4.tar.gz | gunzip -c - | tar -xf - \
    && cd pmm-client-* \
    && bash ./install


FROM centos:latest
RUN yum -y install iproute

COPY --from=0 /usr/local/bin/monit /usr/bin/monit
ADD --chown=nobody:nobody monitrc /etc/monitrc
RUN install -d -o nobody -g nobody /etc/monit.d /var/lib/monit /var/lib/monit/eventqueue /run /var/log /etc/rc.d/init.d

COPY --from=0 --chown=nobody:nobody /usr/local/percona /usr/local/percona
COPY --from=0 --chown=nobody:nobody /usr/sbin/pmm-admin /usr/sbin/pmm-admin
ADD service /usr/bin/service
ADD entrypoint.sh /entrypoint.sh

USER nobody
ENTRYPOINT ["/entrypoint.sh"]
