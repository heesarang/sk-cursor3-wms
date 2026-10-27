# WMS 실습 수행 순서와 환경 준비

08번 순차 개발을 시작할 때 이 순서대로 진행한다. 요구사항을 분석하고 DB 모델을 작성한 다음, 개발 환경을 준비한다. `@db-architect`는 검토한 모델을 입력으로 받아 SQL 적용·검증과 초기 데이터를 완성한다. 이후 UI·백엔드·프론트엔드를 구현한다.

대상은 Windows와 Vue 3 CDN 방식의 WMS 실습이다. 작업은 Cursor에서 연 저장소 루트를 기준으로 한다. 서버 주소는 [환경 공지](https://app.notion.com/p/40530a7e09f081c2aaf0e0c485a78497), 계정은 강사가 전달한 본인 번호를 사용한다.

## 1. 전체 수행 순서

처음 준비한다면 [프로그램 목록과 다운로드](setup/00-downloads.md) → [Cursor 설치·로그인·실습 폴더 열기](setup/00-cursor.md)부터 진행한다. 교육 전 설치를 마친 도구는 수업의 해당 단계에서 설정·접속을 확인한다.

| 순서 | 수행할 일 | 완료 확인 | 상세 안내 |
|---|---|---|---|
| 0 | 프로그램 준비, Cursor 설치·로그인, 실습 폴더 열기 | 로그인과 Agent 응답 확인, 루트에 `.cursor`, `backend`, `database`, `docs`가 보임 | [다운로드 목록](setup/00-downloads.md), [Cursor 설치](setup/00-cursor.md) |
| 1 | PRD 읽기와 `@analyst` 실행 | F1~F4 요구사항과 역할별 Task 작성 | [08번 §4.1](08-sequential-dev.md#41-분석설계--analyst) |
| 2 | DB 표준 검토와 모델링 | 개념 모델, 관계, DDL 초안, 업무 규칙 검토 결과 | 이 문서 2절 |
| 3 | Java 설치와 환경변수 설정 | `java`, `javac`, `JAVA_HOME`이 같은 JDK를 가리킴 | [화면별 안내](setup/03-java.md) |
| 4 | Gradle Wrapper 확인 | `gradlew.bat --version`과 `help` 성공 | [화면별 안내](setup/04-gradle.md) |
| 5 | DBeaver 설치와 개인 DB 접속 | 본인 DB·계정·`wms` 스키마 확인 | [화면별 안내](setup/05-dbeaver.md) |
| 6 | PostgreSQL MCP 설정 | Cursor에서 본인 DB로 SELECT 성공 | [화면별 안내](setup/06-mcp.md) |
| 7 | Live Server 설치 | 확장 설치 확인, 실행할 폴더 확인 | [화면별 안내](setup/07-live-server.md) |
| 8 | `@db-architect`로 확정 모델 적용과 검증 | 표준 점검 PASS, 시드·데이터 사전, 인계 자료 완성 | 8절, [08번 §4.2](08-sequential-dev.md#42-db-적용과-검증--db-architect) |
| 9 | `@ui-designer` | 입고·출고·대시보드 UI 설계서 | 08번 §4.3 |
| 10 | `@backend-developer` | 빌드·서버 기동 성공, REQ §5 갱신 | 08번 §4.4 |
| 11 | `@test-backend` | 정상·비정상 API 검증 결과 | 08번 §4.5 |
| 12 | `@frontend-developer` | Vue 화면 생성과 Live Server 실행 | 08번 §4.6 |
| 13 | `@test-integration` | 화면 → API → DB 흐름 확인 | 08번 §4.7 |

Git은 실습 자료 보관·배포에 사용한다. 이 절차에 공용 저장소 push나 브랜치 실습은 포함하지 않는다. MCP를 사용하지 못하면 강사와 확인하여 DBeaver·psql로 SQL을 실행하고 같은 완료 기준을 충족한다.

## 2. DB 모델링을 먼저 진행하기

이 단계는 Cursor와 문서만으로 진행한다. Java·Gradle·MCP가 없어도 모델과 SQL 파일을 작성할 수 있다. **DB 적용은 환경 준비 뒤 8단계에서 진행한다.**

### 2.1 입력과 범위 확인

기본 PRD `docs/01.analysis/01.rfp/wms_prd.md`, analyst가 만든 REQ·DB Task, `.cursor/rules/06-database.mdc`를 읽는다. 기본 범위는 F1 입고, F2 출고, F3 대시보드, F4 상태 전이다. 추가 PRD는 기본 실습 완료 후 별도 안내에 따라 진행한다.

### 2.2 개념 모델과 관계 검토

일반 Cursor 채팅에서 아래 프롬프트를 실행한다. 아직 `@db-architect`를 호출하지 않는다.

```text
docs/01.analysis/01.rfp/wms_prd.md와 생성된 요구사항·DB Task를 읽고
F1~F4의 개념 모델을 만들어 줘.
엔터티, 핵심 속성, 관계와 카디널리티, 업무 식별자, 확인 질문을 정리해.
입고·출고 주문과 라인, 센터·상품, 공통코드, 상태 전이 규칙과 이력을 검토해.
아직 DDL을 생성하거나 DB에 접속하지 마.
결과는 database/docs/wms-model.md에 정리해.
```

주문과 라인의 1:N 관계, 주문과 상품의 관계를 라인으로 표현했는지, 상태 전이와 변경 이력을 구분했는지 확인한다. 모호한 업무 규칙은 강사와 답을 정한 뒤 문서에 반영한다.

### 2.3 논리 모델과 DDL 초안 작성

```text
검토한 database/docs/wms-model.md와 .cursor/rules/06-database.mdc를 기준으로
테이블별 PK·FK·UNIQUE·CHECK·NULL 허용·타입과 필요한 인덱스를 정리해.
PostgreSQL 17 DDL을 database/schemas/wms_ddl.sql에 작성해.
모든 테이블·컬럼에 한글 COMMENT를 넣어.
DB·계정·권한은 제공되므로 CREATE DATABASE, CREATE ROLE, ALTER ROLE,
GRANT, REVOKE는 작성하지 마. 스키마는 wms를 사용해.
기존 DDL이 있으면 덮어쓰기 전에 차이를 설명해.
파일만 작성하고 SQL 실행·데이터 삭제·스키마 초기화는 하지 마.
```

### 2.4 업무 규칙 검토와 적용 후보 확정

```text
PRD의 업무 규칙이 wms_ddl.sql의 어떤 테이블·컬럼·제약으로 표현되는지 표로 정리해.
DB 제약으로 보장하는 규칙과 애플리케이션에서 구현할 규칙을 구분해.
누락·충돌·확인 질문과 결정 내용을 database/docs/wms-model.md에 반영해.
DDL을 임의로 다시 설계하거나 DB에 적용하지 마.
```

학생과 강사가 모델을 검토하고 적용할 DDL을 정한다. 형식 표준과 실제 SQL 실행 검증은 DB 연결 후 수행한다. **모델 검토 완료와 DB 적용 완료는 별개다.**

[DB 모델링 실습](../../database/README.md)의 Lab 1, 2-1, 2-2, 2-4가 이 단계에 해당한다. Lab 0, 2-3, 2-5의 DB 적용과 Lab 3은 환경 준비 후 8단계에서 이어 간다.

각 환경 준비 안내는 [노션 수강생 페이지](https://app.notion.com/p/40630a7e09f0819f9e11cc3022a93e19)에서도 볼 수 있다.

## 3. Java 설치와 환경변수

[3. Java 설치와 환경변수](setup/03-java.md)

JDK 21 설치 → JAVA_HOME·Path 설정 → java·javac 실행 경로 확인. 다운로드 선택과 Windows 설정 진입 화면을 참고한다.

## 4. Gradle Wrapper와 실행 환경 준비

[4. Gradle Wrapper 준비](setup/04-gradle.md)

배포된 Wrapper 파일 확인 → --version·help 실행 → application.yml 준비. Gradle을 전역 설치하지 않는다.

## 5. DBeaver와 개인 DB 접속

[5. DBeaver와 개인 DB 접속](setup/05-dbeaver.md)

PostgreSQL 연결 생성 → 개인 계정 입력 → SSL require → 연결 테스트 → 본인 DB·계정 확인. 앱 환경변수도 이 페이지에서 준비한다.

## 6. PostgreSQL MCP 연결

[6. PostgreSQL MCP 연결](setup/06-mcp.md)

Node.js 준비 → MCP 예제 설정 → wms-lab 프로필 등록 → Cursor에서 SELECT 확인. DBeaver 접속을 먼저 확인한다.

## 7. Live Server 설치

[7. Live Server 설치와 실행](setup/07-live-server.md)

확장 설치 확인 → 프론트 파일 생성 후 HTTP 실행 → 백엔드 구현 후 API 연결 확인. 설치 상태와 구현 후 실행 예시를 구분한다.

## 8. 환경 준비 후 DB 적용과 검증

모델링 초안과 REQ·Task를 준비한 상태에서 [08번 §4.2](08-sequential-dev.md#42-db-적용과-검증--db-architect)의 `@db-architect` 프롬프트를 실행한다. 검토한 모델을 활용하며 처음부터 다시 설계하지 않는다.

진행 순서는 **대상 DB 확인 → DDL 검토·적용 → 표준 점검 → 필요한 수정·재검토 → 기준 모델 확정 → 시드 → 데이터 검증 → 데이터 사전**이다. 강사가 공통 기준 모델을 지정하면 그 모델과의 차이를 확인한 후 적용한다. 이미 적용된 테이블이 있으면 자동 DROP·초기화 대신 현재 상태를 먼저 비교한다.

DB 상세 실습의 Lab 2-3·2-5·3을 여기서 수행한다. SQL 파일은 실제로 작성·검토된 뒤 실행한다. 없는 시드·검증 파일을 실행하거나, 프롬프트만 전달한 것을 DB 적용 완료로 판단하지 않는다.

### 개발 단계로 넘어가는 확인표

- [ ] 요구사항·Task, 모델링 검토 결과, 기준 `wms_ddl.sql`이 준비되어 있다.
- [ ] DBeaver와 사용할 경우 MCP에서 본인 DB·계정을 확인했다.
- [ ] 실제 DB에 DDL이 반영되어 있고 표준 점검 결과를 확인했다.
- [ ] 확정 모델에 맞는 시드와 데이터 사전이 준비되었다.
- [ ] Java·Gradle 준비와 Live Server 설치를 마쳤다.
- [ ] 백엔드 실행 환경에 `SPRING_DATASOURCE_*`를 설정할 수 있다.

## 9. 개발과 실행 확인

이후에는 08번 §4.3~4.7의 프롬프트와 완료 기준을 따른다.

백엔드 구현 후, DB 환경변수를 설정한 PowerShell에서 실행한다.

```powershell
Set-Location backend
.\gradlew.bat build
.\gradlew.bat bootRun
```

별도 터미널에서 `curl.exe -I http://localhost:8080/v3/api-docs`로 상태 코드를 확인하고 Swagger UI를 연다. API 테스트를 마친 뒤 프론트 코드를 생성하고 Live Server를 실행한다. `frontend/js/api.js`의 API 주소를 백엔드와 맞추고 브라우저에서 목록 조회와 상태 변경을 확인한다. API만 성공하고 화면이 실패하면 CORS와 Network 탭을 확인한다.

기동 터미널에서 `Ctrl+C`로 서버를 종료한다. 09번 자동 위임 실습은 별도 실습이며, 이 과정을 마쳤다는 이유로 소스나 DB를 바로 초기화하지 않는다.
