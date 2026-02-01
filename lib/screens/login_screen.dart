import 'package:breathe_flow/screens/signup_screen.dart';
import 'package:breathe_flow/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:breathe_flow/constants/app_colors.dart';
import 'package:breathe_flow/constants/app_strings.dart';
import 'package:breathe_flow/constants/app_typography.dart';
import 'package:breathe_flow/widgets/professional_button.dart';
import '../providers/auth_provider.dart';

/// 🚶 Misafir Modu Wrapper - Kayıt olmadan kullanım
class _GuestModeWrapper extends StatelessWidget {
  const _GuestModeWrapper();

  @override
  Widget build(BuildContext context) {
    // Misafir modunda direkt ana ekranı göster
    return const MainNavigationScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _submitForm() async {
    if (!mounted) return;
    
    final isValid = _formKey.currentState?.validate() ?? false;
    
    if (isValid) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // signInWithEmail çağır - hata mesajı AuthProvider'da saklanacak
      // Consumer widget otomatik olarak güncellenecek
      await authProvider.signInWithEmail(email, password);
      
      // Başarılı giriş durumunda AuthWrapper otomatik yönlendirecek
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Şifre Sıfırlama',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'E-posta adresiniz',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'E-posta gelmezse spam/gereksiz klasörünü kontrol edin.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Lütfen e-posta adresinizi girin'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          return;
                        }
                        
                        final success = await authProvider.sendPasswordResetEmail(email);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Şifre sıfırlama bağlantısı gönderildi!'
                                    : authProvider.errorMessage ?? 'Bir hata oluştu',
                              ),
                              backgroundColor: success ? AppColors.success : AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Gönder',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primaryAccent),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🚶 Misafir olarak devam et - kayıt olmadan uygulamayı kullan
  void _continueAsGuest() {
    // Direkt ana ekrana git (AuthWrapper'ı bypass et)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const _GuestModeWrapper(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.1),
                
                // App icon
                Center(
                  child: Container(
                    width: isSmallScreen ? 70 : 80,
                    height: isSmallScreen ? 70 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.self_improvement,
                      size: isSmallScreen ? 35 : 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 24 : 32),
                
                Text(
                  AppStrings.welcomeBack,
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: isSmallScreen ? 22 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  AppStrings.continueJourney,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: screenHeight * 0.05),
                
                // Login form
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          labelText: AppStrings.emailAddress,
                          hintText: AppStrings.emailPlaceholder,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppStrings.emailRequired;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return AppStrings.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _passwordController,
                          labelText: AppStrings.password,
                          hintText: AppStrings.passwordPlaceholder,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppStrings.passwordRequired;
                            }
                            if (value!.length < 6) {
                              return AppStrings.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Hata mesajı gösterimi - Consumer ile AuthProvider'dan direkt oku
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final errorMsg = authProvider.errorMessage;
                            if (errorMsg == null || errorMsg.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.error.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorMsg,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotPasswordDialog(),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                                ),
                              );
                            }
                            
                            return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                AppStrings.loginButton,
                                style: AppTypography.buttonText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: AppStrings.noAccountYet,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signUpButton,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 🚶 Misafir olarak devam et
                Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.textTertiary.withOpacity(0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'veya',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.textTertiary.withOpacity(0.3))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => _continueAsGuest(),
                        icon: Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        label: Text(
                          'continueAsGuest'.tr(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.textTertiary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceElevated.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
} 