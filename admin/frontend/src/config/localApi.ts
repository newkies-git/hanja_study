/**
 * 로컬 Express(`server.js`) SQLite API 사용 여부.
 * - `VITE_USE_LOCAL_API`를 **비우면**: `vite` 개발 서버에서는 켜짐, `vite build` 산출물에서는 꺼짐.
 * - `true` / `false` 등으로 **명시**하면 그 값이 우선한다.
 * `localApiFetch`는 꺼져 있으면 즉시 reject 한다.
 *
 * 선택: `VITE_LOCAL_API_BASE_URL` (예: `http://localhost:3000`) — 비우면
 * 동일 오리진의 `/api`(Vite dev 프록시 등).
 */

function parseEnvFlag(raw: unknown): boolean {
  if (raw === true) return true;
  if (typeof raw !== "string") return false;
  const s = raw.trim().toLowerCase();
  return s === "true" || s === "1" || s === "yes";
}

const rawLocalApi = import.meta.env.VITE_USE_LOCAL_API;
/** 명시 없으면: `vite` 개발 중만 켜고, `vite build` 산출물에서는 끔 */
export const isLocalApiEnabled =
  rawLocalApi !== undefined && String(rawLocalApi).trim() !== ""
    ? parseEnvFlag(rawLocalApi)
    : import.meta.env.DEV;

/** `/api/...` 또는 절대 베이스 + path */
export function localApiUrl(path: string): string {
  const p = path.startsWith("/") ? path : `/${path}`;
  const base = String(import.meta.env.VITE_LOCAL_API_BASE_URL ?? "").replace(/\/$/, "");
  if (base) return `${base}${p}`;
  return p;
}

export function localApiFetch(path: string, init?: RequestInit): Promise<Response> {
  if (!isLocalApiEnabled) {
    return Promise.reject(
      new Error("로컬 API가 비활성화되어 있습니다. 개발 시 .env에 VITE_USE_LOCAL_API=true 를 설정하세요."),
    );
  }
  return fetch(localApiUrl(path), init);
}
