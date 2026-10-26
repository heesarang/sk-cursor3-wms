# DB 접속 안내 (AWS PostgreSQL)

> **허용된 네트워크에서 TLS로 직접 접속한다.** 실습 DB는 AWS PostgreSQL 17 서버이며 PC에 PostgreSQL 서버를 설치하지 않는다. 학생은 SSH 터널·개인 키 파일 없이 DBeaver로 접속하며, 서버 확인용 공개 CA 인증서만 등록한다.

접속 확인일: **2026-10-26**. 외부 TLS 접속이 활성화되어 있으며 강사가 허용한 공인 IP에서만 연결할 수 있다. 서버 주소는 고정 IP가 아니므로 교육 시작 전 환경 공지(Notion)를 확인한다.

서버 주소와 상태는 [환경 공지](https://app.notion.com/p/40530a7e09f081c2aaf0e0c485a78497)에서 확인한다. 설정 절차는 [노션 수강생 안내](https://app.notion.com/p/40430a7e09f081fb93efd63a246d3218)에도 있다. 노션 열람 권한은 강사가 별도로 안내한다.

## 1. 접속 정보

본인 실습 번호에 맞춰 입력한다. **이 안내 파일은 Git으로 배포하는 문서다.** 개인 비밀번호를 이 파일에 채우거나 커밋하지 말고, 강사에게 개별 전달받은 값을 DBeaver의 비밀번호 입력란에 넣는다.

| 항목 | 값 | 비고 |
|---|---|---|
| Host | 환경 공지의 Host | 서버 중지·시작 후 주소가 바뀔 수 있어 교육 당일 공지한다 |
| Port | 5432 | 고정 |
| Database | `wmsNN` | 본인 번호. 1번이면 `wms01` |
| Username | `studentNN` | 1번이면 `student01` |
| Password | 개별 전달받은 최신 비밀번호 | 이전에 저장한 값이 있다면 최신 값으로 교체 |
| SSL/TLS | `verify-full` | CA 인증서: `database/certs/training-db-ca.crt` |
| SSH | 사용하지 않음 | 학생에게 SSH 키를 배포하지 않음 |
| 기본 스키마 | `wms` | 빈 스키마가 미리 있다 |

본인 번호는 좌석표 또는 강사가 알려 준다. 다른 사람의 DB·계정으로 접속하지 않는다.

예를 들어 1번 학생은 환경 공지의 Host, Port `5432`, Database `wms01`, Username `student01`을 입력한다. Password는 별도 전달값이며, 아래 TLS 설정을 적용한 후 테스트한다. DBeaver의 Database에는 `wms`가 아니라 `wms01`처럼 개인 DB명을 넣는다. `wms`는 DB 안의 스키마 이름이다.

## 2. DBeaver 설정

1. 상단 메뉴 `Database` › `New Database Connection`을 연다.
2. `PostgreSQL`을 선택하고 `Next`를 누른다.
3. `Main` 탭에 Host, Port, Database, Username, Password를 입력한다. `Show all databases`는 끈다.
4. `SSH` 터널은 끈다. `SSL` 탭에서 `Use SSL`을 켜고 SSL mode를 `verify-full`로 설정한다. `CA Certificate`에 내려받은 `database/certs/training-db-ca.crt`의 절대 경로를 지정한다. `Client Certificate`와 `Client Private Key`는 비워 둔다. 인증서·호스트 검증을 끄지 않는다. 같은 설정을 Driver properties에서 할 경우 `sslmode=verify-full`, `sslrootcert=CA 인증서의 절대 경로`를 지정한다.
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
# 저장소 루트에서 실행. 본인 번호와 공지된 최신 주소로 수정한다.
export PGHOST="<환경 공지의 Host>" PGPORT="5432" PGDATABASE="wms01" PGUSER="student01"
export PGSSLMODE="verify-full" PGSSLROOTCERT="$(pwd)/database/certs/training-db-ca.crt"
psql -W -v ON_ERROR_STOP=1 -c "SELECT current_database(), current_user, current_schema();"
```

비밀번호는 `-W` 프롬프트에 입력한다. 명령문·스크립트·Git에 비밀번호를 적지 않는다. PowerShell이면 `export` 대신 `$env:PGHOST="<Host>"`처럼 한 줄씩 설정한다.

CA 인증서는 공개 배포 파일이며 계정 비밀번호나 SSH 개인 키가 아니다. 강사에게 직접 전달받은 파일을 써도 된다.

## 4. Spring Boot 연결 (개발 단계)

Spring Boot는 `.env.example`을 자동으로 읽지 않는다. 터미널 또는 IDE 실행 설정에 환경변수를 넣는다.

```bash
# 본인 DB명과 CA 인증서의 실제 절대 경로로 수정한다.
export SPRING_DATASOURCE_URL="jdbc:postgresql://<환경 공지의 Host>:5432/wms01?currentSchema=wms&sslmode=verify-full&sslrootcert=<저장소 절대경로>/database/certs/training-db-ca.crt"
export SPRING_DATASOURCE_USERNAME="student01"
# 비밀번호를 명령 기록에 직접 남기지 않고 입력한다 (Git Bash).
read -r -s -p "DB password: " SPRING_DATASOURCE_PASSWORD
export SPRING_DATASOURCE_PASSWORD
```

위 JDBC URL의 인증서 경로는 예시다. 본인 PC에 저장한 인증서 경로로 바꾸고, 공백·특수문자가 있으면 URL 인코딩한다. 접속 주소가 바뀌면 JDBC URL도 수정한다. 환경변수와 psql용 `PG...` 변수는 별개이며, 실제 비밀번호를 코드·공개 파일·명령 기록에 남기지 않는다.

## 5. 접속이 안 될 때

| 증상 | 원인 후보 | 조치 |
|---|---|---|
| `Connection timed out` / 연결 거부 | 교육장 IP 미허용, 서버 중지, Host 오타 | 최신 Host와 허용 네트워크를 확인한 후 강사 호출 |
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
