import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/data.dart';
import 'package:klasio/presentation/providers/capture_notifier.dart';
import 'package:klasio/presentation/providers/tag_notifier.dart';

class CaptureModalContent extends ConsumerStatefulWidget {
  final int folderId;
  final int? captureId;
  final File? imageFile;
  final String? imagePath;
  final CaptureNotifier captureNotifier;

  const CaptureModalContent({
    super.key,
    required this.folderId,
    this.captureId,
    this.imageFile,
    this.imagePath,
    required this.captureNotifier,
  });

  @override
  ConsumerState<CaptureModalContent> createState() =>
      _CaptureModalContentState();
}

class _CaptureModalContentState extends ConsumerState<CaptureModalContent> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);
  final List<int> _selectedTagIds = [];
  int _selectedColorIndex = 0;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath ?? widget.imageFile?.path;
    if (widget.captureId != null) {
      Future.microtask(() => _loadCaptureData(widget.captureId!));
    }
  }

  Future<void> _loadCaptureData(int id) async {
    setState(() {
      _isLoading = true;
    });

    final capture = await widget.captureNotifier.getById(id);
    if (capture != null && mounted) {
      setState(() {
        _nameController.text = capture.name;
        _selectedColorIndex = capture.indexBgColor % colorOptions.length;
        _selectedTagIds.clear();
        _selectedTagIds.addAll(capture.tagIds);
        _imagePath = capture.path;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _isBusyNotifier.dispose();
    super.dispose();
  }

  void _toggleTag(int tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
  }

  Future<void> _saveCapture() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa un nombre para la captura"),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final path = _imagePath ?? widget.imageFile?.path ?? '';
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró la ruta de la imagen"),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;

    try {
      if (widget.captureId != null) {
        await widget.captureNotifier.updateCapture(
          id: widget.captureId!,
          folderId: widget.folderId,
          name: name,
          path: path,
          tagIds: _selectedTagIds,
          indexBgColor: _selectedColorIndex,
          indexTextColor: 0,
        );
      } else {
        await widget.captureNotifier.addCapture(
          folderId: widget.folderId,
          name: name,
          path: path,
          tagIds: _selectedTagIds,
          indexBgColor: _selectedColorIndex,
          indexTextColor: 0,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text(
              "Captura '$name' ${widget.captureId != null ? 'actualizada' : 'guardada'} exitosamente.",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _isBusyNotifier.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar la captura: $e"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagAsyncValue = ref.watch(tagNotifierProvider);
    final isEditing = widget.captureId != null;

    return ValueListenableBuilder<bool>(
      valueListenable: _isBusyNotifier,
      builder: (context, isBusy, child) {
        return AbsorbPointer(
          absorbing: isBusy,
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
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
                          Text(
                            isEditing ? "Editar Captura" : "Registrar Captura",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isEditing
                                ? "Modifica el nombre, etiquetas y color de la captura."
                                : "Asigna un nombre, etiquetas y color a tu nueva foto capturada.",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_imagePath != null && _imagePath!.isNotEmpty)
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                color: AppColors.surfaceAlt,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => const Center(
                                          child: Icon(
                                            Icons.image_not_supported_rounded,
                                            color: AppColors.textMuted,
                                            size: 40,
                                          ),
                                        ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isEditing
                                                ? Icons.edit_rounded
                                                : Icons.check_circle_rounded,
                                            color: isEditing
                                                ? Colors.amberAccent
                                                : Colors.greenAccent,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isEditing
                                                ? "En edición"
                                                : "Optimizada",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            autofocus: !isEditing,
                            decoration: InputDecoration(
                              hintText: "Ej. Pizarra de derivadas",
                              labelText: "Nombre de la captura",
                              filled: true,
                              fillColor: AppColors.surfaceAlt,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.edit_note_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            "Etiquetas:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          tagAsyncValue.when(
                            data: (tags) {
                              if (tags.isEmpty) {
                                return const Text(
                                  "No hay etiquetas disponibles",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 38,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: tags.length,
                                  itemBuilder: (context, index) {
                                    final tag = tags[index];
                                    final isSelected =
                                        tag.id != 0 &&
                                        _selectedTagIds.contains(tag.id);

                                    return GestureDetector(
                                      onTap: () {
                                        if (tag.id != 0) {
                                          _toggleTag(tag.id);
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.surfaceAlt,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.border.withValues(
                                                    alpha: 0.5,
                                                  ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isSelected) ...[
                                                const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                              Text(
                                                tag.name,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => const SizedBox(
                              height: 38,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            error: (err, _) => Text(
                              "Error al cargar etiquetas: $err",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            "Color del distintivo:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: colorOptions.length,
                              itemBuilder: (context, index) {
                                final opt = colorOptions[index];
                                final isSelected = _selectedColorIndex == index;
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColorIndex = index;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: opt.option,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: opt.option.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 22,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isBusy ? null : _saveCapture,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isBusy
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      isEditing
                                          ? "Actualizar Captura"
                                          : "Guardar Captura",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
