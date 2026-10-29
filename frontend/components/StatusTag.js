/**
 * 공통 상태 태그 — project-standards §4 색상 매핑
 * props: statusCode, statusName, orderKind ('INBOUND' | 'OUTBOUND')
 */
const StatusTag = {
  name: 'StatusTag',
  props: {
    statusCode: { type: String, default: '' },
    statusName: { type: String, default: '' },
    orderKind: { type: String, default: 'INBOUND' },
  },
  template: `
    <el-tag :type="tagType" size="small" effect="light">
      {{ displayName }}
    </el-tag>
  `,
  computed: {
    tagType() {
      return getStatusTagType(this.statusCode, this.orderKind);
    },
    displayName() {
      return getStatusDisplayName(this.statusCode, this.statusName, this.orderKind);
    },
  },
};
