# Phase 1: Project Stabilization

This phase focuses on stabilizing the codebase by fixing failing tests, addressing Lint warnings, and ensuring the core SM-2 review algorithm is implemented correctly.

## 1. Test Stabilization

### [MODIFY] [landing_screen_test.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/test/landing_screen_test.dart)
- Update expected text to match current UI (`추사 1817`).
- Update interaction logic to work with the `Stack` + `SingleChildScrollView` layout instead of `ListView`.

## 2. Lint Cleanup

### [MODIFY] [statistics_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/statistics/statistics_screen.dart)
- Fix underscore usage (`unnecessary_underscores`).
- Correct naming for constant `Weekdays` to `weekdays` (camelCase).

### [MODIFY] [study_screen.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/features/study/study_screen.dart)
- Remove unused local variable `hanja`.

### [MODIFY] [editorial_input_group.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/shared/widgets/editorial_input_group.dart)
- Remove unnecessary casts to improve performance and code clarity.

## 3. Algorithm Refinement (SM-2)

### [MODIFY] [local_repositories.dart](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/lib/core/database/repositories/local_repositories.dart)
- Refine `upsertProgressByHanjaId` to implement a proper SM-2 progression:
  - Update **Interval (I)**, **Easiness Factor (EF)**, and **Repetition (n)** based on user score.
  - Calculate `nextReviewAt` using the formula: `I(n) = I(n-1) * EF`.

## Verification Plan

### Automated Tests
- Run `flutter test` and ensure all 6 files pass.
- Run `flutter analyze` to verify 0 issues remain.

### Manual Verification
- Verify the Landing Screen renders correctly in the app.
- Check the Statistics screen for any broken UI after fixing Lint warnings.
