---
description: 연결된 Flutter 디바이스·에뮬레이터에서 스크린샷·화면 녹화를 수집한다
---

# Flutter 디바이스 캡처 워크플로우

UI 검수, 버그 재현 자료, 스토어 스크린샷용으로 **연결된 기기 또는 시뮬레이터** 화면을 이미지·동영상으로 저장한다.

## 사전 조건

- 프로젝트 루트: `/Users/yutaek/zWorkSpace/zBasis/HANJA`
- Flutter 앱 패키지: `flutter/chusa1817`
- **권장 출력 디렉터리(생성):**  
  `/Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/captures/`  
  (저장소에 커밋할지는 팀 정책에 따른다. `.gitignore`에 `captures/`를 넣는 경우가 많다.)

```bash
mkdir -p /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/captures
```

- **도구:** `flutter`, `adb`(Android), Xcode CLI(iOS 시뮬레이터). 물리 iPhone은 USB + 신뢰 설정이 필요할 수 있다.

---

## 수행 절차

### 1. 디바이스 확인
// turbo
```bash
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817
flutter devices
flutter doctor -v
```
캡처할 기기 ID를 확인한다 (예: `emulator-5554`, `iPhone 16 Pro`).

특정 기기만 지정해 실행 중이면 아래 명령에 `-d <device_id>` 를 붙인다.

---

### 2-A. 스크린샷 (Flutter 공통 · 권장)

앱이 해당 기기에서 **이미 실행 중**이어야 한다.  
출력 경로는 `-o` 로 지정한다.

// turbo
```bash
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817
TS=$(date +%Y%m%d_%H%M%S)
flutter screenshot -o "captures/screenshot_${TS}.png"
```

기기를 고정하려면:

```bash
flutter screenshot -d <device_id> -o "captures/screenshot_${TS}.png"
```

**참고:** 일부 환경에서 `flutter screenshot`이 실패하면 아래 플랫폼별 방법을 쓴다.

---

### 2-B. Android (adb)

기기가 `adb devices`에 보여야 한다.

**스크린샷 (PNG):**

// turbo
```bash
TS=$(date +%Y%m%d_%H%M%S)
OUT="/Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/captures/android_${TS}.png"
adb exec-out screencap -p > "$OUT"
```

**화면 녹화 (최대 180초, 기본 3분 제한):**

```bash
TS=$(date +%Y%m%d_%H%M%S)
REMOTE="/sdcard/screen_${TS}.mp4"
adb shell screenrecord "$REMOTE"
# 종료: Ctrl+C
adb pull "$REMOTE" "/Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/captures/"
adb shell rm "$REMOTE"
```

---

### 2-C. iOS 시뮬레이터

부팅된 시뮬레이터가 있어야 한다 (`open -a Simulator`).

**스크린샷:**

// turbo
```bash
TS=$(date +%Y%m%d_%H%M%S)
OUT="/Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/captures/ios_sim_${TS}.png"
xcrun simctl io booted screenshot "$OUT"
```

**화면 녹화 (Ctrl+C로 종료):**

```bash
TS=$(date +%Y%m%d_%H%M%S)
OUT="/Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/captures/ios_sim_${TS}.mp4"
xcrun simctl io booted recordVideo "$OUT"
```

---

### 3. 완료 보고

- 저장한 파일의 **절대 경로**와 **해상도·기기명**(가능하면 `flutter devices` 한 줄)을 알린다.
- 문서·PR·이슈에 붙일 때는 민감 정보(계정, 개인 데이터)가 가려졌는지 확인한다.

---

## 주의사항

> [!NOTE]
> **물리 기기(iPhone 실기기)** 는 `flutter screenshot` 또는 Xcode **Window → Device and Simulators → Open Console / 스크린샷**으로 수집하는 경우가 많다. macOS에 `idevicescreenshot`(libimobiledevice)이 있으면 CLI로도 가능하나, 환경별 설치가 필요하다.

> [!CAUTION]
> Android `screenrecord`는 일부 기기에서 해상도·코덱 제한이 있다. 재생이 안 되면 `adb pull`로 파일 무결성을 먼저 확인한다.

> [!NOTE]
> 캡처 폴더를 git에 올리지 않으려면 `flutter/chusa1817/.gitignore`에 `captures/`를 추가한다.

---

## 관련 워크플로우

- `/git_commit_push` — 캡처를 저장소에 포함해 커밋할 때
- `/analyze_and_propose` — UI 상태를 분석 보고에 반영할 때 참고 자료로 첨부
