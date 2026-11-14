import "dart:math" as math;
import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Onboarding Screen 10: Intro Slide Three (Win with AI Insights)
/// Authentic reproduction of the CRM Pro Field Sales walkthrough slide three.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class IntroSlideThreeScreen extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSkip;

  const IntroSlideThreeScreen({super.key, this.onGetStarted, this.onSkip});

  void _handleGetStarted(BuildContext context) {
    if (onGetStarted != null) {
      onGetStarted!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  void _handleSkip(BuildContext context) {
    if (onSkip != null) {
      onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _handleSkip(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyle(fontFamily: 'Inter', 
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF99F6E4),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Main Content Area (Graphic card + Headline + Subtitle)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Center Graphic Card (280 x 280)
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFF135858),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const CustomPaint(
                          painter: AiInsightsGraphicPainter(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Headline: "Win with AI Insights"
                    Text(
                      "Win with AI Insights",
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      "Smart lead scoring, deal win probability, and personalized day-coaching to close deals faster.",
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD1FAE5).withOpacity(0.85),
                        height: 1.45,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Control Row: Indicator Dots on Left, "Get Started" Pill Button on Right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3-dot carousel indicator with third dot active
                  Row(
                    children: [
                      // Dot 1 (inactive)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      // Dot 2 (inactive)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      // Dot 3 (active)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Pill-shaped "Get Started" Button
                  GestureDetector(
                    onTap: () => _handleGetStarted(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Get Started",
                        style: TextStyle(fontFamily: 'Inter', 
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F4C4C),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the Win with AI Insights graphic:
/// - 4x4 coordinate grid lines
/// - Three ascending growth bars (muted teal, medium teal, crisp white)
/// - Small and large outlined stars
class AiInsightsGraphicPainter extends CustomPainter {
  const AiInsightsGraphicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle 4x4 coordinate grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i < 4; i++) {
      final x = (w / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      final y = (h / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Baseline for the bars
    final yBase = h * 0.72;
    final barWidth = w * 0.062; // ~17.5px

    // Bar 1 (Leftmost, shortest, muted gray-teal)
    final bar1Left = w * 0.245;
    final bar1Height = h * 0.26;
    final bar1Rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(bar1Left, yBase - bar1Height, barWidth, bar1Height),
      topLeft: const Radius.circular(5.5),
      topRight: const Radius.circular(5.5),
    );
    final bar1Paint = Paint()
      ..color = const Color(0xFF4D8080)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bar1Rect, bar1Paint);

    // Bar 2 (Middle, medium height, brighter teal)
    final bar2Left = w * 0.368;
    final bar2Height = h * 0.46;
    final bar2Rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(bar2Left, yBase - bar2Height, barWidth, bar2Height),
      topLeft: const Radius.circular(5.5),
      topRight: const Radius.circular(5.5),
    );
    final bar2Paint = Paint()
      ..color = const Color(0xFF6BADA8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bar2Rect, bar2Paint);

    // Bar 3 (Rightmost, tallest, solid crisp white)
    final bar3Left = w * 0.493;
    final bar3Height = h * 0.62;
    final bar3Rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(bar3Left, yBase - bar3Height, barWidth, bar3Height),
      topLeft: const Radius.circular(5.5),
      topRight: const Radius.circular(5.5),
    );
    final bar3Paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bar3Rect, bar3Paint);

    // Outline Stars on the right of the tallest bar
    // Star outline paint
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Small outline star (near baseline, right of tallest bar)
    final smallStarCenter = Offset(w * 0.65, h * 0.665);
    final smallStarPath = _createStarPath(smallStarCenter, 7.5, 3.8);
    canvas.drawPath(
      smallStarPath,
      starPaint
        ..strokeWidth = 1.7
        ..color = Colors.white.withOpacity(0.9),
    );

    // Large outline star (further right)
    final largeStarCenter = Offset(w * 0.79, h * 0.63);
    final largeStarPath = _createStarPath(largeStarCenter, 13.0, 6.2);
    canvas.drawPath(
      largeStarPath,
      starPaint
        ..strokeWidth = 2.1
        ..color = Colors.white,
    );
  }

  Path _createStarPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    const int numPoints = 5;
    final double step = math.pi / numPoints;
    double angle = -math.pi / 2; // point upwards

    for (int i = 0; i < numPoints * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
