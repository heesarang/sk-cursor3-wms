# CR 영향 문서 — 출고 주문 거래처 담당자 이름·연락처

| 항목 | 내용 |
|------|------|
| 문서 ID | IMPACT-outbound-partner-contact |
| 기준 요청 | 채팅 `/my-cr-plan` (출고 담당자 이름·연락처) / `10-change-request.md` §1 |
| 참고 | 입고 선행 CR `IMPACT-inbound-partner-contact-tel` / `IMPACT-inbound-partner-contact-name` (동일 컬럼 의미) |
| 작성 Command | `/my-cr-plan` |
| 승인 상태 | **승인됨** (2026-10-29, 채팅 `영향 승인:`) |

---

## 1. 요청 요약

출고 오더에 거래처 담당자 이름·연락처를 기록하고, 출고 목록·상세에서 이름·연락처를 인접 표시한다.

## 2. 컬럼 정의

| 항목 | 값 |
|------|------|
| 테이블 | `wms.outbound_order` |
| 컬럼 1 | `partner_contact_name` |
| 타입 1 | `VARCHAR(100)` |
| NULL 1 | 허용 |
| COMMENT 1 | `거래처 담당자 이름 (예: 홍길동)` |
| 컬럼 2 | `partner_contact_tel` |
| 타입 2 | `VARCHAR(20)` |
| NULL 2 | 허용 |
| COMMENT 2 | `거래처 담당자 연락처 (예: 010-1234-5678)` |
| 위치 | 공통 감사 컬럼(`created_at` 등) **뒤**에 이름·연락처 순(인접) |
| 표시 | 출고 목록 · 출고 상세 (**이름·연락처 인접**) |

## 3. 수정 허용 파일 목록 (ALLOWED_PATHS)

```
database/migrations/20261029_003_add_contact_to_outbound_order.sql
database/schemas/wms_ddl.sql
docs/99.references/data-dictionary.md
backend/src/main/resources/mapper/OutboundOrderMapper.xml
docs/01.analysis/02.requirements/REQ-F2-outbound.md
docs/01.analysis/04.ui/UI-F2-outbound.md
frontend/views/OutboundList.js
frontend/components/OutboundDetail.js
docs/01.analysis/05.change-requests/IMPACT-outbound-partner-contact.md
```

(마지막 IMPACT 경로는 승인 상태 갱신용.)

## 4. 수정 금지

- 입고(Mapper·목록·상세·REQ-F1·UI-F1)·대시보드·상태 전이 서비스/Mapper
- SecurityConfig, build.gradle(불필요 시)
- 거래처·담당자 마스터 신설, 전체 시드 재작성
- CREATE DATABASE / GRANT / reset_schema
- 입고용 migration(`20261029_001` / `20261029_002`) 재작성

## 5. DB 작업 구분

| 구분 | Command | 내용 |
|------|---------|------|
| 파일 | `/my-cr-db-files` | migration 작성 + `wms_ddl.sql` + data-dictionary 동기화 (**DB 미실행**) |
| 실행 | `/my-cr-db-apply` | 접속 지문 확인 후 본인 DB에 migration 적용 (`DB 적용 승인:` 필요) |

## 6. 앱 작업

→ `/my-cr-app` (ALLOWED_PATHS 내 Outbound Mapper·목록·상세·필요 시 REQ-F2/UI-F2; UI는 이름·연락처 인접)

## 7. 검증

→ `/my-cr-verify` (출고 목록·상세 새 필드 + 대시보드·불허 전이 회귀; 입고는 비변경 확인)

## 8. 승인 상태

**승인됨**

승인 문구:
`영향 승인: docs/01.analysis/05.change-requests/IMPACT-outbound-partner-contact.md`
