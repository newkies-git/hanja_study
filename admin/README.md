# Admin 백오피스 & Firestore 규칙 (`admin/`)

HANJA 저장소의 **관리자 백오피스 웹 애플리케이션(`webapp/`)** 및 **Firestore 보안 규칙 배포 환경(`firestore/`)**을 관리하는 디렉터리입니다.

---

## 📁 디렉터리 구조

| 경로 | 역할 및 구성 |
| :--- | :--- |
| **[`webapp/`](webapp/package.json)** | **어드민 관리 웹 앱** (Vite 6, Vue 3, TypeScript, Tailwind CSS 대시보드) |
| **[`firestore/`](firestore/README.md)** | **Firestore CLI 배포 환경** (`firebase.json`, `.firebaserc`, `firestore.rules`, `firestore_connect.md`) |

---

## 🚀 빠른 실행 및 가이드

### 1. 어드민 관리 웹 실행 (`admin/webapp/`)
```bash
# 디렉터리 이동 및 환경 변수 설정
cd admin/webapp
cp .env.example .env

# 의존성 설치 및 개발 서버 실행 (포트 5174)
npm install
npm run dev

# 단위 테스트 및 프로덕션 빌드
npm run test -- --run
npm run build
```

### 2. Firestore 보안 규칙 배포 (`admin/firestore/`)
```bash
# 디렉터리 이동 후 Firebase CLI 배포
cd admin/firestore
firebase deploy --only firestore:rules --project chusa-1817
```

---

## 📚 관련 명세 문서
- **어드민 백오피스 상세 기능 명세서**: [`docs/SPEC-admin.md`](../docs/SPEC-admin.md)
- **Firestore 연동 & 보안 마스터 문서**: [`admin/firestore/firestore_connect.md`](firestore/firestore_connect.md)
- **저장소 마스터 안내서**: [`README.md`](../README.md)
