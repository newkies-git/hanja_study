# Android 에뮬레이터 앱 실행 가이드 작성 워크스루

## 1. 개요
Android 에뮬레이터에서 Flutter 클라이언트 앱(추사 1817 - `chusa1817`)을 시동하고 모바일 레이아웃 최적화 및 뷰포트 오버플로우를 검증할 수 있는 상세 구동 가이드 문서 [`client/android_emulator_guide.md`](../client/android_emulator_guide.md)를 작성하고, [`client/README.md`](../client/README.md) 인덱스에 연동했습니다.

---

## 2. 주요 구성 내용

1. **에뮬레이터 목록 확인**: `flutter emulators` CLI 명령
2. **에뮬레이터 구동**: `flutter emulators --launch Medium_Phone_API_36.0`
3. **디바이스 인식 점검**: `flutter devices`
4. **앱 실행**: `cd client/chusa1817 && flutter run -d emulator-5554`
5. **핫리로드 & 레이아웃 검증**: `r` (Hot Reload), `v` (DevTools Layout Explorer)

---

## 3. 검증 결과
- **상대 경로 링크**: 문서 간 하이퍼링크가 환경 독립적인 상대 경로로 연결됨
- **CLI 동작**: `Medium_Phone_API_36.0` 및 `flutter_emulator` 2종 정상 인식 확인 완료
