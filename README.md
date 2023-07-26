# Matter OpenWRT Feed

This repository is an [OpenWRT](https://openwrt.org) feed that packages [Matter](https://github.com/project-chip/connectedhomeip) software components for the OpenWRT operating system. It forms part of a reference implementation for Matter device types in the Routers & Access Points category.

Matter is a unified, open-source application-layer connectivity standard built to enable developers and device manufacturers to connect and build reliable, and secure ecosystems and increase compatibility among connected home devices. Visit [buildwithmatter.com](http://buildwithmatter.com) to learn more.

## Usage

This repository is intended to be included as a package feed in an OpenWRT buildroot, and familiarity with the configuration and use of the OpenWRT build system is assumed in the following instructions. Please refer to the [OpenWRT Developer Guide](https://openwrt.org/docs/guide-developer/start) for general guidance on building an OpenWRT system.

Note that this repository is aimed primarily at Matter implementers and OpenWRT integrators, and provides source packages only.

### Adding the feed

Add the following line to `feeds.conf` (ensure the OpenWRT `packages` feed is also present; it's definition can be copied from `feeds.conf.default` if necessary):

```
src-git matter https://github.com/project-chip/matter-openwrt.git
```

Run the following commands to fetch the feed and install the `matter-netman` package into the build:

```
$ ./scripts/feeds update packages matter
$ ./scripts/feeds install matter-netman
```

### Build configuration

For a minimal configuration, overwrite the `.config` file with the following lines and then run `make defconfig`:

```
CONFIG_PACKAGE_wpad-basic-wolfssl=n
CONFIG_PACKAGE_wpad-openssl=y
CONFIG_PACKAGE_matter-netman=y
```

Note that since the Matter SDK is configured to build using OpenSSL, it is recommended to also use OpenSSL as the TLS backend for hostapd / wpad.

## License

Matter-OpenWRT is released under the [Apache 2.0 license](./LICENSE).
