<!--
[사용법] Agent 입력창에서 /create-api 입력 후 실행
[목적] 새 API 엔드포인트에 필요한 파일을 한번에 생성
-->

# 새 API 엔드포인트 생성

지정된 도메인에 대해 아래 파일을 한번에 생성해주세요.

1. Controller — backend/src/main/java/com/execnt/wms/controller/{Domain}Controller.java
2. Service — backend/src/main/java/com/execnt/wms/service/{Domain}Service.java
3. Mapper 인터페이스 — backend/src/main/java/com/execnt/wms/mapper/{Domain}Mapper.java
4. MyBatis XML — backend/src/main/resources/mapper/{Domain}Mapper.xml

프로젝트 Rules를 준수하고, 기존 코드 패턴과 일관되게 작성하세요.
생성 후 빌드하여 컴파일 오류가 없는지 확인하세요.
