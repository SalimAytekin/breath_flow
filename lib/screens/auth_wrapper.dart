import 'package:breathe_flow/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';

///  Auth Wrapper - Giriş Opsiyonel
///  User can login from the profile screen
///  If the user is not logged in, the app will directly navigate to the main screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly navigate to the main screen
    // User can login from the profile screen
    return const MainNavigationScreen();
  }
}