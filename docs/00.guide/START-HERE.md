# 실습 시작 안내

## 실습 흐름

WMS 요구사항을 읽고 DB 모델을 설계한 뒤, 백엔드와 프론트엔드를 구현하고 동작을 검증합니다.

## 제공하는 것

- 기본 WMS PRD와 문서·개발·업무 표준
- Cursor Rule·Command·Skill·Agent 예시
- Java 21 Gradle 프로젝트와 환경변수 기반 접속 설정 예시
- 서버 기동·종료 및 API 검증 Bash 스크립트

## 실습에서 만드는 것

- 요구사항·Task·UI 설계 문서
- `database/schemas/wms_ddl.sql`과 확정 모델 기준 데이터 사전
- 확정 모델과 일치하는 시드·검증·데이터 초기화 SQL
- 백엔드 및 프론트엔드 코드

DB 설계는 db-architect 또는 모델링 실습으로 진행합니다. 확정한 DDL이 있으면 후속 개발 단계에서 다시 만들지 않습니다.

## 실행 전 확인

서버 실행·API 검증 스크립트는 애플리케이션 구현 후 사용합니다. 파일을 지우거나 DB를 초기화하기 전에는 강사와 대상·단계를 확인합니다.

## 환경

Java 21 및 Git이 필요합니다. Gradle은 Wrapper를 사용합니다. Bash 스크립트는 Git Bash/WSL 등의 환경에서 실행합니다. Hooks의 일부는 Python을 필요로 합니다. 프론트는 현재 CDN 규약이므로 Node.js는 기본 실행 필수가 아니며, 선택 MCP와 포맷 도구를 사용하는 경우에만 별도 확인합니다.

DB 접속 주소·계정·비밀번호는 강사가 별도로 안내합니다. 접속 방법은 [DB 접속 안내](DB-CONNECT.md)를 참고하세요. 예시 파일을 복사한 뒤 셸 또는 IDE에서 환경변수를 설정합니다. DB 객체를 자동 생성하거나 적용하는 설정은 포함하지 않습니다. (선택) 에이전트가 DB 도구를 쓰게 하려면 [MCP 설정](11-mcp.md)을 진행합니다.

## 모델 정책 (Cursor Premium $30 포함 사용량 안에서 끝내기)

실습 플랜은 Cursor Premium($30/월)이다. 포함 사용량은 Cursor 모델(Composer·Grok)에만 적용되고 주 단위로 다시 채워진다. 실습은 전 단계를 Composer 2.5로 한다. Claude·GPT·Gemini 같은 외부 모델은 선불 크레딧이 따로 필요하므로 실습에서는 쓰지 않는다.

| 단계 | 모델 | 이유 |
|---|---|---|
| 코드 생성·수정, DDL 작성, 시드, 테스트 | Composer 2.5 | Input $0.50 / Output $2.50 (100만 토큰당). Cursor 모델 중 최저가 |
| 개념 모델, 업무 규칙 리뷰, gap 해석, 설계 판단 | Composer 2.5 | 같은 모델 유지. Grok 4.7이 낫다는 공개 근거가 없고, 대화 중 모델을 바꾸면 캐시가 사라진다 |
| 금지 | Claude·GPT·Gemini 등 외부 모델 | 포함 사용량 밖. 선불 크레딧 필요 |
| Auto | Cost 모드 | 개인 플랜은 Cost 모드만 제공. Cursor 모델 풀에서 차감 |

규칙 세 가지. 신규 개발의 orchestrator 실행은 1회만 하고 실패한 부분은 해당 Agent만 Composer로 다시 돌린다. 대화가 길어지면 새 채팅을 연다. Settings › Usage에서 주간 사용량이 70%를 넘으면 Composer 전용으로 전환하고 강사에게 알린다. `.cursor/agents/*.md`의 `model: inherit`는 바꾸지 않는다. 외부 모델을 지정하면 크레딧이 없어 그 Agent가 실패한다.
