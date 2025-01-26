ARG ROCKY_VERSION=9
FROM rockylinux:${ROCKY_VERSION}

ARG ROCKY_VERSION=9
ENV CD_LABEL="RockyLiveCD"
ENV CUSTOM_KICKSTART="custom"
ENV FLATTENED_KICKSTART="live"

RUN dnf install -y epel-release \
    && dnf install -y \
        git \
        pykickstart \
        livecd-tools \
    && dnf clean all

RUN git clone \
    --branch r${ROCKY_VERSION} \
    --single-branch \
    https://github.com/rocky-linux/kickstarts.git \
    /usr/share/rocky-kickstarts

COPY --chmod=755 --chown=root:root build.sh /usr/local/bin/build


VOLUME [ "/out", "/in" ]

WORKDIR /out

CMD ["build"]
