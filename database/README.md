# DB 모델링·검증 실습 (2일차 · 90분)

요구사항(PRD)에서 개념 모델을 만들고, DB 표준 Rule에 맞춰 DDL을 쓰고, 도구로 형식을 점검하고, 업무 규칙을 사람이 리뷰한 뒤 기준 모델을 확정한다. 여기서 확정한 스키마를 이어지는 백엔드·프론트엔드 개발이 그대로 쓴다.

| Lab | 내용 | 시간 | 모델 |
|---|---|---|---|
| 0 | 접속 확인 | 5분 | — |
| 1 | DB 표준 Rule 검토 | 10분 | Sonnet |
| 2 | 개념 모델 → DDL → 표준 점검 → 업무 규칙 리뷰 → 기준 모델 확정 | 50분 | 2-1·2-4 Sonnet, 2-2·2-3 Composer |
| 3 | 권한 확인, 시드, 데이터 사전 | 20분 | Composer |
| — | 백엔드 인계 정리 | 5분 | — |

모델 정책은 `docs/00.guide/START-HERE.md` §모델 정책을 따른다. 설계·리뷰(2-1, 2-4)만 Sonnet 5.5, 나머지는 Composer 2.5다.

## 폴더

- `init/00_roles.sql` 롤·권한. 관리자가 1회 실행하며 수강생은 실행하지 않는다
- `schemas/wms_ddl.sql` 기준 DDL. Lab 2에서 만든다
- `seeds/` 공통코드 → 기준정보 → 전이 규칙 → 샘플 순. Lab 3에서 만든다
- `migrations/` 기준 모델 확정 뒤의 변경 이력 `YYYYMMDD_NNN_설명.sql`
- `tools/std_check.sql` 표준 자동 점검(위반 0 = PASS), `tools/reset_schema.sql` 확정 전 초기화
- `docs/` ERD·테이블 정의서 (이번 차수 선택)
- `reports/` 로컬 점검 결과(커밋 제외)

## Lab 0. 접속 확인 (5분)

강사가 안내한 접속 정보를 환경변수로 넣는다. 아래 `$PG...`는 그 값이다.

```bash
psql "$PGURL_OWNER" -c "select current_user, version()"
```

PostgreSQL 16, 사용자 `wms_owner`(또는 안내된 계정)가 보이면 된다. 스키마 `wms`가 이미 있으면 `tools/reset_schema.sql`을 owner로 실행해 비운다.

## Lab 1. DB 표준 Rule 검토 (10분)

`.cursor/rules/06-database.mdc`를 연다. 2차수 DDL이 어떻게 달라졌는지가 이 Rule에 들어 있다. Cursor 채팅에 입력한다.

```text
@06-database.mdc 이 표준의 핵심 규칙을 7개 이내로 요약해줘.
규칙끼리 충돌하거나 해석이 모호한 부분이 있으면 지적해줘.
```

확인 포인트. 표준도 검토 대상이다. 규칙이 모순되면 AI는 아무 쪽이나 고른다. `SERIAL` 대 "시퀀스 사용 안 함", `'Y'/'N'` 대 `BOOLEAN`이 그 예다.

## Lab 2. 모델 생성과 검증 (50분)

### 2-1. 개념 모델 (DDL은 아직)

```text
@wms_prd.md 를 읽고 개념 모델을 만들어줘.
- 엔터티 목록과 핵심 속성
- 관계와 카디널리티(1:1, 1:N, M:N)
- 요구사항에서 애매한 부분은 '확인 질문' 목록으로 따로
아직 DDL은 만들지 마.
```

확인 포인트. 입고·출고 주문과 라인(1:N), 주문과 상품(M:N을 라인으로 푼 것), 상태 전이 규칙, 상태 이력, 공통코드가 나왔는가. 센터·상품 기준정보가 따로 있는가.

### 2-2. DDL 생성

```text
@06-database.mdc @wms_prd.md
위 개념 모델로 PostgreSQL DDL을 작성해서 database/schemas/wms_ddl.sql 로 저장해줘.
- 스키마 wms, 공통코드 테이블(code_group, common_code) 포함
- 모든 테이블·컬럼에 한글 COMMENT
- 롤 생성·GRANT는 넣지 말고, 파일 맨 앞에 CREATE SCHEMA 와
  GRANT USAGE ON SCHEMA wms TO wms_app, wms_ro; 한 줄만 넣어줘
```

### 2-3. DB 적용과 표준 자동 점검

```bash
psql "$PGURL_OWNER" -v ON_ERROR_STOP=1 -f database/schemas/wms_ddl.sql
psql "$PGURL_OWNER" -v schema=wms -f database/tools/std_check.sql
```

위반이 나오면 결과를 복사해 Cursor에 넘긴다.

```text
std_check 결과야. @06-database.mdc 기준으로 wms_ddl.sql 을 고쳐줘. [결과 붙여넣기]
```

다시 적용하기 전에 초기화한다. 기준 모델 확정 전까지만 쓴다.

```bash
psql "$PGURL_OWNER" -f database/tools/reset_schema.sql
```

목표는 `위반 건수 0 | PASS`다. 참고로 2차수 DDL을 같은 점검에 넣으면 142건이 나온다.

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
psql "$PGURL_OWNER" -f database/tools/reset_schema.sql
psql "$PGURL_OWNER" -v ON_ERROR_STOP=1 -f database/schemas/wms_ddl.sql
```

## Lab 3. 권한, 시드, 데이터 사전 (20분)

### 3-1. 권한 구조 확인

`init/00_roles.sql`을 열어 세 계정의 역할을 읽는다. 아래 두 명령은 모두 거부돼야 정상이다. DDL 권한은 GRANT가 아니라 소유권에서 나온다.

```bash
psql "$PGURL_APP" -c "DROP TABLE wms.item_info"
psql "$PGURL_RO"  -c "DELETE FROM wms.item_info"
```

### 3-2. 시드 (백엔드 계정으로)

강사가 배포하는 `seeds/*.sql` 4종을 순서대로 적용한다.

```bash
for f in seed_common_code seed_master seed_transition_rule seed_sample_order; do
  psql "$PGURL_APP" -v ON_ERROR_STOP=1 -f database/seeds/$f.sql
done
psql "$PGURL_RO" -f database/tools/verify_schema.sql
```

테이블 10, 컬럼 COMMENT 누락 0, 공통코드 10, 전이 규칙 6, 상태 이력 12가 나오면 된다.

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
- [ ] 접속 계정: DDL `wms_owner`, 애플리케이션 `wms_app`

## 막혔을 때

| 증상 | 조치 |
|---|---|
| `permission denied for schema wms` | owner 계정으로 접속했는지 확인. 롤 미생성이면 강사 호출 |
| AI가 GRANT·롤 생성을 DDL에 넣음 | Lab 1 요약을 다시 보여 주고 해당 줄 삭제 요청 |
| AI가 `SERIAL`·`TIMESTAMP`·`CHAR(1)`을 씀 | 프롬프트에 `@06-database.mdc`를 넣었는지 확인 |
| `relation ... already exists` | `reset_schema.sql` 실행 후 다시 적용 |
| AI 결과가 계속 엉뚱함 | 2-5로 넘어가 기준 DDL로 진행하고, 차이를 설명하게 한다 |
