import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/hanja_colors.dart';

/// "The Scholar's Editorial" 스타일의 공용 바텀 시트 모달.
///
/// 우아한 Glassmorphism 배경과 하단 핸들, 타이틀 바를 포함한다.
class EditorialModal extends StatelessWidget {
  const EditorialModal({
    super.key,
    required this.title,
    required this.child,
    this.maxHeight = 0.85,
  });

  final String title;
  final Widget child;
  final double maxHeight;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double maxHeight = 0.85,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => EditorialModal(
        title: title,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: maxHeight,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: HanjaColors.surface.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Column(
                children: [
                  // Handle & Header Area
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: HanjaColors.outlineVariant.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Indicator Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: HanjaColors.outlineVariant.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                color: HanjaColors.onSurfaceVariant,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Area
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        child,
                        const SizedBox(height: 40), // Bottom padding for content
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
