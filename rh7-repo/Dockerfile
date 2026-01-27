# RHEL UBI 9
FROM registry.access.redhat.com/ubi7/ubi

# Add Repos and Install Packages
RUN yum makecache && \
    yum install -y createrepo mkisofs yum-utils && \
    yum-config-manager --enable rhel-7-server-extras-rpms
    yum-config-manager --enable rhel-7-server-optional-rpms
    yum-config-manager --enable rhel-7-server-rh-common-rpms
    yum-config-manager --enable rhel-7-server-supplementary-rpms
    yum clean all

VOLUME ["/repoData"]

COPY ./app/rhRepoDownload.sh /usr/local/bin/rhRepoDownload.sh
RUN chmod a+x /usr/local/bin/rhRepoDownload.sh

CMD ["/bin/sh", "-c", "/usr/local/bin/rhRepoDownload.sh"]

