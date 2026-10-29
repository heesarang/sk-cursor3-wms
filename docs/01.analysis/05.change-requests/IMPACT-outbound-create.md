# CR 영향 문서 — 출고 주문 등록

| 항목 | 내용 |
|------|------|
| 문서 ID | IMPACT-outbound-create |
| 기준 요청 | `docs/01.analysis/01.rfp/wms_prd-outbound-create.md` |
| 작성 Command | `/my-create-plan` |
| 대칭 | `IMPACT-inbound-create` (입고 등록 UX·체인 대칭) |
| 승인 상태 | **승인됨** (2026-10-29, 채팅 `영향 승인:`) |

---

## 1. 요청 요약

화면에서 출고 주문을 신규 등록한다. **[출고 등록]**은 대시보드·입고·출고 공통 네비에서 열고(입고 등록과 병존), UI는 출고 주문 상세와 같은 형태(헤더 + 라인 + 저장/취소)로 한다.

## 2. 도메인 파라미터

| 키 | 값 |
|----|-----|
| `domain` | outbound |
| `label` | 출고 등록 |
| `order_kind` | OUTBOUND |
| `api_create` | `POST /api/outbound/orders` |
| `detail_ui` | OutboundDetail 유사 (`OutboundCreate` 다이얼로그 권장) |
| `nav_entry` | 전역 `[출고 등록]` (`AppNav`, `[입고 등록]`과 병존) |
| `prd` | `docs/01.analysis/01.rfp/wms_prd-outbound-create.md` |
| 초기 상태 | `status_code = '00'` |
| 채번 | 서버 `OB-{center_no}-{일련}` (시드·`OB-DONE` 등과 충돌 방지) |
| 테이블 | 기존 `wms.outbound_order` + `wms.outbound_order_line` INSERT |
| 라인 | 1건 이상, `order_qty` > 0, `picked_qty = 0` |
| 담당자 | `partner_contact_name` / `partner_contact_tel` 입력 가능 (NULL 허용) |
| 재고 | 1차 검증 **없음** (F7 후속) |

## 3. DB

**불필요** — 신규 컬럼·테이블 없음. 기존 테이블 INSERT만.

→ `/my-create-db-files` / `/my-create-db-apply` **건너뜀**.

## 4. 수정 허용 파일 목록 (ALLOWED_PATHS)

```
docs/01.analysis/02.requirements/REQ-F5-outbound-create.md
docs/01.analysis/04.ui/UI-F5-outbound-create.md
docs/01.analysis/05.change-requests/IMPACT-outbound-create.md
backend/src/main/java/com/execnt/wms/controller/OutboundOrderController.java
backend/src/main/java/com/execnt/wms/service/OutboundOrderService.java
backend/src/main/java/com/execnt/wms/mapper/OutboundOrderMapper.java
backend/src/main/resources/mapper/OutboundOrderMapper.xml
frontend/components/AppNav.js
frontend/components/OutboundCreate.js
frontend/js/api.js
frontend/views/OutboundList.js
frontend/app.js
frontend/index.html
```

- `OutboundList.js`: 선택 — 목록 보조 [출고 등록]  
- `AppNav.js`: **출고 등록 버튼·다이얼로그 연결만** 추가 (입고 등록 동작 유지)  
- `app.js` / `index.html`: `OutboundCreate` 로드·등록 시에만

## 5. 수정 금지

- 입고 Controller/Service/Mapper·`InboundCreate`/`InboundDetail` 로직 훼손
- 대시보드 집계 SQL·StatusTransitionService 전이 규칙 훼손
- 재고(F6)·재고 연동 출고 검증(F7) 범위 편입
- SecurityConfig·인증, 마스터 CRUD, 전체 시드 재작성
- CREATE DATABASE / GRANT / reset_schema
- 입고용 IMPACT/경로를 출고에 무분별 복붙(파라미터·테이블만 출고로)

## 6. 앱 작업

→ `/my-create-app` (영향 승인 후)

- `POST /api/outbound/orders` + Mapper INSERT  
- `AppNav` 전역 **[출고 등록]** + `OutboundCreate`  
- `api.outbound.create`  
- REQ-F5 / UI-F5 출고용 신규 작성

## 7. 검증

→ `/my-create-verify`

## 8. 승인 상태

**승인됨**

승인 문구:
`영향 승인: docs/01.analysis/05.change-requests/IMPACT-outbound-create.md`
