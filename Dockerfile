ARG ROCKY_VERSION=9
FROM rockylinux:${ROCKY_VERSION}

RUN dnf install -y epel-release \
    && dnf install -y \
        pykickstart \
        livecd-tools \
    && dnf clean all
