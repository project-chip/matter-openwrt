# Copyright (c) 2024 Apple Inc.
# Copyright (c) 2024 Project CHIP Authors
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

PKG_NAME:=mDNSResponder
PKG_VERSION:=2200.140.11
PKG_RELEASE:=1

PKG_SOURCE:=mDNSResponder-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/apple-oss-distributions/mDNSResponder/archive/refs/tags
PKG_HASH:=f52963497e8baf650e6640fb5769ffbad7c6e45eea833dec2a0ca86a3ca55928

# Use local source dir for development
# USE_SOURCE_DIR:=$(HOME)/workspace/mDNSResponder

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_CONFIG_DEPENDS:=CONFIG_MDNSD_DEBUG_LOGGING

include $(INCLUDE_DIR)/package.mk

define Package/mdnsresponder/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://github.com/apple-oss-distributions/mDNSResponder
endef

define Package/mdnsresponder/Default/description
The mDNS Responder suite consists of a set of daemons, tools, and
libraries that implement Multicast DNS and DNS-SD service discovery.
endef


define Package/mdnsresponder
  $(call Package/mdnsresponder/Default)
  TITLE:=mDNS Responder suite (meta package)
  DEPENDS:=+mdnsd +libdnssd +mdns-utils
endef

define Package/mdnsresponder/description
$(call Package/mdnsresponder/Default/description)

This meta-package selects all packages in the mDNS Responder suite.
endef


define Package/mdnsd
  $(call Package/mdnsresponder/Default)
  TITLE:=mDNS Responder daemon
  MENU:=1
endef

define Package/mdnsd/config
if PACKAGE_mdnsd
	config MDNSD_DEBUG_LOGGING
		bool "Enable debug logging"
		default n
endif
endef

define Package/mdnsd/description
$(call Package/mdnsresponder/Default/description)

The mDNS Responder daemon serves both as resolver for information
published using multicast DNS (mDNS), and as a publisher of mDNS
information.
endef


define Package/libdnssd
  $(call Package/mdnsresponder/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=
  TITLE:=mDNS Responder DNS-SD client library
  CONFLICTS:=libavahi-compat-libdnssd
  DEPENDS:=+mdnsd
endef

define Package/libdnssd/description
The DNS-SD client library allows applications to make use of the
functionality provided by mDNSResponder. This includes publishing,
browsing, and resolving of DNS-SD services.
endef


define Package/mdns-utils
  $(call Package/mdnsresponder/Default)
  TITLE:=mDNS Responder utilities
  DEPENDS:=+libdnssd
endef

define Package/mdns-utils/description
This package contains the dns-sd utility.
endef


# The GitHub archive tarball has the wrong prefix due to the tag including the package name
TAR_CMD=$(HOST_TAR) -C $(1) --strip-components 1 $(TAR_OPTIONS)

# Build with os=linux-uclibc ("not glibc") because musl does not support nss.
# Build without debug options or stripping, both are handled via the OpenWrt build system.
# Use gcc as the linker front-end so libssp gets linked automatically if needed.
MAKE_PATH:=mDNSPosix
OUT_DIR:=$(PKG_BUILD_DIR)/$(MAKE_PATH)/build/prod
CLIENTS_OUT_DIR:=$(PKG_BUILD_DIR)/Clients/build
MAKE_FLAGS+=os=linux-uclibc tls=no CFLAGS_DEBUGGING= LD="$(TARGET_CC)" STRIP=:
TARGET_CFLAGS+=\
	-DmDNSResponderVersion=$(PKG_VERSION)-$(PKG_RELEASE) \
	-DMDNS_VERSIONSTR_NODTS \
	-DUNICAST_DISABLED \
	-DMDNS_DEBUGMSGS=$(if CONFIG_MDNSD_DEBUG_LOGGING,1,0)

# No configure step as such, but make clean on config changes
define Build/Configure
	[ -f $(STAMP_CONFIGURED) ] || $(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) clean
endef

define Build/Compile
	$(call Build/Compile/Default,Daemon libdns_sd Clients)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/mDNSShared/dns_sd.h $(1)/usr/include/
	$(CP) $(OUT_DIR)/libdns_sd.so $(1)/usr/lib/
endef

# make install is not suitable for a cross-compilation environment,
# pick up files directly from the build directory instead.
Build/Install:=$(empty)


Package/mdnsresponder/install:=$(empty)

define Package/mdnsd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_BIN) $(OUT_DIR)/mdnsd $(1)/usr/sbin
	$(INSTALL_BIN) ./files/mdnsd.init $(1)/etc/init.d/mdnsd
endef

define Package/libdnssd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(OUT_DIR)/libdns_sd.so $(1)/usr/lib/
endef

define Package/mdns-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(CLIENTS_OUT_DIR)/dns-sd $(1)/usr/bin
endef

$(eval $(call BuildPackage,mdnsresponder))
$(eval $(call BuildPackage,mdnsd))
$(eval $(call BuildPackage,libdnssd))
$(eval $(call BuildPackage,mdns-utils))
