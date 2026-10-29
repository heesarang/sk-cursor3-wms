/**
 * 상단 네비게이션 — 대시보드 / 입고 / 출고 + 전역 입고·출고 등록
 */
const AppNav = {
  name: 'AppNav',
  components: { InboundCreate, OutboundCreate },
  template: `
    <header class="bg-slate-800 text-white shadow">
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center gap-6">
        <span class="font-semibold tracking-wide text-lg">WMS</span>
        <nav class="flex gap-1 flex-1">
          <router-link
            v-for="item in items"
            :key="item.path"
            :to="item.path"
            class="px-3 py-1.5 rounded text-sm transition-colors"
            :class="isActive(item.path)
              ? 'bg-slate-600 text-white'
              : 'text-slate-300 hover:bg-slate-700 hover:text-white'"
          >
            {{ item.label }}
          </router-link>
        </nav>
        <div class="flex items-center gap-2">
          <el-button type="primary" size="small" @click="openInboundCreate">입고 등록</el-button>
          <el-button type="success" size="small" @click="openOutboundCreate">출고 등록</el-button>
        </div>
      </div>
      <inbound-create
        :visible="showInboundCreate"
        @close="showInboundCreate = false"
      />
      <outbound-create
        :visible="showOutboundCreate"
        @close="showOutboundCreate = false"
      />
    </header>
  `,
  data() {
    return {
      showInboundCreate: false,
      showOutboundCreate: false,
      items: [
        { path: '/dashboard', label: '대시보드' },
        { path: '/inbound', label: '입고' },
        { path: '/outbound', label: '출고' },
      ],
    };
  },
  mounted() {
    window.addEventListener('wms-open-inbound-create', this.openInboundCreate);
    window.addEventListener('wms-open-outbound-create', this.openOutboundCreate);
  },
  beforeUnmount() {
    window.removeEventListener('wms-open-inbound-create', this.openInboundCreate);
    window.removeEventListener('wms-open-outbound-create', this.openOutboundCreate);
  },
  methods: {
    isActive(path) {
      return this.$route.path === path;
    },
    openInboundCreate() {
      this.showInboundCreate = true;
    },
    openOutboundCreate() {
      this.showOutboundCreate = true;
    },
  },
};
