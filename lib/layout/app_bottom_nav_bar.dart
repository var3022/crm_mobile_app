import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// Navigation item data model for [AppBottomNavBar]
class AppBottomNavItem {
  final String label;
  final IconData icon;
  final IconData outlinedIcon;

  const AppBottomNavItem({
    required this.label,
    required this.icon,
    required this.outlinedIcon,
  });
}

/// Standard reusable CRM Pro Bottom Navigation Bar component.
/// Guaranteed fixed dimensions, zero layout shifts, and persistent styling:
/// - Fixed height across all screens
/// - Uniform 5-tab distribution with [Expanded] slots (no resizing or horizontal jumps)
/// - Active pill highlight with animated transition (#E6F4F2 background, #0F4C4C deep teal)
/// - Muted inactive styling (#9CA3AF icon, #6B7280 text)
/// - Top border #E5E7EB with soft upward shadow
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const List<AppBottomNavItem> defaultItems = [
    AppBottomNavItem(
      label: "Home",
      icon: Icons.home_rounded,
      outlinedIcon: Icons.home_outlined,
    ),
    AppBottomNavItem(
      label: "Leads",
      icon: Icons.folder_rounded,
      outlinedIcon: Icons.folder_outlined,
    ),
    AppBottomNavItem(
      label: "Visits",
      icon: Icons.share_location_rounded,
      outlinedIcon: Icons.share_location_outlined,
    ),
    AppBottomNavItem(
      label: "Tasks",
      icon: Icons.format_list_bulleted_rounded,
      outlinedIcon: Icons.format_list_bulleted_outlined,
    ),
    AppBottomNavItem(
      label: "Profile",
      icon: Icons.manage_accounts_rounded,
      outlinedIcon: Icons.manage_accounts_outlined,
    ),
  ];

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed("/dashboard");
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed("/leads-list");
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed("/visits");
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tasks screen coming soon"),
            duration: Duration(milliseconds: 900),
          ),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile screen coming soon"),
            duration: Duration(milliseconds: 900),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final double navHeight = 64.0 + (bottomPadding > 0 ? bottomPadding : 12.0);

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: bottomPadding > 0 ? bottomPadding : 10,
        left: 4,
        right: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(defaultItems.length, (index) {
          final item = defaultItems[index];
          final isActive = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(context, index),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE6F4F2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.icon : item.outlinedIcon,
                        size: 22,
                        color: isActive
                            ? const Color(0xFF0F4C4C)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF0F4C4C)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
