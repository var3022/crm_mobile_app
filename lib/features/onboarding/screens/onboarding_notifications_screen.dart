import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 5 of Onboarding: Notifications Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingNotificationsScreen extends StatefulWidget {
  final VoidCallback? onAllowNotifications;
  final VoidCallback? onSkip;

  const OnboardingNotificationsScreen({
    super.key,
    this.onAllowNotifications,
    this.onSkip,
  });

  @override
  State<OnboardingNotificationsScreen> createState() =>
      _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState
    extends State<OnboardingNotificationsScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowNotifications() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate notification permission prompt latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Notifications enabled! Push channels calibrated for field sales.",
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowNotifications != null) {
        widget.onAllowNotifications!();
      } else {
        // Proceed to Screen 6: Prepare for Offline setup
        Navigator.of(context).pushReplacementNamed("/onboarding-offline-setup");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/onboarding-offline-setup");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Progress Bar (Step 5 of Onboarding: ~78%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.78,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Soft mint card with notification bell vector illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(120, 110),
                  painter: _NotificationBellIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Notifications"
              Text(
                "Enable Notifications",
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "Get reminders for visits, follow-ups, and new lead assignments.",
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // 5. Value Propositions List (3 key benefits with mint checkmark badges)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    _BenefitItem(
                      title: "Real-time Lead Routing",
                      description:
                          "Instant alert the moment a manager scopes a hot lead into your zone.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Next Appointment Alerts",
                      description:
                          "Polite reminders 15 mins prior to keep you moving efficiently.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Daily Summary",
                      description:
                          "Morning heads-up summarizing critical actions for the day.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Notifications"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isGranted
                                    ? "Notifications Enabled"
                                    : "Allow Notifications",
                                style: TextStyle(fontFamily: 'Inter', 
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary Action: "Skip for now"
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip for now",
                        style: TextStyle(fontFamily: 'Inter', 
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to render each value proposition item with a mint checkmark badge
class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check, size: 14, color: Color(0xFF0F766E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the minimalist notification bell vector illustration matching the reference image
class _NotificationBellIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    // 1. Bell Body Outline with wide flare and notch for notification pip
    final bellPath = Path();

    // Start on upper curve just left of the alert circle
    bellPath.moveTo(47.0 * scaleX, 17.5 * scaleY);

    // Arch over top apex to the left shoulder
    bellPath.cubicTo(
      42.0 * scaleX,
      17.0 * scaleY,
      37.5 * scaleX,
      21.0 * scaleY,
      36.0 * scaleX,
      28.0 * scaleY,
    );

    // Down through the left waist
    bellPath.cubicTo(
      35.0 * scaleX,
      35.0 * scaleY,
      35.0 * scaleX,
      41.0 * scaleY,
      33.5 * scaleX,
      46.0 * scaleY,
    );

    // Graceful outward flare to bottom-left rim tip
    bellPath.cubicTo(
      31.5 * scaleX,
      52.0 * scaleY,
      26.0 * scaleX,
      55.0 * scaleY,
      24.0 * scaleX,
      56.5 * scaleY,
    );

    // Rounded bottom-left corner
    bellPath.arcToPoint(
      Offset(27.0 * scaleX, 58.5 * scaleY),
      radius: Radius.circular(2.5 * scaleX),
      clockwise: false,
    );

    // Flat horizontal baseline
    bellPath.lineTo(71.0 * scaleX, 58.5 * scaleY);

    // Rounded bottom-right corner
    bellPath.arcToPoint(
      Offset(74.0 * scaleX, 56.5 * scaleY),
      radius: Radius.circular(2.5 * scaleX),
      clockwise: false,
    );

    // Graceful inward swoop from bottom-right flare tip through right waist
    bellPath.cubicTo(
      72.0 * scaleX,
      55.0 * scaleY,
      66.5 * scaleX,
      52.0 * scaleY,
      64.5 * scaleX,
      46.0 * scaleY,
    );

    // Up through the right waist, terminating cleanly below the alert circle
    bellPath.cubicTo(
      63.0 * scaleX,
      41.0 * scaleY,
      63.0 * scaleX,
      36.0 * scaleY,
      59.5 * scaleX,
      31.0 * scaleY,
    );

    canvas.drawPath(bellPath, strokePaint);

    // 2. Alert Notification Pip (circle on upper-right shoulder)
    final alertCenter = Offset(58.0 * scaleX, 20.0 * scaleY);
    final alertRadius = 7.5 * scaleX;
    canvas.drawCircle(alertCenter, alertRadius, strokePaint);

    // 3. Centered Bell Clapper (smile arc underneath the rim)
    final clapperPath = Path();
    clapperPath.moveTo(44.0 * scaleX, 64.0 * scaleY);
    clapperPath.quadraticBezierTo(
      49.0 * scaleX,
      68.0 * scaleY,
      54.0 * scaleX,
      64.0 * scaleY,
    );
    canvas.drawPath(clapperPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
