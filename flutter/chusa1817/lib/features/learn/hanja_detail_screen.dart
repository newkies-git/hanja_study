import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';

import 'widgets/hanja_hero_section.dart';
import 'widgets/hanja_tab_bar.dart';
import 'widgets/hanja_info_tab.dart';
import 'widgets/hanja_strokes_tab.dart';
import 'widgets/hanja_words_tab.dart';

/// 한자 상세 정보 화면.
///
/// 탭: [HanjaDetailTab.info] 기본정보 / [HanjaDetailTab.strokes] 획순 /
///     [HanjaDetailTab.words] 관련 단어
///
/// 하단 고정 CTA로 쓰기 연습 화면([StudyScreen])으로 연결된다.
class HanjaDetailScreen extends ConsumerStatefulWidget {
  const HanjaDetailScreen({
    super.key,
    required this.hanjaId,
  });

  final String hanjaId;

  @override
  ConsumerState<HanjaDetailScreen> createState() => _HanjaDetailScreenState();
}

class _HanjaDetailScreenState extends ConsumerState<HanjaDetailScreen> {
  HanjaDetailTab _activeTab = HanjaDetailTab.info;

  @override
  Widget build(BuildContext context) {
    final hanjaAsync = ref.watch(hanjaByIdProvider(widget.hanjaId));

    return hanjaAsync.when(
      loading: () => const Scaffold(
        backgroundColor: HanjaColors.surface,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: HanjaColors.surface,
        body: SafeArea(
          child: Center(
            child: Text(
              '한자 정보를 불러오지 못했습니다.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (hanjaRow) {
        if (hanjaRow == null) {
          return const Scaffold(
            backgroundColor: HanjaColors.surface,
            body: SafeArea(
              child: Center(child: Text('해당 한자를 찾을 수 없습니다.')),
            ),
          );
        }

        final hanja = hanjaRow.character;
        final meaning = '${hanjaRow.meaning} (${hanjaRow.reading})';
        final originText = (hanjaRow.origin ?? '').trim();

        return Scaffold(
          backgroundColor: HanjaColors.surface,
          body: SafeArea(
            child: Stack(
              children: [
                ListView(
                  // 안드로이드 12 이상 등에서 화면 위/아래 끝 도달 시 고무줄처럼 늘어나는(Stretch) 효과를 방지하기 위함
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  children: [
                    _buildAppBar(context, hanjaId: hanjaRow.id),
                    const SizedBox(height: 10),
                    HanjaHeroSection(
                      hanja: hanja,
                      meaning: '${hanjaRow.meaning} (${hanjaRow.reading})',
                      radical: hanjaRow.radical,
                      totalStrokes: hanjaRow.totalStrokes,
                    ),
                    const SizedBox(height: 24),
                    HanjaTabBar(
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                    ),
                    const SizedBox(height: 20),
                    _buildTabContent(
                      hanjaId: hanjaRow.id,
                      hanja: hanja,
                      radical: hanjaRow.radical,
                      radicalLabel: hanjaRow.radicalName,
                      totalStrokes: hanjaRow.totalStrokes,
                      originText: originText,
                    ),
                  ],
                ),
                _buildStickyWritingButton(
                  context,
                  hanjaId: hanjaRow.id,
                  meaning: '${hanjaRow.meaning} (${hanjaRow.reading})',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, {required String hanjaId}) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        Expanded(
          child: Text(
            '추사 1817',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: HanjaColors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        IconButton(
          tooltip: '공유 링크 복사',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: '${AppRoutes.hanjaDetail}/$hanjaId'));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('링크를 복사했습니다.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.share, color: HanjaColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildTabContent({
    required String hanjaId,
    required String hanja,
    required String radical,
    required String radicalLabel,
    required int totalStrokes,
    required String originText,
  }) {
    switch (_activeTab) {
      case HanjaDetailTab.info:
        return HanjaInfoTab(
          radical: radical,
          radicalLabel: radicalLabel,
          totalStrokes: totalStrokes,
          originText: originText,
        );
      case HanjaDetailTab.strokes:
        return HanjaStrokesTab(hanjaId: hanjaId, hanja: hanja);
      case HanjaDetailTab.words:
        return HanjaWordsTab(hanjaId: hanjaId);
    }
  }

  Widget _buildStickyWritingButton(
    BuildContext context, {
    required String hanjaId,
    required String meaning,
  }) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: GradientPrimaryButton(
            label: '쓰기 연습 시작',
            onPressed: () => context.push(
              '${AppRoutes.study}/$hanjaId'
              '?meaning=${Uri.encodeComponent(meaning)}',
            ),
          ),
        ),
      ),
    );
  }
}
