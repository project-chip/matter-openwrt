# Copyright (c) 2023-2024 Project CHIP Authors
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
PKG_RELEASE:=1
PKG_SOURCE_URL:=https://github.com/project-chip/connectedhomeip.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_MIRROR:=0 # don't try OpenWrt mirror
PKG_SOURCE_SUBMODULES:=\
  third_party/pigweed/repo \
  third_party/jsoncpp/repo \
  third_party/nlassert/repo \
  third_party/nlio/repo

# Hash can be regenerated with make package/matter-netman/check FIXUP=1
PKG_SOURCE_DATE:=2025-07-08
PKG_SOURCE_VERSION:=dda2252eb28440305c883d0204737dce5b3abe62
PKG_MIRROR_HASH:=ad81137221dafc0302c70cb90a03ab2472a02ee3c03e8cef8edcba26fd34201d

# Use local source dir for development
# USE_SOURCE_DIR:=$(HOME)/workspace/connectedhomeip

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

# Python 3.11 is required for code generation; use the python3 host package if necessary
HAVE_PYTHON_311:=$(shell $(STAGING_DIR_HOST)/bin/$(PYTHON) -c 'import sys; print(sys.version_info>=(3,11) or "")')
PKG_BUILD_DEPENDS:=gn/host $(if $(HAVE_PYTHON_311),,python3/host)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/matter-netman/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Matter Network Infrastructure Manager Daemon
  URL:=https://github.com/project-chip/connectedhomeip
  DEPENDS:=+libstdcpp +libatomic
  USERID:=matter:matter
endef

define Package/matter-netman/default/description
  Matter Network Infrastructure Manager Daemon
  Integrates a router / access point with the Matter IoT ecosystem.
endef

define Package/matter-netman-mbedtls
  $(Package/matter-netman/default)
  TITLE+= (mbedtls)
  DEPENDS+= +PACKAGE_matter-netman-mbedtls:libmbedtls
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
endef

define Package/matter-netman-mbedtls/description
$(Package/matter-netman/default/description)

This variant of the package uses the mbedTLS crypto library,
which must have the MBEDTLS_CCM_C option enabled.
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

# General options
CONFIGURE_OPTIONS:=\
	--enable-recommended=no \
	--enable-access-restrictions=no \
	--enable-wifi=no \
	--enable-openthread=no \
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
CONFIG_DIR:=/etc/matter
TARGET_CFLAGS+=\
	-DCHIP_CONFIG_KVS_PATH=\"$(CONFIG_DIR)/chip_kvs.ini\" \
	-DFATCONFDIR=\"$(CONFIG_DIR)\" \
	-DSYSCONFDIR=\"$(CONFIG_DIR)\" \
	-DLOCALSTATEDIR=\"$(CONFIG_DIR)\"

# Device Information. Runtime information is configured by bootstrap.sh
include $(INCLUDE_DIR)/version.mk
OS_VERSION:=$(if $(filter-out SNAPSHOT,$(VERSION_NUMBER)),$(VERSION_NUMBER)-)$(VERSION_CODE)
TARGET_CFLAGS+=\
	-DCHIP_DEVICE_CONFIG_ENABLE_TEST_SETUP_PARAMS=0 \
	-DCHIP_DEVICE_CONFIG_DEVICE_SOFTWARE_VERSION_STRING=\"$(PKG_VERSION)@$(OS_VERSION)\" \
	-DCHIP_DEVICE_CONFIG_DEFAULT_DEVICE_HARDWARE_VERSION_STRING=\"\" \
	-DCHIP_DEVICE_CONFIG_DEVICE_VENDOR_NAME=\"$(VERSION_DIST)\" \
	-DCHIP_DEVICE_CONFIG_DEVICE_PRODUCT_NAME=\"\"

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
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/matter $(1)/etc/init.d
	$(INSTALL_BIN) $(OUT_DIR)/matter-network-manager-app $(1)/usr/sbin
	$(INSTALL_DATA) ./files/bootstrap.sh $(1)/usr/share/matter/
	$(INSTALL_BIN) ./files/matter.init $(1)/etc/init.d/matter
endef

Package/matter-netman-mbedtls/install=$(Package/matter-netman/default/install)
Package/matter-netman-openssl/install=$(Package/matter-netman/default/install)

define Package/matter-netman/default/conffiles
$(CONFIG_DIR)/
endef

Package/matter-netman-mbedtls/conffiles=$(Package/matter-netman/default/conffiles)
Package/matter-netman-openssl/conffiles=$(Package/matter-netman/default/conffiles)

$(eval $(call BuildPackage,matter-netman-mbedtls))
$(eval $(call BuildPackage,matter-netman-openssl))
