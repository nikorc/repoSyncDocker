FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf install -y dnf-plugins-core && \
    dnf install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf install -y --nogpgcheck \
        https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm && \
    dnf makecache && \
    dnf install -y createrepo genisoimage && \
    dnf clean all

COPY ./app/generateExtrasRepo.sh /usr/local/bin/
COPY ./app/rhRepoDownload.sh /usr/local/bin/
COPY ./app/mkISO.sh /usr/local/bin/

RUN chmod +x \
    /usr/local/bin/generateExtrasRepo.sh \
    /usr/local/bin/rhRepoDownload.sh \
    /usr/local/bin/mkISO.sh

CMD ["/usr/local/bin/rhRepoDownload.sh"]
