package com.execnt.wms.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DashboardMapper {

    List<Map<String, Object>> selectInboundSummary(Map<String, Object> params);

    List<Map<String, Object>> selectOutboundSummary(Map<String, Object> params);

    List<Map<String, Object>> selectRecentHistory(Map<String, Object> params);

    int countOrderExists(Map<String, Object> params);

    List<Map<String, Object>> selectOrderHistoryTrace(Map<String, Object> params);
}
