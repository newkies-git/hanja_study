import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';

/// 화면 상단 에디토리얼 브랜드 바.
///
/// 중앙에 이탤릭체 브랜드 타이틀을, 좌/우에 아이콘을 배치하는
/// 전문 아카이브/학술지 지면 스타일의 상단 바.
class EditorialTopBar extends ConsumerWidget {
  const EditorialTopBar({
    super.key,
    required this.title,
    this.onMenuPressed,
  });

  final String title;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.translate(
            offset: const Offset(-8, 0),
            child: IconButton(
              onPressed: onMenuPressed ?? () => Scaffold.maybeOf(context)?.openDrawer(),
              icon: const Icon(Icons.menu),
              color: HanjaColors.neutralIcon,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '메뉴',
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: HanjaColors.primaryContainer,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(8, 0),
            child: PopupMenuButton<int>(
              onSelected: (value) async {
                if (value == 0) {
                  context.push(AppRoutes.planSettings);
                } else if (value == 1) {
                  context.push(AppRoutes.contentSync);
                } else if (value == 2) {
                  context.push(AppRoutes.resetPassword);
                } else if (value == 3) {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.landing);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              offset: const Offset(0, 40),
              icon: const Icon(Icons.account_circle),
              color: Colors.white,
              tooltip: '계정 메뉴',
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 20, color: HanjaColors.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        '학습 설정',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_download_outlined,
                          size: 20, color: HanjaColors.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        '데이터 동기화',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      const Icon(Icons.lock_reset, size: 20, color: HanjaColors.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        '비밀번호 변경',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 20, color: HanjaColors.error),
                      const SizedBox(width: 12),
                      Text(
                        '로그아웃',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: HanjaColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
