---
name: api-scaffolding
description: "새 도메인의 CRUD API를 일괄 생성할 때 사용"
disable-model-invocation: true
---

<!--
[목적] /api-scaffolding 명시 호출 시에만 실행. 도메인명을 받아 보일러플레이트 생성.
[사용법] Agent 입력창에서 "/api-scaffolding 도메인명" 입력
-->

# API 스캐폴딩

도메인명을 받아 아래 파일을 일괄 생성한다.

## 생성 파일
1. {Domain}Controller.java — references/TemplateController.java 참고
2. {Domain}Service.java — references/TemplateService.java 참고
3. {Domain}Mapper.java — references/TemplateMapper.java 참고
4. {Domain}Mapper.xml — references/TemplateMapper.xml 참고

## 절차
1. 도메인명을 PascalCase로 변환
2. references/ 하위 템플릿을 읽고 도메인명으로 치환
3. 프로젝트 Rules의 패키지/네이밍 규칙을 적용
4. 파일 생성 후 빌드 확인

## 참조
- references/ 디렉토리의 템플릿 파일
- scripts/scaffold.sh
