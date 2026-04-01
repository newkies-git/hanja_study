import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/app_providers.dart';

/// 사용자 프로필 화면.
///
/// 프로필 정보, 학습 계획 설정, 로그아웃 메뉴를 제공한다.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final totalHanjaCount = ref.watch(totalHanjaCountProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: '내 정보'),
        const SizedBox(height: 14),
        _buildProfileCard(textTheme),
        const SizedBox(height: 14),
        _buildHanjaCountCard(textTheme, totalHanjaCount),
        const SizedBox(height: 14),
        _buildMenuCard(context, textTheme),
      ],
    );
  }

  Widget _buildProfileCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: HanjaColors.primaryFixed,
            child: Icon(Icons.person, color: HanjaColors.primaryContainer),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scholar', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'scholar@example.com',
                style: textTheme.bodyMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHanjaCountCard(TextTheme textTheme, AsyncValue<int> count) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HanjaColors.secondary, HanjaColors.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: HanjaColors.secondary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '학습 가능 한자',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                count.when(
                  data: (value) => Text(
                    '$value 자',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  error: (error, _) => Text(
                    '오류',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.storage_outlined,
            color: Colors.white.withValues(alpha: 0.3),
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit_calendar,
              color: HanjaColors.primaryContainer,
            ),
            title: Text(
              '학습 계획 설정',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '나만의 학습 리듬을 설정하세요',
              style: textTheme.bodyMedium?.copyWith(
                color: HanjaColors.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.planSettings),
          ),
          Divider(
            height: 1,
            color: HanjaColors.outlineVariant.withValues(alpha: 0.15),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: HanjaColors.tertiary),
            title: Text(
              '로그아웃',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.landing),
          ),
        ],
      ),
    );
  }
}
