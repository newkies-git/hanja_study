# Admin 영역 안내 (`admin/`)

HANJA 저장소에서 **백오피스(Vue 3 Web App) 및 Firebase/Firestore 운영** 관련 파일은 `admin/` 아래에서 관리합니다. 데이터 파이프라인(ETL)은 **`admin-etl/`**, 클라이언트 모바일 앱은 **`client/`**로 분리되어 독립적으로 관리됩니다.

---

## 디렉터리 구조

| 경로 | 역할 |
|------|------|
| `admin/webapp/` | **관리 웹앱** (Vite · Vue 3 · TypeScript · Tailwind CSS 어드민 대시보드) |
| `admin/firestore/` | **Firestore 규칙 배포용 Firebase CLI 루트** — `firebase.json`, `.firebaserc`, `firestore.rules`, `README.md`, `firestore_connect.md` |
| `admin-etl/` | **Python ETL 데이터 파이프라인** (네이버 한자 스크래핑, 획순 SVG 추출, Firestore 업로더) |
| `client/chusa1817/` | **Flutter 모바일 클라이언트 앱** |
| `client/scripts/setup_firebase_flutter.sh` | 로컬에서 Firebase CLI 로그인, **`admin/firestore`에서 규칙 배포**, `flutterfire configure` 안내·실행 |

### Admin 웹 (`admin/webapp`)

1. `cd admin/webapp && cp .env.example .env` 후 Firebase 웹 앱 키를 채운다.  
2. `npm install` → `npm run dev` (기본 포트 `5174`).  
3. Authentication에서 **이메일/비밀번호** 로그인을 켜고, 쓰기가 필요하면 `set_firebase_custom_claims.py`로 `admin` 클레임을 부여한다.  
4. 한자 마스터 등록(CSV 업로드) 등에서 `Missing or insufficient permissions`가 나오면 **`admin/firestore/firestore_connect.md` §11.1**을 본다.

---

## Firebase / Firestore

- **프로젝트 ID**: `chusa-1817` (Dart 패키지/앱 식별자 `chusa1817`과 구분)
- **규칙 배포**는 반드시 **`admin/firestore`를 작업 디렉터리**로 둔 뒤 실행한다 (`firebase.json`이 `firestore.rules`를 가리킴). `.firebaserc`에 기본 프로젝트가 설정되어 있다.

  ```bash
  cd admin/firestore
  firebase deploy --only firestore:rules --project chusa-1817
  ```

- 한 번에 맞추려면 저장소 루트에서:

  ```bash
  ./client/scripts/setup_firebase_flutter.sh
  ```

  이 스크립트는 **`admin/firestore`에서 규칙을 배포**하고, **저장소 루트**의 `client/chusa1817`에 대해 `flutterfire configure`를 돌린다.

- 상세: `admin/firestore/firestore_connect.md` · 폴더 요약: `admin/firestore/README.md`

---

## Python ETL (`admin-etl/`)

작업 디렉터리: `admin-etl/`

| 작업 | 명령 예 |
|------|---------|
| 의존성(ETL) | `pip install -r requirements.txt` 후 Playwright Chromium 설치( `hanja_pipeline.py` 주석 참고) |
| ETL 실행 | `python hanja_pipeline.py` (CSV 경로 입력) |
| Firestore 업로드 | `pip install -r requirements-firebase.txt` → `python upload_to_firestore.py --project-id chusa-1817` |
| Admin Auth 클레임 | `python set_firebase_custom_claims.py --project-id chusa-1817 --email … --admin true` |

`upload_to_firestore.py`의 기본 JSON 경로는 **`admin-etl/output/`** 아래를 가리킨다.

---

## Flutter 앱과의 관계 (`client/`)

- 앱 소스: **`client/chusa1817`**
- Firestore에서 읽기 전용 동기화, 익명 로그인 등은 `firestore_connect.md` 절차를 따른다.

---

## 관련 문서 요약

| 문서 | 내용 |
|------|------|
| `admin/admin-readme.md` | 이 파일 — `admin/` 전체 맵 |
| `admin/firestore/README.md` | Firestore CLI 폴더 구성·배포 한 줄 요약 |
| `admin/firestore/firestore_connect.md` | Firestore 스키마, 앱 매핑, 배포·업로드 절차 |

---

## 변경 이력 (경로 정리)

- 예전에는 저장소 루트에 `firebase.json`, `firestore/`, `python/`, `scripts/`가 있었을 수 있다. 이후 **`admin/`** 아래로 모았다.
- **Firestore CLI 설정**(`firebase.json`, `.firebaserc`)은 **`admin/firestore/`**에 둔다. `flutter/scripts/setup_firebase_flutter.sh`는 **`admin/firestore`에서 `firebase deploy`**를 실행하고, Flutter 앱 경로는 **`flutter/chusa1817`**(저장소 루트 기준)으로 잡는다.
