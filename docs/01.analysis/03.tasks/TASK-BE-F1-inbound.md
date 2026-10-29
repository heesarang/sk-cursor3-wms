---
task_id: TASK-BE-F1-inbound
agent: backend-developer
title: "입고 주문 조회·상태 전이 API"
---

# Task: 입고 주문 조회·상태 전이 API

## 선행 조건

- REQ-F1-inbound.md §5 전체
- DDL·시드 적용 완료
- TASK-BE-F4-common의 StatusTransitionService 사용 가능
- MyBatis XML only, Controller에 비즈니스 로직 금지

## 목표

입고 목록·상세·전이 API를 REQ §5대로 구현한다. 전이 시 검증→UPDATE→이력 INSERT를 단일 트랜잭션으로 처리한다.

## 상세 작업

1. InboundOrderController / Service / Mapper / Mapper.xml
2. `GET /api/inbound/orders` — Query: center_no, status_code
3. `GET /api/inbound/orders/{orderNo}` — 헤더+라인(품목명, order_qty, inspected_qty); 없으면 404
4. `POST .../transition` — Body snake_case; validateTransition(INBOUND); @Transactional
5. OpenAPI `@Tag`/`@Operation`
6. 응답 Map 래퍼 준수

## 산출물 경로

- `backend/src/main/java/com/execnt/wms/controller/InboundOrderController.java`
- `backend/src/main/java/com/execnt/wms/service/InboundOrderService.java`
- `backend/src/main/java/com/execnt/wms/mapper/InboundOrderMapper.java`
- `backend/src/main/resources/mapper/InboundOrderMapper.xml`

## 완료 조건

- [ ] 빌드 성공
- [ ] **서버 기동 확인**: `scripts/start-backend` → 로그 Started → `scripts/stop-backend`로 종료
- [ ] §5.1~§5.3 경로·응답 형태 충족 (curl로 스모크 가능) — 정상 전이 `00→10→20→90`
- [ ] 비허용 전이 400 + message
- [ ] **REQ §5 갱신**: 구현이 REQ-F1-inbound.md §5와 다르면 실제에 맞게 갱신

## 의존성

- 선행: TASK-DB-F1-inbound, TASK-BE-F4-common
- 후행: TASK-TEST-BE-F1-inbound, TASK-FE-F1-inbound
