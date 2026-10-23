# 05. Agents — 역할별 보조 에이전트

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. Agents란

Agents는 특정 역할을 가진 보조 에이전트를 정의한 파일이다. `.cursor/agents/` 폴더에 `.md` 파일로 저장하며, 파일명이 곧 에이전트 식별자가 된다. 채팅에서 `@에이전트명`으로 호출하거나, 오케스트레이터가 `/에이전트명`으로 작업을 위임할 수 있다.

Rules가 "무엇을 지켜야 하는지", Commands가 "어떤 순서로 실행하는지", Skills가 "어떤 형식으로 만드는지"를 정의한다면, Agents는 "누가 하는지"를 정의한다. 각 에이전트는 자신의 역할과 행동 원칙에 따라 작업을 수행하며, 프로젝트의 Rules와 Skills를 자동으로 참조한다.

## 2. 에이전트 파일 형식

각 에이전트 파일 상단에 YAML 프론트매터를 작성한다.

```yaml
---
name: 에이전트-식별자
description: "에이전트 역할 요약. 어떤 요청 시 사용되는지 명시"
model: inherit
readonly: false
---
```

필드의 역할은 다음과 같다.

- **name** — 에이전트 식별자. 파일명과 일치시킨다.
- **description** — 에이전트의 역할과 활성화 조건. "proactively 사용한다"로 끝나는 문장은 Cursor가 관련 요청을 감지했을 때 자동으로 이 에이전트를 선택하는 힌트가 된다.
- **model** — 사용할 모델. `inherit`은 현재 채팅에서 선택된 모델을 그대로 사용한다는 의미이다.
- **readonly** — `true`이면 파일 수정 없이 읽기·분석만 수행한다.

오케스트레이터 에이전트에는 추가로 `is_background: false` 필드가 있으며, 이는 백그라운드 실행이 아닌 사용자와 대화하며 진행함을 의미한다.

본문에는 역할, 행동 원칙, 실행 순서(오케스트레이터의 경우), 산출물 위치를 작성한다.

## 3. 프로젝트에 구성된 Agents

`.cursor/agents/` 폴더에 8개의 에이전트가 제공되어 있다. 역할에 따라 분석·설계, 개발, 테스트, 총괄의 네 그룹으로 나뉜다.

### 분석·설계 그룹

#### 3.1 `analyst.md` — 분석/설계 에이전트

```yaml
---
name: analyst
description: "요구사항을 분석하여 API 명세, 도메인 모델, 프로젝트 구조, 에이전트별 Task를 산출하는 에이전트. 분석, 설계, Task 분해, 작업 분배 요청 시 proactively 사용한다."
model: inherit
readonly: false
---
```

요구사항 문서와 기존 산출물을 읽고, 개발에 필요한 설계 산출물과 Task를 만든다. 요구사항 문서를 반드시 먼저 읽고 시작하며, 기존 DB 스키마나 코드가 있으면 반영한다. Task는 담당 에이전트가 독립적으로 실행할 수 있도록 필요한 모든 정보를 포함하고, 병렬 실행 가능한 Task는 의존성 없이 분리하며, 각 Task에 완료 조건을 명시한다.

#### 3.2 `ui-designer.md` — UI 설계 에이전트

```yaml
---
name: ui-designer
description: "화면 레이아웃, 컴포넌트 구성, 상호작용 흐름을 설계하는 에이전트. UI 설계, 화면 설계, 와이어프레임 요청 시 proactively 사용한다."
model: inherit
readonly: false
---
```

요구사항과 API 명세를 기반으로 화면별 UI 설계서를 만든다. API 명세가 있으면 반드시 참조하여 연동 매핑을 포함하고, 화면 간 일관된 UX 패턴을 유지한다. 와이어프레임(ASCII 또는 Markdown)을 포함하며, 에러/예외 시 사용자 피드백을 반드시 설계에 포함한다. 한국어 UI를 기본으로 한다.

