import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";
import "../repositories/auth_repository.dart";

/// Screen 5: Forgot Password Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Forgot Password screen.
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onSendCode;
  final VoidCallback? onSignInTap;
  final String? initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.onBack,
    this.onSendCode,
    this.onSignInTap,
    this.initialEmail,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;
  String? _emailError;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$",
    );
    return emailRegex.hasMatch(email.trim());
  }

  void _validateField() {
    final text = _emailController.text.trim();
    if (text.isEmpty) {
      _emailError = "Email address is required";
    } else if (!_isValidEmail(text)) {
      _emailError = "Email address is invalid";
    } else {
      _emailError = null;
    }
  }

  void _handleSubmit() async {
    setState(() {
      _hasAttemptedSubmit = true;
      _validateField();
    });

    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    try {
      final authRepo = AuthRepository();
      await authRepo.forgotPassword(_emailController.text.trim());

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (widget.onSendCode != null) {
        widget.onSendCode!(_emailController.text.trim());
      } else {
        Navigator.of(context).pushNamed(
          "/otp-verification",
          arguments: {
            "email": _emailController.text.trim(),
            "purpose": "password_reset",
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _apiError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // 1. Top Navigation Bar: Back Button
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
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusBackButton,
                            ),
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

                        const SizedBox(height: 24),

                        // 2. Lock Graphic Badge
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(
                                0xFFE8F5F3,
                              ), // Soft mint / brand teal tint
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(44, 48),
                                painter: _LockIconPainter(
                                  color: AppColors.primary,
                                  strokeWidth: 2.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 3. Screen Title
                        Center(
                          child: Text(
                            "Forgot Password?",
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

                        // 4. Instructions Subtitle
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Enter your registered email below. We'll send you a 6-digit verification code to reset your password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 15,
                                height: 1.45,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 5. Email Address Input Field
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) {
                              if (_hasAttemptedSubmit) {
                                setState(() {
                                  _validateField();
                                });
                              }
                            },
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter your registered email",
                              hintStyle: const TextStyle(
                                fontFamily: "Inter",
                                color: Color(0xFF94A3B8),
                                fontSize: 15,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 14, right: 12),
                                child: Icon(
                                  Icons.mail_outline_rounded,
                                  size: 22,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 46,
                                minHeight: 46,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFE2E8F0),
                                  width: _emailError != null ? 1.4 : 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null
                                      ? const Color(0xFFEF4444)
                                      : AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Error message
                        if (_emailError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 13,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        if (_apiError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _apiError!,
                                    style: const TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 13,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 6. Action Button: Send Verification Code
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusButton,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Send Verification Code",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const Spacer(),

                        // 7. Footer: Remember your password? Sign In
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 24.0,
                            top: 20.0,
                          ),
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
                                    TextSpan(text: "Remember your password? "),
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

/// Custom painter for the Lock icon matching the reference artwork
class _LockIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LockIconPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Shackle (top arched loop)
    final shacklePath = Path();
    final shackleLeft = w * 0.22;
    final shackleRight = w * 0.78;
    final shackleTop = h * 0.04;
    final shackleBottom = h * 0.44;

    shacklePath.moveTo(shackleLeft, shackleBottom);
    shacklePath.lineTo(shackleLeft, shackleTop + (w * 0.28));
    shacklePath.arcToPoint(
      Offset(shackleRight, shackleTop + (w * 0.28)),
      radius: Radius.circular((shackleRight - shackleLeft) / 2),
      clockwise: true,
    );
    shacklePath.lineTo(shackleRight, shackleBottom);

    canvas.drawPath(shacklePath, paint);

    // 2. Lock Body (rounded rectangle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.40, w, h * 0.58),
      const Radius.circular(9),
    );
    canvas.drawRRect(bodyRect, paint);

    // 3. Keyhole (circle + small notch)
    final keyholeCenter = Offset(w * 0.5, h * 0.65);
    canvas.drawCircle(keyholeCenter, 3.2, fillPaint);

    final notchPath = Path();
    notchPath.moveTo(w * 0.46, h * 0.67);
    notchPath.lineTo(w * 0.54, h * 0.67);
    notchPath.lineTo(w * 0.53, h * 0.77);
    notchPath.lineTo(w * 0.47, h * 0.77);
    notchPath.close();
    canvas.drawPath(notchPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _LockIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
