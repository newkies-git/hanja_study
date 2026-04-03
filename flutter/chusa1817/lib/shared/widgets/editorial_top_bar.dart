import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';

/// 화면 상단 에디토리얼 브랜드 바.
///
/// 중앙에 이탤릭체 브랜드 타이틀을, 좌/우에 아이콘을 배치하는
/// 전문 아카이브/학술지 지면 스타일의 상단 바.
class EditorialTopBar extends StatelessWidget {
  const EditorialTopBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onAvatarPressed,
  });

  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.translate(
            offset: const Offset(-8, 0),
            child: IconButton(
              onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: HanjaColors.primaryContainer,
                  ),
            ),
          ),
          Transform.translate(
            offset: const Offset(8, 0),
            child: IconButton(
              onPressed: onAvatarPressed ?? () => context.go('${AppRoutes.home}?tab=4'),
              icon: const Icon(Icons.account_circle),
              color: HanjaColors.neutralIcon,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '프로필',
            ),
          ),
        ],
      ),
    );
  }
}
