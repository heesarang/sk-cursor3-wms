# 04. Skills — 작업 패턴 참고서

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. Skills란

Skills는 특정 작업 유형에 대한 형식과 절차를 정의한 참고서이다. `.cursor/skills/` 아래에 폴더 단위로 저장하며, 각 폴더에는 반드시 `SKILL.md` 파일이 있어야 한다. 에이전트는 작업 중 필요하다고 판단하면 해당 스킬을 읽고 같은 절차·형식으로 산출물을 만든다.

Rules가 "이렇게 해라"는 정적 지침이라면, Skills는 "이 작업은 이런 구조로 한다"는 작업 패턴 카드이다. Rules는 파일 매칭이나 설정에 의해 컨텍스트에 자동 주입되지만, Skills는 에이전트가 작업 내용을 보고 능동적으로 참조한다는 점이 다르다.

## 2. [SKILL.md](http://skill.md/) 형식

각 스킬 폴더의 `SKILL.md` 상단에 YAML 프론트매터를 작성한다.

```yaml
---
name: 스킬-식별자
description: "에이전트가 로드 여부를 판단하는 힌트 문장"
paths: "적용 파일 경로 패턴"
---

```

세 가지 필드의 역할은 다음과 같다.

- **name** — 스킬 식별자. 폴더명과 일치시키는 것이 관례이다.
- **description** — 에이전트가 현재 작업과 관련 있는지 판단하는 근거. 구체적으로 작성할수록 정확하게 로드된다.
- **paths** — 이 스킬이 적용되는 파일 경로 패턴. 매칭 파일 작업 시 자동 로드된다.

선택 필드로 `disable-model-invocation: true`를 지정하면 에이전트가 자동으로 로드하지 않고, 사용자가 명시적으로 호출할 때만 실행된다.

스킬 폴더 안에는 `SKILL.md` 외에 `references/`(템플릿·예시 파일), `scripts/`(보조 셸 스크립트) 등 보조 리소스를 둘 수 있다. 에이전트는 `SKILL.md`에서 이들을 참조하여 작업을 수행한다.

## 3. 프로젝트에 구성된 Skills

`.cursor/skills/` 폴더에 2개의 스킬이 제공되어 있다.

### 3.1 `api-scaffolding/` — 수동 호출 전용

```
.cursor/skills/api-scaffolding/
├── SKILL.md
├── references/
│   ├── TemplateController.java
│   ├── TemplateService.java
│   ├── TemplateMapper.java
│   └── TemplateMapper.xml
└── scripts/
    └── scaffold.sh

```

```yaml
---
name: api-scaffolding
description: "새 도메인의 CRUD API를 일괄 생성할 때 사용"
disable-model-invocation: true
---

```

`disable-model-invocation: true`이므로 에이전트가 자동으로 로드하지 않는다. 사용자가 명시적으로 호출해야 실행된다. 도메인명을 받아 Controller, Service, Mapper 인터페이스, MyBatis XML 4개 파일을 `references/` 디렉터리의 템플릿을 기반으로 일괄 생성한다. 생성 후 프로젝트 Rules의 패키지·네이밍 규칙을 적용하고 빌드를 확인한다.

03-commands.md에서 다룬 `/create-api` 커맨드와 역할이 비슷해 보이지만, Commands는 "무엇을 해라"라는 진입점이고 Skills는 "어떤 형식·절차로 만들어라"라는 패턴 정의라는 점에서 구분된다. 커맨드가 이 스킬을 참조하여 실행할 수 있다.

### 3.2 `status-workflow/` — 자동 로드

```
.cursor/skills/status-workflow/
├── SKILL.md
└── scripts/
    └── check-transition.sh

```

```yaml
---
name: status-workflow
description: "입고/출고 상태 전이 로직을 구현하거나 수정할 때 사용. 상태 전이 검증 → 상태 업데이트 → 이력 저장의 순서를 따른다."
paths: "backend/src/**/*.java"
---

```

`backend/src/` 아래 Java 파일 작업 시 자동 로드 대상이 되며, description에 "상태 전이"가 명시되어 있으므로 에이전트가 상태 변경 관련 작업을 감지하면 능동적으로 참조한다. 상태 변경 코드 작성 시 반드시 따라야 할 4단계 절차를 정의한다.


| 단계         | 내용                                                                                                                                       |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 1. 검증      | `StatusTransitionService.validateTransition(processType, fromStatus, toStatus)` 호출. `status_transition_rule` 테이블에서 허용 여부 조회, 미허용 시 예외 발생 |
| 2. 상태 업데이트 | 해당 주문 테이블의 `status` 컬럼을 `toStatus`로 UPDATE                                                                                               |
| 3. 이력 저장   | `order_status_history` 테이블에 INSERT (`order_no`, `from_status`, `to_status`, `changed_at`, `changed_by`)                                        |
| 4. 트랜잭션    | 2~3을 같은 `@Transactional` 내에서 처리, 하나라도 실패하면 전체 롤백                                                                                         |


