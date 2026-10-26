# 09. Orchestration — 오케스트레이터 자동 완성

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. 이 단계의 목적

08에서 사람이 에이전트를 한 명씩 호출하며 전체 WMS를 만들었다. 09에서는 소스를 초기화한 뒤, 오케스트레이터 에이전트 1명에게 PRD를 주고 동일한 결과물을 자동으로 완성하는 과정을 체험한다.

08과 09의 차이는 "누가 에이전트를 호출하느냐"이다. 08은 사람이 순서대로 호출했고, 09는 오케스트레이터가 판단하여 위임·검증·재시도까지 자동으로 수행한다.

## 2. 08 vs 09 비교


| 구분      | 08 순차 개발             | 09 오케스트레이션               |
| ------- | -------------------- | ------------------------ |
| 범위      | PRD 전체 (F1~F4)       | PRD 전체 (F1~F4)           |
| 방식      | 사람이 에이전트 6명을 순서대로 호출 (db-architect 제외) | 오케스트레이터 1명에게 전체 위임       |
| 에이전트 호출 | 사람이 `@에이전트명`으로 직접    | 오케스트레이터가 `/에이전트명`으로 자동   |
| 병렬 실행   | 사람이 판단하여 순차 진행       | 오케스트레이터가 독립 Task는 병렬 위임  |
| 검증·재시도  | 사람이 확인 포인트를 보고 판단    | 오케스트레이터가 산출물 확인 후 자동 재시도 |
| 목적      | 에이전트별 역할과 산출물 흐름 이해  | 멀티 에이전트 자동 완성 체험         |


## 3. 사전 준비 — 소스 초기화

08에서 만든 산출물을 정리하고 깨끗한 상태에서 시작한다.

### 3.1 보존 대상

다음은 삭제하지 않는다.

- `.cursor/` 전체 (Rules, Commands, Skills, Agents, Hooks)
- `docs/01.analysis/01.rfp/wms_prd.md` (PRD 원문)
- `docs/99.references/` 전체 (document-standards.md, coding-standards.md, backend-config.md)
- `database/schemas/` (DB 스키마는 이미 만들어진 것 사용)
- `build.gradle`, `settings.gradle`, `gradlew` 등 프로젝트 빌드 설정

### 3.2 초기화 대상

다음을 삭제하여 오케스트레이터가 처음부터 만들게 한다.

```
# 분석 산출물
rm -rf docs/01.analysis/02.requirements/*
rm -rf docs/01.analysis/03.tasks/*
rm -rf docs/01.analysis/04.ui/*

# 백엔드 소스 (설정 파일 제외)
rm -rf backend/src/*

# 프론트엔드 소스
rm -rf frontend/*

# 테스트 리포트
rm -rf docs/test-reports/*
```

### 3.3 초기화 확인

삭제 후 다음을 확인한다.

- `.cursor/` 하위 파일이 온전한가 (Rules 7개, Commands 6개, Skills 2개, Agents 8개, Hooks 4개)
- PRD 파일이 존재하는가 (`docs/01.analysis/01.rfp/wms_prd.md`)
- 참조 문서 3개가 존재하는가 (`docs/99.references/` 하위 document-standards.md, coding-standards.md, backend-config.md)
- 빌드 설정이 유효한가 (`./gradlew tasks` 실행 가능)

## 4. 오케스트레이터 실행

**DB 설계 완료가 선행 조건이다.** `database/README.md`의 모델링 실습에서 직접 설계·검토한 기준 DDL과 데이터 사전을 확정한 뒤 진행한다. 아래의 DB 단계 제외는 이미 수행한 설계를 중복하지 않는다는 뜻이며, 개인 DB가 사전 제공되었다는 이유로 테이블 설계를 생략하는 뜻이 아니다. 아직 확정 모델이 없다면 DB 설계 실습부터 완료한다.

### 4.1 프롬프트

채팅에서 오케스트레이터에게 다음과 같이 요청한다.
실행 순서·위임·검증·재시도는 `.cursor/agents/orchestrator.md` 정의를 따른다.
단계마다 사용자가 다시 `@에이전트명`을 호출할 필요는 없다.

**최소 프롬프트 (§8 핵심 포인트)**

```
@orchestrator
docs/01.analysis/01.rfp/wms_prd.md 를 입력으로 PRD 전체(F1~F4)를 처음부터 끝까지 만들어 줘.
DB DDL은 database/schemas/에 이미 작성되어 있어.
```

