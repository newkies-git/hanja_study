import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../auth/login_screen.dart';
import 'plan_settings_screen.dart';

/// 사용자 프로필 화면.
///
/// 프로필 정보, 학습 계획 설정, 로그아웃 메뉴를 제공한다.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: '내 정보'),
        const SizedBox(height: 14),
        _buildProfileCard(textTheme),
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlanSettingsScreen()),
            ),
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
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}
