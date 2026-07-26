# Firestore & Firebase 보안 안내

> **Firestore CLI 프로젝트 루트**: [`admin/firestore/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/firestore/README.md)  
> **상세 연결·스키마 문서**: [`admin/firestore/firestore_connect.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/firestore/firestore_connect.md)

---

## 🔒 Firebase 서비스 계정 키 (레포 밖 보관)

이 디렉터리에는 **Admin SDK 서비스 계정 JSON 키를 절대 보관하지 않습니다.**

### 권장 위치 (저장소 외부)
```text
/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json
```

### 환경 변수 설정
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json
```

자세한 Firestore 보안 규칙 배포, App Check 강제 적용 및 클레임 부여는 [`admin/firestore/firestore_connect.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/firestore/firestore_connect.md)를 참고하세요.
