import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../../../core/theme/app_colors.dart";
// ignore: unused_import
import "../../../core/theme/app_typography.dart";
// ignore: unused_import
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 6: OTP Verification Screen ("Verify Your Identity")
/// Pixel-accurate reproduction of the CRM Pro Field Sales OTP Verification screen.
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onBack;
  final ValueChanged<String>? onVerifySuccess;
  final VoidCallback? onResend;
  final VoidCallback? onSignInTap;
  final int initialCountdownSeconds;
  final String? initialError;

  const OtpVerificationScreen({
    super.key,
    this.email = "j***@company.com",
    this.onBack,
    this.onVerifySuccess,
    this.onResend,
    this.onSignInTap,
    this.initialCountdownSeconds = 45,
    this.initialError,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  bool _showSuccessToast = false;
  String _successToastMessage = "";

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _secondsRemaining = widget.initialCountdownSeconds;
    _errorMessage = widget.initialError;

    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String get _currentOtp =>
      _controllers.map((controller) => controller.text).join();

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty) &&
      _currentOtp.length == _otpLength;

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.length > 1) {
      // Handle paste of multiple characters
      final clean = value.replaceAll(RegExp(r"[^0-9]"), "");
      for (int i = 0; i < _otpLength && i < clean.length; i++) {
        _controllers[i].text = clean[i];
      }
      final nextIndex = (clean.length < _otpLength)
          ? clean.length
          : _otpLength - 1;
      _focusNodes[nextIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handleBackspace(int index) {
    setState(() {
      _errorMessage = null;
    });
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    } else {
      _controllers[index].clear();
    }
  }

  void _handleResend() {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _secondsRemaining = widget.initialCountdownSeconds;
        _showSuccessToast = true;
        _successToastMessage = "New 6-digit code sent to ${widget.email}";
      });
      _startTimer();
      widget.onResend?.call();

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showSuccessToast = false;
          });
        }
      });
    });
  }

  void _handleVerify() {
    final otp = _currentOtp;
    if (otp.length < _otpLength) {
      setState(() {
        _errorMessage = "Invalid code. Please check and try again.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Verification logic: accept '123456' as valid or show invalid message
      if (otp == "123456") {
        setState(() {
          _showSuccessToast = true;
          _successToastMessage = "Identity verified successfully!";
        });
        widget.onVerifySuccess?.call(otp);
      } else {
        setState(() {
          _errorMessage = "Invalid code. Please check and try again.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Navigation Bar (Back Button)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap:
                                widget.onBack ??
                                () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 28,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Optional Feedback Toast
                      if (_showSuccessToast)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successToastMessage,
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 2. Graphic Badge (120x120 Mint Circle with Shield-Check)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 28.0),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(38, 44),
                                painter: _ShieldCheckPainter(
                                  color: AppColors.primary,
                                  strokeWidth: 2.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. Screen Headline
                      const Text(
                        "Verify Your Identity",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 4. Subtitle with Masked Email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF64748B),
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(
                                text: "We sent a 6-digit code to ",
                              ),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 5. 6-Digit OTP Input Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_otpLength, (index) {
                            final isFocused = _focusNodes[index].hasFocus;
                            // ignore: unused_local_variable
                            final hasValue =
                                _controllers[index].text.isNotEmpty;
                            final hasError = _errorMessage != null;

                            return Container(
                              width: 48,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: hasError
                                      ? AppColors.error
                                      : isFocused
                                      ? AppColors.primary
                                      : const Color(0xFFE2E8F0),
                                  width: isFocused || hasError ? 2.0 : 1.2,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: RawKeyboardListener(
                                focusNode: FocusNode(),
                                onKey: (event) {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace) {
                                    _handleBackspace(index);
                                  }
                                },
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                  cursorColor: AppColors.primary,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) =>
                                      _onDigitChanged(index, value),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 6. Error Message (if any)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // 7. Resend Code Countdown Row
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(text: "Didn't receive? "),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: _secondsRemaining == 0
                                      ? _handleResend
                                      : null,
                                  child: Text(
                                    _secondsRemaining > 0
                                        ? "Resend (${_formatTimer(_secondsRemaining)})"
                                        : "Resend Code",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _secondsRemaining > 0
                                          ? AppColors.primary
                                          : AppColors.primary,
                                      decoration: _secondsRemaining == 0
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 8. Primary CTA: Verify Code Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isOtpComplete)
                              ? null
                              : _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.38),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white.withValues(
                              alpha: 0.7,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Verify Code",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),

                      const Spacer(),

                      // 9. Bottom Footer: Back to Sign In
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0, top: 20.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (widget.onSignInTap != null) {
                                widget.onSignInTap!();
                              } else {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed("/sign-in");
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
    );
  }
}

/// Custom painter for the Shield with inner Checkmark
class _ShieldCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ShieldCheckPainter({required this.color, required this.strokeWidth});

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
