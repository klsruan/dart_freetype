#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Running VM tests"
flutter test test/vm

if [[ "${RUN_WEB_TESTS:-0}" == "1" ]]; then
  echo "==> Running browser tests (Chrome)"
  if command -v xvfb-run >/dev/null 2>&1; then
    xvfb-run -a flutter test --platform chrome test/web
  else
    flutter test --platform chrome test/web
  fi
else
  echo "==> Skipping web/wasm tests (set RUN_WEB_TESTS=1 to enable)"
fi

echo "All tests passed."
