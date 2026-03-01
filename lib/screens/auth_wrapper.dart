import 'package:breathe_flow/screens/main_navigation_screen.dart';
import 'package:breathe_flow/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// 🔐 Auth Wrapper - Giriş Kontrolü
/// Kullanıcı giriş yapmışsa → Ana ekran (otomatik)
/// Kullanıcı giriş yapmamışsa → Login ekranı
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;
  
  @override
  void initState() {
    super.initState();
    // Firebase Auth durumunu kontrol et
    _checkAuthState();
  }
  
  Future<void> _checkAuthState() async {
    // Kısa bir bekleme - Firebase Auth state'inin yüklenmesi için
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // İlk yükleme durumu - splash göster
        if (_isInitializing || authProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo veya animasyon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAccent,
                          AppColors.primaryAccent.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
          );
        }
        
        // Kullanıcı giriş yapmış mı?
        if (authProvider.isAuthenticated) {
          // ✅ Giriş yapılmış → Direkt ana ekran (login ekranı gösterme!)
          if (kDebugMode) {
            debugPrint('✅ Kullanıcı oturumu açık: ${authProvider.user?.email}');
          }
          return const MainNavigationScreen();
        } else {
          // ❌ Giriş yapılmamış → Login ekranı
          if (kDebugMode) {
            debugPrint('🔐 Kullanıcı giriş yapmamış, login ekranı gösteriliyor');
          }
          return const LoginScreen();
        }
      },
    );
  }
}