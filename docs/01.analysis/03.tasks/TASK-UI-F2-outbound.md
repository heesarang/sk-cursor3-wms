---
task_id: TASK-UI-F2-outbound
agent: ui-designer
title: "출고 관리 화면 UI 설계"
---

# Task: 출고 관리 화면 UI 설계

## 선행 조건

- REQ-F2-outbound.md §3·§5
- UI-F1과 동일 UX 패턴 유지
- project-standards OUT_STATUS 태그 색상

## 목표

출고 목록·상세·피킹/확정 전이를 UI-F2-outbound.md로 설계한다.

## 상세 작업

1. 라우트 예: `#/outbound`
2. F1과 동일 레이아웃·컴포넌트 패턴
3. 액션: 피킹시작 / 피킹완료 / 출고확정
4. API: `/api/outbound/orders` 목록·상세·transition
5. 라인 컬럼에 picked_qty
6. 정상·에러 시나리오

## 산출물 경로

- `docs/01.analysis/04.ui/UI-F2-outbound.md`

## 완료 조건

- [ ] §3.3 구조 충족
- [ ] F1 UX 대칭 + 출고 상태/라벨
- [ ] REQ-F2 §5 매핑 완료

## 의존성

- 선행: REQ-F2-outbound (권장: UI-F1 초안 참고)
- 후행: TASK-FE-F2-outbound, TASK-TEST-INT-all
