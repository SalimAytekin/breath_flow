class SmartRecommendation {
  final String title;
  final String description;
  final String ctaText; // Call to Action Text (e.g., "Hadi Başlayalım")
  final Function() onCtaPressed; // Eyleme tıklandığında ne olacağı
  final String icon; // Gösterilecek ikon (örneğin 'assets/icons/moon.svg')

  SmartRecommendation({
    required this.title,
    required this.description,
    required this.ctaText,
    required this.onCtaPressed,
    required this.icon,
  });
} 