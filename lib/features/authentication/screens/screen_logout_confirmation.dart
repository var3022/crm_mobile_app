import "package:flutter/material.dart";
import "logout_confirmation_screen.dart";

/// Screen: Logout Confirmation (`screen-logout-confirmation`)
/// Direct route alias delegating to `LogoutConfirmationScreen`.
class ScreenLogoutConfirmation extends StatelessWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onCancel;

  const ScreenLogoutConfirmation({
    super.key,
    this.onSignOut,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return LogoutConfirmationScreen(
      onSignOut: onSignOut,
      onCancel: onCancel,
    );
  }
}
