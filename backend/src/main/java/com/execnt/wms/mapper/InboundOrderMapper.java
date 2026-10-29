package com.execnt.wms.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface InboundOrderMapper {

    List<Map<String, Object>> selectInboundOrderList(Map<String, Object> params);

    Map<String, Object> selectInboundOrderDetail(Map<String, Object> params);

    List<Map<String, Object>> selectInboundOrderLines(Map<String, Object> params);

    int updateInboundOrderStatus(Map<String, Object> params);
}
