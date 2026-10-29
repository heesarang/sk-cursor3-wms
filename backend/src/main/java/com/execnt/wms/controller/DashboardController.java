package com.execnt.wms.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.execnt.wms.service.DashboardService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "Dashboard", description = "대시보드 요약·이력 API")
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @Operation(summary = "입출고 상태별 건수 요약")
    @GetMapping("/summary")
    public Map<String, Object> summary(
            @Parameter(description = "센터 번호") @RequestParam(value = "center_no", required = false) String centerNo) {
        return success(dashboardService.getSummary(centerNo));
    }

    @Operation(summary = "최근 상태 변경 이력")
    @GetMapping("/history/recent")
    public Map<String, Object> recentHistory(
            @Parameter(description = "조회 건수 (기본 20, 최대 100)")
            @RequestParam(value = "limit", required = false) Integer limit) {
        List<Map<String, Object>> data = dashboardService.getRecentHistory(limit);
        return success(data);
    }

    @Operation(summary = "주문별 상태 이력 추적")
    @GetMapping("/history/trace")
    public Map<String, Object> historyTrace(
            @Parameter(description = "주문 종류 (INBOUND | OUTBOUND)")
            @RequestParam(value = "order_type", required = false) String orderType,
            @Parameter(description = "주문번호")
            @RequestParam(value = "order_no", required = false) String orderNo) {
        return success(dashboardService.getHistoryTrace(orderType, orderNo));
    }

    private Map<String, Object> success(Object data) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", true);
        body.put("data", data);
        return body;
    }
}
