-- =============================================================================
-- 시드: 재고 (INV_TXN_TYPE / inventory_balance / inventory_history INIT)
-- 선행: seed_common_code, seed_master, migration 또는 wms_ddl의 재고 테이블
-- 기준: wms_prd-inventory.md CR-INV-05 — 활성 센터×SKU 가용 1000 + INIT
-- 재실행 안전: 잔량 ON CONFLICT DO NOTHING, INIT WHERE NOT EXISTS
-- created_by / updated_by = 'seed'
-- 기존 확정(90) 주문 역산 없음
-- =============================================================================

-- INV_TXN_TYPE 코드그룹
INSERT INTO wms.code_group (group_code, group_name, is_active, created_by, updated_by)
VALUES ('INV_TXN_TYPE', '재고 거래 유형', TRUE, 'seed', 'seed')
ON CONFLICT (group_code) DO UPDATE
SET group_name = EXCLUDED.group_name,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';

INSERT INTO wms.common_code (code_group_id, code_value, code_name, sort_order, is_active, created_by, updated_by)
SELECT cg.code_group_id, v.code_value, v.code_name, v.sort_order, TRUE, 'seed', 'seed'
FROM wms.code_group cg
CROSS JOIN (VALUES
    ('INBOUND',  '입고 반영', 1),
    ('OUTBOUND', '출고 반영', 2),
    ('INIT',     '초기재고',  3)
) AS v(code_value, code_name, sort_order)
WHERE cg.group_code = 'INV_TXN_TYPE'
ON CONFLICT (code_group_id, code_value) DO UPDATE
SET code_name  = EXCLUDED.code_name,
    sort_order = EXCLUDED.sort_order,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';

-- 활성 센터 × 활성 품목 → 가용 1000
INSERT INTO wms.inventory_balance (
    center_info_id, item_info_id, qty_on_hand, created_by, updated_by
)
SELECT c.center_info_id, i.item_info_id, 1000, 'seed', 'seed'
FROM wms.center_info c
CROSS JOIN wms.item_info i
WHERE c.is_active = TRUE
  AND i.is_active = TRUE
ON CONFLICT (center_info_id, item_info_id) DO NOTHING;

-- INIT 이력 (잔량행당 1건)
INSERT INTO wms.inventory_history (
    inventory_balance_id, txn_type_code, change_qty, after_qty,
    order_kind, order_no, line_no, changed_by, changed_at, created_by, updated_by
)
SELECT b.inventory_balance_id, 'INIT', 1000, b.qty_on_hand,
       NULL, NULL, NULL, 'seed', now(), 'seed', 'seed'
FROM wms.inventory_balance b
JOIN wms.center_info c ON c.center_info_id = b.center_info_id
JOIN wms.item_info i ON i.item_info_id = b.item_info_id
WHERE c.is_active = TRUE
  AND i.is_active = TRUE
  AND NOT EXISTS (
      SELECT 1
      FROM wms.inventory_history h
      WHERE h.inventory_balance_id = b.inventory_balance_id
        AND h.txn_type_code = 'INIT'
  );
