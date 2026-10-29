-- =============================================================================
-- 시드: 기준정보 (center_info / item_info)
-- REQ §5: CTR01, CTR02 / SKU-AAA, SKU-BBB, SKU-CCC
-- 재실행 안전: ON CONFLICT
-- created_by / updated_by = 'seed'
-- =============================================================================

INSERT INTO wms.center_info (center_no, center_name, is_active, created_by, updated_by)
VALUES
    ('CTR01', '서울센터', TRUE, 'seed', 'seed'),
    ('CTR02', '부산센터', TRUE, 'seed', 'seed')
ON CONFLICT (center_no) DO UPDATE
SET center_name = EXCLUDED.center_name,
    is_active   = EXCLUDED.is_active,
    updated_at  = now(),
    updated_by  = 'seed';

INSERT INTO wms.item_info (sku_no, item_name, is_active, created_by, updated_by)
VALUES
    ('SKU-AAA', '상품 AAA', TRUE, 'seed', 'seed'),
    ('SKU-BBB', '상품 BBB', TRUE, 'seed', 'seed'),
    ('SKU-CCC', '상품 CCC', TRUE, 'seed', 'seed')
ON CONFLICT (sku_no) DO UPDATE
SET item_name  = EXCLUDED.item_name,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';
