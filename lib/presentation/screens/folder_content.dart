import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/data.dart';
import 'package:klasio/core/service/native_service.dart';
import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/presentation/providers/capture_notifier.dart';
import 'package:klasio/presentation/providers/tag_notifier.dart';
import 'package:klasio/presentation/widgets/widgets.dart';

class FolderContentScreen extends ConsumerStatefulWidget {
  final int folderId;
  final String folderName;
  final Color folderColor;
  final Color folderBgColor;

  const FolderContentScreen({
    super.key,
    required this.folderId,
    required this.folderName,
    this.folderColor = AppColors.folderBlue,
    this.folderBgColor = AppColors.folderBlueLight,
  });

  @override
  ConsumerState<FolderContentScreen> createState() =>
      _FolderContentScreenState();
}

class _FolderContentScreenState extends ConsumerState<FolderContentScreen> {
  int _selectedFilter = 0;
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);
  final NativeService _nativeService = NativeService();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _isBusyNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadCaptures() async {
    if (widget.folderId <= 0) {
      Navigator.pop(context);
      return;
    }

    final captureNotifier = ref.read(captureNotifierProvider.notifier);
    await captureNotifier.getAll(folderId: widget.folderId, tagId: 0);
  }

  Future<void> _showCreateCaptureModal({
    File? imageFile,
    String? imagePath,
    int? captureId,
    List<File>? tempFilesToDeleteOnCancel,
  }) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    bool? isSaved;
    try {
      final captureNotifier = ref.read(captureNotifierProvider.notifier);
      isSaved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return CaptureModalContent(
            folderId: widget.folderId,
            captureId: captureId,
            imageFile: imageFile,
            imagePath: imagePath,
            captureNotifier: captureNotifier,
          );
        },
      );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }

    if (isSaved != true && tempFilesToDeleteOnCancel != null) {
      for (final tempFile in tempFilesToDeleteOnCancel) {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          debugPrint("Error al eliminar archivo temporal de captura: $e");
        }
      }
    }
  }

  Future<void> _takePhoto() async {
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

      if (pickedFile == null) {
        return;
      }

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
      await _showCreateCaptureModal(
        imageFile: finalFile,
        tempFilesToDeleteOnCancel: filesToClean,
      );
    }
  }

  Future<void> _pickFromGallery() async {
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

      if (pickedFile == null) {
        return;
      }

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
      await _showCreateCaptureModal(
        imageFile: finalFile,
        tempFilesToDeleteOnCancel: filesToClean,
      );
    }
  }

  Future<void> _showAddCaptureSheet() async {
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

    if (!mounted) return;

    if (action == 'camera') {
      await _takePhoto();
    } else if (action == 'gallery') {
      await _pickFromGallery();
    }
  }

  Future<void> _showCaptureOptions(Capture capture) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    dynamic result;
    try {
      result = await CaptureOptionsModal.show(
        context,
        capture: capture,
      );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }

    if (!mounted) return;

    if (result == 'edit' && capture.id != null) {
      await _showCreateCaptureModal(
        captureId: capture.id,
        imagePath: capture.path,
      );
    }
  }

  Future<void> _extractTextFromAllCaptures() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;

    try {
      final ds = ref.read(captureDatasourceProvider);
      final allCaptures = await ds.getByFolderId(widget.folderId);

      if (allCaptures.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "No hay capturas en esta carpeta para extraer texto.",
              ),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      final progressNotifier = ValueNotifier<String>("Iniciando escaneo...");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Extrayendo texto de ${allCaptures.length} imágenes...",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: progressNotifier,
                  builder: (context, msg, _) => Text(
                    msg,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final buffer = StringBuffer();
      buffer.writeln("Materia: ${widget.folderName}");
      buffer.writeln("Total de capturas: ${allCaptures.length}\n");

      int foundCount = 0;
      for (int i = 0; i < allCaptures.length; i++) {
        final cap = allCaptures[i];
        progressNotifier.value =
            "Procesando ${i + 1} de ${allCaptures.length}: ${cap.name}";

        final text = await _nativeService.extractTextFromImage(cap.path);
        if (text != null && text.trim().isNotEmpty) {
          foundCount++;
          buffer.writeln("Captura ${i + 1}: ${cap.name}");
          buffer.writeln(text.trim());
          buffer.writeln("\n");
        }
      }

      if (foundCount == 0) {
        buffer.writeln(
            "No se detectó texto legible en las capturas escaneadas.");
      }

      if (mounted) {
        Navigator.pop(context);

        TextExtractionViewer.show(
          context,
          title: "Texto de la Carpeta",
          subtitle:
              "${widget.folderName} ($foundCount/${allCaptures.length} con texto)",
          initialText: buffer.toString(),
          defaultFileName:
              "${widget.folderName.replaceAll(' ', '_')}_completo.txt",
        );
      }
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _showCaptureViewer(Map<String, dynamic> capture) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      await showDialog(
        context: context,
        builder: (context) => CaptureViewer(
          title: capture['name'] ?? '',
          imageUrl: capture['path'] ?? '',
          note: capture['note'] ?? '',
          date: capture['createdAt'] ?? '',
          tag: capture['tag'] ?? '',
          tagColor: capture['tagColor'] ?? AppColors.textPrimary,
          tagBg: capture['tagBg'] ?? AppColors.surface,
        ),
      );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _filterByTag(int tagId, int filterIndex) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      setState(() {
        _selectedFilter = filterIndex;
      });
      await ref
          .read(captureNotifierProvider.notifier)
          .getAll(folderId: widget.folderId, tagId: tagId);
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _onPageChanged(int newPage) async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    try {
      final tagAsync = ref.read(tagNotifierProvider);
      final tagId = tagAsync.maybeWhen(
        data: (tags) => _selectedFilter == 0
            ? 0
            : (_selectedFilter - 1 < tags.length
                ? (tags[_selectedFilter - 1].id)
                : 0),
        orElse: () => 0,
      );
      await ref.read(captureNotifierProvider.notifier).getAll(
            folderId: widget.folderId,
            tagId: tagId,
            page: newPage,
          );
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadCaptures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagAsyncValue = ref.watch(tagNotifierProvider);
    final captureAsyncValue = ref.watch(captureNotifierProvider);

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
                        child: CaptureHeader(
                          folderBgColor: widget.folderBgColor,
                          folderColor: widget.folderColor,
                          captureCount: captureAsyncValue.maybeWhen(
                            data: (data) => data.pagination.total,
                            orElse: () => 0,
                          ),
                          onExtractText: _extractTextFromAllCaptures,
                          onAddCapture: _showAddCaptureSheet,
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.folderName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Todas las fotos de pizarra, diapositivas y apuntes de esta clase.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      tagAsyncValue.when(
                        error: (error, stackTrace) => SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Error al cargar las etiquetas: $error",
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ),
                        loading: () => const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        data: (data) {
                          final tags = [
                            "Todas",
                            ...data.map((tag) => tag.name),
                          ];
                          return SliverToBoxAdapter(
                            child: SizedBox(
                              height: 42,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: tags.length,
                                itemBuilder: (context, index) {
                                  final isSelected = _selectedFilter == index;
                                  return TagChip(
                                    tag: tags[index],
                                    isSelected: isSelected,
                                    onTap: () {
                                      final tagId = index == 0
                                          ? 0
                                          : (data[index - 1].id);
                                      _filterByTag(tagId, index);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      captureAsyncValue.when(
                        data: (data) {
                          final listCaptures = [...data.captures];

                          if (listCaptures.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 64,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "No hay capturas en esta categoría",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: _showAddCaptureSheet,
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text("Tomar foto ahora"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    isTablet ? 5 : (isLandscape ? 5 : 2),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final capture = listCaptures[index];
                                return CaptureTile(
                                  capture: capture,
                                  onOptionsTap: _showCaptureOptions,
                                  onLongPress: _showCaptureOptions,
                                  showCaptureViewer: (capture) {
                                    final colorOpt =
                                        colorOptions[capture.indexBgColor %
                                            colorOptions.length];
                                    _showCaptureViewer({
                                      'name': capture.name,
                                      'path': capture.path,
                                      'note': '',
                                      'createdAt': capture.createdAt
                                          .toString()
                                          .split('.')[0],
                                      'tag': capture.tags.isNotEmpty
                                          ? capture.tags.first.name
                                          : '',
                                      'tagColor': colorOpt.option,
                                      'tagBg': colorOpt.bgOption,
                                    });
                                  },
                                );
                              }, childCount: listCaptures.length),
                            ),
                          );
                        },
                        error: (error, stackTrace) => SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Error al cargar las capturas: $error",
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ),
                        loading: () => const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      captureAsyncValue.maybeWhen(
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

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
