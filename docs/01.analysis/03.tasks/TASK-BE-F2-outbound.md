---
task_id: TASK-BE-F2-outbound
agent: backend-developer
title: "출고 주문 조회·상태 전이 API"
---

# Task: 출고 주문 조회·상태 전이 API

## 선행 조건

- REQ-F2-outbound.md §5
- TASK-BE-F4-common 완료
- 출고 DDL·시드 적용

## 목표

출고 목록·상세·전이 API를 F1과 대칭으로 구현한다 (`order_kind=OUTBOUND`).

## 상세 작업

1. OutboundOrderController / Service / Mapper / XML
2. `GET /api/outbound/orders`, `GET /api/outbound/orders/{orderNo}`, `POST .../transition`
3. 라인 필드: order_qty, picked_qty
4. 전이: validateTransition + 트랜잭션 이력
5. OpenAPI 어노테이션

## 산출물 경로

- `backend/src/main/java/com/execnt/wms/controller/OutboundOrderController.java`
- `backend/src/main/java/com/execnt/wms/service/OutboundOrderService.java`
- `backend/src/main/java/com/execnt/wms/mapper/OutboundOrderMapper.java`
- `backend/src/main/resources/mapper/OutboundOrderMapper.xml`

## 완료 조건

- [ ] 빌드 성공
- [ ] **서버 기동 확인**: `scripts/start-backend` → 로그 Started → `scripts/stop-backend`로 종료
- [ ] REQ-F2 §5 충족 — 정상 전이 `00→10→20→90` (피킹시작→피킹완료→출고확정)
- [ ] 00→20·확정 재전이 거부
- [ ] **REQ §5 갱신**: 구현이 REQ-F2-outbound.md §5와 다르면 실제에 맞게 갱신

## 의존성

- 선행: TASK-DB-F2-outbound, TASK-BE-F4-common
- 후행: TASK-TEST-BE-F2-outbound, TASK-FE-F2-outbound
