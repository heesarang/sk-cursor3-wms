package com.execnt.wms.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface StatusTransitionMapper {

    int countActiveRule(Map<String, Object> params);

    List<Map<String, Object>> selectStatusTransitionRuleList(Map<String, Object> params);

    int insertOrderStatusHistory(Map<String, Object> params);
}
