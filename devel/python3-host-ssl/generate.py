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

import os
import ssl
import sys

# Replicate the copyright header
with open(__file__, 'r') as source:
    for line in source:
        if not line.startswith('#'): break
        print(line.strip())

# Get the SSL configuration from the host python and emit them as
# constants into the helper module that applies them at runtime.
hostpaths = ssl.get_default_verify_paths()
print(f"""
import os
import ssl

# Configuration extracted from {os.path.realpath(sys.executable)}
HOST_CAFILE={hostpaths.openssl_cafile!r}
HOST_CAPATH={hostpaths.openssl_capath!r}

def get_default_verify_paths():
    paths = get_default_verify_paths.orig()
    useenv = not ssl.OPENSSL_VERSION.startswith('LibreSSL ') # get_default_verify_paths() lies on LibreSSL
    cafile, capath = (paths.cafile, paths.capath) if useenv else (paths.openssl_cafile, paths.openssl_capath)
    if os.path.isfile(cafile) or os.path.isdir(capath):
        return paths
    return ssl.DefaultVerifyPaths(
        HOST_CAFILE if os.path.isfile(HOST_CAFILE) else None,
        HOST_CAPATH if os.path.isdir(HOST_CAPATH) else None,
        paths.openssl_cafile_env if useenv else None, HOST_CAFILE,
        paths.openssl_capath_env if useenv else None, HOST_CAPATH)

def set_default_verify_paths(self):
    paths = get_default_verify_paths()
    self.load_verify_locations(cafile=paths.cafile, capath=paths.capath)

# Monkey patch the ssl module
get_default_verify_paths.orig = ssl.get_default_verify_paths
ssl.get_default_verify_paths = get_default_verify_paths
ssl.SSLContext.set_default_verify_paths = set_default_verify_paths
""")
