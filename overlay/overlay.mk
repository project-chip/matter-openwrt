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

OVERLAY_MK:=$(abspath $(lastword $(MAKEFILE_LIST)))
OVERLAY_SH:=$(dir $(OVERLAY_MK))overlay.sh

define BuildPackageOverlay
  $(call BuildPackageOverlay/$(if $(DUMP),Dump,Build),$(notdir $(1)),$(call overlay_base,$(1)))
endef

define BuildPackageOverlay/Dump
  CURDIR:=$$(TOPDIR)/$(2)
  include $$(CURDIR)/Makefile
endef

define BuildPackageOverlay/Build
  include $$(TOPDIR)/rules.mk

  OVERLAY_DIR:=$$(BUILD_DIR_BASE)/overlaypkg/$(1)
  OVERLAY_BASE_DIR:=$$(TOPDIR)/$(2)
  OVERLAY_STAMP:=$$(OVERLAY_DIR)/.stamp.$$(call overlay_hash,$$(CURDIR) $$(OVERLAY_BASE_DIR))
  OVERLAY_TARGETS:=$$(filter-out check clean,$$(DEFAULT_SUBDIR_TARGETS))

  default: $$(if $$(CHECK),check,compile)

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

overlay_base=$(or $(call overlay_find_core,$(1)),$(error Unable to locate core package '$(1)' (missing base feed?)))
overlay_find_core=$(firstword $(foreach p,package/$(1) feeds/base/package/$(1),$(if $(wildcard $(TOPDIR)/$(p)/Makefile),$(p))))
overlay_hash=$(shell find $(1) -type f -not -name '.*' | sort | mkhash md5)
