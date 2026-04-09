import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/filter_pill.dart';
import '../../shared/widgets/hanja_card.dart';
import '../../core/router/app_router.dart';
import '../../core/database/app_database.dart';

/// 한자 사전 목록 화면.
///
/// 정렬 필터(가나다순, 획수순, 랜덤)를 Pill 형태로 제공한다.
class LearnListScreen extends ConsumerStatefulWidget {
  const LearnListScreen({super.key});

  @override
  ConsumerState<LearnListScreen> createState() => _LearnListScreenState();
}

class _LearnListScreenState extends ConsumerState<LearnListScreen> {
  _LearnSort _sort = _LearnSort.koreanOrder;
  String _searchQuery = '';
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();

  // 사전 화면의 페이지 크기는 학습 목표와 무관하게 고정
  static const int _itemsPerPage = 30;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hanjaListAsync = ref.watch(learnHanjaListProvider);

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
                _currentPage = 0; // 검색어 변경 시 첫 페이지로
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
                  isSelected: _sort == _LearnSort.koreanOrder,
                  onTap: () => setState(() => _sort = _LearnSort.koreanOrder),
                ),
                const SizedBox(width: 10),
                FilterPill(
                  label: '획수순',
                  isSelected: _sort == _LearnSort.strokeCount,
                  onTap: () => setState(() => _sort = _LearnSort.strokeCount),
                ),
                const SizedBox(width: 10),
                FilterPill(
                  label: '랜덤',
                  isSelected: _sort == _LearnSort.random,
                  onTap: () => setState(() => _sort = _LearnSort.random),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: hanjaListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                '목록을 불러오지 못했습니다.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (hanjaList) {
              if (hanjaList.isEmpty) {
                return const Center(
                  child: Text('학습할 한자가 아직 준비되지 않았습니다.'),
                );
              }

              final List<HanjaTableData> filtered = _searchQuery.isEmpty 
                  ? List.of(hanjaList) 
                  : hanjaList.where((h) => h.reading.contains(_searchQuery)).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('검색 결과가 없습니다.'));
              }

              final List<HanjaTableData> sorted = filtered;
              switch (_sort) {
                case _LearnSort.koreanOrder:
                  sorted.sort((a, b) => a.reading.compareTo(b.reading));
                case _LearnSort.strokeCount:
                  sorted.sort((a, b) => a.totalStrokes.compareTo(b.totalStrokes));
                case _LearnSort.random:
                  final seed = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 30);
                  sorted.shuffle(Random(seed));
              }

              final int totalPages =
                  (sorted.length + _itemsPerPage - 1) ~/ _itemsPerPage;

              // 검색어 변경 등으로 현재 페이지가 범위를 벗어날 수 있으므로 안전 처리
              final int maxPage = totalPages > 0 ? totalPages - 1 : 0;
              final int safeCurrentPage = _currentPage.clamp(0, maxPage);

              final int startIndex = safeCurrentPage * _itemsPerPage;
              final int endIndex =
                  (startIndex + _itemsPerPage).clamp(0, sorted.length);
              final List<HanjaTableData> paginatedList =
                  sorted.sublist(startIndex, endIndex);

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
                      itemCount: paginatedList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final hanjaRow = paginatedList[index];
                        final hanjaId = hanjaRow.id;
                        final hanja = hanjaRow.character;
                        final meaning = hanjaRow.meaning;

                        return HanjaCard(
                          hanja: hanja,
                          reading: hanjaRow.reading,
                          meaning: meaning,
                          totalStrokes: hanjaRow.totalStrokes,
                          radical: hanjaRow.radical,
                          onTap: () => context.push(
                            '${AppRoutes.hanjaDetail}/$hanjaId'
                            '?meaning=${Uri.encodeComponent(meaning)}'
                            '&radical=${Uri.encodeComponent(hanjaRow.radical)}'
                            '&radicalLabel=${Uri.encodeComponent('')}'
                            '&totalStrokes=${hanjaRow.totalStrokes}',
                          ),
                        );
                      },
                    ),
                  ),
                  _buildPaginationControls(safeCurrentPage, totalPages, sorted.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(int currentPage, int totalPages, int total) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final rangeStart = currentPage * _itemsPerPage + 1;
    final rangeEnd = ((currentPage + 1) * _itemsPerPage).clamp(0, total);

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
                    '${currentPage + 1} / $totalPages 페이지',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '$rangeStart–$rangeEnd / $total자',
                    style: textTheme.labelSmall?.copyWith(
                      color: HanjaColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
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

enum _LearnSort { koreanOrder, strokeCount, random }
