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

export const COLLECTION_NAMES: CollectionName[] = [
  "hanja_basis",
  "hanja_extend",
  "hanja_word",
];

export const COLLECTION_LABELS: Record<CollectionName, string> = {
  hanja_basis: "기준 한자 (hanja_basis)",
  hanja_extend: "확장 메타 (hanja_extend)",
  hanja_word: "단어·성어 (hanja_word)",
};

export const useDataVersionStore = defineStore("dataVersion", () => {
  const version = ref<DataVersion | null>(null);
  const isFetching = ref(false);
  const isPublishing = ref(false);
  const fetchError = ref<string | null>(null);

  /** CRUD 후 아직 발행되지 않은 컬렉션 목록 */
  const pendingCollections = ref<CollectionName[]>([]);

  /** VersionBumpModal 표시 여부 — 어느 컴포넌트에서든 openBumpModal()로 열 수 있음 */
  const bumpModalOpen = ref(false);

  function markPending(col: CollectionName) {
    if (!pendingCollections.value.includes(col)) {
      pendingCollections.value = [...pendingCollections.value, col];
    }
  }

  function clearPending() {
    pendingCollections.value = [];
  }

  function openBumpModal() {
    bumpModalOpen.value = true;
  }

  function closeBumpModal() {
    bumpModalOpen.value = false;
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
        // 첫 발행 전: 0으로 초기화
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

  async function publish(
    changedCollections: CollectionName[],
    notes: string,
  ): Promise<void> {
    if (!isFirebaseConfigured())
      throw new Error("Firebase가 설정되지 않았습니다.");
    if (changedCollections.length === 0)
      throw new Error("변경된 컬렉션을 하나 이상 선택하세요.");

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
      // 최신 버전 문서 덮어쓰기
      await setDoc(doc(db, "_meta", "data_version"), payload);
      // 발행 이력 기록
      await addDoc(collection(db, "_changelog"), {
        ...payload,
        collections: changedCollections,
      });
      // 로컬 상태 업데이트
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

  return {
    version,
    isFetching,
    isPublishing,
    fetchError,
    pendingCollections,
    bumpModalOpen,
    markPending,
    clearPending,
    openBumpModal,
    closeBumpModal,
    fetchVersion,
    publish,
  };
});
