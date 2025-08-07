import 'dart:math';

class MotivationalQuotes {
  static final List<String> _quotes = [
    "Bugün, dün olduğundan daha iyi olmak için bir şans.",
    "Küçük adımlar, büyük başarılara yol açar.",
    "Nefes al, sakin ol ve anın tadını çıkar.",
    "Başlamak için mükemmel olmak zorunda değilsin, ama başlamak zorundasın.",
    "Her fırtınanın ardından bir gökkuşağı belirir.",
    "Zorluklar, zihnin kaslarını güçlendirir.",
    "Kendine inan, çünkü sen sandığından daha güçlüsün.",
    "Bugünün enerjisi, yarının gerçekliğini yaratır.",
    "Sadece bir nefes uzağında, huzur seni bekliyor.",
    "Hayat bir yolculuktur, manzaranın tadını çıkar.",
  ];

  static String getDailyQuote() {
    // Yılın gününe göre her gün farklı bir söz seçer.
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }
} 