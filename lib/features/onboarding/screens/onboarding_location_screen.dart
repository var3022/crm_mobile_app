import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
// ignore: unused_import
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 2 of Onboarding: Location Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingLocationScreen extends StatefulWidget {
  final VoidCallback? onAllowLocation;
  final VoidCallback? onSkip;

  const OnboardingLocationScreen({
    super.key,
    this.onAllowLocation,
    this.onSkip,
  });

  @override
  State<OnboardingLocationScreen> createState() =>
      _OnboardingLocationScreenState();
}

class _OnboardingLocationScreenState extends State<OnboardingLocationScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowLocation() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate location permission request latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission granted successfully!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowLocation != null) {
        widget.onAllowLocation!();
      } else {
        // Default navigation to next onboarding screen (camera access)
        Navigator.of(context).pushNamed("/onboarding-camera");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-camera");
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

              // 1. Top Progress Indicator (Step 2 of Onboarding: ~25%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.25,
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

              // 2. Hero Graphic Card: Light mint container with custom route/nodes illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: _RouteIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Location"
              Text(
                "Enable Location",
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
                "We use GPS to verify your check-ins, optimize your routes, and show nearby leads.",
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // 5. Value Propositions List (3 key benefits with checkmark icons)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    _BenefitItem(
                      title: "Accurate Check-ins",
                      description:
                          "Geofenced visits automatically logs meetings at the client's office.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Smart Route Optimization",
                      description:
                          "Minimize commute fatigue with dynamic sequence plans.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Nearby Client Alerts",
                      description:
                          "Discover unassigned hot prospects within 1 km of your current site.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Location Access"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowLocation,
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
                                    ? "Location Access Granted"
                                    : "Allow Location Access",
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

/// Helper widget to render each value proposition item with a green checkmark badge
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

/// Custom painter for the route & nodes illustration matching the reference image
class _RouteIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final nodeFillPaint = Paint()
      ..color = const Color(0xFFF0FDF9)
      ..style = PaintingStyle.fill;

    // 1. Draw outer boundary L-bracket frame
    final framePath = Path();
    framePath.moveTo(size.width * 0.15, size.height * 0.18);
    framePath.lineTo(size.width * 0.15, size.height * 0.80);
    // Rounded bottom-left corner
    framePath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.88,
      size.width * 0.24,
      size.height * 0.88,
    );
    framePath.lineTo(size.width * 0.82, size.height * 0.88);
    canvas.drawPath(framePath, strokePaint);

    // 2. Define node positions (3 connected route waypoints)
    final nodeA = Offset(size.width * 0.52, size.height * 0.28); // Upper node
    final nodeB = Offset(
      size.width * 0.68,
      size.height * 0.48,
    ); // Middle-right node
    final nodeC = Offset(
      size.width * 0.42,
      size.height * 0.70,
    ); // Lower-left node

    // Connecting line from upper-right edge into Node A
    final leadInEnd = Offset(size.width * 0.80, size.height * 0.22);
    canvas.drawLine(leadInEnd, nodeA, strokePaint);

    // Segment between Node A and Node B
    canvas.drawLine(nodeA, nodeB, strokePaint);

    // Segment between Node B and Node C
    canvas.drawLine(nodeB, nodeC, strokePaint);

    // Draw the 3 circular node discs
    const nodeRadius = 8.5;
    final nodes = [nodeA, nodeB, nodeC];

    for (final node in nodes) {
      // Clear inside of node
      canvas.drawCircle(node, nodeRadius, nodeFillPaint);
      // Draw outer circle ring
      canvas.drawCircle(node, nodeRadius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
