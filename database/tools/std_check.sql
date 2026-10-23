-- =====================================================================
-- std_check.sql : DB 표준 자동 점검 (결정적 검사)
--   사용: psql -d wmsdb -f std_check.sql                 (기본 스키마 wms)
--         psql -d wmsdb -v schema=다른스키마 -f std_check.sql
--   결과가 0건이면 표준 통과. 위반 내용은 Cursor에게 설명·수정을 요청한다.
--   R01 테이블 COMMENT   R02 컬럼 COMMENT      R03 PK 존재          R04 PK명 {테이블}_id
--   R05 IDENTITY(SERIAL 금지)  R06 공통컬럼       R07 금지 타입         R08 길이/정밀도
--   R09 FK 인덱스        R10 명명(snake_case, 두 단어)  R11 제약·인덱스명   R12 코드그룹 코멘트
--   R13 CASCADE 금지     R14 BOOLEAN is_ 접두어  R15 FK명·타입 = 부모 PK
--   ※ M:N 누락, 스냅샷 누락 같은 "업무 의미"는 검사하지 못한다 → 사람이 리뷰
-- =====================================================================
\if :{?schema}
\else
  \set schema wms
\endif
\pset footer off
\echo '== DB 표준 점검: 스키마' :'schema' '=='

\set QUIET on
CREATE OR REPLACE TEMP VIEW std_violation AS
WITH
tbl AS (
  SELECT c.oid, c.relname AS table_name
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = :'schema' AND c.relkind IN ('r','p')
),
col AS (
  SELECT t.oid AS table_oid, t.table_name, a.attnum, a.attname AS column_name,
         format_type(a.atttypid, a.atttypmod) AS col_type,
         a.atttypid::regtype::text AS base_type, a.atttypmod,
         a.attidentity, pg_get_expr(d.adbin, d.adrelid) AS col_default,
         col_description(t.oid, a.attnum) AS col_comment
  FROM tbl t
  JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum > 0 AND NOT a.attisdropped
  LEFT JOIN pg_attrdef d ON d.adrelid = t.oid AND d.adnum = a.attnum
),
con AS (
  SELECT t.table_name, k.conname, k.contype, k.conkey, k.confdeltype, k.conrelid, k.confrelid, k.confkey
  FROM tbl t JOIN pg_constraint k ON k.conrelid = t.oid
),
idx AS (
  SELECT t.table_name, i.indexrelid::regclass::text AS index_name,
         i.indkey[0] AS lead_col, i.indisunique, i.indisprimary
  FROM tbl t JOIN pg_index i ON i.indrelid = t.oid
),
v AS (
  -- R01 테이블 코멘트
  SELECT 'R01' rule_id, table_name AS object_name, '테이블 COMMENT 누락' AS message
  FROM tbl WHERE obj_description(oid, 'pg_class') IS NULL
  UNION ALL
  -- R02 컬럼 코멘트
  SELECT 'R02', table_name||'.'||column_name, '컬럼 COMMENT 누락'
  FROM col WHERE col_comment IS NULL
  UNION ALL
  -- R03 PK 존재
  SELECT 'R03', table_name, 'PK 없음'
  FROM tbl t WHERE NOT EXISTS (SELECT 1 FROM con WHERE con.table_name = t.table_name AND contype = 'p')
  UNION ALL
  -- R04 PK 컬럼명 = {테이블}_id 단일 컬럼
  SELECT 'R04', con.table_name, 'PK는 단일 컬럼 '||con.table_name||'_id 여야 함'
  FROM con
  WHERE contype = 'p'
    AND (array_length(conkey,1) <> 1
         OR (SELECT attname FROM pg_attribute WHERE attrelid = con.conrelid AND attnum = conkey[1]) <> con.table_name||'_id')
  UNION ALL
  -- R05 PK는 IDENTITY (SERIAL/nextval 금지)
  SELECT 'R05', col.table_name||'.'||col.column_name, 'PK는 GENERATED ... AS IDENTITY 여야 함 (현재: '||coalesce(col_default,'기본값 없음')||')'
  FROM col JOIN con ON con.table_name = col.table_name AND con.contype = 'p' AND con.conkey = ARRAY[col.attnum]
  WHERE col.attidentity = ''
  UNION ALL
  SELECT 'R05', table_name||'.'||column_name, 'nextval 기본값(SERIAL/수동 시퀀스) 사용 금지'
  FROM col WHERE col_default LIKE 'nextval(%'
  UNION ALL
  -- R06 공통 컬럼
  SELECT 'R06', t.table_name, '공통컬럼 누락: '||c.need
  FROM tbl t CROSS JOIN (VALUES ('created_at'),('created_by'),('updated_at'),('updated_by')) c(need)
  WHERE NOT EXISTS (SELECT 1 FROM col WHERE col.table_name = t.table_name AND col.column_name = c.need)
  UNION ALL
  -- R07 금지 타입
  SELECT 'R07', table_name||'.'||column_name, '금지 타입 '||col_type||' → '||
         CASE base_type
           WHEN 'character' THEN 'VARCHAR(n)'
           WHEN 'timestamp without time zone' THEN 'TIMESTAMPTZ'
           WHEN 'money' THEN 'NUMERIC(p,s)'
           ELSE 'NUMERIC(p,s)' END
  FROM col WHERE base_type IN ('character','timestamp without time zone','money','real','double precision')
  UNION ALL
  SELECT 'R07', table_name||'.'||column_name, 'ENUM/사용자 정의 타입 금지 → 공통코드 사용 ('||col_type||')'
  FROM col c WHERE EXISTS (SELECT 1 FROM pg_type ty WHERE ty.oid = c.base_type::regtype AND ty.typtype IN ('e','d','c'))
  UNION ALL
  -- R08 길이/정밀도 지정
  SELECT 'R08', table_name||'.'||column_name, '길이/정밀도 미지정: '||col_type
  FROM col WHERE base_type IN ('character varying','numeric') AND atttypmod = -1
  UNION ALL
  -- R09 FK 컬럼 인덱스
  SELECT 'R09', con.table_name||'.'||(SELECT attname FROM pg_attribute WHERE attrelid = con.conrelid AND attnum = con.conkey[1]),
         'FK('||con.conname||') 컬럼이 선두인 인덱스 없음'
  FROM con
  WHERE contype = 'f'
    AND NOT EXISTS (SELECT 1 FROM idx WHERE idx.table_name = con.table_name AND idx.lead_col = con.conkey[1])
  UNION ALL
  -- R10 명명: 소문자 snake_case, 컬럼은 두 단어 이상
  SELECT 'R10', table_name,
         CASE WHEN table_name !~ '^[a-z][a-z0-9_]*$' THEN '테이블명은 소문자 snake_case'
              ELSE '테이블명은 두 단어 이상 (기준정보는 _info 접미사)' END
  FROM tbl WHERE table_name !~ '^[a-z][a-z0-9_]*$' OR position('_' IN table_name) = 0
  UNION ALL
  SELECT 'R10', table_name||'.'||column_name,
         CASE WHEN column_name !~ '^[a-z][a-z0-9_]*$' THEN '컬럼명은 소문자 snake_case'
              ELSE '컬럼명은 두 단어 이상 (예: '||column_name||' → xxx_'||column_name||')' END
  FROM col WHERE column_name !~ '^[a-z][a-z0-9_]*$' OR position('_' IN column_name) = 0
  UNION ALL
  -- R11 제약조건 명명
  SELECT 'R11', table_name||'.'||conname,
         '제약조건명 규칙 위반 (기대: '||table_name||
         CASE contype WHEN 'p' THEN '_pk'
                      WHEN 'f' THEN '_'||(SELECT relname FROM pg_class WHERE oid = confrelid)||'_fk'
                      WHEN 'u' THEN '_uxN' ELSE '_ckN' END||')'
  FROM con
  WHERE contype IN ('p','f','u','c')
    AND conname !~ ('^'||table_name||
         CASE contype WHEN 'p' THEN '_pk$'
                      WHEN 'f' THEN '_'||(SELECT relname FROM pg_class WHERE oid = confrelid)||'_fk[0-9]*$'
                      WHEN 'u' THEN '_ux[0-9]+$' ELSE '_ck[0-9]+$' END)
  UNION ALL
  -- R11 인덱스 명명 (제약조건이 만든 인덱스 제외)
  SELECT 'R11', i.table_name||'.'||i.index_name,
         '인덱스명 규칙 위반 (기대: '||i.table_name||CASE WHEN i.indisunique THEN '_uxN' ELSE '_ixN' END||')'
  FROM idx i
  WHERE NOT EXISTS (SELECT 1 FROM con WHERE con.conname = split_part(i.index_name,'.',2) OR con.conname = i.index_name)
    AND split_part(i.index_name,'.',2) !~ ('^'||i.table_name||CASE WHEN i.indisunique THEN '_ux[0-9]+$' ELSE '_ix[0-9]+$' END)
    AND i.index_name !~ ('^'||i.table_name||CASE WHEN i.indisunique THEN '_ux[0-9]+$' ELSE '_ix[0-9]+$' END)
  UNION ALL
  -- R12 코드 컬럼 코멘트에 코드그룹
  SELECT 'R12', table_name||'.'||column_name, '_code 컬럼 COMMENT에 "코드그룹:" 표기 필요'
  FROM col WHERE column_name LIKE '%\_code' AND column_name <> 'group_code'
             AND col_comment IS NOT NULL AND col_comment NOT LIKE '%코드그룹:%'
  UNION ALL
  -- R14 BOOLEAN 컬럼은 is_ 접두어
  SELECT 'R14', table_name||'.'||column_name, 'BOOLEAN 컬럼명은 is_ 로 시작 (예: is_'||column_name||')'
  FROM col WHERE base_type = 'boolean' AND column_name NOT LIKE 'is\_%'
  UNION ALL
  -- R15 FK 컬럼명·타입 = 부모 PK 컬럼명·타입
  SELECT 'R15', con.table_name||'.'||ca.attname,
         'FK 컬럼은 부모 PK와 이름·타입 동일해야 함 (부모: '||pa.attname||' '||format_type(pa.atttypid, pa.atttypmod)||')'
  FROM con
  JOIN pg_attribute ca ON ca.attrelid = con.conrelid  AND ca.attnum = con.conkey[1]
  JOIN pg_attribute pa ON pa.attrelid = con.confrelid AND pa.attnum = con.confkey[1]
  WHERE con.contype = 'f' AND array_length(con.conkey,1) = 1
    AND (ca.attname <> pa.attname OR ca.atttypid <> pa.atttypid)
  UNION ALL
  -- R13 ON DELETE CASCADE 금지
  SELECT 'R13', table_name||'.'||conname, 'ON DELETE CASCADE 금지'
  FROM con WHERE contype = 'f' AND confdeltype = 'c'
)
SELECT rule_id, object_name, message FROM v;
\set QUIET off

SELECT rule_id AS "규칙", object_name AS "대상", message AS "위반 내용"
FROM std_violation ORDER BY 1, 2;

SELECT count(*) AS "위반 건수",
       CASE WHEN count(*) = 0 THEN 'PASS: 표준 준수' ELSE 'FAIL: 위 내용을 수정하세요' END AS "결과"
FROM std_violation;
