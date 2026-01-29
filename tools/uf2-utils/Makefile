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

PKG_NAME:=uf2-utils
PKG_VERSION:=0.1.0

PKG_LICENSE:=Apache-2.0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/uf2-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for interacting with UF2 bootloaders
  DEPENDS:=+kmod-usb-storage +kmod-fs-vfat
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CPPFLAGS) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/uf2 uf2.c $(TARGET_LDFLAGS)
endef

define Package/uf2-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uf2 $(1)/usr/sbin
endef

$(eval $(call BuildPackage,uf2-utils))
