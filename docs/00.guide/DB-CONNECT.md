# DB 접속 안내 (AWS PostgreSQL)

> 실습 DB는 AWS에 있는 PostgreSQL 17 서버다. PC에 PostgreSQL을 설치하지 않는다. SSH 터널·키 파일도 쓰지 않는다. 접속은 DBeaver로 하고, 필요하면 psql·Spring Boot에도 같은 값을 쓴다.

## 1. 접속 정보

강사가 실습 시작 때 안내하는 값을 아래 표에 옮겨 적는다. 이 파일은 Git에 커밋하지 않으므로 값을 직접 채우지 말고 메모장에 따로 적어 둔다.

| 항목 | 값 | 비고 |
|---|---|---|
| Host | 강사 안내 | 서버 주소 |
| Port | 5432 | 고정 |
| Database | `wmsNN` | 본인 번호. 1번이면 `wms01` |
| Username | `studentNN` | 1번이면 `student01` |
| Password | 강사 안내 | 최초 접속 후 변경 여부는 강사 안내 |
| SSL | 강사 안내 | TLS 사용 시 모드 지정 |
| 기본 스키마 | `wms` | 빈 스키마가 미리 있다 |

본인 번호는 좌석표 또는 강사가 알려 준다. 다른 사람의 DB·계정으로 접속하지 않는다.

## 2. DBeaver 설정

1. 상단 메뉴 `Database` › `New Database Connection`을 연다.
2. `PostgreSQL`을 선택하고 `Next`를 누른다.
3. `Main` 탭에 Host, Port, Database, Username, Password를 입력한다. `Show all databases`는 끈다.
4. `SSL` 탭에서 강사가 안내한 모드로 설정한다. 안내가 없으면 비워 둔다.
5. `Test Connection`을 누른다. 드라이버 다운로드 창이 뜨면 `Download`를 누른다.
6. `Connection is established`가 나오면 `Finish`를 누른다.
7. SQL 편집기(`Ctrl+]`)에서 아래 SQL을 실행한다.

```sql
SELECT current_database(), current_user, current_schema(), version();
```

기대값은 본인 DB(`wmsNN`), 본인 계정(`studentNN`), `wms`, PostgreSQL 17이다. `current_schema()`가 `public`으로 나오면 `SET search_path TO wms;`를 실행한 뒤 다시 확인한다. 연결 편집 화면의 `Initialization` › `Default schema`에 `wms`를 넣어 두면 매번 설정하지 않아도 된다.

## 3. psql (선택)

`std_check.sql`처럼 psql 전용 명령이 있는 파일을 돌릴 때만 필요하다. Git Bash 기준이다.

```bash
export PGHOST=<Host> PGPORT=5432 PGDATABASE=<wmsNN> PGUSER=<studentNN>
psql -W -v ON_ERROR_STOP=1 -c "SELECT current_database(), current_user, current_schema();"
```

비밀번호는 `-W` 프롬프트에 입력한다. 명령문·스크립트·Git에 비밀번호를 적지 않는다. PowerShell이면 `export` 대신 `$env:PGHOST="<Host>"`처럼 한 줄씩 설정한다.

## 4. Spring Boot 연결 (개발 단계)

Spring Boot는 `.env.example`을 자동으로 읽지 않는다. 터미널 또는 IDE 실행 설정에 환경변수를 넣는다.

```bash
export SPRING_DATASOURCE_URL="jdbc:postgresql://<Host>:5432/<wmsNN>?currentSchema=wms"
export SPRING_DATASOURCE_USERNAME="<studentNN>"
export SPRING_DATASOURCE_PASSWORD="<비밀번호>"
```

TLS를 쓰는 경우 URL 끝에 강사가 안내한 파라미터(예: `&sslmode=require`)를 붙인다. 이 세 줄은 터미널 세션에만 남기고 파일에 저장하지 않는다.

## 5. 접속이 안 될 때

| 증상 | 원인 후보 | 조치 |
|---|---|---|
| `Connection timed out` | 교육장 IP 미허용, Host 오타 | Host 재확인 후 강사 호출 |
| `password authentication failed` | 비밀번호·계정 오타, 다른 번호 계정 | 번호 확인, Caps Lock 확인 |
| `database "wmsNN" does not exist` | Database 번호 오타 | 본인 번호 재확인 |
| `no pg_hba.conf entry ... SSL` | SSL 모드 불일치 | SSL 탭을 강사 안내대로 수정 |
| `current_schema()`가 `public` | 기본 스키마 미설정 | `SET search_path TO wms;` |
| `permission denied for schema wms` | 권한 문제 | `database/init/00_roles.sql` 결과를 강사에게 보여 준다 |
| DBeaver가 드라이버 다운로드 실패 | 사내망 프록시 | 강사 호출 |

3분 안에 풀리지 않으면 혼자 시간을 쓰지 말고 손을 든다.

## 6. 하지 않는 것

- 다른 학생 DB·계정으로 접속하지 않는다.
- `postgres` 같은 관리자 계정을 요청하거나 시도하지 않는다.
- DB 자체를 만들거나 계정·권한을 바꾸지 않는다.
- 비밀번호를 Git·메신저·Cursor 채팅 프롬프트에 붙여 넣지 않는다.
- 접속 직후 `wms` 스키마를 초기화하지 않는다. 빈 스키마가 정상 상태다.
