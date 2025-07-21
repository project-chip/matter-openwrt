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

type get_mac_label >/dev/null || . /lib/functions/system.sh
type json_init >/dev/null || . /usr/share/libubox/jshn.sh

random_uint32() {
	hexdump -n 4 -e '4 "%u"' /dev/urandom
}

random_discriminator() {
	echo "$(($(random_uint32) & 0xfff))"
}

random_pincode() {
	while true; do
		local pin="$(($(random_uint32) & 0x7ffffff))" # 0x7ffffff >= 99999999
		[ 0 -lt $pin -a $pin -lt 99999999 -a \
			$pin -ne 11111111 -a $pin -ne 22222222 -a $pin -ne 33333333 -a $pin -ne 44444444 -a \
			$pin -ne 55555555 -a $pin -ne 66666666 -a $pin -ne 77777777 -a $pin -ne 88888888 -a \
			$pin -ne 12345678 -a $pin -ne 87654321 ] && break
	done
	echo "$pin"
}

get_model_name() {
	local model
	local cfg="/etc/board.json"
	[ -s "$cfg" ] || return
	json_init
	json_load "$(cat $cfg)"
	if json_is_a model object; then
		json_select model
		json_get_var model name
		json_select ..
	fi
	echo "$model"
}

generate_factory_ini() {
	echo "[DEFAULT]"
	echo "discriminator=$(random_discriminator)"
	echo "pin-code=$(random_pincode)"

	serial="$(get_mac_label)"
	serial="${serial//:/}"
	[ -n "$serial" ] && echo "serial-num=$serial"

	model="$(get_model_name)"
	[ -n "$model" ] && echo "product-name=$model"
}

matter_bootstrap() {
	mkdir -p /etc/matter
	chown matter:matter /etc/matter
	chmod 0700 /etc/matter
	local ini=/etc/matter/chip_factory.ini
	if ! [ -s "$ini" ]; then
		generate_factory_ini >"${ini}.tmp"
		mv "${ini}.tmp" "$ini"
	fi
}

[ -n "$INCLUDE_ONLY" ] || matter_bootstrap
