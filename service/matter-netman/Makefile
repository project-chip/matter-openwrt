# Copyright (c) 2023-2026 Project CHIP Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include $(TOPDIR)/rules.mk

PKG_NAME:=matter-netman
PKG_RELEASE:=2
PKG_SOURCE_URL:=https://github.com/project-chip/connectedhomeip.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBMODULES:=\
  third_party/pigweed/repo \
  third_party/jsoncpp/repo \
  third_party/nlassert/repo \
  third_party/nlio/repo

# Hash can be regenerated with make package/matter-netman/check FIXUP=1
PKG_SOURCE_DATE:=2026-07-30
PKG_SOURCE_VERSION:=72ecdc2bca57e99b3defea68eb3bcc5bd8bebdbd
PKG_MIRROR_HASH:=6812910e012294a9b812bc7550e352e981627e8bec932d3634e098be68ebe7fb

# Use local source dir for development
# USE_SOURCE_DIR:=$(HOME)/workspace/connectedhomeip

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

# Python 3.11 is required for code generation; use the python3 host package if necessary.
# Because it is installed with a broken SSL configuration in some cases (including the
# OpenWrt SDK docker images), we use the python3-host-ssl package to work around this.
HAVE_PYTHON_311:=$(shell $(STAGING_DIR_HOST)/bin/$(PYTHON) -c 'import sys; print(sys.version_info>=(3,11) or "")')
PKG_BUILD_DEPENDS:=gn/host $(if $(HAVE_PYTHON_311),,python3-host-ssl/host)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/matter-netman/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Matter Network Infrastructure Manager Daemon
  URL:=https://github.com/project-chip/connectedhomeip
  DEPENDS:=+libstdcpp +libatomic +libubus +libubox +jsonfilter
  PROVIDES:=matter-netman
  USERID:=matter:matter
endef

define Package/matter-netman/default/description
  Matter Network Infrastructure Manager Daemon
  Integrates a router / access point with the Matter IoT ecosystem.

  This is an uncertified build. It identifies itself with the Connectivity
  Standards Alliance test vendor id 0xFFF1 and product id 0x8013, and it
  attests with the Matter SDK's development attestation certificate for that
  pair.

  That certificate is shared, not unique to this device: the same one ships
  in every build of the example, and its private key is published in the SDK
  source. Device attestation therefore cannot distinguish this router from
  any other node presenting the same credential, and successful attestation
  says nothing about who built the device or what software is running on it.
  The certificate also chains to a development root rather than a production
  one, so whether a controller accepts it silently, warns, or refuses depends
  on which roots that controller trusts.

  The manufacturer and product names reported in Basic Information are read
  from the firmware and describe who built it. They are accurate, and they
  are not backed by any Matter certification.
endef

define Package/matter-netman-mbedtls
  $(Package/matter-netman/default)
  TITLE+= (mbedtls)
  DEPENDS+= +PACKAGE_matter-netman-mbedtls:libmbedtls +@MBEDTLS_CCM_C
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
endef

define Package/matter-netman-mbedtls/description
$(Package/matter-netman/default/description)

This variant of the package uses the mbedTLS crypto library. It turns on
that library's MBEDTLS_CCM_C option, which OpenWrt leaves off by default
and which the AES-CCM cipher of the Matter message layer requires.
endef

define Package/matter-netman-openssl
  $(Package/matter-netman/default)
  TITLE+= (openssl)
  DEPENDS+= +PACKAGE_matter-netman-openssl:libopenssl
  CONFLICTS:=matter-netman-mbedtls
  VARIANT:=openssl
endef

define Package/matter-netman-openssl/description
$(Package/matter-netman/default/description)

This variant of the package uses the OpenSSL crypto library.
endef

# General options. The last two deliberately reverse what the example's
# args.gni asks for: access restrictions are backed only by the SDK's
# demonstration provider, which lifts every restriction on request, and
# tracing is of no use in a shipped build.
CONFIGURE_OPTIONS:=\
	--enable-ubus \
	--enable-detail-logging \
	--enable-recommended=no \
	--enable-access-restrictions=no \
	--enable-network-layer-ble=no \
	--enable-tracing-support=no

# Logging backend
CONFIGURE_OPTIONS+= --logging-backend=syslog
TARGET_CFLAGS+= -DCHIP_SYSLOG_IDENT=\"matter\"

