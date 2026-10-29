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

    Long selectActiveCenterIdByNo(Map<String, Object> params);

    Long selectActiveItemIdBySku(Map<String, Object> params);

    Integer selectMaxOrderSeqByCenter(Map<String, Object> params);

    int insertInboundOrder(Map<String, Object> params);

    int insertInboundOrderLine(Map<String, Object> params);
}
