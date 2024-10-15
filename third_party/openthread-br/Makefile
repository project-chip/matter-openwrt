#  Copyright (c) 2020, The OpenThread Authors.
#  Copyright (c) 2024 Project CHIP Authors
#
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.

include $(TOPDIR)/rules.mk

PKG_NAME:=openthread-br
PKG_RELEASE:=2
PKG_SOURCE_URL:=https://github.com/openthread/ot-br-posix.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_MIRROR:=0 # don't try OpenWrt mirror

PKG_SOURCE_DATE:=2024-08-24
PKG_SOURCE_VERSION:=f2c799d154aed339e66c0dd85f6109bd9d91c5a9
PKG_MIRROR_HASH:=e79e70c0e6ca9341ff820915e4a0926c920cd5fe9bc4b81813f3e99e5086bd07

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/openthread-br/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenThread Border Router
  URL:=https://github.com/openthread/ot-br-posix
  DEPENDS:=+libstdcpp +libjson-c +libubus +libblobmsg-json +kmod-usb-acm +kmod-tun
endef

define Package/openthread-br/Default/description
The OpenThread Border Router daemon connects a Thread Network to the
Wi-Fi / Ethernet infrastructure network. Requires a Radio Co-Processor
(RCP) with appropriate firmware connected via UART / USB.
endef


define Package/openthread-br
  $(call Package/openthread-br/Default)
  VARIANT:=default
  DEPENDS+= +libdnssd
endef

define Package/openthread-br/description
$(call Package/openthread-br/Default/description)

This default variant of the package uses mDNSResponder for mDNS / DNS-SD.
endef


define Package/openthread-br-avahi
  $(call Package/openthread-br/Default)
  VARIANT:=avahi
  PROVIDES:=openthread-br
  CONFLICTS:=openthread-br
  DEPENDS+= +libavahi-client
endef

define Package/openthread-br-avahi/description
$(call Package/openthread-br/Default/description)

This variant of the package uses Avahi for mDNS / DNS-SD.
endef


# Disable firewall integration due to https://github.com/openthread/ot-br-posix/issues/1675
CMAKE_OPTIONS+= \
	-DCMAKE_BUILD_TYPE=$(if $(CONFIG_DEBUG),Debug,Release) \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DBUILD_TESTING=OFF \
	-DOTBR_OPENWRT=ON \
	-DOTBR_BORDER_AGENT=ON \
	-DOTBR_BORDER_ROUTING=ON \
	-DOTBR_INFRA_IF_NAME=br-lan \
	-DOTBR_SRP_ADVERTISING_PROXY=ON \
	-DOTBR_NAT64=OFF \
	-DOT_FIREWALL=OFF \
	-DOT_POSIX_SETTINGS_PATH=\"/etc/openthread\" \
	-DOT_READLINE=OFF

# OpenWrt uses /var/run instead of /run
TARGET_CFLAGS += \
	-DOPENTHREAD_POSIX_CONFIG_DAEMON_SOCKET_BASENAME=\\\"/var/run/openthread-%s\\\" \
	-DOPENTHREAD_CONFIG_LOG_PREPEND_UPTIME=0 \
	-DOPENTHREAD_CONFIG_LOG_PREPEND_LEVEL=0

ifeq ($(BUILD_VARIANT),avahi)
CMAKE_OPTIONS+= -DOTBR_MDNS="avahi"
else
CMAKE_OPTIONS+= -DOTBR_MDNS="mDNSResponder"
endif

define Package/openthread-br/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/otbr-agent $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ot-ctl $(1)/usr/sbin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/init.d/* $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/config/* $(1)/etc/config

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/admin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/openwrt/controller/thread.lua $(1)/usr/lib/lua/luci/controller/admin

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(CP) $(PKG_BUILD_DIR)/src/openwrt/view/admin_thread $(1)/usr/lib/lua/luci/view

	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(CP) $(PKG_BUILD_DIR)/src/openwrt/handle_error.js $(1)/www/luci-static/resources
endef

define Package/openthread-br/conffiles
/etc/openthread/
endef

Package/openthread-br-avahi/install=$(Package/openthread-br/install)
Package/openthread-br-avahi/conffiles=$(Package/openthread-br/conffiles)

$(eval $(call BuildPackage,openthread-br))
$(eval $(call BuildPackage,openthread-br-avahi))
