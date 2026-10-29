---
task_id: TASK-TEST-INT-all
agent: test-integration
title: "F1~F4 화면·API 통합 테스트"
---

# Task: F1~F4 화면·API 통합 테스트

## 선행 조건

- UI 설계서: `docs/01.analysis/04.ui/UI-F1-inbound.md`, `UI-F2-outbound.md`, `UI-F3-dashboard.md`
- 프론트엔드 화면·백엔드 API 구현 완료
- REQ §5 최신본
- `scripts/start-backend.sh`|`.ps1`, `scripts/stop-backend.sh`|`.ps1`
- 프론트: Live Server 등 (CORS 허용 전제)

## 목표

UI 설계서의 화면·버튼·시나리오 기준으로 입출고·대시보드 E2E를 검증하고 통합 리포트를 작성한다.

## 상세 작업

1. `stop-backend` → `start-backend`
2. Health: `GET http://localhost:8080/v3/api-docs` 200 대기
3. 프론트 기동 후 UI 시나리오 검증:

### 입고 (UI-F1)

- 센터·상태 필터로 목록 조회
- 상세에서 품목·수량 확인
- 허용 전이(검수시작→검수완료→입고확정) 확인 다이얼로그 후 성공
- 종료 주문에서 비허용 전이 시 에러 메시지

### 출고 (UI-F2)

- F1과 동일 UX로 피킹시작→피킹완료→출고확정
- 건너뛰기/재전이 에러

### 대시보드 (UI-F3)

- 상태별 건수 요약 (센터 필터)
- 최근 이력 표시
- order_type+order_no로 이력 추적 (존재/없음)

4. `stop-backend`
5. 리포트: `docs/test-reports/REPORT-INT-{YYYYMMDD}.md` (document-standards §3.4)

## 산출물 경로

- `docs/test-reports/REPORT-INT-*.md`

## 완료 조건

- [ ] **서버 기동 → health check → 테스트 → 종료** 절차 준수
- [ ] **UI 설계서 기반 화면 기능 시나리오 검증** (UI-F1/F2/F3의 버튼·시나리오가 테스트 케이스 기준)
- [ ] 입고 `00→10→20→90`·출고 `00→10→20→90` 화면 전이 포함
- [ ] 통과/실패·재현 절차 기록
- [ ] F5~F7 범위 테스트하지 않음

## 의존성

- 선행: TASK-FE-F1/F2/F3, TASK-BE-F1/F2/F3/F4, UI-F1/F2/F3
- 권장: TASK-TEST-BE-* 통과 후 실행
