import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

enum MoodType {
  relaxation,
  focus,
  sleep,
}

extension MoodTypeExtension on MoodType {
  String get name {
    switch (this) {
      case MoodType.relaxation:
        return AppStrings.relaxation;
      case MoodType.focus:
        return AppStrings.focus;
      case MoodType.sleep:
        return AppStrings.sleep;
    }
  }

  String get description {
    switch (this) {
      case MoodType.relaxation:
        return AppStrings.relaxationDesc;
      case MoodType.focus:
        return AppStrings.focusDesc;
      case MoodType.sleep:
        return AppStrings.sleepDesc;
    }
  }

  Color get color {
    switch (this) {
      case MoodType.relaxation:
        return AppColors.relaxation;
      case MoodType.focus:
        return AppColors.focus;
      case MoodType.sleep:
        return AppColors.sleep;
    }
  }



  IconData get icon {
    switch (this) {
      case MoodType.relaxation:
        return Icons.spa;
      case MoodType.focus:
        return Icons.center_focus_strong;
      case MoodType.sleep:
        return Icons.bedtime;
    }
  }
} 