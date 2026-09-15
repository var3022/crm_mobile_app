/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  Smartphone,
  FileCode,
  CheckCircle2,
  Copy,
  Check,
  Eye,
  EyeOff,
  Mail,
  Lock,
  Building2,
  Terminal,
  User,
  ChevronDown,
  Briefcase,
  Award,
  ChevronLeft,
  RotateCcw,
  ShieldCheck,
  ArrowRight,
  ExternalLink,
  Sparkles,
  AlertTriangle,
  Circle,
  CheckCheck
} from 'lucide-react';

export default function App() {
  const [selectedScreen, setSelectedScreen] = useState<'success' | 'reset' | 'otp' | 'forgot' | 'verification' | 'signup' | 'signin' | 'splash'>('success');
  const [activeTab, setActiveTab] = useState<'preview' | 'code' | 'instructions'>('preview');
  const [copied, setCopied] = useState(false);

  // Screen 7: Reset Password ("Set New Password") State
  const [resetNewPassword, setResetNewPassword] = useState<string>('');
  const [resetConfirmPassword, setResetConfirmPassword] = useState<string>('');
  const [resetObscureNew, setResetObscureNew] = useState<boolean>(true);
  const [resetObscureConfirm, setResetObscureConfirm] = useState<boolean>(true);
  const [resetAttempted, setResetAttempted] = useState<boolean>(false);
  const [resetNewTouched, setResetNewTouched] = useState<boolean>(false);
  const [resetConfirmTouched, setResetConfirmTouched] = useState<boolean>(false);
  const [resetLoading, setResetLoading] = useState<boolean>(false);
  const [resetSuccessMessage, setResetSuccessMessage] = useState<string | null>(null);

  // Screen 6: OTP Verification State
  const [otpDigits, setOtpDigits] = useState<string[]>(['', '', '', '', '', '']);
  const [activeOtpIndex, setActiveOtpIndex] = useState<number>(0);
  const [focusedIndex, setFocusedIndex] = useState<number | null>(null);
  const [otpCountdown, setOtpCountdown] = useState<number>(45);
  const [otpLoading, setOtpLoading] = useState<boolean>(false);
  const [otpError, setOtpError] = useState<string | null>(null);
  const [otpSuccessMessage, setOtpSuccessMessage] = useState<string | null>(null);
  const otpInputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Screen 5: Forgot Password Form State
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotAttempted, setForgotAttempted] = useState(false);
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotSuccessMessage, setForgotSuccessMessage] = useState<string | null>(null);

  // Email Verification State (Screen 4)
  const [countdown, setCountdown] = useState(45);
  const [isResending, setIsResending] = useState(false);
  const [verificationFeedback, setVerificationFeedback] = useState<string | null>(null);

  // Sign In Form State
  const [signInEmail, setSignInEmail] = useState('');
  const [signInPassword, setSignInPassword] = useState('');
  const [showSignInPassword, setShowSignInPassword] = useState(false);
  const [signInAttempted, setSignInAttempted] = useState(false);

  // Sign Up Form State
  const [fullName, setFullName] = useState('');
  const [signUpEmail, setSignUpEmail] = useState('');
  const [countryCode, setCountryCode] = useState('+91');
  const [phone, setPhone] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [designation, setDesignation] = useState('');
  const [signUpAttempted, setSignUpAttempted] = useState(false);
  const [showCountryDropdown, setShowCountryDropdown] = useState(false);
  const [showDesignationDropdown, setShowDesignationDropdown] = useState(false);
  const [submittedSuccess, setSubmittedSuccess] = useState(false);

  const countryCodes = ['+91', '+1', '+44', '+65', '+971', '+61'];
  const designations = [
    'Field Sales Executive',
    'Area Sales Manager',
    'Senior Sales Representative',
    'Territory Lead',
    'Business Development Executive',
    'Sales Director',
  ];

  // Validation rules for Sign Up
  const fullNameError = signUpAttempted && !fullName.trim() ? 'Full name is required' : '';
  const signUpEmailError =
    signUpAttempted && !signUpEmail.trim()
      ? 'Email address is required'
      : signUpAttempted && (!signUpEmail.includes('@') || !signUpEmail.includes('.'))
      ? 'Email address is invalid'
      : '';
  const phoneError = signUpAttempted && !phone.trim() ? 'Phone number is required' : '';
  const companyError = signUpAttempted && !companyName.trim() ? 'Company name is required' : '';
  const designationError = signUpAttempted && !designation ? 'Please select a designation' : '';

  // Validation rules for Sign In
  const signInEmailError =
    signInAttempted && !signInEmail.trim()
      ? 'Email address is required'
      : signInAttempted && (!signInEmail.includes('@') || !signInEmail.includes('.'))
      ? 'Email address is invalid'
      : '';
  const signInPasswordError = signInAttempted && !signInPassword.trim() ? 'Password is required' : '';

  const handleSignUpSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setSignUpAttempted(true);
    if (
      fullName.trim() &&
      signUpEmail.trim() &&
      signUpEmail.includes('@') &&
      phone.trim() &&
      companyName.trim() &&
      designation
    ) {
      setSubmittedSuccess(true);
      setTimeout(() => {
        setSubmittedSuccess(false);
        setCountdown(45);
        setSelectedScreen('verification');
      }, 1000);
    }
  };

  const handleSignInSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setSignInAttempted(true);
    if (signInEmail.trim() && signInPassword.trim()) {
      setSubmittedSuccess(true);
      setTimeout(() => setSubmittedSuccess(false), 3000);
    }
  };

  // Verification Screen Timer Effect
  useEffect(() => {
    if (selectedScreen !== 'verification') return;
    if (countdown <= 0) return;
    const interval = setInterval(() => {
      setCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, [countdown, selectedScreen]);

  // Screen 6: OTP Countdown Timer
  useEffect(() => {
    if (selectedScreen !== 'otp' || otpCountdown <= 0) return;
    const interval = setInterval(() => {
      setOtpCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, [otpCountdown, selectedScreen]);

  // Disappear invalid code warning whenever all boxes are empty
  useEffect(() => {
    const isAllEmpty = otpDigits.every((d) => !d || d.trim() === '');
    if (isAllEmpty && otpError) {
      setOtpError(null);
    }
  }, [otpDigits, otpError]);

  // Check if all 6 digits are entered
  const isOtpComplete = otpDigits.every((d) => d.trim() !== '') && otpDigits.join('').length === 6;
  const isVerifyDisabled = !isOtpComplete || otpLoading;

  const handleOtpChange = (index: number, value: string) => {
    const digitsOnly = value.replace(/\D/g, '');
    setOtpError(null);

    if (digitsOnly.length > 1) {
      const newDigits = [...otpDigits];
      for (let i = 0; i < 6 && i < digitsOnly.length; i++) {
        newDigits[i] = digitsOnly[i];
      }
      setOtpDigits(newDigits);
      const nextIndex = Math.min(digitsOnly.length, 5);
      setActiveOtpIndex(nextIndex);
      otpInputRefs.current[nextIndex]?.focus();
      return;
    }

    const newDigits = [...otpDigits];
    newDigits[index] = digitsOnly.slice(-1);
    setOtpDigits(newDigits);

    if (digitsOnly.length > 0) {
      if (index < 5) {
        setActiveOtpIndex(index + 1);
        otpInputRefs.current[index + 1]?.focus();
      } else {
        otpInputRefs.current[index]?.blur();
      }
    }
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace') {
      setOtpError(null);
      if (!otpDigits[index] && index > 0) {
        const newDigits = [...otpDigits];
        newDigits[index - 1] = '';
        setOtpDigits(newDigits);
        setActiveOtpIndex(index - 1);
        otpInputRefs.current[index - 1]?.focus();
      } else {
        const newDigits = [...otpDigits];
        newDigits[index] = '';
        setOtpDigits(newDigits);
      }
    } else if (e.key === 'ArrowLeft' && index > 0) {
      setActiveOtpIndex(index - 1);
      otpInputRefs.current[index - 1]?.focus();
    } else if (e.key === 'ArrowRight' && index < 5) {
      setActiveOtpIndex(index + 1);
      otpInputRefs.current[index + 1]?.focus();
    }
  };

  const handleOtpResend = () => {
    if (otpCountdown > 0 || otpLoading) return;
    setOtpLoading(true);
    setOtpError(null);
    setTimeout(() => {
      setOtpLoading(false);
      setOtpCountdown(45);
      setOtpSuccessMessage('New 6-digit code sent to j***@company.com');
      setTimeout(() => setOtpSuccessMessage(null), 3500);
    }, 600);
  };

  const handleVerifyOtp = () => {
    const code = otpDigits.join('');
    if (code.length < 6) {
      return;
    }
    setOtpLoading(true);
    setOtpError(null);
    setTimeout(() => {
      setOtpLoading(false);
      if (code === '123456') {
        setOtpSuccessMessage('Identity verified successfully!');
        setTimeout(() => {
          setSelectedScreen('reset');
        }, 1500);
      } else {
        setOtpError('Invalid code. Please check and try again.');
      }
    }, 700);
  };

  // Screen 7: Criteria evaluation
  const resetRuleLength = resetNewPassword.length >= 8;
  const resetRuleUpperLower = /[a-z]/.test(resetNewPassword) && /[A-Z]/.test(resetNewPassword);
  const resetRuleNumber = /[0-9]/.test(resetNewPassword);
  const resetRuleSpecial = /[!@#$%^&*(),.?":{}|<>_\-]/.test(resetNewPassword);

  const resetStrengthScore =
    (resetRuleLength ? 1 : 0) +
    (resetRuleUpperLower ? 1 : 0) +
    (resetRuleNumber ? 1 : 0) +
    (resetRuleSpecial ? 1 : 0);

  const resetStrengthLabel =
    resetNewPassword.length === 0
      ? ''
      : resetStrengthScore <= 1
      ? 'Weak'
      : resetStrengthScore === 2
      ? 'Medium'
      : 'Strong';

  const resetStrengthColor =
    resetStrengthScore <= 1 ? '#EF4444' : resetStrengthScore === 2 ? '#F59E0B' : '#10B981';

  const resetStrengthPercent =
    resetNewPassword.length === 0 ? 0 : Math.round((resetStrengthScore / 4) * 100);

  // Errors for Screen 7: show warnings on respective cases fail (all 4 cases applicable)
  const resetNewError =
    resetAttempted && resetNewPassword.length === 0
      ? 'Password must be at least 8 characters'
      : (resetAttempted || resetNewTouched) && resetNewPassword.length > 0
      ? !resetRuleLength
        ? 'Password must be at least 8 characters'
        : !resetRuleUpperLower
        ? 'Must include uppercase & lowercase letters'
        : !resetRuleNumber
        ? 'Must include a number'
        : !resetRuleSpecial
        ? 'Must include a special character'
        : null
      : null;

  const resetConfirmError =
    resetAttempted && resetConfirmPassword.length === 0
      ? 'Passwords do not match'
      : (resetAttempted || resetConfirmTouched) &&
        resetConfirmPassword.length > 0 &&
        resetConfirmPassword !== resetNewPassword
      ? 'Passwords do not match'
      : null;

  const isResetFormValid =
    resetRuleLength &&
    resetRuleUpperLower &&
    resetRuleNumber &&
    resetRuleSpecial &&
    resetConfirmPassword.length > 0 &&
    resetConfirmPassword === resetNewPassword;

  const handleResetPasswordSubmit = () => {
    setResetAttempted(true);
    setResetNewTouched(true);
    setResetConfirmTouched(true);

    if (!isResetFormValid) {
      return;
    }

    setResetLoading(true);
    setTimeout(() => {
      setResetLoading(false);
      setSelectedScreen('success');
    }, 700);
  };

  const resetPasswordDartCode = `import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
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
    _newPasswordController = TextEditingController(text: widget.initialPassword ?? "");
    _confirmPasswordController = TextEditingController(text: widget.initialConfirmPassword ?? "");

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
  bool get _hasSpecialChar => RegExp(r'[!@#\\$%^&*(),.?":{}|<>_\\-]').hasMatch(_newPasswordController.text);

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
    if ((_hasAttemptedSubmit || _confirmPasswordTouched) && confirmPass.isNotEmpty && newPass != confirmPass) {
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
        _successToastMessage = "Password reset successfully! Redirecting to Sign In...";
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
                          horizontal: AppSpacing.spacing24,
                          vertical: AppSpacing.spacing16,
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
                                  onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
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
                                    color: AppColors.success.withValues(alpha: 0.3),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
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
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                onPressed: (_isLoading || !_isFormValid) ? null : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid ? AppColors.primary : AppColors.primary.withOpacity(0.4),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                                  disabledForegroundColor: Colors.white.withOpacity(0.7),
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
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        "Reset Password",
                                        style: AppTypography.buttonLarge.copyWith(
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
              isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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

  Widget _buildRuleItem({
    required bool isMet,
    required String text,
  }) {
    return Row(
      children: [
        if (isMet)
          const Icon(
            Icons.check_rounded,
            color: Color(0xFF10B981),
            size: 18,
          )
        else
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(left: 1, right: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF94A3B8),
                width: 1.5,
              ),
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
}`;

  const passwordResetSuccessDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 8: Password Reset Success Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Password Reset Success screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class PasswordResetSuccessScreen extends StatefulWidget {
  final VoidCallback? onBackToSignIn;
  final String title;
  final String message;
  final String buttonText;

  const PasswordResetSuccessScreen({
    super.key,
    this.onBackToSignIn,
    this.title = "Password Reset!",
    this.message = "Your password has been successfully reset. You can now sign in with your new password.",
    this.buttonText = "Back to Sign In",
  });

  @override
  State<PasswordResetSuccessScreen> createState() => _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState extends State<PasswordResetSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleBackToSignIn() {
    if (widget.onBackToSignIn != null) {
      widget.onBackToSignIn!();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/sign-in",
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // 1. Success Concentric Circular Badge with Double Checkmark
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Center(
                          child: Container(
                            width: 196,
                            height: 196,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD1FADF), // Soft mint outer glow circle
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981), // Emerald green inner circle
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

                      const SizedBox(height: 36),

                      // 2. Headings & Message (Fade-in transition)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF4B5563),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 3. Primary Action Button: "Back to Sign In"
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _handleBackToSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              widget.buttonText,
                              style: AppTypography.buttonPrimary.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),
                      const SizedBox(height: 24),
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

class _DoubleCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DoubleCheckPainter({
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

    final w = size.width;
    final h = size.height;

    final path1 = Path();
    path1.moveTo(w * 0.12, h * 0.54);
    path1.lineTo(w * 0.38, h * 0.82);
    path1.lineTo(w * 0.84, h * 0.28);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(w * 0.50, h * 0.58);
    path2.lineTo(w * 0.66, h * 0.76);
    path2.lineTo(w * 0.98, h * 0.38);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _DoubleCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}`;

  const formatCountdown = (totalSec: number) => {
    const mins = Math.floor(totalSec / 60);
    const secs = totalSec % 60;
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  const handleResendEmail = () => {
    if (isResending) return;
    setIsResending(true);
    setTimeout(() => {
      setIsResending(false);
      setCountdown(45);
      setVerificationFeedback('New verification link sent to your inbox!');
      setTimeout(() => setVerificationFeedback(null), 3500);
    }, 600);
  };

  const handleOpenEmailApp = () => {
    setVerificationFeedback('Opening default email application...');
    setTimeout(() => setVerificationFeedback(null), 3000);
  };

  const maskedEmail = signUpEmail && signUpEmail.includes('@')
    ? `${signUpEmail.split('@')[0].charAt(0)}***@${signUpEmail.split('@')[1]}`
    : 'j***@company.com';

  // Forgot Password Validation and Submission
  const getForgotEmailError = () => {
    if (!forgotAttempted) return null;
    const trimmed = forgotEmail.trim();
    if (!trimmed) return 'Email address is required';
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$/;
    if (!emailRegex.test(trimmed)) return 'Email address is invalid';
    return null;
  };

  const forgotEmailError = getForgotEmailError();

  const handleForgotSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setForgotAttempted(true);
    const trimmed = forgotEmail.trim();
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$/;
    if (!trimmed || !emailRegex.test(trimmed)) {
      return;
    }
    setForgotLoading(true);
    setTimeout(() => {
      setForgotLoading(false);
      setForgotSuccessMessage(`6-digit verification code sent to ${trimmed}`);
      setTimeout(() => {
        setForgotSuccessMessage(null);
        setSelectedScreen('otp');
      }, 1000);
    }, 700);
  };

  const otpVerificationDartCode = `import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
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
    return "\${m.toString().padLeft(2, '0')}:\${s.toString().padLeft(2, '0')}";
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
      final nextIndex = (clean.length < _otpLength) ? clean.length : _otpLength - 1;
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
        _successToastMessage = "New 6-digit code sent to \${widget.email}";
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
                horizontal: AppSpacing.screenPaddingH,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
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
                            onTap: widget.onBack ??
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
                              const TextSpan(text: "We sent a 6-digit code to "),
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
                                          color: AppColors.primary
                                              .withValues(alpha: 0.12),
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
                                        ? "Resend (\${_formatTimer(_secondsRemaining)})"
                                        : "Resend Code",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
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
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.38),
                            foregroundColor: Colors.white,
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.7),
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
                                Navigator.of(context)
                                    .pushReplacementNamed("/sign-in");
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
`;

  const forgotPasswordDartCode = `import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

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
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_\`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)+$");
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

  void _handleSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
      _validateField();
    });

    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate sending 6-digit verification code
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (widget.onSendCode != null) {
        widget.onSendCode!(_emailController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              "Verification code sent to \${_emailController.text.trim()}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
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

                        const SizedBox(height: 24),

                        // 2. Lock Graphic Badge
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3),
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
                              hintText: "john.sales@company.com",
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

                        // 6. Action Button: Send Verification Code
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
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

class _LockIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LockIconPainter({
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

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

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

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.40, w, h * 0.58),
      const Radius.circular(9),
    );
    canvas.drawRRect(bodyRect, paint);

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
}`;

  const emailVerificationDartCode = `import "dart:async";
import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

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

  void _handleResend() {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
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
    });
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

                        const Spacer(flex: 2),

                        // 2. Verified Shield Graphic Badge
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3),
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
                                  const TextSpan(text: "We've sent a verification link to\\n"),
                                  TextSpan(
                                    text: widget.email,
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
                              widget.onOpenEmailApp?.call();
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

    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.18);
    shieldPath.quadraticBezierTo(w, h * 0.65, w * 0.5, h);
    shieldPath.quadraticBezierTo(0, h * 0.65, 0, h * 0.18);
    shieldPath.close();
    canvas.drawPath(shieldPath, paint);

    final checkPath = Path();
    checkPath.moveTo(w * 0.35, h * 0.48);
    checkPath.lineTo(w * 0.47, h * 0.60);
    checkPath.lineTo(w * 0.68, h * 0.38);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) => false;
}`;

  const signUpDartCode = `import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";

/// Screen 3: Sign Up Screen (Create Account)

/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Sign Up screen.
class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;
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
    "+91", "+1", "+44", "+65", "+971", "+61"
  ];

  bool _hasAttemptedSubmit = false;
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _companyError;
  String? _designationError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
      final name = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final company = _companyController.text.trim();

      _fullNameError = name.isEmpty ? "Full name is required" : null;
      if (email.isEmpty) {
        _emailError = "Email address is required";
      } else if (!email.contains("@") || !email.contains(".")) {
        _emailError = "Invalid email format";
      } else {
        _emailError = null;
      }
      _phoneError = phone.isEmpty ? "Phone number is required" : null;
      _companyError = company.isEmpty ? "Company name is required" : null;
      _designationError = (_selectedDesignation == null || _selectedDesignation!.isEmpty)
          ? "Please select a designation"
          : null;
    });

    if (_fullNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _companyError == null &&
        _designationError == null) {
      widget.onSignUpSuccess?.call();
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
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 2. Headings
              const Text(
                "Create Account",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
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
                ),
              ),

              const SizedBox(height: 24),

              // 3. Full Name Field
              const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _fullNameController,
                hintText: "e.g. John Doe",
                prefixIcon: Icons.person_outline_rounded,
                hasError: _hasAttemptedSubmit && _fullNameError != null,
              ),
              if (_hasAttemptedSubmit && _fullNameError != null) ...[
                const SizedBox(height: 5),
                Text(_fullNameError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 4. Email Address Field
              const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _emailController,
                hintText: "e.g. john@company.com",
                prefixIcon: Icons.mail_outline_rounded,
                hasError: _hasAttemptedSubmit && _emailError != null,
              ),
              if (_hasAttemptedSubmit && _emailError != null) ...[
                const SizedBox(height: 5),
                Text(_emailError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 5. Phone Number Field
              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    height: 52,
                    width: 88,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasAttemptedSubmit && _phoneError != null ? const Color(0xFFEF4444) : AppColors.border,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        items: _countryCodes.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
                        onChanged: (val) => setState(() => _selectedCountryCode = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInputField(
                      controller: _phoneController,
                      hintText: "98765 43210",
                      keyboardType: TextInputType.phone,
                      hasError: _hasAttemptedSubmit && _phoneError != null,
                    ),
                  ),
                ],
              ),
              if (_hasAttemptedSubmit && _phoneError != null) ...[
                const SizedBox(height: 5),
                Text(_phoneError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 6. Company Name Field
              const Text("Company Name", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _companyController,
                hintText: "e.g. Acme Corp",
                prefixIcon: Icons.business_center_outlined,
                hasError: _hasAttemptedSubmit && _companyError != null,
              ),
              if (_hasAttemptedSubmit && _companyError != null) ...[
                const SizedBox(height: 5),
                Text(_companyError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 7. Designation Selector
              const Text("Designation", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasAttemptedSubmit && _designationError != null ? const Color(0xFFEF4444) : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDesignation,
                    isExpanded: true,
                    hint: const Text("Select Designation"),
                    items: _designationOptions.map((desig) => DropdownMenuItem(value: desig, child: Text(desig))).toList(),
                    onChanged: (val) => setState(() => _selectedDesignation = val),
                  ),
                ),
              ),
              if (_hasAttemptedSubmit && _designationError != null) ...[
                const SizedBox(height: 5),
                Text(_designationError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 24),

              // 8. CTA Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Create Account"),
                ),
              ),

              const SizedBox(height: 26),

              // 9. OR SIGN UP WITH
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text("OR SIGN UP WITH", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 20),

              // 10. Company SSO
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: widget.onCompanySSO,
                  icon: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                  label: const Text("Company SSO"),
                ),
              ),

              const SizedBox(height: 28),

              // 11. Footer: Already have an account? Sign In
              Center(
                child: InkWell(
                  onTap: widget.onSignInTap,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: "Already have an account? "),
                        TextSpan(text: "Sign In", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
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
}`;

  const currentDartCode =
    selectedScreen === 'success'
      ? passwordResetSuccessDartCode
      : selectedScreen === 'reset'
      ? resetPasswordDartCode
      : selectedScreen === 'otp'
      ? otpVerificationDartCode
      : selectedScreen === 'forgot'
      ? forgotPasswordDartCode
      : selectedScreen === 'verification'
      ? emailVerificationDartCode
      : selectedScreen === 'signup'
      ? signUpDartCode
      : selectedScreen === 'signin'
      ? `// Refer to lib/features/authentication/screens/sign_in_screen.dart`
      : `// Refer to lib/features/authentication/screens/splash_screen.dart`;

  const copyCode = () => {
    navigator.clipboard.writeText(currentDartCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="min-h-screen bg-[#EBF0F0] text-[#111827] flex flex-col font-['Inter',sans-serif]">
      {/* Top Application Header */}
      <header className="bg-white border-b border-[#E5E7EB] px-6 py-3 flex items-center justify-between sticky top-0 z-50">
        <div className="flex items-center space-x-3">
          <div className="w-9 h-9 rounded-xl bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-sm shadow-xs">
            LP
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <h1 className="text-base font-extrabold text-[#111827]">CRM Pro Field Sales</h1>
              <span className="bg-[#ECFDF5] text-[#10B981] text-[11px] font-semibold px-2 py-0.5 rounded-md border border-[#A7F3D0]">
                {selectedScreen === 'success'
                  ? 'Screen 8: Password Reset Success'
                  : selectedScreen === 'reset'
                  ? 'Screen 7: Set New Password'
                  : selectedScreen === 'otp'
                  ? 'Screen 6: OTP Verification'
                  : selectedScreen === 'forgot'
                  ? 'Screen 5: Forgot Password'
                  : selectedScreen === 'verification'
                  ? 'Screen 4: Email Verification'
                  : selectedScreen === 'signup'
                  ? 'Screen 3: Sign Up'
                  : selectedScreen === 'signin'
                  ? 'Screen 2: Sign In'
                  : 'Screen 1: Splash'}
              </span>
            </div>
            <p className="text-xs text-[#4B5563]">
              Authentication Flow &bull; lib/features/authentication/screens/{selectedScreen === 'success' ? 'password_reset_success_screen.dart' : selectedScreen === 'reset' ? 'reset_password_screen.dart' : selectedScreen === 'otp' ? 'otp_verification_screen.dart' : selectedScreen === 'forgot' ? 'forgot_password_screen.dart' : selectedScreen === 'verification' ? 'email_verification_screen.dart' : selectedScreen === 'signup' ? 'sign_up_screen.dart' : selectedScreen === 'signin' ? 'sign_in_screen.dart' : 'splash_screen.dart'}
            </p>
          </div>
        </div>

        {/* Screen Switcher & View Switcher */}
        <div className="flex items-center space-x-3">
          {/* Switch Between Screens */}
          <div className="flex bg-[#F3F4F6] p-1 rounded-xl border border-[#E5E7EB] text-xs font-medium">
            <button
              onClick={() => setSelectedScreen('success')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'success'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Reset Success (Screen 8)
            </button>
            <button
              onClick={() => setSelectedScreen('reset')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'reset'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Set Password (Screen 7)
            </button>
            <button
              onClick={() => setSelectedScreen('otp')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'otp'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              OTP Verify (Screen 6)
            </button>
            <button
              onClick={() => setSelectedScreen('forgot')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'forgot'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Forgot Password (Screen 5)
            </button>
            <button
              onClick={() => setSelectedScreen('verification')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'verification'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Verify Email (Screen 4)
            </button>
            <button
              onClick={() => setSelectedScreen('signup')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'signup'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Sign Up (Screen 3)
            </button>
            <button
              onClick={() => setSelectedScreen('signin')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'signin'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Sign In (Screen 2)
            </button>
            <button
              onClick={() => setSelectedScreen('splash')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'splash'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Splash (Screen 1)
            </button>
          </div>

          {/* View Mode */}
          <div className="flex bg-[#F3F4F6] p-1 rounded-xl border border-[#E5E7EB] text-xs font-medium">
            <button
              onClick={() => setActiveTab('preview')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'preview'
                  ? 'bg-white text-[#0F4C4C] shadow-xs font-bold'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              <Smartphone className="w-3.5 h-3.5" />
              <span>Canvas (390&times;844)</span>
            </button>
            <button
              onClick={() => setActiveTab('code')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'code'
                  ? 'bg-white text-[#0F4C4C] shadow-xs font-bold'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              <FileCode className="w-3.5 h-3.5" />
              <span>Flutter Dart</span>
            </button>
            <button
              onClick={() => setActiveTab('instructions')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'instructions'
                  ? 'bg-white text-[#0F4C4C] shadow-xs font-bold'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              <Terminal className="w-3.5 h-3.5" />
              <span>Android Guide</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 p-6 flex justify-center items-start overflow-y-auto">
        {activeTab === 'preview' && (
          <div className="flex flex-col items-center">
            {/* Viewport Meta Details */}
            <div className="w-[390px] mb-3 flex items-center justify-between text-xs text-[#4B5563] px-1">
              <span className="font-semibold text-[#0F4C4C]">
                Clean Canvas &bull; 390 &times; 844 px
              </span>
              <span className="text-[11px] text-[#6B7280]">
                {selectedScreen === 'success'
                  ? 'Password Reset Success • Pixel-accurate Screen 8 layout'
                  : selectedScreen === 'reset'
                  ? 'Set New Password &bull; Test real-time validation & strength meter'
                  : selectedScreen === 'otp'
                  ? 'Enter all 6 digits to enable verify (test 123456 for success)'
                  : selectedScreen === 'forgot'
                  ? 'Tap "Send Verification Code" to test validation'
                  : selectedScreen === 'verification'
                  ? 'Email Verification Flow &bull; Timer & Resend'
                  : selectedScreen === 'signup'
                  ? 'Tap "Create Account" to test empty validation'
                  : 'Tap "Sign In" to test empty validation'}
              </span>
            </div>

            {/* Mobile Screen Canvas */}
            <div
              className="w-[390px] h-[844px] bg-white rounded-[32px] shadow-2xl border-[6px] border-[#1F2937] flex flex-col overflow-hidden relative select-none"
              style={{ boxShadow: '0 25px 60px -15px rgba(15, 76, 76, 0.35)' }}
            >
              {selectedScreen === 'success' ? (
                /* SCREEN 8: PASSWORD RESET SUCCESS */
                <div className="flex-1 flex flex-col justify-between px-6 pt-12 pb-8 overflow-y-auto no-scrollbar scroll-smooth">
                  <div className="flex-1 flex flex-col items-center justify-center">
                    {/* Concentric Circular Badge with Crisp White Double Checkmark */}
                    <div className="flex items-center justify-center w-[196px] h-[196px] rounded-full bg-[#D1FADF] animate-fade-in transition-all">
                      <div className="flex items-center justify-center w-[128px] h-[128px] rounded-full bg-[#10B981] shadow-lg shadow-[#10B981]/25">
                        <CheckCheck className="w-14 h-14 text-white stroke-[1.25]" />
                      </div>
                    </div>

                    {/* Title */}
                    <h2 className="mt-9 text-[#0F172A] text-[26px] font-extrabold tracking-tight text-center leading-tight">
                      Password Reset!
                    </h2>

                    {/* Subtitle / Description */}
                    <p className="mt-3 text-[#4B5563] text-[15px] font-normal leading-relaxed text-center px-4 max-w-[320px]">
                      Your password has been successfully reset. You can now sign in with your new password.
                    </p>

                    {/* Primary Action Button: Back to Sign In */}
                    <div className="w-full mt-10">
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs cursor-pointer"
                      >
                        Back to Sign In
                      </button>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'reset' ? (
                /* SCREEN 7: RESET PASSWORD SCREEN ("Set New Password") */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Top Bar: Back Button */}
                    <div className="flex items-center justify-between">
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('otp')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#0F172A] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to OTP Verification"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {resetSuccessMessage && (
                      <div className="mt-3 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{resetSuccessMessage}</span>
                      </div>
                    )}

                    {/* Screen Title & Subtitle */}
                    <div className="mt-5">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight leading-tight">
                        Set New Password
                      </h2>
                      <p className="text-[#64748B] text-[14px] font-normal mt-2 leading-relaxed">
                        Your new password must be different from previous used passwords.
                      </p>
                    </div>

                    {/* Field 1: New Password */}
                    <div className="mt-7">
                      <label className="block text-[13.5px] font-semibold text-[#0F172A] mb-2">
                        New Password
                      </label>
                      <div
                        className={`h-[52px] rounded-xl px-4 flex items-center transition-all border ${
                          resetNewError
                            ? 'bg-[#FDE8E8] border-[#F87171] focus-within:ring-2 focus-within:ring-[#F87171]/20'
                            : 'bg-white border-[#E2E8F0] focus-within:border-[#0F4C4C] focus-within:ring-2 focus-within:ring-[#0F4C4C]/10'
                        }`}
                      >
                        <input
                          type={resetObscureNew ? 'password' : 'text'}
                          value={resetNewPassword}
                          onChange={(e) => {
                            const val = e.target.value;
                            setResetNewPassword(val);
                            if (val.length > 0) {
                              setResetNewTouched(true);
                            } else if (!resetAttempted) {
                              setResetNewTouched(false);
                            }
                          }}
                          placeholder="Enter new password"
                          className="flex-1 bg-transparent text-[#0F172A] text-[15px] font-medium outline-none placeholder-[#94A3B8]"
                        />
                        <button
                          type="button"
                          onClick={() => setResetObscureNew(!resetObscureNew)}
                          className="p-1 text-[#64748B] hover:text-[#0F172A] transition-colors cursor-pointer"
                        >
                          {resetObscureNew ? (
                            <EyeOff className="w-5 h-5" />
                          ) : (
                            <Eye className="w-5 h-5" />
                          )}
                        </button>
                      </div>
                      {resetNewError && (
                        <p className="text-[12px] text-[#EF4444] mt-1.5 font-medium">
                          {resetNewError}
                        </p>
                      )}
                    </div>

                    {/* Password Strength Section */}
                    {resetNewPassword.length > 0 && (
                      <div className="mt-4">
                        <div className="flex items-center justify-between mb-1.5">
                          <span className="text-[13px] font-semibold text-[#334155]">
                            Password Strength
                          </span>
                          <span
                            className="text-[13px] font-bold"
                            style={{ color: resetStrengthColor }}
                          >
                            {resetStrengthLabel}
                          </span>
                        </div>
                        <div className="w-full h-1 bg-[#E2E8F0] rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full transition-all duration-300"
                            style={{
                              width: `${resetStrengthPercent}%`,
                              backgroundColor: resetStrengthColor,
                            }}
                          />
                        </div>
                      </div>
                    )}

                    {/* Field 2: Confirm New Password */}
                    <div className="mt-4">
                      <label className="block text-[13.5px] font-semibold text-[#0F172A] mb-2">
                        Confirm New Password
                      </label>
                      <div
                        className={`h-[52px] rounded-xl px-4 flex items-center transition-all border ${
                          resetConfirmError
                            ? 'bg-[#FDE8E8] border-[#F87171] focus-within:ring-2 focus-within:ring-[#F87171]/20'
                            : 'bg-white border-[#E2E8F0] focus-within:border-[#0F4C4C] focus-within:ring-2 focus-within:ring-[#0F4C4C]/10'
                        }`}
                      >
                        <input
                          type={resetObscureConfirm ? 'password' : 'text'}
                          value={resetConfirmPassword}
                          onChange={(e) => {
                            const val = e.target.value;
                            setResetConfirmPassword(val);
                            if (val.length > 0) {
                              setResetConfirmTouched(true);
                            } else if (!resetAttempted) {
                              setResetConfirmTouched(false);
                            }
                          }}
                          placeholder="Confirm new password"
                          className="flex-1 bg-transparent text-[#0F172A] text-[15px] font-medium outline-none placeholder-[#94A3B8]"
                        />
                        <button
                          type="button"
                          onClick={() => setResetObscureConfirm(!resetObscureConfirm)}
                          className="p-1 text-[#64748B] hover:text-[#0F172A] transition-colors cursor-pointer"
                        >
                          {resetObscureConfirm ? (
                            <EyeOff className="w-5 h-5" />
                          ) : (
                            <Eye className="w-5 h-5" />
                          )}
                        </button>
                      </div>
                      {resetConfirmError && (
                        <p className="text-[12px] text-[#EF4444] mt-1.5 font-medium">
                          {resetConfirmError}
                        </p>
                      )}
                    </div>

                    {/* Requirements Checklist */}
                    <div className="mt-5 space-y-2.5">
                      <div className="flex items-center space-x-2.5">
                        {resetRuleLength ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleLength ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          At least 8 characters long
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        {resetRuleUpperLower ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleUpperLower ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          Includes uppercase & lowercase
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        {resetRuleNumber ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleNumber ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          Includes a number
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        {resetRuleSpecial ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleSpecial ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          Includes a special character
                        </span>
                      </div>
                    </div>

                    {/* Primary CTA Button: Reset Password */}
                    <div className="mt-8">
                      <button
                        type="button"
                        onClick={handleResetPasswordSubmit}
                        disabled={!isResetFormValid || resetLoading}
                        className={`w-full h-[52px] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs ${
                          !isResetFormValid || resetLoading
                            ? 'bg-[#0F4C4C]/40 text-white/70 cursor-not-allowed'
                            : 'bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white cursor-pointer'
                        }`}
                      >
                        {resetLoading ? (
                          <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                        ) : (
                          'Reset Password'
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'otp' ? (
                /* SCREEN 6: OTP VERIFICATION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Back Button */}
                    <div>
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('forgot')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#1E293B] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to Forgot Password"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {otpSuccessMessage && (
                      <div className="mt-2 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{otpSuccessMessage}</span>
                      </div>
                    )}

                    {/* Graphic Badge: 120x120 Mint Circle with Shield-Check */}
                    <div className="flex justify-center pt-6 pb-7">
                      <div className="w-[120px] h-[120px] rounded-full bg-[#E8F5F3] flex items-center justify-center shadow-xs">
                        <svg
                          className="w-12 h-14 text-[#0F4C4C]"
                          viewBox="0 0 38 44"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.8"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          <path d="M19 2L36 7.5V23C36 32.5 28 39 19 42C10 39 2 32.5 2 23V7.5L19 2Z" />
                          <path d="M13 22L17.5 26.5L25.5 16.5" />
                        </svg>
                      </div>
                    </div>

                    {/* Screen Headline */}
                    <div className="text-center px-2">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight">
                        Verify Your Identity
                      </h2>
                      <p className="text-[#64748B] text-[15px] font-normal mt-2.5 leading-relaxed">
                        We sent a 6-digit code to{' '}
                        <strong className="text-[#0F172A] font-bold">
                          {forgotEmail.trim() ? forgotEmail.trim() : 'j***@company.com'}
                        </strong>
                      </p>
                    </div>

                    {/* 6-Digit OTP Input Row */}
                    <div className="mt-8">
                      <div className="flex justify-between items-center px-1">
                        {otpDigits.map((digit, index) => {
                          const isFocused = focusedIndex === index;
                          const hasError = otpError !== null;
                          return (
                            <input
                              key={index}
                              ref={(el) => {
                                otpInputRefs.current[index] = el;
                              }}
                              type="text"
                              inputMode="numeric"
                              pattern="[0-9]*"
                              maxLength={1}
                              value={digit}
                              onFocus={() => {
                                setFocusedIndex(index);
                                setActiveOtpIndex(index);
                              }}
                              onBlur={() => setFocusedIndex(null)}
                              onChange={(e) => handleOtpChange(index, e.target.value)}
                              onKeyDown={(e) => handleOtpKeyDown(index, e)}
                              className={`w-[48px] h-[58px] text-center text-[22px] font-extrabold rounded-xl border transition-all outline-none ${
                                hasError
                                  ? 'border-[#EF4444] text-[#0F172A] bg-white focus:border-[#EF4444] focus:ring-2 focus:ring-[#EF4444]/20'
                                  : isFocused
                                  ? 'border-[#0F4C4C] text-[#0F172A] bg-white ring-2 ring-[#0F4C4C]/20 shadow-xs'
                                  : digit
                                  ? 'border-[#CBD5E1] text-[#0F172A] bg-white'
                                  : 'border-[#E2E8F0] text-[#0F172A] bg-white'
                              }`}
                            />
                          );
                        })}
                      </div>

                      {/* Validation Error Message */}
                      {otpError && (
                        <div className="mt-3.5 flex items-center justify-center space-x-1.5 text-xs text-[#EF4444]">
                          <AlertTriangle className="w-3.5 h-3.5 shrink-0" />
                          <span className="font-medium">{otpError}</span>
                        </div>
                      )}

                      {/* Resend Code Row */}
                      <div className="mt-5 text-center">
                        <span className="text-xs text-[#64748B]">Didn&apos;t receive? </span>
                        <button
                          type="button"
                          onClick={handleOtpResend}
                          disabled={otpCountdown > 0 || otpLoading}
                          className={`text-xs font-bold transition-colors cursor-pointer ${
                            otpCountdown > 0
                              ? 'text-[#0F4C4C] cursor-not-allowed opacity-90'
                              : 'text-[#0F4C4C] underline hover:text-[#0C3E3E]'
                          }`}
                        >
                          {otpCountdown > 0
                            ? `Resend (${formatCountdown(otpCountdown)})`
                            : 'Resend Code'}
                        </button>
                      </div>

                      {/* Primary CTA: Verify Code Button */}
                      <div className="mt-7">
                        <button
                          type="button"
                          onClick={handleVerifyOtp}
                          disabled={isVerifyDisabled}
                          className={`w-full h-[52px] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs ${
                            isVerifyDisabled
                              ? 'bg-[#0F4C4C]/40 text-white/70 cursor-not-allowed'
                              : 'bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white cursor-pointer'
                          }`}
                        >
                          {otpLoading ? (
                            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                          ) : (
                            'Verify Code'
                          )}
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Bottom Footer: Back to Sign In */}
                  <div className="text-center pt-5 pb-2">
                    <p className="text-xs text-[#64748B] font-medium">
                      Back to{' '}
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                      >
                        Sign In
                      </button>
                    </p>
                  </div>
                </div>
              ) : selectedScreen === 'forgot' ? (
                /* SCREEN 5: FORGOT PASSWORD SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Back Button */}
                    <div>
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#1E293B] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to Sign In"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {forgotSuccessMessage && (
                      <div className="mt-2 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-medium">{forgotSuccessMessage}</span>
                      </div>
                    )}

                    {/* Lock Graphic Badge */}
                    <div className="flex justify-center pt-8 pb-7">
                      <div className="w-[120px] h-[120px] rounded-full bg-[#E8F5F3] flex items-center justify-center shadow-xs">
                        <svg
                          className="w-12 h-14 text-[#0F4C4C]"
                          viewBox="0 0 28 32"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.5"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          {/* Arched Shackle */}
                          <path d="M7 13V8.5a7 7 0 0 1 14 0V13" />
                          {/* Rounded Body */}
                          <rect x="3" y="13" width="22" height="16" rx="5" />
                          {/* Keyhole */}
                          <circle cx="14" cy="20" r="1.8" fill="currentColor" />
                          <path d="M14 21.8v2.6" strokeWidth="2.4" />
                        </svg>
                      </div>
                    </div>

                    {/* Screen Headline */}
                    <div className="text-center px-2">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight">
                        Forgot Password?
                      </h2>
                      <p className="text-[#64748B] text-[15px] font-normal mt-3 leading-relaxed max-w-[310px] mx-auto">
                        Enter your registered email below. We&apos;ll send you a 6-digit verification code to reset your password.
                      </p>
                    </div>

                    {/* Form Section */}
                    <form onSubmit={handleForgotSubmit} className="mt-8">
                      <div>
                        <label className="block text-sm font-semibold text-[#334155] mb-2">
                          Email Address
                        </label>

                        <div
                          className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            forgotEmailError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E2E8F0] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <Mail className="w-5 h-5 text-[#64748B] shrink-0 mr-3" />
                          <input
                            type="email"
                            value={forgotEmail}
                            onChange={(e) => setForgotEmail(e.target.value)}
                            placeholder="john.sales@company.com"
                            className="w-full text-[15px] text-[#0F172A] placeholder-[#94A3B8] outline-hidden bg-transparent"
                          />
                        </div>

                        {forgotEmailError && (
                          <p className="text-[13px] text-[#EF4444] mt-1.5 font-normal">
                            {forgotEmailError}
                          </p>
                        )}
                      </div>

                      {/* Send Verification Code CTA */}
                      <div className="pt-6">
                        <button
                          type="submit"
                          disabled={forgotLoading}
                          className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs cursor-pointer disabled:opacity-75"
                        >
                          {forgotLoading ? (
                            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                          ) : (
                            'Send Verification Code'
                          )}
                        </button>
                      </div>
                    </form>
                  </div>

                  {/* Bottom Footer Section */}
                  <div className="pt-6 pb-2">
                    <div className="text-center">
                      <p className="text-[14px] text-[#64748B]">
                        Remember your password?{' '}
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('signin')}
                          className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          Sign In
                        </button>
                      </p>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'verification' ? (
                /* SCREEN 4: EMAIL VERIFICATION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Back Button */}
                    <div>
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signup')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#1E293B] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to Sign Up"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {verificationFeedback && (
                      <div className="mt-2 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-medium">{verificationFeedback}</span>
                      </div>
                    )}

                    {/* Verified Shield Graphic Badge */}
                    <div className="flex justify-center pt-8 pb-7">
                      <div className="w-[120px] h-[120px] rounded-full bg-[#E8F5F3] flex items-center justify-center shadow-xs">
                        <svg
                          className="w-12 h-14 text-[#0F4C4C]"
                          viewBox="0 0 24 26"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.4"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          <path d="M12 2L21 5.5V13C21 18.5 16.5 22.5 12 24C7.5 22.5 3 18.5 3 13V5.5L12 2Z" />
                          <path d="M8.5 13L11 15.5L16 10" />
                        </svg>
                      </div>
                    </div>

                    {/* Screen Headline */}
                    <div className="text-center px-2">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight">
                        Verify Your Email
                      </h2>
                      <p className="text-[#64748B] text-[15px] font-normal mt-3 leading-relaxed">
                        We&apos;ve sent a verification link to<br />
                        <strong className="text-[#0F172A] font-bold">{maskedEmail}</strong>. Please check your inbox.
                      </p>
                    </div>

                    {/* Buttons */}
                    <div className="mt-9 space-y-3.5">
                      {/* Open Email App */}
                      <button
                        type="button"
                        onClick={handleOpenEmailApp}
                        className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs cursor-pointer"
                      >
                        Open Email App
                      </button>

                      {/* Resend Email */}
                      <button
                        type="button"
                        onClick={handleResendEmail}
                        disabled={countdown > 0 && !isResending}
                        className={`w-full h-[52px] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center cursor-pointer ${
                          countdown === 0 || isResending
                            ? 'bg-white border-1.5 border-[#0F4C4C] text-[#0F4C4C] hover:bg-[#F9FAFB] active:scale-[0.99]'
                            : 'bg-white border-1.5 border-[#CBD5E1] text-[#94A3B8] cursor-not-allowed opacity-90'
                        }`}
                      >
                        {isResending ? (
                          <div className="flex items-center space-x-2">
                            <RotateCcw className="w-4 h-4 animate-spin text-[#0F4C4C]" />
                            <span className="text-[#0F4C4C]">Sending...</span>
                          </div>
                        ) : (
                          'Resend Email'
                        )}
                      </button>
                    </div>

                    {/* Countdown indicator */}
                    <div className="mt-4 text-center">
                      <p className="text-[14px] text-[#64748B]">
                        Resend link available in{' '}
                        <strong className="text-[#0F4C4C] font-bold">
                          {formatCountdown(countdown)}
                        </strong>
                      </p>
                    </div>
                  </div>

                  {/* Bottom Footer Section */}
                  <div className="pt-6 pb-2">
                    <div className="text-center">
                      <p className="text-[14px] text-[#64748B]">
                        Back to{' '}
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('signin')}
                          className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          Sign In
                        </button>
                      </p>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'signup' ? (
                /* SCREEN 3: SIGN UP SCREEN */
                <div className="flex-1 flex flex-col px-6 py-6 overflow-y-auto no-scrollbar scroll-smooth">
                  {/* 1. Top Logo Row */}
                  <div className="flex items-center space-x-3 pt-1">
                    <div className="w-11 h-11 rounded-[14px] bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-lg tracking-tight shadow-xs">
                      LP
                    </div>
                    <span className="text-[#0F4C4C] font-extrabold text-[19px] tracking-tight">
                      CRM Pro
                    </span>
                  </div>

                  {/* 2. Headings */}
                  <div className="mt-7">
                    <h2 className="text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Create Account
                    </h2>
                    <p className="text-[#4B5563] text-[15px] font-normal mt-1">
                      Register to join the field sales network.
                    </p>
                  </div>

                  {/* 3. Form */}
                  <form onSubmit={handleSignUpSubmit} className="mt-6 space-y-3.5">
                    {/* Full Name */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Full Name
                      </label>
                      <div
                        className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                          fullNameError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                        }`}
                      >
                        <User className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                        <input
                          type="text"
                          value={fullName}
                          onChange={(e) => setFullName(e.target.value)}
                          placeholder="e.g. John Doe"
                          className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                        />
                      </div>
                      {fullNameError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {fullNameError}
                        </p>
                      )}
                    </div>

                    {/* Email Address */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Email Address
                      </label>
                      <div
                        className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                          signUpEmailError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                        }`}
                      >
                        <Mail className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                        <input
                          type="text"
                          value={signUpEmail}
                          onChange={(e) => setSignUpEmail(e.target.value)}
                          placeholder="e.g. john@company.com"
                          className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                        />
                      </div>
                      {signUpEmailError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {signUpEmailError}
                        </p>
                      )}
                    </div>

                    {/* Phone Number (Country code + input) */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Phone Number
                      </label>
                      <div className="flex space-x-2.5">
                        {/* Country code picker */}
                        <div className="relative">
                          <button
                            type="button"
                            onClick={() => setShowCountryDropdown(!showCountryDropdown)}
                            className={`h-[52px] w-[86px] rounded-xl border flex items-center justify-between px-3 bg-white transition-all ${
                              phoneError ? 'border-[#EF4444] ring-1 ring-[#EF4444]' : 'border-[#E5E7EB]'
                            }`}
                          >
                            <span className="text-sm font-bold text-[#111827]">{countryCode}</span>
                            <ChevronDown className="w-4 h-4 text-[#6B7280]" />
                          </button>
                          {showCountryDropdown && (
                            <div className="absolute top-14 left-0 w-24 bg-white border border-[#E5E7EB] rounded-xl shadow-lg z-20 py-1">
                              {countryCodes.map((code) => (
                                <button
                                  key={code}
                                  type="button"
                                  onClick={() => {
                                    setCountryCode(code);
                                    setShowCountryDropdown(false);
                                  }}
                                  className="w-full px-3 py-1.5 text-left text-xs font-semibold hover:bg-[#F3F4F6]"
                                >
                                  {code}
                                </button>
                              ))}
                            </div>
                          )}
                        </div>

                        {/* Phone text input */}
                        <div
                          className={`flex-1 h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            phoneError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <input
                            type="tel"
                            value={phone}
                            onChange={(e) => setPhone(e.target.value)}
                            placeholder="98765 43210"
                            className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                          />
                        </div>
                      </div>
                      {phoneError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {phoneError}
                        </p>
                      )}
                    </div>

                    {/* Company Name */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Company Name
                      </label>
                      <div
                        className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                          companyError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                        }`}
                      >
                        <Briefcase className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                        <input
                          type="text"
                          value={companyName}
                          onChange={(e) => setCompanyName(e.target.value)}
                          placeholder="e.g. Acme Corp"
                          className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                        />
                      </div>
                      {companyError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {companyError}
                        </p>
                      )}
                    </div>

                    {/* Designation Dropdown */}
                    <div className="relative">
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Designation
                      </label>
                      <button
                        type="button"
                        onClick={() => setShowDesignationDropdown(!showDesignationDropdown)}
                        className={`w-full h-[52px] rounded-xl border flex items-center justify-between px-3.5 bg-white transition-all text-left ${
                          designationError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB]'
                        }`}
                      >
                        <div className="flex items-center space-x-2.5">
                          <Award className="w-5 h-5 text-[#9CA3AF] shrink-0" />
                          <span
                            className={`text-sm ${
                              designation ? 'text-[#111827] font-medium' : 'text-[#9CA3AF]'
                            }`}
                          >
                            {designation || 'Select Designation'}
                          </span>
                        </div>
                        <ChevronDown className="w-4 h-4 text-[#6B7280]" />
                      </button>
                      {showDesignationDropdown && (
                        <div className="absolute top-[80px] left-0 right-0 bg-white border border-[#E5E7EB] rounded-xl shadow-xl z-30 py-1.5 max-h-48 overflow-y-auto">
                          {designations.map((desig) => (
                            <button
                              key={desig}
                              type="button"
                              onClick={() => {
                                setDesignation(desig);
                                setShowDesignationDropdown(false);
                              }}
                              className="w-full px-4 py-2.5 text-left text-sm text-[#111827] hover:bg-[#F3F4F6] flex items-center justify-between"
                            >
                              <span>{desig}</span>
                              {designation === desig && (
                                <Check className="w-4 h-4 text-[#0F4C4C]" />
                              )}
                            </button>
                          ))}
                        </div>
                      )}
                      {designationError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {designationError}
                        </p>
                      )}
                    </div>

                    {/* Primary CTA Button: Create Account */}
                    <div className="pt-2">
                      <button
                        type="submit"
                        className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs"
                      >
                        Create Account
                      </button>
                    </div>
                  </form>

                  {/* Divider: OR SIGN UP WITH */}
                  <div className="flex items-center my-5">
                    <div className="flex-1 border-t border-[#E5E7EB]" />
                    <span className="px-3 text-[11px] font-semibold text-[#6B7280] tracking-wider uppercase">
                      OR SIGN UP WITH
                    </span>
                    <div className="flex-1 border-t border-[#E5E7EB]" />
                  </div>

                  {/* Secondary Outlined CTA: Company SSO */}
                  <button
                    type="button"
                    className="w-full h-[52px] bg-white border border-[#E5E7EB] hover:bg-[#F9FAFB] active:scale-[0.99] text-[#111827] rounded-xl font-bold text-[15px] transition-all flex items-center justify-center space-x-2.5 shadow-2xs"
                  >
                    <Building2 className="w-5 h-5 text-[#0F4C4C]" />
                    <span>Company SSO</span>
                  </button>

                  {/* Bottom Footer: Already have an account? Sign In */}
                  <div className="pt-6 pb-4 text-center">
                    <p className="text-[13.5px] text-[#4B5563]">
                      Already have an account?{' '}
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                      >
                        Sign In
                      </button>
                    </p>
                  </div>
                </div>
              ) : selectedScreen === 'signin' ? (
                /* SCREEN 2: SIGN IN SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 py-7 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Top Logo Row */}
                    <div className="flex items-center space-x-3 pt-2">
                      <div className="w-11 h-11 rounded-[14px] bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-lg tracking-tight shadow-xs">
                        LP
                      </div>
                      <span className="text-[#0F4C4C] font-extrabold text-[19px] tracking-tight">
                        CRM Pro
                      </span>
                    </div>

                    {/* Headings */}
                    <div className="mt-8">
                      <h2 className="text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                        Welcome Back
                      </h2>
                      <p className="text-[#4B5563] text-[15px] font-normal mt-1.5">
                        Sign in to continue your field work.
                      </p>
                    </div>

                    {/* Form */}
                    <form onSubmit={handleSignInSubmit} className="mt-7 space-y-4">
                      {/* Email Address */}
                      <div>
                        <label className="block text-sm font-semibold text-[#111827] mb-2">
                          Email Address
                        </label>
                        <div
                          className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            signInEmailError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <Mail className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                          <input
                            type="text"
                            value={signInEmail}
                            onChange={(e) => setSignInEmail(e.target.value)}
                            placeholder="e.g. john@company.com"
                            className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                          />
                        </div>
                        {signInEmailError && (
                          <p className="text-[12px] text-[#EF4444] mt-1.5 font-normal">
                            {signInEmailError}
                          </p>
                        )}
                      </div>

                      {/* Password */}
                      <div>
                        <label className="block text-sm font-semibold text-[#111827] mb-2">
                          Password
                        </label>
                        <div
                          className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            signInPasswordError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <Lock className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                          <input
                            type={showSignInPassword ? 'text' : 'password'}
                            value={signInPassword}
                            onChange={(e) => setSignInPassword(e.target.value)}
                            placeholder="Enter your password"
                            className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                          />
                          <button
                            type="button"
                            onClick={() => setShowSignInPassword(!showSignInPassword)}
                            className="text-[#9CA3AF] hover:text-[#4B5563] ml-2 focus:outline-hidden"
                          >
                            {showSignInPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                          </button>
                        </div>
                        {signInPasswordError && (
                          <p className="text-[12px] text-[#EF4444] mt-1.5 font-normal">
                            {signInPasswordError}
                          </p>
                        )}
                      </div>

                      {/* Forgot Password */}
                      <div className="flex justify-end pt-0.5">
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('forgot')}
                          className="text-sm font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          Forgot Password?
                        </button>
                      </div>

                      {/* Primary CTA */}
                      <div className="pt-2">
                        <button
                          type="submit"
                          className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs"
                        >
                          Sign In
                        </button>
                      </div>
                    </form>

                    {/* Divider */}
                    <div className="flex items-center my-6">
                      <div className="flex-1 border-t border-[#E5E7EB]" />
                      <span className="px-3 text-[11px] font-semibold text-[#6B7280] tracking-wider uppercase">
                        OR SIGN IN WITH
                      </span>
                      <div className="flex-1 border-t border-[#E5E7EB]" />
                    </div>

                    {/* Company SSO */}
                    <button
                      type="button"
                      className="w-full h-[52px] bg-white border border-[#E5E7EB] hover:bg-[#F9FAFB] active:scale-[0.99] text-[#111827] rounded-xl font-bold text-[15px] transition-all flex items-center justify-center space-x-2.5 shadow-2xs"
                    >
                      <Building2 className="w-5 h-5 text-[#0F4C4C]" />
                      <span>Company SSO</span>
                    </button>
                  </div>

                  {/* Footer */}
                  <div className="pt-8 pb-3 text-center">
                    <p className="text-[13.5px] text-[#4B5563]">
                      Don&apos;t have an account?{' '}
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signup')}
                        className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                      >
                        Create Account
                      </button>
                    </p>
                  </div>
                </div>
              ) : (
                /* SCREEN 1: SPLASH SCREEN */
                <div className="flex-1 bg-[#0F4C4C] flex flex-col justify-between relative overflow-hidden">
                  <svg className="absolute inset-0 w-full h-full pointer-events-none" xmlns="http://www.w3.org/2000/svg">
                    <line x1="0" y1="380" x2="390" y2="380" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <line x1="195" y1="0" x2="195" y2="844" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <circle cx="195" cy="380" r="140" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <circle cx="195" cy="380" r="235" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <circle cx="195" cy="380" r="340" fill="none" stroke="rgba(255,255,255,0.035)" strokeWidth="1" />
                  </svg>

                  <div className="flex-1 flex flex-col items-center justify-center relative z-10 px-6">
                    <div className="w-[96px] h-[96px] bg-white rounded-[26px] flex items-center justify-center shadow-2xl">
                      <span className="text-[#0F4C4C] font-extrabold text-[36px] tracking-tight leading-none">
                        LP
                      </span>
                    </div>
                    <h2 className="text-white text-[28px] font-extrabold tracking-tight text-center mt-7 leading-tight">
                      CRM Pro Field Sales
                    </h2>
                    <p className="text-[#D3E4E4] text-[16px] font-normal text-center mt-2 tracking-normal">
                      Your field. Your leads. Your wins.
                    </p>
                  </div>

                  <div className="pb-10 flex flex-col items-center justify-center relative z-10">
                    <span className="text-[#8BA7A7] text-[12px] font-normal tracking-wide">
                      v1.0.0
                    </span>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'code' && (
          <div className="w-full max-w-4xl bg-white rounded-2xl border border-[#E5E7EB] shadow-xs overflow-hidden">
            <div className="bg-[#1F2937] px-6 py-4 flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <FileCode className="w-4 h-4 text-[#10B981]" />
                <span className="font-mono text-xs text-gray-200 font-semibold">
                  lib/features/authentication/screens/{selectedScreen === 'reset' ? 'reset_password_screen.dart' : selectedScreen === 'otp' ? 'otp_verification_screen.dart' : selectedScreen === 'forgot' ? 'forgot_password_screen.dart' : selectedScreen === 'verification' ? 'email_verification_screen.dart' : selectedScreen === 'signup' ? 'sign_up_screen.dart' : selectedScreen === 'signin' ? 'sign_in_screen.dart' : 'splash_screen.dart'}
                </span>
              </div>
              <button
                onClick={copyCode}
                className="flex items-center space-x-1.5 px-3 py-1.5 rounded-lg bg-gray-700 hover:bg-gray-600 text-xs text-white font-medium transition-all cursor-pointer"
              >
                {copied ? <Check className="w-3.5 h-3.5 text-[#10B981]" /> : <Copy className="w-3.5 h-3.5" />}
                <span>{copied ? 'Copied' : 'Copy Dart Code'}</span>
              </button>
            </div>
            <pre className="p-6 bg-[#111827] text-gray-200 font-mono text-xs overflow-x-auto leading-relaxed max-h-[700px]">
              <code>{currentDartCode}</code>
            </pre>
          </div>
        )}

        {activeTab === 'instructions' && (
          <div className="w-full max-w-3xl bg-white rounded-2xl border border-[#E5E7EB] p-8 shadow-xs space-y-6">
            <div className="flex items-start space-x-3">
              <div className="w-10 h-10 rounded-xl bg-[#E6F0F0] text-[#0F4C4C] flex items-center justify-center shrink-0">
                <Terminal className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg font-extrabold text-[#111827]">Running in Android Studio</h2>
                <p className="text-xs text-[#4B5563] mt-0.5">
                  Execute the Sign Up flow locally on Android emulator or physical device.
                </p>
              </div>
            </div>

            <div className="space-y-4 text-xs text-[#111827]">
              <div className="p-4 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB]">
                <p className="font-bold text-[#0F4C4C] mb-1">Step 1: Open in Android Studio</p>
                <p className="text-[#4B5563]">
                  Select <strong>File &rarr; Open</strong> and choose this repository directory.
                </p>
              </div>

              <div className="p-4 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB]">
                <p className="font-bold text-[#0F4C4C] mb-1">Step 2: Fetch Packages</p>
                <code className="block bg-[#111827] text-green-400 p-2.5 rounded-lg font-mono">
                  flutter pub get
                </code>
              </div>

              <div className="p-4 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB]">
                <p className="font-bold text-[#0F4C4C] mb-1">Step 3: Run Flutter App</p>
                <code className="block bg-[#111827] text-green-400 p-2.5 rounded-lg font-mono">
                  flutter run
                </code>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
