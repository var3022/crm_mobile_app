import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 3 of Onboarding: Camera Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingCameraScreen extends StatefulWidget {
  final VoidCallback? onAllowCamera;
  final VoidCallback? onSkip;

  const OnboardingCameraScreen({super.key, this.onAllowCamera, this.onSkip});

  @override
  State<OnboardingCameraScreen> createState() => _OnboardingCameraScreenState();
}

class _OnboardingCameraScreenState extends State<OnboardingCameraScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowCamera() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate camera permission request latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera permission granted successfully!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowCamera != null) {
        widget.onAllowCamera!();
      } else {
        // Navigate to next onboarding step: microphone permission
        Navigator.of(context).pushNamed("/onboarding-microphone");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-microphone");
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

              // 1. Top Progress Indicator (Step 3 of Onboarding: ~42%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.42,
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

              // 2. Hero Graphic Card: Light mint container with custom camera line illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(106, 106),
                  painter: _CameraIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Camera"
              Text(
                "Enable Camera",
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
                "Capture visiting cards, customer photos, and documents during visits.",
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
                      title: "Business Card OCR",
                      description:
                          "Instant lead translation from physical cards directly to the CRM.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Site Verification",
                      description:
                          "Upload physical storefront images as meeting proof for compliance.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Receipt Scans",
                      description:
                          "Instantly log client lunch bills to expenses on the fly.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Camera Access"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowCamera,
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
                                    ? "Camera Access Granted"
                                    : "Allow Camera Access",
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
        // Mint circular check badge
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF), // Mint circle
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF0F766E), // Teal check
          ),
        ),
        const SizedBox(width: 12),

        // Text Column: Title & Description
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

/// Custom painter for the camera outline illustration matching the reference image
class _CameraIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;

    // Draw clean iconic camera outline with angled slopes and rounded corners
    final path = Path();
    path.moveTo(14.5 * scale, 4.0 * scale);
    path.lineTo(9.5 * scale, 4.0 * scale);
    path.lineTo(7.0 * scale, 7.0 * scale);
    path.lineTo(4.0 * scale, 7.0 * scale);
    path.arcToPoint(
      Offset(2.0 * scale, 9.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(2.0 * scale, 18.0 * scale);
    path.arcToPoint(
      Offset(4.0 * scale, 20.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(20.0 * scale, 20.0 * scale);
    path.arcToPoint(
      Offset(22.0 * scale, 18.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(22.0 * scale, 9.0 * scale);
    path.arcToPoint(
      Offset(20.0 * scale, 7.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(17.0 * scale, 7.0 * scale);
    path.close();

    canvas.drawPath(path, strokePaint);

    // Central circular camera lens
    canvas.drawCircle(
      Offset(12.0 * scale, 13.0 * scale),
      3.4 * scale,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
