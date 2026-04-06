import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// ENUM'LAR
// ─────────────────────────────────────────────

enum FitnessCategory { posture, strength, mobility, quick }

/// Kullanıcının onboarding'de seçtiği ana hedef.
/// Recommendation mantığının temelidir.
enum UserGoal { posture, strength, mobility, quick }

enum DifficultyLevel { beginner, intermediate, advanced }

// ─────────────────────────────────────────────
// FitnessExercise
// ─────────────────────────────────────────────

class FitnessExercise {
  final String id;
  final String name;
  final String description;
  final FitnessCategory category;
  final DifficultyLevel difficulty;
  final String durationLabel;
  final String icon;
  final String muscleGroup;
  final bool isAiEnabled;
  final String? nativeExerciseKey;

  const FitnessExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationLabel,
    required this.icon,
    required this.muscleGroup,
    this.isAiEnabled = false,
    this.nativeExerciseKey,
  });
}

// ─────────────────────────────────────────────
// FitnessProgram
// ─────────────────────────────────────────────

class FitnessProgram {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String whyItWorks;       // "Neden işe yarar" alanı
  final FitnessCategory category;
  final List<FitnessExercise> exercises;
  final String totalDuration;
  final int weekCount;           // Kaç haftalık program (0 = tek seferlik)
  final DifficultyLevel difficulty;
  final String icon;
  final bool isNew;
  final bool isPremium;
  final bool isFeatured;         // Kategori sayfasında öne çıkar

  const FitnessProgram({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.whyItWorks,
    required this.category,
    required this.exercises,
    required this.totalDuration,
    this.weekCount = 0,
    this.difficulty = DifficultyLevel.beginner,
    required this.icon,
    this.isNew = false,
    this.isPremium = false,
    this.isFeatured = false,
  });

  // Computed properties
  int get exerciseCount => exercises.length;

  String get categoryLabel {
    switch (category) {
      case FitnessCategory.posture:   return 'POSTURE';
      case FitnessCategory.strength:  return 'STRENGTH';
      case FitnessCategory.mobility:  return 'MOBILITY';
      case FitnessCategory.quick:     return 'QUICK';
    }
  }

  Color get categoryColor {
    switch (category) {
      case FitnessCategory.posture:   return const Color(0xFF64FFDA);
      case FitnessCategory.strength:  return const Color(0xFFFF8A00);
      case FitnessCategory.mobility:  return const Color(0xFFEA80FC);
      case FitnessCategory.quick:     return const Color(0xFF448AFF);
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:      return 'Başlangıç';
      case DifficultyLevel.intermediate:  return 'Orta';
      case DifficultyLevel.advanced:      return 'İleri';
    }
  }
}
