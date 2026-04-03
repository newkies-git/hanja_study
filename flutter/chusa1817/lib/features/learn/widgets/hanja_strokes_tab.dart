import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../study/widgets/stroke_animation_player.dart';

/// 획순 보기 탭 화면.
/// 획순 애니메이션을 표시한다.
class HanjaStrokesTab extends ConsumerWidget {
  const HanjaStrokesTab({
    super.key,
    required this.hanjaId,
    required this.hanja,
  });

  final String hanjaId;
  final String hanja;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final strokesAsync = ref.watch(hanjaStrokeVisualProvider(hanjaId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            data: (visual) {
              if (visual.polylineStrokes.isEmpty &&
                  (visual.svgPaths == null || visual.svgPaths!.isEmpty)) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('표시할 획순 데이터가 없습니다.'),
                );
              }
              return StrokeAnimationPlayer(
                key: ValueKey(
                  '$hanjaId:${visual.svgPaths?.length ?? 0}:${visual.polylineStrokes.length}',
                ),
                hanja: hanja,
                visual: visual,
              );
            },
          ),
        ],
      ),
    );
  }
}