#### 3.3 `db-architect.md` — DB 설계 에이전트

```yaml
---
name: db-architect
description: "DB 스키마 설계, DDL 작성, 초기 데이터 생성을 수행하는 에이전트. 데이터베이스 설계, 테이블 생성, SQL 작업 시 proactively 사용한다."
model: inherit
readonly: false
---
```

요구사항 문서를 기반으로 데이터베이스를 설계하고 SQL을 작성한다. DDL → 초기 데이터 → 검증 순서로 작업하며, 테이블 간 참조 무결성을 고려한다. 실행 즉시 개발 시작 가능한 상태의 SQL을 만들고, 작업 완료 후 SQL을 직접 실행하여 오류가 없는지 확인한다.

### 개발 그룹

#### 3.4 `backend-developer.md` — 백엔드 개발 에이전트

```yaml
---
name: backend-developer
description: "설계 문서와 Task를 기반으로 백엔드 코드를 구현하는 에이전트. 백엔드 개발, API 구현, 서비스/매퍼 구현 요청 시 proactively 사용한다."
model: inherit
readonly: false
---
```

Task에 명시된 설계 문서를 참조하여 백엔드 코드를 구현한다. Controller → Service → Mapper → MyBatis XML 순서로 작업하며, 프로젝트의 Rules를 준수한다. 컴파일 오류가 없는지 빌드하여 확인하고, 작업 범위를 벗어나는 파일은 수정하지 않는다.

#### 3.5 `frontend-developer.md` — 프론트엔드 개발 에이전트

```yaml
---
name: frontend-developer
description: "UI 설계서와 API 명세를 기반으로 프론트엔드 화면을 구현하는 에이전트. 프론트엔드 개발, 화면 구현, UI 구현 요청 시 proactively 사용한다."
model: inherit
readonly: false
---
```

UI 설계서와 API 명세를 참조하여 프론트엔드 화면을 구현한다. UI 설계서의 레이아웃과 컴포넌트 구성을 따르고, API 명세에 맞게 연동 코드를 작성한다. 에러 처리와 사용자 피드백을 반드시 구현하며, 작업 범위를 벗어나는 파일은 수정하지 않는다.

### 테스트 그룹

#### 3.6 `test-backend.md` — 백엔드 테스트 에이전트

```yaml
---
name: test-backend
description: "백엔드 API를 호출하여 DB 연동과 비즈니스 로직이 정상 동작하는지 검증하는 에이전트. 백엔드 테스트, API 테스트, DB 연동 테스트 요청 시 proactively 사용한다."
model: inherit
readonly: false
---
```

백엔드를 **실제로 기동**한 뒤 curl 또는 셸로 API를 검증한다(본 레포 입고 시 **표준 재현**: 루트 `scripts/smoke-inbound-api.sh`). 정상 케이스와 비정상 케이스(잘못된 상태 전이 등)를 모두 테스트하고, 결과를 성공/실패로 명확히 정리한다. Testcontainers 등 임베디드 테스트는 사용자가 명시할 때만 사용한다. 실패 시 원인을 분석하고 수정 방안을 제시하며, 테스트 결과 리포트를 산출한다.

#### 3.7 `test-integration.md` — 통합 테스트 에이전트

```yaml
---
name: test-integration
description: "프론트엔드와 백엔드 간 연동이 정상 동작하는지 검증하는 에이전트. 통합 테스트, E2E 테스트, 프론트-백엔드 연동 테스트 요청 시 proactively 사용한다."
model: inherit
readonly: false
---
```

프론트엔드 화면에서 백엔드 API까지 전체 흐름이 정상 동작하는지 검증한다. 화면 → API 호출 → DB 반영 → 화면 갱신의 전체 흐름을 확인하고, API 응답 형식이 프론트엔드 기대와 일치하는지 검증한다. 에러 케이스에서 적절한 메시지가 표시되는지 확인하며, 테스트 결과 리포트를 산출한다.

