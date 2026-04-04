import { createRouter, createWebHistory } from 'vue-router';
import { routes } from 'vue-router/auto-routes';
import { useAuthStore } from '@/stores/auth';

// Manually register the landing page as a standalone route outside the (main) FullLayout group.
// unplugin-vue-router's (main).vue group owns path '/' as its parent layout —
// any index.vue at the root level would become a child rendered inside FullLayout.
const landingRoute = {
  path: '/',
  name: 'landing',
  component: () => import('@/pages/index.vue'),
  meta: { requiresAuth: false }
};

// 404 Not Found route - catches all undefined paths
const notFoundRoute = {
  path: '/:pathMatch(.*)*',
  name: 'NotFound',
  component: () => import('@/pages/maintenance/error.vue'),
  meta: { requiresAuth: false }
};

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [landingRoute, ...routes, notFoundRoute]
});

router.beforeEach((to) => {
  const auth = useAuthStore();

  const routeName = String(to.name ?? '');
  const authRequired = routeName.startsWith('/(main)') || to.matched.some((record) => record.meta.requiresAuth === true);

  if (authRequired && !auth.user) {
    auth.returnUrl = to.fullPath;
    return { path: '/login' };
  }

  if (auth.user && to.path === '/login') {
    return { path: auth.returnUrl || '/dashboard/default' };
  }
});
