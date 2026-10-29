---
task_id: TASK-TEST-BE-F3-dashboard
agent: test-backend
title: "대시보드 API 백엔드 테스트"
---

# Task: 대시보드 API 백엔드 테스트

## 선행 조건

- REQ-F3-dashboard.md §5 최신
- 시드 IB-CTR01-020 및 이력 데이터
- start/stop-backend

## 목표

요약·최근 이력·주문 추적 API를 검증한다.

## 상세 작업

1. stop → start → health
2. GET `/api/dashboard/summary`, `?center_no=CTR01` → 200
3. GET `/api/dashboard/history/recent`, `?limit=5` → 200
4. GET trace `order_type=INBOUND&order_no=IB-CTR01-020` → 200
5. 존재하지 않는 order_no → 404
6. order_no 누락 → 400
7. stop → 리포트

## 산출물 경로

- `docs/test-reports/REPORT-BE-*.md`

## 완료 조건

- [ ] **서버 기동 → health check → 테스트 → 종료** 절차 준수
- [ ] REQ-F3 §5 시나리오 기록

## 의존성

- 선행: TASK-BE-F3-dashboard
