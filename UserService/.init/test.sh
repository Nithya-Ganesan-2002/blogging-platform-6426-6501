#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/blogging-platform-6426-6501/UserService"
cd "$WORKSPACE"
mkdir -p src/__tests__
cat > src/__tests__/fixtures.test.js <<'JS'
const fixtures = require('../mock/fixtures.json');
test('fixtures has users array', () => {
  expect(Array.isArray(fixtures.users)).toBe(true);
  expect(fixtures.users.length).toBeGreaterThan(0);
});
JS
# prefer local react-scripts test runner
if [ -x node_modules/.bin/react-scripts ]; then
  ./node_modules/.bin/react-scripts test --watchAll=false --runInBand --testPathPattern=src/__tests__
else
  if [ -x node_modules/.bin/jest ]; then
    ./node_modules/.bin/jest --colors --runInBand --testPathPattern=src/__tests__
  else
    echo "no local test runner found; run deps step" >&2; exit 5
  fi
fi
