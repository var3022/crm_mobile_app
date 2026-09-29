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
import "features/authentication/screens/logout_confirmation_screen.dart";
import "features/onboarding/screens/onboarding_welcome_screen.dart";
import "features/onboarding/screens/onboarding_location_screen.dart";
import "features/onboarding/screens/onboarding_camera_screen.dart";
import "features/onboarding/screens/onboarding_microphone_screen.dart";
import "features/onboarding/screens/onboarding_notifications_screen.dart";
import "features/onboarding/screens/onboarding_offline_setup_screen.dart";
import "features/onboarding/screens/onboarding_complete_screen.dart";
import "features/onboarding/screens/onboarding_skip_confirmation_screen.dart";
import "features/onboarding/screens/screen_onboarding_skip_confirmation.dart";
import "features/onboarding/screens/app_intro_walkthrough_screen.dart";
import "features/onboarding/screens/intro_slide_two_screen.dart";
import "features/onboarding/screens/intro_slide_three_screen.dart";
import "features/dashboard/screens/notifications_screen.dart";
import "features/leads/screens/empty_leads_screen.dart";
import "features/visits/screens/visits_list_screen.dart";
import "features/visits/screens/schedule_visit_screen.dart";
import "layout/layout.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CrmProApp());
}

class CrmProApp extends StatefulWidget {
  const CrmProApp({super.key});

  static bool isFirstTimeSetup = true;

  @override
  State<CrmProApp> createState() => _CrmProAppState();
}

