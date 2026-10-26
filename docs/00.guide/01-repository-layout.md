# 01. 저장소 구조와 문서 배치

> 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. 이번 단계에서 하는 일

이 프로젝트의 폴더 구조와 경로 규약을 파악합니다. 에이전트가 산출물을 어디에 저장하고, 어디에서 읽어오는지를 이해해야 이후 단계가 자연스럽게 연결됩니다.

## 2. 핵심 개념

`docs/01.analysis/` 는 RFP부터 요구·Task·UI 설계까지 분석 단계 산출물의 루트입니다. 번호 하위 폴더(`01.rfp` … `04.ui`)가 의미 단위입니다.

`database/schemas/` 는 DDL과 초기 데이터 SQL의 단일 소스(SoT)입니다. 에이전트가 DB 스크립트를 만들면 이 경로에 저장하고, 실제 DB 실행은 사용자 책임입니다.

`.cursor/` 에는 Rules, Commands, Skills, Agents, Hooks가 이미 구성되어 있습니다. 이후 단계에서 각 요소의 내용을 하나씩 살펴봅니다.

## 3. 경로 구조


| 경로                                  | 용도                                        |
| ----------------------------------- | ----------------------------------------- |
| `docs/01.analysis/01.rfp/`          | PRD 원문 (`wms_prd.md`) — 모든 분석·설계의 입력 기준. 추가 PRD `wms_prd-inventory-flow.md`(F5~F7 입고 등록·재고·재고 연동 출고)는 F1~F3 완료 후 선택 과제 |
| `docs/01.analysis/02.requirements/` | 요구사항 정의서                                  |
| `docs/01.analysis/03.tasks/`        | Task 정의서 (`*.task.md`)                    |
| `docs/01.analysis/04.ui/`           | UI 설계 HTML·Mock JSON                      |
| `database/schemas/`                 | DDL, 초기 데이터 SQL                           |
| `database/init/`, `tools/`, `seeds/`, `migrations/` | 권한 조회 SQL, 표준 점검·초기화 SQL, 시드(강사 배포), 변경 이력 |
| `database/certs/`                   | DB 서버 확인용 공개 CA 인증서 (접속 방법은 `docs/00.guide/DB-CONNECT.md`) |
| `scripts/`                          | 백엔드 기동·종료, API 검증 Bash 스크립트 |
| `backend/`                          | Spring Boot 소스 (Java 21, MyBatis, Gradle) |
| `frontend/`                         | Vue 3 CDN 소스 (Element Plus, Tailwind CSS) |
| `.cursor/rules/`                    | Rules — 프로젝트 지침 (`.mdc`)                  |
| `.cursor/commands/`                 | Commands — 슬래시 커맨드 (`.md`)                |
| `.cursor/skills/`                   | Skills — 작업 패턴 참고서 (`SKILL.md`)           |
| `.cursor/agents/`                   | Agents — 서브에이전트 정의 (`.md`)                |
| `.cursor/hooks/`                    | Hooks — 자동 실행 스크립트 (`.sh`)                |
| `.cursor/hooks.json.example`                | Hooks 설정 예시 (복사해 `hooks.json`으로 사용. 어떤 이벤트에 어떤 스크립트를 실행할지)          |


## 4. 실습

**4.1 PRD 파일 확인**

`docs/01.analysis/01.rfp/wms_prd.md`를 열어 내용을 훑어봅니다. 이 파일이 WMS 도메인의 요구사항 전문이며, 이후 에이전트가 분석·설계·개발의 입력으로 사용합니다.

**4.2 .cursor 하위 구성 확인**

`.cursor/` 폴더를 열어 아래 항목이 있는지 확인합니다.


| 확인 항목        | 위치                          |
| ------------ | --------------------------- |
| Rules 파일들    | `.cursor/rules/*.mdc`       |
| Commands 파일들 | `.cursor/commands/*.md`     |
| Skills 폴더들   | `.cursor/skills/*/SKILL.md` |
| Agents 파일들   | `.cursor/agents/*.md`       |
| Hooks 설정     | `.cursor/hooks.json.example`        |
| Hook 스크립트들   | `.cursor/hooks/*.sh`        |


**4.3 산출물 경로 확인**

`docs/01.analysis/` 아래에 `02.requirements/`, `03.tasks/`, `04.ui/` 폴더가 있는지, `database/schemas/` 폴더가 있는지 확인합니다. 에이전트가 만드는 산출물은 모두 이 경로에 저장됩니다.

## 5. 완료 기준

- PRD 파일(`docs/01.analysis/01.rfp/wms_prd.md`)의 위치와 역할을 이해했다.
- `.cursor/` 하위에 Rules, Commands, Skills, Agents, Hooks가 구성되어 있음을 확인했다.
- 산출물 경로(`docs/01.analysis/02~04`, `database/schemas/`, `backend/`, `frontend/`)를 파악했다.

## 6. 핵심 포인트

문서 파이프라인은 경로 규약이 곧 계약입니다. 에이전트가 산출물을 엉뚱한 경로에 만들면 다른 에이전트가 참조하지 못합니다. 이 경로 구조는 Rules(`01-project-context.mdc` 등)에도 명시되어 있어서, 에이전트가 작업할 때 자동으로 참조합니다.

→ 다음: [02-rules.md](02-rules.md)
