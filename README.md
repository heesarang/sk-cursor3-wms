# WMS 실습

[GitHub 저장소](https://github.com/sk-devax-training/sk-cursor3-wms)

## 실습 소개

Cursor를 활용해 창고관리 시스템(WMS)을 구현하는 실습입니다. Java 소스와 프론트엔드 구현, DDL·시드·초기화 SQL은 실습 과정에서 작성합니다.

- 백엔드: Java 21, Spring Boot 3.5.4, MyBatis, Gradle Wrapper
- 패키지·Gradle group: `com.execnt.wms`
- 프론트엔드: Vue 3 CDN
- DB: PostgreSQL 17, 학생별 개인 DB·계정 (예: `student01` → `wms01`), 업무 스키마 `wms`
- 기능 출발점: 입고·출고·대시보드·상태 전이(F1~F4)

## 시작하기

1. 이 저장소 루트를 Cursor에서 엽니다.
2. `docs/00.guide/START-HERE.md`에서 시작 상태를 확인합니다.
3. 기본 PRD와 `.cursor/rules/`를 읽습니다.
4. DB 모델링·기준 모델 확정 후 개발을 진행합니다.

실제 DB 접속 정보는 환경변수로 전달합니다. `.env.example`은 변수 목록일 뿐 Spring Boot가 자동으로 읽는 파일이 아닙니다. `backend/src/main/resources/application.yml.example`을 같은 폴더의 `application.yml`로 복사하여 사용합니다.

## 폴더 구성

- `.cursor/`: Rules 6종, Commands 5종, Skills 2종, Agents 8종과 Hooks 예시
- `backend/`: Gradle 기반, 실행 설정 예시. 애플리케이션 소스 미작성
- `frontend/`: 구현 전 빈 작업 영역
- `database/`: DDL·시드·DB 검증 도구
- `docs/`: 기본 PRD, 개발 표준, 실습 가이드
- `scripts/`: Bash 기반 기동·종료·API 검증 도구. 구현 완료 후 사용

Hooks는 `.cursor/hooks.json.example`로만 제공합니다. Bash·Python 등 실행 환경 확인 후 필요하면 `hooks.json`으로 복사합니다. 예시 Hook은 보안 경계나 완전한 명령 차단 도구가 아닙니다. MCP는 선택 사항이며 실제 연결 설정은 배포하지 않습니다.
