import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/repository_interfaces.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../core/utils/route_builders.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/filter_pill.dart';
import '../../shared/widgets/hanja_card.dart';

/// 한자 사전 목록 화면.
///
/// 정렬 필터(가나다순, 획수순, 랜덤)를 Pill 형태로 제공한다.
class LearnListScreen extends ConsumerStatefulWidget {
  const LearnListScreen({super.key});

  @override
  ConsumerState<LearnListScreen> createState() => _LearnListScreenState();
}

class _LearnListScreenState extends ConsumerState<LearnListScreen> {
  HanjaListSortOrder _sortOrder = HanjaListSortOrder.readingAscending;
  String _searchQuery = '';
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemsPerPage = ref.watch(dailyGoalProvider).value ?? 10;
    final pageQuery = LearnHanjaPageQuery(
      pageIndex: _currentPage,
      pageSize: itemsPerPage,
      readingQuery: _searchQuery,
      sortOrder: _sortOrder,
    );
    final hanjaPageAsync = ref.watch(learnHanjaPageProvider(pageQuery));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const EditorialTopBar(title: '추사 1817'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
                _currentPage = 0;
              });
            },
            decoration: InputDecoration(
              hintText: '음으로 한자 검색 (예: 가)',
              prefixIcon: const Icon(Icons.search, color: HanjaColors.outline),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _currentPage = 0;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterPill(
                  label: '가나다순',
                  isSelected: _sortOrder == HanjaListSortOrder.readingAscending,
                  onTap: () => setState(() {
                    _sortOrder = HanjaListSortOrder.readingAscending;
                    _currentPage = 0;
                  }),
                ),
                const SizedBox(width: 10),
                FilterPill(
                  label: '획수순',
                  isSelected: _sortOrder == HanjaListSortOrder.strokeCountAscending,
                  onTap: () => setState(() {
                    _sortOrder = HanjaListSortOrder.strokeCountAscending;
                    _currentPage = 0;
                  }),
                ),
                const SizedBox(width: 10),
                FilterPill(
                  label: '랜덤',
                  isSelected: _sortOrder == HanjaListSortOrder.random,
                  onTap: () => setState(() {
                    _sortOrder = HanjaListSortOrder.random;
                    _currentPage = 0;
                  }),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: hanjaPageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                '목록을 불러오지 못했습니다.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (page) {
              if (page.totalCount == 0) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? '학습할 한자가 아직 준비되지 않았습니다.'
                        : '검색 결과가 없습니다.',
                  ),
                );
              }

              final int totalPages =
                  (page.totalCount + itemsPerPage - 1) ~/ itemsPerPage;
              final int maxPage = totalPages > 0 ? totalPages - 1 : 0;
              final int safeCurrentPage = _currentPage.clamp(0, maxPage);
              if (safeCurrentPage != _currentPage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _currentPage = safeCurrentPage);
                });
              }

              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: page.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final hanjaRow = page.items[index];
                        return _LearnedHanjaCardTile(hanjaRow: hanjaRow);
                      },
                    ),
                  ),
                  _buildPaginationControls(
                    safeCurrentPage,
                    totalPages,
                    page.totalCount,
                    itemsPerPage,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(
    int currentPage,
    int totalPages,
    int total,
    int itemsPerPage,
  ) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final rangeStart = currentPage * itemsPerPage + 1;
    final rangeEnd = ((currentPage + 1) * itemsPerPage).clamp(0, total);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: const BoxDecoration(
        color: HanjaColors.surface,
        border: Border(top: BorderSide(color: HanjaColors.surfaceVariant)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: currentPage > 0
                  ? () => setState(() => _currentPage = currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              color: HanjaColors.primary,
              disabledColor: HanjaColors.outlineVariant,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentPage + 1} / $totalPages',
                    style: textTheme.labelLarge?.copyWith(
                      color: HanjaColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$rangeStart–$rangeEnd / $total',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: currentPage < totalPages - 1
                  ? () => setState(() => _currentPage = currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              color: HanjaColors.primary,
              disabledColor: HanjaColors.outlineVariant,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnedHanjaCardTile extends ConsumerWidget {
  const _LearnedHanjaCardTile({required this.hanjaRow});

  final HanjaTableData hanjaRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(hanjaProgressProvider(hanjaRow.id));
    final bool isBookmarked = progressAsync.value?.isBookmarked ?? false;

    return HanjaCard(
      hanja: hanjaRow.character,
      reading: hanjaRow.reading,
      meaning: hanjaRow.meaning,
      totalStrokes: hanjaRow.totalStrokes,
      radical: hanjaRow.radical,
      isBookmarked: isBookmarked,
      onBookmarkTap: () async {
        await ref.read(progressRepositoryProvider).toggleBookmark(hanjaRow.id);
        ref.invalidate(hanjaProgressProvider(hanjaRow.id));
        ref.invalidate(bookmarkedHanjaListProvider);
      },
      onTap: () => context.push(RouteBuilders.hanjaDetail(hanjaRow.id)),
    );
  }
}
