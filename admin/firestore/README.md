# Admin · Firestore (Firebase CLI)

이 디렉터리가 **Firestore 규칙 배포용 Firebase 프로젝트 루트**다. `firebase deploy`는 여기서 실행한다.

| 파일 | 설명 |
|------|------|
| `firebase.json` | `firestore.rules` 경로 지정 |
| `.firebaserc` | 기본 Firebase 프로젝트 `chusa-1817` |
| `firestore.rules` | 배포할 보안 규칙 |
| `firestore_connect.md` | Flutter 앱 연동·스키마·업로드·트러블슈팅 |

```bash
cd admin/firestore
firebase deploy --only firestore:rules
# 또는 명시: firebase deploy --only firestore:rules --project chusa-1817
```

Python 업로드·Auth 클레임은 `admin/python/`을 본다.

---

## 🔒 Firebase 서비스 계정 키 (레포 밖 보관)

이 디렉터리 및 저장소 내에는 **Admin SDK 서비스 계정 JSON 키를 보관하지 않는다.**

- **권장 위치 (저장소 외부)**: `/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json`
- **환경 변수 설정**: `export GOOGLE_APPLICATION_CREDENTIALS=/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json`

