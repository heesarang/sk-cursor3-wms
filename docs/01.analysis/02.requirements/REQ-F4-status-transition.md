# 요구사항 정의서 — 상태 전이 규칙

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-F4-status-transition |
| 버전 | 1.0 |
| 기준 PRD | docs/01.analysis/01.rfp/wms_prd.md — §4 F4 |

## §1. 추적성 (PRD 매핑)

| PRD 항목 | 본 문서 |
|----------|---------|
| F4 허용된 전이만 가능 | §3 FR-F4-01, §5 |
| F4 비허용 시 명확한 에러 | §3 FR-F4-02 |
| F4 이력 자동 기록 | §3 FR-F4-03 |
| F4 상태 변경+이력 동일 트랜잭션 | §3 FR-F4-04 |
| §6·§7 전이 규칙·이력·공통코드 | §2, §4 |
| 입고/출고 전이 API 호출 | REQ-F1 §5.3, REQ-F2 §5.3 |

## §2. 상태 모델

`project-standards.md` §2~§3이 정본.

| order_kind | 흐름 |
|------------|------|
| INBOUND | 00→10→20→90 |
| OUTBOUND | 00→10→20→90 |

금지: 종료 재전이, 단계 건너뛰기, 역방향. 규칙은 DB `status_transition_rule`에만 두고 코드에 하드코딩하지 않는다 (`.cursor/skills/status-workflow`).

## §3. 기능 요구사항

| ID | 요구 | 우선 |
|----|------|------|
| FR-F4-01 | `(order_kind, from, to, is_active=true)` 규칙 존재 시에만 전이 허용 | Must |
| FR-F4-02 | 거부 시 message에 order_kind·from·to를 포함 | Must |
| FR-F4-03 | 성공 시 `order_status_history` INSERT (changed_by, change_reason, changed_at) | Must |
| FR-F4-04 | 헤더 UPDATE와 이력 INSERT는 `@Transactional` 동일 트랜잭션 | Must |
| FR-F4-05 | 공통 `StatusTransitionService.validateTransition` 제공, 입출고 Service가 호출 | Must |
| FR-F4-06 | (선택) 활성 전이 규칙 조회 API — 디버그·테스트·UI 버튼 구성용 | Should |

## §4. 데이터·도메인

| 테이블 | 역할 |
|--------|------|
| `status_transition_rule` | order_kind, from_status_code, to_status_code, is_active (+ UX) |
| `order_status_history` | order_kind, order_no(물리 FK 없음 — 입출고 공용 참조), from/to, changed_by, change_reason, changed_at |
| `common_code` | INB_STATUS, OUT_STATUS, ORDER_KIND |

이력의 `order_no`는 입고·출고를 모두 가리키므로 물리 FK를 두지 않고 `order_kind`+`order_no`로 식별한다 (DB 설계 시 COMMENT에 이유 명시).

## §5. API 설계 초안

전이 실행 API는 도메인별로 F1/F2에 둔다. F4는 공통 서비스 + (선택) 규칙 조회.

### §5.1 활성 상태 전이 규칙 조회 (선택·권장)

- **Method / Path**: `GET /api/status-transitions/rules`
- **Query**: `order_kind` (Y) — `INBOUND` \| `OUTBOUND`

- **성공 응답 예시** (HTTP 200)

```json
{
  "success": true,
  "data": [
    {
      "order_kind": "INBOUND",
      "from_status_code": "00",
      "to_status_code": "10",
      "is_active": true
    },
    {
      "order_kind": "INBOUND",
      "from_status_code": "10",
      "to_status_code": "20",
      "is_active": true
    },
    {
      "order_kind": "INBOUND",
      "from_status_code": "20",
      "to_status_code": "90",
      "is_active": true
    }
  ]
}
```

- **에러 응답 예시** (HTTP 400 — order_kind 누락·잘못된 값)

```json
{
  "success": false,
  "message": "order_kind는 INBOUND 또는 OUTBOUND 이어야 합니다"
}
```

### §5.2 전이 실행 (도메인 API — 계약 참조)

| order_kind | Method / Path |
|------------|---------------|
| INBOUND | `POST /api/inbound/orders/{orderNo}/transition` → REQ-F1 §5.3 |
| OUTBOUND | `POST /api/outbound/orders/{orderNo}/transition` → REQ-F2 §5.3 |

서버 처리 순서 (`status-workflow` 스킬):

1. 현재 status_code 조회
2. `validateTransition(orderKind, from, to)`
3. 헤더 status UPDATE
4. history INSERT  
2~4 실패 시 전체 롤백.

### §5.시드 테스트 시드 전제

| 전제 | 내용 |
|------|------|
| 규칙 시드 | INBOUND·OUTBOUND 각 3건 활성 전이 |
| 거부 케이스 | `IB-INVALID-TRANS`(90), 동적 00 주문의 00→20 |
| 이력 | 전이 성공 후 해당 order_no 이력 1행 이상 증가 |
| 규칙 API | `GET .../rules?order_kind=INBOUND` 및 `OUTBOUND` → 200 |

시드 파일: `database/seeds/seed_transition_rule.sql` (+ 공통코드·샘플 주문).

## §6. 비기능

- 전이 표를 Java enum/하드코딩 금지 — DB 규칙 조회
- 트랜잭션 경계 명확화
- InvalidTransitionException + GlobalExceptionHandler → 통일된 에러 JSON

## §7. 다음 산출물

| 산출물 | 담당 |
|--------|------|
| TASK-DB-F4-common | db-architect |
| TASK-BE-F4-common | backend-developer (F1/F2보다 선행 또는 동시) |
| TASK-TEST-BE-F4-common | test-backend (규칙 API·거부 메시지) |
| F1/F2 전이 통합 검증 | TASK-TEST-BE-F1/F2, TASK-TEST-INT-all |
