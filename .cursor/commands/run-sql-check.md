<!--
[사용법] Agent 입력창에서 /run-sql-check 입력 후 실행
[목적] database/ 디렉토리의 SQL 파일 품질 점검
-->

# SQL 파일 점검

database/ 디렉토리의 SQL 파일을 점검해주세요.

## 체크 항목
- `06-database.mdc` 표준 준수 여부 (대리키 `{테이블}_id`, 명명, 타입, COMMENT)
- 컬럼명 snake_case 준수 여부
- 공통 컬럼(created_at, updated_at, created_by, updated_by) 누락 여부
- DROP TABLE IF EXISTS 사용 여부
- INSERT 시 컬럼명 명시 여부
- 실행 순서(schemas/wms_ddl → seeds/seed_common_code → seed_master → seed_transition_rule → seed_sample_order) 정합성
- `database/tools/std_check.sql` 실행 결과(위반 0 = PASS) 확인

문제가 있으면 파일명, 라인, 내용, 수정 제안을 정리해주세요.
