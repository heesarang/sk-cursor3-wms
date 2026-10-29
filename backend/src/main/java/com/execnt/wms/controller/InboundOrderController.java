package com.execnt.wms.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.execnt.wms.service.InboundOrderService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "Inbound Order", description = "입고 주문 API")
@RestController
@RequestMapping("/api/inbound/orders")
public class InboundOrderController {

    private final InboundOrderService inboundOrderService;

    public InboundOrderController(InboundOrderService inboundOrderService) {
        this.inboundOrderService = inboundOrderService;
    }

    @Operation(summary = "입고 주문 목록 조회")
    @GetMapping
    public Map<String, Object> list(
            @Parameter(description = "센터 번호") @RequestParam(value = "center_no", required = false) String centerNo,
            @Parameter(description = "상태 코드") @RequestParam(value = "status_code", required = false) String statusCode) {
        List<Map<String, Object>> data = inboundOrderService.getOrders(centerNo, statusCode);
        return success(data);
    }

    @Operation(summary = "입고 주문 상세 조회")
    @GetMapping("/{orderNo}")
    public Map<String, Object> detail(
            @Parameter(description = "입고 주문번호") @PathVariable String orderNo) {
        return success(inboundOrderService.getOrderDetail(orderNo));
    }

    @Operation(summary = "입고 상태 전이")
    @PostMapping("/{orderNo}/transition")
    public Map<String, Object> transition(
            @Parameter(description = "입고 주문번호") @PathVariable String orderNo,
            @RequestBody Map<String, Object> body) {
        return success(inboundOrderService.transition(orderNo, body));
    }

    private Map<String, Object> success(Object data) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", true);
        body.put("data", data);
        return body;
    }
}
