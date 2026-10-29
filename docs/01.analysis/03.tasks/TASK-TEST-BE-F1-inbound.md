---
task_id: TASK-TEST-BE-F1-inbound
agent: test-backend
title: "입고 API 백엔드 테스트"
---

# Task: 입고 API 백엔드 테스트

## 선행 조건

- REQ-F1-inbound.md §5 (backend가 갱신한 최신본)
- DDL·시드 적용, 백엔드 빌드 가능
- `scripts/start-backend.sh`|`.ps1`, `scripts/stop-backend.sh`|`.ps1`
- (선택) `scripts/run-be-api-tests.sh`의 inbound 케이스 재사용

## 목표

입고 목록·상세·전이·거부 시나리오를 REQ §5 기준으로 검증하고 리포트를 남긴다.

## 상세 작업

1. `stop-backend` → `start-backend`
2. Health: `GET http://localhost:8080/v3/api-docs` 200 대기 (최대 ~120s)
3. 테스트 (curl 등):
   - GET `/api/inbound/orders` (전체·center_no·status_code)
   - GET `/api/inbound/orders/IB-INVALID-TRANS` → 200
   - GET 존재하지 않는 주문 → 404
   - status_code=00 주문 선택 후 00→20 → 400
   - 동일 주문 00→10→20→90 → 각 200
   - IB-INVALID-TRANS 90→10 → 400
4. `stop-backend`
5. 리포트: `docs/test-reports/REPORT-BE-{YYYYMMDD}.md` (또는 F1 섹션 포함)

## 산출물 경로

- `docs/test-reports/REPORT-BE-*.md`

## 완료 조건

- [ ] **서버 기동 → health check → 테스트 → 종료** 절차 준수
- [ ] REQ-F1 §5 시나리오 결과 기록 (통과/실패) — 정상 `00→10→20→90` 포함
- [ ] 실패 시 재현 명령 포함

## 의존성

- 선행: TASK-BE-F1-inbound
- 병행 가능: 다른 TEST-BE (동일 서버 스크립트 충돌 주의 — 순차 권장)
