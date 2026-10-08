FROM registry.access.redhat.com/ubi10/ubi:latest

LABEL description="RHEL 10 repository reposync and GPG key downloader"

RUN dnf -y install \
        bash \
        ca-certificates \
        curl \
        dnf-plugins-core \
        gzip \
        tar \
        findutils \
        coreutils \
        subscription-manager \
    && dnf clean all \
    && rm -rf /var/cache/dnf

COPY reposync.sh /usr/local/bin/reposync.sh

RUN chmod 0750 /usr/local/bin/reposync.sh \
    && mkdir -p /repos/rhel10/gpg-keys

ENV reposync_ROOT=/repos/rhel10

ENTRYPOINT ["/usr/local/bin/reposync.sh"]