**권장 프롬프트 (참조 문서·전제를 명시)**

```
@orchestrator
docs/01.analysis/01.rfp/wms_prd.md 를 입력으로 PRD 전체(F1~F4)를 처음부터 끝까지 만들어 줘.

전제:
- DB DDL은 database/schemas/에 이미 있음 → db-architect 위임하지 않음
- 실행 순서·검증·재시도는 orchestrator 에이전트 정의를 따름

참조 문서:
- docs/99.references/document-standards.md
- docs/99.references/coding-standards.md
- docs/99.references/backend-config.md
```

### 4.2 오케스트레이터가 수행하는 흐름

```
orchestrator
  │
  ├─① analyst 위임
  │    └─ 요구사항 정의서 + Task 정의서 + application.yml 생성
  │    └─ [검증] §5 API 명세에 응답 예시·시드 데이터가 있는가
  │    └─ [검증] 네이밍이 document-standards.md를 따르는가
  │
  ├─② ui-designer 위임
  │    └─ 입고·출고·대시보드 UI 설계서 생성
  │    └─ [검증] 화면·버튼·시나리오·에러 피드백이 포함되어 있는가
  │
  ├─③ backend-developer 위임 (병렬: 입고·출고·대시보드)
  │    └─ 입고·출고·대시보드·상태 전이 API 구현
  │    └─ CORS 전용 SecurityConfig 생성 (backend-config.md 참조)
  │    └─ 빌드 확인 → 서버 기동 확인 → REQ §5 갱신
  │    └─ [검증] 빌드 성공, 서버 기동 성공, §5 갱신 완료, SecurityConfig 존재
  │
  ├─④ test-backend 위임
  │    └─ REQ §5 기준 전체 API 테스트
  │    └─ [검증] 정상·비정상 케이스 통과, 이력 기록 확인
  │    └─ [실패 시] 원인 파악 → backend-developer에게 수정 위임 → 재테스트
  │
  ├─⑤ frontend-developer 위임
  │    └─ UI 설계서 + REQ §5 기준 SPA 화면 구현 (index.html + views/ + components/)
  │    └─ [검증] SPA 구조, views/ 페이지 컴포넌트 생성, api.js API_BASE 포트 일치
  │
  └─⑥ test-integration 위임
       └─ UI 설계서 기준 화면 기능 시나리오 테스트
       └─ [검증] 입고·출고·대시보드 시나리오 통과, CORS Preflight 정상, curl과 브라우저 결과 일치
       └─ [실패 시] CORS/포트/프론트/백엔드 원인 식별 → 해당 에이전트에게 수정 위임 → 재테스트
```

### 4.3 오케스트레이터의 판단 포인트

오케스트레이터는 각 단계에서 다음을 판단한다.

**다음 단계로 넘어가도 되는가**: 산출물이 존재하고, 다음 에이전트의 입력으로 충분한지 확인한다. 부족하면 같은 에이전트에게 보완을 요청한다.

**병렬 실행이 가능한가**: backend-developer의 독립 Task(입고·출고·대시보드)는 동시에 위임할 수 있다. analyst 완료 후 ui-designer는 단독 진행하며, backend-developer 이후(test-backend → frontend → test-integration)는 반드시 순차 실행한다.

**테스트 실패 시 어디를 수정해야 하는가**: test-backend 실패는 backend-developer에게, test-integration의 프론트↔백엔드 불일치는 원인 쪽(프론트 또는 백엔드)에게 수정을 위임한다.

## 5. 관찰 포인트

오케스트레이터가 자동 실행하는 동안 다음을 관찰한다.

### 5.1 위임 흐름

- 오케스트레이터가 에이전트를 올바른 순서로 호출하는가
- 각 에이전트에게 충분한 컨텍스트(Task 경로, 참조 문서)를 전달하는가
- 병렬 실행 가능한 백엔드 Task(입고·출고·대시보드)를 실제로 병렬 처리하는가

### 5.2 참조 문서 활용

- 에이전트들이 document-standards.md의 네이밍 규칙을 따르는가
- 백엔드 코드가 coding-standards.md의 패키지 구조를 따르는가
- application.yml이 backend-config.md 기준으로 생성되었는가
- 백엔드에 CORS 전용 SecurityConfig가 backend-config.md 기준으로 생성되었는가
- 프론트엔드 api.js의 API_BASE가 백엔드 실행 포트와 일치하는가

