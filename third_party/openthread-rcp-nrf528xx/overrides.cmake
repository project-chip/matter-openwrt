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

set (OVR_OT_PLATFORM_INFO "" CACHE STRING "OpenThread Platform Name")
if(NOT "${OVR_OT_PLATFORM_INFO}" STREQUAL "")
    list(APPEND OT_PLATFORM_DEFINES "OPENTHREAD_CONFIG_PLATFORM_INFO=\"${OVR_OT_PLATFORM_INFO}\"")
endif()

set(OVR_USBD_PRODUCT_NAME "" CACHE STRING "USB Product Name")
if(NOT "${OVR_USBD_PRODUCT_NAME}" STREQUAL "")
    list(APPEND OT_PLATFORM_DEFINES "APP_USBD_STRINGS_PRODUCT=APP_USBD_STRING_DESC(\"${OVR_USBD_PRODUCT_NAME}\")")
endif()

set(OVR_USBD_BUS_POWERED OFF CACHE STRING "USB device is bus-powered")
if(OVR_USBD_BUS_POWERED)
    list(APPEND OT_PLATFORM_DEFINES "APP_USBD_CONFIG_SELF_POWERED=0")
endif()
