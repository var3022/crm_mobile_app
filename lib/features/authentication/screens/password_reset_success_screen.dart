import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 8: Password Reset Success Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Password Reset Success screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class PasswordResetSuccessScreen extends StatefulWidget {
  final VoidCallback? onBackToSignIn;
  final String title;
  final String message;
  final String buttonText;

  const PasswordResetSuccessScreen({
    super.key,
    this.onBackToSignIn,
    this.title = "Password Reset!",
    this.message = "Your password has been successfully reset. You can now sign in with your new password.",
    this.buttonText = "Back to Sign In",
  });

  @override
  State<PasswordResetSuccessScreen> createState() => _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState extends State<PasswordResetSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleBackToSignIn() {
    if (widget.onBackToSignIn != null) {
      widget.onBackToSignIn!();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/sign-in",
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // 1. Success Concentric Circular Badge with Double Checkmark
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Center(
                          child: Container(
                            width: 196,
                            height: 196,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD1FADF), // Soft mint outer glow circle
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981), // Emerald green inner circle
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1A10B981),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(56, 42),
                                painter: _DoubleCheckPainter(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 2. Headings & Message (Fade-in transition)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF4B5563),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 3. Primary Action Button: "Back to Sign In"
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _handleBackToSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              widget.buttonText,
                              style: AppTypography.buttonPrimary.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the crisp white double checkmark (interlocking double ticks)
/// matching the exact screenshot design.
class _DoubleCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DoubleCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // First checkmark (left primary tick)
    final path1 = Path();
    path1.moveTo(w * 0.12, h * 0.54);
    path1.lineTo(w * 0.38, h * 0.82);
    path1.lineTo(w * 0.84, h * 0.28);
    canvas.drawPath(path1, paint);

    // Second checkmark (nested offset tick to the right)
    final path2 = Path();
    path2.moveTo(w * 0.50, h * 0.58);
    path2.lineTo(w * 0.66, h * 0.76);
    path2.lineTo(w * 0.98, h * 0.38);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _DoubleCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
