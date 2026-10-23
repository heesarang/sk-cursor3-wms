---
description: "Java 백엔드 코딩 표준 – Controller/Service/Mapper 계층 규칙, 네이밍, 에러 처리"
globs: ["backend/src/main/java/**/*.java"]
alwaysApply: false
---


<!--
[목적] Java 백엔드 코딩 규칙. Java 파일 편집 시에만 로드된다.
[작동] backend/src/ 하위 .java 파일을 작업할 때 자동 적용.
-->

# Java 백엔드 규칙

## 참조 문서
- docs/99.references/coding-standards.md — 패키지 구조, 클래스 네이밍, API 경로 패턴 상세

## Controller
- @RestController, @RequestMapping 사용
- 메서드에 @GetMapping, @PutMapping 등 명시
- 파라미터는 @RequestParam 또는 @RequestBody
- 비즈니스 로직 넣지 말고 Service 호출만
- **Swagger / OpenAPI**: 새·수정 API에는 `io.swagger.v3.oas.annotations` 로 `@Tag`, `@Operation`, 필요 시 `@Parameter` 를 붙여 Swagger UI 문서가 비어 있지 않게 한다. (`/swagger-ui.html`, OpenAPI는 `/v3/api-docs`)

## Service
- @Service 어노테이션 필수
- 상태 변경은 반드시 StatusTransitionService를 통해 검증
- 트랜잭션이 필요한 메서드에 @Transactional

## Mapper
- @Mapper 어노테이션 필수
- 메서드 파라미터/리턴은 Map<String, Object> 사용
- SQL은 여기에 쓰지 않음. MyBatis XML에 작성

## 에러 처리
- 비즈니스 예외는 RuntimeException 상속 커스텀 예외 사용
- Controller에서 try-catch 하지 말고 @ExceptionHandler로 처리

## 네이밍
- 패키지명 전부 소문자
- Service 클래스에 @Service, Controller에 @RestController 필수
