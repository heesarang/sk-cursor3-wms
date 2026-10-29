---
task_id: TASK-TEST-BE-F2-outbound
agent: test-backend
title: "출고 API 백엔드 테스트"
---

# Task: 출고 API 백엔드 테스트

## 선행 조건

- REQ-F2-outbound.md §5 최신
- 시드에 OB-DONE, status_code=00 출고 주문
- start/stop-backend 헬퍼

## 목표

출고 목록·상세·전이·거부 시나리오를 검증한다.

## 상세 작업

1. stop → start → health (`/v3/api-docs`)
2. GET `/api/outbound/orders`, `?status_code=10`
3. GET `/api/outbound/orders/OB-DONE` → 200
4. 00 주문: 00→20 → 400; 00→10→20→90 → 200; 이후 재전이 → 400
5. stop → 리포트 기록

## 산출물 경로

- `docs/test-reports/REPORT-BE-*.md`

## 완료 조건

- [ ] **서버 기동 → health check → 테스트 → 종료** 절차 준수
- [ ] REQ-F2 §5 기준 결과 기록 — 정상 `00→10→20→90` 포함

## 의존성

- 선행: TASK-BE-F2-outbound
