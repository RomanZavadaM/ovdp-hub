#!/bin/bash
set -eu
cd -- "$(dirname -- "$0")"
FLUTTER="${FLUTTER_ROOT:+${FLUTTER_ROOT}/bin/}flutter"
fail() { echo "Startup failed. See START-README.md and run flutter doctor -v."; read -r -p "Press Enter to close..." _ || true; }
trap fail ERR
"$FLUTTER" --version | grep -q '^Flutter 3.47.5 '
"$FLUTTER" pub get --enforce-lockfile
printf '%s\n' 'Starting macOS app. First launch builds native components.' 'Console: r = hot reload, R = restart, q = quit.'
"$FLUTTER" run -d macos --debug --no-pub
