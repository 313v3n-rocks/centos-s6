ARG CENTOS_VERSION=centos7

FROM centos:${CENTOS_VERSION}

ARG S6_OVERLAY_VERSION="v1.22.1.0"
ENV ENVIRONMENT=local

# fail if cont-init or fix-attrs exited with != 0
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_STOP_GRACETIME=30000

RUN sed -i "s/enabled=1/enabled=0/" /etc/yum/pluginconf.d/fastestmirror.conf && \
# touch /var/lib/rpm/*: https://bugzilla.redhat.com/show_bug.cgi?id=1213602
    touch /var/lib/rpm/* && \
    yum clean all && rm -rf /var/cache/yum && yum repolist all && \
    yum update -y && \
    yum install -y -q cronie bind-utils lsof net-tools nano unzip telnet htop && \
    curl "https://github.com/just-containers/s6-overlay/releases/download/$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz" \
            -sLo /tmp/s6-overlay-amd64.tar.gz && \
        tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" && \
        tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin && \
        groupadd s6 && \
    yum clean all && rm -rf /var/cache/yum

# Comment pam_systemd He still does not
# Cron write warning if not comment
RUN sed -i -e 's~^\(-session.*pam_systemd.so\)$~#\1~' /etc/pam.d/password-auth

# envplate
RUN curl -Ls https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux -o /usr/local/bin/ep && \
    chmod +x /usr/local/bin/ep

# goss
RUN curl -Ls https://github.com/aelsabbahy/goss/releases/download/v0.3.5/goss-linux-amd64 -o /usr/local/bin/goss && \
    chmod +x /usr/local/bin/goss

HEALTHCHECK --start-period=1m CMD healthcheck

ENTRYPOINT ["/init"]

COPY root /
