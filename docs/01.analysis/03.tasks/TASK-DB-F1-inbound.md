---
task_id: TASK-DB-F1-inbound
agent: db-architect
title: "입고·공통 마스터 DDL 및 시드"
---

# Task: 입고·공통 마스터 DDL 및 시드

## 선행 조건

- `docs/01.analysis/02.requirements/REQ-F1-inbound.md` §2·§4 확인
- `docs/99.references/project-standards.md` 상태·식별자 확인
- `.cursor/rules/06-database.mdc` 준수
- F5~F7(inventory-flow) 범위 제외

## 목표

`wms` 스키마에 공통 마스터·공통코드·입고 주문/라인·(공유) 이력·전이 규칙 골격과 입고 관련 시드를 정의한다. 기준 DDL은 `database/schemas/wms_ddl.sql` 단일 파일.

## 상세 작업

1. 개념 모델 확정 후 DDL 작성: `center_info`, `item_info`, `code_group`, `common_code`, `inbound_order`, `inbound_order_line`
2. 공유 객체(이 Task에서 초안 포함 가능, F4 Task와 중복 없이 최종 통합): `order_status_history`, `status_transition_rule` — F4 Task와 조율하여 한 DDL에 합본
3. PK/FK/UNIQUE/CHECK/인덱스·한글 COMMENT·공통 컬럼 4종
4. 시드: `seed_common_code.sql` (INB_STATUS, ORDER_KIND 등), `seed_master.sql` (CTR01/CTR02, SKU-*), 입고 샘플 주문(상태 분산, `IB-INVALID-TRANS`, `IB-CTR01-020` 등 — REQ §5.시드)
5. `std_check.sql` 위반 0 목표로 형식 점검
6. `docs/99.references/data-dictionary.md` 갱신 (입고·공통 부분)

## 산출물 경로

- `database/schemas/wms_ddl.sql` (공통+입고 부분; F2/F4와 합본)
- `database/seeds/seed_common_code.sql`
- `database/seeds/seed_master.sql`
- `database/seeds/seed_sample_order.sql` (입고 분; 출고와 동일 파일 가능)
- `docs/99.references/data-dictionary.md`

## 완료 조건

- [ ] DDL이 06-database 표준을 충족하고 std_check PASS 가능
- [ ] 입고 헤더/라인·센터·품목·공통코드가 REQ-F1 §4와 대응
- [ ] REQ §5.시드에 명시된 주문번호·센터·SKU가 시드에 존재
- [ ] data-dictionary.md에 테이블·컬럼 의미 기록
- [ ] F5~F7 재고 테이블을 추가하지 않음

## 의존성

- 선행: analyst 산출물 (REQ, project-standards)
- 후행: TASK-DB-F2-outbound, TASK-DB-F4-common (동일 DDL 합본), TASK-BE-F1-inbound
