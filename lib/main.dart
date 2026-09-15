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
      initialRoute: "/password-reset-success",
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
      },
    );
  }
}
