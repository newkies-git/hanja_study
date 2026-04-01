import { createRouter, createWebHistory } from "vue-router";
import { watch } from "vue";
import { useAuthStore } from "@/stores/auth";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/login",
      name: "login",
      component: () => import("@/views/LoginView.vue"),
      meta: { public: true },
    },
    {
      path: "/",
      component: () => import("@/layouts/DashboardLayout.vue"),
      meta: { requiresAuth: true },
      children: [
        {
          path: "",
          name: "dashboard",
          component: () => import("@/views/dashboard/DashboardHomeView.vue"),
        },
        {
          path: "basis",
          name: "basis",
          component: () => import("@/views/dashboard/BasisManageView.vue"),
        },
        {
          path: "basis/upload",
          name: "basis-upload",
          component: () => import("@/views/dashboard/BasisCsvUploadView.vue"),
        },
        {
          path: "etl",
          name: "etl",
          component: () => import("@/views/dashboard/EtlExtendView.vue"),
        },
        {
          path: "settings/auth",
          name: "settings-auth",
          component: () => import("@/views/dashboard/SettingsAuthView.vue"),
        },
      ],
    },
    {
      path: "/:pathMatch(.*)*",
      name: "not-found",
      component: () => import("@/views/NotFoundView.vue"),
    },
  ],
});

async function waitAuthReady() {
  const auth = useAuthStore();
  if (auth.ready) return;
  await new Promise<void>((resolve) => {
    const stop = watch(
      () => auth.ready,
      (val) => {
        if (val) {
          stop();
          resolve();
        }
      },
    );
  });
}

router.beforeEach(async (to) => {
  await waitAuthReady();
  const auth = useAuthStore();
  const isPublic = to.meta.public === true;

  if (!isPublic && !auth.isAuthenticated) {
    return { name: "login", query: { redirect: to.fullPath } };
  }
  if (to.name === "login" && auth.isAuthenticated) {
    return { path: "/" };
  }
  return true;
});

export default router;
