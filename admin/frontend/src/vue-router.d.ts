export {};

declare module "vue-router" {
  interface RouteMeta {
    /** 로그인 없이 접근 가능 */
    public?: boolean;
    /** 로그인 필요(레이아웃 기본) */
    requiresAuth?: boolean;
    /** admin 커스텀 클레임 필요 */
    requiresAdmin?: boolean;
  }
}
