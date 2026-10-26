# 07. Verification — 형식 점검·라우팅 표·스모크 테스트

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. 이 단계의 목적

02~06에서 구성한 다섯 가지 하네스 요소(Rules, Commands, Skills, Agents, Hooks)가 형식적으로 올바른지, 요소 간 참조 관계가 끊어지지 않았는지, 실제로 동작하는지를 검증한다. 개별 요소의 동작은 각 가이드 문서의 실습에서 확인했으므로, 여기서는 전체를 한번에 점검하는 데 집중한다.

## 2. 형식 점검 체크리스트

### 2.1 Rules (`.cursor/rules/*.mdc`)


| 점검 항목                                              | 확인 방법                      |
| -------------------------------------------------- | -------------------------- |
| 파일 확장자가 `.mdc`인가                                   | 파일 목록에서 확장자 확인             |
| YAML 프론트매터가 `---`로 열고 닫히는가                         | 각 파일 상단 확인                 |
| `globs`가 배열 형태인가 (`[]` 또는 `["패턴"]`)                | 문자열이 아닌 배열인지 확인            |
| `alwaysApply`가 `true` 또는 `false`인가                 | 오타(`True`, `yes` 등) 없는지 확인 |
| Always Apply 룰(`01-project-context.mdc`)이 정확히 1개인가 | 토큰 낭비 방지                   |


### 2.2 Commands (`.cursor/commands/*.md`)


| 점검 항목                                 | 확인 방법             |
| ------------------------------------- | ----------------- |
| 파일 확장자가 `.md`인가                       | 파일 목록 확인          |
| 상단에 HTML 주석(`<!-- -->`)으로 사용법·목적이 있는가 | 각 파일 상단 확인        |
| 채팅에서 `/` 입력 시 5개 커맨드가 목록에 나타나는가       | Cursor 채팅에서 직접 확인 |


### 2.3 Skills (`.cursor/skills/*/SKILL.md`)


| 점검 항목                                                    | 확인 방법                            |
| -------------------------------------------------------- | -------------------------------- |
| 각 스킬 폴더에 `SKILL.md`가 존재하는가                               | 폴더 구조 확인                         |
| 프론트매터에 `name`, `description`이 비어 있지 않은가                  | 각 SKILL.md 확인                    |
| `api-scaffolding`에 `disable-model-invocation: true`가 있는가 | 프론트매터 확인                         |
| `references/` 안 템플릿 파일 4개가 존재하는가                         | `api-scaffolding/references/` 확인 |


### 2.4 Agents (`.cursor/agents/*.md`)


| 점검 항목                                               | 확인 방법                          |
| --------------------------------------------------- | ------------------------------ |
| 파일 8개가 모두 존재하는가                                     | 파일 목록 확인                       |
| 프론트매터에 `name`, `description`, `model: inherit`이 있는가 | 각 파일 확인                        |
| `orchestrator.md`에 `is_background: false`가 있는가      | 프론트매터 확인                       |
| `orchestrator.md` 본문의 위임 대상 이름이 실제 에이전트 파일명과 일치하는가  | `/analyst` → `analyst.md` 등 대조 |


### 2.5 Hooks (`.cursor/hooks.json` + `.cursor/hooks/*.sh`)


| 점검 항목                                                | 확인 방법                                     |
| ---------------------------------------------------- | ----------------------------------------- |
| `hooks.json`이 유효한 JSON인가                             | `python3 -m json.tool .cursor/hooks.json` |
| `hooks.json`의 `command` 경로가 실제 스크립트 파일과 일치하는가        | 4개 경로 대조                                  |
| 스크립트 파일에 실행 권한이 있는가                                  | `ls -l .cursor/hooks/*.sh`                |
| Settings → Features → Hooks에서 "Enable hooks"가 켜져 있는가 | Cursor 설정 확인                              |


## 3. 라우팅 표 — 요소 간 연결 관계

하네스 요소들은 독립적으로 존재하지 않고 서로 연결되어 동작한다. 아래 표는 에이전트가 작업을 수행할 때 어떤 Rules, Skills, Hooks가 함께 작동하는지를 보여준다.


