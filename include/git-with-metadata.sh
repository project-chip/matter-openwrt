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

# This script is sourced at the start of a git download command sequence.
# It intercepts `git` and `true` commands so additional work can be
# performed at these injection points.

GWM_IN_HOOK=
GWM_META="$(mktemp -t gwm-meta.XXXXXX)"

git() { command git "$@" && [ -n "$GWM_IN_HOOK" ] || gwm_hook git "$@"; }
true() { [ -n "$GWM_IN_HOOK" ] || gwm_hook true "$@"; }

gwm_gather() {
    local func="gwm_gather_$1"
    if type "$func" >/dev/null; then
        echo "Gathering meta-data..."
        "$func" | tee "$GWM_META"
    fi
}

gwm_hook() {
    local GWM_IN_HOOK=1
    if [ "$1 $2" = "git checkout" ]; then
        gwm_gather checkout
    elif [ "$1 $2 $3" = "git submodule update" ]; then
        gwm_gather submodules
    elif [ "$1 $2" = "true dl_tar_pack" ]; then
        [ -s "$GWM_META" ] && mv "$GWM_META" "$SUBDIR/.git-metadata"
    fi
}
