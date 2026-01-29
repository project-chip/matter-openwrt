# Copyright (c) 2026 Project CHIP Authors
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

PKG_NAME:=openthread-rcp-nrf528xx
PKG_RELEASE:=1
PKG_SOURCE_URL:=https://github.com/openthread/ot-nrf528xx.git
PKG_SOURCE_PROTO:=git-with-metadata
PKG_SOURCE_MIRROR:=0 # don't try OpenWrt mirror

# Note: The commit picked for this package should be aligned with that of the
# openthread-br package so that the underlying OpenThread version matches.
PKG_SOURCE_DATE:=2025-10-28
PKG_SOURCE_VERSION:=580f7bc7b432ee98c0767fbca13563c18f0144e0
PKG_MIRROR_HASH:=2f1e8283a7de7191851041106cec87e832f314d7f486e193c6b013bcdcdbe8fb

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=arm-gnu-rm-toolchain/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../include/git-with-metadata.mk

define GitWithMetadata/gather
echo -n OT_GIT_VERSION= && git -C openthread describe --dirty --always
endef

define Package/openthread-rcp-nrf52840-mdk
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenThread RCP firmware for NRF52840-MDK
  URL:=https://github.com/openthread/ot-nrf528xx
  VARIANT:=nrf52840-mdk
  DEPENDS:=+uf2-utils
  PKGARCH:=all
endef

define Package/openthread-rcp-nrf52840-mdk/description
  This variant targets the Makerdiary nRF52840 MDK USB Dongle
endef

BUILD_BINDIR:=$(PKG_BUILD_DIR)$(if $(USE_SOURCE_DIR),/build)
BUILD_PLATFORM:=$(word 1,$(subst -, ,$(BUILD_VARIANT)))
BUILD_PLATFORM_INFO:=$(call toupper,$(BUILD_VARIANT))
BUILD_OPTIONS:=\
	-DCMAKE_TOOLCHAIN_FILE=src/$(BUILD_PLATFORM)/arm-none-eabi.cmake \
	-DCMAKE_PROJECT_ot-nrf528xx_INCLUDE=$(CURDIR)/overrides.cmake \
	-DCMAKE_BUILD_TYPE=MinSizeRel \
	-DNRF_PLATFORM=$(BUILD_PLATFORM) \
	-DOT_PLATFORM=external \
	-DOT_EXTERNAL_MBEDTLS=nordicsemi-mbedtls \
	-DOT_PACKAGE_VERSION=$(call GitWithMetadata/resolve,OT_GIT_VERSION)$(if $(PKG_RELEASE),-r$(PKG_RELEASE)) \
	-DOVR_OT_PLATFORM_INFO="$(BUILD_PLATFORM_INFO)" \
	-DOT_SLAAC=ON \
	-DOT_USB=ON

ifeq ($(BUILD_VARIANT),nrf52840-mdk)
  BUILD_OPTIONS+= \
	-DOVR_USBD_PRODUCT_NAME="nRF52840-MDK OpenThread Device" \
	-DOT_BOOTLOADER=UF2 \
	-DOT_STATUS_LED_PINS="(0,23),(0,22),(0,24)" \
	-DOVR_USBD_BUS_POWERED=ON
endif

define Build/Configure
	mkdir -p $(BUILD_BINDIR) && cd $(BUILD_BINDIR) && \
		rm -f CMakeCache.txt && \
		cmake -GNinja $(BUILD_OPTIONS) $(PKG_BUILD_DIR)
endef

define Build/Compile
	+$(NINJA) -C $(BUILD_BINDIR) bin/ot-rcp
	arm-none-eabi-objcopy -O binary $(BUILD_BINDIR)/bin/ot-rcp $(BUILD_BINDIR)/bin/ot-rcp.bin
	arm-none-eabi-strings $(BUILD_BINDIR)/bin/ot-rcp | grep ^OPENTHREAD/ >$(BUILD_BINDIR)/bin/ot-rcp.version \
		&& grep -Fq "; $(BUILD_PLATFORM_INFO);" $(BUILD_BINDIR)/bin/ot-rcp.version
endef

define Package/openthread-rcp-nrf52840-mdk/install
	$(INSTALL_DIR) $(1)/usr/share/openthread-rcp
	$(INSTALL_DATA) $(BUILD_BINDIR)/bin/ot-rcp.bin $(1)/usr/share/openthread-rcp/$(BUILD_VARIANT).bin
	$(INSTALL_DATA) $(BUILD_BINDIR)/bin/ot-rcp.version $(1)/usr/share/openthread-rcp/$(BUILD_VARIANT).version
	$(INSTALL_DATA) ./files/$(BUILD_VARIANT).sh $(1)/usr/share/openthread-rcp/$(BUILD_VARIANT).sh
endef

$(eval $(call BuildPackage,openthread-rcp-nrf52840-mdk))
