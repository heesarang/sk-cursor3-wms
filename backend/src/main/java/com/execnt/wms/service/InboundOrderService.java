package com.execnt.wms.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.execnt.wms.exception.BadRequestException;
import com.execnt.wms.exception.ResourceNotFoundException;
import com.execnt.wms.mapper.InboundOrderMapper;

@Service
public class InboundOrderService {

    private static final String ORDER_KIND = "INBOUND";
    private static final String INITIAL_STATUS = "00";

    private final InboundOrderMapper inboundOrderMapper;
    private final StatusTransitionService statusTransitionService;

    public InboundOrderService(InboundOrderMapper inboundOrderMapper,
            StatusTransitionService statusTransitionService) {
        this.inboundOrderMapper = inboundOrderMapper;
        this.statusTransitionService = statusTransitionService;
    }

    public List<Map<String, Object>> getOrders(String centerNo, String statusCode) {
        Map<String, Object> params = new HashMap<>();
        params.put("center_no", centerNo);
        params.put("status_code", statusCode);
        return inboundOrderMapper.selectInboundOrderList(params);
    }

    public Map<String, Object> getOrderDetail(String orderNo) {
        Map<String, Object> params = new HashMap<>();
        params.put("order_no", orderNo);

        Map<String, Object> header = inboundOrderMapper.selectInboundOrderDetail(params);
        if (header == null || header.isEmpty()) {
            throw new ResourceNotFoundException("입고 주문을 찾을 수 없습니다: " + orderNo);
        }

        List<Map<String, Object>> lines = inboundOrderMapper.selectInboundOrderLines(params);
        Map<String, Object> detail = new LinkedHashMap<>(header);
        detail.put("lines", lines);
        return detail;
    }

    @Transactional
    public Map<String, Object> createOrder(Map<String, Object> body) {
        String centerNo = asString(body.get("center_no"));
        String createdBy = asString(body.get("created_by"));
        if (!StringUtils.hasText(createdBy)) {
            createdBy = "demo-user";
        }
        if (createdBy.length() > 50) {
            throw new BadRequestException("created_by는 최대 50자입니다");
        }
        if (!StringUtils.hasText(centerNo)) {
            throw new BadRequestException("center_no는 필수입니다");
        }

        String partnerName = blankToNull(asString(body.get("partner_contact_name")));
        String partnerTel = blankToNull(asString(body.get("partner_contact_tel")));
        if (partnerName != null && partnerName.length() > 100) {
            throw new BadRequestException("partner_contact_name은 최대 100자입니다");
        }
        if (partnerTel != null && partnerTel.length() > 20) {
            throw new BadRequestException("partner_contact_tel은 최대 20자입니다");
        }

        Object linesObj = body.get("lines");
        if (!(linesObj instanceof List<?> rawLines) || rawLines.isEmpty()) {
            throw new BadRequestException("lines는 1건 이상 필요합니다");
        }

        Map<String, Object> centerParams = new HashMap<>();
        centerParams.put("center_no", centerNo);
        Long centerInfoId = inboundOrderMapper.selectActiveCenterIdByNo(centerParams);
        if (centerInfoId == null) {
            throw new BadRequestException("유효한 센터가 아닙니다: " + centerNo);
        }

        List<Map<String, Object>> normalizedLines = new ArrayList<>();
        int lineNo = 1;
        for (Object raw : rawLines) {
            if (!(raw instanceof Map<?, ?> lineMap)) {
                throw new BadRequestException("lines 항목 형식이 올바르지 않습니다");
            }
            String skuNo = asString(lineMap.get("sku_no"));
            if (!StringUtils.hasText(skuNo)) {
                throw new BadRequestException("sku_no는 필수입니다");
            }
            BigDecimal orderQty = toPositiveQty(lineMap.get("order_qty"), skuNo);

            Map<String, Object> skuParams = new HashMap<>();
            skuParams.put("sku_no", skuNo);
            Long itemInfoId = inboundOrderMapper.selectActiveItemIdBySku(skuParams);
            if (itemInfoId == null) {
                throw new BadRequestException("유효한 SKU가 아닙니다: " + skuNo);
            }

            Map<String, Object> line = new HashMap<>();
            line.put("line_no", lineNo++);
            line.put("item_info_id", itemInfoId);
            line.put("order_qty", orderQty);
            line.put("created_by", createdBy);
            line.put("updated_by", createdBy);
            normalizedLines.add(line);
        }

        Integer maxSeq = inboundOrderMapper.selectMaxOrderSeqByCenter(centerParams);
        int nextSeq = (maxSeq == null ? 0 : maxSeq) + 1;
        String orderNo = String.format("IB-%s-%03d", centerNo, nextSeq);

        Map<String, Object> header = new HashMap<>();
        header.put("order_no", orderNo);
        header.put("center_info_id", centerInfoId);
        header.put("status_code", INITIAL_STATUS);
        header.put("created_by", createdBy);
        header.put("updated_by", createdBy);
        header.put("partner_contact_name", partnerName);
        header.put("partner_contact_tel", partnerTel);

        inboundOrderMapper.insertInboundOrder(header);
        Object generatedId = header.get("inbound_order_id");
        if (generatedId == null) {
            throw new BadRequestException("입고 주문 등록에 실패했습니다");
        }
        Long inboundOrderId = ((Number) generatedId).longValue();

        for (Map<String, Object> line : normalizedLines) {
            line.put("inbound_order_id", inboundOrderId);
            inboundOrderMapper.insertInboundOrderLine(line);
        }

        return getOrderDetail(orderNo);
    }

