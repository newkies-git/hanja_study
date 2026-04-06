import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/firebase/content_sync_controller.dart';
import '../../core/firebase/content_sync_progress.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/content_sync_progress_section.dart';
import '../../shared/widgets/gradient_primary_button.dart';

/// Firestore → 기기 한자 콘텐츠 수동 동기화 전용 화면.
class ContentSyncScreen extends ConsumerWidget {
  const ContentSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final syncState = ref.watch(contentSyncControllerProvider);
    final syncProgress = ref.watch(contentSyncProgressProvider);
    final isLoading = syncState.isLoading;

    return Scaffold(
      backgroundColor: HanjaColors.surfaceContainerLow,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: HanjaColors.surfaceContainerLow,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '데이터 동기화',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: HanjaColors.primaryContainer,
              ),
            ),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Firestore에 있는 한자·획순·단어 데이터를 이 기기의 로컬 DB로 가져옵니다. '
                  'Wi-Fi 환경에서 실행하는 것을 권장합니다.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: HanjaColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_download_outlined,
                            color: HanjaColors.primaryContainer,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '한자 데이터 동기화',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'hanja_basis · hanja_extend · hanja_stroke · hanja_word',
                        style: textTheme.bodySmall?.copyWith(
                          color: HanjaColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ContentSyncProgressSection(
                        progress: syncProgress,
                        isSyncLoading: isLoading,
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: isLoading ? 0.55 : 1,
                        child: IgnorePointer(
                          ignoring: isLoading,
                          child: GradientPrimaryButton(
                            label: isLoading ? '동기화 중…' : '지금 동기화',
                            onPressed: () async {
                              if (ref.read(contentSyncControllerProvider).isLoading) {
                                return;
                              }
                              final outcome = await ref
                                  .read(contentSyncControllerProvider.notifier)
                                  .syncFromFirestoreNow();
                              if (!context.mounted) return;
                              final async = ref.read(contentSyncControllerProvider);
                              final String message;
                              if (async.hasError) {
                                final err = async.error;
                                message = kDebugMode && err != null
                                    ? '동기화 실패: $err'
                                    : '동기화에 실패했습니다.';
                              } else if (outcome?.remoteContentVersion == -1) {
                                message = '이미 최신 상태입니다. (변경사항 없음)';
                              } else if (outcome != null) {
                                message = '동기화가 완료되었습니다.';
                              } else {
                                message = '동기화가 완료되었습니다.';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
