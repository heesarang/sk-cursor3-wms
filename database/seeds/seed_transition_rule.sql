-- =============================================================================
-- 시드: 상태 전이 규칙 (status_transition_rule)
-- INBOUND / OUTBOUND 각 00→10, 10→20, 20→90 (is_active=true)
-- 재실행 안전: ON CONFLICT
-- created_by / updated_by = 'seed'
-- =============================================================================

INSERT INTO wms.     (
    order_kind, from_status_code, to_status_code, is_active, created_by, updated_by
)
VALUES
    -- 입고
    ('INBOUND',  '00', '10', TRUE, 'seed', 'seed'),
    ('INBOUND',  '10', '20', TRUE, 'seed', 'seed'),
    ('INBOUND',  '20', '90', TRUE, 'seed', 'seed'),
    -- 출고
    ('OUTBOUND', '00', '10', TRUE, 'seed', 'seed'),
    ('OUTBOUND', '10', '20', TRUE, 'seed', 'seed'),
    ('OUTBOUND', '20', '90', TRUE, 'seed', 'seed')
ON CONFLICT (order_kind, from_status_code, to_status_code) DO UPDATE
SET is_active  = EXCLUDED.is_active,
    updated_at = now(),
    updated_by = 'seed';
