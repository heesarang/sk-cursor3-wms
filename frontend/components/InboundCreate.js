/**
 * 입고 주문 등록 다이얼로그 — InboundDetail과 동일 정보 구조 (입력 모드)
 */
const InboundCreate = {
  name: 'InboundCreate',
  props: {
    visible: { type: Boolean, default: false },
  },
  emits: ['close', 'created'],
  template: `
    <el-dialog
      :model-value="visible"
      title="입고 주문 등록"
      width="720px"
      destroy-on-close
      @close="$emit('close')"
    >
      <div class="grid grid-cols-2 gap-3 mb-4 text-sm">
        <div>
          <span class="text-slate-500">주문번호</span>
          <div class="font-medium text-slate-400">저장 시 자동 채번</div>
        </div>
        <div>
          <span class="text-slate-500">센터</span>
          <el-select v-model="form.center_no" placeholder="센터 선택" class="mt-1" style="width: 100%">
            <el-option
              v-for="c in centers"
              :key="c.value"
              :label="c.label"
              :value="c.value"
            />
          </el-select>
        </div>
        <div>
          <span class="text-slate-500">상태</span>
          <div class="mt-1">
            <status-tag status-code="00" status-name="주문생성" order-kind="INBOUND" />
          </div>
        </div>
        <div>
          <span class="text-slate-500">주문일시</span>
          <div class="font-medium text-slate-400 mt-1">등록 시각 (서버)</div>
        </div>
        <div>
          <span class="text-slate-500">담당자 이름</span>
          <el-input v-model="form.partner_contact_name" class="mt-1" maxlength="100" clearable />
        </div>
        <div>
          <span class="text-slate-500">담당자 연락처</span>
          <el-input v-model="form.partner_contact_tel" class="mt-1" maxlength="20" clearable />
        </div>
      </div>

      <div class="flex justify-between items-center mb-2">
        <span class="text-sm text-slate-600">라인</span>
        <el-button size="small" @click="addLine">라인 추가</el-button>
      </div>
      <el-table :data="form.lines" border stripe size="small" empty-text="라인을 추가하세요">
        <el-table-column label="라인" width="70" align="center">
          <template #default="{ $index }">{{ $index + 1 }}</template>
        </el-table-column>
        <el-table-column label="SKU" min-width="140">
          <template #default="{ row }">
            <el-select v-model="row.sku_no" placeholder="SKU" style="width: 100%">
              <el-option
                v-for="s in skus"
                :key="s.value"
                :label="s.label"
                :value="s.value"
              />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="주문수량" width="120" align="right">
          <template #default="{ row }">
            <el-input-number v-model="row.order_qty" :min="1" :step="1" controls-position="right" style="width: 110px" />
          </template>
        </el-table-column>
        <el-table-column label="검수확정수량" width="110" align="right">
          <template #default>0</template>
        </el-table-column>
        <el-table-column label="" width="70" align="center">
          <template #default="{ $index }">
            <el-button link type="danger" size="small" @click="removeLine($index)">삭제</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="mt-4 flex items-center gap-2">
        <span class="text-slate-500 text-sm">등록자</span>
        <el-input v-model="form.created_by" size="small" style="width: 160px" />
      </div>

      <template #footer>
        <div class="flex justify-end gap-2 w-full">
          <el-button @click="$emit('close')">취소</el-button>
          <el-button type="primary" :loading="saving" @click="submit">저장(등록)</el-button>
        </div>
      </template>
    </el-dialog>
  `,
  data() {
    return {
      saving: false,
      centers: CENTERS,
      skus: [
        { value: 'SKU-AAA', label: 'SKU-AAA (상품 AAA)' },
        { value: 'SKU-BBB', label: 'SKU-BBB (상품 BBB)' },
        { value: 'SKU-CCC', label: 'SKU-CCC (상품 CCC)' },
      ],
      form: this.emptyForm(),
    };
  },
  watch: {
    visible(val) {
      if (val) {
        this.form = this.emptyForm();
      }
    },
  },
  methods: {
    emptyForm() {
      return {
        center_no: 'CTR01',
        partner_contact_name: '',
        partner_contact_tel: '',
        created_by: DEFAULT_CHANGED_BY,
        lines: [{ sku_no: 'SKU-AAA', order_qty: 1 }],
      };
    },
    addLine() {
      this.form.lines.push({ sku_no: 'SKU-AAA', order_qty: 1 });
    },
    removeLine(index) {
      this.form.lines.splice(index, 1);
    },
    async submit() {
      if (!this.form.center_no) {
        ElementPlus.ElMessage.error('센터를 선택하세요');
        return;
      }
      if (!this.form.lines.length) {
        ElementPlus.ElMessage.error('라인을 1건 이상 추가하세요');
        return;
      }
      for (const line of this.form.lines) {
        if (!line.sku_no || !line.order_qty || line.order_qty < 1) {
          ElementPlus.ElMessage.error('SKU와 주문수량(1 이상)을 확인하세요');
          return;
        }
      }
      this.saving = true;
      try {
        const body = {
          center_no: this.form.center_no,
          partner_contact_name: this.form.partner_contact_name || null,
          partner_contact_tel: this.form.partner_contact_tel || null,
          created_by: (this.form.created_by || DEFAULT_CHANGED_BY).trim(),
          lines: this.form.lines.map((l) => ({
            sku_no: l.sku_no,
            order_qty: l.order_qty,
          })),
        };
        const res = await api.inbound.create(body);
        if (res.data && res.data.success) {
          const orderNo = res.data.data?.order_no || '';
          ElementPlus.ElMessage.success(`입고 주문이 등록되었습니다${orderNo ? ': ' + orderNo : ''}`);
          this.$emit('created', res.data.data);
          this.$emit('close');
          window.dispatchEvent(new CustomEvent('wms-inbound-created', { detail: res.data.data }));
        } else {
          ElementPlus.ElMessage.error(res.data?.message || '입고 등록에 실패했습니다');
        }
      } catch (err) {
        ElementPlus.ElMessage.error(extractErrorMessage(err, '입고 등록 중 오류가 발생했습니다'));
      } finally {
        this.saving = false;
      }
    },
  },
};
