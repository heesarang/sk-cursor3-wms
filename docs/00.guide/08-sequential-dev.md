# 08. Sequential Dev — 에이전트 순차 개발

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. 이 단계의 목적

PRD 전체(F1 입고, F2 출고, F3 대시보드, F4 상태 전이)를 대상으로, 에이전트를 한 명씩 순서대로 호출하며 개발 전 과정을 체험한다. 각 에이전트가 어떤 산출물을 만들고, 그 산출물이 다음 에이전트의 입력이 되는 흐름을 직접 확인하는 것이 핵심이다.

09-orchestration.md에서는 소스를 초기화한 뒤 동일 범위를 오케스트레이터 1명에게 위임하여 자동 완성하므로, 08과 09의 차이는 "사람이 한 명씩 호출" vs "오케스트레이터가 자동 위임"이다.

## 2. 참조 문서 체계

에이전트와 Rules는 아래 참조 문서를 기준으로 동작한다. 산출물 경로, 네이밍, 코딩 표준을 변경할 때는 참조 문서만 수정하면 전체에 반영된다.


| 참조 문서  | 경로                                       | 내용                                 |
| ------ | ---------------------------------------- | ---------------------------------- |
| 산출물 표준 | docs/99.references/document-standards.md | 산출물 경로, 네이밍, 문서 구조, 참조 규칙          |
| 개발 표준  | docs/99.references/coding-standards.md   | 패키지/클래스/API/DB 네이밍, 응답 포맷, 상태 태그   |
| 백엔드 설정 | docs/99.references/backend-config.md     | application.yml 기본 설정              |
| 데이터 사전 | docs/99.references/data-dictionary.md    | 테이블·컬럼 의미, 공통코드 (db-architect가 생성) |


## 3. 실행 순서 개요


| 순서  | 에이전트                  | 입력                       | 산출물                                        |
| --- | --------------------- | ------------------------ | ------------------------------------------ |
| 1   | `@analyst`            | PRD 전체 (F1~F4)           | 요구사항 정의서, Task 정의서, application.yml        |
| 2   | `@db-architect`       | Task 정의서                 | DDL, 초기 데이터 SQL, 데이터 사전                    |
| 3   | `@ui-designer`        | Task 정의서, API 명세(REQ §5) | UI 설계서 (입고, 출고, 대시보드)                      |
| 4   | `@backend-developer`  | Task 정의서, DDL            | 백엔드 코드 전체 → 서버 기동 확인 → REQ §5 갱신           |
| 5   | `@test-backend`       | REQ §5 (최신)              | API 테스트 리포트                                |
| 6   | `@frontend-developer` | UI 설계서, REQ §5 (최신)      | SPA 화면 (index.html + views/ + components/) |
| 7   | `@test-integration`   | UI 설계서, 화면 코드, 백엔드 API   | E2E 테스트 리포트                                |


각 단계의 산출물이 다음 단계의 입력이 된다. 특히 4단계에서 backend-developer가 갱신한 REQ §5가 5~7단계의 공통 기준이 된다.

산출물 경로와 파일 네이밍은 모두 document-standards.md를 따른다.

## 4. 단계별 실행

### 4.1 분석/설계 — `@analyst`

채팅에서 다음과 같이 요청한다.

```
@analyst
docs/01.analysis/01.rfp/wms_prd.md 전체(F1 입고, F2 출고, F3 대시보드, F4 상태 전이)를 분석해서
요구사항 정의서와 에이전트별 Task 정의서를 만들어 줘.

산출물 네이밍과 경로는 docs/99.references/document-standards.md를 따라.
application.yml이 없으면 docs/99.references/backend-config.md를 참고해서 생성해 줘.
```

확인 포인트:

