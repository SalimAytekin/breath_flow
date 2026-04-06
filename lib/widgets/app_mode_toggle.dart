import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_mode_provider.dart';
import '../constants/app_colors.dart';

class AppModeToggle extends StatelessWidget {
  const AppModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<AppModeProvider>(context);
    final isBody = modeProvider.isBodyMode;

    return GestureDetector(
      onTap: () => modeProvider.toggleMode(),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Kaydırıcı Arka Plan (Gölge ve Aktif renk)
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: isBody ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isBody 
                        ? const LinearGradient(colors: [Color(0xFF8B5E3C), Color(0xFF5A3520)]) // Beden Rengi 
                        : const LinearGradient(colors: [Color(0xFF4A2C8A), Color(0xFF2D1B69)]), // Zihin Rengi
                    boxShadow: [
                      BoxShadow(
                        color: (isBody ? const Color(0xFF8B5E3C) : const Color(0xFF4A2C8A)).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Metinler ve İkonlar
            Row(
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: !isBody ? Colors.white : AppColors.textTertiary,
                      fontWeight: !isBody ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.nights_stay, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Zihin'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isBody ? Colors.white : AppColors.textTertiary,
                      fontWeight: isBody ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fitness_center, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Beden'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
