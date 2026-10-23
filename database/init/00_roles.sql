-- =====================================================================
-- 00_roles.sql : wms 권한 구조 (관리자 계정으로 1회 실행)
--   wms_owner : 스키마·객체 소유자. DDL·마이그레이션 실행 계정
--   wms_app   : 백엔드 런타임 계정. DML만 가능
--   wms_ro    : 조회 전용. MCP·분석 도구 연결용
--   실습용 비밀번호다. 교육 당일 강사가 안내하는 값으로 바꿔 실행한다.
--   DB 이름(wmsdb)은 환경에 맞게 바꾼다. 관리형 DB(Neon 등)는 CREATE ROLE 권한을 먼저 확인한다.
-- =====================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'wms_owner') THEN
    CREATE ROLE wms_owner LOGIN PASSWORD 'owner_pw';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'wms_app') THEN
    CREATE ROLE wms_app LOGIN PASSWORD 'app_pw';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'wms_ro') THEN
    CREATE ROLE wms_ro LOGIN PASSWORD 'ro_pw';
  END IF;
END $$;

GRANT CONNECT, CREATE ON DATABASE wmsdb TO wms_owner;
GRANT CONNECT ON DATABASE wmsdb TO wms_app, wms_ro;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- DDL 권한은 GRANT가 아니라 소유권에서 나온다. owner가 만드는 객체에 자동 적용되는 기본 권한.
ALTER DEFAULT PRIVILEGES FOR ROLE wms_owner GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO wms_app;
ALTER DEFAULT PRIVILEGES FOR ROLE wms_owner GRANT USAGE, SELECT ON SEQUENCES TO wms_app;
ALTER DEFAULT PRIVILEGES FOR ROLE wms_owner GRANT SELECT ON TABLES TO wms_ro;

ALTER ROLE wms_owner SET search_path = wms, public;
ALTER ROLE wms_app   SET search_path = wms, public;
ALTER ROLE wms_ro    SET search_path = wms, public;
