package com.execnt.wms.service;

import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.List;

@Service
public class {{Domain}}Service {

    private final {{Domain}}Mapper {{domain}}Mapper;

    public {{Domain}}Service({{Domain}}Mapper {{domain}}Mapper) {
        this.{{domain}}Mapper = {{domain}}Mapper;
    }

    public List<Map<String, Object>> getList(Map<String, Object> params) {
        return {{domain}}Mapper.selectList(params);
    }
}
