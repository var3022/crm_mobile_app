import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_typography.dart";

/// Onboarding Screen: Skip Confirmation Screen (`screen-onboarding-skip-confirmation`)
///
/// Pixel-accurate implementation matching the CRM Pro Field Sales design system.
/// Features a dimmed background showing the Permissions setup screen, overlaid
/// by a modal bottom sheet warning reps about feature limitations when permissions are skipped.
class OnboardingSkipConfirmationScreen extends StatefulWidget {
  final String? skippedFromRoute;
  final VoidCallback? onGoBack;
  final VoidCallback? onSkipAnyway;
  final ValueChanged<int>? onBottomNavTap;

  const OnboardingSkipConfirmationScreen({
    super.key,
    this.skippedFromRoute,
    this.onGoBack,
    this.onSkipAnyway,
    this.onBottomNavTap,
  });

  /// Static helper to show the skip confirmation as a modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    String? skippedFromRoute,
    VoidCallback? onGoBack,
    VoidCallback? onSkipAnyway,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OnboardingSkipConfirmationSheet(
        onGoBack: () {
          Navigator.of(ctx).pop(false);
          onGoBack?.call();
        },
        onSkipAnyway: () {
          Navigator.of(ctx).pop(true);
          onSkipAnyway?.call();
        },
      ),
    );
  }

  @override
  State<OnboardingSkipConfirmationScreen> createState() =>
      _OnboardingSkipConfirmationScreenState();
}

class _OnboardingSkipConfirmationScreenState
    extends State<OnboardingSkipConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleGoBack() {
    if (widget.onGoBack != null) {
      widget.onGoBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.skippedFromRoute != null) {
      Navigator.of(context).pushReplacementNamed(widget.skippedFromRoute!);
    } else {
      Navigator.of(context).pushReplacementNamed("/onboarding-offline-setup");
    }
  }

  void _handleSkipAnyway() {
    if (widget.onSkipAnyway != null) {
      widget.onSkipAnyway!();
    } else {
      Navigator.of(context).pushReplacementNamed("/onboarding-complete");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8E95A0),
      body: Stack(
        children: [
          // 1. Underlying Permissions Screen (Dimmed Context)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF88929E),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      // Rounded Square Permissions Placeholder Graphic
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B7482).withOpacity(0.65),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Title: Permissions
                      Text(
                        "Permissions",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          "Enable the following permissions to ensure a smooth CRM field sales workflow.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF334155),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Dimmed Scrim Overlay (Greyed-out backdrop)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Container(
                color: Colors.black.withOpacity(0.20 * _fadeAnimation.value),
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
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimensions.maxContentWidth,
                      ),
                      child: OnboardingSkipConfirmationSheet(
                        onGoBack: _handleGoBack,
                        onSkipAnyway: _handleSkipAnyway,
                      ),
                    ),
                  ),
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, "Home", Icons.home_outlined),
              _buildNavItem(1, "Leads", Icons.person_add_alt_outlined),
              _buildNavItem(2, "Visits", Icons.location_on_outlined),
              _buildNavItem(3, "Tasks", Icons.assignment_turned_in_outlined),
              _buildNavItem(4, "Profile", Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final navColor = const Color(0xFF0F4C4C);

    return InkWell(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        widget.onBottomNavTap?.call(index);
      },
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: navColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: navColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone Reusable Skip Confirmation Bottom Sheet
class OnboardingSkipConfirmationSheet extends StatelessWidget {
  final VoidCallback? onGoBack;
  final VoidCallback? onSkipAnyway;

  const OnboardingSkipConfirmationSheet({
    super.key,
    this.onGoBack,
    this.onSkipAnyway,
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
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle pill
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title: "Skip Permissions?"
          Text(
            "Skip Permissions?",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle / Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Some features will be limited without these permissions. You can enable them later in Settings.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Feature Limitation Warning Box (Location, Camera, Notifications)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location bullet
                _buildLimitationItem(
                  category: "Location",
                  description: "Nearby leads & check-in won't work",
                ),
                const SizedBox(height: 10),

                // Camera bullet
                _buildLimitationItem(
                  category: "Camera",
                  description: "Can't capture visit photos",
                ),
                const SizedBox(height: 10),

                // Notifications bullet
                _buildLimitationItem(
                  category: "Notifications",
                  description: "You'll miss important updates",
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Primary Button: "Go Back" (Deep Teal #0F4C4C)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onGoBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C4C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Go Back",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Button: "Skip Anyway" (White Outlined)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onSkipAnyway,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Skip Anyway",
                style: GoogleFonts.inter(
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

  Widget _buildLimitationItem({
    required String category,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "•  ",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFF334155),
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: "$category: ",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                TextSpan(
                  text: description,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
