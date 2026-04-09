import 'package:flutter/material.dart';
import '../../../core/constants/study_status.dart';
import '../../../core/theme/hanja_colors.dart';
import '../../../core/database/app_database.dart';

/// '오늘의 학습' 한자 목록 그리드.
///
/// 한 줄에 5글자씩 표시하며 상태에 따라 스타일을 변경한다.
/// - completed: 민트(secondaryContainer) — 완료·성공 의미, 예정(흰)·학습중(주황)과 구분
/// - learning: Glow (테두리 애니메이션)
/// - planned: 기본 스타일
class TodayHanjaGrid extends StatelessWidget {
  const TodayHanjaGrid({
    super.key,
    required this.hanjaList,
    this.onTap,
  });

  final List<(HanjaTableData, String, bool)> hanjaList;
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
              final isBookmarked = item.$3;
              
              return _HanjaGridItem(
                character: hanja.character,
                status: status,
                isBookmarked: isBookmarked,
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
    required this.isBookmarked,
    required this.size,
    required this.onTap,
  });

  final String character;
  final String status;
  final bool isBookmarked;
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

    if (widget.status == StudyStatus.learning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_HanjaGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == StudyStatus.learning && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.status != StudyStatus.learning && _controller.isAnimating) {
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
    final bool isCompleted = widget.status == StudyStatus.mastered || widget.status == StudyStatus.completed;
    final bool isLearning = widget.status == StudyStatus.learning;

    Color backgroundColor;
    Color textColor;
    
    if (isCompleted) {
      // 완료: 회색(surfaceVariant)은 홈 배경과 대비가 약함 → 성공 의미의 민트(secondaryContainer)
      backgroundColor = HanjaColors.secondaryContainer;
      textColor = HanjaColors.onSurface;
    } else if (isLearning) {
      backgroundColor = HanjaColors.statusWarningContainer; // 파스텔 주황색
      textColor = Colors.black87; // 검정색 유지
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87; // 검정색 유지
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(widget.size / 2), // 완벽한 원형 (이미지 준수)
                  boxShadow: (isCompleted || isLearning)
                      ? [] // 완료된/학습중인 항목은 평면으로 표시 (이미지 준수)
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    widget.character,
                    style: TextStyle(
                      fontSize: widget.size * 0.48,
                      fontFamily: 'NotoSerifKR',
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
