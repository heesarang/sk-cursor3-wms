<!--
[사용법] /my-create-db-apply — DB 적용 승인 후에만 SQL 실행
[목적] 본인 DB에 승인된 migration만 적용
[다음] /my-create-app
-->

# 등록 기능 DB 적용 (`/my-create-db-apply`)

## 사전 조건

1. 영향 승인 완료, migration 파일 존재  
2. 채팅에 `DB 적용 승인: <migration파일경로>` **한 줄** — 없으면 **실행하지 말고 중단**

## 수행

1. 접속 지문 `current_database()`, `current_user`, `current_schema()` — 예상과 다르면 중단  
2. 멱등: 대상이 있으면 스킵 보고  
3. 승인 파일만 실행 (비밀번호 파일 기록 금지)  
4. 확인 조회  

앱·DDL 파일 수정·reset_schema·타 학생 DB 금지.

## 종료 STOP

```
## /my-create-db-apply 완료
- database / user / schema: <값>
- migration 적용: 성공 | 스킵 | 실패
- 다음: /my-create-app
```
