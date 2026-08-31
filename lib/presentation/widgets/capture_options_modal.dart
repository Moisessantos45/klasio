import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/core/service/native_service.dart';
import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/presentation/providers/capture_notifier.dart';
import 'package:klasio/presentation/widgets/text_extraction_viewer.dart';

class CaptureOptionsModal extends ConsumerStatefulWidget {
  final Capture capture;
  final VoidCallback? onEdit;

  const CaptureOptionsModal({
    super.key,
    required this.capture,
    this.onEdit,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Capture capture,
    VoidCallback? onEdit,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          CaptureOptionsModal(capture: capture, onEdit: onEdit),
    );
  }

  @override
  ConsumerState<CaptureOptionsModal> createState() =>
      _CaptureOptionsModalState();
}

class _CaptureOptionsModalState extends ConsumerState<CaptureOptionsModal> {
  final NativeService _nativeService = NativeService();
  final ValueNotifier<bool> _isBusyNotifier = ValueNotifier<bool>(false);
  bool _isProcessingOcr = false;
  bool _isSavingToGallery = false;

  @override
  void dispose() {
    _isBusyNotifier.dispose();
    super.dispose();
  }

  Future<void> _saveToGallery() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    setState(() {
      _isSavingToGallery = true;
    });

    try {
      final success = await _nativeService.saveImageToGallery(
        widget.capture.path,
        title: widget.capture.name,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: success ? Colors.green : AppColors.danger,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  success
                      ? "Foto guardada en la galería (Pictures/Klasio)"
                      : "No se pudo guardar la foto en la galería",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingToGallery = false;
        });
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _extractText() async {
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;
    setState(() {
      _isProcessingOcr = true;
    });

    try {
      final text = await _nativeService.extractTextFromImage(
        widget.capture.path,
      );

      if (mounted) {
        Navigator.pop(context);

        final cleanTitle = widget.capture.name.isNotEmpty
            ? widget.capture.name
            : "Captura";

        TextExtractionViewer.show(
          context,
          title: "Texto Extraído",
          subtitle: cleanTitle,
          initialText: text ?? "",
          defaultFileName: "${cleanTitle.replaceAll(' ', '_')}.txt",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
        });
        _isBusyNotifier.value = false;
      }
    }
  }

  Future<void> _deleteCapture() async {
    if (widget.capture.id == null) return;
    if (_isBusyNotifier.value) return;
    _isBusyNotifier.value = true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "¿Eliminar captura?",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar '${widget.capture.name}'?",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Eliminar"),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        Navigator.pop(context);
        await ref
            .read(captureNotifierProvider.notifier)
            .removeCapture(
              widget.capture.id!,
              folderId: widget.capture.folderId,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surface,
              content: Text(
                "Captura '${widget.capture.name}' eliminada",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        _isBusyNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.capture.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Opciones de captura",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Option: Guardar en Galería
                    _buildOptionTile(
                      icon: Icons.photo_library_outlined,
                      title: "Guardar en el dispositivo",
                      subtitle:
                          "Guarda la foto en la galería (Pictures/Klasio)",
                      color: AppColors.folderBlue,
                      bgColor: AppColors.folderBlueLight,
                      isLoading: _isSavingToGallery,
                      onTap: _saveToGallery,
                    ),
                    const SizedBox(height: 10),

                    // Option: Extraer texto (OCR + TTS + TXT)
                    _buildOptionTile(
                      icon: Icons.document_scanner_rounded,
                      title: "Extraer texto (OCR)",
                      subtitle:
                          "Reconocer texto, copiar, exportar o escuchar audio",
                      color: AppColors.folderGreen,
                      bgColor: AppColors.folderGreenLight,
                      isLoading: _isProcessingOcr,
                      onTap: _extractText,
                    ),
                    const SizedBox(height: 10),

                    // Option: Editar Captura
                    _buildOptionTile(
                      icon: Icons.edit_note_rounded,
                      title: "Editar datos",
                      subtitle:
                          "Modificar nombre, etiquetas y color distintivo",
                      color: AppColors.folderOrange,
                      bgColor: AppColors.folderOrangeLight,
                      onTap: () {
                        if (isBusy) return;
                        Navigator.pop(context, 'edit');
                        widget.onEdit?.call();
                      },
                    ),
                    const SizedBox(height: 10),

                    // Option: Eliminar Captura
                    _buildOptionTile(
                      icon: Icons.delete_outline_rounded,
                      title: "Eliminar captura",
                      subtitle: "Quitar esta imagen del folder",
                      color: AppColors.danger,
                      bgColor: AppColors.dangerLight,
                      onTap: _deleteCapture,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: color,
                      ),
                    )
                  : Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
