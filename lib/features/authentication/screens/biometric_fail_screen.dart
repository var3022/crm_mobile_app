import "package:flutter/material.dart";
import "biometric_login_screen.dart";

/// Authentication Screen - Biometric Fail (`screen-biometric-fail`)
///
/// Fully satisfies the user request to reuse the `BiometricLoginScreen` component page.
/// Accurately renders the failed Face ID state:
/// - Signature Deep Teal background (`#0F4C4C`)
/// - Top LP squircle app logo and "CRM Pro Field Sales" title
/// - Red ring Face ID circle with red Face ID icon
/// - "Face ID Failed" bold headline
/// - "We couldn't verify your identity. Please try again or use your password." subtitle
/// - Red warning: "TOO MANY ATTEMPTS. PLEASE USE PASSWORD."
/// - "Try Again" muted slate-teal primary button
/// - "Use Password Instead" outlined button
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
