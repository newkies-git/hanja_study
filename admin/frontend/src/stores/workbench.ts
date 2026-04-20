import { defineStore } from "pinia";
import { ref } from "vue";
import {
  addDoc,
  collection,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
} from "firebase/firestore";
import { getFirestoreDb, isFirebaseConfigured } from "@/firebase";
import { useAuthStore } from "@/stores/auth";
import { isLocalApiEnabled, localApiUrl } from "@/config/localApi";

export type CollectionName = "hanja_basis" | "hanja_extend" | "hanja_word";

export type DataVersion = {
  global: number;
  hanja_basis: number;
  hanja_extend: number;
  hanja_word: number;
  publishedAt: Date | null;
  publishedBy: string;
  notes: string;
};

/** 로컬 SQLite `sync_sessions` 활성 행 */
export type LocalWorkSession = {
  id: number;
  description?: string | null;
  status?: string;
};

export const COLLECTION_NAMES: CollectionName[] = [
  "hanja_basis",
  "hanja_extend",
  "hanja_word",
];

export const COLLECTION_LABELS: Record<CollectionName, string> = {
  hanja_basis: "Firestore 한자 (hanja_basis)",
  hanja_extend: "확장 메타 (hanja_extend)",
  hanja_word: "단어·성어 (hanja_word)",
};

/**
 * 로컬 작업(채번·sync_sessions)과 서버 반영(Firestore _meta/data_version)을 한 흐름으로 관리합니다.
 * - 로컬: 편집 시 change_number에 쓰일 활성 세션. 동기화로 서버에 올리면 작업 단위가 끝납니다.
 * - 서버: Firestore에서 직접 바꾼 뒤 클라이언트가 알 수 있게 버전을 발행해야 합니다.
 */
