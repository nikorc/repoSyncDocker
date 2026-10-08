FROM registry.access.redhat.com/ubi9/ubi:latest

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

# Install EPEL repository configuration
RUN dnf -y install \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf clean all

# Enable RPM Fusion Free and Nonfree
RUN dnf -y install \
        https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm \
    && dnf clean all

COPY reposync.sh /usr/local/bin/reposync.sh
RUN chmod 0755 /usr/local/bin/reposync.sh

WORKDIR /repos

ENTRYPOINT ["/usr/local/bin/reposync.sh"]
