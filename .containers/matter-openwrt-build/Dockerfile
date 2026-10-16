ARG OPENWRT_VERSION=25.12.5
FROM ghcr.io/openwrt/sdk:x86-generic-${OPENWRT_VERSION}
LABEL org.opencontainers.image.description="Pre-warmed OpenWrt SDK"

# The SDK image is based on Debian 11 (bullseye), which is EOL and has moved to archive.debian.org.
# Its stock ca-certificates (2021) lacks newer roots such as GlobalSign Root E46, which makes curl
# fail with "unable to get local issuer certificate" when downloading from some upstream hosts.
# The check makes this step fail loudly once the SDK image moves to a newer base, so it can be dropped.
USER root
RUN set -x && \
    grep -q '^11\.' /etc/debian_version && \
    sed -i -E 's|^deb http://deb\.debian\.org/|deb http://archive.debian.org/|' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER buildbot

# Core packages to pre-build to speed up CI builds
ARG SRC_PACKAGES="glib2 openssl ubus avahi python3/host"
ARG CFG_PACKAGES="glib2 libopenssl libubus libavahi-client"

RUN set -x && \
    grep -w 'base\|packages' feeds.conf.default | sed -e 's|git.openwrt.org/[^/]*|github.com/openwrt|' >feeds.conf && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install $(echo "${SRC_PACKAGES}" | sed 's|/host||g') && \
    echo "CONFIG_ALL=n" >.config && \
    echo "CONFIG_AUTOREMOVE=n" >>.config && \
    echo "CONFIG_AUTOREBUILD=n" >>.config && \
    for pkg in ${CFG_PACKAGES}; do echo "CONFIG_PACKAGE_${pkg}=y"; done >>.config && \
    : "Normalize timestamps to avoid spurious rebuilds due to Docker layer mtime truncation" && \
    SDE=$(sed -n 's/^SOURCE_DATE_EPOCH:=//p' include/version.mk) && test -n "$SDE" && \
    find .config feeds -exec touch -h -d "@$SDE" {} + && \
    make defconfig && \
    for pkg in ${SRC_PACKAGES}; do make -j "$(nproc)" "package/${pkg}/compile"; done
