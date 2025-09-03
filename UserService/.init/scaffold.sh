#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/blogging-platform-6426-6501/UserService"
cd "$WORKSPACE"
# package.json
if [ ! -f package.json ]; then
  cat > package.json <<'JSON'
{
  "name": "userservice",
  "version": "0.1.0",
  "private": true,
  "engines": { "node": ">=16" },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "jest --watchAll=false --runInBand --colors",
    "lint": "eslint . --ext .js,.jsx"
  },
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-scripts": "^5.0.0"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  },
  "browserslist": [">0.2%","not dead","not op_mini all"]
}
JSON
fi
mkdir -p public src src/mock
if [ ! -f public/index.html ]; then
  cat > public/index.html <<'HTML'
<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>UserService</title></head><body><div id="root"></div></body></html>
HTML
fi
if [ ! -f src/index.js ]; then
  cat > src/index.js <<'JS'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
const root = createRoot(document.getElementById('root'));
root.render(React.createElement(App));
JS
fi
if [ ! -f src/App.js ]; then
  cat > src/App.js <<'JS'
import React from 'react';
import fixtures from './mock/fixtures.json';
export default function App(){ return React.createElement('div',null, 'UserService mock count: '+(fixtures.users||[]).length); }
JS
fi
if [ ! -f src/mock/fixtures.json ]; then
  cat > src/mock/fixtures.json <<'JSON'
{ "users": [ {"id":1,"name":"Alice"}, {"id":2,"name":"Bob"} ] }
JSON
fi
if [ ! -f .gitignore ]; then
  cat > .gitignore <<'GIT'
node_modules
build
.DS_Store
/tmp
GIT
fi
