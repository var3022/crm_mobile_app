import "package:flutter/material.dart";
import "../theme/app_colors.dart";
import "../theme/app_dimensions.dart";
import "../theme/app_typography.dart";

/// Standard 5-tab bottom navigation bar for CRM Pro Field Sales
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, "Home", Icons.home_outlined, Icons.home_rounded),
            _buildNavItem(
              1,
              "Leads",
              Icons.people_outline_rounded,
              Icons.people_rounded,
            ),
            _buildNavItem(
              2,
              "Visits",
              Icons.location_on_outlined,
              Icons.location_on_rounded,
            ),
            _buildNavItem(
              3,
              "Tasks",
              Icons.check_circle_outline_rounded,
              Icons.check_circle_rounded,
            ),
            _buildNavItem(
              4,
              "Profile",
              Icons.person_outline_rounded,
              Icons.person_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData inactiveIcon,
    IconData activeIcon,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textTertiary;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: AppDimensions.bottomNavIconSize,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.navigationLabel.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
