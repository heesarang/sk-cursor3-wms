<!--
[사용법] /my-cr-app — 영향 승인 + (권장) DB 적용 완료 후 실행
[목적] ALLOWED_PATHS 안의 백엔드·프론트(및 허용된 REQ/UI)만 수정
[다음] /my-cr-verify
-->

# CR 앱 반영 (`/my-cr-app`)

## 사전 조건

1. `영향 승인: <영향문서>` 완료
2. 영향 문서의 ALLOWED_PATHS를 다시 읽는다 — **목록에 없는 경로는 수정 금지**
3. DB 컬럼이 아직 없으면: 조회가 실패할 수 있음을 경고하고, 사용자가 강행할지 확인한다.  
   기본은 `/my-cr-db-apply` 완료 후 진행을 권장. 강행 승인이 없으면 중단.

## 수행 내용 (화이트리스트만)

순서 고정:

1. **백엔드** — 입고 목록·상세 SELECT/응답에 컬럼 포함  
   - 전이 API·StatusTransitionService·출고·대시보드 수정 금지  
   - 빌드(`gradlew.bat build` 또는 compile) 확인  
   - 서버가 떠 있으면 목록·상세 JSON에 필드 존재 확인 (없으면 환경 이슈로 보고, 추측 수정 금지)
2. **프론트** — 목록·상세 표시만  
   - `api.js` 경로 변경 금지(필드만 사용)
3. ALLOWED_PATHS에 있을 때만 REQ §5 / UI-F1 최소 갱신

## 금지

- ALLOWED_PATHS 밖 파일
- DB migration 실행·DDL 추가 변경
- 커밋
- 정상 상태 전이로 시드 대량 소모 (검증은 `/my-cr-verify`)

## 종료 (필수 STOP)

```
## /my-cr-app 완료
- 수정한 파일: (ALLOWED_PATHS와 대조한 목록)
- 빌드: 성공/실패
- 다음: /my-cr-verify
```

검증 Command를 자동 실행하지 않는다.
