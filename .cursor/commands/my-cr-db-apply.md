<!--
[사용법] /my-cr-db-apply — migration 파일이 준비된 뒤, DB 실행 승인 후 실행
[목적] 접속 지문 확인 + 본인 DB에 migration 적용. 앱 코드는 수정하지 않음
[다음] /my-cr-app
-->

# CR DB 적용 (`/my-cr-db-apply`)

migration **파일 작성**과 DB **실행**은 다르다. 이 Command는 **실행만** 담당한다.

## 사전 조건

1. 영향 문서가 승인된 상태 (`영향 승인: ...` 완료)
2. `/my-cr-db-files`로 migration 파일이 존재
3. 사용자가 DB 적용을 승인한 상태

### DB 승인 방법

채팅에 한 줄:

`DB 적용 승인: <migration파일경로>`

예: `DB 적용 승인: database/migrations/20261029_001_add_contact_tel_to_inbound_order.sql`

**이 문구가 없으면** SQL을 실행하지 말고 중단한다. (파일을 새로 쓰지 않음)

## 수행 순서

1. **접속 지문**  
   `SELECT current_database(), current_user, current_schema();`  
   결과를 보여 주고, 사용자 예상(예: wms17 / student17 / wms)과 다르면 **실행하지 말고 중단**
2. **멱등 확인**  
   대상 컬럼이 이미 있으면 적용을 건너뛰고 “이미 존재”로 보고한 뒤 다음 안내만 한다
3. **migration 실행**  
   승인된 파일만 실행. 비밀번호를 묻거나 파일에 기록하지 않는다
4. **확인 조회**  
   컬럼·COMMENT 존재 확인

## 금지

- 앱 소스·DDL 파일 수정 (불일치 발견 시 보고만 하고 `/my-cr-db-files`로 되돌리기 안내)
- reset_schema / DROP
- 다른 학생 DB

## 종료 (필수 STOP)

```
## /my-cr-db-apply 완료
- database / user / schema: <값>
- migration 적용: 성공 | 스킵(이미 존재) | 실패
- 다음: /my-cr-app
```

자동으로 앱 수정을 시작하지 않는다.
