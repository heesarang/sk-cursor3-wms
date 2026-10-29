# 요구사항 정의서 — 입고 관리

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-F1-inbound |
| 버전 | 1.0 |
| 기준 PRD | docs/01.analysis/01.rfp/wms_prd.md — §4 F1 |

## §1. 추적성 (PRD 매핑)

| PRD 항목 | 본 문서 |
|----------|---------|
| F1 입고 주문 목록·센터/상태 필터 | §3 FR-F1-01, §5.1 |
| F1 주문 상세·품목별 수량 | §3 FR-F1-02, §5.2 |
| F1 검수시작→검수완료→입고확정 | §2, §3 FR-F1-03, §5.3 |
| F1 비허용 전이 거부·사유 표시 | §3 FR-F1-04, §5.3 |
| §6 도메인·§7 데이터 (입고·라인·센터·품목) | §4 |
| F4 전이 검증·이력 (입고 호출 시) | REQ-F4-status-transition.md, project-standards.md |

## §2. 상태 모델

코드그룹 `INB_STATUS`. 상세·전이·태그 색상은 `docs/99.references/project-standards.md` §2~§4.

```
00 (주문생성) → 10 (검수중) → 20 (검수완료) → 90 (입고확정)
```

| from | to | UI 액션 |
|------|-----|---------|
| 00 | 10 | 검수시작 |
| 10 | 20 | 검수완료 |
| 20 | 90 | 입고확정 |

종료(`90`)·건너뛰기·역방향은 거부. 검증은 `StatusTransitionService` + `status_transition_rule` (F4).

## §3. 기능 요구사항

| ID | 요구 | 우선 |
|----|------|------|
| FR-F1-01 | 센터번호·상태코드로 입고 주문 목록을 필터 조회한다 | Must |
| FR-F1-02 | 주문번호로 헤더·라인(품목명·주문수량·검수확정수량)을 조회한다 | Must |
| FR-F1-03 | 상세에서 허용된 다음 상태로만 전이한다 (Body: to_status, changed_by, change_reason) | Must |
| FR-F1-04 | 비허용 전이는 HTTP 4xx + `{ success:false, message }` | Must |
| FR-F1-05 | 화면에서 주문을 신규 생성하지 않는다 (시드·외부 수신 전제) | Must |
| FR-F1-06 | 상태 변경 전 확인 다이얼로그, 성공/실패 피드백 | Should |

## §4. 데이터·도메인

테이블명·컬럼은 `.cursor/rules/06-database.mdc` 및 db-architect DDL이 정본. 개념 모델:

| 개념 | 예상 테이블 | 핵심 속성 |
|------|-------------|-----------|
| 센터 | `center_info` | center_no(UX), center_name, is_active |
| 품목 | `item_info` | sku_no(UX), item_name, is_active |
| 입고 주문 | `inbound_order` | order_no(UX), center_info_id, status_code, ordered_at |
| 입고 라인 | `inbound_order_line` | inbound_order_id, line_no(UX with order), item_info_id, order_qty, inspected_qty |
| 상태 이력 | `order_status_history` | order_kind, order_no, from/to_status_code, changed_by, change_reason, changed_at |
| 전이 규칙 | `status_transition_rule` | order_kind=INBOUND, from/to, is_active |
| 공통코드 | `code_group` / `common_code` | INB_STATUS, ORDER_KIND |

업무 규칙: 수량 ≥ 0, inspected_qty ≤ order_qty. 주문·센터·SKU 업무번호와 대리키 분리. 마스터는 is_active로 관리(삭제 없음).

## §5. API 설계 초안

공통 응답: 성공 `{ "success": true, "data": ... }` / 실패 `{ "success": false, "message": "..." }`.  
필드명 snake_case. Base package `com.execnt.wms`. 인증 없음.

### §5.1 입고 주문 목록 조회

