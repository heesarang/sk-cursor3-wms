#!/bin/bash
# ============================================================
# [stop] 에이전트 작업 완료 시 macOS 알림 + 로그 기록
# ============================================================

INPUT=$(cat || true)
[ -z "$INPUT" ] && echo '{}' && exit 0

STATUS=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('status') or 'unknown', end='')
" 2>/dev/null) || STATUS="unknown"

# macOS 알림
osascript -e "display notification \"상태: $STATUS\" with title \"Cursor Agent\" subtitle \"작업 완료\" sound name \"Glass\"" 2>/dev/null

# 로그 기록
LOG_DIR=".cursor/logs"
mkdir -p "$LOG_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] status=$STATUS" >> "$LOG_DIR/agent-history.log"
echo "$INPUT" >> "$LOG_DIR/agent-history.log"
echo "---" >> "$LOG_DIR/agent-history.log"

echo '{}'
exit 0
