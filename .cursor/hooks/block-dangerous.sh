#!/bin/bash
# ============================================================
# [beforeShellExecution] 위험한 셸 명령 차단
# ============================================================

INPUT=$(cat || true)
[ -z "$INPUT" ] && echo '{"permission":"allow"}' && exit 0

CMD=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('command') or '', end='')
" 2>/dev/null) || CMD=""

if echo "$CMD" | grep -qiE 'rm\s+-rf\s+/|drop\s+database|truncate\s+table|:()\{.*\|.*\};:'; then
  echo '{"permission":"deny","user_message":"⛔ 위험한 명령이 차단되었습니다."}'
  exit 0
fi

if echo "$CMD" | grep -qiE 'mysql.*prod|psql.*prod|mongo.*prod'; then
  echo '{"permission":"deny","user_message":"⛔ 프로덕션 DB 접속이 차단되었습니다."}'
  exit 0
fi

echo '{"permission":"allow"}'
exit 0
