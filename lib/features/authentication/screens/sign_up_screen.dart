import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../repositories/auth_repository.dart";

/// Screen 3: Sign Up Screen (Create Account)
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Sign Up screen.
class SignUpScreen extends StatefulWidget {
  final ValueChanged<String>? onSignUpSuccess;
  final VoidCallback? onSignInTap;
  final VoidCallback? onCompanySSO;

  const SignUpScreen({
    super.key,
    this.onSignUpSuccess,
    this.onSignInTap,
    this.onCompanySSO,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _apiError;
  bool _obscurePassword = true;

  String _selectedCountryCode = "+91";
  String? _selectedDesignation;

  final List<String> _designationOptions = [
    "Field Sales Executive",
    "Area Sales Manager",
    "Senior Sales Representative",
    "Territory Lead",
    "Business Development Executive",
    "Sales Director",
  ];

  final List<String> _countryCodes = [
    "+91",
    "+1",
    "+44",
    "+65",
    "+971",
    "+61",
  ];

  bool _hasAttemptedSubmit = false;
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _companyError;
  String? _designationError;
  String? _passwordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _hasAttemptedSubmit = true;
      final name = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final company = _companyController.text.trim();

      // Full Name Validation
      if (name.isEmpty) {
        _fullNameError = "Full name is required";
      } else {
        _fullNameError = null;
      }

      // Email Validation
      if (email.isEmpty) {
        _emailError = "Email address is required";
      } else if (!email.contains("@") || !email.contains(".")) {
        _emailError = "Email address is invalid";
      } else {
        _emailError = null;
      }

      // Phone Validation
      if (phone.isEmpty) {
        _phoneError = "Phone number is required";
      } else if (phone.length < 7) {
        _phoneError = "Please enter a valid phone number";
      } else {
        _phoneError = null;
      }

      // Company Name Validation
      if (company.isEmpty) {
        _companyError = "Company name is required";
      } else {
        _companyError = null;
      }

      // Designation Validation
      if (_selectedDesignation == null || _selectedDesignation!.isEmpty) {
        _designationError = "Please select a designation";
      } else {
        _designationError = null;
      }

      // Password Validation
      final password = _passwordController.text;
      if (password.isEmpty) {
        _passwordError = "Password is required";
      } else if (password.length < 6) {
        _passwordError = "Password must be at least 6 characters";
      } else {
        _passwordError = null;
      }
    });

    if (_fullNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _companyError == null &&
        _designationError == null &&
        _passwordError == null) {
      
      setState(() {
        _isLoading = true;
        _apiError = null;
      });

      try {
        final authRepo = AuthRepository();
        
        final nameParts = _fullNameController.text.trim().split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final companyName = _companyController.text.trim();
        final subdomain = companyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');

        await authRepo.register(
          tenantName: companyName,
          subdomain: subdomain,
          adminEmail: _emailController.text.trim(),
          adminPassword: _passwordController.text,
          adminFirstName: firstName,
          adminLastName: lastName,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        final email = _emailController.text.trim();
        if (widget.onSignUpSuccess != null) {
          widget.onSignUpSuccess!(email);
        } else {
          Navigator.of(context).pushNamed("/email-verification", arguments: email);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

              const SizedBox(height: 28),

              // 2. Headings: "Create Account" & subtitle
              const Text(
                "Create Account",
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
                "Register to join the field sales network.",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 24),

              // 3. Full Name
              const Text(
                "Full Name",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _fullNameController,
                hintText: "e.g. John Doe",
                prefixIcon: Icons.person_outline_rounded,
                hasError: _hasAttemptedSubmit && _fullNameError != null,
                onChanged: (val) {
                  if (_hasAttemptedSubmit) {
                    setState(() {
                      _fullNameError = val.trim().isEmpty ? "Full name is required" : null;
                    });
                  }
                },
              ),
              if (_hasAttemptedSubmit && _fullNameError != null) ...[
                const SizedBox(height: 5),
                Text(
                  _fullNameError!,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 4. Email Address
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
                      if (val.trim().isEmpty) {
                        _emailError = "Email address is required";
                      } else if (!val.contains("@") || !val.contains(".")) {
                        _emailError = "Invalid email format";
                      } else {
                        _emailError = null;
                      }
                    });
                  }
                },
              ),
              if (_hasAttemptedSubmit && _emailError != null) ...[
                const SizedBox(height: 5),
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

              // 5. Phone Number (Country Code Dropdown + Phone Input)
              const Text(
                "Phone Number",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Code Dropdown Container
                  Container(
                    height: 52,
                    width: 88,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasAttemptedSubmit && _phoneError != null
                            ? const Color(0xFFEF4444)
                            : AppColors.border,
                        width: 1.2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        items: _countryCodes.map((code) {
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCountryCode = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Phone Number Input
                  Expanded(
                    child: _buildInputField(
                      controller: _phoneController,
                      hintText: "98765 43210",
                      keyboardType: TextInputType.phone,
                      hasError: _hasAttemptedSubmit && _phoneError != null,
                      onChanged: (val) {
                        if (_hasAttemptedSubmit) {
                          setState(() {
                            _phoneError = val.trim().isEmpty ? "Phone number is required" : null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_hasAttemptedSubmit && _phoneError != null) ...[
                const SizedBox(height: 5),
                Text(
                  _phoneError!,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 6. Company Name
              const Text(
                "Company Name",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _companyController,
                hintText: "e.g. Acme Corp",
                prefixIcon: Icons.business_center_outlined,
                hasError: _hasAttemptedSubmit && _companyError != null,
                onChanged: (val) {
                  if (_hasAttemptedSubmit) {
                    setState(() {
                      _companyError = val.trim().isEmpty ? "Company name is required" : null;
                    });
                  }
                },
              ),
              if (_hasAttemptedSubmit && _companyError != null) ...[
                const SizedBox(height: 5),
                Text(
                  _companyError!,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 7. Designation Dropdown Selector
              const Text(
                "Designation",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasAttemptedSubmit && _designationError != null
                        ? const Color(0xFFEF4444)
                        : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDesignation,
                    isExpanded: true,
                    hint: Row(
                      children: const [
                        Icon(
                          Icons.military_tech_outlined,
                          size: 20,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Select Designation",
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                    items: _designationOptions.map((desig) {
                      return DropdownMenuItem<String>(
                        value: desig,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.military_tech_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                desig,
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDesignation = val;
                        if (_hasAttemptedSubmit) {
                          _designationError = null;
                        }
                      });
                    },
                  ),
                ),
              ),
              if (_hasAttemptedSubmit && _designationError != null) ...[
                const SizedBox(height: 5),
                Text(
                  _designationError!,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 7.5 Password Field
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
                hasError: _hasAttemptedSubmit && _passwordError != null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                      _passwordError = val.isEmpty ? "Password is required" : null;
                    });
                  }
                },
              ),
              if (_hasAttemptedSubmit && _passwordError != null) ...[
                const SizedBox(height: 5),
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

              const SizedBox(height: 24),

              if (_apiError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _apiError!,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 8. Create Account Primary CTA Button (52px height)
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 26),

              // 9. Divider: "OR SIGN UP WITH"
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: AppColors.border,
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      "OR SIGN UP WITH",
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

              // 10. Company SSO Button
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

              const SizedBox(height: 28),

              // 11. Bottom Footer: "Already have an account? Sign In"
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: widget.onSignInTap,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(text: "Already have an account? "),
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
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                )
              : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
