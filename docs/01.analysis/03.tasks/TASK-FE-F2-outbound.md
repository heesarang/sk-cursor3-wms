---
task_id: TASK-FE-F2-outbound
agent: frontend-developer
title: "출고 관리 Vue 화면 구현"
---

# Task: 출고 관리 Vue 화면 구현

## 선행 조건

- UI-F2-outbound.md
- REQ-F2-outbound.md §5 (최신)
- 입고 FE와 동일 패턴

## 목표

출고 목록·상세·피킹/확정 전이 화면을 구현한다.

## 상세 작업

1. OutboundList / OutboundDetail
2. api.outbound.list / detail / transition
3. 라우트 `#/outbound`
4. 액션 라벨·상태 태그 OUT_STATUS
5. F1과 공유 레이아웃/네비게이션이 있으면 메뉴에 출고 추가

## 산출물 경로

- `frontend/views/` (출고)
- `frontend/components/` (출고 상세)
- `frontend/js/api.js`
- `frontend/router.js`

## 완료 조건

- [ ] UI 설계서·REQ §5 반영
- [ ] 입고와 UX 대칭
- [ ] 전이 확인·에러 피드백

## 의존성

- 선행: TASK-UI-F2-outbound, TASK-BE-F2-outbound
- 후행: TASK-TEST-INT-all
