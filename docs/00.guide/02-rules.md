# 02. Rules — 프로젝트 룰

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. Rules란

Rules는 Cursor가 채팅이나 코드 편집 시 에이전트의 컨텍스트에 자동으로 주입하는 텍스트 지침이다. `.cursor/rules/` 폴더에 `.mdc` 확장자의 마크다운 파일로 저장되며, 파일 상단의 YAML 프론트매터가 적용 조건을 결정한다.

사람이 코딩 컨벤션 문서를 읽고 그에 맞춰 코드를 작성하듯, 에이전트도 Rules를 읽고 그 지침에 맞는 코드를 생성한다.

## 2. 프론트매터 형식

모든 `.mdc` 파일은 아래 형식의 YAML 프론트매터로 시작한다.

```yaml
---
description: "룰 요약 한 줄"
globs: ["패턴/**/*.확장자"]
alwaysApply: false
---

```

세 가지 필드가 적용 모드를 결정한다.

- **description** — 룰의 목적을 한 줄로 요약한다. Apply Intelligently 모드에서 에이전트가 이 설명을 보고 로드 여부를 판단한다.
- **globs** — 파일 경로 패턴의 배열이다. 편집 중인 파일이 패턴에 매칭되면 자동으로 룰이 주입된다.
- **alwaysApply** — `true`이면 모든 대화에 무조건 포함된다.

## 3. 네 가지 적용 모드


| 모드                  | alwaysApply | globs | description | 로드 시점                    |
| ------------------- | ----------- | ----- | ----------- | ------------------------ |
| Always Apply        | `true`      | 무관    | 무관          | 모든 대화에 항상                |
| Auto‑attach         | `false`     | 패턴 있음 | 권장          | 매칭 파일 편집 시 자동            |
| Apply Intelligently | `false`     | `[]`  | 필수          | 에이전트가 description을 보고 판단 |
| Manual              | `false`     | `[]`  | 없음          | 사용자가 `@룰이름`으로 직접 호출      |


**Always Apply**는 토큰을 항상 소비하므로 프로젝트 전역에 반드시 필요한 내용만 담는다. **Auto‑attach**는 특정 기술 스택 파일을 편집할 때만 로드되므로 토큰 효율이 좋다. **Apply Intelligently**는 글로브 패턴으로 특정할 수 없지만 맥락상 필요한 규칙에 적합하다.

## 4. 프로젝트에 구성된 Rules

`.cursor/rules/` 폴더에 6개의 룰 파일이 제공되어 있다.

### 4.1 `01-project-context.mdc` — Always Apply

```yaml
---
description: "프로젝트 전역 컨텍스트 – 기술 스택, 패키지 구조, 레이어 규칙, API 응답 형식"
globs: []
alwaysApply: true
---

```

모든 대화에 항상 주입되는 프로젝트 헌법이다. 기술 스택(Java 21, Spring Boot 3.x, MyBatis, PostgreSQL 17, Vue 3 CDN, Element Plus, Tailwind CSS 3), 패키지 구조(`com.execnt.wms`), DB 스키마 규약(`wms` 스키마, 접두어 없음), 레이어 호출 방향(Controller → Service → Mapper), API 응답 형식(`ApiResponse<T>`) 등 프로젝트 전역 규칙을 담고 있다.

### 4.2 `02-java-backend.mdc` — Auto‑attach

```yaml
---
description: "Java 백엔드 코딩 표준 – Controller/Service/Mapper 계층 규칙, 네이밍, 에러 처리"
globs: ["backend/src/main/java/**/*.java"]
alwaysApply: false
---

```

`backend/src/main/java/` 아래 `.java` 파일을 편집할 때 자동 주입된다. Controller에서 `@RestController`·`@RequestMapping` 사용, Service에서 `@Service`·`@Transactional` 사용, Mapper 인터페이스에서 `@Mapper` 사용 등 계층별 어노테이션 규칙과 네이밍 컨벤션, 예외 처리(`@ExceptionHandler`) 패턴을 정의한다.

### 4.3 `03-mybatis-mapper.mdc` — Auto‑attach

```yaml
---
description: "MyBatis XML SQL 패턴 – 형식, 동적 SQL, namespace, resultType/parameterType 규칙"
globs: ["backend/**/mapper/**/*.xml"]
alwaysApply: false
---

```

MyBatis XML 매퍼 파일 편집 시 자동 주입된다. namespace와 Mapper 인터페이스 연결, `resultType`/`parameterType` 지정, 동적 SQL(`<if>`, `<choose>`, `<foreach>`) 작성 규칙, SQL 포맷팅 표준을 담고 있다.

