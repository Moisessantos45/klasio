import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';

class CaptureHeader extends StatelessWidget {
  final Color folderBgColor;
  final Color folderColor;
  final int captureCount;
  final VoidCallback? onExtractText;
  final VoidCallback? onAddCapture;
  final VoidCallback? onAddSubfolder;

  const CaptureHeader({
    super.key,
    required this.folderBgColor,
    required this.folderColor,
    required this.captureCount,
    this.onExtractText,
    this.onAddCapture,
    this.onAddSubfolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: folderBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_rounded, color: folderColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  "$captureCount capturas",
                  style: TextStyle(
                    color: folderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onExtractText,
                tooltip: "Extraer texto de todo el folder (OCR)",
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                icon: const Icon(Icons.document_scanner_rounded, size: 20),
              ),
              if (onAddSubfolder != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onAddSubfolder,
                  tooltip: "Crear subcarpeta",
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAddCapture,
                tooltip: "Agregar captura",
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
                icon: const Icon(Icons.add_a_photo_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
