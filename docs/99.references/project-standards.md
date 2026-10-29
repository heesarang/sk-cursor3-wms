# WMS 프로젝트 표준 — 도메인·상태·전이

| 항목 | 내용 |
|------|------|
| 문서 ID | project-standards |
| 버전 | 1.2 |
| 기준 PRD | docs/01.analysis/01.rfp/wms_prd.md (F1~F4 only; F5~F7 제외) |
| DB 스키마 | `wms` (테이블 접두어 없음, 표준: `.cursor/rules/06-database.mdc`) |

---

## 1. 도메인 목록

| 도메인 ID | 영문 키 | 설명 | REQ |
|-----------|---------|------|-----|
| F1 | inbound | 입고 주문 조회·상태 진행 | REQ-F1-inbound.md |
| F2 | outbound | 출고 주문 조회·상태 진행 | REQ-F2-outbound.md |
| F3 | dashboard | 입출고 현황·이력 대시보드 | REQ-F3-dashboard.md |
| F4 | status-transition | 상태 전이 규칙·공통 전이 로직 | REQ-F4-status-transition.md |

**order_kind** (API·DB 공통): `INBOUND` | `OUTBOUND`

---

## 2. 상태 코드 (공통 코드)

### 2.1 입고 — `INB_STATUS` (`code_group.group_code`, 값은 `common_code.code_value`)

| code_value | code_name | 단계 |
|---------|---------|------|
| `00` | 주문생성 | 1 |
| `10` | 검수중 | 2 |
| `20` | 검수완료 | 3 |
| `90` | 입고확정 | 4 (종료) |

### 2.2 출고 — `OUT_STATUS` (`code_group.group_code`, 값은 `common_code.code_value`)

| code_value | code_name | 단계 |
|---------|---------|------|
| `00` | 주문생성 | 1 |
| `10` | 피킹중 | 2 |
| `20` | 피킹완료 | 3 |
| `90` | 출고확정 | 4 (종료) |

DB 컬럼명은 `status_code`, API 쿼리·응답 필드도 `status_code` (2자리 문자열). 화면 표시명은 `common_code.code_name` 조인 또는 서버 매핑.

**order_kind**는 코드그룹 `ORDER_KIND` (`INBOUND`, `OUTBOUND`).

---

## 3. 상태 전이 규칙

정의 테이블: `wms.status_transition_rule` (시드: `database/seeds/seed_transition_rule.sql`). 컬럼 `order_kind`, `from_status_code`, `to_status_code`, `is_active`.

### 3.1 입고 (`order_kind = INBOUND`)

```
00 (주문생성) → 10 (검수중) → 20 (검수완료) → 90 (입고확정)
```

| from | to | UI 액션 라벨 (권장) |
|------|-----|-------------------|
| 00 | 10 | 검수시작 |
| 10 | 20 | 검수완료 |
| 20 | 90 | 입고확정 |

### 3.2 출고 (`order_kind = OUTBOUND`)

```
00 (주문생성) → 10 (피킹중) → 20 (피킹완료) → 90 (출고확정)
```

| from | to | UI 액션 라벨 (권장) |
|------|-----|-------------------|
| 00 | 10 | 피킹시작 |
| 10 | 20 | 피킹완료 |
| 20 | 90 | 출고확정 |

### 3.3 금지 전이 예시

- 종료 상태(`90`)에서 다른 상태로 변경 불가 (예: 시드 `IB-INVALID-TRANS`, `OB-DONE`)
- 단계 건너뛰기 불가 (예: `00` → `20`)
- 역방향 불가 (예: `20` → `10`)

---

## 4. 상태 태그 색상 (UI / Element Plus)

프론트·UI 설계서에서 `el-tag` `type` 또는 Tailwind 클래스에 매핑한다.

### 4.1 입고 (`INB_STATUS`)

| status_code | 표시명 | el-tag type | 비고 |
|-----------|--------|-------------|------|
| 00 | 주문생성 | info | |
| 10 | 검수중 | warning | |
| 20 | 검수완료 | primary | |
| 90 | 입고확정 | success | 종료 |