### 4.4 `04-frontend.mdc` — Auto‑attach

```yaml
---
description: "프론트엔드 규칙 – Vue 3 CDN, Element Plus, Tailwind, API 호출 패턴"
globs: ["frontend/**/*.html", "frontend/**/*.js", "frontend/**/*.css"]
alwaysApply: false
---

```

`frontend/` 아래 HTML, JS, CSS 파일 편집 시 자동 주입된다. Vue 3 CDN 방식 컴포넌트 작성, Element Plus 컴포넌트 사용법, Tailwind 유틸리티 클래스 규칙, `fetch` 기반 API 호출 패턴을 정의한다.

### 4.5 `05-status-transition.mdc` — Apply Intelligently

```yaml
---
description: "상태 전이 검증 – status_transition_rule 테이블 기반 유효성 검사, 이력 테이블 기록 규칙"
globs: []
alwaysApply: false
---

```

글로브 패턴이 비어 있고 `alwaysApply`가 `false`이므로 Apply Intelligently 모드로 동작한다. 에이전트가 상태 전이 관련 작업(입고 상태 변경, 출고 승인 등)을 감지하면 description을 보고 자동으로 로드한다. `status_transition_rule` 테이블 기반 유효성 검사와 이력 테이블 기록 규칙을 포함한다.

### 4.6 `06-database.mdc` — Auto‑attach

```yaml
---
description: "PostgreSQL DB 설계·DDL 표준 – 스키마 wms, 대리키 {테이블}_id, 명명·타입·코멘트·권한·변경 관리"
globs: ["database/**/*.sql"]
alwaysApply: false
---

```

`database/` 아래 `.sql` 파일 편집 시 자동 주입된다. 스키마명 `wms`, 대리키 `{테이블}_id`, 명명·타입(BOOLEAN, TIMESTAMPTZ)·전 컬럼 COMMENT, 제약·인덱스 명명, 마이그레이션 기반 변경 관리를 정의한다. 형식 위반은 `database/tools/std_check.sql`이 자동 검출한다.

### 요약 표


| 파일                         | 적용 모드               | 트리거                                 |
| -------------------------- | ------------------- | ----------------------------------- |
| `01-project-context.mdc`   | Always Apply        | 모든 대화                               |
| `02-java-backend.mdc`      | Auto‑attach         | `backend/src/main/java/**/*.java`   |
| `03-mybatis-mapper.mdc`    | Auto‑attach         | `backend/**/mapper/**/*.xml`        |
| `04-frontend.mdc`          | Auto‑attach         | `frontend/**/*.html`, `.js`, `.css` |
| `05-status-transition.mdc` | Apply Intelligently | 에이전트 판단                             |
| `06-database.mdc`          | Auto‑attach         | `database/**/*.sql`                 |


## 5. 실습 — 적용 모드 확인

첫 번째로 `.cursor/rules/` 폴더에서 6개 `.mdc` 파일을 각각 열어 프론트매터의 `alwaysApply`, `globs`, `description` 조합을 확인하고 위 요약 표와 대조한다.

두 번째로 Auto‑attach 동작을 체험한다. `backend/src/main/java/` 아래 아무 `.java` 파일을 열고 에이전트에게 "이 파일의 계층 규칙과 네이밍 컨벤션을 설명해 줘"라고 질문한다. 응답에 `02-java-backend.mdc`의 내용(Controller/Service/Mapper 어노테이션, 네이밍 등)이 반영되어 있으면 Auto‑attach가 정상 작동하는 것이다.

세 번째로 Apply Intelligently 동작을 체험한다. 에이전트에게 "입고 상태를 '검수완료’에서 '입고확정’으로 변경하는 서비스 로직을 작성해 줘"라고 요청한다. 응답에서 `status_transition_rule` 테이블 조회나 이력 기록 언급이 포함되면 `05-status-transition.mdc`가 자동 로드된 것이다.

## 6. 완료 기준

- 6개 룰 파일의 파일명, 적용 모드, 트리거 조건을 설명할 수 있다
- 프론트매터의 세 필드(`description`, `globs`, `alwaysApply`) 조합이 네 가지 적용 모드를 결정하는 방식을 이해한다
- Auto‑attach와 Apply Intelligently의 차이를 실습으로 확인했다



→ 다음: [03-commands.md](http://03-commands.md)
