const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/dashboard', component: DashboardView },
  { path: '/inbound', component: InboundList },
  { path: '/outbound', component: OutboundList },
];

const router = VueRouter.createRouter({
  history: VueRouter.createWebHashHistory(),
  routes,
});
