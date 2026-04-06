import 'package:flutter/material.dart';
import '../models/fitness_exercise.dart';

/// Global kullanıcı hedefi state'i.
/// Onboarding'de seçilir, recommendation mantığında kullanılır.
class UserGoalProvider extends ChangeNotifier {
  UserGoal _goal = UserGoal.posture;
  int _durationMinutes = 10;
  bool _onboardingDone = false;

  UserGoal get goal => _goal;
  int get durationMinutes => _durationMinutes;
  bool get onboardingDone => _onboardingDone;

  void setGoal(UserGoal goal) {
    _goal = goal;
    notifyListeners();
  }

  void setDuration(int minutes) {
    _durationMinutes = minutes;
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingDone = true;
    notifyListeners();
  }

  void resetOnboarding() {
    _onboardingDone = false;
    notifyListeners();
  }
}
