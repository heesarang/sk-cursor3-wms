---
task_id: TASK-UI-F3-dashboard
agent: ui-designer
title: "상태 현황 대시보드 UI 설계"
---

# Task: 상태 현황 대시보드 UI 설계

## 선행 조건

- REQ-F3-dashboard.md §3·§5
- project-standards 상태 표시명·색상
- document-standards §3.3

## 목표

입출고 요약·최근 이력·주문 추적 UI를 UI-F3-dashboard.md로 설계한다.

## 상세 작업

1. 라우트 예: `#/dashboard`
2. 요약 영역: inbound/outbound 상태별 건수 (센터 필터 선택)
3. 최근 이력 테이블 + limit
4. 주문 추적: order_type + order_no 입력 → 이력 타임라인/테이블
5. API 매핑 §5.1~§5.3
6. 404/400 피드백
7. 사용자 시나리오 (요약 확인 → 최근 이력 → 특정 주문 추적)

## 산출물 경로

- `docs/01.analysis/04.ui/UI-F3-dashboard.md`

## 완료 조건

- [ ] §3.3 구조 충족
- [ ] REQ-F3 API 전부 매핑
- [ ] 통합 테스트가 따를 수 있는 step-by-step 시나리오 포함

## 의존성

- 선행: REQ-F3-dashboard
- 후행: TASK-FE-F3-dashboard, TASK-TEST-INT-all
