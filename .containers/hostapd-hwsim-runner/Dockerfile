FROM --platform=linux/amd64 debian:trixie-slim

# The tests need mac80211_hwsim, which is not available for the kernel of a
# GitHub Actions runner, so qemu-run executes them in a nested VM built around
# the generic Debian kernel.
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # hostap build
        build-essential git pkg-config \
        autoconf automake libtool \
        binutils-dev libiberty-dev \
        libnl-3-dev libnl-genl-3-dev libnl-route-3-dev \
        libmbedtls-dev libssl-dev \
        libsqlite3-dev libpcap-dev libxml2-dev libcurl4-openssl-dev \
        # test runtime
        python3 python3-pip \
        iproute2 iw bridge-utils net-tools \
        kmod procps psmisc openssl wireless-regdb \
        faketime ca-certificates \
        qemu-system-x86 virtiofsd; \
    # Download and unpack the kernel image directly; this avoids pulling in
    # it's runtime dependencies (linux-base, systemd, udev, ...) and also
    # avoids running any post-install hooks like initramfs generation.
    kpkg="$(apt-cache depends linux-image-amd64 | grep Depends | grep -o 'linux-image-.*')"; \
    cd /var/cache; apt-get download "$kpkg"; dpkg-deb -x linux-image-*.deb /; \
    cd /boot; ln -s vmlinuz-* vmlinuz-qemu; \
    kver="$(ls /lib/modules)"; depmod "$kver"; \
    # Clean up
    rm -rf /var/cache/linux-image-*.deb /var/lib/apt/lists/*

COPY qemu-run /usr/local/bin/qemu-run

# The Debian wolfssl package does not enable all the options hostapd requires.
# Build from source enabling everything hostapd's crypto_wolfssl.c / DPP / EAP
# code references: --enable-all is the feature umbrella (PKCS7, cert gen/req,
# HPKE, ...) and --enable-wpas adds the wpa_supplicant-specific bits that
# --enable-all does not (notably HAVE_SECRET_CALLBACK, HAVE_KEYING_MATERIAL).
RUN cd /usr/local/src \
    && git clone --depth 1 --single-branch --branch v5.9.2-stable https://github.com/wolfSSL/wolfssl \
    && cd wolfssl \
    && ./autogen.sh && ./configure --enable-all --enable-wpas --enable-hpke \
    && make -j"$(nproc)" && make install && ldconfig \
    && cd / && rm -rf /usr/local/src/wolfssl

# Test-framework Python deps (the packaged versions are known-problematic, so use pip;
# Debian marks the base env externally-managed, hence --break-system-packages).
RUN pip3 install --no-cache-dir --break-system-packages pycryptodome pyrad

# hwsim tests launch hostapd/wpa_supplicant etc. via sudo unconditionally,
# which strips LD_PRELOAD and breaks using faketime to work around expired
# test certificates. Use a sudo stub similar to tests/hwsim/vm/inside.sh.
RUN printf '%s\n' '#!/bin/sh' 'exec "$@"' >/usr/local/bin/sudo \
    && chmod +x /usr/local/bin/sudo
