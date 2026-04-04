import { createApp } from 'vue';
import { createPinia } from 'pinia';
import App from './App.vue';
import { router } from './router';
import vuetify, { i18n } from './plugins/vuetify';
import '@/scss/style.scss';
import { PerfectScrollbarPlugin } from 'vue3-perfect-scrollbar';
import VueTablerIcons from 'vue-tabler-icons';
//Mock Api data
import { fakeBackend } from '@/utils/helpers/fake-backend';

const app = createApp(App);
const pinia = createPinia();
app.use(pinia);
fakeBackend();
app.use(router);
app.use(PerfectScrollbarPlugin);
app.use(VueTablerIcons);
app.use(i18n);
app.use(vuetify).mount('#app');
