import "dart:math" as math;
import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Onboarding Screen 7: App Intro Walkthrough Screen
/// Direct, authentic reproduction of the CRM Pro Field Sales walkthrough intro screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class AppIntroWalkthroughScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final VoidCallback? onSkip;

  const AppIntroWalkthroughScreen({super.key, this.onFinished, this.onSkip});

  @override
  State<AppIntroWalkthroughScreen> createState() =>
      _AppIntroWalkthroughScreenState();
}

class _AppIntroWalkthroughScreenState extends State<AppIntroWalkthroughScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<_WalkthroughSlideData> _slides = const [
    _WalkthroughSlideData(
      title: "Plan Your Day",
      subtitle:
          "AI-optimized routes, smart scheduling, and morning briefings to maximize your visits.",
      type: _SlideGraphicType.mapRoute,
    ),
    _WalkthroughSlideData(
      title: "Track Your Visits",
      subtitle:
          "GPS-verified check-ins, real-time visit tracking, and automated meeting logs kept instantly in sync.",
      type: _SlideGraphicType.trackVisits,
    ),
    _WalkthroughSlideData(
      title: "Win with AI Insights",
      subtitle:
          "Smart lead scoring, deal win probability, and personalized day-coaching to close deals faster.",
      type: _SlideGraphicType.aiInsights,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWalkthrough();
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      _finishWalkthrough();
    }
  }

  void _finishWalkthrough() {
    if (widget.onFinished != null) {
      widget.onFinished!();
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
                  onPressed: _handleSkip,
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
                      color: const Color(0xFF99F6E4), // Crisp light mint/teal
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Carousel Pages (Illustration + Content)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Center Graphic Card (Map Route grid / node visualization)
                        Center(
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF135858,
                              ), // Subtle lighter teal card
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
                            child: CustomPaint(
                              painter: _buildPainterForType(slide.type),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title: "Plan Your Day"
                        Text(
                          slide.title,
                          style: TextStyle(fontFamily: 'Inter', 
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Subtitle: "AI-optimized routes..."
                        Text(
                          slide.subtitle,
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
                  );
                },
              ),
            ),

            // 3. Bottom Control Row: Indicator Dots on Left, Floating Next Button on Right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Indicators (3 dots)
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
                        ),
                      );
                    }),
                  ),

                  // Bottom Right: Circular Next Button (slides 1 & 2) OR "Get Started" Pill (slide 3)
                  if (_currentPage == _slides.length - 1)
                    GestureDetector(
                      onTap: _finishWalkthrough,
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
                    )
                  else
                    GestureDetector(
                      onTap: _handleNext,
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

  CustomPainter _buildPainterForType(_SlideGraphicType type) {
    switch (type) {
      case _SlideGraphicType.mapRoute:
        return const _MapRoutePainter();
      case _SlideGraphicType.trackVisits:
        return const _TrackVisitsPainter();
      case _SlideGraphicType.aiInsights:
        return const _AiInsightsPainter();
      case _SlideGraphicType.offlineShield:
        return const _OfflineShieldPainter();
    }
  }
}

enum _SlideGraphicType { mapRoute, trackVisits, aiInsights, offlineShield }

class _WalkthroughSlideData {
  final String title;
  final String subtitle;
  final _SlideGraphicType type;

  const _WalkthroughSlideData({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

/// Custom painter rendering the 4x4 coordinate grid and 3 connected waypoint circles
/// matching the exact screenshot design.
class _MapRoutePainter extends CustomPainter {
  const _MapRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw 4x4 coordinate grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Vertical grid lines (3 internal dividers for 4 columns)
    for (int i = 1; i < 4; i++) {
      final x = (w / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Horizontal grid lines (3 internal dividers for 4 rows)
    for (int i = 1; i < 4; i++) {
      final y = (h / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Node Coordinates (normalized according to the screenshot)
    final p1 = Offset(w * 0.28, h * 0.65); // Lower-left node
    final p2 = Offset(w * 0.49, h * 0.38); // Top-center node
    final p3 = Offset(w * 0.74, h * 0.50); // Mid-right node

    // 3. Draw Dashed Route Lines connecting Node 1 -> Node 2 -> Node 3
    final dashPaint = Paint()
      ..color = const Color(0xFF6EE7B7)
          .withOpacity(0.6) // Minty light dashed line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    _drawDashedLine(canvas, p1, p2, dashPaint, dashLength: 6, dashSpace: 5);
    _drawDashedLine(canvas, p2, p3, dashPaint, dashLength: 6, dashSpace: 5);

    // 4. Draw Waypoint Nodes
    _drawWaypointNode(canvas, p1, 13.0);
    _drawWaypointNode(canvas, p2, 12.0);
    _drawWaypointNode(canvas, p3, 12.0);
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

  void _drawWaypointNode(Canvas canvas, Offset center, double radius) {
    // Outer crisp white ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, radius, ringPaint);

    // Inner translucent dark teal fill
    final fillPaint = Paint()
      ..color = const Color(0xFF0F4C4C).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1.2, fillPaint);

    // Center bright core dot
    final corePaint = Paint()
      ..color = const Color(0xFF99F6E4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.2, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Slide 2 Graphic: Track Your Visits illustration (building, pin, verified badge, dashed lines)
class _TrackVisitsPainter extends CustomPainter {
  const _TrackVisitsPainter();

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

    // Windows (2 columns, 3 rows of dots)
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

    // Entrance door
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
    final badgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 19.0, badgePaint);

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

/// Slide 3 Graphic: Win with AI Insights illustration (3 ascending bars + 2 outline stars)
class _AiInsightsPainter extends CustomPainter {
  const _AiInsightsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Grid lines
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

    final yBase = h * 0.72;
    final barWidth = w * 0.062;

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
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Small outline star
    final smallStarCenter = Offset(w * 0.65, h * 0.665);
    final smallStarPath = _createStarPath(smallStarCenter, 7.5, 3.8);
    canvas.drawPath(
      smallStarPath,
      starPaint
        ..strokeWidth = 1.7
        ..color = Colors.white.withOpacity(0.9),
    );

    // Large outline star
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
    double angle = -math.pi / 2;

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

/// Slide 3 Graphic: Offline sync shield illustration in dark teal
class _OfflineShieldPainter extends CustomPainter {
  const _OfflineShieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grid lines
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

    final center = Offset(w * 0.5, h * 0.48);

    // Shield Path
    final shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - 44);
    shieldPath.lineTo(center.dx + 38, center.dy - 28);
    shieldPath.quadraticBezierTo(
      center.dx + 38,
      center.dy + 20,
      center.dx,
      center.dy + 46,
    );
    shieldPath.quadraticBezierTo(
      center.dx - 38,
      center.dy + 20,
      center.dx - 38,
      center.dy - 28,
    );
    shieldPath.close();

    final shieldPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, shieldPaint);

    // Checkmark inside shield
    final checkPaint = Paint()
      ..color = const Color(0xFF6EE7B7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(center.dx - 12, center.dy);
    checkPath.lineTo(center.dx - 3, center.dy + 9);
    checkPath.lineTo(center.dx + 15, center.dy - 10);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
