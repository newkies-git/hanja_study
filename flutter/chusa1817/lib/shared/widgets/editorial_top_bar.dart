import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 화면 상단 에디토리얼 브랜드 바.
///
/// 중앙에 이탤릭체 브랜드 타이틀을, 좌/우에 아이콘을 배치하는
/// The Scholar's Editorial 스타일 앱 바.
class EditorialTopBar extends StatelessWidget {
  const EditorialTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: [
          const Icon(Icons.menu, color: HanjaColors.legacyNeutralIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: HanjaColors.primaryContainer,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.account_circle, color: HanjaColors.legacyNeutralIcon),
        ],
      ),
    );
  }
}
