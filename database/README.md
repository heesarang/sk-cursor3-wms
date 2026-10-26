# DB 모델링·검증 실습 (2일차 · 90분)

요구사항(PRD)에서 개념 모델을 만들고, DB 표준 Rule에 맞춰 DDL을 쓰고, 도구로 형식을 점검하고, 업무 규칙을 사람이 리뷰한 뒤 기준 모델을 확정한다. 여기서 확정한 스키마를 이어지는 백엔드·프론트엔드 개발이 그대로 쓴다.

| Lab | 내용 | 시간 | 모델 |
|---|---|---|---|
| 0 | 접속 확인 | 5분 | — |
| 1 | DB 표준 Rule 검토 | 10분 | Composer |
| 2 | 개념 모델 → DDL → 표준 점검 → 업무 규칙 리뷰 → 기준 모델 확정 | 50분 | 전 단계 Composer |
| 3 | 권한 확인, 시드, 데이터 사전 | 20분 | Composer |
| — | 백엔드 인계 정리 | 5분 | — |

모델 정책은 `docs/00.guide/START-HERE.md` §모델 정책을 따른다. 전 단계 Composer 2.5다.

## 폴더

- `init/00_roles.sql` 학생 계정·DB·스키마 권한을 조회하는 읽기 전용 확인 SQL. 계정 생성은 강사가 별도로 관리한다
- `schemas/wms_ddl.sql` 기준 DDL. Lab 2에서 만든다
- `seeds/` 공통코드 → 기준정보 → 전이 규칙 → 샘플 순. Lab 3에서 만든다
- `migrations/` 기준 모델 확정 뒤의 변경 이력 `YYYYMMDD_NNN_설명.sql`
- `tools/std_check.sql` 표준 자동 점검(위반 0 = PASS), `tools/reset_schema.sql` 확정 전 초기화
- `docs/` ERD·테이블 정의서 (이번 차수 선택)
- `reports/` 로컬 점검 결과(커밋 제외)

## Lab 0. 접속 확인 (5분)

학생별 DB와 로그인 계정은 강사가 미리 생성한다. 1번은 `student01` → `wms01`, 2번은 `student02` → `wms02`처럼 배정되며 각 DB의 기본 스키마는 `wms`다. 본인 계정으로 DDL 작성·적용, 데이터 조회·수정, 앱 연결을 모두 수행한다. 별도의 소유자·앱·조회 전용 계정을 생성하지 않는다.

**DB 외부 접속 개방 공지 후 진행한다.** DBeaver에는 강사가 안내한 최종 Host, Port 5432, 본인 Database·Username·Password 및 TLS 설정을 입력한다. 학생은 SSH 터널·키 파일을 사용하지 않는다. PostgreSQL 서버는 PC에 설치하지 않아도 된다.

아래 명령은 `psql` 클라이언트가 설치된 Git Bash/WSL 등의 셸용이다. 강사가 안내한 `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`와 최종 TLS 관련 환경변수를 설정한 뒤 실행한다. 비밀번호는 `-W` 프롬프트에 입력하며 URL·명령문·Git에 기록하지 않는다. 이 변수들은 아래 Spring Boot 접속 변수와 별개다. psql이 없으면 조회 SQL은 DBeaver에서 실행할 수 있지만, `std_check.sql` 등 psql 전용 명령이 있는 파일은 psql이 필요하다.

```bash
psql -W -v ON_ERROR_STOP=1 -c "SELECT current_database(), current_user, current_schema(), version();"
```

PostgreSQL 17, 본인 DB·계정, 스키마 `wms`인지 확인한다. 1번 학생의 예상값은 `wms01`, `student01`, `wms`다. 빈 `wms` 스키마는 사전 제공하므로 접속 직후 초기화하지 않는다. 본인 DB 안에서 테이블을 직접 설계하는 것이 실습이며, DB 자체 생성이나 계정 관리는 수행하지 않는다.

## Lab 1. DB 표준 Rule 검토 (10분)

`.cursor/rules/06-database.mdc`를 열어 이번 실습의 DB 설계 표준을 확인한다. Cursor 채팅에 입력한다.

```text
@06-database.mdc 이 표준의 핵심 규칙을 7개 이내로 요약해줘.
규칙끼리 충돌하거나 해석이 모호한 부분이 있으면 지적해줘.
```

확인 포인트. 표준도 검토 대상이다. 규칙이 모순되면 AI는 아무 쪽이나 고른다. `SERIAL` 대 "시퀀스 사용 안 함", `'Y'/'N'` 대 `BOOLEAN`이 그 예다.

