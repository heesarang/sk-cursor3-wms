---
task_id: TASK-DB-F2-outbound
agent: db-architect
title: "출고 주문 DDL 및 시드"
---

# Task: 출고 주문 DDL 및 시드

## 선행 조건

- REQ-F2-outbound.md §2·§4
- TASK-DB-F1-inbound와 동일 기준 DDL에 합본
- project-standards.md OUT_STATUS·식별자

## 목표

출고 주문·라인 테이블과 OUT_STATUS 코드·출고 샘플 시드를 추가한다.

## 상세 작업

1. DDL: `outbound_order`, `outbound_order_line` (입고와 대칭 구조, picked_qty)
2. 공통코드 OUT_STATUS 시드
3. 샘플: 상태 분산 주문, `OB-DONE`(90), status_code=00 1건 이상
4. OUTBOUND 전이 규칙은 TASK-DB-F4-common과 합본
5. data-dictionary.md 출고 섹션 갱신
6. F5~F7 범위 제외

## 산출물 경로

- `database/schemas/wms_ddl.sql` (출고 테이블 반영)
- `database/seeds/seed_common_code.sql` (OUT_STATUS)
- `database/seeds/seed_sample_order.sql` (출고 분)
- `docs/99.references/data-dictionary.md`

## 완료 조건

- [ ] outbound_order / outbound_order_line이 표준·REQ §4 충족
- [ ] REQ-F2 §5.시드 주문·상태가 시드에 존재
- [ ] 센터·품목 FK가 F1 마스터를 참조
- [ ] std_check PASS 가능

## 의존성

- 선행: TASK-DB-F1-inbound (마스터·공통)
- 병행/합본: TASK-DB-F4-common
- 후행: TASK-BE-F2-outbound
