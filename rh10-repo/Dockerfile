FROM registry.access.redhat.com/ubi10/ubi:latest

ENV LANG=C.UTF-8

RUN dnf -y install \
        dnf-plugins-core \
        ca-certificates \
        curl \
        gzip \
        tar \
        xz \
        findutils \
        xorriso \
    && dnf clean all

# EPEL 10
RUN dnf -y install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm \
    && dnf clean all

# RPM Fusion for EL10
RUN dnf -y install \
    https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-10.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-10.noarch.rpm \
    && dnf clean all

COPY reposync.sh /usr/local/bin/reposync.sh
RUN chmod 0755 /usr/local/bin/reposync.sh

WORKDIR /repos

ENTRYPOINT ["/usr/local/bin/reposync.sh"]

