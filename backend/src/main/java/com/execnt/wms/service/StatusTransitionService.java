package com.execnt.wms.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.execnt.wms.exception.BadRequestException;
import com.execnt.wms.exception.InvalidTransitionException;
import com.execnt.wms.mapper.StatusTransitionMapper;

@Service
public class StatusTransitionService {

    private final StatusTransitionMapper statusTransitionMapper;

    public StatusTransitionService(StatusTransitionMapper statusTransitionMapper) {
        this.statusTransitionMapper = statusTransitionMapper;
    }

    /**
     * status_transition_rule(is_active=true) 기준으로 허용 여부를 검증한다.
     * 전이 표는 하드코딩하지 않는다.
     */
    public void validateTransition(String orderKind, String fromStatusCode, String toStatusCode) {
        Map<String, Object> params = new HashMap<>();
        params.put("order_kind", orderKind);
        params.put("from_status_code", fromStatusCode);
        params.put("to_status_code", toStatusCode);

        int count = statusTransitionMapper.countActiveRule(params);
        if (count <= 0) {
            throw new InvalidTransitionException(
                    "허용되지 않은 상태 전이입니다: " + orderKind + " " + fromStatusCode + " → " + toStatusCode);
        }
    }

    public List<Map<String, Object>> getActiveRules(String orderKind) {
        if (!StringUtils.hasText(orderKind)
                || (!"INBOUND".equals(orderKind) && !"OUTBOUND".equals(orderKind))) {
            throw new BadRequestException("order_kind는 INBOUND 또는 OUTBOUND 이어야 합니다");
        }

        Map<String, Object> params = new HashMap<>();
        params.put("order_kind", orderKind);
        return statusTransitionMapper.selectStatusTransitionRuleList(params);
    }

    public void insertHistory(String orderKind, String orderNo, String fromStatusCode,
            String toStatusCode, String changedBy, String changeReason) {
        Map<String, Object> params = new HashMap<>();
        params.put("order_kind", orderKind);
        params.put("order_no", orderNo);
        params.put("from_status_code", fromStatusCode);
        params.put("to_status_code", toStatusCode);
        params.put("changed_by", changedBy);
        params.put("change_reason", changeReason);
        statusTransitionMapper.insertOrderStatusHistory(params);
    }
}
