import { createApp } from 'vue';
import { createPinia } from 'pinia';
import App from './App.vue';
import { router } from './router';
import vuetify, { i18n } from './plugins/vuetify';
import '@/scss/style.scss';
import { PerfectScrollbarPlugin } from 'vue3-perfect-scrollbar';
import VueApexCharts from 'vue3-apexcharts';
import VueTablerIcons from 'vue-tabler-icons';
//Mock Api data
import './_mockApis';
import { fakeBackend } from '@/utils/helpers/fake-backend';

// print
import print from 'vue3-print-nb';

// @ts-expect-error: vue3-easy-data-table doesn't have default export
import DataTable from 'vue3-easy-data-table';

const app = createApp(App);
const pinia = createPinia();
app.use(pinia);
fakeBackend();
app.use(router);
app.component('EasyDataTable', DataTable);
app.use(PerfectScrollbarPlugin);
app.use(VueTablerIcons);
app.use(print);
app.use(VueApexCharts);
app.use(i18n);
app.use(vuetify).mount('#app');
