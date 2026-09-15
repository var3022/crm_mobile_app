import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen: Biometric Login Screen (Face ID / Touch ID)
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Biometric Login screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class BiometricLoginScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  final VoidCallback? onUsePasswordInstead;
  final String title;
  final String promptText;
  final String alternativeOptionText;

  const BiometricLoginScreen({
    super.key,
    this.onAuthenticated,
    this.onUsePasswordInstead,
    this.title = "CRM Pro Field Sales",
    this.promptText = "Use Face ID to sign in",
    this.alternativeOptionText = "Use password instead",
  });

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isAuthenticating = false;
  bool _authSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _triggerBiometricScan() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    // Simulate authentic biometric sensor read
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _authSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (widget.onAuthenticated != null) {
      widget.onAuthenticated!();
    } else {
      // Default navigation flow to home/dashboard or root
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Face ID Authenticated successfully!"),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleUsePassword() {
    if (widget.onUsePasswordInstead != null) {
      widget.onUsePasswordInstead!();
    } else {
      Navigator.of(context).pushReplacementNamed("/sign-in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Signature Deep Teal #0F4C4C
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // 1. App Logo Squircle ("LP")
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "LP",
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. App Title: "CRM Pro Field Sales"
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),

                const Spacer(flex: 4),

                // 3. Face ID Scanning Disc
                GestureDetector(
                  onTap: _triggerBiometricScan,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E6060), // Translucent soft teal disc
                            border: Border.all(
                              color: _authSuccess
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _authSuccess
                                    ? const Color(0x3310B981)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _authSuccess
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 52,
                                )
                              : _isAuthenticating
                                  ? const SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.8,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const CustomPaint(
                                      size: Size(54, 54),
                                      painter: _FaceIdIconPainter(
                                        color: Colors.white,
                                        strokeWidth: 2.6,
                                      ),
                                    ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Prompt Text: "Use Face ID to sign in"
                GestureDetector(
                  onTap: _triggerBiometricScan,
                  child: Text(
                    _isAuthenticating
                        ? "Verifying Face ID..."
                        : _authSuccess
                            ? "Verified!"
                            : widget.promptText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const Spacer(flex: 5),

                // 5. Alternative Option: "Use password instead"
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextButton(
                    onPressed: _handleUsePassword,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.85),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      widget.alternativeOptionText,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the pixel-accurate Face ID vector icon:
/// - 4 curved corner frame brackets (top-left, top-right, bottom-left, bottom-right)
/// - Two eye slits/dots
/// - Subtle vertical nose dash
/// - Warm curved smile
class _FaceIdIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _FaceIdIconPainter({
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

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Corner bracket parameters
    const bracketLen = 12.0;
    const cornerRadius = 4.0;

    // 1. Top-Left Corner Bracket
    final pathTL = Path();
    pathTL.moveTo(0, bracketLen);
    pathTL.lineTo(0, cornerRadius);
    pathTL.arcToPoint(const Offset(cornerRadius, 0), radius: const Radius.circular(cornerRadius));
    pathTL.lineTo(bracketLen, 0);
    canvas.drawPath(pathTL, paint);

    // 2. Top-Right Corner Bracket
    final pathTR = Path();
    pathTR.moveTo(w - bracketLen, 0);
    pathTR.lineTo(w - cornerRadius, 0);
    pathTR.arcToPoint(Offset(w, cornerRadius), radius: const Radius.circular(cornerRadius));
    pathTR.lineTo(w, bracketLen);
    canvas.drawPath(pathTR, paint);

    // 3. Bottom-Left Corner Bracket
    final pathBL = Path();
    pathBL.moveTo(0, h - bracketLen);
    pathBL.lineTo(0, h - cornerRadius);
    pathBL.arcToPoint(Offset(cornerRadius, h), radius: const Radius.circular(cornerRadius));
    pathBL.lineTo(bracketLen, h);
    canvas.drawPath(pathBL, paint);

    // 4. Bottom-Right Corner Bracket
    final pathBR = Path();
    pathBR.moveTo(w - bracketLen, h);
    pathBR.lineTo(w - cornerRadius, h);
    pathBR.arcToPoint(Offset(w, h - cornerRadius), radius: const Radius.circular(cornerRadius));
    pathBR.lineTo(w, h - bracketLen);
    canvas.drawPath(pathBR, paint);

    // 5. Left Eye (vertical rounded slit / dot)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.36, h * 0.42),
          width: strokeWidth + 0.8,
          height: strokeWidth + 3.0,
        ),
        const Radius.circular(2),
      ),
      fillPaint,
    );

    // 6. Right Eye (vertical rounded slit / dot)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.64, h * 0.42),
          width: strokeWidth + 0.8,
          height: strokeWidth + 3.0,
        ),
        const Radius.circular(2),
      ),
      fillPaint,
    );

    // 7. Nose (small vertical stroke in center)
    canvas.drawLine(
      Offset(w * 0.50, h * 0.48),
      Offset(w * 0.50, h * 0.55),
      paint,
    );

    // 8. Smile (curved arc at bottom)
    final smilePath = Path();
    smilePath.moveTo(w * 0.35, h * 0.68);
    smilePath.quadraticBezierTo(
      w * 0.50,
      h * 0.78,
      w * 0.65,
      h * 0.68,
    );
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceIdIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
