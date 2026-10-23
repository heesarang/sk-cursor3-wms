#!/bin/bash
# ============================================================
# [afterFileEdit] 파일 수정 후 자동 포맷팅
# Java → google-java-format (설치되어 있으면)
# JS/HTML/CSS → prettier (설치되어 있으면)
# ============================================================

INPUT=$(cat || true)
[ -z "$INPUT" ] && echo '{}' && exit 0

FILE=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('file_path') or '', end='')
" 2>/dev/null) || FILE=""

[ -n "$FILE" ] && [ -f "$FILE" ] || { echo '{}'; exit 0; }

if [[ "$FILE" == *.java ]]; then
  which google-java-format > /dev/null 2>&1 && google-java-format --replace "$FILE" 2>/dev/null
fi

if [[ "$FILE" =~ \.(js|html|css|vue)$ ]]; then
  which npx > /dev/null 2>&1 && npx prettier --write "$FILE" 2>/dev/null
fi

echo '{}'
exit 0
