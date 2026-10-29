<!--
[사용법] /my-create-db-files — IMPACT에 DB 변경이 있고 영향 승인된 뒤에만
[목적] migration + DDL·사전 동기화. DB 미실행
[다음] /my-create-db-apply
-->

# 등록 기능 DB 파일 (`/my-create-db-files`)

## 사전 조건

1. `영향 승인: <IMPACT-*-create.md>` 완료  
2. IMPACT § DB가 **필요**로 되어 있을 것. **불필요**이면 이 Command를 실행하지 말고 `/my-create-app`으로 안내 후 종료  
3. ALLOWED_PATHS의 DB 경로만 수정

## 수행

- `/my-cr-db-files`와 동일 원칙: ALTER/COMMENT만, GRANT/DROP/CREATE DATABASE 금지  
- 공통 감사 컬럼 **중간 삽입 금지**. 기존 업무 컬럼이 있으면 그 **다음**에 추가  
- 앱 코드·시드 전체 재작성 금지

## 종료 STOP

```
## /my-create-db-files 완료
- migration: <경로>
- DB 적용: 아직 안 함
다음: DB 적용 승인: <migration경로> 후 /my-create-db-apply
```
