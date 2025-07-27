Dockerfile

# RHEL UBI 9
FROM redhat/ubi9:latest

# Add Repos
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
        dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm && \
        dnf config-manager --enable codeready-builder-for-rhel-9-x86_64-rpms && \
        dnf makecache \
        dnf install -y createrepo

VOLUME ["/repoData"]
VOLUME ["/app"]

Copy ./app /app

WORKDIR /appp

CMD ["/bin/bash"]
