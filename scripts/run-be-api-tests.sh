#!/usr/bin/env bash
#
# REQ §5 기준 백엔드 API curl 스모크.
# 선행: database/schemas/wms_ddl.sql 적용 및 시드(database/seeds/*.sql), backend application.yml DB 접근 가능.
# 사용: REPORT_PATH 지정 또는 기본 REPORT-BE-YYYY-MM-DD.md
#
set -euo pipefail

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE="${BASE_URL:-http://localhost:8080}"
TODAY="$(date +%Y%m%d)"
REPORT_PATH="${REPORT_PATH:-${ROOT}/docs/test-reports/REPORT-BE-${TODAY}.md}"
TMP_BODY="$(mktemp)"
WAIT_SECS="${WAIT_SECS:-120}"

TOTAL=0
PASS=0
FAIL=0
SKIP=0
declare -a ROWS=()

cleanup() {
  rm -f "$TMP_BODY"
}
trap cleanup EXIT

wait_ready() {
  local i=0
  while [[ $i -lt $WAIT_SECS ]]; do
    if curl -sf -o /dev/null "${BASE}/v3/api-docs"; then
      echo "OK health: GET ${BASE}/v3/api-docs"
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done
  echo "FAIL: server not reachable at ${BASE} within ${WAIT_SECS}s"
  return 1
}

# args: 설명 기대코드 메서드 URL [curl extra args...]
req() {
  local desc="$1" expect="$2" method="$3" url="$4"
  shift 4
  TOTAL=$((TOTAL + 1))
  local code
  code="$(curl -sS -o "$TMP_BODY" -w "%{http_code}" -X "$method" "$@" "${url}")" || true
  local ok="FAIL"
  if [[ "$code" == "$expect" ]]; then
    PASS=$((PASS + 1))
    ok="통과"
  else
    FAIL=$((FAIL + 1))
    ok="실패"
  fi
  local snippet
  local body=""
  body="$(head -c 280 "$TMP_BODY" 2>/dev/null)"
  snippet="${body//$'\n'/ }"
  snippet="${snippet//$'\r'/ }"
  ROWS+=("| ${TOTAL} | ${desc} | HTTP ${expect} · success 검증 가능 | HTTP ${code} · ${snippet}… | ${ok} |")
  if [[ "$ok" != "통과" ]]; then
    echo "  [실패] ${desc} → ${code} (기대 ${expect})"
    head -c 500 "$TMP_BODY" | sed 's/^/    /'
  fi
}

# JSON POST helper
post_json() {
  local desc="$1" expect="$2" url="$3" json="$4"
  req "$desc" "$expect" POST "$url" -H 'Content-Type: application/json' -d "$json"
}

# JSON 목록에서 status_code 가 00 인 첫 행 주문번호 (연속 테스트 시 재현용)
pick_inbound_order_00() {
  curl -sf "${BASE}/api/inbound/orders?status_code=00" | python3 -c "import sys,json; \
j=json.load(sys.stdin); \
rs=j.get('data') or []; \
print(rs[0]['order_no'] if rs else '', end='')"
}

pick_outbound_order_00() {
  curl -sf "${BASE}/api/outbound/orders?status_code=00" | python3 -c "import sys,json; \
j=json.load(sys.stdin); \
rs=j.get('data') or []; \
print(rs[0]['order_no'] if rs else '', end='')"
}

skip_case() {
  local desc="$1"
  local reason="$2"
  TOTAL=$((TOTAL + 1))
  SKIP=$((SKIP + 1))
  ROWS+=("| ${TOTAL} | ${desc} | (사전조건 불충족) | 건너뜀 — ${reason} | 건너뜀 |")
}

RUN_TESTS=yes
if [[ "${SKIP_TESTS:-}" == "1" ]]; then RUN_TESTS=no; fi

