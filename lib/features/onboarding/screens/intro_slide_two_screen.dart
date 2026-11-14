import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Onboarding Screen 9: Intro Slide Two (Track Your Visits)
/// Authentic reproduction of the CRM Pro Field Sales walkthrough slide two.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class IntroSlideTwoScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const IntroSlideTwoScreen({super.key, this.onNext, this.onSkip});

  void _handleNext(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
      Navigator.of(context).pushReplacementNamed("/app-intro-walkthrough");
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
                    style: GoogleFonts.inter(
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
                          painter: TrackVisitsGraphicPainter(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Headline: "Track Your Visits"
                    Text(
                      "Track Your Visits",
                      style: GoogleFonts.inter(
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
                      "GPS-verified check-ins, real-time visit tracking, and automated meeting logs kept instantly in sync.",
                      style: GoogleFonts.inter(
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

            // 3. Bottom Control Row: Indicator Dots (2nd active) on Left, Next Button on Right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3-dot carousel indicator with second dot active
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
                      // Dot 2 (active)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      // Dot 3 (inactive)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),

                  // Circular white Next button (56 x 56)
                  GestureDetector(
                    onTap: () => _handleNext(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 24,
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

/// Custom painter for the Track Your Visits graphic:
/// - 4x4 coordinate grid
/// - Location pin icon at top center
/// - Building icon at bottom left
/// - Verified checkmark circle badge at bottom right
/// - Dashed trajectory connecting Building -> Pin and Building -> Checkmark
class TrackVisitsGraphicPainter extends CustomPainter {
  const TrackVisitsGraphicPainter();

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

    // Key Anchor Points
    final buildingCenter = Offset(w * 0.28, h * 0.70);
    final pinCenter = Offset(w * 0.495, h * 0.17);
    final checkmarkCenter = Offset(w * 0.715, h * 0.70);

    // 2. Dashed Trajectory Lines
    final dashPaint = Paint()
      ..color = const Color(0xFF6EE7B7).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Diagonal dashed line: Building -> Pin
    final pDiagStart = Offset(buildingCenter.dx + 4, buildingCenter.dy - 16);
    final pDiagEnd = Offset(pinCenter.dx - 1, pinCenter.dy + 23);
    _drawDashedLine(
      canvas,
      pDiagStart,
      pDiagEnd,
      dashPaint,
      dashLength: 6,
      dashSpace: 5,
    );

    // Horizontal dashed line: Building -> Checkmark
    final pHorizStart = Offset(buildingCenter.dx + 16, buildingCenter.dy);
    final pHorizEnd = Offset(checkmarkCenter.dx - 22, checkmarkCenter.dy);
    _drawDashedLine(
      canvas,
      pHorizStart,
      pHorizEnd,
      dashPaint,
      dashLength: 6,
      dashSpace: 5,
    );

    // 3. Draw Building Icon at bottom left
    _drawBuildingIcon(canvas, buildingCenter);

    // 4. Draw Location Pin Icon at top center
    _drawLocationPin(canvas, pinCenter);

    // 5. Draw White Checkmark Badge at bottom right
    _drawCheckmarkBadge(canvas, checkmarkCenter);
  }

  void _drawLocationPin(Canvas canvas, Offset center) {
    final pinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Top circle arc with pointed tip at bottom
    final r = 13.5;
    final topCenter = Offset(center.dx, center.dy);
    path.addArc(
      Rect.fromCircle(center: topCenter, radius: r),
      3.14159 * 0.75,
      3.14159 * 1.5,
    );
    path.quadraticBezierTo(
      center.dx + r * 0.9,
      center.dy + r * 1.0,
      center.dx,
      center.dy + r * 1.7,
    );
    path.quadraticBezierTo(
      center.dx - r * 0.9,
      center.dy + r * 1.0,
      center.dx - r * 0.707,
      center.dy + r * 0.707,
    );
    canvas.drawPath(path, pinPaint);

    // Inner hole circle
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(topCenter, 4.5, holePaint);
  }

  void _drawBuildingIcon(Canvas canvas, Offset center) {
    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = 22.0;
    final h = 28.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(5.0),
    );
    canvas.drawRRect(rect, whiteStroke);

    // Windows (2 columns, 3 rows of dots/mini-squares)
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final leftX = center.dx - 4.5;
    final rightX = center.dx + 4.5;
    final y1 = center.dy - 7.5;
    final y2 = center.dy - 2.5;
    final y3 = center.dy + 2.5;

    canvas.drawCircle(Offset(leftX, y1), 1.2, dotPaint);
    canvas.drawCircle(Offset(rightX, y1), 1.2, dotPaint);
    canvas.drawCircle(Offset(leftX, y2), 1.2, dotPaint);
    canvas.drawCircle(Offset(rightX, y2), 1.2, dotPaint);
    canvas.drawCircle(Offset(leftX, y3), 1.2, dotPaint);
    canvas.drawCircle(Offset(rightX, y3), 1.2, dotPaint);

    // Entrance door at bottom center
    final doorPath = Path();
    doorPath.moveTo(center.dx - 3.5, center.dy + h / 2);
    doorPath.lineTo(center.dx - 3.5, center.dy + h / 2 - 5.5);
    doorPath.arcToPoint(
      Offset(center.dx + 3.5, center.dy + h / 2 - 5.5),
      radius: const Radius.circular(3.5),
    );
    doorPath.lineTo(center.dx + 3.5, center.dy + h / 2);
    canvas.drawPath(doorPath, whiteStroke..style = PaintingStyle.stroke);
  }

  void _drawCheckmarkBadge(Canvas canvas, Offset center) {
    // White circular badge
    final badgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 19.0, badgePaint);

    // Dark teal checkmark
    final checkPaint = Paint()
      ..color = const Color(0xFF0F4C4C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(center.dx - 7.5, center.dy);
    checkPath.lineTo(center.dx - 2.0, center.dy + 5.5);
    checkPath.lineTo(center.dx + 7.5, center.dy - 4.5);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLength = 6.0,
    double dashSpace = 4.0,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalDistance = (end - start).distance;
    if (totalDistance == 0) return;

    final normalizedDx = dx / totalDistance;
    final normalizedDy = dy / totalDistance;

    double currentDistance = 0.0;
    while (currentDistance < totalDistance) {
      final segmentLength = (currentDistance + dashLength > totalDistance)
          ? totalDistance - currentDistance
          : dashLength;

      final pStart = Offset(
        start.dx + normalizedDx * currentDistance,
        start.dy + normalizedDy * currentDistance,
      );
      final pEnd = Offset(
        start.dx + normalizedDx * (currentDistance + segmentLength),
        start.dy + normalizedDy * (currentDistance + segmentLength),
      );

      canvas.drawLine(pStart, pEnd, paint);
      currentDistance += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
