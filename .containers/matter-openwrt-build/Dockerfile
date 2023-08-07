ARG OPENWRT_VERSION=22.03.5
FROM ghcr.io/openwrt/sdk:x86-generic-${OPENWRT_VERSION}
LABEL org.opencontainers.image.description="Pre-warmed OpenWrt SDK"

# Core packages to pre-build to speed up CI builds
ARG SRC_PACKAGES="openssl glib2"
ARG CFG_PACKAGES="libopenssl glib2"

# Add host tools from WORKDIR (/builder) to PATH
ENV PATH="/builder/staging_dir/host/bin:$PATH"
RUN set -x && \
    grep -w 'base\|packages' feeds.conf.default > feeds.conf && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install ${SRC_PACKAGES} && \
    for pkg in ${CFG_PACKAGES}; do echo "CONFIG_PACKAGE_${pkg}=y"; done >.config && \
    make defconfig && \
    make -j $(for pkg in ${SRC_PACKAGES}; do echo "package/${pkg}/compile"; done)
