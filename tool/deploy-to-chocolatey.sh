#!/bin/bash -e
# Copyright 2018 Google Inc. Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

openssl aes-256-cbc -K $encrypted_d18df560dfb2_key -iv $encrypted_d18df560dfb2_iv -in tool/encrypted/credentials.tar.enc \
    -out credentials.tar -d

tar xfO credentials.tar choco > choco

function travis_cmd() {
  echo "\$ $@"
  "$@"
}

travis_fold() {
  local action=$1
  local name=$2
  echo -en "travis_fold:${action}:${name}\r"
}

travis_fold start chocolatey
travis_cmd pub run grinder update_chocolatey
travis_fold end chocolatey
