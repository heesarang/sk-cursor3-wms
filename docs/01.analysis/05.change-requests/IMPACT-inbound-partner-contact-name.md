# CR 영향 문서 — 입고 주문 거래처 담당자 이름

| 항목 | 내용 |
|------|------|
| 문서 ID | IMPACT-inbound-partner-contact-name |
| 기준 요청 | `docs/01.analysis/01.rfp/wms_prd-inbound-contact-name.md` / `10-change-request.md` §1 |
| 선행 CR | `IMPACT-inbound-partner-contact-tel` (`partner_contact_tel`) |
| 작성 Command | `/my-cr-plan` |
| 승인 상태 | **승인됨** (2026-10-29, 채팅 `영향 승인:`) |

---

## 1. 요청 요약

입고 오더에 거래처 담당자 이름을 기록하고, 입고 목록·상세에서 연락처 옆에 보이게 한다.

## 2. 컬럼 정의

| 항목 | 값 |
|------|------|
| 테이블 | `wms.inbound_order` |
| 컬럼 | `partner_contact_name` |
| 타입 | `VARCHAR(100)` |
| NULL | 허용 |
| COMMENT | `거래처 담당자 이름 (예: 홍길동)` |
| 위치 | 공통 감사 컬럼 뒤·기존 `partner_contact_tel` **다음**(인접) |
| 표시 | 입고 목록 · 입고 상세 (**연락처 옆**) |

## 3. 수정 허용 파일 목록 (ALLOWED_PATHS)

```
database/migrations/20261029_002_add_contact_name_to_inbound_order.sql
database/schemas/wms_ddl.sql
docs/99.references/data-dictionary.md
backend/src/main/resources/mapper/InboundOrderMapper.xml
docs/01.analysis/02.requirements/REQ-F1-inbound.md
docs/01.analysis/04.ui/UI-F1-inbound.md
frontend/views/InboundList.js
frontend/components/InboundDetail.js
docs/01.analysis/05.change-requests/IMPACT-inbound-partner-contact-name.md
```

(마지막 IMPACT 경로는 승인 상태 갱신용.)

## 4. 수정 금지

- 출고·대시보드·상태 전이 서비스/Mapper
- SecurityConfig, build.gradle(불필요 시)
- 거래처·담당자 마스터 신설, 전체 시드 재작성
- 연락처 컬럼(`partner_contact_tel`) 정의 변경·삭제
- CREATE DATABASE / GRANT / reset_schema
- 선행 tel migration(`20261029_001_...`) 재작성

## 5. DB 작업 구분

| 구분 | Command | 내용 |
|------|---------|------|
| 파일 | `/my-cr-db-files` | migration 작성 + `wms_ddl.sql` + data-dictionary 동기화 (**DB 미실행**) |
| 실행 | `/my-cr-db-apply` | 접속 지문 확인 후 본인 DB에 migration 적용 (`DB 적용 승인:` 필요) |

## 6. 앱 작업

→ `/my-cr-app` (ALLOWED_PATHS 내 Mapper·목록·상세·필요 시 REQ/UI; UI는 이름·연락처 인접 배치)

## 7. 검증

→ `/my-cr-verify` (새 필드 + 선행 연락처 표시·전이·대시보드 회귀)

## 8. 승인 상태

**승인됨**

승인 문구:
`영향 승인: docs/01.analysis/05.change-requests/IMPACT-inbound-partner-contact-name.md`
