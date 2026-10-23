---
description: "프론트엔드 규칙 – Vue 3 CDN SPA, Vue Router, Element Plus, Tailwind, API 호출 패턴"
globs: ["frontend/**/*.html", "frontend/**/*.js", "frontend/**/*.css"]
alwaysApply: false
---

<!--
[목적] 프론트엔드 코딩 규칙. frontend/ 하위 파일 편집 시에만 로드된다.
[작동] frontend/ 하위 .html, .js, .css 파일을 작업할 때 자동 적용.
-->

# 프론트엔드 규칙

## 참조 문서
- docs/99.references/coding-standards.md — SPA 파일 구조, 컴포넌트 패턴, api.js 패턴, 상태 태그 색상 규칙, 프론트↔백엔드 연동 주의사항
- docs/99.references/backend-config.md — SecurityConfig(CORS) 설정

## 기술
- Vue 3 CDN (Options API)
- Vue Router CDN (Hash History)
- Element Plus CDN
- Tailwind CSS CDN
- Axios CDN

## SPA 구조
- index.html 하나에서 Vue Router로 화면을 전환한다
- 화면별 독립 HTML 파일을 만들지 않는다
- 페이지 컴포넌트는 views/ 폴더에 .js로 작성한다
- 재사용 컴포넌트(다이얼로그, 공통 태그 등)는 components/ 폴더에 .js로 작성한다
- 모든 컴포넌트는 Options API + 전역 변수로 선언한다
- 전역 컴포넌트 등록과 플러그인 등록은 app.js에서 수행한다
- 라우팅 정의는 router.js에서 관리한다

## API 연동
- js/api.js의 메서드를 통해서만 호출한다
- baseURL은 api.js에서 한 곳만 관리한다
- 컴포넌트에서 axios를 직접 호출하지 않는다
- 에러 시 ElementPlus.ElMessage.error()로 사용자에게 피드백한다

## CORS / 포트 주의사항
- 프론트엔드(Live Server ~5500)와 백엔드(bootRun ~8080)는 포트가 다르므로 브라우저가 교차 출처(CORS) 요청으로 판단한다
- api.js의 API_BASE는 백엔드가 실제로 실행 중인 주소·포트와 반드시 일치해야 한다
- 백엔드에 CORS 전용 SecurityConfig가 있어야 브라우저 요청이 허용된다. 없으면 docs/99.references/backend-config.md를 참조하여 생성한다
- curl은 CORS를 검사하지 않으므로 curl 성공이 브라우저 성공을 보장하지 않는다
- 브라우저 연동 확인 시 개발자 도구 Network 탭과 Console을 반드시 확인한다

## UI
- 한국어 텍스트
- 상태값은 공통 컴포넌트(StatusTag)로 표시하고 el-tag 색상으로 구분한다
- 위험 동작(상태 변경)은 ElementPlus.ElMessageBox.confirm() 확인 후 실행한다
- 성공 시 ElementPlus.ElMessage.success()로 피드백한다
