import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 4 of Onboarding: Microphone Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingMicrophoneScreen extends StatefulWidget {
  final VoidCallback? onAllowMicrophone;
  final VoidCallback? onSkip;

  const OnboardingMicrophoneScreen({
    super.key,
    this.onAllowMicrophone,
    this.onSkip,
  });

  @override
  State<OnboardingMicrophoneScreen> createState() =>
      _OnboardingMicrophoneScreenState();
}

class _OnboardingMicrophoneScreenState
    extends State<OnboardingMicrophoneScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowMicrophone() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate microphone permission latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Microphone permission granted successfully!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowMicrophone != null) {
        widget.onAllowMicrophone!();
      } else {
        // Navigate to next onboarding step: notifications permission
        Navigator.of(context).pushNamed("/onboarding-notifications");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-notifications");
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

              // 1. Top Progress Bar (Step 4 of Onboarding: ~60%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.60,
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

              // 2. Hero Graphic Card: Soft mint card with continuous audio waveform vector illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(125, 105),
                  painter: _WaveformIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Microphone"
              Text(
                "Enable Microphone",
                style: GoogleFonts.inter(
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
                "Record voice notes during or after meetings instead of typing.",
                style: GoogleFonts.inter(
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
                      title: "Hands-free Minutes",
                      description:
                          "Dictate logs walking back to your car, converted instantly to text.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Quick Client Quotes",
                      description:
                          "Capture precise verbal requests with secure client agreement notes.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Smart Summary",
                      description:
                          "AI distills 5-minute recordings into actionable tasks.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Microphone Access"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowMicrophone,
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
                                    ? "Microphone Access Granted"
                                    : "Allow Microphone Access",
                                style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
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

/// Custom painter for the continuous audio sound waveform illustration matching the reference image
class _WaveformIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    final path = Path();

    // Start of the left wave tail
    path.moveTo(16.0 * scaleX, 52.0 * scaleY);

    // Curve into the first vertical stem
    path.cubicTo(
      22.0 * scaleX,
      51.0 * scaleY,
      26.0 * scaleX,
      42.0 * scaleY,
      28.0 * scaleX,
      32.0 * scaleY,
    );

    // Peak 1 top rounded dome with wider breathing room
    path.arcToPoint(
      Offset(44.0 * scaleX, 32.0 * scaleY),
      radius: Radius.circular(8.0 * scaleX),
      clockwise: true,
    );

    // Straight down to trough 1
    path.lineTo(44.0 * scaleX, 78.0 * scaleY);

    // Trough 1 bottom rounded curve (deepest drop) with wider space
    path.arcToPoint(
      Offset(60.0 * scaleX, 78.0 * scaleY),
      radius: Radius.circular(8.0 * scaleX),
      clockwise: false,
    );

    // Straight up to peak 2 (highest peak)
    path.lineTo(60.0 * scaleX, 22.0 * scaleY);

    // Peak 2 top rounded dome with wider space
    path.arcToPoint(
      Offset(76.0 * scaleX, 22.0 * scaleY),
      radius: Radius.circular(8.0 * scaleX),
      clockwise: true,
    );

    // Straight down to trough 2
    path.lineTo(76.0 * scaleX, 62.0 * scaleY);

    // Trough 2 bottom rounded curve with wider space
    path.arcToPoint(
      Offset(90.0 * scaleX, 62.0 * scaleY),
      radius: Radius.circular(7.0 * scaleX),
      clockwise: false,
    );

    // Curve out to the right ending tail
    path.cubicTo(
      91.0 * scaleX,
      55.0 * scaleY,
      94.0 * scaleX,
      48.0 * scaleY,
      98.0 * scaleX,
      44.0 * scaleY,
    );

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
