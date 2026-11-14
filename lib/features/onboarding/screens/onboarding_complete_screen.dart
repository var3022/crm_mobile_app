import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 7 of Onboarding: Onboarding Complete ("You're All Set!")
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class OnboardingCompleteScreen extends StatefulWidget {
  final VoidCallback? onContinue;

  const OnboardingCompleteScreen({super.key, this.onContinue});

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
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
              const SizedBox(height: 32),

              // 1. Hero Graphic: Concentric Emerald Success Badge with Double Checkmark
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 196,
                      height: 196,
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFFD1FADF,
                        ), // Soft mint outer glow circle (same as reset success)
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF10B981,
                          ), // Emerald green inner circle
                          shape: BoxShape.circle,
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
              ),

              const SizedBox(height: 36),

              // 2. Title: "You're All Set!"
              Text(
                "You're All Set!",
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 3. Subtitle: "Your field kit is ready. Time to hit the road."
              Text(
                "Your field kit is ready. Time to hit the road.",
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 26),

              // 4. Territory Prep Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB), // Clean soft light background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header label
                    Text(
                      "TERRITORY PREP OVERVIEW",
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B7280),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Item 1: 120 leads parsed and mapped
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "120 leads parsed and mapped",
                            style: TextStyle(fontFamily: 'Inter', 
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Item 2: 6 priority visits mapped out for today
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "6 priority visits mapped out for today",
                            style: TextStyle(fontFamily: 'Inter', 
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Item 3: Offline capability fully ready (✓ Active)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: Color(0xFF10B981), // Emerald green
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Inter', 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF10B981), // Green text
                                height: 1.35,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Offline capability fully ready ",
                                ),
                                TextSpan(
                                  text: "(✓ Active)",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 5. Bottom Action: "Continue" CTA
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // #0F4C4C
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(fontFamily: 'Inter', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the crisp white double checkmark (interlocking double ticks)
/// matching the exact screenshot design (identical to password reset success).
class _DoubleCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DoubleCheckPainter({required this.color, required this.strokeWidth});

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
