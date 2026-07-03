# RHEL UBI 9
FROM redhat/ubi10:latest

# Add Repos and Install Packages
RUN dnf config-manager --enable codeready-builder-for-rhel-$(rpm -E %rhel)-x86_64-rpms && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm && \
#    /usr/sbin/subscription-manager release --set=10.2 && \
#    dnf makecache && \
#    dnf install -y createrepo xorriso && \
    dnf clean all

VOLUME ["/repoData"]

COPY ./app/rhRepoDownload.sh /usr/local/bin/rhRepoDownload.sh
RUN chmod a+x /usr/local/bin/rhRepoDownload.sh

CMD ["/bin/sh", "-c", "/usr/local/bin/rhRepoDownload.sh"]

