package com.execnt.wms.service;

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
}
