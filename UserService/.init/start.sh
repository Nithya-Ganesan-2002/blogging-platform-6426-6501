#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/blogging-platform-6426-6501/UserService"
cd "$WORKSPACE"
PORT=${PORT:-3000}
PIDFILE=/tmp/userservice_dev.pid
LOGPATHFILE=/tmp/userservice_dev.logpath
# cleanup stale pidfile if process dead
if [ -f "$PIDFILE" ]; then
  oldpid=$(cat "$PIDFILE" || true)
  if [ -n "$oldpid" ] && ! ps -p "$oldpid" >/dev/null 2>&1; then rm -f "$PIDFILE" "$LOGPATHFILE" || true; fi
fi
[ -x node_modules/.bin/react-scripts ] || { echo "local react-scripts not found; run deps step" >&2; exit 4; }
LOGFILE=$(mktemp /tmp/userservice_dev.XXXXXX.log)
# use nohup and capture PID reliably
nohup env NODE_ENV=development PORT="$PORT" BROWSER=none CI=true ./node_modules/.bin/react-scripts start >"$LOGFILE" 2>&1 &
PID=$!
echo "$PID" > "$PIDFILE"
echo "$LOGFILE" > "$LOGPATHFILE"
printf "started:%s:%s\n" "$PID" "$LOGFILE"
