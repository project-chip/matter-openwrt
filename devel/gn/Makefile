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
PKG_SOURCE_PROTO:=git-with-metadata
PKG_SOURCE_MIRROR:=0 # don't try OpenWrt mirror

PKG_SOURCE_DATE:=2025-03-21
PKG_SOURCE_VERSION:=6e8e0d6d4a151ab2ed9b4a35366e630c55888444
PKG_MIRROR_HASH:=544da724e63e496be1f29df66259a6dd61bd6f4925b6310766185a5488d95681

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_HOST_ONLY:=1
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../../include/git-with-metadata.mk

define GitWithMetadata/gather
desc="`git describe HEAD --abbrev=12 --match initial-commit`" && \
echo -n "GN_VERSION=" && echo "$$$$desc" | cut -d - -f 3 && \
echo -n "GN_COMMIT=" && echo "$$$$desc" | cut -d - -f 4 | cut -c 2-
endef

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
		$(STAGING_DIR_HOST)/bin/python build/gen.py --no-last-commit-position && \
	{ . .git-metadata && \
		echo "#ifndef OUT_LAST_COMMIT_POSITION_H_" && \
		echo "#define OUT_LAST_COMMIT_POSITION_H_" && \
		echo "#define LAST_COMMIT_POSITION_NUM $$$$GN_VERSION" && \
		echo "#define LAST_COMMIT_POSITION \"$$$$GN_VERSION ($$$$GN_COMMIT)\"" && \
		echo "#endif // OUT_LAST_COMMIT_POSITION_H_" ; } >$(HOST_BUILD_DIR)/out/last_commit_position.h
endef

define Host/Compile
	$(NINJA) -C $(HOST_BUILD_DIR)/out gn
endef

define Host/Install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/out/gn $(1)/bin
endef

$(eval $(call BuildPackage,gn))
$(eval $(call HostBuild))