class _CrmProAppState extends State<CrmProApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CRM Pro Field Sales",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(
          onFinished: () {
            Navigator.of(context).pushReplacementNamed("/sign-in");
          },
          onAuthenticated: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
        ),
        "/splash": (context) => SplashScreen(
          onFinished: () {
            Navigator.of(context).pushReplacementNamed("/sign-in");
          },
          onAuthenticated: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
        ),
        "/sign-in": (context) => SignInScreen(
          isFirstTimeSetup: CrmProApp.isFirstTimeSetup,
          onSignInSuccess: () {
            if (CrmProApp.isFirstTimeSetup) {
              CrmProApp.isFirstTimeSetup = false;
              Navigator.of(context).pushReplacementNamed("/onboarding-welcome");
            } else {
              Navigator.of(context).pushReplacementNamed("/dashboard");
            }
          },
          onForgotPassword: () {
            Navigator.of(context).pushNamed("/forgot-password");
          },
          onSignUp: () {
            Navigator.of(context).pushNamed("/sign-up");
          },
        ),
        "/sign-up": (context) => SignUpScreen(
          onSignUpSuccess: (email) {
            Navigator.of(context).pushNamed("/email-verification", arguments: email);
          },
          onSignInTap: () {
            Navigator.of(context).pushReplacementNamed("/sign-in");
          },
        ),
        "/email-verification": (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return EmailVerificationScreen(
            email: email ?? "j***@company.com",
            onBack: () {
              Navigator.of(context).maybePop();
            },
            onSignInTap: () {
              Navigator.of(context).pushReplacementNamed("/sign-in");
            },
          );
        },
        "/forgot-password": (context) => ForgotPasswordScreen(
          onBack: () {
            Navigator.of(context).maybePop();
          },
          onSignInTap: () {
            Navigator.of(context).pushReplacementNamed("/sign-in");
          },
          onSendCode: (email) {
            Navigator.of(context).pushNamed("/otp-verification", arguments: email);
          },
        ),
        "/otp-verification": (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return OtpVerificationScreen(
            email: email ?? "j***@company.com",
            onBack: () {
              Navigator.of(context).maybePop();
            },
            onSignInTap: () {
              Navigator.of(context).pushReplacementNamed("/sign-in");
            },
            onVerifySuccess: (code) {
              Navigator.of(context).pushNamed("/reset-password", arguments: code);
            },
          );
        },
        "/reset-password": (context) => ResetPasswordScreen(
          onBack: () {
            Navigator.of(context).maybePop();
          },
          onSignInTap: () {
            Navigator.of(context).pushReplacementNamed("/sign-in");
          },
          onResetSuccess: (newPassword) {
            Navigator.of(
              context,
            ).pushReplacementNamed("/password-reset-success");
          },
        ),
        "/password-reset-success": (context) => PasswordResetSuccessScreen(
          onBackToSignIn: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/sign-in", (route) => false);
          },
        ),
        "/biometric-login": (context) => BiometricLoginScreen(
          onAuthenticated: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
          onUsePasswordInstead: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/sign-in", (route) => false);
          },
        ),
        "/biometric-fail": (context) => BiometricFailScreen(
          onUsePasswordInstead: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/sign-in", (route) => false);
          },
          onTryAgain: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Re-verifying Face ID..."),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        "/screen-biometric-fail": (context) => BiometricFailScreen(
          onUsePasswordInstead: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/sign-in", (route) => false);
          },
          onTryAgain: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Re-verifying Face ID..."),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        "/logout-confirmation": (context) => LogoutConfirmationScreen(
          onSignOut: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/sign-in", (route) => false);
          },
          onCancel: () {
            Navigator.of(context).maybePop();
          },
        ),
        "/screen-logout-confirmation": (context) => LogoutConfirmationScreen(
          onSignOut: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("/sign-in", (route) => false);
          },
          onCancel: () {
            Navigator.of(context).maybePop();
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
            Navigator.of(context).pushNamed(
              "/onboarding-camera",
              arguments: {"skippedFrom": "/onboarding-location"},
            );
          },
        ),
        "/onboarding-camera": (context) => OnboardingCameraScreen(
          onAllowCamera: () {
            Navigator.of(context).pushNamed("/onboarding-microphone");
          },
          onSkip: () {
            Navigator.of(context).pushNamed(
              "/onboarding-microphone",
              arguments: {"skippedFrom": "/onboarding-camera"},
            );
          },
        ),
        "/onboarding-microphone": (context) => OnboardingMicrophoneScreen(
          onAllowMicrophone: () {
            Navigator.of(context).pushNamed("/onboarding-notifications");
          },
          onSkip: () {
            Navigator.of(context).pushNamed(
              "/onboarding-notifications",
              arguments: {"skippedFrom": "/onboarding-microphone"},
            );
          },
        ),
        "/onboarding-notifications": (context) => OnboardingNotificationsScreen(
          onAllowNotifications: () {
            Navigator.of(
              context,
            ).pushReplacementNamed("/onboarding-offline-setup");
          },
          onSkip: () {
            Navigator.of(context).pushNamed(
              "/onboarding-offline-setup",
              arguments: {"skippedFrom": "/onboarding-notifications"},
            );
          },
        ),
        "/onboarding-offline-setup": (context) => OnboardingOfflineSetupScreen(
          onDownloadComplete: () {
            Navigator.of(context).pushReplacementNamed("/onboarding-complete");
          },
          onSkip: () {
            Navigator.of(context).pushNamed(
              "/onboarding-skip-confirmation",
              arguments: {"skippedFrom": "/onboarding-offline-setup"},
            );
          },
        ),
        "/onboarding-complete": (context) => OnboardingCompleteScreen(
          onContinue: () {
            Navigator.of(
              context,
            ).pushReplacementNamed("/app-intro-walkthrough");
          },
        ),
        "/onboarding-skip-confirmation": (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final skippedFrom =
              args?["skippedFrom"] as String? ?? "/onboarding-offline-setup";
          return OnboardingSkipConfirmationScreen(
            skippedFromRoute: skippedFrom,
            onGoBack: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(skippedFrom);
              }
            },
            onSkipAnyway: () {
              Navigator.of(
                context,
              ).pushReplacementNamed("/onboarding-complete");
            },
          );
        },
        "/screen-onboarding-skip-confirmation": (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final skippedFrom =
              args?["skippedFrom"] as String? ?? "/onboarding-offline-setup";
          return ScreenOnboardingSkipConfirmation(
            skippedFromRoute: skippedFrom,
            onGoBack: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(skippedFrom);
              }
            },
            onSkipAnyway: () {
              Navigator.of(
                context,
              ).pushReplacementNamed("/onboarding-complete");
            },
          );
        },
        "/app-intro-walkthrough": (context) => AppIntroWalkthroughScreen(
          onFinished: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
          onSkip: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
        ),
        "/onboarding-walkthrough": (context) => AppIntroWalkthroughScreen(
          onFinished: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
          onSkip: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
        ),
        "/intro-slide-two": (context) => IntroSlideTwoScreen(
          onNext: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
          onSkip: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
        ),
        "/onboarding-intro-slide-two": (context) => IntroSlideTwoScreen(
          onNext: () {
            Navigator.of(context).pushReplacementNamed("/intro-slide-three");
          },
          onSkip: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
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
        "/dashboard": (context) => const MainLayoutScreen(initialIndex: 0),
        "/notifications": (context) => NotificationsScreen(
          onHomeTap: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
          onLeadsTap: () {
            Navigator.of(context).pushReplacementNamed("/leads-list");
          },
        ),
        "/empty-notifications": (context) => NotificationsScreen(
          startEmpty: true,
          onHomeTap: () {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          },
          onLeadsTap: () {
            Navigator.of(context).pushReplacementNamed("/leads-list");
          },
        ),
        "/leads-list": (context) => const MainLayoutScreen(initialIndex: 1),
        "/leads": (context) => const MainLayoutScreen(initialIndex: 1),
        "/screen-leads-list": (context) => const MainLayoutScreen(initialIndex: 1),
        "/empty-leads": (context) => const EmptyLeadsScreen(),
        "/screen-empty-leads": (context) => const ScreenEmptyLeads(),
        "/visits": (context) => const MainLayoutScreen(initialIndex: 2),
        "/visits-list": (context) => const MainLayoutScreen(initialIndex: 2),
        "/screen-visits-list": (context) => const MainLayoutScreen(initialIndex: 2),
        "/empty-visits": (context) => const VisitsListScreen(startEmpty: true),
        "/screen-empty-visits": (context) => const VisitsListScreen(startEmpty: true),
        "/schedule-visit": (context) => const ScheduleVisitScreen(),
        "/screen-schedule-visit": (context) => const ScreenScheduleVisit(),
      },
    );
  }
}
