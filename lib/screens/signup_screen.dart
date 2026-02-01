import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:breathe_flow/constants/app_colors.dart';
import 'package:breathe_flow/constants/app_strings.dart';
import 'package:breathe_flow/constants/app_typography.dart';
import 'package:breathe_flow/widgets/professional_button.dart';
import 'package:breathe_flow/providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUpWithEmail(email, password);

      if (mounted) {
        if (success) {
          // ✅ Kayıt başarılı - Ana ekrana yönlendir
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // ❌ Kayıt başarısız - Hata mesajını göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? AppStrings.signupFailed),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isSmallScreen ? 20 : screenHeight * 0.05),
                
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
                  AppStrings.joinUs,
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: isSmallScreen ? 22 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  AppStrings.startJourney,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: isSmallScreen ? 20 : screenHeight * 0.05),
                
                // Signup form
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
                          controller: _nameController,
                          labelText: AppStrings.fullName,
                          hintText: AppStrings.fullNamePlaceholder,
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppStrings.fullNameRequired;
                            }
                            if (value!.length < 2) {
                              return AppStrings.fullNameMinLength;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
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
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _confirmPasswordController,
                          labelText: AppStrings.confirmPassword,
                          hintText: AppStrings.passwordPlaceholder,
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppStrings.confirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return AppStrings.passwordsNotMatch;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Terms and conditions
                        Text(
                          'Devam ederek, Kullanım Şartları ve Gizlilik Politikamızı kabul etmiş olursunuz.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
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
                                  AppStrings.signUpNow,
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
                    onPressed: () => Navigator.pop(context),
                    child: Text.rich(
                      TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.loginNow,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 13 : 14,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
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