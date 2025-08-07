import 'package:breathe_flow/models/user.dart';
import 'package:breathe_flow/providers/auth_provider.dart';
import 'package:breathe_flow/screens/home_screen.dart';
import 'package:breathe_flow/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthProvider>(context);

    return StreamBuilder<AppUser?>(
      stream: authService.user,
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
          return const HomeScreen(); // Or your main navigation screen
        } else {
          // User is not logged in, show the login screen
          return const LoginScreen();
        }
      },
    );
  }
} 