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

PKG_NAME:=arm-gnu-rm-toolchain
UPSTREAM_VERSION:=10.3-2021.10
PKG_VERSION:=$(subst -,.,$(UPSTREAM_VERSION))

PrebuiltTarball=gcc-arm-none-eabi-$(UPSTREAM_VERSION)-$(1).tar.bz2
define Download/prebuilt
  URL:=https://developer.arm.com/-/media/files/downloads/gnu-rm/$(UPSTREAM_VERSION)/
  FILE:=$(call PrebuiltTarball,$(1))
endef
define Download/x86_64-linux
  $(call Download/prebuilt,x86_64-linux)
  MD5SUM:=2383e4eb4ea23f248d33adc70dc3227e
endef
define Download/aarch64-linux
  $(call Download/prebuilt,aarch64-linux)
  MD5SUM:=3fe3d8bb693bd0a6e4615b6569443d0d
endef
define Download/mac
  $(call Download/prebuilt,mac)
  MD5SUM:=7f2a7b7b23797302a9d6182c6e482449
endef

PKG_LICENSE:=GPL-3.0-or-later LGPL-3.0-or-later MIT Zlib
PKG_LICENSE_FILES:=license.txt

PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/arm-gnu-rm-toolchain
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=arm-gnu-rm-toolchain
  URL:=https://developer.arm.com/downloads/-/gnu-rm
  BUILDONLY:=1
endef

define Package/arm-gnu-rm-toolchain/description
  The GNU Arm Embedded Toolchain for 32-bit Arm Cortex-A, Arm Cortex-M, and Arm Cortex-R processor families.
endef

PREBUILT_FLAVOR:=$(if $(filter Darwin,$(HOST_OS)),mac,$(HOST_ARCH)-$(call tolower,$(HOST_OS)))
PREBUILT_TARBALL:=$(DL_DIR)/$(call PrebuiltTarball,$(PREBUILT_FLAVOR))
$(if $(strip $(Download/$(PREBUILT_FLAVOR))),$(eval $(call Download,$(PREBUILT_FLAVOR))))

Host/Prepare:=$(empty)
Host/Configure:=$(empty)

define Host/Compile
	test -f $(PREBUILT_TARBALL) || { echo "ERROR: Unsupported host platform '$(PREBUILT_FLAVOR)'"; false; }
endef

define Host/Install
	bzcat $(PREBUILT_TARBALL) | $(HOST_TAR) -C $(1) --strip-components 1 -xf -
endef

$(eval $(call BuildPackage,arm-gnu-rm-toolchain))
$(eval $(call HostBuild))