## Lab 2. 모델 생성과 검증 (50분)

### 2-1. 개념 모델 (DDL은 아직)

```text
@wms_prd.md 를 읽고 개념 모델을 만들어줘. §7 데이터 요구사항이 설계 입력이다.
- 엔터티 목록과 핵심 속성
- 관계와 카디널리티(1:1, 1:N, M:N)
- 요구사항에서 애매한 부분은 '확인 질문' 목록으로 따로
아직 DDL은 만들지 마.
```

확인 포인트. 입고·출고 주문과 라인(1:N), 주문과 상품(M:N을 라인으로 푼 것), 상태 전이 규칙, 상태 이력, 공통코드가 나왔는가. 센터·상품 기준정보가 따로 있는가. PRD §7의 관리 대상 8개와 빠짐없이 대응하는가. "거래처(발주처)는 어디에 두나" 같은 확인 질문이 나오면 "이번 범위에서는 없음"으로 답한다(2일차 변경 대응에서 다룬다). `wms_prd-inventory-flow.md`는 이 단계에서 읽지 않는다.

### 2-2. DDL 생성

```text
@06-database.mdc @wms_prd.md
위 개념 모델로 PostgreSQL 17 DDL을 작성해서 database/schemas/wms_ddl.sql 로 저장해줘.
- 스키마 wms, 공통코드 테이블(code_group, common_code) 포함
- 모든 테이블·컬럼에 한글 COMMENT
- 학생별 DB와 계정은 이미 준비돼 있으므로 CREATE DATABASE, CREATE ROLE,
  ALTER ROLE, GRANT, REVOKE는 넣지 마.
- 스키마는 사전 제공되며, 기준 DDL 맨 앞에는 CREATE SCHEMA IF NOT EXISTS wms;만 넣어줘.
- 파일만 작성하고 DB 적용·초기화는 사용자 확인 없이 실행하지 마.
```

### 2-3. DB 적용과 표준 자동 점검

```bash
psql -W -v ON_ERROR_STOP=1 -f database/schemas/wms_ddl.sql
psql -W -v ON_ERROR_STOP=1 -v schema=wms -f database/tools/std_check.sql
```

위반이 나오면 결과를 복사해 Cursor에 넘긴다.

```text
std_check 결과야. @06-database.mdc 기준으로 wms_ddl.sql 을 고쳐줘. [결과 붙여넣기]
```

초안 재적용에 초기화가 필요한 경우에만 강사와 대상 DB·삭제 범위를 확인한다. `reset_schema.sql`은 현재 접속한 DB의 `wms` 스키마와 그 안의 객체·데이터를 삭제한다. 보존할 자료를 백업하고 본인 DB인지 확인한 뒤 기준 모델 확정 전에만 실행한다. 기준 DDL로 스키마를 다시 생성해야 한다. 아래 명령을 무조건 실행하는 절차가 아니다.

```bash
psql -W -v ON_ERROR_STOP=1 -f database/tools/reset_schema.sql
```

목표는 `위반 건수 0 | PASS`다.

### 2-4. 업무 규칙 리뷰 (도구가 못 잡는 것)

`std_check`는 형식만 본다. 의미는 사람이 본다.

```text
@wms_prd.md @wms_ddl.sql
PRD의 업무 규칙 하나하나가 DDL의 어떤 테이블·컬럼·제약조건으로 보장되는지 표로 매핑해줘.
보장되지 않는 규칙은 '미반영'으로 표시하고 이유를 써줘.
```

직접 확인할 체크리스트.

- [ ] 주문 헤더와 라인이 분리돼 있고 라인에 `(주문 ID, line_no)` UNIQUE가 있는가
- [ ] 주문번호·센터번호·SKU 번호는 PK가 아니라 UNIQUE인가
- [ ] 수량 컬럼에 `>= 0` CHECK가 있는가
- [ ] 상태 코드가 ENUM이나 CHECK IN 목록이 아니라 공통코드 참조인가
- [ ] 상태 전이 규칙 테이블에 `(order_kind, from, to)` UNIQUE가 있는가
- [ ] 상태 이력에 변경자·사유·일시가 있는가
- [ ] 센터별·상태별 조회를 받칠 인덱스가 있는가

### 2-5. 팀 기준 모델 확정

실무에서도 여러 초안 중 하나를 팀 기준으로 정한다. 강사가 배포하는 기준 DDL과 자기 초안을 비교한다.

