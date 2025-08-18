Dockerfile

# RHEL UBI 9
FROM redhat/ubi9:latest



# Add Repos
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm && \
        dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm && \
        dnf config-manager --enable codeready-builder-for-rhel-$(rpm -E %rhel)-x86_64-rpms && \
        dnf makecache && \
        dnf install -y createrepo mkisofs

## ADD user group ID

#VOLUME ["/repoData"]
#VOLUME ["/repoConfigs"]

COPY ./app/generateExtrasRepo.sh /usr/local/bin/generateExtrasRepo.sh
COPY ./app/rhRepoDownload.sh /usr/local/bin/rhRepoDownload.sh
COPY ./app/mkISO.sh /usr/local/bin/mkISO.sh
RUN chmod +x /usr/local/bin/generateExtrasRepo.sh /usr/local/bin/rhRepoDownload.sh /usr/local/bin/mkISO.sh

#CMD ["/bin/bash"]
CMD ["/bin/sh", "-c", "/usr/local/bin/generateExtrasRepo.sh && /usr/local/bin/rhRepoDownload.sh"]
#CMD ["/bin/sh", "-c", "/usr/local/bin/generateExtrasRepo.sh"]
CMD ["/bin/sh", "-c", "/usr/local/bin/mkISO.sh"]

