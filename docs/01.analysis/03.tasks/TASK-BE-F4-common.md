---
task_id: TASK-BE-F4-common
agent: backend-developer
title: "공통 상태 전이 서비스 및 규칙 API"
---

# Task: 공통 상태 전이 서비스 및 규칙 API

## 선행 조건

- REQ-F4-status-transition.md §5
- DDL·시드 적용 (status_transition_rule, order_status_history)
- coding-standards.md, backend-config.md, status-workflow 스킬
- `scripts/start-backend.sh` / `stop-backend.sh` (또는 .ps1) 사용

## 목표

입출고가 공유하는 `StatusTransitionService`·규칙 조회 API·예외 처리를 구현한다. CORS SecurityConfig·GlobalExceptionHandler 기반을 마련한다.

## 상세 작업

1. **서버 기동/종료 헬퍼** (없으면 작성, 있으면 동작 검증): `scripts/start-backend.sh`, `scripts/stop-backend.sh` 및 Windows용 `scripts/start-backend.ps1`, `scripts/stop-backend.ps1`
   - 포트 8080에서 `./gradlew bootRun` (또는 `gradlew.bat bootRun`) 기동
   - Health 대기 기준: `GET http://localhost:8080/v3/api-docs` → 200
   - stop은 8080 리스너·Gradle 래퍼 PID 종료
2. 패키지 `com.execnt.wms`: config(SecurityConfig CORS-only — JWT/로그인 없음), exception(InvalidTransitionException, GlobalExceptionHandler)
3. `StatusTransitionMapper` + XML: 활성 규칙 존재 여부, 규칙 목록
4. `StatusTransitionService.validateTransition(orderKind, from, to)` — 하드코딩 금지
5. (권장) history insert를 공통 메서드/매퍼로 제공하거나 입출고 Service가 동일 패턴으로 INSERT
6. Controller: `GET /api/status-transitions/rules?order_kind=` — REQ-F4 §5.1, `@Tag`/`@Operation`
7. application.yml은 기존 파일 사용 (없으면 `application.yml.example`·backend-config.md 기준으로 복사; **기존 파일 덮어쓰기 금지**)

## 산출물 경로

- `scripts/start-backend.sh`, `scripts/stop-backend.sh` (+ `.ps1`)
- `backend/src/main/java/com/execnt/wms/config/SecurityConfig.java`
- `backend/src/main/java/com/execnt/wms/exception/...`
- `backend/src/main/java/com/execnt/wms/service/StatusTransitionService.java`
- `backend/src/main/java/com/execnt/wms/mapper/StatusTransitionMapper.java`
- `backend/src/main/resources/mapper/StatusTransitionMapper.xml`
- `backend/src/main/java/com/execnt/wms/controller/StatusTransitionController.java` (또는 동등)

## 완료 조건

- [ ] `scripts/start-backend.sh`·`stop-backend.sh`(및 `.ps1`) 존재·기동/종료에 사용 가능
- [ ] `./gradlew build` (또는 `gradlew.bat build`) 성공
- [ ] `scripts/start-backend`로 기동 → 로그에 Started 확인 → `scripts/stop-backend`로 종료
- [ ] `GET /api/status-transitions/rules?order_kind=INBOUND` (및 OUTBOUND)가 REQ §5와 일치
- [ ] 구현이 REQ-F4 §5와 다르면 REQ 문서를 실제에 맞게 갱신
- [ ] JWT/로그인 로직 없음

## 의존성

- 선행: TASK-DB-F4-common (및 DDL 적용)
- 후행: TASK-BE-F1-inbound, TASK-BE-F2-outbound (validateTransition 호출)
