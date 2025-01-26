ARG ROCKY_VERSION=9
FROM rockylinux:${ROCKY_VERSION}

ARG ROCKY_VERSION=9
ENV CD_LABEL="RockyLiveCD"
ENV LIVE_PRODUCT_LABEL="Custom Rocky ${ROCKY_VERSION} live CD"
ENV CUSTOM_KICKSTART="custom"
ENV FLATTENED_KICKSTART="live"
ENV SSH_ENABLED=true
ENV SSH_AUTHORIZED_KEY=
ENV SSH_KEY_URL=
ENV AUTOLOGIN_ENABLED=true

RUN dnf install -y epel-release-9-7.el9 \
    && dnf install -y \
        git-2.43.5-2.el9_5 \
        pykickstart-3.32.11-1.el9 \
        livecd-tools-31.0-1.el9 \
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