- **Method / Path**: `GET /api/inbound/orders`
- **Query**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| center_no | string | N | 센터 번호 (예: CTR01) |
| status_code | string | N | INB_STATUS 값 (00/10/20/90) |

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": [
    {
      "order_no": "IB-CTR01-001",
      "center_no": "CTR01",
      "center_name": "서울센터",
      "status_code": "00",
      "status_name": "주문생성",
      "ordered_at": "2026-05-14T09:00:00+09:00"
    }
  ]
}
```

- **에러 응답 예시** (HTTP 500)

```json
{
  "success": false,
  "message": "입고 주문 목록 조회 중 오류가 발생했습니다"
}
```

### §5.2 입고 주문 상세 조회

- **Method / Path**: `GET /api/inbound/orders/{orderNo}`
- **Path**: `orderNo` — 업무 주문번호 (예: IB-INVALID-TRANS)
- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": {
    "order_no": "IB-CTR01-001",
    "center_no": "CTR01",
    "center_name": "서울센터",
    "status_code": "00",
    "status_name": "주문생성",
    "ordered_at": "2026-05-14T09:00:00+09:00",
    "lines": [
      {
        "line_no": 1,
        "sku_no": "SKU-AAA",
        "item_name": "상품A",
        "order_qty": 10,
        "inspected_qty": 0
      }
    ]
  }
}
```

- **에러 응답 예시** (HTTP 404 — 주문 없음)

```json
{
  "success": false,
  "message": "입고 주문을 찾을 수 없습니다: IB-___NOTEXIST___"
}
```

### §5.3 입고 상태 전이

- **Method / Path**: `POST /api/inbound/orders/{orderNo}/transition`
- **Body** (`project-standards.md` §5)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| to_status | string | Y | 목표 상태 코드 |
| changed_by | string | Y | 변경자 (≤50) |
| change_reason | string | N | 사유 (≤500) |

```json
{
  "to_status": "10",
  "changed_by": "demo-user",
  "change_reason": "검수시작"
}
```

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": {
    "order_no": "IB-CTR01-001",
    "from_status": "00",
    "to_status": "10",
    "status_name": "검수중"
  }
}
```

- **에러 응답 예시** (HTTP 400 — 비허용 전이, 예: 00→20 또는 확정 후 재전이)

```json
{
  "success": false,
  "message": "허용되지 않은 상태 전이입니다: INBOUND 00 → 20"
}
```

동일 트랜잭션에서 `inbound_order.status_code` UPDATE + `order_status_history` INSERT. 검증은 F4 `StatusTransitionService`.

### §5.시드 테스트 시드 전제

| 전제 | 내용 |
|------|------|
| 센터 | `CTR01`, `CTR02` (`center_info`) |
| 품목 | `SKU-AAA`, `SKU-BBB`, `SKU-CCC` |
| 상태 00 주문 | 목록 `status_code=00`에 1건 이상 (정상 전이 스모크용, 동적 선택) |
| 확정 주문 | `IB-INVALID-TRANS` — status `90` (90→10 거부 검증) |
| 이력 추적용 | `IB-CTR01-020` — 대시보드 trace와 공유 가능 |
| 전이 규칙 | INBOUND 00→10, 10→20, 20→90 (`is_active=true`) |
| 공통코드 | `INB_STATUS`, `ORDER_KIND` |

시드 경로(예정): `database/seeds/seed_common_code.sql`, `seed_master.sql`, `seed_transition_rule.sql`, `seed_sample_order.sql`.

## §6. 비기능

- API 응답 Map 중심, SQL은 MyBatis XML만
- CORS 전용 Security (JWT 없음)
- 상태 변경 확인·피드백 (사용성)
- OpenAPI: Controller `@Tag`/`@Operation`, Swagger UI `/swagger-ui.html`

## §7. 다음 산출물

| 산출물 | 담당 |
|--------|------|
| TASK-DB-F1-inbound, TASK-DB-F4-common | db-architect |
| TASK-UI-F1-inbound → UI-F1-inbound.md | ui-designer |
| TASK-BE-F1-inbound (+ F4 common 선행) | backend-developer |
| TASK-FE-F1-inbound | frontend-developer |
| TASK-TEST-BE-F1-inbound | test-backend |
| TASK-TEST-INT-all | test-integration |
