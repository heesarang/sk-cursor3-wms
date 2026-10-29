---
task_id: TASK-BE-F3-dashboard
agent: backend-developer
title: "대시보드 요약·이력 API"
---

# Task: 대시보드 요약·이력 API

## 선행 조건

- REQ-F3-dashboard.md §5
- 입출고 테이블·order_status_history 시드 존재
- coding-standards 응답 포맷

## 목표

상태별 건수 요약, 최근 이력, 주문별 이력 추적 API를 구현한다.

## 상세 작업

1. DashboardController / Service / Mapper / XML
2. `GET /api/dashboard/summary?center_no=`
3. `GET /api/dashboard/history/recent?limit=`
4. `GET /api/dashboard/history/trace?order_type=&order_no=` — 필수 누락 400, 주문 없음 404
5. 응답 필드 snake_case; 이력의 order_type은 order_kind 매핑

## 산출물 경로

- `backend/src/main/java/com/execnt/wms/controller/DashboardController.java`
- `backend/src/main/java/com/execnt/wms/service/DashboardService.java`
- `backend/src/main/java/com/execnt/wms/mapper/DashboardMapper.java`
- `backend/src/main/resources/mapper/DashboardMapper.xml`

## 완료 조건

- [ ] 빌드 성공
- [ ] **서버 기동 확인**: `scripts/start-backend` → 로그 Started → `scripts/stop-backend`로 종료
- [ ] REQ-F3 §5.1~§5.3 충족
- [ ] IB-CTR01-020 trace 200 (시드 전제)
- [ ] **REQ §5 갱신**: 구현이 REQ-F3-dashboard.md §5와 다르면 실제에 맞게 갱신

## 의존성

- 선행: TASK-DB-F1/F2/F4 (데이터), 입출고 BE와 병행 가능
- 후행: TASK-TEST-BE-F3-dashboard, TASK-FE-F3-dashboard
