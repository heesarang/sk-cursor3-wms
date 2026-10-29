/**
 * 상단 네비게이션 — 대시보드 / 입고 / 출고
 */
const AppNav = {
  name: 'AppNav',
  template: `
    <header class="bg-slate-800 text-white shadow">
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center gap-6">
        <span class="font-semibold tracking-wide text-lg">WMS</span>
        <nav class="flex gap-1">
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
      </div>
    </header>
  `,
  data() {
    return {
      items: [
        { path: '/dashboard', label: '대시보드' },
        { path: '/inbound', label: '입고' },
        { path: '/outbound', label: '출고' },
      ],
    };
  },
  methods: {
    isActive(path) {
      return this.$route.path === path;
    },
  },
};
