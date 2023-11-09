#!/bin/bash

set -e 


if [ -z "$*" ]; then
  echo "[+] Compiling nextcloud desktop to /opt/app/desktop"
  set -x
  cd /usr/src/desktop
  cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/opt/app/desktop -DCMAKE_BUILD_TYPE=Debug
  cmake --build build --target install
else
  exec $@
fi

