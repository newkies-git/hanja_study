import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../shared/widgets/won_go_ji_grid.dart';
import '../../core/router/app_router.dart';
import '../study/widgets/stroke_animation_player.dart';

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
    final TextTheme textTheme = Theme.of(context).textTheme;
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  children: [
                    _buildAppBar(context, hanjaId: hanjaRow.id),
                    const SizedBox(height: 10),
                    _buildHeroSection(textTheme, hanja: hanja, meaning: meaning),
                    const SizedBox(height: 18),
                    _buildTabRow(),
                    const SizedBox(height: 18),
                    _buildTabContent(
                      textTheme,
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
                  meaning: meaning,
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

  Widget _buildHeroSection(
    TextTheme textTheme, {
    required String hanja,
    required String meaning,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 320,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: WonGoJiGrid(opacity: 0.12)),
                  Center(
                    child: Text(
                      hanja,
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 120,
                        color: HanjaColors.primary,
                        height: 1,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 14,
                    right: 14,
                    child: Icon(Icons.star, color: HanjaColors.tertiary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '뜻과 음',
          style: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF9A9DA0),
            letterSpacing: 3.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          meaning,
          style: textTheme.displaySmall?.copyWith(
            fontSize: 40,
            color: HanjaColors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildTabRow() {
    return Row(
      children: [
        _DetailTab(
          label: '기본 정보',
          isSelected: _activeTab == HanjaDetailTab.info,
          onTap: () => setState(() => _activeTab = HanjaDetailTab.info),
        ),
        const Spacer(),
        _DetailTab(
          label: '획순 보기',
          isSelected: _activeTab == HanjaDetailTab.strokes,
          onTap: () => setState(() => _activeTab = HanjaDetailTab.strokes),
        ),
        const Spacer(),
        _DetailTab(
          label: '관련 단어',
          isSelected: _activeTab == HanjaDetailTab.words,
          onTap: () => setState(() => _activeTab = HanjaDetailTab.words),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    TextTheme textTheme, {
    required String hanjaId,
    required String hanja,
    required String radical,
    required String radicalLabel,
    required int totalStrokes,
    required String originText,
  }) {
    switch (_activeTab) {
      case HanjaDetailTab.info:
        return _buildInfoTab(
          textTheme,
          radical: radical,
          radicalLabel: radicalLabel,
          totalStrokes: totalStrokes,
          originText: originText,
        );
      case HanjaDetailTab.strokes:
        return _buildStrokesTab(textTheme, hanjaId: hanjaId, hanja: hanja);
      case HanjaDetailTab.words:
        return _buildWordsTab(textTheme, hanjaId: hanjaId);
    }
  }

  Widget _buildInfoTab(
    TextTheme textTheme, {
    required String radical,
    required String radicalLabel,
    required int totalStrokes,
    required String originText,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: '부수',
                value: radical,
                subLabel: radicalLabel,
                valueColor: HanjaColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                label: '총획',
                value: '$totalStrokes',
                subLabel: '전체 획수',
                valueColor: HanjaColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: HanjaColors.outlineVariant.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            originText.isNotEmpty
                ? originText
                : '아직 유래 설명이 준비되지 않았습니다.',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrokesTab(
    TextTheme textTheme, {
    required String hanjaId,
    required String hanja,
  }) {
    final strokesAsync = ref.watch(hanjaStrokePointsProvider(hanjaId));
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '획순 보기',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          strokesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '획순 데이터를 불러오지 못했습니다.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (strokes) {
              final usable = strokes.where((s) => s.length >= 2).toList();
              if (usable.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('표시할 획순 데이터가 없습니다.'),
                );
              }
              return StrokeAnimationPlayer(hanja: hanja, strokes: usable);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordsTab(TextTheme textTheme, {required String hanjaId}) {
    final wordsAsync = ref.watch(hanjaWordsProvider(hanjaId));
    final idiomsAsync = ref.watch(hanjaIdiomsProvider(hanjaId));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관련 단어',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (wordsAsync.isLoading || idiomsAsync.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (wordsAsync.hasError || idiomsAsync.hasError)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '관련 단어를 불러오지 못했습니다.\n'
                '${wordsAsync.error ?? ''}\n'
                '${idiomsAsync.error ?? ''}',
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            ...((wordsAsync.value ?? const []).map(
              (w) => RelatedWordTile(
                hanja: w.word,
                meaning: '${w.meaning} (${w.reading})'.trim(),
              ),
            )),
            ...((idiomsAsync.value ?? const []).map(
              (i) => RelatedWordTile(
                hanja: i.idiom,
                meaning: '${i.meaning} (${i.reading})'.trim(),
              ),
            )),
            if ((wordsAsync.value?.isEmpty ?? true) &&
                (idiomsAsync.value?.isEmpty ?? true))
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('표시할 단어/성어 데이터가 없습니다.'),
              ),
          ],
        ],
      ),
    );
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

/// 한자 상세 화면 탭 열거형.
enum HanjaDetailTab { info, strokes, words }

/// 탭 선택 버튼.
class _DetailTab extends StatelessWidget {
  const _DetailTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = isSelected
        ? HanjaColors.primaryContainer
        : const Color(0xFF9A9DA0);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? HanjaColors.primaryContainer
                  : HanjaColors.outlineVariant.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: foregroundColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// 정보 카드 (부수, 총획 등 단일 속성 표시).
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HanjaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9A9DA0),
              letterSpacing: 2.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subLabel,
            style: textTheme.bodySmall?.copyWith(
              color: HanjaColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 관련 단어 목록 타일.
///
/// 기존 private `_RelatedWordTile`을 public으로 승격하여
/// 단어 목록 화면(Phase 2)에서도 재사용 가능하게 한다.
class RelatedWordTile extends StatelessWidget {
  const RelatedWordTile({
    super.key,
    required this.hanja,
    required this.meaning,
  });

  final String hanja;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HanjaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              hanja,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                meaning,
                style: textTheme.bodyMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: HanjaColors.outline),
          ],
        ),
      ),
    );
  }
}
