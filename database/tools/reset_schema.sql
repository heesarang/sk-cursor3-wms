-- reset_schema.sql : 기준 모델 확정 전, 초안 DDL 재적용용 초기화 (본인 학생 계정·개인 DB)
--   wms 스키마와 그 안의 객체·데이터를 삭제한다. 대상 확인·백업·강사 승인 후에만 실행한다.
--   접속 확인 단계에서 실행하지 않는다. 이후 기준 DDL로 wms 스키마를 다시 생성한다.
--   기준 모델을 확정한 뒤에는 쓰지 않는다. 확정 후 변경은 migrations/ 로만 한다.
SET client_min_messages = warning;
DROP SCHEMA IF EXISTS wms CASCADE;
