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

# An overlay package adds patch files and/or modifies the build configuration
# of a base package from the OpenWrt core. The Makefile for an overlay is
# somewhat similar to that of a regular package:
#
#   # The PKG_RELEASE value of the overlaid package is calculated as
#   # 1000 * (base PKG_RELEASE) + OVERLAY_RELEASE, so that the overlaid
#   # package always has a higher revision than the base package. If set,
#   # it must be set before including overlay.mk; otherwise it defaults to 1.
#   OVERLAY_RELEASE:=1
#
#   # Include the overlay build logic. Should use a relative path within
#   # this repository, since the path from $(TOPDIR) depends on the local
#   # name used to pull in the feed.
#   include ../../include/overlay.mk
#
#   # Optional block of Makefile text to inject into the overlaid package.
#   # It will be placed after the base Makefile logic, but before any calls
#   # to BuildPackage.
#   define Overlay/BuildConfig
#   TARGET_CFLAGS+= -DENABLE_SOMETHING
#   endef
#
#   # Instead of calling BuildPackage, call BuildPackageOverlay with the
#   # base package path relative to $(TOPDIR)/package/.
#   $(eval $(call BuildPackageOverlay,network/services/hostapd))


OVERLAY_SH:=$(patsubst %.mk,%.sh,$(abspath $(lastword $(MAKEFILE_LIST))))
OVERLAY_RELEASE?=1

define BuildPackageOverlay
  $(call BuildPackageOverlay/$(if $(DUMP),Dump,Build),$(notdir $(1)),$(call overlay_base,$(1)))
endef

define BuildPackageOverlay/Dump
  CURDIR:=$$(TOPDIR)/$(2)
  include $$(CURDIR)/Makefile
  # Note: Overlay/BuildConfig is not supported for DUMP
endef

define BuildPackageOverlay/Build
  include $$(TOPDIR)/rules.mk
  include $$(INCLUDE_DIR)/depends.mk

  OVERLAY_DIR:=$$(BUILD_DIR_BASE)/overlaypkg/$(1)
  OVERLAY_BASE_DIR:=$$(TOPDIR)/$(2)
  OVERLAY_STAMP:=$$(OVERLAY_DIR)/.stamp.$$(call overlay_hash,$$(CURDIR) $$(OVERLAY_BASE_DIR))
  OVERLAY_TARGETS:=$$(filter-out check clean,$$(DEFAULT_SUBDIR_TARGETS))

  default: $$(if $$(CHECK),check,compile)

  $$(OVERLAY_STAMP): export OVERLAY_INJECT:=$$(overlay_inject)
  $$(OVERLAY_STAMP):
	rm -rf $$(OVERLAY_DIR)
	$$(OVERLAY_SH) $$(OVERLAY_BASE_DIR) $$(CURDIR) $$(OVERLAY_DIR)
	touch $$@

  .PHONY: $$(OVERLAY_TARGETS)
  $$(OVERLAY_TARGETS): $$(OVERLAY_STAMP)
	$$(MAKE) -C $$(OVERLAY_DIR) $$@

  .PHONY: clean
  clean:
	$$(MAKE) -C $$(OVERLAY_BASE_DIR) $$@
	rm -rf $$(OVERLAY_DIR)
endef

# Base packages should be directly in feeds/base, but before OpenWrt 25 that path can
# point to the root of a core repo working copy, requiring an additional package/ suffix.
overlay_base=$(or $(call overlay_find_core,$(1)),$(error Unable to locate core package '$(1)' (missing base feed?)))
overlay_find_core=$(firstword $(foreach p,feeds/base/$(1) feeds/base/package/$(1),$(if $(wildcard $(TOPDIR)/$(p)/Makefile),$(p))))
overlay_hash=$(shell $(call $(if $(CONFIG_AUTOREMOVE),find_md5_reproducible,find_md5),$(1)))
define overlay_inject
### OVERLAY BEGIN
PKG_RELEASE := $$(shell expr $$(PKG_RELEASE) \* 1000 + $(OVERLAY_RELEASE))
$(value Overlay/BuildConfig)
### OVERLAY END
endef
