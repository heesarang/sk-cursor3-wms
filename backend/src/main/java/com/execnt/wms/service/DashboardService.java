package com.execnt.wms.service;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.execnt.wms.exception.BadRequestException;
import com.execnt.wms.exception.ResourceNotFoundException;
import com.execnt.wms.mapper.DashboardMapper;

@Service
public class DashboardService {

    private static final int DEFAULT_RECENT_LIMIT = 20;
    private static final int MAX_RECENT_LIMIT = 100;

    private final DashboardMapper dashboardMapper;

    public DashboardService(DashboardMapper dashboardMapper) {
        this.dashboardMapper = dashboardMapper;
    }

    public Map<String, Object> getSummary(String centerNo) {
        Map<String, Object> params = new HashMap<>();
        params.put("center_no", centerNo);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("inbound", dashboardMapper.selectInboundSummary(params));
        data.put("outbound", dashboardMapper.selectOutboundSummary(params));
        return data;
    }

    public List<Map<String, Object>> getRecentHistory(Integer limit) {
        int resolved = limit == null ? DEFAULT_RECENT_LIMIT : limit;
        if (resolved < 1) {
            throw new BadRequestException("limit은 1 이상이어야 합니다");
        }
        if (resolved > MAX_RECENT_LIMIT) {
            resolved = MAX_RECENT_LIMIT;
        }

        Map<String, Object> params = new HashMap<>();
        params.put("limit", resolved);
        return dashboardMapper.selectRecentHistory(params);
    }

    public Map<String, Object> getHistoryTrace(String orderType, String orderNo) {
        if (!StringUtils.hasText(orderType) || !StringUtils.hasText(orderNo)) {
            throw new BadRequestException("order_type과 order_no는 필수입니다");
        }
        if (!"INBOUND".equals(orderType) && !"OUTBOUND".equals(orderType)) {
            throw new BadRequestException("order_type은 INBOUND 또는 OUTBOUND 이어야 합니다");
        }

        Map<String, Object> params = new HashMap<>();
        params.put("order_type", orderType);
        params.put("order_no", orderNo);

        int exists = dashboardMapper.countOrderExists(params);
        if (exists <= 0) {
            throw new ResourceNotFoundException("주문을 찾을 수 없습니다: " + orderType + " / " + orderNo);
        }

        List<Map<String, Object>> histories = dashboardMapper.selectOrderHistoryTrace(params);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("order_type", orderType);
        data.put("order_no", orderNo);
        data.put("histories", histories);
        return data;
    }
}
