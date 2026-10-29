package com.execnt.wms.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.execnt.wms.service.StatusTransitionService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "Status Transition", description = "상태 전이 규칙 API")
@RestController
@RequestMapping("/api/status-transitions")
public class StatusTransitionController {

    private final StatusTransitionService statusTransitionService;

    public StatusTransitionController(StatusTransitionService statusTransitionService) {
        this.statusTransitionService = statusTransitionService;
    }

    @Operation(summary = "활성 상태 전이 규칙 조회")
    @GetMapping("/rules")
    public Map<String, Object> getRules(
            @Parameter(description = "주문 종류 (INBOUND | OUTBOUND)", required = true)
            @RequestParam(value = "order_kind", required = false) String orderKind) {
        List<Map<String, Object>> rules = statusTransitionService.getActiveRules(orderKind);
        return success(rules);
    }

    private Map<String, Object> success(Object data) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", true);
        body.put("data", data);
        return body;
    }
}
