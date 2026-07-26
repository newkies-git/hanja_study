# Android 에뮬레이터 앱 실행 가이드 (`client/android_emulator_guide.md`)

HANJA 저장소의 **Flutter 모바일 클라이언트 앱(추사 1817 - `chusa1817`)**을 Android 에뮬레이터에서 구동하고 모바일 레이아웃 최적화 및 레이아웃 오버플로우를 검증하는 실행 가이드입니다.

---

## 📋 1. 등록된 Android 에뮬레이터 목록 확인

터미널에서 현재 Mac 시스템에 등록된 사용 가능한 에뮬레이터 목록을 확인합니다.

```bash
flutter emulators
```

**[확인된 에뮬레이터 목록]**
- `Medium_Phone_API_36.0`: Android 15 (API 36) 표준 휴대폰 뷰포트
- `flutter_emulator`: Google 기본 설정 에뮬레이터

---

## 🚀 2. Android 에뮬레이터 구동 (Launch)

원하는 에뮬레이터 ID를 지정하여 에뮬레이터를 백그라운드 시동합니다.

```bash
# Option A: Medium Phone 에뮬레이터 실행 (권장)
flutter emulators --launch Medium_Phone_API_36.0

# Option B: 기본 flutter_emulator 실행
flutter emulators --launch flutter_emulator
```

---

## 📱 3. 연결된 디바이스 ID 확인 및 부팅 대기

에뮬레이터 실행 후 부팅이 완전히 끝날 때까지 5~10초 대기한 뒤 디바이스 목록을 확인합니다.

```bash
flutter devices
```

> ⚠️ **`Device emulator-5554 is offline` 메시지가 뜨는 경우**:
> Android OS 시스템 부팅이 진행 중인 상태입니다. 에뮬레이터 화면에 Android 홈 화면이 뜰 때까지 잠시 기다린 후 `flutter devices`를 다시 실행하면 `online(device)` 상태로 변경됩니다.

**[부팅 완료 시 출력 예시]**
```text
emulator-5554 • flutter emulator • android-x86_64 • Android 14 / 15
```

---

## 🏃 4. Flutter 앱 실행 (`flutter run`)

`pubspec.yaml` 파일이 존재하는 **Flutter 프로젝트 루트 디렉터리(`client/chusa1817`)**로 이동하여 앱을 빌드하고 실행합니다.

```bash
# 1. Flutter 프로젝트 루트 디렉터리로 이동 (필수)
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/client/chusa1817

# 2-A. 부팅 완료된 에뮬레이터로 앱 실행
flutter run

# 2-B. 디바이스 ID를 명시하여 실행하는 경우
flutter run -d emulator-5554
```

---

## ⚡ 5. 앱 실행 중 유용한 단축키

`flutter run` 실행 중 터미널 입력창에 다음 키를 눌러 실시간 반응성을 검증합니다:

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`r`** | **Hot Reload** (소소한 UI/코드 수정 사항 1초 만에 화면 반영) |
| **`R`** | **Hot Restart** (앱 재시동 및 상태 변수 초기화) |
| **`v`** | **DevTools 링크 열기** (브라우저에서 Widget Inspector 및 Layout Explorer 실행) |
| **`h`** | 유용한 CLI 도움말 목록 출력 |
| **`q`** | 앱 구동 및 세션 종료 |

---

## 🔍 6. 뷰포트 & 레이아웃 검증 (DevTools)

모바일 화면 픽셀 잘림(Yellow/Black Striped Overflow)이나 SafeArea 침범을 검증하려면:

1. `flutter run` 실행 후 터미널에 표출되는 **DevTools URL** (`http://127.0.0.1:9100/...`)을 브라우저로 엽니다.
2. **Layout Explorer** 메뉴에서 `Show Guidelines`를 켜고 캔버스, 원고지 그리드, 카드리스트의 뷰포트 채움 여부를 확인합니다.

---

## 📚 관련 명세 문서
- **모바일 클라이언트 상세 기능 명세서**: [`docs/SPEC-client.md`](../docs/SPEC-client.md)
- **클라이언트 개발 로드맵**: [`client/to-do-list.md`](to-do-list.md)
- **클라이언트 마스터 안내서**: [`client/README.md`](README.md)
