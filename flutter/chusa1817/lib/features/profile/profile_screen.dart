import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/firebase/content_sync_controller.dart';
import '../../core/firebase/content_sync_progress.dart';
import '../../core/firebase/firestore_content_sync.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/app_providers.dart';

/// 사용자 프로필 화면.
///
/// 프로필 정보, 학습 계획 설정, 로그아웃 메뉴를 제공한다.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final totalHanjaCount = ref.watch(totalHanjaCountProvider);
    final authState = ref.watch(authStateChangesProvider);
    final authUser = authState.asData?.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: '내 정보'),
        const SizedBox(height: 14),
        _buildProfileCard(textTheme, authUser),
        const SizedBox(height: 14),
        _buildHanjaCountCard(textTheme, totalHanjaCount),
        const SizedBox(height: 14),
        _buildMenuCard(context, textTheme, ref),
      ],
    );
  }

  Widget _buildProfileCard(TextTheme textTheme, User? authUser) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: HanjaColors.primaryFixed,
            child: Icon(Icons.person, color: HanjaColors.primaryContainer),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authUser?.displayName ?? (authUser?.isAnonymous == false ? '추사 1817 학습자' : '게스트 사용자'), 
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                (authUser?.isAnonymous ?? true) ? '데이터가 기기에 임시 저장됩니다' : (authUser?.email ?? '이메일 정보 없음'),
                style: textTheme.bodyMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHanjaCountCard(TextTheme textTheme, AsyncValue<int> count) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HanjaColors.secondary, HanjaColors.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: HanjaColors.secondary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '학습 가능 한자',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                count.when(
                  data: (value) => Text(
                    '$value 자',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  error: (error, _) => Text(
                    '오류',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.storage_outlined,
            color: Colors.white.withValues(alpha: 0.3),
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, TextTheme textTheme, WidgetRef ref) {
    final syncState = ref.watch(contentSyncControllerProvider);
    final syncProgress = ref.watch(contentSyncProgressProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit_calendar,
              color: HanjaColors.primaryContainer,
            ),
            title: Text(
              '학습 계획 설정',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '나만의 학습 리듬을 설정하세요',
              style: textTheme.bodyMedium?.copyWith(
                color: HanjaColors.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.planSettings),
          ),
          Divider(
            height: 1,
            color: HanjaColors.outlineVariant.withValues(alpha: 0.15),
          ),
          ListTile(
            leading: syncState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_download_outlined, color: HanjaColors.primary),
            title: Text(
              '한자 데이터 동기화',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Firestore → 기기 저장소 (hanja_basis·extend·stroke·word)',
              style: textTheme.bodySmall?.copyWith(
                color: HanjaColors.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await ref
                  .read(contentSyncControllerProvider.notifier)
                  .syncFromFirestoreNow();
              if (!context.mounted) return;
              final async = ref.read(contentSyncControllerProvider);
              final String message;
              if (async.hasError) {
                final Object? err = async.error;
                message = kDebugMode && err != null
                    ? '동기화 실패: $err'
                    : '동기화에 실패했습니다.';
              } else {
                final ContentSyncResult? result = async.maybeWhen(
                  data: (v) => v,
                  orElse: () => null,
                );
                message = result != null
                    ? '동기화 완료: $result'
                    : '동기화가 완료되었습니다.';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildFirestoreSyncProgress(
            textTheme,
            syncProgress,
            syncState.isLoading,
          ),
          Divider(
            height: 1,
            color: HanjaColors.outlineVariant.withValues(alpha: 0.15),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: HanjaColors.tertiary),
            title: Text(
              '로그아웃',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.landing);
            },
          ),
        ],
      ),
    );
  }

  /// Firestore → 로컬 동기화 시 컬렉션(단계)별 진행 상태.
  Widget _buildFirestoreSyncProgress(
    TextTheme textTheme,
    ContentSyncProgressState? progress,
    bool isSyncLoading,
  ) {
    if (!isSyncLoading && progress == null) {
      return const SizedBox.shrink();
    }

    const rows = <(ContentSyncStage, String)>[
      (ContentSyncStage.resetLocal, '로컬 테이블 초기화'),
      (ContentSyncStage.hanjaBasis, 'hanja_basis'),
      (ContentSyncStage.hanjaExtend, 'hanja_extend'),
      (ContentSyncStage.hanjaStroke, 'hanja_stroke'),
      (ContentSyncStage.hanjaWord, 'hanja_word'),
      (ContentSyncStage.savingVersion, 'config/content 버전 저장'),
    ];

    final ContentSyncStage effective = progress?.stage ??
        (isSyncLoading ? ContentSyncStage.resetLocal : ContentSyncStage.idle);
    final String? detail = progress?.detail;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '동기화 진행',
            style: textTheme.labelLarge?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...rows.map((e) {
            final ContentSyncStage rowStage = e.$1;
            final String label = e.$2;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _syncStageLeadingIcon(effective, rowStage),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (detail != null && effective == rowStage)
                          Text(
                            detail,
                            style: textTheme.bodySmall?.copyWith(
                              color: HanjaColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _syncStageLeadingIcon(
    ContentSyncStage current,
    ContentSyncStage row,
  ) {
    const double size = 18;
    if (current == ContentSyncStage.idle) {
      return Icon(
        Icons.radio_button_unchecked,
        size: size,
        color: HanjaColors.outlineVariant,
      );
    }
    if (current == ContentSyncStage.done || current.index > row.index) {
      return Icon(
        Icons.check_circle,
        size: size,
        color: HanjaColors.secondary,
      );
    }
    if (current == row) {
      return const SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(
      Icons.radio_button_unchecked,
      size: size,
      color: HanjaColors.outlineVariant,
    );
  }
}
