import 'package:flutter/material.dart';

/// Hedef kitleyi ve uygulama deneyimini ayıran iki temel mod
enum AppMode {
  /// Dinlendirici, uyku, rahatlama ve stres yönetimi (Mevcut Tema)
  mind,
  
  /// Aktif, kas geliştirme, duruş düzeltme ve yapay zeka antrenörü (Yeni Tema)
  body
}

class AppModeProvider extends ChangeNotifier {
  AppMode _currentMode = AppMode.mind;

  AppMode get currentMode => _currentMode;

  /// Şalter şu an "Beden (Fitness)" tarafında mı?
  bool get isBodyMode => _currentMode == AppMode.body;
  
  /// Şalter şu an "Zihin (Rahatlama)" tarafında mı?
  bool get isMindMode => _currentMode == AppMode.mind;

  /// Modlar arası animasyonlu geçişi tetikler
  void toggleMode() {
    if (_currentMode == AppMode.mind) {
      _currentMode = AppMode.body;
    } else {
      _currentMode = AppMode.mind;
    }
    notifyListeners();
  }

  /// Doğrudan istenilen moda ayarlar
  void setMode(AppMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }
}
