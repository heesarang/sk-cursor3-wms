-- reset_schema.sql : 기준 모델 확정 전, 초안 DDL을 다시 적용하기 위한 초기화 (실행 계정: wms_owner)
--   기준 모델을 확정한 뒤에는 쓰지 않는다. 확정 후 변경은 migrations/ 로만 한다.
SET client_min_messages = warning;
DROP SCHEMA IF EXISTS wms CASCADE;
