import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;

  final int totalPages;

  final int? totalItems;

  final ValueChanged<int> onPageChanged;

  final int maxVisiblePages;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.totalItems,
    this.maxVisiblePages = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1 && (totalItems == null || totalItems! <= 0)) {
      return const SizedBox.shrink();
    }

    final hasPrevious = currentPage > 1;
    final hasNext = currentPage < totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Anterior
              _NavButton(
                icon: Icons.chevron_left_rounded,
                label: 'Anterior',
                isEnabled: hasPrevious,
                onTap: () {
                  if (hasPrevious) {
                    onPageChanged(currentPage - 1);
                  }
                },
              ),

              // Botones de Páginas Numéricas
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildPageNumbers(),
                  ),
                ),
              ),

              // Botón Siguiente
              _NavButton(
                icon: Icons.chevron_right_rounded,
                label: 'Siguiente',
                isTrailingIcon: true,
                isEnabled: hasNext,
                onTap: () {
                  if (hasNext) {
                    onPageChanged(currentPage + 1);
                  }
                },
              ),
            ],
          ),
          if (totalItems != null) ...[
            const SizedBox(height: 8),
            Text(
              'Página $currentPage de $totalPages ($totalItems resultados)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> items = [];

    if (totalPages <= maxVisiblePages) {
      for (int i = 1; i <= totalPages; i++) {
        items.add(_buildPageItem(i));
      }
      return items;
    }

    items.add(_buildPageItem(1));

    int start = (currentPage - 1).clamp(2, totalPages - 2);
    int end = (currentPage + 1).clamp(3, totalPages - 1);

    if (start > 2) {
      items.add(_buildEllipsis());
    }

    for (int i = start; i <= end; i++) {
      if (i > 1 && i < totalPages) {
        items.add(_buildPageItem(i));
      }
    }

    if (end < totalPages - 1) {
      items.add(_buildEllipsis());
    }

    items.add(_buildPageItem(totalPages));

    return items;
  }

  Widget _buildPageItem(int page) {
    final isSelected = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => onPageChanged(page),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback onTap;
  final bool isTrailingIcon;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.onTap,
    this.isTrailingIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? AppColors.primary : AppColors.textMuted;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primaryLight.withValues(alpha: 0.3)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isTrailingIcon) Icon(icon, size: 18, color: color),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
              if (isTrailingIcon) Icon(icon, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
