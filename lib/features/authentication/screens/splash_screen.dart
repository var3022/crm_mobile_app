import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../repositories/auth_repository.dart";

/// Screen 1: Splash Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales splash screen.
class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished; // Used for unauthenticated state
  final VoidCallback? onAuthenticated; // Used for authenticated state

  const SplashScreen({super.key, this.onFinished, this.onAuthenticated});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authRepo = AuthRepository();
    
    // We want to show the splash screen for at least 2.4 seconds for brand experience
    final minDurationFuture = Future.delayed(const Duration(milliseconds: 2400));
    
    bool isAuthenticated = false;
    
    try {
      await authRepo.getCurrentUser();
      isAuthenticated = true;
    } catch (e) {
      // Not authenticated or network error
      isAuthenticated = false;
    }

    // Wait for the minimum duration to complete before navigating
    await minDurationFuture;
    
    if (mounted) {
      if (isAuthenticated && widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else if (widget.onFinished != null) {
        widget.onFinished!();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background: Subtle Field Sales Radar / Geometric rings & crosshair grid
          Positioned.fill(
            child: CustomPaint(painter: const _SplashRadarPainter()),
          ),

          // Main Centered Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  const Spacer(flex: 7),

                  // Animated Logo & Text Content
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Icon Squircle Container
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "LP",
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // App Title
                          Text(
                            "CRM Pro Field Sales",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Tagline
                          Text(
                            "Your field. Your leads. Your wins.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFD3E4E4),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 8),

                  // Bottom Version Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        "v1.0.0",
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8BA7A7),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the faint geometric radar rings and coordinate lines
/// visible in the screenshot background.
class _SplashRadarPainter extends CustomPainter {
  const _SplashRadarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.44);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Crosshair axis lines (Field sales coordinates)
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      linePaint,
    );

    // Diagonal subtle guide lines
    final diagonalPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      diagonalPaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      diagonalPaint,
    );

    // Subtle concentric radar distance circles
    final radii = [
      size.width * 0.36,
      size.width * 0.62,
      size.width * 0.90,
      size.width * 1.22,
      size.width * 1.58,
    ];

    for (final radius in radii) {
      canvas.drawCircle(center, radius, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