export const useWorkbenchStore = defineStore("workbench", () => {
  // ── 서버 데이터 버전 ──────────────────────────────────────────────────────
  const version = ref<DataVersion | null>(null);
  const isFetching = ref(false);
  const isPublishing = ref(false);
  const fetchError = ref<string | null>(null);
  const pendingCollections = ref<CollectionName[]>([]);

  // ── 로컬 작업 세션 ────────────────────────────────────────────────────────
  const localSession = ref<LocalWorkSession | null>(null);
  const localSessionLoading = ref(false);

  // ── 통합 모달 ────────────────────────────────────────────────────────────
  const workbenchModalOpen = ref(false);

  function markPending(col: CollectionName) {
    if (!pendingCollections.value.includes(col)) {
      pendingCollections.value = [...pendingCollections.value, col];
    }
  }

  function clearPending() {
    pendingCollections.value = [];
  }

  function openWorkbenchModal() {
    workbenchModalOpen.value = true;
  }

  function closeWorkbenchModal() {
    workbenchModalOpen.value = false;
  }

  async function fetchVersion(): Promise<void> {
    if (!isFirebaseConfigured()) return;
    isFetching.value = true;
    fetchError.value = null;
    try {
      const db = getFirestoreDb();
      const snap = await getDoc(doc(db, "_meta", "data_version"));
      if (snap.exists()) {
        const d = snap.data();
        version.value = {
          global: (d["global"] as number) ?? 0,
          hanja_basis: (d["hanja_basis"] as number) ?? 0,
          hanja_extend: (d["hanja_extend"] as number) ?? 0,
          hanja_word: (d["hanja_word"] as number) ?? 0,
          publishedAt: (d["publishedAt"] as { toDate?: () => Date } | null)?.toDate?.() ?? null,
          publishedBy: (d["publishedBy"] as string) ?? "",
          notes: (d["notes"] as string) ?? "",
        };
      } else {
        version.value = {
          global: 0,
          hanja_basis: 0,
          hanja_extend: 0,
          hanja_word: 0,
          publishedAt: null,
          publishedBy: "",
          notes: "",
        };
      }
    } catch (e) {
      fetchError.value =
        e instanceof Error ? e.message : "버전 정보를 불러오지 못했습니다.";
    } finally {
      isFetching.value = false;
    }
  }

  async function publish(notes: string): Promise<void> {
    if (!isFirebaseConfigured())
      throw new Error("Firebase가 설정되지 않았습니다.");

    const changedCollections =
      pendingCollections.value.length > 0 ? pendingCollections.value : COLLECTION_NAMES;

    const auth = useAuthStore();
    await auth.syncIdTokenForFirestore();

    const db = getFirestoreDb();
    const cur = version.value ?? {
      global: 0,
      hanja_basis: 0,
      hanja_extend: 0,
      hanja_word: 0,
    };
    const newGlobal = cur.global + 1;

    const payload: Record<string, unknown> = {
      global: newGlobal,
      hanja_basis: cur.hanja_basis,
      hanja_extend: cur.hanja_extend,
      hanja_word: cur.hanja_word,
      publishedAt: serverTimestamp(),
      publishedBy: auth.user?.email ?? "unknown",
      notes: notes.trim(),
    };

    for (const col of changedCollections) {
      payload[col] = (cur[col] as number) + 1;
    }

    isPublishing.value = true;
    try {
      await setDoc(doc(db, "_meta", "data_version"), payload);
      await addDoc(collection(db, "_changelog"), {
        ...payload,
        collections: changedCollections,
      });
      version.value = {
        global: newGlobal,
        hanja_basis: payload["hanja_basis"] as number,
        hanja_extend: payload["hanja_extend"] as number,
        hanja_word: payload["hanja_word"] as number,
        publishedAt: new Date(),
        publishedBy: auth.user?.email ?? "unknown",
        notes: notes.trim(),
      };
      clearPending();
    } finally {
      isPublishing.value = false;
    }
  }

  async function fetchLocalSession(): Promise<void> {
    if (!isLocalApiEnabled) {
      localSession.value = null;
      return;
    }
    localSessionLoading.value = true;
    try {
      const res = await fetch(localApiUrl("/api/session"));
      const j = (await res.json()) as { data?: LocalWorkSession | null };
      if (j.data) {
        const id = Number(j.data.id);
        localSession.value = {
          ...j.data,
          id: Number.isFinite(id) ? id : j.data.id,
        };
      } else {
        localSession.value = null;
      }
    } catch {
      localSession.value = null;
    } finally {
      localSessionLoading.value = false;
    }
  }

  async function startLocalSession(description: string | null): Promise<void> {
    if (!isLocalApiEnabled) {
      throw new Error("로컬 API가 비활성화되어 있습니다. VITE_USE_LOCAL_API=true 로 설정하세요.");
    }
    const res = await fetch(localApiUrl("/api/session"), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ description: description ?? null }),
    });
    const json = (await res.json().catch(() => ({}))) as {
      data?: LocalWorkSession | null;
      error?: string;
    };
    if (!res.ok) {
      throw new Error(json.error || "채번을 발급하지 못했습니다.");
    }
    if (json.data) {
      const id = Number(json.data.id);
      localSession.value = {
        ...json.data,
        id: Number.isFinite(id) ? id : (json.data.id as number),
      };
      return;
    }
    await fetchLocalSession();
    if (!localSession.value) {
      throw new Error("발급 응답에 채번이 없고, 조회로도 가져오지 못했습니다.");
    }
  }

  async function setLocalSessionDescription(description: string): Promise<void> {
    if (!isLocalApiEnabled) {
      throw new Error("로컬 API가 비활성화되어 있습니다. VITE_USE_LOCAL_API=true 로 설정하세요.");
    }
    const s = localSession.value;
    if (!s) throw new Error("활성 채번이 없습니다.");
    const res = await fetch(localApiUrl(`/api/session/${s.id}`), {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ description }),
    });
    if (!res.ok) throw new Error("작업 로그를 수정하지 못했습니다.");
    await fetchLocalSession();
  }

  return {
    version,
    isFetching,
    isPublishing,
    fetchError,
    pendingCollections,
    localSession,
    localSessionLoading,
    workbenchModalOpen,
    markPending,
    clearPending,
    openWorkbenchModal,
    closeWorkbenchModal,
    fetchVersion,
    publish,
    fetchLocalSession,
    startLocalSession,
    setLocalSessionDescription,
  };
});
