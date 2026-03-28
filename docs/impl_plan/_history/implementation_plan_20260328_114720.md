# Rename Project to 'chusa1817' and Fix Gradle Conflicts

The goal is to rename the Flutter project directory from `hanja_app` to `chusa1817` and update all internal references to ensure consistency. This also provides an opportunity to resolve the Gradle project name conflicts previously identified.

## User Review Required

> [!IMPORTANT]
> This change involves renaming the main project directory and updating the Android application ID/namespace. This will effectively create a "new" app on Android devices (the package name changes).

## Proposed Changes

### [Directroy Renaming]

#### [MOVE] [hanja_app](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/hanja_app) -> [chusa1817](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817)

### [Project Metadata]

#### [MODIFY] [pubspec.yaml](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/pubspec.yaml)
Update the project name from `breeze_chusa_1817` to `chusa1817` (or ensure consistency).

#### [MODIFY] [settings.gradle.kts](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/android/settings.gradle.kts)
Set `rootProject.name = "chusa1817"`.

#### [MODIFY] [build.gradle.kts](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/android/app/build.gradle.kts)
Update `namespace` and `applicationId` to `com.basis.hanja.chusa1817`.

#### [MODIFY] [web files](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/web/index.html)
Update titles and manifest information.

## Open Questions

> [!QUESTION]
> Should the Dart project name in `pubspec.yaml` be changed from `breeze_chusa_1817` to `chusa1817`? I will assume yes to match the folder name unless instructed otherwise.

## Verification Plan

### Automated Tests
- Run `flutter pub get` in the new directory.
- Run `flutter build bundle` to verify the build process.
- Verify Gradle project name with `./gradlew projects` in the `android` directory.

### Manual Verification
- Verify that the app still compiles and runs.
- Check that the 'Duplicate root element' error is resolved after JDT.LS re-scans the new directory.

## Verification Plan

### Automated Tests
- I'll check if the IDE still reports the same errors in the `@[current_problems]` after the change (although I can't trigger a re-scan myself, the USER_REQUEST will likely update or the user will see it).
- I'll try to run `./gradlew projects` in the `android` directory to ensure the name change is reflected and doesn't break the build.

### Manual Verification
- The user should see the errors in the 'Problems' tab disappear after the language server re-indexes the project.
- If the first two 'Invalid Gradle project configuration file' errors persist, the user might need to run the 'Clean Java Language Server Workspace' command in the IDE.