### 4.2 출고 (`OUT_STATUS`)

| status_code | 표시명 | el-tag type | 비고 |
|-----------|--------|-------------|------|
| 00 | 주문생성 | info | |
| 10 | 피킹중 | warning | |
| 20 | 피킹완료 | primary | |
| 90 | 출고확정 | success | 종료 |

---

## 5. 상태 변경 요청 Body (전이 API 공통)

모든 `POST .../transition` 요청 Body 필드는 **snake_case** JSON.

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `to_status` | string | Y | 목표 상태 코드 (`00`/`10`/`20`/`90`) |
| `changed_by` | string | Y | 변경 수행자 (최대 50자) |
| `change_reason` | string | N | 변경 사유 (최대 500자) |

예시:

```json
{
  "to_status": "10",
  "changed_by": "demo-user",
  "change_reason": "검수시작"
}
```

서버는 `order_kind`·현재 `status_code`·`status_transition_rule`로 허용 여부를 검증한다. 성공 시 주문 헤더 갱신 + `order_status_history` INSERT는 **단일 트랜잭션**.

---

## 6. 마스터·식별자 (REQ §5.시드와 정합)

| 구분 | 코드 예시 | 설명 |
|------|-----------|------|
| 센터 | `CTR01`, `CTR02` | `center_info` |
| 상품 | `SKU-AAA`, `SKU-BBB`, `SKU-CCC` | `item_info` |
| 입고 주문번호 | `IB-CTR01-001`, `IB-CTR01-020`, `IB-INVALID-TRANS`(90) | `inbound_order.order_no` |
| 출고 주문번호 | `OB-CTR01-001`, `OB-DONE`(90) | `outbound_order.order_no` |

---

## 7. API 응답 래퍼

`docs/99.references/coding-standards.md` §4.2 준수.

- 성공: `{ "success": true, "data": ... }`
- 실패: `{ "success": false, "message": "..." }` (HTTP 4xx/5xx)

---

## 8. 패키지·빌드

| 항목 | 값 |
|------|-----|
| Gradle group | `com.execnt.wms` |
| Base package | `com.execnt.wms` |
| Spring Boot | 3.x, Java 21 |
| MyBatis | XML only (`backend/src/main/resources/mapper/`) |

---

## 9. API 경로 요약 (F1~F4)

정본은 각 REQ §5. 대시보드 쿼리의 `order_type`과 DB/규칙 API의 `order_kind`는 동일 값(`INBOUND`/`OUTBOUND`).

| 기능 | Method | Path |
|------|--------|------|
| F1 목록 | GET | `/api/inbound/orders` |
| F1 상세 | GET | `/api/inbound/orders/{orderNo}` |
| F1 전이 | POST | `/api/inbound/orders/{orderNo}/transition` |
| F2 목록 | GET | `/api/outbound/orders` |
| F2 상세 | GET | `/api/outbound/orders/{orderNo}` |
| F2 전이 | POST | `/api/outbound/orders/{orderNo}/transition` |
| F3 요약 | GET | `/api/dashboard/summary` |
| F3 최근 이력 | GET | `/api/dashboard/history/recent` |
| F3 주문 추적 | GET | `/api/dashboard/history/trace` |
| F4 규칙 조회 | GET | `/api/status-transitions/rules` |

인증/JWT 없음. CORS-only SecurityConfig (`backend-config.md`).

---

## 10. 서버 헬퍼

| 스크립트 | 용도 |
|----------|------|
| `scripts/start-backend.sh` / `.ps1` | Gradle `bootRun` 기동 (포트 8080) |
| `scripts/stop-backend.sh` / `.ps1` | 8080 리스너·래퍼 종료 |
| Health | `GET http://localhost:8080/v3/api-docs` → 200 |

작성·유지 책임: analyst가 PRD 분석 시 초안 생성, `TASK-BE-F4-common`에서 존재·동작을 확인하고 없으면 동일 스펙으로 작성한다. 이후 TEST-BE / TEST-INT가 재사용한다.
