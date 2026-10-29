# CR 영향 문서 — 입고 주문 등록

| 항목 | 내용 |
|------|------|
| 문서 ID | IMPACT-inbound-create |
| 기준 요청 | `docs/01.analysis/01.rfp/wms_prd-inbound-create.md` |
| 작성 Command | `/my-create-plan` |
| 승인 상태 | **승인됨** (2026-10-29, 채팅 `영향 승인:`) |

---

## 1. 요청 요약

화면에서 입고 주문을 신규 등록한다. **[입고 등록]**은 대시보드·입고·출고 공통 네비에서 열고, UI는 입고 주문 상세와 같은 형태(헤더 + 라인 + 저장/취소)로 한다.

## 2. 도메인 파라미터

| 키 | 값 |
|----|-----|
| `domain` | inbound |
| `label` | 입고 등록 |
| `order_kind` | INBOUND |
| `api_create` | `POST /api/inbound/orders` |
| `detail_ui` | InboundDetail 유사 (`InboundCreate` 다이얼로그 권장) |
| `nav_entry` | 전역 `[입고 등록]` (`AppNav`) |
| `prd` | `docs/01.analysis/01.rfp/wms_prd-inbound-create.md` |
| 초기 상태 | `status_code = '00'` |
| 채번 | 서버 `IB-{center_no}-{일련}` (시드와 충돌 방지) |
| 테이블 | 기존 `wms.inbound_order` + `wms.inbound_order_line` INSERT |
| 라인 | 1건 이상, `order_qty` > 0, `inspected_qty = 0` |
| 담당자 | `partner_contact_name` / `partner_contact_tel` 입력 가능 (NULL 허용) |

## 3. DB

**불필요** — 신규 컬럼·테이블 없음. 기존 테이블 INSERT만.

→ `/my-create-db-files` / `/my-create-db-apply` **건너뜀**.

## 4. 수정 허용 파일 목록 (ALLOWED_PATHS)

```
docs/01.analysis/02.requirements/REQ-F5-inbound-create.md
docs/01.analysis/04.ui/UI-F5-inbound-create.md
docs/01.analysis/05.change-requests/IMPACT-inbound-create.md
backend/src/main/java/com/execnt/wms/controller/InboundOrderController.java
backend/src/main/java/com/execnt/wms/service/InboundOrderService.java
backend/src/main/java/com/execnt/wms/mapper/InboundOrderMapper.java
backend/src/main/resources/mapper/InboundOrderMapper.xml
frontend/components/AppNav.js
frontend/components/InboundCreate.js
frontend/js/api.js
frontend/views/InboundList.js
frontend/app.js
frontend/index.html
```

- `InboundList.js`: 선택 — 목록 보조 [입고 등록] (네비와 동일 다이얼로그).  
- `app.js` / `index.html`: `InboundCreate` 스크립트 로드·등록 시에만.

## 5. 수정 금지

- 출고 Controller/Service/Mapper·`OutboundList`/`OutboundDetail` 무단 변경
- 대시보드 집계 SQL·StatusTransitionService 전이 규칙 훼손
- 재고(F6)·출고 등록(F7) 범위 편입
- SecurityConfig·인증, 마스터 CRUD, 전체 시드 재작성
- CREATE DATABASE / GRANT / reset_schema
- 입고용이 아닌 도메인 경로로의 복붙

## 6. 앱 작업

→ `/my-create-app` (영향 승인 후)

- `POST /api/inbound/orders` + Mapper INSERT  
- `AppNav` 전역 버튼 + `InboundCreate` (상세형 레이아웃)  
- `api.inbound.create`  
- REQ-F5 / UI-F5 신규 작성

## 7. 검증

→ `/my-create-verify`

## 8. 승인 상태

**승인됨**

승인 문구:
`영향 승인: docs/01.analysis/05.change-requests/IMPACT-inbound-create.md`
