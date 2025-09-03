#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/blogging-platform-6426-6501/UserService"
cd "$WORKSPACE"
[ -f package.json ] || { echo "package.json missing" >&2; exit 2; }
# helper: retry command up to 3 times with backoff
retry() { local n=0; local cmd="$@"; until [ $n -ge 3 ]; do if eval "$cmd"; then return 0; fi; n=$((n+1)); sleep $n; done; return 1; }
# decide install strategy
need_ci=0
if [ -f package-lock.json ] && [ ! -d node_modules ]; then need_ci=1; fi
# if node_modules exists but is older than package-lock.json, prefer clean install
if [ -d node_modules ] && [ -f package-lock.json ]; then
  if [ package-lock.json -nt node_modules ]; then need_ci=1; fi
fi
if [ ! -d node_modules ] || [ $need_ci -eq 1 ]; then
  if [ -f package-lock.json ]; then
    retry npm ci --no-audit --no-fund --no-progress || { echo "npm ci failed" >&2; exit 3; }
  else
    retry npm i --no-audit --no-fund --no-progress || { echo "npm i failed" >&2; exit 4; }
  fi
fi
# minimal lint configs
if [ ! -f .eslintrc.json ]; then
  cat > .eslintrc.json <<'JSON'
{ "env": {"browser": true, "es2021": true}, "extends": "eslint:recommended", "parserOptions": {"ecmaVersion": 2021, "sourceType": "module", "ecmaFeatures": {"jsx": true}}, "rules": {"no-unused-vars": "warn"} }
JSON
fi
if [ ! -f .prettierrc ]; then
  echo '{"singleQuote": true, "trailingComma":"es5"}' > .prettierrc
fi
# verify local react-scripts availability
if [ -x node_modules/.bin/react-scripts ]; then
  printf "local react-scripts found\n"
fi
