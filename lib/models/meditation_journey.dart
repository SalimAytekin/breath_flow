import 'package:flutter/material.dart';

class JourneyStep {
  final String id;
  final String title;
  final String duration; // "10 dk" gibi bir metin
  final String audioPath;
  bool isCompleted;

  JourneyStep({
    required this.id,
    required this.title,
    required this.duration,
    required this.audioPath,
    this.isCompleted = false,
  });
}

class MeditationJourney {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final Color color;
  final List<JourneyStep> steps;

  MeditationJourney({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
    required this.steps,
  });

  // İlerleme hesaplaması
  double get progress {
    if (steps.isEmpty) return 0.0;
    final completedSteps = steps.where((step) => step.isCompleted).length;
    return completedSteps / steps.length;
  }

  // Örnek veri
  static List<MeditationJourney> sampleJourneys = [
    MeditationJourney(
      id: 'stres_azaltma',
      title: '7 Günlük Stres Azaltma',
      description: 'Zihninizi sakinleştirin ve stresi yönetmeyi öğrenin.',
      imagePath: 'assets/images/sounds/forest.jpg', // Örnek görsel
      color: Colors.green,
      steps: List.generate(7, (index) => JourneyStep(
        id: 'stres_gun_${index + 1}',
        title: 'Gün ${index + 1}: Farkındalık Nefesi',
        duration: '10 dk',
        audioPath: 'placeholder.mp3'
      )),
    ),
    MeditationJourney(
      id: 'uyku_kalitesi',
      title: 'Daha İyi Uyu',
      description: 'Uyku kalitenizi artıracak rehberli pratikler.',
      imagePath: 'assets/images/sounds/rain.jpg', // Örnek görsel
      color: Colors.blue,
      steps: List.generate(5, (index) => JourneyStep(
        id: 'uyku_gun_${index + 1}',
        title: 'Gece Meditasyonu ${index + 1}',
        duration: '12 dk',
        audioPath: 'placeholder.mp3'
      )),
    ),
     MeditationJourney(
      id: 'oz_sefkat',
      title: 'Öz Şefkat Yolculuğu',
      description: 'Kendinize karşı daha nazik ve anlayışlı olun.',
      imagePath: 'assets/images/sounds/meditation_bell.jpg', // Örnek görsel
      color: Colors.purple,
      steps: List.generate(10, (index) => JourneyStep(
        id: 'sefkat_gun_${index + 1}',
        title: 'Şefkat Pratiği ${index + 1}',
        duration: '8 dk',
        audioPath: 'placeholder.mp3'
      )),
    ),
  ];
} 