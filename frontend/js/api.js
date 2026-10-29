/**
 * API 호출 중앙 집중 — API_BASE 한 곳 관리
 * 경로·쿼리·Body는 REQ §5 / project-standards 기준 (snake_case)
 */
const API_BASE = 'http://localhost:8080';

const api = {
  inbound: {
    list: (params) => axios.get(`${API_BASE}/api/inbound/orders`, { params }),
    detail: (orderNo) => axios.get(`${API_BASE}/api/inbound/orders/${encodeURIComponent(orderNo)}`),
    create: (body) => axios.post(`${API_BASE}/api/inbound/orders`, body),
    transition: (orderNo, body) =>
      axios.post(`${API_BASE}/api/inbound/orders/${encodeURIComponent(orderNo)}/transition`, body),
  },
  outbound: {
    list: (params) => axios.get(`${API_BASE}/api/outbound/orders`, { params }),
    detail: (orderNo) => axios.get(`${API_BASE}/api/outbound/orders/${encodeURIComponent(orderNo)}`),
    create: (body) => axios.post(`${API_BASE}/api/outbound/orders`, body),
    transition: (orderNo, body) =>
      axios.post(`${API_BASE}/api/outbound/orders/${encodeURIComponent(orderNo)}/transition`, body),
  },
  dashboard: {
    summary: (params) => axios.get(`${API_BASE}/api/dashboard/summary`, { params }),
    historyRecent: (params) => axios.get(`${API_BASE}/api/dashboard/history/recent`, { params }),
    historyTrace: (params) => axios.get(`${API_BASE}/api/dashboard/history/trace`, { params }),
  },
  statusTransitions: {
    rules: (params) => axios.get(`${API_BASE}/api/status-transitions/rules`, { params }),
  },
};
