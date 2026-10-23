#!/bin/bash
# ============================================================
# [beforeReadFile] 민감 파일 읽기 차단
# ============================================================

INPUT=$(cat || true)
[ -z "$INPUT" ] && echo '{"permission":"allow"}' && exit 0

FILE=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('file_path') or '', end='')
" 2>/dev/null) || FILE=""

[ -n "$FILE" ] || { echo '{"permission":"allow"}'; exit 0; }

if echo "$FILE" | grep -qiE '\.env$|\.env\.|id_rsa|\.pem$|credentials|secrets'; then
  BN=$(basename "$FILE" 2>/dev/null || echo "$FILE")
  echo "{\"permission\":\"deny\",\"user_message\":\"🔒 민감 파일 접근 차단: $BN\"}"
  exit 0
fi

echo '{"permission":"allow"}'
exit 0
