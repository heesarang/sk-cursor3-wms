# WMS 데이터 사전

| 항목 | 내용 |
|------|------|
| 문서 ID | data-dictionary |
| 버전 | 1.0 |
| 스키마 | `wms` (테이블 접두어 없음) |
| 기준 DDL | `database/schemas/wms_ddl.sql` |
| 개념 모델 | `database/docs/wms-model.md` |
| 범위 | F1~F4 (재고·로케이션·거래처·인증 제외) |
| 적용 DB 예 | `wms17` / `student17` / schema `wms` |

---

## 1. 테이블 목록

| # | 테이블 | 한글명 | 유형 | 시드 |
|---|--------|--------|------|------|
| 1 | `center_info` | 센터 기준정보 | 마스터 | `seed_master.sql` |
| 2 | `item_info` | 상품 기준정보 | 마스터 | `seed_master.sql` |
| 3 | `code_group` | 공통코드 그룹 | 마스터 | `seed_common_code.sql` |
| 4 | `common_code` | 공통코드 | 마스터 | `seed_common_code.sql` |
| 5 | `inbound_order` | 입고 주문 헤더 | 트랜잭션 | `seed_sample_order.sql` |
| 6 | `inbound_order_line` | 입고 주문 라인 | 트랜잭션 | `seed_sample_order.sql` |
| 7 | `outbound_order` | 출고 주문 헤더 | 트랜잭션 | `seed_sample_order.sql` |
| 8 | `outbound_order_line` | 출고 주문 라인 | 트랜잭션 | `seed_sample_order.sql` |
| 9 | `status_transition_rule` | 상태 전이 규칙 | 규칙 | `seed_transition_rule.sql` |
| 10 | `order_status_history` | 주문 상태 이력 | 이력 | `seed_sample_order.sql` |

모든 테이블 공통 컬럼(맨 뒤): `created_at`, `updated_at`, `created_by`, `updated_by`.

---

## 2. 테이블·컬럼 정의

### 2.1 `center_info` — 센터 기준정보

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `center_info_id` | BIGINT IDENTITY | N | PK 대리키 |
| `center_no` | VARCHAR(50) | N | 업무 식별자 UK (`center_info_ux1`). 예: CTR01 |
| `center_name` | VARCHAR(100) | N | 센터명 |
| `is_active` | BOOLEAN | N | 사용 여부 (DEFAULT TRUE) |
| `created_at` / `updated_at` | TIMESTAMPTZ | N | 등록·수정 일시 |
| `created_by` / `updated_by` | VARCHAR(50) | N | 등록·수정자 |

시드: `CTR01`(서울센터), `CTR02`(부산센터).

### 2.2 `item_info` — 상품 기준정보

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `item_info_id` | BIGINT IDENTITY | N | PK 대리키 |
| `sku_no` | VARCHAR(50) | N | SKU UK (`item_info_ux1`). 예: SKU-AAA |
| `item_name` | VARCHAR(200) | N | 품목명 |
| `is_active` | BOOLEAN | N | 사용 여부 |
| 공통 4종 | — | N | 위와 동일 |

시드: `SKU-AAA`, `SKU-BBB`, `SKU-CCC`.

### 2.3 `code_group` — 공통코드 그룹

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `code_group_id` | BIGINT IDENTITY | N | PK |
| `group_code` | VARCHAR(30) | N | 그룹 코드 UK. 예: INB_STATUS |
| `group_name` | VARCHAR(100) | N | 그룹명 |
| `is_active` | BOOLEAN | N | 사용 여부 |
| 공통 4종 | — | N | |

### 2.4 `common_code` — 공통코드

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `common_code_id` | BIGINT IDENTITY | N | PK |
| `code_group_id` | BIGINT | N | FK → `code_group` (`common_code_code_group_fk`) |
| `code_value` | VARCHAR(30) | N | 그룹 내 코드 값. UK with group (`common_code_ux1`) |
| `code_name` | VARCHAR(100) | N | 표시명 |
| `sort_order` | INT | N | 표시 순서 (DEFAULT 0) |
| `is_active` | BOOLEAN | N | 사용 여부 |
| 공통 4종 | — | N | |