- 요구사항 정의서가 document-standards.md의 네이밍 규칙(REQ-{기능ID}-{도메인}.md)으로 생성되었는가
- 각 요구사항의 §5(API 설계 초안)에 Method, Path, 파라미터, 성공/에러 응답 예시, 테스트 시드 전제가 포함되어 있는가
- Task가 에이전트별로 document-standards.md의 네이밍 규칙(TASK-{약어}-{기능ID}-{도메인}.md)에 맞게 분리되어 있는가
- backend/src/main/resources/application.yml이 생성되었는가 (backend-config.md 기준)
- 백엔드 Task 완료 조건에 "서버 기동 확인"과 "REQ §5 갱신"이 포함되어 있는가
- 테스트 Task에 "서버 기동 → health check → 테스트 → 종료" 절차가 명시되어 있는가
- 통합 테스트 Task에 "UI 설계서 기반 화면 기능 시나리오 검증"이 명시되어 있는가
- 서버 기동/종료 헬퍼 스크립트(scripts/start-backend.sh, stop-backend.sh) 작성이 특정 Task에 포함되어 있는가
- 입고 상태 전이(주문생성 → 검수중 → 검수완료 → 입고확정)와 출고 상태 전이(주문생성 → 피킹중 → 피킹완료 → 출고확정)가 모두 포함되어 있는가

### 4.2 DB 설계 — `@db-architect`

analyst가 만든 Task를 기반으로 DB를 설계한다.

```
실제 실습에서는 만들어진 DB를 사용할 예정으로 수행금지
```

~~@db-architect
docs/01.analysis/03.tasks/ 에서 DB 관련 Task를 읽고
전체 기능(입고, 출고, 대시보드, 상태 전이)에 필요한 DDL과 초기 데이터를 작성해 줘.
데이터 사전(data-dictionary.md)도 함께 만들어 줘.~~

~~산출물 네이밍과 경로는 docs/99.references/document-standards.md를 따라.
DB 네이밍 규칙은 docs/99.references/coding-standards.md를 따라.~~

확인 포인트:

- DDL 파일 네이밍이 document-standards.md 규칙({순번}_{설명}.sql)을 따르는가
- 테이블 접두사 `twms`_가 적용되었는가
- 공통 컬럼(created_at, updated_at, created_by, updated_by)이 포함되어 있는가
- status_transition_rule 테이블에 입고·출고 상태 전이 규칙이 모두 INSERT 되어 있는가
- 입고 관련 테이블(inbound_order, inbound_order_line 등)이 생성되었는가
- 출고 관련 테이블(outbound_order, outbound_order_line 등)이 생성되었는가
- 이력 테이블이 입고·출고 모두 지원하는가
- 공통코드, 센터, 상품 등 마스터 초기 데이터가 포함되어 있는가
- docs/99.references/data-dictionary.md가 생성되었는가
- SQL을 실행하여 오류가 없는지 확인했는가

### 4.3 UI 설계 — `@ui-designer`

analyst가 만든 Task와 API 명세를 기반으로 화면을 설계한다.

```
@ui-designer
docs/01.analysis/03.tasks/ 에서 UI 관련 Task를 읽고
입고, 출고, 대시보드 화면의 UI 설계서를 만들어 줘.
API 경로는 요구사항 정의서 §5를 참조해.

산출물 네이밍과 경로는 docs/99.references/document-standards.md를 따라.
상태 태그 색상은 docs/99.references/coding-standards.md를 따라.
```

확인 포인트:

- UI 설계서 네이밍이 document-standards.md 규칙(UI-{기능ID}-{도메인}.md)을 따르는가
- UI 설계서가 document-standards.md §3.3의 표준 구조를 따르는가
- 입고 화면: 주문 목록(센터별·상태별 필터, el-table), 상세 다이얼로그(품목별 수량, 상태 변경 버튼)
- 출고 화면: 입고와 동일한 UX 패턴, 출고 상태(피킹시작·피킹완료·출고확정) 버튼
- 대시보드: 입고/출고 상태별 건수 요약, 최근 상태 변경 이력, 주문별 이력 추적
- 상태별 el-tag 색상 구분이 coding-standards.md 기준으로 정의되어 있는가
- 에러/예외 시 사용자 피드백이 설계에 포함되어 있는가
- 각 화면의 사용자 시나리오(어떤 순서로 어떤 버튼을 누르는지)가 명시되어 있는가

