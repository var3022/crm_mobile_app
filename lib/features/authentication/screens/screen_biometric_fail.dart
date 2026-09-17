import "package:flutter/material.dart";
import "biometric_login_screen.dart";

/// Screen: Biometric Fail (`screen-biometric-fail`)
/// Reuses the existing `BiometricLoginScreen` component with `isFailed: true`.
class ScreenBiometricFail extends StatelessWidget {
  final VoidCallback? onUsePasswordInstead;
  final VoidCallback? onTryAgain;
  final VoidCallback? onAuthenticated;

  const ScreenBiometricFail({
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
