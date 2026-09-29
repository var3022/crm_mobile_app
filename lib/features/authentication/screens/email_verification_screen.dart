import "dart:async";
import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";
import "../repositories/auth_repository.dart";

/// Screen 4: Email Verification Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Email Verification screen.
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onBack;
  final VoidCallback? onOpenEmailApp;
  final VoidCallback? onResendEmail;
  final VoidCallback? onSignInTap;
  final int initialCountdownSeconds;

  const EmailVerificationScreen({
    super.key,
    this.email = "j***@company.com",
    this.onBack,
    this.onOpenEmailApp,
    this.onResendEmail,
    this.onSignInTap,
    this.initialCountdownSeconds = 45,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _isResending = false;
  bool _showSuccessBanner = false;
  String? _apiError;

  String _maskEmail(String rawEmail) {
    if (rawEmail.isEmpty) return "j***@company.com";
    if (rawEmail.contains("***")) return rawEmail;
    final parts = rawEmail.split("@");
    if (parts.length != 2) return rawEmail;
    final name = parts[0];
    final domain = parts[1];
    if (name.isEmpty) return rawEmail;
    return "${name[0]}***@$domain";
  }

  String get _displayEmail {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final emailToUse = (routeArg is String && routeArg.isNotEmpty)
        ? routeArg
        : widget.email;
    return _maskEmail(emailToUse);
  }

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialCountdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleResend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _apiError = null;
    });

    try {
      final emailToUse = _displayEmail.contains("***") 
          ? (ModalRoute.of(context)?.settings.arguments as String? ?? widget.email)
          : _displayEmail;

      final authRepo = AuthRepository();
      await authRepo.resendVerificationEmail(emailToUse);

      if (!mounted) return;
      
      setState(() {
        _isResending = false;
        _secondsRemaining = widget.initialCountdownSeconds;
        _showSuccessBanner = true;
      });
      
      _startTimer();
      widget.onResendEmail?.call();

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showSuccessBanner = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
          _apiError = e.toString();
        });
      }
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesStr = minutes.toString().padLeft(2, "0");
    final secondsStr = seconds.toString().padLeft(2, "0");
    return "$minutesStr:$secondsStr";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsRemaining == 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // 1. Top Navigation Bar with Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (widget.onBack != null) {
                                widget.onBack!();
                              } else {
                                Navigator.of(context).maybePop();
                              }
                            },
                            borderRadius: BorderRadius.circular(AppDimensions.radiusBackButton),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.centerLeft,
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 32,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),

                        // Feedback Notification Banner
                        if (_showSuccessBanner)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "New verification link sent to $_displayEmail",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_apiError != null)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _apiError!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(flex: 2),

                        // 2. Verified Shield Graphic Badge
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3), // Soft mint / brand teal tint
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(48, 52),
                                painter: _ShieldCheckPainter(
                                  color: AppColors.primary,
                                  strokeWidth: 2.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // 3. Screen Title
                        Center(
                          child: Text(
                            "Verify Your Email",
                            textAlign: TextAlign.center,
                            style: AppTypography.h2.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 4. Instructions & Masked Email
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Color(0xFF64748B),
                                ),
                                children: [
                                  const TextSpan(text: "We've sent a verification link to\n"),
                                  TextSpan(
                                    text: _displayEmail,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const TextSpan(text: ". Please check your inbox."),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 38),

                        // 5. Primary Action: Open Email App
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.onOpenEmailApp != null) {
                                widget.onOpenEmailApp!();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Launching mail application..."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                              ),
                            ),
                            child: const Text(
                              "Open Email App",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 6. Secondary Action: Resend Email
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: OutlinedButton(
                            onPressed: canResend && !_isResending ? _handleResend : null,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              disabledForegroundColor: const Color(0xFF94A3B8),
                              side: BorderSide(
                                color: canResend ? AppColors.primary : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                              ),
                            ),
                            child: _isResending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Text(
                                    "Resend Email",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 7. Resend Link Countdown Notice
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(text: "Resend link available in "),
                                TextSpan(
                                  text: _formatTime(_secondsRemaining),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // 8. Bottom Footer: Back to Sign In
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0, top: 20.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onSignInTap != null) {
                                  widget.onSignInTap!();
                                } else {
                                  Navigator.of(context).pushReplacementNamed("/sign-in");
                                }
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: "Back to "),
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
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
            },
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the Shield with inner Checkmark
class _ShieldCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ShieldCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Outer Shield Path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.18);
    shieldPath.quadraticBezierTo(w, h * 0.65, w * 0.5, h);
    shieldPath.quadraticBezierTo(0, h * 0.65, 0, h * 0.18);
    shieldPath.close();

    canvas.drawPath(shieldPath, paint);

    // Inner Checkmark Path
    final checkPath = Path();
    checkPath.moveTo(w * 0.35, h * 0.48);
    checkPath.lineTo(w * 0.47, h * 0.60);
    checkPath.lineTo(w * 0.68, h * 0.38);

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
