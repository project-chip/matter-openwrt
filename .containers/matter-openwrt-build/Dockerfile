ARG OPENWRT_VERSION=23.05.5
FROM ghcr.io/openwrt/sdk:x86-generic-${OPENWRT_VERSION}
LABEL org.opencontainers.image.description="Pre-warmed OpenWrt SDK"

# Core packages to pre-build to speed up CI builds
ARG SRC_PACKAGES="glib2 openssl ubus avahi"
ARG CFG_PACKAGES="glib2 libopenssl libubus libavahi-client"

RUN set -x && \
    grep -w 'base\|packages' feeds.conf.default > feeds.conf && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install ${SRC_PACKAGES} && \
    echo "CONFIG_ALL=n" >.config && \
    echo "CONFIG_AUTOREMOVE=n" >.config && \
    for pkg in ${CFG_PACKAGES}; do echo "CONFIG_PACKAGE_${pkg}=y"; done >>.config && \
    make defconfig && \
    for pkg in ${SRC_PACKAGES}; do make -j "$(nproc)" "package/${pkg}/compile"; done
