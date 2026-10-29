---
task_id: TASK-UI-F1-inbound
agent: ui-designer
title: "입고 관리 화면 UI 설계"
---

# Task: 입고 관리 화면 UI 설계

## 선행 조건

- REQ-F1-inbound.md §3·§5
- project-standards.md §4 상태 태그 색상
- document-standards.md §3.3 UI 설계서 구조
- UI 설계서만 작성 (화면 코드·DDL 금지)

## 목표

입고 목록·상세·상태 전이 UX를 UI-F1-inbound.md로 설계한다.

## 상세 작업

1. 화면 개요·라우트 (예: `#/inbound`)
2. 레이아웃: 필터(센터·상태) + el-table 목록 + 상세 다이얼로그
3. 상태별 액션 버튼 (검수시작/검수완료/입고확정) — 현재 상태에서 허용된 것만
4. API 매핑: §5.1 목록, §5.2 상세, §5.3 transition
5. el-tag type: info/warning/primary/success (00/10/20/90)
6. 확인(ElMessageBox)·성공/에러 피드백
7. 정상·에러 사용자 시나리오 step-by-step

## 산출물 경로

- `docs/01.analysis/04.ui/UI-F1-inbound.md`

## 완료 조건

- [ ] document-standards §3.3 섹션 구조 충족
- [ ] REQ §5 API와 버튼/동작 1:1 매핑
- [ ] 상태 태그·전이 라벨이 project-standards와 일치
- [ ] 비허용 전이 에러 피드백 명시

## 의존성

- 선행: REQ-F1-inbound
- 후행: TASK-FE-F1-inbound, TASK-TEST-INT-all
