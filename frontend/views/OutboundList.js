/**
 * 출고 주문 목록 — 센터·상태 필터, 행 클릭 → 상세
 */
const OutboundList = {
  name: 'OutboundList',
  components: { OutboundDetail, StatusTag },
  template: `
    <div>
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-semibold text-slate-800">출고 주문 관리</h1>
        <el-button type="success" @click="openCreate">출고 등록</el-button>
      </div>

      <div class="bg-white border border-slate-200 rounded-lg p-4 mb-4 flex flex-wrap items-end gap-3">
        <div>
          <div class="text-xs text-slate-500 mb-1">센터</div>
          <el-select v-model="filter.center_no" clearable placeholder="전체" style="width: 200px">
            <el-option
              v-for="c in centers"
              :key="c.value"
              :label="c.label"
              :value="c.value"
            />
          </el-select>
        </div>
        <div>
          <div class="text-xs text-slate-500 mb-1">상태</div>
          <el-select v-model="filter.status_code" clearable placeholder="전체" style="width: 180px">
            <el-option
              v-for="s in statusOptions"
              :key="s.value"
              :label="s.label"
              :value="s.value"
            />
          </el-select>
        </div>
        <el-button type="primary" @click="fetchList">조회</el-button>
        <el-button @click="resetFilter">초기화</el-button>
      </div>

      <div class="bg-white border border-slate-200 rounded-lg overflow-hidden" v-loading="loading">
        <el-table
          :data="list"
          stripe
          highlight-current-row
          empty-text="조회된 출고 주문이 없습니다"
          style="width: 100%"
          @row-click="openDetail"
        >
          <el-table-column prop="order_no" label="주문번호" min-width="160" />
          <el-table-column label="센터" min-width="160">
            <template #default="{ row }">
              {{ formatCenter(row.center_no, row.center_name) }}
            </template>
          </el-table-column>
          <el-table-column label="상태" width="120">
            <template #default="{ row }">
              <status-tag
                :status-code="row.status_code"
                :status-name="row.status_name"
                order-kind="OUTBOUND"
              />
            </template>
          </el-table-column>
          <el-table-column label="주문일시" width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.ordered_at) }}
            </template>
          </el-table-column>
          <el-table-column prop="partner_contact_name" label="담당자 이름" min-width="120">
            <template #default="{ row }">
              {{ row.partner_contact_name || '-' }}
            </template>
          </el-table-column>
          <el-table-column prop="partner_contact_tel" label="담당자 연락처" min-width="140">
            <template #default="{ row }">
              {{ row.partner_contact_tel || '-' }}
            </template>
          </el-table-column>
        </el-table>
      </div>

      <outbound-detail
        :visible="showDetail"
        :order-no="selectedKey"
        @close="closeDetail"
        @refresh="fetchList"
      />
    </div>
  `,
  data() {
    return {
      list: [],
      loading: false,
      filter: { center_no: '', status_code: '' },
      showDetail: false,
      selectedKey: null,
      centers: CENTERS,
      statusOptions: OUT_STATUS_OPTIONS,
    };
  },
  mounted() {
    this.fetchList();
    window.addEventListener('wms-outbound-created', this.fetchList);
  },
  beforeUnmount() {
    window.removeEventListener('wms-outbound-created', this.fetchList);
  },
  methods: {
    formatCenter,
    formatDateTime,
    openCreate() {
      window.dispatchEvent(new CustomEvent('wms-open-outbound-create'));
    },
    buildParams() {
      const params = {};
      if (this.filter.center_no) params.center_no = this.filter.center_no;
      if (this.filter.status_code) params.status_code = this.filter.status_code;
      return params;
    },
    async fetchList() {
      this.loading = true;
      try {
        const res = await api.outbound.list(this.buildParams());
        if (res.data && res.data.success) {
          this.list = res.data.data || [];
        } else {
          this.list = [];
          ElementPlus.ElMessage.error(res.data?.message || '목록 조회에 실패했습니다');
        }
      } catch (err) {
        this.list = [];
        ElementPlus.ElMessage.error(extractErrorMessage(err, '출고 주문 목록 조회 중 오류가 발생했습니다'));
      } finally {
        this.loading = false;
      }
    },
    resetFilter() {
      this.filter = { center_no: '', status_code: '' };
      this.fetchList();
    },
    openDetail(row) {
      this.selectedKey = row.order_no;
      this.showDetail = true;
    },
    closeDetail() {
      this.showDetail = false;
      this.selectedKey = null;
    },
  },
};