run_all_tests() {
  local IB00=""
  local OB00=""
  IB00="$(pick_inbound_order_00)"
  OB00="$(pick_outbound_order_00)"

  req "Inbound 목록 전체 GET §5.1" 200 GET "${BASE}/api/inbound/orders"
  req "Inbound 목록 필터 center_cd CTR01" 200 GET "${BASE}/api/inbound/orders?center_cd=CTR01"
  req "Outbound 목록 GET §5.1" 200 GET "${BASE}/api/outbound/orders"
  req "Outbound 필터 status_code 10" 200 GET "${BASE}/api/outbound/orders?status_code=10"
  req "Dashboard summary §5.1" 200 GET "${BASE}/api/dashboard/summary"
  req "Dashboard summary center CTR01" 200 GET "${BASE}/api/dashboard/summary?center_cd=CTR01"
  req "Dashboard recent 기본§5.2" 200 GET "${BASE}/api/dashboard/history/recent"
  req "Dashboard recent limit=5§5.2" 200 GET "${BASE}/api/dashboard/history/recent?limit=5"
  req "F4 규칙 INBOUND§5 optional" 200 GET "${BASE}/api/status-transitions/rules?order_kind=INBOUND"
  req "F4 규칙 OUTBOUND" 200 GET "${BASE}/api/status-transitions/rules?order_kind=OUTBOUND"

  req "Inbound 상세 IB-INVALID-TRANS §5.2(시드 고정)" 200 GET "${BASE}/api/inbound/orders/IB-INVALID-TRANS"
  req "Outbound 상세 OB-DONE §5.2(시드 고정)" 200 GET "${BASE}/api/outbound/orders/OB-DONE"

  req "Inbound 상세 404§5.2" 404 GET "${BASE}/api/inbound/orders/IB-___NOTEXIST___"
  req "Dashboard trace 존재 INBOUND§5.3" 200 GET "${BASE}/api/dashboard/history/trace?order_type=INBOUND&order_no=IB-CTR01-020"

  req "Dashboard trace 헤더없음 404§5.3" 404 GET "${BASE}/api/dashboard/history/trace?order_type=INBOUND&order_no=IB-________NOPE"

  req "Dashboard trace 필수 파라미터 누락" 400 GET "${BASE}/api/dashboard/history/trace?order_type=INBOUND"

  if [[ -z "$IB00" ]]; then
    skip_case "입고 상태 전체 정상 시나리오(00주문 선택)" "'status_code=00' 목록이 비었음 — DB 시드/리셋 필요"
    skip_case "입고 비정상 전이 00→20" "(동일)"
  else
    req "허용되지 않은 입고 전이 00→20§5.3(dynamic ${IB00})" 400 POST "${BASE}/api/inbound/orders/${IB00}/transition" \
      -H 'Content-Type: application/json' \
      -d '{"to_status":"20","changed_by":"test-be","change_reason":"bad-skip"}'

    post_json "입고 정상 00→10(${IB00})§5.3" 200 "${BASE}/api/inbound/orders/${IB00}/transition" \
      '{"to_status":"10","changed_by":"test-be","change_reason":"검수시작"}'
    post_json "입고 정상 10→20(${IB00})" 200 "${BASE}/api/inbound/orders/${IB00}/transition" \
      '{"to_status":"20","changed_by":"test-be","change_reason":"검수완료"}'
    post_json "입고 정상 20→90(${IB00})" 200 "${BASE}/api/inbound/orders/${IB00}/transition" \
      '{"to_status":"90","changed_by":"test-be","change_reason":"입고확정"}'
  fi

  post_json "확정주문(IB-INVALID-TRANS 90→10 거부§5)" 400 "${BASE}/api/inbound/orders/IB-INVALID-TRANS/transition" \
    '{"to_status":"10","changed_by":"test-be","change_reason":"무효"}'

  if [[ -z "$OB00" ]]; then
    skip_case "출고 상태 전체 정상 시나리오(00주문 선택)" "'status_code=00' 목록이 비었음 — DB 시드/리셋 필요"
    skip_case "출고 비정상 전이(추후 이미 확정 상태)" "(동일)"
  else
    post_json "출고 허용불가(00→20) 검증(dynamic ${OB00})§5" 400 "${BASE}/api/outbound/orders/${OB00}/transition" \
      '{"to_status":"20","changed_by":"test-be","change_reason":"건너뛰기"}'

    post_json "출고 정상 00→10(${OB00})§5.3" 200 "${BASE}/api/outbound/orders/${OB00}/transition" \
      '{"to_status":"10","changed_by":"test-be","change_reason":"피킹시작"}'
    post_json "출고 정상 10→20(${OB00})" 200 "${BASE}/api/outbound/orders/${OB00}/transition" \
      '{"to_status":"20","changed_by":"test-be","change_reason":"피킹완료"}'
    post_json "출고 정상 20→90(${OB00})" 200 "${BASE}/api/outbound/orders/${OB00}/transition" \
      '{"to_status":"90","changed_by":"test-be","change_reason":"출고확정"}'

    post_json "출고 허용불가(이미 90 재전이)§5" 400 "${BASE}/api/outbound/orders/${OB00}/transition" \
      '{"to_status":"10","changed_by":"test-be","change_reason":"되돌리기불가"}'

    req "trace 동적 확정 출고건(${OB00})§5.3" 200 GET "${BASE}/api/dashboard/history/trace?order_type=OUTBOUND&order_no=${OB00}"
  fi
}

