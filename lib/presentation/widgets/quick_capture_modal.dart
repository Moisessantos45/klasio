import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';

class QuickCaptureModal extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onSelectFromGallery;
  final VoidCallback? onCancel;

  const QuickCaptureModal({
    super.key,
    this.onTakePhoto,
    this.onSelectFromGallery,
    this.onCancel,
  });

  static Future<String?> show(
    BuildContext context, {
    VoidCallback? onTakePhoto,
    VoidCallback? onSelectFromGallery,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickCaptureModal(
        onTakePhoto: onTakePhoto,
        onSelectFromGallery: onSelectFromGallery,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
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
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Nueva Captura de Clase",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Toma una foto de la pizarra o selecciona capturas de tu galería para guardarlas en una materia.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionOption(
                      icon: Icons.camera_alt_rounded,
                      title: "Tomar Foto",
                      subtitle: "Pizarra / Apuntes",
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                      onTap: () {
                        Navigator.pop(context, 'camera');
                        onTakePhoto?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionOption(
                      icon: Icons.photo_library_rounded,
                      title: "Desde Galería",
                      subtitle: "Capturas de pantalla",
                      color: AppColors.folderBlue,
                      bgColor: AppColors.folderBlueLight,
                      onTap: () {
                        Navigator.pop(context, 'gallery');
                        onSelectFromGallery?.call();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
