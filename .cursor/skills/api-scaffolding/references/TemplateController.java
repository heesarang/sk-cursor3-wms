package com.execnt.wms.controller;

import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.List;

/**
 * {{Domain}} Controller
 * /create-api 또는 /api-scaffolding으로 생성된 템플릿
 */
@RestController
@RequestMapping("/api/{{domain}}")
public class {{Domain}}Controller {

    private final {{Domain}}Service {{domain}}Service;

    public {{Domain}}Controller({{Domain}}Service {{domain}}Service) {
        this.{{domain}}Service = {{domain}}Service;
    }

    @GetMapping("/list")
    public Map<String, Object> getList(@RequestParam Map<String, Object> params) {
        // TODO: 구현
        return Map.of("success", true, "data", {{domain}}Service.getList(params));
    }
}