### 5.3 산출물 검증

- 각 단계 완료 후 오케스트레이터가 산출물을 확인하는가
- 부족한 부분을 감지하고 보완 요청하는가

### 5.4 실패 대응

- 빌드 실패, 서버 기동 실패, 테스트 실패 시 오케스트레이터가 원인을 파악하는가
- 적절한 에이전트에게 수정을 위임하는가
- 수정 후 재검증하는가
- 브라우저에서만 실패하는 경우(curl 성공, 브라우저 실패) CORS 설정 문제로 식별하는가
- CORS 문제 시 backend-developer에게 SecurityConfig 수정을 위임하는가

### 5.5 Rules·Skills 적용

- 백엔드 코드에 Java 백엔드 Rules(02-java-backend.mdc)가 반영되는가
- 상태 전이 코드에 status-workflow 스킬이 적용되는가
- SQL이 MyBatis XML에만 작성되는가

## 6. 08 산출물과 비교

09 완료 후 08에서 만든 산출물(초기화 전 백업해 둔 경우)과 비교한다.


| 비교 항목    | 확인 내용                                                           |
| -------- | --------------------------------------------------------------- |
| 요구사항 정의서 | 네이밍이 document-standards.md를 따르는가, §5 응답 예시가 포함되어 있는가            |
| DB 스키마   | database/schemas/ 기존 DDL·전이 규칙과 정합하는가                  |
| 백엔드 코드   | 계층 구조(Controller→Service→Mapper→XML)가 coding-standards.md를 따르는가 |
| 프론트엔드    | 같은 화면·컴포넌트 패턴인가, api.js 구조가 coding-standards.md를 따르는가           |
| 테스트 결과   | 동일한 케이스를 커버하는가, 리포트가 document-standards.md 구조를 따르는가             |


동일한 (.cursor/)와 PRD에서 출발했으므로 산출물의 구조와 패턴이 유사해야 한다. 차이가 있다면 어떤 에이전트의 어떤 판단이 달랐는지 분석해 본다.

## 7. 완료 기준

- 소스 초기화 후 오케스트레이터 1명에게 위임하여 PRD 전체(F1~F4)가 자동 완성되었다
- 오케스트레이터가 6개 에이전트(db-architect 제외)를 올바른 순서로 호출하고 산출물을 검증하는 과정을 관찰했다
- 모든 산출물의 네이밍과 경로가 document-standards.md를 따른다
- 빌드 성공, 서버 기동 성공, API 테스트 통과, 화면 구현 완료를 확인했다
- 테스트 실패 시 오케스트레이터가 수정 위임 → 재테스트하는 흐름을 확인했다 (실패가 없었으면 의도적으로 발생시켜 볼 수 있다)
- 08(순차)과 09(자동)의 결과물을 비교하고, 일관된 산출물을 만드는지 확인했다

## 8. 핵심 포인트

08에서 사람이 6번 판단하고 6번 호출한 것을(db-architect 제외), 09에서는 오케스트레이터가 대신한다. 사람이 한 일은 "PRD를 주고 시작해"라는 한 문장뿐이다. 상세 실행 순서는 사용자가 적지 않아도 된다. `.cursor/agents/orchestrator.md`에 정의되어 있으며, 사용자는 PRD 경로와 DB 전제만 전달하면 된다.

이것이 가능한 이유는 5요소가 갖춰져 있기 때문이다. Rules가 코딩 규칙을 주입하고, Skills가 상태 전이 패턴을 제공하고, Agents가 역할을 나누고, Task가 완료 조건을 명시하고, Hooks가 위험 동작을 차단한다. 오케스트레이터는 이 인프라 위에서 "다음에 누구를 부르고, 결과가 충분한지 확인"하는 역할만 한다.

참조 문서 체계(document-standards.md, coding-standards.md, backend-config.md)가 모든 에이전트의 공통 기준이므로, 산출물의 일관성이 보장된다. 표준을 변경할 때는 참조 문서만 수정하면 전체에 반영된다.

01~07에서 구축이 견고할수록 09의 자동 완성 품질이 높아진다. 결과가 기대에 미치지 못하면, 코드를 고치기 전에 5요소(Rules·Task 완료 조건·에이전트 행동 원칙·참조 문서)를 먼저 점검하는 것이 올바른 순서이다.

→ 가이드 목차: [README.md](README.md)
