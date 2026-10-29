# 요구사항 정의서 — 출고 관리

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-F2-outbound |
| 버전 | 1.0 |
| 기준 PRD | docs/01.analysis/01.rfp/wms_prd.md — §4 F2 |

## §1. 추적성 (PRD 매핑)

| PRD 항목 | 본 문서 |
|----------|---------|
| F2 출고 주문 관리·F1과 동일 UX | §3, §5 (경로만 outbound) |
| F2 피킹시작→피킹완료→출고확정 | §2, §3 FR-F2-03, §5.3 |
| F2 비허용 전이 거부 | §3 FR-F2-04, §5.3 |
| §7 출고 주문·라인 | §4 |
| F4 전이·이력 | REQ-F4-status-transition.md |

## §2. 상태 모델

코드그룹 `OUT_STATUS`. 상세는 `project-standards.md` §2~§4.

```
00 (주문생성) → 10 (피킹중) → 20 (피킹완료) → 90 (출고확정)
```

| from | to | UI 액션 |
|------|-----|---------|
| 00 | 10 | 피킹시작 |
| 10 | 20 | 피킹완료 |
| 20 | 90 | 출고확정 |

## §3. 기능 요구사항

| ID | 요구 | 우선 |
|----|------|------|
| FR-F2-01 | 센터·상태로 출고 주문 목록 필터 조회 | Must |
| FR-F2-02 | 주문번호로 헤더·라인(품목명·주문수량·피킹수량) 조회 | Must |
| FR-F2-03 | 허용된 다음 상태로만 전이 | Must |
| FR-F2-04 | 비허용 전이 거부 + message | Must |
| FR-F2-05 | 화면에서 주문 신규 생성 없음 (시드 전제) | Must |
| FR-F2-06 | UX는 입고와 동일 패턴 (목록→상세→확인 후 전이) | Must |

## §4. 데이터·도메인

| 개념 | 예상 테이블 | 핵심 속성 |
|------|-------------|-----------|
| 출고 주문 | `outbound_order` | order_no(UX), center_info_id, status_code, ordered_at |
| 출고 라인 | `outbound_order_line` | outbound_order_id, line_no, item_info_id, order_qty, picked_qty |
| 이력·규칙 | `order_status_history`, `status_transition_rule` | order_kind=`OUTBOUND` |

센터·품목·공통코드는 F1과 공유. 수량 ≥ 0, picked_qty ≤ order_qty.

## §5. API 설계 초안

### §5.1 출고 주문 목록 조회

- **Method / Path**: `GET /api/outbound/orders`
- **Query**: `center_no` (N), `status_code` (N, OUT_STATUS)

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": [
    {
      "order_no": "OB-CTR01-001",
      "center_no": "CTR01",
      "center_name": "서울센터",
      "status_code": "10",
      "status_name": "피킹중",
      "ordered_at": "2026-05-14T10:00:00+09:00"
    }
  ]
}
```

- **에러 응답 예시** (HTTP 500)

```json
{
  "success": false,
  "message": "출고 주문 목록 조회 중 오류가 발생했습니다"
}
```

### §5.2 출고 주문 상세 조회

- **Method / Path**: `GET /api/outbound/orders/{orderNo}`

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": {
    "order_no": "OB-DONE",
    "center_no": "CTR01",
    "center_name": "서울센터",
    "status_code": "90",
    "status_name": "출고확정",
    "ordered_at": "2026-05-10T11:00:00+09:00",
    "lines": [
      {
        "line_no": 1,
        "sku_no": "SKU-BBB",
        "item_name": "상품B",
        "order_qty": 5,
        "picked_qty": 5
      }
    ]
  }
}
```

- **에러 응답 예시** (HTTP 404)

```json
{
  "success": false,
  "message": "출고 주문을 찾을 수 없습니다: OB-___NOTEXIST___"
}
```

### §5.3 출고 상태 전이

- **Method / Path**: `POST /api/outbound/orders/{orderNo}/transition`
- **Body**: `to_status`, `changed_by`, `change_reason` (F1과 동일 규격)

```json
{
  "to_status": "10",
  "changed_by": "demo-user",
  "change_reason": "피킹시작"
}
```

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": {
    "order_no": "OB-CTR01-001",
    "from_status": "00",
    "to_status": "10",
    "status_name": "피킹중"
  }
}
```

- **에러 응답 예시** (HTTP 400 — 예: 00→20 건너뛰기, 또는 90에서 재전이)

```json
{
  "success": false,
  "message": "허용되지 않은 상태 전이입니다: OUTBOUND 00 → 20"
}
```

### §5.시드 테스트 시드 전제

| 전제 | 내용 |
|------|------|
| 센터·품목 | F1과 동일 (`CTR01` 등, `SKU-*`) |
| 상태 00 주문 | `status_code=00` 목록 1건 이상 (동적 전이 테스트) |
| 확정 주문 | `OB-DONE` — status `90` (상세·거부 시나리오) |
| 전이 규칙 | OUTBOUND 00→10, 10→20, 20→90 |
| 공통코드 | `OUT_STATUS`, `ORDER_KIND` |

## §6. 비기능

F1과 동일: Map 응답, MyBatis XML, CORS-only Security, OpenAPI 문서화, 상태 변경 확인 UX.

## §7. 다음 산출물

| 산출물 | 담당 |
|--------|------|
| TASK-DB-F2-outbound | db-architect |
| TASK-UI-F2-outbound | ui-designer |
| TASK-BE-F2-outbound (+ TASK-BE-F4-common) | backend-developer |
| TASK-FE-F2-outbound | frontend-developer |
| TASK-TEST-BE-F2-outbound | test-backend |
| TASK-TEST-INT-all | test-integration |
