import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/custom_navigator.dart';
import 'package:klasio/config/data.dart';
import 'package:klasio/core/service/native_service.dart';
import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/presentation/providers/capture_notifier.dart';
import 'package:klasio/presentation/providers/folder_notifier.dart';
import 'package:klasio/presentation/providers/statistics.dart';
import 'package:klasio/presentation/screens/folder.dart';
import 'package:klasio/presentation/screens/folder_content.dart';
import 'package:klasio/presentation/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);
  final NativeService _nativeService = NativeService();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    currentIndexNotifier.dispose();
    _isBusyNotifier.dispose();
    super.dispose();
  }

  Future<void> _showQuickCaptureModal() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    String? action;
    try {
      action = await QuickCaptureModal.show(context);
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }

    if (!mounted || action == null) return;

    if (action == 'camera') {
      await _takePhotoFromHome();
    } else if (action == 'gallery') {
      await _pickFromGalleryFromHome();
    }
  }

  Future<void> _takePhotoFromHome() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    File? finalFile;
    List<File>? filesToClean;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxHeight: 1000,
        maxWidth: 1000,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final File? result = await _nativeService.optimizeImage(
        pickedFile.path,
        quality: 80,
      );

      finalFile = result ?? file;

      if (!mounted) {
        try {
          if (await file.exists()) await file.delete();
          if (result != null && await result.exists()) await result.delete();
        } catch (_) {}
        return;
      }

      filesToClean = <File>{file, finalFile}.toList();
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }

    if (mounted) {
      await _processCapturedImageForFolder(finalFile, filesToClean);
    }
  }

  Future<void> _pickFromGalleryFromHome() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    File? finalFile;
    List<File>? filesToClean;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1000,
        maxWidth: 1000,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final File? result = await _nativeService.optimizeImage(
        pickedFile.path,
        quality: 80,
      );

      finalFile = result ?? file;

      if (!mounted) {
        try {
          if (await file.exists()) await file.delete();
          if (result != null && await result.exists()) await result.delete();
        } catch (_) {}
        return;
      }

      filesToClean = <File>{file, finalFile}.toList();
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }

    if (mounted) {
      await _processCapturedImageForFolder(finalFile, filesToClean);
    }
  }

  Future<void> _processCapturedImageForFolder(
    File finalFile,
    List<File>? filesToClean,
  ) async {
    final folderDs = ref.read(folderDatasourceProvider);
    final result = await folderDs.getAll(limit: 100);

    if (!mounted) return;

    if (result.folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Primero crea una materia para organizar tus capturas"),
          backgroundColor: AppColors.folderOrange,
        ),
      );
      if (filesToClean != null) {
        for (final f in filesToClean) {
          try {
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }
      }
      return;
    }

    int? targetFolderId;

    if (result.folders.length == 1) {
      targetFolderId = result.folders.first.id;
    } else {
      targetFolderId = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "Selecciona la Materia",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "¿A qué materia pertenece esta foto capturada?",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: result.folders.length,
                    itemBuilder: (ctx, i) {
                      final folder = result.folders[i];
                      final colorOpt =
                          colorOptions[folder.indexColor % colorOptions.length];
                      final iconOpt =
                          iconOptions[folder.indexIcon % iconOptions.length];

                      return ListTile(
                        onTap: () => Navigator.pop(ctx, folder.id),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorOpt.bgOption,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            iconOpt.option,
                            color: colorOpt.option,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          folder.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "${folder.captureCount} capturas",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (targetFolderId == null || !mounted) {
      if (filesToClean != null) {
        for (final f in filesToClean) {
          try {
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }
      }
      return;
    }

    final captureNotifier = ref.read(captureNotifierProvider.notifier);
    final isSaved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return CaptureModalContent(
          folderId: targetFolderId!,
          imageFile: finalFile,
          captureNotifier: captureNotifier,
        );
      },
    );

    if (isSaved == true) {
      ref.read(statisticsNotifierProvider.notifier).refresh();
    } else if (filesToClean != null) {
      for (final tempFile in filesToClean) {
        try {
          if (await tempFile.exists()) await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _showImageDetailModal(Capture capture) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      await showDialog(
        context: context,
        builder: (context) => ImageDetailModal(
          imageUrl: capture.path,
          title: capture.name,
          time: capture.createdAt.toString().split('.')[0],
          folderBg:
              colorOptions[capture.indexBgColor % colorOptions.length].bgOption,
          folderColor:
              colorOptions[capture.indexTextColor % colorOptions.length].option,
        ),
      );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _goToFolders() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      currentIndexNotifier.value = 1;
      await CustomNavigator.pushReplacementFade(context, const FolderScreen());
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _openFolder(dynamic folder) async {
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
    final statisticsAsyncValue = ref.watch(statisticsNotifierProvider);
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
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          Color(0xFF6EE7B7),
                                        ],
                                      ),
                                      boxShadow: AppColors.cardShadow,
                                    ),
                                    child: const Icon(
                                      Icons.auto_stories_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Klasio",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        "Mis capturas de clase",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _showQuickCaptureModal,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  padding: const EdgeInsets.all(10),
                                ),
                                icon: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppColors.textPrimary,
                                  size: 22,
                                ),
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
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          "Captura Rápida",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "¿Tomaste foto a la pizarra?",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Guárdala directo en la materia correspondiente.",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      ElevatedButton.icon(
                                        onPressed: _showQuickCaptureModal,
                                        icon: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 18,
                                        ),
                                        label: const Text("Organizar captura"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              AppColors.primaryDark,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_enhance_rounded,
                                    size: 52,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      statisticsAsyncValue.maybeWhen(
                        data: (data) {
                          final totalCaptures = data.totalCaptures;
                          final totalFolders = data.totalFolders;
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricCard(
                                      title: "Total Capturas",
                                      value: "$totalCaptures",
                                      icon: Icons.photo_library_rounded,
                                      color: AppColors.folderBlue,
                                      bgColor: AppColors.folderBlueLight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMetricCard(
                                      title: "Materias",
                                      value: "$totalFolders",
                                      icon: Icons.folder_copy_rounded,
                                      color: AppColors.folderOrange,
                                      bgColor: AppColors.folderOrangeLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        orElse: () =>
                            const SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Materias Recientes",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: _goToFolders,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  "Ver todas",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      statisticsAsyncValue.maybeWhen(
                        data: (data) {
                          final folderData = [...data.recentFolders.folders];
                          return SliverToBoxAdapter(
                            child: SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                itemCount: folderData.length,
                                itemBuilder: (context, index) {
                                  final folder = folderData[index];
                                  return Container(
                                    width: 190,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: FolderGridCard(
                                      name: folder.name,
                                      count: folder.captureCount,
                                      color: colorOptions[folder.indexColor]
                                          .option,
                                      bgColor: colorOptions[folder.indexColor]
                                          .bgOption,
                                      icon:
                                          iconOptions[folder.indexIcon].option,
                                      onTap: () => _openFolder(folder),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        orElse: () =>
                            const SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Últimas Capturas Guardadas",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      statisticsAsyncValue.maybeWhen(
                        data: (data) {
                          final captureData = [...data.lastCaptures.captures];
                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isTablet
                                        ? 4
                                        : (isLandscape ? 5 : 2),
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.78,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final capture = captureData[index];
                                return _buildCaptureCard(capture);
                              }, childCount: captureData.length),
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
              onAddTap: _showQuickCaptureModal,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard(Capture capture) {
    return InkWell(
      onTap: () => _showImageDetailModal(capture),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    getFileFromPath(capture.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceAlt,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  if (capture.tags.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              colorOptions[capture.indexBgColor %
                                      colorOptions.length]
                                  .bgOption
                                  .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          capture.tags.first.name,
                          style: TextStyle(
                            color:
                                colorOptions[capture.indexTextColor %
                                        colorOptions.length]
                                    .option,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capture.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    capture.createdAt.toString().split('.')[0],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  File getFileFromPath(String path) {
    return File(path);
  }
}
