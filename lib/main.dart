import "package:flutter/material.dart";
import "core/theme/app_theme.dart";
import "features/authentication/screens/splash_screen.dart";
import "features/authentication/screens/sign_in_screen.dart";
import "features/authentication/screens/sign_up_screen.dart";
import "features/authentication/screens/email_verification_screen.dart";
import "features/authentication/screens/forgot_password_screen.dart";
import "features/authentication/screens/otp_verification_screen.dart";
import "features/authentication/screens/reset_password_screen.dart";
import "features/authentication/screens/password_reset_success_screen.dart";
import "features/authentication/screens/biometric_login_screen.dart";
import "features/onboarding/screens/onboarding_welcome_screen.dart";
import "features/onboarding/screens/onboarding_location_screen.dart";
import "features/onboarding/screens/onboarding_camera_screen.dart";
import "features/onboarding/screens/onboarding_microphone_screen.dart";
import "features/onboarding/screens/onboarding_notifications_screen.dart";
import "features/onboarding/screens/onboarding_offline_setup_screen.dart";
import "features/onboarding/screens/onboarding_complete_screen.dart";
import "features/onboarding/screens/app_intro_walkthrough_screen.dart";
import "features/onboarding/screens/intro_slide_two_screen.dart";
import "features/onboarding/screens/intro_slide_three_screen.dart";
import "features/dashboard/screens/dashboard_screen.dart";
import "features/dashboard/screens/notifications_screen.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CrmProApp());
}

class CrmProApp extends StatelessWidget {
  const CrmProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CRM Pro Field Sales",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: "/app-intro-walkthrough",
      routes: {
        "/": (context) => SplashScreen(
              onFinished: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
            ),
        "/splash": (context) => SplashScreen(
              onFinished: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
            ),
        "/sign-in": (context) => SignInScreen(
              onForgotPassword: () {
                Navigator.of(context).pushNamed("/forgot-password");
              },
              onContactSupport: () {},
            ),
        "/sign-up": (context) => SignUpScreen(
              onSignUpSuccess: () {
                Navigator.of(context).pushNamed("/verify-email");
              },
              onSignInTap: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
            ),
        "/verify-email": (context) => EmailVerificationScreen(
              onBack: () {
                Navigator.of(context).maybePop();
              },
              onSignInTap: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
            ),
        "/forgot-password": (context) => ForgotPasswordScreen(
              onBack: () {
                Navigator.of(context).maybePop();
              },
              onSignInTap: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
              onSendCode: (email) {
                Navigator.of(context).pushNamed("/otp-verification");
              },
            ),
        "/otp-verification": (context) => OtpVerificationScreen(
              email: "j***@company.com",
              onBack: () {
                Navigator.of(context).maybePop();
              },
              onSignInTap: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
              onVerifySuccess: (code) {
                Navigator.of(context).pushNamed("/reset-password");
              },
            ),
        "/reset-password": (context) => ResetPasswordScreen(
              onBack: () {
                Navigator.of(context).maybePop();
              },
              onSignInTap: () {
                Navigator.of(context).pushReplacementNamed("/sign-in");
              },
              onResetSuccess: (newPassword) {
                Navigator.of(context).pushReplacementNamed("/password-reset-success");
              },
            ),
        "/password-reset-success": (context) => PasswordResetSuccessScreen(
              onBackToSignIn: () {
                Navigator.of(context).pushNamedAndRemoveUntil("/sign-in", (route) => false);
              },
            ),
        "/biometric-login": (context) => BiometricLoginScreen(
              onAuthenticated: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Face ID Authenticated! Welcome to CRM Pro."),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              onUsePasswordInstead: () {
                Navigator.of(context).pushNamedAndRemoveUntil("/sign-in", (route) => false);
              },
            ),
        "/onboarding-welcome": (context) => OnboardingWelcomeScreen(
              onLetsGo: () {
                Navigator.of(context).pushNamed("/onboarding-location");
              },
            ),
        "/onboarding-location": (context) => OnboardingLocationScreen(
              onAllowLocation: () {
                Navigator.of(context).pushNamed("/onboarding-camera");
              },
              onSkip: () {
                Navigator.of(context).pushNamed("/onboarding-camera");
              },
            ),
        "/onboarding-camera": (context) => OnboardingCameraScreen(
              onAllowCamera: () {
                Navigator.of(context).pushNamed("/onboarding-microphone");
              },
              onSkip: () {
                Navigator.of(context).pushNamed("/onboarding-microphone");
              },
            ),
        "/onboarding-microphone": (context) => OnboardingMicrophoneScreen(
              onAllowMicrophone: () {
                Navigator.of(context).pushNamed("/onboarding-notifications");
              },
              onSkip: () {
                Navigator.of(context).pushNamed("/onboarding-notifications");
              },
            ),
        "/onboarding-notifications": (context) => OnboardingNotificationsScreen(
              onAllowNotifications: () {
                Navigator.of(context).pushReplacementNamed("/onboarding-offline-setup");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/onboarding-offline-setup");
              },
            ),
        "/onboarding-offline-setup": (context) => OnboardingOfflineSetupScreen(
              onDownloadComplete: () {
                Navigator.of(context).pushReplacementNamed("/onboarding-complete");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/onboarding-complete");
              },
            ),
        "/onboarding-complete": (context) => OnboardingCompleteScreen(
              onContinue: () {
                Navigator.of(context).pushReplacementNamed("/app-intro-walkthrough");
              },
            ),
        "/app-intro-walkthrough": (context) => AppIntroWalkthroughScreen(
              onFinished: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
            ),
        "/onboarding-walkthrough": (context) => AppIntroWalkthroughScreen(
              onFinished: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
            ),
        "/intro-slide-two": (context) => IntroSlideTwoScreen(
              onNext: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
            ),
        "/onboarding-intro-slide-two": (context) => IntroSlideTwoScreen(
              onNext: () {
                Navigator.of(context).pushReplacementNamed("/intro-slide-three");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              },
            ),
        "/intro-slide-three": (context) => IntroSlideThreeScreen(
              onGetStarted: () {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              },
            ),
        "/onboarding-intro-slide-three": (context) => IntroSlideThreeScreen(
              onGetStarted: () {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              },
              onSkip: () {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              },
            ),
        "/dashboard": (context) => DashboardScreen(
              onNotificationTap: () {
                Navigator.of(context).pushNamed("/notifications");
              },
              onViewAllMapTap: () {},
              onFabTap: () {},
              onViewBriefTap: () {},
            ),
        "/screen-dashboard": (context) => DashboardScreen(
              onNotificationTap: () {
                Navigator.of(context).pushNamed("/notifications");
              },
              onViewAllMapTap: () {},
              onFabTap: () {},
              onViewBriefTap: () {},
            ),
        "/notifications": (context) => NotificationsScreen(
              onHomeTap: () {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              },
            ),
        "/screen-notification": (context) => NotificationsScreen(
              onHomeTap: () {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              },
            ),
      },
    );
  }
}

