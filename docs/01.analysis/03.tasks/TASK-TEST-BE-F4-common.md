---
task_id: TASK-TEST-BE-F4-common
agent: test-backend
title: "상태 전이 규칙·공통 검증 테스트"
---

# Task: 상태 전이 규칙·공통 검증 테스트

## 선행 조건

- REQ-F4-status-transition.md §5
- StatusTransitionService 및 규칙 API 구현
- F1/F2 전이 API로 거부·트랜잭션 간접 검증 가능

## 목표

규칙 조회 API와 비허용 전이 메시지·이력 기록을 검증한다.

## 상세 작업

1. stop → start → health
2. GET `/api/status-transitions/rules?order_kind=INBOUND` → 200, 3건 이상
3. GET `...?order_kind=OUTBOUND` → 200
4. (연동) 입고/출고 비허용 전이 400 message에 order_kind·from·to 포함 여부 확인
5. 허용 전이 후 dashboard/history 또는 DB로 이력 증가 확인 (가능 시)
6. stop → 리포트

## 산출물 경로

- `docs/test-reports/REPORT-BE-*.md`

## 완료 조건

- [ ] **서버 기동 → health check → 테스트 → 종료** 절차 준수
- [ ] REQ-F4 §5.1 및 거부 메시지 기준 충족 기록 (입·출고 비허용 전이 포함)

## 의존성

- 선행: TASK-BE-F4-common (권장: F1/F2 BE도 완료)
