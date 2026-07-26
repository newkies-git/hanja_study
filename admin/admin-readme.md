# Admin 영역 안내 (`admin/`)

HANJA 저장소에서 **백오피스·데이터 파이프라인·Firebase/Firestore 운영**과 관련된 자료를 `admin/` 한 곳에 모아 둔다. 클라이언트 앱(Flutter) 코드는 **`flutter/chusa1817`**에 그대로 두며, 이 문서의 경로는 저장소 루트를 기준으로 한다.

---

## 디렉터리 구조

| 경로 | 역할 |
|------|------|
| `admin/firestore/` | **Firestore 규칙 배포용 Firebase CLI 루트** — `firebase.json`, `.firebaserc`, `firestore.rules`, `README.md`, `firestore_connect.md` |
| `flutter/scripts/setup_firebase_flutter.sh` | 로컬에서 Firebase CLI 로그인, **`admin/firestore`에서 규칙 배포**, `flutterfire configure` 안내·실행 |
| `admin/admin-etl/` | ETL(네이버 한자사전 스크래핑), JSON 산출물, Firestore 업로드·Auth 커스텀 클레임 스크립트 |
| `admin/admin-etl/output/` | ETL 파이프라인 결과. **`hanja_extend`·`hanja_stroke`·`hanja_word`는 JSON(객체 배열)이 표준 형식**이며, `hanja_entities.json` / `stroke_entities.json` / `word_entities.json`이 각각 2~4단계 원천이다. `hanja_basis`는 CSV. 관리 웹「한자 마스터 등록」에서 순서대로 업로드(JSON 직접 또는 CSV). |
| `ref_hud_vue_v6.0/` (저장소 루트) | HUD Vue 템플릿 참고 자료(문서·스타터) |
| `admin/webapp/` | 관리 웹앱(Vite · Vue 3 · TypeScript · Tailwind). 레이아웃은 HUD와 유사하게 사이드바+헤더 구성 |

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
  ./flutter/scripts/setup_firebase_flutter.sh
  ```

  이 스크립트는 **`admin/firestore`에서 규칙을 배포**하고, **저장소 루트**의 `flutter/chusa1817`에 대해 `flutterfire configure`를 돌린다.

- 상세: `admin/firestore/firestore_connect.md` · 폴더 요약: `admin/firestore/README.md`

---

## Python ETL (데이터 파이프라인 · 업로드 · 클레임)

작업 디렉터리: `admin/admin-etl/`

| 작업 | 명령 예 |
|------|---------|
| 의존성(ETL) | `pip install -r requirements.txt` 후 Playwright Chromium 설치( `hanja_pipeline.py` 주석 참고) |
| ETL 실행 | `python hanja_pipeline.py` (CSV 경로 입력) |
| Firestore 업로드 | `pip install -r requirements-firebase.txt` → `python upload_to_firestore.py --project-id chusa-1817` |
| Admin Auth 클레임 | `python set_firebase_custom_claims.py --project-id chusa-1817 --email … --admin true` |

`upload_to_firestore.py`의 기본 JSON 경로는 **`admin/admin-etl/output/`** 아래를 가리킨다.

---

## Flutter 앱과의 관계

- 앱 소스: **`flutter/chusa1817`**
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