`scripts/check-transition.sh`는 DB에서 특정 상태의 허용 전이를 조회하는 보조 스크립트이다.

### 요약 표


| 폴더                 | name              | 로드 방식                                    | 용도                     |
| ------------------ | ----------------- | ---------------------------------------- | ---------------------- |
| `api-scaffolding/` | `api-scaffolding` | 수동 호출 (`disable-model-invocation: true`) | 도메인 CRUD API 4파일 일괄 생성 |
| `status-workflow/` | `status-workflow` | 자동 (`paths` + `description` 매칭)          | 상태 전이 검증→업데이트→이력 절차    |


### Skills vs Rules vs Commands 비교


| 구분       | 저장 위치                       | 로드 방식                 | 역할                     |
| -------- | --------------------------- | --------------------- | ---------------------- |
| Rules    | `.cursor/rules/*.mdc`       | 프론트매터 조건에 따라 자동 주입    | “무엇을 지켜야 하는지” — 정적 지침  |
| Commands | `.cursor/commands/*.md`     | 사용자가 `/이름`으로 호출       | “무엇을 할지” — 작업 진입점      |
| Skills   | `.cursor/skills/*/SKILL.md` | `paths` 매칭 또는 에이전트 판단 | “어떤 형식·절차로 할지” — 작업 패턴 |


## 4. 실습 — 스킬 로드 및 동작 확인

### 4.1 스킬 파일 확인

`.cursor/skills/` 폴더에서 두 스킬 폴더를 열어 `SKILL.md`의 프론트매터(`name`, `description`, `paths`, `disable-model-invocation`)를 확인한다.

### 4.2 `api-scaffolding` 스킬로 테스트 도메인 생성

`api-scaffolding` 스킬의 동작을 체험한다. 에이전트에게 다음과 같이 요청한다.

```
api-scaffolding 스킬을 참조해서 SampleTest 도메인의 CRUD API를 생성해 줘

```

에이전트가 `references/` 디렉터리의 템플릿(TemplateController.java, TemplateService.java, TemplateMapper.java, TemplateMapper.xml)을 기반으로 아래 4개 파일을 생성하는지 확인한다.


| 파일           | 경로                                                                          |
| ------------ | --------------------------------------------------------------------------- |
| Controller   | `backend/src/main/java/com/execnt/wms/controller/SampleTestController.java` |
| Service      | `backend/src/main/java/com/execnt/wms/service/SampleTestService.java`       |
| Mapper 인터페이스 | `backend/src/main/java/com/execnt/wms/mapper/SampleTestMapper.java`         |
| MyBatis XML  | `backend/src/main/resources/mapper/SampleTestMapper.xml`                    |


생성된 파일에서 다음을 확인한다.

- Controller에 `@RestController`, `@RequestMapping` 어노테이션이 있는가
- Service에 `@Service` 어노테이션이 있는가
- Mapper 인터페이스에 `@Mapper` 어노테이션이 있는가
- MyBatis XML의 `namespace`가 Mapper 인터페이스의 FQCN과 일치하는가
- 프로젝트 Rules(02-java-backend.mdc, 03-mybatis-mapper.mdc)의 네이밍·계층 규칙이 반영되어 있는가

### 4.3 테스트 파일 삭제

확인이 끝나면 생성된 파일을 삭제한다. 에이전트에게 다음과 같이 요청한다.

```
실습으로 생성한 SampleTest 도메인 파일을 모두 삭제해 줘.
backend/src 하위의 SampleTest 관련 Java 파일 제거해.
```

4개 파일이 모두 삭제되었는지 확인한다. 이 파일들은 실습 확인 용도이므로 반드시 삭제하여 이후 단계에서 실제 개발 시 노이즈가 되지 않도록 한다.



## 5. 완료 기준

- `.cursor/skills/` 아래 2개 폴더(`api-scaffolding`, `status-workflow`)와 각 `SKILL.md`의 역할을 확인한다.
- `api-scaffolding` 스킬로 테스트 도메인을 생성하고 템플릿 기반 산출물을 확인한 뒤 삭제했다
- `paths`와 `description`에 의한 자동 로드, `disable-model-invocation: true`에 의한 수동 호출의 차이를 이해한다
- Rules(정적 지침), Commands(작업 진입점), Skills(작업 패턴)의 역할 구분을 설명할 수 있다



→ 다음: [05-agents.md](https://www.genspark.ai/05-agents.md)
