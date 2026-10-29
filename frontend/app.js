const app = Vue.createApp({
  template: `
    <div class="min-h-screen bg-slate-50">
      <app-nav />
      <main class="max-w-6xl mx-auto px-4 py-6">
        <router-view />
      </main>
    </div>
  `,
});

app.component('AppNav', AppNav);
app.component('StatusTag', StatusTag);
app.component('InboundDetail', InboundDetail);
app.component('OutboundDetail', OutboundDetail);

app.use(ElementPlus);
app.use(router);
app.mount('#app');
