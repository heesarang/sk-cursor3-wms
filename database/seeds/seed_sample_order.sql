-- =============================================================================
-- 시드: 샘플 주문·라인·상태 이력
-- REQ-F1/F2/F3/F4 §5 시드 전제
-- 재실행 안전: 주문·라인 ON CONFLICT / 이력 WHERE NOT EXISTS
-- created_by / updated_by = 'seed'
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. 입고 주문 헤더 (CTR01 상태 분산 + IB-INVALID-TRANS)
-- -----------------------------------------------------------------------------
INSERT INTO wms.inbound_order (
    order_no, center_info_id, status_code, ordered_at, created_by, updated_by
)
SELECT v.order_no, c.center_info_id, v.status_code, v.ordered_at, 'seed', 'seed'
FROM (VALUES
    ('IB-CTR01-001',      'CTR01', '00', TIMESTAMPTZ '2026-10-20 09:00:00+09'),
    ('IB-CTR01-010',      'CTR01', '10', TIMESTAMPTZ '2026-10-21 10:00:00+09'),
    ('IB-CTR01-020',      'CTR01', '20', TIMESTAMPTZ '2026-10-22 11:00:00+09'),
    ('IB-INVALID-TRANS',  'CTR01', '90', TIMESTAMPTZ '2026-10-15 08:00:00+09'),
    ('IB-CTR02-001',      'CTR02', '00', TIMESTAMPTZ '2026-10-23 09:30:00+09')
) AS v(order_no, center_no, status_code, ordered_at)
JOIN wms.center_info c ON c.center_no = v.center_no
ON CONFLICT (order_no) DO UPDATE
SET center_info_id = EXCLUDED.center_info_id,
    status_code    = EXCLUDED.status_code,
    ordered_at     = EXCLUDED.ordered_at,
    updated_at     = now(),
    updated_by     = 'seed';

-- -----------------------------------------------------------------------------
-- 2. 입고 주문 라인
-- -----------------------------------------------------------------------------
INSERT INTO wms.inbound_order_line (
    inbound_order_id, line_no, item_info_id, order_qty, inspected_qty, created_by, updated_by
)
SELECT io.inbound_order_id, v.line_no, i.item_info_id, v.order_qty, v.inspected_qty, 'seed', 'seed'
FROM (VALUES
    ('IB-CTR01-001',     1, 'SKU-AAA', 10::NUMERIC, 0::NUMERIC),
    ('IB-CTR01-001',     2, 'SKU-BBB',  5::NUMERIC, 0::NUMERIC),
    ('IB-CTR01-010',     1, 'SKU-AAA', 20::NUMERIC, 8::NUMERIC),
    ('IB-CTR01-020',     1, 'SKU-BBB', 15::NUMERIC, 15::NUMERIC),
    ('IB-CTR01-020',     2, 'SKU-CCC',  7::NUMERIC,  7::NUMERIC),
    ('IB-INVALID-TRANS', 1, 'SKU-AAA', 30::NUMERIC, 30::NUMERIC),
    ('IB-CTR02-001',     1, 'SKU-CCC', 12::NUMERIC,  0::NUMERIC)
) AS v(order_no, line_no, sku_no, order_qty, inspected_qty)
JOIN wms.inbound_order io ON io.order_no = v.order_no
JOIN wms.item_info i ON i.sku_no = v.sku_no
ON CONFLICT (inbound_order_id, line_no) DO UPDATE
SET item_info_id  = EXCLUDED.item_info_id,
    order_qty     = EXCLUDED.order_qty,
    inspected_qty = EXCLUDED.inspected_qty,
    updated_at    = now(),
    updated_by    = 'seed';

-- -----------------------------------------------------------------------------
-- 3. 출고 주문 헤더 (CTR01 상태 분산 + OB-DONE)
-- -----------------------------------------------------------------------------
INSERT INTO wms.outbound_order (
    order_no, center_info_id, status_code, ordered_at, created_by, updated_by
)
SELECT v.order_no, c.center_info_id, v.status_code, v.ordered_at, 'seed', 'seed'
FROM (VALUES
    ('OB-CTR01-001', 'CTR01', '00', TIMESTAMPTZ '2026-10-20 14:00:00+09'),
    ('OB-CTR01-010', 'CTR01', '10', TIMESTAMPTZ '2026-10-21 15:00:00+09'),
    ('OB-CTR01-020', 'CTR01', '20', TIMESTAMPTZ '2026-10-22 16:00:00+09'),
    ('OB-DONE',      'CTR01', '90', TIMESTAMPTZ '2026-10-16 13:00:00+09'),
    ('OB-CTR02-001', 'CTR02', '00', TIMESTAMPTZ '2026-10-23 14:30:00+09')
) AS v(order_no, center_no, status_code, ordered_at)
JOIN wms.center_info c ON c.center_no = v.center_no
ON CONFLICT (order_no) DO UPDATE
SET center_info_id = EXCLUDED.center_info_id,
    status_code    = EXCLUDED.status_code,
    ordered_at     = EXCLUDED.ordered_at,
    updated_at     = now(),
    updated_by     = 'seed';

