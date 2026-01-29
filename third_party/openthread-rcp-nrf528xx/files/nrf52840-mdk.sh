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

rcp_fw_nrf52840_mdk() {
	local PREFIX=/usr/share/openthread-rcp/nrf52840-mdk
	local verb="$1"; shift
	case "$verb" in
		update) rcp_fw_nrf52840_mdk_update "$@";;
		installable) rcp_fw_nrf52840_mdk_installable "$@";;
		install) rcp_fw_nrf52840_mdk_install "$@";;
		*) return "$RC_INTERNAL";;
	esac
}

rcp_fw_nrf52840_mdk_update() {  # devicename tty url currentfw
	local dev="$1" tty="$2" currentfw="$4"
	[ "${currentfw/; NRF52840-MDK;/}" != "$currentfw" ] || return "$RC_NOT_SUPPORTED"

	local version
	[ -r "${PREFIX}.version" ] && read -r version <"${PREFIX}.version" && [ -n "$version" ] || return "$RC_INTERNAL"
	if [ "$currentfw" = "$version" ]; then
		log debug "Firmware of USB device $dev is up to date"
		return 0
	fi

	# Sanity check that the binary we're about to flash matches the version we think it has
	[ -r "${PREFIX}.bin" ] && grep -qF "$version" "${PREFIX}.bin" || return "$RC_INTERNAL"
	log notice "Attempting firmware update of nrf52840_mdk device $dev"
	log notice " -> $version"

	rcp_fw_nrf52840_mdk_bootloader "$dev" "$tty" || return $?
	rcp_fw_nrf52840_mdk_install "$dev"
}

rcp_fw_nrf52840_mdk_bootloader() {  # devicename tty
	local dev="$1" tty="$2" retry
	for retry in 2 1 0; do
		log debug "Triggering reset into UF2 boot loader"
		uf2 reset "$tty"
		sleep 1
		usb_read_property "$dev" TYPE && [ "$REPLY" = 239/2/1 ] && return 0
	done
	log error "Failed to trigger UF2 boot loader on USB device $dev"
	return "$RC_INTERNAL"
}

rcp_fw_nrf52840_mdk_installable() {  # devicename
	# The vendor and product ids can't be used easily because they vary depending on the boot loader version
	usb_read_property "$1" TYPE && [ "$REPLY" = 239/2/1 ] || return "$RC_NOT_SUPPORTED"
	usb_read_property "$1" product && REPLY="${REPLY// /-}" && [ "${REPLY#nRF52840-MDK-}" != "$REPLY" ] || return "$RC_NOT_SUPPORTED"
	[ -r "${PREFIX}.bin" ] || return "$RC_INTERNAL"
	return 0
}

rcp_fw_nrf52840_mdk_install() {  # devicename
	local dev="$1"

	if ! usb_wait_devnode "$dev" block sd; then
		log error "Failed to find UF2 block device for USB device $dev"
		return "$RC_INTERNAL"
	fi
	local blockdev="$REPLY"

	local mnt="/tmp/rcp-uf2.$$"
	local cleanup="{ umount -f '$mnt'; rmdir '$mnt'; } 2>/dev/null"
	trap "$cleanup" 0; cleanup="trap - 0; $cleanup" # otbr-rcp ensures HUP/INT/TERM trigger exit
	log debug "Mounting UF2 block device $blockdev"
	if ! mkdir -p -m 0600 "$mnt" || ! mount -t vfat -o noatime,shortname=win95,umask=0077 "$blockdev" "$mnt"; then
		log error "Failed to mount UF2 block device $blockdev for USB device $dev"
		eval "$cleanup"; return "$RC_INTERNAL"
	fi

	local info="$mnt/INFO_UF2.TXT"
	if ! [ -r "$info" ] || ! read -r info <"$info"; then
		log error "Failed to read UF2 boot loader information from $blockdev for USB device $dev"
		eval "$cleanup"; return "$RC_INTERNAL"
	fi
	log debug " -> $info"

	log notice "Flashing USB device $dev via UF2 boot loader on $blockdev"
	uf2 convert 0xADA52840 0x1000 "${PREFIX}.bin" "$mnt/FLASH.UF2" # exit status may not be reliable
	eval "$cleanup"
	return 0
}
