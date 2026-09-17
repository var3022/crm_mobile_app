import "package:flutter/material.dart";
import "onboarding_skip_confirmation_screen.dart";

/// Route screen alias for Onboarding Skip Confirmation (`screen-onboarding-skip-confirmation`)
class ScreenOnboardingSkipConfirmation extends StatelessWidget {
  final String? skippedFromRoute;
  final VoidCallback? onGoBack;
  final VoidCallback? onSkipAnyway;

  const ScreenOnboardingSkipConfirmation({
    super.key,
    this.skippedFromRoute,
    this.onGoBack,
    this.onSkipAnyway,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingSkipConfirmationScreen(
      skippedFromRoute: skippedFromRoute,
      onGoBack: onGoBack,
      onSkipAnyway: onSkipAnyway,
    );
  }
}
