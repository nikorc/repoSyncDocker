FROM registry.access.redhat.com/ubi8/ubi:latest

ENV container=docker
ENV LANG=C.UTF-8

RUN dnf -y install \
        dnf-plugins-core \
        subscription-manager \
        ca-certificates \
        tar \
        gzip \
        xz \
        findutils \
        xorriso \
    && dnf clean all


COPY reposync.sh /usr/local/bin/reposync.sh
RUN chmod 0755 /usr/local/bin/reposync.sh

WORKDIR /repos

ENTRYPOINT ["/usr/local/bin/reposync.sh"]
