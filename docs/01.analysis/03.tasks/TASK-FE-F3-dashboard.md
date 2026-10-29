---
task_id: TASK-FE-F3-dashboard
agent: frontend-developer
title: "대시보드 Vue 화면 구현"
---

# Task: 대시보드 Vue 화면 구현

## 선행 조건

- UI-F3-dashboard.md
- REQ-F3-dashboard.md §5 (최신)
- 백엔드 대시보드 API 기동 가능

## 목표

상태별 건수·최근 이력·주문 추적 화면을 구현한다.

## 상세 작업

1. Dashboard view: 요약 카드/테이블, 최근 이력, trace 폼
2. api.dashboard.summary / historyRecent / historyTrace
3. 라우트 `#/dashboard` (기본 홈 가능)
4. 센터 필터·limit·order_type/order_no 입력
5. 404/400 메시지 표시

## 산출물 경로

- `frontend/views/` (대시보드)
- `frontend/js/api.js`
- `frontend/router.js`

## 완료 조건

- [ ] UI 설계 시나리오·REQ §5 반영
- [ ] 요약·최근·trace 동작
- [ ] 네비게이션에 대시보드 포함

## 의존성

- 선행: TASK-UI-F3-dashboard, TASK-BE-F3-dashboard
- 후행: TASK-TEST-INT-all
