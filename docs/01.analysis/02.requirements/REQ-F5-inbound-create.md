# 요구사항 — 입고 주문 등록 (F5)

| 항목 | 내용 |
|------|------|
| 문서 ID | REQ-F5-inbound-create |
| 기준 PRD | `wms_prd-inbound-create.md` |
| 영향 문서 | `IMPACT-inbound-create.md` |

## §5. API — 입고 주문 등록

- **Method / Path**: `POST /api/inbound/orders`
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

채번: `IB-{center_no}-{일련3자리}`. 초기 `inspected_qty = 0`.
