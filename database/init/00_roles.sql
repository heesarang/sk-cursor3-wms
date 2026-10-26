-- 00_roles.sql : 개인 실습 DB의 계정·권한 조회 (읽기 전용)
-- PostgreSQL 17. 예: student01 -> wms01, 기본 스키마 wms.
-- DB와 로그인 계정은 강사가 사전 생성한다. 이 파일은 생성·변경하지 않는다.
-- DDL·조회·DML·앱 연결은 본인 학생 계정으로 수행한다.
SELECT current_database() AS database_name,
       current_user AS user_name,
       current_schema() AS schema_name,
       version() AS server_version;

SELECT has_database_privilege(current_user, current_database(), 'CONNECT') AS can_connect,
       has_database_privilege(current_user, current_database(), 'CREATE') AS can_create_schema,
       has_schema_privilege(current_user, n.oid, 'USAGE') AS can_use_schema,
       has_schema_privilege(current_user, n.oid, 'CREATE') AS can_create_objects,
       pg_get_userbyid(n.nspowner) = current_user AS owns_schema
FROM pg_namespace n
WHERE n.nspname = 'wms';

-- 학생 계정은 모두 false여야 한다. 스키마 조회가 0행이면 강사에게 문의한다.
SELECT rolsuper AS is_superuser,
       rolcreatedb AS can_create_database,
       rolcreaterole AS can_manage_roles
FROM pg_roles
WHERE rolname = current_user;
