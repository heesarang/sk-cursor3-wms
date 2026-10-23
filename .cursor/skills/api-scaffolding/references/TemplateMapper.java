package com.execnt.wms.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.Map;
import java.util.List;

@Mapper
public interface {{Domain}}Mapper {
    List<Map<String, Object>> selectList(Map<String, Object> params);
}