-- -----------------------------------------------------------------------------
-- 4. 출고 주문 라인
-- -----------------------------------------------------------------------------
INSERT INTO wms.outbound_order_line (
    outbound_order_id, line_no, item_info_id, order_qty, picked_qty, created_by, updated_by
)
SELECT oo.outbound_order_id, v.line_no, i.item_info_id, v.order_qty, v.picked_qty, 'seed', 'seed'
FROM (VALUES
    ('OB-CTR01-001', 1, 'SKU-AAA',  8::NUMERIC, 0::NUMERIC),
    ('OB-CTR01-001', 2, 'SKU-CCC',  3::NUMERIC, 0::NUMERIC),
    ('OB-CTR01-010', 1, 'SKU-BBB', 12::NUMERIC, 5::NUMERIC),
    ('OB-CTR01-020', 1, 'SKU-AAA', 10::NUMERIC, 10::NUMERIC),
    ('OB-DONE',      1, 'SKU-BBB', 20::NUMERIC, 20::NUMERIC),
    ('OB-CTR02-001', 1, 'SKU-AAA',  6::NUMERIC,  0::NUMERIC)
) AS v(order_no, line_no, sku_no, order_qty, picked_qty)
JOIN wms.outbound_order oo ON oo.order_no = v.order_no
JOIN wms.item_info i ON i.sku_no = v.sku_no
ON CONFLICT (outbound_order_id, line_no) DO UPDATE
SET item_info_id = EXCLUDED.item_info_id,
    order_qty    = EXCLUDED.order_qty,
    picked_qty   = EXCLUDED.picked_qty,
    updated_at   = now(),
    updated_by   = 'seed';

-- -----------------------------------------------------------------------------
-- 5. 상태 이력 (IB-CTR01-020 trace + 복수 최근 이력)
--    UK 없음 → WHERE NOT EXISTS 로 재실행 안전
-- -----------------------------------------------------------------------------
INSERT INTO wms.order_status_history (
    order_kind, order_no, from_status_code, to_status_code,
    changed_by, change_reason, changed_at, created_by, updated_by
)
SELECT v.order_kind, v.order_no, v.from_status_code, v.to_status_code,
       v.changed_by, v.change_reason, v.changed_at, 'seed', 'seed'
FROM (VALUES
    -- IB-CTR01-020: 00→10→20 (대시보드 trace)
    ('INBOUND',  'IB-CTR01-020',     '00', '10', 'seed', '검수시작',
        TIMESTAMPTZ '2026-10-22 11:30:00+09'),
    ('INBOUND',  'IB-CTR01-020',     '10', '20', 'seed', '검수완료',
        TIMESTAMPTZ '2026-10-22 12:00:00+09'),
    -- IB-CTR01-010: 00→10
    ('INBOUND',  'IB-CTR01-010',     '00', '10', 'seed', '검수시작',
        TIMESTAMPTZ '2026-10-21 10:30:00+09'),
    -- IB-INVALID-TRANS: 완료 경로
    ('INBOUND',  'IB-INVALID-TRANS', '00', '10', 'seed', '검수시작',
        TIMESTAMPTZ '2026-10-15 09:00:00+09'),
    ('INBOUND',  'IB-INVALID-TRANS', '10', '20', 'seed', '검수완료',
        TIMESTAMPTZ '2026-10-15 10:00:00+09'),
    ('INBOUND',  'IB-INVALID-TRANS', '20', '90', 'seed', '입고확정',
        TIMESTAMPTZ '2026-10-15 11:00:00+09'),
    -- 출고 이력
    ('OUTBOUND', 'OB-CTR01-010',     '00', '10', 'seed', '피킹시작',
        TIMESTAMPTZ '2026-10-21 15:30:00+09'),
    ('OUTBOUND', 'OB-CTR01-020',     '00', '10', 'seed', '피킹시작',
        TIMESTAMPTZ '2026-10-22 16:20:00+09'),
    ('OUTBOUND', 'OB-CTR01-020',     '10', '20', 'seed', '피킹완료',
        TIMESTAMPTZ '2026-10-22 17:00:00+09'),
    ('OUTBOUND', 'OB-DONE',          '00', '10', 'seed', '피킹시작',
        TIMESTAMPTZ '2026-10-16 13:30:00+09'),
    ('OUTBOUND', 'OB-DONE',          '10', '20', 'seed', '피킹완료',
        TIMESTAMPTZ '2026-10-16 14:00:00+09'),
    ('OUTBOUND', 'OB-DONE',          '20', '90', 'seed', '출고확정',
        TIMESTAMPTZ '2026-10-16 15:00:00+09')
) AS v(order_kind, order_no, from_status_code, to_status_code, changed_by, change_reason, changed_at)
WHERE NOT EXISTS (
    SELECT 1
    FROM wms.order_status_history h
    WHERE h.order_kind       = v.order_kind
      AND h.order_no         = v.order_no
      AND h.from_status_code = v.from_status_code
      AND h.to_status_code   = v.to_status_code
      AND h.changed_at       = v.changed_at
      AND h.created_by       = 'seed'
);
