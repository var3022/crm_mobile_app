import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
// ignore: unused_import
import "../../../core/widgets/app_button.dart";

/// Screen 2: Sign In Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Sign In screen.
class SignInScreen extends StatefulWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onCompanySSO;
  final VoidCallback? onBiometricLogin;
  final VoidCallback? onContactSupport;

  const SignInScreen({
    super.key,
    this.onSignInSuccess,
    this.onForgotPassword,
    this.onCompanySSO,
    this.onBiometricLogin,
    this.onContactSupport,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _hasAttemptedSubmit =
      false; // Validation errors are only shown when user attempts submit with empty field
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty) {
        _emailError = "Email address is required";
      } else if (!email.contains("@") || !email.contains(".")) {
        _emailError = "Email address is invalid";
      } else {
        _emailError = null;
      }

      if (password.isEmpty) {
        _passwordError = "Password is required";
      } else if (password.length < 6) {
        _passwordError = "Password must be at least 6 characters";
      } else {
        _passwordError = null;
      }
    });

    if (_emailError == null && _passwordError == null) {
      widget.onSignInSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // 1. Top Logo Row: [LP Icon] + "CRM Pro"
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "LP",
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "CRM Pro",
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 2. Headings: "Welcome Back" & subtitle
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Sign in to continue your field work.",
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.1,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // 3. Email Field
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hintText: "e.g. john@company.com",
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          hasError: _hasAttemptedSubmit && _emailError != null,
                          onChanged: (val) {
                            if (_hasAttemptedSubmit) {
                              setState(() {
                                _emailError = val.trim().isEmpty
                                    ? "Email address is required"
                                    : null;
                              });
                            }
                          },
                        ),
                        if (_hasAttemptedSubmit && _emailError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _emailError!,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.error,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // 4. Password Field
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: "Enter your password",
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          hasError:
                              _hasAttemptedSubmit && _passwordError != null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          onChanged: (val) {
                            if (_hasAttemptedSubmit) {
                              setState(() {
                                _passwordError = val.isEmpty
                                    ? "Password is required"
                                    : null;
                              });
                            }
                          },
                        ),
                        if (_hasAttemptedSubmit && _passwordError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _passwordError!,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.error,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // 5. "Forgot Password?" Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: widget.onForgotPassword,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 2.0,
                              ),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 6. Sign In Primary CTA Button (52px height)
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _validateAndSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // 7. Divider: "OR SIGN IN WITH"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                              ),
                              child: Text(
                                "OR SIGN IN WITH",
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1.0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 8a. Face ID Biometric Button
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: OutlinedButton(
                            onPressed: () {
                              if (widget.onBiometricLogin != null) {
                                widget.onBiometricLogin!();
                              } else {
                                Navigator.of(
                                  context,
                                ).pushNamed("/biometric-login");
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: AppColors.border,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.fingerprint_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Sign in with Face ID",
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 8b. Company SSO Button
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: OutlinedButton(
                            onPressed: widget.onCompanySSO,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: AppColors.border,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.apartment_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Company SSO",
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // 9. Bottom Support Footer: "Having trouble? Contact IT Support"
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 24.0,
                              bottom: 20.0,
                            ),
                            child: InkWell(
                              onTap: widget.onContactSupport,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 6.0,
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(text: "Having trouble? "),
                                      TextSpan(
                                        text: "Contact IT Support",
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    bool hasError = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? const Color(0xFFEF4444) : AppColors.border,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: const Color(0xFF9CA3AF),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
