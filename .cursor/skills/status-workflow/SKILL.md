---
name: status-workflow
description: "입고/출고 상태 전이 로직을 구현하거나 수정할 때 사용. 상태 전이 검증 → 상태 업데이트 → 이력 저장의 순서를 따른다."
paths: "backend/src/**/*.java"
---

<!--
[목적] 상태 전이 구현 워크플로우. 상태 관련 코드 작업 시 에이전트가 자동으로 참조.
[테스트] 상태 변경 로직을 구현하거나 수정 요청 시 이 스킬이 로드되는지 확인.
-->

# 상태 전이 구현 워크플로우

상태를 변경하는 코드를 작성할 때 반드시 아래 순서를 따른다.

## 단계

### 1. 검증
StatusTransitionService.validateTransition(orderKind, fromStatusCode, toStatusCode) 호출.
status_transition_rule 테이블에서 (order_kind, from_status_code, to_status_code, is_active = true) 행 존재 여부를 조회한다. 전이 표를 코드에 하드코딩하지 않는다.
존재하지 않으면 예외 발생.

### 2. 상태 업데이트
해당 주문 테이블(inbound_order 또는 outbound_order)의 status_code 컬럼을 toStatusCode로 UPDATE.

### 3. 이력 저장
order_status_history 테이블에 INSERT.
항목: order_kind, order_no, from_status_code, to_status_code, changed_by, change_reason, changed_at(now). order_no는 물리 FK가 없으므로 order_kind와 함께 식별한다.

### 4. 트랜잭션
위 2-3은 같은 @Transactional 내에서 처리.
하나라도 실패하면 전체 롤백.

## 참조 파일
- scripts/check-transition.sh — DB에서 특정 상태의 허용 전이 조회
