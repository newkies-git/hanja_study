import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';
import '../../../core/database/app_database.dart';

/// '오늘의 학습' 한자 목록 그리드.
///
/// 한 줄에 5글자씩 표시하며 상태에 따라 스타일을 변경한다.
/// - completed: Dim (낮은 투명도)
/// - learning: Glow (테두리 애니메이션)
/// - planned: 기본 스타일
class TodayHanjaGrid extends StatelessWidget {
  const TodayHanjaGrid({
    super.key,
    required this.hanjaList,
    this.onTap,
  });

  final List<(HanjaTableData, String)> hanjaList;
  final Function(String hanjaId, String meaning)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemSize = (constraints.maxWidth - (4 * 10)) / 5;
          
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hanjaList.map((item) {
              final hanja = item.$1;
              final status = item.$2;
              
              return _HanjaGridItem(
                character: hanja.character,
                status: status,
                size: itemSize,
                onTap: () => onTap?.call(
                  hanja.id,
                  '${hanja.meaning} ${hanja.reading}',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _HanjaGridItem extends StatefulWidget {
  const _HanjaGridItem({
    required this.character,
    required this.status,
    required this.size,
    required this.onTap,
  });

  final String character;
  final String status;
  final double size;
  final VoidCallback onTap;

  @override
  State<_HanjaGridItem> createState() => _HanjaGridItemState();
}

class _HanjaGridItemState extends State<_HanjaGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.status == 'learning') {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_HanjaGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == 'learning' && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.status != 'learning' && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.status == 'completed';
    final bool isLearning = widget.status == 'learning';

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLearning
                    ? HanjaColors.primary.withValues(alpha: 0.3 + (0.7 * _glowAnimation.value))
                    : (isCompleted ? Colors.transparent : HanjaColors.surfaceContainerHigh),
                width: isLearning ? 2.5 : 1,
              ),
              boxShadow: isLearning
                  ? [
                      BoxShadow(
                        color: HanjaColors.primary.withValues(alpha: 0.2 * _glowAnimation.value),
                        blurRadius: 8 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      )
                    ]
                  : (isCompleted ? null : const [
                      BoxShadow(
                        color: HanjaColors.shadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ]),
            ),
            child: Center(
              child: Opacity(
                opacity: isCompleted ? 0.35 : 1.0,
                child: Text(
                  widget.character,
                  style: TextStyle(
                    fontSize: widget.size * 0.45,
                    fontFamily: 'NotoSerifKR',
                    fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w900,
                    color: isCompleted
                        ? HanjaColors.onSurfaceVariant
                        : HanjaColors.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
