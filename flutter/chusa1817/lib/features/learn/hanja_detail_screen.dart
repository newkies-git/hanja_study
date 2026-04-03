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
  Offset? _fabPosition;

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

        // ── 진도 및 북마크 상태 구독 ──────────────────────────────────────────
        final progressAsync = ref.watch(hanjaProgressProvider(hanjaRow.id));
        final bool isBookmarked = progressAsync.value?.isBookmarked ?? false;

        return Scaffold(
          backgroundColor: HanjaColors.surface,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 초기 위치 설정 (우하단)
                if (_fabPosition == null) {
                  _fabPosition = Offset(
                    constraints.maxWidth - 100, // 대략적인 버튼 폭 고려
                    constraints.maxHeight - 80,
                  );
                }

                return Stack(
                  children: [
                    ListView(
                      // 안드로이드 12 이상 등에서 화면 위/아래 끝 도달 시 고무줄처럼 늘어나는(Stretch) 효과를 방지하기 위함
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                      children: [
                        _buildAppBar(context, hanjaId: hanjaRow.id),
                        const SizedBox(height: 10),
                        HanjaHeroSection(
                          hanja: hanja,
                          meaning: '${hanjaRow.meaning} (${hanjaRow.reading})',
                          radical: hanjaRow.radical,
                          totalStrokes: hanjaRow.totalStrokes,
                          isBookmarked: isBookmarked,
                          onBookmarkToggle: () async {
                            await ref.read(progressRepositoryProvider).toggleBookmark(hanjaRow.id);
                            // 상태 갱신
                            ref.invalidate(hanjaProgressProvider(hanjaRow.id));
                            // 가벼운 진동 피드백 (선택사항)
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(height: 14),
                        HanjaTabBar(
                          activeTab: _activeTab,
                          onTabChanged: (tab) => setState(() => _activeTab = tab),
                        ),
                        const SizedBox(height: 10),
                        _buildTabContent(
                          hanjaId: hanjaRow.id,
                          hanja: hanja,
                          originText: originText,
                        ),
                      ],
                    ),
                    // ── 자유롭게 이동 가능한 FAB ────────────────────────────────
                    Positioned(
                      left: _fabPosition!.dx,
                      top: _fabPosition!.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            // 이동 거리 합산
                            _fabPosition = _fabPosition! + details.delta;
                            
                            // 경계값 처리 (화면 밖으로 나가지 않게)
                            final double x = _fabPosition!.dx.clamp(0.0, constraints.maxWidth - 80); // 버튼 예상 최소 폭
                            final double y = _fabPosition!.dy.clamp(0.0, constraints.maxHeight - 60); // 버튼 예상 최소 높이
                            _fabPosition = Offset(x, y);
                          });
                        },
                        child: _buildFAB(
                          context,
                          hanjaId: hanjaRow.id,
                          meaning: '${hanjaRow.meaning} (${hanjaRow.reading})',
                        ),
                      ),
                    ),
                  ],
                );
              },
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
        const SizedBox(width: 48), // 타이틀 중앙 정렬 유지를 위한 더미 공간
      ],
    );
  }

  Widget _buildTabContent({
    required String hanjaId,
    required String hanja,
    required String originText,
  }) {
    switch (_activeTab) {
      case HanjaDetailTab.info:
        return HanjaInfoTab(
          originText: originText,
        );
      case HanjaDetailTab.strokes:
        return HanjaStrokesTab(hanjaId: hanjaId, hanja: hanja);
      case HanjaDetailTab.words:
        return HanjaWordsTab(hanjaId: hanjaId);
    }
  }

  Widget _buildFAB(
    BuildContext context, {
    required String hanjaId,
    required String meaning,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, right: 4),
      child: FloatingActionButton.extended(
        onPressed: () => context.push(
          '${AppRoutes.study}/$hanjaId'
          '?meaning=${Uri.encodeComponent(meaning)}',
        ),
        backgroundColor: HanjaColors.primary,
        elevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            'assets/images/brush_icon.png',
            fit: BoxFit.contain,
          ),
        ),
        label: Text(
          '쓰기',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}
