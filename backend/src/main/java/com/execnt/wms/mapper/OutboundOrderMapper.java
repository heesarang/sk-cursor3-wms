package com.execnt.wms.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OutboundOrderMapper {

    List<Map<String, Object>> selectOutboundOrderList(Map<String, Object> params);

    Map<String, Object> selectOutboundOrderDetail(Map<String, Object> params);

    List<Map<String, Object>> selectOutboundOrderLines(Map<String, Object> params);

    int updateOutboundOrderStatus(Map<String, Object> params);
}