### 2.5 `inbound_order` — 입고 주문 헤더

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `inbound_order_id` | BIGINT IDENTITY | N | PK |
| `order_no` | VARCHAR(50) | N | 입고 주문번호 UK. 예: IB-CTR01-001 |
| `center_info_id` | BIGINT | N | FK → `center_info` |
| `status_code` | VARCHAR(10) | N | 입고 상태 (코드그룹: INB_STATUS). 물리 FK 없음 |
| `ordered_at` | TIMESTAMPTZ | N | 주문 일시 |
| 공통 4종 | — | N | |

인덱스: `inbound_order_ix1` (`center_info_id`, `status_code`).

시드 핵심: `IB-CTR01-001`(00), `IB-CTR01-010`(10), `IB-CTR01-020`(20), `IB-INVALID-TRANS`(90), `IB-CTR02-001`(00).

### 2.6 `inbound_order_line` — 입고 주문 라인

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `inbound_order_line_id` | BIGINT IDENTITY | N | PK |
| `inbound_order_id` | BIGINT | N | FK → `inbound_order`. UK with `line_no` |
| `line_no` | INT | N | 라인 순번 |
| `item_info_id` | BIGINT | N | FK → `item_info` (주문 내 SKU 중복 허용) |
| `order_qty` | NUMERIC(12,0) | N | 주문 수량 ≥ 0 (`_ck1`) |
| `inspected_qty` | NUMERIC(12,0) | N | 검수 수량 ≥ 0, ≤ order_qty (`_ck2`,`_ck3`) |
| 공통 4종 | — | N | |

인덱스: `inbound_order_line_ix1` (`item_info_id`).

### 2.7 `outbound_order` — 출고 주문 헤더

입고와 대칭. `status_code`는 코드그룹 OUT_STATUS.  
시드 핵심: `OB-CTR01-001`(00), `OB-CTR01-010`(10), `OB-CTR01-020`(20), `OB-DONE`(90), `OB-CTR02-001`(00).

### 2.8 `outbound_order_line` — 출고 주문 라인

입고 라인과 대칭. `picked_qty` = 피킹 수량 (≥ 0, ≤ order_qty).

### 2.9 `status_transition_rule` — 상태 전이 규칙

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `status_transition_rule_id` | BIGINT IDENTITY | N | PK |
| `order_kind` | VARCHAR(20) | N | ORDER_KIND: INBOUND / OUTBOUND |
| `from_status_code` | VARCHAR(10) | N | 출발 상태 |
| `to_status_code` | VARCHAR(10) | N | 도착 상태 |
| `is_active` | BOOLEAN | N | 규칙 활성 |
| 공통 4종 | — | N | |

UK: (`order_kind`, `from_status_code`, `to_status_code`).

시드(활성 6건): INBOUND·OUTBOUND 각 `00→10`, `10→20`, `20→90`.

### 2.10 `order_status_history` — 주문 상태 이력 (공용)

| 컬럼 | 타입 | NULL | 설명 |
|------|------|------|------|
| `order_status_history_id` | BIGINT IDENTITY | N | PK |
| `order_kind` | VARCHAR(20) | N | INBOUND / OUTBOUND |
| `order_no` | VARCHAR(50) | N | 주문번호. **물리 FK 없음** (입·출고 중 하나를 가리키므로 단일 부모 FK 불가). 앱이 존재 주문에만 INSERT |
| `from_status_code` | VARCHAR(10) | N | 이전 상태 |
| `to_status_code` | VARCHAR(10) | N | 이후 상태 |
| `changed_by` | VARCHAR(50) | N | 변경 수행자 |
| `change_reason` | VARCHAR(500) | Y | 변경 사유 |
| `changed_at` | TIMESTAMPTZ | N | 변경 일시 |
| 공통 4종 | — | N | |

