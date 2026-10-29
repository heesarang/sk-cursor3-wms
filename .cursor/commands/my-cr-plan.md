<!--
[사용법] /my-cr-plan — 변경 요청 문구와 함께 실행
[목적] 계획만: 코드·SQL 없이 영향 문서(수정 허용 파일 목록 포함) 작성 후 중단
[다음] 사람 승인 → /my-cr-db-files
-->

# CR 계획 — 영향 문서 (`/my-cr-plan`)

`10-change-request.md` §1 단순 컬럼 추가의 **계획 단계만** 수행한다.

## 절대 금지 (이 Command)

- 소스 코드·Mapper XML·프론트 수정
- `database/migrations/` SQL 작성·수정
- `wms_ddl.sql` / 시드 수정
- DB 접속·ALTER·쿼리 실행(조회 포함도 가능하면 생략; 계획만)
- 커밋·push

## 수행 내용

### 1. 명세 정리

사용자 요청에서 다음을 확정한다. 없으면 질문하고, **추측으로 파일 생성을 강행하지 않는다.**
가이드 예시로 임의 진행하지 않는다.

- 대상 테이블 (기본 후보: `wms.inbound_order`)
- 컬럼명·타입·NULL·COMMENT
- 표시 위치 (목록 / 상세)
- 범위 밖: 거래처 마스터, 출고·대시보드·전이 로직

### 2. 영향 문서 작성 (유일한 산출물)

경로:
`docs/01.analysis/05.change-requests/IMPACT-<짧은영문slug>.md`

문서에 반드시 포함할 섹션:

1. **요청 요약** (원문 한두 문장)
2. **컬럼 정의** (이름, 타입, NULL, COMMENT, 테이블)
3. **수정 허용 파일 목록 (ALLOWED_PATHS)** — 경로를 한 줄에 하나씩. 이 목록만 이후 Command가 수정 가능
4. **수정 금지** — 출고/대시보드/전이/SecurityConfig/전체 시드 재작성 등
5. **DB 작업 구분**  
   - 파일 작업: migration 작성 + 기준 DDL·사전 동기화 → `/my-cr-db-files`  
   - DB 실행: 본인 DB 적용 → `/my-cr-db-apply`
6. **앱 작업** → `/my-cr-app`
7. **검증** → `/my-cr-verify`
8. **승인 상태** — `대기` (초기값)

ALLOWED_PATHS 후보 예시(요청에 맞게 줄이거나 늘린다):

```
database/migrations/YYYYMMDD_NNN_add_<column>_to_inbound_order.sql
database/schemas/wms_ddl.sql
docs/99.references/data-dictionary.md
backend/src/main/resources/mapper/InboundOrderMapper.xml
docs/01.analysis/02.requirements/REQ-F1-inbound.md
docs/01.analysis/04.ui/UI-F1-inbound.md
frontend/views/InboundList.js
frontend/components/InboundDetail.js
```

### 3. 종료 (필수 STOP)

영향 문서를 저장한 뒤 **여기서 멈춘다.** 다음 Command를 자동 실행하지 않는다.

채팅에 출력:

```
## /my-cr-plan 완료
- 영향 문서: <경로>
- 승인 상태: 대기

다음 단계로 가려면 채팅에 한 줄로 보내세요:
영향 승인: <경로>

그 다음 Command: /my-cr-db-files
(승인 문구 없이 /my-cr-db-files를 실행하면 거부하고 중단하세요)
```
