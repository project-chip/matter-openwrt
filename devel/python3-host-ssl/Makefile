# Copyright (c) 2025 Project CHIP Authors
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

PKG_NAME:=python3-host-ssl
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_HOST_ONLY:=1
PKG_BUILD_DEPENDS:=python3/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/python3-host-ssl
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python3 host package SSL configuration
endef

define Package/python3-host-ssl/description
  Augments the SSL configuration of the python3 host package to
  fall back to trust roots from the host python if necessary.
endef

Host/Configure:=$(empty)
Host/Compile:=$(empty)

define Host/Install
	SITEDIR=`$(STAGING_DIR_HOSTPKG)/bin/python3 -c 'import site; print(site.getsitepackages()[0])'` && \
	$(STAGING_DIR_HOST)/bin/python3 generate.py >$$$$SITEDIR/host_ssl_config.py && \
	echo import host_ssl_config >$$$$SITEDIR/host_ssl_config.pth
endef

define Host/Uninstall
	SITEDIR=`$(STAGING_DIR_HOSTPKG)/bin/python3 -c 'import site; print(site.getsitepackages()[0])'` && \
	rm -f $$$$SITEDIR/host_ssl_config.py $$$$SITEDIR/host_ssl_config.pth
endef

$(eval $(call BuildPackage,python3-host-ssl))
$(eval $(call HostBuild))
