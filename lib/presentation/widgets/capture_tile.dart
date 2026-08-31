import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/data.dart';
import 'package:klasio/domain/entities/capture.dart';

class CaptureTile extends StatelessWidget {
  final Capture capture;
  final void Function(Capture) showCaptureViewer;
  final void Function(Capture)? onLongPress;
  final void Function(Capture)? onOptionsTap;

  const CaptureTile({
    super.key,
    required this.capture,
    required this.showCaptureViewer,
    this.onLongPress,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showCaptureViewer(capture),
      onLongPress: onLongPress != null ? () => onLongPress!(capture) : null,
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
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              colorOptions[capture.indexBgColor %
                                      colorOptions.length]
                                  .bgOption
                                  .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
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
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => (onOptionsTap ?? onLongPress)?.call(capture),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 16,
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
                    capture.createdAt.toString(),
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
