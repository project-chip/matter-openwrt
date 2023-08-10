#!/bin/bash -e

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

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 BASE SRC DST" >&2
    exit 1
fi
if [[ "${1#/}" == "$1" || "${2#/}" == "$2" ]]; then
    echo "BASE and SRC paths must be absolute" >&2
    exit 2
fi
if [[ -d "$3" ]]; then
    echo "DST directory already exists" >&2
    exit 2
fi

mkdir -p "$3/patches"
ln -s "$1" "$3/.base"
ln -s "$2" "$3/.overlay"

cd "$3"
shopt -s nullglob
for p in .base/patches/* .overlay/patches/*; do
    ln -s "../$p" patches/
done
for f in .base/*; do
    [[ "$f" == .base/patches ]] && continue
    ln -s "$f" .
done
