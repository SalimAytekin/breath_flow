import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// 💎 Professional AppBar - Merkezi, Dinamik ve Yeniden Kullanılabilir
///
/// Bu AppBar, uygulama genelinde tutarlı, modern ve premium bir görünüm sağlar.
/// Kaydırma olaylarına göre arka plan rengini, saydamlığını ve blur efektini dinamik olarak ayarlar.
///
/// Özellikler:
/// - **Dinamik Saydamlık:** Sayfa aşağı kaydırıldıkça yavaşça opaklaşır.
/// - **Glassmorphism Efekti:** Kaydırma sırasında camsı bir blur efekti uygular.
/// - **Merkezi Stil:** Tüm AppBar'lar için tek bir stil ve davranış kaynağı.
/// - **Premium Renk:** Varsayılan siyah yerine sofistike `premiumBlack` rengini kullanır.
class ProfessionalAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final String title;
  final List<Widget>? actions;

  const ProfessionalAppBar({
    super.key,
    required this.scrollController,
    required this.title,
    this.actions,
  });

  @override
  State<ProfessionalAppBar> createState() => _ProfessionalAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProfessionalAppBarState extends State<ProfessionalAppBar> {
  double _opacity = 0.3; // Başlangıçta görünür olması için

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // AppBar'ın ne kadar kaydırıldıktan sonra tamamen opak olacağını belirler.
    const scrollThreshold = 100.0;
    final offset = widget.scrollController.hasClients ? widget.scrollController.offset : 0;
    // Opaklık değerini 0.3 ile 1.0 arasında sınırlar (minimum görünürlük için).
    final newOpacity = ((offset / scrollThreshold) * 0.7 + 0.3).clamp(0.3, 1.0);

    if (newOpacity != _opacity) {
      setState(() {
        _opacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AppBar(
          backgroundColor: AppColors.premiumBlack.withOpacity(0.8),
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.title, 
            style: AppTypography.headlineSmall.copyWith(color: Colors.white)
          ),
          leading: IconButton(
            icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: widget.actions?.map((action) {
            if (action is IconButton) {
              return IconButton(
                onPressed: action.onPressed,
                icon: Icon(
                  (action.icon as Icon).icon,
                  color: Colors.white,
                ),
              );
            }
            return action;
          }).toList(),
        ),
      ),
    );
  }
}
