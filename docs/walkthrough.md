# 미사용 레퍼런스/임시 파일 정돈 및 .gitignore 최신화 워크스루

## 1. 개요
저장소 내 불필요한 미사용 레퍼런스 템플릿 폴더(`ref/`) 및 임시 스크린샷/로그 파일들을 완전히 정돈(삭제)하고, 루트 [`.gitignore`](../.gitignore)를 현재 3대 탑레벨 디렉터리 체계(`admin/`, `admin-etl/`, `client/`)에 맞춰 최신화했습니다.

---

## 2. 정돈 및 삭제 내역

1. **미사용 템플릿 폴더 삭제**:
   - `ref/` (`berry-vue-v2/`, `hud_vue_v6.0/`, `viewer/`) 완전 제거
2. **임시 이미지 및 로그 파일 삭제**:
   - `client/chusa1817/screenshots/` 디렉터리 및 `flutter_device_capture.png` 삭제
   - `client/chusa1817/flutter_01.png`, `flutter_02.png` 삭제
   - `client/chusa1817/custom_lint.log` 삭제
3. **루트 `.gitignore` 최신화**:
   - `client/**/.dart_tool/`, `client/**/build/`, `client/**/screenshots/`
   - `admin/webapp/node_modules/`, `admin/webapp/dist/`
   - `admin-etl/output/*.part*.json`

---

## 3. 검증 결과
- **Flutter 클라이언트 테스트 (`client/chusa1817`)**: **16 / 16 Passed (100% 통과)**
- **Admin Web App 유닛 테스트 & 프로덕션 빌드 (`admin/webapp`)**: **14 / 14 Passed**, **`built in 1.04s` 0에러 성공**
