import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../shared/widgets/won_go_ji_grid.dart';
import '../study/study_screen.dart';
import '../study/widgets/stroke_animation_player.dart';

/// 한자 상세 정보 화면.
///
/// 탭: [HanjaDetailTab.info] 기본정보 / [HanjaDetailTab.strokes] 획순 /
///     [HanjaDetailTab.words] 관련 단어
///
/// 하단 고정 CTA로 쓰기 연습 화면([StudyScreen])으로 연결된다.
class HanjaDetailScreen extends StatefulWidget {
  const HanjaDetailScreen({
    super.key,
    required this.hanja,
    required this.meaning,
    required this.radical,
    required this.radicalLabel,
    required this.totalStrokes,
  });

  final String hanja;
  final String meaning;
  final String radical;
  final String radicalLabel;
  final int totalStrokes;

  @override
  State<HanjaDetailScreen> createState() => _HanjaDetailScreenState();
}

class _HanjaDetailScreenState extends State<HanjaDetailScreen> {
  HanjaDetailTab _activeTab = HanjaDetailTab.info;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              children: [
                _buildAppBar(context),
                const SizedBox(height: 10),
                _buildHeroSection(textTheme),
                const SizedBox(height: 18),
                _buildTabRow(),
                const SizedBox(height: 18),
                _buildTabContent(textTheme),
              ],
            ),
            _buildStickyWritingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
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
        const Icon(Icons.share, color: HanjaColors.onSurface),
      ],
    );
  }

  Widget _buildHeroSection(TextTheme textTheme) {
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
                      widget.hanja,
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
          widget.meaning,
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

  Widget _buildTabContent(TextTheme textTheme) {
    switch (_activeTab) {
      case HanjaDetailTab.info:
        return _buildInfoTab(textTheme);
      case HanjaDetailTab.strokes:
        return _buildStrokesTab(textTheme);
      case HanjaDetailTab.words:
        return _buildWordsTab(textTheme);
    }
  }

  Widget _buildInfoTab(TextTheme textTheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _InfoCard(label: '부수', value: widget.radical, subLabel: widget.radicalLabel, valueColor: HanjaColors.secondary)),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard(label: '총획', value: '${widget.totalStrokes}', subLabel: '전체 획수', valueColor: HanjaColors.primary)),
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
            '"사람(人)과 규범적 형태가 결합된 자형으로, 옥(圭)처럼 맑고 깨끗한 사람을 아름답다고 한 데서 유래했습니다."',
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

  Widget _buildStrokesTab(TextTheme textTheme) {
    // 佳 한자의 하드코딩 획 좌표 (정규화 0~1). Phase 3에서 SVG 파이프라인 데이터로 교체.
    final List<List<Offset>> strokes = [
      [const Offset(0.30, 0.20), const Offset(0.30, 0.55)],
      [const Offset(0.28, 0.20), const Offset(0.70, 0.20)],
      [const Offset(0.28, 0.38), const Offset(0.70, 0.38)],
      [const Offset(0.55, 0.21), const Offset(0.55, 0.80)],
      [const Offset(0.28, 0.55), const Offset(0.55, 0.55)],
      [const Offset(0.30, 0.60), const Offset(0.70, 0.75)],
      [const Offset(0.28, 0.72), const Offset(0.70, 0.72)],
      [const Offset(0.28, 0.80), const Offset(0.70, 0.80)],
    ];
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
          StrokeAnimationPlayer(hanja: widget.hanja, strokes: strokes),
        ],
      ),
    );
  }

  Widget _buildWordsTab(TextTheme textTheme) {
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
          RelatedWordTile(
            hanja: '${widget.hanja}人',
            meaning: '아름다운 사람',
          ),
          RelatedWordTile(
            hanja: '${widget.hanja}作',
            meaning: '좋은 작품',
          ),
          RelatedWordTile(
            hanja: '${widget.hanja}話',
            meaning: '아름다운 말',
          ),
        ],
      ),
    );
  }

  Widget _buildStickyWritingButton() {
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StudyScreen(
                  hanja: widget.hanja,
                  meaning: widget.meaning,
                ),
              ),
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
