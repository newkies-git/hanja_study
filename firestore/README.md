# Firebase 서비스 계정 키 (레포 밖 보관)

이 디렉터리에는 **Admin SDK JSON을 두지 않습니다.**  
키가 워크스페이스에 있으면 백업·실수 커밋·공유로 유출될 수 있습니다.

## 권장 위치

레포 밖 (예):

```text
/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json
```

## 사용

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json
```

클레임 부여 등: `admin/firestore/firestore_connect.md` § 커스텀 클레임 참고.

유출이 의심되면 Firebase Console에서 해당 서비스 계정 키를 **즉시 폐기·재발급**하세요.
