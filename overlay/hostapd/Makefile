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

OVERLAY_RELEASE:=1

include ../../include/overlay.mk

define Overlay/BuildConfig
# Safe for all package variants except those using the 'internal' TLS backend.
# Only variants with CONFIG_EAP_TLS=y will actually build pinning support.
ifneq ($(SSL_VARIANT),internal)
DRIVER_MAKEOPTS += CONFIG_EAP_TLS_PINNING=y
endif
endef

$(eval $(call BuildPackageOverlay,network/services/hostapd))
