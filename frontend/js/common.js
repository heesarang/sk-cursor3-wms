/**
 * 공통 유틸리티 — 상태 태그, 날짜 포맷, API 에러 메시지
 */

const CENTERS = [
  { value: 'CTR01', label: 'CTR01 (서울센터)' },
  { value: 'CTR02', label: 'CTR02 (부산센터)' },
];

const INB_STATUS_OPTIONS = [
  { value: '00', label: '00 주문생성' },
  { value: '10', label: '10 검수중' },
  { value: '20', label: '20 검수완료' },
  { value: '90', label: '90 입고확정' },
];

const OUT_STATUS_OPTIONS = [
  { value: '00', label: '00 주문생성' },
  { value: '10', label: '10 피킹중' },
  { value: '20', label: '20 피킹완료' },
  { value: '90', label: '90 출고확정' },
];

const INB_STATUS_META = {
  '00': { name: '주문생성', type: 'info' },
  '10': { name: '검수중', type: 'warning' },
  '20': { name: '검수완료', type: 'primary' },
  '90': { name: '입고확정', type: 'success' },
};

const OUT_STATUS_META = {
  '00': { name: '주문생성', type: 'info' },
  '10': { name: '피킹중', type: 'warning' },
  '20': { name: '피킹완료', type: 'primary' },
  '90': { name: '출고확정', type: 'success' },
};

/** 입고 전이: 현재 상태 → { to_status, label, buttonType } */
const INB_TRANSITIONS = {
  '00': { to_status: '10', label: '검수시작', buttonType: 'primary' },
  '10': { to_status: '20', label: '검수완료', buttonType: 'primary' },
  '20': { to_status: '90', label: '입고확정', buttonType: 'success' },
};

/** 출고 전이 */
const OUT_TRANSITIONS = {
  '00': { to_status: '10', label: '피킹시작', buttonType: 'primary' },
  '10': { to_status: '20', label: '피킹완료', buttonType: 'primary' },
  '20': { to_status: '90', label: '출고확정', buttonType: 'success' },
};

const DEFAULT_CHANGED_BY = 'demo-user';

function buildInboundSlots() {
  return ['00', '10', '20', '90'].map((code) => ({
    status_code: code,
    status_name: INB_STATUS_META[code].name,
    order_count: 0,
  }));
}

function buildOutboundSlots() {
  return ['00', '10', '20', '90'].map((code) => ({
    status_code: code,
    status_name: OUT_STATUS_META[code].name,
    order_count: 0,
  }));
}

function getStatusMeta(statusCode, orderKind) {
  const map = orderKind === 'OUTBOUND' ? OUT_STATUS_META : INB_STATUS_META;
  return map[statusCode] || { name: statusCode || '-', type: 'info' };
}

function getStatusTagType(statusCode, orderKind) {
  return getStatusMeta(statusCode, orderKind).type;
}

function getStatusDisplayName(statusCode, statusName, orderKind) {
  if (statusName) return statusName;
  return getStatusMeta(statusCode, orderKind).name;
}

function formatDateTime(value) {
  if (!value) return '-';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return String(value);
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  const hh = String(d.getHours()).padStart(2, '0');
  const mi = String(d.getMinutes()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd} ${hh}:${mi}`;
}

function formatCenter(centerNo, centerName) {
  if (!centerNo) return '-';
  return centerName ? `${centerNo} (${centerName})` : centerNo;
}

function extractErrorMessage(error, fallback) {
  const msg =
    error?.response?.data?.message ||
    error?.message ||
    fallback ||
    '요청 처리 중 오류가 발생했습니다';
  return msg;
}
