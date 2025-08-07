import 'package:breathe_flow/screens/login_screen.dart';
import 'package:breathe_flow/screens/main_navigation_screen.dart';
import 'package:breathe_flow/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, show the main app
          return const MainNavigationScreen();
        } else {
          // User is not logged in, show the login screen
          return const LoginScreen();
        }
      },
    );
  }
} 