### 4.4 백엔드 개발 — `@backend-developer`

Task와 DDL을 기반으로 백엔드 코드를 구현한다.

```
@backend-developer
docs/01.analysis/03.tasks/ 에서 백엔드 관련 Task를 읽고
입고, 출고, 대시보드, 상태 전이 API를 모두 구현해 줘.
database/schemas/ 의 DDL을 참조해서 MyBatis XML을 작성해.

패키지 구조와 네이밍은 docs/99.references/coding-standards.md를 따라.
Controller → Service → Mapper → XML 순서로 작업해.
완료 후 서버 기동 확인하고, 실제 구현이 REQ §5와 다른 점이 있으면 REQ 문서를 갱신해.

CORS 전용 SecurityConfig도 docs/99.references/backend-config.md를 참조해서 생성해.

```

확인 포인트:

- 패키지 구조가 coding-standards.md를 따르는가
- Controller에 @RestController, @RequestMapping, @Tag, @Operation이 있는가
- Service에 @Service, @Transactional이 있는가
- 상태 변경 시 StatusTransitionService.validateTransition()을 호출하는가
- 상태 변경과 이력 기록이 같은 트랜잭션 내에서 처리되는가
- MyBatis XML의 namespace가 Mapper 인터페이스 FQCN과 일치하는가
- 입고 API, 출고 API, 대시보드 API가 모두 구현되었는가
- 빌드 성공하는가
- 서버 기동 후 "Started" 로그가 확인되는가 (확인 후 서버 종료)
- REQ §5가 실제 구현에 맞게 갱신되었는가
- CORS 전용 SecurityConfig가 생성되었는가 (docs/99.references/backend-config.md 기준)
- build.gradle에 spring-boot-starter-security 의존성이 포함되어 있는가
- 스웨거 : [http://localhost:8080/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html)

### 4.5 백엔드 테스트 — `@test-backend`

구현된 API를 실제 기동한 서버에서 검증한다.

```
@test-backend
요구사항 정의서 §5를 읽고 전체 API를 테스트해 줘.
서버 기동 → health check → 전체 API curl 테스트 → 결과 리포트 → 서버 종료.

정상 케이스(상태 순차 진행)와 비정상 케이스(허용되지 않은 상태 전이)를 모두 확인해.
입고·출고·대시보드 API 모두 대상이야.

리포트 네이밍은 docs/99.references/document-standards.md를 따라.
```

확인 포인트:

- REQ §5를 기준으로 테스트 대상을 파악했는가
- 서버가 정상 기동되고 health check를 통과했는가
- 입고 API: 목록 조회, 상세 조회, 상태 전이(00→10→20→90) 정상 동작
- 출고 API: 목록 조회, 상세 조회, 상태 전이(00→10→20→90) 정상 동작
- 대시보드 API: 상태별 건수, 최근 이력 조회 정상 동작
- 불허 전이(건너뛰기, 역방향 등)가 400 + 명확한 메시지로 거부되는가
- 상태 변경 후 조회로 실제 DB 반영 확인했는가
- 이력이 정상 기록되는가
- 테스트 완료 후 서버가 종료되었는가
- 리포트가 document-standards.md의 테스트 리포트 구조를 따르는가

### 4.6 프론트엔드 개발 — `@frontend-developer`

UI 설계서와 REQ §5를 기반으로 화면을 구현한다.

```
@frontend-developer
docs/01.analysis/04.ui/ 의 UI 설계서를 읽고
docs/01.analysis/02.requirements/ 의 요구사항 §5를 참조해서
입고, 출고, 대시보드 화면을 모두 구현해 줘.

파일 구조와 api.js 패턴은 docs/99.references/coding-standards.md를 따라.
API 연동은 REQ §5의 경로·파라미터를 기준으로 해.
```

확인 포인트:

- index.html 하나에서 Vue Router로 화면을 전환하는 SPA 구조인가 (화면별 독립 HTML이 아닌가)
- Vue 3, Vue Router, Element Plus, Tailwind CSS, Axios CDN 임포트가 index.html에 있는가
- 페이지 컴포넌트가 views/ 폴더에 .js로 작성되었는가 (InboundList.js, OutboundList.js, Dashboard.js)
- 재사용 컴포넌트가 components/ 폴더에 .js로 작성되었는가 (InboundDetail.js, OutboundDetail.js, StatusTag.js)
- router.js에 라우팅이 정의되고 app.js에서 전역 컴포넌트 등록·플러그인 등록·마운트가 수행되는가
- API 호출이 js/api.js 메서드를 통해서만 이루어지는가 (컴포넌트에서 axios 직접 호출 없는가)
- 입고 화면: el-table 목록 + 센터별·상태별 필터 + 상세 el-dialog + 상태 변경 버튼
- 출고 화면: 입고와 동일 패턴 + 출고 상태 버튼(피킹시작·피킹완료·출고확정)
- 대시보드: 상태별 건수 카드 + 최근 이력 테이블
- 상태 태그가 공통 컴포넌트(StatusTag)를 사용하고 coding-standards.md 기준 색상이 적용되어 있는가
- API 에러 시 ElementPlus.ElMessage.error로 사용자 피드백이 있는가
- 상태 변경 시 ElementPlus.ElMessageBox.confirm 확인 후 실행하는가
- API 경로가 REQ §5와 일치하는가
- js/api.js의 API_BASE가 백엔드 실행 포트(기본 8080)와 일치하는가
- 백엔드에 CORS 전용 SecurityConfig가 존재하는가
- 브라우저 개발자 도구(Network 탭)에서 CORS 에러 없이 API 호출이 되는가

### 4.7 통합 테스트 — `@test-integration`

UI 설계서 기준으로 화면에서 API까지 전체 흐름을 검증한다. -> 일부 체험만.

```
@test-integration
docs/01.analysis/04.ui/ 의 UI 설계서를 기준으로
입고, 출고, 대시보드 화면의 전체 기능을 테스트해 줘.

화면별 사용자 시나리오대로:
- 입고: 목록 필터 → 상세 보기 → 검수시작 → 검수완료 → 입고확정 → 목록 갱신
- 출고: 목록 필터 → 상세 보기 → 피킹시작 → 피킹완료 → 출고확정 → 목록 갱신
- 대시보드: 상태별 건수 확인 → 최근 이력 확인
- 에러: 잘못된 전이 시 에러 메시지 표시 확인

리포트 네이밍은 docs/99.references/document-standards.md를 따라.
```

확인 포인트:

- UI 설계서의 화면·버튼·시나리오 기준으로 테스트했는가
- 서버가 정상 기동되고 health check를 통과했는가
- 프론트엔드가 index.html 하나의 SPA 구조이고 Vue Router로 화면 전환이 되는가
- js/api.js의 API 호출 경로가 실제 백엔드 엔드포인트와 일치하는가
- API 응답 필드명이 views/ 컴포넌트에서 참조하는 필드명과 일치하는가
- 입고 시나리오: 목록 로드 → 상세 다이얼로그 → 상태 변경 → 목록 갱신까지 전체 흐름 정상
- 출고 시나리오: 동일 패턴으로 전체 흐름 정상
- 대시보드: 건수 조회, 이력 조회 정상
- 에러 케이스: 서버 400 응답 시 ElementPlus.ElMessage.error로 메시지 표시되는가
- 리포트가 document-standards.md의 테스트 리포트 구조를 따르는가
- js/api.js의 API_BASE가 백엔드 실행 포트와 일치하는가
- CORS 전용 SecurityConfig가 존재하고 allowedOriginPatterns("*"), allowedMethods, allowPrivateNetwork(true)가 설정되어 있는가
- curl로 성공하는 API가 브라우저에서도 성공하는가 (CORS Preflight 통과 확인)
- 브라우저 개발자 도구 Network 탭에서 OPTIONS Preflight 요청이 200으로 응답하는가

## 5. 산출물 경로

document-standards.md §1 산출물 경로를 따른다.

## 6. 산출물 흐름도

```
       analyst
          ├─ 요구사항 정의서 (§5에 API 경로·응답 예시·시드 데이터)
          ├─ Task 정의서 (에이전트별, 완료 조건 포함)
          └─ application.yml (backend-config.md 기준)
          │
     ┌────┴────┬──────────────┐
     ▼         ▼              ▼
 db-architect  ui-designer   (병렬 가능)
     │              │
     ▼              ▼
  DDL·초기 데이터   UI 설계서
  data-dictionary
     │              │
     └──────┬───────┘
            ▼
    backend-developer
       ├─ 코드 구현 + 빌드
       ├─ 서버 기동 확인
       └─ REQ §5 갱신 ◀── 이후 단계의 공통 기준
            │
            ▼
      test-backend
       ├─ REQ §5 읽기 → 서버 기동 → curl 테스트 → 서버 종료
       └─ 테스트 리포트
            │
            ▼
    frontend-developer
       ├─ UI 설계서 + REQ §5 → SPA 화면 구현 (index.html + views/ + components/)
            │
            ▼
    test-integration
       ├─ UI 설계서 기준 시나리오 → 서버 기동 → 화면 기능 검증 → 서버 종료
       └─ 테스트 리포트
```

## 7. 완료 기준

- PRD 전체(F1 입고, F2 출고, F3 대시보드, F4 상태 전이)가 화면에서 DB까지 동작한다
- 입고 상태 전이(주문생성 → 검수중 → 검수완료 → 입고확정)가 정상 작동하고 불허 전이는 거부된다
- 출고 상태 전이(주문생성 → 피킹중 → 피킹완료 → 출고확정)가 정상 작동하고 불허 전이는 거부된다
- 대시보드에서 상태별 건수와 이력을 조회할 수 있다
- 7개 에이전트를 순서대로 호출하며 각 산출물이 다음 단계의 입력이 되는 흐름을 체험했다
- 모든 산출물의 네이밍과 경로가 document-standards.md를 따른다
- 백엔드 개발 에이전트가 서버 기동 확인 + REQ §5 갱신까지 수행함을 확인했다
- 테스트 에이전트가 서버 기동 → health check → 테스트 → 종료 절차를 따름을 확인했다
- 통합 테스트 에이전트가 UI 설계서의 화면 기능 시나리오 기준으로 검증함을 확인했다

## 8. 핵심 포인트

이 단계에서 체험한 7단계 순차 호출이 곧 오케스트레이터의 내부 로직과 동일하다. 핵심 개선점은 세 가지다.

첫째, 백엔드 개발 에이전트가 코드만 만드는 게 아니라 서버 기동까지 확인하고, 실제 구현에 맞게 REQ §5를 갱신한다. 이 갱신된 §5가 후속 에이전트들의 "살아있는 계약서"가 된다.

둘째, 테스트 에이전트가 서버 준비 절차(기동 → health check → 대기)를 거친 뒤에 테스트를 시작한다. 서버가 안 떠 있는 상태에서 curl을 쏘는 문제가 사라진다.

셋째, 통합 테스트는 API 경로 대조가 아니라 UI 설계서의 화면 기능 시나리오를 기준으로 검증한다. 사용자가 실제로 하는 동작 흐름이 테스트 단위가 된다.

모든 에이전트가 참조 문서(document-standards.md, coding-standards.md, backend-config.md)를 공통 기준으로 사용하므로, 표준을 변경할 때는 참조 문서만 수정하면 전체에 반영된다.

→ 다음: [09-orchestration.md](09-orchestration.md)
