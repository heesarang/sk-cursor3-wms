/**
 * 상태 현황 대시보드 — 요약 / 최근 이력 / 주문 추적
 */
const DashboardView = {
  name: 'DashboardView',
  components: { StatusTag },
  template: `
    <div>
      <h1 class="text-xl font-semibold text-slate-800 mb-4">상태 현황 대시보드</h1>

      <!-- A. 요약 -->
      <section class="bg-white border border-slate-200 rounded-lg p-4 mb-4">
        <div class="flex flex-wrap items-end gap-3 mb-4">
          <div>
            <div class="text-xs text-slate-500 mb-1">센터</div>
            <el-select v-model="summaryCenter" clearable placeholder="전체" style="width: 200px" @change="fetchSummary">
              <el-option
                v-for="c in centers"
                :key="c.value"
                :label="c.label"
                :value="c.value"
              />
            </el-select>
          </div>
          <el-button type="primary" :loading="summaryLoading" @click="refreshAll">새로고침</el-button>
        </div>

        <div v-loading="summaryLoading" class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="border border-slate-100 rounded-lg p-4">
            <h2 class="text-sm font-semibold text-slate-700 mb-3">입고 요약</h2>
            <div class="space-y-2">
              <div
                v-for="row in inboundSummary"
                :key="'in-' + row.status_code"
                class="flex items-center justify-between text-sm"
              >
                <status-tag
                  :status-code="row.status_code"
                  :status-name="row.status_name"
                  order-kind="INBOUND"
                />
                <span class="font-semibold text-slate-800 tabular-nums">{{ row.order_count }}건</span>
              </div>
            </div>
          </div>
          <div class="border border-slate-100 rounded-lg p-4">
            <h2 class="text-sm font-semibold text-slate-700 mb-3">출고 요약</h2>
            <div class="space-y-2">
              <div
                v-for="row in outboundSummary"
                :key="'out-' + row.status_code"
                class="flex items-center justify-between text-sm"
              >
                <status-tag
                  :status-code="row.status_code"
                  :status-name="row.status_name"
                  order-kind="OUTBOUND"
                />
                <span class="font-semibold text-slate-800 tabular-nums">{{ row.order_count }}건</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- B. 최근 이력 -->
      <section class="bg-white border border-slate-200 rounded-lg p-4 mb-4">
        <h2 class="text-sm font-semibold text-slate-700 mb-3">최근 상태 변경 이력</h2>
        <div class="flex flex-wrap items-end gap-3 mb-3">
          <div>
            <div class="text-xs text-slate-500 mb-1">limit</div>
            <el-input-number v-model="historyLimit" :min="1" :max="100" size="default" />
          </div>
          <el-button type="primary" :loading="historyLoading" @click="fetchRecentHistory">조회</el-button>
        </div>
        <el-table
          v-loading="historyLoading"
          :data="recentHistory"
          stripe
          size="small"
          empty-text="최근 이력이 없습니다"
        >
          <el-table-column label="유형" width="110">
            <template #default="{ row }">
              <el-tag :type="row.order_type === 'OUTBOUND' ? 'warning' : 'info'" size="small">
                {{ row.order_type }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="주문번호" min-width="140">
            <template #default="{ row }">
              <el-button link type="primary" @click="fillTraceFromHistory(row)">
                {{ row.order_no }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column label="이전 → 이후" min-width="200">
            <template #default="{ row }">
              <status-tag
                :status-code="row.from_status_code"
                :order-kind="row.order_type"
              />
              <span class="mx-1 text-slate-400">→</span>
              <status-tag
                :status-code="row.to_status_code"
                :order-kind="row.order_type"
              />
            </template>
          </el-table-column>
          <el-table-column prop="changed_by" label="변경자" width="110" />
          <el-table-column prop="change_reason" label="사유" min-width="120" show-overflow-tooltip />
          <el-table-column label="변경일시" width="150">
            <template #default="{ row }">
              {{ formatDateTime(row.changed_at) }}
            </template>
          </el-table-column>
        </el-table>
      </section>

      <!-- C. 주문 추적 -->
      <section class="bg-white border border-slate-200 rounded-lg p-4">
        <h2 class="text-sm font-semibold text-slate-700 mb-3">주문 이력 추적</h2>
        <div class="flex flex-wrap items-end gap-3 mb-4">
          <div>
            <div class="text-xs text-slate-500 mb-1">유형</div>
            <el-select v-model="trace.order_type" style="width: 160px">
              <el-option label="INBOUND" value="INBOUND" />
              <el-option label="OUTBOUND" value="OUTBOUND" />
            </el-select>
          </div>
          <div>
            <div class="text-xs text-slate-500 mb-1">주문번호</div>
            <el-input
              v-model="trace.order_no"
              placeholder="예: IB-CTR01-020"
              style="width: 220px"
              clearable
              @keyup.enter="fetchTrace"
            />
          </div>
          <el-button type="primary" :loading="traceLoading" @click="fetchTrace">추적</el-button>
        </div>

        <div v-if="traceResult">
          <p class="text-sm text-slate-600 mb-3">
            {{ traceResult.order_type }} / {{ traceResult.order_no }}
            <span class="text-slate-400">({{ (traceResult.histories || []).length }}건)</span>
          </p>
          <el-timeline v-if="(traceResult.histories || []).length">
            <el-timeline-item
              v-for="(h, idx) in traceResult.histories"
              :key="idx"
              :timestamp="formatDateTime(h.changed_at)"
              placement="top"
            >
              <div class="flex flex-wrap items-center gap-2 text-sm">
                <status-tag :status-code="h.from_status_code" :order-kind="traceResult.order_type" />
                <span class="text-slate-400">→</span>
                <status-tag :status-code="h.to_status_code" :order-kind="traceResult.order_type" />
                <span class="text-slate-500">· {{ h.changed_by }}</span>
                <span v-if="h.change_reason" class="text-slate-600">· {{ h.change_reason }}</span>
              </div>
            </el-timeline-item>
          </el-timeline>
          <p v-else class="text-sm text-slate-400">이력이 없습니다.</p>
        </div>
        <p v-else-if="!traceLoading" class="text-sm text-slate-400">주문 유형과 주문번호를 입력 후 [추적]을 누르세요.</p>
      </section>
    </div>
  `,
  data() {
    return {
      centers: CENTERS,
      summaryCenter: '',
      summaryLoading: false,
      inboundSummary: buildInboundSlots(),
      outboundSummary: buildOutboundSlots(),
      historyLimit: 20,
      historyLoading: false,
      recentHistory: [],
      trace: { order_type: 'INBOUND', order_no: '' },
      traceLoading: false,
      traceResult: null,
    };
  },
  mounted() {
    this.fetchSummary();
    this.fetchRecentHistory();
  },
  methods: {
    formatDateTime,
    emptyInboundSlots: buildInboundSlots,
    emptyOutboundSlots: buildOutboundSlots,
    mergeStatusSlots(apiRows, emptySlots) {
      const map = {};
      (apiRows || []).forEach((r) => {
        map[r.status_code] = r;
      });
      return emptySlots.map((slot) => {
        const hit = map[slot.status_code];
        return hit
          ? {
              status_code: hit.status_code,
              status_name: hit.status_name || slot.status_name,
              order_count: hit.order_count ?? 0,
            }
          : { ...slot };
      });
    },
    async refreshAll() {
      await Promise.all([this.fetchSummary(), this.fetchRecentHistory()]);
    },
    async fetchSummary() {
      this.summaryLoading = true;
      try {
        const params = {};
        if (this.summaryCenter) params.center_no = this.summaryCenter;
        const res = await api.dashboard.summary(params);
        if (res.data && res.data.success) {
          const data = res.data.data || {};
          this.inboundSummary = this.mergeStatusSlots(data.inbound, this.emptyInboundSlots());
          this.outboundSummary = this.mergeStatusSlots(data.outbound, this.emptyOutboundSlots());
        } else {
          this.inboundSummary = this.emptyInboundSlots();
          this.outboundSummary = this.emptyOutboundSlots();
          ElementPlus.ElMessage.error(res.data?.message || '요약 조회에 실패했습니다');
        }
      } catch (err) {
        this.inboundSummary = this.emptyInboundSlots();
        this.outboundSummary = this.emptyOutboundSlots();
        ElementPlus.ElMessage.error(extractErrorMessage(err, '대시보드 요약 조회 중 오류가 발생했습니다'));
      } finally {
        this.summaryLoading = false;
      }
    },
    async fetchRecentHistory() {
      this.historyLoading = true;
      try {
        const res = await api.dashboard.historyRecent({ limit: this.historyLimit });
        if (res.data && res.data.success) {
          this.recentHistory = res.data.data || [];
        } else {
          ElementPlus.ElMessage.error(res.data?.message || '최근 이력 조회에 실패했습니다');
        }
      } catch (err) {
        ElementPlus.ElMessage.error(extractErrorMessage(err, '최근 이력 조회 중 오류가 발생했습니다'));
      } finally {
        this.historyLoading = false;
      }
    },
    fillTraceFromHistory(row) {
      this.trace.order_type = row.order_type;
      this.trace.order_no = row.order_no;
      this.fetchTrace();
    },
    async fetchTrace() {
      const orderType = (this.trace.order_type || '').trim();
      const orderNo = (this.trace.order_no || '').trim();
      if (!orderType || !orderNo) {
        ElementPlus.ElMessage.warning('주문 유형과 주문번호를 입력하세요');
        return;
      }
      this.traceLoading = true;
      this.traceResult = null;
      try {
        const res = await api.dashboard.historyTrace({
          order_type: orderType,
          order_no: orderNo,
        });
        if (res.data && res.data.success) {
          this.traceResult = res.data.data;
        } else {
          ElementPlus.ElMessage.error(res.data?.message || '추적에 실패했습니다');
        }
      } catch (err) {
        this.traceResult = null;
        ElementPlus.ElMessage.error(extractErrorMessage(err, '주문 추적 중 오류가 발생했습니다'));
      } finally {
        this.traceLoading = false;
      }
    },
  },
};
