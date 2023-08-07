# Copyright (c) 2023 Project CHIP Authors
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

PKG_NAME:=gn
PKG_SOURCE_URL:=https://gn.googlesource.com/gn
PKG_SOURCE_PROTO:=git
PKG_SOURCE_MIRROR:=0 # don't try OpenWrt mirror

# GN versioning is based on the number of commits since the tag `initial-commit`,
# and is exposed to build scripts via the `gn_version` variable. When updating
# PKG_SOURCE_VERSION to a new commit hash, GN_VERSION needs to be obtained via
#   git describe HEAD --match initial-commit | cut -f 3 -d -
# and updated below.
PKG_SOURCE_DATE:=2023-07-24
PKG_SOURCE_VERSION:=62ac86a938c365ccdbbbd9a9b49fb72fa3d6eb81
PKG_MIRROR_HASH:=231e7e663ec3a374bb86a50904b2af6562c29aad03de43f6b4a03d1be1f083c5
GN_VERSION:=2116

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_HOST_ONLY:=1
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/gn
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=gn
  URL:=https://gn.googlesource.com/gn
endef

define Package/gn/description
  GN is a meta-build system that generates build files for Ninja.
endef

define Host/Configure
	cd $(HOST_BUILD_DIR) && $(HOST_CONFIGURE_VARS) \
		$(STAGING_DIR_HOST)/bin/python build/gen.py --no-last-commit-position
	echo "$$$$GN_LAST_COMMIT_HEADER" | \
		VER_NUM=$(GN_VERSION) VER_STR="$(GN_VERSION) (`echo "$(PKG_SOURCE_VERSION)" | cut -c 1-12`)" \
		perl -lpe 's/\$$$$(\w+)/$$$$ENV{$$$$1}/ge' >$(HOST_BUILD_DIR)/out/last_commit_position.h
endef

define Host/Compile
	$(NINJA) -C $(HOST_BUILD_DIR)/out gn
endef

define Host/Install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/out/gn $(1)/bin
endef

define GN_LAST_COMMIT_HEADER
#ifndef OUT_LAST_COMMIT_POSITION_H_
#define OUT_LAST_COMMIT_POSITION_H_
#define LAST_COMMIT_POSITION_NUM $$VER_NUM
#define LAST_COMMIT_POSITION "$$VER_STR"
#endif // OUT_LAST_COMMIT_POSITION_H_
endef
export GN_LAST_COMMIT_HEADER

$(eval $(call BuildPackage,gn))
$(eval $(call HostBuild))