```text
@wms_ddl.sql @기준_wms_ddl.sql 두 파일의 모델링 차이를 설명해줘.
어느 쪽이 요구사항을 더 잘 반영하는지 항목별로 판단해줘.
```

이후 단계는 전원이 기준 DDL을 쓴다. 백엔드 Rule·Agent가 이 스키마를 전제하기 때문이다.

```bash
# 초기화가 필요하다고 강사와 확인한 경우에만 실행한다.
psql -W -v ON_ERROR_STOP=1 -f database/tools/reset_schema.sql
psql -W -v ON_ERROR_STOP=1 -f database/schemas/wms_ddl.sql
```

## Lab 3. 권한, 시드, 데이터 사전 (20분)

### 3-1. 권한 구조 확인

`init/00_roles.sql`은 계정 생성 스크립트가 아니라 현재 계정과 권한을 조회하는 SQL이다. DBeaver 또는 아래 명령으로 실행한다. 본인 DB의 CONNECT/CREATE와 `wms` 스키마의 USAGE/CREATE가 true인지 확인한다. 테이블 구조 변경·삭제는 본인이 소유한 객체에서 가능하다. 실제 테이블을 DROP/DELETE해서 접근 제한을 시험하지 않는다.

```bash
psql -W -v ON_ERROR_STOP=1 -f database/init/00_roles.sql
```

학생은 다른 학생·강사 DB에 접속할 수 없고, DB 자체 삭제·계정 생성 권한은 없다. 강사는 실습 지원을 위해 학생 DB를 조회·수정할 수 있다. 본인 계정당 동시 연결 한도는 4개이므로 앱 풀은 최대 3개를 기준으로 하고 DB 도구의 추가 세션에 따라 더 줄인다.

### 3-2. 시드 (본인 학생 계정으로)

강사가 배포하는 `seeds/*.sql` 4종을 순서대로 적용한다.

```bash
for f in seed_common_code seed_master seed_transition_rule seed_sample_order; do
  psql -W -v ON_ERROR_STOP=1 -f database/seeds/$f.sql || break
done
psql -W -v ON_ERROR_STOP=1 -f database/tools/verify_schema.sql
```

위 시드·검증 파일은 기준 모델 확정 단계에서 제공 또는 작성한 뒤 실행한다. 초기 저장소에는 들어 있지 않다. 검증 기준 건수는 확정된 모델·시드에 맞춰 확인하며, 임의로 테이블·행 수를 고정하지 않는다.

### 3-3. 데이터 사전

```text
@wms_ddl.sql 을 읽고 docs/99.references/data-dictionary.md 를 채워줘.
테이블별 컬럼 의미, 공통코드 그룹과 값, 상태 코드 매핑을 포함해.
```

## 백엔드 인계 체크리스트

- [ ] `database/schemas/wms_ddl.sql` 기준 DDL (DTO·MyBatis 매퍼의 기준)
- [ ] `std_check` PASS
- [ ] 모든 테이블·컬럼 COMMENT (DTO·매퍼 생성 시 AI가 읽는 근거)
- [ ] 시드 4종 적용, `verify_schema` 기준치 일치
- [ ] `data-dictionary.md` 작성
- [ ] DDL·조회·앱 연결 모두 본인 학생 계정 사용 (예: `student01` / `wms01`)
- [ ] 앱의 `SPRING_DATASOURCE_URL`·`SPRING_DATASOURCE_USERNAME`·`SPRING_DATASOURCE_PASSWORD`에 개별 전달값과 최종 TLS 설정 반영 (Git 커밋 금지)

## 막혔을 때

| 증상 | 조치 |
|---|---|
| `permission denied for schema wms` | 본인 DB·학생 계정인지 확인. 스키마 소유권·권한은 강사에게 문의하고 계정을 새로 만들지 않는다 |
| AI가 GRANT·롤 생성을 DDL에 넣음 | Lab 1 요약을 다시 보여 주고 해당 줄 삭제 요청 |
| AI가 `SERIAL`·`TIMESTAMP`·`CHAR(1)`을 씀 | 프롬프트에 `@06-database.mdc`를 넣었는지 확인 |
| `relation ... already exists` | 기존 객체와 DDL을 확인. 확정 전 재적용에 초기화가 필요한 경우만 강사 승인·백업 후 `reset_schema.sql` 사용 |
| AI 결과가 계속 엉뚱함 | 2-5로 넘어가 기준 DDL로 진행하고, 차이를 설명하게 한다 |
