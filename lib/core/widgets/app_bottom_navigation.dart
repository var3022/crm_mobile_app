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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
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
              Icons.folder_outlined,
              Icons.folder_rounded,
            ),
            _buildNavItem(
              2,
              "Visits",
              Icons.route_outlined,
              Icons.route_rounded,
            ),
            _buildNavItem(
              3,
              "Tasks",
              Icons.checklist_outlined,
              Icons.checklist_rounded,
            ),
            _buildNavItem(
              4,
              "Profile",
              Icons.manage_accounts_outlined,
              Icons.manage_accounts_rounded,
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

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
      ),
    );
  }
}
