#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/blogging-platform-6426-6501/UserService"
cd "$WORKSPACE"
[ -x node_modules/.bin/react-scripts ] || { echo "local react-scripts missing; run deps step" >&2; exit 2; }
# run build and fail on error
./node_modules/.bin/react-scripts build
# verify build output
[ -d build ] || { echo "build directory missing after build" >&2; exit 3; }
printf "build_ok: yes\n"
