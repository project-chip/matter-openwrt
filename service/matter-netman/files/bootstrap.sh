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
	jsonfilter -q -i /etc/board.json -e @.model.name
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

ensure_mod_own() { # path mode owner group
	# avoid unnecessary flash writes: only chmod/chown if different
	find "$1" -maxdepth 0 ! -perm "$2" -exec chmod "$2" -- {} \;
	find "$1" -maxdepth 0 ! \( -user "$3" -a -group "$4" \) -exec chown "$3:$4" -- {} \;
}

matter_bootstrap() {
	# create /etc/matter and /etc/matter/data if needed and ensure the
	# permissions are correct (sysupgrade loses directory permissions).
	mkdir -p /etc/matter/data
	ensure_mod_own /etc/matter 0750 root matter
	ensure_mod_own /etc/matter/data 0700 matter matter

	# generate factory config if necessary
	local ini=/etc/matter/chip_factory.ini
	if ! [ -s "$ini" ]; then
		rm -f "${ini}.tmp"
		( umask 277; generate_factory_ini >"${ini}.tmp" )
		chown matter:matter "${ini}.tmp"
		mv "${ini}.tmp" "$ini"
	fi

	# migration: data used to live in /etc/matter directly
	if [ -f /etc/matter/chip_kvs.ini -a ! -f /etc/matter/data/chip_kvs.ini ]; then
		mv -n /etc/matter/chip_config.ini /etc/matter/chip_counters.ini /etc/matter/chip_kvs.ini /etc/matter/data/
	fi
}

[ -n "$INCLUDE_ONLY" ] || matter_bootstrap
