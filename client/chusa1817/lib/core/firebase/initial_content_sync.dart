import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/hanja_colors.dart';
import 'content_sync_controller.dart';
import 'content_sync_progress.dart';

/// 앱 기동 후 Firestore → 로컬 동기화를 연결할 래퍼.
///
/// 로컬 DB 사전이 완전히 비어있을 경우(한자 0건) 동기화를 완료할 때까지
/// 스플래시 화면을 유지한 후 메인 앱 화면([child])을 연다.
class InitialContentSync extends ConsumerStatefulWidget {
  const InitialContentSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InitialContentSync> createState() => _InitialContentSyncState();
}

class _InitialContentSyncState extends ConsumerState<InitialContentSync> {
  bool _isCheckingOrBlockingSync = true;
  bool _isDbInitiallyEmpty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSyncInitialData();
    });
  }

  Future<void> _checkAndSyncInitialData() async {
    try {
      final int totalCount =
          await ref.read(hanjaRepositoryProvider).fetchTotalCount();
      if (totalCount == 0) {
        if (mounted) {
          setState(() {
            _isDbInitiallyEmpty = true;
          });
        }
        // 사전 데이터가 없을 경우 동기화를 완료할 때까지 대기
        await ref.read(contentSyncControllerProvider.notifier).syncIfNeeded();
      } else {
        // 이미 데이터가 존재하면 즉시 앱 실행 후 백그라운드 동기화
        ref.read(contentSyncControllerProvider.notifier).syncIfNeeded();
      }
    } catch (_) {
      // 오류 발생 시에도 앱 실행 차단을 방지
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOrBlockingSync = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(contentSyncControllerProvider);
    final progress = ref.watch(contentSyncProgressProvider);
    final isSyncing = syncState.isLoading;

    // 로컬 사전이 비어있어 동기화를 기다리는 중일 때 전면 동기화 스플래시 표시
    if (_isCheckingOrBlockingSync && _isDbInitiallyEmpty) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF141218),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: HanjaColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HanjaColors.primary.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '秋史',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: HanjaColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '추사 1817',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '기초 한자 및 획순 데이터를 초기 준비 중입니다...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.white12,
                      color: HanjaColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (progress != null)
                    Text(
                      _syncStageLabel(progress.stage, progress.detail),
                      style: TextStyle(
                        fontSize: 12,
                        color: HanjaColors.primary.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          widget.child,
          if (isSyncing && !_isDbInitiallyEmpty)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LinearProgressIndicator(minHeight: 2),
                  if (progress != null)
                    Material(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.92),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          _syncStageLabel(progress.stage, progress.detail),
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _syncStageLabel(ContentSyncStage stage, String? detail) {
    final String base = switch (stage) {
      ContentSyncStage.idle => '동기화',
      ContentSyncStage.resetLocal => '로컬 테이블 초기화',
      ContentSyncStage.hanjaBasis => '기초 한자 수신 중',
      ContentSyncStage.hanjaExtend => '확장 데이터 수신 중',
      ContentSyncStage.hanjaStroke => '획순 SVG 수신 중',
      ContentSyncStage.hanjaWord => '어휘 데이터 수신 중',
      ContentSyncStage.savingVersion => '버전 저장 중',
      ContentSyncStage.done => '완료',
    };
    if (detail == null || detail.isEmpty) return base;
    return '$base · $detail';
  }
}
