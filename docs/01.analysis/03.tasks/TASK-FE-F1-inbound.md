---
task_id: TASK-FE-F1-inbound
agent: frontend-developer
title: "입고 관리 Vue 화면 구현"
---

# Task: 입고 관리 Vue 화면 구현

## 선행 조건

- `docs/01.analysis/04.ui/UI-F1-inbound.md` 완료
- REQ-F1-inbound.md §5 (백엔드 구현·갱신본 우선)
- coding-standards.md §5 Vue CDN SPA 구조
- API_BASE가 백엔드 포트와 일치

## 목표

입고 목록·상세·상태 전이 화면을 Vue 3 CDN SPA로 구현한다.

## 상세 작업

1. `frontend/` 골격(없으면): index.html, app.js, router.js, js/api.js, js/common.js
2. views: InboundList — 필터·테이블·상태 태그
3. components: InboundDetail — 라인·상태별 전이 버튼·confirm
4. api.inbound.list / detail / transition
5. 라우트 `#/inbound`
6. ElMessage / ElMessageBox 피드백

## 산출물 경로

- `frontend/views/` (입고 목록)
- `frontend/components/` (입고 상세)
- `frontend/js/api.js` (inbound 섹션)
- `frontend/router.js` (라우트 등록)

## 완료 조건

- [ ] UI 설계서 컬럼·필터·액션 반영
- [ ] REQ §5 API 연동
- [ ] 상태 태그 색상 project-standards 준수
- [ ] Live Server 등으로 목록·전이 확인 가능

## 의존성

- 선행: TASK-UI-F1-inbound, TASK-BE-F1-inbound
- 후행: TASK-TEST-INT-all