main() {
  mkdir -p "$(dirname "$REPORT_PATH")"
  "${ROOT}/scripts/stop-backend.sh" >/dev/null 2>&1 || true
  "${ROOT}/scripts/start-backend.sh"

  if ! wait_ready; then
    FAIL=1 PASS=0 TOTAL=1
    ROWS=("| 1 | 서버 헬스(GET /v3/api-docs) | HTTP 200 (OpenAPI) | 서버 미기동·연결 불가 또는 DB 오류 가능 | 실패 |")
  elif [[ "$RUN_TESTS" == yes ]]; then
    echo "Running REQ §5 curl tests against ${BASE} ..."
    run_all_tests
    echo "Totals: 통과=${PASS} 실패=${FAIL} 건너뜀=${SKIP} (실행 블록=${TOTAL})"
  fi

  {
    echo "# 테스트 리포트 — BE (curl)"
    echo ""
    echo "| 항목 | 내용 |"
    echo "|------|------|"
    echo "| 실행일 | $(date +%Y-%m-%d) |"
    echo "| 대상 | REQ-F1/F2/F3 §5 및 F4 선택 규칙 API (curl) |"
    echo "| 결과 | 통과 ${PASS}건 / 실패 ${FAIL}건 / 건너뜀 ${SKIP}건 |"
    echo "| BASE_URL | ${BASE} |"
    echo "| 비고 | 상태 전이 정상 플로는 GET …?status_code=00 목록 첫 행(dynamic) 기준이다. 같은 DB로 반복 실행 시 00 행 소진 후 건너뜀 가능. 초기 상태로 돌리려면 database/schemas/05_init_sample.sql 또는 TRUNC 후 시드 필요. 필수 요구: curl, bash, python3. |"
    echo ""
    echo "## 테스트 결과 요약"
    echo ""
    echo "| No | 시나리오 | 기대 결과 | 실제 결과 | 상태 |"
    echo "|----|---------|-----------|-----------|------|"
    for row in "${ROWS[@]}"; do echo "$row"; done
    echo ""
    echo "## 실패 항목 상세"
    echo ""
    if [[ "$FAIL" -eq 0 ]]; then echo "- 해당 실행에서는 없음."; else echo "- 위 「테스트 결과 요약」표의 실패 행 및 콘솔 로그를 참고한다."; fi
    echo ""
    echo "## 재현 명령"
    echo ""
    echo '```bash'
    echo "./scripts/stop-backend.sh"
    echo "./scripts/start-backend.sh"
    echo "# 헬스: curl -sf http://localhost:8080/v3/api-docs >/dev/null && echo OK"
    echo "./scripts/run-be-api-tests.sh   # 선택: REPORT_PATH=... WAIT_SECS=180"
    echo "./scripts/stop-backend.sh"
    echo '```'
  } >"$REPORT_PATH"

  echo "Wrote ${REPORT_PATH}"
  "${ROOT}/scripts/stop-backend.sh"

  [[ "$FAIL" -eq 0 ]]
}

main "$@"
