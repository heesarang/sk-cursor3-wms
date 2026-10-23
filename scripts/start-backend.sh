#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT/logs"
LOG_FILE="$LOG_DIR/backend.log"
PID_FILE="$LOG_DIR/backend-wrapper.pid"

mkdir -p "$LOG_DIR"

if command -v lsof >/dev/null 2>&1; then
  if lsof -i :8080 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Port 8080 is already in use. Stop the existing process or change the server port."
    exit 1
  fi
fi

cd "$ROOT/backend"
nohup ./gradlew bootRun >>"$LOG_FILE" 2>&1 &
echo $! >"$PID_FILE"

echo "Started backend (Gradle wrapper PID $(cat "$PID_FILE")). Logs: $LOG_FILE"
echo "Wait until GET http://localhost:8080/v3/api-docs returns 200, then run tests or the frontend."
