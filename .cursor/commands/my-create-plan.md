<!--
[사용법] /my-create-plan — PRD·도메인 파라미터와 함께 실행
[목적] 등록 기능 영향 문서만 작성 후 STOP
[다음] 영향 승인 → (DB 있으면 db-files) → /my-create-app
-->

# 등록 기능 계획 (`/my-create-plan`)

## 절대 금지

- 소스·Mapper·프론트·migration·DDL·시드 수정
- DB 접속·실행
- 커밋·push
- 입고용 경로를 출고 요청에 임의 전용

## 1. 명세 확정 (없으면 질문, 추측 강행 금지)

사용자/PRD에서 확인:

- `domain` / `label` / `order_kind`
- `api_create` (Method·Path)
- 대상 테이블(헤더·라인) — **기존 테이블 INSERT**인지, DDL 추가인지
- 등록 UI: **해당 도메인 상세와 유사**한지, 전역 네비 버튼 문구
- 초기 `status_code`, 채번 규칙, 필수 필드·라인 규칙
- 범위 밖 (예: 재고 연동, 반대편 입출고 등록, 마스터 CRUD)

## 2. 영향 문서 (유일한 산출물)

경로:
`docs/01.analysis/05.change-requests/IMPACT-<slug>-create.md`  
예: `IMPACT-inbound-create.md`, `IMPACT-outbound-create.md`

필수 섹션:

1. 요청 요약  
2. **도메인 파라미터** 표 (`domain`, `label`, `api_create`, `detail_ui`, `nav_entry`, …)  
3. **DB** — `불필요` | `migration 필요` (필요 시 컬럼/테이블 요약)  
4. **ALLOWED_PATHS** (한 줄에 하나씩). 도메인에 맞게 고른다. 후보:

```
# 문서
docs/01.analysis/02.requirements/REQ-F5-<domain>-create.md   # 또는 합의된 REQ 경로
docs/01.analysis/04.ui/UI-F5-<domain>-create.md             # 또는 기존 UI 문서 최소 갱신
docs/01.analysis/05.change-requests/IMPACT-<slug>-create.md

# 백엔드 (해당 도메인만)
backend/src/main/java/com/execnt/wms/controller/<Xxx>Controller.java
backend/src/main/java/com/execnt/wms/service/<Xxx>Service.java
backend/src/main/java/com/execnt/wms/mapper/<Xxx>Mapper.java
backend/src/main/resources/mapper/<Xxx>Mapper.xml

# 프론트
frontend/components/AppNav.js
frontend/components/<Domain>Create.js          # 또는 Detail mode=create
frontend/js/api.js                             # create 메서드만 추가
frontend/views/<Domain>List.js                 # 선택: 보조 버튼
frontend/app.js / index.html                   # 스크립트 로드 시에만

# DB가 있을 때만
database/migrations/YYYYMMDD_NNN_....sql
database/schemas/wms_ddl.sql
docs/99.references/data-dictionary.md
```

5. 수정 금지 — 반대 도메인·대시보드 로직 무단 변경·전이 규칙 훼손·인증 추가 등  
6. 다음 Command — DB 유무에 따라 `my-create-db-files` 또는 `my-create-app`  
7. 검증 → `/my-create-verify`  
8. 승인 상태 — `대기`

## 3. 종료 (필수 STOP)

```
## /my-create-plan 완료
- 영향 문서: <경로>
- DB: 불필요 | 필요
- 승인 상태: 대기

다음: 영향 승인: <경로>
그 다음: <DB 필요 시 /my-create-db-files, 아니면 /my-create-app>
```
