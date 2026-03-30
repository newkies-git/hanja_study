import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import BasisManageView from '../views/dashboard/BasisManageView.vue';
import BasisCsvUploadView from '../views/dashboard/BasisCsvUploadView.vue';
import SettingsAuthView from '../views/dashboard/SettingsAuthView.vue';
import ComingSoonView from '../views/dashboard/ComingSoonView.vue';
import { auth } from '../firebase';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/dashboard'
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView
    },
    {
      path: '/dashboard',
      redirect: '/dashboard/basis/manage',
      meta: { requiresAuth: true },
    },
    { path: '/dashboard/basis/manage', component: BasisManageView, meta: { requiresAuth: true } },
    { path: '/dashboard/basis/csv-upload', component: BasisCsvUploadView, meta: { requiresAuth: true } },
    { path: '/dashboard/settings/authentication', component: SettingsAuthView, meta: { requiresAuth: true } },
    { path: '/dashboard/etl-monitor', component: ComingSoonView, props: { title: 'ETL 상태 모니터링' }, meta: { requiresAuth: true } },
    { path: '/dashboard/sync', component: ComingSoonView, props: { title: '동기화 관리' }, meta: { requiresAuth: true } }
  ]
});

// Guard Setup
router.beforeEach((to) => {
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth);
  const currentUser = auth?.currentUser ?? null;
  if (requiresAuth && !currentUser) {
    return '/login';
  }
  if (to.path === '/login' && currentUser) {
    return '/dashboard';
  }
  return true;
});

export default router;
