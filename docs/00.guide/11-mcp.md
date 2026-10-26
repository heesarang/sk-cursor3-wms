# 11. MCP — PostgreSQL 연동 (선택)

> DB Host·계정·TLS는 [DB 접속 안내](DB-CONNECT.md)를 먼저 확인하세요. 환경 준비는 [실습 시작 안내](START-HERE.md)를 참고하세요.

## 1. MCP란

MCP(Model Context Protocol)는 Cursor가 외부 도구(여기서는 PostgreSQL)와 대화형으로 연동하는 방식이다. 에이전트가 채팅 안에서 스키마 조회, 읽기 전용 SQL, DDL·DML 실행 등을 **도구 호출**로 수행할 수 있다.

이 저장소는 **Microsoft [@microsoft/postgres-mcp](https://github.com/microsoft/postgres-mcp)** 를 stdio 방식으로 붙이는 구성을 예시로 제공한다. MCP 없이도 DBeaver·psql·Spring Boot로 실습을 완료할 수 있으며, MCP는 DDL 적용·스키마 확인·데이터 점검을 에이전트에게 맡기고 싶을 때 켜면 된다.

## 2. 파일 구조

```
.cursor/
├── mcp.json.example   ← 저장소에 포함 (복사 원본)
└── mcp.json           ← 로컬 전용 (.gitignore). 본인 PC에서만 생성

database/tools/
└── setup_postgres_mcp.ps1   ← Windows PowerShell 프로필 등록 스크립트 (선택)

~/.postgres-mcp/
└── connections.yaml   ← 프로필 메타데이터 (패키지가 생성)

OS 키링 (Windows: 자격 증명 관리자)
└── postgres-mcp 서비스 아래에 DB 비밀번호 저장
```

| 파일 | Git | 역할 |
|------|-----|------|
| `.cursor/mcp.json.example` | 포함 | Cursor MCP 서버 정의 예시 |
| `.cursor/mcp.json` | **제외** | 실제 Cursor가 읽는 설정 |
| `database/tools/setup_postgres_mcp.ps1` | 포함 | `wms-lab` 등 이름으로 연결 프로필 등록 |
| `~/.postgres-mcp/connections.yaml` | 로컬 | Host·DB·User 등 (비밀번호는 **미포함**) |

비밀번호는 `mcp.json`·`connections.yaml`·Git에 넣지 않는다. [DB 접속 안내](DB-CONNECT.md)와 동일한 원칙이다.

## 3. 사전 요건

- **Node.js**와 `npx` (패키지를 매번 `-y`로 받아 실행)
- **Cursor**에서 MCP 기능 사용 가능한 버전
- 실습 DB에 **허용된 네트워크**에서 TLS(`sslmode=require`)로 접속 가능한 상태
- DBeaver 등으로 한 번 접속 테스트를 마친 Host·Database·Username·Password

## 4. mcp.json 만들기

1. 저장소 루트에서 예시를 복사한다.

   **PowerShell**

   ```powershell
   Copy-Item .cursor\mcp.json.example .cursor\mcp.json
   ```

   **Git Bash**

   ```bash
   cp .cursor/mcp.json.example .cursor/mcp.json
   ```

2. 내용은 아래와 같다. 서버 키 이름 `postgres`는 Cursor MCP 목록에 표시되는 이름이다.

```json
{
  "mcpServers": {
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_DEFAULT_PROFILE": "wms-lab"
      }
    }
  }
}
```

`POSTGRES_MCP_DEFAULT_PROFILE` 값(`wms-lab`)은 다음 절에서 등록하는 **연결 프로필 이름**과 같아야 한다. 다른 이름을 쓰면 `mcp.json`의 env 값도 같이 바꾼다.

> 프로젝트별 MCP 설정은 **워크스페이스** `.cursor/mcp.json`에 둔다. Cursor Settings UI에만 넣고 파일을 만들지 않으면 팀원과 설정이 어긋날 수 있다.

## 5. DB 연결 프로필 등록

연결 정보는 **저장된 프로필 + OS 키링 비밀번호** 방식을 권장한다. URI에는 비밀번호를 넣지 않는다.

### 5.1 PowerShell 스크립트 (Windows)

`database/tools/setup_postgres_mcp.ps1`을 연 뒤, 상단 `param` 블록의 Host·Database·User를 [DB 접속 안내](DB-CONNECT.md) 값으로 바꾸고 실행한다.

```powershell
# 예: 1번 학생, Host는 환경 공지 값
.\database\tools\setup_postgres_mcp.ps1 `
  -ProfileName wms-lab `
  -HostName "<환경 공지의 Host>" `
  -Database wms01 `
  -User student01
```

비밀번호는 `connection set-password` 프롬프트에 입력하며 Windows 자격 증명 관리자에 저장된다.

### 5.2 CLI 직접 실행 (Windows / macOS / Linux 공통)

```powershell
npx -y @microsoft/postgres-mcp connection add wms-lab `
  "postgresql://student01@<Host>:5432/wms01?sslmode=require"

npx -y @microsoft/postgres-mcp connection set-password wms-lab

npx -y @microsoft/postgres-mcp connection list
```

`connection list`에 `wms-lab`이 보이면 프로필 등록은 끝이다. Git Bash에서는 백틱(`\``) 대신 `\` 줄바꿈을 쓰거나 한 줄로 입력한다.

### 5.3 libpq 키=값 형식 (대안)

URI 대신 다음 형식도 사용할 수 있다.

```text
host=<Host> port=5432 user=student01 dbname=wms01 sslmode=require
```

## 6. Cursor에서 MCP 활성화

1. Cursor에서 **이 저장소 루트**를 연 상태인지 확인한다.
2. **Settings → MCP** (또는 **Cursor Settings → Tools & MCP**)로 이동한다.
3. `postgres` 서버가 목록에 있고 상태가 **연결됨(녹색)** 인지 확인한다.
4. 처음 연결 시 `npx`가 패키지를 받으므로 네트워크가 필요하며, 수십 초 걸릴 수 있다.

워크스페이스 `.cursor/mcp.json`을 수정한 뒤에는 MCP 서버 **Reload** 또는 Cursor 재시작이 필요할 수 있다.

## 7. 동작 확인

채팅(Agent 모드)에서 예를 들어 다음을 요청한다.

```text
postgres MCP로 연결 프로필 목록을 보여 주고, wms-lab에 연결한 뒤
SELECT current_database(), current_user, current_schema();
를 실행해줘.
```

기대 결과는 Database `wmsNN`, User `studentNN`, schema `wms`이다. `current_schema()`가 `public`이면 세션에서 `SET search_path TO wms;` 후 다시 확인한다.

DDL·시드 적용을 맡길 때는 강사 안내에 따라 진행한다. 예:

```text
postgres MCP로 database/schemas/wms_ddl.sql 내용을 내 wms01 DB에 적용해줘.
직접 실행 전에 적용할 문장 종류(DDL/DML)를 짧게 요약해줘.
```

운영 DB가 아닌 **본인 실습 DB**에만 적용한다.

## 8. 에이전트가 쓰는 도구 (요약)

| 도구 | 용도 |
|------|------|
| `postgres_mcp_list_connection_profiles` | 저장된 프로필 목록 |
| `postgres_mcp_connect` / `postgres_mcp_disconnect` | 프로필로 연결·해제 |
| `postgres_mcp_db_context` | 테이블·인덱스 등 CREATE 스크립트 조회 |
| `postgres_mcp_query` | 읽기 전용 SELECT |
| `postgres_mcp_modify` | DDL·DML (CREATE, INSERT, …) |

자율 에이전트에 쓸 때는 DB 계정 권한과 MCP 프로필 `access_mode`를 함께 제한하는 것이 안전하다. 실습에서는 본인 DB만 사용한다.

## 9. 문제 해결

| 증상 | 원인 후보 | 조치 |
|------|-----------|------|
| MCP 서버가 빨간색 / 시작 실패 | Node·npx 없음, 방화벽 | `node -v`, `npx -v` 확인. 회사망이면 npm 레지스트리 차단 여부 확인 |
| `connection list`에 프로필 없음 | 프로필 미등록·이름 불일치 | 5절 재실행. `mcp.json`의 `POSTGRES_MCP_DEFAULT_PROFILE`과 이름 일치 확인 |
| DB 연결 오류 | Host·TLS·IP 허용 | [DB 접속 안내](DB-CONNECT.md) 5절. DBeaver Test Connection 먼저 |
| `password authentication failed` | 키링 비밀번호 구버전 | `connection set-password wms-lab` 다시 실행 |
| 도구가 채팅에 안 보임 | MCP 비활성·Agent 아님 | Settings에서 MCP 활성, Agent 모드 사용 |
| `mcp.json`이 Git에 잡힘 | ignore 누락 | `.gitignore`에 `.cursor/mcp.json` 있는지 확인. 커밋하지 않음 |

Headless·CI처럼 키링을 쓸 수 없는 환경은 공식 문서의 `PGSQL_MCP_CONNECTION_STRING` 방식을 검토한다. **대화형 실습 PC에서는 저장 프로필 방식을 유지한다.**

## 10. 완료 기준

- `.cursor/mcp.json`을 예시에서 복사했고, 프로필 이름 env가 등록한 프로필과 같다.
- `connection list`에 해당 프로필이 보인다.
- Cursor MCP에서 `postgres` 서버가 연결된 상태다.
- 채팅에서 `current_database()` 등 간단한 SQL로 본인 DB 접속을 확인했다.

## 11. 핵심 포인트

MCP는 에이전트에게 **DB에 손대는 도구**를 준다. Rules와 Hooks가 코드·명령을 제한하더라도, MCP `modify`로 DDL이 실행될 수 있으므로 **본인 DB·본인 프로필**만 쓰고, 비밀번호는 키링에만 둔다. 팀 저장소에는 `mcp.json.example`만 두고, 실제 Host·계정·프로필은 각자 로컬에서 등록한다.

→ 이전: [10-change-request.md](10-change-request.md) · 선택 과제 · DB: [DB-CONNECT.md](DB-CONNECT.md)
