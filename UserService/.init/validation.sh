#!/usr/bin/env bash
set -euo pipefail

# Validation script: checks dev server readiness and verifies production bundling
WORKSPACE="/home/kavia/workspace/code-generation/blogging-platform-6426-6501/UserService"
cd "$WORKSPACE"
PIDFILE=/tmp/userservice_dev.pid
LOGPATHFILE=/tmp/userservice_dev.logpath
RESULT="$WORKSPACE/.ci_result.json"

# Ensure PID file exists
[ -f "$PIDFILE" ] || { echo "dev server pid not found; ensure start step ran" >&2; exit 6; }
PID=$(cat "$PIDFILE" 2>/dev/null || true)
LOGPATH=$(cat "$LOGPATHFILE" 2>/dev/null || echo /tmp/userservice_dev.log)
[ -n "$PID" ] || { echo "empty pidfile" >&2; exit 7; }

# Wait up to 60s for compilation success phrases in log or an HTTP 200/3xx response
timeout=60; i=0; ok=0
while [ $i -lt $timeout ]; do
  if [ -f "$LOGPATH" ]; then
    if grep -qE "Compiled successfully|Compiled successfully\.|You can now view" "$LOGPATH" 2>/dev/null; then
      ok=1; break
    fi
  fi
  http_code=$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PORT:-3000}/" || true)
  if echo "$http_code" | grep -qE "^200$|^301$|^302$"; then ok=1; break; fi
  sleep 1; i=$((i+1))
done

if [ $ok -ne 1 ]; then
  echo "did not detect successful compilation or HTTP 200 within timeout" >&2
  tail -n 80 "$LOGPATH" || true
  # attempt cleanup
  if ps -p "$PID" >/dev/null 2>&1; then kill "$PID" >/dev/null 2>&1 || true; fi
  rm -f "$PIDFILE" "$LOGPATHFILE" || true
  jq -n --arg status "failed" --arg msg "compile_or_http_timeout" '{status:$status,message:$msg}' > "$RESULT" || true
  cat "$RESULT" || true
  exit 8
fi

# Final HTTP health check
http_code=$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PORT:-3000}/" || true)
if ! echo "$http_code" | grep -qE "^200$|^301$|^302$"; then
  echo "unexpected http status: $http_code" >&2
  tail -n 80 "$LOGPATH" || true
  if ps -p "$PID" >/dev/null 2>&1; then kill "$PID" >/dev/null 2>&1 || true; fi
  rm -f "$PIDFILE" "$LOGPATHFILE" || true
  jq -n --arg status "failed" --arg http "$http_code" '{status:$status,http:$http}' > "$RESULT" || true
  cat "$RESULT" || true
  exit 9
fi

# Run dedicated build step to verify production bundling (fail on errors)
if [ -x ./node_modules/.bin/react-scripts ]; then
  ./node_modules/.bin/react-scripts build
else
  echo "react-scripts not found at ./node_modules/.bin/react-scripts" >&2
  # attempt to fail fast with a clear result file
  jq -n --arg status "failed" --arg msg "react-scripts_missing" '{status:$status,message:$msg}' > "$RESULT" || true
  cat "$RESULT" || true
  exit 10
fi
[ -d build ] || { echo "build missing after build" >&2; exit 11; }

# Write result artifact
jq -n --arg status "success" --arg http "$http_code" --arg pid "$PID" --arg log "$LOGPATH" '{status:$status,http:$http,pid:$pid,log:$log}' > "$RESULT" || true

# Cleanup server process (graceful then forceful if needed)
if ps -p "$PID" >/dev/null 2>&1; then
  kill "$PID" >/dev/null 2>&1 || true
  sleep 2
  if ps -p "$PID" >/dev/null 2>&1; then kill -9 "$PID" >/dev/null 2>&1 || true; fi
fi
rm -f "$PIDFILE" "$LOGPATHFILE" || true

# Print minimal evidence
cat "$RESULT" || true
