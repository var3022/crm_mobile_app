// ignore_for_file: unused_import

import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_typography.dart";

/// Screen: Logout Confirmation Screen (`screen-logout-confirmation`)
///
/// Authentic, pixel-perfect reproduction of the CRM Pro Field Sales Logout Confirmation dialog/sheet.
/// Renders the Settings screen in the background (with muted ACCOUNT options and Profile tab active),
/// overlaid by the modal bottom sheet prompting Marcus Vance to confirm Sign Out.
class LogoutConfirmationScreen extends StatefulWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onCancel;
  final VoidCallback? onPersonalInformationTap;
  final VoidCallback? onChangePasswordTap;
  final VoidCallback? onNotificationPreferencesTap;
  final ValueChanged<int>? onBottomNavTap;

  const LogoutConfirmationScreen({
    super.key,
    this.onSignOut,
    this.onCancel,
    this.onPersonalInformationTap,
    this.onChangePasswordTap,
    this.onNotificationPreferencesTap,
    this.onBottomNavTap,
  });

  /// Static helper to trigger the logout confirmation as a modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onSignOut,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogoutConfirmationSheet(
        onSignOut: () {
          Navigator.of(ctx).pop(true);
          onSignOut?.call();
        },
        onCancel: () {
          Navigator.of(ctx).pop(false);
          onCancel?.call();
        },
      ),
    );
  }

  @override
  State<LogoutConfirmationScreen> createState() =>
      _LogoutConfirmationScreenState();
}

class _LogoutConfirmationScreenState extends State<LogoutConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleSignOut() {
    setState(() {
      _isSigningOut = true;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        widget.onSignOut?.call();
      }
    });
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // 1. Underlying Settings Page (Dimmed by backdrop overlay)
          Positioned.fill(
            child: Column(
              children: [
                // Top status bar gap + Header
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Settings",
                          style: TextStyle(fontFamily: 'Inter', 
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Settings Body List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // "ACCOUNT" Section Header
                        Text(
                          "ACCOUNT",
                          style: TextStyle(fontFamily: 'Inter', 
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List Item 1: Personal Information
                        _buildSettingsRow(
                          icon: Icons.person_outline_rounded,
                          title: "Personal Information",
                          onTap: widget.onPersonalInformationTap,
                        ),
                        const SizedBox(height: 12),

                        // List Item 2: Change Password
                        _buildSettingsRow(
                          icon: Icons.lock_outline_rounded,
                          title: "Change Password",
                          onTap: widget.onChangePasswordTap,
                        ),
                        const SizedBox(height: 12),

                        // List Item 3: Notification Preferences
                        _buildSettingsRow(
                          icon: Icons.notifications_none_rounded,
                          title: "Notification Preferences",
                          onTap: widget.onNotificationPreferencesTap,
                        ),
                      ],
                    ),
                  ),
                ),

                // Placeholder space for Bottom Nav
                const SizedBox(height: 80),
              ],
            ),
          ),

          // 2. Dimmed Scrim Overlay (Greyed-out backdrop)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Container(
                color: Colors.black.withOpacity(0.42 * _fadeAnimation.value),
              ),
            ),
          ),

          // 3. Foreground Bottom Sheet Modal + Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Center constrained bottom sheet for tablet & desktop responsiveness
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimensions.maxContentWidth,
                      ),
                      child: LogoutConfirmationSheet(
                        isSigningOut: _isSigningOut,
                        onSignOut: _handleSignOut,
                        onCancel: _handleCancel,
                      ),
                    ),
                  ),

                  // Bottom Navigation Bar with Profile active
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFF4B5563)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, "Home", Icons.home_outlined, false),
                  _buildNavItem(
                    1,
                    "Leads",
                    Icons.person_add_alt_outlined,
                    false,
                  ),
                  _buildNavItem(2, "Visits", Icons.location_on_outlined, false),
                  _buildNavItem(
                    3,
                    "Tasks",
                    Icons.assignment_turned_in_outlined,
                    false,
                  ),
                  _buildNavItem(
                    4,
                    "Profile",
                    Icons.person_outline_rounded,
                    true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, bool isActive) {
    final activeColor = const Color(0xFF0F4C4C);
    final inactiveColor = const Color(0xFF6B7280);

    return InkWell(
      onTap: () => widget.onBottomNavTap?.call(index),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? activeColor : inactiveColor),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone Reusable Logout Confirmation Bottom Sheet
class LogoutConfirmationSheet extends StatelessWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onCancel;
  final bool isSigningOut;

  const LogoutConfirmationSheet({
    super.key,
    this.onSignOut,
    this.onCancel,
    this.isSigningOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle pill
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // User Avatar: Marcus Vance
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=256&auto=format&fit=crop&q=80",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF0F4C4C),
                    alignment: Alignment.center,
                    child: Text(
                      "MV",
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // User Name: Marcus Vance
          Text(
            "Marcus Vance",
            style: TextStyle(fontFamily: 'Inter', 
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),

          // Territory Subtitle: Pacific Northwest Territory
          Text(
            "Pacific Northwest Territory",
            style: TextStyle(fontFamily: 'Inter', 
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),

          // Sign Out? Title
          Text(
            "Sign Out?",
            style: TextStyle(fontFamily: 'Inter', 
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Warning & prompt text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Are you sure you want to sign out? You will need to sign in again to access your account.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Primary Button: "Sign Out" (Vibrant Red)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSigningOut ? null : onSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSigningOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Sign Out",
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Button: "Cancel" (Outlined)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: isSigningOut ? null : onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