| 에이전트               | 주요 작업                        | 자동 로드 Rules                                                              | 자동 로드 Skills                | 작동 Hooks                                                 |
| ------------------ | ---------------------------- | ------------------------------------------------------------------------ | --------------------------- | -------------------------------------------------------- |
| analyst            | PRD 분석·Task 분해               | `01-project-context.mdc`                                                 | —                           | `block-secrets.sh`, `notify-done.sh`                     |
| ui-designer        | 화면 설계서 작성                    | `01-project-context.mdc`, `04-frontend.mdc`                              | —                           | `block-secrets.sh`, `notify-done.sh`                     |
| db-architect       | DDL·초기 데이터 작성                | `01-project-context.mdc`, `06-database.mdc`                              | —                           | `block-dangerous.sh`, `notify-done.sh`                   |
| backend-developer  | Controller/Service/Mapper 구현 | `01-project-context.mdc`, `02-java-backend.mdc`, `03-mybatis-mapper.mdc` | `status-workflow` (상태 전이 시) | `auto-format.sh`, `block-dangerous.sh`, `notify-done.sh` |
| frontend-developer | Vue 3 화면 구현                  | `01-project-context.mdc`, `04-frontend.mdc`                              | —                           | `auto-format.sh`, `notify-done.sh`                       |
| test-backend       | 실행 기준 API 테스트 (스모크 스크립트·curl, BE↔DB) | `01-project-context.mdc`                                                 | —                           | `block-dangerous.sh`, `notify-done.sh`                   |
| test-integration   | E2E 테스트                      | `01-project-context.mdc`                                                 | —                           | `block-dangerous.sh`, `notify-done.sh`                   |
| orchestrator       | 전체 위임·검증                     | `01-project-context.mdc`                                                 | —                           | `notify-done.sh`                                         |


이 표를 통해 확인할 수 있는 점은 다음과 같다. `01-project-context.mdc`는 Always Apply이므로 모든 에이전트에 항상 주입된다. `02-java-backend.mdc`와 `03-mybatis-mapper.mdc`는 백엔드 개발 에이전트가 Java/XML 파일을 편집할 때 Auto-attach된다. `status-workflow` 스킬은 상태 전이 관련 작업에서만 자동 로드된다. `block-dangerous.sh`는 셸 명령을 실행하는 에이전트에서 작동하고, `auto-format.sh`는 코드 파일을 수정하는 에이전트에서 작동한다.

## 4. 스모크 테스트

형식 점검과 라우팅 표 확인을 마쳤으면, 실제 에이전트가 하네스를 올바르게 참조하는지 간단한 테스트를 수행한다.

### 4.1 Rules 주입 확인

채팅에서 다음과 같이 질문한다.

```
이 프로젝트의 기술 스택과 패키지 구조를 설명해 줘
```

응답에 Java 21, Spring Boot 3.x, MyBatis, PostgreSQL 17, `com.execnt.wms` 패키지, 접두어 없는 `wms` 스키마 등 `01-project-context.mdc`의 내용이 반영되어 있으면 Always Apply 룰이 정상 주입되고 있는 것이다.

### 4.2 Commands 호출 확인

채팅에서 `/run-sql-check`를 실행한다. `database/` 폴더의 SQL 파일을 스캔하고 점검 결과를 반환하면 커맨드가 정상 동작하는 것이다. (03-commands.md 실습에서 이미 확인했다면 생략 가능)

### 4.3 에이전트 인식 확인

채팅에서 `/`를 입력하여 에이전트 목록이 나타나는지 확인한다. 8개 에이전트(analyst, ui-designer, db-architect, backend-developer, frontend-developer, test-backend, test-integration, orchestrator)가 후보로 보이면 정상이다.

### 4.4 Hooks 동작 확인

06-hooks.md 실습에서 `block-dangerous.sh` 차단을 확인했다면 여기서는 `notify-done.sh`의 로그 기록을 확인한다. 위 4.1~4.3의 채팅 작업 후 다음을 확인한다.

```bash
cat .cursor/logs/agent-history.log
```

타임스탬프와 상태가 기록되어 있으면 `stop` 훅이 정상 작동하는 것이다. 로그 파일이 없거나 비어 있으면 Settings → Features → Hooks에서 "Enable hooks"가 켜져 있는지 다시 확인한다.

## 5. 완료 기준

- 형식 점검 체크리스트(2.1~2.5)를 모두 통과했다
- 라우팅 표에서 각 에이전트가 어떤 Rules·Skills·Hooks와 연결되는지 설명할 수 있다
- 스모크 테스트(4.1~4.4)를 수행하여 Rules 주입, Commands 호출, 에이전트 인식, Hooks 동작을 확인했다
- 문제가 발견된 항목이 있으면 해당 가이드 문서(02~06)로 돌아가 수정했다

## 6. 핵심 포인트

하네스 5요소는 개별적으로 올바르더라도 연결이 끊어지면 동작하지 않는다. 라우팅 표는 "이 에이전트가 이 작업을 할 때, 어떤 Rules가 붙고, 어떤 Skills를 참조하고, 어떤 Hooks가 개입하는지"를 한눈에 보여주는 지도이다. 새로운 룰이나 에이전트를 추가할 때마다 이 표를 갱신하면 요소 간 누락을 방지할 수 있다.



→ 다음: [08-sequential-dev.md](08-sequential-dev.md)