# Crypto backend
ifeq ($(BUILD_VARIANT),mbedtls)
CONFIGURE_OPTIONS+= --crypto=mbedtls --enable-external-mbedtls
TARGET_LDFLAGS+= -lmbedcrypto -lmbedx509
endif
ifeq ($(BUILD_VARIANT),openssl)
CONFIGURE_OPTIONS+= --crypto=openssl
endif

# Configuration / persistence
CONF_DIR:=/etc/matter
TARGET_CFLAGS+=\
	-DFATCONFDIR=\"$(CONF_DIR)\" \
	-DSYSCONFDIR=\"$(CONF_DIR)/data\" \
	-DLOCALSTATEDIR=\"$(CONF_DIR)/data\" \
	-DCHIP_CONFIG_KVS_PATH=\"$(CONF_DIR)/data/chip_kvs.ini\"

# Device Information. Runtime information is configured by bootstrap.sh
include $(INCLUDE_DIR)/version.mk
OS_VERSION:=$(if $(filter-out SNAPSHOT,$(VERSION_NUMBER)),$(VERSION_NUMBER)-)$(VERSION_CODE)
# The identity strings are gn arguments rather than -D in TARGET_CFLAGS: the
# configure script splits CFLAGS on whitespace, so a define whose value has a
# space in it does not survive. The serial number stays a define because its
# gn argument emits nothing for the empty string, which is the value wanted.
CONFIGURE_OPTIONS+=\
	--device-config-device-software-version-string="$(PKG_VERSION)@$(OS_VERSION)" \
	--device-config-device-hardware-version-string="-" \
	--device-config-device-vendor-name="$(VERSION_DIST)"
TARGET_CFLAGS+=\
	-DCHIP_DEVICE_CONFIG_ENABLE_TEST_SETUP_PARAMS=0 \
	-DCHIP_DEVICE_CONFIG_TEST_SERIAL_NUMBER=\"\"

# https://github.com/openwrt/openwrt/issues/13016
TARGET_CFLAGS+= -Wno-format-nonliteral

# The build environment contains host tools that can be shared between targets
CHIP_BUILD_ENV_DIR:=$(STAGING_DIR_HOST)/share/matter-build-env
OUT_DIR:=$(PKG_BUILD_DIR)/out/openwrt

define Build/Configure
	mkdir -p $(OUT_DIR) && cd $(OUT_DIR) && \
		$(CONFIGURE_VARS) $(PKG_BUILD_DIR)/scripts/configure \
			--build-env-dir="$(CHIP_BUILD_ENV_DIR)" \
			--project=examples/network-manager-app/linux \
			--target=$(GNU_TARGET_NAME) \
			$(CONFIGURE_OPTIONS)
endef

define Build/Compile
	$(NINJA) -C $(OUT_DIR) matter-network-manager-app
endef

define Package/matter-netman/default/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/matter $(1)/etc/init.d $(1)/usr/share/acl.d $(1)/etc/hotplug.d/iface $(1)/etc/config
	$(INSTALL_BIN) $(OUT_DIR)/matter-network-manager-app $(1)/usr/sbin
	$(INSTALL_DATA) ./files/bootstrap.sh $(1)/usr/share/matter/
	$(INSTALL_DATA) ./files/matter_acl.json $(1)/usr/share/acl.d
	$(INSTALL_BIN) ./files/matter.init $(1)/etc/init.d/matter
	$(INSTALL_CONF) ./files/matter.config $(1)/etc/config/matter
	$(INSTALL_BIN) ./files/matter.iface-hotplug $(1)/etc/hotplug.d/iface/99-matter
endef

Package/matter-netman-mbedtls/install=$(Package/matter-netman/default/install)
Package/matter-netman-openssl/install=$(Package/matter-netman/default/install)

define Package/matter-netman/default/conffiles
$(CONF_DIR)/
/etc/config/matter
endef

Package/matter-netman-mbedtls/conffiles=$(Package/matter-netman/default/conffiles)
Package/matter-netman-openssl/conffiles=$(Package/matter-netman/default/conffiles)

$(eval $(call BuildPackage,matter-netman-mbedtls))
$(eval $(call BuildPackage,matter-netman-openssl))
