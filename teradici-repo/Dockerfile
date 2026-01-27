Dockerfile

# RHEL UBI 9
FROM redhat/ubi9:latest

# Add Repos
RUN dnf install -y createrepo mkisofs curl && \
        curl -1sLf https://dl.anyware.hp.com/HL3bgsJjNFh653zr/pcoip-agent/cfg/setup/bash.rpm.sh | bash distro=el codename=9 && \
        dnf makecache 

## ADD user group ID

#VOLUME ["/repoData"]
#VOLUME ["/repoConfigs"]

COPY ./app/repoDownload.sh /usr/local/bin/repoDownload.sh
COPY ./app/mkISO.sh /usr/local/bin/mkISO.sh
RUN chmod a+rx /usr/local/bin/repoDownload.sh /usr/local/bin/mkISO.sh

#CMD ["/bin/bash"]
CMD ["/bin/sh", "-c", "/usr/local/bin/repoDownload.sh"]
#CMD ["/bin/sh", "-c", "/usr/local/bin/mkISO.sh"]

