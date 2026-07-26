import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/ghost_divider.dart';
import '../../shared/widgets/glass_card.dart';

/// 사용자 프로필 통합 관리 화면 (`/profile`).
///
/// 계정 정보(이메일/익명), 학습 설정, 데이터 동기화, 로그아웃 기능을 제공한다.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authStateChangesProvider).value;
    final isNonAnon = ref.watch(isNonAnonymousUserProvider);
    final totalCountAsync = ref.watch(totalHanjaCountProvider);
    final bookmarkedAsync = ref.watch(bookmarkedHanjaListProvider);

    return Scaffold(
      backgroundColor: HanjaColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: HanjaColors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '내 프로필',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: HanjaColors.primaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 계정 카드
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: HanjaColors.primaryContainer.withValues(alpha: 0.1),
                    child: Icon(
                      isNonAnon ? Icons.person_rounded : Icons.person_outline_rounded,
                      size: 32,
                      color: HanjaColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isNonAnon ? (user?.email ?? '회원 계정') : '익명 사용자',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isNonAnon ? '이메일 로그인 회원' : '익명 사용자로 이용 중입니다.',
                          style: textTheme.bodySmall?.copyWith(
                            color: HanjaColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 학습 현황 요약
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '학습 요약',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: HanjaColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: '전체 한자',
                        value: totalCountAsync.value?.toString() ?? '-',
                      ),
                      _StatColumn(
                        label: '즐겨찾기',
                        value: bookmarkedAsync.value?.length.toString() ?? '-',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 메뉴 리스트
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: HanjaColors.primary),
                    title: const Text('학습 설정 (목표 & 시간)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.planSettings),
                  ),
                  const GhostDivider(),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined, color: HanjaColors.secondary),
                    title: const Text('데이터 동기화 (Firestore)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.contentSync),
                  ),
                  const GhostDivider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: HanjaColors.onSurfaceVariant),
                    title: const Text('추사 1817 정보'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 로그아웃 버튼
            if (isNonAnon)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: HanjaColors.error,
                  side: const BorderSide(color: HanjaColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('로그아웃'),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (!context.mounted) return;
                  context.go(AppRoutes.landing);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: HanjaColors.primaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: HanjaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
