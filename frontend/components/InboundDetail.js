/**
 * 입고 주문 상세 다이얼로그 — 라인 + 상태별 전이 버튼
 */
const InboundDetail = {
  name: 'InboundDetail',
  props: {
    visible: { type: Boolean, default: false },
    orderNo: { type: String, default: null },
  },
  emits: ['close', 'refresh'],
  template: `
    <el-dialog
      :model-value="visible"
      title="입고 주문 상세"
      width="720px"
      destroy-on-close
      @close="$emit('close')"
    >
      <div v-loading="loading">
        <template v-if="detail">
          <div class="grid grid-cols-2 gap-3 mb-4 text-sm">
            <div><span class="text-slate-500">주문번호</span>
              <div class="font-medium">{{ detail.order_no }}</div>
            </div>
            <div><span class="text-slate-500">센터</span>
              <div class="font-medium">{{ centerLabel }}</div>
            </div>
            <div><span class="text-slate-500">상태</span>
              <div class="mt-1">
                <status-tag
                  :status-code="detail.status_code"
                  :status-name="detail.status_name"
                  order-kind="INBOUND"
                />
              </div>
            </div>
            <div><span class="text-slate-500">주문일시</span>
              <div class="font-medium">{{ formatDateTime(detail.ordered_at) }}</div>
            </div>
          </div>

          <el-table :data="detail.lines || []" border stripe size="small" empty-text="라인 없음">
            <el-table-column prop="line_no" label="라인" width="70" align="center" />
            <el-table-column prop="sku_no" label="SKU" width="110" />
            <el-table-column prop="item_name" label="품목명" min-width="120" />
            <el-table-column prop="order_qty" label="주문수량" width="100" align="right" />
            <el-table-column prop="inspected_qty" label="검수확정수량" width="110" align="right" />
          </el-table>

          <div class="mt-4 flex items-center gap-2">
            <span class="text-slate-500 text-sm">변경자</span>
            <el-input v-model="changedBy" size="small" style="width: 160px" />
          </div>
        </template>
        <div v-else-if="!loading" class="text-slate-500 text-sm py-6 text-center">상세 정보가 없습니다.</div>
      </div>

      <template #footer>
        <div class="flex justify-between items-center w-full">
          <div>
            <template v-if="allowedAction">
              <el-button
                :type="allowedAction.buttonType"
                :loading="transitioning"
                @click="confirmTransition"
              >
                {{ allowedAction.label }}
              </el-button>
            </template>
            <span v-else-if="detail && detail.status_code === '90'" class="text-slate-400 text-sm">
              입고확정 완료 — 추가 전이가 없습니다.
            </span>
          </div>
          <el-button @click="$emit('close')">닫기</el-button>
        </div>
      </template>
    </el-dialog>
  `,
  data() {
    return {
      detail: null,
      loading: false,
      transitioning: false,
      changedBy: DEFAULT_CHANGED_BY,
    };
  },
  computed: {
    centerLabel() {
      if (!this.detail) return '-';
      return formatCenter(this.detail.center_no, this.detail.center_name);
    },
    allowedAction() {
      if (!this.detail) return null;
      return INB_TRANSITIONS[this.detail.status_code] || null;
    },
  },
  watch: {
    visible(val) {
      if (val && this.orderNo) {
        this.changedBy = DEFAULT_CHANGED_BY;
        this.fetchDetail();
      } else if (!val) {
        this.detail = null;
      }
    },
  },
  methods: {
    formatDateTime,
    async fetchDetail() {
      this.loading = true;
      this.detail = null;
      try {
        const res = await api.inbound.detail(this.orderNo);
        if (res.data && res.data.success) {
          this.detail = res.data.data;
        } else {
          ElementPlus.ElMessage.error(res.data?.message || '상세 조회에 실패했습니다');
          this.$emit('close');
        }
      } catch (err) {
        ElementPlus.ElMessage.error(extractErrorMessage(err, '입고 주문 상세 조회 중 오류가 발생했습니다'));
        this.$emit('close');
      } finally {
        this.loading = false;
      }
    },
    async confirmTransition() {
      if (!this.allowedAction || !this.detail) return;
      const action = this.allowedAction;
      const from = this.detail.status_code;
      try {
        await ElementPlus.ElMessageBox.confirm(
          `「${action.label}」을 진행하시겠습니까? (${from} → ${action.to_status})`,
          '상태 변경 확인',
          { confirmButtonText: '확인', cancelButtonText: '취소', type: 'warning' }
        );
      } catch {
        return;
      }
      this.transitioning = true;
      try {
        const body = {
          to_status: action.to_status,
          changed_by: (this.changedBy || DEFAULT_CHANGED_BY).trim(),
          change_reason: action.label,
        };
        const res = await api.inbound.transition(this.detail.order_no, body);
        if (res.data && res.data.success) {
          const name = res.data.data?.status_name || action.label;
          ElementPlus.ElMessage.success(`상태가 '${name}'(으)로 변경되었습니다`);
          await this.fetchDetail();
          this.$emit('refresh');
        } else {
          ElementPlus.ElMessage.error(res.data?.message || '상태 변경에 실패했습니다');
        }
      } catch (err) {
        ElementPlus.ElMessage.error(extractErrorMessage(err, '상태 변경 중 오류가 발생했습니다'));
      } finally {
        this.transitioning = false;
      }
    },
  },
};
