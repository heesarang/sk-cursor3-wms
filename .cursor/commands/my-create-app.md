<!--
[사용법] /my-create-app — 영향 승인 후 (및 DB 필요 시 적용 후)
[목적] ALLOWED_PATHS만으로 등록 API·전역 버튼·상세형 입력 UI 구현
[다음] /my-create-verify
-->

# 등록 기능 앱 반영 (`/my-create-app`)

## 사전 조건

1. `영향 승인:` 완료, IMPACT의 ALLOWED_PATHS 재확인 — **목록 밖 수정 금지**  
2. IMPACT § DB가 `필요`인데 미적용이면 경고 후 강행 승인 없으면 중단  
3. 도메인 파라미터(`api_create`, `label`, `detail_ui`, `nav_entry`)를 IMPACT에서 다시 읽는다

## 수행 순서 (화이트리스트만)

1. **백엔드**  
   - `POST` 등록: 검증 → 채번 → 헤더·라인 INSERT (동일 트랜잭션)  
   - 초기 상태·NULL 정책은 IMPACT/PRD  
   - 전이 API·StatusTransitionService·반대 도메인·대시보드 Mapper 무단 수정 금지  
   - `gradlew` compile/build 확인  

2. **프론트**  
   - `AppNav`(또는 합의된 공통 헤더)에 IMPACT의 `nav_entry` 버튼 — **대시보드·입고·출고 등 기존 라우트 전부**에서 보임  
   - 등록 UI는 IMPACT `detail_ui`와 **같은 정보 구조**(헤더 그리드 + 라인 테이블 + 저장/취소). 전이 버튼 없음  
   - `api.js`에는 **create 호출만** 추가 (기존 경로 파괴 금지)  

3. ALLOWED에 있을 때만 REQ/UI 문서 최소 갱신  

## 금지

- ALLOWED 밖, 무단 migration 실행, 커밋  
- 입고용 하드코드를 출고 IMPACT에 복붙  

## 종료 STOP

```
## /my-create-app 완료
- 수정한 파일: (ALLOWED와 대조)
- 빌드: 성공/실패
- 런타임: (서버 떠 있으면 create 응답 요약, 없으면 재시작 안내)
- 다음: /my-create-verify
```
