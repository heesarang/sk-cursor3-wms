# CR 영향 문서 — 재고 관리·이력·입출고 확정 연동

| 항목 | 내용 |
|------|------|
| 문서 ID | IMPACT-inventory |
| 기준 요청 | `docs/01.analysis/01.rfp/wms_prd-inventory.md` |
| 참고 | `wms_prd-inventory-flow.md` §F6 (초기 재고는 **1000**, 빈 시작 아님) |
| 작성 단계 | 구현 게이트 1/4 (IMPACT만) |
| 승인 상태 | **승인** (`영향 승인` 2026-10-29) |

---

## 1. 요청 요약

센터×SKU 재고를 두고, 입고 확정 시 증가·출고 확정 시 감소하며, 네비 **재고** 메뉴에서 잔량·이력을 본다. 활성 센터×활성 품목마다 기본 가용 **1000**(+ INIT 이력). 기존 `90` 주문 역산 없음.

## 2. 도메인·설계 파라미터 (초안)

| 키 | 값 |
|----|-----|
| 잔량 테이블 (초안명) | `wms.inventory_balance` — UK(`center_info_id`,`item_info_id`), `qty_on_hand NUMERIC` ≥ 0 |
| 이력 테이블 (초안명) | `wms.inventory_history` — 유형·변동수량·반영후잔량·order_kind+order_no·line_no(선택)·처리자·일시 |
| 공통코드 | `INV_TXN_TYPE`: `INBOUND` / `OUTBOUND` / `INIT` |
| 증가 시점 | 입고 `20→90` (수량: `inspected_qty > 0` ? 그 값 : `order_qty`) |
| 감소 시점 | 출고 `20→90` (수량: `picked_qty > 0` ? 그 값 : `order_qty`), 부족 시 400·롤백 |
| 초기 시드 | 활성 센터 × 활성 SKU → 각 `qty_on_hand=1000` + INIT 이력 (예: 2×3=6행) |
| 역산 | 기존 확정(`90`) 주문 **미반영** |
| API | `GET /api/inventory`, `GET /api/inventory/{centerNo}/{skuNo}`, `GET /api/inventory/history` |
| UI | `#/inventory` — 잔량 목록 + 이력 |

물리 컬럼·제약 최종명은 DB 파일 단계에서 `06-database.mdc`·`std_check`에 맞춘다.

## 3. DB

**필요** — 신규 테이블·공통코드·초기 1000 시드.

| 구분 | Command |
|------|---------|
| 파일 | migration + `wms_ddl.sql` + `data-dictionary.md` + 시드 (± migration 내 포함) |
| 실행 | `DB 적용 승인: <migration경로>` 후 본인 DB 적용 |

제안 migration: `database/migrations/20261029_004_inventory.sql`  
제안 시드: `database/seeds/seed_inventory.sql` (또는 migration 하단에 INIT INSERT)

## 4. 수정 허용 파일 목록 (ALLOWED_PATHS)

```
database/migrations/20261029_004_inventory.sql
database/seeds/seed_inventory.sql
database/schemas/wms_ddl.sql
docs/99.references/data-dictionary.md
docs/01.analysis/02.requirements/REQ-F6-inventory.md
docs/01.analysis/04.ui/UI-F6-inventory.md
docs/01.analysis/05.change-requests/IMPACT-inventory.md
backend/src/main/java/com/execnt/wms/controller/InventoryController.java
backend/src/main/java/com/execnt/wms/service/InventoryService.java
backend/src/main/java/com/execnt/wms/mapper/InventoryMapper.java
backend/src/main/resources/mapper/InventoryMapper.xml
backend/src/main/java/com/execnt/wms/service/InboundOrderService.java
backend/src/main/java/com/execnt/wms/service/OutboundOrderService.java
backend/src/main/resources/mapper/InboundOrderMapper.xml
backend/src/main/resources/mapper/OutboundOrderMapper.xml
frontend/components/AppNav.js
frontend/views/InventoryView.js
frontend/router.js
frontend/js/api.js
frontend/app.js
frontend/index.html
```

### 경로별 허용 범위

| 경로 | 허용 내용 |
|------|-----------|
| Inbound/Outbound **Service** | `20→90` 성공 경로에서만 `InventoryService` 호출 (동일 `@Transactional`) |
| Inbound/Outbound **Mapper XML** | 확정 반영용 라인 조회(센터·SKU·수량) **추가 SELECT만**. 전이 UPDATE 로직 훼손 금지 |
| AppNav / router / index / app | **재고** 메뉴·라우트·스크립트 로드만 |
| api.js | `inventory.*` 조회 메서드만 추가 |

## 5. 수정 금지

- `wms_prd.md` 및 본 IMPACT 밖 문서 무단 개편
- 인증/JWT/SecurityConfig 강화
- 마스터(센터·품목) CRUD 화면
- 로케이션·실사·수동 재고 조정
- 입출고 **등록** UX 대수술·출고 등록 시 강제 재고 예약(F7 전체)
- StatusTransitionService 전이 규칙 테이블/검증 로직 변경 (훅은 Order Service에만)
- Dashboard Mapper 대수술
- CREATE DATABASE / GRANT / reset_schema / 타 학생 DB
- 커밋·push (사용자 요청 전)

## 6. 다음 단계

| 순서 | 조건 | Command/작업 |
|------|------|----------------|
| 2 | `영향 승인:` 후 | DB 파일 작성 (migration·DDL·사전·1000 시드). **DB 미실행** |
| 2b | `DB 적용 승인: database/migrations/20261029_004_inventory.sql` | 본인 DB 적용 |
| 3 | DB 적용 후 | 앱: Inventory API·전이 훅·재고 화면 |
| 4 | 앱 후 | 검증 (1000 행수, 증감, 부족 거부, 메뉴·회귀, ALLOWED 대조). 커밋 금지 |

## 7. 검증 체크리스트 (단계 4용 예고)

- [ ] 활성 센터×SKU 행 수·각 `qty_on_hand=1000`·INIT 이력
- [ ] 입고 `20→90` 후 증가 + INBOUND 이력
- [ ] 출고 `20→90` 후 감소 + OUTBOUND 이력
- [ ] 부족 출고 확정 → 400·잔량 불변
- [ ] `#/inventory` 잔량·이력 UI
- [ ] 대시보드·입출고 목록/등록 회귀
- [ ] ALLOWED_PATHS 대조표

## 8. 승인 상태

**승인** — `영향 승인: docs/01.analysis/05.change-requests/IMPACT-inventory.md`

DB 파일(단계 2) 작성 완료.
DB 적용(단계 2b) 완료 — `wms17` / `student17` / `wms` (`20261029_004_inventory.sql`).

다음: 단계 3 앱 구현 (Inventory API·전이 훅·재고 화면).
