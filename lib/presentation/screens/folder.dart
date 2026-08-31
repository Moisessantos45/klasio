import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/custom_navigator.dart';
import 'package:klasio/config/data.dart';
import 'package:klasio/presentation/providers/folder_notifier.dart';
import 'package:klasio/presentation/screens/folder_content.dart';
import 'package:klasio/presentation/widgets/widgets.dart';

class FolderScreen extends ConsumerStatefulWidget {
  const FolderScreen({super.key});

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    currentIndexNotifier.dispose();
    _isBusyNotifier.dispose();
    super.dispose();
  }

  Future<void> _showCreateFolderModal(int? id) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      final folderNotifier = ref.read(folderNotifierProvider.notifier);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return FolderModalContent(folderNotifier: folderNotifier, id: id);
        },
      );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _refreshFolders() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      _searchController.clear();
      final folderNotifier = ref.read(folderNotifierProvider.notifier);
      await folderNotifier.refresh();
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _searchFolders(String query) async {
    final folderNotifier = ref.read(folderNotifierProvider.notifier);
    await folderNotifier.getAll(query: query);
  }

  Future<void> _onPageChanged(int newPage) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      await ref.read(folderNotifierProvider.notifier).getAll(
            page: newPage,
            query: _searchController.text,
          );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _openFolderContent(dynamic folder) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      await CustomNavigator.pushFade(
        context,
        FolderContentScreen(
          folderId: int.tryParse(folder.id.toString()) ?? 0,
          folderName: folder.name,
          folderColor: colorOptions[folder.indexColor].option,
          folderBgColor: colorOptions[folder.indexColor].bgOption,
        ),
      );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderAsyncValue = ref.watch(folderNotifierProvider);
    return ValueListenableBuilder<bool>(
      valueListenable: _isBusyNotifier,
      builder: (context, isBusy, child) {
        return AbsorbPointer(
          absorbing: isBusy,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape =
                      constraints.maxWidth > constraints.maxHeight;
                  final isTablet =
                      constraints.maxWidth >= 600 &&
                      constraints.maxHeight >= 600 &&
                      constraints.maxWidth < 1024;
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              folderAsyncValue.maybeWhen(
                                data: (data) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Mis Carpetas",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        "${data.pagination.total} materias organizadas",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                orElse: () => const SizedBox.shrink(),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _refreshFolders,
                                    tooltip: "Refrescar",
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: BorderSide(
                                          color: AppColors.border.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _showCreateFolderModal(null),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                    ),
                                    label: const Text("Nueva"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: AppColors.cardShadow,
                              border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.5),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                _searchFolders(value);
                              },
                              decoration: const InputDecoration(
                                hintText: "Buscar materia o clase...",
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      folderAsyncValue.when(
                        data: (data) {
                          final folders = [...data.folders];
                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    isTablet ? 5 : (isLandscape ? 5 : 2),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.95,
                              ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final folder = folders[index];
                                return FolderGridCard(
                                  name: folder.name,
                                  count: folder.captureCount,
                                  color: colorOptions[folder.indexColor].option,
                                  bgColor:
                                      colorOptions[folder.indexColor].bgOption,
                                  icon: iconOptions[folder.indexIcon].option,
                                  onTap: () => _openFolderContent(folder),
                                  onLongPress: () {
                                    _showCreateFolderModal(folder.id);
                                  },
                                );
                              }, childCount: folders.length),
                            ),
                          );
                        },
                        loading: () {
                          return const SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        error: (error, stackTrace) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                "Error al cargar carpetas",
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                          );
                        },
                      ),

                      folderAsyncValue.maybeWhen(
                        data: (data) {
                          if (data.pagination.totalPages <= 1) {
                            return const SliverToBoxAdapter(
                              child: SizedBox.shrink(),
                            );
                          }
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: PaginationControls(
                                currentPage: data.pagination.currentPage,
                                totalPages: data.pagination.totalPages,
                                totalItems: data.pagination.total,
                                onPageChanged: _onPageChanged,
                              ),
                            ),
                          );
                        },
                        orElse: () =>
                            const SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              ),
            ),
            bottomNavigationBar: CustomNavigationBar(
              currentIndexNotifier: currentIndexNotifier,
              onAddTap: () => _showCreateFolderModal(null),
            ),
          ),
        );
      },
    );
  }
}