인덱스: `order_status_history_ix1` (`order_kind`, `order_no`, `changed_at`), `order_status_history_ix2` (`changed_at`).

시드: `IB-CTR01-020` 이력 2건(trace), `IB-INVALID-TRANS`·`OB-DONE` 완료 경로, 기타 최근 이력 포함(총 12건).

---

## 3. 공통코드 매핑

### 3.1 `INB_STATUS` — 입고 상태

| code_value | code_name | sort_order |
|------------|-----------|------------|
| 00 | 주문생성 | 1 |
| 10 | 검수중 | 2 |
| 20 | 검수완료 | 3 |
| 90 | 입고확정 | 4 |

### 3.2 `OUT_STATUS` — 출고 상태

| code_value | code_name | sort_order |
|------------|-----------|------------|
| 00 | 주문생성 | 1 |
| 10 | 피킹중 | 2 |
| 20 | 피킹완료 | 3 |
| 90 | 출고확정 | 4 |

### 3.3 `ORDER_KIND` — 주문 종류

| code_value | code_name | sort_order |
|------------|-----------|------------|
| INBOUND | 입고 | 1 |
| OUTBOUND | 출고 | 2 |

상태·구분값은 ENUM/CHECK IN으로 고정하지 않으며, 공통코드·전이 규칙 테이블로 관리한다.

---

## 4. 관계 요약

| 부모 | 자식 | 카디널리티 | FK |
|------|------|------------|-----|
| `center_info` | `inbound_order` | 1:N | `inbound_order_center_info_fk` |
| `center_info` | `outbound_order` | 1:N | `outbound_order_center_info_fk` |
| `inbound_order` | `inbound_order_line` | 1:N | `inbound_order_line_inbound_order_fk` |
| `outbound_order` | `outbound_order_line` | 1:N | `outbound_order_line_outbound_order_fk` |
| `item_info` | `inbound_order_line` | 1:N | `inbound_order_line_item_info_fk` |
| `item_info` | `outbound_order_line` | 1:N | `outbound_order_line_item_info_fk` |
| `code_group` | `common_code` | 1:N | `common_code_code_group_fk` |
| (논리) 주문 헤더 | `order_status_history` | 1:N | 없음 — `order_kind`+`order_no` |
| (논리) `status_transition_rule` | 주문 헤더 | — | 없음 — 전이 검증 시 조회 |

`ON DELETE CASCADE` 없음. FK 컬럼은 인덱스 선두(UNIQUE 또는 명시 인덱스).

---

## 5. 시드 파일·적용 순서

| 순서 | 파일 | 내용 |
|------|------|------|
| 1 | `database/seeds/seed_common_code.sql` | INB_STATUS, OUT_STATUS, ORDER_KIND |
| 2 | `database/seeds/seed_master.sql` | CTR01/CTR02, SKU-* |
| 3 | `database/seeds/seed_transition_rule.sql` | 입·출고 전이 각 3건 |
| 4 | `database/seeds/seed_sample_order.sql` | 샘플 주문·라인·이력 |

재실행: 업무 UK에 `ON CONFLICT DO UPDATE`, 이력은 `WHERE NOT EXISTS`. `created_by`/`updated_by` = `'seed'`.

---

## 6. 업무 규칙 (DB 보장 범위)

| 규칙 | 보장 |
|------|------|
| 센터·SKU·주문번호 중복 금지 | UNIQUE |
| 라인 순번 주문 내 유일 | UNIQUE(주문_id, line_no) |
| 수량 ≥ 0, 검수/피킹 ≤ 주문 | CHECK |
| 허용 전이만 가능 | App이 `status_transition_rule` 조회 (DB는 규칙 행 UX) |
| 전이+이력 동일 트랜잭션 | App |
| 마스터 물리 삭제 금지 | `is_active` + App/운영 |
