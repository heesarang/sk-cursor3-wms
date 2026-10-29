-- CR: 입고 주문 거래처 담당자 이름
-- 영향 문서: docs/01.analysis/05.change-requests/IMPACT-inbound-partner-contact-name.md
-- 본 파일은 작성만 한다. DB 적용은 /my-cr-db-apply + 「DB 적용 승인:」 후에 수행.

ALTER TABLE wms.inbound_order
    ADD COLUMN partner_contact_name VARCHAR(100);

COMMENT ON COLUMN wms.inbound_order.partner_contact_name IS '거래처 담당자 이름 (예: 홍길동)';
