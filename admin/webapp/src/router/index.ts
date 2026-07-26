import {
  createRouter,
  createWebHistory,
  type RouteLocationNormalized,
  type RouteRecordNormalized,
} from "vue-router";
import { watch } from "vue";
import { useAuthStore } from "@/stores/auth";
import { isLocalApiEnabled } from "@/config/localApi";

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
          path: "firestore/manage",
          meta: { requiresAdmin: true, splitManage: true },
          component: () => import("@/views/dashboard/FirestoreManageLayout.vue"),
          children: [
            {
              path: "",
              name: "firestore-manage",
              component: () => import("@/views/dashboard/FirestoreManagePlaceholder.vue"),
            },
            {
              path: ":id",
              name: "firestore-manage-detail",
              component: () => import("@/views/dashboard/FirestoreHanjaDetailView.vue"),
            },
          ],
        },
        {
          path: "basis",
          redirect: "/firestore/manage",
        },
        {
          path: "basis/:id",
          redirect: (to) => ({
            path: `/firestore/manage/${String(to.params.id)}`,
          }),
        },
        {
          path: "sqlite/manage",
          meta: { requiresAdmin: true, splitManage: true, needsLocalApi: true },
          component: () => import("@/views/dashboard/LocalHanjaManageLayout.vue"),
          children: [
            {
              path: "",
              name: "sqlite-manage",
              component: () => import("@/views/dashboard/LocalHanjaManagePlaceholder.vue"),
            },
            {
              path: ":id",
              name: "sqlite-detail",
              component: () => import("@/views/dashboard/LocalHanjaDetailView.vue"),
            },
          ],
        },
        {
          path: "sqlite/detail/:id",
          redirect: (to) => ({
            path: `/sqlite/manage/${String(to.params.id)}`,
          }),
        },
        {
          path: "firestore/stroke-register/:id?",
          name: "firestore-stroke-register",
          meta: { requiresAdmin: true },
          component: () => import("@/views/dashboard/HanjaStrokeRegisterView.vue"),
        },
        {
          path: "db-sync",
          name: "db-sync",
          meta: { requiresAdmin: true, needsLocalApi: true },
          component: () => import("@/views/dashboard/DatabaseSyncView.vue"),
        },
        {
          path: "settings/auth",
          name: "settings-auth",
          component: () => import("@/views/dashboard/SettingsAuthView.vue"),
        },
        {
          path: "settings/display",
          name: "settings-display",
          component: () => import("@/views/dashboard/SettingsDisplayView.vue"),
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

async function waitUntilAuthenticationReady() {
  const auth = useAuthStore();
  if (auth.isAuthReady) return;
  await new Promise<void>((resolve) => {
    const stop = watch(
      () => auth.isAuthReady,
      (val) => {
        if (val) {
          stop();
          resolve();
        }
      },
    );
  });
}

router.beforeEach(async (to: RouteLocationNormalized) => {
  await waitUntilAuthenticationReady();
  const auth = useAuthStore();
  const isPublic = to.meta.public === true;

  if (!isPublic && !auth.isAuthenticated) {
    return { name: "login", query: { redirect: to.fullPath } };
  }
  if (to.name === "login" && auth.isAuthenticated) {
    return { path: "/" };
  }

  const needsAdmin = to.matched.some(
    (r: RouteRecordNormalized) => r.meta.requiresAdmin === true,
  );
  if (needsAdmin && !auth.isAdmin) {
    return { name: "dashboard", query: { needAdmin: "1" } };
  }

  const needsLocalApi = to.matched.some(
    (r: RouteRecordNormalized) => r.meta.needsLocalApi === true,
  );
  if (needsLocalApi && !isLocalApiEnabled) {
    return { name: "dashboard", query: { localApi: "0" } };
  }

  return true;
});

/** 새 배포로 인해 기존 청크 JS 해시가 변경되었을 때 자동 새로고침으로 최신 리소스 로드 */
router.onError((error, to) => {
  const errorMessage = error?.message || "";
  const isChunkLoadFailed =
    errorMessage.includes("Failed to fetch dynamically imported module") ||
    errorMessage.includes("Importing a module script failed") ||
    error?.name === "ChunkLoadError";

  if (isChunkLoadFailed && typeof window !== "undefined") {
    console.warn("새 배포로 인한 청크 로드 실패: 최신 자원으로 자동 새로고침합니다.");
    window.location.assign(to.fullPath);
  }
});

export default router;
