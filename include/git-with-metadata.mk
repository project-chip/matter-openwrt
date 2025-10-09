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

GWM_SH:=$(patsubst %.mk,%.sh,$(abspath $(lastword $(MAKEFILE_LIST))))

# Hook function that gathers git metadata; it can be overridden by the
# package Makefile. The output of this shell command (or commands) is
# captured into a .git-metadata file located at the root of the source tree.
define GitWithMetadata/gather
git show -s --format="COMMIT_TIMESTAMP=%ct" HEAD
endef

# Expands into a shell expression that resolves a variable from
# .git-metadata at build time, usually for passing as an argument
# to configure or cmake.
# Example: $(call GitWithMetadata/resolve,COMMIT_HASH)
define GitWithMetadata/resolve
"`. .git-metadata && echo "$$$$$(1)"`"
endef

ifndef DownloadMethod/default
$(error git-with-metadata.mk must be included after package.mk)
endif

# Set up hooks and delegate to the 'git' download method.
$(eval dl_tar_pack=true dl_tar_pack && $(value dl_tar_pack))
define DownloadMethod/git-with-metadata
	gwm_gather_$(if $(filter skip,$(SUBMODULES)),checkout,submodules)() { $(GitWithMetadata/gather) ; } && \
	SUBDIR=$(SUBDIR) && . $(GWM_SH) && $(call DownloadMethod/git,$(1),$(2))
endef
