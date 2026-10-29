-- CR: 입고 주문 거래처 담당자 연락처
-- 영향 문서: docs/01.analysis/05.change-requests/IMPACT-inbound-partner-contact-tel.md
-- 본 파일은 작성만 한다. DB 적용은 /my-cr-db-apply + 「DB 적용 승인:」 후에 수행.

ALTER TABLE wms.inbound_order
    ADD COLUMN partner_contact_tel VARCHAR(20);

COMMENT ON COLUMN wms.inbound_order.partner_contact_tel IS '거래처 담당자 연락처 (예: 010-1234-5678)';
