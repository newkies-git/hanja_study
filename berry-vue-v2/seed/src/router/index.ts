import { createRouter, createWebHistory } from 'vue-router';
import { routes } from 'vue-router/auto-routes';
import { useAuthStore } from '@/stores/auth';

// Manually register the landing page as a standalone route outside auto-routes.
const landingRoute = {
  path: '/',
  name: 'landing',
  component: () => import('@/pages/authentication/login.vue'),
  meta: { requiresAuth: false }
};

// 404 Not Found route
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
    return { path: '/authentication/login' };
  }

  if (auth.user && to.path === '/authentication/login') {
    return { path: auth.returnUrl || '/starter' };
  }
});
