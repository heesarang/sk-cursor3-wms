-- =============================================================================
-- 시드: 공통코드 (code_group / common_code)
-- 재실행 안전: ON CONFLICT
-- created_by / updated_by = 'seed'
-- =============================================================================

-- 코드그룹
INSERT INTO wms.code_group (group_code, group_name, is_active, created_by, updated_by)
VALUES
    ('INB_STATUS', '입고 상태', TRUE, 'seed', 'seed'),
    ('OUT_STATUS', '출고 상태', TRUE, 'seed', 'seed'),
    ('ORDER_KIND', '주문 종류', TRUE, 'seed', 'seed')
ON CONFLICT (group_code) DO UPDATE
SET group_name = EXCLUDED.group_name,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';

-- INB_STATUS
INSERT INTO wms.common_code (code_group_id, code_value, code_name, sort_order, is_active, created_by, updated_by)
SELECT cg.code_group_id, v.code_value, v.code_name, v.sort_order, TRUE, 'seed', 'seed'
FROM wms.code_group cg
CROSS JOIN (VALUES
    ('00', '주문생성', 1),
    ('10', '검수중',   2),
    ('20', '검수완료', 3),
    ('90', '입고확정', 4)
) AS v(code_value, code_name, sort_order)
WHERE cg.group_code = 'INB_STATUS'
ON CONFLICT (code_group_id, code_value) DO UPDATE
SET code_name  = EXCLUDED.code_name,
    sort_order = EXCLUDED.sort_order,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';

-- OUT_STATUS
INSERT INTO wms.common_code (code_group_id, code_value, code_name, sort_order, is_active, created_by, updated_by)
SELECT cg.code_group_id, v.code_value, v.code_name, v.sort_order, TRUE, 'seed', 'seed'
FROM wms.code_group cg
CROSS JOIN (VALUES
    ('00', '주문생성', 1),
    ('10', '피킹중',   2),
    ('20', '피킹완료', 3),
    ('90', '출고확정', 4)
) AS v(code_value, code_name, sort_order)
WHERE cg.group_code = 'OUT_STATUS'
ON CONFLICT (code_group_id, code_value) DO UPDATE
SET code_name  = EXCLUDED.code_name,
    sort_order = EXCLUDED.sort_order,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';

-- ORDER_KIND
INSERT INTO wms.common_code (code_group_id, code_value, code_name, sort_order, is_active, created_by, updated_by)
SELECT cg.code_group_id, v.code_value, v.code_name, v.sort_order, TRUE, 'seed', 'seed'
FROM wms.code_group cg
CROSS JOIN (VALUES
    ('INBOUND',  '입고', 1),
    ('OUTBOUND', '출고', 2)
) AS v(code_value, code_name, sort_order)
WHERE cg.group_code = 'ORDER_KIND'
ON CONFLICT (code_group_id, code_value) DO UPDATE
SET code_name  = EXCLUDED.code_name,
    sort_order = EXCLUDED.sort_order,
    is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';
