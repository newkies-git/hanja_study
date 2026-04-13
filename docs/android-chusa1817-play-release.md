# chusa1817 Android 릴리스 · 업로드 keystore · Play 배포

Flutter 앱 `flutter/chusa1817`을 Google Play에 올리기 위한 로컬 keystore 생성, Gradle 연결, Firebase·Google 로그인 지문 등록, AAB 빌드까지의 절차를 정리한다.

## 전제

- Android 애플리케이션 ID: `com.basis.breeze.chusa1817`
- 버전은 `pubspec.yaml`의 `version: 이름+번호` 형식에서, `+` 뒤가 Play의 `versionCode`이며 **업로드마다 증가**해야 한다.
- 릴리스 서명은 `android/app/build.gradle.kts`에서 `android/key.properties`가 있으면 해당 keystore를 사용한다. 없으면 debug 서명으로 release가 빌드된다(스토어 업로드용이 아님).

## 1. 업로드용 keystore 생성

터미널에서 대화형으로 비밀번호·이름 정보를 입력한다.

```bash
keytool -genkeypair -v \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias chusa1817 \
  -keystore ./chusa1817-upload-keystore.jks
```

- `chusa1817` 디렉터리(`flutter/chusa1817`)에서 실행하면 현재 폴더에 `chusa1817-upload-keystore.jks`가 생성된다.
- keystore 비밀번호·키 비밀번호·별칭(`alias`)은 안전한 곳에 따로 보관한다. 분실 시 동일 키로 재서명할 수 없다.
- keystore 파일은 Git에 포함하지 않는다. 저장소에는 `flutter/chusa1817/.gitignore`에 `chusa1817-upload-keystore.jks`가 포함되어 있다.

### keytool 기본 경로 오류

`keytool -list -v`만 실행하면 기본으로 `~/.keystore`를 찾는다. 파일이 없으면 “키 저장소 파일이 존재하지 않음” 오류가 난다. 반드시 `-keystore`로 실제 경로를 지정한다.

```bash
keytool -list -v \
  -keystore /Users/본인계정/Documents/zWorkSpace/HANJA/flutter/chusa1817/chusa1817-upload-keystore.jks \
  -alias chusa1817
```

출력의 **SHA1**, **SHA-256**을 복사해 둔다(Firebase·OAuth 클라이언트 등록에 사용).

## 2. `key.properties` 구성

`flutter/chusa1817/android/key.properties.example`을 참고해 `flutter/chusa1817/android/key.properties`를 만든다. 이 파일은 `android/.gitignore`에 의해 추적되지 않는다.

예시(keystore가 `flutter/chusa1817/chusa1817-upload-keystore.jks`에 있는 경우). `storeFile`은 **`android/app` 모듈 기준** 상대 경로다.

```properties
storePassword=…
keyPassword=…
keyAlias=chusa1817
storeFile=../../chusa1817-upload-keystore.jks
```

keystore를 저장소 루트 `HANJA/`에 두었다면:

```properties
storeFile=../../../../chusa1817-upload-keystore.jks
```

## 3. 릴리스 빌드(App Bundle)

```bash
cd flutter/chusa1817
flutter build appbundle --release
```

산출물: `build/app/outputs/bundle/release/app-release.aab`

Play Console에는 **AAB**를 업로드한다.

## 4. Firebase에 서명 지문 등록

1. [Firebase 콘솔](https://console.firebase.google.com) → 해당 프로젝트 → **프로젝트 설정** → **내 앱** → Android 앱(`com.basis.breeze.chusa1817`).
2. **지문 추가**에 `keytool -list -v`로 확인한 **SHA1** 및 **SHA-256**을 등록한다.
3. 패키지명을 바꾼 경우 콘솔에 동일 패키지의 Android 앱이 등록되어 있어야 하며, 필요 시 `google-services.json`을 다시 내려받아 `android/app/`에 반영한다.

## 5. Google 로그인(Google Sign-In) 사용 시

[Google Cloud Console](https://console.cloud.google.com) → **API 및 서비스** → **사용자 인증 정보**에서 Android용 **OAuth 2.0 클라이언트 ID**에 다음이 릴리스 keystore와 일치하는지 확인한다.

- 패키지 이름: `com.basis.breeze.chusa1817`
- SHA-1 지문: 위 `keytool` 출력과 동일

## 6. Google Play Console

1. [Play Console](https://play.google.com/console)에서 앱을 만들거나 기존 앱을 연다. 패키지명이 `com.basis.breeze.chusa1817`와 일치해야 한다.
2. **내부 테스트** 등 원하는 트랙에 `app-release.aab`를 업로드한다.
3. 스토어 등록 정보, **데이터 안전**, 콘텐츠 등급, 개인정보처리방침 URL 등 정책 항목을 완료한 뒤 검토를 제출한다.
4. **Google Play 앱 서명**을 사용하면 Google이 앱 서명 키를 보관하고, 개발자는 **업로드 키**로 AAB만 서명하면 된다.

## 7. 체크리스트 요약

| 단계 | 확인 |
|------|------|
| keystore 생성 | `chusa1817-upload-keystore.jks`, alias·비밀번호 백업 |
| Git | keystore·`key.properties` 미추적 |
| `key.properties` | `storeFile` 경로가 실제 파일 위치와 일치 |
| 지문 | Firebase(및 필요 시 OAuth)에 SHA1·SHA-256 |
| 빌드 | `flutter build appbundle --release` |
| 스토어 | AAB 업로드, `versionCode` 증가 |

## 관련 파일

- `flutter/chusa1817/android/app/build.gradle.kts` — `key.properties` 기반 release 서명
- `flutter/chusa1817/android/key.properties.example` — `storeFile` 경로 예시
- `flutter/chusa1817/lib/firebase_options.dart` — Firebase 초기화(iOS 번들 ID 등은 콘솔과 맞출 것)
