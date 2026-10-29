<!--
[사용법] /my-cr-db-files — 영향 문서가 「영향 승인: 경로」로 승인된 뒤에만 실행
[목적] migration 파일 작성 + 기준 DDL·데이터 사전 동기화. DB에는 실행하지 않음
[다음] /my-cr-db-apply
-->

# CR DB 파일 (`/my-cr-db-files`)

## 사전 조건 (미충족 시 즉시 중단)

1. 사용자가 이번 대화(또는 명시적 인용)에서  
   `영향 승인: docs/01.analysis/05.change-requests/IMPACT-....md`  
   형식으로 승인한 상태여야 한다.
2. 해당 영향 문서를 읽고 `승인 상태`를 `승인됨`으로 갱신할 수 있다.
3. **승인 문구가 없으면** 코드를 쓰지 말고 `/my-cr-plan`으로 안내한 뒤 종료한다.

## 이 Command에서 하는 일

영향 문서의 **ALLOWED_PATHS**에 있는 DB 관련 파일만 수정·생성:

1. **migration 파일 작성** (`database/migrations/...sql`)
   - `ALTER TABLE ... ADD COLUMN ...`
   - `COMMENT ON COLUMN ...`
   - CREATE DATABASE / ROLE / GRANT / DROP 금지
2. **기준 DDL 동기화** (`wms_ddl.sql`)
   - 동일 컬럼을 **공통 감사 컬럼 뒤**에 추가 (중간 삽입 금지)
3. **데이터 사전** (`data-dictionary.md`) 해당 테이블·컬럼 반영
4. 마이그레이션 ↔ DDL 정의(이름·타입·NULL·COMMENT) 일치 여부를 보고

## 이 Command에서 하지 않는 일

- 본인 DB에 SQL **실행**
- 백엔드·프론트 수정
- 시드 전체 재작성
- 커밋

## 종료 (필수 STOP)

```
## /my-cr-db-files 완료
- migration: <경로>
- wms_ddl.sql / data-dictionary.md: 동기화함
- DB 적용: 아직 안 함 (파일만 준비됨)

다음: /my-cr-db-apply
(DB에 실행하려면 별도 Command와 DB 승인이 필요합니다)
```

자동으로 `/my-cr-db-apply`를 이어서 실행하지 않는다.
