import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// Screen: Biometric Login Screen (Unified Face ID Login & Failed States)
/// Pixel-accurate implementation supporting both Normal and Failed states in a single optimized screen.
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
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late bool _isFailed;
  bool _isAuthenticating = false;
  bool _authSuccess = false;

  @override
  void initState() {
    super.initState();
    _isFailed = widget.isFailed;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant BiometricLoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFailed != widget.isFailed) {
      setState(() {
        _isFailed = widget.isFailed;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerScan() async {
    if (!_isFailed) {
      setState(() {
        _isAuthenticating = false;
        _isFailed = true; // Transition to Failed screen on first scan
      });
      return;
    }
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    if (_isFailed) {
      // If a custom onTryAgain callback is provided, invoke it
      if (widget.onTryAgain != null) {
        setState(() => _isAuthenticating = false);
        widget.onTryAgain!();
        return;
      }

      // Successful re-authentication from failed state
      setState(() {
        _isAuthenticating = false;
        _isFailed = false;
        _authSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      _navigateToDashboard();
      return;
    }

    setState(() {
      _isAuthenticating = false;
      _authSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    if (widget.onAuthenticated != null) {
      widget.onAuthenticated!();
    } else {
      Navigator.of(context).pushReplacementNamed("/dashboard");
    }
  }

  void _navigateToSignIn() {
    if (widget.onUsePasswordInstead != null) {
      widget.onUsePasswordInstead!();
    } else {
      Navigator.of(context).pushReplacementNamed("/sign-in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F4C4C), // Signature Deep Teal
      body: SafeArea(
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // 1. App Logo Squircle ("LP")
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "LP",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F4C4C),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 2. App Title: "CRM Pro Field Sales"
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),

                const Spacer(flex: 4),

                // 3. Face ID Scanning Disc
                GestureDetector(
                  onTap: _triggerScan,
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
                            color: _isFailed
                                ? const Color(0xFF133B3B) // Dark tinted teal
                                : const Color(
                                    0xFF1B5555,
                                  ), // Translucent soft teal
                            border: Border.all(
                              color: _isFailed
                                  ? const Color(
                                      0xFFEF4444,
                                    ) // Bright red outline
                                  : _authSuccess
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withValues(alpha: 0.18),
                              width: _isFailed ? 2.0 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isFailed
                                    ? const Color(0x35EF4444)
                                    : Colors.black.withValues(alpha: 0.12),
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
                                  size: 50,
                                )
                              : _isAuthenticating
                              ? const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.8,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : CustomPaint(
                                  size: const Size(54, 54),
                                  painter: _FaceIdIconPainter(
                                    color: _isFailed
                                        ? const Color(0xFFEF4444)
                                        : Colors.white,
                                    strokeWidth: 2.8,
                                    isFailed: _isFailed,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // 4. Headline & Subtitle / Prompt
                if (_isFailed) ...[
                  Text(
                    widget.failedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      widget.failedSubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: _triggerScan,
                    child: Text(
                      _isAuthenticating
                          ? "Verifying Face ID..."
                          : _authSuccess
                          ? "Verified!"
                          : widget.promptText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ],

                const Spacer(flex: 4),

                // 5. Bottom Controls (Failed state buttons vs Normal state text link)
                if (_isFailed) ...[
                  Text(
                    widget.errorBannerText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _triggerScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF628E8E),
                        foregroundColor: const Color(0xFF103636),
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
                          color: const Color(0xFF103636),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _navigateToSignIn,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 1.5,
                        ),
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
                  const SizedBox(height: 16),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: TextButton(
                      onPressed: _navigateToSignIn,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.85),
                      ),
                      child: Text(
                        widget.alternativeOptionText,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
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
/// - 4 curved corner brackets
/// - Two eye slit lines
/// - Subtle vertical nose line
/// - Curved smile in normal mode / Straight flat mouth line in failed mode
class _FaceIdIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isFailed;

  const _FaceIdIconPainter({
    required this.color,
    required this.strokeWidth,
    this.isFailed = false,
  });

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

    // 1. Top Left Bracket
    final pathTL = Path()
      ..moveTo(sx(4), sy(14))
      ..lineTo(sx(4), sy(8))
      ..cubicTo(sx(4), sy(5.79), sx(5.79), sy(4), sx(8), sy(4))
      ..lineTo(sx(14), sy(4));
    canvas.drawPath(pathTL, paint);

    // 2. Top Right Bracket
    final pathTR = Path()
      ..moveTo(sx(40), sy(4))
      ..lineTo(sx(46), sy(4))
      ..cubicTo(sx(48.21), sy(4), sx(50), sy(5.79), sx(50), sy(8))
      ..lineTo(sx(50), sy(14));
    canvas.drawPath(pathTR, paint);

    // 3. Bottom Left Bracket
    final pathBL = Path()
      ..moveTo(sx(4), sy(40))
      ..lineTo(sx(4), sy(46))
      ..cubicTo(sx(4), sy(48.21), sx(5.79), sy(50), sx(8), sy(50))
      ..lineTo(sx(14), sy(50));
    canvas.drawPath(pathBL, paint);

    // 4. Bottom Right Bracket
    final pathBR = Path()
      ..moveTo(sx(40), sy(50))
      ..lineTo(sx(46), sy(50))
      ..cubicTo(sx(48.21), sy(50), sx(50), sy(48.21), sx(50), sy(46))
      ..lineTo(sx(50), sy(40));
    canvas.drawPath(pathBR, paint);

    // 5. Left Eye
    final eyePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.05
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(sx(19), sy(20)), Offset(sx(19), sy(23)), eyePaint);

    // 6. Right Eye
    canvas.drawLine(Offset(sx(35), sy(20)), Offset(sx(35), sy(23)), eyePaint);

    // 7. Nose
    canvas.drawLine(Offset(sx(27), sy(24)), Offset(sx(27), sy(30)), paint);

    // 8. Mouth: Straight flat line if failed, curved smile if normal
    if (isFailed) {
      canvas.drawLine(Offset(sx(21), sy(37)), Offset(sx(33), sy(37)), paint);
    } else {
      final smilePath = Path()
        ..moveTo(sx(19), sy(36))
        ..cubicTo(sx(21.5), sy(39), sx(32.5), sy(39), sx(35), sy(36));
      canvas.drawPath(smilePath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceIdIconPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.isFailed != isFailed;
}

/// Screen: Biometric Fail (`screen-biometric-fail`)
/// Unified alias: instantiates `BiometricLoginScreen` in its failed state.
class BiometricFailScreen extends StatelessWidget {
  final VoidCallback? onUsePasswordInstead;
  final VoidCallback? onTryAgain;
  final VoidCallback? onAuthenticated;

  const BiometricFailScreen({
    super.key,
    this.onUsePasswordInstead,
    this.onTryAgain,
    this.onAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return BiometricLoginScreen(
      isFailed: true,
      onUsePasswordInstead: onUsePasswordInstead,
      onTryAgain: onTryAgain,
      onAuthenticated: onAuthenticated,
    );
  }
}
