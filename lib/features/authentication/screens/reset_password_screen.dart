import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
// ignore: unused_import
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 7: Reset Password Screen ("Set New Password")
/// Pixel-accurate reproduction of the CRM Pro Field Sales Set New Password screen.
class ResetPasswordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onResetSuccess;
  final VoidCallback? onSignInTap;
  final String? initialPassword;
  final String? initialConfirmPassword;

  const ResetPasswordScreen({
    super.key,
    this.onBack,
    this.onResetSuccess,
    this.onSignInTap,
    this.initialPassword,
    this.initialConfirmPassword,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;
  bool _newPasswordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _showSuccessToast = false;
  String _successToastMessage = "";

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController(
      text: widget.initialPassword ?? "",
    );
    _confirmPasswordController = TextEditingController(
      text: widget.initialConfirmPassword ?? "",
    );

    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onConfirmPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Password validation criteria
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUpperAndLower {
    final text = _newPasswordController.text;
    return RegExp(r"(?=.*[a-z])(?=.*[A-Z])").hasMatch(text);
  }

  bool get _hasNumber => RegExp(r"[0-9]").hasMatch(_newPasswordController.text);
  bool get _hasSpecialChar => RegExp(
    r'[!@#$%^&*(),.?":{}|<>_\-]',
  ).hasMatch(_newPasswordController.text);

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUpperAndLower) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  String get _strengthLabel {
    final text = _newPasswordController.text;
    if (text.isEmpty) return "";
    final score = _strengthScore;
    if (score <= 1) return "Weak";
    if (score == 2) return "Medium";
    return "Strong";
  }

  Color get _strengthColor {
    final score = _strengthScore;
    if (score <= 1) return AppColors.error;
    if (score == 2) return AppColors.warning;
    return AppColors.success;
  }

  double get _strengthProgress {
    final text = _newPasswordController.text;
    if (text.isEmpty) return 0.0;
    return (_strengthScore / 4).clamp(0.0, 1.0);
  }

  String? get _newPasswordError {
    final text = _newPasswordController.text;
    if (_hasAttemptedSubmit && text.isEmpty) {
      return "Password must be at least 8 characters";
    }
    if ((_hasAttemptedSubmit || _newPasswordTouched) && text.isNotEmpty) {
      if (!_hasMinLength) {
        return "Password must be at least 8 characters";
      }
      if (!_hasUpperAndLower) {
        return "Must include uppercase & lowercase letters";
      }
      if (!_hasNumber) {
        return "Must include a number";
      }
      if (!_hasSpecialChar) {
        return "Must include a special character";
      }
    }
    return null;
  }

  String? get _confirmPasswordError {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    if (_hasAttemptedSubmit && confirmPass.isEmpty) {
      return "Passwords do not match";
    }
    if ((_hasAttemptedSubmit || _confirmPasswordTouched) &&
        confirmPass.isNotEmpty &&
        newPass != confirmPass) {
      return "Passwords do not match";
    }
    return null;
  }

  bool get _isFormValid {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    return _hasMinLength &&
        _hasUpperAndLower &&
        _hasNumber &&
        _hasSpecialChar &&
        confirmPass.isNotEmpty &&
        newPass == confirmPass;
  }

  void _handleResetPassword() {
    setState(() {
      _hasAttemptedSubmit = true;
      _newPasswordTouched = true;
      _confirmPasswordTouched = true;
    });

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showSuccessToast = true;
        _successToastMessage =
            "Password reset successfully! Redirecting to Sign In...";
      });

      widget.onResetSuccess?.call(_newPasswordController.text);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        widget.onSignInTap?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl24,
                          vertical: AppSpacing.lg16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Semantics(
                                button: true,
                                label: "Back to previous screen",
                                child: InkWell(
                                  onTap:
                                      widget.onBack ??
                                      () => Navigator.of(context).maybePop(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.chevron_left_rounded,
                                      size: 30,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Feedback Toast
                            if (_showSuccessToast) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  border: Border.all(
                                    color: AppColors.success.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
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
                                        style: AppTypography.caption.copyWith(
                                          color: const Color(0xFF065F46),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Headline
                            Text(
                              "Set New Password",
                              style: AppTypography.h1.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your new password must be different from previous used passwords.",
                              style: AppTypography.bodyMedium.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Field 1: New Password
                            _buildLabel("New Password"),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _newPasswordController,
                              isObscured: _obscureNewPassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              hasError: _newPasswordError != null,
                              onChanged: (val) {
                                setState(() {
                                  if (val.isNotEmpty) {
                                    _newPasswordTouched = true;
                                  } else if (!_hasAttemptedSubmit) {
                                    _newPasswordTouched = false;
                                  }
                                });
                              },
                              hintText: "Enter new password",
                            ),

                            // New Password Error Message
                            if (_newPasswordError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _newPasswordError!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // Password Strength Row & Meter
                            if (_newPasswordController.text.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Password Strength",
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    _strengthLabel,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: _strengthColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 4,
                                  child: LinearProgressIndicator(
                                    value: _strengthProgress,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _strengthColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],

                            // Field 2: Confirm New Password
                            _buildLabel("Confirm New Password"),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              isObscured: _obscureConfirmPassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              hasError: _confirmPasswordError != null,
                              onChanged: (val) {
                                setState(() {
                                  if (val.isNotEmpty) {
                                    _confirmPasswordTouched = true;
                                  } else if (!_hasAttemptedSubmit) {
                                    _confirmPasswordTouched = false;
                                  }
                                });
                              },
                              hintText: "Confirm new password",
                            ),

                            // Confirm Password Error Message
                            if (_confirmPasswordError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _confirmPasswordError!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // Requirements Checklist
                            _buildRuleItem(
                              isMet: _hasMinLength,
                              text: "At least 8 characters long",
                            ),
                            const SizedBox(height: 10),
                            _buildRuleItem(
                              isMet: _hasUpperAndLower,
                              text: "Includes uppercase & lowercase",
                            ),
                            const SizedBox(height: 10),
                            _buildRuleItem(
                              isMet: _hasNumber,
                              text: "Includes a number",
                            ),
                            const SizedBox(height: 10),
                            _buildRuleItem(
                              isMet: _hasSpecialChar,
                              text: "Includes a special character",
                            ),

                            const SizedBox(height: 32),

                            // Primary CTA: Reset Password Button (disabled until all cases pass)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: (_isLoading || !_isFormValid)
                                    ? null
                                    : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid
                                      ? AppColors.primary
                                      : AppColors.primary.withOpacity(0.4),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary
                                      .withOpacity(0.4),
                                  disabledForegroundColor: Colors.white
                                      .withOpacity(0.7),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        "Reset Password",
                                        style: AppTypography.buttonPrimary
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleObscure,
    required bool hasError,
    required ValueChanged<String> onChanged,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFDE8E8) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? const Color(0xFFF87171) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        onChanged: onChanged,
        style: AppTypography.bodyMedium.copyWith(
          color: const Color(0xFF0F172A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              isObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: onToggleObscure,
            splashRadius: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem({required bool isMet, required String text}) {
    return Row(
      children: [
        if (isMet)
          const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18)
        else
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(left: 1, right: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: isMet ? const Color(0xFF334155) : const Color(0xFF64748B),
            fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