    @Transactional
    public Map<String, Object> transition(String orderNo, Map<String, Object> body) {
        String toStatus = asString(body.get("to_status"));
        String changedBy = asString(body.get("changed_by"));
        String changeReason = asString(body.get("change_reason"));

        if (!StringUtils.hasText(toStatus) || !StringUtils.hasText(changedBy)) {
            throw new BadRequestException("to_status와 changed_by는 필수입니다");
        }
        if (changedBy.length() > 50) {
            throw new BadRequestException("changed_by는 최대 50자입니다");
        }
        if (changeReason != null && changeReason.length() > 500) {
            throw new BadRequestException("change_reason은 최대 500자입니다");
        }

        Map<String, Object> params = new HashMap<>();
        params.put("order_no", orderNo);
        Map<String, Object> header = inboundOrderMapper.selectInboundOrderDetail(params);
        if (header == null || header.isEmpty()) {
            throw new ResourceNotFoundException("입고 주문을 찾을 수 없습니다: " + orderNo);
        }

        String fromStatus = asString(header.get("status_code"));
        statusTransitionService.validateTransition(ORDER_KIND, fromStatus, toStatus);

        Map<String, Object> updateParams = new HashMap<>();
        updateParams.put("order_no", orderNo);
        updateParams.put("from_status", fromStatus);
        updateParams.put("to_status", toStatus);
        updateParams.put("changed_by", changedBy);

        int updated = inboundOrderMapper.updateInboundOrderStatus(updateParams);
        if (updated == 0) {
            throw new BadRequestException("상태 변경에 실패했습니다. 주문이 이미 변경되었을 수 있습니다");
        }

        statusTransitionService.insertHistory(
                ORDER_KIND, orderNo, fromStatus, toStatus, changedBy, changeReason);

        Map<String, Object> refreshed = inboundOrderMapper.selectInboundOrderDetail(params);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("order_no", orderNo);
        result.put("from_status", fromStatus);
        result.put("to_status", toStatus);
        result.put("status_name", refreshed != null ? refreshed.get("status_name") : null);
        return result;
    }

    private String asString(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private String blankToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private BigDecimal toPositiveQty(Object raw, String skuNo) {
        if (raw == null) {
            throw new BadRequestException("order_qty는 필수입니다: " + skuNo);
        }
        BigDecimal qty;
        try {
            if (raw instanceof Number number) {
                qty = new BigDecimal(number.toString());
            } else {
                qty = new BigDecimal(String.valueOf(raw).trim());
            }
        } catch (NumberFormatException ex) {
            throw new BadRequestException("order_qty 형식이 올바르지 않습니다: " + skuNo);
        }
        if (qty.compareTo(BigDecimal.ZERO) <= 0 || qty.stripTrailingZeros().scale() > 0) {
            throw new BadRequestException("order_qty는 1 이상의 정수여야 합니다: " + skuNo);
        }
        return qty;
    }
}
