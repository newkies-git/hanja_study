import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/hanja_colors.dart';

/// 앱 소개·버전 정보를 보여 주는 About 화면.
class AboutChusa1817Screen extends StatefulWidget {
  const AboutChusa1817Screen({super.key});

  @override
  State<AboutChusa1817Screen> createState() => _AboutChusa1817ScreenState();
}

class _AboutChusa1817ScreenState extends State<AboutChusa1817Screen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo info) {
      if (mounted) setState(() => _packageInfo = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surfaceContainerLow,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: HanjaColors.surfaceContainerLow,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: HanjaColors.onSurface,
            ),
            title: Text(
              'About 추사1817',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'ABOUT',
                  style: textTheme.labelSmall?.copyWith(
                    color: HanjaColors.primary,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '한국 중·고등학교 교육용 기초 한자 학습',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '추사1817은 교육 과정에 맞춘 한자를 체계적으로 익히도록 돕는 앱입니다. '
                  '사전·획순·쓰기 연습·복습·퀴즈·통계로 학습 흐름을 한곳에서 이어 갈 수 있습니다.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: HanjaColors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),
                _SectionCard(
                  title: '주요 기능',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bullet(
                        textTheme,
                        text: '한자 사전 및 상세 정보(부수, 획수, 획순 등)',
                      ),
                      _Bullet(
                        textTheme,
                        text: '획순 보기와 필기 연습',
                      ),
                      _Bullet(
                        textTheme,
                        text: '복습 노트·퀴즈·학습 통계',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: '앱 정보',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        textTheme,
                        label: '앱 이름',
                        value: _packageInfo?.appName ?? '추사1817',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        textTheme,
                        label: '버전',
                        value: _packageInfo == null
                            ? '불러오는 중…'
                            : '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '문의·개선 제안은 앱스토어 리뷰 또는 지원 채널을 이용해 주세요.',
                  style: textTheme.bodySmall?.copyWith(
                    color: HanjaColors.outline,
                    height: 1.45,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HanjaColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.textTheme, {required this.text});

  final TextTheme textTheme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: HanjaColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: HanjaColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
    this.textTheme, {
    required this.label,
    required this.value,
  });

  final TextTheme textTheme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: HanjaColors.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