### 총괄

#### 3.8 `orchestrator.md` — 오케스트레이터 에이전트

```yaml
---
name: orchestrator
description: "전체 개발 프로세스를 총괄하여 에이전트들에게 작업을 위임하고 결과를 검증하며 진행하는 에이전트. 전체 빌드, 자동 완성, 오케스트레이션 요청 시 proactively 사용한다."
model: inherit
readonly: false
is_background: false
---
```

PRD로부터 전체 개발 프로세스를 총괄한다. 다른 에이전트에게 작업을 위임하고, 산출물을 검증하고, 다음 단계로 진행한다. 실행 순서는 `.cursor/agents/orchestrator.md`와 동일하다.

| 순서 | 단계 | 위임 대상 |
|------|------|-----------|
| 1 | 분석/설계 | `/analyst` — PRD 분석 및 Task 분해 |
| 2 | UI 설계 | `/ui-designer` — 화면 설계 |
| 3 | 백엔드 개발 | `/backend-developer` — Task별 병렬 위임 (입고·출고·대시보드) |
| 4 | 백엔드 테스트 | `/test-backend` — API 검증 |
| 5 | 프론트엔드 개발 | `/frontend-developer` — 화면 구현 |
| 6 | 통합 테스트 | `/test-integration` — E2E 검증 |

> DB DDL이 `database/schemas/`에 이미 있으면 `/db-architect` 단계는 생략한다.

각 단계 산출물이 다음 단계 입력으로 충분한지 검증하며, 병렬 실행 가능한 단계는 백엔드 도메인별 Task뿐이다. backend-developer 이후(test-backend → frontend → test-integration)는 순차 실행한다. 에이전트가 실패하면 원인을 파악하고 재시도 또는 수정을 지시한다. 전 과정의 진행 상황을 사용자에게 보고하고, 모든 단계 완료 후 최종 빌드 + 실행 확인으로 마무리한다.

### 요약 표

| 파일 | name | 그룹 | 역할 |
|------|------|------|------|
| `analyst.md` | analyst | 분석·설계 | PRD → 설계 산출물·Task 분해 |
| `ui-designer.md` | ui-designer | 분석·설계 | 화면별 UI 설계서 |
| `db-architect.md` | db-architect | 분석·설계 | DDL·초기 데이터 SQL |
| `backend-developer.md` | backend-developer | 개발 | Controller/Service/Mapper 구현 |
| `frontend-developer.md` | frontend-developer | 개발 | Vue 3 화면·API 연동 |
| `test-backend.md` | test-backend | 테스트 | API 호출·DB 연동 검증 |
| `test-integration.md` | test-integration | 테스트 | 프론트↔백엔드 E2E 검증 |
| `orchestrator.md` | orchestrator | 총괄 | 전체 프로세스 위임·검증·진행 |

### 에이전트 협업 흐름

```
orchestrator
  ├─→ analyst              ─→ 설계 산출물 + Task
  ├─→ ui-designer          ─→ UI 설계서
  ├─→ backend-developer    ─→ 백엔드 코드 (병렬: 입고/출고/대시보드)
  ├─→ test-backend         ─→ API 테스트 리포트
  ├─→ frontend-developer   ─→ 프론트엔드 화면
  └─→ test-integration     ─→ E2E 테스트 리포트
```

## 4. 완료 기준

- `.cursor/agents/` 아래 8개 파일의 이름, 역할, 그룹 구분을 설명할 수 있다
- 프론트매터의 `name`, `description`, `model`, `readonly` 필드의 역할을 이해한다
- 오케스트레이터가 다른 6개 에이전트(db-architect 제외 시)에게 작업을 위임하는 순서와 병렬 실행 구간을 설명할 수 있다
- Agents는 "누가 하는지"를 정의하며, Rules(지침)·Commands(진입점)·Skills(패턴)와 함께 동작함을 이해한다

→ 다음: [06-hooks.md](06-hooks.md)
