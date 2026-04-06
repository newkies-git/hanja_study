---
name: device_capture
description: >-
  Captures the connected mobile/desktop screen using `flutter screenshot` from
  chusa1817, writing PNG under `screenshots/`. Use when the user asks for device
  capture, screen capture, flutter screenshot, 디바이스 캡처, 화면 캡처, or 스킬
  device_capture.
---

# Flutter 디바이스 화면 캡처 (device_capture)

연결된 기기의 **전체 화면**(Flutter 밖 UI 포함)을 `flutter screenshot`으로 저장한다. 저장소 내 Flutter 앱 경로는 **`flutter/chusa1817`** 이다.

## 절차

1. 필요 시 기기 확인: `flutter devices` 로 **device id**를 본다.
2. 저장 디렉터리 생성(최초 1회): `mkdir -p screenshots`
3. 캡처 실행(저장소 루트 `HANJA` 기준):

```bash
cd flutter/chusa1817
mkdir -p screenshots
flutter screenshot -o screenshots/flutter_device_capture.png -d R3CN109NNGP
```

- **`-d`**: 대상 기기 ID(또는 이름 접두사). 예: 갤럭시 `R3CN109NNGP`.
- **다른 기기**면 `flutter devices` 출력의 **ID 열**을 확인한 뒤 **`-d` 값만** 바꾼다.
- **출력 경로**는 `-o`로 바꿀 수 있다(프로젝트 규칙에 맞게 `screenshots/` 하위 권장).

## 참고

- USB/무선 연결·개발자 옵션이 갖춰져 있어야 기기가 잡힌다.
- Skia 트리만 뽑는 `--type=skia`는 VM Service URL이 필요하므로 이 스킬 범위 밖이다.
