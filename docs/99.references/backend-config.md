# 백엔드 설정 참조

## 실행 설정

`backend/src/main/resources/application.yml.example`을 같은 폴더의 `application.yml`로 복사합니다. 실제 접속 정보는 다음 환경변수로 전달합니다.

- SPRING_DATASOURCE_URL: 강사가 안내한 JDBC URL
- SPRING_DATASOURCE_USERNAME: 강사가 안내한 애플리케이션 계정
- SPRING_DATASOURCE_PASSWORD: 해당 계정 비밀번호

루트 `.env.example`은 변수 목록입니다. Spring Boot와 기존 실행 스크립트는 .env를 자동으로 읽지 않습니다. 셸 또는 IDE 실행 환경에 직접 설정하세요. 실계정 설정 파일과 비밀번호를 커밋하지 않습니다.

Java 21, Spring Boot 3.5.4, MyBatis를 사용하며 기본 패키지는 `com.execnt.wms`입니다. 실행 가능한 Java 소스는 아직 없습니다. 코드 작성 전 bootRun을 실행하면 메인 클래스를 찾지 못하는 것이 정상입니다.

## CORS와 인증

로그인·JWT는 교육 범위에 포함하지 않습니다. 프론트와 백엔드의 포트가 다르면 개발용 SecurityConfig에서 CORS를 구성합니다. 교육 중 사용할 실제 프론트 Origin을 명시하고 GET/POST/PUT/DELETE/OPTIONS와 필요한 헤더를 허용합니다. 쿠키 인증을 사용하지 않으면 allowCredentials는 false로 둡니다.

개발용 무인증 정책을 설정할 때는 CSRF와 permitAll 적용 범위를 검토하고, 교육 환경에 한정합니다. 포트 변경 시 프론트 API 기본 주소도 맞춥니다. curl 성공과 브라우저 CORS 성공을 별도로 확인하세요.

## DB 적용

DDL 실행은 애플리케이션 시작과 분리합니다. 검토한 DDL을 실습 DB에 적용하고 테이블과 제약조건을 확인한 뒤 애플리케이션을 실행합니다.
