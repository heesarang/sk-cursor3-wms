---
task_id: TASK-DB-F4-common
agent: db-architect
title: "상태 전이 규칙·이력 DDL 및 시드"
---

# Task: 상태 전이 규칙·이력 DDL 및 시드

## 선행 조건

- REQ-F4-status-transition.md §2·§4
- project-standards.md §3 전이표
- F1/F2 DDL과 동일 `wms_ddl.sql`에 합본

## 목표

`status_transition_rule`, `order_status_history`를 설계하고 INBOUND/OUTBOUND 활성 전이 시드와 샘플 이력을 넣는다.

## 상세 작업

1. DDL: status_transition_rule — (order_kind, from_status_code, to_status_code) UNIQUE, is_active
2. DDL: order_status_history — order_kind, order_no(물리 FK 없음, COMMENT에 이유), from/to, changed_by, change_reason, changed_at + 공통 컬럼
3. 시드 `seed_transition_rule.sql`: INBOUND 00→10→20→90, OUTBOUND 동일 패턴, is_active=true
4. 샘플 이력: IB-CTR01-020 등 trace 가능한 행
5. data-dictionary에 이력 참조 방식·이유 기록
6. 재고 관련 테이블 추가 금지

## 산출물 경로

- `database/schemas/wms_ddl.sql`
- `database/seeds/seed_transition_rule.sql`
- `database/seeds/seed_sample_order.sql` (이력 분 포함 가능)
- `docs/99.references/data-dictionary.md`

## 완료 조건

- [ ] 전이 규칙 6건(입·출 각 3) 이상 활성 시드
- [ ] 이력 테이블이 입·출고 공용이며 FK 부재 이유가 COMMENT에 있음
- [ ] REQ-F4 §5.시드 전제 충족
- [ ] std_check PASS 가능

## 의존성

- 선행/병행: TASK-DB-F1-inbound, TASK-DB-F2-outbound
- 후행: TASK-BE-F4-common
