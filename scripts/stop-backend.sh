#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$ROOT/logs/backend-wrapper.pid"

stop_by_port() {
  if ! command -v lsof >/dev/null 2>&1; then
    echo "lsof not found; install it or stop the Java process that listens on port 8080 manually."
    return 1
  fi
  local pids
  pids="$(lsof -ti :8080 -sTCP:LISTEN 2>/dev/null || true)"
  if [[ -z "${pids}" ]]; then
    echo "No listener found on port 8080."
    return 0
  fi
  echo "Stopping process(es) on port 8080: ${pids}"
  kill ${pids} 2>/dev/null || true
}

stop_by_port

if [[ -f "$PID_FILE" ]]; then
  WRAPPER_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${WRAPPER_PID}" ]] && kill -0 "$WRAPPER_PID" 2>/dev/null; then
    echo "Stopping Gradle wrapper PID ${WRAPPER_PID}"
    kill "$WRAPPER_PID" 2>/dev/null || true
  fi
  rm -f "$PID_FILE"
fi

echo "Done."
