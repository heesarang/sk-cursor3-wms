# 요구사항 — 출고 주문 등록 (F5)

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-F5-outbound-create |
| 기준 PRD | `wms_prd-outbound-create.md` |
| 영향 문서 | `IMPACT-outbound-create.md` |

## §5. API — 출고 주문 등록

- **Method / Path**: `POST /api/outbound/orders`
- **Body**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| center_no | string | Y | 활성 센터 번호 |
| partner_contact_name | string | N | 최대 100 |
| partner_contact_tel | string | N | 최대 20 |
| created_by | string | N | 기본 `demo-user`, 최대 50 |
| lines | array | Y | 1건 이상 |
| lines[].sku_no | string | Y | 활성 SKU |
| lines[].order_qty | number | Y | 1 이상 정수 |

- **성공** (200): `{ "success": true, "data": { ...상세와 동일, status_code "00"... } }`
- **실패** (400): `{ "success": false, "message": "..." }`

채번: `OB-{center_no}-{일련3자리}` (`OB-DONE` 등 비패턴 주문과 충돌하지 않음). 초기 `picked_qty = 0`. 1차 재고 검증 없음.
