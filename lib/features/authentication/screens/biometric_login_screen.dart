// ignore_for_file: unused_import

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
  final VoidCallback? onTryAgain;
  final String title;
  final String promptText;
  final String alternativeOptionText;
  final bool isFailed;
  final String failedTitle;
  final String failedSubtitle;
  final String errorBannerText;

  const BiometricLoginScreen({
    super.key,
    this.onAuthenticated,
    this.onUsePasswordInstead,
    this.onTryAgain,
    this.title = "CRM Pro Field Sales",
    this.promptText = "Use Face ID to sign in",
    this.alternativeOptionText = "Use password instead",
    this.isFailed = false,
    this.failedTitle = "Face ID Failed",
    this.failedSubtitle =
        "We couldn't verify your identity. Please try again or use your password.",
    this.errorBannerText = "TOO MANY ATTEMPTS. PLEASE USE PASSWORD.",
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

  late bool _isFailedState;
  bool _isAuthenticating = false;
  bool _authSuccess = false;
  // ignore: unused_field
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isFailedState = widget.isFailed;

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
  void didUpdateWidget(covariant BiometricLoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFailed != widget.isFailed) {
      setState(() {
        _isFailedState = widget.isFailed;
      });
    }
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

    if (_isFailedState) {
      // In failed state, re-attempt can either fail again or trigger custom callback
      setState(() {
        _isAuthenticating = false;
      });
      if (widget.onTryAgain != null) {
        widget.onTryAgain!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Face ID verification failed. Please use password."),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // 1. App Logo Squircle ("LP")
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "LP",
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. App Title: "CRM Pro Field Sales"
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),

                const Spacer(flex: 4),

                // 3. Face ID Scanning Disc (Normal or Failed state)
                GestureDetector(
                  onTap: _triggerBiometricScan,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isFailedState
                                ? const Color(
                                    0xFF133B3B,
                                  ) // Tinted dark teal inner disc
                                : const Color(
                                    0xFF1E6060,
                                  ), // Translucent soft teal disc
                            border: Border.all(
                              color: _isFailedState
                                  ? const Color(
                                      0xFFEF4444,
                                    ) // Coral red border for failure
                                  : _authSuccess
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withOpacity(0.15),
                              width: _isFailedState ? 2.0 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isFailedState
                                    ? const Color(0x38EF4444)
                                    : _authSuccess
                                    ? const Color(0x3310B981)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 18,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : CustomPaint(
                                  size: const Size(58, 58),
                                  painter: _FaceIdIconPainter(
                                    color: _isFailedState
                                        ? const Color(
                                            0xFFEF4444,
                                          ) // Coral red Face ID
                                        : Colors.white,
                                    strokeWidth: 2.8,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // 4. Headline & Subtitle
                if (_isFailedState) ...[
                  Text(
                    widget.failedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      widget.failedSubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.75),
                        letterSpacing: -0.1,
                        height: 1.45,
                      ),
                    ),
                  ),
                ] else ...[
                  // Normal Prompt Text: "Use Face ID to sign in"
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
                ],

                const Spacer(flex: 4),

                // 5. Bottom Controls (Failed State Dual Buttons vs Normal Single Link)
                if (_isFailedState) ...[
                  // Error Warning Text: "TOO MANY ATTEMPTS. PLEASE USE PASSWORD."
                  Text(
                    widget.errorBannerText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button 1: "Try Again"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _triggerBiometricScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E8585),
                        foregroundColor: const Color(0xFF1B3B3B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Try Again",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B3B3B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Button 2: "Use Password Instead"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _handleUsePassword,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Use Password Instead",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Normal Alternative Option: "Use password instead"
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: TextButton(
                      onPressed: _handleUsePassword,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.85),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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

  const _FaceIdIconPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 54.0;
    final scaleY = size.height / 54.0;

    double sx(double x) => x * scaleX;
    double sy(double y) => y * scaleY;

    // 1. Top Left Bracket: M4 14V8C4 5.79086 5.79086 4 8 4H14
    final pathTL = Path();
    pathTL.moveTo(sx(4), sy(14));
    pathTL.lineTo(sx(4), sy(8));
    pathTL.cubicTo(sx(4), sy(5.79086), sx(5.79086), sy(4), sx(8), sy(4));
    pathTL.lineTo(sx(14), sy(4));
    canvas.drawPath(pathTL, paint);

    // 2. Top Right Bracket: M40 4H46C48.2091 4 50 5.79086 50 8V14
    final pathTR = Path();
    pathTR.moveTo(sx(40), sy(4));
    pathTR.lineTo(sx(46), sy(4));
    pathTR.cubicTo(sx(48.2091), sy(4), sx(50), sy(5.79086), sx(50), sy(8));
    pathTR.lineTo(sx(50), sy(14));
    canvas.drawPath(pathTR, paint);

    // 3. Bottom Left Bracket: M4 40V46C4 48.2091 5.79086 50 8 50H14
    final pathBL = Path();
    pathBL.moveTo(sx(4), sy(40));
    pathBL.lineTo(sx(4), sy(46));
    pathBL.cubicTo(sx(4), sy(48.2091), sx(5.79086), sy(50), sx(8), sy(50));
    pathBL.lineTo(sx(14), sy(50));
    canvas.drawPath(pathBL, paint);

    // 4. Bottom Right Bracket: M40 50H46C48.2091 50 50 48.2091 50 46V40
    final pathBR = Path();
    pathBR.moveTo(sx(40), sy(50));
    pathBR.lineTo(sx(46), sy(50));
    pathBR.cubicTo(sx(48.2091), sy(50), sx(50), sy(48.2091), sx(50), sy(46));
    pathBR.lineTo(sx(50), sy(40));
    canvas.drawPath(pathBR, paint);

    // 5. Left Eye Slit: M19 20V23 (strokeWidth: 3.0)
    final eyePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(sx(19), sy(20)), Offset(sx(19), sy(23)), eyePaint);

    // 6. Right Eye Slit: M35 20V23 (strokeWidth: 3.0)
    canvas.drawLine(Offset(sx(35), sy(20)), Offset(sx(35), sy(23)), eyePaint);

    // 7. Nose: M27 24V30 (strokeWidth: 2.6)
    canvas.drawLine(Offset(sx(27), sy(24)), Offset(sx(27), sy(30)), paint);

    // 8. Smile: M19 36C21.5 39 32.5 39 35 36 (strokeWidth: 2.6)
    final smilePath = Path();
    smilePath.moveTo(sx(19), sy(36));
    smilePath.cubicTo(sx(21.5), sy(39), sx(32.5), sy(39), sx(35), sy(36));
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceIdIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
