Dockerfile

# RHEL UBI 9
FROM ubi/ubi9:latest

# Add Repos
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
        dmf install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm && \
        subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms && \
        dnf unpdate -y

VOLUME ["/repoData"]

WORKDIR /repoData

CMD ["/bin/bash"]