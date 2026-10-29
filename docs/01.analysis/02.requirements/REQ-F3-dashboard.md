# 요구사항 정의서 — 상태 현황 대시보드

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-F3-dashboard |
| 버전 | 1.0 |
| 기준 PRD | docs/01.analysis/01.rfp/wms_prd.md — §4 F3 |

## §1. 추적성 (PRD 매핑)

| PRD 항목 | 본 문서 |
|----------|---------|
| F3 입고/출고 상태별 건수 요약 | §3 FR-F3-01, §5.1 |
| F3 최근 상태 변경 이력 | §3 FR-F3-02, §5.2 |
| F3 특정 주문 전체 이력 추적 | §3 FR-F3-03, §5.3 |
| §7.3 대표 조회 (요약·이력) | §4, §5 |

## §2. 상태 모델

대시보드는 자체 상태 전이가 없다. 집계·표시는 `INB_STATUS` / `OUT_STATUS` 및 `order_status_history`를 사용한다. 태그 색상은 `project-standards.md` §4.

## §3. 기능 요구사항

| ID | 요구 | 우선 |
|----|------|------|
| FR-F3-01 | 입고·출고 각각 상태코드별 주문 건수를 요약 표시 | Must |
| FR-F3-02 | 최근 상태 변경 이력을 시간 역순으로 조회 (limit) | Must |
| FR-F3-03 | order_type + order_no로 해당 주문 이력 전체(시간순) 추적 | Must |
| FR-F3-04 | 선택적으로 센터 필터로 요약 범위를 좁힌다 | Should |
| FR-F3-05 | 존재하지 않는 주문 trace는 404 | Must |

## §4. 데이터·도메인

| 조회 | 소스 |
|------|------|
| 상태별 건수 | `inbound_order` / `outbound_order` GROUP BY status_code (+ 선택 center) |
| 최근 이력 | `order_status_history` ORDER BY changed_at DESC LIMIT n |
| 주문 추적 | `order_status_history` WHERE order_kind(=order_type) AND order_no |

API 쿼리 파라미터명 **`order_type`** 은 화면·curl 계약용이며, DB 컬럼·도메인 키는 **`order_kind`** (`INBOUND` \| `OUTBOUND`). 값은 동일하다.

## §5. API 설계 초안

### §5.1 입출고 상태별 건수 요약

- **Method / Path**: `GET /api/dashboard/summary`
- **Query**: `center_no` (N)

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": {
    "inbound": [
      { "status_code": "00", "status_name": "주문생성", "order_count": 3 },
      { "status_code": "10", "status_name": "검수중", "order_count": 1 },
      { "status_code": "20", "status_name": "검수완료", "order_count": 1 },
      { "status_code": "90", "status_name": "입고확정", "order_count": 2 }
    ],
    "outbound": [
      { "status_code": "00", "status_name": "주문생성", "order_count": 2 },
      { "status_code": "10", "status_name": "피킹중", "order_count": 1 },
      { "status_code": "20", "status_name": "피킹완료", "order_count": 0 },
      { "status_code": "90", "status_name": "출고확정", "order_count": 1 }
    ]
  }
}
```

- **에러 응답 예시** (HTTP 500)

```json
{
  "success": false,
  "message": "대시보드 요약 조회 중 오류가 발생했습니다"
}
```

### §5.2 최근 상태 변경 이력

- **Method / Path**: `GET /api/dashboard/history/recent`
- **Query**: `limit` (N, 기본 20, 최대 100 권장)

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": [
    {
      "order_type": "INBOUND",
      "order_no": "IB-CTR01-001",
      "from_status_code": "00",
      "to_status_code": "10",
      "changed_by": "demo-user",
      "change_reason": "검수시작",
      "changed_at": "2026-05-14T12:00:00+09:00"
    }
  ]
}
```

- **에러 응답 예시** (HTTP 400 — limit 비정상)

```json
{
  "success": false,
  "message": "limit은 1 이상이어야 합니다"
}
```

### §5.3 주문별 상태 이력 추적

- **Method / Path**: `GET /api/dashboard/history/trace`
- **Query**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| order_type | string | Y | `INBOUND` 또는 `OUTBOUND` |
| order_no | string | Y | 업무 주문번호 |

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": {
    "order_type": "INBOUND",
    "order_no": "IB-CTR01-020",
    "histories": [
      {
        "from_status_code": "00",
        "to_status_code": "10",
        "changed_by": "seed",
        "change_reason": "검수시작",
        "changed_at": "2026-05-12T09:00:00+09:00"
      },
      {
        "from_status_code": "10",
        "to_status_code": "20",
        "changed_by": "seed",
        "change_reason": "검수완료",
        "changed_at": "2026-05-12T10:00:00+09:00"
      }
    ]
  }
}
```

- **에러 응답 예시** (HTTP 404 — 헤더 주문 없음)

```json
{
  "success": false,
  "message": "주문을 찾을 수 없습니다: INBOUND / IB-________NOPE"
}
```

- **에러 응답 예시** (HTTP 400 — 필수 파라미터 누락)

```json
{
  "success": false,
  "message": "order_type과 order_no는 필수입니다"
}
```

### §5.시드 테스트 시드 전제

| 전제 | 내용 |
|------|------|
| 요약 | CTR01 기준 입고·출고 각 상태 건수가 집계 가능하도록 샘플 주문 분산 |
| 최근 이력 | `order_status_history`에 복수 행 (seed 또는 전이 실행 결과) |
| Trace 존재 | `IB-CTR01-020` + order_type=INBOUND → 200 |
| Trace 없음 | 존재하지 않는 order_no → 404 |
| 센터 필터 | `center_no=CTR01` 요약 200 |

## §6. 비기능

- 읽기 전용 API (상태 변경 없음)
- 집계 쿼리는 MyBatis XML
- 화면은 카드/테이블로 한눈에 파악 (UI 설계서에서 상세)

## §7. 다음 산출물

| 산출물 | 담당 |
|--------|------|
| TASK-UI-F3-dashboard | ui-designer |
| TASK-BE-F3-dashboard | backend-developer |
| TASK-FE-F3-dashboard | frontend-developer |
| TASK-TEST-BE-F3-dashboard | test-backend |
| TASK-TEST-INT-all | test-integration |
