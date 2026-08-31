import 'package:flutter/material.dart';
import 'package:klasio/config/app_colors.dart';
import 'package:klasio/config/custom_navigator.dart';
import 'package:klasio/presentation/screens/folder.dart';
import 'package:klasio/presentation/screens/home.dart';
import 'package:klasio/presentation/screens/profile.dart';

class CustomNavigationBar extends StatelessWidget {
  final ValueNotifier<int> currentIndexNotifier;
  final VoidCallback? onAddTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndexNotifier,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(34),
          boxShadow: AppColors.floatingShadow,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: currentIndexNotifier,
              builder: (context, currentIndex, _) {
                return _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                  label: "Inicio",
                  selected: currentIndex == 0,
                  onTap: () {
                    if (currentIndex != 0) {
                      currentIndexNotifier.value = 0;
                      CustomNavigator.pushReplacementFade(
                        context,
                        const HomeScreen(),
                      );
                    }
                  },
                );
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: currentIndexNotifier,
              builder: (context, currentIndex, _) {
                return _buildNavItem(
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder_rounded,
                  label: "Materias",
                  selected: currentIndex == 1,
                  onTap: () {
                    if (currentIndex != 1) {
                      currentIndexNotifier.value = 1;
                      CustomNavigator.pushReplacementFade(
                        context,
                        const FolderScreen(),
                      );
                    }
                  },
                );
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: currentIndexNotifier,
              builder: (context, currentIndex, _) {
                return _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: "Perfil",
                  selected: currentIndex == 2,
                  onTap: () {
                    if (currentIndex != 2) {
                      currentIndexNotifier.value = 2;
                      CustomNavigator.pushReplacementFade(
                        context,
                        const ProfileScreen(),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: AppColors.primaryLight,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
